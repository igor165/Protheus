#Include 'AGRX720.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWBrowse.ch'
#Include 'FwMvcDef.ch' 

Static __cTabBlc	:= "" //Tabela Temporária de Blocos
Static __cTabFar	:= "" //Tabela Temporária de Fardos
Static __cNamBlc	:= "" //Tabela Temporária de Blocos - Nome no banco de dados
Static __cNamFar	:= "" //Tabela Temporária de Fardos - Nome no banco de dados

/*{Protheus.doc} AGRX720
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/05/2017
@version undefined
@param cFilTipCtr, characters, descricao
@param aFilHviCtr, array, descricao
@param aFardos, array, descricao
@type function
*/
function AGRX720(pcFiltrDXI, cFilTipCtr, aFilHviCtr, pcFiltrN9D, aOptions ,aFardosSel, aFardoExc, nQtdCad, nTolen, nQtdUsada, cRegraEsp, cContrato, lAuto)
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oSize 
	Local oSize2
	Local oSize3
	Local nOpcX			 := 0
	Local nCont    		 := 0
	Local aRetSM0 		 := {}
	Local aFilBrowBlc	 := {}
	Local aFilBrowFar	 := {}
	Local nx       		 := 0
	Local oDlg	   		 := Nil
	Local oPnl1    		 := nil
	Local aQtdInt		 := TamSX3("NNY_QTDINT")
	Local aToleran		 := TamSX3("NJR_TOLENT")
	Local cTituloQtd     := ""
		
	Default aFilHviCtr   := {} 	//filtros hvi do contrato
	Default cFilTipCtr   := "" 	//filtros tipos aceitáveis do contrato
	Default aFardosSel      := {} 	//fardos selecionados previamente
	Default aFardoExc    := {}
	Default nQtdUsada    := 0 
	Default nTolen       := 0 
	Default nQtdCad      := 0 	
	Default pcFiltrDXI   := ""
	Default pcFiltrN9D   := ""
	Default cRegraEsp	 := ""
	Default lAuto        := .F.
	
	//variaveis do programa	
	Private _aFiliais    := {}  //filiais diponíveis
	Private _aFilHvi     := {} 	//filtros hvi
	Private _cTpUBA060   := "" 	//tipos selecionados para a consulta especifica
	Private _nTotFar	 := 0	//variavel totalizador de fardos selecionados
	Private _nTotVal	 := 0	//variavel totalizador de peso liquido total dos fardos selecionados
	Private _afardoSel   := {} 	//fardos previamente selecionados
	Private _aBlocoSel   := {} 	//blocos previamente selecionados
	Private _oStruDX7    := FWFormStruct( 1, "DX7" , {|cCampo| ALLTRIM(cCampo) $ "DX7_MIC,DX7_RES,DX7_FIBRA,DX7_UI,DX7_SFI,DX7_ELONG,DX7_LEAF,DX7_AREA,DX7_CSP,DX7_CG,DX7_MAISB,DX7_RD,DX7_COUNT,DX7_UHM,DX7_SCI"} )
	Private _lGridActv   := .F. // Variavel de controle da View
	Private _oView		 := Nil // View referente ao filtro hvi
	Private _nLine		 := 0 	// Variavel de controle de linha da grid de filtro
	Private _aGrdDt		 := {} 	// Array de carga de dados
	Private _nTolen      := nTolen
	Private _nQtdCad     := nQtdCad
	Private _nOpcX       := nOpcX
	Private _nQtdUsada   := nQtdUsada
	Private _aFardoExc   := aFardoExc
	Private _cFiltrDXI   := pcFiltrDXI
	Private _cFiltrN9D   := pcFiltrN9D
	Private _cFiltrN80   := cRegraEsp
	Private _lAuto       := lAuto
	
	//variaveis para tratamentos da tela(options)
	Private _lValLimit   := .t. 
	Private _lShowAVinc  := .t. 
	Private _cCodCtr     := "" 	//codigo do contrato
	Private _lReprov     := .T. //inclui reprovados
	Private _cContrato	 := cContrato
	/************* DADOS DEFAULT ****************************/
		
	for nCont := 1 to len(aOptions) //seta as variáveis do programa
		&(aOptions[nCont][1]) := aOptions[nCont][2] 
	next nCont
	
	aRotina   := {} //reset consulta
	 	
	/*****set fardos já selecionados
	_aBlocoSel = Blocos que já devem estar selecionados
	_afardoSel = Fardos que já devem estar selecionados
	aNoSelec   = Fardos que NÃO devem estar selecionados -> Perfomance no array	
	*******/
	
	if Len(aFardosSel) > 0 //temos fardos selecionados
		nCont := 1  
		while nCont <= Len(aFardosSel)
									
		 	if len(aFardosSel[nCont][3]) > 0 //vamos add somente com fardo selecionado
		 		For nx := 1  to Len(aFardosSel[nCont][3])
		 			aADD(_afardoSel,aFardosSel[nCont][3][nx]) //colocando todos recnos
		 		Next nx
		 		//pegar a filial do bloco
		 		dbSelectArea( "DXI" )
				dbSetOrder( 1 ) 
		 		if dbGoto(aFardosSel[nCont][3][1]) //pegando a filial do fardo
		 			aADD(_aBlocoSel,DXI->DXI_FILIAL+aFardosSel[nCont][2])
		 		endif
		 	end
		 	      
	        nCont++ //update data
		enddo
	endif
	
	if FwModeAccess("DXP", 1) == "C" .AND. FwModeAccess("DXP", 2) == "C" .AND. FwModeAccess("DXP", 3) == "C" // Se totalemente compartilhada então carrega todas as filiais do grupo de empresa
		aRetSM0    := FWAllFilial(,,,.F.)// FWLoadSM0()
		For nCont := 1  to Len(aRetSM0) 
	        aADD(_aFiliais, {"1",aRetSM0[nCont],FWFilName(cEmpAnt,aRetSM0[nCont])})
	    Next nCont 
	//busca as filiais disponíveis
	elseif FwModeAccess("DXP", 1) == "E" .AND. FwModeAccess("DXP", 2) == "C" .AND. FwModeAccess("DXP", 3) == "C" 
		aRetSM0    := FWAllFilial(FWCompany(),,,.F.)// FWLoadSM0()
	    For nCont := 1  to Len(aRetSM0) 
	        aADD(_aFiliais, {"1",aRetSM0[nCont],FWFilName(cEmpAnt,aRetSM0[nCont])})
	    Next nCont
	elseif FwModeAccess("DXP", 1) == "E" .AND. FwModeAccess("DXP", 2) == "E" .AND. FwModeAccess("DXP", 3) == "C"  //está usando tabela compartilhada - buscamos todas as filiais
		aRetSM0    := FWAllFilial(FWCompany(),FWUnitBusiness(),cEmpAnt,.F.)// FWLoadSM0()
	    For nCont := 1  to Len(aRetSM0) 
	        aADD(_aFiliais, {"1",aRetSM0[nCont],FWFilName(cEmpAnt,aRetSM0[nCont])})
	    Next nCont
	else //somente a filial logada
		aADD(_aFiliais, {"1",cFilAnt, FWFilName(FWCodEmp(),FWCodFil())})
	endif	
	
	//copia os filtros HVI
	For nCont := 1  to Len(aFilHviCtr) 
        aADD(_aFilHvi,aFilHviCtr[nCont])
        aAdd(_aGrdDt, {nCont, aFilHviCtr[nCont]})
    Next nCont
	       
	//copia os filtros de tipo
	_cTpUBA060 := PadR(cFilTipCtr,80) //variavel consulta especifica  	
	       
	//campos blocos
	aCpsBrowBlc := {{"Sel"       , "MARK"	, "C", 1,, "@!"},; //control utilização
					{"RECNO"     , "RECNO"	, "N", 18, 0, "@ 9999999999"},; //control utilização
					{STR0046, "DXD_FILIAL"	, TamSX3( "DXD_FILIAL" )[3]	, TamSX3( "DXD_FILIAL" )[1]	, TamSX3( "DXD_FILIAL" )[2]	, PesqPict("DXD","DXD_FILIAL") 	},;	//"Filial"
			        {STR0047, "DXD_CODIGO"	, TamSX3( "DXD_CODIGO" )[3]	, TamSX3( "DXD_CODIGO" )[1]	, TamSX3( "DXD_CODIGO" )[2]	, PesqPict("DXD","DXD_CODIGO") 	},;	//"Bloco"
			        {STR0048, "QTDE_DISPO"	, "C"						, 4							, 0							, "9999" 						},;	//"Qtd. Disp."
			        {STR0049, "DXD_CLACOM"	, TamSX3( "DXD_CLACOM" )[3]	, TamSX3( "DXD_CLACOM" )[1]	, TamSX3( "DXD_CLACOM" )[2]	, PesqPict("DXD","DXD_CLACOM") 	},;	//"Class.Com."
			        {STR0050, "DXD_SAFRA"	, TamSX3( "DXD_SAFRA" )[3]	, TamSX3( "DXD_SAFRA" )[1]	, TamSX3( "DXD_SAFRA" )[2]	, PesqPict("DXD","DXD_SAFRA") 	}}	//"Safra"
	//campos Fardos
	aCpsBrowFar := {{"Blc"       , "MBLC"	    , "C", 1,, "@!"},; //control utilização bloco
					{"Far"       , "MARK"	    , "C", 1,, "@!"},; //control utilização
					{"ST"        , "REJEITADO"	, "C", 1,, "@!"},; //rejeitados
			        {AGRTITULO("DXI_PSESTO")    , "DXI_PSESTO"	, TamSX3( "DXI_PSESTO" )[3]	, TamSX3( "DXI_PSESTO" )[1]	, TamSX3( "DXI_PSESTO" )[2]	, PesqPict("DXI","DXI_PSESTO") 	},; // Peso Estoque
					{STR0046, "DXI_FILIAL"	, TamSX3( "DXI_FILIAL" )[3]	, TamSX3( "DXI_FILIAL" )[1]	, TamSX3( "DXI_FILIAL" )[2]	, PesqPict("DXI","DXI_FILIAL") 	},;	//"Filial"
			        {STR0051, "DXI_CODIGO"	, TamSX3( "DXI_CODIGO" )[3]	, TamSX3( "DXI_CODIGO" )[1]	, TamSX3( "DXI_CODIGO" )[2]	, PesqPict("DXI","DXI_CODIGO") 	},;	//"Fardo"
			        {STR0047, "DXI_BLOCO"	, TamSX3( "DXI_BLOCO" )[3]	, TamSX3( "DXI_BLOCO" )[1]	, TamSX3( "DXI_BLOCO" )[2]	, PesqPict("DXI","DXI_BLOCO") 	},;	//"Bloco"
			        {STR0052, "DXI_PSLIQU"	, TamSX3( "DXI_PSLIQU" )[3]	, TamSX3( "DXI_PSLIQU" )[1]	, TamSX3( "DXI_PSLIQU" )[2]	, PesqPict("DXI","DXI_PSLIQU") 	},;	//"Peso Liquido"
			        {STR0049, "DXI_CLACOM"	, TamSX3( "DXI_CLACOM" )[3]	, TamSX3( "DXI_CLACOM" )[1]	, TamSX3( "DXI_CLACOM" )[2]	, PesqPict("DXI","DXI_CLACOM") 	},;	//"Class.Com."
			        {STR0053, "DXI_ETIQ"	, TamSX3( "DXI_ETIQ" )[3]	, TamSX3( "DXI_ETIQ" )[1]	, TamSX3( "DXI_ETIQ" )[2]	, PesqPict("DXI","DXI_ETIQ") 	},;	//"Etiqueta"
			        {STR0050, "DXI_SAFRA"	, TamSX3( "DXI_SAFRA" )[3]	, TamSX3( "DXI_SAFRA" )[1]	, TamSX3( "DXI_SAFRA" )[2]	, PesqPict("DXI","DXI_SAFRA") 	},;//Safra
			        {STR0054, "DXI_CODRES"	, TamSX3( "DXI_CODRES" )[3]	, TamSX3( "DXI_CODRES" )[1]	, TamSX3( "DXI_CODRES" )[2]	, PesqPict("DXI","DXI_CODRES") 	}} //Reserva
			        
	
	/*Adicionando os campos HVI*/
	//copia os filtros HVI
	For nCont := 1  to Len(_oStruDX7:aFields) 
        aADD(aCpsBrowFar, {_oStruDX7:aFields[nCont][1], _oStruDX7:aFields[nCont][3],_oStruDX7:aFields[nCont][4], _oStruDX7:aFields[nCont][5], _oStruDX7:aFields[nCont][6], PesqPict("DX7", _oStruDX7:aFields[nCont][3])   } )
   	Next nCont
	
	Processa({||  MontaTabel(@__cTabBlc,@__cNamBlc, aCpsBrowBlc, {{"", "DXD_FILIAL+DXD_SAFRA+DXD_CODIGO"}, {"SELEC", "MARK"}})},STR0025)
	Processa({||  MontaTabel(@__cTabFar,@__cNamFar, aCpsBrowFar, {{"PRINC", "DXI_FILIAL+DXI_SAFRA+DXI_BLOCO+DXI_CODIGO"}, {"SELEC", "MARK+REJEITADO"} })},STR0025)
	
	Processa({|| SetDataBlc()},STR0023) //popula temp-table de bloco
	Processa({|| SetDataFar()},STR0024) //popula temp-table de fardo
			        
	If !_lAuto /************* TELA DE PESQUISA ************************/
		aSize := MsAdvSize()
		
		//tamanho da tela principal
		oSize := FWDefSize():New(.T.)
		oSize:AddObject('DLG',100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:aMargins := {0,0,0,0}
		oSize:Process()
		
		oDlg := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Consulta
		
		// Desabilita o fechamento da tela através da tela ESC.
		oDlg:lEscClose := .F.
		
		oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3] - 30)
			
		// Instancia o layer
		oFWL := FWLayer():New()

		// Inicia o Layer
		oFWL:init( oPnl1, .F. )
		
		// Cria as divisões horizontais
		oFWL:addLine( 'MASTER'   , 100 , .F.)
		oFWL:addCollumn( 'LEFT' ,30,.F., 'MASTER' )
		oFWL:addCollumn( 'CENTER' , 30,.F., 'MASTER' )
		oFWL:addCollumn( 'RIGHT' , 40,.F., 'MASTER' )
			
		//cria as janelas
		oFWL:addWindow( 'LEFT' 	, 'Wnd1', STR0002	,  30 /*tamanho*/, .T., .F.,, 'MASTER' ) 	//"Parametros"
		oFWL:addWindow( 'LEFT' 	, 'Wnd2', STR0003	,  40 /*tamanho*/, .T., .F.,, 'MASTER' )	//"Filtro de Qualidade"   
		oFWL:addWindow( 'LEFT' 	, 'Wnd3', STR0004	,  30 /*tamanho*/, .T., .F.,, 'MASTER' )	//"Filiais"
				
		oFWL:addWindow( 'CENTER', 'Wnd4', STR0005	, 100 /*tamanho*/, .F., .T.,, 'MASTER' )	//"Blocos"
			
		oFWL:addWindow( 'RIGHT'	, 'Wnd5', STR0006	,  83 /*tamanho*/, .F., .T.,, 'MASTER' )	//"Fardos"
		oFWL:addWindow( 'RIGHT'	, 'Wnd6', STR0035   ,  17 /*tamanho*/, .F., .T.,, 'MASTER' )	//"Fardos Selecionados"
		
		oFWL:setColSplit ( 'LEFT'  , 0, 'MASTER')
		oFWL:setColSplit ( 'CENTER', 0, 'MASTER')

		// Recupera os Paineis das divisões do Layer
		oPnlWnd1:= oFWL:getWinPanel( 'LEFT' 	, 'Wnd1', 'MASTER' )
		oPnlWnd2:= oFWL:getWinPanel( 'LEFT' 	, 'Wnd2', 'MASTER' )
		oPnlWnd3:= oFWL:getWinPanel( 'LEFT'		, 'Wnd3', 'MASTER' )
		oPnlWnd4:= oFWL:getWinPanel( 'CENTER' 	, 'Wnd4', 'MASTER' )
		oPnlWnd5:= oFWL:getWinPanel( 'RIGHT'	, 'Wnd5', 'MASTER' )
		oPnlWnd6:= oFWL:getWinPanel( 'RIGHT'	, 'Wnd6', 'MASTER' )
		
		/*********************PARÂMETROS *****************************/
		//- Recupera coordenadas 
		oSize2 := FWDefSize():New(.F.)
		oSize2:AddObject(STR0002,100,100,.T.,.T.)
		oSize2:SetWindowSize({0,0,oPnlWnd1:NHEIGHT,oPnlWnd1:NWIDTH})
		oSize2:lProp 	:= .T.
		oSize2:aMargins := {0,0,0,0}
		oSize2:Process()
		
		//cria os componentes
		oSay   := TSay():New(oSize2:aPosObj[1,1],oSize2:aPosObj[1,2],{||STR0007},oPnlWnd1,,,,,,.T.,,,25,10,,,,,,.f.)
		oTGet1 := TGet():New(oSize2:aPosObj[1,1]+8,oSize2:aPosObj[1,2],{|u| If(PCount()>0,_cTpUBA060:=u,_cTpUBA060) },oPnlWnd1,oSize2:aPosObj[1,4]-2,009,"@!",{|| fVldTipQld()},0,,,.F.,,.T.,,.F.,{|| Empty(_cContrato) /* bWhen */ },.F.,.F.,{|| /*SetDataBlc(), AGRX720UP(oBrowse3) */ },.F.,.F.,,"_cTpUBA060",,,,.t.,.f. )
		
		oTGet1:cF3 := "N80ES1" //consulta espécifica UBAA060BLO //valid
			
		oTCheck1 := TCheckBox():New(oSize2:aPosObj[1,1]+25,oSize2:aPosObj[1,2],STR0008,,oPnlWnd1,100,15,,,,,,,,.T.,,,)
		oTCheck1:cVariable   := "_lReprov"
		oTCheck1:bSetGet     := {|u| If(PCount()>0,_lReprov:=u,_lReprov) }
		oTCheck1:bChange     := {|| Processa({|| SetDataFar()},STR0024), AGRX720UP(oBrowse4)  } //reset
		
		If !Empty(_cCodCtr) //tem contrato envolvido
			
			cTituloQtd := STR0040
					
			oSay4:= tSay():New(oSize2:aPosObj[1,1]+38,oSize2:aPosObj[1,2],{||cTituloQtd},oPnlWnd1,,,,,,.T.,CLR_BLACK,CLR_WHITE,120,30)//
			oTGet4 := TGet():New(oSize2:aPosObj[1,1]+48,oSize2:aPosObj[1,2],bSetGet(nQtdCad)/*{|u| If(PCount()>0,_cTpUBA060:=u,_cTpUBA060) }*/,oPnlWnd1, CalcFieldSize(aQtdInt[3]/* Tipo*/, aQtdInt[1]/* Tamanho */, aQtdInt[2]/* Decimal */, PesqPict("NNY","NNY_QTDINT")) + 5,009, PesqPict("NNY","NNY_QTDINT"),/*{|| fVldTipQld()}*/,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,{|| /*SetDataBlc(), AGRX720UP(oBrowse3) */ },.F.,.F.,,/**/,,,,.t.,.f. )
			
			oSay5:= tSay():New(oSize2:aPosObj[1,1]+38,oSize2:aPosObj[1,2]+60,{||STR0039},oPnlWnd1,,,,,,.T.,CLR_BLACK,CLR_WHITE,120,30)//
			oTGet5 := TGet():New(oSize2:aPosObj[1,1]+48,oSize2:aPosObj[1,2]+60,bSetGet(nTolen)/*{|u| If(PCount()>0,_cTpUBA060:=u,_cTpUBA060) }*/,oPnlWnd1,CalcFieldSize(aToleran[3]/* Tipo*/, aToleran[1]/* Tamanho */, aToleran[2]/* Decimal */, PesqPict("NJR","NJR_TOLENT")) + 5,009,PesqPict("NJR","NJR_TOLENT"),/*{|| fVldTipQld()}*/,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,{|| /*SetDataBlc(), AGRX720UP(oBrowse3) */ },.F.,.F.,,/**/,,,,.t.,.f. )
			
			if _lShowAVinc //mostra o valor restante
				oSay6  := tSay():New(oSize2:aPosObj[1,1]+38,oSize2:aPosObj[1,2]+100,{||STR0045},oPnlWnd1,,,,,,.T.,CLR_BLACK,CLR_WHITE,120,30)//
				oTGet6 := TGet():New(oSize2:aPosObj[1,1]+48,oSize2:aPosObj[1,2]+100,bSetGet(_nQtdUsada)/*{|u| If(PCount()>0,_cTpUBA060:=u,_cTpUBA060) }*/,oPnlWnd1, CalcFieldSize(aQtdInt[3]/* Tipo*/, aQtdInt[1]/* Tamanho */, aQtdInt[2]/* Decimal */, PesqPict("NNY","NNY_QTDINT")) + 5,009, PesqPict("NNY","NNY_QTDINT"),/*{|| fVldTipQld()}*/,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,{|| /*SetDataBlc(), AGRX720UP(oBrowse3) */ },.F.,.F.,,/**/,,,,.t.,.f. )
			endif
			
		EndIf
		
		/****************** FILTROS ********************************/
		//- Recupera coordenadas 
		oSize3 := FWDefSize():New(.F.)
		oSize3:AddObject(STR0003,100,100,.T.,.T.)
		oSize3:SetWindowSize({0,0,oPnlWnd2:NHEIGHT,oPnlWnd2:NWIDTH})
		oSize3:lProp 	:= .T.
		oSize3:aMargins := {0,2,0,0}
		oSize3:Process()
		
		// ### Instância e Ativa a View resposável pelo filtro hvi, passando como parâmetro o objeto no qual a view será construída. ###
		AGRX720VWL(oPnlWnd2)  
			
		/****************** FILIAIS ********************************/
		//- Recupera coordenadas 
		oSize4 := FWDefSize():New(.F.)
		oSize4:AddObject(STR0002,100,100,.T.,.T.)
		oSize4:SetWindowSize({0,0,oPnlWnd3:NHEIGHT,oPnlWnd3:NWIDTH})
		oSize4:lProp 	:= .T.
		oSize4:aMargins := {0,0,0,0}
		oSize4:Process()
			
		oBrowse2 := FWBrowse():New(oPnlWnd3)
		oBrowse2:SetDataArray(.T.)
		oBrowse2:DisableFilter(.T.) 
		oBrowse2:DisableReport(.T.) 
		oBrowse2:DisableSeek(.T.) 
		oBrowse2:SetArray(_aFiliais)
		oBrowse2:SetProfileID("AGRX720FIL")
		oBrowse2:AddMarkColumns( { ||Iif( !Empty( _aFiliais[oBrowse2:nAt,1] = "1" ),"LBOK","LBNO" ) },{ || AGRX720DB( oBrowse2, "E" ), AGRX720UP(oBrowse2, .f.),  Processa({|| SetDataBlc()},STR0023), Processa({|| SetDataFar()},STR0024), AGRX720UP(oBrowse4), AGRX720UP(oBrowse3), oBrowse2:SetFocus(), oBrowse2:GoColumn(1)}, { || AGRX720HD( oBrowse2, "E" ), AGRX720UP(oBrowse2), Processa({|| SetDataBlc()},STR0023), Processa({|| SetDataFar()},STR0024),  AGRX720UP(oBrowse3), AGRX720UP(oBrowse4) } )     
		oBrowse2:AddColumn( {STR0014  , { || _aFiliais[oBrowse2:nAt,2] }    ,"C","@!",1,,,.f.,,,{|| AGRX720DBC(oBrowse2) }} )
		oBrowse2:AddColumn( {STR0015   , { || _aFiliais[oBrowse2:nAt,3] }    ,"C","@!",1,,,.f.,,,{|| AGRX720DBC(oBrowse2) }} )
		
		oBrowse2:bGotFocus := {|tGrid| AGRX720FOC(tGrid)} 
		oBrowse2:Activate()		
		
		/****************** BLOCOS ********************************/
		//- Recupera coordenadas 
		oSize4 := FWDefSize():New(.F.)
		oSize4:AddObject(STR0005,100,100,.T.,.T.)
		oSize4:SetWindowSize({0,0,oPnlWnd4:NHEIGHT,oPnlWnd4:NWIDTH})
		oSize4:lProp 	:= .T.
		oSize4:aMargins := {0,0,0,0}
		oSize4:Process()
						
		//adicionando os widgets de tela
		oBrowse3 := FWMBrowse():New()
		oBrowse3:SetAlias(__cTabBlc)
		oBrowse3:DisableDetails()
		oBrowse3:SetMenuDef( "" )
		oBrowse3:DisableReport(.T.) 
		oBrowse3:DisableSeek(.T.) 
		oBrowse3:SetProfileID("AGRX720BLC")
																																						
		oBrowse3:AddMarkColumns( { ||Iif(  (__cTabBlc)->MARK = "1" ,"LBOK","LBNO" ) },{ || AGRX720DB( oBrowse3, "B" ),  AGRX720UP(oBrowse3, .f.),  Processa({|| SetDataFar(,,IIF((__cTabBlc)->MARK = "1", "S", "D"))},STR0024), AGRX720UP(oBrowse4), oBrowse3:SetFocus(), oBrowse3:GoColumn(1)  }, { || AGRX720HD( oBrowse3, "B" ), AGRX720UP(oBrowse3), Processa({|| SetDataFar()},STR0024), AGRX720UP(oBrowse4), oBrowse3:SetFocus()  } )     
		For nCont := 3 /*PULAR O Campo de Sel*/ to Len(aCpsBrowBlc) 
			oBrowse3:AddColumn( {aCpsBrowBlc[nCont][1]  , &("{||"+aCpsBrowBlc[nCont][2]+"}") ,aCpsBrowBlc[nCont][3],aCpsBrowBlc[nCont][6],1,aCpsBrowBlc[nCont][4],aCpsBrowBlc[nCont][5],.f.,,,{|| AGRX720DBC(oBrowse3) }} )
			aADD(aFilBrowBlc,  {aCpsBrowBlc[nCont][2], aCpsBrowBlc[nCont][1], aCpsBrowBlc[nCont][3], aCpsBrowBlc[nCont][4], aCpsBrowBlc[nCont][5], aCpsBrowBlc[nCont][6] } )
		Next nCont  
		
		oBrowse3:SetFieldFilter(aFilBrowBlc)    
	
		oBrowse3:bGotFocus := {|tGrid| AGRX720FOC(tGrid)} 
		oBrowse3:Activate(oPnlWnd4)
			
		/****************** FARDOS ********************************/
		//- Recupera coordenadas 
		oSize5 := FWDefSize():New(.F.)
		oSize5:AddObject(STR0006,100,100,.T.,.T.)
		oSize5:SetWindowSize({0,0,oPnlWnd5:NHEIGHT,oPnlWnd5:NWIDTH})
		oSize5:lProp 	:= .T.
		oSize5:aMargins := {0,0,0,0}
		oSize5:Process()
						
		oBrowse4 := FWMBrowse():New()
		oBrowse4:SetAlias(__cTabFar)
		oBrowse4:DisableDetails()
		oBrowse4:SetMenuDef("")
		oBrowse4:DisableReport(.T.) 
		oBrowse4:DisableSeek(.T.) 
		oBrowse4:SetProfileID("AGRX720FAR")
		
		oBrowse4:AddColumn( {aCpsBrowFar[2][1]  , &("{||Iif( !Empty( (__cTabFar)->MARK = '1' ),'LBOK','LBNO' )}")  ,aCpsBrowFar[2][3],"@BMP",1,aCpsBrowFar[2][4],aCpsBrowFar[2][5],.f.,,.t.,{ || AGRX720DB( oBrowse4, "F" ), AGRX720UP(oBrowse4, .f.) }              ,,{ || AGRX720HD( oBrowse4, "F" ), AGRX720UP(oBrowse4), oTGet2:Refresh(),  oTGet3:Refresh()  }} )
		oBrowse4:AddColumn( {aCpsBrowFar[1][1]  , &("{||Iif( !Empty( (__cTabFar)->MBLC = '1' ),'LBTIK','LBNO' )}") ,aCpsBrowFar[1][3],"@BMP",1,aCpsBrowFar[1][4],aCpsBrowFar[1][5],.f.,,.t.,{ || AGRX720DB( oBrowse4, "A" ), AGRX720UP(oBrowse4, .t., oBrowse4:At()) },,{ || AGRX720HD( oBrowse4, "A" ), AGRX720UP(oBrowse4), oTGet2:Refresh(),  oTGet3:Refresh()  }} )
		oBrowse4:AddLegend( "REJEITADO == 'F'", "GREEN" , STR0021)        //"Controle de aprovação habilitado"
		oBrowse4:AddLegend( "REJEITADO == 'T'", "RED"  , STR0022)   
		
		For nCont := 5 /*PULAR O Campo de Peso Estoque*/ to Len(aCpsBrowFar) 
			oBrowse4:AddColumn( {aCpsBrowFar[nCont][1]  , &("{||"+aCpsBrowFar[nCont][2]+"}") ,aCpsBrowFar[nCont][3],aCpsBrowFar[nCont][6],1,aCpsBrowFar[nCont][4],aCpsBrowFar[nCont][5],.f.,,,{|| AGRX720DBC(oBrowse4) }} )
			aADD(aFilBrowFar, {aCpsBrowFar[nCont][2], aCpsBrowFar[nCont][1], aCpsBrowFar[nCont][3], aCpsBrowFar[nCont][4], aCpsBrowFar[nCont][5], aCpsBrowFar[nCont][6]}) 
		Next nCont
			
		oBrowse4:SetFieldFilter(aFilBrowFar)
		oBrowse4:bGotFocus := {|tGrid| AGRX720FOC(tGrid)} // Evento para reposicionar o foco na primeira coluna do Browse.
		oBrowse4:Activate(oPnlWnd5)
	
		/*********************TOTALIZADORES *****************************/
		//- Recupera coordenadas 
		oSize6 := FWDefSize():New(.F.)
		oSize6:AddObject(STR0035,100,100,.T.,.T.)		//"Fardos Selecionados" 
		oSize6:SetWindowSize({0,0,oPnlWnd6:NHEIGHT,oPnlWnd6:NWIDTH})
		oSize6:lProp 	:= .T.
		oSize6:aMargins := {0,0,0,0}
		oSize6:Process()
		
		//Cria campos totalizadores - Total Fardos
		oSay2  := TSay():New(oSize6:aPosObj[1,1]	, oSize6:aPosObj[1,2], {||STR0036}		,oPnlWnd6,,,,,,.T.,,,60,10,,,,,,.F.)	//"Total de Fardos"
		oTGet2 := TGet():New(oSize6:aPosObj[1,1]+8	, oSize6:aPosObj[1,2], bSetGet(_nTotFar),oPnlWnd6, oSize6:aPosObj[1,5] / 2, 009, "@E 999999999", /*bValid*/, 0, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {||.F. } , /*bWhen*/, /*uParam18*/, /*uParam19*/, .T. /*bChange*/, .F. /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam26*/, /*uParam27*/,.T.,.F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)

		//Cria campos totalizadores - Peso Líquido Total [Volume]
		oSay3  := TSay():New(oSize6:aPosObj[1,1]	, ((oSize6:aPosObj[1,5]/2) + oSize6:aPosObj[1,2] + 5), {||STR0037}		 , oPnlWnd6,,,,,,.T.,,,60,10,,,,,,.F.)	//"Peso Líquido Total"
		oTGet3 := TGet():New(oSize6:aPosObj[1,1]+8	,((oSize6:aPosObj[1,5]/2)  + oSize6:aPosObj[1,2] + 5), bSetGet(_nTotVal) , oPnlWnd6, (oSize6:aPosObj[1,5] /2) - 5, 009,PesqPict("DXQ","DXQ_PSLIQU"), /*bValid*/, 0, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {||.F. } , /*bWhen*/, /*uParam18*/, /*uParam19*/, .T. /*bChange*/, .F. /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam26*/, /*uParam27*/,.T.,.F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)
		
		oBrowse3:SetFocus()	 //focus no browser de blocos - principal
		oBrowse3:GoColumn(1) // Posiciona o Browse 4 na primeira coluna depois da ativação

		oDlg:Activate( , , , .t., , , EnchoiceBar(oDlg, {|| IF(AGRX720EXT(),ODlg:End(), NIL) } /*OK*/ , {|| nOpcX := 0, oDlg:End() } /*Cancel*/ ) )
	Else
		AGRX720EXT()	
    EndIf
		
	If _oView != Nil // View HVI, desativar e destruir para não impactar em outras views
		_oView:DeActivate()
		_oView:Destroy()
	EndIf
	
	//verifica as opções selecionadas no enchoicebar
	nOpcX := _nOpcX 
	If nOpcX==1 .OR. _lAuto
		return { .t. , AGRX720SL() } 
	endif
		
return { .f. , {} } //retorno cancel

/****Funções de Marcação*/

/*{Protheus.doc} AGRX720DB
Seleção individual de filiais / blocos e fardos
@author jean.schulze
@since 25/05/2017
@version undefined
@param oBrwObj, object, descricao
@param cBrwName, characters, descricao
@type function
*/
static function AGRX720DB(oBrwObj, cBrwName)
	Local cSelect := ""
	Local cBloco  := ""
	Local cFardo  := ""
	Local cArTabFar := ""
				
	Do Case   
	case cBrwName == "E"	//filiais
		_aFiliais[oBrwObj:nAt,1] := IIF(_aFiliais[oBrwObj:nAt,1] == "", "1", "")
		
	case cBrwName == "B"	//blocos
		if RecLock((__cTabBlc),.F.)	.and. !empty((__cTabBlc)->DXD_CODIGO) //tratamento de excessao - sempre posicionado
			(__cTabBlc)->MARK := IIF((__cTabBlc)->MARK  == "1", "", "1")	
			MsUnlock()	
		endif
			
	case cBrwName == "F"   	//fardos
		if RecLock((__cTabFar),.F.)	.and. !empty((__cTabFar)->DXI_CODIGO) //tratamento de excessao - sempre posicionado
			(__cTabFar)->MARK := IIF((__cTabFar)->MARK  == "1", "", "1")	
			MsUnlock()	
		endif	

	case cBrwName == "A"   	//Ambos - Fardos e Blocos
		if !empty((__cTabFar)->DXI_CODIGO) //tratamento de excessao - sempre posicionado
			
			cSelect := IIF((__cTabFar)->MBLC  == "1", "", "1")	
			cBloco  := (__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO
			cFardo  := (__cTabFar)->DXI_CODIGO //use para reposic
			 
			DbSelectArea((__cTabFar))
			DbGoTop()
			If DbSeek(cBloco) 
			
				
				While !(__cTabFar)->(Eof()) .and. alltrim(cBloco) == alltrim((__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO)
											
					If RecLock((__cTabFar),.f.)	
						(__cTabFar)->MBLC = cSelect
						(__cTabFar)->MARK = cSelect
						MsUnlock()	
					EndIf			
					 
					(__cTabFar)->( dbSkip() )	

				enddo
							
			endif
						 
		endif	
		
	endCase
	
	//Totalizadores de fardos e peso liquido 
	If cBrwName == "F" .OR. cBrwName == "A"
	
		_nTotFar := 0
		_nTotVal := 0
		
		cArTabFar := (__cTabFar)->(GetArea())
		
		DbSelectArea((__cTabFar))
		(__cTabFar)->(DbGoTop())
		While !(__cTabFar)->(Eof())
			
			If (__cTabFar)->MARK  == "1"
				_nTotFar ++
				_nTotVal += (__cTabFar)->DXI_PSLIQU
			EndIf
			
			(__cTabFar)->(DbSkip())
		EndDo
		
		RestArea(cArTabFar)
	EndIf
		
return

/*{Protheus.doc} AGRX720HD
Seleção de todos os itens do browse [filiais / blocos e fardos]
@author jean.schulze
@since 28/06/2017
@version undefined
@param objBrowser, object, descricao
@param cBrwName, characters, descricao
@type function
*/
static function AGRX720HD(objBrowser, cBrwName)
	Local nCont     := 0
	Local cOperDat  := 0
	Local cArTabFar := ""
				
	Do Case   
	case cBrwName == "E"	//filiais
		
		cOperDat := IIF(_aFiliais[1,1] == "", "1", "")  
		For nCont := 1  to Len(_aFiliais) 
			_aFiliais[nCont,1] = cOperDat
	    Next nCont
	    		
	case cBrwName == "B"	//blocos
		
		DbSelectArea((__cTabBlc))
		DbGoTop()
		If DbSeek((__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_SAFRA+(__cTabBlc)->DXD_CODIGO) 
			cOperDat := IIF((__cTabBlc)->MARK  == "1", "", "1")
			While !(__cTabBlc)->(Eof())
				If RecLock((__cTabBlc),.f.)	
					(__cTabBlc)->MARK = cOperDat
					MsUnlock()	
				EndIf			
				(__cTabBlc)->( dbSkip() )	
			enddo
		endif		
					
	case cBrwName == "F"  	//fardos
	 
		DbSelectArea((__cTabFar))
		DbGoTop()
		If DbSeek((__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO+(__cTabFar)->DXI_CODIGO) 
			cOperDat := IIF((__cTabFar)->MARK  == "1", "", "1")
			While !(__cTabFar)->(Eof())
			
				If RecLock((__cTabFar),.f.)	
					(__cTabFar)->MARK = cOperDat
					MsUnlock()	
				EndIf	

				(__cTabFar)->( dbSkip() )	
			enddo
		endif	
	case cBrwName == "A"  	//fardos
	 
		DbSelectArea((__cTabFar))
		DbGoTop()
		If DbSeek((__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO+(__cTabFar)->DXI_CODIGO) 
			cOperDat := IIF((__cTabFar)->MBLC  == "1", "", "1")
			While !(__cTabFar)->(Eof())
			
				If RecLock((__cTabFar),.f.)	
					(__cTabFar)->MARK := cOperDat
					(__cTabFar)->MBLC := cOperDat
					MsUnlock()	
				EndIf			

				//Totalizadores de fardos e peso liquido
				If (__cTabFar)->MARK  == "1"
					_nTotFar ++
					_nTotVal += (__cTabFar)->DXI_PSLIQU	
				EndiF

				(__cTabFar)->( dbSkip() )	
			enddo
		endif
	endCase
	
	If cBrwName == "F"
		
		_nTotFar := 0
		_nTotVal := 0
		
		cArTabFar := (__cTabFar)->(GetArea())
		
		DbSelectArea((__cTabFar))
		(__cTabFar)->(DbGoTop())
		While !(__cTabFar)->(Eof())
			
			If (__cTabFar)->MARK  == "1"
				_nTotFar ++
				_nTotVal += (__cTabFar)->DXI_PSLIQU
			EndIf
			
			(__cTabFar)->(DbSkip())
		EndDo
		
		RestArea(cArTabFar)		
	EndIf

return

/*{Protheus.doc} AGRX720UP
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/05/2017
@version undefined
@param objBrowser, object, descricao
@type function
*/
static function AGRX720UP(objBrowser, lUpdAll, nLine) //tratamento de refresh	
	Default lUpdAll := .t.
	Default nLine   := 0
	
	if lUpdAll
        
		objBrowser:UpdateBrowse() //reconstroi tudo	
		
		if nLine > 0 //posiciona na linha
			objBrowser:GoTo(nLine)
		endif
	else	
		objBrowser:LineRefresh() //só refaz a linha
	endif
	
	objBrowser:GoColumn(1)	
	
return .t.

/*{Protheus.doc} AGRX720SL
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/05/2017
@version undefined 

@type function
*/
static function AGRX720SL
	Local aFarSel := {}
	Local aBlcRej := {}
	Local cTxtrej := ""
	Local nX      := 0
	
	DbSelectArea((__cTabFar))
	(__cTabFar)->(DbGoTop())
	(__cTabFar)->(DbSetOrder(2)) //markado
	If DbSeek("1") 
		While !(__cTabFar)->(Eof()) .and. (__cTabFar)->MARK == "1" 
			aADD(aFarSel, { (__cTabFar)->DXI_FILIAL,(__cTabFar)->DXI_CODIGO,(__cTabFar)->DXI_BLOCO, (__cTabFar)->DXI_SAFRA, (__cTabFar)->DXI_ETIQ,  (__cTabFar)->DXI_PSLIQU, (__cTabFar)->DXI_PSESTO, (__cTabFar)->DXI_CODRES })
			(__cTabFar)->( dbSkip() )	
		EndDo 
	EndIF
	
	//verifica os rejeitados
	DbSelectArea((__cTabFar))
	(__cTabFar)->(DbGoTop())
	(__cTabFar)->(DbSetOrder(2)) //markado
	If DbSeek("1T") 
		While !(__cTabFar)->(Eof()) .and. (__cTabFar)->MARK+(__cTabFar)->REJEITADO == "1T" 
			aADD(aFarSel, { (__cTabFar)->DXI_FILIAL,(__cTabFar)->DXI_CODIGO,(__cTabFar)->DXI_BLOCO, (__cTabFar)->DXI_SAFRA, (__cTabFar)->DXI_ETIQ,  (__cTabFar)->DXI_PSLIQU, (__cTabFar)->DXI_PSESTO, (__cTabFar)->DXI_CODRES })
			
			if aScan(aBlcRej, {|x| AllTrim(x[1]) == AllTrim((__cTabFar)->DXI_FILIAL +"-"+ (__cTabFar)->DXI_BLOCO)} ) = 0 //ainda não está no array - verificação por bloco
		 		AGRX720REJ(@aBlcRej, (__cTabFar)->DXI_FILIAL,(__cTabFar)->DXI_BLOCO, (__cTabFar)->DXI_CODIGO, _cCodCtr)
		 	endif
			
			(__cTabFar)->( dbSkip() )	
		EndDo 
	EndIF
	
	//verifica se já ocorreu uma rejeição - tela
	if len(aBlcRej) > 0
		
		For nX := 1 to Len(aBlcRej) 
			cTxtrej += STR0026 + iif(substr(aBlcRej[nX][1],1,1) == "-", substr(aBlcRej[nX][1],2,len(aBlcRej[nX][1])-1), aBlcRej[nX][1] )+ "," + STR0027 + Posicione("NNA",1,xFilial("NNA")+aBlcRej[nX][2],"NNA_NOME") + ". " + STR0028 + DTOC(aBlcRej[nX][3]) + ". " + STR0029 + aBlcRej[nX][4] +  Chr(13) + Chr(10) + Chr(13) + Chr(10) 
		Next nX 
		
		//chama a dialog
		MsgInfo(cTxtrej, STR0030)	
	endif

return aFarSel

/*{Protheus.doc} AGRX720REJ
Verificar se o bloco foi rejeitado
@author jean.schulze
@since 29/06/2017
@version undefined
@type function
*/
static function AGRX720REJ(aBlcRej, cFilBlc, cBloco, cFardo, cContrato)
	
	//verifica o bloco
	DbselectArea( "N7I")
	N7I->(DbGoTop())
	N7I->(DbsetOrder(1))
	
	if N7I->(Dbseek(xFilial("N7I")+cBloco+cFardo+cFilBlc))
		if cContrato == N7I->N7I_CODCTP //mesmo contrato
			aAdd(aBlcRej, {cFilBlc+"-"+cBloco, N7I->N7I_CLAEXT, N7I->N7I_DATARE, N7I->N7I_MOTIVO })
		endif	
	endif
	
return

/*{Protheus.doc} fVldTipQld
//TODO Descrição auto-gerada.
@author jean.schulze
@since 26/05/2017
@version undefined

@type function
*/
static function fVldTipQld
	if UBAA060BLO(_cTpUBA060)
		Processa({|| SetDataBlc()},STR0023) //atualiza a listagem
		AGRX720UP(oBrowse3)
		Processa({|| SetDataFar()},STR0024) //atualiza a listagem
		AGRX720UP(oBrowse4)
	else
		return .f.
	endif
return .t.


/** {Protheus.doc} SetDataBlc
Função que monta as Temp-Tables da Rotina

@param:     Nil
@return:    boolean - True ou False
@author:    Equipe Agroindustria
@since:     18/05/2015
@Uso:       AGRX720 - Consulta de Blocos/Fardos
*/
Static Function MontaTabel(cAliasTMP,cNameTMP, aCpsBrow, aIdxTab)
    Local nCont 	:= 0
    Local cTabela	:= ''	
	Local aStrTab 	:= {}	//Estrutura da tabela
	Local oArqTemp	:= Nil	//Objeto retorno da tabela

    //-- Busca no aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(aCpsBrow) 
        aADD(aStrTab,{aCpsBrow[nCont][2], aCpsBrow[nCont][3], aCpsBrow[nCont][4], aCpsBrow[nCont][5] })
    Next nCont 
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas 
    oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})	  
    
    //inserido o alias de tabela
    cAliasTMP := cTabela
    
    //inserido o real name da tabela
    cNameTMP := oArqTemp:GetRealName() 
      	
Return .t.

/** {Protheus.doc} SetDataBlc
Função que retorna os Blocos selecionáveis

@param:     Nil
@return:    boolean - True ou False
@author:    Equipe Agroindustria
@since:     18/05/2015
@Uso:       AGRX720 - Consulta de Blocos/Fardos
*/
Static Function SetDataBlc()
	
	Local cFiltro    := ""
	Local nCont      := 0
	Local cFiliais   := ""
	Local cTpQualids := ""
	Local aLstTipos	 := STRTOKARR (_cTpUBA060 , "OU" )
	Local aLstFils   := aClone(_aFiliais)
	
	//--Deleta tudo da temporaria para realizar nova busca
	DbSelectArea((__cTabBlc))
	DbGoTop()
	If DbSeek((__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_SAFRA+(__cTabBlc)->DXD_CODIGO) 
		While !(__cTabBlc)->(Eof())
			
			if (__cTabBlc)->MARK = "1" .and. AScan(_aBlocoSel, (__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_CODIGO ) == 0 //não está na lista
				aADD(_aBlocoSel,(__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_CODIGO) //adicionado ao bloco
			elseif (__cTabBlc)->MARK <> "1" .and. (nPos := AScan(_aBlocoSel, (__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_CODIGO )) > 0 //não está na lista
				aDel(_aBlocoSel, nPos )
				aSize(_aBlocoSel, Len( _aBlocoSel )-1)
			endif
			
			If RecLock((__cTabBlc),.f.)	
				(__cTabBlc)->(DbDelete())
				(__cTabBlc)->(MsUnlock())
			EndIf			
			(__cTabBlc)->( dbSkip() )	
		EndDo 
	EndIF
	
	//monta as filiais disponíveis da consulta
	For nCont := 1  to Len(aLstFils) 
		if aLstFils[nCont][1] = "1" //selecionada 
			cFiliais +=  iif(!empty(cFiliais),",","") + "'" + xFilial("DXD",aLstFils[nCont][2]) + "'"//retorna a filial conforme a seleção
        endif
    Next nCont
    
    if !empty(cFiliais)
    	cFiltro += " AND DXD.DXD_FILIAL IN (" + cFiliais + ")"
    else 
    	return .t. //sem filiais selecionadas
    endif    
    
    //monta os tipos disponíveis da consulta
	For nCont := 1  to Len(aLstTipos) 
		if !empty(aLstTipos[nCont]) //not null
			cTpQualids +=  iif(!empty(cTpQualids),",","") + "'" + AllTrim(aLstTipos[nCont]) + "'" //monta os blocos conforme o tipo
        endif
    Next nCont
    
    if !empty(cTpQualids)
    	cFiltro += " AND DXD.DXD_CLACOM IN (" + cTpQualids + ")"
    endif  
    	    
    //recoloca os filtros 
    if !empty(_cFiltrDXI)
    	cFiltro += " AND " + _cFiltrDXI
    endif
    
    //recoloca os filtros da tabela N9D
    if !empty(_cFiltrN9D)
    	cFiltro += " AND " + _cFiltrN9D
	endif

    //Se for especifica, limita os blocos
    if !empty(_cFiltrN80)
    	cFiltro += " AND " + _cFiltrN80
	endif	
	
	
	
	//busca os blocos conforme filtro montado
	InsRegBlc(cFiltro)

return .t.


/*{Protheus.doc} InsRegBlc
//TODO Descrição auto-gerada.
@author jean.schulze
@since 02/04/2018
@version 1.0
@return ${return}, ${return_description}
@param cFiltro, characters, descricao
@type function
*/
Static Function InsRegBlc(cFiltro)
	
	Local cAliasDXD	 := GetNextAlias()
	Local cQuery := ""
	Local nQtdFrd    := 0

	cQuery := "SELECT DXD.DXD_FILIAL, DXD.DXD_CODIGO, DXD.DXD_CLACOM, DXD.DXD_SAFRA, DXD.DXD_QTDMAX, DXD.R_E_C_N_O_ AS DXDRECNO "
	
	/*cQuery += " (SELECT COUNT(*) "
	cQuery += " FROM " + RetSqlName("DXI") + " TAB " 
	cQuery += " WHERE TAB.DXI_FILIAL = DXD.DXD_FILIAL "
	cQuery += " AND TAB.DXI_SAFRA    = DXD.DXD_SAFRA "
	cQuery += " AND TAB.DXI_BLOCO    = DXD.DXD_CODIGO "
	cQuery += " AND TAB.D_E_L_E_T_   = ' ') AS SOMA "
	*/	
	cQuery += " FROM " + RetSqlName("DXD") + " DXD "
	cQuery += " INNER JOIN " + RetSqlName("DXI") + " DXI ON  DXI.DXI_FILIAL = DXD.DXD_FILIAL "
	cQuery += 			                   " AND DXI.DXI_SAFRA  = DXD.DXD_SAFRA "
	cQuery += 			                   " AND DXI.DXI_BLOCO  = DXD.DXD_CODIGO "
	cQuery += 			                   " AND DXI.D_E_L_E_T_ = '' "

	If !empty(_cFiltrN9D) //tem filtro pelo N9D
		cQuery += " INNER JOIN " + RetSqlName("N9D") + " N9D ON  N9D.N9D_FILIAL = DXI.DXI_FILIAL "
		cQuery += 	                           		   " AND N9D.N9D_SAFRA      = DXI.DXI_SAFRA  "
		cQuery += 	                           		   " AND N9D.N9D_FARDO      = DXI.DXI_ETIQ  "
		cQuery += 						       		   " AND N9D.N9D_STATUS		< '3' "  //difente de inativo
		cQuery += 						       		   " AND N9D.D_E_L_E_T_ = '' "
	EndIf
	
	cQuery += " WHERE DXD.D_E_L_E_T_ = '' "
	cQuery += cFiltro 
	cQuery += " GROUP BY DXD.DXD_FILIAL, "
	cQuery += 			" DXD.DXD_CODIGO,"
	cQuery += 			" DXD.DXD_CLACOM,"
	cQuery += 			" DXD.DXD_SAFRA, "
	cQuery += 			" DXD.DXD_QTDMAX, "  
	cQuery += 			" DXD.R_E_C_N_O_  "  	
	cQuery += " ORDER BY DXD.DXD_CODIGO  "	
	
	
	//apropriação de dados
	cAliasDXD := GetSqlAll(cQuery)
	DbselectArea( cAliasDXD )
	DbGoTop()
	While ( cAliasDXD )->( !Eof() )
	
		SetDataFar(,,,.T.,(cAliasDXD)->DXDRECNO,@nQtdFrd)

		If _lAuto //se for automático já trás marcado
            cMark := '1'
		Else
			cMark := iif(AScan(_aBlocoSel, (cAliasDXD)->DXD_FILIAL+(cAliasDXD)->DXD_CODIGO ) > 0, "1", "")
		EndiF

		RecLock((__cTabBlc),.T.)
			(__cTabBlc)->MARK	    := cMark //start marcado, execto quando já estava desmarcado 	
			(__cTabBlc)->DXD_FILIAL	:= (cAliasDXD)->DXD_FILIAL		
			(__cTabBlc)->DXD_CODIGO	:= (cAliasDXD)->DXD_CODIGO
			(__cTabBlc)->QTDE_DISPO	:= 	Alltrim(STR(nQtdFrd))		
			(__cTabBlc)->DXD_CLACOM	:= (cAliasDXD)->DXD_CLACOM	
			(__cTabBlc)->DXD_SAFRA	:= (cAliasDXD)->DXD_SAFRA
			(__cTabBlc)->RECNO   	:= (cAliasDXD)->DXDRECNO

		(__cTabBlc)->(MsUnlock())
				
		(cAliasDXD)->(dbSkip())
	EndDo
	
	(cAliasDXD)->(dbCloseArea())	
	

return .t.

/** {Protheus.doc} SetDataFar
Função que retorna os Fardos selecionáveis

@param:     Nil
@return:    boolean - True ou False
@author:    Equipe Agroindustria
@since:     18/05/2015
@Uso:       AGRX720 - Consulta de Blocos/Fardos
@param:     lBuscaFrd, boolean, .T. - Apenas buscar os fardos (Não inclui)
@param:     cRenoBlc, character, Recno do bloco
@param:     nQtdFrd, number, Quantidade de fardos
*/
Static Function SetDataFar(nLineDel, cDel, cOperac, lBuscaFrd, cRenoBlc, nQtdFrd)
	
	Local cFiltro     := ""
	Local nCont       := 0
	Local nLinhaAtua  := 0
	Local nIt		  := 0 // Iterador do filtro hvi
	Local aDadosGrd	  := {} // Array auxiliar para montagem do filtro hvi
	Local cArTabFar   := ""
	
	Private aNoSelec    := {}
	
	Default nLineDel 		:= 0 // Linha de verificação de delete ou undelete
	Default cDel			:= "" // Evento de DELETE ou UNDELETE
	Default cOperac         := ""
	Default lBuscaFrd		:= .F.
		
	If _lGridActv // Se a grid hvi está ativa então realiza a construção do array para o filtro hvi
		aDadosGrd := _oView:GetModel():GetModel("N7HSUBMODEL"):GetData()
		_aFilHvi := {}
		For nIt := 1 To Len(aDadosGrd)				
			If nIt == nLineDel .AND. cDel == "DELETE"
				Loop
			ElseIf nIt == nLineDel .AND. cDel == "UNDELETE"
			 	aDadosGrd[nIt][3] == .F.
			EndIf
			If aDadosGrd[nIt][3] == .F. .AND. !Empty(aDadosGrd[nIt][1][1][2])
				aAdd(_aFilHvi, aDadosGrd[nIt][1][1])	
			EndIf
		Next nIt
	EndIf
	      
    //monta as qualidade em HVI disponíveis na consulta
	For nCont := 1  to Len(_aFilHvi) 
		If FieldPos(ALLTRIM(_aFilHvi[nCont][1] )) > 0
			cFiltro += " AND DX7." + ALLTRIM(_aFilHvi[nCont][1]) + " BETWEEN '" + cValToChar(_aFilHvi[nCont][3]) + "' AND '" + cValToChar(_aFilHvi[nCont][4]) + "'"
		EndIf
   	Next nCont
    	    
    if !_lReprov //filtra os blocos reprovados
    	cFiltro += " AND N7I.N7I_BLOCO  IS NULL"
    endif 
	
	 //recoloca os filtros 
    if !empty(_cFiltrDXI)
    	cFiltro += " AND " + _cFiltrDXI
    endif
    
    //recoloca os filtros da tabela N9D
    if !empty(_cFiltrN9D)
    	cFiltro += " AND " + _cFiltrN9D
	endif
	
    //Se for especifica, limita os blocos
    if !empty(_cFiltrN80)
		cFiltro += " AND " + _cFiltrN80
	endif	
	
	If lBuscaFrd
	
		nQtdFrd := 0
		
		cFiltro := cFiltro + "AND (DXD.R_E_C_N_O_ = '" + Alltrim(STR(cRenoBlc))+ "')"
		
		InsRegFar(cFiltro, .T., @nQtdFrd)
		
	ElseIf empty(cOperac) //vamos buscar todos os fardos novamente
		//-- variavel para informar total de fardos selecionados
		//-- inciado valor zero pois sempre zera-se temporaria		
		//--Deleta tudo da temporaria para realizar nova busca
		DbSelectArea((__cTabFar))
		DbGoTop()
		If DbSeek((__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO+(__cTabFar)->DXI_CODIGO) 
			While !(__cTabFar)->(Eof())
				If RecLock((__cTabFar),.f.)	
					if (__cTabFar)->MARK <> "1" //deselecionou 
						aADD(aNoSelec, (__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_BLOCO+(__cTabFar)->DXI_CODIGO)
					endif
					(__cTabFar)->(DbDelete())
					(__cTabFar)->(MsUnlock())
				EndIf			
				(__cTabFar)->( dbSkip() )	
			EndDo 
		EndIF
		
		//monta os blocos selecionados
		nLinhaAtua := (__cTabBlc)->(Recno())
		DbSelectArea((__cTabBlc))
		DbGoTop()
		If DbSeek((__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_SAFRA+(__cTabBlc)->DXD_CODIGO) 
			nCont := 1
			cSqlExtra := ""
			While !(__cTabBlc)->(Eof())
				if (__cTabBlc)->MARK = "1" //selecionada 
					//implementar recno // ou ver uma operação melhor
					if nCont > 100
						InsRegFar(cFiltro + " AND (DXD.R_E_C_N_O_ = '" + alltrim(str((__cTabBlc)->RECNO ))+ "'" + cSqlExtra + ")")
						nCont := 1
						cSqlExtra := ""
					else 
						cSqlExtra += " OR DXD.R_E_C_N_O_ = '" + alltrim(str((__cTabBlc)->RECNO ))+ "'""
						nCont += 1
					endif	 	
		        endif
				(__cTabBlc)->( dbSkip() )	
			EndDo 
			
			//faz a sobra
			if !empty(cSqlExtra)
				InsRegFar(cFiltro + " AND (" + substr(cSqlExtra, 4 ) + ")")
			endif
		EndIF
		DbGoto(nLinhaAtua)		
		
		//resresh da area de seleção de fardos
		TCRefresh(__cNamFar)
				
	else //busca determinado bloco
	    
	    if cOperac == "D" //delete
		    //--Deleta tudo da temporaria para realizar nova busca
			DbSelectArea((__cTabFar))
			DbGoTop()
			If DbSeek((__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_SAFRA+(__cTabBlc)->DXD_CODIGO) 
				While !(__cTabFar)->(Eof()) .and. alltrim((__cTabBlc)->DXD_FILIAL+(__cTabBlc)->DXD_SAFRA+(__cTabBlc)->DXD_CODIGO) == alltrim((__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_SAFRA+(__cTabFar)->DXI_BLOCO)
					If RecLock((__cTabFar),.f.)	
						if (__cTabFar)->MARK <> "1" //deselecionou 
							aADD(aNoSelec, (__cTabFar)->DXI_FILIAL+(__cTabFar)->DXI_BLOCO+(__cTabFar)->DXI_CODIGO)
						endif	
						(__cTabFar)->(DbDelete())
						(__cTabFar)->(MsUnlock())
					EndIf			
					(__cTabFar)->( dbSkip() )	
				EndDo 
			EndIF
		else //select
			cFiltro += " AND ( DXI_FILIAL = '"+(__cTabBlc)->DXD_FILIAL+"' AND DXI_SAFRA = '"+(__cTabBlc)->DXD_SAFRA+"' AND DXI_BLOCO = '"+(__cTabBlc)->DXD_CODIGO+"')"
			InsRegFar(cFiltro)
			
			//resresh da area de seleção de fardos
			TCRefresh(__cNamFar)
		endif
			    
	endif
	
	If !lBuscaFrd
		_afardoSel := {}
		
		_nTotFar := 0
		_nTotVal := 0
		
		cArTabFar := (__cTabFar)->(GetArea())
		
		DbSelectArea((__cTabFar))
		(__cTabFar)->(DbGoTop())
		While !(__cTabFar)->(Eof())
			
			If (__cTabFar)->MARK  == "1"
				_nTotFar ++
				_nTotVal += (__cTabFar)->DXI_PSLIQU
			EndIf
			
			(__cTabFar)->(DbSkip())
		EndDo
		
		RestArea(cArTabFar)
	EndIf
	
return .t.

/*{Protheus.doc} InsRegFar
Seleção dos fardos
@author jean.schulze
@since 09/04/2018
@version 1.0
@return ${return}, ${return_description}
@param cFiltro, characters, descricao
@param lBuscaFrd, boolean, .T. - Apenas busca qtd de fardos
@param nQtdFrd, number, Quantidade de fardos
@type function
*/
Static Function InsRegFar(cFiltro, lBuscaFrd, nQtdFrd)
	Local cArea       := GetArea()
	Local cAliasDXI   := GetNextAlias()
	Local nCont       := 0
	Local cQuery      := ""
	Local cCamposHVI  := ""
	Local cValorHVI   := ""
	Local cVlrNullHVI := ""
	Local lRastro
	
	Default lBuscaFrd := .F.
	Default nQtdFrd	  := 0

	//monta a lista de itens dos dados HVI
	For nCont := 1  to Len(_oStruDX7:aFields) 
		cCamposHVI   += "," + _oStruDX7:aFields[nCont][3] 
		cVlrNullHVI  += IIF(TamSx3(_oStruDX7:aFields[nCont][3])[3] = 'N',', 0',", ''")
    Next nCont
		
	//monta a query de busca
	cQuery := "SELECT DXI.DXI_FILIAL, DXI.DXI_CODPRO, DXI.DXI_LOTE, DXI.DXI_CODIGO, DXI.DXI_BLOCO, DXI.DXI_PSLIQU, DXI.DXI_PSESTO, DXI.DXI_CLACOM, DXI.DXI_SAFRA, DXI.DXI_ETIQ, DXI.DXI_CODRES, DXI.R_E_C_N_O_ AS DX_RECNO, N7I.N7I_BLOCO, DX7.R_E_C_N_O_ AS DX7_RECNO "		      
	cQuery += " FROM " + RetSqlName("DXI") + " DXI "
    cQuery += " INNER JOIN " + RetSqlName("DXD") + " DXD ON DXD.DXD_FILIAL  = DXI.DXI_FILIAL " 
	cQuery +=                             " AND DXD.DXD_SAFRA  = DXI.DXI_SAFRA "
	cQuery +=                             " AND DXD.DXD_CODIGO = DXI.DXI_BLOCO "
	cQuery +=                             " AND DXD.D_E_L_E_T_ = '' "
	cQuery += " LEFT JOIN " + RetSqlName("DX7") + " DX7 ON  DX7.DX7_ETIQ   = DXI.DXI_ETIQ "
	cQuery +=                             " AND DX7.D_E_L_E_T_ <> '*' "
	cQuery +=                             " AND DX7.DX7_FILIAL = DXI.DXI_FILIAL "  
	cQuery +=                             " AND DX7.DX7_SAFRA  = DXI.DXI_SAFRA "   
	cQuery +=                             " AND DX7.DX7_ATIVO = '1' "
	cQuery += " LEFT JOIN " + RetSqlName("N7I") + " N7I ON  N7I.N7I_BLOCO   = DXI.DXI_BLOCO "
	cQuery +=                             " AND N7I.D_E_L_E_T_ = '' "
	cQuery +=                             " AND N7I.N7I_FARDO  = DXI.DXI_CODIGO " 
	cQuery +=                             " AND N7I.N7I_FILORG = DXI.DXI_FILIAL "     
	
 	If !empty(_cFiltrN9D)  //tem filtro pelo N9D
		cQuery += " INNER JOIN " + RetSqlName("N9D") + " N9D ON  N9D.N9D_FILIAL = DXI.DXI_FILIAL "
		cQuery += 	                           		   " AND N9D.N9D_SAFRA      = DXI.DXI_SAFRA  "
		cQuery += 	                           		   " AND N9D.N9D_FARDO      = DXI.DXI_ETIQ  "
		cQuery += 						       		   " AND N9D.N9D_STATUS		< '3' "  //ativo
		cQuery += 						       		   " AND N9D.D_E_L_E_T_ = '' "
	EndIf
	
	cQuery += " WHERE DXI.D_E_L_E_T_ = '' "        
	cQuery += cFiltro
	
	cQuery += " GROUP BY DXI.DXI_FILIAL,"
	cQuery += 		 " DXI.DXI_CODIGO,"
	cQuery += 		 " DXI.DXI_CODPRO,"	
	cQuery += 		 " DXI.DXI_LOTE,"
	cQuery += 		 " DXI.DXI_BLOCO,"
	cQuery += 		 " DXI.DXI_PSLIQU," 
	cQuery += 		 " DXI.DXI_PSESTO," 
	cQuery += 		 " DXI.DXI_CLACOM,"
	cQuery += 		 " DXI.DXI_SAFRA,"
	cQuery += 		 " DXI.DXI_ETIQ,"
	cQuery += 		 " DXI.DXI_CODRES,"	
	cQuery += 		 " DXI.R_E_C_N_O_," 
	cQuery += 		 " N7I.N7I_BLOCO,"
	cQuery += 		 " DX7.R_E_C_N_O_ "
	cQuery += " ORDER BY DXI.DXI_BLOCO "	
			         		           
	//apropriação de dados
    cAliasDXI := GetSqlAll(cQuery)
	DbGoTop()
		
	while ( cAliasDXI )->( !Eof() )	

		//verifica se o produto controla lote e se já possui lote.
		lRastro := .T.

		If !Empty((cAliasDXI)->DXI_CODPRO)
			If Rastro((cAliasDXI)->DXI_CODPRO)				
				If Empty((cAliasDXI)->DXI_LOTE)
					lRastro := .F. //se controlar lote e não possuir lote, False.
				EndIf
			EndIf			
		EndIf

		if !(len(_aFardoExc) > 0 .and. AScan(_aFardoExc, (cAliasDXI)->DX_RECNO ) > 0)  //retirar os que estão na exclusão

			
				if !(!_lReprov .and. !empty((cAliasDXI)->N7I_BLOCO)) //Não aceita reprovados
						
					cMark := "1" //valor padrão
					cRejeitado := iif(!empty((cAliasDXI)->N7I_BLOCO),'T','F')
					
					If lRastro
					
						If lBuscaFrd
							nQtdFrd++
							(cAliasDXI)->(DbSkip())
							LOOP							
						EndIf
						
						if len(aNoSelec) > 0 //tratando o padrão - performance no array
							cMark := iif(AScan(aNoSelec, (cAliasDXI)->DXI_FILIAL+(cAliasDXI)->DXI_BLOCO+(cAliasDXI)->DXI_CODIGO ) > 0, "", "1") //start marcado, execto quando já estava desmarcado 
												
						elseif len(_afardoSel) > 0 //tratando o update
							cMark := iif(AScan(_afardoSel, (cAliasDXI)->DX_RECNO) > 0, "1", "") //somente os que já foram selecionados
														
						endif						
						
						cValorHVI := cVlrNullHVI //reset correct
						
						//copia dos dados de HVI
						IF !empty((cAliasDXI)->DX7_RECNO) 
							
							if (Select("DX7") == 0)
								DbSelectArea("DX7")
							endif
											
							DX7->(dbGoto((cAliasDXI)->DX7_RECNO))
															
							if !EOF() .and. (DX7->DX7_FILIAL == (cAliasDXI)->DXI_FILIAL .and. DX7->DX7_SAFRA == (cAliasDXI)->DXI_SAFRA .and. DX7->DX7_ETIQ == (cAliasDXI)->DXI_ETIQ)
								cValorHVI := "" //reset
								For nCont := 1  to Len(_oStruDX7:aFields)
									If TamSx3(_oStruDX7:aFields[nCont][3])[3] = 'N'
										cValorHVI += ", "+ alltrim(str( &("DX7->"+_oStruDX7:aFields[nCont][3])))
									Else
										cValorHVI += ", '"+ alltrim(&("DX7->"+_oStruDX7:aFields[nCont][3]))+"'"
									EndIf
								Next nCont
							endif 
											
						endif
						
						/*if nQry > 50
							AGRExecSQL(cQryInsert)

							cQryInsert := ""
							nQry := 1

						else*/ 
							//cQryInsert += " INSERT INTO "+__cNamFar + " (DXI_FILIAL, DXI_SAFRA, DXI_BLOCO, DXI_CODIGO,  MARK, REJEITADO ,  MBLC,  DXI_CLACOM,  DXI_PSLIQU , DXI_ETIQ, DXI_PSESTO "+cCamposHVI+" ) VALUES " + /*cQryInsert +*/ "('"+(cAliasDXI)->DXI_FILIAL+"', '"+(cAliasDXI)->DXI_SAFRA+"', '"+(cAliasDXI)->DXI_BLOCO+"', '"+(cAliasDXI)->DXI_CODIGO+"', '"+cMark+"', '"+cRejeitado+"', '1',  '"+(cAliasDXI)->DXI_CLACOM+"' ,  '"+alltrim(str((cAliasDXI)->DXI_PSLIQU))+"' , '"+(cAliasDXI)->DXI_ETIQ+"', '"+alltrim(str((cAliasDXI)->DXI_PSESTO))+"' "+cValorHVI+"); "+CHR(13)+CHR(10)
							//nQry += 1
						//endif
							Reclock((__cTabFar),.t.)
							(__cTabFar)->DXI_FILIAL := (cAliasDXI)->DXI_FILIAL
							(__cTabFar)->DXI_SAFRA  := (cAliasDXI)->DXI_SAFRA
							(__cTabFar)->DXI_BLOCO  := (cAliasDXI)->DXI_BLOCO
							(__cTabFar)->DXI_CODIGO := (cAliasDXI)->DXI_CODIGO
							(__cTabFar)->MARK       := cMark
							(__cTabFar)->REJEITADO  := cRejeitado
							(__cTabFar)->MBLC       := '1'
							(__cTabFar)->DXI_CLACOM := (cAliasDXI)->DXI_CLACOM
							(__cTabFar)->DXI_PSLIQU := (cAliasDXI)->DXI_PSLIQU
							(__cTabFar)->DXI_ETIQ   := (cAliasDXI)->DXI_ETIQ
							(__cTabFar)->DXI_PSESTO := (cAliasDXI)->DXI_PSESTO
							(__cTabFar)->DXI_CODRES := (cAliasDXI)->DXI_CODRES						
							aAux1 := StrTokArr2(cCamposHVI,',')
							aAux2 := StrTokArr2(cValorHVI,',')
							For nCont := 1 to Len(aAux1)
								&("(__cTabFar)->"+(aAux1[nCont])) := &(aAux2[nCont])
							Next
							(__cTabFar)->(MsUnlock())
					EndIf						
				endif
					
		endif
			
		(cAliasDXI)->(dbSkip())
	Enddo
	
	/*if !empty(cQryInsert)
		AGRExecSQL(cQryInsert)
	endif*/	
	
	(cAliasDXI)->(dbCloseArea())	
	
	If !lBuscaFrd	
		_afardoSel := {}
	EndIf
	
	Restarea(cArea)
return .t.

/*{Protheus.doc} AGRX720FOC
(Evento de Foco no Browse para posicionar 
na coluna 1 de check)
@type function
@author roney.maia
@since 14/06/2017
@version 1.0
@param tGrid, ${Objeto}, (TGrid referente ao Browse4)
*/
Static Function AGRX720FOC(tGrid)
	tGrid:GoColumn(1)	
Return


/*{Protheus.doc} AGRX720DBC
Posiciona e double click na linha
@author jean.schulze
@since 29/06/2017
@version undefined
@param oBrw, object, descricao
@type function
*/
Static function AGRX720DBC(oBrw)
	oBrw:GoColumn(1)
	oBrw:DoubleClick()
return

/*{Protheus.doc} AGRX720VWL
(Função que cria a View resposável pela Grid de Filtro HVI)
@type function
@author roney.maia
@since 04/07/2017
@version 1.0
@param oPnlOwner, objeto, (Objeto Owner-Pai que irá ser construido a View)
*/
Static Function AGRX720VWL(oPnlOwner)

	Local oStruN7HM  	:= FWFormStruct( 1, "N7H", { |x| !ALLTRIM(x) $ 'N7H_FILIAL, N7H_CODCTR, N7H_ITEM'}) // Estrutura de Qualidade do Algodão
	Local oStruN7HV  	:= FWFormStruct( 2, "N7H" , { |x| !ALLTRIM(x) $ 'N7H_CODCTR, N7H_CAMPO, N7H_ITEM'})	// Estrutura da tabela de qualidade de algodão	
	Local bValid		:= {|oModelNJR, cCampo, xNewValue, xOldValue| AGRX720VLD(oModelNJR, cCampo, xNewValue, xOldValue)}
	Local oModel		:= MpFormModel():New("AGRX720")

	dbSelectArea( "N7H" )
	N7H->( dbSetOrder( 1 ) )

	// Definição do MODEL ###########################
	
	oStruN7HM:SetProperty("N7H_HVIDES" , MODEL_FIELD_VALID, bValid)
	oStruN7HM:SetProperty("N7H_VLRINI" , MODEL_FIELD_VALID, bValid)
	oStruN7HM:SetProperty("N7H_VLRFIM" , MODEL_FIELD_VALID, bValid)
	

	oModel:AddFields( "N7HOWNER", /*cOwner*/, oStruN7HM, , /*bPost*/, /*bLoad */  )
	oModel:GetModel( "N7HOWNER" ):SetOnlyQuery()
	
	oModel:AddGrid( "N7HSUBMODEL", "N7HOWNER", oStruN7HM, {|oGridModel, nLine, cAction| AGRX720UND(oGridModel, nLine, cAction)}, , , , {|oObj, lCopia| _aGrdDt} )  // Adiciona Grid e o Array de Carga de Dados
	oModel:GetModel( "N7HSUBMODEL" ):SetUniqueLine( { "N7H_CAMPO" } ) 
	oModel:GetModel( "N7HSUBMODEL" ):SetOptional( .T. )
	oModel:GetModel( "N7HSUBMODEL" ):SetOnlyQuery() // Seta como somente para consulta
	
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	
	oModel:SetPrimaryKey({'N7H_CAMPO'}) // Seta chave primária, Necessário pois a grid não possui um relacionamento definido
	
	// ###############################################
	
	// Definição da View #############################
	
	// Seta propriedade das PVARS
	oStruN7HV:SetProperty("N7H_VLRINI" , MVC_VIEW_PVAR, {|oGridN7H, cCampo| Iif(Empty(oGridN7H:GetValue("N7H_CAMPO")), "@E", PesqPict("DX7", oGridN7H:GetValue("N7H_CAMPO")))})
	oStruN7HV:SetProperty("N7H_VLRFIM" , MVC_VIEW_PVAR, {|oGridN7H, cCampo| Iif(Empty(oGridN7H:GetValue("N7H_CAMPO")), "@E", PesqPict("DX7", oGridN7H:GetValue("N7H_CAMPO")))})
	
	_oView	:= FwFormView():New() // Instância uma nova view para a grid de qualidade do algodão, setando o pai a view principal	
	_oView:SetModel(oModel) // Seta o Model			
   	_oView:AddGrid( "BROWSE1GRID", oStruN7HV, "N7HSUBMODEL")    
  	_oView:CreateHorizontalBox( "BROWSE1BOX" , 100)                          
   	_oView:SetOwnerView("BROWSE1GRID", "BROWSE1BOX")                             	
   	_oView:SetOwner(oPnlOwner) // Seta o objeto pai que sera construido a view
   	_oView:SetViewAction( 'DELETELINE', { |oView,cIdView, nLine| _nLine := nLine, Iif(oView:GetModel():GetModel("N7HSUBMODEL"):IsDeleted(), Processa({|| SetDataFar(_nLine, "DELETE")},STR0024), Processa({|| SetDataFar(_nLine, "UNDELETE")},STR0024)), AGRX720UP(oBrowse4) , oView:GetViewObj(cIdView)[3]:oBrowse:SetFocus()}) 	    			   	
	_oView:Activate() // Realiza a ativação da view
		
	_lGridActv := .T. // Variável de controle
	
	// Altera a largura das colunas para melhorar a usabilidade
	//_oView:GetViewObj("BROWSE1GRID")[3]:oBrowse:oBrowse:SetColumnSize(0, 80) 
	//_oView:GetViewObj("BROWSE1GRID")[3]:oBrowse:oBrowse:SetColumnSize(1, 110)
	//_oView:GetViewObj("BROWSE1GRID")[3]:oBrowse:oBrowse:SetColumnSize(2, 110)

Return

/*{Protheus.doc} AGRX720VLD
(Função que trata a validação dos campos da Grid de Filtro)
@type function
@author roney.maia
@since 04/07/2017
@version 1.0
@param oModelGrd, objeto, (SubModelGrid)
@param cCampo, character, (Campo que disparou a validação)
@param xNewValue, variável, (Novo valor inserido)
@param xOldValue, variável, (Valor que ja continha no campo)
@return ${return}, ${.T. - Válido, .F. - Inválido}
*/
Static Function AGRX720VLD(oModelGrd, cCampo, xNewValue, xOldValue)

	Local lRet 		:= .T.
	Local nIt			:= 0
	Local cValor		:= ""
	Local nLine		:= oModelGrd:GetLine()
	
	If "N7H_HVIDES" $ cCampo											
		For nIt := 1 To Len(_oStruDX7:AFIELDS)	// Percore os campos da DX7
			// Compara os Titulos dos campos a fim de encontrar o campo informado na N7H_HVIDES	 
			If UPPER(AllTrim(_oStruDX7:AFIELDS[nIt][1])) == UPPER(AllTrim(oModelGrd:GetValue("N7H_HVIDES")))
				// Se os valor encontrado é diferente do que contem no campo, preenche o campo
				If AllTrim(_oStruDX7:AFIELDS[nIt][3]) != AllTrim(oModelGrd:GetValue("N7H_CAMPO")) 
					oModelGrd:SetValue('N7H_CAMPO', _oStruDX7:AFIELDS[nIt][3])
					cValor := _oStruDX7:AFIELDS[nIt][3]
					lRet := .T.
					Exit
				Else // Senão o valor ja está contido no campo
					cValor := _oStruDX7:AFIELDS[nIt][3]
					lRet := .T.
					Exit
				EndIf
			Else // Caso não encontrar o campo, o valor informado é invalido
				lRet := .F.
			EndIf
		Next nIt
		If Empty(oModelGrd:GetValue("N7H_HVIDES")) // Se o campo informado estiver vazio, limpa o campo hvi
			oModelGrd:LoadValue('N7H_CAMPO', "")
			lRet := .T.
		EndIf
		If lRet
			oModelGrd:LoadValue('N7H_VLRINI', 0)
			oModelGrd:LoadValue('N7H_VLRFIM', 0)
		Else
			oModelGrd:LoadValue('N7H_CAMPO', "")
			oModelGrd:GetModel():SetErrorMessage( , , oModelGrd:GetId() , "", "", STR0031, STR0032, "", "") // # "A descrição HVI informada é inválida.", "Informar uma descrição HVI válida."
		EndIf
	EndIf
	
	If lRet 
		For nIt := 1 To oModelGrd:Length() // Validação de Linha Duplicada, que difere do changeline padrão do protheus
			If !oModelGrd:IsDeleted(nIt) .AND. ALLTRIM(oModelGrd:GetValue("N7H_CAMPO", nIt)) == ALLTRIM(cValor) .AND. nIt != nLine
				oModelGrd:LoadValue('N7H_CAMPO', "")
				oModelGrd:GetModel():SetErrorMessage( , , oModelGrd:GetId() , "", "", STR0033, STR0034, "", "") // # "Já existe uma filtro de qualidade com a mesma descrição HVI informada.", "Informar uma descrição HVI diferente."
				Return .F.
			EndIf
		Next nIt
		Processa({|| SetDataFar()},STR0024) // Se a validação estiver ok do campo, refaz a consulta dos fardos
		AGRX720UP(oBrowse4) // Atualiza o browse de fardos
		_oView:GetViewObj("BROWSE1GRID")[3]:oBrowse:SetFocus() // Devolve o foco a grid devido ao Processa
	EndIf
	
Return lRet

/*{Protheus.doc} AGRX720UND
(Função que trata a validação do UNDELETE em específico)
@type function
@author roney.maia
@since 04/07/2017
@version 1.0
@param oGridModel, objeto, (SubModelGrid)
@param nLine, numérico, (Linha atual posicionada na grid)
@param cAction, character, (Ação disparada pela validação)
@return ${return}, ${.T. - Válido, .F. - Inválido}
*/
Static Function AGRX720UND(oGridModel, nLine, cAction)
	
	Local lRet 	:= .T.
	Local nIt		:= 0
	Local cValor	:= oGridModel:GetValue("N7H_CAMPO", nLine)
		
	If cAction == "UNDELETE"
		For nIt := 1 To oGridModel:Length() // Validação de Linha Duplicada, que difere do changeline padrão do protheus
		If !oGridModel:IsDeleted(nIt) .AND. ALLTRIM(oGridModel:GetValue("N7H_CAMPO", nIt)) == ALLTRIM(cValor) .AND. nIt != nLine
			oGridModel:GetModel():SetErrorMessage( , , oGridModel:GetId() , "", "", STR0033, STR0034, "", "") // # "Já existe uma filtro de qualidade com a mesma descrição HVI informada.", "Informar uma descrição HVI diferente."
			Return .F.
		EndIf
	Next nIt	
	EndIf
		
Return lRet 

/*{Protheus.doc} AGRX720EXT
(Antes de Sair. verifica se a quantidade de fardos está dentro do parâmetro de percentual/tolerância)
@type function
@author Marcelo Ferrari
@since 18/09/2018
@version 1.0
@param Nil
@return lRet
*/
Function AGRX720EXT(nOpcX)
   Local lRet 		:= .T.
   Local aTTPesLiq 	:= 0
   Local nToler    	:= (1+(_nTolen / 100))
   Local lIsCtrRF	:= FwIsInCallStack("OGX290SF")
 
   If lIsCtrRF // Se for manutenção de fardos na regra fiscal, então não precisa validar a tolerância
		_nOpcX := 1
		Return lRet
   EndIf

   If  _lValLimit .AND. !Empty(_cCodCtr)  .and. _nTotVal > 0
	   // Faz a somatória do peso dos fardos para validar a quantidade
	   aTTPesLiq :=_nTotVal

	   If aTTPesLiq > (_nQtdCad * nToler ) - _nQtdUsada
	      Msginfo(STR0041 + CRLF + ;                                                   //O total de fardos selecionados é superior ao limite definido na regra
	              STR0042 + cValToChar((_nQtdCad * (1 + (_nTolen / 100) )) - _nQtdUsada ) + CRLF + ;  //Quantidade total permitida
	              STR0043 + cValToChar(_nTotVal)   ;                                   //Quantidade selecionada
	              , STR0044 ) //Limite de seleção de fardos para Regra BCI
	      lRet := .F.
		  If !_lAuto
			AGRX720UP(oBrowse4) // Atualiza o browse de fardos
			AGRX720UP(oBrowse3) // Atualiza o browse de fardos
		  EndIf
	      _nOpcX := 0
	   Else
	      _nOpcX := 1
	   EndIf
	Else
	   _nOpcX := 1
	EndIf
Return lRet

/*{Protheus.doc} AGRExecSQL
(Executa uma instrução SQL - Insert)
@type function
@author Marcos Wagner Jr.
@since 12/06/2018
@version 1.0
@param cClausula, character, (Cláusula de Insert ou Update)
@return lRet
*/
/*Function AGRExecSQL(cClausula)
	Local cExecutar := ""
	Local cIncluido := ""

	cExecutar += " BEGIN "
	cExecutar += cClausula
	cExecutar += " COMMIT;"
	cExecutar += " END;" 
	
	TCSqlExec(cExecutar)

	//resresh da area de seleção de fardos
	TCRefresh(__cNamFar)
	If ValType("oBrowse4") == 'O'
		AGRX720UP(oBrowse4)
	EndIf

	DbSelectArea((__cTabFar))
	DbGoTop()
	While !Eof((__cTabFar))
		cIncluido += (__cTabFar)->DXI_CODIGO + " - "
		(__cTabFar)->(dbSkip())
	End

Return*/


