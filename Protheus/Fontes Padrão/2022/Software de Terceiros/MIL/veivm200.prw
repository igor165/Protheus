#INCLUDE 'FWMVCDEF.CH'
#Include "PROTHEUS.CH"
#Include "VEIVM200.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ VEIVM200 ∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  21/08/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Transmissao/Recepcao de Vendas e Bonus de Veiculos         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Veiculos                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VEIVM200()
Local aObjects   := {} , aPos := {} , aInfo := {} 
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
//
Local lMarcarSF2 := .f.
Local lMarcarVQ1 := .f.
//
Local a1FilNFI   := {}
Local cQuery     := ""
Local cQAlAux    := "SQLAUXILIAR"
//
Local aButtons := {}
//
Private c1FilNFI := space(TamSX3("F2_FILIAL")[1])
Private c1NumNFI := space(TamSX3("F2_DOC")[1])
Private c1SerNFI := space(FGX_MILSNF("SF2", 6,"F2_SERIE"))
Private c1CodCli := space(TamSX3("F2_CLIENTE")[1])
Private c1LojCli := space(TamSX3("F2_LOJA")[1])
Private d1DatIni := dDataBase
Private d1DatFin := dDataBase 
Private c1NumPed := space(TamSX3("VQ0_NUMPED")[1])
//
Private c2NumNFI := space(TamSX3("F2_DOC")[1])
Private c2SerNFI := space(FGX_MILSNF("SF2", 6,"F2_SERIE"))
Private c2CodCli := space(TamSX3("F2_CLIENTE")[1])
Private c2LojCli := space(TamSX3("F2_LOJA")[1])
Private d2DatIni := dDataBase
Private d2DatFin := dDataBase 
Private c2NumPed := space(TamSX3("VQ0_NUMPED")[1])
Private c2Retorn := space(TamSX3("VQ1_RETUID")[1])
//
Private c3NumNFI := space(TamSX3("F2_DOC")[1])
Private c3SerNFI := space(FGX_MILSNF("SF2", 6,"F2_SERIE"))
Private c3TipTPR := ""
Private a3TipTPR := X3CBOXAVET("VQ4_TIPREG","1")
Private d3DatIni := dDataBase
Private d3DatFin := dDataBase 
Private c3NumPed := space(TamSX3("VQ0_NUMPED")[1])
Private c3Return := space(TamSX3("VQ4_RETUID")[1])
//
Private aSF2     := {} // Vetor com as NFs Vendas Veiculos
Private aSF2Vei  := {} // Vetor com os Veiculos das NFs
//
Private aVQ1     := {} // Vetor com as NFs Comissao Bonus
Private aVQ1Bon  := {} // Vetor com os Bonus das NFs
//
Private aVQ4     := {} // Vetor com os Historicos NFs
Private aVQ4His  := {} // Vetor com os Registros Historicos da NF
//
Private oX       := LoadBitmap( GetResources() , "NADA" )		// Nenhuma figura
Private o0       := LoadBitmap( GetResources() , "BR_BRANCO" )	// NF nao transmitida
Private o1       := LoadBitmap( GetResources() , "BR_VERDE" )	// NF transmitida    
Private oLBNO    := LoadBitmap( GetResources() , "LBNO" )		// Sem TIK
Private oLBTIK   := LoadBitmap( GetResources() , "LBTIK" )		// Com TIK
//
Private cDirEnv  := ""
Private cDirRec  := ""
//
Private oDTFConfig := OFJDDTFConfig():New()
Private oRetAPiG := OFJDDTF():New("GET")
Private oRetAPiP := OFJDDTF():New("PUT")


oDTFConfig:GetConfig()
FS_CriaSX1("VEI200")
SetKey(VK_F12,{ || FS_PERGXML()})
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objeto
aObjects := {}
AAdd( aObjects, { 0,  00, .T. , .T. } ) // ListBox 1
AAdd( aObjects, { 0, 110, .T. , .F. } ) // ListBox 2
aPos := MsObjSize( aInfo, aObjects )
//
aAdd(a1FilNFI,"") // Todos
cQuery := "SELECT DISTINCT F2_FILIAL FROM "+RetSQLName("SF2")+" WHERE D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	aAdd(a1FilNFI,( cQAlAux )->( F2_FILIAL )) // Filial
	( cQAlAux )->( dbSkip() )
EndDo
( cQAlAux )->( dbCloseArea() )
//
FS_LEVANTA("SF2",.f.,1)
FS_LEVANTA("SF2Vei",.f.,0)
//
FS_LEVANTA("VQ1",.f.,1)
FS_LEVANTA("VQ1Bon",.f.,0)
//
FS_XML(3) // Retornos
//
FS_LEVANTA("VQ4",.f.,1)
FS_LEVANTA("VQ4His",.f.,0)
//
DEFINE MSDIALOG oVEIVM200 TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Transmissao/Recepcao de Vendas e Bonus de Veiculos
	oVEIVM200:lEscClose := .F.
	//
	oFoldVM200 := TFolder():New(aPos[1,1],aPos[1,2],{STR0002,STR0003,STR0004},{},oVEIVM200,,,,.t.,.f.,aPos[1,3],aPos[1,4]) // NF(s) de Venda / NF(s) de Bonus / HistÛricos
	oFoldVM200:Align := CONTROL_ALIGN_ALLCLIENT 
	//
	Aadd( aButtons, {STR0044, {|| oRetAPiG:getDTFList_Service(".BRCMAMT .BRSLERR",oDTFConfig:getIncentivo_Maquina())}, STR0045, STR0046 , {|| .T.}} )//"Busca DTF" /"Busca arquivos DTF" / "Importa DTF"
	Aadd( aButtons, {STR0047, {|| oRetAPiP:getDTFPut_Service(oDTFConfig:get_UP_Incentivo_Maquina())}, STR0048, STR0049 , {|| .T.}} )//"Envia DTF" /"Envia arquivos DTF" / "Exporta DTF"
	//
	// ------------------------------------------------- //
	// N O T A       F I S C A L      D E      V E N D A //
	// ------------------------------------------------- //
	oTScroll1 := TScrollBox():New( oFoldVM200:aDialogs[1] , 01 , 01 , 10 , 140 , .t. , , .t. )
	oTScroll1:Align := CONTROL_ALIGN_LEFT

	oPanF1_1 := tPanel():Create( oFoldVM200:aDialogs[1],01,01,,,.F.,,,,100,90)
	oPanF1_1:Align := CONTROL_ALIGN_ALLCLIENT
	oPanF1_2 := tPanel():Create( oFoldVM200:aDialogs[1],01,01,,,.F.,,,,100,90)
	oPanF1_2:Align := CONTROL_ALIGN_BOTTOM

	oPanF1_1_2 := tPanel():Create( oPanF1_1,01,01,,,.F.,,,,100,90)
	oPanF1_1_2:Align := CONTROL_ALIGN_ALLCLIENT

	oPanF1_1_3 := tPanel():Create( oPanF1_1,01,01,,,.F.,,,,100,17)
	oPanF1_1_3:Align := CONTROL_ALIGN_BOTTOM
	oPanF1_1_3:ReadClientCoors()
	
	@ 002 , 030 SAY UPPER(STR0005) SIZE 100,8 OF oTScroll1 PIXEL COLOR CLR_HBLUE // Filtrar NF(s) de VENDA
	@ 019 , 002 SAY (STR0012+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Filial
	@ 018 , 025 MSCOMBOBOX o1FilNFI VAR c1FilNFI SIZE 96,08 COLOR CLR_BLACK ITEMS a1FilNFI OF oTScroll1 PIXEL 
	@ 031 , 002 SAY (STR0006+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // NF
	@ 030 , 025 MSGET o1NumNFI VAR c1NumNFI F3 "SF2" PICTURE "@!" SIZE 54,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 030 , 081 MSGET o1SerNFI VAR c1SerNFI PICTURE "@!" SIZE 10,08 OF oTScroll1 PIXEL COLOR CLR_BLACK
	@ 043 , 002 SAY (STR0007+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Cliente
	@ 042 , 025 MSGET o1CodCli VAR c1CodCli F3 "SA1" PICTURE "@!" SIZE 54,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 042 , 081 MSGET o1LojCli VAR c1LojCli PICTURE "@!" SIZE 10,08 OF oTScroll1 PIXEL COLOR CLR_BLACK
	@ 055 , 002 SAY (STR0008+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Periodo
	@ 054 , 025 MSGET o1DatIni VAR d1DatIni PICTURE "@D" SIZE 43,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 055 , 069 SAY (STR0009) SIZE 15,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // ate
	@ 054 , 081 MSGET o1DatFin VAR d1DatFin PICTURE "@D" SIZE 43,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 067 , 002 SAY (STR0010+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Pedido
	@ 066 , 025 MSGET o1NumPed VAR c1NumPed PICTURE "@!" SIZE 54,08 OF oTScroll1 PIXEL COLOR CLR_BLACK

	@ 087 , 032 BUTTON o1Filtro PROMPT STR0011 OF oTScroll1 SIZE 60,09 PIXEL ACTION ( FS_LEVANTA("SF2",.t.,1) , FS_LEVANTA("SF2Vei",.t.,oLbSF2:nAt)) // Filtrar

	@ 01,01 LISTBOX oLbSF2 ;
		FIELDS ;
		HEADER "","",STR0012,STR0013,STR0006,STR0014,STR0015,STR0007 ;
		COLSIZES 10,10,50,35,35,20,50,150 ;
		SIZE 50,50 ;
		OF oPanF1_1_2 PIXEL ;
		ON CHANGE ( FS_LEVANTA("SF2Vei",.t.,oLbSF2:nAt) ) ;
		ON DBLCLICK IIf(aSF2[oLbSF2:nAt,02]<>"X",(aSF2[oLbSF2:nAt,01]:=!aSF2[oLbSF2:nAt,01]),.t.)
	oLbSF2:Align := CONTROL_ALIGN_ALLCLIENT
	oLbSF2:SetArray(aSF2)
	oLbSF2:bLine := { || { IIf(aSF2[oLbSF2:nAt,01],oLBTIK,oLBNO) , &("o"+aSF2[oLbSF2:nAt,02]) , aSF2[oLbSF2:nAt,03] , Transform(stod(aSF2[oLbSF2:nAt,04]),"@D") , aSF2[oLbSF2:nAt,05] , aSF2[oLbSF2:nAt,06] , FG_AlinVlrs(Transform(aSF2[oLbSF2:nAt,07],"@E 999,999,999.99")) , aSF2[oLbSF2:nAt,08] }}
	oLbSF2:bHeaderClick := { |oObj,nCol| IIf( nCol == 1 , ( lMarcarSF2 := !lMarcarSF2 , aEval( aSF2 , { |x| x[1] := lMarcarSF2 } ) ) ,Nil) , oLbSF2:Refresh() }
	//
	@ 003,010 BUTTON o1EnvNF PROMPT STR0020 OF oPanF1_1_3 SIZE 90,09 PIXEL ACTION FS_XML(1) // Transmitir NF(s) de Venda

	@ 003, 110 BITMAP o1Brac RESOURCE "BR_BRANCO" OF oPanF1_1_3 NOBORDER SIZE 10,10 PIXEL
	@ 003, 120 SAY STR0021 SIZE 100,8 OF oPanF1_1_3 PIXEL COLOR CLR_BLUE // NF nao transmitida
	@ 003, 180 BITMAP o1Verd RESOURCE "BR_VERDE" OF oPanF1_1_3 NOBORDER SIZE 10,10 PIXEL
	@ 003, 190 SAY STR0022 SIZE 100,8 OF oPanF1_1_3 PIXEL COLOR CLR_BLUE // NF transmitida
    //
	@ 001 , 001 LISTBOX oLbSF2Vei ;
		FIELDS ;
		HEADER STR0015,STR0010,STR0016,STR0017,STR0018,STR0019 ;
		COLSIZES 50,40,60,20,140,50 ;
		SIZE 50,50 ;
		OF oPanF1_2 PIXEL
	oLbSF2Vei:Align := CONTROL_ALIGN_ALLCLIENT
	oLbSF2Vei:SetArray(aSF2Vei)
	oLbSF2Vei:bLine := { || { ;
		FG_AlinVlrs(Transform(aSF2Vei[oLbSF2Vei:nAt,01],"@E 999,999,999.99")) , ;
		aSF2Vei[oLbSF2Vei:nAt,02] ,;
		aSF2Vei[oLbSF2Vei:nAt,03] ,;
		aSF2Vei[oLbSF2Vei:nAt,04] ,;
		aSF2Vei[oLbSF2Vei:nAt,05] ,;
		aSF2Vei[oLbSF2Vei:nAt,06] }}
	oLbSF2Vei:bLDblClick := { || VM2000011_Visualizar( aSF2Vei[oLbSF2Vei:nAt,02] , aSF2Vei[oLbSF2Vei:nAt,03] ) }
	//
	// ------------------------------------------------- //
	// N O T A       F I S C A L      D E      B O N U S //
	// ------------------------------------------------- //
	oTScroll2 := TScrollBox():New( oFoldVM200:aDialogs[2] , 01 , 01 , 10 , 140 , .t. , , .t. )
	oTScroll2:Align := CONTROL_ALIGN_LEFT

	oPanF2_1 := tPanel():Create( oFoldVM200:aDialogs[2],01,01,,,.F.,,,,100,90)
	oPanF2_1:Align := CONTROL_ALIGN_ALLCLIENT
	oPanF2_2 := tPanel():Create( oFoldVM200:aDialogs[2],01,01,,,.F.,,,,100,90)
	oPanF2_2:Align := CONTROL_ALIGN_BOTTOM

	oPanF2_1_2 := tPanel():Create( oPanF2_1,01,01,,,.F.,,,,100,90)
	oPanF2_1_2:Align := CONTROL_ALIGN_ALLCLIENT

	oPanF2_1_3 := tPanel():Create( oPanF2_1,01,01,,,.F.,,,,100,17)
	oPanF2_1_3:Align := CONTROL_ALIGN_BOTTOM
	oPanF2_1_3:ReadClientCoors()

	@ 002 , 030 SAY UPPER(STR0025) SIZE 100,8 OF oTScroll2 PIXEL COLOR CLR_HBLUE // Filtrar NF(s) de BONUS

	@ 019 , 002 SAY (STR0006+":") SIZE 55,8 OF oTScroll2 PIXEL COLOR CLR_BLUE // NF
	@ 018 , 025 MSGET o2NumNFI VAR c2NumNFI F3 "SF2" PICTURE "@!" SIZE 54,08 OF oTScroll2 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 018 , 081 MSGET o2SerNFI VAR c2SerNFI PICTURE "@!" SIZE 10,08 OF oTScroll2 PIXEL COLOR CLR_BLACK
	@ 031 , 002 SAY (STR0007+":") SIZE 55,8 OF oTScroll2 PIXEL COLOR CLR_BLUE // Cliente
	@ 030 , 025 MSGET o2CodCli VAR c2CodCli F3 "SA1" PICTURE "@!" SIZE 54,08 OF oTScroll2 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 030 , 081 MSGET o2LojCli VAR c2LojCli PICTURE "@!" SIZE 10,08 OF oTScroll2 PIXEL COLOR CLR_BLACK
	@ 043 , 002 SAY (STR0008+":") SIZE 55,8 OF oTScroll2 PIXEL COLOR CLR_BLUE // Periodo
	@ 042 , 025 MSGET o2DatIni VAR d2DatIni PICTURE "@D" SIZE 43,08 OF oTScroll2 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 043 , 069 SAY (STR0009) SIZE 25,8 OF oTScroll2 PIXEL COLOR CLR_BLUE // ate
	@ 042 , 081 MSGET o2DatFin VAR d2DatFin PICTURE "@D" SIZE 43,08 OF oTScroll2 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 055 , 002 SAY (STR0010+":") SIZE 55,8 OF oTScroll2 PIXEL COLOR CLR_BLUE // Pedido
	@ 054 , 025 MSGET o2NumPed VAR c2NumPed PICTURE "@!" SIZE 54,08 OF oTScroll2 PIXEL COLOR CLR_BLACK
	@ 067 , 002 SAY (STR0033+":") SIZE 55,8 OF oTScroll2 PIXEL COLOR CLR_BLUE // Retorno
	@ 066 , 025 MSGET o2Retorn VAR c2Retorn PICTURE "@!" SIZE 54,08 OF oTScroll2 PIXEL COLOR CLR_BLACK

	@ 087 , 032 BUTTON o2Filtro PROMPT STR0011 OF oTScroll2 SIZE 60,09 PIXEL ACTION (  FS_LEVANTA("VQ1",.t.,1) , FS_LEVANTA("VQ1Bon",.t.,oLbVQ1:nAt)) // Filtrar
    //
	@ 001 , 001 LISTBOX oLbVQ1 ;
		FIELDS ;
		HEADER "","",STR0012,STR0013,STR0006,STR0014,STR0015,STR0007,STR0033 ;
		COLSIZES 10,10,50,35,35,20,50,150,50 ;
		SIZE 50,50 ;
		OF oPanF2_1_2 PIXEL ;
		ON CHANGE ( FS_LEVANTA("VQ1Bon",.t.,oLbVQ1:nAt) ) ;
		ON DBLCLICK IIf(aVQ1[oLbVQ1:nAt,02]<>"X",(aVQ1[oLbVQ1:nAt,01]:=!aVQ1[oLbVQ1:nAt,01]),.t.)
	oLbVQ1:Align := CONTROL_ALIGN_ALLCLIENT	
	oLbVQ1:SetArray(aVQ1)
	oLbVQ1:bLine := { || { IIf(aVQ1[oLbVQ1:nAt,01],oLBTIK,oLBNO) , &("o"+aVQ1[oLbVQ1:nAt,02]) , aVQ1[oLbVQ1:nAt,03] , Transform(stod(aVQ1[oLbVQ1:nAt,04]),"@D") , aVQ1[oLbVQ1:nAt,05] , aVQ1[oLbVQ1:nAt,06] , FG_AlinVlrs(Transform(aVQ1[oLbVQ1:nAt,07],"@E 999,999,999.99")) , aVQ1[oLbVQ1:nAt,08] , aVQ1[oLbVQ1:nAt,09] }}
	oLbVQ1:bHeaderClick := { |oObj,nCol| IIf( nCol == 1 , ( lMarcarVQ1 := !lMarcarVQ1 , aEval( aVQ1 , { |x| x[1] := lMarcarVQ1 } ) ) ,Nil) , oLbVQ1:Refresh() }
	//
	@ 003 , 010 BUTTON o2EnvNF PROMPT STR0023 OF oPanF2_1_3 SIZE 90,09 PIXEL ACTION FS_XML(2) // Transmitir NF(s) de Bonus
	//
	@ 003 , 110 BITMAP o2Brac RESOURCE "BR_BRANCO" OF oPanF2_1_3 NOBORDER SIZE 10,10 PIXEL
	@ 003 , 120 SAY STR0021 SIZE 100,8 OF oPanF2_1_3 PIXEL COLOR CLR_BLUE // NF nao transmitida
	@ 003 , 180 BITMAP o2Verd RESOURCE "BR_VERDE" OF oPanF2_1_3 NOBORDER SIZE 10,10 PIXEL
	@ 003 , 190 SAY STR0022 SIZE 100,8 OF oPanF2_1_3 PIXEL COLOR CLR_BLUE // NF transmitida
    //
	@ aPos[2,1]-003,aPos[2,2]+000 LISTBOX oLbVQ1Bon ;
		FIELDS ;
		HEADER STR0024,STR0015,STR0010,STR0016,STR0017,STR0018,STR0019 ;
		COLSIZES 45,50,40,60,20,140,50 ;
		SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1]-((aPos[1,1]+003)*2) ;
		OF oPanF2_2 PIXEL
	oLbVQ1Bon:Align := CONTROL_ALIGN_ALLCLIENT
	oLbVQ1Bon:SetArray(aVQ1Bon)
	oLbVQ1Bon:bLine := { || { ;
		aVQ1Bon[oLbVQ1Bon:nAt,01] , ;
		FG_AlinVlrs(Transform(aVQ1Bon[oLbVQ1Bon:nAt,02],"@E 999,999,999.99")) , ;
		aVQ1Bon[oLbVQ1Bon:nAt,03] ,;
		aVQ1Bon[oLbVQ1Bon:nAt,04] ,;
		aVQ1Bon[oLbVQ1Bon:nAt,05] ,;
		aVQ1Bon[oLbVQ1Bon:nAt,06] ,;
		aVQ1Bon[oLbVQ1Bon:nAt,07] }}
	oLbVQ1Bon:bLDblClick := { || VM2000011_Visualizar( aVQ1Bon[oLbVQ1Bon:nAt,03] , aVQ1Bon[oLbVQ1Bon:nAt,04] ) }
	//
	// ----------------- //
	// H I S T O R I C O //
	// ----------------- //
	oTScroll3 := TScrollBox():New( oFoldVM200:aDialogs[3] , 01 , 01 , 10 , 140 , .t. , , .t. )
	oTScroll3:Align := CONTROL_ALIGN_LEFT 	

	oPanF3_1 := tPanel():Create( oFoldVM200:aDialogs[3],01,01,,,.F.,,,,100,90)
	oPanF3_1:Align := CONTROL_ALIGN_ALLCLIENT
	oPanF3_2 := tPanel():Create( oFoldVM200:aDialogs[3],01,01,,,.F.,,,,100,90)
	oPanF3_2:Align := CONTROL_ALIGN_BOTTOM

	oPanF3_1_2 := tPanel():Create( oPanF3_1,01,01,,,.F.,,,,100,90)
	oPanF3_1_2:Align := CONTROL_ALIGN_ALLCLIENT

	//oPanF3_1_3 := tPanel():Create( oPanF3_1,01,01,,,.F.,,,,100,17)
	//oPanF3_1_3:Align := CONTROL_ALIGN_BOTTOM
	//oPanF3_1_3:ReadClientCoors()

	@ 002 , 035 SAY UPPER(STR0026) SIZE 100,8 OF oTScroll3 PIXEL COLOR CLR_HBLUE // Filtrar Historicos

	@ 019 , 002 SAY (STR0006+":") SIZE 55,8 OF oTScroll3 PIXEL COLOR CLR_BLUE // NF
	@ 018 , 025 MSGET o3NumNFI VAR c3NumNFI F3 "SF2" PICTURE "@!" SIZE 54,08 OF oTScroll3 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 018 , 081 MSGET o3SerNFI VAR c3SerNFI PICTURE "@!" SIZE 10,08 OF oTScroll3 PIXEL COLOR CLR_BLACK
	@ 031 , 002 SAY (STR0028+":") SIZE 55,8 OF oTScroll3 PIXEL COLOR CLR_BLUE // Tipo
	@ 030 , 025 MSCOMBOBOX o3TipTPR VAR c3TipTPR SIZE 77,08 ITEMS a3TipTPR OF oTScroll3 PIXEL COLOR CLR_BLUE
	@ 043 , 002 SAY (STR0008+":") SIZE 55,8 OF oTScroll3 PIXEL COLOR CLR_BLUE // Periodo
	@ 042 , 025 MSGET o3DatIni VAR d3DatIni PICTURE "@D" SIZE 43,08 OF oTScroll3 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 043 , 069 SAY (STR0009) SIZE 25,8 OF oTScroll3 PIXEL COLOR CLR_BLUE // ate
	@ 042 , 081 MSGET o3DatFin VAR d3DatFin PICTURE "@D" SIZE 43,08 OF oTScroll3 PIXEL HASBUTTON COLOR CLR_BLACK
	@ 055 , 002 SAY (STR0010+":") SIZE 55,8 OF oTScroll3 PIXEL COLOR CLR_BLUE // Pedido
	@ 054 , 025 MSGET o3NumPed VAR c3NumPed PICTURE "@!" SIZE 54,08 OF oTScroll3 PIXEL COLOR CLR_BLACK
	@ 067 , 002 SAY (STR0033+":") SIZE 55,8 OF oTScroll3 PIXEL COLOR CLR_BLUE // Retorno
	@ 066 , 025 MSGET o3Return VAR c3Return PICTURE "@!" SIZE 54,08 OF oTScroll3 PIXEL COLOR CLR_BLACK

	@ 087 , 032 BUTTON o3Filtro PROMPT STR0011 OF oTScroll3 SIZE 60,09 PIXEL ACTION ( FS_LEVANTA("VQ4",.t.,1) , FS_LEVANTA("VQ4His",.t.,oLbVQ4:nAt) ) // Filtrar
    //
	@ 001 , 001 LISTBOX oLbVQ4 ;
		FIELDS ;
		HEADER STR0012,STR0006,STR0014,STR0029,STR0030, STR0043, STR0003 ;
		COLSIZES 60,40,20,40,40,40,350 ;
		SIZE 50 , 50  ;
		OF oPanF3_1_2 PIXEL ;
		ON CHANGE ( FS_LEVANTA("VQ4His",.t.,oLbVQ4:nAt) )
	oLbVQ4:Align := CONTROL_ALIGN_ALLCLIENT	
	oLbVQ4:SetArray(aVQ4)
	oLbVQ4:bLine := { || {	aVQ4[oLbVQ4:nAt,01] , aVQ4[oLbVQ4:nAt,02] , aVQ4[oLbVQ4:nAt,03] , FG_AlinVlrs(Transform(aVQ4[oLbVQ4:nAt,04],"@E 999,999,999.99")) , FG_AlinVlrs(Transform(aVQ4[oLbVQ4:nAt,05],"@E 999,999,999.99")),FG_AlinVlrs(Transform(aVQ4[oLbVQ4:nAt,07],"@E 999,999,999.99")) ,aVQ4[oLbVQ4:nAt,06] }}
	//
	@ 001 , 001 LISTBOX oLbVQ4His ;
		FIELDS ;
		HEADER STR0013,STR0027,STR0028,STR0010,STR0016,STR0033,STR0032,STR0031 ;
		COLSIZES 40,50,50,50,60,50,70,140 ;
		SIZE 50 , 50 ;
		OF oPanF3_2 PIXEL
	oLbVQ4His:Align := CONTROL_ALIGN_ALLCLIENT
	oLbVQ4His:SetArray(aVQ4His)
	oLbVQ4His:bLine := { || { ;
		Transform(stod(aVQ4His[oLbVQ4His:nAt,01]),"@D") , ;
		IIf(!Empty(aVQ4His[oLbVQ4His:nAt,02]),X3CBOXDESC("VQ4_TIPREG",aVQ4His[oLbVQ4His:nAt,02]),"") , ;
		IIf(!Empty(aVQ4His[oLbVQ4His:nAt,03]),X3CBOXDESC("VQ4_TIPNFI",aVQ4His[oLbVQ4His:nAt,03]),"") , ;
		aVQ4His[oLbVQ4His:nAt,04] , ;
		aVQ4His[oLbVQ4His:nAt,05] , ;
		aVQ4His[oLbVQ4His:nAt,08] , ;
		aVQ4His[oLbVQ4His:nAt,07] , ;
		aVQ4His[oLbVQ4His:nAt,06] }}
	oLbVQ4His:bLDblClick := { || VM2000011_Visualizar( aVQ4His[oLbVQ4His:nAt,04] , aVQ4His[oLbVQ4His:nAt,05] ) }
	//
ACTIVATE MSDIALOG oVEIVM200 ON INIT EnchoiceBar(oVEIVM200,{|| oVEIVM200:End() , .f. },{|| oVEIVM200:End() },, @aButtons )
//
SetKey(VK_F12,Nil)
//
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_LEVANTA≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 15/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Levanta registros                                           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_LEVANTA(cTp,lRefresh,nLinha)

Local cQuery     := ""
Local cQAlSQL    := "ALIASSQL"
Local cQAlAUX    := "ALIASAUX"
Local cFilSF2    := ""
Local cFilVQ1    := xFilial("VQ1")
Local cFilVQ4    := xFilial("VQ4")
Local cAux       := ""
Local cBkpFilAnt := cFilAnt
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local nCont      := 0
Local cQuebraFil := "INICIAL"
//
Local cNamSF2    := RetSQLName("SF2")
Local cNamVV0    := RetSQLName("VV0")
Local cNamSA1    := RetSQLName("SA1")
Local cNamSD2    := RetSQLName("SD2")
Local cNamSB1    := RetSQLName("SB1")
Local cNamVV1    := RetSQLName("VV1")
Local cNamVV2    := RetSQLName("VV2")
Local cNamVVC    := RetSQLName("VVC")
Local cNamVQ0    := RetSQLName("VQ0")
Local cNamVQ1    := RetSQLName("VQ1")
Local cNamVQ4    := RetSQLName("VQ4")

//
&("a"+cTp) := {} // Limpar vetor
//

Do Case 


	Case cTp == "SF2" // NFs de Venda - Exclusivo por Filial
		//
		For nCont := 1 to Len(aSM0)
        	//
			cFilAnt := aSM0[nCont]
            //
            cFilSF2 := xFilial("SF2")
            If ( cQuebraFil == cFilSF2 ) .or. ( !Empty(c1FilNFI) .and. c1FilNFI <> cFilSF2 )
           		Loop
            EndIf
            cQuebraFil := cFilSF2
			cFilVQ4 := xFilial("VQ4")
            //
			cQuery := "SELECT DISTINCT SF2.F2_FILIAL , SF2.F2_EMISSAO , SF2.F2_DOC  , "+FGX_MILSNF("SF2", 3,"F2_SERIE")+" , SF2.F2_SERIE , SF2.F2_VALBRUT , SF2.F2_CLIENTE , SF2.F2_LOJA , SA1.A1_NOME "
			cQuery += "FROM "+cNamSF2+" SF2 "
			cQuery += "JOIN "+cNamVV0+" VV0 ON ( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_NUMNFI=SF2.F2_DOC AND VV0.VV0_SERNFI=SF2.F2_SERIE AND VV0.VV0_OPEMOV='0' AND VV0.VV0_TIPFAT='0' AND VV0.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamSA1+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamSD2+" SD2 ON ( SD2.D2_FILIAL=SF2.F2_FILIAL AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE AND SD2.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVV1+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=SB1.B1_CODITE AND VV1.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVQ0+" VQ0 ON ( VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0.VQ0_CHAINT=VV1.VV1_CHAINT AND VQ0.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE SF2.F2_FILIAL='"+cFilSF2+"' AND "
			If !Empty(c1NumNFI)
				cQuery += "SF2.F2_DOC='"+c1NumNFI+"' AND "
			EndIf
			If !Empty(c1SerNFI)
				cQuery += "SF2.F2_SERIE LIKE '"+c1SerNFI+"%' AND "
			EndIf
			If !Empty(c1CodCli)
				cQuery += "SF2.F2_CLIENTE='"+c1CodCli+"' AND "
			EndIf
			If !Empty(c1LojCli)
				cQuery += "SF2.F2_LOJA='"+c1LojCli+"' AND "
			EndIf
			cQuery += "SF2.F2_PREFORI='"+GetMv("MV_PREFVEI")+"' AND "
			cQuery += "SF2.F2_EMISSAO>='"+dtos(d1DatIni)+"' AND SF2.F2_EMISSAO<='"+dtos(d1DatFin)+"' AND "
			If !Empty(c1NumPed)
				cQuery += "VQ0.VQ0_NUMPED='"+c1NumPed+"' AND "
			EndIf
			cQuery += "SF2.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY SF2.F2_FILIAL , SF2.F2_EMISSAO , SF2.F2_DOC , SF2.F2_SERIE "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				aAdd(aSF2,{ .f. , "0" , ( cQAlSQL )->( F2_FILIAL ) , ( cQAlSQL )->( F2_EMISSAO ) , ( cQAlSQL )->( F2_DOC ) , ( cQAlSQL )->( F2_SERIE ) , ( cQAlSQL )->( F2_VALBRUT ) , ( cQAlSQL )->( F2_CLIENTE )+"-"+( cQAlSQL )->( F2_LOJA )+" "+( cQAlSQL )->( A1_NOME ) , cFilAnt })
				cQuery := "SELECT VQ4.R_E_C_N_O_ RECVQ4 FROM "+cNamVQ4+" VQ4 WHERE VQ4.VQ4_FILIAL='"+cFilVQ4+"' AND "
				cQuery += "VQ4.VQ4_FILNFI='"+( cQAlSQL )->( F2_FILIAL )+"' AND VQ4.VQ4_NUMNFI='"+( cQAlSQL )->( F2_DOC )+"' AND VQ4.VQ4_SERNFI='"+( cQAlSQL )->( F2_SERIE )+"' AND VQ4.D_E_L_E_T_=' ' "
				If FM_SQL(cQuery) > 0
					aSF2[len(aSF2),2] := "1"
				EndIf
				( cQAlSQL )->( DbSkip() )
			EndDo
			( cQAlSQL )->( DbCloseArea() )
			//
		Next
		//
		cFilAnt := cBkpFilAnt
		//
		If Len(aSF2) <= 0
			aAdd(aSF2,{.f.,"X","","","","",0,"",""})
		EndIf
		If lRefresh
			oLbSF2:nAt := 1
			oLbSF2:SetArray(aSF2)
			oLbSF2:bLine := { || { IIf(aSF2[oLbSF2:nAt,01],oLBTIK,oLBNO) , &("o"+aSF2[oLbSF2:nAt,02]) , aSF2[oLbSF2:nAt,03] , Transform(stod(aSF2[oLbSF2:nAt,04]),"@D") , aSF2[oLbSF2:nAt,05] , aSF2[oLbSF2:nAt,06] , FG_AlinVlrs(Transform(aSF2[oLbSF2:nAt,07],"@E 999,999,999.99")) , aSF2[oLbSF2:nAt,08] }}
			oLbSF2:SetFocus()
			oLbSF2:Refresh()
		EndIf

	Case cTp == "SF2Vei" // Veiculos da NF - Exclusivo por Filial

		If nLinha > 0 .and. !Empty(aSF2[nLinha,len(aSF2[nLinha])])
			cFilAnt := aSF2[nLinha,len(aSF2[nLinha])]
			cQuery := "SELECT VQ0.VQ0_NUMPED , SD2.D2_TOTAL , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VVC.VVC_DESCRI "
			cQuery += "FROM "+cNamSD2+" SD2 "
			cQuery += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVV1+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=SB1.B1_CODITE AND VV1.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVQ0+" VQ0 ON ( VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0.VQ0_CHAINT=VV1.VV1_CHAINT AND VQ0.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVV2+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVVC+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE SD2.D2_FILIAL='"+aSF2[nLinha,3]+"' AND SD2.D2_DOC='"+aSF2[nLinha,5]+"' AND SD2.D2_SERIE='"+aSF2[nLinha,6]+"' AND SD2.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				aAdd(aSF2Vei,{ ( cQAlSQL )->( D2_TOTAL ) , ( cQAlSQL )->( VQ0_NUMPED ) , ( cQAlSQL )->( VV1_CHASSI ) , ( cQAlSQL )->( VV1_CODMAR ) , Alltrim(( cQAlSQL )->( VV1_MODVEI ))+" - "+( cQAlSQL )->( VV2_DESMOD ) ,  Alltrim(( cQAlSQL )->( VV1_CORVEI ))+" - "+( cQAlSQL )->( VVC_DESCRI ) })
				( cQAlSQL )->( DbSkip() )
			EndDo
			( cQAlSQL )->( DbCloseArea() )
			cFilAnt := cBkpFilAnt
		EndIf
		If Len(aSF2Vei) <= 0
			aAdd(aSF2Vei,{0,"","","","",""})
		EndIf
		If lRefresh
			oLbSF2Vei:nAt := 1
			oLbSF2Vei:SetArray(aSF2Vei)
			oLbSF2Vei:bLine := { || { FG_AlinVlrs(Transform(aSF2Vei[oLbSF2Vei:nAt,01],"@E 999,999,999.99")) , aSF2Vei[oLbSF2Vei:nAt,02] , aSF2Vei[oLbSF2Vei:nAt,03] , aSF2Vei[oLbSF2Vei:nAt,04] , aSF2Vei[oLbSF2Vei:nAt,05] , aSF2Vei[oLbSF2Vei:nAt,06] }}
			oLbSF2Vei:Refresh()
		EndIf

	Case cTp == "VQ1" // NFs de Bonus do Veiculo - Compartilhado nas Filiais

		cQuery := "SELECT DISTINCT VQ1.VQ1_FILNFI , VQ1.VQ1_DATNFI , VQ1.VQ1_NUMNFI , VQ1.VQ1_SERNFI , VQ1.VQ1_RETUID , SF2.F2_VALBRUT , SF2.F2_CLIENTE , SF2.F2_LOJA , SA1.A1_NOME "
		cQuery += "FROM "+cNamVQ0+" VQ0 "
		cQuery += "JOIN "+cNamVQ1+" VQ1 ON ( VQ1.VQ1_FILIAL=VQ0.VQ0_FILIAL AND VQ1.VQ1_CODIGO=VQ0.VQ0_CODIGO AND VQ1.VQ1_STATUS='3' AND VQ1.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+cNamSF2+" SF2 ON ( SF2.F2_FILIAL=VQ1.VQ1_FILNFI AND SF2.F2_DOC=VQ1.VQ1_NUMNFI AND SF2.F2_SERIE=VQ1.VQ1_SERNFI AND SF2.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+cNamSA1+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"' AND "
		If !Empty(c2NumPed)
			cQuery += "VQ0.VQ0_NUMPED='"+c2NumPed+"' AND "
		EndIf
		If !Empty(c2NumNFI)
			cQuery += "VQ1.VQ1_NUMNFI='"+c2NumNFI+"' AND "
		EndIf
		If !Empty(c2SerNFI)
			cQuery += "VQ1.VQ1_SERNFI LIKE '"+c2SerNFI+"%' AND "
		EndIf
		If !Empty(c2Retorn)
			cQuery += "VQ1.VQ1_RETUID='"+c2Retorn+"' AND "
		EndIf
		If !Empty(c2CodCli)
			cQuery += "SF2.F2_CLIENTE='"+c2CodCli+"' AND "
		EndIf
		If !Empty(c2LojCli)
			cQuery += "SF2.F2_LOJA='"+c2LojCli+"' AND "
		EndIf
		cQuery += "SF2.F2_EMISSAO>='"+dtos(d2DatIni)+"' AND SF2.F2_EMISSAO<='"+dtos(d2DatFin)+"' AND "
		cQuery += "VQ0.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY VQ1.VQ1_FILNFI , VQ1.VQ1_DATNFI , VQ1.VQ1_NUMNFI , VQ1.VQ1_SERNFI "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			aAdd(aVQ1,{ .f. , "0" , ( cQAlSQL )->( VQ1_FILNFI ) , ( cQAlSQL )->( VQ1_DATNFI ) , ( cQAlSQL )->( VQ1_NUMNFI ) , ( cQAlSQL )->( VQ1_SERNFI ) , ( cQAlSQL )->( F2_VALBRUT ) , ( cQAlSQL )->( F2_CLIENTE )+"-"+( cQAlSQL )->( F2_LOJA )+" "+( cQAlSQL )->( A1_NOME ) , ( cQAlSQL )->( VQ1_RETUID ) })
			cQuery := "SELECT VQ4.R_E_C_N_O_ RECVQ4 FROM "+cNamVQ4+" VQ4 WHERE VQ4.VQ4_FILIAL='"+cFilVQ4+"' AND "
			cQuery += "VQ4.VQ4_FILNFI='"+( cQAlSQL )->( VQ1_FILNFI )+"' AND VQ4.VQ4_NUMNFI='"+( cQAlSQL )->( VQ1_NUMNFI )+"' AND VQ4.VQ4_SERNFI='"+( cQAlSQL )->( VQ1_SERNFI )+"' AND VQ4.D_E_L_E_T_=' ' "
			If FM_SQL(cQuery) > 0
				aVQ1[len(aVQ1),2] := "1"
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo	
		( cQAlSQL )->( DbCloseArea() )
		If Len(aVQ1) <= 0
			aAdd(aVQ1,{.f.,"X","","","","",0,"",""})
		EndIf
		If lRefresh
			oLbVQ1:nAt := 1
			oLbVQ1:SetArray(aVQ1)
			oLbVQ1:bLine := { || { IIf(aVQ1[oLbVQ1:nAt,01],oLBTIK,oLBNO) , &("o"+aVQ1[oLbVQ1:nAt,02]) , aVQ1[oLbVQ1:nAt,03] , Transform(stod(aVQ1[oLbVQ1:nAt,04]),"@D") , aVQ1[oLbVQ1:nAt,05] , aVQ1[oLbVQ1:nAt,06] , FG_AlinVlrs(Transform(aVQ1[oLbVQ1:nAt,07],"@E 999,999,999.99")) , aVQ1[oLbVQ1:nAt,08] , aVQ1[oLbVQ1:nAt,09] }}
			oLbVQ1:SetFocus()
			oLbVQ1:Refresh()
		EndIf

	Case cTp == "VQ1Bon" // Bonus referente a NF - Compartilhado nas Filiais

		If nLinha > 0
			cQuery := "SELECT VQ1.VQ1_CODBON , VQ1.VQ1_VLRTOT , VQ0.VQ0_NUMPED , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VVC.VVC_DESCRI "
			cQuery += "FROM "+cNamVQ1+" VQ1 "
			cQuery += "JOIN "+cNamVQ0+" VQ0 ON ( VQ0.VQ0_FILIAL=VQ1.VQ1_FILIAL AND VQ0.VQ0_CODIGO=VQ1.VQ1_CODIGO AND VQ0.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVV1+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VQ0.VQ0_CHAINT AND VV1.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVV2+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVVC+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VQ1.VQ1_FILNFI='"+aVQ1[nLinha,3]+"' AND VQ1.VQ1_NUMNFI='"+aVQ1[nLinha,5]+"' AND VQ1.VQ1_SERNFI='"+aVQ1[nLinha,6]+"' AND VQ1.VQ1_STATUS='3' AND VQ1.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				aAdd(aVQ1Bon,{ ( cQAlSQL )->( VQ1_CODBON ) , ( cQAlSQL )->( VQ1_VLRTOT ) , ( cQAlSQL )->( VQ0_NUMPED ) , ( cQAlSQL )->( VV1_CHASSI ) , ( cQAlSQL )->( VV1_CODMAR ) , Alltrim(( cQAlSQL )->( VV1_MODVEI ))+" - "+( cQAlSQL )->( VV2_DESMOD ) ,  Alltrim(( cQAlSQL )->( VV1_CORVEI ))+" - "+( cQAlSQL )->( VVC_DESCRI ) })
				( cQAlSQL )->( DbSkip() )
			EndDo	
			( cQAlSQL )->( DbCloseArea() )
		EndIf
		If Len(aVQ1Bon) <= 0
			aAdd(aVQ1Bon,{"",0,"","","","",""})
		EndIf
		If lRefresh
			oLbVQ1Bon:nAt := 1
			oLbVQ1Bon:SetArray(aVQ1Bon)
			oLbVQ1Bon:bLine := { || { aVQ1Bon[oLbVQ1Bon:nAt,01] , FG_AlinVlrs(Transform(aVQ1Bon[oLbVQ1Bon:nAt,02],"@E 999,999,999.99")) , aVQ1Bon[oLbVQ1Bon:nAt,03] , aVQ1Bon[oLbVQ1Bon:nAt,04] , aVQ1Bon[oLbVQ1Bon:nAt,05] , aVQ1Bon[oLbVQ1Bon:nAt,06] , aVQ1Bon[oLbVQ1Bon:nAt,07] }}
			oLbVQ1Bon:Refresh()
		EndIf

	Case cTp == "VQ4" // Historico do Pedido ( NFs ) - Compartilhado nas Filiais

		cQuery := "SELECT VQ4.VQ4_FILNFI , VQ4.VQ4_NUMNFI , VQ4.VQ4_SERNFI , VQ4.VQ4_VLRTOT , VQ4.VQ4_VLRLIQ , VQ4.VQ4_RETUID, "
		cQuery += "(SF2.F2_VALBRUT-(SF2.F2_VALPIS+SF2.F2_VALCOFI+SF2.F2_VALIRRF)) VLR_LIQUIDO_RET  "
		cQuery += "FROM "+cNamVQ4+" VQ4 "
		cQuery += "LEFT JOIN "+cNamSF2+" SF2 "
		cQuery += "ON VQ4.VQ4_NUMNFI = SF2.F2_DOC "
		cQuery += "AND VQ4.VQ4_SERNFI = SF2.F2_SERIE "
		cQuery += "AND VQ4_FILNFI = SF2.F2_FILIAL "
		cQuery += "WHERE VQ4.VQ4_FILIAL='"+cFilVQ4+"' AND "
		If !Empty(c3TipTPR)
			cQuery += "VQ4.VQ4_TIPREG='"+c3TipTPR+"' AND "
		EndIf
		If !Empty(c3NumPed)
			cQuery += "VQ4.VQ4_NUMPED='"+c3NumPed+"' AND "
		EndIf
		If !Empty(c3NumNFI)
			cQuery += "VQ4.VQ4_NUMNFI='"+c3NumNFI+"' AND "
		EndIf
		If !Empty(c3SerNFI)
			cQuery += "VQ4."+FGX_MILSNF("VQ4", 3, "VQ4_SERNFI")+"='"+c3SerNFI+"' AND "
		EndIf
		If !Empty(c3Return)
			cQuery += "VQ4.VQ4_RETUID='"+c3Return+"' AND "
		EndIf
		cQuery += "VQ4.VQ4_DATREG>='"+dtos(d3DatIni)+"' AND VQ4.VQ4_DATREG<='"+dtos(d3DatFin)+"' AND "
		cQuery += "VQ4.D_E_L_E_T_=' '  ORDER BY VQ4.VQ4_FILNFI , VQ4.VQ4_NUMNFI , VQ4.VQ4_SERNFI"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			If cAux <> ( cQAlSQL )->( VQ4_FILNFI )+( cQAlSQL )->( VQ4_NUMNFI )+( cQAlSQL )->( VQ4_SERNFI )
				cAux := ( cQAlSQL )->( VQ4_FILNFI )+( cQAlSQL )->( VQ4_NUMNFI )+( cQAlSQL )->( VQ4_SERNFI )
				aAdd(aVQ4,{	( cQAlSQL )->( VQ4_FILNFI ) , ( cQAlSQL )->( VQ4_NUMNFI ) , ( cQAlSQL )->( VQ4_SERNFI ) , ( cQAlSQL )->( VQ4_VLRTOT ) , ( cQAlSQL )->( VQ4_VLRLIQ ) , "" , ( cQAlSQL )->( VLR_LIQUIDO_RET )})
			EndIf
			If !( "..." $ aVQ4[len(aVQ4),6] )
				cQuery := "SELECT DISTINCT VQ1.VQ1_NUMNFI , VQ1.VQ1_SERNFI "
				cQuery += "FROM "+cNamVQ1+" VQ1 "
				cQuery += "WHERE VQ1.VQ1_FILIAL='"+cFilVQ1+"' AND VQ1.VQ1_RETUID='"+( cQAlSQL )->( VQ4_RETUID )+"' AND VQ1.VQ1_NUMNFI<>' ' AND VQ1.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAUX , .F., .T. )
				While !( cQAlAUX )->( Eof() )
					If !( Alltrim(( cQAlAUX )->( VQ1_NUMNFI ))+"-"+Alltrim( FGX_UFSNF(( cQAlAUX )->( VQ1_SERNFI )) ) $ aVQ4[len(aVQ4),6] )
						If !Empty(aVQ4[len(aVQ4),6])
							aVQ4[len(aVQ4),6] +=  " / "
						EndIf
						aVQ4[len(aVQ4),6] += Alltrim(( cQAlAUX )->( VQ1_NUMNFI ))+"-"+Alltrim( FGX_UFSNF(( cQAlAUX )->( VQ1_SERNFI )) )
					EndIf
					If len(aVQ4[len(aVQ4),6]) > 100
						aVQ4[len(aVQ4),6] +=  " / ..."
						Exit
					EndIf 
					( cQAlAUX )->( DbSkip() )
				EndDo
				( cQAlAUX )->( DbCloseArea() )
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo	
		( cQAlSQL )->( DbCloseArea() )
		If Len(aVQ4) <= 0
			aAdd(aVQ4,{"","","",0,0,"",0})
		EndIf
		If lRefresh
			oLbVQ4:nAt := 1
			oLbVQ4:SetArray(aVQ4)
			oLbVQ4:bLine := { || {	aVQ4[oLbVQ4:nAt,01] , aVQ4[oLbVQ4:nAt,02] , aVQ4[oLbVQ4:nAt,03] , FG_AlinVlrs(Transform(aVQ4[oLbVQ4:nAt,04],"@E 999,999,999.99")) , FG_AlinVlrs(Transform(aVQ4[oLbVQ4:nAt,05],"@E 999,999,999.99")) ,FG_AlinVlrs(Transform(aVQ4[oLbVQ4:nAt,07],"@E 999,999,999.99")), aVQ4[oLbVQ4:nAt,06] }}
			oLbVQ4:Refresh()
        EndIf


	Case cTp == "VQ4His" // Historico do Pedido referente a NF selecionada - Compartilhado nas Filiais

		If nLinha > 0
			cQuery := "SELECT VQ4.VQ4_DATREG , VQ4.VQ4_TIPREG , VQ4.VQ4_TIPNFI , VQ4.VQ4_NUMPED , "
			cQuery += "VQ4.VQ4_CHASSI , VQ4.VQ4_OBSERV , VQ4.VQ4_CIACGC , VQ4.VQ4_RETUID "
			cQuery += "FROM "+cNamVQ4+" VQ4 "
			cQuery += "WHERE VQ4.VQ4_FILIAL='"+cFilVQ4+"' AND "
			If !Empty(c3TipTPR)
				cQuery += "VQ4.VQ4_TIPREG='"+c3TipTPR+"' AND "
			EndIf
			If !Empty(c3NumPed)
				cQuery += "VQ4.VQ4_NUMPED='"+c3NumPed+"' AND "
			EndIf
			cQuery += "VQ4.VQ4_FILNFI='"+aVQ4[nLinha,1]+"' AND "
			cQuery += "VQ4.VQ4_NUMNFI='"+aVQ4[nLinha,2]+"' AND "
			cQuery += "VQ4.VQ4_SERNFI='"+aVQ4[nLinha,3]+"' AND "
			If !Empty(c3Return)
				cQuery += "VQ4.VQ4_RETUID='"+c3Return+"' AND "
			EndIf
			cQuery += "VQ4.VQ4_DATREG>='"+dtos(d3DatIni)+"' AND VQ4.VQ4_DATREG<='"+dtos(d3DatFin)+"' AND "
			cQuery += "VQ4.D_E_L_E_T_=' ' ORDER BY VQ4.VQ4_CODIGO"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				aAdd(aVQ4His,{	( cQAlSQL )->( VQ4_DATREG ) , ( cQAlSQL )->( VQ4_TIPREG ) , ( cQAlSQL )->( VQ4_TIPNFI ) , ( cQAlSQL )->( VQ4_NUMPED ) ,;
							( cQAlSQL )->( VQ4_CHASSI ) , ( cQAlSQL )->( VQ4_OBSERV ) , ( cQAlSQL )->( VQ4_CIACGC ) , ( cQAlSQL )->( VQ4_RETUID ) })
				( cQAlSQL )->( DbSkip() )
			EndDo	
			( cQAlSQL )->( DbCloseArea() )
		EndIf
		If Len(aVQ4His) <= 0
			aAdd(aVQ4His,{"","","","","","","",""})
		EndIf
		If lRefresh
			oLbVQ4His:nAt := 1
			oLbVQ4His:SetArray(aVQ4His)
			oLbVQ4His:bLine := { || { Transform(stod(aVQ4His[oLbVQ4His:nAt,01]),"@D") , IIf(!Empty(aVQ4His[oLbVQ4His:nAt,02]),X3CBOXDESC("VQ4_TIPREG",aVQ4His[oLbVQ4His:nAt,02]),"") , IIf(!Empty(aVQ4His[oLbVQ4His:nAt,03]),X3CBOXDESC("VQ4_TIPNFI",aVQ4His[oLbVQ4His:nAt,03]),"") , ;
									aVQ4His[oLbVQ4His:nAt,04] , aVQ4His[oLbVQ4His:nAt,05] , aVQ4His[oLbVQ4His:nAt,08] , aVQ4His[oLbVQ4His:nAt,07] , aVQ4His[oLbVQ4His:nAt,06] }}
			oLbVQ4His:Refresh()
        EndIf

EndCase
Return(.t.) 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_XML    ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 28/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ XML ( 1 - Envia Vendas / 2 - Envia Bonus / 3 - Recepcao )   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_XML(nTp)
Local aObjects  := {} , aPos := {} , aInfo := {} 
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cStr      := ""
Local ni        := 0 
Local nj        := 0 
Local ny        := 0
Local lCriaVQ4  := .f.
Local aGravVQ4  := {} 
Local cNamVQ0   := RetSQLName("VQ0")
Local cNamVQ1   := RetSQLName("VQ1")
Local cNamVQ4   := RetSQLName("VQ4")
Local cNamSB1   := RetSQLName("SB1")
Local cNamVV1   := RetSQLName("VV1")
Local cNamVV2   := RetSQLName("VV2")
Local cNamVVC   := RetSQLName("VVC")
Local cNamSD2   := RetSQLName("SD2")
Local cFilVQ0   := xFilial("VQ0")
Local cFilVQ4   := xFilial("VQ4")
Local cFilVV1   := xFilial("VV1")
Local cFilSA1   := xFilial("SA1")
Local cFilSA3   := xFilial("SA3")
Local cQuery    := ""
Local cQuery1   := ""
Local cQuery2   := ""
Local cQuery3   := ""
Local cQAlSQL   := "ALIASSQL"
Local cChassi   := ""
Local cDealer   := ""
Local cCNPJ     := ""
Local cRetID    := ""
Local dData     := ctod("")
Local nBruto    := 0
Local nLiq      := 0
Local cNF       := ""
Local cSer      := ""
Local cFil      := ""
Local nTam      := 0
Local aNFEnv    := {}
Local lMarcarNFE := .t.
Local cBkpFilAnt := cFilAnt
Local aFiles    := {}
Local cExtFile  := ""
Local lVQ4_NXML := ( VQ4->(FieldPos("VQ4_NXMLAT")) > 0 )
Local cCodVQ4   := ""
Local nTamVQ4   := GeTSX3Cache("VQ4_CODIGO","X3_TAMANHO") // Tamanho do Campo VQ4_CODIGO
Local lInd2VQ4  := FwSixUtil():ExistIndex( "VQ4" , "2" ) // Existe o Indice 2 no VQ4 ? ( VQ4_FILIAL + VQ4_CODIGO )
Local lPEValid	:= .T.
//
Pergunte("VEI200",.f.)
If Empty(MV_PAR01) .or. Empty(MV_PAR02)
	Pergunte("VEI200",.t.)
EndIf
//
cDirEnv := Alltrim(MV_PAR01)
if !Empty(cDirEnv) .and. right(cDirEnv,1) <> AllTrim("\ ")
	cDirEnv := cDirEnv+ AllTrim(" \ ")
Endif	
cDirRec := Alltrim(MV_PAR02)
if !Empty(cDirRec) .and. right(cDirRec,1) <> AllTrim("\ ")
	cDirRec := cDirRec+ AllTrim("\ ")
Endif	
//
If nTp == 1 // 1 - Envia NF de Vendas <<<<< PROCESS A >>>>> 

	//PE VM200VLD 
	// deve	retornar .T. para prosseguir com a transmiss„o 
	// ou .F. para interromper o processo
	//CI 010034
	If ExistBlock("VM200VLD")
		lPEValid := ExecBlock("VM200VLD",.f.,.f.,{nTp,aSF2})
		If !lPEValid
			Return()
		EndIf
	EndIf

	For ni := 1 to Len(aSF2)
	if aSF2[ni,1] .and. !Empty(aSF2[ni,len(aSF2[ni])])
			//
			cFilAnt := aSF2[ni,len(aSF2[ni])]
			//
		    dbSelectArea("SF2")                               
			dbSetOrder(1)
			dbSeek(aSF2[ni,03]+aSF2[ni,05]+aSF2[ni,06])
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			dbSelectArea("SA3")
			dbSetOrder(1)
			dbSeek(xFilial("SA3")+SF2->F2_VEND1)
			//
			cQuery := "SELECT VQ0.VQ0_NUMPED , SD2.D2_TOTAL , SD2.D2_VALIMP5 , SD2.D2_VALIMP6 , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VVC.VVC_DESCRI "
			cQuery += "FROM "+cNamSD2+" SD2 "
			cQuery += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD2.D2_COD AND SB1.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+cNamVV1+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=SB1.B1_CODITE AND VV1.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVQ0+" VQ0 ON ( VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0.VQ0_CHAINT=VV1.VV1_CHAINT AND VQ0.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVV2+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+cNamVVC+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE SD2.D2_FILIAL='"+aSF2[ni,3]+"' AND SD2.D2_DOC='"+aSF2[ni,5]+"' AND SD2.D2_SERIE='"+aSF2[ni,6]+"' AND SD2.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				aAdd(aNFEnv,{.t.,ni,SA1->(RecNo()),SA3->(RecNo()),SF2->(RecNo()),( cQAlSQL )->( VQ0_NUMPED ),( cQAlSQL )->( VV1_CHASSI ),( cQAlSQL )->( D2_TOTAL ),( cQAlSQL )->( D2_VALIMP5 ),( cQAlSQL )->( D2_VALIMP6 ),( cQAlSQL )->( VV1_CODMAR ) , Alltrim(( cQAlSQL )->( VV1_MODVEI ))+" - "+( cQAlSQL )->( VV2_DESMOD ) ,  Alltrim(( cQAlSQL )->( VV1_CORVEI ))+" - "+( cQAlSQL )->( VVC_DESCRI ) })
				( cQAlSQL )->( DbSkip() )
			EndDo
			( cQAlSQL )->( DbCloseArea() )
			//
    	Endif
    Next
    //
	cFilAnt := cBkpFilAnt
	//
	if len(aNFEnv) > 0

		// Tela: 75%
		//For ni := 1 to Len(aSizeHalf)
		//	aSizeHalf[ni] := INT(aSizeHalf[ni] * 0.75)
		//Next   
		aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 0, 00, .T. , .T. } ) // ListBox
		aPos := MsObjSize( aInfo, aObjects )

		DEFINE MSDIALOG oSelItem TITLE STR0036 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Deseja transmitir a(s) NF(s) de Venda?

		@ aPos[1,1],aPos[1,2] LISTBOX oNFEnv FIELDS HEADER "",STR0012,STR0006,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019 COLSIZES 10,50,35,20,50,70,25,80,60 SIZE aPos[1,4],aPos[1,3]-aPos[1,1]-2 OF oSelItem PIXEL ON DBLCLICK (aNFEnv[oNFEnv:nAt,01]:=!aNFEnv[oNFEnv:nAt,01])
		oNFEnv:SetArray(aNFEnv)
		oNFEnv:bLine := { || { IIf(aNFEnv[oNFEnv:nAt,01],oLBTIK,oLBNO) , aSF2[aNFEnv[oNFEnv:nAt,02],03] , aSF2[aNFEnv[oNFEnv:nAt,02],05] , aSF2[aNFEnv[oNFEnv:nAt,02],06] , FG_AlinVlrs(Transform(aNFEnv[oNFEnv:nAt,08],"@E 999,999,999.99")) , aNFEnv[oNFEnv:nAt,07] , aNFEnv[oNFEnv:nAt,11] , aNFEnv[oNFEnv:nAt,12] , aNFEnv[oNFEnv:nAt,13] }}
		oNFEnv:bHeaderClick := { |oObj,nCol| IIf( nCol == 1 , ( lMarcarNFE := !lMarcarNFE , aEval( aNFEnv , { |x| x[1] := lMarcarNFE } ) ) ,Nil) , oNFEnv:Refresh() }

		ACTIVATE MSDIALOG oSelItem ON INIT EnchoiceBar(oSelItem,{|| lCriaVQ4 := .t. , oSelItem:End() },{|| oSelItem:End() } )
		
	Endif
	If lCriaVQ4
		nX := 0
		For ni := 1 to Len(aNFEnv)
    		if aNFEnv[ni,1]
				//
			    dbSelectArea("SA1")
				dbGoto(aNFEnv[ni,3])
			    dbSelectArea("SA3")
				dbGoto(aNFEnv[ni,4])
			    dbSelectArea("SF2")
				dbGoto(aNFEnv[ni,5])
				//
				If nX <> aNFEnv[ni,2]
					//
					nX := aNFEnv[ni,2]
					FS_EXMLNF("A",nX,"",aNFEnv) // Envia arquivo
					//
				EndIf
				//
				aAdd(aGravVQ4,{ aNFEnv[ni,6] , "1" , "1" , aSF2[nX,03] , aSF2[nX,05] , aSF2[nX,06] , aNFEnv[ni,8] , aNFEnv[ni,7] , "" , "" , "" , aNFEnv[ni,8] - ( aNFEnv[ni,9] + aNFEnv[ni,10]) , "" , "" })
				//
			Endif
		Next
		If nX <> 0
			MsgInfo(STR0042+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cDirEnv,STR0041) // Arquivo(s) gerado(s)! / Atencao
		EndIf
	EndIf
ElseIf nTp == 2 // 2 - Envia NF de Bonus <<<<< PROCESS I >>>>>

	//PE VM200VLD 
	// deve	retornar .T. para prosseguir com a transmiss„o 
	// ou .F. para interromper o processo
	//CI 010034
	If ExistBlock("VM200VLD")
		lPEValid := ExecBlock("VM200VLD",.f.,.f.,{nTp,aVQ1})
		If !lPEValid
			Return()
		EndIf
	EndIf

	For ni := 1 to Len(aVQ1)
		if aVQ1[ni,1]
			If aVQ1[ni,2] == "0"
	    		cStr += aVQ1[ni,05]+"-"+aVQ1[ni,06]+" "+CHR(13)+CHR(10)
        	Else
	    		cStr += aVQ1[ni,05]+"-"+aVQ1[ni,06]+" ( "+STR0039+" )"+CHR(13)+CHR(10) // re-transmitir
	    	Endif	
    	Endif
    Next
	if !Empty(cStr) .and. Aviso(STR0040,cStr,{STR0037,STR0038},3) == 1 // Deseja transmitir a(s) NF(s) de Comiss„o de Bonus? / OK / Cancelar
		lCriaVQ4 := .t.
	Endif
	If lCriaVQ4
		For ni := 1 to Len(aVQ1)
	    	if aVQ1[ni,1]
	    		//
			    dbSelectArea("SF2")
	    		dbSetOrder(1)
			    dbSeek(aVQ1[ni,03]+aVQ1[ni,05]+aVQ1[ni,06])
			    dbSelectArea("SA1")
			    dbSetOrder(1)
			    dbSeek(cFilSA1+SF2->F2_CLIENTE+SF2->F2_LOJA)
				dbSelectArea("SA3")
				dbSetOrder(1)
				dbSeek(cFilSA3+SF2->F2_VEND1)
				//
			    FS_EXMLNF("I",ni,aVQ1[ni,09]) // Envia arquivo
				//
				cQuery := "SELECT VQ0.VQ0_NUMPED , VV1.VV1_CHASSI , VQ0.VQ0_FILATE , VQ0.VQ0_NUMATE "
				cQuery += "FROM "+cNamVQ1+" VQ1 "
				cQuery += "JOIN "+cNamVQ0+" VQ0 ON ( VQ0.VQ0_FILIAL=VQ1.VQ1_FILIAL AND VQ0.VQ0_CODIGO=VQ1.VQ1_CODIGO AND VQ0.D_E_L_E_T_=' ' ) "
				cQuery += "LEFT JOIN "+cNamVV1+" VV1 ON ( VV1.VV1_FILIAL='"+cFilVV1+"' AND VV1.VV1_CHAINT=VQ0.VQ0_CHAINT AND VV1.D_E_L_E_T_=' ' ) "
				cQuery += "WHERE VQ1.VQ1_FILNFI='"+aVQ1[ni,3]+"' AND VQ1.VQ1_NUMNFI='"+aVQ1[ni,5]+"' AND VQ1.VQ1_SERNFI='"+aVQ1[ni,6]+"' AND VQ1.VQ1_STATUS='3' AND VQ1.D_E_L_E_T_=' ' "
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
				While !( cQAlSQL )->( Eof() )
					aAdd(aGravVQ4,{ ( cQAlSQL )->( VQ0_NUMPED ) , "1" , "2" , aVQ1[ni,03] , aVQ1[ni,05] , aVQ1[ni,06] , SF2->F2_VALBRUT , ( cQAlSQL )->( VV1_CHASSI ) , "" , "" , aVQ1[ni,09] , SF2->F2_VALBRUT-(SF2->F2_VALIMP5+SF2->F2_VALIMP6+SF2->F2_VALIRRF) , "" , "" })
					( cQAlSQL )->( DbSkip() )
				EndDo	
				( cQAlSQL )->( DbCloseArea() )
				//
			EndIf
		Next
		MsgInfo(STR0042+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cDirEnv,STR0041) // Arquivo(s) gerado(s)! / Atencao
	EndIf
Else // 3 - Recepcao <<<<< PROCESS G >>>>>
	cError   := ""
	cWarning := ""

	// Recepcao NF comissao
	cFile := Alltrim(cDirRec)
	
	For nj := 1 to 2

		If nj == 1 // Retorno OK
			cExtFile := "BRCMAMT"
		Else // Retorno Erro 
			cExtFile := "BRSLERR"
		EndIf

		aFiles := Directory(cFile + "*."+cExtFile)
		For ni := 1 to Len(aFiles)
			cAuxNomeNovo := AllTrim(aFiles[ni,1])
			nPos := AT(cExtFile,cAuxNomeNovo)
			cAuxNomeNovo := cExtFile+SUBSTR(aFiles[ni,1],1,nPos-1)+"XML"
			FRENAME(cFile + aFiles[ni,1], cFile + cAuxNomeNovo )
		Next

		aFiles := Directory(cFile+cExtFile+"*.xml")
	
		For ni := 1 to Len(aFiles)

			// Renomear arquivo XML
			cAuxNomeNovo := AllTrim(aFiles[ni,1])
			nPos := AT("XML",cAuxNomeNovo)
			cNome := SUBSTR(aFiles[ni,1],1,nPos-1)+"XXML"
			cAuxNomeNovo := cNome
			cAuxNomeNovo += "" + StrTran(DtoC(dDataBase),"/","")
			cAuxNomeNovo += "_" + StrTran(Time(),":","")

			oXml := XmlParserFile( cFile+aFiles[ni,1], "_", @cError, @cWarning ) 
			
			If nj == 1 .and. oXml <> NIL .and. XmlChildEx(oXml,"_GRANDTOTAL") <> NIL
				//
				cDealer  := FMX_RETXML( oXml:_GRANDTOTAL:_REGISTER , "_DEALERACCOUNT"   , ""  )  // oXml:_GRANDTOTAL:_REGISTER:_DEALERACCOUNT:Text
				cCNPJ    := FMX_RETXML( oXml:_GRANDTOTAL:_REGISTER , "_JDCNPJ"          , ""  )  // oXml:_GRANDTOTAL:_REGISTER:_JDCNPJ:Text
				cRetID   := FMX_RETXML( oXml:_GRANDTOTAL:_REGISTER , "_RETURNID"        , ""  )  // oXml:_GRANDTOTAL:_REGISTER:_RETURNID:Text
				dData    := FMX_RETXML( oXml:_GRANDTOTAL:_REGISTER , "_COMMISSIONDATE"  , ""  )  // oXml:_GRANDTOTAL:_REGISTER:_COMMISSIONDATE:Text
				
				nVlrB    := FMX_RETXML( oXml:_GRANDTOTAL:_REGISTER , "_BRUTO"           , "0" )
				nPosV    := At(",",nVlrB)
				If nPosV > 0
					nBruto := val(substr(nVlrB,1,nPosV-1)+substr(nVlrB,nPosV+1,2)) / 100         // val(oXml:_GRANDTOTAL:_REGISTER:_BRUTO:Text)
				Else
					nBruto := val(nVlrB)
				EndIf

				nVlrL    := FMX_RETXML( oXml:_GRANDTOTAL:_REGISTER , "_LIQUIDO"         , "0" )
				nPosL    := At(",",nVlrL)
				If nPosL > 0
					nLiq := val(substr(nVlrL,1,nPosL-1)+substr(nVlrL,nPosL+1,2))/100      
				Else
					nLiq := val(nVlrL)
				EndIf

				xTeste := oXml:_GRANDTOTAL:_REGISTER:_DEALERINVOICENUMBER:_INVOICENUMBER
				If valtype(xTeste) == "A" // Array
					nQtd     := len(oXml:_GRANDTOTAL:_REGISTER:_DEALERINVOICENUMBER:_INVOICENUMBER)
		            For ny := 1  to nQtd
						cNF	 := Alltrim(substr(oXml:_GRANDTOTAL:_REGISTER:_DEALERINVOICENUMBER:_INVOICENUMBER[ny]:Text,3,Len(oXml:_GRANDTOTAL:_REGISTER:_DEALERINVOICENUMBER:_INVOICENUMBER[ny]:Text)))
						nTam := At(" ",cNF)
						cSer := substr(cNF,nTam+1)
						cNF  := substr(cNF,1,nTam-1)
						cFil := Alltrim(xFilial("VQ4"))+substr(oXml:_GRANDTOTAL:_REGISTER:_DEALERINVOICENUMBER:_INVOICENUMBER[ny]:Text,1,2)  
						aAdd(aGravVQ4,{ "" , "2" , "2" , cFil , cNF , cSer , nBruto , "" , "OK" , cCNPJ , cRetID , nLiq , cFile + aFiles[ni,1] , cFile + cAuxNomeNovo })
					Next
				Else // valtype(xTeste) == "O"
					nQtd := 0
					cNF	 := Alltrim(substr(oXml:_GRANDTOTAL:_REGISTER:_DEALERINVOICENUMBER:_INVOICENUMBER:Text,3,Len(oXml:_GRANDTOTAL:_REGISTER:_DEALERINVOICENUMBER:_INVOICENUMBER:Text)))
					nTam := At(" ",cNF)
					cSer := substr(cNF,nTam+1)
					cNF  := substr(cNF,1,nTam-1)
					cFil := Alltrim(xFilial("VQ4"))+substr(oXml:_GRANDTOTAL:_REGISTER:_DEALERINVOICENUMBER:_INVOICENUMBER:Text,1,2)  
					aAdd(aGravVQ4,{ "" , "2" , "2" , cFil , cNF , cSer , nBruto , "" , "OK" , cCNPJ , cRetID , nLiq , cFile + aFiles[ni,1] , cFile + cAuxNomeNovo })
				EndIf

				lCriaVQ4 := .t.
		
			ElseIf nj == 2 .and. oXml <> NIL .and. XmlChildEx(oXml,"_ERRORLOG") <> NIL
				//
				
				xTeste := oXml:_ERRORLOG:_ERROR
				If valtype(xTeste) == "A" // Array
					nQtd     := len(oXml:_ERRORLOG:_ERROR)
		            For ny := 1  to nQtd
						cDealer  := FMX_RETXML( oXml:_ERRORLOG:_ERROR[ny]    , "_DEALERACCOUNT"   , ""  ) // oXml:_ERRORLOG:_ERROR:_DEALERACCOUNT:Text
						cNF      := Alltrim(substr(FMX_RETXML(oXml:_ERRORLOG:_ERROR[ny],"_INVOICENUMBER",space(6)),5,Len(FMX_RETXML(oXml:_ERRORLOG:_ERROR[ny],"_INVOICENUMBER",space(6))))) // Alltrim(substr(oXml:_ERRORLOG:_ERROR:_INVOICENUMBER:Text,5,Len(oXml:_ERRORLOG:_ERROR:_INVOICENUMBER:Text)))
						cSer     := substr(FMX_RETXML(oXml:_ERRORLOG:_ERROR[ny],"_INVOICENUMBER",space(3)),1,3) // substr(oXml:_ERRORLOG:_ERROR:_INVOICENUMBER:Text,1,3)
						cChassi  := FMX_RETXML(oXml:_ERRORLOG:_ERROR[ny],"_SERIALNUMBER", "" ) // oXml:_ERRORLOG:_ERROR:_SERIALNUMBER:Text
						cCodErr  := FMX_RETXML(oXml:_ERRORLOG:_ERROR[ny],"_ERRORCODE"   , "" ) // oXml:_ERRORLOG:_ERROR:_ERRORCODE:Text
						cCodDesc := FMX_RETXML(oXml:_ERRORLOG:_ERROR[ny],"_DESCRIPTION" , "" ) // oXml:_ERRORLOG:_ERROR:_DESCRIPTION:Text
					Next
				Else// valtype(xTeste) == "O"
					nQtd := 0
					cDealer  := FMX_RETXML( oXml:_ERRORLOG:_ERROR     , "_DEALERACCOUNT"   , ""  ) // oXml:_ERRORLOG:_ERROR:_DEALERACCOUNT:Text
					cNF      := Alltrim(substr(FMX_RETXML(oXml:_ERRORLOG:_ERROR,"_INVOICENUMBER",space(6)),5,Len(FMX_RETXML(oXml:_ERRORLOG:_ERROR,"_INVOICENUMBER",space(6))))) // Alltrim(substr(oXml:_ERRORLOG:_ERROR:_INVOICENUMBER:Text,5,Len(oXml:_ERRORLOG:_ERROR:_INVOICENUMBER:Text)))
					cSer     := substr(FMX_RETXML(oXml:_ERRORLOG:_ERROR,"_INVOICENUMBER",space(3)),1,3) // substr(oXml:_ERRORLOG:_ERROR:_INVOICENUMBER:Text,1,3)
					cChassi  := FMX_RETXML(oXml:_ERRORLOG:_ERROR,"_SERIALNUMBER", "" ) // oXml:_ERRORLOG:_ERROR:_SERIALNUMBER:Text
					cCodErr  := FMX_RETXML(oXml:_ERRORLOG:_ERROR,"_ERRORCODE"   , "" ) // oXml:_ERRORLOG:_ERROR:_ERRORCODE:Text
					cCodDesc := FMX_RETXML(oXml:_ERRORLOG:_ERROR,"_DESCRIPTION" , "" ) // oXml:_ERRORLOG:_ERROR:_DESCRIPTION:Text
				Endif

				//
				dbSelectArea("VV1")
				dbSetOrder(2)
				dbSeek(xFilial("VV1")+cChassi)
				//
				cQuery1 := "SELECT VQ0.VQ0_NUMPED FROM "+cNamVQ0+" VQ0 WHERE VQ0.VQ0_FILIAL='"+cFilVQ0+"' AND "
				cQuery1 += "VQ0.VQ0_CHAINT='"+VV1->VV1_CHAINT+"' AND VQ0.D_E_L_E_T_=' ' "
			
				cQuery2  := "SELECT VQ4.VQ4_TIPNFI FROM "+cNamVQ4+" VQ4 WHERE VQ4.VQ4_FILIAL='"+cFilVQ4+"' AND "
				cQuery2  += "VQ4.VQ4_NUMNFI='"+cNF+"' AND VQ4.VQ4_SERNFI LIKE '"+cSer+"%' AND VQ4.D_E_L_E_T_=' ' "
				
				cQuery3  := "SELECT VQ4.VQ4_VLRTOT FROM "+cNamVQ4+" VQ4 WHERE VQ4.VQ4_FILIAL='"+cFilVQ4+"' AND "
				cQuery3  += "VQ4.VQ4_NUMNFI='"+cNF+"' AND VQ4.VQ4_SERNFI LIKE '"+cSer+"%' AND VQ4.D_E_L_E_T_=' ' "
				
				aAdd(aGravVQ4,{ FM_SQL(cQuery1) , "2" , strzero(val(FM_SQL(cQuery2))+4,1) , SD2->D2_FILIAL , cNF , cSer , FM_SQL(cQuery3) , cChassi , cCodErr+"-"+cCodDesc , "" , "" , 0 , cFile + aFiles[ni,1] , cFile + cAuxNomeNovo })

				lCriaVQ4 := .t.

		 	Endif

			// Renomear arquivo XML
			FRENAME( cFile + aFiles[ni,1] , cFile + cAuxNomeNovo )

		Next
	
	Next

EndIf
If lCriaVQ4 // Historico
	For ni := 1 to len(aGravVQ4)
		If lInd2VQ4 // Se existir o Indice 2 do VQ4
			cCodVQ4 := GetSXENum("VQ4","VQ4_CODIGO",,2) // Utiliza Funcao PADRAO
			ConfirmSX8()
		Else // Se NAO existir o Indice 2 do VQ4
			cCodVQ4 := Soma1( FM_SQL("SELECT MAX(VQ4_CODIGO) FROM "+cNamVQ4+" WHERE VQ4_FILIAL='"+cFilVQ4+"'") , nTamVQ4 ) // SOMA 1 no MAX
		EndIf
		DbSelectArea("VQ4")
		RecLock("VQ4",.t.)
			VQ4->VQ4_FILIAL := xFilial("VQ4")
			VQ4->VQ4_CODIGO := cCodVQ4
			VQ4->VQ4_DATREG := dDataBase
			VQ4->VQ4_NUMPED := aGravVQ4[ni,01]
			VQ4->VQ4_TIPREG := aGravVQ4[ni,02]
			VQ4->VQ4_TIPNFI := aGravVQ4[ni,03]
			VQ4->VQ4_FILNFI := aGravVQ4[ni,04]
			VQ4->VQ4_NUMNFI := aGravVQ4[ni,05]
			VQ4->VQ4_SERNFI := aGravVQ4[ni,06]
			VQ4->VQ4_VLRTOT := aGravVQ4[ni,07]
			VQ4->VQ4_CHASSI	:= aGravVQ4[ni,08]
			VQ4->VQ4_OBSERV	:= aGravVQ4[ni,09]
			VQ4->VQ4_CIACGC	:= aGravVQ4[ni,10]
			VQ4->VQ4_RETUID := aGravVQ4[ni,11]
			VQ4->VQ4_VLRLIQ	:= aGravVQ4[ni,12]
			If lVQ4_NXML
				VQ4->VQ4_NXMLAN := aGravVQ4[ni,13] // Nome XML Anterior
				VQ4->VQ4_NXMLAT := aGravVQ4[ni,14] // Nome XML Atual
			EndIf
		MsUnLock()
		If !lInd2VQ4 // NAO existe o Indice 2 no VQ4
			VQ4->(dbGoTo(VQ4->(Recno()))) // Desposicionar, para considerar em SELECT no meio da transacao
		EndIf
	Next
	If nTp == 1
		FS_LEVANTA("SF2",.t.,oLbSF2:nAt)
		FS_LEVANTA("SF2Vei",.t.,oLbSF2:nAt)
		FS_LEVANTA("VQ4",.t.,1)
	ElseIf nTp == 2
		FS_LEVANTA("VQ1",.t.,oLbVQ1:nAt)
		FS_LEVANTA("VQ1Bon",.t.,oLbVQ1:nAt)
		FS_LEVANTA("VQ4",.t.,1)
	EndIf
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_EXMLNF≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 15/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Envio de arquivos                                           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_EXMLNF(cTipo,nLin,cRETUID,aNFEnv)
Local aMeses     := {"JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"} // NAO TRADUZIR  <<---
Local ni         := 0
Local cCnt       := ""
Local cDiaRSD    := ""
Local cMesRSD    := ""
Local cAnoRSD    := ""
Local cBkpFilAnt := cFilAnt
Default aNFEnv   := {}

if cTipo == "A" // Envio NF Venda
	cFilAnt := aSF2[nLin,03]
	_DEALER_ACCOUNT := GetMV("MV_MIL0005")
	cFilAnt := cBkpFilAnt
Else
	_DEALER_ACCOUNT := GetMV("MV_MIL0005")
EndIf
////////////////////////////////////////////
// DLR2JD_20xxxx_DDMMMAAAA_HHMMSQ.??????? //
////////////////////////////////////////////
cArquivo := "DLR2JD_"+_DEALER_ACCOUNT+"_"
cArquivo += strzero(day(dDataBase),2)+aMeses[month(dDataBase)]+strzero(year(dDataBase),4)+"_"
cArquivo += strzero(val(substr(time(),1,2)),2)+strzero(val(substr(time(),4,2)),2)
cCnt := "00"

if cTipo == "A" // Envio NF Venda

	For ni := 1 to 9999
		cCnt := Soma1(cCnt,2)
		If !File(Alltrim(cDirEnv)+Alltrim(cArquivo)+cCnt+".BRSLDAT")
			cArquivo += cCnt+".BRSLDAT"
			Exit
		EndIf
	Next
	nHnd := FCREATE(Alltrim(cDirEnv)+Alltrim(cArquivo),0)

	cDia := substr(dtos(ddatabase),7,2)
	cMes := substr(dtos(ddatabase),5,2)
	cAno := substr(dtos(ddatabase),1,4)

	cDiaRSD := substr(aSF2[nLin,04],7,2)
	cMesRSD := substr(aSF2[nLin,04],5,2)
	cAnoRSD := substr(aSF2[nLin,04],1,4)    
	
	cLinha := '<?xml version="1.0" encoding="UTF-8"?>'+CHR(13)+CHR(10)
	cLinha += '<invoice fileCreationDate="'+cAno+"-"+cMes+"-"+cDia+"T"+time()+'">'+CHR(13)+CHR(10)
	cLinha += "<dealerAccount>"+_DEALER_ACCOUNT+"</dealerAccount>"+CHR(13)+CHR(10)     
	cLinha += "<invoiceNumber>"+right(Alltrim(aSF2[nLin,03]),2)+aSF2[nLin,05]+" "+aSF2[nLin,06]+"</invoiceNumber>"+CHR(13)+CHR(10)
	cLinha += "<retailSaleDate>"+cDiaRSD+"/"+cMesRSD+"/"+cAnoRSD+"</retailSaleDate>"+CHR(13)+CHR(10)
	cLinha += "<customerName>"+Alltrim(SA1->A1_NOME)+"</customerName>"+CHR(13)+CHR(10)
	cLinha += "<cpfCnpj>"+Alltrim(SA1->A1_CGC)+"</cpfCnpj>"+CHR(13)+CHR(10)
	cLinha += "<salesmanName>"+Alltrim(SA3->A3_NOME)+"</salesmanName>"+CHR(13)+CHR(10)
	
	For ni := 1 to len(aNFEnv)
		If aNFEnv[ni,1] .and. nLin == aNFEnv[ni,2]
			cLinha += "<product>"+CHR(13)+CHR(10)
			cLinha += "<serialNumber>"+Alltrim(aNFEnv[ni,7])+"</serialNumber>"+CHR(13)+CHR(10)
			cLinha += "<customerPrice>"+Alltrim(str(aNFEnv[ni,8]))+"</customerPrice>"+CHR(13)+CHR(10)
			cLinha += "<opt1></opt1>"+CHR(13)+CHR(10)
			cLinha += "</product>"+CHR(13)+CHR(10)
		EndIf
	Next
	
	cLinha += "<nfopt1/>"+CHR(13)+CHR(10)
	cLinha += "<nfopt2/>"+CHR(13)+CHR(10)
	cLinha += "<nfopt3/>"+CHR(13)+CHR(10)
	cLinha += "</invoice>"+CHR(13)+CHR(10)

Else // Envio NF Bonus

	For ni := 1 to 9999
		cCnt := Soma1(cCnt,2)
		If !File(lower(Alltrim(cDirEnv))+Alltrim(cArquivo)+cCnt+".BRCMDAT")
			cArquivo += cCnt+".BRCMDAT"
			Exit
		EndIf
	Next
	nHnd := FCREATE(lower(Alltrim(cDirEnv))+Alltrim(cArquivo) ,0)
	//
	cLinha := '<?xml version="1.0" encoding="UTF-16"?>'+CHR(13)+CHR(10)
	cLinha += "<commissionInvoice>"+CHR(13)+CHR(10)
	cLinha += "<dealerAccount>"+_DEALER_ACCOUNT+"</dealerAccount>"+CHR(13)+CHR(10)
	cLinha += "<jdCnpj>"+SA1->A1_CGC+"</jdCnpj>"+CHR(13)+CHR(10)
	cLinha += "<returnID>"+cRETUID+"</returnID>"+CHR(13)+CHR(10)
	cLinha += "<invoiceNumber>"+right(Alltrim(aVQ1[nLin,03]),2)+aVQ1[nLin,05]+" "+aVQ1[nLin,06]+"</invoiceNumber>"+CHR(13)+CHR(10)
	cLinha += "<dataNF>"+dtoc(stod(aVQ1[nLin,04]))+"</dataNF>"+CHR(13)+CHR(10)
	cLinha += "<retidoIR>"+Alltrim(str(SF2->F2_VALIRRF))+"</retidoIR>"+CHR(13)+CHR(10)
	cLinha += "<retidoPISCOFINS>"+Alltrim(str(SF2->F2_VALPIS+SF2->F2_VALCOFI))+"</retidoPISCOFINS>"+CHR(13)+CHR(10)
	cLinha += "<bruto>"+Alltrim(str(SF2->F2_VALBRUT))+"</bruto>"+CHR(13)+CHR(10)
	cLinha += "<liquido>"+Alltrim(str(SF2->F2_VALBRUT-(SF2->F2_VALPIS+SF2->F2_VALCOFI+SF2->F2_VALIRRF)))+"</liquido>"+CHR(13)+CHR(10)
	cLinha += "</commissionInvoice>"+CHR(13)+CHR(10)
	//
Endif

fWrite(nHnd,cLinha)
fClose(nHnd)
iif (IsSrvUnix(),CHMOD(lower(Alltrim(cDirEnv))+Alltrim(cArquivo) , 666,,.f. ),CHMOD(lower(Alltrim(cDirEnv))+Alltrim(cArquivo) , 2,,.f. ))

/////////////////////////////
// RENOMEAR PARA MAIUSCULO //
/////////////////////////////
FRenameEx(lower(Alltrim(cDirEnv))+Alltrim(cArquivo),lower(Alltrim(cDirEnv))+UPPER(Alltrim(cArquivo)))
	
Return(.t.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_CriaSX1≥ Autor ≥ Thiago                 ≥ Data ≥ 15/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Criacao das Perguntes                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_CriaSX1(cPerg)
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
Local nOpcGetFil := GETF_NETWORKDRIVE + GETF_RETDIRECTORY

dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(Left(Alltrim(cPerg)+SPACE(100),Len(SX1->X1_GRUPO))+"01") .and. Alltrim(SX1->X1_VALID)<> ("!Vazio().or.(Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))")
	While !Eof() .and. SX1->X1_GRUPO == Left(Alltrim(cPerg)+SPACE(100),Len(SX1->X1_GRUPO))
		RecLock("SX1",.f.,.t.)
			SX1->(DbDelete())
		MsUnLock()
		DbSkip()
	EndDo
EndIf

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
			"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
			"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
			"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME","X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}

aAdd(aSX1,{cPerg,"01",STR0034,"","","MV_CH1","C",99,0,0,"G","!Vazio().or.(Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
aAdd(aSX1,{cPerg,"02",STR0035,"","","MV_CH2","C",99,0,0,"G","!Vazio().or.(Mv_Par02:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_PERGXML≥ Autor ≥ Thiago                 ≥ Data ≥ 15/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ F12 - Pergunte ( Diretorios: Envio / Recepcao )             ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_PERGXML()
SetKey(VK_F12,Nil)
If Pergunte("VEI200",.t.)
	cDirEnv := Alltrim(MV_PAR01)
	if !Empty(cDirEnv) .and. right(cDirEnv,1) <> "\"
		cDirEnv := cDirEnv+"\"
	Endif	
	cDirRec := Alltrim(MV_PAR02)
	if !Empty(cDirRec) .and. right(cDirRec,1) <> "\"
		cDirRec := cDirRec+"\"
	Endif	
EndIf
SetKey(VK_F12,{ || FS_PERGXML()})
Return(.t.)

/*/{Protheus.doc} VM2000011_Visualizar()
Visualizar: Pedido (VQ0) ou Veiculo (VV1)

@author Andre Luis Almeida
@since 16/12/2021
/*/
Static Function VM2000011_Visualizar( cNumPed , cChassi )
Local nOpcAviso := 0
Local nRecNo    := 0
Local cQuery    := ""
Default cNumPed := ""
Default cChassi := ""
Do Case
	Case !Empty(cNumPed) .and. !Empty(cChassi) // Tem Pedido e Chassi - Selecionar
		nOpcAviso := Aviso(STR0050,; // Visualizar Cadastro
					CHR(13)+CHR(10)+;
					" - "+STR0010+" ( "+Alltrim(cNumPed)+" )"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Pedido
					" - "+STR0051+" ( "+Alltrim(cChassi)+" )"+CHR(13)+CHR(10)+CHR(13)+CHR(10),; // VeÌculo/M·quina
					{STR0010,STR0051,STR0038},2) // Pedido / VeÌculo/M·quina / Cancelar
	Case !Empty(cNumPed)
		nOpcAviso := 1
	Case !Empty(cChassi)
		nOpcAviso := 2
EndCase
If nOpcAviso == 1 // Pedido (VQ0)
	cQuery := "SELECT R_E_C_N_O_ FROM "+RetSQLName("VQ0")+" WHERE VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0_NUMPED='"+cNumPed+"' AND VQ0_CHASSI='"+cChassi+"' AND D_E_L_E_T_=' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo > 0
		DbSelectArea("VQ0")
		VQ0->(DbGoto(nRecNo))
		oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0050) // Visualizar Cadastro
		oExecView:SetSource("VEIA142")
		oExecView:SetOperation(MODEL_OPERATION_VIEW)
		oExecView:OpenView(.T.)
	EndIf
ElseIf nOpcAviso == 2 // Chassi (VV1)
	cQuery := "SELECT R_E_C_N_O_ FROM "+RetSQLName("VV1")+" WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHASSI='"+cChassi+"' AND D_E_L_E_T_=' '"
	nRecNo := FM_SQL(cQuery)
	If nRecNo > 0
		DbSelectArea("VV1")
		VV1->(DbGoto(nRecNo))
		oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0050) // Visualizar Cadastro
		oExecView:SetSource("VEIA070")
		oExecView:SetOperation(MODEL_OPERATION_VIEW)
		oExecView:OpenView(.T.)
	EndIf
EndIf
Return