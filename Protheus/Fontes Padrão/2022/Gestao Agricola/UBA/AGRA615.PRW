#INCLUDE "AGRA615.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMBROWSE.ch"
#INCLUDE "FWMVCDEF.ch"

Static lEsteira := SuperGetMV("MV_AGRESTE",.T.,.F.)
Static nQuantMala := SuperGetMV("MV_AGRQTML", ,50)
Static lAutMala	  := SuperGetMv("MV_AGRMALA", ,.T.) // Mala Automática ou Manual, Padrão: Automática
Static oArqTemp  := Nil
Static nRendMax := 100 // Rendimento maximo de algodão em pluma por fardao
Static lRPO17	:= GetRPORelease() < '12.1.023'
Static __nFdiLq := CriaVar('DXI_PSLIQU'	, .F.)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA615
Rotina de Beneficiamento de Algodão

@author: carlos.augusto
@since: 28/02/2017
@Uso: SIGAAGR(UBA)
------------------------------------------------------------------------------------------ **/
Function AGRA615()
	Private lReload := .T.
	Private _lNovSafra 	:= .F.

	if NN1->(ColumnPos('NN1_CODSAF' )) > 0
		_lNovSafra := .T.
	endIf

	While lReload
		lReload := .F.
		AGRA615A( )
	EndDo
Return( Nil )

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA615
Rotina de Beneficiamento de Algodão

@author: Aécio Gomes
@since: 15/03/2012
@Uso: SIGAAGR(UBA)
------------------------------------------------------------------------------------------ **/
Function AGRA615A( )
	Local aCoors		:= FWGetDialogSize( oMainWnd )
	Local bKeyF12	
	Local bKeyF9	
	Local cRendimento	:= STR0001 + chr(13) + chr(10) + '0,00%' //"Rendimento"
	Local lEtiq			:= .T.
	Local nTam			:= 0
	Local nColAnt 		:= 0
	Local oFntAB32		:= Nil
	Local oFont19n 		:= TFont():New( "Arial" , , 19, , .T., , , , , .F. )
	Local oSize,  oSize1,   oSize2,   oSize3
	Local oSay01, oSay02,   oSay03,   oSay04,   oSay05,    oSay06,  oSay07, oSay08, oSay09, oSay10
	Local oSay11, oSay12,   oSay13,   oSay14,   oSay15,    oSay16 , oSay17, oSay21, oSay22, oSay24, oSayProdut,oSayDProd
	Local oFWL,   oPnlWnd1, oPnlWnd2, oPnlWnd3, oWnd2Pnl1
	Local oBut2,    oBut3
	Local nOcultUNB := 0 //Conta a quantidade de posições
	Local ConsBen	:= "DXLBEN" //Consulta padrao de Fardoes
	Local lAG615SXB := ExistBlock('AG615SXB') 
	Local lAG615FRDA := ExistBlock('AG615FRDA')

	Private oBut1

	Private aPerBal		:= AGRX003E( .F., 'AGRA615001' )
	Private oPnlRend, oBrowse, oPnlWnd5, oPnlWnd6, oPnlWnd7, oPnlWnd8, oPnlWnd9, oPnlWndML

	//Mala
	Private aMalaDb		:= {} //Mala atual no browse
	Private aMalaComp   := {} //Mala atual com as amostras
	Private oPnlCnj, oPnlPrensa, oPnlEtiq, oPnlFardo, oPnlPesoBr, oPnlPesoLq, oPnlAmost
	Private cMalaAtual := "" //Controla a mala que esta em tela

	//Gets dos totalizadores
	Private nTotFdi 	:= 0, nTotBrut:= 0, nTotLiqu := 0
	Private oGTotFdi, oGTotBrut, oGTotLiqu

	//Gets da tela de Dados do Fardão
	Private oGSafra, oGProdutor, oGLJPro, oGNmPdtor, oGCodFaz, oGNomeFaz, oGCodVar, oGDescVar, oGCodFda, oGPsLiqu, oGCodTur, oGDtBenef, oEsteira, oGCodProd, oGDescPro
	Private cSafra		
	Private cProdutor	:= iif(lRPO17,CriaVar('DX8_CODIGO',.F.),CriaVar('NJ0_CODENT',.F.) )
	Private cLjPro		:= iif(lRPO17,CriaVar('DX8_LOJA'  ,.F.),CriaVar('NJ0_LOJENT',.F.) )
	Private cNmPdtor	:= iif(lRPO17,CriaVar('DX8_NOME'  ,.F.),CriaVar('NJ0_NOME'	,.F.) )
	Private cCodFaz		:= CriaVar('NN2_CODIGO'	, .F.)
	Private cNomeFaz	:= CriaVar('NN2_NOME' 	, .F.)
	Private cCodProdut  := CriaVar('B1_COD' 	, .F.)
	Private cDescPro	:= CriaVar('B1_DESC' 	, .F.)
	Private cLocalPro	:= CriaVar('B1_LOCPAD' 	, .F.)
	Private cCodVar		:= CriaVar('NNV_CODIGO' , .F.)
	Private cDescVar	:= CriaVar('NNV_DESCRI' , .F.)
	Private cCodFda		:= CriaVar('DXL_CODIGO' , .F.)
	Private nPsLiqu		:= CriaVar('DXL_PSLIQU' , .F.)
	Private cCodTur		:= CriaVar('H7_CODIGO'	, .F.)
	Private DtBenef		:= CriaVar('DXL_DTBEN'	, .F.)
	Private cUNB        := A655GETUNB( )  
	Private cCodUNB     := CriaVar('DXL_CODUNB' , .F.)

	//Gets da tela de lançamento da produção
	Private oCFdiTip, oGCodCnj, oGPrensa, oGCodEtq, oGCodFdi, oGFdiPBr, oGFdiPLq
	Private lCostelado	:= .F.
	Private cCodCnj		:= CriaVar('DXI_CODCNJ'	, .F.)
	Private cPrensa		:= CriaVar('DXI_PRENSA'	, .F.)
	Private cCodEtq		:= CriaVar('DXI_ETIQ'  	, .F.)
	Private cCodFdi		:= CriaVar('DXI_CODIGO'	, .F.)
	Private nFdiPBr		:= CriaVar('DXI_PSBRUT'	, .F.)
	Private nFdiPLq		:= CriaVar('DXI_PSLIQU'	, .F.)

	Private aFardao 	:= {}
	Private cAliasTRB	:= Nil
	Private cAlTMPDXK	:= Nil
	Private oFntAB14	:= Nil

	//Mala
	Private oBrwMala
	Private cUserBenf := cUNB
	Private cClasVis  := SPACE(TAMSX3("DXK_CLAVIS")[1])
	Private cCodigo
	Private cEsteira

	Private lManutFard := !Empty(MV_PAR09) .And. MV_PAR09 == 1

	//Desenha a tela no formato esteira
	Private lTelaEst   := lEsteira .And. !lManutFard
	Private oDlg		:= Nil

	bKeyF12	 := SetKey( VK_F12, { || (A615INITVAR(.T.) ) } )
	If lAG615FRDA
		bKeyF9 := SetKey( VK_F9, { || (fTrataPEF9() ) } )
	EndIf

	If lAG615SXB // Ponto de entrada de troca de consulta padrao DXLBEN
		aRet := ExecBlock('AG615SXB',.F.,.F.)
		If ValType(aRet) == 'C'	//Caso o retorno do PE seja char, substitui a consulta padrao DXLBEN
			ConsBen	:= aRet
		EndIf
	Endif

	if _lNovSafra
		cSafra	:= CriaVar('NJU_CODSAF' , .F.)
	else
		cSafra	:= (CriaVar('NN1_ANO',.F.)+CriaVar('NN1_SEQ',.F.))
	endIf

	If TableInDic('N70')
		cEsteira    := CriaVar('N70_CODIGO' , .F.)
	else
		lAutMala := .F.
	endIf

	If !Empty(cUNB)
		cCodUNB := cUNB
		nOcultUNB := 1
	EndIf

	// Inicializador de Variaveis
	A615INITVAR(.F.)

	//Apresenta tela de pergunte caso nao tenha nenhuma balança configurada para o usuário
	If Empty(MV_PAR01)
		aPerBal := AGRX003E( .T., 'AGRA615001' )
		// Inicializador de Variaveis
		A615INITVAR(.F.)
	EndIf

	oFntAB32 	:= TFont():New( 'Arial Black', , -32, .T. )
	oFntAB14 	:= TFont():New( 'Arial Black', , -14, .T. )

	//- Coordenadas da area total da Dialog
	oSize := FWDefSize():New(.T.)
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {3,3,3,3}
	oSize:Process()

	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] TITLE STR0002 OF oMainWnd PIXEL //"Beneficiamento de Algodão Em Caroço"
	// Desabilita o fechamento da tela através da tela ESC.
	oDlg:lEscClose := .F.

	// Instancia o layer
	oFWL := FWLayer():New()
	// Inicia o Layer
	oFWL:init( oDlg, .F. )
	// Cria uma linha unica para o Layer
	oFWL:addLine( 'TOTAL', 100 , .F.)

	// Cria colunas
	oFWL:addCollumn( 'ESQ', 70, .F., 'TOTAL' )
	oFWL:addCollumn( 'DIR', 30, .F., 'TOTAL' )

	// Adiciona janelas no Layer
	If lTelaEst
		oFWL:addWindow( 'ESQ' , 'Wnd1', STR0003	,  18, .F., .T.,, 'TOTAL' ) //"Dados do Fardão"
		oFWL:addWindow( 'ESQ' , 'Wnd2', STR0004	,  67, .F., .T.,, 'TOTAL' ) //"Monitor da Produção"
		oFWL:addWindow( 'ESQ' , 'Wnd5', STR0066	,  15, .F., .T.,, 'TOTAL' ) //"Fila de Fardões"
	Else
		If TableInDic('N70')
			oFWL:addWindow( 'ESQ' , 'Wnd1', STR0003	,  32, .F., .T.,, 'TOTAL' ) //"Dados do Fardão"
			oFWL:addWindow( 'ESQ' , 'Wnd2', STR0004	,  68, .F., .T.,, 'TOTAL' ) //"Monitor da Produção"
		else
			oFWL:addWindow( 'ESQ' , 'Wnd1', STR0003	,  30, .F., .T.,, 'TOTAL' ) //"Dados do Fardão"
			oFWL:addWindow( 'ESQ' , 'Wnd2', STR0004	,  70, .F., .T.,, 'TOTAL' ) //"Monitor da Produção"
		endIf
	EndIf

	If lAutMala .And. !lManutFard //Nao e manutencao fardao
		oFWL:addWindow( 'DIR' , 'Wnd3', STR0005	,  58, .F., .T.,, 'TOTAL' ) //"Lançamento da Produção"
		oFWL:addWindow( 'DIR' , 'Wnd6', STR0076	,  17, .F., .T.,, 'TOTAL' ) //"Mala"
		oFWL:addWindow( 'DIR' , 'Wnd4', STR0006	,  25, .F., .T.,, 'TOTAL' ) //"Monitor de Rendimento"
	Else
		oFWL:addWindow( 'DIR' , 'Wnd3', STR0005	,  75, .F., .T.,, 'TOTAL' ) //"Lançamento da Produção"
		oFWL:addWindow( 'DIR' , 'Wnd4', STR0006	,  25, .F., .T.,, 'TOTAL' ) //"Monitor de Rendimento"
	EndIf

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:getWinPanel( 'ESQ', 'Wnd1', 'TOTAL' )
	oPnlWnd2:= oFWL:getWinPanel( 'ESQ', 'Wnd2', 'TOTAL' )
	oPnlWnd3:= oFWL:getWinPanel( 'DIR', 'Wnd3', 'TOTAL' )
	oPnlWnd4:= oFWL:getWinPanel( 'DIR', 'Wnd4', 'TOTAL' )

	If lTelaEst
		oPnlWnd5:= oFWL:getWinPanel( 'ESQ', 'Wnd5', 'TOTAL' )
		oPnlWnd6:= oFWL:getWinPanel( 'ESQ', 'Wnd5', 'TOTAL' )
		oPnlWnd7:= oFWL:getWinPanel( 'ESQ', 'Wnd5', 'TOTAL' )
		oPnlWnd8:= oFWL:getWinPanel( 'ESQ', 'Wnd5', 'TOTAL' )
		oPnlWnd9:= oFWL:getWinPanel( 'ESQ', 'Wnd5', 'TOTAL' )

		oPnlWnd5		:= TPanel():New(0,0  ,"",oPnlWnd5,oFntAB14,.T.,,CLR_BLACK,CLR_GREEN,50,20)
		oPnlWnd6		:= TPanel():New(0,60 ,"",oPnlWnd6,oFntAB14,.T.,,CLR_BLACK,CLR_GREEN,50,20)
		oPnlWnd7		:= TPanel():New(0,120,"",oPnlWnd7,oFntAB14,.T.,,CLR_BLACK,CLR_GREEN,50,20)
		oPnlWnd8		:= TPanel():New(0,180,"",oPnlWnd8,oFntAB14,.T.,,CLR_BLACK,CLR_GREEN,50,20)
		oPnlWnd9		:= TPanel():New(0,240,"",oPnlWnd9,oFntAB14,.T.,,CLR_BLACK,CLR_GREEN,50,20)

		oPnlWnd5:lVisible := .F.
		oPnlWnd6:lVisible := .F.
		oPnlWnd7:lVisible := .F.
		oPnlWnd8:lVisible := .F.
		oPnlWnd9:lVisible := .F.

	EndIf

	If lAutMala

		oPnlCnj 	:= oFWL:getWinPanel( 'DIR', 'Wnd3', 'TOTAL' )
		oPnlPrensa	:= oFWL:getWinPanel( 'DIR', 'Wnd3', 'TOTAL' )
		oPnlEtiq	:= oFWL:getWinPanel( 'DIR', 'Wnd3', 'TOTAL' )
		oPnlFardo	:= oFWL:getWinPanel( 'DIR', 'Wnd3', 'TOTAL' )
		oPnlPesoBr	:= oFWL:getWinPanel( 'DIR', 'Wnd3', 'TOTAL' )
		oPnlPesoLq	:= oFWL:getWinPanel( 'DIR', 'Wnd3', 'TOTAL' )

		oPnlCnj		:= TPanel():New(13,  2,"",oPnlCnj,,.T.,,,,50,30)
		oPnlPrensa	:= TPanel():New(13, 38,"",oPnlPrensa,,.T.,,,,50,30)
		oPnlEtiq	:= TPanel():New(38,  2,"",oPnlEtiq	,,.T.,,,,100,30)
		oPnlFardo	:= TPanel():New(63,  2,"",oPnlFardo	,,.T.,,,,60,30)
		oPnlPesoBr	:= TPanel():New(88,  2,"",oPnlPesoBr,,.T.,,,,60,30)
		oPnlPesoLq	:= TPanel():New(88, 60,"",oPnlPesoLq,,.T.,,,,60,30)

		IF !lManutFard
			oPnlWndML   := oFWL:getWinPanel( 'DIR', 'Wnd6', 'TOTAL' )
			oPnlWndML:= TPanel():New(0,0,"",oPnlWndML,,.T.,,,,200,60)
			oBrwMala := CriaBrowse()
		EndIf
	EndIf

	//- Recupera coordenadas da area superior da linha e coluna a esquerda do container
	oSize1 := FWDefSize():New(.F.)
	oSize1:AddObject('SUPER',100,100,.T.,.T.)
	oSize1:SetWindowSize({0,0,oPnlWnd1:NHEIGHT,oPnlWnd1:NWIDTH})
	oSize1:lProp 	:= .T.
	oSize1:aMargins := {3,3,3,3}
	oSize1:Process()

	//- Recupera coordenadas da area Inferior da linha e coluna a esquerda do container
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject('MONITOR',90,90,.T.,.T.)
	oSize2:AddObject('RODAPE',10,10,.T.,.T.)
	oSize2:SetWindowSize({0,0,oPnlWnd2:NHEIGHT,oPnlWnd2:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,0,0}
	oSize2:Process()

	// Painel para monitor de fardos beneficiados
	@ oSize2:aPosObj[1,1],oSize2:aPosObj[1,2] MSPANEL oWnd2Pnl1 OF oPnlWnd2 SIZE oSize2:aPosObj[1,4],oSize2:aPosObj[1,3]

	//- Recupera coordenadas da area superior da linha e coluna a direita do container
	oSize3 := FWDefSize():New(.F.)
	oSize3:AddObject('SUPER',100,100,.T.,.T.)
	oSize3:SetWindowSize({0,0,oPnlWnd3:NHEIGHT,oPnlWnd3:NWIDTH})
	oSize3:lProp 	:= .T.
	oSize3:aMargins := {3,3,3,3}
	oSize3:Process()

	//Label
	@ 0, 0 TO oSize3:aPosObj[1,3], oSize3:aPosObj[1,4] OF oPnlWnd3 PIXEL
	@ 0, 0 TO oPnlWnd4:NWIDTH, oPnlWnd4:NHEIGHT OF oPnlWnd4 PIXEL

	// Enchoice
	aTam := {{},{}}

	If lTelaEst
		If Empty(cUNB)
			AADD(aTam[1],TamSX3('DXL_CODUNB')[1])
		EndIf
		AADD(aTam[1],TamSX3('N70_CODIGO')[1])
		AADD(aTam[1],TamSX3('DXL_CODIGO')[1])
		AADD(aTam[1],TamSX3('DXL_PSLIQU')[1]-2)
		AADD(aTam[1],TamSX3('H7_CODIGO')[1])
		AADD(aTam[1],TamSX3('DXL_DTBEN')[1]+5)
	Else
		if _lNovSafra
			AADD(aTam[1],TamSX3('NJU_CODSAF')[1])
		else
			AADD(aTam[1],TamSX3('NN1_ANO')[1]+TamSX3('NN1_SEQ')[1])
		endIf

		AADD(aTam[1],iif(lRPO17,TamSX3('DX8_CODIGO')[1],TamSX3('NJ0_CODENT')[1]))
		AADD(aTam[1],iif(lRPO17,TamSX3('DX8_LOJA')[1]  ,TamSX3('NJ0_LOJENT')[1]))
		AADD(aTam[1],iif(lRPO17,30  ,40))//Travado para evitar reposicionamento de componentes na tela
		AADD(aTam[1],TamSX3('NN2_CODIGO')[1])
		AADD(aTam[1],30)//Travado para evitar reposicionamento de componentes na tela
	EndIf

	AADD(aTam[2],TamSX3('B1_COD')[1])
	AADD(aTam[2],50)//Travado para evitar reposicionamento de componentes na tela
	AADD(aTam[2],TamSX3('NNV_CODIGO')[1])
	AADD(aTam[2],15)//Travado para evitar reposicionamento de componentes na tela. 
	AADD(aTam[2],TamSX3('DXL_CODUNB')[1])
	AADD(aTam[2],TamSX3('DXL_CODIGO')[1])
	AADD(aTam[2],TamSX3('DXL_PSLIQU')[1])
	AADD(aTam[2],TamSX3('H7_CODIGO')[1]+1)
	AADD(aTam[2],TamSX3('DXL_DTBEN')[1]+5)

	aPos := {{},{}}
	AADD(aPos[1],0)

	If lTelaEst
		If Empty(cUNB)
			AADD(aPos[1],aTail(aPos[1])+aTam[1,1]+7)
		EndIf
		AADD(aPos[1],aTail(aPos[1])+aTam[1,2 - nOcultUNB]+6)
		AADD(aPos[1],aTail(aPos[1])+aTam[1,3 - nOcultUNB]+5)
		AADD(aPos[1],aTail(aPos[1])+aTam[1,4 - nOcultUNB]+2)
		AADD(aPos[1],aTail(aPos[1])+aTam[1,5 - nOcultUNB]+7)
		AADD(aPos[1],aTail(aPos[1])+aTam[1,6 - nOcultUNB])
	Else
		AADD(aPos[1],aTail(aPos[1])+aTam[1,1]+3)
		AADD(aPos[1],aTail(aPos[1])+aTam[1,2]+5)
		AADD(aPos[1],aTail(aPos[1])+aTam[1,3]+5)
		AADD(aPos[1],aTail(aPos[1])+aTam[1,4]+3)
		AADD(aPos[1],aTail(aPos[1])+aTam[1,5]+6)
		AADD(aPos[1],aTail(aPos[1])+aTam[1,6]+3)
	EndIf

	AADD(aPos[2],0)
	AADD(aPos[2],aTail(aPos[2])+aTam[2,1]+3)
	AADD(aPos[2],aTail(aPos[2])+aTam[2,2]+2)
	AADD(aPos[2],aTail(aPos[2])+aTam[2,3]+5)
	AADD(aPos[2],aTail(aPos[2])+aTam[2,4]+2)
	AADD(aPos[2],aTail(aPos[2])+aTam[2,5]+6)
	AADD(aPos[2],aTail(aPos[2])+aTam[2,6]+6)
	AADD(aPos[2],aTail(aPos[2])+aTam[2,7]+1)
	AADD(aPos[2],aTail(aPos[2])+aTam[2,8]+7)
	AADD(aPos[2],aTail(aPos[2])+aTam[2,9]+6)

	aPosGet := MsObjGetPos(oSize:aWindSize[4], 315, aPos)
	aTamGet := MsObjGetPos(oSize:aWindSize[4], 315, aTam)

	If lTelaEst
		If Empty(cUNB)
			oSay22     := TSay():New( oSize1:aPosObj[1,1], aPosGet[1,1] , {|| OemToAnsi( STR0056) } ,oPnlWnd1,,, .f., .f., .f., .t., , , Len(STR0056)*4, 009 ) //"DataBenef"###"DataBenef"
			oGUnBenef  := TGet():New( oSize1:aPosObj[1,1]+8, aPosGet[1,1] , bSetGet( IIF(EMPTY(cCodUNB),IIF(EMPTY(mv_par10),cCodUNB,mv_par10),cCodUNB) ),oPnlWnd1, aTamGet[1,1], 009, PesqPict('DXL','DXL_CODUNB'), { || A615CodUNB() },,,,,, .t.,,, {|| .t.},,,,,, 'DX3' )			
		EndIf

		oSay24     := TSay():New( oSize1:aPosObj[1,1],  aPosGet[1,2 - nOcultUNB], {|| OemToAnsi( STR0065 )} ,oPnlWnd1, , , .f., .f., .f., .t.,,, Len(STR0065)*4, 009 )		
		oEsteira   := TGet():New( oSize1:aPosObj[1,1]+8,aPosGet[1,2 - nOcultUNB], bSetGet( IIF(EMPTY(cEsteira),IIF(EMPTY(mv_par11),cEsteira,mv_par11),cEsteira) ),oPnlWnd1, aTamGet[1,2 - nOcultUNB], 009, PesqPict('N70', 'N70_CODIGO'), {||A165VldEst()},,,,,, .t.,,, {||IIF(!Empty(MV_PAR09) .And. MV_PAR09 == 1,.F.,.T.)  },,,;
		{|| },,, 'N70BEN' )
	Else

		oSay01     := TSay():New( oSize1:aPosObj[1,1], oSize1:aPosObj[1,1], {|| OemToAnsi(STR0007) } , oPnlWnd1, , , .f., .f., .f., .t., , , Len(STR0007)*4, 009 ) //"Safra"###"Safra"
		if _lNovSafra
			oGSafra	   := TGet():New( oSize1:aPosObj[1,1]+8, oSize1:aPosObj[1,2], bSetGet( cSafra ), oPnlWnd1, aTamGet[1,1], 009, '@!' ,{|| A165VldSF() },,,,,, .t.,,, {|| .T.},,,;
			{||  ClearGet({'cProdutor','cLjpro','cNmPdtor','cCodFaz','cNomeFaz','cCodVar','cDescVar','cCodFda','nPsLiqu'}) },,, 'NJU')
		else
			oGSafra	   := TGet():New( oSize1:aPosObj[1,1]+8, oSize1:aPosObj[1,2], bSetGet( cSafra ), oPnlWnd1, aTamGet[1,1], 009, '@!' ,{|| A165VldSF() },,,,,, .t.,,, {|| .T.},,,;
			{||  ClearGet({'cProdutor','cLjpro','cNmPdtor','cCodFaz','cNomeFaz','cCodVar','cDescVar','cCodFda','nPsLiqu'}) },,, 'NN1')
		endIf

		oSay02     := TSay():New( oSize1:aPosObj[1,1], aPosGet[1,2], {|| OemToAnsi(STR0008) } , oPnlWnd1, , , .f., .f., .f., .t., , , Len(STR0008)*4, 009 ) //"Produtor"###"Produtor"
		oGProdutor := TGet():New( oSize1:aPosObj[1,1]+8, aPosGet[1,2], bSetGet( cProdutor ), oPnlWnd1, aTamGet[1,2], 009, iif(lRPO17,PesqPict('DX8','DX8_CODIGO'),PesqPict('NJ0','NJ0_CODENT')),{|| A615VPDTOR()},,,,,, .t.,,, {|| .T.},,,;
		{|| ClearGet({'cLjPro','cNmPdtor','cCodFaz','cNomeFaz','cCodVar','cDescVar','cCodFda','nPsLiqu'}) },,, iif(lRPO17,'DX8','NJ0') )

		oSay03     := TSay():New( oSize1:aPosObj[1,1], aPosGet[1,3], {|| OemToAnsi(STR0009) } ,oPnlWnd1, , , .f., .f., .f., .t.,,, Len(STR0009)*4, 009 ) //"Loja"###"Loja"
		oGLJPro    := TGet():New( oSize1:aPosObj[1,1]+8, aPosGet[1,3], bSetGet( cLjPro ),oPnlWnd1, aTamGet[1,3], 009, iif(lRPO17,PesqPict('DX8','DX8_LOJA'),PesqPict('NJ0','NJ0_LOJENT')),{|| A615VPDTOR()},,,,,, .t.,,, {|| .T.},,,;
		{|| ClearGet({'cNmPdtor','cCodVar','cDescVar','cCodFda','nPsLiqu'}) })

		oSay04     := TSay():New( oSize1:aPosObj[1,1], aPosGet[1,4], {|| OemToAnsi(STR0010) } ,oPnlWnd1, , , .f., .f., .f., .t., , , Len(STR0010)*4, 009 ) //"Nome do Produtor"###"Nome do Produtor"
		oGNmPdtor  := TGet():New( oSize1:aPosObj[1,1]+8,aPosGet[1,4], bSetGet( cNmPdtor ),oPnlWnd1, aTamGet[1,4]-40, 009, iif(lRPO17,PesqPict('DX8','DX8_NOME'),PesqPict('NJ0','NJ0_NOME')),,,,,,, .t.,,, {|| .f.} )

		oSay05     := TSay():New( oSize1:aPosObj[1,1], aPosGet[1,5]-40, {|| OemToAnsi(STR0011) } ,oPnlWnd1, , , .f., .f., .f., .t.,,, Len(STR0011)*4, 009 ) //"Fazenda"###"Fazenda"
		oGCodFaz   := TGet():New( oSize1:aPosObj[1,1]+8, aPosGet[1,5]-40, bSetGet( cCodFaz ),oPnlWnd1, aTamGet[1,5], 009, PesqPict('NN2','NN2_CODIGO'),{||A165VldFaz()},,,,,, .t.,,, {|| .T.},,,;
		{|| ClearGet({'cNomeFaz','cCodVar','cDescVar','cCodFda','nPsLiqu'}) },,, 'NN2BEN' )

		oSay06     := TSay():New( oSize1:aPosObj[1,1], aPosGet[1,6]-40, {|| OemToAnsi(STR0012) } ,oPnlWnd1, , , .f., .f., .f., .t.,,, Len(STR0012)*4, 009 ) //"Nome da Fazenda"###"Nome da Fazenda"
		oGNomeFaz  := TGet():New( oSize1:aPosObj[1,1]+8,aPosGet[1,6]-40, bSetGet( cNomeFaz ),oPnlWnd1, aTamGet[1,6], 009, PesqPict('NN2','DX2_NOME'),,,,,,, .t.,,, {|| .f.} )

		oSayProdut := TSay():New( oSize1:aPosObj[1,1]+20, aPosGet[2,1]+3, {|| OemToAnsi( STR0094) } ,oPnlWnd1, , , .f., .f., .f., .t., , , nTam, 009 ) //"Produto"
		oGCodProd  := TGet():New( oSize1:aPosObj[1,1]+28, aPosGet[2,1]+3, bSetGet( cCodProdut ),oPnlWnd1, aTamGet[2,1], 009, PesqPict('SB1','B1_COD'),{ || A165VldPro()} ,,,,,, .t.,,, {|| .t.},,,;
		{|| ClearGet({'cDescVar','cCodFda','nPsLiqu'}) },,, 'SB1' )

		oSayDProd  := TSay():New( oSize1:aPosObj[1,1]+20, aPosGet[2,2], {|| OemToAnsi(STR0014) } ,oPnlWnd1, , , .f., .f., .f., .t., , , nTam, 009 ) //"Descrição"
		oGDescPro  := TGet():New( oSize1:aPosObj[1,1]+28, aPosGet[2,2], bSetGet( cDescPro ),oPnlWnd1, aTamGet[2,2]+157, 009, PesqPict('SB1','B1_DESC'),,,,,,, .t.,,, {|| .f.} )

		oSay07     := TSay():New( oSize1:aPosObj[1,1]+40, aPosGet[1,1]+3, {|| OemToAnsi( STR0013) } ,oPnlWnd1, , , .f., .f., .f., .t., , , nTam, 009 ) //"Variedade"
		oGCodVar   := TGet():New( oSize1:aPosObj[1,1]+48, aPosGet[1,1]+3, bSetGet( cCodVar ),oPnlWnd1, aTamGet[2,3], 009, PesqPict('NNV','NNV_CODIGO'),{ || A165VldVar()} ,,,,,, .t.,,, {|| .t.},,,;
		{|| ClearGet({'cDescVar','cCodFda','nPsLiqu'}) },,, 'NNV' )

		//		oSay08 	   := TSay():New( oSize1:aPosObj[1,1]+40, aPosGet[1,2], {|| OemToAnsi(STR0014) } ,oPnlWnd1, , , .f., .f., .f., .t., , , nTam, 009 ) //"Descrição"
		//		oGDescVar  := TGet():New( oSize1:aPosObj[1,1]+48, aPosGet[1,2], bSetGet( cDescVar ),oPnlWnd1, aTamGet[2,4], 009, PesqPict('NNV','NNV_DESCRI'),,,,,,, .t.,,, {|| .f.} )

	EndIf

	If TableInDic('N70')
		If Empty(cUNB) .And. !lTelaEst
			oSay08 	   := TSay():New( oSize1:aPosObj[1,1]+40, aPosGet[1,2]-15, {|| OemToAnsi(STR0014) } ,oPnlWnd1, , , .f., .f., .f., .t., , , nTam, 009 ) //"Descrição"
			oGDescVar  := TGet():New( oSize1:aPosObj[1,1]+48, aPosGet[1,2]-15, bSetGet( cDescVar ),oPnlWnd1, aTamGet[2,4], 009, PesqPict('NNV','NNV_DESCRI'),,,,,,, .t.,,, {|| .f.} )

			oSay22     := TSay():New( oSize1:aPosObj[1,1]+40, aPosGet[1,3]+5, {|| OemToAnsi( STR0056) } ,oPnlWnd1,,, .f., .f., .f., .t., , , Len(STR0056)*4, 009 ) //"Un. Benef."
			oGUnBenef  := TGet():New( oSize1:aPosObj[1,1]+48, aPosGet[1,3]+5, bSetGet( cCodUNB ),oPnlWnd1, aTamGet[2,5], 009, PesqPict('DXL','DXL_CODUNB'), { || A615CodUNB() },,,,,, .t.,,, {|| .t.},,,,,, 'DX3' )
		Endif

		oSay09     := TSay():New( IIF(lTelaEst,oSize1:aPosObj[1,1],  oSize1:aPosObj[1,1]+40), IIF(lTelaEst,aPosGet[1,3 - nOcultUNB],aPosGet[1,4]+5), {|| OemToAnsi( STR0015) } , IIF(lTelaEst,oPnlWnd1,oPnlWnd1),,, .f., .f., .f., .t., , , nTam,009) //"Fardao"
		oGCodFda   := TGet():New( IIF(lTelaEst,oSize1:aPosObj[1,1]+8,oSize1:aPosObj[1,1]+48), IIF(lTelaEst,aPosGet[1,3 - nOcultUNB],aPosGet[1,4]+5), bSetGet( cCodFda ), 		  IIF(lTelaEst,oPnlWnd1,oPnlWnd1), IIF(lTelaEst,aTamGet[1,3 - nOcultUNB],aTamGet[2,6]) , 009, PesqPict('DXL','DXL_CODIGO'), {|| A165CodFda() },,,,,, .t., , ,;
		{|| IIF(lTelaEst .And. (!lManutFard),.F.,.T.) },,,{|| ClearGet({'nPsLiqu'}) },,, ConsBen)


		oSay10     := TSay():New( IIF(lTelaEst,oSize1:aPosObj[1,1],  oSize1:aPosObj[1,1]+40), IIF(lTelaEst,aPosGet[1,4 - nOcultUNB],aPosGet[1,5]-100) , {|| OemToAnsi( STR0016) } , IIF(lTelaEst,oPnlWnd1,oPnlWnd1),,, .f., .f., .f., .t., , , nTam, 009 ) //"Peso Liquido"
		oGPsLiqu   := TGet():New( IIF(lTelaEst,oSize1:aPosObj[1,1]+8,oSize1:aPosObj[1,1]+48), IIF(lTelaEst,aPosGet[1,4 - nOcultUNB],aPosGet[1,5]-100) , bSetGet( nPsLiqu )        , IIF(lTelaEst,oPnlWnd1,oPnlWnd1), IIF(lTelaEst,aTamGet[1,4 - nOcultUNB],aTamGet[2,7]) , 009, PesqPict('DXL','DXL_PSLIQU'),,,,,,, .t.,,, {|| .f.},,,,,,,,,,,,.T.)

		oSay11     := TSay():New( IIF(lTelaEst,oSize1:aPosObj[1,1],  oSize1:aPosObj[1,1]+40), IIF(lTelaEst,aPosGet[1,5 - nOcultUNB],aPosGet[1,6]-63) , {|| OemToAnsi( STR0017) } , IIF(lTelaEst,oPnlWnd1,oPnlWnd1),,, .f., .f., .f., .t., , , Len(STR0017)*4, 009 ) //"Turno"###"Turno"
		oGCodTur   := TGet():New( IIF(lTelaEst,oSize1:aPosObj[1,1]+8,oSize1:aPosObj[1,1]+48), IIF(lTelaEst,aPosGet[1,5 - nOcultUNB],aPosGet[1,6]-63) , bSetGet( cCodTur )        , IIF(lTelaEst,oPnlWnd1,oPnlWnd1), IIF(lTelaEst,aTamGet[1,5 - nOcultUNB],aTamGet[2,8]), 009, PesqPict('SH7','H7_CODIGO'), { || A165CodTur() },,,,,, .t.,,, {|| .t.},,,,,, 'SH7' )

		oSay21     := TSay():New( IIF(lTelaEst,oSize1:aPosObj[1,1],  oSize1:aPosObj[1,1]+40), IIF(lTelaEst,aPosGet[1,6 - nOcultUNB],aPosGet[1,7]-140) , {|| OemToAnsi( STR0052) } , IIF(lTelaEst,oPnlWnd1,oPnlWnd1),,, .f., .f., .f., .t., , , Len(STR0052)*4, 009 ) //"DataBenef"###"DataBenef"
		oGDtBenef  := TGet():New( IIF(lTelaEst,oSize1:aPosObj[1,1]+8,oSize1:aPosObj[1,1]+48), IIF(lTelaEst,aPosGet[1,6 - nOcultUNB],aPosGet[1,7]-140) , bSetGet( dtBenef )        , IIF(lTelaEst,oPnlWnd1,oPnlWnd1), IIF(lTelaEst,aTamGet[1,6 - nOcultUNB],aTamGet[2,9]), 009, PesqPict('DXL','DXL_DTBEN'), { || A165DtBen() },,,,,, .t.,,, {|| lManutFard},,,,,,  )
	else
		If Empty(cUNB) .And. !lTelaEst
			oSay08 	   := TSay():New( oSize1:aPosObj[1,1]+40, aPosGet[1,2]+5, {|| OemToAnsi(STR0014) } ,oPnlWnd1, , , .f., .f., .f., .t., , , nTam, 009 ) //"Descrição"
			oGDescVar  := TGet():New( oSize1:aPosObj[1,1]+48, aPosGet[1,2]+5, bSetGet( cDescVar ),oPnlWnd1, aTamGet[2,4], 009, PesqPict('NNV','NNV_DESCRI'),,,,,,, .t.,,, {|| .f.} )

			oSay22     := TSay():New( oSize1:aPosObj[1,1]+40, aPosGet[1,3]+28, {|| OemToAnsi( STR0056) } ,oPnlWnd1,,, .f., .f., .f., .t., , , Len(STR0056)*4, 009 ) //"Un. Benef."
			oGUnBenef  := TGet():New( oSize1:aPosObj[1,1]+48, aPosGet[1,3]+28, bSetGet( cCodUNB ),oPnlWnd1, aTamGet[2,5], 009, PesqPict('DXL','DXL_CODUNB'), { || A615CodUNB() },,,,,, .t.,,, {|| .t.},,,,,, 'DX3' )
		Endif

		oSay09     := TSay():New( IIF(lTelaEst,oSize1:aPosObj[1,1],  oSize1:aPosObj[1,1]+40), IIF(lTelaEst,aPosGet[1,3 - nOcultUNB],aPosGet[1,4]+35), {|| OemToAnsi( STR0015) } , IIF(lTelaEst,oPnlWnd1,oPnlWnd1),,, .f., .f., .f., .t., , , nTam,009) //"Fardao"
		oGCodFda   := TGet():New( IIF(lTelaEst,oSize1:aPosObj[1,1]+8,oSize1:aPosObj[1,1]+48), IIF(lTelaEst,aPosGet[1,3 - nOcultUNB],aPosGet[1,4]+35), bSetGet( cCodFda ), 		  IIF(lTelaEst,oPnlWnd1,oPnlWnd1), IIF(lTelaEst,aTamGet[1,3 - nOcultUNB],aTamGet[2,6]) , 009, PesqPict('DXL','DXL_CODIGO'), {|| A165CodFda() },,,,,, .t., , ,;
		{|| IIF(lTelaEst .And. (!lManutFard),.F.,.T.) },,,{|| ClearGet({'nPsLiqu'}) },,, ConsBen)


		oSay10     := TSay():New( IIF(lTelaEst,oSize1:aPosObj[1,1],  oSize1:aPosObj[1,1]+40), IIF(lTelaEst,aPosGet[1,4 - nOcultUNB],aPosGet[1,5]-40) , {|| OemToAnsi( STR0016) } , IIF(lTelaEst,oPnlWnd1,oPnlWnd1),,, .f., .f., .f., .t., , , nTam, 009 ) //"Peso Liquido"
		oGPsLiqu   := TGet():New( IIF(lTelaEst,oSize1:aPosObj[1,1]+8,oSize1:aPosObj[1,1]+48), IIF(lTelaEst,aPosGet[1,4 - nOcultUNB],aPosGet[1,5]-40) , bSetGet( nPsLiqu ), 		   IIF(lTelaEst,oPnlWnd1,oPnlWnd1), IIF(lTelaEst,aTamGet[1,4 - nOcultUNB],aTamGet[2,7]) , 009, PesqPict('DXL','DXL_PSLIQU'),,,,,,, .t.,,, {|| .f.},,,,,,,,,,,,.T.)

		oSay11     := TSay():New( IIF(lTelaEst,oSize1:aPosObj[1,1],  oSize1:aPosObj[1,1]+40), IIF(lTelaEst,aPosGet[1,5 - nOcultUNB],aPosGet[1,6]-5) , {|| OemToAnsi( STR0017) } ,IIF(lTelaEst,oPnlWnd1,oPnlWnd1),,, .f., .f., .f., .t., , , Len(STR0017)*4, 009 ) //"Turno"###"Turno"
		oGCodTur   := TGet():New( IIF(lTelaEst,oSize1:aPosObj[1,1]+8,oSize1:aPosObj[1,1]+48), IIF(lTelaEst,aPosGet[1,5 - nOcultUNB],aPosGet[1,6]-5) , bSetGet( cCodTur ),		   IIF(lTelaEst,oPnlWnd1,oPnlWnd1), IIF(lTelaEst,aTamGet[1,5 - nOcultUNB],aTamGet[2,8]), 009, PesqPict('SH7','H7_CODIGO'), { || A165CodTur() },,,,,, .t.,,, {|| .t.},,,,,, 'SH7' )

		oSay21     := TSay():New( IIF(lTelaEst,oSize1:aPosObj[1,1],  oSize1:aPosObj[1,1]+40), IIF(lTelaEst,aPosGet[1,6 - nOcultUNB],aPosGet[1,7]-75) , {|| OemToAnsi( STR0052) } ,IIF(lTelaEst,oPnlWnd1,oPnlWnd1),,, .f., .f., .f., .t., , , Len(STR0052)*4, 009 ) //"DataBenef"###"DataBenef"
		oGDtBenef  := TGet():New( IIF(lTelaEst,oSize1:aPosObj[1,1]+8,oSize1:aPosObj[1,1]+48), IIF(lTelaEst, aPosGet[1,6 - nOcultUNB],aPosGet[1,7]-75) , bSetGet( dtBenef ),		   IIF(lTelaEst,oPnlWnd1,oPnlWnd1), IIF(lTelaEst,aTamGet[1,6 - nOcultUNB],aTamGet[2,9]), 009, PesqPict('DXL','DXL_DTBEN'), { || A165DtBen() },,,,,, .t.,,, {|| lManutFard},,,,,,  )		
	endIf

    //ponto de entrada para adicionar botoes na tela
    If ExistBlock('AG615BTN')
        ExecBlock('AG615BTN',.F.,.F.,{oPnlWnd1, oSize1})
    EndIf
    //fim

	//Cria o Browse na parte esquerda inferior da janela
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0018 ) //"Fardos Beneficiados"
	oBrowse:SetOwner( oWnd2Pnl1 )
	oBrowse:SetAlias('DXI')
	oBrowse:SetOnlyFields({'DXI_DATA','DXI_HORA','DXI_ETIQ','DXI_CODIGO','DXI_CODCNJ','DXI_PSBRUT','DXI_PSLIQU','DXI_CODTUR','DXI_COSTEL','DXI_PRENSA'})
	oBrowse:DisableDetail()
	oBrowse:SetSeek (.F.)
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:AddButton("Sair",{||oDlg:End()},,,,,,'10')

	if _lNovSafra
		oBrowse:SetFilterDefault("DXI_FILIAL=='" + FWxFilial("DXI") + "' .AND.DXI_FARDAO=='" + cCodFda + "' .AND.DXI_SAFRA=='" + PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ') + "' .AND.DXI_PRDTOR=='" + cProdutor + "' .AND.DXI_LJPRO=='" + cLjPro + "' .AND.DXI_FAZ=='" + cCodFaz + "'")
	else
		oBrowse:SetFilterDefault("DXI_FILIAL=='" + FWxFilial("DXI") + "' .AND.DXI_FARDAO=='" + cCodFda + "' .AND.DXI_SAFRA=='" + cSafra + "' .AND.DXI_PRDTOR=='" + cProdutor + "' .AND.DXI_LJPRO=='" + cLjPro + "' .AND.DXI_FAZ=='" + cCodFaz + "'")
	endIf

	oBrowse:Activate()

	// Divisão para totalizadores
	aTam := {{}}
	AADD(aTam[1],4)
	AADD(aTam[1],TamSX3('DXL_PSLIQU')[1])
	aTamGet := MsObjGetPos(oSize:aWindSize[4]*0.30, 315*0.30, aTam)

	oSay18		:= TSay():New(oSize2:aPosObj[2,1], nColAnt := (oSize2:aPosObj[2,2]+3), {|| OemToAnsi( 'Fardos' ) } ,oPnlWnd2, , , .f., .f., .f., .t., , , Len(STR0020)*4, 010 ) //"Total Fardos"
	oGTotFdi	:= TGet():New(oSize2:aPosObj[2,1]+7, nColAnt, bSetGet( nTotFdi ),oPnlWnd2, nTam := aTamGet[1,1], 010, '@E 9999', { || .T.},,,,,, .t.,,, {|| .f.},,,,,,,,,,,,.T.)

	oSay19		:= TSay():New(oSize2:aPosObj[2,1], nColAnt := (nColAnt+nTam+8), {|| OemToAnsi( STR0021 ) } ,oPnlWnd2, , , .f., .f., .f., .t., , , Len(STR0021)*4, 010 ) //"Total Bruto"###"Total Bruto"
	oGTotBrut	:= TGet():New(oSize2:aPosObj[2,1]+7, nColAnt, bSetGet( nTotBrut ),oPnlWnd2, nTam := aTamGet[1,2], 010, PesqPict('DXL','DXL_PSLIQU'), { || .T.},,,,,, .t.,,, {|| .f.},,,,,,,,,,,,.T.)

	oSay20		:= TSay():New(oSize2:aPosObj[2,1], nColAnt := (nColAnt+nTam+8), {|| OemToAnsi( STR0022 ) } ,oPnlWnd2, , , .f., .f., .f., .t., , , Len(STR0022)*4, 010 ) //"Total Liquido"###"Total Liquido"
	oGTotLiqu	:= TGet():New(oSize2:aPosObj[2,1]+7, nColAnt, bSetGet( nTotLiqu ),oPnlWnd2, nTam := aTamGet[1,2], 010, PesqPict('DXL','DXL_PSLIQU'), { || .T.},,,,,, .t.,,, {|| .f.},,,,,,,,,,,,.T.)

	// Divisão Lateral para lançamento dos fardos beneficiados.
	aTam := {{}}
	AADD(aTam[1],TamSX3('DXI_CODCNJ')[1])
	AADD(aTam[1],TamSX3('DXI_PRENSA')[1])
	AADD(aTam[1],TamSX3('DXI_ETIQ')[1])
	AADD(aTam[1],TamSX3('DXI_CODIGO')[1]*2)
	AADD(aTam[1],TamSX3('DXI_PSBRUT')[1]*2)
	AADD(aTam[1],TamSX3('DXI_PSLIQU')[1]*2)

	aTamGet 	:= MsObjGetPos(oSize:aWindSize[4]*0.30, 315*0.30, aTam)

	oCFdiTip	:= TCheckBox():New( oSize3:aPosObj[1,1], oSize3:aPosObj[1,2], OemToAnsi( STR0023 ), { || lCostelado },oPnlWnd3, 100, 215,, {|| lCostelado := IIf( lCostelado, .f., .t. ) },,,,,, .T.,,, ) //"Costelado"

	oSay12		:= TSay():New(IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,1]+13), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , {|| OemToAnsi( STR0024 ) } ,IIF(lAutMala,oPnlCnj,oPnlWnd3), , , .f., .f., .f., .t., , , Len(STR0024)*4, 010 ) //"Conjunto"###"Conjunto"
	oGCodCnj	:= TGet():New(IIF(lAutMala,oSize3:aPosObj[1,1]+8,oSize3:aPosObj[1,1]+20), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , bSetGet( cCodCnj ),IIF(lAutMala,oPnlCnj,oPnlWnd3), 030, 010, PesqPict('DXI','DXI_CODCNJ'), { || A615ValCnj() },,,,,, .t.,,, {|| A615WHEN()},,,,,, 'DXE')

	oSay13		:= TSay():New(IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,1]+35), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , {|| OemToAnsi( STR0025 ) } ,IIF(lAutMala,oPnlPrensa,oPnlWnd3), , , .f., .f., .f., .t., , , Len(STR0025)*4, 010 ) //"Prensa"###"Prensa"
	oGPrensa	:= TGet():New(IIF(lAutMala,oSize3:aPosObj[1,1]+8,oSize3:aPosObj[1,1]+42), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]), bSetGet( cPrensa ),		  IIF(lAutMala,oPnlPrensa,oPnlWnd3), aTamGet[1,2], 010, PesqPict('DXI','DXI_PRENSA'), { || .T.},,,,,, .t.,,, {|| .f.})

	oSay14		:= TSay():New(IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,1]+57), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , {|| OemToAnsi( STR0026 ) } , IIF(lAutMala,oPnlEtiq,oPnlWnd3), , , .f., .f., .f., .t., , , Len(STR0026)*4, 010 ) //"Etiqueta"###"Etiqueta"
	oGCodEtq	:= TGet():New(IIF(lAutMala,oSize3:aPosObj[1,1]+8,oSize3:aPosObj[1,1]+64), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , bSetGet( cCodEtq ),		  IIF(lAutMala,oPnlEtiq,oPnlWnd3), aTamGet[1,3], 010, PesqPict('DXI','DXI_ETIQ'), { || A615CodEti(cCodEtq, lEtiq:=.T., @oBut1) },,,,,, .t.,,, {|| A615WHEN()} )

	oSay15		:= TSay():New(IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,1]+79), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , {|| OemToAnsi( STR0027 ) } ,IIF(lAutMala,oPnlFardo,oPnlWnd3), , , .f., .f., .f., .t., , , Len(STR0027)*4, 010 ) //"Fardo"###"Fardo"
	oGCodFdi	:= TGet():New(IIF(lAutMala,oSize3:aPosObj[1,1]+8,oSize3:aPosObj[1,1]+86), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , bSetGet( cCodFdi ),		  IIF(lAutMala,oPnlFardo,oPnlWnd3), aTamGet[1,4], 010, PesqPict('DXI','DXI_CODIGO'), { || A615CodEti(cCodFdi, lEtiq:=.F., @oBut1) },,,oFont19n,,, .t.,,, {|| A615WHFard()} )

	oSay16		:= TSay():New(IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,1]+101), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , {|| OemToAnsi( STR0028 ) } ,IIF(lAutMala,oPnlPesoBr,oPnlWnd3), , , .f., .f., .f., .t., , , Len(STR0028 )*4, 010) //"Peso Bruto"###"Peso Bruto"
	oGFdiPBr	:= TGet():New(IIF(lAutMala,oSize3:aPosObj[1,1]+8,oSize3:aPosObj[1,1]+108), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , bSetGet( nFdiPBr ),		  IIF(lAutMala,oPnlPesoBr,oPnlWnd3), aTamGet[1,5], 010, PesqPict('DXI','DXI_PSLIQU'), { || .T. },,,oFont19n,,, .t.,,, {|| A615WHEN() .And. aPerBal[ 3 ] },,,{|| A615PsBrt()},,,,,,,,,.T.)

	oSay17		:= TSay():New(IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,1]+123), IIF(lAutMala,oSize3:aPosObj[1,1],oSize3:aPosObj[1,2]) , {|| OemToAnsi( STR0016 ) } ,IIF(lAutMala,oPnlPesoLq,oPnlWnd3), , , .f., .f., .f., .t., , , Len(STR0016)*4, 010 ) //"Peso Liquido"###"Peso Liquido"
	oGFdiPLq	:= TGet():New(IIF(lAutMala,oSize3:aPosObj[1,1]+8,oSize3:aPosObj[1,1]+130), IIF(lAutMala,oSize3:aPosObj[1,1], oSize3:aPosObj[1,2]), bSetGet( nFdiPLq ),		   IIF(lAutMala,oPnlPesoLq,oPnlWnd3), aTamGet[1,6], 010, PesqPict('DXI','DXI_PSLIQU'), { || .T.},,,oFont19n,,, .t.,,, {|| .f.},,,,,,,,,,,,.T.)

	//Botões
	oBut1 	:= TButton():New(IIF(lAutMala,oSize3:aPosObj[1,1]+113,oSize3:aPosObj[1,1]+172), oSize3:aPosObj[1,2]		, OemToAnsi( STR0029 )	,oPnlWnd3, { || A615Salvar(lEtiq) }, 035, 015,,, .f., .t., .f., , .f.,,, .f. ) //"Salvar"
	oBut2 	:= TButton():New(IIF(lAutMala,oSize3:aPosObj[1,1]+113,oSize3:aPosObj[1,1]+172), oSize3:aPosObj[1,2]+40	, OemToAnsi( STR0030 )	,oPnlWnd3, { || A615Limpar(lEtiq) }, 035, 015,,, .f., .t., .f., , .f.,,, .f. ) //"Limpar"
	oBut3 	:= TButton():New(IIF(lAutMala,oSize3:aPosObj[1,1]+113,oSize3:aPosObj[1,1]+172), oSize3:aPosObj[1,2]+80	, OemToAnsi( STR0031),oPnlWnd3, { || A615Encer() }, 035, 015,,, .f., .t., .f., , .f.,,, .f. ) //"Encerrar"

	// Painel de Rendimento do Fardão
	oPnlRend		:= TPanel():New(0,0,cRendimento,oPnlWnd4,oFntAB32,.T.,,CLR_BLACK,CLR_GREEN,130,60)
	oPnlRend:align	:= CONTROL_ALIGN_ALLCLIENT

	If lTelaEst 
		if !Empty(cUNB)
			oEsteira:SetFocus()
		else
			oGUnBenef:SetFocus()
		endIF
	else
		oGSafra:SetFocus()
	endIf

	ACTIVATE MSDIALOG oDlg CENTERED

	SetKey( VK_F12, bKeyF12 )
	If lAG615FRDA
		SetKey( VK_F9, bKeyF9 )
	EndIf

Return( Nil )

/** ------------------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Retorna Modelo de dados da rotina

@param: Nil
@author: TOTVS
@since: 15/03/2012
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function ModelDef()
	Local nX
	Local oStruct 	:= FWFormStruct( 1, 'DXI' )

	Local aStruct    := aClone(oStruct:AFIELDS)
	Local oModel 	   := MPFormModel():New( "AGRA615", /*<bPre >*/,{| oModel | PosModelo(oModel)},{| oModel | GrvModelo( oModel ) } )

	For nX := 1 To Len(aStruct)
		//---------------------------------------------------
		// Retira obrigatoriedade de preenchimento dos campos
		//---------------------------------------------------
		oStruct:SetProperty(aStruct[nX,3] , MODEL_FIELD_OBRIGAT , .F.)

		//-------------------------------
		// Remove os campos da estrutura
		//-------------------------------
		If !(Alltrim(aStruct[nX,3]) $ 'DXI_ETIQ|DXI_CODIGO|DXI_CODUNB|DXI_FARDAO|DXI_CODCNJ|DXI_DATA|DXI_HORA|DXI_PSBRUT|DXI_PSLIQU|DXI_COSTEL')
			oStruct:RemoveField(aStruct[nX,3])
		EndIf
	Next

	//-------------------
	// Instancia o model
	//-------------------
	//oModel:= MPFormModel():New( 'AGRA615' )
	oModel:SetDescription( STR0032  ) //"Beneficiamento"

	//----------------------
	// Adiciona um gatilho
	//----------------------
	oStruct:AddTrigger( "DXI_PSBRUT", "DXI_PSLIQU", { || .T. }, { | x | A615PSLIQU( x ) } )


	//--------------------------------
	// Adiciona a estrutura do modelo
	//--------------------------------
	oModel:AddFields( 'DXIMASTER', Nil, oStruct)
	oModel:GetModel('DXIMASTER'):SetDescription( STR0018  ) //"Fardos Beneficiados"

	//------------------------------------------------------
	// Seta modo de edição para os campos do modelo de dados
	//------------------------------------------------------
	oStruct:SetProperty( '*' , MODEL_FIELD_WHEN ,FwBuildFeature( STRUCT_FEATURE_WHEN, 'INCLUI' ))
	oStruct:SetProperty( 'DXI_COSTEL' , MODEL_FIELD_WHEN ,FwBuildFeature( STRUCT_FEATURE_WHEN, '.T.' ))  	//Costelado
	oStruct:SetProperty( 'DXI_PSBRUT' , MODEL_FIELD_WHEN ,FwBuildFeature( STRUCT_FEATURE_WHEN, '.T.' ))  	//Peso Bruto
	oStruct:SetProperty( 'DXI_PSLIQU' , MODEL_FIELD_WHEN ,FwBuildFeature( STRUCT_FEATURE_WHEN, '.T.' ))	//Peso Liquido

	//---------------------
	// Seta chave primaria
	//---------------------
	oModel:SetPrimaryKey( { 'DXI_FILIAL','DXI_SAFRA','DXI_ETIQ' } )

Return( oModel )

/** {Protheus.doc} GrvModelo

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Bruna Rocio
@since: 	30/07/2015
@type function
*/
Static Function GrvModelo( oModel )

	Local lRetorno	 	:= .T.
	Local aAreaAtu	 	:= GetArea()
	Local nOperation 	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_DELETE
		
		//Quando fardo deletado busca o primeiro fardo para atualizar a data de beneficiamento do fardao
		nrecno := recno()
		//Verifica data de produção Dia -1
		If RecLock( 'DXL', .F. )
			if AGRIFDBSEEK("DXI", DXL->DXL_CODIGO + DXL->DXL_SAFRA,2,.F.)
				aMatriz:= AGRBUSREGIS("DXI","DXI_FILIAL+DXI_FARDAO+DXI_SAFRA",2,.F.,.F.,"DXI_FILIAL= xFilial('DXI').and.  DXI_FARDAO = cCodFda .and. DXI_SAFRA = cSafra ",	{{"DXI_DATA"},{"DXI_HORA"},{'DXI_CODTUR'}},'recno() <>  nrecno ',,"M",)
				aFardos := aclone(aMatriz[2])
				if (Len(aFardos) > 0 )
					aFardos:= ASort( aFardos, , , { | x, y | dtos(x[ 1 ]) + x[ 2 ] < dtos(y[ 1 ]) + y[ 2 ]})
					cMenoDATA:= aFardos[1,1]
					cMenoHora:= aFardos[1,2]
					cCodTur:= aFardos[1,3]
					vVetRet := ARGULTMDHCALE(cMenoDATA,cCodTur)
					cHoraIT := vVetRet[2]

					DXL->DXL_DTBEN  := DXI->DXI_DATA
					DXL->DXL_CODTUR 	:= cCodTur
				else
					DXL->DXL_DTBEN  := ctod("")
					DXL->DXL_CODTUR := ""
					DXL->DXL_CODCNJ := ""        //Conjunto
					DXL->DXL_RDMTO  := 0         //Rendimento
					If lRet := ApMsgYesNo(STR0055)
						DXL->DXL_STATUS := "3"    //Disponível
					Endif
				endif
			endif
			DXL->(MsUnLock())
		Endif

	endif

	If nOperation == MODEL_OPERATION_UPDATE
		aChaveMov := {{FwxFilial("N9D")	},;
		{DXI->DXI_SAFRA  	},;
		{DXI->DXI_ETIQ	} ;
		}

		aMovFrd   := {{	{"N9D_PESINI", M->DXI_PSLIQU },;
		{"N9D_PESFIM", M->DXI_PSLIQU } ;	
		}}

		lRetorno := A615GrvMov("Altera", aMovFrd, aChaveMov) //exclui movimentos do fardo		 	  

	EndIf

	if lRetorno
		FWFormCommit(oModel)
	endIf

	RestArea( aAreaAtu )
Return (lRetorno)

/*/{Protheus.doc} PosModelo
//Validar exclusoes
@author carlos.augusto
@since 26/04/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function PosModelo(oModel)
	Local lRet	:= .T.
	Local aArea := GetArea()
	Local aChaveMov		:= {}

	If oModel:GetOperation() == MODEL_OPERATION_DELETE 
		
		If _lNovSafra
			lRet := DelAmostra()
		EndIf

		If lRet
			aChaveMov := {	;
			{FwxFilial("N9D")	},;
			{DXI->DXI_SAFRA  	},;
			{DXI->DXI_ETIQ		} ;				 		
			}

			lRet := A615GrvMov("Exclui", {}, aChaveMov) //exclui movimentos do fardo

		Endif
	Endif

	RestArea(aArea)
Return lRet

/** ------------------------------------------------------------------------------------------
{Protheus.doc} ViewDef
Retorna Modelo de interface da rotina

@param: Nil
@author: TOTVS
@since: 15/03/2012
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function ViewDef()
	Local nX
	Local oView    := Nil
	Local oStruct  := FWFormStruct( 2, 'DXI' )
	Local oModel   := FWLoadModel( 'AGRA615' )
	Local aStruct  := aClone(oStruct:AFIELDS)

	For nX := 1 To Len(aStruct)
		If !(Alltrim(aStruct[nX,1]) $ 'DXI_ETIQ|DXI_CODIGO|DXI_FARDAO|DXI_CODCNJ|DXI_DATA|DXI_HORA|DXI_PSBRUT|DXI_PSLIQU|DXI_COSTEL')
			oStruct:RemoveField(aStruct[nX,1])
		EndIf
	Next

	//--------------------
	// Instancia a View
	//--------------------
	oView := FWFormView():New()

	//------------------------
	// Seta o modelo de dados
	//------------------------
	oView:SetModel( oModel )

	//--------------------------------------------------------------------------
	// Metodo que seta um Code-block para ser avaliado apos o OK padrao do View       
	//--------------------------------------------------------------------------
	oView:SetAfterOkButton( {|| A615AtuBrw() } )

	//-------------------------------------------
	// Adiciona a estrutura dos campos no modelo
	//-------------------------------------------
	oView:AddField( 'VIEW_DXI', oStruct, 'DXIMASTER')

	//---------------------
	// Cria box horizontal
	//---------------------
	oView:CreateHorizontalBox( 'TOTAL'  , 100 )

	//------------
	// Seta Owner
	//------------
	oView:SetOwnerView( 'VIEW_DXI', 'TOTAL'   )

Return( oView )

/** ------------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Menu padrão da rotina

@param: Nil
@author: TOTVS
@since: 15/03/2012
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function MenuDef()
	Local aRotina := {}	
	Local lUtlzaMala := IIF(lAutMala = Nil,SuperGetMv("MV_AGRMALA", ,.T.),lAutMala)

	ADD OPTION aRotina Title STR0033 Action 'VIEWDEF.AGRA615' OPERATION 4 ACCESS 0
	IF (lUtlzaMala .And. ValType(MV_PAR09) == 'N' .And. MV_PAR09 == 1) .Or. !lUtlzaMala
		ADD OPTION aRotina Title STR0034 Action 'VIEWDEF.AGRA615' OPERATION 5 ACCESS 0
	EndIf
	ADD OPTION aRotina Title "Reimprimir Etiquetas"  Action 'A615Print' OPERATION 8 ACCESS 0
	If ExistBlock('AG615MNU')
		aRet := ExecBlock('AG615MNU',.F.,.F.,{aRotina})
		If ValType(aRet) == 'A'
			aRotina	:= aClone(aRet)
		EndIf
	EndIf

Return( aRotina )


/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615INITVAR
Inicializador de Variaveis

@param: Nil
@author: TOTVS
@since: 28/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Function A615INITVAR(lPerg)
	Local aArea := GetArea()
	Local cMV09Temp1 := MV_PAR09
	Local cMV12Temp1 := MV_PAR12
	Local lPergOk := Nil //Para ter 3 condicoes
	Local cTempEst := cEsteira

	ClearGet({'cNmPdtor','cNomeFaz'})

	//Se lPerg = Falso, o metodo serve para inicializar a tela. Nao alterar lPergOk
	//Se lPerg = True, devemos pegar o valor de lPergOk para saber se deve recarregar a tela ou nao
	If IIF(lPerg, lPergOk := Pergunte('AGRA615001',lPerg), Pergunte('AGRA615001',lPerg))
		If cMV09Temp1 != MV_PAR09 .OR. cMV12Temp1 != MV_PAR12
			lReload := .T.
		EndIf
	EndIf

	aPerBal := AGRX003E( .F., 'AGRA615001' )

	//Se OK no pergunte, usa esteira e nao alterou parametro manut fardao
	If lPergOk .And. lTelaEst .And. !lReload 
		Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0096 ), 1 )
		//#"Os parâmetros de Safra, Produto, Produtor, Loja e Fazenda não são considerados no modo de beneficiamento esteira." 
	EndIf

	If !Empty(MV_PAR02)
		cSafra		:= MV_PAR02 // Safra
	EndIf

	//lPergOk = nulo ou verdadeiro, preenche os campos da tela
	if _lNovSafra .AND. lPergOk <> .F.
		If !Empty(MV_PAR03)
			cCodProdut	:= MV_PAR03 // Produto
		EndIf
		If !Empty(MV_PAR04)
			cProdutor	:= MV_PAR04 // Produtor
		EndIf
		If !Empty(MV_PAR05)
			cLjPro		:= MV_PAR05 // Loja
		EndIf
		If !Empty(MV_PAR06)
			cCodFaz		:= MV_PAR06 // Fazenda
		EndIf

		If !Empty(MV_PAR10)
			cCodUnb		:= MV_PAR10 // Unid. Benef.
		EndIf

		If !Empty(MV_PAR11)
			cEsteira	:= MV_PAR11 // Esteira
		Else
			cEsteira 	:= space(TamSX3('N70_CODIGO')[1])
		EndIf

		If cTempEst <> MV_PAR11
			If Type("oEsteira") == 'O'
				oEsteira:SetFocus()
			EndIf
		EndIf

	else
		//		If !Empty(MV_PAR03)
		//			cProdutor	:= MV_PAR03 // Produtor
		//		EndIf
		//		If !Empty(MV_PAR04)
		//			cLjPro		:= MV_PAR04 // Loja
		//		EndIf
		//		If !Empty(MV_PAR05)
		//			cCodFaz		:= MV_PAR05 // Fazenda
		//		EndIf

		If !Empty(MV_PAR03)
			cCodProdut	:= MV_PAR03 // Produto
		EndIf
		If !Empty(MV_PAR04)
			cProdutor	:= MV_PAR04 // Produtor
		EndIf
		If !Empty(MV_PAR05)
			cLjPro		:= MV_PAR05 // Loja
		EndIf
		If !Empty(MV_PAR06)
			cCodFaz		:= MV_PAR06 // Fazenda
		EndIf

		If !Empty(MV_PAR10)
			cCodUnb		:= MV_PAR10 // Unid. Benef.
		EndIf

		//		If !Empty(MV_PAR11)
		//			cEsteira	:= MV_PAR11 // Esteira
		//		Else
		//			cEsteira 	:= space(TamSX3('N70_CODIGO')[1])
		//		EndIf

		//		If cTempEst <> MV_PAR11
		//			If Type("oEsteira") == 'O'
		//				oEsteira:SetFocus()
		//			EndIf
		//		EndIf
	endIf

	//Inicializa Descrição do Produto
	dbSelectArea('SB1')
	SB1->(dbSetOrder(1))
	If MSSeek(FWxFilial('SB1')+cCodProdut)
		cDescPro 	:= SB1->B1_DESC
		cLocalPro	:= SB1->B1_LOCPAD 
	EndIf

	DtBenef := dDatabase

	if lRPO17
		DX8->(dbSetOrder(1))
		If DX8->(MsSeek(FWxFilial('DX8')+cProdutor+cLjPro))
			cNmPdtor := DX8->DX8_NOME
			NN2->(dbSetOrder(3))
			If NN2->(MSSeek(FWxFilial('NN2')+DX8->(DX8_CODIGO+DX8_LOJA)+cCodFaz))
				cNomeFaz :=  NN2->NN2_NOME
			EndIf
		EndIf
	else
		NJ0->(dbSetOrder(1))
		If NJ0->(MsSeek(FWxFilial('NJ0')+cProdutor+cLjPro))
			cNmPdtor := NJ0->NJ0_NOME
			NN2->(dbSetOrder(3))
			If NN2->(MSSeek(FWxFilial('NN2')+NJ0->(NJ0_CODENT+NJ0_LOJENT)+cCodFaz))
				cNomeFaz :=  NN2->NN2_NOME
			EndIf
		EndIf
	endIf

	RestArea(aArea)
	If lReload
		oDlg:End()
	EndIf

	RestArea(aArea)
Return

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A165VldSF
Validação da Safra

@param: Nil
@author: TOTVS
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A165VldSF()
	Local lRet := .T.

	if !EMPTY(cSafra)
		if _lNovSafra
			NJU->(dbSetOrder(1))
			If !NJU->(MsSeek(FWxFilial('NJU')+cSafra))
				lRet := .F.
				Help('',1,'REGNOIS',,,1)
			EndIf		
		else
			NN1->(dbSetOrder(1))
			If !NN1->(MsSeek(FWxFilial('NN1')+cSafra))
				lRet := .F.
				Help('',1,'REGNOIS',,,1)
			EndIf
		endIf
	endIf

Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615VPDTOR
Validação do Produtor

@param: Nil
@author: TOTVS
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615VPDTOR()
	Local aArea := GetArea()
	Local lRet  := .T.

	if !EMPTY(cProdutor) .AND. !EMPTY(cLjPro)
		if lRPO17
			If !DX8->(DbSeek(xFilial('DX8')+cProdutor+If(!Empty(cLjPro),cLjPro,'')))
				lRet := .F.
				Help('',1,'REGNOIS',,,1)
			EndIf

			If lRet .And. !Empty(cLjPro)
				cLjPro		:= DX8->DX8_LOJA
				cNmPdtor	:= DX8->DX8_NOME
			EndIf
		else
			If !NJ0->(MSSeek(FWxFilial('NJ0')+cProdutor+If(!Empty(cLjPro),cLjPro,'')))
				lRet := .F.
				Help('',1,'REGNOIS',,,1)
			EndIf

			If lRet .And. !Empty(cLjPro)
				cLjPro		:= NJ0->NJ0_LOJENT
				cNmPdtor	:= NJ0->NJ0_NOME
			EndIf
		endIf
	endIf

	RestArea(aArea)
Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A165VldFaz
Validação da Fazenda

@param: Nil
@author: TOTVS
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A165VldFaz()
	Local aArea 	:= GetArea()
	Local lRet 		:= .T.

	If !Empty(cCodFaz)
		dbSelectArea('NN2')
		NN2->(dbSetOrder(3))

		If NN2->(MsSeek(FWxFilial('NN2')+cProdutor+cLjPro+cCodFaz))
			cNomeFaz := NN2->NN2_NOME
		Else
			Help('',1,'REGNOIS')
			lRet := .F.
		EndIf
		NN2->(DbCloseArea())
	EndIf

	RestArea(aArea)
Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A165VldVar
Validação da Variedade

@param: Nil
@author: TOTVS
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A165VldVar()
	Local aArea 	:= GetArea()
	Local lRet 		:= .T.

	If !Empty(cCodVar)
		if _lNovSafra
			NJU->(dbSetOrder(1))
			NJU->(MsSeek(FWxFilial('NJU')+cSafra))
		else
			NN1->(dbSetOrder(1))
			NN1->(MsSeek(FWxFilial('NN1')+cSafra))
		endif

		dbSelectArea('NNV')
		NNV->(dbSetOrder(1))

		if _lNovSafra
			If !ExistCPO('NNV',PADR(cCodProdut,TamSX3('B1_COD')[1],' ')+PADR(cCodVar,TamSX3('NNV_CODIGO')[1],' '),1)
				lRet := .F.
			EndIf
		else
			If !ExistCPO('NNV',PADR(NN1->NN1_CODPRO,TamSX3('B1_COD')[1],' ')+PADR(cCodVar,TamSX3('NNV_CODIGO')[1],' '),1)
				lRet := .F.
			EndIf
		endif

		If lRet
			cDescVar := NNV->NNV_DESCRI
		EndIf
	EndIf

	Restarea(aArea)
Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A165CodFda
Validação do Fardao

@param: Nil
@author: Aécio Gomes
@since: 15/03/2012
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A165CodFda()	
	Local lRet		:= .T.
	Local lEmpty	:= .F.
	Local nRedCnj	:= Posicione('DXE',1,xFilial('DXE')+cCodCnj,'DXE_RDMAX')
	Local cAliasQtd    	:= GetNextAlias()
	Local cQry    := ""
	Local nQtd   

	Private cAliasFrd    	:= GetNextAlias()

	nPsLiqu		:= 0

	If Empty(cCodFda)
		lEmpty	:= .T.
	EndIf

	If !lEmpty
		dbSelectArea( 'DXL' )
		DXL->(dbSetOrder(1)) //Filial+Codigo+safra+Produtor+fazenda

		if _lNovSafra
			If DXL->(MsSeek( FWxFilial( 'DXL')+cCodFda+PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ')+cProdutor+cLjPro+cCodFaz))
				If !Empty(cCodVar) .and. cCodVar <> DXL->DXL_CODVAR  
					Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0105  ), 1 ) //"Atenção"###"Variedade do fardao informado é diferente da selecionada"
					Return .F. 
				EndIf
				If !Empty(cCodProdut) .And. DXL->DXL_CODPRO != cCodProdut
					Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0095  ), 1 ) //"Atenção"###"O produto de origem informado é diferente do produto do fardão."
					oGCodProd:SetFocus()
					Return .F.
				EndIf

				If DXL->DXL_STATUS == '5'

					If lRet := ApMsgYesNo( STR0035 ) //"Este fardão já foi beneficiado, deseja reabriar o beneficiamento?"
						Reclock('DXL', .F.)
						DXL->DXL_STATUS := '4'
						If DXL->(ColumnPos( 'DXL_FILBEN' )) > 0
							DXL->DXL_FILBEN := FWxFilial('DXI')
						Endif
						DXL->(MsUnlock())
					EndIf

				EndIf

				If lRet .And. DXL->DXL_STATUS $ '3|4'  //2=EmRomaneio ou 3=Disponivel ou 4=Em beneficiamento
					if DXL->DXL_PSLIQU > 0
						nPsLiqu 	:= DXL->DXL_PSLIQU
						nRendMax	:= nRedCnj //Rendimento Máximo Definido no Conjunto
						dbSelectArea( 'DXL' )
					else
						lRet := .F.
						Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0051  ), 1 ) //"Atenção"###"Peso liquido inválido"
					endif
				Else
					lRet := .F.
					Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0037 ), 1 ) //"Atenção"###"Somente fardões com status de [3=Disponivel ou 4=Em beneficamento] podem ser beneficiados"
				EndIf

				If !Empty(cUNB) .AND. DXL->DXL_CODUNB <> cUNB //Unidade de Beneficiamento do Fardao e Selecionada
					lRet := .F.
					Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0058  ), 1 ) //"Atenção"###"Fardão informado inválido para a Unidade de Beneficiamento selecionada"
				Endif
			Else
				If Select(cAliasFrd) > 0
					(cAliasFrd)->(DbCloseArea())
				Endif

				cQry := "SELECT * "
				cQry += " FROM " +RetSqlName("DXL")+ " DXL "
				cQry += " WHERE DXL.D_E_L_E_T_ = ' ' "
				cQry += " AND DXL_FILIAL = '"+FwxFilial( 'DXL' )+"' "
				cQry += " AND DXL_CODIGO = '" +cCodFda+ "' "
				cQry := ChangeQuery( cQry ) 
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasFrd, .F., .T. )

				If Select(cAliasQtd) > 0
					(cAliasQtd)->(DbCloseArea())
				Endif

				cQry := "SELECT COUNT(DXL_CODIGO) AS QTDFRD "
				cQry += " FROM " +RetSqlName("DXL")+ " DXL "
				cQry += " WHERE DXL.D_E_L_E_T_ = ' ' "
				cQry += " AND DXL_FILIAL = '"+FwxFilial( 'DXL' )+"' "
				cQry += " AND DXL_CODIGO = '" +cCodFda+ "' "
				cQry := ChangeQuery( cQry ) 
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQtd, .F., .T. )
				nQtd := (cAliasQtd)->QTDFRD
				If nQtd = 0
					lRet := .F.
					Help('',1,'REGNOIS',,,1)
				ElseIf nQtd = 1	
					If DXL->(MsSeek( FWxFilial( 'DXL')+(cAliasFrd)->(DXL_CODIGO+DXL_SAFRA+DXL_PRDTOR+DXL_LJPRO+DXL_FAZ)))//cCodFda+cSafra+cProdutor+cLjPro+cCodFaz))
						If !Empty(cCodVar) .and. cCodVar <> DXL->DXL_CODVAR  
							Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0105  ), 1 ) //"Atenção"###"Variedade do fardao informado é diferente da selecionada"
							Return .F. 
						EndIf				
						If DXL->DXL_STATUS == '5'		
							If lRet := ApMsgYesNo( STR0035 ) //"Este fardão já foi beneficiado, deseja reabriar o beneficiamento?"
								Reclock('DXL', .F.)
								DXL->DXL_STATUS := '4'
								If DXL->(ColumnPos( 'DXL_FILBEN' )) > 0
									DXL->DXL_FILBEN := FWxFilial('DXI')
								Endif
								DXL->(MsUnlock())
							EndIf		
						EndIf		
						If lRet .And. DXL->DXL_STATUS $ '3|4'  //2=EmRomaneio ou 3=Disponivel ou 4=Em beneficamento
							if DXL->DXL_PSLIQU > 0
								nPsLiqu 	:= DXL->DXL_PSLIQU
								nRendMax	:= nRedCnj //Rendimento Máximo Definido no Conjunto
								dbSelectArea( 'DXL' )
							else
								lRet := .F.
								Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0051  ), 1 ) //"Atenção"###"Peso liquido inválido"
							endif
						Else
							lRet := .F.
							Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0037 ), 1 ) //"Atenção"###"Somente fardões com status de [3=Disponivel ou 4=Em beneficamento] podem ser beneficiados"				
						EndIf		
						If !Empty(cUNB) .AND. DXL->DXL_CODUNB <> cUNB//Unidade de Beneficiamento do Fardao e Selecionada
							lRet := .F.
							Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0058  ), 1 ) //"Atenção"###"Fardão informado inválido para a Unidade de Beneficiamento selecionada"
						Endif						
						If lRet
							cSafra 		:= (cAliasFrd)->DXL_SAFRA
							cProdutor 	:= (cAliasFrd)->DXL_PRDTOR
							cLjPro 		:= (cAliasFrd)->DXL_LJPRO
							If lRPO17 
								cNmPdtor 	:= Posicione( "DX8", 1, FWxFilial("DX8") + (cAliasFrd)->(DXL_PRDTOR+DXL_LJPRO), "DX8_NOME" )
							Else
								cNmPdtor 	:= Posicione( "NJ0", 1, FWxFilial("NJ0") + (cAliasFrd)->(DXL_PRDTOR+DXL_LJPRO), "NJ0_NOME" )
							Endif
							cCodFaz 	:= (cAliasFrd)->DXL_FAZ
							cNomeFaz 	:= Posicione( "NN2", 3, FWxFilial("NN2") + (cAliasFrd)->(DXL_PRDTOR+DXL_LJPRO+DXL_FAZ), "NN2_NOME" )
							cCodProdut 	:= (cAliasFrd)->DXL_CODPRO
							cDescPro 	:= Posicione( "SB1", 1, xFilial( "SB1" ) + (cAliasFrd)->DXL_CODPRO, "B1_DESC" )
							cCodVar 	:= (cAliasFrd)->DXL_CODVAR
							cDescVar 	:= Posicione("NNV",2,FWxFilial("NNV") + (cAliasFrd)->DXL_CODVAR, "NNV_DESCRI")
							cCodUNB 	:= (cAliasFrd)->DXL_CODUNB
							nPsLiqu 	:= (cAliasFrd)->DXL_PSLIQU
						Endif						
					Endif

				Else
					ConsDXLF3()
				Endif
			EndIf
		else		    

			If DXL->(MsSeek( FWxFilial( 'DXL')+cCodFda+cSafra+cProdutor+cLjPro+cCodFaz))
				If !Empty(cCodVar) .and. cCodVar <> DXL->DXL_CODVAR  
					Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0105  ), 1 ) //"Atenção"###"Variedade do fardao informado é diferente da selecionada"
					Return .F. 
				EndIf				
				If DXL->DXL_STATUS == '5'

					If lRet := ApMsgYesNo( STR0035 ) //"Este fardão já foi beneficiado, deseja reabriar o beneficiamento?"
						Reclock('DXL', .F.)
						DXL->DXL_STATUS := '4'
						If DXL->(ColumnPos( 'DXL_FILBEN' )) > 0
							DXL->DXL_FILBEN := FWxFilial('DXI')
						Endif
						DXL->(MsUnlock())
					EndIf

				EndIf

				If lRet .And. DXL->DXL_STATUS $ '3|4'  //2=EmRomaneio ou 3=Disponivel ou 4=Em beneficamento
					if DXL->DXL_PSLIQU > 0
						nPsLiqu 	:= DXL->DXL_PSLIQU
						nRendMax	:= nRedCnj //Rendimento Máximo Definido no Conjunto
						dbSelectArea( 'DXL' )
					else
						lRet := .F.
						Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0051  ), 1 ) //"Atenção"###"Peso liquido inválido"
					endif
				Else
					lRet := .F.
					Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0037 ), 1 ) //"Atenção"###"Somente fardões com status de [3=Disponivel ou 4=Em beneficamento] podem ser beneficiados"				
				EndIf

				If !Empty(cUNB) .AND. DXL->DXL_CODUNB <> cUNB//Unidade de Beneficiamento do Fardao e Selecionada
					lRet := .F.
					Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0058  ), 1 ) //"Atenção"###"Fardão informado inválido para a Unidade de Beneficiamento selecionada"
				Endif
			Else

				If Select(cAliasFrd) > 0
					(cAliasFrd)->(DbCloseArea())
				Endif

				cQry := "SELECT * "
				cQry += " FROM " +RetSqlName("DXL")+ " DXL "
				cQry += " WHERE DXL.D_E_L_E_T_ = ' ' "
				cQry += " AND DXL_FILIAL = '"+FwxFilial( 'DXL' )+"' "
				cQry += " AND DXL_CODIGO = '" +cCodFda+ "' "
				cQry := ChangeQuery( cQry ) 
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasFrd, .F., .T. )

				If Select(cAliasQtd) > 0
					(cAliasQtd)->(DbCloseArea())
				Endif

				cQry := "SELECT COUNT(DXL_CODIGO) AS QTDFRD "
				cQry += " FROM " +RetSqlName("DXL")+ " DXL "
				cQry += " WHERE DXL.D_E_L_E_T_ = ' ' "
				cQry += " AND DXL_FILIAL = '"+FwxFilial( 'DXL' )+"' "
				cQry += " AND DXL_CODIGO = '" +cCodFda+ "' "
				cQry := ChangeQuery( cQry ) 
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQtd, .F., .T. )
				nQtd := (cAliasQtd)->QTDFRD
				If nQtd = 0
					lRet := .F.
					Help('',1,'REGNOIS',,,1)
				ElseIf nQtd = 1	
					If DXL->(MsSeek( FWxFilial( 'DXL')+(cAliasFrd)->(DXL_CODIGO+DXL_SAFRA+DXL_PRDTOR+DXL_LJPRO+DXL_FAZ)))//cCodFda+cSafra+cProdutor+cLjPro+cCodFaz))
						If !Empty(cCodVar) .and. cCodVar <> DXL->DXL_CODVAR  
							Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0105  ), 1 ) //"Atenção"###"Variedade do fardao informado é diferente da selecionada"
							Return .F. 
						EndIf				
						If DXL->DXL_STATUS == '5'		
							If lRet := ApMsgYesNo( STR0035 ) //"Este fardão já foi beneficiado, deseja reabriar o beneficiamento?"
								Reclock('DXL', .F.)
								DXL->DXL_STATUS := '4'
								If DXL->(ColumnPos( 'DXL_FILBEN' )) > 0
									DXL->DXL_FILBEN := FWxFilial('DXI')
								Endif
								DXL->(MsUnlock())
							EndIf		
						EndIf		
						If lRet .And. DXL->DXL_STATUS $ '3|4'  //2=EmRomaneio ou 3=Disponivel ou 4=Em beneficamento
							if DXL->DXL_PSLIQU > 0
								nPsLiqu 	:= DXL->DXL_PSLIQU
								nRendMax	:= nRedCnj //Rendimento Máximo Definido no Conjunto
								dbSelectArea( 'DXL' )
							else
								lRet := .F.
								Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0051  ), 1 ) //"Atenção"###"Peso liquido inválido"
							endif
						Else
							lRet := .F.
							Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0037 ), 1 ) //"Atenção"###"Somente fardões com status de [3=Disponivel ou 4=Em beneficamento] podem ser beneficiados"				
						EndIf		
						If !Empty(cUNB) .AND. DXL->DXL_CODUNB <> cUNB//Unidade de Beneficiamento do Fardao e Selecionada
							lRet := .F.
							Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0058  ), 1 ) //"Atenção"###"Fardão informado inválido para a Unidade de Beneficiamento selecionada"
						Endif						
						If lRet
							cSafra 		:= (cAliasFrd)->DXL_SAFRA
							cProdutor 	:= (cAliasFrd)->DXL_PRDTOR
							cLjPro 		:= (cAliasFrd)->DXL_LJPRO
							If lRPO17 
								cNmPdtor 	:= Posicione( "DX8", 1, FWxFilial("DX8") + (cAliasFrd)->(DXL_PRDTOR+DXL_LJPRO), "DX8_NOME" )
							Else
								cNmPdtor 	:= Posicione( "NJ0", 1, FWxFilial("NJ0") + (cAliasFrd)->(DXL_PRDTOR+DXL_LJPRO), "NJ0_NOME" )
							Endif
							cCodFaz 	:= (cAliasFrd)->DXL_FAZ
							cNomeFaz 	:= Posicione( "NN2", 3, FWxFilial("NN2") + (cAliasFrd)->(DXL_PRDTOR+DXL_LJPRO+DXL_FAZ), "NN2_NOME" )
							cCodProdut 	:= (cAliasFrd)->DXL_CODPRO
							cDescPro 	:= Posicione( "SB1", 1, xFilial( "SB1" ) + (cAliasFrd)->DXL_CODPRO, "B1_DESC" )
							cCodVar 	:= (cAliasFrd)->DXL_CODVAR
							cDescVar 	:= Posicione("NNV",2,FWxFilial("NNV") + (cAliasFrd)->DXL_CODVAR, "NNV_DESCRI")
							cCodUNB 	:= (cAliasFrd)->DXL_CODUNB
							nPsLiqu 	:= (cAliasFrd)->DXL_PSLIQU
						Endif						
					Endif
				Else
					ConsDXLF3()
				Endif
			EndIf
		endIf
	EndIf

	If !lEmpty
		//-------------------------------------------------------------------------------------------------
		// Quando nao localizado percentual maximo de redimento no fardão e no conjunto assume padrão 100%;
		// somente para não apresentar legenda na cor amarela ou vermelha para o usuário
		//-------------------------------------------------------------------------------------------------
		If nRendMax <= 0
			nRendMax := 100
		EndIf

		If lRet
			A615AtuBrw()
		EndIf

		if !Empty(cCodFda) .and.;
		!Empty(cCodTur	) .and.;
		!Empty(cCodUNB ) .and.;
		!Empty(cCodCnj	)
			A615ValCnj()
			oGCodEtq:SetFocus()
		else
			oGCodCnj:SetFocus()
		endif
	endIf

Return( lRet )

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615CodUNB
Validação da Unidade de Beneficiamento

@param: Nil
@author: Bruna Rocio
@since: 23/09/2015
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615CodUNB()
	Local lRet		:= .T.

	cUNB := cCodUNB

	//Ao digitar/alterar o codigo da unidade, limpar turno, fardao e resetar informacoes de conjunto
	cCodTur := space(TamSX3('H7_CODIGO')[1])
	cCodFda := space(TamSX3('DXL_CODIGO')[1])
	ResetConj()
	A615AtuBrw()//Atualizar Browse de Fardinhos na troca de UNB (Limpar)

	if lTelaEst
		aFardao 	:= {}
		AtualFila()
	endIf

	If .NOT. Empty(cCodUNB)
		dbSelectArea( 'DX3' )
		DX3->(dbSetOrder(1))
		If !DX3->(MsSeek(FWxFilial( 'DX3' ) + cCodUNB))
			lRet := .F.
			Help('',1,'REGNOIS',,,1)
		EndIf
		DX3->(DbCloseArea())
	EndIf

	//Valida se a esteira que ja está na tela é da mesma unidade de beneficiamento
	If (lTelaEst .And. !Empty(cCodUNB)) .And. (Empty(MV_PAR09) .Or. MV_PAR09 == 2)
		lRet := .F.
		dbSelectArea( 'N70' )
		N70->(dbGoTop())
		While N70->(!Eof())
			If N70->N70_CODUNB = cCodUNB
				lRet := .T.
				exit
			EndIf
			N70->(dbSkip())
		EndDo
		N70->(DbCloseArea())

		If !lRet
			Help('', 1, OemToAnsi( STR0038 ), , OemToAnsi( STR0071 ), 1 )
		EndIf
	EndIf

	//valida a Unidade de Beneficiamento. Especificamente quando usuário altera o campo cCodUNB em tela
	If !Empty(cCodCnj) .AND. .NOT. Empty(cCodUNB)
		dbSelectArea('DXE')
		DXE->(dbSetOrder(1))
		If DXE->(MsSeek(FWxFilial('DXE')+cCodCnj))
			If DXE->DXE_UBA <> cCodUNB
				ResetConj()
			EndIf
		EndIf
		DXE->(DbCloseArea())
	EndIf

Return( lRet )


/** ------------------------------------------------------------------------------------------
{Protheus.doc} A165CodTur
Validação do Turno

@param: Nil
@author: Ricardo Tomasi
@since: 15/03/2012
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A165CodTur()
	Local lRet		  := .T.
	Local aAreaAtu	  := GetArea()
	
	dbSelectArea( 'SH7' )
	SH7->(dbSetOrder( 1 ))
	If !Empty(cCodTur) .And. !SH7->(MsSeek( FWxFilial( 'SH7' ) + cCodTur ))
		lRet := .F.
		Help('',1,'REGNOIS',,,1)
	EndIf

	SH7->(DbCloseArea())

	If lTelaEst //Algumas validacoes antes de permitir conjuntos
		If (!Empty(MV_PAR09) .And. MV_PAR09 == 1) .And. Empty(cCodFda) //Manutencao de fardao + Fardao Vazio
			Help('', 1, STR0036, , STR0093, 1 ) //#"Favor preencher o código do Fardão"
			oGCodFda:SetFocus()
			cCodTur := space(TamSX3('H7_CODIGO')[1])
		ElseIf (Empty(MV_PAR09) .Or. MV_PAR09 == 2) .And. Empty(cEsteira) //Beneficiamento + Esteira Vazia
			Help('', 1, STR0036, , STR0070, 1 )
			oEsteira:SetFocus()
			cCodTur := space(TamSX3('H7_CODIGO')[1])
		ElseIf (Empty(MV_PAR09) .Or. MV_PAR09 == 2) .And. Empty(cCodFda)// Beneficiamento + Fardao Vazio
			Help('', 1, STR0036, , STR0069, 1 )
			cCodTur := space(TamSX3('H7_CODIGO')[1])
			If Empty(A655GETUNB()) //Primeiro campo UNB
				oGUnBenef:SetFocus()
			Else //Primeiro campo Esteira
				oEsteira:SetFocus()
			EndIf
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( lRet )

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A165DtBen
Validação do Turno

@param: Nil
@author: Bruna Rocio
@since: 08/07/2015
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A165DtBen()
	Local lRet		:= .T.
	Local aAreaAtu	:= GetArea()
	Local lAG615DTB := ExistBlock('AG615DTB')
	Local lExec 

	If lAG615DTB
		lExec := ExecBlock("AG615DTB",.F.,.F.) //Ponto de entrada para manipular a validação da data de beneficiamento
		If ValType(lExec) == "L"
			lRet := lExec 
		EndIf
	ElseIf DtBenef <> dDatabase .AND. !MsgYesNo(OemToAnsi(STR0053),OemToAnsi(STR0036))//""###"Atenção"
		lRet := .F.
	EndIf
	If lRet
		oGCodCnj:SetFocus()
	Endif
	RestArea( aAreaAtu )
Return( lRet )

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615ValCnj
Validação do conjunto

@param: Nil
@author: TOTVS
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615ValCnj()
	Local lRet 		:= .T.

	Static cProdBN   := ''
	Static nPercFixo := 0 // Total de redimento fixo do percentual de separação

	If cCodCnj == Nil .or. Empty(cCodCnj)//Ao invalidar conjunto e usuario forcar, recebe nil
		lRet := .F.
	Else
		nRendMax := Posicione('DXE',1,FwxFilial('DXE') + cCodCnj,'DXE_RDMAX')
	EndIf

	dbSelectArea('DXE')
	DXE->(dbSetOrder(1))

	If lRet .And. DXE->(MsSeek(FWxFilial('DXE')+cCodCnj))
		cPrensa  := SubStr(DXE->DXE_CODSAI,13,1)
		cProdBN  := DXE->DXE_CODPRO //Produto algodão em pluma com arame e tela

		DXC->(dbSetOrder(3)) //Conjunto+pluma
		If DXC->(MsSeek(FWxFilial('DXC')+DXE->DXE_CODIGO+'1'))
			nRendMax := If(nRendMax == 100, (A615AtuBrw(.F.,.T.),DXC->DXC_PERC), nRendMax)

			nPercFixo := 0
			While DXC->(!Eof() .And. DXC_FILIAL == FWxFilial('DXC') .And.  DXC_CODIGO == DXE->DXE_CODIGO)
				If DXC->DXC_TIPO == '1' .And. DXC->DXC_PLUMA <> '1'
					nPercFixo += DXC->DXC_PERC
				EndIf
				DXC->(dbSkip())
			EndDo
		EndIf

		If DXE->DXE_UBA <> cCodUNB .And. !Empty(cCodUNB)
			lRet := .F.
		EndIf
		
	Else
		lRet := .F.
	EndIf

	DXE->(DbCloseArea())

	If lRet
		oGCodEtq:SetFocus()
	Else
		cPrensa	:= Space(1)
	EndIf

	ClearGet({'cCodEtq', 'cCodFdi','nFdiPBr','nFdiPLq'})

	If lAutMala .And. !Empty(cCodCnj) .And. !lManutFard .And. lRet
		UpdBrwMala() //Atualiza grid de mala
	EndIf

	If !lRet
		Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0061  ), 1 ) //"Atenção"###"conjunto informado inválido para a Unidade de Beneficiamento selecionada"
	EndIf

Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615CodEti
Validação da Etiqueta

@param: cEtiqueta - código da etiqueta
@param: lEtiq - Indica se é validação da etiqueta ou do numero do fardo
@author: Aécio Gomes
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615CodEti(cEtiqueta, lEtiq, oBut1)
	Local aArea		:= GetArea()
	Local aAreaDXE	:= DXE->(GetArea())
	Local cFardinho	:= ''
	Local cCodSAI	:= ''
	Local cDigito	:= ''
	Local lRet	 	:= .T.
	Local lEmpty	:= .F.
	Local nPsTara 	:= 0
	Local nTamEtiq	:= TamSX3('DXI_ETIQ')[1]
	Local nTamFdi   := TamSX3('DXI_CODIGO')[1]
	Local cQry		:= ''
	Local cAliasQry	:= ''
	Local cMala		:= ''

	If !Empty(cEtiqueta) .And. !AGRIsNum(cEtiqueta)
		Help('', 1, STR0036, , STR0092, 1 ) //#"Campo numérico."
		Return .F.
	EndIf

	dbSelectArea('DXE')
	DXE->(dbSetOrder(1))
	If DXE->(MsSeek(FWxFilial('DXE')+cCodCnj))
		nPsTara	 := DXE->DXE_PSBAL

		If DXE->DXE_CODSAI <> AllTrim(Substr(cEtiqueta,1,13)) .And. !Empty(cEtiqueta) .And. lEtiq
			dbSelectArea('DXE')
			DXE->(dbSetOrder(2))
			If DXE->(MsSeek(FWxFilial('DXE')+AllTrim(Substr(cEtiqueta,1,13))))
				cCodCnj := DXE->DXE_CODIGO
				cPrensa := SubStr(DXE->DXE_CODSAI,13,1)
				oGCodCnj:Refresh()
			Endif
		Endif	
	ElseIf !Empty(cEtiqueta)
		If lEtiq
			dbSelectArea('DXE')
			DXE->(dbSetOrder(2))
			If DXE->(MsSeek(FWxFilial('DXE')+AllTrim(Substr(cEtiqueta,1,13))))
				cCodCnj := DXE->DXE_CODIGO
				cPrensa := SubStr(DXE->DXE_CODSAI,13,1)
				oGCodCnj:Refresh()
			Endif	
		Else
			lRet := .F.
			Help('', 1, OemToAnsi( STR0038 ), , OemToAnsi( STR0039 ), 1 ) //"Atenção!"###"Conjunto da etiqueta inválido ou não encontrado no sistema!!!"
		Endif	
	EndIf

	If Empty(cEtiqueta)
		lEmpty 	:= .T.
		cCodFdi := Space(nTamFdi)
		cCodEtq := Space(nTamEtiq)
	EndIf

	If lRet .And. !lEmpty

		//----------------------------------------
		// Valida o dígito verificar da Etiqueta 
		//----------------------------------------
		If !lEtiq
			cEtiqueta := PADL(Alltrim(cEtiqueta),6,'0')
			cEtiqueta := DXE->DXE_CODSAI+Alltrim(cEtiqueta)
			cEtiqueta += SAIDigito(cEtiqueta)

		Else
			cDigito := SAIDigito(SubStr(cEtiqueta,1,19))
			If DXE->DXE_CODSAI <> SubStr(cEtiqueta,0,13)
				lRet := .F.
				Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0040 ), 1 ) //"Atenção"###"Etiqueta inválida"
			EndIf

			If lRet .And. cDigito <> SubStr(cEtiqueta,20,1)
				lRet := .F.
				Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0040 ), 1 ) //"Atenção"###"Etiqueta inválida"
			EndIf
		EndIf

		If lRet
			cCodEtq := cEtiqueta
		EndIf

		If lRet

			cAliasQry := GetNextAlias()
			cQry := "SELECT DXI_SAFRA,DXI_ETIQ"
			cQry += " FROM "+ RetSqlName("DXI") + " DXI"
			cQry += " WHERE	DXI.DXI_FILIAL 	= '"+FWxFilial("DXI")+"'"

			if _lNovSafra
				cQry += " AND DXI.DXI_SAFRA 	= '"+ PADR(cSafra,TamSx3('DXL_SAFRA')[1],' ')+"'"
			else
				cQry += " AND DXI.DXI_SAFRA 	= '"+cSafra+"'"
			endIf

			cQry += " AND DXI.DXI_ETIQ 		= '"+cCodEtq+"'"
			cQry += " AND DXI.D_E_L_E_T_	= ' ' "

			cQry := ChangeQuery( cQry )
			dbUseArea( .T., 'TOPCONN', TcGenQry( , , cQry ), cAliasQry, .F., .T. )

			If !(cAliasQry)->(Eof())
				lRet := .F.
				Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0041 ), 1 ) //"Atenção"###"Ja existe etiqueta cadastrada com esta numeração!!!"
			Endif

			If lRet
				cCodSAI:= Substr( cCodEtq, 1, TamSX3('DXE_CODSAI')[1] )
				cFardinho := Substr( cCodEtq, TamSX3('DXE_CODSAI')[1]+1, nTamFdi )
			EndIf

			If lRet
				cCodFdi := cFardinho
				oGCodFdi:Refresh()
				If ExistBlock( 'AGR615PS' )
					nFdiPBr := ExecBlock( 'AGR615PS', .f., .f. )
				Else
					AGRX003A( @nFdiPBr, .f., aPerBal)
				EndIf

				//Quando pesagem manual posiciona no peso bruto, caso contrario, posiciona no botão salvar
				If aPerBal[ 3 ]
					oGFdiPBr:SetFocus()
				Else
					nFdiPLq := nFdiPBr - DXE->( DXE_PSBAL )
					oGFdiPLq:Refresh()
					oBut1:SetFocus()
				EndIf
				A615PsBrt()
				oGFdiPBr:Refresh()

			EndIf
			(cAliasQry)->(DbCloseArea())

			If lRet .And. lAutMala .And. .Not. Empty(MV_PAR09) .And. MV_PAR09 == 2
				cMala := fPesqAmost(cSafra, cCodEtq)
				If .Not. Empty(cMala)
					lRet := .F.
					//#"O fardo faz parte de uma mala: .Não é possível beneficiar e vincular a uma mala automaticamente. "
					//#"Favor realizar o beneficiamento em modo de manutenção de fardão. "
					Help('', 1, STR0036 , , STR0103 + cValToChar(cMala) + ". " + STR0090 + STR0091 , 1 ) 
				EndIf
			EndIf

			//Ponto de Entrada 
			If lRet .And. ExistBlock('AGRA615PE')
				lRet := ExecBlock('AGRA615PE',.F.,.F.)
			EndIf			

		EndIf
	EndIf

	DXE->(DbCloseArea())

	RestArea(aArea)
	RestArea(aAreaDXE)
Return( lRet )

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615PsBrt
Validação do peso bruto e atualização do peso líquido do fardo

@param: lGrava - Indica se valida o peso para gravação dos dados
@author: Aécio Gomes
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615PsBrt(lGrava)
	Local aArea := GetArea()
	Local lRet 	:= .T.

	Default lGrava := .F.

	dbSelectArea('DXE')
	DXE->(dbSetOrder(1))
	If DXE->(MsSeek(FWxFilial('DXE')+cCodCnj))
		If lGrava
			If lRet .And. DXE->DXE_PSMAX < nFdiPBr
				lRet := .F.
				Help('', 1, OemToAnsi( STR0042 ), , OemToAnsi( STR0043 ), 1 ) //"Peso Maximo"###"O peso da fardo maior que o máximo estabelecido para este conjunto!"
			EndIf

			If lRet .And. DXE->DXE_PSMIN > nFdiPBr
				lRet := .F.
				Help('', 1, OemToAnsi( STR0044 ), , OemToAnsi( STR0045 ), 1 ) //"Peso Minimo"###"O peso da fardo é menor que o minimo estabelecido para este conjunto!"
			EndIf
		Else
			nFdiPLq := nFdiPBr - DXE->( DXE_PSBAL )
			oGFdiPLq:Refresh()			
		EndIf
	Else
		lRet := .F.
		Help('', 1, OemToAnsi( STR0036 ), , STR0046, 1 ) //"Atenção"###"Conjunto inválido ou nao localizado!"
	EndIf

	DXE->(DbCloseArea())

	RestArea(aArea)
Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615AtuBrw
Atualiza Browser de monitor da produção e o Painel de Rendimento

@param: lAtuMonit - Atualiza o monitor da produção 
@param: lAtuPanel - Atualiza o paninel de rendimento
@author: Aécio Gomes
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615AtuBrw(lAtuMonit, lAtuPanel)
	Local nPerRen	:= A615REND()
	Local nPerAux   := (nRendMax - (nRendMax*10/100))
	Local oModel	  := FwModelActive()
	Local nOperation  := IIF(oModel != nil, oModel:GetOperation(),4)
	Default lAtuMonit := .T.
	Default lAtuPanel := .T.

	If lAtuMonit
		If nOperation != MODEL_OPERATION_DELETE //Deletando, estou posicionado e filtrado
			oBrowse:FWFilter():CleanFilter()
			oBrowse:CleanExFilter()
			oBrowse:FWFilter():DeleteFilter()

			if _lNovSafra
				oBrowse:SetFilterDefault("DXI_FILIAL=='" + FWxFilial("DXI") + "' .AND.DXI_FARDAO=='" + cCodFda + "' .AND.DXI_SAFRA=='" + PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ') + "' .AND.DXI_PRDTOR=='" + cProdutor + "' .AND.DXI_LJPRO=='" + cLjPro + "' .AND.DXI_FAZ=='" + cCodFaz + "'")
			else
				oBrowse:SetFilterDefault("DXI_FILIAL=='" + FWxFilial("DXI") + "' .AND.DXI_FARDAO=='" + cCodFda + "' .AND.DXI_SAFRA=='" + cSafra + "' .AND.DXI_PRDTOR=='" + cProdutor + "' .AND.DXI_LJPRO=='" + cLjPro + "' .AND.DXI_FAZ=='" + cCodFaz + "'")
			endIf

			oBrowse:Refresh(.T.)
		EndIf
	EndIf

	//------------------------------------------------------------------------------
	// Calcula 10% do rendimento máximo para mudança de cor do painel de rendimento
	//------------------------------------------------------------------------------
	If lAtuPanel
		oPnlRend:cTitle := STR0001 + chr( 13 ) + chr( 10 ) + Transform( nPerRen, '@E 999.99' ) + '%' //"Rendimento"

		If nPerRen >= nPerAux .And. nPerRen < nRendMax
			oPnlRend:nClrPane := CLR_YELLOW
		ElseIf nPerRen >= nRendMax
			oPnlRend:nClrPane := CLR_HRED
		Else
			oPnlRend:nClrPane := CLR_GREEN
		EndIf
		oPnlRend:Refresh()
	EndIf

Return(.T.)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615REND
Retorna o percentual total de redimento de algodão em pluma do fardao

@param: Nil
@author: Aécio Gomes
@since: 16/04/2012
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615REND()
	Local nPerRen   := 0
	Local cQry      := ''
	Local cAliasQry := GetNextAlias()

	cAliasQry := GetNextAlias()
	cQry := "SELECT COUNT(DXI_ETIQ) AS QTDFDI, SUM(DXI_PSBRUT) AS TOTPSBRUT, SUM(DXI_PSLIQU) AS TOTPSLIQU"
	cQry += " FROM "+ RetSqlName("DXI") + " DXI"
	cQry += " WHERE	DXI.DXI_FILIAL = '"+FWxFilial("DXI")+"'"
	cQry += " AND DXI.DXI_FARDAO	= '"+cCodFda+"'"

	if _lNovSafra
		cQry += " AND DXI.DXI_SAFRA 	= '"+ PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ')+"'"
	else
		cQry += " AND DXI.DXI_SAFRA 	= '"+cSafra+"'"
	endIf

	cQry += " AND DXI.DXI_PRDTOR 	= '"+cProdutor+"'"
	cQry += " AND DXI.DXI_LJPRO		= '"+cLjPro+"'"
	cQry += " AND DXI.DXI_FAZ 		= '"+cCodFaz+"'"
	cQry += " AND DXI.D_E_L_E_T_	= ' ' "

	cQry := ChangeQuery( cQry )
	dbUseArea( .T., 'TOPCONN', TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	nPerRen := Round( ( TOTPSLIQU / nPsLiqu ) * 100, 2 )

	nTotFdi 	:= QTDFDI
	nTotBrut	:= TOTPSBRUT
	nTotLiqu 	:= TOTPSLIQU

	//Fecha arquivo temporario
	(cAliasQry)->(DbCloseArea())

Return(nPerRen)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615Salvar
Grava os dados da etiqueta na tabela

@param: lEtiq - Indica se seta o foco da digitação na etiqueta ou no fardo
@author: Ricardo Tomasi
@since: 15/03/2012
@Uso: AGRA615
@type function
------------------------------------------------------------------------------------------ **/
Static Function A615Salvar(lEtiq, oBut1)	
	Local nTotRend  := 0
	Local lRet		:= .T.
	Local aCposCab 	:= {}	// Irá conter os Cpos da DXJ
	Local aCposDet 	:= {}	// Irá conter os Cpos da DXK
	Local aCposMast := {}
	Local aFards 	:= {}
	Local nI1 		:= 0
	Local aMovFrd	:= {}
	Local cUltRed	:=  iif(DXE->(ColumnPos( 'DXE_ULTREN' )) > 0, Posicione('DXE',1,FWxFilial('DXE')+cCodCnj,'DXE_ULTREN'),"2")
	Local lIniNvFar := .F.
	Local lTurnoRetro := SuperGetMV("MV_AGRO048", .F., .F.)

	//Mala
	Local cEtiqTmp
	Local nFdiPLqTmp := nFdiPLq
	Local nFdiPBrTmp := nFdiPBr
	Local lExistMala := .F.
	Private cFardTmp := cCodFdi
	__nFdiLq := nFdiPLq
	lRet := A615PsBrt(.T.)

	If lRet.And. Empty(cCodEtq)
		lRet := .F.
	EndIf

	If lRet .And. nFdiPLq <= 0
		lRet := .F.
	EndIf

	//Valida o código e verifica se  obedece o sequenciamento
	If(lRet .And. lAutMala)
		// Se achou amostras. Não valida codigo
		If !lManutFard //Nao e manutencao fardao
			lRet   	  := VldCodFdi(cCodFdi)
		EndIf
		cFardTmp  := cCodFdi
		cEtiqTmp  := cCodEtq
	EndIf
	If lRet .and. ValType(MV_PAR13) == "N" .AND. !lTurnoRetro
		If  .NOT. MV_PAR13 == 1// SE O TURNO FOR RETROATIVO NÃO ATUALIZA A DATA
			//Atualiza a data de beneficiamento
			//devido ao horário de início do beneficiamento
			//e a database do início do beneficiamento.//solicitado pela bom futuro
			If .Not. lManutFard
				If ( Date() - DtBenef ) = 1 
					DtBenef := Date()
				Endif
			Endif
		EndIf
	Elseif MV_PAR09 == 2 .AND. MV_PAR13 == 1 .AND. lTurnoRetro // Não é manutenção de fardão, é turno retroativo e MV_AGRO048 == .T. 
		dbSelectArea( 'SH7' )
		If SH7->(MsSeek( FWxFilial( 'SH7' ) + cCodTur ))
			A165VldDtB(SH7->H7_ALOC)
		Endif		
	Endif
	
	SH7->(DbCloseArea())

	If lRet			
		dbSelectArea( 'DXL' )
		DXL->(dbSetOrder(1))// Filial+Codigo+safra+Produtor+Fazenda
		if _lNovSafra
			Begin Transaction
				If DXL->(MsSeek( fwxFilial( 'DXL' )+cCodFda+PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ')+cProdutor+cLjPro+cCodfaz))
					dbSelectArea( 'DXI')
					If RecLock( 'DXI', .T. )
						DXI_FILIAL	:= FWxFilial( 'DXI' )
						DXI_ETIQ	:= cCodEtq
						DXI_CODIGO	:= cCodFdi
						DXI_FARDAO	:= cCodFda
						DXI_COSTEL	:= IIf( lCostelado, '2', '1' )
						DXI_CODCNJ	:= cCodCnj
						DXI_PRENSA	:= cPrensa
						DXI_CODPRO	:= cProdBN
						DXI_CODVAR	:= DXL->DXL_CODVAR
						DXI_CODTUR	:= cCodTur
						DXI_SAFRA	:= PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ')
						DXI_PRDTOR	:= cProdutor
						DXI_LJPRO	:= cLjPro
						DXI_FAZ	    := cCodFaz
						DXI_DATA	:= DtBenef
						DXI_HORA	:= Substr( Time(), 1, 5 )
						DXI_PSBRUT	:= nFdiPBr
						DXI_PSLIQU	:= nFdiPLq
						DXI_PSESTO  := DXI_PSLIQU
						If DXI->(ColumnPos( 'DXI_PSTARA' )) > 0
							DXI_PSTARA  := nFdiPBr - nFdiPLq
						EndIf
						DXI_CODUNB  := cCodUNB
						DXI_CODUSU	:= RetCodUsr()
						DXI_LOCAL	:= cLocalPro
						DXI_INICOL	:= DXL->DXL_INICOL
						DXI_ENCCOL	:= DXL->DXL_ENCCOL
						DXI_STATUS	:= "10" //Beneficiado
						DXI->(MsUnLock())
					EndIf

					If DXL->DXL_CODUNB <> cCodUNB .And. !Empty(cCodUNB) //Validar fardao antes do beneficiamento
						Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0058  ), 1 ) //"Atenção"###"Fardão informado inválido para a Unidade de Beneficiamento selecionada"
						If Empty(A655GETUNB())
							oGUnBenef:SetFocus()
						ElseIf !Empty(MV_PAR09) .And. MV_PAR09 == 1 //Manutencao de fardao
							oGCodFda:SetFocus()
						Else
							oEsteira:SetFocus()
						EndIf
						lRet := .F.
					Endif
					

					If lRet
						If lEtiq
							ClearGet({'cCodFdi'})
							oGCodEtq:SetFocus()
						Else
							cCodFdi := Soma1(cCodFdi)
							oGCodFdi:SetFocus()
						EndIf

						ClearGet({'cCodEtq','nFdiPBr','nFdiPLq'})

						aMovFrd :=  {{	;
						{"N9D_FILIAL", FwxFilial("N9D")	},;
						{"N9D_SAFRA" , DXI->DXI_SAFRA  	},;
						{"N9D_FARDO" , DXI->DXI_ETIQ	},;
						{"N9D_TIPMOV", "01" 			},;
						{"N9D_PESINI", DXI->DXI_PSLIQU 	},;
						{"N9D_PESFIM", DXI->DXI_PSLIQU	},;							 									 		
						{"N9D_DATA"  , dDAtaBase 		},;
						{"N9D_STATUS", "2" 				},;
						{"N9D_ENTLOC", DXI->DXI_PRDTOR 	},;
						{"N9D_LOJLOC", DXI->DXI_LJPRO 	},;							 		
						{"N9D_CODROM", DXL->DXL_CODROM 	},;
						{"N9D_FILORG", FwxFilial("DXI")	},;
						{"N9D_CODFAR", DXI->DXI_CODIGO	},;
						{"N9D_LOCAL" , DXI->DXI_LOCAL	} ;
						}}

						lRet := A615GrvMov("Inclui", aMovFrd)
					EndIf

					if lRet

						// Busca o percentual total de rendimento de algodao em pluma do fardão 
						nTotRend := A615REND()

						/*************************************************/
						/* Ponto de entrada para que com base nas infos  */
						/* do fardinho a gravação possa prosseguir ou    */
						/* ser interrompida                              */
						/*************************************************/
						If ExistBlock("AG615SAVE")
							lRet := ExecBlock("AG615SAVE", .F., .F., { {cCodEtq, cCodFdi, cCodFda, cCodCnj, cProdBN,;
							cSafra, cProdutor, cLjPro, cCodFaz, cCodUNB,;
							nFdiPBr, nFdiPLq} })
						Endif
					endIf

					//Verifica data de produção Dia -1
					If lRet .And. RecLock( 'DXL', .F. )
						if AGRIFDBSEEK("DXI", cCodFda,2,.F.)
							aMatriz:= AGRBUSREGIS("DXI","DXI_FILIAL+DXI_FARDAO",2,.F.,.F.,"DXI_FILIAL= xFilial('DXI').and.  DXI_FARDAO = cCodFda",	{{"DXI_DATA"},{"DXI_HORA"}},,,"M",)
							aFardos := aclone(aMatriz[2])
							aFardos:= ASort( aFardos, , , { | x, y | dtos(x[ 1 ]) + x[ 2 ] < dtos(y[ 1 ]) + y[ 2 ]})
							cMenoDATA:= aFardos[1,1]
							cMenoHora:= aFardos[1,2]
							vVetRet := ARGULTMDHCALE(DXI->DXI_DATA,cCodTur)
							cHoraIT := vVetRet[2]

							DXL->DXL_DTBEN := DXI->DXI_DATA
							DXL->DXL_CODTUR 	:= cCodTur

							If Empty(DXL->DXL_CODCNJ)
								DXL->DXL_CODCNJ := cCodCnj
							endif

						endif

						If nTotRend >= nRendMax .And. MSGYESNO(STR0048, FunName()) //"O fardão atingiu o percentual máximo de redimento, Deseja iniciar um novo fardão? "

							//Bruna

							cCodFdi := cFardTmp
							oGCodFdi:SetFocus()

							lIniNvFar  := .T.

							If cUltRed = "2" //conjunto não permite ultrapassar o rendimento máximo
								lRet := .F.	 //desfaz o beneficiamento se ultrapassou o rendimento máximo
							Else
								DXL->DXL_RDMTO 	:= nTotRend
								DXL->DXL_STATUS := '5' 		// Status 5=Beneficiado
								If DXL->(ColumnPos( 'DXL_HRBEN' )) > 0
									DXL->DXL_FILBEN	:= FWxFilial('DXI')
									DXL->DXL_HRBEN  := Time()
								endIf

							EndIF

						Else
							If nTotRend >= nRendMax  .AND. cUltRed = "2" //conjunto não permite ultrapassar o rendimento máximo
								lRet := .F.	 //desfaz o beneficiamento se ultrapassou o rendimento máximo

								cCodFdi := cFardTmp
								oGCodFdi:SetFocus()

								ClearGet({'cCodEtq','nFdiPBr','nFdiPLq'})
							Else
								If DXL->DXL_STATUS <> '4'
									DXL->DXL_STATUS := '4' 		// Status 4=Em Beneficiamento
									If DXL->(ColumnPos( 'DXL_FILBEN' )) > 0
										DXL->DXL_FILBEN := FWxFilial('DXI')
									Endif
									If lTelaEst
										CarregaTemp()
									EndIf

									If !Empty(cCodCnj)
										DXL->DXL_CODCNJ := cCodCnj	// Atualiza o codigo do conjunto
									Endif
								EndIf
							EndIf
						EndIf
						DXL->(MsUnlock())
					EndIf

					If DXK->(ColumnPos( 'DXK_TIPO' )) > 0
						If(lRet .And. lAutMala) .And. (!lManutFard) //Nao e manutencao fardao

							//Valida se pode montar mala com o codigo digitado
							lExistMala := fPesqMala(cFardTmp)
							If lExistMala												  //#O fardo faz parte de uma mala fechada
								lRet := .F.												  //#Não é possível beneficiar e vincular a uma mala automaticamente
								Help('', 1, STR0036 , , STR0089 + STR0090 + STR0091, 1 )  //#Favor realizar o beneficiamento em modo de manutenção de fardão
							EndIf

							If lRet
								// Montagem das malas
								aMalas := MontaMala(cFardTmp)

								// Montagem das amostras
								aAdd( aFards, { 'DXK_TIPO'	, "1" } ) // Tipo de Amostra, 1 - Visual, 2 - HVI						
								aAdd( aFards, { 'DXK_SAFRA' , DXL->DXL_SAFRA } ) // Safra
								aAdd( aFards, { 'DXK_ETIQ' , cEtiqTmp } ) // Código da Etiqueta
								aAdd( aFards, { 'DXK_FARDO' , cFardTmp } ) // Código do Fardo
								aAdd( aFards, { 'DXK_PSLIQU' , nFdiPLqTmp } ) // Peso Líquido do Fardo
								aAdd( aFards, { 'DXK_PSBRUT' , nFdiPBrTmp } ) // Peso bruto do fardo
								aAdd( aFards, { 'DXK_CODVAR' , DXL->DXL_CODVAR } ) // Código da Variedade para Descrição da Variedade
								aAdd( aFards, { 'DXK_TALHAO' , DXL->DXL_TALHAO } ) // Talhão

								For nI1 := 1 To 2
									If(nI1 ==1)
										aAdd( aCposMast, aCposCab )
										aAdd( aCposDet, aFards )
									Else
										aAdd( aCposMast, aClone(aCposCab) )
										aAdd( aCposDet, aClone(aFards) )
									EndIf
								Next
								aCposDet[2][1][2] := "2" // Atribuição para cadastro de amostra hvi
								fncMalaGRV(aMalas, aCposDet) // Função responsavel por criar mala e amostras
							EndIf
						EndIf
					endIf

				Else
					lRet := .F.
					Help('', 1, STR0036 , , STR0049, 1 ) //"Atenção"###"Código do fardão invalido ou não localizado!"
				EndIf
				If !lRet
					DisarmTransaction()
					Break
				EndIf

			End Transaction
		else
			Begin Transaction
				If DXL->(MsSeek(FWxFilial('DXL')+cCodFda+cSafra+cProdutor+cLjPro+cCodfaz))
					dbSelectArea( 'DXI' )
					If RecLock( 'DXI', .T. )
						DXI_FILIAL	:= FWxFilial( 'DXI' )
						DXI_ETIQ	:= cCodEtq
						DXI_CODIGO	:= cCodFdi
						DXI_FARDAO	:= cCodFda
						DXI_COSTEL	:= IIf( lCostelado, '2', '1' )
						DXI_CODCNJ	:= cCodCnj
						DXI_PRENSA	:= cPrensa
						DXI_CODPRO	:= cProdBN
						DXI_CODVAR	:= DXL->DXL_CODVAR
						DXI_CODTUR	:= cCodTur
						DXI_SAFRA	:= cSafra
						DXI_PRDTOR	:= cProdutor
						DXI_LJPRO	:= cLjPro
						DXI_FAZ	    := cCodFaz
						DXI_DATA	:= DtBenef
						DXI_HORA	:= Substr( Time(), 1, 5 )
						DXI_PSBRUT	:= nFdiPBr
						DXI_PSLIQU	:= nFdiPLq
						If DXI->(ColumnPos( 'DXI_PSTARA' )) > 0
							DXI_PSTARA  := nFdiPBr - nFdiPLq
						EndIf
						DXI_PSESTO  := DXI->DXI_PSLIQU
						DXI_CODUNB  := cCodUNB
						if DXI->(ColumnPos('DXI_INICOL' )) > 0 .AND. DXI->(ColumnPos('DXI_ENCCOL' )) > 0
							DXI_INICOL	:= DXL->DXL_INICOL
							DXI_ENCCOL	:= DXL->DXL_ENCCOL
						endIf
						DXI_CODUSU	:= RetCodUsr()
						DXI_LOCAL	:= cLocalPro
						DXI->(MsUnLock())
					EndIf
					DXI->(DbCloseArea())
					If DXL->DXL_CODUNB <> cCodUNB .And. !Empty(cCodUNB) //Validar fardao antes do beneficiamento
						Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0058  ), 1 ) //"Atenção"###"Fardão informado inválido para a Unidade de Beneficiamento selecionada"
						If Empty(A655GETUNB())
							oGUnBenef:SetFocus()
						ElseIf !Empty(MV_PAR08) .And. MV_PAR08 == 1 //Manutencao de fardao
							oGCodFda:SetFocus()
						Else
							oEsteira:SetFocus()
						EndIf
						lRet := .f.
					Endif

					If lRet
						If lEtiq
							ClearGet({'cCodFdi'})
							oGCodEtq:SetFocus()
						Else
							cCodFdi := Soma1(cCodFdi)
							oGCodFdi:SetFocus()
						EndIf

						ClearGet({'cCodEtq','nFdiPBr','nFdiPLq'})

						// Busca o percentual total de rendimento de algodao em pluma do fardão 
						nTotRend := A615REND()
						/*************************************************/
						/* Ponto de entrada para que com base nas infos  */
						/* do fardinho a gravação possa prosseguir ou    */
						/* ser interrompida                              */
						/*************************************************/
						If ExistBlock("AG615SAVE")
							lRet := ExecBlock("AG615SAVE", .F., .F., { {cCodEtq, cCodFdi, cCodFda, cCodCnj, cProdBN,;
							cSafra, cProdutor, cLjPro, cCodFaz, cCodUNB,;
							nFdiPBr, nFdiPLq} })
						Endif
					EndIf

					//Verifica data de produção Dia -1
					If lRet .And. RecLock( 'DXL', .F. )
						if AGRIFDBSEEK("DXI", cCodFda,2,.F.)
							aMatriz:= AGRBUSREGIS("DXI","DXI_FILIAL+DXI_FARDAO",2,.F.,.F.,"DXI_FILIAL= xFilial('DXI').and.  DXI_FARDAO = cCodFda",	{{"DXI_DATA"},{"DXI_HORA"}},,,"M",)
							aFardos := aclone(aMatriz[2])
							aFardos:= ASort( aFardos, , , { | x, y | dtos(x[ 1 ]) + x[ 2 ] < dtos(y[ 1 ]) + y[ 2 ]})
							cMenoDATA:= aFardos[1,1]
							cMenoHora:= aFardos[1,2]
							vVetRet := ARGULTMDHCALE(DXI->DXI_DATA,cCodTur)
							cHoraIT := vVetRet[2]

							DXL->DXL_DTBEN := DXI->DXI_DATA
							DXL->DXL_CODTUR 	:= cCodTur

							If Empty(DXL->DXL_CODCNJ)
								DXL->DXL_CODCNJ := cCodCnj
							endif

						endif

						If nTotRend >= nRendMax .And. MSGYESNO(STR0048, FunName()) //"O fardão atingiu o percentual máximo de redimento, Deseja iniciar um novo fardão? "
							DXL->DXL_RDMTO 	:= nTotRend
							DXL->DXL_STATUS := '5' 		// Status 5=Beneficiado
							if DXL->(ColumnPos('DXL_FILBEN' )) > 0
								DXL->DXL_FILBEN := FWxFilial('DXI')
							endIf

							If DXL->(ColumnPos( 'DXL_HRBEN' )) > 0
								DXL->DXL_HRBEN  := Time()
							endIf

							ClearGet({'cCodFda','nPsLiqu','cCodEtq','cCodFdi'})
							oGCodFda:SetFocus()

							If lTelaEst
								CarregaTemp()
							EndIf

						Else
							If DXL->DXL_STATUS <> '4'
								DXL->DXL_STATUS := '4' 		// Status 4=Em Beneficiamento

								if DXL->(ColumnPos('DXL_FILBEN' )) > 0
									DXL->DXL_FILBEN := FWxFilial('DXI')
								endIf

								If lTelaEst
									CarregaTemp()
								EndIf

								If !Empty(cCodCnj)
									DXL->DXL_CODCNJ := cCodCnj	// Atualiza o codigo do conjunto
								Endif
							EndIf
						EndIf
						DXL->(MsUnLock())
					EndIf
				Else
					lRet := .F.
					Help('', 1, STR0036 , , STR0049, 1 ) //"Atenção"###"Código do fardão invalido ou não localizado!"
				EndIf
				If !lRet
					DisarmTransaction()
					Break
				EndIf

			End Transaction
		EndIF
	EndIf
	If lRet
		if ValType(mv_par06) = 'C'
			If mv_par07 == 1
				A615Print()
			ElseIf mv_par07 == 3
				If MsgYesNo("Deseja imprimir a Etiqueta de Pesagem para esse fardinho?", "Etiqueta de Pesagem")//"Deseja imprimir a Etiqueta de Pesagem para esse fardinho?", "Etiqueta de Pesagem"
					A615Print()
				EndIf
			EndIf
		Else
			If mv_par06 == 1
				A615Print()
			ElseIf mv_par06 == 3
				If MsgYesNo("Deseja imprimir a Etiqueta de Pesagem para esse fardinho?", "Etiqueta de Pesagem")//"Deseja imprimir a Etiqueta de Pesagem para esse fardinho?", "Etiqueta de Pesagem"
					A615Print()
				EndIf
			EndIf
		EndIf
	Endif

	If lIniNvFar //Inicializa novo fardão

		If !lRet
			// Busca o percentual total de rendimento de algodao em pluma do fardão 
			nTotRend := A615REND()

			DXL->(dbSelectArea('DXL'))
			DXL->(dbSetOrder(1))// Filial+Codigo+safra+Produtor+Fazenda
			IF (DXL->(MsSeek(FWxFilial('DXL')+cCodFda+PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ')+cProdutor+cLjPro+cCodfaz)))			
				Reclock('DXL', .F.)
				DXL->DXL_RDMTO 	:= nTotRend
				DXL->DXL_STATUS := '5' 		// Status 5=Beneficiado	
				If DXL->(ColumnPos( 'DXL_FILBEN' )) > 0
					DXL->DXL_FILBEN	:= FWxFilial('DXI')
					DXL->DXL_HRBEN  := Time()
				Endif
				DXL->(MsUnlock())
			EndIf

			lRet := .T.
		EndIf

		ClearGet({'cCodFda','nPsLiqu','cCodEtq','cCodFdi'})
		oGCodFda:SetFocus()

		//chama update automático
		If mv_par08 == 1
			MsgRun( STR0107 , STR0106 , {|| A615AutEnF() })//"Gerando as movimentações de Estoque" //"Aguarde"
		ElseIf mv_par08 == 3
			If MsgYesNo(STR0109, STR0108) //"Realizar o encerramento automático do Fardão?" //"Encerramento Automático"
				MsgRun( STR0107 , STR0106 , {|| A615AutEnF() }) //"Gerando as movimentações de Estoque" //"Aguarde"
			EndIf
		EndIf

		DXL->(DbCloseArea())

		If lTelaEst
			CarregaTemp()
		EndIf
	EndIf

	//-------------------------------------
	// Atualiza o browse do Beneficiamento
	//-------------------------------------
	A615AtuBrw()

	//-------------------------------------
	// Atualiza o browse de Mala
	//-------------------------------------
	If(lRet .And. lAutMala) .And. !lManutFard
		UpdBrwMala()
	EndIf

	If !lRet
		If aPerBal[ 3 ] //Pesagem Manual
			oGFdiPBr:SetFocus()
		Else
			If lEtiq
				oGCodEtq:SetFocus()
			Else
				oGCodFdi:SetFocus()
			EndIf
		Endif
	Endif

Return(Nil)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615Limpar
Limpa o conteúdo dos Gets de Etiqueta e Fardo, Peso Bruto e Peso Líquido

@param: lEtiq - Indica se seta o foco da digitação na etiqueta ou no fardo
@author: Aécio Gomes
@since: 15/03/2012
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615Limpar(lEtiq)

	ClearGet({'cCodEtq','cCodFdi','nFdiPBr','nFdiPLq'})

	If lEtiq
		oGCodEtq:SetFocus()
	Else
		oGCodFdi:SetFocus()
	EndIf

Return(Nil)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615Encer
Encerramento manual do beneficiamento

@param: Nil
@author: Aécio Gomes
@since: 03/04/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615Encer()	
	Local lRet    := .T.
	Local nRDMIN  := Posicione('DXE',1,FwxFilial('DXE')+cCodCnj,'DXE_RDMIN')

	dbSelectArea('DXI')
	DXI->(dbSetOrder(2))
	If !(DXI->(MsSeek(FWxFilial('DXI')+cCodFda)))
		Help('', 1, OemToAnsi( STR0036 ), , STR0060, 1 ) //"Atenção"###"Conjunto inválido ou nao localizado!"
		Return
	Endif

	DXI->(DbCloseArea())

	dbSelectArea('DXL')
	DXL->(dbSetOrder(1))

	if _lNovSafra
		lRet := DXL->(MsSeek(FWxFilial( 'DXL' )+cCodFda+PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ')+cProdutor+cLjPro+cCodfaz))

		If lRet
			// Busca o percentual total de rendimento de algodao em pluma do fardão
			nTotRend := A615REND()

			If nRDMIN > nTotRend
				If ApMsgYesNo( STR0059) //"Fardão não atingiu o rendimento mínimo estipulado. Deseja encerrar mesmo assim?"
					Reclock('DXL', .F.)
					DXL->DXL_RDMTO 	:= nTotRend
					DXL->DXL_STATUS := '5' // Status 5=Beneficiado
					if DXL->(ColumnPos('DXL_FILBEN' )) > 0
						DXL->DXL_FILBEN	:= FWxFilial('DXI')
					endIf

					If DXL->(ColumnPos( 'DXL_HRBEN' )) > 0
						DXL->DXL_HRBEN  := Time()
					endIf
					DXL->(MsUnlock())

					ClearGet({'cCodFda','nPsLiqu','cCodEtq','cCodFdi'})
					oGCodFda:SetFocus()

					If DXJ->(ColumnPos( 'DXJ_QTVINC' )) > 0
						//chama update automático
						If mv_par08 == 1
							MsgRun( STR0107 , STR0106 , {|| A615AutEnF() }) //"Gerando as movimentações de Estoque" //Aguarde
						ElseIf mv_par08 == 3
							If MsgYesNo(STR0109, STR0108) //"Realizar o encerramento automático do Fardão?" //"Encerramento Automático"
								MsgRun( STR0107 , STR0106 , {|| A615AutEnF() }) //"Gerando as movimentações de Estoque" //Aguarde
							EndIf
						EndIf
					endIf
				Endif
			ElseIf ApMsgYesNo( STR0050) //"Deseja Encerrar o beneficiamento deste fardão?"
				Reclock('DXL', .F.)
				DXL->DXL_RDMTO 	:= nTotRend
				DXL->DXL_STATUS := '5' 		// Status 5=Beneficiado
				if DXL->(ColumnPos('DXL_FILBEN' )) > 0
					DXL->DXL_FILBEN	:= FWxFilial('DXI')
				endIf

				If DXL->(ColumnPos( 'DXL_HRBEN' )) > 0
					DXL->DXL_HRBEN  := Time()
				endIf
				DXL->(MsUnlock())

				ClearGet({'cCodFda','nPsLiqu','cCodEtq','cCodFdi'})
				oGCodFda:SetFocus()

				If DXJ->(ColumnPos( 'DXJ_QTVINC' )) > 0
					//chama update automático
					If mv_par08 == 1
						MsgRun( STR0107 , STR0106 , {|| A615AutEnF() }) //"Gerando as movimentações de Estoque" //Aguarde
					ElseIf mv_par08 == 3
						If MsgYesNo(STR0109, STR0108) //"Realizar o encerramento automático do Fardão?" //"Encerramento Automático"
							MsgRun( STR0107 , STR0106 , {|| A615AutEnF() }) //"Gerando as movimentações de Estoque" //Aguarde
						EndIf
					EndIf
				endIf
			EndIf
		EndIf

		A615AtuBrw(.T., .T.)
		oBrowse:SetFilterDefault("DXI_FILIAL=='" + FWxFilial("DXI") + "' .AND.DXI_FARDAO=='" + cCodFda + "' .AND.DXI_SAFRA=='" + PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ') + "' .AND.DXI_PRDTOR=='" + cProdutor + "' .AND.DXI_LJPRO=='" + cLjPro + "' .AND.DXI_FAZ=='" + cCodFaz + "'")
	else
		lRet := DXL->(MsSeek(FWxFilial('DXL')+cCodFda+cSafra+cProdutor+cLjPro+cCodfaz))

		If lRet
			// Busca o percentual total de rendimento de algodao em pluma do fardão
			nTotRend := A615REND()

			If nRDMIN > nTotRend
				If ApMsgYesNo( STR0059) //"Fardão não atingiu o rendimento mínimo estipulado. Deseja encerrar mesmo assim?"
					Reclock('DXL', .F.)
					DXL->DXL_RDMTO 	:= nTotRend
					DXL->DXL_STATUS := '5' // Status 5=Beneficiado
					if DXL->(ColumnPos('DXL_FILBEN' )) > 0
						DXL->DXL_FILBEN	:= FWxFilial('DXI')
					endIf
					DXL->(MsUnlock())

					ClearGet({'cCodFda','nPsLiqu','cCodEtq','cCodFdi'})
					oGCodFda:SetFocus()					
				Endif
			ElseIf ApMsgYesNo( STR0050) //"Deseja Encerrar o beneficiamento deste fardão?"
				Reclock('DXL', .F.)
				DXL->DXL_RDMTO 	:= nTotRend
				DXL->DXL_STATUS := '5' 		// Status 5=Beneficiado
				if DXL->(ColumnPos('DXL_FILBEN' )) > 0
					DXL->DXL_FILBEN	:= FWxFilial('DXI')
				endIf
				DXL->(MsUnlock())
				
				ClearGet({'cCodFda','nPsLiqu','cCodEtq','cCodFdi'})
				oGCodFda:SetFocus()
			EndIf
		EndIf	

		A615AtuBrw(.T., .T.)
		oBrowse:SetFilterDefault("DXI_FILIAL=='" + FWxFilial("DXI") + "' .AND.DXI_FARDAO=='" + cCodFda + "' .AND.DXI_SAFRA=='" + cSafra + "' .AND.DXI_PRDTOR=='" + cProdutor + "' .AND.DXI_LJPRO=='" + cLjPro + "' .AND.DXI_FAZ=='" + cCodFaz + "'")
	endIf

	oBrowse:Refresh()

	If lTelaEst
		CarregaTemp()
	EndIf

Return(Nil)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615AutEnF
Executa o encerramento automático do Fardão

@param: Nil
@author: Agro
@since: 27/03/2016 
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/

Static Function A615AutEnF()
	Private nPsTotal := DXL->DXL_PSLIQU
	Private aFardoes := {}
	Private aDetItens := {}
	private aProd := {}
	Private aDetProd := {}

	//cria a linha do fardão atual
	If DXL->(ColumnPos( 'DXL_FILBEN' )) > 0
		aFardoes := {{DXL->DXL_CODIGO, DXL->DXL_CODPRO, DXL->DXL_LOCAL, DXL->DXL_PSLIQU, '', DXL->(Recno()), DXL->DXL_CODCNJ, DXL->DXL_LOTCTL, DXL->DXL_NMLOT, DXL->DXL_LOCLIZ, DXL->DXL_FILBEN}}
	Else
		aFardoes := {{DXL->DXL_CODIGO, DXL->DXL_CODPRO, DXL->DXL_LOCAL, DXL->DXL_PSLIQU, '', DXL->(Recno()), DXL->DXL_CODCNJ, DXL->DXL_LOTCTL, DXL->DXL_NMLOT, DXL->DXL_LOCLIZ}}
	Endif
	//gera os dados a serem atualizados
	AGRA620CIT(nPsTotal,aFardoes,@aDetItens,@aProd,@aDetProd)
	//grava os dados
	AGRA620GRV(, aFardoes, aDetItens, aDetProd, aProd)

	aPerBal := AGRX003E( .F., 'AGRA615001' )
Return()


/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615WHEN
Valida permissão de edição do campo

@param: Nil
@author: Aécio Gomes
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function A615WHEN()
	Local lRet := .T.

	If lRet .And. Empty(cCodTur)
		lRet := .F.
	EndIf

Return(lRet)

/*/{Protheus.doc} A615WHFard
Valida permissão de edição do campo fardo de acordo com o parâmetro mv_par12
@author silvana.torres
@since 22/02/2018
@version undefined

@type function
/*/
Static Function A615WHFard()
	Local lRet := .T.

	If Empty(cCodTur) .OR. mv_par12 == 2 
		lRet := .F.
	EndIf

Return(lRet)

/** --------------------------------------------------------------------------------------------------
{Protheus.doc} SAIDigito
Retorna digito verificador da etiqueta do Fardo conforme padrão 
SAI(Sistema Abrapa de identificação)

@param: cEtiqueta - Número da Etiqueta
@author: Aécio Gomes
@since: 27/03/2013
@Uso: GENERICO

//---------------------------------------------------------------------------------------------------
//³Estrutura da Etiqueta de codigo de barras:                                                       ³
//³A. O tipo de código na classificação da GS1 Brasil que informa aos leitores óticos a composição  ³
//³de 20 dígitos do código de barras (2 primeiros dígitos);                                         ³
//³B. O dígito de extensão que identifica se a algodoeira é matriz ou filial (1 dígito);            ³
//³C. O prefixo GS1 Brasil da Algodoeira /matriz (9 dígitos);                                       ³
//³D. O número da prensa que produziu o fardo (1 dígito);                                           ³
//³E. O serial de identificação do fardo (6 dígitos);                                               ³
//³F. O dígito verificador (1 dígito), calculado de acordo com a fórmula do tipo de código de barras³
//³EAN/128.                                                                                         ³
//---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------ **/
Function SAIDigito( cEtiqueta )
	Local cCodAux   := ''
	Local nX        := 0
	Local nMult 	  := 3
	Local nSoma 	  := 0
	Local nDigito   := 0

	cEtiqueta:= PADL(AllTrim(cEtiqueta),19,'0')
	cCodAux := cEtiqueta

	//-------------------------------------------------------------------------------
	//Faz o calculo alternando entre a base 3 e 1 e iniciando da direita pela base 3
	//-------------------------------------------------------------------------------
	For nX:=1 To Len(cEtiqueta)
		nSoma 	 += Int(Val(SubStr(cEtiqueta,Len(cCodAux),1))) * nMult
		cCodAux := PADR(cEtiqueta,Len(cCodAux)-1)
		nMult 	 := If(nMult == 3, 1, 3)
	Next nX

	//-----------------------------
	// Retorna o resto da divisão
	//-----------------------------
	nResto := Int(nSoma % 10)

	nDigito := If(nResto > 0, 10 - nResto, nDigito)

Return(Str(nDigito, 1))

/** ------------------------------------------------------------------------------------------
{Protheus.doc} ClearGet
Limpa o conteúdo das variáveis PRIVATES passadas por array

@param: aGet - Variáveis de escopo PRIVATE
@author: Aécio Gomes
@since: 27/03/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Static Function ClearGet(aGet)
	Local nX 		:= 0
	Local xConteudo := Nil

	For nX := 1 To Len(aGet)
		xConteudo := &(aGet[nX])
		If !Empty(xConteudo)

			If ValType(xConteudo) == 'C'
				&(aGet[nX]) := Space( len(xConteudo) )
			ElseIf ValType(xConteudo) == 'N'
				&(aGet[nX]) := 0
			EndIf
		End	
	Next
Return(Nil)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615Print
Efetua a impressão das etiquetas dos fardos

@author: Leonardo Quintania
@since: 20/07/2013
@Uso: AGRA615
------------------------------------------------------------------------------------------ **/
Function A615Print()
	Local nLin	    := 0
	Local nCol      := 0
	Local oEtiq     := Nil
	Local oFont8n   := TFont():New( "Arial" , , 10, , .T., , , , , .F. )
	Local oFont18n  := TFont():New( "Arial" , , 18, , .T., , , , , .F. )
	Local cCodPro   := ""
	Local cCodFaz   := ""
	Local cPeso     := ""
	Local lAG615PRT := ExistBlock('AG615PRT')

	if lRPO17
		cCodPro := AllTrim( Posicione( "DX8", 1, FWxFilial("DX8") + DXL->(DXL_PRDTOR+DXL_LJPRO), "DX8_NOME" ) ) //Entidade
	else
		cCodPro := AllTrim( Posicione( "NJ0", 1, FWxFilial("NJ0") + DXL->(DXL_PRDTOR+DXL_LJPRO), "NJ0_NOME" ) ) //Entidade
	endIf

	cCodFaz := AllTrim( Posicione( "NN2", 3, FWxFilial("NN2") + DXL->(DXL_PRDTOR+DXL_LJPRO+DXL_FAZ), "NN2_NOME" ) ) //Fazenda
	cPeso   := Transform( IIF(__nFdiLq > 0,__nFdiLq,DXI->( DXI_PSLIQU )), PesqPict( "DXI", "DXI_PSLIQU" ) ) + " Kg"
	
	If lAG615PRT
		ExecBlock("AG615PRT",.F.,.F.,{cCodPro, cCodFaz, cPeso})
	Else 
		nPixGeral	:=FWCalcFieldSize( "C", 180  	   , , , , "Arial", 10, .T., .F., .F. )
		nPixPro	:=FWCalcFieldSize( "C", Len(cCodPro) , , , , "Arial", 10, .T., .F., .F. )
		nPixFaz	:=FWCalcFieldSize( "C", Len(cCodFaz) , , , , "Arial", 10, .T., .F., .F. )

		oEtiq := TMSPrinter():New()

		if _lNovSafra
			if mv_par07 == 3
				oEtiq:Setup()
			endif
		else
			if LEN(mv_par06) = 1
				if mv_par06 == 3
					oEtiq:Setup()
				endif
			else
				if mv_par07 == 3
					oEtiq:Setup()
				endif
			endIf
		endIf

		If oEtiq:IsPrinterActive()	
			nCol := (nPixGeral-nPixPro)/2
			nLin := 10
			oEtiq:Say(nLin,nCol,cCodPro,oFont8n,nPixGeral,,,2)

			nCol := (nPixGeral-nPixFaz)/2
			nLin += 30
			oEtiq:Say(nLin,nCol,cCodFaz,oFont8n,nPixGeral,,,2)

			nCol += 100
			nLin += 90
			oEtiq:Say( nLin, nCol, cPeso, oFont18n)
			oEtiq:EndPage()
			oEtiq:Print()
		else 
			oEtiq:Setup()
		EndIf

		oEtiq:End()
		__nFdiLq := 0
	EndIF	
Return(Nil)


/*/{Protheus.doc} A615GrvMov
Grava os movimentos dos fardos
@author silvana.torres
@since 22/02/2018
@version undefined

@type function
/*/
Static Function A615GrvMov(cAcao, aMovFrd, aChaveMov)

	Local aArea     	:= GetArea()
	Local lRet 			:= .T.
	Local aRet			:= {}

	Default aChaveMov 	:= {}

	if TableInDic('N9D') .AND. N9D->(ColumnPos("N9D_FILIAL")) > 0
		if cAcao == "Inclui"															
			aRet := AGRMOVFARD(aMovFrd, 1)
		elseIf cAcao == "Exclui"
			aRet := AGRMOVFARD(aMovFrd, 3, 1, aChaveMov)
		elseIf cAcao == "Altera"
			aRet := AGRMOVFARD(aMovFrd, 4, 1, aChaveMov)
		endIf

		if aRet[2] <> ""
			lRet := .F.
			Help(,,STR0036,, aRet[2],1,0)		
		endIf
	endIf

	RestArea(aArea)

Return lRet

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A615PSLIQU
Retorna Peso Liquido 

@param: 	Nil
@author: 	TOTVS
@since: 	15/03/2012
@Uso: 		AGRA615
------------------------------------------------------------------------------------------ **/
Function A615PSLIQU( )
	Local aAreaAtu 	:= GetArea()
	Local oModel 	:= FwModelActive()
	Local oDXI 		:= oModel:GetModel("DXIMASTER")
	Local nPsLiqu	:= 0

	dbSelectArea('DXE')
	DXE->(dbSetOrder(1))
	If DXE->(MsSeek(FWxFilial('DXE')+DXI->DXI_CODCNJ))

		nPsLiqu := Round( ( M->DXI_PSBRUT - DXE->( DXE_PSBAL )  ), TamSX3( "DXI_PSLIQU" )[2] )

		oDXI:SetValue( "DXI_PSLIQU", Abs(nPsLiqu))
	EndIf	
	DXE->(DbCloseArea())

	RestArea(aAreaAtu)
Return( nPsLiqu )

/*{Protheus.doc
} fncMalaGRV
(Responsável por Gerar, incluir e alterar Malas de Amostras VISUAL e HVI)
@type function
@author roney.maia
@since 26/12/2016
@version 1.0
@param aCpoMaster, array, (Array para preenchimento de informacões das malas)
@param aCpoDetail, array, (Array para preenchimento de informacões das amostras)
*/
Static Function fncMalaGRV(aCpoMaster, aCpoDetail)
	Local oModel, oAux, oStruct
	Local nI 		:= 0
	Local nJ 		:= 0
	Local nI1 		:= 0
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local aAux 		:= {}
	Local lAux 		:= .T.
	Local nIMast 	:= 0
	Local oAuxDXK
	Local aAuxDXKFld 	:= {}
	Local oStructDXK
	Local lFechaMala 	:= .F.
	Local aMalaTemp 	:= {}
	Local cMsgErro
	Local qTFardos		:= 0
	Local cFrdFim       := ""

	dbSelectArea( 'DXK' )
	dbSetOrder( 1 )
	dbSelectArea( 'DXJ' )
	dbSetOrder( 1 )

	// Consulta Mala Aberta
	If !Empty(aMalaDb)
		cMalaAtual := ConsultMala(PADR(cSafra,TamSX3('DXL_SAFRA')[1],' '), cCodCnj)
	Else
		cMalaAtual := IIF(!Empty(aMalaDb), aMalaDb[1][1], "")
	EndIf

	If DXJ->(ColumnPos( 'DXJ_QTVINC' )) > 0
		// Consulta para quantidade de amostras cadastradas
		If !Empty(cMalaAtual)
			qTFardos := Posicione("DXJ",1,FwXFilial('DXJ')+cMalaAtual+"1","DXJ_QTVINC")
		Endif
	endIf

	//Para fechar a mala, ela deve ter a quantidade total de quando foi criada. 
	//Nao posso me basear no parametro, pq este pode ser alterado posteriormente.
	//Para isso uso o fardo final menos o fardo inicial + 1.
	lFechaMala :=  IIF(!Empty(aMalaDb) .And. ((aMalaDb[1][4] + 1) == ((Val(aMalaDb[1][3])+1) - Val(aMalaDb[1][2]))),.T.,.F.)



	For nIMast := 1 to (IIF(lFechaMala,4,2)) // Loop para criação e atualização de malas, sendo a primeira - Visual e segunda - HVI
		oModel := FWLoadModel( 'AGRA630' )   // Se fecha a mala é necessário criar mais duas malas vazias 3-Visual 4-HVI
		oModel:SetOnDemand( .T. )
		oModel:GetModel('MdFieldDXJ'):GetStruct():SetProperty('DXJ_CODUNB',MODEL_FIELD_OBRIGAT, .F.)

		//Na terceira vez cria-se uma nova mala com quantidade zero
		If nIMast == 3
			cFrdFim	  := fFrdFim()
			aMalaTemp := MontaMala(STRZERO(Val(cFrdFim) + 1, TamSX3("DXI_CODIGO")[1]), .T.)
			For nI1 := 1 To len(aMalaTemp)
				aAdd( aCpoMaster, aMalaTemp[nI1])
			Next
			aCpoDetail	:= {}
			cMalaAtual	:= ""
			qTFardos 	:= 0
		EndIf

		If !Empty(cMalaAtual) // Verifica se ja existe mala aberta, Responsavel por atualizar e incluir os fardinhos

			dbSelectArea('DXJ')
			dbSetOrder(1)
			If MsSeek(FwXFilial('DXJ')+cMalaAtual+cValtoChar(nImast)) //Filial+Codigo+Tipo (1 = Visual, 2 = HVI)

				// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
				oModel:SetOperation( 4 )

				// Antes de atribuirmos os valores dos campos temos que ativar o modelo
				If(oModel:Activate())

					//AMOSTRAS
					oAuxDXK := oModel:GetModel( 'MdGridDXK' ) // Instanciamos apenas a parte do modelo referente aos dados do item
					oStructDXK := oAuxDXK:GetStruct() // Obtemos a estrutura de dados do item
					aAuxDXKFld := oStructDXK:GetFields()

					If qTFardos > 0 //Sem amostras no grid, incluir linha somente a partir da segunda
						oAuxDXK:AddLine()
					EndIf

					For nJ := 1 To Len( aCpoDetail[nIMast] )
						// Verifica se os campos passados existem na estrutura de item
						If ( nPos := aScan( aAuxDXKFld, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nIMast][nJ][1] ) } ) ) > 0
							If !( lAux := oModel:SetValue( 'MdGridDXK', aCpoDetail[nIMast][nJ][1], aCpoDetail[nIMast][nJ][2] ) )
								lRet := .F. //Quando nao puder gravar valor, retorna erro
								Exit
							EndIf
							oModel:SetValue( 'MdGridDXK', aCpoDetail[nIMast][nJ][1], aCpoDetail[nIMast][nJ][2] )
						EndIf
					Next

					If !lRet
						Exit
					Else
						If DXJ->(ColumnPos( 'DXJ_QTVINC' )) > 0
							oModel:SetValue( 'MdFieldDXJ', "DXJ_QTVINC", qTFardos + 1 )
						endIf

						If lFechaMala
							FwFldPut("DXJ_STATUS", IIF(nIMast == 1, "1", "4"),,,,.T.)
						EndIf
					EndIf

				EndIf
			Endif
		Else // Condição responsável para criar uma mala caso ela não exista
			oModel:SetOperation( 3 )
			// Antes de atribuirmos os valores dos campos temos que ativar o modelo
			oModel:Activate()
			// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
			oAux := oModel:GetModel( 'MdFieldDXJ' )   // Modelo da NJJ Cab. Romaneio = NJJUNICO, dos Itens == NJMUnico
			// Obtemos a estrutura de dados do cabeçalho
			oStruct := oAux:GetStruct()
			aAux    := oStruct:GetFields()

			If lRet
				For nI := 1 To Len(aCpoMaster[nIMast])
					// Verifica se os campos passados existem na estrutura do cabeçalho
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nIMast][nI][1] ) } ) ) > 0
						//E feita a atribuição do dado aos campo do Model do cabeçalho
						If !( lAux := oModel:LoadValue( 'MdFieldDXJ', aCpoMaster[nIMast][nI][1],aCpoMaster[nIMast][nI][2] ) )
							lRet := .F. //Quando nao puder gravar valor, retorna erro
							Help(,,STR0036,, oModel:GetErrorMessage()[6],1,0)
							Exit
						EndIf
					EndIf
				Next
			EndIf

			// Instanciamos apenas a parte do modelo referente aos dados do item
			oAuxDXK := oModel:GetModel( 'MdGridDXK' )
			// Obtemos a estrutura de dados do item
			oStructDXK := oAuxDXK:GetStruct()
			aAuxDXKFld := oStructDXK:GetFields()


			If !Empty(aCpoDetail)
				If qTFardos > 0 //Sem amostras no grid, incluir linha somente a partir da segunda
					oAuxDXK:AddLine()
				EndIf

				For nJ := 1 To Len( aCpoDetail[nIMast] )
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAuxDXKFld, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nIMast][nJ][1] ) } ) ) > 0
						If !( lAux := oModel:LoadValue( 'MdGridDXK', aCpoDetail[nIMast][nJ][1], aCpoDetail[nIMast][nJ][2] ) )
							lRet := .F. //Quando nao puder gravar valor, retorna erro
							Exit
						EndIf
					EndIf
				Next
			EndIf

		EndIf

		If lRet
			// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
			// neste momento os dados não são gravados, são somente validados.
			If ( lRet := oModel:VldData() )
				// Se o dados foram validados faz-se a gravação efetiva dos
				// dados (commit)
				lRet := oModel:CommitData()
			EndIf
		EndIf

		If !lRet
			cMsgErro := oModel:GetErrorMessage()[6] + Chr(10)+Chr(13)
		EndIf

		// Desativamos o Model
		oModel:DeActivate()
	Next nIMast

	If !Empty(cMsgErro)
		Help('', 1, "Atenção", , OemToAnsi( cMsgErro ), 1 ) //"Falha ao gerar malas automáticas"
	Endif

Return lRet


/*{Protheus.doc} ConsultMala
(Permite consultar a Mala Atual)
@type function
@author roney.maia
@since 26/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
*/
Static Function ConsultMala(cSafra, cConjunto)

	Local QryDXJBG := GetNextAlias()

	//Existe aberta para safra e conjunto

	If DXJ->(ColumnPos( 'DXJ_AUTOMA' )) > 0
		BeginSql Alias QryDXJBG
			Select
			DXJ.*
			From
			%table:DXJ% DXJ
			Where
			DXJ.DXJ_FILIAL = %xFilial:DXJ% And
			DXJ.DXJ_SAFRA  = %exp:cSafra% And
			DXJ.DXJ_STATUS = "7" And //Aberta			
			DXJ.DXJ_AUTOMA = "1" And //Automática
			DXJ.DXJ_CODCNJ = %exp:cConjunto% And
			DXJ.%NotDel%
			Order By DXJ.DXJ_CODIGO Desc

		EndSql
	else
		BeginSql Alias QryDXJBG
			Select
			DXJ.*
			From
			%table:DXJ% DXJ
			Where
			DXJ.DXJ_FILIAL = %xFilial:DXJ% And
			DXJ.DXJ_SAFRA  = %exp:cSafra% And
			DXJ.DXJ_STATUS = "7" And //Aberta
			DXJ.DXJ_CODCNJ = %exp:cConjunto% And
			DXJ.%NotDel%
			Order By DXJ.DXJ_CODIGO Desc

		EndSql
	endIF

	dbSelectArea('DXJ')
	dbSetOrder(1)
	dbGoTop()

Return ((QryDXJBG)->DXJ_CODIGO)


/*/{Protheus.doc} A165VldEst
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 08/02/2017
@version undefined

@type function
/*/
Static Function A165VldEst()
	Local lRet    := .T.

	DBSelectArea("N70")
	N70->( dbSetOrder(1) )

	If( !Empty(cEsteira) .And. !N70->(MsSeek(FWxFilial("N70") + cEsteira ) ))		
		Help('', 1, STR0036, , STR0067, 1 )
		lRet := .F.
	EndIf

	ResetConj()
	cCodFda := space(TamSX3('DXL_CODIGO')[1])
	cCodTur := space(TamSX3('H7_CODIGO')[1])

	cUNB := A655GETUNB( )
	If Empty(cUNB)
		dbSelectArea( 'N70' )
		N70->(dbSetOrder(1))
		If N70->(MsSeek(FWxFilial( 'N70')+cEsteira))
			If Trim(N70->N70_CODUNB) <> Trim(cCodUNB) .And. !Empty(cCodUNB)
				lRet := .F.
				Help('', 1, OemToAnsi( STR0036 ), , OemToAnsi( STR0068 ), 1 )
			EndIf
		EndIf
	EndIf

	If lRet .And. !Empty(cEsteira) 
		lRet := CarregaTemp()

		If Empty(aFardao)
			If lRet //Somente se nao apresentar erro de safra
				Help('', 1, STR0036, , STR0069, 1 )
			EndIf
			If Empty(cUNB)
				oGUnBenef:SetFocus()
				Return .T.
			EndIf
			lRet := .F.
		EndIf

	EndIf



Return lRet
/*/{Protheus.doc} CarregaTemp
//TODO Descrição auto-gerada.
@since 23/12/2016
@version undefined

@type function
/*/
Static Function CarregaTemp()
	Local cQry      := ""
	Local cMensagem := ""
	Local lRet		:= .T.

	aFardao   := {}

	cAliasTRB := GetNextAlias()
	cQry  := " SELECT DXL_CODIGO, DXL_STATUS, DXL_SAFRA, DXL_CODPRO, DXL_PRDTOR, DXL_LJPRO, DXL_FAZ FROM "+ retSqlName('DXL')+" DXL"
	cQry  += " INNER JOIN " + retSqlName('N71')+" N71" +" ON "
	cQry  += " N71.D_E_L_E_T_ = ' ' "
	cQry  += " AND N71_FILIAL = '" + fwxFilial('N71') + "'"
	cQry  += " AND N71_FARDAO = DXL_CODIGO  "
	cQry  += " AND N71_SAFRA  = DXL_SAFRA "
	cQry  += " AND N71_PRODUT = DXL_PRDTOR "
	cQry  += " AND N71_CODPRO = DXL_CODPRO"
	cQry  += " AND N71_LOJA   = DXL_LJPRO "
	cQry  += " AND N71_FAZEN  = DXL_FAZ"
	cQry  += " AND N71_CODEST = '"  + cEsteira +"'"
	cQry  += " WHERE DXL_FILIAL = '"+ fwxFILIAL('DXL')+"'"
	cQry  += " AND DXL.D_E_L_E_T_ = ' '"
	cQry  += " AND DXL_STATUS = '5' "
	cQry  += " ORDER BY DXL_DTBEN DESC "

	If DXL->(ColumnPos( 'DXL_HRBEN' )) > 0
		cQry  += "    , DXL_HRBEN DESC "
	endIf

	cQry  := ChangeQuery(cQry)
	DBUseArea(.T., 'TOPCONN', TCGENQRY(,,cQry),cAliasTRB,.F.,.T.)

	if !(cAliasTRB)->(Eof())

		Aadd(aFardao, {(cAliasTRB)->DXL_STATUS,;
		(cAliasTRB)->DXL_CODIGO,;
		(cAliasTRB)->DXL_SAFRA,;
		(cAliasTRB)->DXL_CODPRO,;
		(cAliasTRB)->DXL_PRDTOR,;
		(cAliasTRB)->DXL_LJPRO,;
		(cAliasTRB)->DXL_FAZ})
		(cAliasTRB)->( DbSkip() )
	EndIf

	(cAliasTRB)->(dbCloseArea())

	cAliasTRB := GetNextAlias()

	cQry  := " SELECT DXL_CODIGO, DXL_STATUS, DXL_SAFRA, DXL_CODPRO, DXL_PRDTOR, DXL_LJPRO, DXL_FAZ FROM "+ retSqlName('DXL')+" DXL"
	cQry  += " INNER JOIN " + retSqlName('N71')+" N71" +" ON "
	cQry  += " N71.D_E_L_E_T_ = ' ' "
	cQry  += " AND N71_FILIAL = '" + fwxFilial('N71') + "'" 
	cQry  += " AND N71_FARDAO = DXL_CODIGO"
	cQry  += " AND N71_SAFRA  = DXL_SAFRA "
	cQry  += " AND N71_PRODUT = DXL_PRDTOR"
	cQry  += " AND N71_CODPRO = DXL_CODPRO"
	cQry  += " AND N71_LOJA   = DXL_LJPRO"
	cQry  += " AND N71_FAZEN  = DXL_FAZ "
	cQry  += " AND N71_CODEST = '"  + cEsteira +"'"
	cQry  += " WHERE DXL_FILIAL = '"+ FWXFILIAL('DXL')+"'"
	cQry  += " AND DXL.D_E_L_E_T_ = ' '"
	cQry  += " AND DXL_RDMTO = 0"
	cQry  += " AND (DXL_STATUS = '3' OR DXL_STATUS = '4' )"
	cQry  += " ORDER BY N71_ORDEM "

	cQry  := ChangeQuery(cQry)
	DBUseArea(.T., 'TOPCONN', TCGENQRY(,,cQry),cAliasTRB,.F.,.T.)

	While !(cAliasTRB)->(Eof())

		Aadd(aFardao, {(cAliasTRB)->DXL_STATUS,;
		(cAliasTRB)->DXL_CODIGO,;
		(cAliasTRB)->DXL_SAFRA,;
		(cAliasTRB)->DXL_CODPRO,;
		(cAliasTRB)->DXL_PRDTOR,;
		(cAliasTRB)->DXL_LJPRO,;
		(cAliasTRB)->DXL_FAZ})
		(cAliasTRB)->( DbSkip() )
	EndDo

	(cAliasTRB)->(DBGoTop())

	if !Empty(aFardao)

		if aFardao[1][1] == "5"
			If Len(afardao) > 1
				cCodFda 	:= aFardao[2][2]
				cSafra		:= aFardao[2][3]
				cCodProdut	:= aFardao[2][4]
				cProdutor	:= aFardao[2][5]
				cLjPro		:= aFardao[2][6]
				cCodFaz		:= aFardao[2][7]
			endIf
		else
			cCodFda 	:= aFardao[1][2]
			cSafra		:= aFardao[1][3]
			cCodProdut	:= aFardao[1][4]
			cProdutor	:= aFardao[1][5]
			cLjPro		:= aFardao[1][6]
			cCodFaz		:= aFardao[1][7]
		endIf

		cUNB 	:= cCodUNB
		A165CodFda()
		cUNB 	:= A655GETUNB( )
		AtualFila()
	EndIf

	If !lRet
		Help('', 1, STR0036, , cMensagem, 1 )
	EndIf

Return lRet

/*/{Protheus.doc} AtualFila
// Atualiza painel de fardos
@author carlos.augusto, jeferson.chaves, camila.foliveira
@since 10/01/2017
@version undefined
@type function
/*/
Static Function AtualFila()
	//Fila de Fardoes
	If Len(afardao) > 0
		oPnlWnd5:lVisible := .T.
		oPnlWnd5:cTitle := afardao[1][2]
		If afardao[1][1] == "4"
			oPnlWnd5:nClrPane := CLR_YELLOW
		Else
			If afardao[1][1] == "5"
				oPnlWnd5:nClrPane := CLR_HRED
			else
				oPnlWnd5:nClrPane := CLR_GREEN
			endIf
		EndIf
	Else
		oPnlWnd5:lVisible := .F.
	EndIf

	If Len(afardao) > 1
		oPnlWnd6:lVisible := .T.
		oPnlWnd6:cTitle := afardao[2][2]

		If afardao[2][1] == "4"
			oPnlWnd6:nClrPane := CLR_YELLOW
		Else
			oPnlWnd6:nClrPane := CLR_GREEN
		EndIf
	Else
		oPnlWnd6:lVisible := .F.
	EndIf

	If Len(afardao) > 2
		oPnlWnd7:lVisible := .T.
		oPnlWnd7:cTitle := afardao[3][2]

		If afardao[3][1] == "4"
			oPnlWnd7:nClrPane := CLR_YELLOW
		Else
			oPnlWnd7:nClrPane := CLR_GREEN
		EndIf
	Else
		oPnlWnd7:lVisible := .F.
	EndIf

	If Len(afardao) > 3
		oPnlWnd8:lVisible := .T.
		oPnlWnd8:cTitle := afardao[4][2]

		If afardao[4][1] == "4"
			oPnlWnd8:nClrPane := CLR_YELLOW
		Else
			oPnlWnd8:nClrPane := CLR_GREEN
		EndIf
	Else
		oPnlWnd8:lVisible := .F.
	EndIf

	If Len(afardao) > 4
		oPnlWnd9:lVisible := .T.
		oPnlWnd9:cTitle := afardao[5][2]

		If afardao[5][1] == "4"
			oPnlWnd9:nClrPane := CLR_YELLOW
		Else
			oPnlWnd9:nClrPane := CLR_GREEN
		EndIf
	Else
		oPnlWnd9:lVisible := .F.
	EndIf

	oPnlWnd5:Refresh()
	oPnlWnd6:Refresh()
	oPnlWnd7:Refresh()
	oPnlWnd8:Refresh()
	oPnlWnd9:Refresh()

Return

/*/{Protheus.doc} ResetConj
// Atualiza painel de conjuntos
@author carlos.augusto, jeferson.chaves, camila.foliveira
@since 10/01/2017
@version undefined
@type function
/*/
Static Function ResetConj()
	lCostelado	:= .F.
	cCodCnj		:= space(TamSX3('DXI_CODCNJ')[1])
	cPrensa		:= space(TamSX3('DXI_PRENSA')[1])
	cCodFdi		:= space(TamSX3('DXI_CODIGO')[1])
	ClearGet({'cCodEtq','nFdiPBr','nFdiPLq','nPsLiqu'})
	dtBenef		:= dDatabase
	A615WHEN()
Return

/*/{Protheus.doc} UpdBrwMala
// Busca mala aberta para o conjunto
@author carlos.augusto
@since 09/02/2017
@version undefined
@type function
/*/
Static Function UpdBrwMala()
	Local cQuery 	:= ""
	Local lPrim 	:= .T.
	aMalaDb 		:= {}
	aMalaComp 		:= {}

	cDXJAlias := GetNextAlias()
	cQuery := " SELECT DXJ.DXJ_SAFRA, DXJ.DXJ_STATUS, DXJ.DXJ_CODIGO, DXJ.DXJ_FRDINI, DXJ.DXJ_FRDFIM, "

	If DXJ->(ColumnPos( 'DXJ_QTVINC' )) > 0
		cQuery += "    DXJ.DXJ_QTVINC, " 
	endIf

	cQuery += " 	   DXJ.DXJ_TIPO, DXJ.R_E_C_N_O_, DXK.DXK_ETIQ, DXK.DXK_FARDO, DXK.DXK_CODVAR, DXK.DXK_PSLIQU, "
	cQuery += "		   DXK.DXK_PSBRUT, DXK.DXK_PSBRUT, DXK.DXK_TALHAO "

	If DXK->(ColumnPos( 'DXK_TIPO' )) > 0
		cQuery += ", DXK.DXK_TIPO "
	endIf

	cQuery += " FROM " + RetSqlName("DXJ") + " DXJ "
	cQuery += " LEFT JOIN " + retSqlName('DXK') + " DXK ON "
	cQuery += " 	    DXK.DXK_FILIAL = '" + fwxFilial('DXK') + "'" 
	cQuery += " 	AND DXK.DXK_CODROM  = DXJ.DXJ_CODIGO"

	If DXK->(ColumnPos( 'DXK_TIPO' )) > 0
		cQuery += " 	AND DXK.DXK_TIPO   = '1' "
	endIf

	cQuery += " 	AND DXK.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DXJ.D_E_L_E_T_ = ' ' "
	cQuery += "   AND DXJ.DXJ_FILIAL = '" + fwxFilial('DXJ') +"'"
	cQuery += "   AND DXJ.DXJ_SAFRA = '" + DXL->DXL_SAFRA +"'"
	cQuery += "   AND DXJ.DXJ_TIPO   = '1' "
	cQuery += "   AND DXJ.DXJ_CODCNJ = '" + cCodCnj +"'" //é do conjunto da tela. Possui a prensa

	If DXJ->(ColumnPos( 'DXJ_AUTOMA' )) > 0
		cQuery += "   AND DXJ.DXJ_STATUS = '7' " //Status Aberta
		cQuery += "   AND DXJ.DXJ_AUTOMA = '1' "
	endIf


	cQuery += " Order By DXJ.R_E_C_N_O_ desc "
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cDXJAlias, .F., .T.)

	dbSelectArea(cDXJAlias)
	dbGoTop()
	While (cDXJAlias)->(!Eof())
		If Empty(aMalaDb) .And. lPrim
			If !DXJ->(ColumnPos( 'DXJ_QTVINC' )) > 0
				aMalaDb	:= {{(cDXJAlias)->DXJ_CODIGO,;
				(cDXJAlias)->DXJ_FRDINI,;
				(cDXJAlias)->DXJ_FRDFIM,;
				(cDXJAlias)->DXJ_SAFRA}}
			else
				aMalaDb	:= {{(cDXJAlias)->DXJ_CODIGO,;
				(cDXJAlias)->DXJ_FRDINI,;
				(cDXJAlias)->DXJ_FRDFIM,;
				(cDXJAlias)->DXJ_QTVINC,;
				(cDXJAlias)->DXJ_SAFRA}}
			endIf
			lPrim := .F.
		EndIf
		aAdd( aMalaComp, {  (cDXJAlias)->DXJ_CODIGO	,;
		(cDXJAlias)->DXK_ETIQ,;
		(cDXJAlias)->DXK_FARDO,;
		(cDXJAlias)->DXK_CODVAR,;
		(cDXJAlias)->DXK_PSLIQU,;
		(cDXJAlias)->DXK_PSBRUT,;
		(cDXJAlias)->DXK_TALHAO } )
		(cDXJAlias)->(dbSkip())
	End

	oBrwMala:SetArray( aMalaDb )
	oBrwMala:Refresh()
	(cDXJAlias)->(dbCloseArea())

Return aMalaDb


/*/{Protheus.doc} CriaBrowse
//Função responsável pela criação da grid de mala
@since 13/10/2017
@version undefined
@type function
/*/
Static Function CriaBrowse()

	Local oFont := TFont():New( "Arial" , , 16, , .T., , , , , .F. )

	oSize4 := FWDefSize():New(.F.)
	oSize4:AddObject('SUPER',100,100,.T.,.T.)
	oSize4:SetWindowSize({0,0,oPnlWndML:NHEIGHT,oPnlWndML:NWIDTH})
	oSize4:lProp 	:= .T.
	oSize4:aMargins := {0,0,0,0}
	oSize4:Process()

	oBrwMala := TCBrowse():New( oSize4:aPosObj[1,1], oSize4:aPosObj[1,2], oSize4:aPosObj[1,3], oSize4:aPosObj[1,4], , , , oPnlWndML, , , , {|| }, {|| }, ,oFont , , , , , .f., , .t., , .f., , , )
	oBrwMala:AddColumn( TCColumn():New(STR0078, { || IIF(!EMPTY(aMalaDb), aMalaDb[oBrwMala:nAt,1], "" )}	, , , , "LEFT", 040, .f., .t., , , , .f., ) )       //Cód. Mala
	oBrwMala:AddColumn( TCColumn():New(STR0079, { || IIF(!EMPTY(aMalaDb), aMalaDb[oBrwMala:nAt,2], "" )}, , , , "LEFT", 040, .f., .t., , , , .f., ) )		//"Fardo Inicial"
	oBrwMala:AddColumn( TCColumn():New(STR0080, { || IIF(!EMPTY(aMalaDb), aMalaDb[oBrwMala:nAt,3], "" )}	  , , , , "LEFT", 040, .f., .t., , , , .f., ) )	//Fardo Final
	oBrwMala:AddColumn( TCColumn():New(STR0081, { || IIF(!EMPTY(aMalaDb) .AND. aMalaDb[oBrwMala:nAt,4]<> NIL, Transform( aMalaDb[oBrwMala:nAt,4], "@E 999" ), 0)}, , , , "LEFT", 010, .f., .t., , , , .f., ) ) //Qt Vinc

	oBrwMala:SetArray( aMalaDb )
	oBrwMala:bLDblClick 	:=  {|| fncDetMala()}
	oBrwMala:bHeaderClick 	:=  {|| fncDetMala()}

	oBrwMala:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwMala:Refresh(.T.)


return oBrwMala

/*/{Protheus.doc} MontaMala
// Monta um novo par de malas, caso não tenha nenhuma aberta
@author bruna.rocio
@since 08/02/2017
@version undefined

@type function
/*/
Static Function MontaMala(cFardTmp, lMalaVazia)
	Local aMalas   := Array(0)
	Local aMalaVis := Array(0)
	Local aMalaHVI := Array(0)
	Local aSequen

	If Empty(aMalaDb) .Or. cFardTmp > aMalaDb[1][3]  
		cCodigo  := GETSXENUM("DXJ","DXJ_CODIGO")
		DXJ->(dbSetOrder(1))
		While DXJ->(MsSeek(FwXFilial("DXJ")+cCodigo)) //DXJ_FILIAL+DXJ_CODIGO+DXJ_TIPO
			If ( __lSx8)
				//--Salva numeração
				ConfirmSX8()
			EndIf
			cCodigo  := GETSXENUM("DXJ","DXJ_CODIGO")
			ConfirmSX8()
		EndDo
	Else
		cCodigo  := aMalaDb[1][1] 		
	EndIf   

	//Busca numeração
	aSequen := GetSeqNum(cFardTmp)

	// Montagem da mala Visual
	aAdd( aMalaVis, { 'DXJ_CODIGO'	, cCodigo } )    // Código da Mala
	aAdd( aMalaVis, { 'DXJ_TIPO'	, "1" } )        // Tipo Mala, 1 - Visual, 2 - HVI
	aAdd( aMalaVis, { 'DXJ_DATA'	, DtBenef 	} )  // Data do beneficiamento
	aAdd( aMalaVis, { 'DXJ_CODCNJ'	, cCodCnj } )    // Conjunto
	aAdd( aMalaVis, { 'DXJ_SAFRA'	, PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ') } )     // Safra
	aAdd( aMalaVis, { 'DXJ_PRDTOR'	, cProdutor } )  // Proprietário do Fardo
	aAdd( aMalaVis, { 'DXJ_LJPRO'	, cLjPro } )     // Loja do Produtor
	aAdd( aMalaVis, { 'DXJ_FAZ'	    , cCodFaz } )    // Fazenda do Produtor
	aAdd( aMalaVis, { 'DXJ_CODVAR'	, DXL->DXL_CODVAR } ) // Codigo da variedade
	aAdd( aMalaVis, { 'DXJ_CODUNB'	, cCodUNB } )    // Unidade de Beneficiamento

	If DXJ->(ColumnPos( 'DXJ_AUTOMA' )) > 0
		aAdd( aMalaVis, { 'DXJ_AUTOMA'	, "1" } )        // Status Automatico. 1 - Automatico, 2 - Manual
	endIf

	aAdd( aMalaVis, { 'DXJ_STATUS'	, "7" } )        // Status da Mala = Aberto
	aAdd( aMalaVis, { 'DXJ_FRDINI'  , aSequen[1] } ) // Inicio sequenciamento fardinho
	aAdd( aMalaVis, { 'DXJ_FRDFIM'  , aSequen[2] } ) // Final sequenciamento fardinho
	aAdd( aMalaVis, { 'DXJ_DATA'    , dDatabase } ) // Final sequenciamento fardinho
	aAdd( aMalaVis, { 'DXJ_HORA'    , Substr( Time(), 1, 5 ) } ) // Final sequenciamento fardinho
	aAdd( aMalaVis, { 'DXJ_CODUSU'  , Substr(cUsuario,7,15)  } ) // Final sequenciamento fardinho

	If DXJ->(ColumnPos( 'DXJ_QTVINC' )) > 0
		aAdd( aMalaVis, { 'DXJ_QTVINC'  , IIF(lMalaVazia,0,1)   } ) 					// Quantidade Vinculada
		aAdd( aMalaVis, { 'DXJ_CODBAR'  , PADR(AGRSmartCode("DXJ", cSafra, cCodigo, "1", "ML"),TamSX3("DXJ_CODBAR")[1]) } ) // Código Inteligente e Único
	endIf

	// Montagem da mala HVI
	aAdd( aMalaHVI, { 'DXJ_CODIGO'	, cCodigo } )   // Código da Mala
	aAdd( aMalaHVI, { 'DXJ_TIPO'	, "2" } )       // Tipo Mala, 1 - Visual, 2 - HVI
	aAdd( aMalaHVI, { 'DXJ_DATA'	, DtBenef 	} ) // Data do beneficiamento
	aAdd( aMalaHVI, { 'DXJ_CODCNJ'	, cCodCnj } )   // Conjunto
	aAdd( aMalaHVI, { 'DXJ_SAFRA'	, PADR(cSafra,TamSX3('DXL_SAFRA')[1],' ') } )    // Safra
	aAdd( aMalaHVI, { 'DXJ_PRDTOR'	, cProdutor } ) // Proprietário do Fardo
	aAdd( aMalaHVI, { 'DXJ_LJPRO'	, cLjPro } )     // Loja do Produtor
	aAdd( aMalaHVI, { 'DXJ_FAZ'	    , cCodFaz } )   // Fazenda do Produtor
	aAdd( aMalaHVI, { 'DXJ_CODVAR'	, DXL->DXL_CODVAR } ) // Codigo da variedade
	aAdd( aMalaHVI, { 'DXJ_CODUNB'	, cCodUNB } )   // Unidade de Beneficiamento

	If DXJ->(ColumnPos( 'DXJ_AUTOMA' )) > 0
		aAdd( aMalaHVI, { 'DXJ_AUTOMA'	, "1" } )       // Status Automatico. 1 - Automatico, 2 - Manual
	endIf

	aAdd( aMalaHVI, { 'DXJ_STATUS'	, "7" } )       // Status da Mala = Aberto
	aAdd( aMalaHVI, { 'DXJ_FRDINI'  , aSequen[1] } ) // Inicio sequenciamento fardinho
	aAdd( aMalaHVI, { 'DXJ_FRDFIM'  , aSequen[2] } ) // Final sequenciamento fardinho
	aAdd( aMalaHVI, { 'DXJ_DATA'    , dDatabase } ) // Final sequenciamento fardinho
	aAdd( aMalaHVI, { 'DXJ_HORA'    , Substr( Time(), 1, 5 ) } ) // Final sequenciamento fardinho
	aAdd( aMalaHVI, { 'DXJ_CODUSU'  , Substr(cUsuario,7,15)  } ) // Final sequenciamento fardinho

	If DXJ->(ColumnPos( 'DXJ_QTVINC' )) > 0
		aAdd( aMalaHVI, { 'DXJ_QTVINC'  , IIF(lMalaVazia,0,1)  } )
		aAdd( aMalaHVI, { 'DXJ_CODBAR'  , PADR(AGRSmartCode("DXJ", cSafra, cCodigo, "2", "ML"),TamSX3("DXJ_CODBAR")[1]) } ) // Código Inteligente e Único
	endIf

	//Retorna as malas
	aAdd(aMalas, aMalaVis)
	aAdd(aMalas, aMalaHVI)
Return aMalas


/*/{Protheus.doc} GetSeqNum
//Gera sequenciamento para range de fardinhos da mala
@author bruna.rocio
@since 08/02/2017
@version undefined
@param cFardinho, characters, Fardinho corrente para retorno da sequencia
@type function
/*/
Static Function GetSeqNum(cFardinho)
	Local aArea     := GetArea()
	Local aSeqNum   := {,}

	aSeqNum[1] := cFardinho
	aSeqNum[2] := StrZero(Val(cFardinho)+(nQuantMala - 1),TamSX3("DXI_CODIGO")[1])

	RestArea(aArea)
Return aSeqNum

/*/{Protheus.doc} VldCodFdi
//Valida o sequenciamento
@author carlos.augusto
@since 14/02/2017
@version undefined
@param cFardinho, characters, Fardinho corrente para retorno da sequencia
@type function
/*/
Static Function VldCodFdi(cFardTmp)
	Local cCodFdiAtu := ""
	Local lRet		 := .T.
	Local nQtdVinc 	 := IIF(!Empty(aMalaDb) .And. aMalaDb[1][4] != 0,  aMalaDb[1][4],0)
	Local cFrdIni  	 := IIF(!Empty(aMalaDb) .And. aMalaDb[1][2] != "", aMalaDb[1][2],"")
	Local cFrdFin  	 := IIF(!Empty(aMalaDb) .And. aMalaDb[1][2] != "", aMalaDb[1][3],"")
	Local cFrdUlt	 := ""  //ultimo fardinho lancado
	Local nx
	Local lFardSup   := .F. //Existem fardos lançados com cod superiores na mala atual aberta
	Local lMalaVazia := .F.

	If lAutMala
		If !Empty(aMalaDb)
			If Val(cFrdFin) < Val(cFardTmp)
				lRet := .F.
				Help('', 1, STR0038, , STR0099, 1 ) //#"O código do fardo é maior do que o último da mala."
			ElseIf Val(cFrdIni) > Val(cFardTmp)
				lRet := .F.
				Help('', 1, STR0038, , STR0100, 1 ) //#"O código do fardo é menor do que o primeiro da mala."
			EndIf
		EndIf

		//Se ja tem fardos vinculados
		If lRet .And. !Empty(aMalaDb) .And. nQtdVinc != 0

			For nx := 1 To Len(aMalaComp)

				//Identificar a ultima amostra lancada
				If nx == 1
					cFrdUlt := aMalaComp[nx][3]
				ElseIf cFrdUlt < aMalaComp[nx][3]
					cFrdUlt := aMalaComp[nx][3]
				EndIf

				//Existe fardos superiores na mesma mala
				If cFardTmp < aMalaComp[nx][3]
					lFardSup := .T.
					Exit
				EndIf

			Next nx

			If lFardSup
				//#"Já existe(m) fardo(s) superior(es) na mala. É possível visualizá-los clicando duas vezes no painel de Mala. Deseja continuar o beneficiamento para o fardo: "
				lRet := MsgYesNo(STR0097 + cFardTmp + "?")
			Else
				If (Val(cFrdUlt) + 1) != Val(cFardTmp)
					lRet := .F.
					cCodFdiAtu := STRZERO(Val(cFrdUlt) + 1, TamSX3("DXI_CODIGO")[1])
					If MsgYesNo(STR0073 + cCodFdiAtu + ". " + STR0086, STR0072)
						lRet := A615CodEti(cCodFdiAtu, .F. , @oBut1)
						cCodFdi := cCodFdiAtu
						lRet := .T.
					EndIf
				EndIf
			EndIf
		Else
			lMalaVazia := .T.
		EndIf

		If lRet .And. lMalaVazia .And. .Not. Empty(cFrdIni) .And. cFrdIni != cFardTmp
			//#"A mala está vazia. Mas o fardo informado não é o primeiro da mala. Deseja continuar o beneficiamento para o fardo: "
			lRet := MsgYesNo(STR0101 + cFardTmp + "?")
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} fncDetMala
//Valida se deve exibir o browse com as amostras
@author carlos.augusto
@since 22/02/2017
@version undefined
@type function
/*/
Static Function fncDetMala()

	If !Empty(aMalaDb) .And. (!Empty(aMalaDb[1][1]) .And. aMalaDb[1][4] != 0)
		fncBuscaDXK()
	Else
		Help('', 1, STR0036, , STR0082, 1 ) //#A mala não possui amostras."
	EndIf
Return

/*/{Protheus.doc} fncBuscaDXK
//Busca amostras e exibe em um novo dialog
@author carlos.augusto
@since 22/02/2017
@version undefined
@type function
/*/
Static Function fncBuscaDXK()
	Local aCoors 	:= FWGetDialogSize(oMainWnd) //Tamanho tela
	Local nAltura  	:= aCoors[3] * 0.7 //Tamanho tela
	Local nLargura 	:= aCoors[4] * 0.7 //Tamanho tela
	Local nx
	Local cArqTemp 	:= ""
	Local aArqTemp 	:= {}
	Local aColBrw 	:=	{"DXK_ETIQ","DXK_FARDO","DXK_CODVAR","DXK_PSLIQU","DXK_PSBRUT","DXK_TALHAO"} //Colunas browse
	Local aColumns 	:= {}

	//Limpa tabela
	If (!Empty(cAlTMPDXK)) .AND. Select(cAlTMPDXK) > 0
		(cAlTMPDXK)->(DbCloseArea())
	EndIf

	//Cria colunas a serem exibidas no browse a partir da SX3
	For nx := 1 To Len(aColBrw)
		AAdd(aColumns,FWBrwColumn():New())

		If !Empty(TamSx3(aColBrw[nx]))
			aColumns[nx]:SetData(&("{||"+aColBrw[nx]+"}"))
			aColumns[nx]:SetTitle(RetTitle(aColBrw[nx]))
			aColumns[nx]:SetPicture(Alltrim(X3PICTURE(aColBrw[nx])))
			aColumns[nx]:SetType(TamSx3(aColBrw[nx])[3])
			aColumns[nx]:SetSize(TamSx3(aColBrw[nx])[1])
			aColumns[nx]:SetReadVar(aColBrw[nx])

			//Campos para a tabela temporária
			AADD(aArqTemp,{aColBrw[nx], TamSx3(aColBrw[nx])[3],TamSx3(aColBrw[nx])[1],TamSx3(aColBrw[nx])[2]})
		EndIf

	Next nx

	//-- Cria Indice de Trabalho
	cArqTemp  := GetNextAlias()
	oArqTemp  := AGRCRTPTB(cArqTemp, {aArqTemp, {{"", "DXK_ETIQ, DXK_FARDO"}} })
	cAlTMPDXK := cArqTemp

	For nx := 1 To Len(aMalaComp)
		DbSelectArea(cAlTMPDXK)
		Reclock(cAlTMPDXK, .T.)
		Replace (cAlTMPDXK)->DXK_ETIQ   With aMalaComp[nx][2]
		Replace (cAlTMPDXK)->DXK_FARDO  With aMalaComp[nx][3]
		Replace (cAlTMPDXK)->DXK_CODVAR With aMalaComp[nx][4]
		Replace (cAlTMPDXK)->DXK_PSLIQU With aMalaComp[nx][5]
		Replace (cAlTMPDXK)->DXK_PSBRUT With aMalaComp[nx][6]
		Replace (cAlTMPDXK)->DXK_TALHAO With aMalaComp[nx][7]
		MsUnlock()
	Next nx

	If Select(cAliasTRB) > 0
		(cAliasTRB)->(dbGoTop())
	EndIf

	//"Detalhamento de Amostras na Mala"
	DEFINE MSDIALOG oDlgX TITLE STR0083 FROM aCoors[1], aCoors[2] TO nAltura, nLargura PIXEL OF oMainWnd

	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	// Instancia o layer
	oFWL1 := FWLayer():New()
	// Inicia o Layer
	oFWL1:init( oDlgX,.F.)
	// Cria colunas
	oFWL1:AddCollumn('COL',100,,)

	oWIN   := oFWL1:GetColPanel('COL',)

	DEFINE FWFORMBROWSE oBrowsX DATA TABLE ALIAS cAlTMPDXK OF oPnlAmost
	oBrowsX:SetTemporary(.T.)
	oBrowsX:SetColumns(aColumns)
	oBrowsX:SetOwner(oWIN)
	oBrowsX:SetDBFFilter(.T.)
	oBrowsX:SetUseFilter(.T.)
	oBrowsX:DisableDetails(.F.)
	oBrowsX:AddButton(STR0084,{|| oDlgX:end()},,9,0) //Sair
	ACTIVATE FWFORMBROWSE oBrowsX
	ACTIVATE MSDIALOG oDlgX CENTER

	Define Font oFont Name 'Courier New' Size 0, -12
Return Nil

/*/{Protheus.doc} fPesqMala
//Busca mala de acordo com a amostra informada
@author carlos.augusto
@since 22/02/2017
@version undefined
@type function
/*/
Static Function fPesqMala(cFardTmp)
	Local lAchouMala := .F.
	Local cQuery 	 := ""

	cANovaMala := GetNextAlias()
	cQuery := " SELECT DXJ.DXJ_SAFRA, DXJ.DXJ_STATUS, DXJ.DXJ_CODIGO, DXJ.DXJ_FRDINI, DXJ.DXJ_FRDFIM, "

	If DXJ->(ColumnPos('DXJ_QTVINC')) > 0
		cQuery += "    DXJ.DXJ_QTVINC, "
	endIf

	cQuery += "        DXJ.DXJ_TIPO, DXJ.R_E_C_N_O_ " 

	cQuery += " FROM " + RetSqlName("DXJ") + " DXJ "
	cQuery += " WHERE DXJ.DXJ_FILIAL = '" + FWxFilial("DXJ") +"'"
	cQuery += " AND DXJ.DXJ_SAFRA = '" + DXL->DXL_SAFRA +"'"

	If DXJ->(ColumnPos( 'DXJ_AUTOMA' )) > 0
		cQuery += " AND DXJ.DXJ_AUTOMA = '1' "
	endIf

	cQuery += " AND  '" + cFardTmp + "' BETWEEN DXJ.DXJ_FRDINI AND  DXJ.DXJ_FRDFIM "
	cQuery += " AND (DXJ.DXJ_STATUS = '1' OR DXJ.DXJ_STATUS = '4') "
	cQuery += " AND DXJ.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cANovaMala, .F., .T.)

	dbSelectArea(cANovaMala)
	dbGoTop()
	If (cANovaMala)->(!Eof())
		(cANovaMala)->DXJ_CODIGO
		lAchouMala := .T.
	EndIf
	(cANovaMala)->(dbCloseArea())
Return lAchouMala

/*/{Protheus.doc} fFrdFim
//Busca mala de acordo com a amostra informada
@author carlos.augusto
@since 22/02/2017
@version undefined
@type function
/*/
Static Function fFrdFim()
	Local cFrdFim := ""
	Local cQuery  := ""

	cAFrdFim := GetNextAlias()
	cQuery := " SELECT DXJ.DXJ_FRDFIM, DXJ.R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("DXJ") + " DXJ "
	cQuery += " WHERE DXJ.DXJ_FILIAL =  '" + FWxFilial("DXJ") +"'"

	If DXJ->(ColumnPos( 'DXJ_AUTOMA' )) > 0
		cQuery += "   AND DXJ.DXJ_AUTOMA = '1' "
	endIf

	cQuery += "   AND DXJ.D_E_L_E_T_ = ' ' "
	cQuery += " Order By DXJ.R_E_C_N_O_ desc "
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAFrdFim, .F., .T.)

	dbSelectArea(cAFrdFim)
	dbGoTop()
	If (cAFrdFim)->(!Eof())
		cFrdFim := (cAFrdFim)->DXJ_FRDFIM
	EndIf
	(cAFrdFim)->(dbCloseArea())
Return cFrdFim

/*/{Protheus.doc} A165VldPro
//Valida o código do produto
@author carlos.augusto
@since 10/03/2017
@version undefined
@type function
/*/
Static Function A165VldPro()
	Local aArea 	:= GetArea()
	Local lRet 		:= .T.

	If !Empty(cCodProdut)
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(FWxFilial('SB1')+cCodProdut))

		dbSelectArea('SB1')
		SB1->(dbSetOrder(1))

		If !ExistCPO('SB1',PADR(cCodProdut,TamSX3('B1_COD')[1],' '),1)
			lRet := .F.
		EndIf

		If lRet
			cDescPro := SB1->B1_DESC
		EndIf
	EndIf

	Restarea(aArea)
Return(lRet)

/*/{Protheus.doc} AGRA615DXL
//Filtra Fardoes de acordo com os dados informados em tela
@author carlos.augusto
@since 10/03/2017
@version undefined
@type function
/*/
Function AGRA615DXL()
	Local cFilter := ""

	cFilter += "@"
	cFilter += "DXL_PSLIQU > 0 AND "	
	cFilter += "DXL_STATUS IN ('3','4') AND "
	cFilter += "DXL_SAFRA='" + PADR(cSafra,TamSx3('DXL_SAFRA')[1],' ') + "' "
	IIF(Empty(cUnb),,cFilter += "AND DXL_CODUNB='" + cUnb + "' ")
	IIF(Empty(cProdutor),,cFilter += "AND DXL_PRDTOR='" + cProdutor + "' ")
	IIF(Empty(cLjPro),,cFilter += "AND DXL_LJPRO='" + cLjPro + "' ")
	IIF(Empty(cCodFaz),,cFilter += "AND DXL_FAZ='" + cCodFaz + "' ")
	IIF(Empty(cCodVar),,cFilter += "AND DXL_CODVAR='" + cCodVar + "' ")
	IIF(Empty(cCodProdut),,cFilter += "AND DXL_CODPRO='" + cCodProdut + "' ")

Return (cFilter)

/*/{Protheus.doc} UNBXEST
//Cria query para busca das esteiras no banco de dados
@author rafael.leithold
@since 15/01/2018
@version 1.0
@type function
/*/
Function A615UXE()
	Local cQry := ""	

	If !Empty(cUNB)
		cQry += "@#N70_CODUNB  == '" + cUNB + "' @#"
	Else
		cQry += "@#N70_CODUNB  == '" + MV_PAR10 + "' @#"
	EndIf  	

Return cQry


/*/{Protheus.doc} fPesqAmost
//Complemento de valid para etiqueta e codigo do fardo.
//Se ja tem amostra em mala para o fardo informado, nao permite beneficiamento em modo mala automatica
@author carlos.augusto
@since 04/04/2018
@version undefined
@param cCodEtq, characters, descricao
@type function
/*/
Static Function fPesqAmost(cSafra, cCodEtq)
	Local cMala		:= ""
	Local cAliasQry := ""
	Local cQry		:= ""

	cAliasQry := GetNextAlias()
	cQry := "SELECT DXK_CODROM "
	cQry += " FROM "+ RetSqlName("DXK") + " DXK"
	cQry += " WHERE DXK.DXK_FILIAL 	= '" + FwxFilial("DXK") + "'"
	cQry += "   AND DXK.DXK_SAFRA 	= '" + cSafra + "'"
	cQry += "   AND DXK.DXK_ETIQ 	= '" + cCodEtq + "'"  
	cQry += "   AND DXK.D_E_L_E_T_	= '' "

	cQry := ChangeQuery( cQry )
	dbUseArea( .T., 'TOPCONN', TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	If !(cAliasQry)->(Eof())
		cMala := (cAliasQry)->DXK_CODROM
	Endif

Return cMala


/*/{Protheus.doc} DelAmostra
//Remove amostra da mala
@author carlos.augusto
@since 26/04/2018
@version undefined
@type function
/*/
Static Function DelAmostra()
	Local lRet		:= .T.
	Local oMdMala
	Local oMdlDXK 
	Local aAreaDXK
	Local nX
	Local aArea := GetArea()

	If .Not. Empty(DXI->DXI_CLAVIS)
		//Classificação visual encontrada
		Help('' ,1,".AGRA61500113.", , ,1,0)//O fardo informado possui classificação visual.
		lRet := .F.	
	EndIf

	If lRet
		dbSelectArea("DX7")
		DX7->(dbSetOrder(2))
		If MsSeek(FWxFilial("DX7") + DXI->DXI_SAFRA + DXI->DXI_ETIQ + '1')
			Help('' ,1,".AGRA61500114.", , ,1,0) //O fardo informado possui classificação HVI.
			//Importacao HVI encontrada
			lRet := .F. 	
		EndIf
		DX7->(dbCloseArea())
	EndIf

	If lRet
		dbSelectArea("NPX")
		NPX->(dbSetOrder(4))
		If MsSeek(FWxFilial("NPX") + DXI->DXI_SAFRA + DXI->DXI_ETIQ)
			While NPX->(!Eof()) .And. NPX->NPX_FILIAL == FWxFilial("NPX") .And. ;
			NPX->NPX_CODSAF == DXI->DXI_SAFRA .And. NPX->NPX_ETIQ == DXI->DXI_ETIQ .And. NPX->NPX_ATIVO == "1"
				Help('' ,1,".AGRA61500115.", , ,1,0) //O fardo informado possui lançamento de contaminantes.
				//Lançamento de contaminante encontrado
				lRet := .F.
				exit
				NPX->(dbSkip())
			EndDo
		EndIF
		NPX->(dbCloseArea())
	EndIf

	If lRet

		Begin Transaction

			dbSelectArea("DXK")
			DXK->(dbSetOrder(2))
			If MsSeek(FWxFilial("DXK") + DXI->DXI_SAFRA + DXI->DXI_ETIQ)

				While DXK->(!Eof()) .And. DXK->DXK_FILIAL == FWxFilial("DXK") .And. ;
				DXK->DXK_SAFRA == DXI->DXI_SAFRA .And. DXK->DXK_ETIQ == DXI->DXI_ETIQ .And. lRet
					aAreaDXK := DXK->(GetArea())
					dbSelectArea("DXJ")
					DXJ->(dbSetOrder(3))
					If MsSeek(FWxFilial("DXJ") + DXK->DXK_SAFRA + DXK->DXK_CODROM + DXK->DXK_TIPO)

						oMdMala	:= FwLoadModel('AGRA630')
						oMdlDXK := oMdMala:GetModel('MdGridDXK')
						oMdlDXJ := oMdMala:GetModel( 'MdFieldDXJ' )

						oMdMala:SetOperation( MODEL_OPERATION_UPDATE )
						If oMdMala:Activate()
							For nX := 1 to oMdlDXK:Length()
								oMdlDXK:GoLine( nX )
								If oMdlDXK:GetValue("DXK_ETIQ") == DXI->DXI_ETIQ
									oMdlDXK:DeleteLine()
									oMdlDXJ:LoadValue("DXJ_QTVINC", oMdlDXJ:GetValue("DXJ_QTVINC")-1)
								EndIf 
							Next nX
							lRet := oMdMala:VldData()
							If lRet
								lRet := oMdMala:CommitData()
							EndIf
							If .Not. lRet
								Help('', 1, STR0038, , oMdMala:GetErrorMessage()[6] + " - " + oMdMala:GetErrorMessage()[7], 1 ) //Atenção
							EndIf
							oMdMala:DeActivate()
						Else
							Help('', 1, STR0038, , oMdMala:GetErrorMessage()[6], 1 ) //Atenção. 
							lRet := .F.
						EndIf

					EndIF
					DXJ->(dbCloseArea())
					RestArea( aAreaDXK )
					DXK->(dbSkip())
				EndDo
			EndIF
			DXK->(dbCloseArea())

			If .Not. lRet
				DisarmTransaction()
			EndIf

		End Transaction

	EndIf
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} ConsDXLF3
função para criar consulta especifica caso exista fardos com mesmo código
@author Christopher.miranda
@since 16/07/2019
@version 1.0
/*/
Function ConsDXLF3() 
	Local aBotoes	:= {}
	Private _oLista                    //Declarando o objeto do browser
	Private _oDlg
	Private _aCabecalho  := {}         //Variavel que montará o aHeader do grid
	Private _aFardos 	:= {}         //Variável que receberá os dados

	DEFINE MSDIALOG _oDlg TITLE "Fardões" FROM 000, 000  TO 300, 700  PIXEL
	//chamar a função que cria a estrutura do aHeader
	fCabecFrd()

	//Monta o browser com inclusão, remoção e atualização
	_oLista := MsNewGetDados():New( 060, 080, 450, 800,GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue","AllwaysTrue","",,,99,"AllwaysTrue",,"AllwaysTrue",_oDlg, _aCabecalho, _aFardos)
	_oLista:lActive := .F.
	_oLista:oBrowse:blDblClick := {|| fDbClick() }

	//Carregar os itens que irão compor o conteudo do grid
	fCarrFrd()

	//Alinho o grid para ocupar todo o meu formulário
	_oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	_oLista:oBrowse:SetFocus()

	//Crio o menu que irá aparece no botão Ações relacionadas

	EnchoiceBar(_oDlg, {|| _oDlg:End() }, {|| _oDlg:End() },,aBotoes)


	ACTIVATE MSDIALOG _oDlg CENTERED
Return

/*/{Protheus.doc} fCabecFrd
função para carregar o cabeçalho responsavel pela consulta
@author Christopher.miranda
@since 16/07/2019
@version 1.0
/*/
Static Function fCabecFrd()
	Aadd(_aCabecalho, {"Código","código fardão","@!",6,0,"","","C","","R","","",""})
	Aadd(_aCabecalho, {"Safra","safra","@!",15,0,"","","C","","R","","",""})
	Aadd(_aCabecalho, {"Entidade","entidade","@!",6,0,"","","C","","R","","",""})
	Aadd(_aCabecalho, {"Nome Ent","nome entidade","@!",40,0,"","","C","","V","","",""})
	Aadd(_aCabecalho, {"Loja Ent","loja entidade","@!",2,0,"","","C","","R","","",""})
	Aadd(_aCabecalho, {"Fazenda","fazenda","@!",2,0,"","","C","","R","","",""})
	Aadd(_aCabecalho, {"Nome Faz","nome faz","@!",40,0,"","","C","","V","","",""})
	Aadd(_aCabecalho, {"Produto","código produto","@!",15,0,"","","C","","R","","",""})
	Aadd(_aCabecalho, {"Desc Prod","descri produto","@!",40,0,"","","C","","V","","",""})
	Aadd(_aCabecalho, {"Variedade","código variedade","@!",6,0,"","","C","","R","","",""})
	Aadd(_aCabecalho, {"Desc Var","descri variedade","@!",30,0,"","","C","","V","","",""})
	Aadd(_aCabecalho, {"Un. Benef.","un. beneficiamento","@!",2,0,"","","C","","R","","",""})
	Aadd(_aCabecalho, {"Pes. Liquid.","peso liquido","@!",14,2,"","","C","","V","","",""})

Return

/*/{Protheus.doc} fCarrFrdF3
função para carregar o array responsavel pela consulta
@author Christopher.miranda
@since 16/07/2019
@version 1.0
/*/
Static Function fCarrFrd()
	Local nomePdtor	:= ""
	Local nomeFaz   := ""
	Local descPro   := ""
	Local descVar   := ""
	Local aArea    	:= GetArea()
	Local lRet		:= .T.

	dbSelectArea( cAliasFrd )
	(cAliasFrd)->(dbGoTop())
	While (cAliasFrd)->(!Eof()) 

		If lRPO17 
			nomePdtor 	:= Posicione( "DX8", 1, FWxFilial("DX8") + (cAliasFrd)->(DXL_PRDTOR+DXL_LJPRO), "DX8_NOME" )
		Else
			nomePdtor 	:= Posicione( "NJ0", 1, FWxFilial("NJ0") + (cAliasFrd)->(DXL_PRDTOR+DXL_LJPRO), "NJ0_NOME" )
		Endif
		nomeFaz 	:= Posicione( "NN2", 3, FWxFilial("NN2") + (cAliasFrd)->(DXL_PRDTOR+DXL_LJPRO+DXL_FAZ), "NN2_NOME" )
		descPro 	:= Posicione( "SB1", 1, xFilial( "SB1" ) + (cAliasFrd)->DXL_CODPRO, "B1_DESC" )
		descVar 	:= Posicione("NNV",2,FWxFilial("NNV") + (cAliasFrd)->DXL_CODVAR, "NNV_DESCRI")

		Aadd(_aFardos, {cCodFda, (cAliasFrd)->DXL_SAFRA, (cAliasFrd)->DXL_PRDTOR, nomePdtor, ;
		(cAliasFrd)->DXL_LJPRO, (cAliasFrd)->DXL_FAZ, nomeFaz, (cAliasFrd)->DXL_CODPRO, descPro,;
		(cAliasFrd)->DXL_CODVAR, descVar, (cAliasFrd)->DXL_CODUNB, (cAliasFrd)->DXL_PSLIQU, .F.})

		(cAliasFrd)->(dbskip())

	EndDo

	//Setar array do aCols do Objeto.
	_oLista:SetArray(_aFardos,.T.)

	//Atualizo as informações no grid
	_oLista:Refresh()

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fDbClick
função para gatilhar informações ao dar o duplo click
@author Christopher.miranda
@since 16/07/2019
@version 1.0
/*/
Static Function fDbClick()
	Local lRet 		:= .T.
	Local cQry 		:= ""
	Local cQryRet 	:= GetNextAlias()

	cQry := "SELECT * "
	cQry += " FROM " +RetSqlName("DXL")+ " DXL "
	cQry += " WHERE DXL.D_E_L_E_T_ = ' ' "
	cQry += " AND DXL_FILIAL = '"+FwxFilial( 'DXL' )+"' "
	cQry += " AND DXL_CODIGO = '" +_aFardos[_oLista:nAt][1]+ "' "
	cQry += " AND DXL_SAFRA = '" +_aFardos[_oLista:nAt][2]+ "' "
	cQry += " AND DXL_PRDTOR = '" +_aFardos[_oLista:nAt][3]+ "' "
	cQry += " AND DXL_LJPRO = '" +_aFardos[_oLista:nAt][5]+ "' "
	cQry += " AND DXL_FAZ = '" +_aFardos[_oLista:nAt][6]+ "' "

	cQry := ChangeQuery( cQry ) 
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cQryRet, .F., .T. )

	cSafra 		:= (cQryRet)->DXL_SAFRA
	cProdutor 	:= (cQryRet)->DXL_PRDTOR
	cLjPro 		:= (cQryRet)->DXL_LJPRO
	If lRPO17 
		cNmPdtor 	:= Posicione( "DX8", 1, FWxFilial("DX8") + (cQryRet)->(DXL_PRDTOR+DXL_LJPRO), "DX8_NOME" )
	Else
		cNmPdtor 	:= Posicione( "NJ0", 1, FWxFilial("NJ0") + (cQryRet)->(DXL_PRDTOR+DXL_LJPRO), "NJ0_NOME" )
	Endif
	cCodFaz 	:= (cQryRet)->DXL_FAZ
	cNomeFaz 	:= Posicione( "NN2", 3, FWxFilial("NN2") + (cQryRet)->(DXL_PRDTOR+DXL_LJPRO+DXL_FAZ), "NN2_NOME" )
	cCodProdut 	:= (cQryRet)->DXL_CODPRO
	cDescPro 	:= Posicione( "SB1", 1, xFilial( "SB1" ) + (cQryRet)->DXL_CODPRO, "B1_DESC" )
	cCodVar 	:= (cQryRet)->DXL_CODVAR
	cDescVar 	:= Posicione("NNV",2,FWxFilial("NNV") + (cQryRet)->DXL_CODVAR, "NNV_DESCRI")
	cCodUNB 	:= (cQryRet)->DXL_CODUNB
	nPsLiqu 	:= (cQryRet)->DXL_PSLIQU

	_oDlg:End()

Return lRet

/*/{Protheus.doc} A165VldDtB
Adaptação da função A680calen - MATA680, para que a data de beneficiamento seja alterada conforme início/fim do turno - Solicitado pela BF
@author lara.rodrigues
@since 09/09/2020
@version 1.0
/*/
Static Function A165VldDtB(cCalend)
    Local nDias     := 0
	Local nDias1    := 0
	Local nInicio   := 1
	Local aCalend   := {}
	Local aHorIni   := {} 
	Local aHorFim   := {}
	Local aHorInip  := {} 
	Local aHorFimp  := {}
	Local nPrecisao := 4
    Local nTamDia   := 1440/(60/nPrecisao)
	Local cIdent    := " "
	Local lVirada   := .F.
	Local cHoraAtu  := ""
	Local cFimTurno := ""
	Local cIniTurno := ""
	Local nDia      := 0

	//Se já possui algum fardinho é setado a mesma data para os próximos fardinhos do fardão
	nrecno := recno()
	If AGRIFDBSEEK("DXI", DXL->DXL_CODIGO + DXL->DXL_SAFRA,2,.F.)
		aMatriz := AGRBUSREGIS("DXI","DXI_FILIAL+DXI_FARDAO+DXI_SAFRA",2,.F.,.F.,"DXI_FILIAL= xFilial('DXI').and.  DXI_FARDAO = cCodFda .and. DXI_SAFRA = cSafra ",	{{"DXI_DATA"},{"DXI_HORA"},{'DXI_CODTUR'}},'recno() <>  nrecno ',,"M",)
		aFardos := aclone(aMatriz[2])
		If (Len(aFardos) > 0 )
			aFardos := ASort( aFardos, , , { | x, y | dtos(x[ 1 ]) + x[ 2 ] < dtos(y[ 1 ]) + y[ 2 ]})
			DtBenef := aFardos[1,1]
		Endif	
	Else //Se não possui fardinho, obtém-se inicio e fim do turno e verifica se é setado a data atual ou data - 1 
		For nDias := 1 to 7 //Separa o calendário em dias da semana
			AADD(aCalend,Substr(cCalend,nInicio,nTamDia)) 
			nInicio+=nTamDia
		Next nDias

		For nDias := 1 To Len(aCalend) //hora inicial e final do calendário em número para cálculo.
			If !Empty(aCalend[nDias])
				AADD(aHorIni ,((60/nPrecisao)/60)*(AT("X",Upper(aCalend[nDias]))-1))
				AADD(aHorFim, ((60/nPrecisao)/60)*(RAT("X",Upper(aCalend[nDias]))))
   			EndIf

			For nDias1 := AT("X",Upper(aCalend[nDias])) To RAT("X",Upper(aCalend[nDias])) //Hora inicial e final das paradas do calendário em número para cálculo
				If Substr(Upper(aCalend[nDias]),nDias1,1) == cIdent
    				If Empty(cIdent)
						AADD(aHorFimp, {nDias, ((60/nPrecisao)/60)*(nDias1-1)})
						cIdent  := "X"
					Else
						AADD(aHorInip, {nDias,((60/nPrecisao)/60)*(nDias1-1)})
	   					cIdent  := " "
					EndIf
				EndIf
 			Next nDias1
		Next nDias
			
		//Pegando o dia atual para saber qual indice do array
		nDia := Dow(Date()) // Retorna o dia de hoje em número
		If nDia == 7 //Sabado para função Dow
			ndDia := 6 // Sabado no indice
		ElseIf nDia == 1 // Domingo para função Dow
			nDia := 7 //Sabado no indice
		Else 
			nDia := 1 // Calendário permite horários diferentes apenas sab/dom, então se não for sab/dom é considerado o primeiro dia 
		Endif	
			
		//Obtendo inicio e fim do turno e convertendo de horas para minutos	
		If aHorIni[1] == 0 //Quando turno possui virada, esta variável possui valor 0 e o início e fim do turno ficam em aHorInip e aHorFimp 
			cFimTurno := Hrs2Min(aHorFimp[nDia][2])
			cIniTurno := Hrs2Min(aHorInip[nDia][2])
			lVirada   := .T. 			
		Else // Quando turno não possui virada início/fim do turno ficam em aHorFim e aHorIni
			cFimTurno := Hrs2Min(aHorFim[nDia]) 		
			cIniTurno := Hrs2Min(aHorIni[nDia])
		Endif
		
		cHoraAtu := Hrs2Min(Time()) //Convertendo a hora atual para minutos
			
		//Verificando se é necessário retrocer para o dia anterior
		If cHoraAtu < cIniTurno .AND. cHoraAtu <= cFimTurno .AND. lVirada //Única situação em que é necessário retroceder. 
			DtBenef := Date() - 1
		Else
			DtBenef := Date()
		Endif	
	Endif		
Return	

/*/{Protheus.doc} fTrataPEF9
Função para tratar o ponto de entrada AG615FRDA
@author claudineia.reinert
@since 01/12/2020
@version 1.0
/*/
Static Function fTrataPEF9()
	If ExistBlock('AG615FRDA')
		aRet := ExecBlock('AG615FRDA',.F.,.F.)
		If ValType(aRet) == 'A'	 .and. !Empty(Alltrim(aRet[8]))
			ClearGet({'cSafra','cProdutor','cLjpro','cNmPdtor','cCodFaz','cNomeFaz','cCodProdut','cDescPro','cCodVar','cDescVar','cCodUNB','cCodFda','nPsLiqu'})
			cSafra 		:= PADR(Alltrim(aRet[1]), TamSX3('NJU_CODSAF')[1])
			cProdutor	:= PADR(Alltrim(aRet[2]), TamSX3('NJ0_CODENT')[1])
			cLjPro		:= PADR(Alltrim(aRet[3]), TamSX3('NJ0_LOJENT')[1])
			cNmPdtor 	:= PADR(AllTrim(Posicione( "NJ0", 1, FWxFilial("NJ0") + cProdutor + cLjPro, "NJ0_NOME" )), 40)
			cCodFaz		:= PADR(Alltrim(aRet[4]), TamSX3('NN2_CODIGO')[1])
			cNomeFaz 	:= PADR(Alltrim(Posicione( "NN2", 3, FWxFilial("NN2") + cProdutor + cLjPro + cCodFaz, "NN2_NOME" )), 30)
			cCodProdut	:= PADR(Alltrim(aRet[5]), TamSX3('B1_COD')[1])
			cDescPro 	:= PADR(Alltrim(Posicione( "SB1", 1, xFilial( "SB1" ) + cCodProdut, "B1_DESC" )), 50)
			cCodVar		:= PADR(Alltrim(aRet[6]), TamSX3('NNV_CODIGO')[1])
			cDescVar 	:= PADR(Alltrim(Posicione("NNV",2,FWxFilial("NNV") + cCodVar, "NNV_DESCRI")), 15)
			cCodUNB		:= PADR(Alltrim(aRet[7]), TamSX3('DXL_CODUNB')[1])
			cCodFda		:= PADR(Alltrim(aRet[8]), TamSX3('DXL_CODIGO')[1])
			A165CodFda()
			oGCodFda:SetFocus()
		EndIf
	EndIf
Return 
