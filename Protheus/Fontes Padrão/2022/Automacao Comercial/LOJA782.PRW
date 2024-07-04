#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FOLDER.CH'
#INCLUDE 'LOJA782.CH'


Static cParamFil := ""

//--------------------------------------------------------
/*/{Protheus.doc} LOJA782
Monitor Vendas PDVs x Reducao Z

@author  Carlos.Gorgulho
@since   08/10/2015
@version P11.8

/*/
//--------------------------------------------------------
Function LOJA782()

	Local aObj    	:= {}				// Array para dimensionamento de tela do Dialog
	Local aSizeAut	:= {}				// Array para dimensionamento de tela do Dialog
	Local aInfo   	:= {}				// Array para dimensionamento de tela do Dialog
	Local aPObj   	:= {}	  			// Array para dimensionamento de tela do Dialog
	Local aSitua	:= {}				// Array com os WebServices para filtro
	Local cAlias	:= GetNextAlias()	// Alias para a query    
	Local cQuery	:= ""				// Query para filtrar os dados do log
	Local dDeDt 	:= CTOD("")	 		// Data incial selecionada para filtragem
	Local dAtDt 	:= CTOD("")	 		// Data final selecionada para filtragem
	Local nCor		:= 239				// Cor do painel
	Local nOpcA		:= 0				// Variavel para confirmacao de gravacao
	Local oDlg 		:= Nil				// Objeto do dialogo           
	Local oCbx    	:= Nil				// Objeto do combobox para filtro 
	Local cPerg		:= "LOJA782"		// Nome do Pergunte da rotina
	Local aFilUsu	:= {}
	Local cUsuFil	:= ""
	Local lAllFil	:= .F.
	Local nX		:= 1      
	Local oFont1	:= Nil   
	Local oFont2	:= Nil
	Local oFont3	:= Nil
	Local oFont4	:= Nil
	Local K_OK     	:= 0
	Local bOK      	:= { || nOpca := K_OK, oDlg:End() }
	Local bCancel  	:= { || oDlg:End() }
	Local oBrw
	Local aBrw	 	:= {}
	Local oBrw1		:= Nil
	Local oPanel1	:= Nil
	Local oPanel2	:= Nil
	Local aBrw1	 	:= {}
	Local nInd
	Local nValTotRet := 0				
	Local nValTotPdv := 0
	Local nValTotDif := 0               
	Local nQtdBrw1	 := 0	
	Local cSitua	 := ""
	Local aButtons	 := {{"", {|| LJ782Len()}, "Legendas", "Legendas"}} 
	Local oFolder    := Nil
	Local aFolder    := {"Redução Z x Orçamentos (SFI x SL1)", "Redução Z x Vendas (SFI x SD2)", "Vendas x Orçamentos (SD2 x SL1)"}
	Local oBPanel 
	Local oBSButton 
	Local oBCbx 
	Local oBBrw 
	Local oBBrw1 
	Local oBPanel1 
	Local nBValTotRet := 0
	Local nBValTotPdv := 0
	Local nBValTotDif := 0
	Local aBBrw := {}
	Local aBBrw1 := {}
	Local nBQtdBrw1 := 0

	Local oCPanel 
	Local oCSButton 
	Local oCCbx 
	Local oCBrw 
	Local oCBrw1 
	Local oCPanel1 
	Local nCValTotRet := 0
	Local nCValTotPdv := 0
	Local nCValTotDif := 0
	Local aCBrw := {}
	Local aCBrw1 := {}
	Local nCQtdBrw1 := 0

	// Campo verificador se está sendo chamado pelo Robo
	Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
	Local lPergunte := .f. 

	Private cCadastro	:= ""	 		// Nome da rotina no Dialog
	Private aRotina	:= {}	  		// Opcoes no menu
	Private cEstacao	:= Space(75)	// Estacao selecionado para filtragem      
	Private cFilSel	:= Space(99)  

	DEFINE FONT oFont1  NAME "ARIAL"        SIZE 08,17 BOLD   //Largura x Altura
	DEFINE FONT oFont2  NAME "ARIAL"        SIZE 07,14 BOLD   //Largura x Altura
	DEFINE FONT oFont3  NAME "ARIAL"        SIZE 06,13 BOLD   //Largura x Altura
	DEFINE FONT oFont4  NAME "ARIAL"        SIZE 07,15 BOLD   //Largura x Altura     

	//Realiza o pergunte: Exportacao ou Importacao      
	If !lAutomato
		lPergunte := Pergunte(cPerg,.T.)
	Else
		Pergunte(cPerg,.f.)
		lPergunte := .t.
	EndIf

	If lPergunte

		cCadastro := STR0001		//"Monitor integracao Vendas Retaguarda x PDV"

		//Defini as opcoes do menu
		AAdd(aRotina,{ STR0002	,"AxPesqui()" , 0, 1})		//"Pesquisar"
		AAdd(aRotina,{ STR0003	,"AxVisual()" , 0, 2})		//"Visualizar"  

		aSitua := {STR0007}	//"Todos"
		AAdd(aSitua,STR0004)	//"Diferenca PDV"
		AAdd(aSitua,STR0005)	//"Diferenca Retaguarda"
		AAdd(aSitua,STR0006)	//"Sem Diferenca"

		cSitua  := mv_par04

		aFilUsu := LJ782Filial() //Valida as filiais que o usuario possui acesso

		If Empty(aFilUsu)
			MsgStop(STR0012) //"Usuario nao possui acesso a nenhuma filial do sistema"	 
			Return()
		ElseIf !("@" $ aFilUsu[1])
			For nX := 1 To Len(aFilUsu)
				If nX = 1
					cUsuFil := alltrim(aFilUsu[nX])
				Else
					cUsuFil += ","+ alltrim(aFilUsu[nX])
				Endif 
			Next
			cUsuFil := IIF(Empty(cUsuFil), "''", cUsuFil)
		Else
			lAllFil := .T.
		EndIf

		dDeDt := mv_par01
		dAtDt := mv_par02

		If Empty(cFilSel)
			cFilSel := MV_PAR03
		EndIf

		aBrw1 := {}

		L782FDados(@oDlg,@oBrw1,@oPanel1,@aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nValTotRet,@nValTotPdv,@nValTotDif,,.T.,@oBrw,@aBrw,cSitua,@nQtdBrw1)

		aBBrw1 := {}

		FiltraSFISD2(@oDlg,@oBBrw1,@oBPanel1,@aBBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nBValTotRet,@nBValTotPdv,@nBValTotDif,,.T.,@oBBrw,@aBBrw,cSitua,@nBQtdBrw1)

		aCBrw1 := {}

		FiltraSL1SD2(@oDlg,@oCBrw1,@oCPanel1,@aCBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nCValTotRet,@nCValTotPdv,@nCValTotDif,,.T.,@oCBrw,@aCBrw,cSitua,@nCQtdBrw1)

		//Monta interface
		aSizeAut  := MsAdvSize()

		aADD( aObj, { 100, 010, .T., .T. })
		aADD( aObj, { 100, 035, .T., .T. })
		aADD( aObj, { 100, 045, .T., .T. })
		aADD( aObj, { 100, 010, .T., .T. })

		aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3 }

		aPObj := MsObjSize( aInfo, aObj, .T.)
		aPObj[1,1] := 01
		aPObj[1,2] := 01

		DEFINE MSDIALOG oDlg TITLE STR0001 From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL  //"Monitor integracao Vendas Retaguarda x PDV"                                                                                                                                                                                                                                                                                                                                                                                                                                                                        

		oFolder := TFolder():New(aPObj[1,1],aPObj[1,2],aFolder,{},oDlg,,,,.T.,,aPObj[1,4],aPObj[1,3])
		oFolder:Align:= CONTROL_ALIGN_ALLCLIENT

		//---------------------------------------------------------------------------------------------------------------------------------	
		//FOLDER 1                                                                                                                     
		//---------------------------------------------------------------------------------------------------------------------------------
		oPanel:= tPanel():New(aPObj[1,1], aPObj[1,2], "", oFolder:aDialogs[1],,,,,RGB(nCor,nCor,nCor), aPObj[1,4], (aPObj[1,3]-aPObj[1,1]),.T.,.F.)	

		@004,030  SAY STR0013		SIZE 35, 25 OF oPanel PIXEL FONT oFont3 		// "FILIAL"
		@012,030  MSGET cFilSel    	SIZE 75, 09 OF oPanel PIXEL When .F. HASBUTTON 
		oSButton := tButton():New(012,109,"?",oPanel,{|| LJ782F3FIL(@cFilSel,@oFolder:aDialogs[1],@oBrw1,@oPanel1,@aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nValTotRet,@nValTotPdv,@nValTotDif,,.T.,@oBrw,@aBrw,cSitua,@nQtdBrw1,"FOLDER_1")},009,012,,,,.T.,,,,{|| .T.}) //"Filtro Filial	

		@004,189  SAY STR0014		SIZE 35, 25 OF oPanel PIXEL FONT oFont3 		// "DIFERENCA"
		oCbx := TComboBox():New(012,190,{|u| if( Pcount( )>0, cSitua:= u, cSitua )},aSitua,070,026,oPanel,,{|x| L782FDados(@oFolder:aDialogs[1],@oBrw1,@oPanel1,@aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nValTotRet,@nValTotPdv,@nValTotDif,		,.T.,@oBrw,@aBrw,cSitua,@nQtdBrw1)},,,,.T.,,,,,,,,,"cSitua")

		@004,345  SAY STR0015		SIZE 30, 09 OF oPanel PIXEL FONT oFont3 		// "DATA"
		@014,345  SAY  STR0016		SIZE 10, 09 OF oPanel PIXEL  		// "De:"
		@012,360  MSGET dDeDt     	SIZE 45, 09 OF oPanel PIXEL HASBUTTON          
		@014,418  SAY STR0017     	SIZE 10, 09 OF oPanel PIXEL  		// "Ate:"
		@012,435  MSGET dAtDt     	SIZE 45, 09 OF oPanel PIXEL HASBUTTON  	

		oSButton1 := SButton():New(012,520,17,{|x| L782FDados(@oFolder:aDialogs[1],@oBrw1,@oPanel1,@aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nValTotRet,@nValTotPdv,@nValTotDif,		,.T.,@oBrw,@aBrw,cSitua,@nQtdBrw1)},oPanel,.T.,,)    // Filtrar

		oBrw := TcBrowse():New( aPObj[2,1],aPObj[2,2],aPObj[2,4],(aPObj[2,3]-aPObj[2,1]),,,,oFolder:aDialogs[1],,,,{|x| L782FDados(@oFolder:aDialogs[1],@oBrw1,@oPanel1,@aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nValTotRet,@nValTotPdv,@nValTotDif,aBrw[oBrw:nAt,1],.F.,@oBrw,@aBrw,cSitua,@nQtdBrw1) }, ,,,,,,, .F.,, .T.,, .F., )     
		oBrw:AddColumn(TcColumn():New("",{|| LoadBitmap(GetResources(),LJ782Leg(aBrw[oBrw:nAt,4])) },,,,,010,.T.,.F.,,,,,)) // Legenda                    
		oBrw:AddColumn(TcColumn():New(STR0019,{ || OemToAnsi(aBrw[oBrw:nAt,1])+" - "+AllTrim(FWFilialName(cEmpAnt,aBrw[oBrw:nAt,1],1 )) },"@!",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))  // "Filial Venda"  
		oBrw:AddColumn(TcColumn():New(STR0020,{ || Transform(aBrw[oBrw:nAt,2],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total Retaguarda"
		oBrw:AddColumn(TcColumn():New(STR0021,{ || Transform(aBrw[oBrw:nAt,3],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total PDV"
		oBrw:AddColumn(TcColumn():New(STR0022,{ || Transform(aBrw[oBrw:nAt,4],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Diferenca" 

		oBrw:SetArray(aBrw)         

		//Browse Estacoes x Filiais
		oBrw1 := TcBrowse():New( aPObj[3,1],aPObj[3,2],aPObj[3,4],(aPObj[3,3]-aPObj[3,1]),,,,oFolder:aDialogs[1],,,,,,,,,,,, .F.,, .T.,, .F., )                           

		oBrw1:AddColumn(TcColumn():New("",{|| LoadBitmap(GetResources(),LJ782Leg(aBrw1[oBrw1:nAt,8])) },,,,,010,.T.,.F.,,,,,)) // Legenda                    
		oBrw1:AddColumn(TcColumn():New(STR0019,{ || OemToAnsi(aBrw1[oBrw1:nAt,1])+" - "+AllTrim(FWFilialName(cEmpAnt,aBrw1[oBrw1:nAt,1],1 )) },"@!",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))  // "Filial Venda"  
		oBrw1:AddColumn(TcColumn():New(STR0023,{ || IIF(!Empty(aBrw1[oBrw1:nAt,2]),OemToAnsi(aBrw1[oBrw1:nAt,2])+" - "+AllTrim(FWFilialName(cEmpAnt,aBrw1[oBrw1:nAt,2],1 )),"") },"@!",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))  // "Filial Movto"   
		oBrw1:AddColumn(TcColumn():New(STR0024,{ || StoD(aBrw1[oBrw1:nAt,3]) },"@!",nil,nil,"CENTER",040,.F.,.F.,nil,nil,nil,.F.,nil))  // "Data Movto"  
		oBrw1:AddColumn(TcColumn():New(STR0025,{ || OemToAnsi(aBrw1[oBrw1:nAt,4]) },"@!",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))  // "Numero PDV" 
		If MV_PAR05 == 1
			oBrw1:AddColumn(TcColumn():New(STR0026,{ || OemToAnsi(aBrw1[oBrw1:nAt,5]) },"@!",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))  // "Serie"
		EndIf    
		oBrw1:AddColumn(TcColumn():New(STR0020 + " (SL1)",{ || Transform(aBrw1[oBrw1:nAt,6],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total Retaguarda"
		oBrw1:AddColumn(TcColumn():New(STR0021 + " (SFI)",{ || Transform(aBrw1[oBrw1:nAt,7],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total PDV"
		oBrw1:AddColumn(TcColumn():New(STR0022,{ || Transform(aBrw1[oBrw1:nAt,8],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Diferenca" 

		oBrw1:SetArray(aBrw1)         

		oPanel1:= tPanel():New(aPObj[4,1], aPObj[4,2], "", oFolder:aDialogs[1],,,,,RGB(nCor,nCor,nCor), aPObj[4,4], (aPObj[4,3]-aPObj[4,1]),.T.,.F.)


		@005,010  SAY STR0028	 SIZE 70, 09 OF oPanel1  PIXEL RIGHT FONT oFont4	// "Quantidade Registros: "
		@005,060  SAY Transform(nQtdBrw1,"99999")	 SIZE 40, 09 OF oPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont4              

		@005,120  SAY STR0029	 SIZE 70, 09 OF oPanel1 PIXEL RIGHT FONT oFont4	// "Valor Total Retaguarda: "
		@005,180  SAY Transform(nValTotRet,PesqPict("SL1", "L1_VLRTOT" ,,1))	 SIZE 50, 09 OF oPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont4

		@005,240  SAY STR0030	 SIZE 70, 09 OF oPanel1 PIXEL RIGHT FONT oFont4	// "Valor Total PDV: "
		@005,300  SAY Transform(nValTotPdv,PesqPict("SL1", "L1_VLRTOT" ,,1))	 SIZE 50, 09 OF oPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont4

		@005,380  SAY STR0031	 SIZE 70, 09 OF oPanel1 PIXEL RIGHT FONT oFont1	// "Valor Total Diferenca: "
		@005,440  SAY Transform(nValTotDif,PesqPict("SL1", "L1_VLRTOT" ,,1))	 SIZE 50, 09 OF oPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont1

		//---------------------------------------------------------------------------------------------------------------------------------	
		//FOLDER 2                                                                                                                     
		//---------------------------------------------------------------------------------------------------------------------------------
		oBPanel:= tPanel():New(aPObj[1,1], aPObj[1,2], "", oFolder:aDialogs[2],,,,,RGB(nCor,nCor,nCor), aPObj[1,4], (aPObj[1,3]-aPObj[1,1]),.T.,.F.)	

		@004,030  SAY STR0013		SIZE 35, 25 OF oBPanel PIXEL FONT oFont3 		// "FILIAL"
		@012,030  MSGET cFilSel    	SIZE 75, 09 OF oBPanel PIXEL When .F. HASBUTTON 
		oBSButton := tButton():New(012,109,"?",oBPanel,{|| LJ782F3FIL(@cFilSel,@oFolder:aDialogs[2],@oBBrw1,@oBPanel1,@aBBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nBValTotRet,@nBValTotPdv,@nBValTotDif,,.T.,@oBBrw,@aBBrw,cSitua,@nBQtdBrw1,"FOLDER_2")},009,012,,,,.T.,,,,{|| .T.}) //"Filtro Filial	

		@004,189  SAY STR0014		SIZE 35, 25 OF oBPanel PIXEL FONT oFont3 		// "DIFERENCA"
		oBCbx := TComboBox():New( 012,190,{|u| if( Pcount( )>0, cSitua:= u, cSitua )},aSitua,070,026,oBPanel,,{|x| FiltraSFISD2(@oFolder:aDialogs[2],@oBBrw1,@oBPanel1,@aBBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nBValTotRet,@nBValTotPdv,@nBValTotDif,		,.T.,@oBBrw,@aBBrw,cSitua,@nBQtdBrw1)},,,,.T.,,,,,,,,,"cSitua")

		@004,345  SAY STR0015		SIZE 30, 09 OF oBPanel PIXEL FONT oFont3 		// "DATA"
		@014,345  SAY  STR0016		SIZE 10, 09 OF oBPanel PIXEL  		// "De:"
		@012,360  MSGET dDeDt     	SIZE 45, 09 OF oBPanel PIXEL HASBUTTON          
		@014,418  SAY STR0017     	SIZE 10, 09 OF oBPanel PIXEL  		// "Ate:"
		@012,435  MSGET dAtDt     	SIZE 45, 09 OF oBPanel PIXEL HASBUTTON  	

		oBSButton1 := SButton():New(012,520,17,{|x| FiltraSFISD2(@oFolder:aDialogs[2],@oBBrw1,@oBPanel1,@aBBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nBValTotRet,@nBValTotPdv,@nBValTotDif,		,.T.,@oBBrw,@aBBrw,cSitua,@nBQtdBrw1)},oBPanel,.T.,,)    // Filtrar

		oBBrw := TcBrowse():New( aPObj[2,1],aPObj[2,2],aPObj[2,4],(aPObj[2,3]-aPObj[2,1]),,,,oFolder:aDialogs[2],,,,{|x| FiltraSFISD2(@oFolder:aDialogs[2],@oBBrw1,@oBPanel1,@aBBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nBValTotRet,@nBValTotPdv,@nBValTotDif,aBBrw[oBBrw:nAt,1],.F.,@oBBrw,@aBBrw,cSitua,@nBQtdBrw1) }, ,,,,,,, .F.,, .T.,, .F., )     
		oBBrw:AddColumn(TcColumn():New("",{|| LoadBitmap(GetResources(),LJ782Leg(aBBrw[oBBrw:nAt,4])) },,,,,010,.T.,.F.,,,,,)) // Legenda                    
		oBBrw:AddColumn(TcColumn():New(STR0019,{ || OemToAnsi(aBBrw[oBBrw:nAt,1])+" - "+AllTrim(FWFilialName(cEmpAnt,aBBrw[oBBrw:nAt,1],1 )) },"@!",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))  // "Filial Venda"  
		oBBrw:AddColumn(TcColumn():New(STR0020,{ || Transform(aBBrw[oBBrw:nAt,2],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total Retaguarda"
		oBBrw:AddColumn(TcColumn():New(STR0021,{ || Transform(aBBrw[oBBrw:nAt,3],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total PDV"
		oBBrw:AddColumn(TcColumn():New(STR0022,{ || Transform(aBBrw[oBBrw:nAt,4],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Diferenca" 

		oBBrw:SetArray(aBBrw)         

		//Browse Estacoes x Filiais
		oBBrw1 := TcBrowse():New( aPObj[3,1],aPObj[3,2],aPObj[3,4],(aPObj[3,3]-aPObj[3,1]),,,,oFolder:aDialogs[2],,,,,,,,,,,, .F.,, .T.,, .F., )                           

		oBBrw1:AddColumn(TcColumn():New("",{|| LoadBitmap(GetResources(),LJ782Leg(aBBrw1[oBBrw1:nAt,8])) },,,,,010,.T.,.F.,,,,,)) // Legenda                    
		oBBrw1:AddColumn(TcColumn():New(STR0019,{ || OemToAnsi(aBBrw1[oBBrw1:nAt,1])+" - "+AllTrim(FWFilialName(cEmpAnt,aBBrw1[oBBrw1:nAt,1],1 )) },"@!",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))  // "Filial Venda"  
		oBBrw1:AddColumn(TcColumn():New(STR0023,{ || IIF(!Empty(aBBrw1[oBBrw1:nAt,2]),OemToAnsi(aBBrw1[oBBrw1:nAt,2])+" - "+AllTrim(FWFilialName(cEmpAnt,aBBrw1[oBBrw1:nAt,2],1 )),"") },"@!",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))  // "Filial Movto"   
		oBBrw1:AddColumn(TcColumn():New(STR0024,{ || StoD(aBBrw1[oBBrw1:nAt,3]) },"@!",nil,nil,"CENTER",040,.F.,.F.,nil,nil,nil,.F.,nil))  // "Data Movto"  
		oBBrw1:AddColumn(TcColumn():New(STR0025,{ || OemToAnsi(aBBrw1[oBBrw1:nAt,4]) },"@!",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))  // "Numero PDV" 
		If MV_PAR05 == 1
			oBBrw1:AddColumn(TcColumn():New(STR0026,{ || OemToAnsi(aBBrw1[oBBrw1:nAt,5]) },"@!",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))  // "Serie"
		EndIf    
		oBBrw1:AddColumn(TcColumn():New(STR0020 + " (SD2)",{ || Transform(aBBrw1[oBBrw1:nAt,6],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total Retaguarda"
		oBBrw1:AddColumn(TcColumn():New(STR0021 + " (SFI)",{ || Transform(aBBrw1[oBBrw1:nAt,7],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total PDV"
		oBBrw1:AddColumn(TcColumn():New(STR0022,{ || Transform(aBBrw1[oBBrw1:nAt,8],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Diferenca" 


		oBBrw1:SetArray(aBBrw1)         

		oBPanel1:= tPanel():New(aPObj[4,1], aPObj[4,2], "", oFolder:aDialogs[2],,,,,RGB(nCor,nCor,nCor), aPObj[4,4], (aPObj[4,3]-aPObj[4,1]),.T.,.F.)


		@005,010  SAY STR0028	 SIZE 70, 09 OF oBPanel1  PIXEL RIGHT FONT oFont4	// "Quantidade Registros: "
		@005,060  SAY Transform(nBQtdBrw1,"99999")	 SIZE 40, 09 OF oBPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont4              

		@005,120  SAY STR0029	 SIZE 70, 09 OF oBPanel1 PIXEL RIGHT FONT oFont4	// "Valor Total Retaguarda: "
		@005,180  SAY Transform(nBValTotRet,PesqPict("SL1", "L1_VLRTOT" ,,1))	 SIZE 50, 09 OF oBPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont4

		@005,240  SAY STR0030	 SIZE 70, 09 OF oBPanel1 PIXEL RIGHT FONT oFont4	// "Valor Total PDV: "
		@005,300  SAY Transform(nBValTotPdv,PesqPict("SL1", "L1_VLRTOT" ,,1))	 SIZE 50, 09 OF oBPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont4

		@005,380  SAY STR0031	 SIZE 70, 09 OF oBPanel1 PIXEL RIGHT FONT oFont1	// "Valor Total Diferenca: "
		@005,440  SAY Transform(nBValTotDif,PesqPict("SL1", "L1_VLRTOT" ,,1))	 SIZE 50, 09 OF oBPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont1

		//---------------------------------------------------------------------------------------------------------------------------------	
		//FOLDER 3                                                                                                                     
		//---------------------------------------------------------------------------------------------------------------------------------
		oCPanel:= tPanel():New(aPObj[1,1], aPObj[1,2], "", oFolder:aDialogs[3],,,,,RGB(nCor,nCor,nCor), aPObj[1,4], (aPObj[1,3]-aPObj[1,1]),.T.,.F.)	

		@004,030  SAY STR0013		SIZE 35, 25 OF oCPanel PIXEL FONT oFont3 		// "FILIAL"
		@012,030  MSGET cFilSel    	SIZE 75, 09 OF oCPanel PIXEL When .F. HASBUTTON 
		oCSButton := tButton():New(012,109,"?",oCPanel,{|| LJ782F3FIL(@cFilSel,@oFolder:aDialogs[3],@oCBrw1,@oCPanel1,@aCBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nCValTotRet,@nCValTotPdv,@nCValTotDif,,.T.,@oCBrw,@aCBrw,cSitua,@nCQtdBrw1,"FOLDER_3")},009,012,,,,.T.,,,,{|| .T.}) //"Filtro Filial	

		@004,189  SAY STR0014		SIZE 35, 25 OF oCPanel PIXEL FONT oFont3 		// "DIFERENCA"
		oCCbx := TComboBox():New( 012,190,{|u| if( Pcount( )>0, cSitua:= u, cSitua )},aSitua,070,026,oCPanel,,{|x| FiltraSL1SD2(@oFolder:aDialogs[3],@oCBrw1,@oCPanel1,@aCBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nCValTotRet,@nCValTotPdv,@nCValTotDif,		,.T.,@oCBrw,@aCBrw,cSitua,@nCQtdBrw1)},,,,.T.,,,,,,,,,"cSitua")

		@004,345  SAY STR0015		SIZE 30, 09 OF oCPanel PIXEL FONT oFont3 		// "DATA"
		@014,345  SAY  STR0016		SIZE 10, 09 OF oCPanel PIXEL  		// "De:"
		@012,360  MSGET dDeDt     	SIZE 45, 09 OF oCPanel PIXEL HASBUTTON          
		@014,418  SAY STR0017     	SIZE 10, 09 OF oCPanel PIXEL  		// "Ate:"
		@012,435  MSGET dAtDt     	SIZE 45, 09 OF oCPanel PIXEL HASBUTTON  	

		oCSButton1 := SButton():New(012,520,17,{|x| FiltraSL1SD2(@oFolder:aDialogs[3],@oCBrw1,@oCPanel1,@aCBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nCValTotRet,@nCValTotPdv,@nCValTotDif,		,.T.,@oCBrw,@aCBrw,cSitua,@nCQtdBrw1)},oCPanel,.T.,,)    // Filtrar

		oCBrw := TcBrowse():New( aPObj[2,1],aPObj[2,2],aPObj[2,4],(aPObj[2,3]-aPObj[2,1]),,,,oFolder:aDialogs[3],,,,{|x| FiltraSL1SD2(@oFolder:aDialogs[3],@oCBrw1,@oCPanel1,@aCBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nCValTotRet,@nCValTotPdv,@nCValTotDif,aCBrw[oCBrw:nAt,1],.F.,@oCBrw,@aCBrw,cSitua,@nCQtdBrw1) }, ,,,,,,, .F.,, .T.,, .F., )     
		oCBrw:AddColumn(TcColumn():New("",{|| LoadBitmap(GetResources(),LJ782Leg(aCBrw[oCBrw:nAt,4])) },,,,,010,.T.,.F.,,,,,)) // Legenda                    
		oCBrw:AddColumn(TcColumn():New(STR0019,{ || OemToAnsi(aCBrw[oCBrw:nAt,1])+" - "+AllTrim(FWFilialName(cEmpAnt,aCBrw[oCBrw:nAt,1],1 )) },"@!",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))  // "Filial Venda"  
		oCBrw:AddColumn(TcColumn():New(STR0020,{ || Transform(aCBrw[oCBrw:nAt,2],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total Retaguarda"
		oCBrw:AddColumn(TcColumn():New(STR0021,{ || Transform(aCBrw[oCBrw:nAt,3],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total PDV"
		oCBrw:AddColumn(TcColumn():New(STR0022,{ || Transform(aCBrw[oCBrw:nAt,4],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Diferenca" 

		oCBrw:SetArray(aCBrw)         

		//Browse Estacoes x Filiais
		oCBrw1 := TcBrowse():New( aPObj[3,1],aPObj[3,2],aPObj[3,4],(aPObj[3,3]-aPObj[3,1]),,,,oFolder:aDialogs[3],,,,,,,,,,,, .F.,, .T.,, .F., )                           


		oCBrw1:AddColumn(TcColumn():New("",{|| LoadBitmap(GetResources(),LJ782Leg(aCBrw1[oCBrw1:nAt,8])) },,,,,010,.T.,.F.,,,,,)) // Legenda                    
		oCBrw1:AddColumn(TcColumn():New(STR0019,{ || OemToAnsi(aCBrw1[oCBrw1:nAt,1])+" - "+AllTrim(FWFilialName(cEmpAnt,aCBrw1[oCBrw1:nAt,1],1 )) },"@!",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))  // "Filial Venda"  
		oCBrw1:AddColumn(TcColumn():New(STR0023,{ || IIF(!Empty(aCBrw1[oCBrw1:nAt,2]),OemToAnsi(aCBrw1[oCBrw1:nAt,2])+" - "+AllTrim(FWFilialName(cEmpAnt,aCBrw1[oCBrw1:nAt,2],1 )),"") },"@!",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))  // "Filial Movto"   
		oCBrw1:AddColumn(TcColumn():New(STR0024,{ || StoD(aCBrw1[oCBrw1:nAt,3]) },"@!",nil,nil,"CENTER",040,.F.,.F.,nil,nil,nil,.F.,nil))  // "Data Movto"  
		oCBrw1:AddColumn(TcColumn():New(STR0025,{ || OemToAnsi(aCBrw1[oCBrw1:nAt,4]) },"@!",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))  // "Numero PDV" 
		If MV_PAR05 == 1
			oCBrw1:AddColumn(TcColumn():New(STR0026,{ || OemToAnsi(aCBrw1[oCBrw1:nAt,5]) },"@!",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))  // "Serie"
		EndIf    
		oCBrw1:AddColumn(TcColumn():New(STR0020,{ || Transform(aCBrw1[oCBrw1:nAt,6],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total Retaguarda"
		oCBrw1:AddColumn(TcColumn():New(STR0021 + " (SD2)",{ || Transform(aCBrw1[oCBrw1:nAt,7],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Total PDV"
		oCBrw1:AddColumn(TcColumn():New(STR0022 + " (SL1)",{ || Transform(aCBrw1[oCBrw1:nAt,8],PesqPict("SL1","L1_VLRTOT",15))},,nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))  // "Diferenca" 


		oCBrw1:SetArray(aCBrw1)         

		oCPanel1:= tPanel():New(aPObj[4,1], aPObj[4,2], "", oFolder:aDialogs[3],,,,,RGB(nCor,nCor,nCor), aPObj[4,4], (aPObj[4,3]-aPObj[4,1]),.T.,.F.)


		@005,010  SAY STR0028	 SIZE 70, 09 OF oCPanel1  PIXEL RIGHT FONT oFont4	// "Quantidade Registros: "
		@005,060  SAY Transform(nCQtdBrw1,"99999")	 SIZE 40, 09 OF oCPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont4              

		@005,120  SAY STR0029	 SIZE 70, 09 OF oCPanel1 PIXEL RIGHT FONT oFont4	// "Valor Total Retaguarda: "
		@005,180  SAY Transform(nCValTotRet,PesqPict("SL1", "L1_VLRTOT" ,,1))	 SIZE 50, 09 OF oCPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont4

		@005,240  SAY STR0030	 SIZE 70, 09 OF oCPanel1 PIXEL RIGHT FONT oFont4	// "Valor Total PDV: "
		@005,300  SAY Transform(nCValTotPdv,PesqPict("SL1", "L1_VLRTOT" ,,1))	 SIZE 50, 09 OF oCPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont4

		@005,380  SAY STR0031	 SIZE 70, 09 OF oCPanel1 PIXEL RIGHT FONT oFont1	// "Valor Total Diferenca: "
		@005,440  SAY Transform(nCValTotDif,PesqPict("SL1", "L1_VLRTOT" ,,1))	 SIZE 50, 09 OF oCPanel1 PIXEL RIGHT COLOR CLR_HRED FONT oFont1

		If !lAutomato	
			ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons,,,.F.,.F.,.F.,.F.,.F.)
		EndIf
	Endif

Return

/*/{Protheus.doc} LJ782Filial
Valida as filiais que o usuario possui acessos

@author	Vendas.Varejo
@version	11.8
@since		28/09/2015
@return	aFilUsr - filial que possue acesso
/*/
//------------------------------------------------------------------------------------------
Static Function LJ782Filial()

	Local aUsrFil	:= {}	// Retorna vetor com informações do usuário
	Local aGrupo    := ""	// Grupos que o usuario pertence
	Local nX        := 0	// Variável de laço For
	Local nxFil     := 0	// Variável de laço For
	Local nInc      := 0	// Variável de laço For
	Local aFilUsr   := {}	// Array de retorno com as filiáis de acesso do usuário

	PswOrder(1)
	If PswSeek( __cUserID, .T. )
		aUsrFil := PswRet()[2,6] 					// Retorna vetor com informações do usuário   

		If Empty(aUsrFil) .And. FWUsrGrpRule(__cUserID) == "1"   // Verifica se prioriza os acessos do grupo do usuario
			aGrupo := FWSFUsrGrps(__cUserID)					 // Grupos que o usuario pertence
			For nX := 1 To  Len(aGrupo)  						 
				PswSeek( aGrupo[nX], .F. ) 
				aFilsGrupo := FWGrpEmp(aGrupo[nX]) 				// Filiais que o Grupo tem acesso
				For nxFil := 1 To Len(aFilsGrupo) 
					AADD(aUsrFil, aFilsGrupo[nxFil])
				Next
			Next
		Endif   

		// Adiciona as filiais que o usuario tem permissão            
		If Len( aUsrFil ) > 0
			If !EMPTY(mv_par03) 
				If "@" $ aUsrFil[1]
					For nInc := 1 To Len( aUsrFil )
						AADD(aFilUsr, Right( aUsrFil[nInc],LEN(aUsrFil[nInc])-2 ))
					Next	
				Else
					For nInc := 1 To Len( aUsrFil )    
						AADD(aFilUsr, Right( aUsrFil[nInc],LEN(aUsrFil[nInc])-2 ) )
					Next
				Endif
			Else
				For nInc := 1 To Len( aUsrFil )
					AADD(aFilUsr, Right( aUsrFil[nInc],LEN(aUsrFil[nInc])-2 ))
				Next	
			Endif	
		Endif
	Endif

Return aFilUsr                                                                            

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LJ782Leg
Função para definição da legenda da venda

@author    Vendas.Varejo
@version   11.8
@since     29/09/2015

@param cEstacao 	Estacao
@return cRet		String do bitmap da legenda

/*/
//------------------------------------------------------------------------------------------
Function LJ782Leg(nValor)

	Local cRet := ""

	DEFAULT nValor := ""   

	If ValType(nValor) <> "N"
		nValor := -1
	EndIf

	If nValor == 0 //OK
		cRet := "BR_VERDE"
	ElseIf nValor > 0 //Erro
		cRet := "BR_AZUL"	
	Else
		cRet := "BR_VERMELHO"	
	EndIf

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LJ782Len
Função para exibicao da legenda

@author    Vendas.Varejo
@version   11.8
@since     29/09/2015

/*/
//------------------------------------------------------------------------------------------

Function LJ782Len()

	Local aCores := {	{"BR_VERDE"		,OemToAnsi(STR0006)},;	//"Sem Diferenca"
	{"BR_VERMELHO"	,OemToAnsi(STR0004)},;	//"Diferenca PDV"
	{"BR_AZUL" 		,OemToAnsi(STR0005)}}	//"Diferenca Retaguarda"

	BrwLegenda(STR0018,STR0032,aCores) //PDV x Retaguarda"

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LJ782F3FIL
Função para exibir as filiais que o usuario possui acesso a partir de um F3

@author    Vendas.Varejo
@version   11.8
@since     02/10/2015

/*/
//------------------------------------------------------------------------------------------
Function LJ782F3FIL(cDado,oDlg,oBrw1,oPanel1,aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,nValTotRet,nValTotPdv,nValTotDif,cFilBrw,lInicio,oBrw,aBrw,cSitua,nQtdBrw1,cFolder)           

	Default cDado			:= ""                                                                                                                                                                       
	Default oDlg			:= nil   
	Default oBrw			:= nil   
	Default oBrw1			:= nil                                                                             
	Default oPanel1		:= nil   
	Default cFilSel		:= ""
	Default dDeDt			:= ""
	Default dAtDt			:= ""
	Default aBrw			:= {}
	Default aBrw1			:= {}
	Default lAllFil		:= .T.
	Default nValTotRet	:= 0
	Default nValTotPdv	:= 0
	Default nValTotDif	:= 0
	Default cFilBrw		:= ""
	Default lInicio		:= .T.   
	Default cSitua		:= ""    
	Default nQtdBrw1		:= 0
	Default cFolder		:= ""

	//Chama tela de seleção de filial
	Lj782TelaFil(cDado,@lAllFil) 

	//Recupera as filiais selecionadas 
	cDado := Lj782SelFil()

	cFilSel := cDado

	If oDlg <> Nil
		oBrw:refresh()
		oDlg:Refresh()
		If cFolder == "FOLDER_1"
			L782FDados(@oDlg,@oBrw1,@oPanel1,@aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nValTotRet,@nValTotPdv,@nValTotDif,,.T.,@oBrw,@aBrw,cSitua,@nQtdBrw1)

		ElseIf cFolder == "FOLDER_2"
			FiltraSFISD2(@oDlg,@oBrw1,@oPanel1,@aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nValTotRet,@nValTotPdv,@nValTotDif,,.T.,@oBrw,@aBrw,cSitua,@nQtdBrw1)

		ElseIf Empty(cFolder) .Or. cFolder == "FOLDER_3" 
			FiltraSL1SD2(@oDlg,@oBrw1,@oPanel1,@aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,@nValTotRet,@nValTotPdv,@nValTotDif,,.T.,@oBrw,@aBrw,cSitua,@nQtdBrw1)

		EndIf
	EndIf

Return .T.       

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FiltraDados
Função para filtrar os dados a exibir

@author    Gorgulho
@version   11.8
@since     15/10/2015

/*/
//------------------------------------------------------------------------------------------

Function L782FDados(oDlg,oBrw1,oPanel1,aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,nValTotRet,nValTotPdv,nValTotDif,cFilBrw,lInicio,oBrw,aBrw,cSitua,nQtdBrw1)

	Local aArea     	:= GetArea()
	Local cAlias		:= GetNextAlias()	// Alias para a query    
	Local cQuery  	:= ""				// Query para filtrar os dados do log
	Local cAlias1		:= GetNextAlias()	// Alias para a query    
	Local cQuery1  	:= ""				// Query para filtrar os dados do log
	Local lRet			:= .T.
	Local nPosFil		:= 0
	Local lEOF			:= .F.
	local nI			:= 0
	local cFil			:= ""	
	local aCopiaFil	:= {}
	local lLJ782Where	:= ExistBlock("LJ782WHERE")
	local cLJ782Where	:= ""
	Local cFilSL1       := ""
	Local cFilSFI       := "" 
	Local cFilBrwSL1    := ""
	Local cFilBrwSFI    := ""

	Default oDlg		:= Nil 
	Default oBrw1		:= Nil
	Default aBrw1       := {} 
	Default oBrw		:= Nil      
	Default oPanel1		:= Nil
	Default aBrw	    := {}
	Default cFilSel		:= ""
	Default dDeDt		:= ""
	Default dAtDt     	:= ""   
	Default lAllFil		:= .T.  
	Default nValTotRet	:= 0
	Default nValTotPdv	:= 0
	Default nValTotDif	:= 0
	Default cFilBrw		:= cFilAnt
	Default lInicio		:= .F.
	Default cSitua		:= ""
	Default nQtdBrw1		:= 0

	If lInicio 

		aBrw := {}

		// Monta query para filtrar os dados de cada filial	
		cQuery := " SELECT "																							
		cQuery += " COALESCE(SL1.L1_FILIAL,SFI.FI_FILIAL)	L1_FILIAL, "
		cQuery += " COALESCE(SFI.FI_FILIAL,SL1.L1_FILIAL)	FI_FILIAL, " 
		cQuery += IIF(MV_PAR05 == 1,"	SL1.L1_SERIE L1_SERIE,","")
		cQuery += " COALESCE(SL1.L1_EMISSAO,SFI.FI_DTMOVTO)	L1_EMISSAO,"
		cQuery += " COALESCE(SFI.FI_DTMOVTO,SL1.L1_EMISSAO)	FI_DTMOVTO,"
		cQuery += " COALESCE(SL1.L1_PDV,SFI.FI_PDV)			L1_PDV,"
		cQuery += " COALESCE(SFI.FI_PDV,SL1.L1_PDV)			FI_PDV,"
		cQuery += " ROUND(SUM(COALESCE(SL1.L1_VLRTOT,0)),2) TOT_ORC, "

		If MV_PAR05 == 1    	    	
			cQuery += " CASE " 
			cQuery += "     WHEN SL1.L1_SERRPS = '' THEN COALESCE(SFI.FI_VALCON,0) " 
			cQuery += "     ELSE COALESCE(SFI.FI_ISS,0) " 
			cQuery += " END REDUCAO, " 

			cQuery += " CASE " 
			cQuery += "     WHEN SL1.L1_SERRPS = '' THEN ROUND((SUM(COALESCE(SL1.L1_VLRTOT,0) ) - (COALESCE(SFI.FI_VALCON,0))),2 ) " 
			cQuery += "     ELSE ROUND((SUM(COALESCE(SL1.L1_VLRTOT,0) ) - (COALESCE(SFI.FI_ISS,0))),2 ) "
			cQuery += " END DIFERENCA "   	   
		Else
			cQuery += " COALESCE(SFI.FI_VALCON,0) + COALESCE(SFI.FI_ISS,0) REDUCAO, "
			cQuery += " ROUND((SUM(COALESCE(SL1.L1_VLRTOT,0) ) - (COALESCE(SFI.FI_VALCON,0) + COALESCE(SFI.FI_ISS,0) )),2 ) DIFERENCA "
		EndIf

		cQuery += " FROM " + RetSQLName("SL1") + " SL1  "
		cQuery += " FULL OUTER JOIN " + RetSQLName("SFI") + " SFI  "
		cQuery += " 	ON SL1.L1_EMISSAO = SFI.FI_DTMOVTO  "
		cQuery += " 	AND SL1.L1_PDV = SFI.FI_PDV  "
		cQuery += " 	AND SL1.L1_SERPDV = SFI.FI_SERPDV "	

		cQuery += " 	AND SFI.D_E_L_E_T_ = ' ' AND SL1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE   "
		cQuery += " 	(	SL1.D_E_L_E_T_ = ' '  "

		If !Empty(cFilSel) 
			cFilSL1 := LjCompFil(cFilSel, "SL1") 
			cFilSFI := LjCompFil(cFilSel, "SFI")	 
		EndIf

		cQuery += " 	AND SL1.L1_FILIAL IN("+cFilSL1+")"
		cQuery += " 	AND SL1.L1_EMISSAO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'  "
		cQuery += " 	AND SL1.L1_DOC <> ' '  "
		cQuery += " 	AND SL1.L1_SERIE <> ' '  "
		cQuery += " 	AND SL1.L1_PDV <> ' '  "
		cQuery += " 	AND SL1.L1_SITUA <> ' ' ) OR "
		cQuery += " 	(	SFI.D_E_L_E_T_ = ' '  "
		cQuery += " 	AND SFI.FI_FILIAL IN("+cFilSFI+")  "
		cQuery += " 	AND SFI.FI_DTMOVTO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'  "
		cQuery += " 	AND SFI.FI_PDV <> ' '  "
		cQuery += " 	AND SFI.FI_SITUA <> ' ' ) "

		If lLJ782Where
			LjGrvLog("Monitor de vendas","Antes da Chamada do Ponto de Entrada:LJ782WHERE")
			cLJ782Where := ExecBlock("LJ782WHERE",.F.,.F., {1})
			LjGrvLog("Monitor de vendas", "Apos a Chamada do Ponto de Entrada:LJ782WHERE", cLJ782Where)
			If ValType(cLJ782Where) == "C"
				cQuery += " " + cLJ782Where + " "
			EndIf
		EndIf

		cQuery += " GROUP BY  "
		cQuery += " SL1.L1_FILIAL, "
		cQuery += " SFI.FI_FILIAL, "
		cQuery += " SL1.L1_EMISSAO, "
		cQuery += " SFI.FI_DTMOVTO, "
		cQuery += " SL1.L1_PDV, "
		cQuery += " SFI.FI_PDV,  "   
		cQuery += IIF(MV_PAR05 == 1,"	SL1.L1_SERIE,","")	
		cQuery += " SFI.FI_VALCON, "	
		cQuery += IIF(MV_PAR05 == 1," L1_SERRPS,","")
		cQuery += " SFI.FI_ISS "	

		cQuery += " ORDER BY   "
		cQuery += " SL1.L1_FILIAL,  "
		cQuery += " SL1.L1_EMISSAO,  "
		cQuery += " SL1.L1_PDV,  "                                 
		cQuery += IIF(MV_PAR05 == 1,"	SL1.L1_SERIE,","")	
		cQuery += " SFI.FI_VALCON "	

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

		If (cAlias)->(Eof()) .OR. Empty(cFilSel)
			aBrw := {}
			aadd(aBrw,{"",0,0,0 })
			lEOF := .T.    
			MsgStop(STR0035,STR0036) // "Não existem dados para exibir. Verifique os parametros de filtro.", "Filtro sem resultado"
		EndIf

		While ! (cAlias)->(Eof())

			If AllTrim(cSitua) == STR0004 //"Diferenca PDV"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
				If (cAlias)->DIFERENCA < 0
					nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->L1_FILIAL})
					If nPosFil > 0
						aBrw[nPosFil][2] += (cAlias)->TOT_ORC     
						aBrw[nPosFil][3] += (cAlias)->REDUCAO		
						aBrw[nPosFil][4] += (cAlias)->DIFERENCA		
					Else
						aadd(aBrw,{(cAlias)->L1_FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
					EndIf
				EndIf
			ElseIf AllTrim(cSitua) == STR0005	// "Diferenca Retaguarda"
				If (cAlias)->DIFERENCA > 0
					nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->L1_FILIAL})
					If nPosFil > 0
						aBrw[nPosFil][2] += (cAlias)->TOT_ORC     
						aBrw[nPosFil][3] += (cAlias)->REDUCAO
						aBrw[nPosFil][4] += (cAlias)->DIFERENCA	
					Else
						aadd(aBrw,{(cAlias)->L1_FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
					EndIf
				EndIf	 
			ElseIf AllTrim(cSitua) == STR0006  // "Sem Diferenca"
				If (cAlias)->DIFERENCA == 0	
					nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->L1_FILIAL})
					If nPosFil > 0
						aBrw[nPosFil][2] += (cAlias)->TOT_ORC     
						aBrw[nPosFil][3] += (cAlias)->REDUCAO
						aBrw[nPosFil][4] += (cAlias)->DIFERENCA	
					Else
						aadd(aBrw,{(cAlias)->L1_FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
					EndIf
				EndIf	 			
			Else	
				nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->L1_FILIAL})
				If nPosFil > 0
					aBrw[nPosFil][2] += (cAlias)->TOT_ORC  
					aBrw[nPosFil][3] += (cAlias)->REDUCAO
					aBrw[nPosFil][4] += (cAlias)->DIFERENCA	
				Else
					aadd(aBrw,{(cAlias)->L1_FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
				EndIf	
			EndIf

			(cAlias)->(DbSkip())

		EndDo
		(cAlias)->(DbCloseArea())

		If Len(aBrw) > 0
			cFilBrw := aBrw[1][1]
		Else                     
			aadd(aBrw,{"",0,0,0})	
		EndIf

	EndIf

	aBrw1 := {}
	nValTotRet := 0
	nValTotPdv := 0
	nValTotDif := 0
	nQtdBrw1   := 0
	cFilBrwSL1 := FWxFilial("SL1", cFilBrw) 
	cFilBrwSFI := FWxFilial("SFI", cFilBrw)

	// Monta query para filtrar os dados de cada filial
	cQuery1 := " SELECT "																							
	cQuery1 += " COALESCE(SL1.L1_FILIAL,SFI.FI_FILIAL)	L1_FILIAL, "
	cQuery1 += " COALESCE(SFI.FI_FILIAL,SL1.L1_FILIAL)	FI_FILIAL, " 
	cQuery1 += IIF(MV_PAR05 == 1,"	SL1.L1_SERIE L1_SERIE,","")
	cQuery1 += " COALESCE(SL1.L1_EMISSAO,SFI.FI_DTMOVTO)	L1_EMISSAO,"
	cQuery1 += " COALESCE(SFI.FI_DTMOVTO,SL1.L1_EMISSAO)	FI_DTMOVTO,"
	cQuery1 += " COALESCE(SL1.L1_PDV,SFI.FI_PDV)			L1_PDV,"
	cQuery1 += " COALESCE(SFI.FI_PDV,SL1.L1_PDV)			FI_PDV,"
	cQuery1 += " ROUND(SUM(COALESCE(SL1.L1_VLRTOT,0)),2) TOT_ORC, "

	If MV_PAR05 == 1                
		cQuery1 += " CASE "  
		cQuery1 += "     WHEN SL1.L1_SERRPS = '' THEN COALESCE(SFI.FI_VALCON,0) " 
		cQuery1 += "     ELSE COALESCE(SFI.FI_ISS,0) " 
		cQuery1 += " END REDUCAO, " 

		cQuery1 += " CASE " 
		cQuery1 += "     WHEN SL1.L1_SERRPS = '' THEN ROUND((SUM(COALESCE(SL1.L1_VLRTOT,0) ) - (COALESCE(SFI.FI_VALCON,0))),2 ) " 
		cQuery1 += "     ELSE ROUND((SUM(COALESCE(SL1.L1_VLRTOT,0) ) - (COALESCE(SFI.FI_ISS,0))),2 ) "
		cQuery1 += " END DIFERENCA "       
	Else
		cQuery1 += " COALESCE(SFI.FI_VALCON,0) + COALESCE(SFI.FI_ISS,0)   REDUCAO, "
		cQuery1 += " ROUND((SUM(COALESCE(SL1.L1_VLRTOT,0) ) - (COALESCE(SFI.FI_VALCON,0) + COALESCE(SFI.FI_ISS,0) )),2 ) DIFERENCA "
	EndIf

	cQuery1 += " FROM " + RetSQLName("SL1") + " SL1  "
	cQuery1 += " FULL OUTER JOIN " + RetSQLName("SFI") + " SFI  "
	cQuery1 += " 	ON SL1.L1_EMISSAO = SFI.FI_DTMOVTO  "
	cQuery1 += " 	AND SL1.L1_PDV = SFI.FI_PDV  "
	cQuery1 += " 	AND SL1.L1_SERPDV = SFI.FI_SERPDV   "

	cQuery1 += " 	AND SFI.D_E_L_E_T_ = ' ' AND SL1.D_E_L_E_T_ = ' ' "
	cQuery1 += " WHERE   "
	cQuery1 += " 	(	SL1.D_E_L_E_T_ = ' '  "

	cQuery1 += " 	AND SL1.L1_FILIAL = '"+cFilBrwSL1+"' "
	cQuery1 += " 	AND SL1.L1_EMISSAO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'"
	cQuery1 += " 	AND SL1.L1_DOC <> ' '  "
	cQuery1 += " 	AND SL1.L1_SERIE <> ' '  "
	cQuery1 += " 	AND SL1.L1_PDV <> ' '  "
	cQuery1 += " 	AND SL1.L1_SITUA <> ' ' ) OR "
	cQuery1 += " 	(	SFI.D_E_L_E_T_ = ' '  "
	cQuery1 += " 	AND SFI.FI_FILIAL = '"+cFilBrwSFI+"' "
	cQuery1 += " 	AND SFI.FI_DTMOVTO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'"
	cQuery1 += " 	AND SFI.FI_PDV <> ' '  "
	cQuery1 += " 	AND SFI.FI_SITUA <> ' ' ) "

	If lLJ782Where
		LjGrvLog("Monitor de vendas","Antes da Chamada do Ponto de Entrada:LJ782WHERE")
		cLJ782Where := ExecBlock("LJ782WHERE",.F.,.F., {1})
		LjGrvLog("Monitor de vendas", "Apos a Chamada do Ponto de Entrada:LJ782WHERE", cLJ782Where)
		If ValType(cLJ782Where) == "C"
			cQuery1 += " " + cLJ782Where + " "
		EndIf
	EndIf

	cQuery1 += " GROUP BY  "
	cQuery1 += " SL1.L1_FILIAL, "
	cQuery1 += " SFI.FI_FILIAL, "
	cQuery1 += " SL1.L1_EMISSAO, "
	cQuery1 += " SFI.FI_DTMOVTO, "
	cQuery1 += " SL1.L1_PDV, "
	cQuery1 += " SFI.FI_PDV,  "   
	cQuery1 += IIF(MV_PAR05 == 1,"	SL1.L1_SERIE,","")
	cQuery1 += " SFI.FI_VALCON, "
	cQuery1 += IIF(MV_PAR05 == 1," L1_SERRPS,","")
	cQuery1 += " SFI.FI_ISS "

	cQuery1 += " ORDER BY   "
	cQuery1 += " SL1.L1_FILIAL,  "
	cQuery1 += " SL1.L1_EMISSAO,  "
	cQuery1 += " SL1.L1_PDV,  "
	cQuery1 += IIF(MV_PAR05 == 1,"	SL1.L1_SERIE,","")
	cQuery1 += " SFI.FI_VALCON "  

	cQuery1 := ChangeQuery(cQuery1)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery1), cAlias1, .T., .T.)

	If (cAlias1)->(Eof())
		aBrw := {} 
		aBrw1 := {}
		aadd(aBrw1,{"","","","","","",0,0,0})    
		If !lEOF 
			MsgStop(STR0035,STR0036) // "Não existem dados para exibir. Verifique os parametros de filtro.", "Filtro sem resultado"	
		EndIf
	EndIf

	While !(cAlias1)->(Eof())

		If AllTrim(cSitua) == STR0004 //"DIFERENCA PDV"
			If (cAlias1)->DIFERENCA < 0
				aadd(aBrw1,{(cAlias1)->L1_FILIAL,(cAlias1)->L1_FILIAL,(cAlias1)->L1_EMISSAO,(cAlias1)->L1_PDV,IIF(MV_PAR05==1,(cAlias1)->L1_SERIE,""),(cAlias1)->TOT_ORC,;
				(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

				nValTotRet += (cAlias1)->TOT_ORC				
				nValTotPdv += (cAlias1)->REDUCAO
				nValTotDif += (cAlias1)->DIFERENCA
				nQtdBrw1 ++
			EndIf
		ElseIf AllTrim(cSitua) == STR0005 //"DIFERENCA RETAGUARDA"	
			If (cAlias1)->DIFERENCA > 0
				aadd(aBrw1,{(cAlias1)->L1_FILIAL,(cAlias1)->L1_FILIAL,(cAlias1)->L1_EMISSAO,(cAlias1)->L1_PDV,IIF(MV_PAR05==1,(cAlias1)->L1_SERIE,""),(cAlias1)->TOT_ORC,;
				(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

				nValTotRet += (cAlias1)->TOT_ORC				
				nValTotPdv += (cAlias1)->REDUCAO
				nValTotDif += (cAlias1)->DIFERENCA
				nQtdBrw1 ++
			EndIf	
		ElseIf AllTrim(cSitua) == STR0006 //"SEM DIFERENCA"	
			If (cAlias1)->DIFERENCA == 0
				aadd(aBrw1,{(cAlias1)->L1_FILIAL,(cAlias1)->L1_FILIAL,(cAlias1)->L1_EMISSAO,(cAlias1)->L1_PDV,IIF(MV_PAR05==1,(cAlias1)->L1_SERIE,""),(cAlias1)->TOT_ORC,;
				(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

				nValTotRet += (cAlias1)->TOT_ORC				
				nValTotPdv += (cAlias1)->REDUCAO
				nValTotDif += (cAlias1)->DIFERENCA
				nQtdBrw1 ++
			EndIf	
		Else
			aadd(aBrw1,{(cAlias1)->L1_FILIAL,(cAlias1)->L1_FILIAL,(cAlias1)->L1_EMISSAO,(cAlias1)->L1_PDV,IIF(MV_PAR05==1,(cAlias1)->L1_SERIE,""),(cAlias1)->TOT_ORC,;
			(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

			nValTotRet += (cAlias1)->TOT_ORC	
			nValTotPdv += (cAlias1)->REDUCAO
			nValTotDif += (cAlias1)->DIFERENCA
			nQtdBrw1 ++
		EndIf

		(cAlias1)->(DbSkip())

	EndDo


	(cAlias1)->(DbCloseArea())

	RestArea(aArea)

	If Len(aBrw) == 0
		aadd(aBrw,{"",0,0,0})	
	EndIf

	If Len(aBrw1) == 0
		aadd(aBrw1,{"","","","","","",0,0,0}) 
	EndIf

	If oDlg <> Nil    
		If Len(aBrw) > 0                  
			oBrw:SetArray(aBrw) 
		EndIf	
		If Len(aBrw1) > 0                   
			oBrw1:SetArray(aBrw1) 
		EndIf			
		oDlg:Refresh()
		oBrw:refresh()   
		oBrw1:refresh()   
		oPanel1:refresh() 
		oBrw1:SetFocus() 
		oBrw:SetFocus()
	EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Lj782Mark
Função para marcar/desmarcar todas as filiais

@author    Vendas CRM
@version   11.80
@since     17/11/2016
@Return 	lRet - Marcado/Desmarcado

/*/
//------------------------------------------------------------------------------------------
Static Function Lj782Mark(aCritica,lMarkAll)
	Local lRet := .F.
	Local nI := 0

	Default aCritica := {}
	Default lMarkAll := .F.

	For nI := 1 To Len(aCritica)
		aCritica[nI,3] := !lMarkAll
	Next nI
	lRet := !lMarkAll

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FiltraSFISD2
Função para filtrar os dados a exibir

@author    Vendas CRM
@version   11.8
@since     25/09/2016

/*/
//------------------------------------------------------------------------------------------
Function FiltraSFISD2(oDlg,oBrw1,oPanel1,aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,nValTotRet,nValTotPdv,nValTotDif,cFilBrw,lInicio,oBrw,aBrw,cSitua,nQtdBrw1)

	Local aArea     	:= GetArea()
	Local cAlias		:= GetNextAlias()	// Alias para a query    
	Local cQuery  		:= ""				// Query para filtrar os dados do log
	Local cAlias1		:= GetNextAlias()	// Alias para a query    
	Local cQuery1  		:= ""				// Query para filtrar os dados do log
	Local lRet			:= .T.
	Local nPosFil		:= 0
	Local lEOF			:= .F.
	local nI			:= 0
	local cFil			:= ""	
	local aCopiaFil		:= {}
	local lLJ782Where	:= ExistBlock("LJ782WHERE")
	local cLJ782Where	:= ""
	Local cFilSD2       := ""    
	Local cFilSFI       := ""
	Local cFilBrwSD2    := ""
	Local cFilBrwSFI    := ""

	Default oDlg		:= Nil 
	Default oBrw1		:= Nil
	Default aBrw1       := {} 
	Default oBrw		:= Nil      
	Default oPanel1		:= Nil
	Default aBrw	    := {}
	Default cFilSel		:= ""
	Default dDeDt		:= ""
	Default dAtDt     	:= ""   
	Default lAllFil		:= .T.  
	Default nValTotRet	:= 0
	Default nValTotPdv	:= 0
	Default nValTotDif	:= 0
	Default cFilBrw		:= cFilAnt
	Default lInicio		:= .F.
	Default cSitua		:= ""
	Default nQtdBrw1	:= 0

	If lInicio 

		aBrw := {}	

		//Monta query para filtrar os dados de cada filial
		cQuery := " SELECT "
		cQuery += " COALESCE(FI_FILIAL	,D2_FILIAL	) FILIAL, "
		cQuery += " COALESCE(D2_FILIAL	,FI_FILIAL	) D2_FILIAL, "
		cQuery += IIF(MV_PAR05 == 1," D2_SERIE D2_SERIE,","")
		cQuery += " COALESCE(FI_DTMOVTO	,D2_EMISSAO	) EMISSAO, "
		cQuery += " COALESCE(D2_EMISSAO	,FI_DTMOVTO	) D2_EMISSAO, "
		cQuery += " COALESCE(FI_PDV		,D2_PDV		) PDV, "
		cQuery += " COALESCE(D2_PDV		,FI_PDV		) D2_PDV, "
		cQuery += " FI_CANCEL	, "	
		cQuery += " COALESCE(SUM(D2_TOTAL) + SUM(D2_VALACRS),0) TOT_ORC, "						

		If MV_PAR05 == 1                
			cQuery += " CASE "  
			cQuery += "     WHEN L1.L1_SERRPS = '' THEN COALESCE(FI.FI_VALCON,0) " 
			cQuery += "     ELSE COALESCE(FI.FI_ISS,0) " 
			cQuery += " END REDUCAO, " 

			cQuery += " CASE " 
			cQuery += "     WHEN L1.L1_SERRPS = '' THEN COALESCE(ROUND(FI_VALCON,2),0) - COALESCE(ROUND(SUM(D2_TOTAL) + SUM(D2_VALACRS),2),0) " 
			cQuery += "     ELSE COALESCE(ROUND(FI_ISS,2),0) - COALESCE(ROUND(SUM(D2_TOTAL) + SUM(D2_VALACRS),2),0) "
			cQuery += " END DIFERENCA "       
		Else
			cQuery += " COALESCE(FI_VALCON,0) + COALESCE(FI_ISS,0) REDUCAO, "
			cQuery += " COALESCE(ROUND(FI_VALCON,2),0) + COALESCE(ROUND(FI_ISS,2),0) - COALESCE(ROUND(SUM(D2_TOTAL) + SUM(D2_VALACRS),2),0) DIFERENCA "
		EndIf

		cQuery += " FROM " + RetSQLName("SFI") + " FI FULL OUTER JOIN " + RetSQLName("SL1") + " L1 ON " 
		cQuery += "    FI.FI_DTMOVTO = L1.L1_EMISSAO "
		cQuery += "    AND FI.FI_PDV = L1.L1_PDV "
		cQuery += "    AND FI.FI_SERPDV = L1.L1_SERPDV " 
		cQuery += "    AND FI.D_E_L_E_T_ = ' ' AND L1.D_E_L_E_T_ = ' ' "
		cQuery += " FULL OUTER JOIN " + RetSQLName("SD2") + " D2 ON "		
		cQuery += "   (L1.L1_FILIAL = D2.D2_FILIAL "		
		cQuery += "   AND L1.L1_DOC = D2.D2_DOC "
		cQuery += "   AND L1.L1_SERIE = D2.D2_SERIE "
		cQuery += "   AND L1.L1_PDV = D2.D2_PDV "
		cQuery += "   AND L1.L1_EMISSAO = D2.D2_EMISSAO "
		cQuery += "   AND L1.D_E_L_E_T_= ' ' AND D2.D_E_L_E_T_ = ' ') "
		cQuery += " WHERE "
		cQuery += " 	(FI.FI_DTMOVTO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'  "
		cQuery += " 	 AND FI.D_E_L_E_T_ = ' ' "

		If !Empty(cFilSel)
			cFilSD2 := LjCompFil(cFilSel, "SD2")	
			cFilSFI := LjCompFil(cFilSel, "SFI")
		EndIf

		cQuery += " AND FI_FILIAL IN("+cFilSFI+")" 
		cQuery += " ) OR ( "
		cQuery += " 	D2.D2_EMISSAO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'  "
		cQuery += " 	AND D2.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND SUBSTRING (D2.D2_SERIE,1,1) <> 'X' "
		cQuery += " 	AND D2_FILIAL IN("+cFilSD2+")" 
		cQuery += " 	AND D2_PDV <> '' ) "  

		If lLJ782Where
			LjGrvLog("Monitor de vendas","Antes da Chamada do Ponto de Entrada:LJ782WHERE")
			cLJ782Where := ExecBlock("LJ782WHERE",.F.,.F., {2})
			LjGrvLog("Monitor de vendas", "Apos a Chamada do Ponto de Entrada:LJ782WHERE", cLJ782Where)
			If ValType(cLJ782Where) == "C"
				cQuery += " " + cLJ782Where + " "
			EndIf
		EndIf	

		cQuery += " GROUP BY "
		cQuery += " FI_FILIAL, "
		cQuery += " D2_FILIAL, "
		cQuery += IIF(MV_PAR05 == 1," D2_SERIE,","")	
		cQuery += " FI_DTMOVTO, "
		cQuery += " D2_EMISSAO, "
		cQuery += " FI_PDV, "
		cQuery += " D2_PDV, " 
		cQuery += " FI_CANCEL, "
		cQuery += " FI_VALCON, "
		cQuery += IIF(MV_PAR05 == 1," L1_SERRPS,","")
		cQuery += " FI_ISS "		
		cQuery += " ORDER BY FI_DTMOVTO, FI_PDV "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

		If (cAlias)->(Eof()) .OR. Empty(cFilSel)
			aBrw := {}
			aadd(aBrw,{"",0,0,0 })
			lEOF := .T.    
			MsgStop(STR0035,STR0036) // "Não existem dados para exibir. Verifique os parametros de filtro.", "Filtro sem resultado"
		EndIf

		While ! (cAlias)->(Eof())

			If AllTrim(cSitua) == STR0004 //"Diferenca PDV"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
				If (cAlias)->DIFERENCA < 0
					nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->FILIAL})
					If nPosFil > 0
						aBrw[nPosFil][2] += (cAlias)->TOT_ORC     
						aBrw[nPosFil][3] += (cAlias)->REDUCAO		
						aBrw[nPosFil][4] += (cAlias)->DIFERENCA		
					Else
						aadd(aBrw,{(cAlias)->FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
					EndIf
				EndIf
			ElseIf AllTrim(cSitua) == STR0005	// "Diferenca Retaguarda"
				If (cAlias)->DIFERENCA > 0
					nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->FILIAL})
					If nPosFil > 0
						aBrw[nPosFil][2] += (cAlias)->TOT_ORC     
						aBrw[nPosFil][3] += (cAlias)->REDUCAO
						aBrw[nPosFil][4] += (cAlias)->DIFERENCA	
					Else
						aadd(aBrw,{(cAlias)->FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
					EndIf
				EndIf	 
			ElseIf AllTrim(cSitua) == STR0006  // "Sem Diferenca"
				If (cAlias)->DIFERENCA == 0	
					nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->FILIAL})
					If nPosFil > 0
						aBrw[nPosFil][2] += (cAlias)->TOT_ORC     
						aBrw[nPosFil][3] += (cAlias)->REDUCAO
						aBrw[nPosFil][4] += (cAlias)->DIFERENCA	
					Else
						aadd(aBrw,{(cAlias)->FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
					EndIf
				EndIf	 			
			Else	
				nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->FILIAL})
				If nPosFil > 0
					aBrw[nPosFil][2] += (cAlias)->TOT_ORC  
					aBrw[nPosFil][3] += (cAlias)->REDUCAO
					aBrw[nPosFil][4] += (cAlias)->DIFERENCA	
				Else
					aadd(aBrw,{(cAlias)->FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
				EndIf	
			EndIf

			(cAlias)->(DbSkip())

		EndDo
		(cAlias)->(DbCloseArea())

		If Len(aBrw) > 0
			cFilBrw := aBrw[1][1]
		Else                     
			aadd(aBrw,{"",0,0,0})	
		EndIf

	EndIf

	aBrw1 := {}
	nValTotRet := 0
	nValTotPdv := 0
	nValTotDif := 0
	nQtdBrw1   := 0
	cFilBrwSD2 := FWxFilial("SD2", cFilBrw) 
	cFilBrwSFI := FWxFilial("SFI", cFilBrw)

	//Monta query para filtrar os dados de cada filial
	cQuery1 := " SELECT "
	cQuery1 += " COALESCE(FI_FILIAL	,D2_FILIAL	) FI_FILIAL, "
	cQuery1 += " COALESCE(D2_FILIAL	,FI_FILIAL	) D2_FILIAL, "
	cQuery1 += IIF(MV_PAR05 == 1," D2_SERIE D2_SERIE,","")
	cQuery1 += " COALESCE(FI_DTMOVTO	,D2_EMISSAO	) FI_DTMOVTO, "
	cQuery1 += " COALESCE(D2_EMISSAO	,FI_DTMOVTO	) D2_EMISSAO, "
	cQuery1 += " COALESCE(FI_PDV		,D2_PDV		) FI_PDV, "
	cQuery1 += " COALESCE(D2_PDV		,FI_PDV		) D2_PDV, "
	cQuery1 += " FI_CANCEL	, "
	cQuery1 += " COALESCE(SUM(D2_TOTAL) + SUM(D2_VALACRS),0) TOT_ORC, "

	If MV_PAR05 == 1                
		cQuery1 += " CASE "  
		cQuery1 += "     WHEN L1.L1_SERRPS = '' THEN COALESCE(FI.FI_VALCON,0) " 
		cQuery1 += "     ELSE COALESCE(FI.FI_ISS,0) " 
		cQuery1 += " END REDUCAO, " 

		cQuery1 += " CASE " 
		cQuery1 += "     WHEN L1.L1_SERRPS = '' THEN COALESCE(ROUND(FI_VALCON,2),0) - COALESCE(ROUND(SUM(D2_TOTAL) + SUM(D2_VALACRS),2),0) " 
		cQuery1 += "     ELSE COALESCE(ROUND(FI_ISS,2),0) - COALESCE(ROUND(SUM(D2_TOTAL) + SUM(D2_VALACRS),2),0) "
		cQuery1 += " END DIFERENCA "       
	Else
		cQuery1 += " COALESCE(FI_VALCON,0) + COALESCE(FI_ISS,0) REDUCAO, "
		cQuery1 += " COALESCE(ROUND(FI_VALCON,2),0) + COALESCE(ROUND(FI_ISS,2),0) - COALESCE(ROUND(SUM(D2_TOTAL) + SUM(D2_VALACRS),2),0) DIFERENCA "
	EndIf

	cQuery1 += " FROM " + RetSQLName("SFI") + " FI FULL OUTER JOIN " + RetSQLName("SL1") + " L1 ON " 
	cQuery1 += "    FI.FI_DTMOVTO = L1.L1_EMISSAO "
	cQuery1 += "    AND FI.FI_PDV = L1.L1_PDV "
	cQuery1 += "    AND FI.FI_SERPDV = L1.L1_SERPDV " 
	cQuery1 += "    AND FI.D_E_L_E_T_ = ' ' AND L1.D_E_L_E_T_ = ' ' "
	cQuery1 += " FULL OUTER JOIN " + RetSQLName("SD2") + " D2 ON "       
	cQuery1 += "   (L1.L1_FILIAL = D2.D2_FILIAL "        
	cQuery1 += "   AND L1.L1_DOC = D2.D2_DOC "
	cQuery1 += "   AND L1.L1_SERIE = D2.D2_SERIE "
	cQuery1 += "   AND L1.L1_PDV = D2.D2_PDV "
	cQuery1 += "   AND L1.L1_EMISSAO = D2.D2_EMISSAO "
	cQuery1 += "   AND L1.D_E_L_E_T_= ' ' AND D2.D_E_L_E_T_ = ' ') "
	cQuery1 += " WHERE "
	cQuery1 += " 	(FI.FI_DTMOVTO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'  "
	cQuery1 += " 	 AND FI.D_E_L_E_T_ = ' ' "
	cQuery1 += " 	 AND FI_FILIAL = '"+cFilBrwSFI+"'"
	cQuery1 += " ) OR ( "
	cQuery1 += " 	D2.D2_EMISSAO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'  "
	cQuery1 += " 	AND D2.D_E_L_E_T_ = ' ' "
	cQuery1 += " 	AND SUBSTRING (D2.D2_SERIE,1,1) <> 'X' "
	cQuery1 += " 	AND D2_FILIAL = '"+cFilBrwSD2+"' "  
	cQuery1 += " 	AND D2_PDV <> '') "

	If lLJ782Where
		LjGrvLog("Monitor de vendas","Antes da Chamada do Ponto de Entrada:LJ782WHERE")
		cLJ782Where := ExecBlock("LJ782WHERE",.F.,.F., {2})
		LjGrvLog("Monitor de vendas", "Apos a Chamada do Ponto de Entrada:LJ782WHERE", cLJ782Where)
		If ValType(cLJ782Where) == "C"
			cQuery1 += " " + cLJ782Where + " "
		EndIf
	EndIf

	cQuery1 += " GROUP BY "
	cQuery1 += " FI_FILIAL, "
	cQuery1 += " D2_FILIAL, "
	cQuery1 += IIF(MV_PAR05 == 1," D2_SERIE,","")
	cQuery1 += " FI_DTMOVTO, "
	cQuery1 += " D2_EMISSAO, "
	cQuery1 += " FI_PDV, "
	cQuery1 += " D2_PDV, " 
	cQuery1 += " FI_CANCEL, "
	cQuery1 += " FI_VALCON, "
	cQuery1 += IIF(MV_PAR05 == 1," L1_SERRPS,","")
	cQuery1 += " FI_ISS "
	cQuery1 += " ORDER BY FI_DTMOVTO, FI_PDV "

	cQuery1 := ChangeQuery(cQuery1)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery1), cAlias1, .T., .T.)

	If (cAlias1)->(Eof())
		aBrw := {} 
		aBrw1 := {}
		aadd(aBrw1,{"","","","","","",0,0,0})    
		If !lEOF 
			MsgStop(STR0035,STR0036) // "Não existem dados para exibir. Verifique os parametros de filtro.", "Filtro sem resultado"	
		EndIf
	EndIf

	While !(cAlias1)->(Eof())

		If AllTrim(cSitua) == STR0004 //"Diferenca PDV"
			If (cAlias1)->DIFERENCA < 0
				aadd(aBrw1,{(cAlias1)->FI_FILIAL,(cAlias1)->FI_FILIAL,(cAlias1)->FI_DTMOVTO,(cAlias1)->FI_PDV,IIF(MV_PAR05 == 1,(cAlias1)->D2_SERIE,""),(cAlias1)->TOT_ORC,;
				(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

				nValTotRet += (cAlias1)->TOT_ORC				
				nValTotPdv += (cAlias1)->REDUCAO
				nValTotDif += (cAlias1)->DIFERENCA
				nQtdBrw1 ++
			EndIf
		ElseIf AllTrim(cSitua) == STR0005 //"Diferenca Retaguarda"	
			If (cAlias1)->DIFERENCA > 0
				aadd(aBrw1,{(cAlias1)->FI_FILIAL,(cAlias1)->FI_FILIAL,(cAlias1)->FI_DTMOVTO,(cAlias1)->FI_PDV,IIF(MV_PAR05 == 1,(cAlias1)->D2_SERIE,""),(cAlias1)->TOT_ORC,;
				(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

				nValTotRet += (cAlias1)->TOT_ORC				
				nValTotPdv += (cAlias1)->REDUCAO
				nValTotDif += (cAlias1)->DIFERENCA
				nQtdBrw1 ++
			EndIf	
		ElseIf AllTrim(cSitua) == STR0006 //"Sem Diferenca"	
			If (cAlias1)->DIFERENCA == 0
				aadd(aBrw1,{(cAlias1)->FI_FILIAL,(cAlias1)->FI_FILIAL,(cAlias1)->FI_DTMOVTO,(cAlias1)->FI_PDV,IIF(MV_PAR05 == 1,(cAlias1)->D2_SERIE,""),(cAlias1)->TOT_ORC,;
				(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

				nValTotRet += (cAlias1)->TOT_ORC				
				nValTotPdv += (cAlias1)->REDUCAO
				nValTotDif += (cAlias1)->DIFERENCA
				nQtdBrw1 ++
			EndIf	
		Else
			aadd(aBrw1,{(cAlias1)->FI_FILIAL,(cAlias1)->FI_FILIAL,(cAlias1)->FI_DTMOVTO,(cAlias1)->FI_PDV,IIF(MV_PAR05 == 1,(cAlias1)->D2_SERIE,""),(cAlias1)->TOT_ORC,;
			(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

			nValTotRet += (cAlias1)->TOT_ORC	
			nValTotPdv += (cAlias1)->REDUCAO
			nValTotDif += (cAlias1)->DIFERENCA
			nQtdBrw1 ++
		EndIf

		(cAlias1)->(DbSkip())

	EndDo


	(cAlias1)->(DbCloseArea())

	RestArea(aArea)

	If Len(aBrw) == 0
		aadd(aBrw,{"",0,0,0})	
	EndIf

	If Len(aBrw1) == 0
		aadd(aBrw1,{"","","","","","",0,0,0}) 
	EndIf

	If oDlg <> Nil    
		If Len(aBrw) > 0                  
			oBrw:SetArray(aBrw) 
		EndIf	
		If Len(aBrw1) > 0                   
			oBrw1:SetArray(aBrw1) 
		EndIf			
		oDlg:Refresh()
		oBrw:refresh()   
		oBrw1:refresh()   
		oPanel1:refresh() 
		oBrw1:SetFocus() 
		oBrw:SetFocus()
	EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FiltraSL1SD2
Função para filtrar os dados a exibir

@author    Vendas CRM
@version   11.8
@since     25/09/2016

/*/
//------------------------------------------------------------------------------------------
Function FiltraSL1SD2(oDlg,oBrw1,oPanel1,aBrw1,dDeDt,dAtDt,cFilSel,lAllFil,nValTotRet,nValTotPdv,nValTotDif,cFilBrw,lInicio,oBrw,aBrw,cSitua,nQtdBrw1)

	Local aArea     	:= GetArea()
	Local cAlias		:= GetNextAlias()	// Alias para a query    
	Local cQuery  		:= ""				// Query para filtrar os dados do log
	Local cAlias1		:= GetNextAlias()	// Alias para a query    
	Local cQuery1  		:= ""				// Query para filtrar os dados do log
	Local lRet			:= .T.
	Local nPosFil		:= 0
	Local lEOF			:= .F.
	local nI			:= 0
	local cFil			:= ""	
	local aCopiaFil		:= {}
	local lLJ782Where	:= ExistBlock("LJ782WHERE")
	local cLJ782Where	:= ""
	Local cFilSL1       := ""    
	Local cFilSD2       := ""
	Local cFilBrwSL1    := ""
	Local cFilBrwSD2    := ""

	Default oDlg		:= Nil 
	Default oBrw1		:= Nil
	Default aBrw1       := {} 
	Default oBrw		:= Nil      
	Default oPanel1		:= Nil
	Default aBrw	    := {}
	Default cFilSel		:= ""
	Default dDeDt		:= ""
	Default dAtDt     	:= ""   
	Default lAllFil		:= .T.  
	Default nValTotRet	:= 0
	Default nValTotPdv	:= 0
	Default nValTotDif	:= 0
	Default cFilBrw		:= cFilAnt
	Default lInicio		:= .F.
	Default cSitua		:= ""
	Default nQtdBrw1	:= 0

	cFilSel := AllTrim(cFilSel)


	If lInicio 

		aBrw := {}	

		//Monta query para filtrar os dados de cada filial
		cQuery := " SELECT "
		cQuery += " L1_NUM,"
		cQuery += " COALESCE(L1_FILIAL, D2_FILIAL) L1_FILIAL "
		cQuery += " ,COALESCE(D2_FILIAL, L1_FILIAL) D2_FILIAL "
		cQuery += IIF(MV_PAR05 == 1,",	L1_SERIE L1_SERIE","")
		cQuery += " ,COALESCE(L1_PDV, D2_PDV) L1_PDV "
		cQuery += " ,COALESCE(D2_PDV, L1_PDV) D2_PDV "
		cQuery += " ,COALESCE(L1_EMISNF, D2_EMISSAO) L1_EMISSAO "
		cQuery += " ,COALESCE(D2_EMISSAO, L1_EMISNF) D2_EMISSAO "
		cQuery += " ,COALESCE(L1_DOC, D2_DOC) L1_DOC "
		cQuery += " ,COALESCE(D2_DOC, D2_DOC) D2_DOC "
		cQuery += " ,COALESCE(L1_VLRLIQ,0) TOT_ORC, "
		cQuery += " L1_SITUA, "
		cQuery += " COALESCE(SUM(D2_TOTAL),0) + COALESCE(SUM(D2_VALACRS),0) REDUCAO, "
		cQuery += " COALESCE(ROUND(L1_VLRLIQ,2),0) - COALESCE(ROUND(SUM(D2_TOTAL) + SUM(D2_VALACRS),2),0) DIFERENCA  "
		cQuery += " FROM " + RetSQLName("SL1") + " L1  "
		cQuery += " FULL OUTER JOIN " + RetSQLName("SD2") + " D2 ON  "
		cQuery += " 	(L1.L1_DOC = D2.D2_DOC AND L1_SERIE = D2_SERIE AND L1.L1_FILIAL = D2.D2_FILIAL AND D2.D_E_L_E_T_ = ' '  AND L1.D_E_L_E_T_ = ' ')   "
		cQuery += " WHERE   "
		cQuery += " 	(	L1.D_E_L_E_T_ = ' ' "

		If !Empty(cFilSel)
			cFilSL1 := LjCompFil(cFilSel, "SL1")    
			cFilSD2 := LjCompFil(cFilSel, "SD2")
		EndIf

		cQuery += " AND L1.L1_FILIAL IN("+cFilSL1+")"
		cQuery += " AND L1.L1_EMISNF BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'  "
		cQuery += " 	AND SUBSTRING (L1_SERIE,1,1) <> 'X' AND L1.L1_DOC <> ' ' AND L1.L1_PDV <> '') "
		cQuery += " 	OR "
		cQuery += " 	(	D2.D_E_L_E_T_ = ' ' AND D2.D2_FILIAL IN("+cFilSD2+") AND D2.D2_EMISSAO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'"
		cQuery += " 	AND SUBSTRING (D2_SERIE,1,1) <> 'X' AND D2.D2_DOC <> ' ' AND D2.D2_PDV <> '') "

		If lLJ782Where
			LjGrvLog("Monitor de vendas","Antes da Chamada do Ponto de Entrada:LJ782WHERE")
			cLJ782Where := ExecBlock("LJ782WHERE",.F.,.F., {3})
			LjGrvLog("Monitor de vendas", "Apos a Chamada do Ponto de Entrada:LJ782WHERE", cLJ782Where)
			If ValType(cLJ782Where) == "C"
				cQuery += " " + cLJ782Where + " "
			EndIf
		EndIf

		cQuery += " GROUP BY  "
		cQuery += " L1_NUM, "
		cQuery += " L1_FILIAL, "
		cQuery += " D2_FILIAL, "
		cQuery += " L1_PDV, "
		cQuery += " D2_PDV,  "
		cQuery += IIF(MV_PAR05 == 1," L1_SERIE,","")
		cQuery += " L1_EMISNF, "
		cQuery += " D2_EMISSAO, "
		cQuery += " L1_DOC, "
		cQuery += " D2_DOC,  "
		cQuery += " L1_VLRLIQ, "
		cQuery += " L1_SITUA  "
		cQuery += " ORDER BY   "
		cQuery += " L1_EMISNF, "
		cQuery += " L1_PDV "				
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

		If (cAlias)->(Eof()) .OR. Empty(cFilSel)
			aBrw := {}
			aadd(aBrw,{"",0,0,0 })
			lEOF := .T.    
			MsgStop(STR0035,STR0036) // "Não existem dados para exibir. Verifique os parametros de filtro.", "Filtro sem resultado"
		EndIf

		While ! (cAlias)->(Eof())

			If AllTrim(cSitua) == STR0004 //"Diferenca PDV"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
				If (cAlias)->DIFERENCA < 0
					nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->L1_FILIAL})
					If nPosFil > 0
						aBrw[nPosFil][2] += (cAlias)->TOT_ORC     
						aBrw[nPosFil][3] += (cAlias)->REDUCAO		
						aBrw[nPosFil][4] += (cAlias)->DIFERENCA		
					Else
						aAdd(aBrw,{(cAlias)->L1_FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
					EndIf
				EndIf
			ElseIf AllTrim(cSitua) == STR0005	// "Diferenca Retaguarda"
				If (cAlias)->DIFERENCA > 0
					nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->L1_FILIAL})
					If nPosFil > 0
						aBrw[nPosFil][2] += (cAlias)->TOT_ORC     
						aBrw[nPosFil][3] += (cAlias)->REDUCAO
						aBrw[nPosFil][4] += (cAlias)->DIFERENCA	
					Else
						aAdd(aBrw,{(cAlias)->L1_FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })       
					EndIf
				EndIf	 
			ElseIf AllTrim(cSitua) == STR0006  // "Sem Diferenca"
				If (cAlias)->DIFERENCA == 0	
					nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->L1_FILIAL})
					If nPosFil > 0
						aBrw[nPosFil][2] += (cAlias)->TOT_ORC     
						aBrw[nPosFil][3] += (cAlias)->REDUCAO
						aBrw[nPosFil][4] += (cAlias)->DIFERENCA	
					Else
						aAdd(aBrw,{(cAlias)->L1_FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
					EndIf
				EndIf	 			
			Else	
				nPosFil	:= aScan(aBrw,{|x| x[1	] == (cAlias)->L1_FILIAL})
				If nPosFil > 0
					aBrw[nPosFil][2] += (cAlias)->TOT_ORC  
					aBrw[nPosFil][3] += (cAlias)->REDUCAO
					aBrw[nPosFil][4] += (cAlias)->DIFERENCA	
				Else
					aAdd(aBrw,{(cAlias)->L1_FILIAL,(cAlias)->TOT_ORC,(cAlias)->REDUCAO,(cAlias)->DIFERENCA })    
				EndIf	
			EndIf

			(cAlias)->(DbSkip())

		EndDo
		(cAlias)->(DbCloseArea())

		If Len(aBrw) > 0
			cFilBrw := aBrw[1][1]
		Else                     
			aadd(aBrw,{"",0,0,0})	
		EndIf

	EndIf

	aBrw1 := {}
	nValTotRet := 0
	nValTotPdv := 0
	nValTotDif := 0
	nQtdBrw1   := 0
	cFilBrwSL1 := FWxFilial("SL1", cFilBrw) 
	cFilBrwSD2 := FWxFilial("SD2", cFilBrw)

	//Monta query para filtrar os dados de cada filial
	cQuery1 := " SELECT "
	cQuery1 += " L1_NUM,"
	cQuery1 += " COALESCE(L1_FILIAL, D2_FILIAL) L1_FILIAL "
	cQuery1 += " ,COALESCE(D2_FILIAL, L1_FILIAL) D2_FILIAL "
	cQuery1 += IIF(MV_PAR05 == 1,",	L1_SERIE L1_SERIE","")
	cQuery1 += " ,COALESCE(L1_PDV, D2_PDV) L1_PDV "
	cQuery1 += " ,COALESCE(D2_PDV, L1_PDV) D2_PDV "
	cQuery1 += " ,COALESCE(L1_EMISNF, D2_EMISSAO) L1_EMISSAO "
	cQuery1 += " ,COALESCE(D2_EMISSAO, L1_EMISNF) D2_EMISSAO "
	cQuery1 += " ,COALESCE(L1_DOC, D2_DOC) L1_DOC "
	cQuery1 += " ,COALESCE(D2_DOC, D2_DOC) D2_DOC "
	cQuery1 += " ,COALESCE(L1_VLRLIQ,0) TOT_ORC, "
	cQuery1 += " L1_SITUA, "
	cQuery1 += " COALESCE(SUM(D2_TOTAL),0) + COALESCE(SUM(D2_VALACRS),0) REDUCAO, "
	cQuery1 += " COALESCE(ROUND(L1_VLRLIQ,2),0) - COALESCE(ROUND(SUM(D2_TOTAL) + SUM(D2_VALACRS),2),0) DIFERENCA  "
	cQuery1 += " FROM " + RetSQLName("SL1") + " L1  "
	cQuery1 += " FULL OUTER JOIN " + RetSQLName("SD2") + " D2 ON  "
	cQuery1 += " 	(L1.L1_DOC = D2.D2_DOC AND L1_SERIE = D2_SERIE AND L1.L1_FILIAL = D2.D2_FILIAL AND D2.D_E_L_E_T_ = ' '  AND L1.D_E_L_E_T_ = ' ')   "
	cQuery1 += " WHERE   "
	cQuery1 += " 	(	L1.D_E_L_E_T_ = ' ' "
	cQuery1 += " AND L1.L1_FILIAL = '"+cFilBrwSL1+"'"
	cQuery1 += " AND L1.L1_EMISNF BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'  "
	cQuery1 += " 	AND SUBSTRING (L1_SERIE,1,1) <> 'X' AND L1.L1_DOC <> ' ' AND L1.L1_PDV <> '') "
	cQuery1 += " 	OR "
	cQuery1 += " 	(	D2.D_E_L_E_T_ = ' ' AND D2.D2_FILIAL = '"+cFilBrwSD2+"' AND D2.D2_EMISSAO BETWEEN '"+DtoS(dDeDt)+"' AND '"+DtoS(dAtDt)+"'"
	cQuery1 += " 	AND SUBSTRING (D2_SERIE,1,1) <> 'X' AND D2.D2_DOC <> ' ' AND D2.D2_PDV <> '') "

	If lLJ782Where
		LjGrvLog("Monitor de vendas","Antes da Chamada do Ponto de Entrada:LJ782WHERE")
		cLJ782Where := ExecBlock("LJ782WHERE",.F.,.F., {3})
		LjGrvLog("Monitor de vendas", "Apos a Chamada do Ponto de Entrada:LJ782WHERE", cLJ782Where)
		If ValType(cLJ782Where) == "C"
			cQuery1 += " " + cLJ782Where + " "
		EndIf
	EndIf

	cQuery1 += " GROUP BY  "
	cQuery1 += " L1_NUM, "
	cQuery1 += " L1_FILIAL, "
	cQuery1 += " D2_FILIAL, "      
	cQuery1 += IIF(MV_PAR05 == 1,"	L1_SERIE,","")
	cQuery1 += " L1_PDV, "
	cQuery1 += " D2_PDV,  "
	cQuery1 += " L1_EMISNF, "
	cQuery1 += " D2_EMISSAO, "
	cQuery1 += " L1_DOC, "
	cQuery1 += " D2_DOC,  "
	cQuery1 += " L1_VLRLIQ, "
	cQuery1 += " L1_SITUA  "
	cQuery1 += " ORDER BY   "
	cQuery1 += " L1_EMISNF, "
	cQuery1 += " L1_PDV "

	cQuery1 := ChangeQuery(cQuery1)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery1), cAlias1, .T., .T.)

	If (cAlias1)->(Eof())
		aBrw := {} 
		aBrw1 := {}
		aadd(aBrw1,{"","","","","","",0,0,0})    
		If !lEOF 
			MsgStop(STR0035,STR0036) // "Não existem dados para exibir. Verifique os parametros de filtro.", "Filtro sem resultado"	
		EndIf
	EndIf

	While !(cAlias1)->(Eof())

		If AllTrim(cSitua) == STR0004 //"Diferenca PDV"
			If (cAlias1)->DIFERENCA < 0
				aadd(aBrw1,{(cAlias1)->L1_FILIAL,(cAlias1)->L1_FILIAL,(cAlias1)->L1_EMISSAO,(cAlias1)->L1_PDV,IIF(MV_PAR05==1,(cAlias1)->L1_SERIE,""),(cAlias1)->TOT_ORC,;
				(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

				nValTotRet += (cAlias1)->TOT_ORC				
				nValTotPdv += (cAlias1)->REDUCAO
				nValTotDif += (cAlias1)->DIFERENCA
				nQtdBrw1 ++
			EndIf
		ElseIf AllTrim(cSitua) == STR0005 //"Diferenca Retaguarda"	
			If (cAlias1)->DIFERENCA > 0
				aadd(aBrw1,{(cAlias1)->L1_FILIAL,(cAlias1)->L1_FILIAL,(cAlias1)->L1_EMISSAO,(cAlias1)->L1_PDV,IIF(MV_PAR05==1,(cAlias1)->L1_SERIE,""),(cAlias1)->TOT_ORC,;
				(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

				nValTotRet += (cAlias1)->TOT_ORC				
				nValTotPdv += (cAlias1)->REDUCAO
				nValTotDif += (cAlias1)->DIFERENCA
				nQtdBrw1 ++
			EndIf	
		ElseIf AllTrim(cSitua) == STR0006 //"Sem Diferenca"	
			If (cAlias1)->DIFERENCA == 0
				aadd(aBrw1,{(cAlias1)->L1_FILIAL,(cAlias1)->L1_FILIAL,(cAlias1)->L1_EMISSAO,(cAlias1)->L1_PDV,IIF(MV_PAR05==1,(cAlias1)->L1_SERIE,""),(cAlias1)->TOT_ORC,;
				(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

				nValTotRet += (cAlias1)->TOT_ORC				
				nValTotPdv += (cAlias1)->REDUCAO
				nValTotDif += (cAlias1)->DIFERENCA
				nQtdBrw1 ++
			EndIf	
		Else
			aadd(aBrw1,{(cAlias1)->L1_FILIAL,(cAlias1)->L1_FILIAL,(cAlias1)->L1_EMISSAO,(cAlias1)->L1_PDV,IIF(MV_PAR05==1,(cAlias1)->L1_SERIE,""),(cAlias1)->TOT_ORC,;
			(cAlias1)->REDUCAO,(cAlias1)->DIFERENCA })    

			nValTotRet += (cAlias1)->TOT_ORC	
			nValTotPdv += (cAlias1)->REDUCAO
			nValTotDif += (cAlias1)->DIFERENCA
			nQtdBrw1 ++
		EndIf

		(cAlias1)->(DbSkip())

	EndDo

	(cAlias1)->(DbCloseArea())

	RestArea(aArea)

	If Len(aBrw) == 0
		aadd(aBrw,{"",0,0,0})	
	EndIf

	If Len(aBrw1) == 0
		aadd(aBrw1,{"","","","","","",0,0,0}) 
	EndIf

	If oDlg <> Nil    
		If Len(aBrw) > 0                  
			oBrw:SetArray(aBrw) 
		EndIf	
		If Len(aBrw1) > 0                   
			oBrw1:SetArray(aBrw1) 
		EndIf			
		oDlg:Refresh()
		oBrw:refresh()   
		oBrw1:refresh()   
		oPanel1:refresh() 
		oBrw1:SetFocus() 
		oBrw:SetFocus()
	EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Lj782TelaFil
Função responsável por apresentar tela de seleção de filiais para o filtro do monitor

@author    Vendas CRM
@version   12.1.7
@since     06/01/2017
@return 	.T. -> Sempre verdadeiro
@obs		Utilizado tambem na consulta padrão LJ782A (presente nos perguntes (SX1) LOJA781 e LOJA782)
/*/
//------------------------------------------------------------------------------------------
Function Lj782TelaFil(cDado, lAllFil)
	Local aArea     	:= GetArea()
	Local K_OK      	:= 0
	Local oDlg2		:= NIl
	Local nOpca     	:= 0
	Local nPosStatus	:= 0   
	Local nX			:= 0
	Local bOK       	:= { || nOpca := K_OK, oDlg2:End() }
	Local bCancel   	:= { || oDlg2:End() }
	Local oCritica	:= Nil
	Local cQuery		:= ""
	Local cUsuFil		:= ""
	Local aCritica	:= {}       
	Local aFilial		:= {}
	Local aFilUsu		:= {}
	Local aCloneFil	:= {}
	Local nInd			:= 0
	Local cAlias		:= GetNextAlias()	// Alias para a query
	Local lMarcado	:= .F.		// Se a filia esta marcada ou nao
	Local oMark		:= Nil
	Local lMarkAll	:= .T.		//Marcar todas
	Local oPanel2		:= Nil

	// Campo verificador se está sendo chamado pelo Robo
	Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

	Default cDado		:= ""
	Default lAllFil	:= .T.

	Private cCadastro := STR0033 //"Filial"

	aFilial := FWAllFilial(,,,.F.)

	aFilUsu := LJ782Filial() //Valida as filiais que o usuario possui acesso

	If Empty(cDado)
		cDado := Lj782SelFil()
	EndIf

	cDado := AllTrim(cDado) 

	If Empty(aFilUsu)
		MsgStop(STR0012)  //"Usuario nao possui acesso a nenhuma filial do sistema"
		Return()
	ElseIf !("@" $ aFilUsu[1])
		For nX := 1 To Len(aFilUsu)
			If nX = 1
				cUsuFil := alltrim(aFilUsu[nX])
			Else
				cUsuFil += ","+ alltrim(aFilUsu[nX])
			Endif 
		Next
		cUsuFil := IIF(Empty(cUsuFil), "''", cUsuFil)
	Else
		lAllFil := .T.
	EndIf

	If lAllFil
		aCloneFil := aClone(aFilial) 
	Else	
		aCloneFil := aClone(aFilUsu) 
	EndiF

	For nX := 1 To Len(aCloneFil)

		nPosStatus	:= aScan(aCritica,aCloneFil[nX])

		If (nPosStatus == 0)
			lMarcado := AllTrim(aCloneFil[nX])$cDado
			If !lMarcado //Tratamento para que ja venha marcado a opção caso ja estejam marcadas todas as filiais.
				lMarkAll := .F.
			EndIf
			aadd(aCritica,{STRTRAN(aCloneFil[nX],"'",""),FWFilialName(cEmpAnt,STRTRAN(aCloneFil[nX],"'",""),1),lMarcado})
		EndIf

	Next

	RestArea(aArea)

	DEFINE MSDIALOG oDlg2 TITLE STR0033 Style DS_MODALFRAME FROM 0,0 TO 320,430 OF oMainWnd PIXEL //"Filial "

	oPanel2:= tPanel():New(25,01,"",oDlg2,,,,,,500,550)

	oCritica := TcBrowse():New( 008, 012, 195, 110,,,, oPanel2,,,,,,,,,,,, .F.,, .T.,, .F., )

	oCritica:AddColumn(TcColumn():New(" ",{ || IF(aCritica[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
	"@!",nil,nil,nil,012,.T.,.T.,nil,nil,nil,.T.,nil))     

	oCritica:AddColumn(TcColumn():New(STR0033 ,{ || OemToAnsi(aCritica[oCritica:nAt,1]) },;
	"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))  //"Filial"   

	oCritica:AddColumn(TcColumn():New(STR0034 ,{ || OemToAnsi(aCritica[oCritica:nAt,2]) },;
	"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))  //"Descricao"   

	oMark := tCheckBox():New(120,12,STR0037,{|| lMarkAll },oPanel2,80,20,,{|| (lMarkAll := Lj782Mark(@aCritica,lMarkAll), oCritica:Refresh(),  )},,{|| .T.},0	,16777215,,.T.,STR0037,,{|| .T.}) //"Marcar/Desmarcar Todos"

	oCritica:SetArray(aCritica)         
	oCritica:bLDblClick := { || aCritica[oCritica:nAt,3] := IF(aCritica[oCritica:nAt,3],.F.,.T.) }

	If !lAutomato
		ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnChoiceBar(oDlg2,bOK,bCancel,.F.,{})
		If nOpca == K_OK

			cDado := ""
			For nInd := 1 To Len(aCritica)
				If aCritica[nInd,3]
					cDado += aCritica[nInd,1]+","
				Endif 
			Next
			cDado := Substr(cDado,1,Len(cDado)-1)
		Endif
	Else
		cDado := MV_PAR03
	EndIf

	SetSelFil(cDado)

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Lj782SelFil
Função para retornar o conteudo da variavel static cParamFil (com o conteudo do parametro filial)

@author    Vendas CRM
@version   12.1.7
@since     06/01/2017
@return 	cParamFil - filiais selecionadas no parametro do pergunte
@obs		Utilizado nos perguntes (SX1) LOJA781 e LOJA782
/*/
//------------------------------------------------------------------------------------------
Function Lj782SelFil()
Return cParamFil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetSelFil
Função para setar o conteudo da variavel static cParamFil (com o conteudo do parametro filial)

@author    Vendas CRM
@version   12.1.7
@since     06/01/2017
@return 	Nil
/*/
//------------------------------------------------------------------------------------------
Static Function SetSelFil(cDado)
	Default cDado := ""

	cParamFil := cDado

Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjCompFil
Função para verificar o compartilhamento das tabelas e retornar a filial correta

@author    alessandrosantos
@version   11.8
@since     13/03/2017

/*/
//------------------------------------------------------------------------------------------

Static Function LjCompFil(cFilSel, cTabela)

	Local cFilTemp  := "'"
	Local nI        := 0
	Local nTamFil   := FWSizeFilial()
	Local aCopiaFil := StrTokArr(cFilSel, ",")               

	For nI := 1 To Len(aCopiaFil)
		aCopiaFil[nI] := Padr(aCopiaFil[nI], nTamFil, "")
		cFilTemp += FWxFilial(cTabela, aCopiaFil[nI]) + "','"
	Next

	cFilTemp := Substr(cFilTemp, 1, Len(cFilTemp) - 2)

Return cFilTemp   
