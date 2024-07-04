#Include "Protheus.ch"                                           
#Include "OFIOC370.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC370 ³ Autor ³ Rafael G. da Silva    ³ Data ³15/04/2009|±±
±±³          ³          ³       ³ Andre Luis Almeida    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Giro de estoque por Grupo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                            
Function OFIOC370()
Private aGrupos := {}
Private aGrpTot := {}
Private dDatIni := Ctod("")
Private dDatFin := dDataBase

/*
Private cCombo  :=  STR0001 +" ( "+Transform(dDataBase-30,"@D")+" " + STR0007 +" "+Transform(dDataBase,"@D")+" )"			//Ultimos 30 dias ### a 
Private aCombo  := {STR0001 +" ( "+Transform(dDataBase-30,"@D")+" " + STR0007 +" "+Transform(dDataBase,"@D")+" )" , ;	//Ultimos 30 dia ### a
						  STR0002 +" ( "+Transform(dDataBase-60,"@D")+" " + STR0007 +" "+Transform(dDataBase,"@D")+" )" , ;	//Ultimos 60 dias ### a
						  STR0003 +" ( "+Transform(dDataBase-90,"@D")+" " + STR0007 +" "+Transform(dDataBase,"@D")+" )" , ;	//Ultimos 90 dias ### a
						  STR0004 +" ( "+Transform(dDataBase-120,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" , ;	//Ultimos 120 dias ### a
						  STR0005 +" ( "+Transform(dDataBase-240,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" , ;	//Ultimos 240 dias ### a
						  STR0006 +" ( "+Transform(dDataBase-365,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" }  	//Ultimos 365 dias ### a
*/
If !FS_VERBASE() // Verifica a existencia dos arquivos envolvidos na Consulta
	MsgStop(STR0008 ,STR0009) //Nao existem dados para esta Consulta! # Atencao
	Return
EndIf 
Processa({ || FS_LEVANTA(0) }) //CHAMADA INICIAL CARREGAR VALORES INICIAIS   
DEFINE MSDIALOG oGEstq FROM 000,000 TO 035,100 TITLE OemToAnsi(STR0010) OF oMainWnd  //Giro Estoque por Grupo
	@ 028,001 LISTBOX oGrpTot FIELDS HEADER   OemToAnsi(STR0037),; //TOTAIS
															OemToAnsi(RetTitle("VPK_QTDEST")),;
															OemToAnsi(RetTitle("VPK_CUSEST")),;
															OemToAnsi(RetTitle("VPK_QTDVDA")),;
															OemToAnsi(RetTitle("VPK_CUSVDA")),;
															OemToAnsi(RetTitle("VPK_VALVDA")),;
															OemToAnsi(RetTitle("VPK_VALLIQ")),;
															OemToAnsi(STR0011 ),;	//Giro Est MeS
															OemToAnsi(STR0012 ),;	//Margem Venda
															OemToAnsi(STR0013 ),;	//Margem Corrig
															OemToAnsi(RetTitle("VPK_PRZMED"));
															COLSIZES 80,50,70,50,50,70,50,40,40,40,40 SIZE 394,065 OF oGEstq PIXEL
	oGrpTot:SetArray(aGrpTot)
  	oGrpTot:bLine := { || {  aGrpTot[oGrpTot:nAt,2] ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,3],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,4],"@E 99,999,999,999.99"))+" "+Transform(aGrpTot[oGrpTot:nAt,5],"@E 9999.9%") ,;									 
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,6],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,7],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,8],"@E 99,999,999,999.99"))+" "+Transform(aGrpTot[oGrpTot:nAt,10],"@E 9999.9%") ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,9],"@E 99,999,999,999.99")) ,; 
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,11],"@E 999999")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,12],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,13],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,14],"@E 999999")) }}  
	
	@ 093,001 LISTBOX oGrpBox FIELDS HEADER   OemToAnsi(RetTitle("VPK_GRUPO")),;
															OemToAnsi(RetTitle("VPK_QTDEST")),;
															OemToAnsi(RetTitle("VPK_CUSEST")),;
															OemToAnsi(RetTitle("VPK_QTDVDA")),;
															OemToAnsi(RetTitle("VPK_CUSVDA")),;
															OemToAnsi(RetTitle("VPK_VALVDA")),;
															OemToAnsi(RetTitle("VPK_VALLIQ")),;
															OemToAnsi(STR0011 ),;	//Giro Est MeS
															OemToAnsi(STR0012 ),;	//Margem Venda
															OemToAnsi(STR0013 ),;	//Margem Corrig
															OemToAnsi(RetTitle("VPK_PRZMED"));
															COLSIZES 80,50,70,50,50,70,50,40,40,40,40 SIZE 394,172 OF oGEstq PIXEL
	oGrpBox:SetArray(aGrupos)
  	oGrpBox:bLine := { || {  aGrupos[oGrpBox:nAt,2] ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,3],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,4],"@E 99,999,999,999.99"))+" "+Transform(aGrupos[oGrpBox:nAt,5],"@E 9999.9%") ,;									 
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,6],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,7],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,8],"@E 99,999,999,999.99"))+" "+Transform(aGrupos[oGrpBox:nAt,10],"@E 9999.9%") ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,9],"@E 99,999,999,999.99")) ,; 
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,11],"@E 999999")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,12],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,13],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,14],"@E 999999")) }}  
									 
	@ 002,005 TO 024,185 LABEL OemToAnsi(STR0014) OF oGEstq PIXEL COLOR CLR_BLUE  //Filtro
//	@ 010,010 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo  VALID processa({ || FS_LEVANTA(1) }) SIZE 170,07 OF oGEstq PIXEL COLOR CLR_BLUE
	@ 011,011 Say OemToAnsi("Data Inicial") SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLUE
	@ 010,047 msGet oDatIni VAR dDatIni Picture "@D" SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLACK
	@ 011,095 Say OemToAnsi("Data Final") SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLUE
	@ 010,131 msGet oDatFin VAR dDatFin Picture "@D" VALID processa({ || FS_LEVANTA(1) }) SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLACK

	@ 002,190 TO 024,295 LABEL (STR0015) OF oGEstq PIXEL COLOR CLR_BLUE   //Analitico
	@ 010,195 BUTTON oCAI  PROMPT OemToAnsi(STR0016) OF oGEstq SIZE 45,10 PIXEL ACTION FS_LISCAI(oGrpBox:nAt)	// CAI
	@ 010,245 BUTTON oEmpr PROMPT OemToAnsi(STR0017) OF oGEstq SIZE 45,10 PIXEL ACTION FS_LISEMP(oGrpBox:nAt)	// FILIAIS
	@ 010,300 BUTTON oImpr PROMPT OemToAnsi(STR0018) OF oGEstq SIZE 44,10 PIXEL ACTION FS_IMPRIMIR(1)	//IMPRIMIR 
	@ 010,348 BUTTON oSair PROMPT OemToAnsi(STR0019) OF oGEstq SIZE 44,10 PIXEL ACTION oGEstq:End()	//SAIR
ACTIVATE MSDIALOG oGEstq CENTER
RETURN  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVANTA  ³ Autor ³  Andre/Rafael         ³ Data ³ 15/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega os dados do ListBox                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANTA(nTip)
Local cQAlVPK := "SQLVPK"
Local nCusEst := 0
Local nValLiq := 0
Local nCusVda := 0                               '
Local nValVda := 0
Local nTotAnt := 0 // Total Anterior
Local nPrzAnt := 0 // Prazo Medio Anterior
Local nTotAtu := 0 // Total Atual
Local nPrzAtu := 0 // Prazo Medio Atual
Local nTotVda := 0 // Total Geral Vendas
Local ni := 1
Local nj := 1
Local nLinTot := 0
aGrupos := {}
aGrpTot := {}
aAdd(aGrpTot,{ 1 , STR0032 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total Geral 
aAdd(aGrpTot,{ 2 , STR0033 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total PESADA
aAdd(aGrpTot,{ 3 , STR0034 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total LEVE
aAdd(aGrpTot,{ 4 , STR0035 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total MOTO
aAdd(aGrpTot,{ 5 , STR0036 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total OUTROS
aAdd(aGrupos,{ 6 , STR0023 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total Geral Arrai para os analiticos
/*
If	cCombo == STR0001 +" ( "+Transform(dDataBase-30,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )"//Ultimos 30 dia ### a
	nj := 30
ElseIf cCombo == STR0002 +" ( "+Transform(dDataBase-60,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 60 dias ### a
	nj := 60
ElseIf cCombo == STR0003 +" ( "+Transform(dDataBase-90,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 90 dias ### a
	nj := 90
ElseIf cCombo == STR0004 +" ( "+Transform(dDataBase-120,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 120 dias ### a
	nj := 120
ElseIf cCombo == STR0005 +" ( "+Transform(dDataBase-240,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 240 dias ### a
	nj := 240
ElseIf cCombo == STR0006 +" ( "+Transform(dDataBase-365,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 365 dias ### a
	nj := 365
EndIf
*/
nj := dDatFin - dDatIni

cQuery := "SELECT VPK.* , SBM.BM_DESC , VE2.VE2_TIPPEC "
cQuery += " FROM "+RetSqlName("VPK")+" VPK JOIN "+RetSqlName("SBM")+" SBM ON ( SBM.BM_FILIAL='"+xFilial("SBM")+"' AND VPK.VPK_GRUPO=SBM.BM_GRUPO  AND SBM.D_E_L_E_T_=' ' ) " 
cQuery += " JOIN "+RetSqlName("VE2")+" VE2 ON ( VE2.VE2_FILIAL='"+xFilial("VE2")+"' AND VPK.VPK_CODCAI=VE2.VE2_CODCAI AND VE2.VE2_CODMAR = SBM.BM_CODMAR AND VE2.D_E_L_E_T_=' ' ) "
//cQuery += "WHERE VPK.VPK_DATMOV>='"+ dtos(dDataBase-nj) +"' AND VPK.D_E_L_E_T_=' ' ORDER BY VPK.VPK_GRUPO"
cQuery += "WHERE VPK.VPK_DATMOV BETWEEN '"+dtos(dDatIni)+"' AND '"+dtos(dDatFin)+"' AND VPK.D_E_L_E_T_=' ' ORDER BY VPK.VPK_GRUPO"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPK, .F., .T. )
While !( cQAlVPK )->( Eof() )     

	//////////////////// Prazo Medio ////////////////////////////
	nTotAnt := aGrpTot[1,8]							// Total Anterior
	nPrzAnt := aGrpTot[1,14]						// Prazo Medio Anterior
	nTotAtu := ( cQAlVPK )->( VPK_VALVDA )		// Total Atual
	nPrzAtu := ( cQAlVPK )->( VPK_PRZMED )		// Prazo Medio Atual
	nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
	aGrpTot[1,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
	/////////////////// TOTAL GERAL /////////////////////////////
	aGrpTot[1,3] += ( cQAlVPK )->( VPK_QTDEST )
 	aGrpTot[1,4] += ( cQAlVPK )->( VPK_CUSEST )
	aGrpTot[1,6] += ( cQAlVPK )->( VPK_QTDVDA )
	aGrpTot[1,7] += ( cQAlVPK )->( VPK_CUSVDA )
	aGrpTot[1,8] += ( cQAlVPK )->( VPK_VALVDA )
	aGrpTot[1,9] += ( cQAlVPK )->( VPK_VALLIQ )   
	
	////////////////// TOTAL GERAL PARA OS ANALITICOS//////////////////////
	nTotAnt := aGrupos[1,8]							// Total Anterior
	nPrzAnt := aGrupos[1,14]						// Prazo Medio Anterior
	nTotAtu := ( cQAlVPK )->( VPK_VALVDA )		// Total Atual
	nPrzAtu := ( cQAlVPK )->( VPK_PRZMED )		// Prazo Medio Atual
	nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
	aGrupos[1,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
	/////////////////// TOTAL GERAL /////////////////////////////
	aGrupos[1,3] += ( cQAlVPK )->( VPK_QTDEST )
 	aGrupos[1,4] += ( cQAlVPK )->( VPK_CUSEST )
	aGrupos[1,6] += ( cQAlVPK )->( VPK_QTDVDA )
	aGrupos[1,7] += ( cQAlVPK )->( VPK_CUSVDA )
	aGrupos[1,8] += ( cQAlVPK )->( VPK_VALVDA )
	aGrupos[1,9] += ( cQAlVPK )->( VPK_VALLIQ ) 
	//////////////////////////////////////////////////////////////  

	IF ( cQAlVPK )->( VE2_TIPPEC ) =="0" //TOTAL PES (PESADA)
		nTotAnt := aGrpTot[2,8]							// Total Anterior
		nPrzAnt := aGrpTot[2,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlVPK )->( VPK_VALVDA )		// Total Atual
		nPrzAtu := ( cQAlVPK )->( VPK_PRZMED )		// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )
		aGrpTot[2,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		aGrpTot[2,3] += ( cQAlVPK )->( VPK_QTDEST )
	 	aGrpTot[2,4] += ( cQAlVPK )->( VPK_CUSEST )
		aGrpTot[2,6] += ( cQAlVPK )->( VPK_QTDVDA )
		aGrpTot[2,7] += ( cQAlVPK )->( VPK_CUSVDA )
		aGrpTot[2,8] += ( cQAlVPK )->( VPK_VALVDA )
		aGrpTot[2,9] += ( cQAlVPK )->( VPK_VALLIQ )
	ELSEIF ( cQAlVPK )->( VE2_TIPPEC ) =="1" //TOTAL LEV (LEVE)
  		nTotAnt := aGrpTot[3,8]							// Total Anterior
		nPrzAnt := aGrpTot[3,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlVPK )->( VPK_VALVDA )		// Total Atual
		nPrzAtu := ( cQAlVPK )->( VPK_PRZMED )		// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )
		aGrpTot[3,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		aGrpTot[3,3] += ( cQAlVPK )->( VPK_QTDEST )
	 	aGrpTot[3,4] += ( cQAlVPK )->( VPK_CUSEST )
		aGrpTot[3,6] += ( cQAlVPK )->( VPK_QTDVDA )
		aGrpTot[3,7] += ( cQAlVPK )->( VPK_CUSVDA )
		aGrpTot[3,8] += ( cQAlVPK )->( VPK_VALVDA )
		aGrpTot[3,9] += ( cQAlVPK )->( VPK_VALLIQ )
	ELSEIF ( cQAlVPK )->( VE2_TIPPEC ) =="2" //TOTAL MOT (MOTO)
  		nTotAnt := aGrpTot[4,8]							// Total Anterior
		nPrzAnt := aGrpTot[4,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlVPK )->( VPK_VALVDA )		// Total Atual
		nPrzAtu := ( cQAlVPK )->( VPK_PRZMED )		// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )
		aGrpTot[4,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		aGrpTot[4,3] += ( cQAlVPK )->( VPK_QTDEST )
	 	aGrpTot[4,4] += ( cQAlVPK )->( VPK_CUSEST )
		aGrpTot[4,6] += ( cQAlVPK )->( VPK_QTDVDA )
		aGrpTot[4,7] += ( cQAlVPK )->( VPK_CUSVDA )
		aGrpTot[4,8] += ( cQAlVPK )->( VPK_VALVDA )
		aGrpTot[4,9] += ( cQAlVPK )->( VPK_VALLIQ ) 
	ELSE //TOTAL OUTROS
  		nTotAnt := aGrpTot[5,8]							// Total Anterior
		nPrzAnt := aGrpTot[5,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlVPK )->( VPK_VALVDA )		// Total Atual
		nPrzAtu := ( cQAlVPK )->( VPK_PRZMED )		// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )
		aGrpTot[5,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		aGrpTot[5,3] += ( cQAlVPK )->( VPK_QTDEST )
	 	aGrpTot[5,4] += ( cQAlVPK )->( VPK_CUSEST )
		aGrpTot[5,6] += ( cQAlVPK )->( VPK_QTDVDA )
		aGrpTot[5,7] += ( cQAlVPK )->( VPK_CUSVDA )
		aGrpTot[5,8] += ( cQAlVPK )->( VPK_VALVDA )
		aGrpTot[5,9] += ( cQAlVPK )->( VPK_VALLIQ ) 
	ENDIF
	nPos := Ascan(aGrupos,{|x| x[2] == ( cQAlVPK )->( VPK_GRUPO )+"-"+( cQAlVPK )->( BM_DESC ) })
	If nPos == 0
		aAdd(aGrupos,{ 7 , ( cQAlVPK )->( VPK_GRUPO )+"-"+( cQAlVPK )->( BM_DESC ) , ( cQAlVPK )->( VPK_QTDEST ) , ( cQAlVPK )->( VPK_CUSEST ) , 0 , ( cQAlVPK )->( VPK_QTDVDA ), ( cQAlVPK )->( VPK_CUSVDA ) , ( cQAlVPK )->( VPK_VALVDA ) , ( cQAlVPK )->( VPK_VALLIQ ) , 0 , 0 , 0 , 0 , ( cQAlVPK )->( VPK_PRZMED ) })
   Else
		///// Prazo Medio /////
			nTotAnt := aGrupos[nPos,8]						// Total Anterior
			nPrzAnt := aGrupos[nPos,14]					// Prazo Medio Anterior
			nTotAtu := ( cQAlVPK )->( VPK_VALVDA )		// Total Atual
			nPrzAtu := ( cQAlVPK )->( VPK_PRZMED )		// Prazo Medio Atual
			nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
			aGrupos[nPos,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		///////////////////////
      aGrupos[nPos,3] += ( cQAlVPK )->( VPK_QTDEST )
		aGrupos[nPos,4] += ( cQAlVPK )->( VPK_CUSEST )
  		aGrupos[nPos,6] += ( cQAlVPK )->( VPK_QTDVDA )
		aGrupos[nPos,7] += ( cQAlVPK )->( VPK_CUSVDA )
		aGrupos[nPos,8] += ( cQAlVPK )->( VPK_VALVDA ) 
		aGrupos[nPos,9] += ( cQAlVPK )->( VPK_VALLIQ )	
		
   EndIf
	nCusEst += ( cQAlVPK )->( VPK_CUSEST ) //custo estoque
	nValLiq += ( cQAlVPK )->( VPK_VALLIQ ) //valor liquido
	nCusVda += ( cQAlVPK )->( VPK_CUSVDA ) //custo venda
	nValVda += ( cQAlVPK )->( VPK_VALVDA ) //valor venda 
	( cQAlVPK )->( DbSkip() )
EndDo
( cQAlVPK )->( dbCloseArea() )	

DbSelectArea("VPK")
For ni := 1 to Len(aGrpTot)
	aGrpTot[ni,5]  := ( ( aGrpTot[ni,4] / nCusEst ) * 100 )  //custo estoque
	aGrpTot[ni,10] := ( ( aGrpTot[ni,9] / nValLiq ) * 100 )  //valor liquido
  	aGrpTot[ni,11] := int( aGrpTot[ni,4] / (aGrpTot[ni,7] / nj ) ) //giro sobre estoque mes  ((Custo venda / dias)/custo estoque)
	aGrpTot[ni,12] := ( ( ( aGrpTot[ni,8] - aGrpTot[ni,7] ) / aGrpTot[ni,8] ) * 100 )  //Margem da Venda
	aGrpTot[ni,13] := ( ( ( aGrpTot[ni,9] - aGrpTot[ni,7] ) / aGrpTot[ni,9] ) * 100 )  //Margem Corrigida

Next 
aSort(aGrpTot,1,,{|x,y| x[1] < y[1]})

For ni := 1 to Len(aGrupos)
	aGrupos[ni,5]  := ( ( aGrupos[ni,4] / nCusEst ) * 100 )  //custo estoque
	aGrupos[ni,10] := ( ( aGrupos[ni,9] / nValLiq ) * 100 )  //valor liquido
  	aGrupos[ni,11] := int( aGrupos[ni,4] / (aGrupos[ni,7] / nj ) ) //giro sobre estoque mes  ((Custo venda / dias)/custo estoque)
	aGrupos[ni,12] := ( ( ( aGrupos[ni,8] - aGrupos[ni,7] ) / aGrupos[ni,8] ) * 100 )  //Margem da Venda
	aGrupos[ni,13] := ( ( ( aGrupos[ni,9] - aGrupos[ni,7] ) / aGrupos[ni,9] ) * 100 )  //Margem Corrigida
Next 
aSort(aGrupos,1,,{|x,y| x[1] < y[1]})

If nTip == 1
	oGrpTot:nAt := 1 //total
	oGrpTot:SetArray(aGrpTot)
  	oGrpTot:bLine := { || {  aGrpTot[oGrpTot:nAt,2] ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,3],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,4],"@E 99,999,999,999.99"))+" "+Transform(aGrpTot[oGrpTot:nAt,5],"@E 9999.9%") ,;									 
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,6],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,7],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,8],"@E 99,999,999,999.99"))+" "+Transform(aGrpTot[oGrpTot:nAt,10],"@E 9999.9%") ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,9],"@E 99,999,999,999.99")) ,; 
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,11],"@E 999999")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,12],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,13],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aGrpTot[oGrpTot:nAt,14],"@E 999999")) }}  

	oGrpTot:SetFocus()
	oGrpTot:Refresh()
	
	oGrpBox:nAt := 1 //itens
	oGrpBox:SetArray(aGrupos)
  	oGrpBox:bLine := { || {  aGrupos[oGrpBox:nAt,2] ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,3],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,4],"@E 99,999,999,999.99"))+" "+Transform(aGrupos[oGrpBox:nAt,5],"@E 9999.9%") ,;									 
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,6],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,7],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,8],"@E 99,999,999,999.99"))+" "+Transform(aGrupos[oGrpBox:nAt,10],"@E 9999.9%") ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,9],"@E 99,999,999,999.99")) ,; 
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,11],"@E 999999")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,12],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,13],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aGrupos[oGrpBox:nAt,14],"@E 999999")) }}
	oGrpBox:SetFocus()
	oGrpBox:Refresh()
EndIF
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LISCAIE  ³ Autor ³  Rafael               ³ Data ³ 01/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista analiticamente CAI                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_LISCAI(nPosGrupo)
Local cQAlCAI := "SQLCAI"
Local nCusEst := 0
Local nValLiq := 0
Local nCusVda := 0
Local nValVda := 0
Local nPos := 0
Local ni := 0
Local nj := 0
Private aCodCAI := {}
Private aTotCai := {}
aAdd(aTotCai,{ 1 , STR0032 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })   //Total Geral
aAdd(aTotCai,{ 2 , STR0033 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total PESADA
aAdd(aTotCai,{ 3 , STR0034 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total LEVE
aAdd(aTotCai,{ 4 , STR0035 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total MOTO
aAdd(aTotCai,{ 5 , STR0036 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total OUTROS
/*
If	cCombo == STR0001 +" ( "+Transform(dDataBase-30,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )"//Ultimos 30 dia ### a
	nj := 30
ElseIf cCombo == STR0002 +" ( "+Transform(dDataBase-60,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 60 dias ### a
	nj := 60
ElseIf cCombo == STR0003 +" ( "+Transform(dDataBase-90,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 90 dias ### a
	nj := 90
ElseIf cCombo == STR0004 +" ( "+Transform(dDataBase-120,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 120 dias ### a
	nj := 120
ElseIf cCombo == STR0005 +" ( "+Transform(dDataBase-240,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 240 dias ### a
	nj := 240
ElseIf cCombo == STR0006 +" ( "+Transform(dDataBase-365,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 365 dias ### a
	nj := 365
EndIf
*/
nj := dDatFin - dDatIni

cQuery := "SELECT VPK.* , VE2.VE2_DESCAI , VE2.VE2_TIPPEC "
cQuery += " FROM "+RetSqlName("VPK")+" VPK JOIN "+RetSqlName("SBM")+" SBM ON ( SBM.BM_FILIAL='"+xFilial("VE2")+"' AND SBM.BM_GRUPO = VPK.VPK_GRUPO AND SBM.D_E_L_E_T_=' ' ) "
cQuery += " JOIN "+RetSqlName("VE2")+" VE2 ON ( VE2.VE2_FILIAL='"+xFilial("VE2")+"' AND VPK.VPK_CODCAI=VE2.VE2_CODCAI AND VE2.VE2_CODMAR = SBM.BM_CODMAR AND VE2.D_E_L_E_T_=' ' ) "
//cQuery += "WHERE VPK.VPK_DATMOV>='"+ dtos(dDataBase-nj) +"' AND "
cQuery += "WHERE VPK.VPK_DATMOV BETWEEN '"+dtos(dDatIni)+"' AND '"+dtos(dDatFin)+"' AND "
If nPosGrupo > 1
	cQuery += "VPK.VPK_GRUPO='"+left(aGrupos[nPosGrupo,2],len(VPK->VPK_GRUPO))+"' AND "
EndIf
cQuery += "VPK.D_E_L_E_T_=' ' ORDER BY VPK.VPK_CODCAI "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlCAI, .F., .T. )
While !( cQAlCAI )->( Eof() )
	///// Prazo Medio /////
	nTotAnt := aTotCai[1,8]							// Total Anterior
	nPrzAnt := aTotCai[1,14]						// Prazo Medio Anterior
	nTotAtu := ( cQAlCAI )->( VPK_VALVDA )	// Total Atual
	nPrzAtu := ( cQAlCAI )->( VPK_PRZMED )	// Prazo Medio Atual
	nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
	aTotCai[1,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
	/////////////////TOTAL GERAL////////////////////
	aTotCai[1,3] += ( cQAlCAI )->( VPK_QTDEST )
 	aTotCai[1,4] += ( cQAlCAI )->( VPK_CUSEST )
	aTotCai[1,6] += ( cQAlCAI )->( VPK_QTDVDA )
	aTotCai[1,7] += ( cQAlCAI )->( VPK_CUSVDA )
	aTotCai[1,8] += ( cQAlCAI )->( VPK_VALVDA )
	aTotCai[1,9] += ( cQAlCAI )->( VPK_VALLIQ ) 
	IF ( cQAlCAI )->( VE2_TIPPEC ) =="0" //TOTAL PES (PESADA)
		nTotAnt := aTotCai[2,8]							// Total Anterior
		nPrzAnt := aTotCai[2,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlCAI )->( VPK_VALVDA )		// Total Atual
		nPrzAtu := ( cQAlCAI )->( VPK_PRZMED )		// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aTotCai[2,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		aTotCai[2,3] += ( cQAlCAI )->( VPK_QTDEST )
	 	aTotCai[2,4] += ( cQAlCAI )->( VPK_CUSEST )
		aTotCai[2,6] += ( cQAlCAI )->( VPK_QTDVDA )
		aTotCai[2,7] += ( cQAlCAI )->( VPK_CUSVDA )
		aTotCai[2,8] += ( cQAlCAI )->( VPK_VALVDA )
		aTotCai[2,9] += ( cQAlCAI )->( VPK_VALLIQ )
	ELSEIF ( cQAlCAI )->( VE2_TIPPEC ) =="1" //TOTAL LEV (LEVE)
		nTotAnt := aTotCai[3,8]							// Total Anterior
		nPrzAnt := aTotCai[3,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlCAI )->( VPK_VALVDA )		// Total Atual
		nPrzAtu := ( cQAlCAI )->( VPK_PRZMED )		// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aTotCai[3,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )	
		aTotCai[3,3] += ( cQAlCAI )->( VPK_QTDEST )
	 	aTotCai[3,4] += ( cQAlCAI )->( VPK_CUSEST )
		aTotCai[3,6] += ( cQAlCAI )->( VPK_QTDVDA )
		aTotCai[3,7] += ( cQAlCAI )->( VPK_CUSVDA )
		aTotCai[3,8] += ( cQAlCAI )->( VPK_VALVDA )
		aTotCai[3,9] += ( cQAlCAI )->( VPK_VALLIQ )
	ELSEIF ( cQAlCAI )->( VE2_TIPPEC ) =="2" //TOTAL MOT (MOTO)
		nTotAnt := aTotCai[4,8]							// Total Anterior
		nPrzAnt := aTotCai[4,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlCAI )->( VPK_VALVDA )		// Total Atual
		nPrzAtu := ( cQAlCAI )->( VPK_PRZMED )		// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aTotCai[4,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )	
		aTotCai[4,3] += ( cQAlCAI )->( VPK_QTDEST )
	 	aTotCai[4,4] += ( cQAlCAI )->( VPK_CUSEST )
		aTotCai[4,6] += ( cQAlCAI )->( VPK_QTDVDA )
		aTotCai[4,7] += ( cQAlCAI )->( VPK_CUSVDA )
		aTotCai[4,8] += ( cQAlCAI )->( VPK_VALVDA )
		aTotCai[4,9] += ( cQAlCAI )->( VPK_VALLIQ )			
	ELSE //TOTAL OUTROS 
		nTotAnt := aTotCai[5,8]							// Total Anterior
		nPrzAnt := aTotCai[5,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlCAI )->( VPK_VALVDA )		// Total Atual
		nPrzAtu := ( cQAlCAI )->( VPK_PRZMED )		// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aTotCai[5,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )		
		aTotCai[5,3] += ( cQAlCAI )->( VPK_QTDEST )
	 	aTotCai[5,4] += ( cQAlCAI )->( VPK_CUSEST )
		aTotCai[5,6] += ( cQAlCAI )->( VPK_QTDVDA )
		aTotCai[5,7] += ( cQAlCAI )->( VPK_CUSVDA )
		aTotCai[5,8] += ( cQAlCAI )->( VPK_VALVDA )
		aTotCai[5,9] += ( cQAlCAI )->( VPK_VALLIQ )
	ENDIF
	nPos := Ascan(aCodCAI,{|x| x[2] ==  Alltrim(( cQAlCAI )->( VPK_CODCAI ))+"-"+( cQAlCAI )->( VE2_DESCAI ) })
	If nPos == 0
		aAdd(aCodCAI,{ 7 ,  Alltrim(( cQAlCAI )->( VPK_CODCAI ))+"-"+( cQAlCAI )->( VE2_DESCAI ) , ( cQAlCAI )->( VPK_QTDEST ) , ( cQAlCAI )->( VPK_CUSEST ) , 0 , ( cQAlCAI )->( VPK_QTDVDA ) , ( cQAlCAI )->( VPK_CUSVDA ) , ( cQAlCAI )->( VPK_VALVDA ) , ( cQAlCAI )->( VPK_VALLIQ ) , 0 , 0 , 0 , 0 , ( cQAlCAI )->( VPK_PRZMED ) })
   Else
		///// Prazo Medio /////
		nTotAnt := aCodCAI[nPos,8]						// Total Anterior
		nPrzAnt := aCodCAI[nPos,14]					// Prazo Medio Anterior
		nTotAtu := ( cQAlCAI )->( VPK_VALVDA )	// Total Atual
		nPrzAtu := ( cQAlCAI )->( VPK_PRZMED )	// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aCodCAI[nPos,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		///////////////////////
      aCodCAI[nPos,3] += ( cQAlCAI )->( VPK_QTDEST )
		aCodCAI[nPos,4] += ( cQAlCAI )->( VPK_CUSEST )
  		aCodCAI[nPos,6] += ( cQAlCAI )->( VPK_QTDVDA )
		aCodCAI[nPos,7] += ( cQAlCAI )->( VPK_CUSVDA )
		aCodCAI[nPos,8] += ( cQAlCAI )->( VPK_VALVDA ) 
		aCodCAI[nPos,9] += ( cQAlCAI )->( VPK_VALLIQ )	
   EndIf
	nCusEst += ( cQAlCAI )->( VPK_CUSEST ) //custo estoque
	nValLiq += ( cQAlCAI )->( VPK_VALLIQ ) //valor liquido
	nCusVda += ( cQAlCAI )->( VPK_CUSVDA ) //custo venda
	nValVda += ( cQAlCAI )->( VPK_VALVDA ) //valor venda 
	( cQAlCAI )->( DbSkip() )
EndDo
( cQAlCAI )->( dbCloseArea() )

DbSelectArea("VPK")
For ni := 1 to Len(aCodCAI)
	aCodCAI[ni,5]  := ( ( aCodCAI[ni,4] / nCusEst ) * 100 )  //custo estoque
	aCodCAI[ni,10] := ( ( aCodCAI[ni,9] / nValLiq ) * 100 )  //valor liquido
  	aCodCAI[ni,11] := int( aCodCAI[ni,4] / (aCodCAI[ni,7] / nj ) ) //giro sobre estoque mes  ((Custo venda / dias)/custo estoque)
	aCodCAI[ni,12] := ( ( ( aCodCAI[ni,8] - aCodCAI[ni,7] ) / aCodCAI[ni,8] ) * 100 )  //Margem da Venda
	aCodCAI[ni,13] := ( ( ( aCodCAI[ni,9] - aCodCAI[ni,7] ) / aCodCAI[ni,9] ) * 100 )  //Margem Corrigida
Next 

For ni := 1 to Len(aTotCai)
	aTotCai[ni,5]  := ( ( aTotCai[ni,4] / nCusEst ) * 100 )  //custo estoque
	aTotCai[ni,10] := ( ( aTotCai[ni,9] / nValLiq ) * 100 )  //valor liquido
  	aTotCai[ni,11] := int( aTotCai[ni,4] / (aTotCai[ni,7] / nj ) ) //giro sobre estoque mes  ((Custo venda / dias)/custo estoque)
	aTotCai[ni,12] := ( ( ( aTotCai[ni,8] - aTotCai[ni,7] ) / aTotCai[ni,8] ) * 100 )  //Margem da Venda
	aTotCai[ni,13] := ( ( ( aTotCai[ni,9] - aTotCai[ni,7] ) / aTotCai[ni,9] ) * 100 )  //Margem Corrigida
Next 
aSort(aTotCai,1,,{|x,y| x[1] < y[1]})


If Len(aCodCAI) == 0 //array em branco
	return
Endif

DEFINE MSDIALOG oAnCAI FROM 000,000 TO 035,100 TITLE OemToAnsi(STR0010+" - "+STR0021) OF oMainWnd  // gIRO ESTOQUE POR GRUPO + ANALITICO CAI
	@ 028,001 LISTBOX oTotCai FIELDS HEADER   OemToAnsi(STR0037),;//TOTAIS
															OemToAnsi(RetTitle("VPK_QTDEST")),;
															OemToAnsi(RetTitle("VPK_CUSEST")),;
															OemToAnsi(RetTitle("VPK_QTDVDA")),;
															OemToAnsi(RetTitle("VPK_CUSVDA")),;
															OemToAnsi(RetTitle("VPK_VALVDA")),;
															OemToAnsi(RetTitle("VPK_VALLIQ")),;
															OemToAnsi(STR0011 ),;	//Giro Est MeS
															OemToAnsi(STR0012 ),;	//Margem Venda
															OemToAnsi(STR0013 ),;	//Margem Corrig
															OemToAnsi(RetTitle("VPK_PRZMED"));
															COLSIZES 80,50,70,50,50,70,50,40,40,40,40 SIZE 394,065 OF oAnCAI PIXEL
	oTotCai:SetArray(aTotCai)
  	oTotCai:bLine := { || {  aTotCai[oTotCai:nAt,2] ,;
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,3],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,4],"@E 99,999,999,999.99"))+" "+Transform(aTotCai[oTotCai:nAt,5],"@E 9999.9%") ,;									 
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,6],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,7],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,8],"@E 99,999,999,999.99"))+" "+Transform(aTotCai[oTotCai:nAt,10],"@E 9999.9%") ,;
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,9],"@E 99,999,999,999.99")) ,; 
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,11],"@E 999999")) ,;
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,12],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,13],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aTotCai[oTotCai:nAt,14],"@E 999999")) }} 

	@ 093,001 LISTBOX oGrpCai FIELDS HEADER   OemToAnsi(RetTitle("VPK_CODCAI")),;
															OemToAnsi(RetTitle("VPK_QTDEST")),;
															OemToAnsi(RetTitle("VPK_CUSEST")),;
															OemToAnsi(RetTitle("VPK_QTDVDA")),;
															OemToAnsi(RetTitle("VPK_CUSVDA")),;
															OemToAnsi(RetTitle("VPK_VALVDA")),;
															OemToAnsi(RetTitle("VPK_VALLIQ")),;
															OemToAnsi(STR0011 ),;	//Giro Est MeS),;
															OemToAnsi(STR0012 ),;	//Margem Venda),;
															OemToAnsi(STR0013 ),;	//Margem Corrig),;
															OemToAnsi(RetTitle("VPK_PRZMED"));
															COLSIZES 80,50,70,50,50,70,50,40,40,40,40 SIZE 394,170 OF oAnCAI PIXEL  
	oGrpCai:SetArray(aCodCAI)
  	oGrpCai:bLine := { || {  aCodCAI[oGrpCai:nAt,2] ,;
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,3],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,4],"@E 99,999,999,999.99"))+" "+Transform(aCodCAI[oGrpCai:nAt,5],"@E 9999.9%") ,;									 
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,6],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,7],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,8],"@E 99,999,999,999.99"))+" "+Transform(aCodCAI[oGrpCai:nAt,10],"@E 9999.9%") ,;
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,9],"@E 99,999,999,999.99")) ,; 
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,11],"@E 999999")) ,;
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,12],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,13],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aCodCAI[oGrpCai:nAt,14],"@E 999999")) }}
	@ 010,348 BUTTON oVoltar PROMPT OemToAnsi(STR0022) OF oAnCAI SIZE 44,10 PIXEL ACTION oAnCAI:End() //VOLTAR
	@ 002,005 TO 024,185 LABEL OemToAnsi(STR0014) OF oAnCAI PIXEL COLOR CLR_BLUE //Filtro
//	@ 010,010 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 170,07 OF oAnCAI PIXEL COLOR CLR_BLUE WHEN .f.
	@ 011,011 Say OemToAnsi("Data Inicial") SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLUE
	@ 010,047 msGet oDatIni VAR dDatIni Picture "@D" SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLACK
	@ 011,095 Say OemToAnsi("Data Final") SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLUE
	@ 010,131 msGet oDatFin VAR dDatFin Picture "@D" VALID processa({ || FS_LEVANTA(1) }) SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLACK
	@ 002,190 TO 024,295 LABEL (Alltrim(RetTitle("VPK_GRUPO"))) OF oAnCAI PIXEL COLOR CLR_BLUE   //Total Geral
	@ 012,195 SAY IIf(nPosGrupo>1,aGrupos[nPosGrupo,2],STR0023) SIZE 150,8 OF oAnCAI PIXEL COLOR CLR_BLUE   //todos
	@ 010,300 BUTTON oImpr PROMPT OemToAnsi(STR0018) OF oAnCAI SIZE 44,10 PIXEL ACTION FS_IMPRIMIR(2)	//IMPRIMIR CAI
ACTIVATE MSDIALOG oAnCAI CENTER
  
Return              


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LISEMP   ³ Autor ³  Rafael               ³ Data ³ 01/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista analiticamente FILIAIS                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_LISEMP(nPosGrupo)
Local cQAlEmp := "SQLCAI"
Local nCusEst := 0
Local nValLiq := 0
Local nCusVda := 0
Local nValVda := 0
Local nPos := 0
Local ni := 0
Local nj := 0
Local cDescFil := ""
Local cEmp  := ""
//////////////////////////////////////////////////////////////////////////////// 
Local nRecSM0 := SM0->(Recno())
Local aVetEmp := {}
Private aCodEmp := {}
Private aTotEmp := {}

cEmp := SM0->M0_CODIGO
DbSelectArea("SM0")
DbGoTop()
While !Eof()
	If cEmp == SM0->M0_CODIGO
		aAdd( aVetEmp, { SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_NOME })
	Endif
	DbSelectArea("SM0")
	DbSkip()
EndDo
DbGoTo(nRecSM0)
////////////////////////////////////////////////////////////////////////////////
aAdd(aTotEmp,{ 1 , STR0032 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })   //Total Geral
aAdd(aTotEmp,{ 2 , STR0033 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total PESADA
aAdd(aTotEmp,{ 3 , STR0034 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total LEVE
aAdd(aTotEmp,{ 4 , STR0035 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total MOTO
aAdd(aTotEmp,{ 5 , STR0036 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) //Total OUTROS
/*   
If	cCombo == STR0001 +" ( "+Transform(dDataBase-30,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )"//Ultimos 30 dia ### a
	nj := 30
ElseIf cCombo == STR0002 +" ( "+Transform(dDataBase-60,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )"//Ultimos 60 dias ### a
	nj := 60
ElseIf cCombo == STR0003 +" ( "+Transform(dDataBase-90,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 90 dias ### a
	nj := 90
ElseIf cCombo == STR0004 +" ( "+Transform(dDataBase-120,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 120 dias ### a
	nj := 120
ElseIf cCombo == STR0005 +" ( "+Transform(dDataBase-240,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 240 dias ### a
	nj := 240
ElseIf cCombo == STR0006 +" ( "+Transform(dDataBase-365,"@D")+" "+ STR0007 +" "+Transform(dDataBase,"@D")+" )" //Ultimos 365 dias ### a
	nj := 365
EndIf
*/
nj := dDatFin - dDatIni

cQuery := "SELECT VPK.* , VE2.VE2_DESCAI , VE2.VE2_TIPPEC "
cQuery += " FROM "+RetSqlName("VPK")+" VPK JOIN "+RetSqlName("SBM")+" SBM ON ( SBM.BM_FILIAL='"+xFilial("SBM")+"' AND SBM.BM_GRUPO = VPK.VPK_GRUPO AND SBM.D_E_L_E_T_=' ' ) "
cQuery += " JOIN "+RetSqlName("VE2")+" VE2 ON ( VE2.VE2_FILIAL='"+xFilial("VE2")+"' AND VPK.VPK_CODCAI=VE2.VE2_CODCAI AND VE2.VE2_CODMAR = SBM.BM_CODMAR AND VE2.D_E_L_E_T_=' ' ) "
//cQuery += " WHERE VPK.VPK_DATMOV>='"+ dtos(dDataBase-nj) +"' AND "
cQuery += "WHERE VPK.VPK_DATMOV BETWEEN '"+dtos(dDatIni)+"' AND '"+dtos(dDatFin)+"' AND "
If nPosGrupo > 1
	cQuery += "VPK.VPK_GRUPO='"+left(aGrupos[nPosGrupo,2],len(VPK->VPK_GRUPO))+"' AND "
EndIf
cQuery += "VPK.D_E_L_E_T_=' ' ORDER BY VPK.VPK_FILIAL "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlEmp, .F., .T. ) 

While !( cQAlEmp )->( Eof() )
	///// Prazo Medio /////
		nTotAnt := aTotEmp[1,8]							// Total Anterior
		nPrzAnt := aTotEmp[1,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlEmp )->( VPK_VALVDA )			// Total Atual
		nPrzAtu := ( cQAlEmp )->( VPK_PRZMED )			// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aTotEmp[1,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
	///////////////////////
	aTotEmp[1,3] += ( cQAlEmp )->( VPK_QTDEST )
 	aTotEmp[1,4] += ( cQAlEmp )->( VPK_CUSEST )
	aTotEmp[1,6] += ( cQAlEmp )->( VPK_QTDVDA )
	aTotEmp[1,7] += ( cQAlEmp )->( VPK_CUSVDA )
	aTotEmp[1,8] += ( cQAlEmp )->( VPK_VALVDA )
	aTotEmp[1,9] += ( cQAlEmp )->( VPK_VALLIQ )
	IF ( cQAlEmp )->( VE2_TIPPEC ) =="0" 				//TOTAL PES (PESADA)
		nTotAnt := aTotEmp[2,8]							// Total Anterior
		nPrzAnt := aTotEmp[2,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlEmp )->( VPK_VALVDA )			// Total Atual
		nPrzAtu := ( cQAlEmp )->( VPK_PRZMED )			// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aTotEmp[2,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		aTotEmp[2,3] += ( cQAlEmp )->( VPK_QTDEST )
	 	aTotEmp[2,4] += ( cQAlEmp )->( VPK_CUSEST )
		aTotEmp[2,6] += ( cQAlEmp )->( VPK_QTDVDA )
		aTotEmp[2,7] += ( cQAlEmp )->( VPK_CUSVDA )
		aTotEmp[2,8] += ( cQAlEmp )->( VPK_VALVDA )
		aTotEmp[2,9] += ( cQAlEmp )->( VPK_VALLIQ )
	ELSEIF ( cQAlEmp )->( VE2_TIPPEC ) =="1" 			//TOTAL LEV (LEVE)
		nTotAnt := aTotEmp[3,8]							// Total Anterior
		nPrzAnt := aTotEmp[3,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlEmp )->( VPK_VALVDA )	   		// Total Atual
		nPrzAtu := ( cQAlEmp )->( VPK_PRZMED )			// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aTotEmp[3,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		aTotEmp[3,3] += ( cQAlEmp )->( VPK_QTDEST )
	 	aTotEmp[3,4] += ( cQAlEmp )->( VPK_CUSEST )
		aTotEmp[3,6] += ( cQAlEmp )->( VPK_QTDVDA )
		aTotEmp[3,7] += ( cQAlEmp )->( VPK_CUSVDA )
		aTotEmp[3,8] += ( cQAlEmp )->( VPK_VALVDA )
		aTotEmp[3,9] += ( cQAlEmp )->( VPK_VALLIQ )
	ELSEIF ( cQAlEmp )->( VE2_TIPPEC ) =="2" 			//TOTAL MOT (MOTO)
		nTotAnt := aTotEmp[4,8]							// Total Anterior
		nPrzAnt := aTotEmp[4,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlEmp )->( VPK_VALVDA )			// Total Atual
		nPrzAtu := ( cQAlEmp )->( VPK_PRZMED )			// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aTotEmp[4,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		aTotEmp[4,3] += ( cQAlEmp )->( VPK_QTDEST )
	 	aTotEmp[4,4] += ( cQAlEmp )->( VPK_CUSEST )
		aTotEmp[4,6] += ( cQAlEmp )->( VPK_QTDVDA )
		aTotEmp[4,7] += ( cQAlEmp )->( VPK_CUSVDA )
		aTotEmp[4,8] += ( cQAlEmp )->( VPK_VALVDA )
		aTotEmp[4,9] += ( cQAlEmp )->( VPK_VALLIQ )			
	ELSE //TOTAL OUTROS
		nTotAnt := aTotEmp[5,8]							// Total Anterior
		nPrzAnt := aTotEmp[5,14]						// Prazo Medio Anterior
		nTotAtu := ( cQAlEmp )->( VPK_VALVDA )			// Total Atual
		nPrzAtu := ( cQAlEmp )->( VPK_PRZMED )			// Prazo Medio Atual
		nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
		aTotEmp[5,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )			
		aTotEmp[5,3] += ( cQAlEmp )->( VPK_QTDEST )
	 	aTotEmp[5,4] += ( cQAlEmp )->( VPK_CUSEST )
		aTotEmp[5,6] += ( cQAlEmp )->( VPK_QTDVDA )
		aTotEmp[5,7] += ( cQAlEmp )->( VPK_CUSVDA )
		aTotEmp[5,8] += ( cQAlEmp )->( VPK_VALVDA )
		aTotEmp[5,9] += ( cQAlEmp )->( VPK_VALLIQ )
	ENDIF

	nPos := Ascan(aCodEmp,{|x| x[2] ==  Alltrim(( cQAlEmp )->( VPK_FILIAL ))+" - "+( cDescFil ) })
	If nPos == 0
		For ni:=1 to len(aVetEmp) //descricao da filial
		    IF alltrim(( cQAlEmp )->( VPK_FILIAL )) == alltrim(aVetEmp[ni,2])
		    	cDescFil := aVetEmp[ni,3]
		    EndIf
		next
		aAdd(aCodEmp,{ 2 ,  Alltrim(( cQAlEmp )->( VPK_FILIAL ))+" - "+( cDescFil ) , ( cQAlEmp )->( VPK_QTDEST ) , ( cQAlEmp )->( VPK_CUSEST ) , 0 , ( cQAlEmp )->( VPK_QTDVDA ) , ( cQAlEmp )->( VPK_CUSVDA ) , ( cQAlEmp )->( VPK_VALVDA ) , ( cQAlEmp )->( VPK_VALLIQ ) , 0 , 0 , 0 , 0 , ( cQAlEmp )->( VPK_PRZMED ) })
   Else
		///// Prazo Medio /////
			nTotAnt := aCodEmp[nPos,8]						// Total Anterior
			nPrzAnt := aCodEmp[nPos,14]						// Prazo Medio Anterior
			nTotAtu := ( cQAlEmp )->( VPK_VALVDA )	   		// Total Atual
			nPrzAtu := ( cQAlEmp )->( VPK_PRZMED )			// Prazo Medio Atual
			nTotVda := ( nTotAnt + nTotAtu )				// Total Geral Vendas
			aCodEmp[nPos,14] := ( ( ( nTotAtu * nPrzAtu ) + ( nTotAnt * nPrzAnt ) ) / nTotVda )
		///////////////////////
      aCodEmp[nPos,3] += ( cQAlEmp )->( VPK_QTDEST )
		aCodEmp[nPos,4] += ( cQAlEmp )->( VPK_CUSEST )
  		aCodEmp[nPos,6] += ( cQAlEmp )->( VPK_QTDVDA )
		aCodEmp[nPos,7] += ( cQAlEmp )->( VPK_CUSVDA )
		aCodEmp[nPos,8] += ( cQAlEmp )->( VPK_VALVDA ) 
		aCodEmp[nPos,9] += ( cQAlEmp )->( VPK_VALLIQ )	
   EndIf
	nCusEst += ( cQAlEmp )->( VPK_CUSEST ) //custo estoque
	nValLiq += ( cQAlEmp )->( VPK_VALLIQ ) //valor liquido
	nCusVda += ( cQAlEmp )->( VPK_CUSVDA ) //custo venda
	nValVda += ( cQAlEmp )->( VPK_VALVDA ) //valor venda 
	( cQAlEmp )->( DbSkip() )
EndDo
( cQAlEmp )->( dbCloseArea() )

DbSelectArea("VPK")
For ni := 1 to Len(aCodEmp)
	aCodEmp[ni,5]  := ( ( aCodEmp[ni,4] / nCusEst ) * 100 )  //custo estoque
	aCodEmp[ni,10] := ( ( aCodEmp[ni,9] / nValLiq ) * 100 )  //valor liquido
  	aCodEmp[ni,11] := int( aCodEmp[ni,4] / (aCodEmp[ni,7] / nj ) ) //giro sobre estoque mes  ((Custo venda / dias)/custo estoque)
	aCodEmp[ni,12] := ( ( ( aCodEmp[ni,8] - aCodEmp[ni,7] ) / aCodEmp[ni,8] ) * 100 )  //Margem da venda
	aCodEmp[ni,13] := ( ( ( aCodEmp[ni,9] - aCodEmp[ni,7] ) / aCodEmp[ni,9] ) * 100 )  //Margem Corrigida
Next
For ni := 1 to Len(aTotEmp)
	aTotEmp[ni,5]  := ( ( aTotEmp[ni,4] / nCusEst ) * 100 )  //custo estoque
	aTotEmp[ni,10] := ( ( aTotEmp[ni,9] / nValLiq ) * 100 )  //valor liquido
  	aTotEmp[ni,11] := int( aTotEmp[ni,4] / (aTotEmp[ni,7] / nj ) ) //giro sobre estoque mes  ((Custo venda / dias)/custo estoque)
	aTotEmp[ni,12] := ( ( ( aTotEmp[ni,8] - aTotEmp[ni,7] ) / aTotEmp[ni,8] ) * 100 )  //Margem da venda
	aTotEmp[ni,13] := ( ( ( aTotEmp[ni,9] - aTotEmp[ni,7] ) / aTotEmp[ni,9] ) * 100 )  //Margem Corrigida
Next 
aSort(aTotEmp,1,,{|x,y| x[1] < y[1]})
If Len(aCodEmp) == 0
	Return
Endif

DEFINE MSDIALOG oAnEmp FROM 000,000 TO 035,100 TITLE OemToAnsi(STR0010+" - "+STR0024) OF oMainWnd  // GIRO ESTOQUE POR GRUPO +  ANALITICO FILIAL
  	@ 028,001 LISTBOX oTotEmp FIELDS HEADER   OemToAnsi(STR0037),; //TOTAIS
															OemToAnsi(RetTitle("VPK_QTDEST")),;
															OemToAnsi(RetTitle("VPK_CUSEST")),;
															OemToAnsi(RetTitle("VPK_QTDVDA")),;
															OemToAnsi(RetTitle("VPK_CUSVDA")),;
															OemToAnsi(RetTitle("VPK_VALVDA")),;
															OemToAnsi(RetTitle("VPK_VALLIQ")),;
															OemToAnsi(STR0011 ),;	//Giro Est MeS
															OemToAnsi(STR0012 ),;	//Margem Venda
															OemToAnsi(STR0013 ),;	//Margem Corrig
															OemToAnsi(RetTitle("VPK_PRZMED"));
															COLSIZES 80,50,70,50,50,70,50,40,40,40,40 SIZE 394,065 OF oAnEmp PIXEL
	oTotEmp:SetArray(aTotEmp)
  	oTotEmp:bLine := { || {  aTotEmp[oTotEmp:nAt,2] ,;
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,3],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,4],"@E 99,999,999,999.99"))+" "+Transform(aTotEmp[oTotEmp:nAt,5],"@E 9999.9%") ,;									 
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,6],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,7],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,8],"@E 99,999,999,999.99"))+" "+Transform(aTotEmp[oTotEmp:nAt,10],"@E 9999.9%") ,;
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,9],"@E 99,999,999,999.99")) ,; 
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,11],"@E 999999")) ,;
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,12],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,13],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aTotEmp[oTotEmp:nAt,14],"@E 999999")) }}  
  
	@ 093,001 LISTBOX oGrpEmp FIELDS HEADER   OemToAnsi(RetTitle("VPK_FILIAL")),;
															OemToAnsi(RetTitle("VPK_QTDEST")),;
															OemToAnsi(RetTitle("VPK_CUSEST")),;
															OemToAnsi(RetTitle("VPK_QTDVDA")),;
															OemToAnsi(RetTitle("VPK_CUSVDA")),;
															OemToAnsi(RetTitle("VPK_VALVDA")),;
															OemToAnsi(RetTitle("VPK_VALLIQ")),;
															OemToAnsi(STR0011 ),;	//Giro Est MeS),;
															OemToAnsi(STR0012 ),;	//Margem Venda),;
															OemToAnsi(STR0013 ),;	//Margem Corrig),;
															OemToAnsi(RetTitle("VPK_PRZMED"));
															COLSIZES 80,50,70,50,50,70,50,40,40,40,40 SIZE 394,170 OF oAnEmp PIXEL  
	oGrpEmp:SetArray(aCodEmp)
  	oGrpEmp:bLine := { || {  aCodEmp[oGrpEmp:nAt,2] ,;
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,3],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,4],"@E 99,999,999,999.99"))+" "+Transform(aCodEmp[oGrpEmp:nAt,5],"@E 9999.9%") ,;									 
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,6],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,7],"@E 99,999,999,999.99")) ,;
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,8],"@E 99,999,999,999.99"))+" "+Transform(aCodEmp[oGrpEmp:nAt,10],"@E 9999.9%") ,;
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,9],"@E 99,999,999,999.99")) ,; 
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,11],"@E 999999")) ,;
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,12],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,13],"@E 9999.9%")) ,;
									 FG_AlinVlrs(Transform(aCodEmp[oGrpEmp:nAt,14],"@E 999999")) }}
	@ 010,348 BUTTON oVoltar PROMPT OemToAnsi(STR0022) OF oAnEmp SIZE 44,10 PIXEL ACTION oAnEmp:End() //VOLTAR
	@ 002,005 TO 024,185 LABEL OemToAnsi(STR0014) OF oAnEmp PIXEL COLOR CLR_BLUE//Filtro
//	@ 010,010 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 170,07 OF oAnEmp PIXEL COLOR CLR_BLUE WHEN .f.
	@ 011,011 Say OemToAnsi("Data Inicial") SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLUE
	@ 010,047 msGet oDatIni VAR dDatIni Picture "@D" SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLACK
	@ 011,095 Say OemToAnsi("Data Final") SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLUE
	@ 010,131 msGet oDatFin VAR dDatFin Picture "@D" VALID processa({ || FS_LEVANTA(1) }) SIZE 40,08 OF oGEstq PIXEL COLOR CLR_BLACK
	@ 002,190 TO 024,295 LABEL (Alltrim(RetTitle("VPK_GRUPO"))) OF oAnEmp PIXEL COLOR CLR_BLUE   //Total Geral
  	@ 012,195 SAY IIf(nPosGrupo>1,aGrupos[nPosGrupo,2],STR0023) SIZE 150,8 OF oAnEmp PIXEL COLOR CLR_BLUE   //Todos
	@ 010,300 BUTTON oImpr PROMPT OemToAnsi(STR0018) OF oAnEmp SIZE 44,10 PIXEL ACTION FS_IMPRIMIR(3)	//IMPRIMIR CAI
ACTIVATE MSDIALOG oAnEmp CENTER
Return
                                
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_IMPRIMIR ³ Autor ³  Rafael               ³ Data ³ 22/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_IMPRIMIR(nTip)

Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Local ni 		:= 0 
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private cTamanho:= "G"           // P/M/G
Private Limite  := 132           // 80/132/220
Private aOrdem  := {}            // Ordem do Relatorio
Private cTitulo := STR0010 		//Giro Estoque por Grupo
Private cNomProg:= "OFIOC370"
Private cNomeRel:= "OFIOC370"
Private nLastKey:= 0
Private cabec1  := ""
Private cabec2  := ""
Private nCaracter:=15
Private m_Pag   := 1 
If nTip == 2
	cTitulo := STR0010+" - "+STR0021 //Giro Estoque por Grupo ### Analitico C.A.I.
ElseIf nTip == 3
	cTitulo := STR0010+" - "+STR0024 //Giro Estoque por Grupo ### Analitico Filial
EndIf
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer 

DbSelectArea("VPK")   
If nTip == 1 //impressao agrupada dos grupos
	cabec1 := space(1)+left(STR0025 +Dtoc(dDatIni) +" a "+Dtoc(dDatFin)+" "+ STR0026 +IIf(oGrpBox:nAt>1,aGrupos[oGrpBox:nAt,2],STR0023)+space(124),124)+" "+Right(space(34)+ STR0027 ,34) +" "+ Right(space(7)+ STR0028 ,7) +" "+ Right(space(9)+ STR0028 ,9) +" "+ Right(space(7)+ STR0029 ,7)  //Filtro: ### Grupo:  ### Todos ### Giro ### Margem ### Margem ### Prazo
	cabec2 := left(space(1)+RetTitle("VPK_GRUPO")+space(26),26) +"  "+ Left( STR0030 +space(11),11)                            +" "+ Right(Space(26)+RetTitle("VPK_CUSEST"),26)                         																  +" "+ Right(Space(19)+RetTitle("VPK_QTDVDA"),19)                        +" "+ Right(space(17)+RetTitle("VPK_CUSVDA"),17)                        +" "+ Right(space(29)+RetTitle("VPK_VALVDA"),29)                                                                                       +" "+ Right(space(15)+RetTitle("VPK_VALLIQ"),15) +' '+ STR0031  //"Qtde Estoq. ### Est Mes  Venda  Corrig Medio 
	nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
	@ nLin++ , 01 psay Left(aGrpTot[1,2]+space(20),20) +" "+ Left(Transform(aGrpTot[1,3],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrpTot[1,4],"@E 99,999,999,999.99")+space(17),17) +" "+ Left(Transform(aGrpTot[1,5],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aGrpTot[1,6],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrpTot[1,7],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrpTot[1,8],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrpTot[1,10],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aGrpTot[1,9],"@E 99,999,999,999.99")+space(18),18) +" "+ Right(Space(9)+Transform(aGrpTot[1,11],"@E 999999"),9) +" "+ Left(Transform(aGrpTot[1,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aGrpTot[1,13],"@E 999999.9%")+space(9),9) +" "+ right(Space(7)+Transform(aGrpTot[1,14],"@E 999999"),7)
  	@ nLin++ , 01 psay Repl("-",185)
  	@ nLin++   
  	For ni :=2 to len(aGrupos)		
  		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
		@ nLin++ , 01 psay Left(aGrupos[ni,2]+space(20),20) +" "+ Left(Transform(aGrupos[ni,3],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrupos[ni,4],"@E 99,999,999,999.99")+space(17),17) +" "+ Left(Transform(aGrupos[ni,5],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aGrupos[ni,6],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrupos[ni,7],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrupos[ni,8],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrupos[ni,10],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aGrupos[ni,9],"@E 99,999,999,999.99")+space(18),18) +" "+ Right(Space(9)+Transform(aGrupos[ni,11],"@E 999999"),9) +" "+ Left(Transform(aGrupos[ni,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aGrupos[ni,13],"@E 999999.9%")+space(9),9) +" "+ right(Space(7)+Transform(aGrupos[ni,14],"@E 999999"),7)
   Next
   @ nLin++
  	For ni :=1 to len(aGrpTot)		
  		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
		@ nLin++ , 01 psay Repl("-",185)
		@ nLin++ , 01 psay Left(aGrpTot[ni,2]+space(20),20) +" "+ Left(Transform(aGrpTot[ni,3],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrpTot[ni,4],"@E 99,999,999,999.99")+space(17),17) +" "+ Left(Transform(aGrpTot[ni,5],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aGrpTot[ni,6],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrpTot[ni,7],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrpTot[ni,8],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aGrpTot[ni,10],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aGrpTot[ni,9],"@E 99,999,999,999.99")+space(18),18) +" "+ Right(Space(9)+Transform(aGrpTot[ni,11],"@E 999999"),9) +" "+ Left(Transform(aGrpTot[ni,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aGrpTot[ni,13],"@E 999999.9%")+space(9),9) +" "+ right(Space(7)+Transform(aGrpTot[ni,14],"@E 999999"),7)
    Next   
	@ nLin++ , 01 psay Repl("-",185)
ElseIf nTip == 2 //analitico por cai IMPRESSAO
	//cabec1 := space(1)+left(STR0025 +cCombo+" "+ STR0026 +IIf(oGrpBox:nAt>1,aGrupos[oGrpBox:nAt,2],STR0023)+space(124),124)+" "+Right(space(6)+ STR0027 ,6) +" "+ Right(space(6)+ STR0028 ,6) +" "+ Right(space(7)+ STR0028 ,7) +" "+ Right(space(5)+ STR0029 ,5)  //Filtro: ### Grupo:  ### Todos ### Giro ### Margem ### Margem ### Prazo
	//cabec2 := left(space(1)+RetTitle("VPK_CODCAI")+space(20),20) +"  "+ Left( STR0030 +space(11),11) +" "+ Right(Space(22)+RetTitle("VPK_CUSEST"),22) +" "+ Right(Space(13)+RetTitle("VPK_QTDVDA"),13) +" "+ Right(space(14)+RetTitle("VPK_CUSVDA"),14) +" "+ Right(space(24)+RetTitle("VPK_VALVDA"),24) +"  "+ Right(space(12)+RetTitle("VPK_VALLIQ"),12) + STR0031  //"Qtde Estoq. ### Est Mes  Venda  Corrig Medio 
	cabec1 := space(1)+left(STR0025 +Dtoc(dDatIni) +" a "+Dtoc(dDatFin)+" "+ STR0026 +IIf(oGrpBox:nAt>1,aGrupos[oGrpBox:nAt,2],STR0023)+space(124),124)+" "+Right(space(34)+ STR0027 ,34) +" "+ Right(space(7)+ STR0028 ,7) +" "+ Right(space(9)+ STR0028 ,9) +" "+ Right(space(7)+ STR0029 ,7)  //Filtro: ### Grupo:  ### Todos ### Giro ### Margem ### Margem ### Prazo
	cabec2 := left(space(1)+RetTitle("VPK_GRUPO")+space(26),26) +"  "+ Left( STR0030 +space(11),11)                            +" "+ Right(Space(26)+RetTitle("VPK_CUSEST"),26)                         																  +" "+ Right(Space(19)+RetTitle("VPK_QTDVDA"),19)                        +" "+ Right(space(17)+RetTitle("VPK_CUSVDA"),17)                        +" "+ Right(space(29)+RetTitle("VPK_VALVDA"),29)                                                                                       +" "+ Right(space(15)+RetTitle("VPK_VALLIQ"),15) +' '+ STR0031  //"Qtde Estoq. ### Est Mes  Venda  Corrig Medio 
	nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
  	@ nLin++ , 01 psay Left(aTotCai[1,2]+space(20),20) +" "+ Left(Transform(aTotCai[1,3],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotCai[1,4],"@E 99,999,999,999.99")+space(17),17) +" "+ Left(Transform(aTotCai[1,5],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotCai[1,6],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotCai[1,7],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotCai[1,8],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotCai[1,10],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotCai[1,9],"@E 99,999,999,999.99")+space(18),18) +" "+ Right(Space(9)+Transform(aTotCai[1,11],"@E 999999"),9) +" "+ Left(Transform(aTotCai[1,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotCai[1,13],"@E 999999.9%")+space(9),9) +" "+ right(Space(7)+Transform(aTotCai[1,14],"@E 999999"),7)
  	@ nLin++ , 01 psay Repl("-",185)
  	@ nLin++ 
  	For ni :=1 to len(aCodCAI)		
  		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
	  	@ nLin++ , 01 psay Left(aCodCAI[ni,2]+space(20),20) +" "+ Left(Transform(aCodCAI[ni,3],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aCodCAI[ni,4],"@E 99,999,999,999.99")+space(17),17) +" "+ Left(Transform(aCodCAI[ni,5],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aCodCAI[ni,6],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aCodCAI[ni,7],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aCodCAI[ni,8],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aCodCAI[ni,10],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aCodCAI[ni,9],"@E 99,999,999,999.99")+space(18),18) +" "+ Right(Space(9)+Transform(aCodCAI[ni,11],"@E 999999"),9) +" "+ Left(Transform(aCodCAI[ni,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aCodCAI[ni,13],"@E 999999.9%")+space(9),9) +" "+ right(Space(7)+Transform(aCodCAI[ni,14],"@E 999999"),7)
   Next
   @ nLin++
  	For ni :=1 to len(aTotCai)		
  		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
		@ nLin++ , 01 psay Repl("-",185)
	   	@ nLin++ , 01 psay Left(aTotCai[ni,2]+space(20),20) +" "+ Left(Transform(aTotCai[ni,3],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotCai[ni,4],"@E 99,999,999,999.99")+space(17),17) +" "+ Left(Transform(aTotCai[ni,5],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotCai[ni,6],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotCai[ni,7],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotCai[ni,8],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotCai[ni,10],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotCai[ni,9],"@E 99,999,999,999.99")+space(18),18) +" "+ Right(Space(9)+Transform(aTotCai[ni,11],"@E 999999"),9) +" "+ Left(Transform(aTotCai[ni,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotCai[ni,13],"@E 999999.9%")+space(9),9) +" "+ right(Space(7)+Transform(aTotCai[ni,14],"@E 999999"),7)
   Next   
	@ nLin++ , 01 psay Repl("-",185)
ElseIf nTip == 3  //analitico por FILIAL
	//cabec1 := space(1)+left(STR0025 +cCombo+" "+ STR0026 +IIf(oGrpBox:nAt>1,aGrupos[oGrpBox:nAt,2],STR0023)+space(124),124)+" "+Right(space(6)+ STR0027 ,6) +" "+ Right(space(6)+ STR0028 ,6) +" "+ Right(space(7)+ STR0028 ,7) +" "+ Right(space(5)+ STR0029 ,5)  //Filtro: ### Grupo:  ### Todos ### Giro ### Margem ### Margem ### Prazo
	//cabec2 := left(space(1)+RetTitle("VPK_FILIAL")+space(20),20) +"  "+ Left( STR0030 +space(11),11) +" "+ Right(Space(22)+RetTitle("VPK_CUSEST"),22) +" "+ Right(Space(13)+RetTitle("VPK_QTDVDA"),13) +" "+ Right(space(14)+RetTitle("VPK_CUSVDA"),14) +" "+ Right(space(24)+RetTitle("VPK_VALVDA"),24) +"  "+ Right(space(12)+RetTitle("VPK_VALLIQ"),12) + STR0031  //"Qtde Estoq. ### Est Mes  Venda  Corrig Medio 
	//nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
	cabec1 := space(1)+left(STR0025 +Dtoc(dDatIni) +" a "+Dtoc(dDatFin)+" "+ STR0026 +IIf(oGrpBox:nAt>1,aGrupos[oGrpBox:nAt,2],STR0023)+space(124),124)+" "+Right(space(34)+ STR0027 ,34) +" "+ Right(space(7)+ STR0028 ,7) +" "+ Right(space(9)+ STR0028 ,9) +" "+ Right(space(7)+ STR0029 ,7)  //Filtro: ### Grupo:  ### Todos ### Giro ### Margem ### Margem ### Prazo
	cabec2 := left(space(1)+RetTitle("VPK_GRUPO")+space(26),26) +"  "+ Left( STR0030 +space(11),11)                            +" "+ Right(Space(26)+RetTitle("VPK_CUSEST"),26)                         																  +" "+ Right(Space(19)+RetTitle("VPK_QTDVDA"),19)                        +" "+ Right(space(17)+RetTitle("VPK_CUSVDA"),17)                        +" "+ Right(space(29)+RetTitle("VPK_VALVDA"),29)                                                                                       +" "+ Right(space(15)+RetTitle("VPK_VALLIQ"),15) +' '+ STR0031  //"Qtde Estoq. ### Est Mes  Venda  Corrig Medio 
	nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
  	@ nLin++ , 01 psay Left(aTotEmp[1,2]+space(20),20) +" "+ Left(Transform(aTotEmp[1,3],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotEmp[1,4],"@E 99,999,999,999.99")+space(17),17) +" "+ Left(Transform(aTotEmp[1,5],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotEmp[1,6],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotEmp[1,7],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotEmp[1,8],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotEmp[1,10],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotEmp[1,9],"@E 99,999,999,999.99")+space(18),18) +" "+ Right(Space(9)+Transform(aTotEmp[1,11],"@E 999999"),9) +" "+ Left(Transform(aTotEmp[1,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotEmp[1,13],"@E 999999.9%")+space(9),9) +" "+ right(Space(7)+Transform(aTotEmp[1,14],"@E 999999"),7)
  	@ nLin++ , 01 psay Repl("-",185)
  	@ nLin++ 
  	For ni :=1 to len(aCodEmp)		
  		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
  	   	@ nLin++ , 01 psay Left(aCodEmp[ni,2]+space(20),20) +" "+ Left(Transform(aCodEmp[ni,3],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aCodEmp[ni,4],"@E 99,999,999,999.99")+space(17),17) +" "+ Left(Transform(aCodEmp[ni,5],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aCodEmp[ni,6],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aCodEmp[ni,7],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aCodEmp[ni,8],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aCodEmp[ni,10],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aCodEmp[ni,9],"@E 99,999,999,999.99")+space(18),18) +" "+ Right(Space(9)+Transform(aCodEmp[ni,11],"@E 999999"),9) +" "+ Left(Transform(aCodEmp[ni,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aCodEmp[ni,13],"@E 999999.9%")+space(9),9) +" "+ right(Space(7)+Transform(aCodEmp[ni,14],"@E 999999"),7)
   Next 
     @ nLin++
  	For ni :=1 to len(aTotEmp)		
  		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
		@ nLin++ , 01 psay Repl("-",185)
  	   	@ nLin++ , 01 psay Left(aTotEmp[ni,2]+space(20),20) +" "+ Left(Transform(aTotEmp[ni,3],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotEmp[ni,4],"@E 99,999,999,999.99")+space(17),17) +" "+ Left(Transform(aTotEmp[ni,5],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotEmp[ni,6],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotEmp[ni,7],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotEmp[ni,8],"@E 99,999,999,999.99")+space(18),18) +" "+ Left(Transform(aTotEmp[ni,10],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotEmp[ni,9],"@E 99,999,999,999.99")+space(18),18) +" "+ Right(Space(9)+Transform(aTotEmp[ni,11],"@E 999999"),9) +" "+ Left(Transform(aTotEmp[ni,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotEmp[ni,13],"@E 999999.9%")+space(9),9) +" "+ right(Space(7)+Transform(aTotEmp[ni,14],"@E 999999"),7)
  	   //retirada a linha pois estava imprimindo de forma incorreta. a linha correta eh a de cima
  	   //@ nLin++ , 01 psay Left(aTotEmp[ni,2]+space(20),20) +" "+ Left(Transform(aTotEmp[ni,3],"@E 9999,999.99")+space(11),11) +" "+ Left(Transform(aTotEmp[ni,4],"@E 9999,999,999.98")+space(15),15) +" "+ Left(Transform(aTotEmp[ni,5],"@E 999.9%")+space(6),6) +" "+ Left(Transform(aTotEmp[ni,6],"@E 9999,999.99")+space(11),11) +" "+ Left(Transform(aTotEmp[ni,7],"@E 9999,999,999.99")+space(15),15) +" "+ Left(Transform(aTotEmp[ni,8],"@E 9999,999,999.99")+space(15),15) +" "+ Left(Transform(aTotEmp[ni,10],"@E 999.9%")+space(6),6) +" "+ Left(Transform(aTotEmp[ni,9],"@E 9999,999,999.99")+space(15),15) +" "+ Right(Space(7)+Transform(aTotEmp[ni,11],"@E 9999"),7) +" "+ Left(Transform(aTotEmp[ni,12],"@E 9999.9%")+space(7),7) +" "+ Left(Transform(aTotEmp[ni,13],"@E 9999.9%")+space(7),7) +" "+ right(Space(5)+Transform(aTotEmp[ni,14],"@E 9999"),5)
   Next   
	@ nLin++ , 01 psay Repl("-",185)
EndIf

Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
OurSpool( cNomeRel )
EndIf
Return()
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////  VERIFICA A BASE SE EXISTE  ///////////////////////////
/////////////////////////////////////////////////////////////////////////////////
Static Function FS_VERBASE()
Local cQuery  := ""
Local cQAlias := "SQLERRO"
Local lOk     := .t.
Local cEmpSALVA:= cEmpAnt
Local cFilSALVA:= cFilAnt
Private bBlock:= ErrorBlock()
Private bErro := ErrorBlock( { |e| lOk := .f. } )
cEmpAnt := SM0->M0_CODIGO
cFilAnt := SM0->M0_CODFIL
cQuery := "SELECT VPK.VPK_GRUPO FROM "+RetSqlName("VPK")+" VPK WHERE VPK.VPK_FILIAL = '"+xFilial("VPK")+"' AND VPK.VPK_GRUPO='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
cQuery := "SELECT VE2.VE2_CODCAI FROM "+RetSqlName("VE2")+" VE2 WHERE VE2.VE2_FILIAL = '"+xFilial("VE2")+"' AND VE2.VE2_CODCAI='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
ErrorBlock(bBlock)
cEmpAnt := cEmpSALVA
cFilAnt := cFilSALVA
Return(lOk)