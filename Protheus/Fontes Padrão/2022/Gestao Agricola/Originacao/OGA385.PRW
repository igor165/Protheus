#INCLUDE "OGA385.ch"
#Include "totvs.ch"
#Include "fwmvcdef.ch"

#Define CR Chr(13) + Chr(10)

Static oArqTemp1 := Nil
Static oArqTemp2 := Nil

/** {Protheus.doc} OGA385
Rotina para relacionar modelos de contrato com entidades

@param: 	Nil
@author: 	Fabiane Schulze
@since: 	11/10/2013
@Uso: 		SIGAAGR - Originação de Grãos
*/ 
Function OGA385()
	Local oDlg
	Local nAlt := (GetScreenRes()[2]-150)
	Local nLrg := (GetScreenRes()[1]-100)
	Local cTipo	
	aNewButton := {}

	Private cCadastro := STR0001 //"Amarração Modelo x Entidade"
	Private cMarca    := GetMark()
	Private oListDoc
	//Arrays para os rodapés - [1]->Nr Docs,[2]->Peso,[3]->Peso Cub,[4]->Volume,[5]->Valor Merc,[6]->Nr Volumes
	Private aRdpDC    := {0,0,0,0,0,0}
	Private aRdpSel   := {0,0,0,0,0,0}
	Private _lFiltro  := .F.
	
	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse  
	//---------------------------------------------- 
				
	aMKB :=    {{"OK"     , "C", 02, 0},;
				{"CODIGO" , "C", TamSX3("A1_COD")[1], 0},;
				{"NOME"   , "C", 40, 0},;
				{"LOJA"   , "C", TamSX3("A1_LOJA")[1], 0},;
				{"NOMLOJ" , "C", 25, 0},;
				{"CLASSE" , "C", 10, 0},;
				{"MODELO" , "C", 06, 0}}				
			                                
	aCpMKB  := {{"OK"   , NIL, "", ""},;
				{"CODIGO", NIL, STR0002, "@!"},;  //"Codigo"
				{"NOME"  , NIL, STR0003, "@!"},; //"Nome"
				{"LOJA"  , NIL, STR0004, "@!"},;  //"Loja"
				{"NOMLOJ", NIL, STR0005, ""},; //"Nome da Loja"
				{"CLASSE", NIL, STR0006, ""},; //"Classe"
				{"MODELO", NIL, STR0007, ""}} //"Modelo"
				
	cAliMKB := GetNextAlias()  
	oArqTemp1  := AGRCRTPTB(cAliMKB, {aMKB, {{"","CODIGO"}} })
	
	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse  
	//---------------------------------------------- 	
				
	aMKB2 :=    {{"OK"   , "C", 02, 0},;
				{"CODIGO" , "C", TamSX3("A1_COD")[1], 0},;
				{"NOME"   , "C", 40, 0},;
				{"LOJA"   , "C", TamSX3("A1_LOJA")[1], 0},;
				{"NOMLOJ" , "C", 25, 0},;
				{"CLASSE" , "C", 10, 0}}
			                                
	aCpMKB2 := {{"OK"   , NIL, "", ""},;
				{"CODIGO", NIL, STR0002, "@!"},;  //"Codigo"
				{"NOME"  , NIL, STR0003, "@!"},; //"Nome"
				{"LOJA"  , NIL, STR0004, "@!"},;  //"Loja"
				{"NOMLOJ", NIL, STR0005, ""},; //"Nome da Loja"
				{"CLASSE", NIL, STR0006, ""}}	//"Classe"
	
	cAliMKB2 := GetNextAlias()
	oArqTemp2  := AGRCRTPTB(cAliMKB2, {aMKB2, {{"","CODIGO"}} })
		
	CursorWait()
	
	//Criação da tela
	
	Define MsDialog oDlg Title cCadastro From 80,50 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.
	
	//----- Painel superior da tela principal, com as informacoes do modelo ------//
	oPnlA := tPanel():New(00,00,,oDlg,,,,,,10,20,.F.,.F.)
		oPnlA:Align := CONTROL_ALIGN_TOP
	
	//----- Splitter para permitir ao usuario movimentar os paineis dos browses -----//	
	oSplitter := tSplitter():New( 0,0,oDlg,80,80,1 ) 
		oSplitter:Align := CONTROL_ALIGN_ALLCLIENT
	    
		//----- Painel superior da tela, para o browse de entidades -----//
		oPanelB := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
			oPanelB:Align := CONTROL_ALIGN_TOP
			
				//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
			oPnlBtn1:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),15,15,.F.,.F.)
			oPnlBtn1:Align := CONTROL_ALIGN_LEFT
		    
			    //------ Botao para adicionar relacionamento da entidade com o modelo -----//			    			
				oBtnAdd  := TBtnBmp():NewBar("PMSSETADOWN","PMSSETADOWN",,,,{||OGA385OK()},,oPnlBtn1,,,"",,,,,"")
				oBtnAdd:cToolTip := STR0008 //"Adicionar"
				oBtnAdd:Align    := CONTROL_ALIGN_TOP
				
				//------ Botao para Filtro da entidade com o modelo -----//			
				oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{|| OGA385FIL()},,oPnlBtn1,,,"",,,,,"")
				oBtnFiltro:cToolTip := STR0009 //"Filtrar"
				oBtnFiltro:Align    := CONTROL_ALIGN_TOP
				
				//Botão para selecionar todas as entidades
				oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||OGA385CHK(1)},,oPnlBtn1,,,"",,,,,"")
				oBtnChk:cToolTip := STR0010 //"Marca todos os documentos de carga em tela"
				oBtnChk:Align    := CONTROL_ALIGN_TOP
				
				//Botão para desselecionar todas as entidades
				oBtnDChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||OGA385CHK(2)},,oPnlBtn1,,,"",,,,,"")
				oBtnDChk:cToolTip := STR0011 //"Desmarca todos os documentos de carga em tela"
				oBtnDChk:Align    := CONTROL_ALIGN_TOP
			
			//----- Painel superior do browse de entidades para colocar o titulo -----//
			oPnlBtn:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,12,.F.,.F.)
				oPnlBtn:Align := CONTROL_ALIGN_TOP
				oFont12B := TFont():New('Arial',,-12,,.T.)
	    		@ 03,14  Say STR0012 Of oPnlBtn COLOR CLR_WHITE Pixel font oFont12B   //"Selecione as Entidades "
	    		
		//------------------ Fim do painel superior da tela ------------------//
		
		
		//----- Painel inferior da tela, para o browse de documentos relacionados -----//
		oPanelC := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
			oPanelC:Align := CONTROL_ALIGN_BOTTOM
			
			//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
			oPnlBtn2:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),15,16,.F.,.F.)
				oPnlBtn2:Align := CONTROL_ALIGN_LEFT
		    
				    //------ Botao para excluir relacionamento da entidade com o modelo  -----//			
					oBtnDel  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{||OGA385D()},,oPnlBtn2,,,"",,,,,"")
					oBtnDel:cToolTip := STR0013 //"Excluir"
					oBtnDel:Align    := CONTROL_ALIGN_TOP
					
					//Botão para selecionar todas as entidades
					oBtnChk2 := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||OGA385C2(1)},,oPnlBtn2,,,"",,,,,"")
					oBtnChk2:cToolTip := STR0010 //"Marca todos os documentos de carga em tela"
					oBtnChk2:Align    := CONTROL_ALIGN_TOP
					
					//Botão para desselecionar todas as entidades
					oBtnDChk2 := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||OGA385C2(2)},,oPnlBtn2,,,"",,,,,"")
					oBtnDChk2:cToolTip := STR0011 //"Desmarca todos os documentos de carga em tela"
					oBtnDChk2:Align    := CONTROL_ALIGN_TOP					
				
			//----- Painel superior do browse de documentos relacionados, para colocar o titulo -----//	
			oPnlBtn3:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,12,.F.,.F.)
				oPnlBtn3:Align := CONTROL_ALIGN_TOP
				oFont12B := TFont():New('Arial',,-12,,.T.)
	    		@ 03,14  Say STR0014 Of oPnlBtn3 COLOR CLR_WHITE Pixel font oFont12B 	 //"Documentos de Carga Relacionados " //"Entidades Relacionadas "
		//--------------- Fim do painel inferior da tela principal-------------------------//
	
		// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
		@ 07,10  Say STR0015 Of oPnlA COLOR CLR_BLACK Pixel //"Filial: " //"Filial: "
	   	@ 05,25  MSGET NJX->NJX_FILIAL Picture "@!" Of oPnlA When .F.   Pixel
	   	  
		@ 07,80  Say STR0016 Of oPnlA COLOR CLR_BLACK Pixel //"Código: " //"Código: "
	   	@ 05,100  MSGET NJX->NJX_CODMOD Picture "@!" Of oPnlA When .F.   Pixel  			
		                                                                                         		
		@ 07,150 Say STR0017 Of oPnlA COLOR CLR_BLACK Pixel //"Descrição: " //"Descrição:"
		@ 05,180 MSGET NJX->NJX_DESCRI  Picture "@!" Of oPnlA Size 130,010 When .F.   Pixel
		
		Do Case
			Case NJX->NJX_TIPO == "1"
				cTipo := STR0018 //"Compra"
			Case NJX->NJX_TIPO == "2"
				cTipo := STR0019 //"Venda"
			Case NJX->NJX_TIPO == "3"
				cTipo := STR0020								 //"Armazenagem de 3"
			Case NJX->NJX_TIPO == "4"
				cTipo := STR0021		 //"Armazenagem em 3"
		EndCase		
		@ 07,330 Say STR0022 Of oPnlA COLOR CLR_BLACK Pixel //"Descrição: " //"Tipo:"
		@ 05,345 MSGET cTipo  Picture "@!" Of oPnlA  When .F.   Pixel	
					                                                                                                                                                                      
		//---------Fim da criacao dos fields ----------//
			
			//--1----- Seleciona a entidade que nao foram relacionados ao modelo e cria o browse -----// 	
			dbSelectArea(cAliMKB)
			dbSetOrder(01)
			dbGoTop()
			oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPanelB)
			oMark:oBrowse:cToolTip := STR0023 //"Documentos de Carga"
			oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oMark:oBrowse:bLDblClick := {|| OGA385CLK('1')}
			//--------------Fim 1 -- criado o browse---------------//
			//--2----- Seleciona as entidades que ja foram relacionados ao modelo e cria o browse -----// 
			dbSelectArea(cAliMKB2)
			dbSetOrder(01)
			dbGoTop()		
			oMark2 := MsSelect():New(cAliMKB2,"OK",,aCpMKB2,,@cMarca,{0,0,0,0},,,oPanelC)
			oMark2:oBrowse:cToolTip := STR0024 //"Relacionamento entre Entidades e Modelos"
			oMark2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oMark2:oBrowse:bLDblClick := {|| OGA385CLK('2')}			
			
		//--------------Fim 2--------------------//
		
		//----- Processa os registros e carrega os browses -----//
		Processa({|lEnd| OGA385A()},STR0025,STR0026) //"Processando informações"###"Aguarde" //"Processando informações"###"Aguarde"
		CursorArrow()
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(OGA385OK(),ODlg:End(),NIL)},;
			{||ODlg:End()},,aNewButton) CENTERED 
	
	dbSelectArea("NJX")
    //Elimina a tabela temporária, se houver
    AGRDLTPTB(oArqTemp1)	
    AGRDLTPTB(oArqTemp2)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OGA385A
Acrescenta os registros na tabela temporaria para que eles sejam exibidos na tela
/*/
//-------------------------------------------------------------------

Static Function OGA385A()
	
	If (Select(cAliMKB) > 0)
        dbSelectArea(cAliMKB)
		 dbGoTop()
		Do While !Eof()
    		RecLock(cAliMKB)
      		DbDelete()
    		MsUnlock() 
   			DbSkip()
		Enddo 
        
   		 EndIF
	 
	If (Select( cAliMKB2 ) > 0)
        dbSelectArea(cAliMKB2)
		 dbGoTop()
        Do While !Eof()
    		RecLock(cAliMKB2)
      		DbDelete()
    		MsUnlock() 
   			DbSkip()
		Enddo
    EndIF
	
	If _lFiltro = .f.

		// Como padrão, não traz nada

		//PRIMEIRA QUERY
		//Memowrite("C:\PRIMEIRAQUERY.txt",cQuery)
				
					
	Else
		
		If MV_PAR08 = 1  // Não
			cQuery := "SELECT '  ' OK, NJ0.NJ0_CODENT CODIGO, " + CR
			cQuery += "NJ0.NJ0_NOME NOME, NJ0.NJ0_LOJENT LOJA, NJ0.NJ0_NOMLOJ NOMLOJ, " + CR
			cQuery += "(CASE NJ0.NJ0_CLASSE WHEN '1' THEN '" + STR0027 + "' WHEN '2' THEN '" + STR0028 + "' WHEN '3' THEN '" + STR0029 + "' END) AS CLASSE " + CR		 //'Proprio'###'Cooperado'###'Terceiro'
			cQuery += "FROM " + RetSQLName("NJ0") + " NJ0 " + CR
			cQuery += " WHERE NJ0.NJ0_CODENT NOT IN (SELECT NJY.NJY_CODENT FROM " + RetSQLName("NJY") + " NJY WHERE  
			cQuery += "NJ0.NJ0_FILIAL = '"+ FwXFilial('NJ0') + "' AND "
			cQuery += "NJY.NJY_FILIAL = '" + FwXFilial('NJY') + "' AND "
			cQuery += "NJ0.NJ0_CODENT = NJY.NJY_CODENT AND NJ0.NJ0_LOJENT = NJY.NJY_LOJENT AND NJY.NJY_TIPO = '" + NJX->NJX_TIPO + "'AND NJY.NJY_CODSAF = '" + NJX->NJX_CODSAF + "'AND NJY.NJY_CODPRO = '" + NJX->NJX_CODPRO + "' AND NJY.D_E_L_E_T_ = '')" + CR
			If NJ0->(FieldPos("NJ0_LLIMIN")) > 0 
				Do Case
					Case MV_PAR09 == 1
				 		cQuery += " AND NJ0.NJ0_LLIMIN = 'N' " + CR
					Case MV_PAR09 == 2
						cQuery += " AND NJ0.NJ0_LLIMIN = 'S' " + CR
				End Case
			EndIf
			cQuery += " AND NJ0.D_E_L_E_T_ = '' " + CR												
		
		//SEGUNDA QUERY
		//Memowrite("C:\SEGUNDAQUERY.txt",cQuery)
		
		ElseIf MV_PAR08 = 2 // Sim
			cQuery := "SELECT '  ' OK, NJ0.NJ0_CODENT CODIGO, " + CR
			cQuery += "NJ0.NJ0_NOME NOME, NJ0.NJ0_LOJENT LOJA, NJ0.NJ0_NOMLOJ NOMLOJ, " + CR
			cQuery += "(CASE NJ0.NJ0_CLASSE WHEN '1' THEN '" + STR0027 + "' WHEN '2' THEN '" + STR0028 + "' WHEN '3' THEN '" + STR0029 + "' END) AS CLASSE, " + CR //'Proprio'###'Cooperado'###'Terceiro'
			cQuery += "(CASE WHEN NJY.NJY_CODMOD IS NULL THEN '' ELSE NJY.NJY_CODMOD END) As MODELO " + CR 
			cQuery += "FROM " + RetSQLName("NJ0") + " NJ0, "+ RetSQLName("NJY") + " NJY " + CR
			cQuery += "WHERE (
			cQuery += "NJ0.NJ0_FILIAL = '"+ FwXFilial('NJ0') +"' AND "
			cQuery += "NJY.NJY_FILIAL = '" + FwXFilial('NJY') +"' AND "
			cQuery += "NJ0.NJ0_CODENT = NJY.NJY_CODENT AND NJ0.NJ0_LOJENT = NJY.NJY_LOJENT AND NJY.NJY_CODMOD <>  '" + NJX->NJX_CODMOD + "' AND NJY.NJY_TIPO = '" + NJX->NJX_TIPO + "'AND NJY.NJY_CODSAF = '" + NJX->NJX_CODSAF + "'AND NJY.NJY_CODPRO = '" + NJX->NJX_CODPRO + "' ) " + CR 
			If NJ0->(FieldPos("NJ0_LLIMIN")) > 0
				Do Case
					Case MV_PAR09 == 1
				 		cQuery += " AND NJ0.NJ0_LLIMIN = 'N' " + CR
					Case MV_PAR09 == 2
						cQuery += " AND NJ0.NJ0_LLIMIN = 'S' " + CR
				End Case
			EndIf			
			cQuery += "AND NJY.D_E_L_E_T_ = '' AND NJ0.D_E_L_E_T_ = '' " + CR				
		
		//TERCEIRA QUERY
		//Memowrite("C:\TERCEIRAQUERY.txt",cQuery)
				
		
		Else // Ambos
			cQuery := "SELECT '  ' OK, NJ0.NJ0_CODENT CODIGO, " + CR
			cQuery += "NJ0.NJ0_NOME NOME, NJ0.NJ0_LOJENT LOJA, NJ0.NJ0_NOMLOJ NOMLOJ, " + CR
			cQuery += "(CASE NJ0.NJ0_CLASSE WHEN '1' THEN '" + STR0027 + "' WHEN '2' THEN '" + STR0028 + "' WHEN '3' THEN '" + STR0029 + "' END) AS CLASSE, " + CR //'Proprio'###'Cooperado'###'Terceiro'
			cQuery += "(CASE WHEN NJY.NJY_CODMOD IS NULL THEN '' ELSE NJY.NJY_CODMOD END) AS MODELO " + CR	
			cQuery += "FROM " + RetSQLName("NJ0") + " NJ0 " + CR	
			cQuery += "LEFT JOIN " + RetSQLName("NJY") + " NJY ON "
			cQuery += "NJY.NJY_FILIAL = '"+ FwXFilial('NJY') +"' AND "
			cQuery += "NJY.NJY_CODENT = NJ0.NJ0_CODENT AND NJY.NJY_LOJENT = NJ0.NJ0_LOJENT AND NJY.NJY_TIPO = '" + NJX->NJX_TIPO + "'AND NJY.NJY_CODSAF = '" + NJX->NJX_CODSAF + "'AND NJY.NJY_CODPRO = '" + NJX->NJX_CODPRO + "' AND NJY.D_E_L_E_T_ = '' " + CR
			cQuery += "WHERE NJ0.NJ0_FILIAL = '" + FwXFilial('NJ0') + "' AND NJ0.D_E_L_E_T_ = '' " + CR	
			If NJ0->(FieldPos("NJ0_LLIMIN")) > 0
				Do Case
					Case MV_PAR09 == 1
				 		cQuery += " AND NJ0.NJ0_LLIMIN = 'N' " + CR
					Case MV_PAR09 == 2
						cQuery += " AND NJ0.NJ0_LLIMIN = 'S' " + CR
				End Case
			EndIf
			cQuery += " AND (NJY.NJY_CODMOD IS NULL OR (NJY.NJY_CODMOD <> '" + NJX->NJX_CODMOD + "' )) " + CR
		EndIf
		
		cQuery += "AND NJ0.NJ0_CODENT >= '" + MV_PAR01 + "' AND NJ0.NJ0_CODENT <= '" + MV_PAR02 + "' " + CR 
		cQuery += "AND NJ0.NJ0_NOME >= '" + MV_PAR03 + "' AND NJ0.NJ0_NOME <= '" + MV_PAR04 + "' "	+ CR
		cQuery += "AND NJ0.NJ0_LOJENT >= '" + MV_PAR05 + "' AND NJ0.NJ0_LOJENT <= '" + MV_PAR06 + "' " + CR
		
		If MV_PAR07 != 4
			cQuery += "AND NJ0.NJ0_CLASSE = '" + cValTochar(MV_PAR07) + "' " + CR
		End	
		
				
		MsgRun(STR0030,STR0026,{||SqlToTrb(cQuery, aMKB, cAliMKB)}) //"Processando Entidades, aguarde..."###"Aguarde"
		
		cQuery := "SELECT '  ' OK, NJ0.NJ0_CODENT CODIGO, NJ0.NJ0_NOME NOME, NJ0.NJ0_LOJENT LOJA, " + CR
		cQuery += "NJ0.NJ0_NOMLOJ NOMLOJ,  " + CR
		cQuery += "(CASE NJ0.NJ0_CLASSE WHEN '1' THEN '" + STR0027 + "' WHEN '2' THEN '" + STR0028 + "' WHEN '3' THEN '" + STR0029 + "' END) AS CLASSE " + CR //'Proprio'###'Cooperado'###'Terceiro'
		cQuery += "FROM " + RetSQLName("NJ0") + " NJ0 " + CR
		cQuery += "INNER JOIN " + RetSQLName("NJY") + " NJY ON NJY.NJY_FILIAL = '" + FwXFilial('NJY') + "' AND NJY.NJY_CODENT = NJ0.NJ0_CODENT AND NJY.NJY_LOJENT = NJ0.NJ0_LOJENT " + CR
		cQuery += "WHERE NJ0.NJ0_FILIAL = '" + FwXFilial('NJ0') + "' AND NJY.NJY_CODMOD = '" + NJX->NJX_CODMOD + "' AND NJY.NJY_FILIAL = '" + NJX->NJX_FILIAL + "'AND NJY.NJY_CODSAF = '" + NJX->NJX_CODSAF + "'AND NJY.NJY_CODPRO = '" + NJX->NJX_CODPRO + "' AND NJY.D_E_L_E_T_ = '' AND " + CR
	    cQuery += "NJ0.D_E_L_E_T_ = '' " + CR
	    
	    
	    MsgRun(STR0031,STR0026,{||SqlToTrb(cQuery, aMKB2, cAliMKB2)}) //"Processando Modelos X Entidades, aguarde..."###"Aguarde"
	EndIf	
	
		
	    
	dbSelectArea(cAliMKB2)
	dbGoTOp()
	oMark2:oBrowse:Refresh()		
	
	aRdpDC:={0,0,0,0,0,0}

	dbSelectArea(cAliMKB)
	dbGoTOp()
	oMark:oBrowse:Refresh()	

Return .T.

// -------------------------------------------------------------------
//{Protheus.doc} OGA385OK
//Cria o relacionamento entre entidade e modelo
// -------------------------------------------------------------------

Function OGA385OK()
	
	Local aTmpArea := (cAliMKB)->( GetArea() )
	
	dbSelectArea(cAliMKB)
	//(cAliMKB)->( dbSetOrder(2) )
	//(cAliMKB)->( dbSeek(cMarca) )
	While !(cAliMKB)->( Eof() )
	  If (cAliMKB)->OK == cMarca
		dbSelectArea("NJY")
		dbSetOrder(2) //NJY_FILIAL+NJY_CODENT+NJY_LOJENT+NJY_CODSAF+NJY_CODPRO+NJY_TIPO+NJY_CODMOD
		If dbSeek(xFilial("NJY") + (cAliMKB)->CODIGO + (cAliMKB)->LOJA + NJX->NJX_CODSAF + NJX->NJX_CODPRO + NJX->NJX_TIPO )	
	
			RecLock("NJY",.F.)
				NJY_FILIAL	:= NJX->NJX_FILIAL
				NJY_CODMOD	:= NJX->NJX_CODMOD
				NJY_TIPO	:= NJX->NJX_TIPO
				NJY_CODENT	:= (cAliMKB)->CODIGO
				NJY_LOJENT	:= (cAliMKB)->LOJA
				NJY_CODSAF	:= NJX->NJX_CODSAF
				NJY_CODPRO	:= NJX->NJX_CODPRO														
			MsUnLock("NJY")
		Else 	
			RecLock("NJY", .T.)
				NJY_FILIAL	:= NJX->NJX_FILIAL
				NJY_CODMOD	:= NJX->NJX_CODMOD
				NJY_TIPO	:= NJX->NJX_TIPO
				NJY_CODENT	:= (cAliMKB)->CODIGO
				NJY_LOJENT	:= (cAliMKB)->LOJA
				NJY_CODSAF	:= NJX->NJX_CODSAF
				NJY_CODPRO	:= NJX->NJX_CODPRO		
			MsUnLock("NJY")
		EndIf	
	
		dbSelectArea(cAliMKB)
	 EndIf
		(cAliMKB)->( dbSkip() )
	EndDo
	
	RestArea(aTmpArea)
	
	OGA385A()

Return .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} OGA385D
Elimina o relacionamento entre o modelo e a entidade
/*/
//-------------------------------------------------------------------
Static Function OGA385D()

	Local aTmpArea := (cAliMKB2)->( GetArea() )
	
	dbSelectArea(cAliMKB2)
	//(cAliMKB2)->( dbSetOrder(2) )
	//(cAliMKB2)->( dbSeek(cMarca) )
	While !(cAliMKB2)->( Eof()) 
	  If (cAliMKB2)->OK == cMarca
		dbSelectArea("NJY")
		dbSetOrder(1) //NJY_FILIAL+NJY_CODMOD
		If dbSeek(xFilial("NJY") + NJX->NJX_CODMOD )	
	
			RecLock("NJY",.F.)
				dbDelete()
			MsUnLock("NJY")	
		
		EndIf

		dbSelectArea(cAliMKB2)
	  EndIf
		(cAliMKB2)->( dbSkip() )
	EndDo
	
	RestArea(aTmpArea)	
		
	OGA385A()

Return
                                            
//-------------------------------------------------------------------
/*/{Protheus.doc} GFE050FIL
Permite o filtro do browse superior

/*/
//-------------------------------------------------------------------
Function OGA385FIL()
	
	if Pergunte("OGA385001", .T.)
		
		_lFiltro := .T.
		
		
	OGA385A()
		
	EndIf
	
Return
       
/*
{Protheus.doc} OGA385CHK
Função para marcar/desmarcar todos os documentos de carga

@sample
OGA385CHK(nOp)

@author Octávio Augusto Felippe de Macedo
@since 01/04/2011
@version 1.0
*/ 

Static Function OGA385CHK(nOp)

	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbGoTop() )
	While !(cAliMKB)->( Eof() )

    	If If(nOp==1,!IsMark("OK",cMarca),IsMark("OK",cMarca))
    		RecLock(cAliMKB,.F.)
				(cAliMKB)->OK := If(nOp==1, cMarca, " ")
			MsUnlock(cAliMKB)
			
		EndIf

		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbSkip() )
	EndDo

	DbSelectArea(cAliMKB)
	(cAliMKB)->( DbGoTop() )

	oMark:oBrowse:Refresh()
Return

Static Function OGA385C2(nOp)

	dbSelectArea(cAliMKB2)
	(cAliMKB2)->( dbGoTop() )
	While !(cAliMKB2)->( Eof() )

    	If If(nOp==1,!IsMark("OK",cMarca),IsMark("OK",cMarca))
    		RecLock(cAliMKB2,.F.)
				(cAliMKB2)->OK := If(nOp==1, cMarca, " ")
			MsUnlock(cAliMKB2)
			
		EndIf

		dbSelectArea(cAliMKB2)
		(cAliMKB2)->( dbSkip() )
	EndDo

	DbSelectArea(cAliMKB2)
	(cAliMKB2)->( DbGoTop() )

	oMark2:oBrowse:Refresh()
Return
/*
{Protheus.doc} OGA385CLK
Função chamada no evento de duplo click para marcar/desmarcar 

@sample
OGA385CLK()

@author Octávio Augusto Felippe de Macedo
@since 01/04/2011
@version 1.0
*/

Static Function OGA385CLK(nMark)
	
	if nMark == '1'
		If !(cAliMKB)->( Eof() )
		
			RecLock(cAliMKB, .F.)
				(cAliMKB)->OK := If(IsMark("OK",cMarca), " ", cMarca)
				
			MsUnlock(cAliMKB)
			
			oMark:oBrowse:Refresh()
		
		EndIf	
	else
		If !(cAliMKB2)->( Eof() )
		
			RecLock(cAliMKB2, .F.)
				(cAliMKB2)->OK := If(IsMark("OK",cMarca), " ", cMarca)
			MsUnlock(cAliMKB2)
			
			oMark2:oBrowse:Refresh()
		
		EndIf		
	endif
	
Return


