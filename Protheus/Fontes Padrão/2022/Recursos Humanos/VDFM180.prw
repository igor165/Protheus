#include "VDFM180.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 

Static lGp020Auto := .F. //SetRotAuto()

//-------------------------------------------------------------------
/*{Protheus.doc} VDFM180  
Alteração de Cragos e Subsidios
@owner Nivia Ferreira
@author Nivia Ferreira
@since 03/10/2013
@version P11
@project GESTÃO DE PESSOAS E VIDA FUNCIONAL MP-MT (M12RHMP)
@history 03/12/2013, Nivia F.		, Alteração de Cargos e Subsidios
@history 20/12/2013, Marcos/Ademar	, Ajuste de tela (scrool) e de nomenclaturas
@history 18/02/2014, Fabricio Amaro	, Ajustes para considerar a categoria 6; 
		Ajustes para sugerir automaticamente o tipo de aumento quando categoria 2 <-> 3 e 6 <-> 6
@history 02/10/2014, Marcos Pereira	, Ajuste na validacao dos periodos fechados para apresentar a msg somente uma vez.
@history 12/05/2015, Joao Balbino	, Tratamento para progressão retroativa.
@history 05/07/2015, Joao Balbino	, Tratamento p/ calc da progeressão retroativa em caso de serv. comissionado efetivo.
@history 01/08/2016, Joao Balbino	, Tratamento p/ regravar registros da SR3 e SR7 na alteração de cargo e subs, retroativo.
@history 16/08/2016, Joao Balbino	, Tratamento p/   gravar registros da SR3 e SR7 na alteração de cargo e subs, retroativo.
@history 30/08/2016, Joao Balbino	, Tratamento p/   gravar gravar o campo de salário de subsidio conforme salario atualizado.
/*/
//-------------------------------------------------------------------
Function VDFM180(aDadosAt)
	Local 	oBrowse
	
	Static aDadosAut	:= {} 
	Default aDadosAt	:= {}

	If Empty(aDadosAt)
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('SRA')
		oBrowse:SetDescription(STR0001)//'Alteração de Cargos e Subsídios'
		oBrowse:SetFilterDefault( "RA_CATFUNC $ '0,1,2,3,5,6' .And. RA_MSBLQL<>'1' .And. RA_SITFOLH<>'D'")
		GpLegend(@oBrowse,.T.)
		oBrowse:DisableDetails()
		oBrowse:Activate()
	Else
		aDadosAut	:= aClone(aDadosAt)
		VDM180ACS()
	EndIf
	
Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	//ADD OPTION aRotina TITLE STR0057 ACTION 'VIEWDEF.VDFM180' OPERATION 2 ACCESS 0//'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VDM180ACS()'     OPERATION 9 ACCESS 0//'Processar Alteração'

Return aRotina


//------------------------------------------------------------------------------
/*/ {Protheus.doc} VDM180ACS
Tela com os Dados de Transferencia
@sample 	VDM180ACS()
@param		
@return	Nil 
@author	Nivia Ferreira			
@since		03/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDM180ACS()
	Local aArea     	 := GetArea()
	Local cAlias    	 := GetNextAlias()
	Local aSize	  		 := FWGetDialogSize( oMainWnd )
	Local aAdvSize		 := {}      
	Local aInfoAdvSize   := {}
	Local aObjSize	 	 := {}
	Local aObjCoords	 := {} 
	Local cCadastro 	 := STR0006 // 'Alteração de Cargos e Subsídios'
	Local lAut 		     := .F.
	Local oGet
	Local oDlg 
	Local oComb
	Local oCombCM
	
	Local lComarq       := .F.
	Local lRet   		:= .F.
	Local bOk     		:= {||lRet:=.t.,oDlg:End()}
	Local bCancel 		:= {||oDlg:End()}
	
	Local cDFuncao 		:= POSICIONE("SRJ",1,FWXFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_DESC")
	Local cDCargo  		:= POSICIONE("SQ3",1,FWXFILIAL("SQ3")+SRA->RA_CARGO  ,"Q3_DESCSUM")
	 
	Private aTabela     := {}
	Private dDataPro    := ctod("  /  /  ") 
	Private cCatfunc	:= Space( TamSX3("RA_CATFUNC")[1])
	Private cCodFunc	:= Space( TamSX3("RA_CODFUNC")[1])
	Private cCargo  	:= Space( TamSX3("RA_CARGO")[1])
	Private cTabela 	:= Space( TamSX3("RA_TABELA")[1])
	Private cTabNive 	:= Space( TamSX3("RA_TABNIVE")[1])
	Private cTabFaix	:= Space( TamSX3("RA_TABFAIX")[1])
	Private nSalario	:= Space( TamSX3("RA_SALARIO")[1])
	Private cTipAum		:= SPACE(03) 
	Private cCombTP		:= ''
	Private cCombCM		:= ''
	Private cComb		:= ''
	Private oCombTP
	Private cCateSoc	:= Space( TamSX3("RA_CATEFD")[1])
	
	Private _Catfunc	:= ''
	Private _CodFunc	:= ''
	Private _Cargo  	:= ''
	Private _Tabela 	:= ''
	Private _TabNive 	:= ''
	Private _TabFaix	:= ''
	Private _Salario	:= 0 //''
	Private _Orgao	    := ''
	Private _CNPJ		:= ''
	Private _DTret	    := '' 
	Private _Tipo   	:= ''
	Private _Tipoc 	    := 0 //''    
	Private _TipoAlt	:= ''
	Private _TipoCD  	:= '' 
	Private _CateSoc	:= ''
	
	Private cOrgao	    := SPACE(30)
	Private cCNPJ	    := SPACE(14)
	Private cDTret	    := ctod("  /  /  ") 
	Private aComb   	:= {}
	Private aCombCM	    := {}
	Private mChave 	    := ''
	Private nDifComs	:= GetMV( "MV_VDFDCOM" )
	Private cCODF_Ant	:= ''
	Private cCargo_Ant  := ''
	Private cTAB_Ant	:= 0
	Private cTABN_Ant	:= 0
	Private cTABF_Ant	:= 0
	Private nSAL_Ant 	:= 0
	Private	lRetro		:= .F.
	Default aDadosAut	:= {}
	
	
	lAut := !Empty(aDadosAut)
	VD180HABIL()  //Rotina para habilitar os campos
	If !lAut
		aAdvSize			:= MsAdvSize()
		aInfoAdvSize		:= { aAdvSize[1] , aAdvSize[2]-14, aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
		aAdd( aObjCoords , { 000 , 000 , .t. , .t. } )
		aObjSize			:= MsObjSize( aInfoAdvSize , aObjCoords )
		
		aCombTP:={"",STR0053,STR0054}//'1=Diferença Subsídio entre cargos','2=% s/ Subsidio do Comissionado'
		If SRA->RA_CATFUNC $ '1,3,6'
			aCombCm		:={'',STR0055,STR0056} //"1=Efetivo","2=Comissionado"
		Endif   
		
		
		
		
		Begin Sequence
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
			
				oScr1 := TScrollBox():New(oDlg,aObjSize[1,1],aObjSize[1,2],aObjSize[1,3],aObjSize[1,4],.T.,.T.,.T.)
				oPanelC := tPanel():New(050,001,STR0058 ,oScr1,,,,,,700,360,.T.,.T.)//"     Informar Alterações"
				oPanel1	:= tPanel():New(090,005,"",oScr1,,.T., .T.,,,360,165,.T.,.T.)      
				oPanel2	:= tPanel():New(090,320,"",oScr1,,.T., .T.,,,360,165,.T.,.T.)
				oPanelR	:= tPanel():New(260,005,"",oScr1,,.T., .T.,,,700,050,.T.,.T.)
				
				//Cabeçalho
				@ aObjSize[1,1], aObjSize[1,2]+010 SAY  STR0060 SIZE 30,10 PIXEL OF oScr1 //"Filial:"
				@ aObjSize[1,1], aObjSize[1,2]+032 MSGET oGet VAR SRA->RA_FILIAL SIZE 30,10 OF oScr1 PIXEL WHEN .F.
								
				@ aObjSize[1,1], aObjSize[1,2]+177 SAY  STR0061 SIZE 30,10 PIXEL OF oScr1 //"Matricula:"
				@ aObjSize[1,1], aObjSize[1,2]+203 MSGET oGet VAR SRA->RA_MAT SIZE 30,10 OF oScr1 PIXEL WHEN .F.
				
				@ aObjSize[1,1], aObjSize[1,2]+340 SAY  STR0062 SIZE 25,10 PIXEL OF oScr1 //"Nome:"
				@ aObjSize[1,1], aObjSize[1,2]+360 MSGET oGet VAR SRA->RA_NOME SIZE 150,10 OF oScr1 PIXEL WHEN .F.

				@ aObjSize[1,1]+15, aObjSize[1,2]+010 SAY  STR0063 SIZE 50,10 PIXEL OF oScr1 //"Função:"
				@ aObjSize[1,1]+15, aObjSize[1,2]+032 MSGET oGet VAR cDFuncao SIZE 100,10 OF oScr1 PIXEL WHEN .F.
				
				@ aObjSize[1,1]+15, aObjSize[1,2]+177 SAY  STR0064 SIZE 20,10 PIXEL OF oScr1 //"Cargo:"
				@ aObjSize[1,1]+15, aObjSize[1,2]+203 MSGET oGet VAR cDCargo SIZE 100,10 OF oScr1 PIXEL WHEN .F.
				
				@ aObjSize[1,1]+15, aObjSize[1,2]+340 SAY  STR0065 SIZE 25,10 PIXEL OF oScr1 //"Tabela:"
				@ aObjSize[1,1]+15, aObjSize[1,2]+360 MSGET oGet VAR SRA->RA_TABELA SIZE 20,10 OF oScr1 PIXEL WHEN .F.
				
				@ aObjSize[1,1]+15, aObjSize[1,2]+410 SAY  STR0066 SIZE 25,10 PIXEL OF oScr1 //"Nível:"
				@ aObjSize[1,1]+15, aObjSize[1,2]+428 MSGET oGet VAR SRA->RA_TABNIVE SIZE 20,10 OF oScr1 PIXEL WHEN .F.
				
				@ aObjSize[1,1]+15, aObjSize[1,2]+470 SAY  STR0067 SIZE 25,10 PIXEL OF oScr1 //"Faixa:"
				@ aObjSize[1,1]+15, aObjSize[1,2]+488 MSGET oGet VAR SRA->RA_TABFAIX SIZE 20,10 OF oScr1 PIXEL WHEN .F.

				//Panel
				oSay:= TSay():New( 015, 10, { || STR0007 }, oPanelC,,,,,,.T.,,, 100, 10 )//'Data para Processar as Alterações:'
				@ 060,100 MSGET oGet VAR dDataPro PICTURE "@D" Valid VD180VALID({1}, lAut) SIZE 58,10 OF oScr1 PIXEL HASBUTTON WHEN aTabela[1]
				
				oSay:= TSay():New( 030, 10, { || STR0008 }, oPanelC,,,,,,.T.,,, 100, 10 )//'Ação s/Efetivo ou Comissionamento:'
				@ 078,100 MSCOMBOBOX oCombCM VAR cCombCM ITEMS aCombCM  Valid VD180VALID({15}, lAut) SIZE 100,8 OF oScr1 PIXEL WHEN aTabela[15]
				
				oSay:= TSay():New( 030, 350, { || STR0076 }, oPanelC,,,,,,.T.,,, 250, 10 )//'Relacionamento EFETIVO x COMISSIONAMENTO'
				
				//Panel1
				oSay:= TSay():New( 010, 10, { || STR0009 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Categoria:'
				@ 100,070 MSGET oGet VAR cCATFUNC  PICTURE "@!" Valid VD180VALID({2},lAut) F3 "28" SIZE 25,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[2]
				@ 100,110 MSGET Alltrim(Posicione('SX5',1,FwxFilial('SX5')+'28'+cCATFUNC,'X5_Descri')) VALID {|| ,oScr1:Refresh()} SIZE 90,8  OF oScr1 Pixel WHEN .F. 	     	  	
						
				//Categoria eSocial
				oSay:= TSay():New( 025, 10, { || STR0078 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Categoria eSocial:'
				@ 115,070 MSGET oGet VAR cCATESOC  PICTURE "@!" Valid VD180VALID({16},lAut) F3 "S049BR" SIZE 25,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[16]
				@ 115,110 MSGET fDescRCC("S049",cCATESOC,1,3,4,30) VALID {|| ,oScr1:Refresh()} SIZE 90,8  OF oScr1 Pixel WHEN .F. 	     	  	


				oSay:= TSay():New( 040, 10, { || STR0017 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Tipo Ação/Aumento:'
				@ 130,070 MSGET oGet VAR cTipAum  PICTURE "@!" Valid VD180VALID({9},lAut) F3 "41" SIZE 25,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[9]
				@ 130,110 MSGET Alltrim(Posicione('SX5',1,FwxFilial('SX5')+'41'+cTipAum,'X5_Descri')) VALID {|| ,oScr1:Refresh()} SIZE 90,8  OF oScr1 Pixel WHEN .F.
				
				oSay:= TSay():New( 055, 10, { || STR0011 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Função:'
				@ 145,070 MSGET oGet VAR cCODFUNC  PICTURE "@!" Valid VD180VALID({3},lAut) F3 "SRJ" SIZE 25,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[3]
				@ 145,110 MSGET Alltrim(POSICIONE("SRJ",1,FwxFilial("SRJ")+cCODFUNC,"RJ_DESC")) VALID {|| ,oScr1:Refresh()} SIZE 90,8  OF oScr1 Pixel WHEN .F.
				
				oSay:= TSay():New( 070, 10, { || STR0012 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Cargo:'
				@ 160,070 MSGET oGet VAR cCARGO  PICTURE "@!" Valid VD180VALID({4},lAut) SIZE 25,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[4]
				@ 160,110 MSGET Alltrim(POSICIONE("SQ3",1,FwxFilial("SQ3")+cCARGO,"Q3_DESCSUM")) VALID {|| ,oScr1:Refresh()} SIZE 90,8  OF oScr1 Pixel WHEN .F.
				
				oSay:= TSay():New( 085, 10, { || STR0013 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Tabela de Subsídios:'
				@ 175,070 MSGET oGet VAR cTABELA  PICTURE "999" Valid VD180VALID({5},lAut)  SIZE 20,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[5]
				
				oSay:= TSay():New( 100, 10, { || STR0014 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Nivel da Tabela:'
				@ 190,070 MSGET oGet VAR cTABNIVE  PICTURE "@!" Valid VD180VALID({6},lAut) F3 "RB606" SIZE 20,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[6]
				
				oSay:= TSay():New( 115, 10, { || STR0015 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Faixa da Tabela:'
				@ 205,070 MSGET oGet VAR cTABFAIX  PICTURE "@!" Valid VD180VALID({7},lAut) F3 "RB607" SIZE 20,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[7]
				
				oSay:= TSay():New( 130, 10, { || STR0016 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Subsídio:'
				@ 220,070 MSGET oGet VAR nSALARIO  PICTURE "@E 999,999,999.99" Valid VD180VALID({8},lAut)  SIZE 70,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[8]
				
				oSay:= TSay():New( 145, 10, { || STR0010 }, oPanel1,,,,,,.T.,,, 100, 10 )//'Tipo Dif. Comis.:'
				@ 235,070 MSCOMBOBOX oCombTP VAR cCombTP ITEMS aCombTP Valid VD180VALID({14},lAut) SIZE 100,8 OF oScr1 PIXEL WHEN aTabela[14]
				
				//Panel2 - Posicao Anterior
				oSay:= TSay():New( 010, 10, { || STR0009 }, oPanel2,,,,,,.T.,,, 100, 10 )//'Categoria:'
				@ 100,390 MSGET oGet VAR _Catfunc  SIZE 100,8 OF oScr1 PIXEL HASBUTTON WHEN .F.
										
				//Panel2 - Categ eSocial
				oSay:= TSay():New( 025, 10, { || STR0078 }, oPanel2,,,,,,.T.,,, 100, 10 )//'Categoria:'
				@ 115,390 MSGET oGet VAR _CateSoc  SIZE 100,8 OF oScr1 PIXEL HASBUTTON WHEN .F.

				oSay:= TSay():New( 040, 10, { || STR0017 }, oPanel2,,,,,,.T.,,, 100, 10 )//'Tipo Ação/Aumento:'
				@ 130,390 MSGET oGet VAR _TipoAlt  SIZE 100,8 OF oScr1 PIXEL HASBUTTON WHEN .F.
				
				oSay:= TSay():New( 055, 10, { || STR0011 }, oPanel2,,,,,,.T.,,, 100, 10 )//'Função:'
				@ 145,390 MSGET oGet VAR _CodFunc  SIZE 120,8 OF oScr1 PIXEL HASBUTTON WHEN .F.
				
				oSay:= TSay():New( 070, 10, { || STR0012 }, oPanel2,,,,,,.T.,,, 100, 10 )//'Cargo:'
				@ 160,390 MSGET oGet VAR _Cargo    SIZE 120,8 OF oScr1 PIXEL HASBUTTON WHEN .F.
				
				oSay:= TSay():New( 085, 10, { || STR0013 }, oPanel2,,,,,,.T.,,, 100, 10 )//'Tabela de Subsídios:'
				@ 175,390 MSGET oGet VAR _Tabela   SIZE 20,8 OF oScr1 PIXEL HASBUTTON WHEN .F.
				
				oSay:= TSay():New( 100, 10, { || STR0014 }, oPanel2,,,,,,.T.,,, 100, 10 )//'Nivel da Tabela:'
				@ 190,390 MSGET oGet VAR _TabNive  SIZE 20,8 OF oScr1 PIXEL HASBUTTON WHEN .F.
				
				oSay:= TSay():New( 115, 10, { || STR0015 }, oPanel2,,,,,,.T.,,, 100, 10 )//'Faixa da Tabela:'
				@ 205,390 MSGET oGet VAR _TabFaix  SIZE 20,8 OF oScr1 PIXEL HASBUTTON WHEN .F.
				
				oSay:= TSay():New( 130, 10, { || STR0016 }, oPanel2,,,,,,.T.,,, 100, 10 )//Subsídio:'
				@ 220,390 MSGET oGet VAR _Salario  PICTURE "@E 999,999,999.99" SIZE 70,8 OF oScr1 PIXEL HASBUTTON WHEN .F.
				
				oSay:= TSay():New( 145, 10, { || STR0010 }, oPanel2,,,,,,.T.,,, 100, 10 )//'Tipo Dif. Comis.:'
				@ 235,390 MSGET oGet VAR _Tipo     SIZE 100,8 OF oScr1 PIXEL WHEN .F.

				//Panel Rodape
				oSay:= TSay():New( 010, 07, { || STR0029 }, oPanelR,,,,,,.T.,,, 100, 10 )//'Orgão p/ Cedência:'
				@ 270,070 MSGET oGet VAR cOrgao  PICTURE "@!" Valid VD180VALID({10},lAut) SIZE 150,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[10]
				
				oSay:= TSay():New( 025, 07, { || STR0031 }, oPanelR,,,,,,.T.,,, 100, 10 )//'CNPJ do Orgão:'
				@ 285,070 MSGET oGet VAR cCNPJ  PICTURE "@R 99.999.999/9999-99" Valid( CGC(cCNPJ) .AND. VD180VALID({11},lAut)) SIZE 60,8 OF oScr1 PIXEL HASBUTTON WHEN aTabela[11]
				
				oSay:= TSay():New( 010, 312, { || STR0030 }, oPanelR,,,,,,.T.,,, 100, 10 )//'Previsão de Retorno:'
				@ 270,390 MSGET oGet VAR cDTret  PICTURE "@D" Valid VD180VALID({12},lAut) SIZE 50,10 OF oScr1 PIXEL HASBUTTON WHEN aTabela[12]
				
				oSay:= TSay():New( 025, 312, { || STR0032 }, oPanelR,,,,,,.T.,,, 100, 10 )//'Modalidade de Cedência:'
				@ 285,390 MSCOMBOBOX oComb VAR cComb ITEMS aComb SIZE 100,8 OF oScr1 PIXEL WHEN aTabela[13]
			
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lRet:=VD180VALID({17,oDlg},lAut)},bCancel)
			
			IF VALTYPE(_SALARIO) <> "N"
				_SALARIO := VAL(_SALARIO)
			ENDIF

			//Botao Confirma
			If lRet == .T.
				IF VD180HIST()
					//Rotina de Publicação
					VDFA060({'VDFM180',SRA->RA_MAT,SRA->RA_CATFUNC,DtoS(dDataPro),SRA->RA_FILIAL,SRA->RA_CIC,dDataPro,'1','SR7'})
				Endif	 
			Endif   
			
		End Sequence

	// Se foi chamado pela rotina de Automação
	Else

		// Preenche os dados da Transferência:
		IF !Empty(aDadosAut)
			dDataPro	:=	aDadosAut[1][1][2]	//-- Data do processamento
			cCombCM 	:=	aDadosAut[1][2][2]	//-- Tipo de Ação
			cCatfunc	:=	aDadosAut[1][3][2]	//-- Categoria 
			cCateSoc	:=	aDadosAut[1][4][2]	//-- Categoria eSocial
			cTipAum		:=	aDadosAut[1][5][2]	//-- Tipo de aumento
			cCodFunc	:=	aDadosAut[1][6][2]	//-- Função
			cTabNive	:=	aDadosAut[1][7][2]	//-- Nível da Tabela de Subsídios
			cTabFaix	:=	aDadosAut[1][8][2]	//-- Faixa da Tabela de Subsídios
			cCombTP 	:=	aDadosAut[1][9][2]	//-- Tipo de comissionamento
			cOrgao 		:=	aDadosAut[1][10][2]	//-- Orgão de cedência
			cCNPJ 		:=	aDadosAut[1][11][2]	//-- CNPJ do orgão 
			cDTret 		:=	aDadosAut[1][12][2]	//-- Data da cedência
			cComb 		:=	aDadosAut[1][13][2]	//-- Tipo de cedência
			cClass 		:=	aDadosAut[1][15][2]	//-- Classificação do documento de atos/portarias
			cTpdoc 		:=	aDadosAut[1][14][2]	//-- Tipo de Documento de atos/portarias
			lRetro		:=  IIF(EMPTY(aDadosAut[1][16][2]) .OR. aDadosAut[1][16][2] != NIL, .F.,aDadosAut[1][16][2]) 
		ENDIF


		cCatfunc	:= IIF(Empty(cCatfunc)	,SRA->RA_CATFUNC	,cCatfunc)
		cCodFunc	:= IIF(Empty(cCodFunc)	,SRA->RA_CODFUNC	,cCodFunc)
		cCargo  	:= IIF(Empty(cCargo)	,SRA->RA_CARGO		,cCargo)
		cTabela 	:= IIF(Empty(cTabela)	,SRA->RA_TABELA		,cTabela)
		cTabNive 	:= IIF(Empty(cTabNive)	,SRA->RA_TABNIVE	,cTabNive)
		cTabFaix	:= IIF(Empty(cTabFaix)	,SRA->RA_TABFAIX	,cTabFaix)
		nSalario	:= IIF(Empty(nSalario)	,SRA->RA_SALARIO	,nSalario) 
		
		IF lRet:=VD180VALID({17,oDlg}) .And. VD180HIST()
			VDFA060({'VDFM180',SRA->RA_MAT,SRA->RA_CATFUNC,DtoS(dDataPro),SRA->RA_FILIAL,SRA->RA_CIC,dDataPro,'1','SR7',cClass,cTpdoc}, lAut)  
		Endif
	Endif
	
	RestArea( aArea )  
Return NIL


//------------------------------------------------------------------------------
/*/ {Protheus.doc} VD180HABIL
Validacao
@sample 	VD180HABIL()
@param
@return	Nil 
@author	Nivia Ferreira			
@since		04/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180HABIL()

	Local cQuery	:= ''
	Local nPos  	:= 0
	Local aCombAux 	:= {}
	
	If SRA->RA_CATFUNC $ '1,3'	//1=Membro em Comissao, 3=Serv Efetivo em Comissionado
		aTabela:=({.T.,;			//1=Data de processamento
			   		.F.,;			//2=Categoria
		    		.F.,;			//3=Função
			   		.F.,;			//4=Cargo
			        .F.,;			//5=Tabela Salarial
		    		.F.,;			//6=Nivel Salarial
		       		.F.,;			//7=Faixa Salarial
		        	.F.,;			//8=Salario
		        	.F.,; 			//9=Tipo do Aumento
		        	.F.,; 			//10=Orgao p Cedencia
		        	.F.,;    		//11=CNPJ do Orgao
		        	.F.,;    		//12=Previsao de Retorno
		        	.F.,;			//13=Modalidade da Cedencia
		        	.F.,;			//14=Tipo de Subs Comissionado
		        	.T.,;   		//15=Tipo de Comissionado
		        	.F.})   		//16=Categoria eSocial   
	     	
	Else	        		        
		aTabela:=({.T.,;			//1=Data de processamento
			        .T.,;			//2=Categoria
		    		.F.,;			//3=Função
			    	.F.,;			//4=Cargo
			    	.F.,;			//5=Tabela Salarial
		    	 	.T.,;			//6=Nivel Salarial
		      		.T.,;			//7=Faixa Salarial
			    	.F.,;			//8=Salario
			    	.T.,; 			//9=Tipo do Aumento
		    		.F.,; 			//10=Orgao p Cedencia
			     	.F.,;    		//11=CNPJ do Orgao
			     	.F.,;    		//12=Previsao de Retorno
		    	  	.F.,;			//13=Modalidade da Cedencia
		      		.F.,;			//14=Tipo de Subs Comissionado	        
		        	.F.,;   		//15=Tipo de Comissionado
		        	.T.})   		//16=Categoria eSocial   
		
	Endif	      		

	//Quando Membro, libera a alteração do cargo, pois pode ser promoção de Promotor para Procurador	
	If SRA->RA_CATFUNC $ '0'	//0=Membro
		aTabela[3] := .t.
	Endif

	cCatfunc	:= SRA->RA_CATFUNC
	cCodFunc	:= SRA->RA_CODFUNC
	cCargo  	:= SRA->RA_CARGO
	cTabela 	:= SRA->RA_TABELA
	cTabNive 	:= SRA->RA_TABNIVE
	cTabFaix	:= SRA->RA_TABFAIX
	nSalario	:= SRA->RA_SALARIO
	
	RCC->(dbsetorder(1))
	RCC->(dbseek(xFilial("RCC")+"S105"))
	While RCC->(!eof()) .and. RCC->(RCC_FILIAL+RCC_CODIGO) == xFilial("RCC")+"S105"
		if "CEDIDO" $ upper(RCC->RCC_CONTEU)
			aadd(aCombAux,left(RCC->RCC_CONTEU,1)+"="+substr(RCC->RCC_CONTEU,2,len(alltrim(RCC->RCC_CONTEU))))
		EndIf
		RCC->(dbskip())
	EndDo
	aComb := aClone(aCombAux)
		
	If SRA->RA_CATFUNC == '5'
		//Acha ultimo registro com datafim em branco
		cQuery  := "SELECT RID_ORGAO,RID_CNPJ,RID_DTPREV,RID_TIADCD"
		cQuery  += " FROM " + RetSqlName( 'RID' ) + ' RID ' "
		cQuery  += " WHERE RID.D_E_L_E_T_=' ' "
		cQuery  += " AND RID_FILIAL='"+ SRA->RA_FILIAL +"'"
		cQuery  += " AND RID_MAT='"+SRA->RA_MAT  +"'"
		cQuery  += " AND RID_DATFIM=' ' "	
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB_RID", .F., .T.)
		dbSelectArea("TRB_RID")
		If !TRB_RID->(EOF()) 
			cOrgao	:= TRB_RID->RID_ORGAO
			cCNPJ	:= TRB_RID->RID_CNPJ
			cDTret	:= STOD(TRB_RID->RID_DTPREV)
			cTipoCD:= TRB_RID->RID_TIADCD
		EndIf
	
		If (nPos := Ascan(aCombAux,{|X| left(X,1) == TRB_RID->RID_TIADCD})) > 0
			aComb := {aCombAux[nPos]}
		EndIf                                                                       
	
		TRB_RID->( dbCloseArea() )
	Endif
	
	
	//Posiciona na SQ3
	dbSelectArea("SQ3")
	dbSetOrder(1)
	dbSeek(FwxFilial("SQ3")+cCARGO)
	
	//Posiciona na RB6
	dbSelectArea("RB6")
	dbSetOrder(1)
	dbSeek(FwxFilial("RB6")+cTABELA+cTABNIVE+cTABFAIX)
	
Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD180VALID
Validacao
@sample 	VD180VALID(aTab)
@param		aParametro[1] Tipo da campo			
			aParametro[2] Campo.
@return		Nil 
@author		Nivia Ferreira			
@since		04/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180VALID(aTab, lAut)
	Local lRet 		:= .T.
	Local nX    	:= 0
	Local aPerAb   	:= {}
	Local aPerFech 	:= {}                                                      
	Local aPerTodos	:= {}
	
	Default lAut    := .F.
	
	//If aTab[1] == 1 .OR. aTab[1] == 16 //Data para processar
	If aTab[1] == 17 //Na confirmacao
	 
	   If	Empty(dDataPro)
	   		//MsgInfo( STR0033 )//'Data não informada'
	   		ShowError(STR0033, lAut, STR0071,)
			Return(.F.)
		Else	
			//-aAdd(aPerAberto, RCH->({ 1-RCH_PER, 2-RCH_NUMPAG, 3-RCH_MES, 4-RCH_ANO, 5-RCH_DTINI, 6-RCH_DTFIM, 7-RCH_PROCES, 8-RCH_ROTEIR, 9-RCH_DTPAGO, 10-RCH_DTCORT}))
			fRetPerComp(Strzero(month(dDataPro),2) , Alltrim(Str(year(dDataPro))) , ,SRA->RA_PROCES ,fGetRotOrdinar(), @aPerAb , @aPerFech , @aPerTodos )
			If  Len(aPerAb) == 0 .And. Len(aPerFech) == 0  
		       	//MsgInfo(STR0068 +' '+DtoC(dDataPro)) //'Não existe Período de Pagamento criado para operação na data informada'
		       	ShowError(STR0068 +' '+DtoC(dDataPro), lAut, STR0071,)
				Return(.F.)
				
			ElseIf Len(aPerAb) > 0
				For nX:= 1 to Len(aPerAb)
					If !fVldAccess( SRA->RA_FILIAL, dDataPro, , .T.,fGetRotOrdinar() , , )
			   	      Return(.F.)
					Endif
				Next
			Else
				If Len(aPerFech) > 0 
					For nX:= 1 to Len(aPerFech)
						If dDataPro >= aPerFech[nX][5] .And. dDataPro <= aPerFech[nX][6]
						   	   If (!lRetro .And. IsBlind()) .Or. (!IsBlind() .And. !MsgYesNo(STR0069)) //"Período ja foi fechado. Confirma o processamento retroativo?"
						   	      Return(.F.)
							   Else
							   	  exit	
					   		   Endif
						Endif
					Next
				Endif
			Endif
		Endif	
		
		If (SRA->RA_CATFUNC $ '1,3') 
		   aTabela[15]:= .T.
		   	If Empty(cCombCM) 
				//MsgInfo(STR0070,STR0071) //"Informe a Ação s/Efetivo ou Comissionamento."  // "Atenção"
				ShowError(STR0070, lAut, STR0071,)
			Endif
		Endif
	Endif
	
	If (aTab[1] == 2 .OR. aTab[1] == 17) .And. lRet==.T.//Categoria
	
	   If Empty(Posicione('SX5',1,FwxFilial('SX5')+'28'+cCATFUNC,'X5_Descri'))
	   		//MsgInfo( STR0034 )//'Categoria Inválida'
	   		ShowError(STR0034, lAut, STR0071,)
			lRet := .F.
		ElseIf	(SRA->RA_CATFUNC == '0' .And. !cCatfunc $ '0,1')  .OR. ;//0=Membro 1=Membro em Comissao
				(SRA->RA_CATFUNC == '1' .And. !cCatfunc $ '1,0')  .OR. ;//1=Membro em Comissao	0=Membro
				(SRA->RA_CATFUNC == '2' .And. !cCatfunc $ '2;3;5').OR. ;//2=Serv Efeitovo 3=Serv. Comissionado 5=Serv Cedido
		   		(SRA->RA_CATFUNC == '3' .And. !cCatfunc $ '2;3')  .OR. ;//3=Serv Efetivo  2=Servidor Efetivo
		   		(SRA->RA_CATFUNC == '5' .And. !cCatfunc $ '2;5')      	//5=Serv Cedido   2=Servidor Efetivo	   
				//MsgInfo( STR0035 )	//'Categoria Inválida.'
				ShowError(STR0035, lAut, STR0071,)
				lRet := .F.
		Endif
		
		If SRA->RA_CATFUNC == '2' .And. cCatfunc=='5' //2=Servidor Efetivo 5=Servidor Cedido  
	   		aTabela[10] := .T.
	   		aTabela[11] := .T.
	   		aTabela[12] := .T.
	   		aTabela[13] := .T.   
	   	ElseIf SRA->RA_CATFUNC == '2' .And. cCatfunc !='5' //2=Servidor Efetivo 5=Servidor Cedido  
	   		aTabela[10] := .F.
	   		aTabela[11] := .F.
	   		aTabela[12] := .F.
	   		aTabela[13] := .F.
		Endif
		If SRA->RA_CATFUNC == '2' .And. cCatfunc=='2' //2=Servidor Efetivo 5=Servidor Cedido  
	   		aTabela[9]:= .T.  //TIPO DE AUMENTO
			aTabela[8]:= .F. 
			aTabela[3]:= .F.
 			aTabela[6]:= .T.  //NIVEL
			aTabela[7]:= .T.  //FAIXA
	   	EndIf
		If SRA->RA_CATFUNC $ '0,2' .And. cCatfunc $'1,3' //0=Membro 2=Servidor Efetivo 1=Membro em Comissao 3=Efetivo em Comissao  
	   		aTabela[14] := .T.
	   	ElseIf aTab[1] <> 17
	   		aTabela[14] := .F.
		Endif
		
		If SRA->RA_CATFUNC $ '0,2' .And. cCatfunc $'1,3' //0=Membro 2=Servidor Efetivo 1=Membro em Comissao 3=Efetivo em Comissao  
	   		aTabela[03] := .T.
		Endif
	
		If SRA->RA_CATFUNC $ '1,3' .And. cCatfunc $'0,2' .and. cCombCM == '2' //Se Em Comissiao retornando para Efetivo
	   		//aTabela[03] 	:= .T.
			cCODF_Ant  		:= cCODFUNC
			cCargo_Ant		:= cCargo
	   		cCODFUNC    	:= Substring(_CodFunc,1,6)
	   		cCargo      	:= Substring(_Cargo,1,6)
	
			cTAB_Ant		:= cTABELA
			cTABN_Ant		:= cTABNIVE
			cTABF_Ant		:= cTABFAIX
			nSAL_Ant   		:= nSalario
			cTABELA			:= _Tabela
			cTABNIVE		:= _TabNive
			cTABFAIX		:= _TabFaix
			nSalario		:= _Salario 
		Endif
	
		If cCatfunc $'1,3' .And. !Empty(cCODF_Ant) .And. !Empty(cCargo_Ant) //1=Membro em Comissao 3=Efetivo em Comissao  
	   		cCODFUNC    	:= cCODF_Ant
	   		cCargo      	:= cCargo_Ant
			cTABELA			:= cTAB_Ant
			cTABNIVE		:= cTABN_Ant
			cTABFAIX		:= cTABF_Ant
			nSalario		:= nSAL_Ant
	   		cCODF_Ant    	:= ''
	   		cCargo_Ant   	:= ''
			cTAB_Ant		:= 0
			cTABN_Ant		:= 0
			cTABF_Ant		:= 0
			nSAL_Ant		:= 0
		Endif
	Endif
	
	If aTab[1] == 3  .And. lRet == .T. //Função
	
		If Empty(POSICIONE("SRJ",1,FwxFilial("SRJ")+cCODFUNC,"RJ_DESC"))
	   		//MsgInfo( STR0037 )//'Função Inválida.'
	   		ShowError(STR0037, lAut, STR0071,)
			lRet := .F.
		Else
		   	cCARGO := POSICIONE("SRJ",1,FwxFilial("SRJ")+cCODFUNC,"RJ_CARGO")
			dbSelectArea("SQ3")
			dbSetOrder(1)
			If dbSeek(FwxFilial("SQ3")+cCARGO)
		 		cTABELA  := SQ3->Q3_TABELA	
    			cTABNIVE := SQ3->Q3_TABNIVE
    			cTABFAIX := SQ3->Q3_TABFAIX
         		nSalario :=	TabSalIni(cTabela,dDataPro,.F.,cTABNIVE,cTABFAIX)
			Endif		    
		Endif
	Endif
	
	If aTab[1] == 4  .And. lRet == .T. //Cargo
		If Empty(cCargo)
	   		//MsgInfo( STR0072 ) //'Cargo Inválido.'
	   		ShowError(STR0072, lAut, STR0071,)
			lRet := .F.
		Endif
	Endif
	
	If (aTab[1] == 5 .OR. aTab[1] == 17) .And. lRet == .T. //Tabela Salarial
	   If Empty(cTABELA)
			//MsgInfo( STR0038 )//'Tabela de Subsídio não Informada.'
			ShowError(STR0038, lAut, STR0071,)
			lRet := .F.
	   Endif
	Endif   
	
	If (aTab[1] == 6 .OR. aTab[1] == 17) .And. lRet==.T. //Nivel Salarial
		If 	Empty(cTABNIVE)
			//MsgInfo( STR0039 )//'Nivel da Tabela não Informado.'
			ShowError(STR0039, lAut, STR0071,)
			lRet := .F.
	   	Endif
	Endif   
	
	If (aTab[1] == 7 .OR. aTab[1] == 17) .And. lRet==.T. //Faixa Salarial
		If 	Empty(cTABFAIX)
			//MsgInfo( STR0073 )//'Nivel da Faixa não Informado.'
			ShowError(STR0073, lAut, STR0071,)
			lRet := .F.
	   	Endif	
		nSalario:= TabSalIni(cTabela,dDataPro,.F.,cTABNIVE,cTABFAIX)
		If 	nSalario == 0
			//MsgInfo( STR0074 )//'Tabela de Subsídio não encontrada.'
			ShowError(STR0074, lAut, STR0071,)
			If aTab[1] == 17
			   lRet := .F.
			Endif   
		Endif
	Endif   
	
	If (aTab[1] == 9 .OR. aTab[1] == 17) .And. lRet == .T. //Tipo do Aumento
	   If Empty(cTipAum) .or. empty(Posicione('SX5',1,FwxFilial('SX5')+'41'+cTipAum,'X5_Descri'))
			//MsgInfo( STR0040 )//'Tipo de Ação/Aumento não Informado.'
			ShowError(STR0040, lAut, STR0071,)
			lRet := .F.
	   Endif
	Endif   
	
	If (aTab[1] == 10 .OR. aTab[1] == 17) .And. lRet == .T. .And. aTabela[10] == .T. //Orgão p/ Cedência
	   If Empty(cOrgao)
			//MsgInfo( STR0041 )//'Orgão para Cedência não Informado.'
			ShowError(STR0041, lAut, STR0071,)
			lRet := .F.
	   Endif                          
	Endif   
	
	If (aTab[1] == 11.OR. aTab[1] == 17) .And. lRet == .T. .And. aTabela[11] == .T. //CNPJ do Orgão
	   If Empty(cCnpj)
			//MsgInfo( STR0043 )//'CNPJ não Informado.'
			ShowError(STR0043, lAut, STR0071,)
			lRet := .F.
	   Endif
	Endif   
	
	If (aTab[1] == 12 .OR. aTab[1] == 17) .And. lRet == .T. .And. aTabela[12] == .T. //Previsão de Retorno
	   If Empty(cDTret)
			//MsgInfo( STR0042 )//'Data de Previsão de Retorno não Informado.'
			ShowError(STR0042, lAut, STR0071,)
			lRet := .F.
	   Endif
	Endif   
	
	If (aTab[1] == 13 .OR. aTab[1] == 17) .And. lRet == .T. .And. aTabela[13] == .T. //Modalidade de Cedência
	   If Empty(cComb)
			//MsgInfo( STR0044 )//'Modalidade de Cedência não Informado.'
			ShowError(STR0044, lAut, STR0071,)
			lRet := .F.
	   Endif
	Endif   
	
	If (aTab[1] == 14 .OR. aTab[1] == 17) .And. lRet == .T. .And. aTabela[14] == .T. //Tipo da Diferença de Comissionamento
	   If Empty(cCombTP)
			//MsgInfo( STR0045 )//'Tipo da Diferença de Comissionamento não Informado.'
			ShowError(STR0045, lAut, STR0071,)
			lRet := .F.
	   Endif
	Endif   
	
	If lRet .and. (aTab[1] == 15 .Or. Isblind() ) .And. aTabela[15]== .T.  //Tipo do Comissionamento
	   	If Empty(cCombCM) 
			//MsgInfo(STR0070,STR0071) //"Informe o Tipo de Diferença de Comissionamento" // "Atenção"
			ShowError(STR0070, lAut, STR0071,)
			lRet := .F.
		Else
			VD180STANT() //Monta tela com ultimo
	   Endif
	Endif   
    // Categoria eSocial
	If (aTab[1] == 16 .OR. aTab[1] == 17) .And. lRet == .T. .And. aTabela[16] == .T. 
	   If (SRA->RA_CATFUNC  <> cCatfunc) .And. Empty(cCateSoc)
			//MsgInfo( STR0079 )//'Categoria foi modificada e Categoria do eSocial não Informada.'
			ShowError(STR0079, lAut, STR0071,)
			lRet := .T.
	   Endif
	Endif   


	If lRet .and. aTab[1] == 1 //DATA PARA PROCESSAR AS ALTERAÇÕES
		//Nao permite com data anterior a admissao

		If	Empty(dDataPro)
	   		//MsgInfo( STR0033 )//'Data não informada'
			ShowError(STR0033, lAut, STR0071,)
			Return(.F.)
		ElseIf dDataPro < SRA->RA_ADMISSA
			//MsgInfo( STR0077 )//"A data para alteração não pode ser anterior ?data de admissão."
			ShowError(STR0077, lAut, STR0071,)
			lRet := .F.
			//COMISSIONADO PURO NÃO PODE TROCAR DE CATEGORIA, MAS PODE PERMITIR ALTERAR A FUNÇÃO E TIPO DE AUMENTO
		ElseIf (SRA->RA_CATFUNC $ '6') 
			aTabela[2]:= .F.  //CATEGORIA
			aTabela[9]:= .F.  //TIPO DE AUMENTO
			   
			//SISTEMA IR?SUGERIR AUTOMATICAMENTE O TIPO DE AUMENTO 
			If UltAltSal("('NOM','EXO')") == "EXO" //Se encontrou a ultima acao como EXO, entao houve exoneracao (sem rescisao)
				cTipAum := "NOM"  //Permite apenas NOM-Nomeacao 
				aTabela[3]:= .T.  //Libera a FUNÇÃO para a nova nomeacao
				aTabela[6]:= .T.  //NIVEL
				aTabela[7]:= .T.  //FAIXA
			Else
				cTipAum := "EXO"  //Permite apenas EXO-Exoneracao (sem rescisao)
				aTabela[3]:= .F.  //FUNÇÃO
				aTabela[6]:= .F.  //NIVEL
				aTabela[7]:= .F.  //FAIXA
			EndIf
		EndIf
	EndIf

	//TRATAMENTO ESPECIFICO PARA O CASO DE COMISSIONAMENTO DE 2 PARA 3 OU VICE-E-VERSA
	If lRet .and. (SRA->RA_CATFUNC == "2" .AND. cCATFUNC == "3")
		aTabela[9]:= .F.  //TIPO DE AUMENTO
		cTipAum := "NOM"  //Nomeacao
		aTabela[6]:= .F.  //NIVEL
		aTabela[7]:= .F.  //FAIXA
	ElseIf lRet .and. (SRA->RA_CATFUNC == "3" .AND. cCATFUNC == "2") .AND. !(SRA->RA_CATFUNC == "3" .AND. cCombCM == "1")
		aTabela[9]:= .F.  //TIPO DE AUMENTO
		cTipAum := "EXO"  //Exoneracao
		aTabela[6]:= .F.  //NIVEL
		aTabela[7]:= .F.  //FAIXA
	EndIf
	
	If lRet == .T. .And. aTab[1] == 17 .And. !IsBlind()
		aTab[2]:End()
	Endif
	
Return(lRet)



//------------------------------------------------------------------------------
/*/ {Protheus.doc} VD180HIST
Validacao
@sample 	VD180HIST()
@param		aParametro[1]	
			aParametro[2]
@return		Nil 
@author		Nivia Ferreira			
@since		07/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180HIST()
	
	Local aArea		:= GetArea()
	Local lRet       	:= .T.
	
	Private _ECAFUNC 	:= ''  
	Private _EFUNCAO 	:= '' 
	Private _EDESCFU 	:= '' 
	Private _ECARGO 	:= '' 
	Private _EDESCCA 	:= ''  
	Private _cAdiCed    := ""
	
	Begin Transaction
		//=========================================
		//Ponto de Entrada de alteração salarial, |
		//comissão e dentre outros dados	 	 |
		//=========================================
		If ExistBlock("VDF180SAL")
			ExecBlock("VDF180SAL",.F.,.F.)
		EndIf
		
		//Grava SR3/SR7
		fGravaSr3(GetMemVar( "RA_ADMISSA" ),GetMemVar("RA_TIPOALT"),GetMemVar("RA_SALARIO"),, 3) 
		
		If 	!(cCATFUNC $ '1,3') .And. !(SRA->RA_CATFUNC $ '1,3') //Nao envolve comissionamento
			
			If SRA->RA_CATFUNC == '2' .And. cCatfunc=='5'		//2=Servidor Efetivo para 5=Cedido
				VD180RID('I')  									//Grava as tabelas SR8/RID
				_cAdiCed := cComb
			Endif
			
			If SRA->RA_CATFUNC == '5' .And. cCatfunc=='2'		//5=Cedido para 2=Servidor Efetivo 
	   			VD180RID('A')    												//Altera as tabelas SR8/RID
				_cAdiCed := " "
			Endif
			
			//Grava tabela SR7/SR3
			VD180GRVSR({cCatfunc, cCodFunc, cCargo, cCatfunc, cCodFunc, cCargo}, {nSalario, nSalario, cTabela, cTabNive, cTabFaix, 0,"", "","",,})	
			
			//Calculo Retroativo
			VD180RCALC()
			
			//Grava tabela SRA	
		    //RA_CATFUNC,RA_CODFUNC,RA_CARGO,RA_TABELA,RA_TABNIVE,RA_TABFAIX,RA_SUBCARR,RA_SALARIO,RA_ANTEAUM,RA_TPSBCOM,RA_ADICEDI, RA_CATEFD
			VD180GVSRA({cCatfunc, cCodFunc, cCargo, cTabela, cTabNive, cTabFaix, nSalario, nSalario, nSalario, , _cAdiCed, cCateSoc})		
			
		ElseIf cCATFUNC $ '1,3' .And. SRA->RA_CATFUNC $ '0,2' //Alteração do Servidor EFETIVO para EFETIVO EM COMISSÃO, ou Membro para Membro EM COMISSÃO 
			//Grava tabela SR7/SR3
			//			 R7_CATFUNC,      R7_FUNCAO,      R7_CARGO,      R7_ECAFUNC,     R7_EFUNCAO,    R7_ECARGO,
			//			 R3_VALOR,        R3_ANTEAUM,     R3_TABELA,     R3_TABNIVE,     R3_TABFAIX,    R3_CSALAR,
			//          R3_CTABELA,  	 R3_CTABNIV,     R3_CTABFAI,    R3_PERCCOM,     R3_TPSBCOM
			VD180GRVSR({cCatfunc,       cCodFunc,       cCargo,        SRA->RA_CATFUNC,SRA->RA_CODFUNC,SRA->RA_CARGO},;
						{SRA->RA_SALARIO,SRA->RA_SALARIO,SRA->RA_TABELA,SRA->RA_TABNIVE,SRA->RA_TABFAIX,nSalario,;
						cTabela,        cTabNive,       cTabFaix,      IIF(substr(cCombTP,1,1)=='2',nDifComs,0),substr(cCombTP,1,1)})
			
			//Calculo Retroativo
			VD180RCALC()
			
			//Grava tabela SRA
		    //RA_CATFUNC,RA_CODFUNC,RA_CARGO,RA_TABELA,RA_TABNIVE,RA_TABFAIX,RA_SUBCARR,RA_SALARIO,RA_ANTEAUM,RA_TPSBCOM,RA_ADICEDI,RA_CATEFD
			VD180GVSRA({cCatfunc,cCodFunc,cCargo,cTabela,cTabNive,cTabFaix,SRA->RA_SALARIO,nSalario,nSalario,substr(cCombTP,1,1),,cCateSoc})	
			
		ElseIf	cCATFUNC $ '0,2' .And.  SRA->RA_CATFUNC $ '1,3'	.And. aTabela[02] == .T.//Quando do RETORNO do Membro ou Servidor em Comissão para Efetivo
			
			//Grava tabela SR7/SR3
			VD180GRVSR({cCatfunc, cCodFunc, cCargo, cCatfunc, cCodFunc, cCargo}, {nSalario, nSalario, cTabela, cTabNive, cTabFaix, nSalario,;
						cTabela, cTabNive, cTabFaix, Iif(substr(cCombTP, 1, 1) == '2', nDifComs, 0), substr(cCombTP, 1, 1)})	
			
			//Calculo Retroativo
			VD180RCALC()
			
			//Grava tabela SRA
		    //          RA_CATFUNC,RA_CODFUNC,RA_CARGO,RA_TABELA,RA_TABNIVE,RA_TABFAIX,RA_SUBCARR, RA_SALARIO,RA_ANTEAUM, RA_TPSBCOM,RA_ADICEDI,RA_CATEFD
			VD180GVSRA({cCatfunc, cCodFunc, cCargo, cTabela, cTabNive, cTabFaix, nSalario, nSalario, nSalario, "", , cCateSoc})
			
		ElseIf SRA->RA_CATFUNC $ '1,3' .And. cCatfunc $ '1,3,0,2' //1=Membro Comiss 3=Serv Efet Comissao
		                                                          //Se acontecer alguma alteração do Membro EM COMISSÃO, 
		                                                          //ou do Serv Efetivo EM COMISSÃO, sem alt de catfunc 
			//Grava tabela SR7/SR3
		 	If Substring(cCombCM,1,1) == '2' //1=Efetivo  2=Comissionado
		 		          //R7_CATFUNC,R7_FUNCAO ,      R7_CARGO , R7_ECAFUNC, R7_EFUNCAO, R7_ECARGO,
		 		          //R3_VALOR  ,R3_ANTEAUM,      R3_TABELA, R3_TABNIVE, R3_TABFAIX, R3_CSALAR,
		 		          //R3_CTABELA,R3_CTABNIV,      R3_CTABFAI,R3_PERCCOM, R3_TPSBCOM
				VD180GRVSR({cCatfunc,  cCodFunc,        cCargo,    _CATFUNC,   _CODFUNC,   _CARGO,,,,},;
							{_Salario,  _Salario , _TABELA,   _TABNIVE,   _TABFAIX,   nSalario,;
							cTabela,   cTabNive,         cTabFaix,  IIF(substr(cCombTP,1,1)=='2',nDifComs,0)  ,substr(cCombTP,1,1)})
							
							//Calculo Retroativo
							VD180RCALC()
							
				          //Grava tabela SRA
				          //RA_CATFUNC,RA_CODFUNC,RA_CARGO,RA_TABELA,RA_TABNIVE,RA_TABFAIX,RA_SUBCARR,      RA_SALARIO,RA_ANTEAUM,     RA_TPSBCOM,RA_ADICEDI,RA_CATEFD
				VD180GVSRA({cCatfunc,  cCodFunc,  cCargo,  cTabela,  cTabNive,  cTabFaix,  SRA->RA_SUBCARR, nSalario,  nSalario    ,substr(cCombTP,1,1), ,cCateSoc})
			Else
				
				         //          R7_CATFUNC              R7_FUNCAO              R7_CARGO    R7_ECAFUNC  R7_EFUNCAO R7_ECARGO
	                     //R3_VALOR  R3_ANTEAUM R3_TABELA R3_TABNIVE R3_TABFAIX R3_CSALAR R3_CTABELA R3_CTABNIV R3_CTABFAI R3_PERCCOM R3_TPSBCOM	
				VD180GRVSR({Substring(cCatfunc,1,1),Substring(CCODFUNC,1,5),Substring(CCARGO,1,5),cCatfunc,  cCodFunc,  cCargo,,,,},; 				
							{nSalario, nSalario,  cTabela,  cTabNive,  cTabFaix,  _SALARIO, _TABELA,   _TABNIVE,  _TABFAIX,  _Tipoc,    SRA->RA_TPSBCOM})			
				
				//Calculo Retroativo
				VD180RCALC()
				
				          //Grava tabela SRA
				          //RA_CATFUNC,     RA_CODFUNC,     RA_CARGO,        RA_TABELA,     RA_TABNIVE,     RA_TABFAIX,
				          //RA_SUBCARR,     RA_SALARIO,     RA_ANTEAUM,      RA_TPSBCOM,    RA_ADICEDI, RA_CATEFD    
				VD180GVSRA({SRA->RA_CATFUNC,cCodFunc,cCargo,   cTabela,cTabNive,cTabFaix,;
							nSalario,        nSalario,SRA->RA_ANTEAUM,substr(cCombTP,1,1),SRA->RA_ADICEDI, cCateSoc })
			Endif       	     
		Endif
		
	End Transaction
	
	RestArea( aArea )
	
Return( lRet )


//------------------------------------------------------------------------------
/*/{Protheus.doc} VD180GVSRA
Validacao
@sample 	VD180GVSRA()
@param		aCampos			
@return	Nil 
@author	Nivia Ferreira			
@since		08/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180GVSRA(aCAMPOS)
   	dbSelectArea("SRA")
	RecLock("SRA",.F.)
		SRA->RA_CATFUNC		:= aCampos[01]
		SRA->RA_CODFUNC 	:= aCampos[02]	
		SRA->RA_CARGO    	:= aCampos[03]
		SRA->RA_TABELA   	:= aCampos[04]
		SRA->RA_TABNIVE  	:= aCampos[05]
		SRA->RA_TABFAIX  	:= aCampos[06]
		SRA->RA_SUBCARR  	:= aCampos[07]
		SRA->RA_SALARIO  	:= aCampos[08]	
		SRA->RA_ANTEAUM  	:= aCampos[09]	
		SRA->RA_TPSBCOM  	:= aCampos[10]
		SRA->RA_ADICEDI 	:= aCampos[11]
        If !Empty(aCampos[12])
			SRA->RA_CATEFD 		:= aCampos[12]
		Endif		
	MsUnLock()
Return( NIL )


//------------------------------------------------------------------------------
/*{Protheus.doc} VD180STANT
Validacao
@sample 	VD180STANT()
@param					
@return	Nil 
@author	Nivia Ferreira			
@since		08/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180STANT()

	Local cQuery 		:= ''
	
	_Catfunc	:= ''
	_CodFunc	:= ''
	_Cargo  	:= ''
	_Tabela 	:= ''
	_TabNive 	:= ''
	_TabFaix	:= ''
	_Salario	:= ''
	_Orgao		:= ''
	_CNPJ		:= ''
	_DTret		:= '' 
	_Tipo   	:= ''
	_Tipoc  	:= 0 //''
	_TipoAlt	:= ''
	_TipoCD   	:= ''
	
	
	cQuery  := "SELECT R7_ECAFUNC,R7_EFUNCAO,R7_EDESCFU,R7_ECARGO,R7_EDESCCA,R7_DATA,"
	cQuery  += " R3_TABELA,R3_TABNIVE,R3_TABFAIX,R3_VALOR,R7_TIPO,R3_PERCCOM, "
	cQuery  += " R7_CATFUNC,R7_FUNCAO,R7_DESCFUN,R7_CARGO,R7_DESCCAR,"
	cQuery  += " R3_CTABELA,R3_CTABNIV,R3_CTABFAI,R3_CSALAR,R3_TIPO,
	cQuery  += " CASE WHEN R3_PERCCOM=0 THEN '1=Diferença Subsídio entre cargos'"
	cQuery  += " ELSE '2=% s/ Subsidio do Comissionado' END AS PERCCON,R7_TIPO, "
	cQuery  += " RID_ORGAO,RID_CNPJ,RID_TIADCD,RID_DTPREV,"
	cQuery  += " CASE WHEN RID_TIADCD='1' THEN '1=Com ônus e com repasse'"
	cQuery  += "      WHEN RID_TIADCD='2' THEN '2=Com ônus e sem repasse'"
	cQuery  += "      WHEN RID_TIADCD='3' THEN '3=Sem ônus'"
	cQuery  += " ELSE ' ' END AS TIPO "
	cQuery  += " FROM " + RetSqlName( 'SR7' ) + ' SR7, ' + RetSqlName( 'SR3' ) + " SR3 "
	cQuery  += " LEFT JOIN "+ RetSqlName("RID")+" RID ON RID.D_E_L_E_T_=' ' AND RID_FILIAL='"+ FwxFilial('SR7') + "' AND RID_MAT =R3_MAT"
	cQuery  += " WHERE SR7.D_E_L_E_T_=' ' AND SR3.D_E_L_E_T_=' ' "
	cQuery  += " AND R7_FILIAL='"+ SRA->RA_FILIAL +"'"
	cQuery  += " AND R7_MAT='"+ SRA->RA_MAT +"'"
	
	If !Empty(dDataPro)
		cQuery  += " AND R7_DATA<='"+ DTOS(dDataPro) +"'"
	Endif
	
	cQuery  += " AND R7_FILIAL=R3_FILIAL"
	cQuery  += " AND R7_MAT=R3_MAT "
	cQuery  += " AND R7_SEQ=R3_SEQ "
	cQuery  += " AND R7_DATA=R3_DATA "	
	cQuery  += " ORDER BY R7_DATA DESC"
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
	dbSelectArea("TRB")
		
	aTabela:=({.T.,;			//1=Data de processamento
		       .T.,;			//2=Categoria
	    		.F.,;			//3=Função
		    	.F.,;			//4=Cargo
		    	.F.,;			//5=Tabela Salarial
	    	 	.T.,;			//6=Nivel Salarial
	      		.T.,;			//7=Faixa Salarial
		    	.F.,;			//8=Salario
		    	.T.,; 			//9=Tipo do Aumento
	    		.F.,; 			//10=Orgao p Cedencia
		     	.F.,;    		//11=CNPJ do Orgao
		     	.F.,;    		//12=Previsao de Retorno
	    	  	.F.,;			//13=Modalidade da Cedencia
	      		.F.,;			//14=Tipo de Subs Comissionado	        
	      		.T.,;			//15=Tipo de Comissionado
	        	.T.})   		//16=Categoria eSocial   

	
	If !TRB->(EOF()) .And. !Empty(TRB->R7_ECAFUNC)
			
		If Substring(cCombCM,1,1) == '1' //1=Efetivo  
			cCatfunc	:= TRB->R7_ECAFUNC
			cCodFunc	:= TRB->R7_EFUNCAO
			cCargo  	:= TRB->R7_ECARGO
			cTabela 	:= TRB->R3_TABELA
			cTabNive 	:= TRB->R3_TABNIVE
			cTabFaix	:= TRB->R3_TABFAIX
			nSalario	:= TRB->R3_VALOR
			cTipAum   	:= TRB->R7_TIPO
			_Catfunc	:= TRB->R7_CATFUNC + ' - ' + Alltrim(Posicione('SX5',1,FwxFilial('SX5')+'28'+TRB->R7_CATFUNC,'X5_Descri'))
			_CodFunc	:= TRB->R7_FUNCAO  + ' - ' + TRB->R7_DESCFUN
			_Cargo		:= TRB->R7_CARGO   + ' - ' + TRB->R7_DESCCAR 
			_Tabela	:= TRB->R3_CTABELA
			_TabNive	:= TRB->R3_CTABNIV
			_TabFaix	:= TRB->R3_CTABFAI
			_Salario	:= TRB->R3_CSALAR
			_TipoAlt	:= TRB->R3_TIPO    + ' - ' + Alltrim(Posicione('SX5',1,FwxFilial('SX5')+'41'+TRB->R3_TIPO,'X5_Descri'))
			_Tipo     	:= TRB->PERCCON
			_Tipoc    	:= TRB->R3_PERCCOM			
	
			VD180COMB('RA_TPSBCOM',SRA->RA_TPSBCOM,.F.)
			aTabela[02]:= .F.
		Else 									//2=Comissionado
			cCatfunc	:= TRB->R7_CATFUNC
			cCodFunc	:= TRB->R7_FUNCAO
			cCargo  	:= TRB->R7_CARGO
			cTabela 	:= TRB->R3_CTABELA
			cTabNive 	:= TRB->R3_CTABNIV
			cTabFaix	:= TRB->R3_CTABFAI
			nSalario	:= TRB->R3_CSALAR
			cTipAum   	:= TRB->R7_TIPO
			_Catfunc	:= TRB->R7_ECAFUNC + ' - ' + Alltrim(Posicione('SX5',1,FwxFilial('SX5')+'28'+TRB->R7_ECAFUNC,'X5_Descri'))
			_CodFunc	:= TRB->R7_EFUNCAO  + ' - ' + TRB->R7_EDESCFU
			_Cargo		:= TRB->R7_ECARGO   + ' - ' + TRB->R7_EDESCCA 
			_Tabela	:= TRB->R3_TABELA
			_TabNive	:= TRB->R3_TABNIVE
			_TabFaix	:= TRB->R3_TABFAIX
			_Salario	:= TRB->R3_VALOR
			_TipoAlt	:= TRB->R3_TIPO    + ' - ' + Alltrim(Posicione('SX5',1,FwxFilial('SX5')+'41'+TRB->R3_TIPO,'X5_Descri'))
			_Tipoc    	:= TRB->R3_PERCCOM			
	
			VD180COMB('RA_TPSBCOM',SRA->RA_TPSBCOM,.T.)
			aTabela[14] := .T.
		   	aTabela[15] := .T.			
		Endif	
	Else
		cCatfunc	:= SRA->RA_CATFUNC
		cCodFunc	:= SRA->RA_CODFUNC
		cCargo  	:= SRA->RA_CARGO
		cTabela 	:= SRA->RA_TABELA
		cTabNive 	:= SRA->RA_TABNIVE
		cTabFaix	:= SRA->RA_TABFAIX
		nSalario	:= SRA->RA_SALARIO
		cCombTP   	:= SRA->RA_TPSBCOM
		VD180COMB('RA_TPSBCOM',SRA->RA_TPSBCOM,aTabela[15])	
	Endif
	
	TRB->( dbCloseArea() )
Return()


//------------------------------------------------------------------------------
/*{Protheus.doc} VD180Seq
Validacao
@sample 	VD180Seq()
@param					
@return	Sequencia 
@author	Nivia Ferreira			
@since		10/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180Seq()
	Local cQuery 	:= ''
	Local cSeq    := ''
	
	cQuery  := "SELECT MAX(R7_SEQ) SEQ "
	cQuery  += " FROM " + RetSqlName( 'SR7' ) 
	cQuery  += " WHERE D_E_L_E_T_ =' '
	cQuery  += " AND R7_FILIAL='" +SRA->RA_FILIAL +"'"
	cQuery  += " AND R7_MAT='"+ SRA->RA_MAT +"'"
	cQuery  += " AND R7_DATA='"+ dtos(dDataPro) +"'" 
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
	dbSelectArea("TRB")
	cSeq := soma1(TRB->SEQ)
	TRB->( dbCloseArea() )
Return(cSeq)


//------------------------------------------------------------------------------
/*{Protheus.doc} VD180RID
Grava as tabelas SR8/RID
@sample 	VD180RID(cTipo)
@param		I - inclusao			
			A - alteracao			
@return	 
@author	Nivia Ferreira			
@since		05/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180RID(cTipo)
	Local cQuery 	:= ''
	
	If	cTipo == 'I' 	//Inclusao 
	
		dbSelectArea("RID") 
		dbSetOrder(1)	
		IF dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+Dtos(dDataPro))
			lLock := RecLock("RID",.F.,.T.)
		Else
			lLock := RecLock("RID",.T.,.T.)
		Endif
			
		IF ( lLock )
			RID->RID_FILIAL	:= SRA->RA_FILIAL
			RID->RID_MAT		:= SRA->RA_MAT
			RID->RID_CODFUN	:= cCodFunc
			RID->RID_DATINI	:= dDataPro
			RID->RID_ORGAO	:= cOrgao
			RID->RID_CNPJ		:= cCNPJ
			RID->RID_TIADCD	:= Subs(cComb,1,1)
			RID->RID_CATORI	:= SRA->RA_CATFUNC
			RID->RID_DTPREV	:= cDTret
			If RID->(ColumnPos("RID_CTESOR")) > 0 
				RID->RID_CTESOR	:= SRA->RA_CATEFD
			Endif	
		EndIf
		
		RID->( MsUnLock() )
		RID->( FKCOMMIT() )
	
	Else
	
	 	//Acha ultimo registro com datafim em branco
		cQuery  := "SELECT R_E_C_N_O_ AS RECNO"
		cQuery  += " FROM " + RetSqlName( 'RID' ) + ' RID ' "
		cQuery  += " WHERE RID.D_E_L_E_T_=' ' "
		cQuery  += " AND RID_FILIAL='"+ SRA->RA_FILIAL +"'"
		cQuery  += " AND RID_MAT='"+SRA->RA_MAT  +"'"
		cQuery  += " AND RID_DATFIM=' ' "	
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB_RID", .F., .T.)
		dbSelectArea("TRB_RID")
		If !TRB_RID->(EOF()) 
			dbSelectArea("RID")
			dbGoTo(TRB_RID->RECNO)
	
			If !RID->(EOF())
				RecLock("RID",.F.,.T.)
				RID->RID_DATFIM	:= dDataPro
				RID->( MsUnLock() )
				RID->( FKCOMMIT() )
			EndIf
		Endif
		TRB_RID->( dbCloseArea() )
		
	Endif
Return()


//------------------------------------------------------------------------------
/*{Protheus.doc} VD180GRVSR
Grava as tabelas SR8/RID
@sample 	VD180GRVSR(aCamposSR7,aCamposSR3)
@param		I - inclusao			
			A - alteracao			
@return	 
@author	Nivia Ferreira			
@since		05/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180GRVSR(aCamposSR7,aCamposSR3)

	dbSelectArea("SR7")
	dbSetOrder(2)
	RecLock("SR7",.T.,.T.)
		SR7->R7_FILIAL   	:= SRA->RA_FILIAL
		SR7->R7_MAT      	:= SRA->RA_MAT
		SR7->R7_DATA     	:= dDataPro
		SR7->R7_TIPO     	:= cTipAum
		SR7->R7_TIPOPGT  	:= If( IsMemVar("RA_TIPOPGT"),GetMemVar("RA_TIPOPGT"),SRA->RA_TIPOPGT )
		SR7->R7_USUARIO  	:= SubStr(cUsuario,7,15)
		SR7->R7_SEQ			:= Alltrim(VD180Seq())
			
		SR7->R7_CATFUNC  	:= aCamposSR7[1]
		SR7->R7_FUNCAO   	:= aCamposSR7[2]
		SR7->R7_DESCFUN  	:= Alltrim(POSICIONE("SRJ",1,FwxFilial("SRJ")+SR7->R7_FUNCAO,"RJ_DESC"))
	   	SR7->R7_CARGO 		:= aCamposSR7[3]
		SR7->R7_DESCCAR		:= Alltrim(POSICIONE("SQ3",1,FwxFilial("SQ3")+SR7->R7_CARGO,"Q3_DESCSUM"))
	
		SR7->R7_ECAFUNC  	:= aCamposSR7[4]
		SR7->R7_EFUNCAO  	:= aCamposSR7[5]
		SR7->R7_EDESCFU  	:= POSICIONE("SRJ",1,FwxFilial("SRJ")+SR7->R7_EFUNCAO,"RJ_DESC")
		SR7->R7_ECARGO  	:= aCamposSR7[6]
		SR7->R7_EDESCCA  	:= Alltrim(POSICIONE("SQ3",1,FwxFilial("SQ3")+SR7->R7_ECARGO,"Q3_DESCSUM"))	
	SR7->( MsUnLock() )
	SR7->( FKCOMMIT() )


	dbSelectArea("SR3")
	dbSetOrder(2)
	RecLock("SR3",.T.,.T.)
		SR3->R3_FILIAL   	:= 	SRA->RA_FILIAL
		SR3->R3_MAT      	:= 	SRA->RA_MAT
		SR3->R3_DATA     	:= 	dDataPro
		SR3->R3_TIPO     	:= 	cTipAum
		SR3->R3_PD       	:= 	"000"
		SR3->R3_DESCPD   	:= 	"SUBSIDIO BASE" 
		SR3->R3_SEQ			:= 	SR7->R7_SEQ	
		
		SR3->R3_VALOR    	:= 	aCamposSR3[01]
		SR3->R3_ANTEAUM 	:= 	aCamposSR3[02]
		SR3->R3_TABELA 		:= 	aCamposSR3[03]
		SR3->R3_TABNIVE		:= 	aCamposSR3[04]
		SR3->R3_TABFAIX		:= 	aCamposSR3[05]
		SR3->R3_CSALAR		:=	aCamposSR3[06]
		SR3->R3_CTABELA		:=	aCamposSR3[07]
		SR3->R3_CTABNIV		:=	aCamposSR3[08]
		SR3->R3_CTABFAI		:=	aCamposSR3[09]
		SR3->R3_PERCCOM		:=	aCamposSR3[10]
		SR3->R3_TPSBCOM		:= 	aCamposSR3[11]
	SR3->( MsUnLock() )
Return()

//------------------------------------------------------------------------------
/*{Protheus.doc} VD180RCALC
Calculo retroativo
@sample 	VD180RCALC()
@param					
@return	 
@author	Nivia Ferreira			
@since		05/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180RCALC()
	
	Local cQuery 	:= ''
	Private TabSR7:= {}
	Private TabSR3:= {}
	
	cQuery  := "SELECT SR7.R_E_C_N_O_ R7_RECNO,SR3.R_E_C_N_O_ R3_RECNO,SR3.*, SR7.*"
	cQuery  += " FROM " + RetSqlName( 'SR7' ) + ' SR7,' + RetSqlName( 'SR3' ) + ' SR3 ' 
	cQuery  += " WHERE SR7.D_E_L_E_T_=' ' "
	cQuery  += " AND SR3.D_E_L_E_T_=' ' "	
	cQuery  += " AND R7_FILIAL='"+ SRA->RA_FILIAL +"'"
	cQuery  += " AND R7_MAT='"+ SRA->RA_MAT +"'"
	cQuery  += " AND R7_DATA>'"+ DTOS(dDataPro) +"'"
	cQuery  += " AND R7_FILIAL=R3_FILIAL"
	cQuery  += " AND R7_MAT=R3_MAT"
	cQuery  += " AND R7_DATA=R3_DATA"
	cQuery  += " AND R7_SEQ=R3_SEQ"	
	cQuery  += " ORDER BY R7_DATA"
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
	dbSelectArea("TRB")
	While !TRB->(Eof())
	   AADD(TabSR7 ,{	TRB->R7_RECNO,TRB->R7_FILIAL,TRB->R7_MAT,TRB->R7_DATA,TRB->R7_SEQ,TRB->R7_TIPO,TRB->R7_TIPOPGT,TRB->R7_USUARIO,;
					 	TRB->R7_CATFUNC,TRB->R7_FUNCAO,TRB->R7_DESCFUN,TRB->R7_CARGO,TRB->R7_DESCCAR,;
					 	SR7->R7_ECAFUNC,SR7->R7_EFUNCAO,SR7->R7_EDESCFU,SR7->R7_ECARGO,SR7->R7_EDESCCA}) 
	
		AADD(TabSR3 ,{TRB->R3_RECNO,TRB->R3_FILIAL,TRB->R3_MAT,TRB->R3_DATA,TRB->R3_SEQ,TRB->R3_TIPO,TRB->R3_PD,;
			        	TRB->R3_ANTEAUM,TRB->R3_DTCDISS,TRB->R3_DESCPD,TRB->R3_PERCCOM,TRB->R3_TPSBCOM,;
					 	TRB->R3_CSALAR,TRB->R3_CTABELA,TRB->R3_CTABNIV,TRB->R3_CTABFAI,;
					 	SR3->R3_VALOR,SR3->R3_TABELA,SR3->R3_TABNIVE,SR3->R3_TABFAIX})			 
		
		//Deleta SR7
		dbSelectArea("SR7")
		dbGoTo(TRB->R7_RECNO)
		RecLock("SR7",.F.)
		SR7->( dbDelete() )
		SR7->( MsUnlock() )
		
		//Deleta SR3
		dbSelectArea("SR3")
		dbGoTo(TRB->R3_RECNO)
		RecLock("SR3",.F.)
		SR3->( dbDelete() )
		SR3->( MsUnlock() )
		
		TRB->(DbSkip())
	EndDo
	
	TRB->(dbCloseArea())
	
	IF 	SRA->RA_CATFUNC $ '0,1,2,3'
		VD180RTAB(left(cCombCM,1))
	Endif	
	
Return()

/*{Protheus.doc} VD180RTAB
Grava SR3/SR7 retroativo
@param cTipo, Caractere, "1" - Efetivo; "2" - Comissionado			
@author	Nivia Ferreira			
@since		12/11/2013
@version	P11.8
/*/
Function VD180RTAB(cTipo)
	
	Local nX:= 0	
	
	If Empty(cTipo) .And. SRA->RA_CATFUNC == "2" 
		cTipo := "1"
	EndIf
	
	For nX:= 1 to Len(TabSR7)
		dbSelectArea("SR7")
		RecLock("SR7",.T.,.T.)
		SR7->R7_FILIAL   	:= 	TabSR7[nX][02]
		SR7->R7_MAT      	:= 	TabSR7[nX][03]
		SR7->R7_DATA     	:= 	STOD(TabSR7[nX][04])
		SR7->R7_SEQ			:= 	TabSR7[nX][05]
		SR7->R7_TIPO     	:= 	TabSR7[nX][06]
		SR7->R7_TIPOPGT  	:= 	TabSR7[nX][07]
		SR7->R7_USUARIO  	:= 	SubStr(cUsuario,7,15)	
		If 	cTipo == '2' //Comissionado
			SR7->R7_CATFUNC  	:= 	cCatfunc
			SR7->R7_FUNCAO   	:= 	cCodFunc
			SR7->R7_DESCFUN  	:= 	Alltrim(POSICIONE("SRJ",1,FwxFilial("SRJ")+SR7->R7_FUNCAO,"RJ_DESC"))
			SR7->R7_CARGO 		:= 	cCargo
			SR7->R7_DESCCAR		:= 	Alltrim(POSICIONE("SQ3",1,FwxFilial("SQ3")+SR7->R7_CARGO,"Q3_DESCSUM"))
			
			SR7->R7_ECAFUNC  	:= 	TabSR7[nX][14]
			SR7->R7_EFUNCAO  	:= 	TabSR7[nX][15]
			SR7->R7_EDESCFU  	:= 	TabSR7[nX][16]
			SR7->R7_ECARGO  	:= 	TabSR7[nX][17]
			SR7->R7_EDESCCA  	:= 	TabSR7[nX][18]
			
		ElseIf cTipo == '1' //Efetivo 	
			SR7->R7_CATFUNC  	:= 	TabSR7[nX][09]
			SR7->R7_FUNCAO   	:= 	TabSR7[nX][10]
			SR7->R7_DESCFUN  	:= 	TabSR7[nX][11]
			SR7->R7_CARGO 		:= 	TabSR7[nX][12]
			SR7->R7_DESCCAR		:= 	TabSR7[nX][13]
			SR7->R7_ECAFUNC  	:= 	cCatfunc
			SR7->R7_EFUNCAO  	:= 	cCodFunc
			SR7->R7_EDESCFU  	:= 	Alltrim(POSICIONE("SRJ",1,FwxFilial("SRJ")+SR7->R7_EFUNCAO,"RJ_DESC"))
			SR7->R7_ECARGO  	:= 	cCargo
			SR7->R7_EDESCCA  	:= 	Alltrim(POSICIONE("SQ3",1,FwxFilial("SQ3")+SR7->R7_ECARGO,"Q3_DESCSUM"))
		Endif			
		SR7->( MsUnLock() )
		SR7->( FKCOMMIT() )
		
		nSalario := TabSalIni(cTabela, STOD(TabSR3[nX][04]), .F., cTABNIVE, cTABFAIX)
		
		dbSelectArea("SR3")
		RecLock("SR3",.T.,.T.)
		SR3->R3_FILIAL   	:= 	TabSR3[nX][02]
		SR3->R3_MAT      	:= 	TabSR3[nX][03]
		SR3->R3_DATA     	:= 	STOD(TabSR3[nX][04])
		SR3->R3_SEQ			:= 	TabSR3[nX][05]
		SR3->R3_TIPO     	:= 	TabSR3[nX][06]
		SR3->R3_PD       	:= 	TabSR3[nX][07]
		SR3->R3_DESCPD   	:=	TabSR3[nX][10] 
		If cTipo == '2' //Comissionado
			SR3->R3_PERCCOM	:=	IIF(substr(cCombTP,1,1)=='2',nDifComs,0)
			SR3->R3_TPSBCOM	:=	substr(cCombTP,1,1) 
			
			SR3->R3_CSALAR 	:=	nSalario 
			SR3->R3_CTABELA	:=	cTabela 
			SR3->R3_CTABNIV	:=	cTabNive 
			SR3->R3_CTABFAI	:=	cTabFaix
			
			SR3->R3_VALOR  	:=	TabSR3[nX][17] 
			SR3->R3_TABELA 	:=	TabSR3[nX][18] 
			SR3->R3_TABNIVE	:=	TabSR3[nX][19] 
			SR3->R3_TABFAIX	:=	TabSR3[nX][20] 
		ElseIf cTipo == '1' //Efetivo
			SR3->R3_ANTEAUM := 	nSalario
			SR3->R3_PERCCOM	:=	TabSR3[nX][11] 
			SR3->R3_TPSBCOM	:=	TabSR3[nX][12] 
			
			SR3->R3_CSALAR 	:=	TabSR3[nX][13]  
			SR3->R3_CTABELA	:=	TabSR3[nX][14]  
			SR3->R3_CTABNIV	:=	TabSR3[nX][15] 
			SR3->R3_CTABFAI	:=	TabSR3[nX][16]
			
			SR3->R3_VALOR  	:=	nSalario
			SR3->R3_TABELA 	:=	cTabela
			SR3->R3_TABNIVE	:=	cTabNive 
			SR3->R3_TABFAIX	:=	cTabFaix 
		Endif
		SR3->( MsUnLock() )
		SR3->( FKCOMMIT() )
	Next
	
Return



//------------------------------------------------------------------------------
/*{Protheus.doc} VD180COMB
Monta Combo
@sample 	VD180COMB()
@param		1-Campo
			2-Tipo
			3-Habilitado			
@return	 
@author	Nivia Ferreira			
@since		19/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VD180COMB(cCampo,cTipo,lLimpa)
	
	If cCampo='RA_TPSBCOM' .And. !IsBlind()
		aCombTP:={''}
		cCombTP:=''
		If !Empty(SRA->RA_TPSBCOM)
			If lLimpa == .T.
				If SRA->RA_TPSBCOM == '1'
					aCombTP:={STR0053,STR0054}//'1=Diferença Subsídio entre cargos','2=% s/ Subsidio do Comissionado'
				ElseIf SRA->RA_TPSBCOM == '2'	
					aCombTP:={STR0054,STR0053}//'1=Diferença Subsídio entre cargos','2=% s/ Subsidio do Comissionado'
				Endif	
				cCombTP:= SRA->RA_TPSBCOM
			Endif
			ObjectMethod(oCombTP,"SetItems(aCombTP)")
		Endif
	Endif

Return()


//------------------------------------------------------------------------------
/*{Protheus.doc} UltAltSal
Monta Combo
@sample 	UltAltSal("'NOM','EXO'")
@param		cTps - Indique os tipos de Aumento que deseja analisar
@return	 
@author		Fabricio Amaro			
@since		19/02/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function UltAltSal(cTps)
	Local aArea	 := GetArea()
	Local cTipo	 := ""
	Default cTps := "('NOM','EXO')"
	
	cQuery := " SELECT * FROM " + RETSQLNAME("SR7")
	cQuery += " WHERE R7_FILIAL = '" + SRA->RA_FILIAL + "' "
	cQuery += "   AND R7_MAT    = '" + SRA->RA_MAT    + "' "
	cQuery += "   AND R7_TIPO  IN  " + cTps           + "  "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY R7_DATA DESC "
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
	dbSelectArea("TRB")
	cTipo := TRB->R7_TIPO
	TRB->(dbCloseArea())
	RestArea( aArea )
Return cTipo



/*/{Protheus.doc} f_Filtro
Filtro para Nivel de Tabela e Faixa
@type function
@author Eduardo
@since 05/10/2018
@version 1.0
@param nOp, numérico, identificador de concatenação para filtro 
@return cFiltro, caractere, Filtro String para consulta padrão
/*/
Function f_Filtro(nOp)

Default nOp		:= 0
Private cFiltro	:= "RB6->RB6_TABELA == SQ3->Q3_TABELA"

If Empty(SQ3->Q3_TABELA) .And. cTabela <> Nil 
	cFiltro:= "RB6->RB6_TABELA== '"+cTabela+"'"
EndIf
If nOp==0
	If !Empty(SQ3->Q3_TABNIVE)
		cFiltro += ".And. RB6->RB6_NIVEL == SQ3->Q3_TABNIVE"
	ElseIF (ValType(cTABNIVE)=="C" .AND. !Empty(cTABNIVE))   
		cFiltro += ".And. RB6->RB6_NIVEL == '"+cTABNIVE+"'"
	Endif
EndIf
If nOp > 0
	IF (ValType(cTABNIVE)=="C" .AND. !Empty(cTABNIVE))   
		cFiltro += ".And. RB6->RB6_NIVEL == '"+cTABNIVE+"'"
	Endif
EndIf
cFiltro := "@#" + cFiltro + "@#"                                                                                                                                                                                 
Return cFiltro


/*/{Protheus.doc} ShowError
	Função responsável em mostrar todos os erros, já fazendo tratativa
para situações do ExecAuto.
	Explicação para existência dessa função:
	A ideia da função HELP é que ela pode ser utilizada junto com o MVC
de maneira que ela guarde na memória os erros que ocorreram, mas
isso não estava acontecendo corretamente. Digamos que fosse passado
4 dependentes num vetor, sendo que todos são válidos, exceto a posição 3,
nesse caso, quando ele passasse pela posição 4, ele limparia os erros que
ocorreram na posição 3.
	Verificar de quando o Framework corrigir alterar essa função.
@author PHILIPE.POMPEU
@since 18/08/2015
@version 12.1.7
@param cMsg, caractere, Mensagem ou Código do Help
@param lIsHelp, lógico, Caso <cMsg> deva ser tratado como um código de Help
@param cTitle, caractere, Título da Tela de Help
@return Nil, Valor Nulo
@project 12.1.7
/*/
Static Function ShowError(cMsg,lIsHelp,cTitle,lCodHlp)
	DEFAULT cMsg 	:= ''
	DEFAULT lIsHelp	:= .F.
	DEFAULT cTitle 	:= OemToAnsi(STR0071) // Atenção
	DEFAULT lCodHlp	:= .F.

	If lGp020Auto
		AutoGrLog(cTitle + ':' + cMsg)
	Else
		If(lIsHelp)
			If lCodHlp
				Help(" ",1,cMsg)
			Else
				Help(,,'HELP',, cMsg,1,0 )
			EndIf
		Else
			MsgInfo(cMsg,cTitle)
		EndIf
	EndIf
Return (Nil)