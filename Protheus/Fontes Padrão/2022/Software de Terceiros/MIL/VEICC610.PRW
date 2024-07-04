// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 33     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEICC610.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³VEICC610³ Autor ³ Andre Luis Almeida       ³ Data ³ 17/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Controle de Entregas                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC610()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam  := 0
Local aFilAtu  := {}
Private aVetor := {}
Private cPesq  := space(30)
Private cQtdVei:= ""
Private cTipDt := STR0025 // Previsao Entrega:
Private oBranc := LoadBitmap( GetResources(), "BR_BRANCO" )
Private oVerde := LoadBitmap( GetResources(), "BR_VERDE" )
Private aFilVVA:= {}
Private aNewBot:= {	{ "FILTRO"    , { || Processa( {|| FS_LEVANT(1) } ) }  , STR0035 } ,;  // Parametros 
					{ "PMSDATE"   , { || FS_ALTDATAS() }                   , STR0044 } ,;  // Alterar Dt.Entrega
					{ "PMSPREV"   , { || FS_VERATEND() }                   , STR0008 } ,;  // Atendimento
					{ "IMPRESSAO" , { || FS_IMPRIMIR() }                   , STR0031 } }   // Imprimir  
Private aParam := { "" ,;								// 1 - Filial Entrega
					STR0023 ,;							// 2 - Relacao
					(dDataBase-day(dDataBase))+1 ,;	// 3 - Venda - Data Inicial
					dDataBase ,;						// 4 - Venda - Data Final
					(dDataBase-day(dDataBase))+1 ,;	// 5 - Entrega - Data Inicial
					dDataBase ,;						// 6 - Entrega - Data Final
					"" ,;								// 7 - Estado Veiculo
					STR0006 }							// 8 - Ordem
//
If ( ExistBlock("VCC610ABOT") )  // Incluir Opcoes no Acoes relacionadas
	aNewBot := ExecBlock("VCC610ABOT",.f.,.f.,{aNewBot})
EndIf
//
aFilAtu := FWArrFilAtu()
aFilVVA := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
aAdd( aFilVVA , "" )
Asort(aFilVVA)

FS_LEVANT(0) // Levantamento

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 01, 12 , .T. , .F. } ) // Topo -> Pesquisa / Total / Legenda
AAdd( aObjects, { 01, 00 , .T. , .T. } ) // ListBox -> Veiculos / Atendimentos

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
DEFINE MSDIALOG oEntreg TITLE STR0003 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5]	of oMainWnd PIXEL // Controle de Entregas

@ aPosObj[2,1],aPosObj[2,2]+002 LISTBOX oLbEnt FIELDS HEADER "",STR0039,STR0040,STR0041,STR0042,STR0006,STR0028,STR0036,STR0007,STR0029,STR0020,STR0008,STR0043,STR0019,STR0009,STR0010,STR0011,STR0012 COLSIZES ;
															  10,     70,     20,     70,     20,     70,     45,     35,     60,     35,     35,     35,     40,     25,     85,     45,     60,     90 SIZE aPosObj[2,4]-4,aPosObj[2,3]-aPosObj[2,1] OF oEntreg PIXEL ON DBLCLICK (FS_VEICC610(oLbEnt:nAt))
oLbEnt:SetArray(aVetor)
oLbEnt:bLine := { || {IIf(aParam[2]==STR0023,oVerde,oBranc) ,                    ;// 01
	aVetor[oLbEnt:nAt,18],                                                         ;// 02
	aVetor[oLbEnt:nAt,19],                                                         ;// 03
	aVetor[oLbEnt:nAt,20]+" - "+aVetor[oLbEnt:nAt,22],                             ;// 04
	strzero(aVetor[oLbEnt:nAt,21],2)+"h",                                          ;// 05
	aVetor[oLbEnt:nAt,5],                                                          ;// 06
	aVetor[oLbEnt:nAt,12],                                                         ;// 07
	aVetor[oLbEnt:nAt,17],                                                         ;// 08
	aVetor[oLbEnt:nAt,6],                                                          ;// 09
	aVetor[oLbEnt:nAt,13],                                                         ;// 10
	aVetor[oLbEnt:nAt,16],                                                         ;// 11
	aVetor[oLbEnt:nAt,7],                                                          ;// 12
	aVetor[oLbEnt:nAt,23],                                                         ;// 13
	Transform(stod(aVetor[oLbEnt:nAt,10]),"@D"),                                   ;// 14
	aVetor[oLbEnt:nAt,1]+"-"+aVetor[oLbEnt:nAt,2]+" "+aVetor[oLbEnt:nAt,3],        ;// 15
	aVetor[oLbEnt:nAt,4],                                                          ;// 16
	aVetor[oLbEnt:nAt,9],                                                          ;// 17
	aVetor[oLbEnt:nAt,8]}}                                                          // 18

@ aPosObj[1,1]+002,aPosObj[1,2]+004 SAY STR0004 SIZE 30,10 OF oEntreg PIXEL COLOR CLR_BLUE 					// Pesquisa
@ aPosObj[1,1]+001,aPosObj[1,2]+034 MSGET oPesq VAR cPesq VALID FS_PESQ() PICTURE "@!" SIZE 100,08 OF oEntreg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+001,(aPosObj[1,4]/2)-45 MSGET oQtdVei VAR cQtdVei SIZE 90,08 OF oEntreg PIXEL COLOR CLR_BLUE WHEN .f.
@ aPosObj[1,1]+002,aPosObj[1,4]-110 BITMAP oCorBranc RESOURCE "BR_BRANCO" OF oEntreg NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[1,1]+002,aPosObj[1,4]-100 SAY oLegBranc VAR STR0024 SIZE 100,10 OF oEntreg PIXEL COLOR CLR_BLUE 					// Veiculos ja entregues
@ aPosObj[1,1]+002,aPosObj[1,4]-110 BITMAP oCorVerde RESOURCE "BR_VERDE" OF oEntreg NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[1,1]+002,aPosObj[1,4]-100 SAY oLegVerde VAR STR0023 SIZE 100,10 OF oEntreg PIXEL COLOR CLR_BLUE 					// Veiculos a serem entregues
oCorBranc:lVisible := .f.
oLegBranc:lVisible := .f.
oCorVerde:lVisible := .f.
oLegVerde:lVisible := .f.
If aParam[2] == STR0023 // Veiculos a serem entregues
	oCorVerde:lVisible := .t.
	oLegVerde:lVisible := .t.
Else // Veiculos ja entregues
	oCorBranc:lVisible := .t.
	oLegBranc:lVisible := .t.
EndIf

ACTIVATE MSDIALOG oEntreg ON INIT EnchoiceBar(oEntreg, { || oEntreg:End() },{|| oEntreg:End() },,aNewBot)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_LEVANT  ³ Autor ³  Andre Luis Almeida   ³ Data ³ 17/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Veiculos ( a serem entregues / ja entregues )         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANT(nTip)
Local lA1_IBGE := ( SA1->(FieldPos("A1_IBGE")) > 0 )
Local cQuery   := ""
Local cQAlias  := "SQLVV0"
Local nVeiEnt  := 1
Local nFil     := 0
Local cVV9FIL  := "" // Filial selecionada nos parametros
Local cVV1Fil  := ""
Local cVV2Fil  := ""
Local cVVCFil  := ""
Local cVeiMod  := ""
Local cVeiCor  := ""
Local cFonCli  := ""
Local cMunCli  := ""
Local cBkpFil  := cFilAnt // Salva cFilAnt principal ( Filial Atual )
Local nRECVV0  := 0
Local cEstVei  := ""
                    
If nTip <> 2 // Mostrar Parametros da Consulta ( 0=Inicial / 1=Parametros )
	FS_PARAM() // Parametros da Consulta
EndIf

If !Empty(aParam[1]) // Filial Entrega
	cFilAnt := aParam[1]
	cVV9FIL := xFilial("VV9") // Filial selecionada nos Parametros
EndIf
	
If aParam[2] == STR0023 // Veiculos a serem entregues
	nVeiEnt := 1
	cTipDt  := STR0025 // Previsao Entrega:
Else // Veiculos ja entregues
	nVeiEnt := 2
	cTipDt  := STR0026 // Data da Entrega:
EndIf

aVetor := {}

For nFil := 1 to Len(aFilVVA)
	
	If Empty(aFilVVA[nFil])
		Loop
	EndIf
	
	cFilAnt := aFilVVA[nFil] // Multi Filial -> Muda cFilAnt para utilizar xFilial dos arquivos
	
	cVV1Fil := xFilial("VV1")
	cVV2Fil := xFilial("VV2")
	cVVCFil := xFilial("VVC")
	
	cQuery := "SELECT VV0.R_E_C_N_O_ RECVV0 , VV0.VV0_TIPFAT , VV0.VV0_FILIAL , VV0.VV0_NUMTRA , VV0.VV0_CODCLI , VV0.VV0_LOJA , VV0.VV0_NUMNFI , "+ FGX_MILSNF("VV0", 3, "VV0_SERNFI") +" , VV0.VV0_SERNFI , VVA.VVA_CHAINT , "
	cQuery += "VVA.VVA_DTEREA , VVA.VVA_DTEPRV , VVA.VVA_HREPRV , VVA.VVA_FIEPRV , VVA.VVA_BOEPRV , VVA.VVA_USEPRV , COALESCE(VAI.VAI_NOMTEC, ' ') VAI_NOMTEC, "
	cQuery += "SA3.A3_NOME , SA1.A1_NOME , SA1.A1_CGC , SA1.A1_TEL, "
	If lA1_IBGE
		cQuery += "VAM.VAM_DESCID , VAM.VAM_ESTADO , VAM.VAM_DDD "
	Else
		cQuery += "SA1.A1_MUN , SA1.A1_EST "
	EndIf
	cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
	cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON  VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS='F' AND VV9.D_E_L_E_T_ = ' '  "
	cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON  VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' '  "
	cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VV0.VV0_CODVEN AND SA3.D_E_L_E_T_=' ' "
	cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VV0.VV0_CODCLI AND SA1.A1_LOJA=VV0.VV0_LOJA AND SA1.D_E_L_E_T_=' ' "
	If lA1_IBGE
		cQuery += "LEFT JOIN "+RetSQLName("VAM")+" VAM ON VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.D_E_L_E_T_=' '  "
	EndIf
	cQuery += "LEFT JOIN "+RetSQLName("VAI")+" VAI ON VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR=VVA.VVA_USEPRV AND VAI_CODUSR <> ' ' AND VAI.D_E_L_E_T_=' '  "
	cQuery += "WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_DATMOV>='"+dtos(aParam[3])+"' AND VV0.VV0_DATMOV<='"+dtos(aParam[4])+"' AND "
	cQuery += "( ( VV0.VV0_OPEMOV='0' AND VV0.VV0_NUMNFI<>'"+space(len(VV0->VV0_NUMNFI))+"' ) OR VV0.VV0_TIPFAT='2' ) AND "
	cQuery += "VV0.VV0_CODCLI<>'"+space(len(VV0->VV0_CODCLI))+"' AND VV0.VV0_NUMTRA<>'"+space(len(VV0->VV0_NUMTRA))+"' AND VV0.D_E_L_E_T_=' ' AND "
	If aParam[2] == STR0023 // Veiculos a serem entregues
		cQuery += "( ( VVA.VVA_DTEPRV>='"+dtos(aParam[5])+"' AND VVA.VVA_DTEPRV<='"+dtos(aParam[6])+"' ) OR VVA.VVA_DTEPRV='        ' ) AND VVA.VVA_DTEREA='        ' AND "
	Else // Veiculos ja entregues
		cQuery += "VVA.VVA_DTEREA>='"+dtos(aParam[5])+"' AND VVA.VVA_DTEREA<='"+dtos(aParam[6])+"' AND VVA.VVA_DTEREA<>'        ' AND "
	EndIf                      
	If !Empty(cVV9FIL) // Filial
		cQuery += "( VVA.VVA_FIEPRV='"+cVV9FIL+"' OR VVA.VVA_FIEPRV='   ' ) AND "
	EndIf
	cQuery += "( VVA.VVA_USEPRV='"+__cUserID+"' OR VVA.VVA_USEPRV='      ' ) "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	If !( cQAlias )->( Eof() )
		Do While !( cQAlias )->( Eof() )
			If nRECVV0 <> ( cQAlias )->( RECVV0 )
				nRECVV0 := ( cQAlias )->( RECVV0 )
				VV1->(DbSetOrder(1))
				If VV1->(DbSeek( cVV1Fil + ( cQAlias )->( VVA_CHAINT ) ))
					If VV1->VV1_GRASEV == "6"
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
					If !Empty(aParam[7]) // Estado do Veiculo
						If VV1->VV1_ESTVEI <> aParam[7]
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
					cVeiMod := VV1->VV1_CODMAR+" "+FM_SQL("SELECT VV2.VV2_DESMOD FROM "+RetSQLName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+cVV2Fil+"' AND VV2.VV2_CODMAR='"+VV1->VV1_CODMAR+"' AND VV2.VV2_MODVEI='"+VV1->VV1_MODVEI+"' AND VV2.D_E_L_E_T_=' ' ")
					cVeiCor := left(FM_SQL("SELECT VVC.VVC_DESCRI FROM "+RetSQLName("VVC")+" VVC WHERE VVC.VVC_FILIAL='"+cVVCFil+"' AND VVC.VVC_CODMAR='"+VV1->VV1_CODMAR+"' AND VVC.VVC_CORVEI='"+VV1->VV1_CORVEI+"' AND VVC.D_E_L_E_T_=' ' "),19)
					If lA1_IBGE
						cFonCli := "("+( cQAlias )->( VAM_DDD )+") "+Alltrim(( cQAlias )->( A1_TEL ))
						cMunCli := Alltrim(( cQAlias )->( VAM_DESCID ))+"-"+( cQAlias )->( VAM_ESTADO )
					Else
						cFonCli := Alltrim(( cQAlias )->( A1_TEL ))
						cMunCli := Alltrim(( cQAlias )->( A1_MUN ))+"-"+( cQAlias )->( A1_EST )
					EndIf
					If ( cQAlias )->( VV0_TIPFAT ) <> "2"
						cEstVei := X3CBOXDESC("VV1_ESTVEI",VV1->VV1_ESTVEI)
					Else
						cEstVei := STR0046 // Fat.Direto
					EndIf
					
					aAdd(aVetor,{;
						( cQAlias )->( VV0_CODCLI ) ,; //1
						( cQAlias )->( VV0_LOJA ) ,;   //2
						left(( cQAlias )->( A1_NOME ),30) ,; //3
						cFonCli ,; //4
						cVeiMod ,; //5
						VV1->VV1_CHASSI ,; //6
						( cQAlias )->( VV0_NUMTRA ) ,; //7
						cMunCli ,; //8
						Transform(( cQAlias )->( A1_CGC ),IIf(Len(Alltrim(( cQAlias )->( A1_CGC )))>12,"@R 99.999.999/9999-99","@R 999.999.999-99")) ,; //9
						IIf(aParam[2]==STR0023,( cQAlias )->( VVA_DTEPRV ),( cQAlias )->( VVA_DTEREA )) ,; //10
						nVeiEnt ,;                           //11
						cVeiCor ,;                           //12
						( cQAlias )->( VV0_NUMNFI )+"-"+(cQAlias)->&(FGX_MILSNF("VV0", 3, "VV0_SERNFI")) ,;                  //13
						( cQAlias )->( VVA_CHAINT ) ,;       //14
						cFilAnt ,;                           //15
						( cQAlias )->( VV0_FILIAL ) ,;       //16
						cEstVei ,;                           //17
						( cQAlias )->( VVA_FIEPRV ) ,;       //18
						( cQAlias )->( VVA_BOEPRV ) ,;       //19
						( cQAlias )->( VVA_USEPRV ) ,;       //20
						( cQAlias )->( VVA_HREPRV ) ,;       //21
						left( (cQAlias)->(VAI_NOMTEC),15) ,; //22
						left( (cQAlias)->(A3_NOME),15) })    //23
				EndIf
			EndIf
			( cQAlias )->( DbSkip() )
		EndDo
	EndIf
	( cQAlias )->( dbCloseArea() )
	
Next

cFilAnt := cBkpFil // Volta cFilAnt principal ( Filial Atual )
DbSelectArea("VV1")
cQtdVei := str(len(aVetor),20)+" "+STR0005 // nnnn veiculo(s)
If len(aVetor) <= 0
	MsgAlert(STR0001,STR0002) // Nenhum Veiculo encontrado! / Atencao
	aAdd(aVetor,{ "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , 2 , "" , "" , "" , "" , "" , "" , "" , "" , "" , 0 , "" , "", "", "", " ", "", "" })
	cQtdVei := ""
EndIf
FS_ORDEM(nTip)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PARAM ³ Autor ³ Andre Luis Almeida         ³ Data ³ 08/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Parametros para o Filtro do Levantamento                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PARAM()
Local aParamBox := {}
Local aRet      := {}
Local lRet      := .f.
Local aVeiEnt   := { STR0023 , STR0024 } // Veiculos a serem entregues / Veiculos ja entregues
Local aOrdem    := { STR0006 , STR0028 , STR0007 , STR0029 , STR0008 , STR0019 , STR0021 } // Ordem: Veiculo / Cor / Chassi / NF/Serie / Atendimento / Data / Nome do Cliente
Local aEstVei   := {" ","0="+Alltrim(X3CBOXDESC("VV1_ESTVEI","0")),"1="+Alltrim(X3CBOXDESC("VV1_ESTVEI","1"))}
AADD(aParamBox,{2,STR0039,aParam[1],aFilVVA,70,"",.f.})												// 1 - Filial Entrega
AADD(aParamBox,{2,STR0027,aParam[2],aVeiEnt,90,"",.f.})												// 2 - Relacao
AADD(aParamBox,{1,STR0033,aParam[3],"@D",'Empty(MV_PAR03) .or. MV_PAR03 <= dDataBase',"","",50,.f.})	// 3 - Venda - Data Inicial
AADD(aParamBox,{1,STR0034,aParam[4],"@D",'MV_PAR04 >= MV_PAR03',"","",50,.f.})						// 4 - Venda - Data Final
AADD(aParamBox,{1,STR0037,aParam[5],"@D",'Empty(MV_PAR05) .or. MV_PAR05 <= dDataBase',"","",50,.f.})	// 5 - Entrega - Data Inicial
AADD(aParamBox,{1,STR0038,aParam[6],"@D",'MV_PAR06 >= MV_PAR05',"","",50,.f.})						// 6 - Entrega - Data Final
AADD(aParamBox,{2,STR0036,aParam[7],aEstVei,70,"",.f.})												// 7 - Estado Veiculo
AADD(aParamBox,{2,STR0022,aParam[8],aOrdem,70,"",.f.})													// 8 - Ordem
If ParamBox(aParamBox,Alltrim(STR0003)+" - "+STR0035,@aRet,,,,,,,,.t.,.t.) // Controle de Entregas - Parametros
	lRet   := .t.
	aParam := aClone(aRet) // Parametros do Filtro
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_ORDEM   ³ Autor ³  Andre Luis Almeida   ³ Data ³ 17/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ordena Vetor de Veiculos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ORDEM(nTip)
Local cOrdAnt := aParam[8] 	// Ordem
If aParam[8] == STR0006 	// Veiculo
	aSort(aVetor,1,,{|x,y| x[5]+x[6] < y[5]+y[6] })
ElseIf aParam[8] == STR0028	// Cor
	aSort(aVetor,1,,{|x,y| x[12]+x[5]+x[6] < y[12]+y[5]+y[6] })
ElseIf aParam[8] == STR0007	// Chassi
	aSort(aVetor,1,,{|x,y| x[6] < y[6] })
ElseIf aParam[8] == STR0029	// NF/Serie
	aSort(aVetor,1,,{|x,y| x[13] < y[13] })
ElseIf aParam[8] == STR0008	// Atendimento
	aSort(aVetor,1,,{|x,y| x[7] < y[7] })
ElseIf aParam[8] == STR0019	// Data
	aSort(aVetor,1,,{|x,y| x[10] < y[10] })
ElseIf aParam[8] == STR0021	// Nome do Cliente
	aSort(aVetor,1,,{|x,y| x[3] < y[3] })
EndIf
If nTip > 0
	oCorBranc:lVisible := .f.
	oLegBranc:lVisible := .f.
	oCorVerde:lVisible := .f.
	oLegVerde:lVisible := .f.
	If aParam[2] == STR0023 // Veiculos a serem entregues
		oCorVerde:lVisible := .t.
		oLegVerde:lVisible := .t.
	Else // Veiculos ja entregues
		oCorBranc:lVisible := .t.
		oLegBranc:lVisible := .t.
	EndIf
	oLbEnt:nAt := 1
	oLbEnt:SetArray(aVetor)

	oLbEnt:bLine := { || {IIf(aParam[2]==STR0023,oVerde,oBranc) ,                    ;// 01
		aVetor[oLbEnt:nAt,18],                                                         ;// 02
		aVetor[oLbEnt:nAt,19],                                                         ;// 03
		aVetor[oLbEnt:nAt,20]+" - "+aVetor[oLbEnt:nAt,22],                             ;// 04
		strzero(aVetor[oLbEnt:nAt,21],2)+"h",                                          ;// 05
		aVetor[oLbEnt:nAt,5],                                                          ;// 06
		aVetor[oLbEnt:nAt,12],                                                         ;// 07
		aVetor[oLbEnt:nAt,17],                                                         ;// 08
		aVetor[oLbEnt:nAt,6],                                                          ;// 09
		aVetor[oLbEnt:nAt,13],                                                         ;// 10
		aVetor[oLbEnt:nAt,16],                                                         ;// 11
		aVetor[oLbEnt:nAt,7],                                                          ;// 12
		aVetor[oLbEnt:nAt,23],                                                         ;// 13
		Transform(stod(aVetor[oLbEnt:nAt,10]),"@D"),                                   ;// 14
		aVetor[oLbEnt:nAt,1]+"-"+aVetor[oLbEnt:nAt,2]+" "+aVetor[oLbEnt:nAt,3],        ;// 15
		aVetor[oLbEnt:nAt,4],                                                          ;// 16
		aVetor[oLbEnt:nAt,9],                                                          ;// 17
		aVetor[oLbEnt:nAt,8]}}                                                          // 18

	oLbEnt:SetFocus()
	oLbEnt:Refresh()
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VEICC610 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 17/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Registra a Entrega do Veiculo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEICC610(nPos)
Local aParamBox := {} // ParamBox
Local aRet    := {}
Local lEntVei := ( VAI->(FieldPos("VAI_ENTVEI")) > 0 )
Local lKMMes  := ( VV1->(FieldPos("VV1_MEDMKM")) > 0 )
Local lEntVen := ( VVA->(FieldPos("VVA_VENREA")) > 0 )
Local nKMMes  := 0
Local lRet    := .f.
Local lOk     := .t.
Local cPar    := ""
Local cTpA    := ""
Local cVen    := ""
Local nDia    := 0
Local cQuery  := ""
Local cQAlias := "SQLVV0"
Local cBkpFil := cFilAnt // Salva cFilAnt principal ( Filial Atual )
Local cObjetiv := ""
///////////////////////
// Posicionar no VAI //
///////////////////////
VAI->(dbSetOrder(4))
VAI->(dbSeek(xFilial("VAI")+__cUserID))
If !Empty(aVetor[nPos,6]) .and. aVetor[nPos,11] == 1 // Veiculos a serem entregues
	
	cFilAnt := aVetor[nPos,15] // Multi Filial -> Muda cFilAnt para utilizar xFilial dos arquivos
	
	If lEntVei
		If VAI->VAI_ENTVEI <> "1" // Usuario nao eh autorizado a Entregar Veiculos se existir OS com Tipos de Tempos em aberto
			cQuery := "SELECT VO1.R_E_C_N_O_ RECVO1 "
			cQuery +=  " FROM " + RetSQLName("VO1") + " VO1 "
			cQuery +=         " JOIN "+RetSQLName("VO2")+" VO2 ON VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_NUMOSV=VO1.VO1_NUMOSV AND VO2.VO2_TIPREQ='P' AND VO2.D_E_L_E_T_=' ' "
			cQuery +=         " JOIN "+RetSQLName("VO3")+" VO3 ON VO3.VO3_FILIAL='"+xFilial("VO3")+"' AND VO3.VO3_NOSNUM=VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_=' ' "
			cQuery +=         " JOIN "+RetSQLName("VOI")+" VOI ON VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND VOI.VOI_TIPTEM=VO3.VO3_TIPTEM AND VOI.D_E_L_E_T_=' ' "
			cQuery += " WHERE VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_CHAINT='"+aVetor[nPos,14]+"' AND VO1.D_E_L_E_T_=' ' AND "
			cQuery +=         "VO3.VO3_DATFEC='"+space(8)+"' AND VO3.VO3_DATCAN='"+space(8)+"' AND VOI.VOI_BLQENT='1' "
			cQuery += " UNION "
			cQuery += "SELECT VO1.R_E_C_N_O_ RECVO1 "
			cQuery +=  " FROM " + RetSQLName("VO1") + " VO1 "
			cQuery +=         " JOIN "+RetSQLName("VO2")+" VO2 ON VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_NUMOSV=VO1.VO1_NUMOSV AND VO2.VO2_TIPREQ='S' AND VO2.D_E_L_E_T_=' ' "
			cQuery +=         " JOIN "+RetSQLName("VO4")+" VO4 ON VO4.VO4_FILIAL='"+xFilial("VO4")+"' AND VO4.VO4_NOSNUM=VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_=' ' "
			cQuery +=         " JOIN "+RetSQLName("VOI")+" VOI ON VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND VOI.VOI_TIPTEM=VO4.VO4_TIPTEM AND VOI.D_E_L_E_T_=' ' "
			cQuery += " WHERE VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_CHAINT='"+aVetor[nPos,14]+"' AND VO1.D_E_L_E_T_=' ' AND "
			cQuery +=         "VO4.VO4_DATFEC='"+space(8)+"' AND VO4.VO4_DATCAN='"+space(8)+"' AND VOI.VOI_BLQENT='1' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
			If !( cQAlias )->( Eof() )
				lOk := .f.
				MsgStop(STR0032,STR0002) // Existe(m) Tipo(s) de Tempo / OS(s) pendentes! Impossivel Entregar o Veiculo! / Atencao
			EndIf
			( cQAlias )->( dbCloseArea() )
		EndIf
	EndIf
	If lOk
		lOk  := VEIVM130TAR(aVetor[nPos,7],"E","",cFilAnt) // E-Verifica/Valida Tarefas na Entrega do Veiculo
		If lOk
			aAdd(aParamBox,{1,STR0006+": ",aVetor[nPos,5],"@!S40","","",".f.",100,.f.}) 	// Veiculo - MV_PAR01
			aAdd(aParamBox,{1,STR0028+": ",aVetor[nPos,12],"@!S20","","",".f.",80,.f.}) 	// Cor - MV_PAR02
			aAdd(aParamBox,{1,STR0007+": ",aVetor[nPos,6],"@!S20","","",".f.",100,.f.}) 	// Chassi - MV_PAR03
			aAdd(aParamBox,{1,STR0015,aVetor[nPos,1]+"-"+aVetor[nPos,2]+" "+aVetor[nPos,3],"@!S20","","",".f.",100,.f.}) // Cliente: - MV_PAR04
			aAdd(aParamBox,{1,STR0016,aVetor[nPos,9],"@!S20","","",".f.",80,.f.}) 		// CPF/CNPJ: - MV_PAR05
			aAdd(aParamBox,{1,STR0017,aVetor[nPos,8],"@!S40","","",".f.",80,.f.})			// Cidade: - MV_PAR06
			aAdd(aParamBox,{1,STR0020+": ",aVetor[nPos,16],"@!S20","","",".f.",60,.f.}) 	// Filial - MV_PAR07
			aAdd(aParamBox,{1,STR0029+": ",aVetor[nPos,13],"@!S20","","",".f.",60,.f.}) 	// NF/Serie - MV_PAR08
			aAdd(aParamBox,{1,STR0008+": ",aVetor[nPos,7],"@!S20","","",".f.",60,.f.}) 	// Atendimento - MV_PAR09
			aAdd(aParamBox,{1,STR0019+": ",stod(aVetor[nPos,10]),"@D","","",".f.",50,.f.})	// Data - MV_PAR10
			If lKMMes
				aAdd(aParamBox,{1,STR0014,nKMMes,VV1->(x3Picture("VV1_MEDMKM")),"","","",50,.f.}) // Media prevista de KM/Mes - MV_PAR11 = aRet[11]
			EndIf
			If lEntVen
				aAdd(aParamBox, {1, STR0047, Space(TamSX3("VVA_VENREA")[1]), VVA->(x3Picture("VVA_VENREA")), "", "SA3", "", 50, .f.}) // Vendedor de Entrega do Veículo - MV_PAR12 = aRet[12]
			EndIf

			If ParamBox(aParamBox,STR0013,@aRet,,,,,,,,.F.) // Confirma a Entrega do Veiculo ?
				DbSelectArea("VV1")
				DbSetOrder(2) // VV1_FILIAL+VV1_CHASSI
				If DbSeek( xFilial("VV1") + aVetor[nPos,6] )
					If lKMMes // Atualiza KM Media Mes caso exista o campo
						RecLock("VV1",.f.)
						VV1->VV1_MEDMKM := aRet[11] // Media prevista de KM/Mes
						MsUnLock()
					EndIf
				EndIf

				DbSelectArea("VV0")
				DbSetOrder(1) // VV0_FILIAL+VV0_NUMTRA
				DbSeek( xFilial("VV0") + aVetor[nPos,7] )

				DbSelectArea("VVA")
				DbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA+VVA_CHASSI
				If DbSeek( xFilial("VVA") + aVetor[nPos,7] + aVetor[nPos,6] )
					RecLock("VVA",.f.)
					VVA->VVA_DTEREA := dDataBase
					VVA->VVA_HORREA := Val(Substr(Time(),1,2)+Substr(Time(),4,2))
					VVA->VVA_USUREA := __cUserID
					If Empty(VVA->VVA_FIEPRV)
						VVA->VVA_FIEPRV := xFilial("VV9")
					EndIf
					If lEntVen
						VVA->VVA_VENREA := aRet[12] // Vendedor de Entrega do Veículo
					EndIf
					MsUnLock()

					// Executa PE Entrega Veiculo //
					If ExistBlock("PVCC610DG")
						ExecBlock("PVCC610DG",.f.,.f.)
					Endif

					cPar := GetNewPar("MV_CEVENTR","")
					If !Empty(cPar)
						cObjetiv := STR0003+"- "+STR0026+" "+Transform(dDataBase,"@D")+CHR(13)+CHR(10) // Controle de Entregas / Data da Entrega:
						cObjetiv += STR0006+": "+Alltrim(aVetor[nPos,6])+" - "+Alltrim(aVetor[nPos,5])+" - "+aVetor[nPos,12]+CHR(13)+CHR(10) // Veiculo
						cObjetiv += STR0008+": "+aVetor[nPos,7]+" - "+STR0029+": "+aVetor[nPos,13] // Atendimento / NF/Serie
						cTpA := left(cPar,1)
						nDia := val(substr(cPar,2,3))

						// Vendedor selecionado para entrega (VVA_VENREA)
						If lEntVen .And. !Empty(aRet[12])
							cVen := aRet[12]
						EndIf

						// vendedor do usuário selecionado se o campo existir senão do usuário logado
						If Empty(cVen)
							cVen := substr(cPar,5,6)
							If Empty(cVen)
								cVen := VAI->VAI_CODVEN // Vendedor do usuario Logado
							EndIf
						EndIf

						FS_AGENDA(cTpA,(dDataBase+nDia),cVen,aVetor[nPos,1],aVetor[nPos,2],,aVetor[nPos,7],,cObjetiv,"","")
					EndIf

					MsgInfo(STR0018,STR0002) // Operacao realizada com sucesso! / Atencao
					lRet := .t.
				EndIf
			EndIf
		EndIf

	EndIf
	
	cFilAnt := cBkpFil // Volta cFilAnt principal ( Filial Atual )
	
EndIf
DbSelectArea("VV1")
If lRet
	FS_LEVANT(2)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_PESQ    ³ Autor ³  Andre Luis Almeida   ³ Data ³ 17/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa no Vetor de Veiculos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQ()
Local ni := 0
If !Empty(cPesq)
	Do Case // Pesquisar pela Ordem
		Case aParam[8] == STR0028 // Cor
			ni := aScan(aVetor,{|x| Alltrim(cPesq) $ x[12] })						// Cor
		Case aParam[8] == STR0007 // Chassi
			ni := aScan(aVetor,{|x| Alltrim(cPesq) $ x[06] })						// Chassi
		Case aParam[8] == STR0029 // NF/Serie
			ni := aScan(aVetor,{|x| Alltrim(cPesq) $ x[13] })						// NF/Serie
		Case aParam[8] == STR0008 // Atendimento
			ni := aScan(aVetor,{|x| Alltrim(cPesq) $ x[07] })	  					// Atendimento
		Case aParam[8] == STR0021 // Nome do Cliente
			ni := aScan(aVetor,{|x| Alltrim(cPesq) $ x[03] })	 					// Nome do Cliente
	EndCase
	If	ni == 0
		ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[07] })							// Atendimento
		If	ni == 0
			ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[13] })						// NF/Serie
			If	ni == 0
				ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[06] })					// Chassi
				If ni == 0
					ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[03] })	 			// Nome do Cliente
					If ni == 0
						ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[05] })			// Marca/Modelo
						If ni == 0
							ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[12] })		// Cor
							If ni == 0
								ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[09] })	// CPF/CNPJ
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
If ni > 0
	oLbEnt:nAt := ni
Else
	oLbEnt:nAt := 1
EndIf
oLbEnt:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ALTDATAS ³ Autor ³ Andre Luis Almeida    ³ Data ³ 08/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteracao da Data de Entrega                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALTDATAS()
Local cFilBkp := cFilAnt
Private aEntrVei := {"","","","",ctod(""),ctod(""),"",0,0,"","","", ""}	// Dt.Entrega do Veiculo
If aParam[2] == STR0023 // Veiculos a serem entregues
	If !Empty(aVetor[oLbEnt:nAt,7])
		cFilAnt := aVetor[oLbEnt:nAt,15]
		nOpc    := 4
		DbSelectArea("VV9")
		DbSetOrder(1)
		If DbSeek( aVetor[oLbEnt:nAt,16] + aVetor[oLbEnt:nAt,7] )
			DbSelectArea("VVA")
			DbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA+VVA_CHASSI
			If DbSeek( aVetor[oLbEnt:nAt,16] + aVetor[oLbEnt:nAt,7] + aVetor[oLbEnt:nAt,6] )
				aEntrVei[01] := aVetor[oLbEnt:nAt,7] // Nro do Atendimento
				aEntrVei[02] := VVA->VVA_CHAINT	 // Chassi Interno do Veiculo
				aEntrVei[05] := VVA->VVA_DTESUG	 // Data de Entrega sugerida pelo Sistema
				aEntrVei[06] := VVA->VVA_DTEPRV	 // Data de Entrega prevista pelo Usuario
				aEntrVei[08] := VVA->(RecNo())  // RECNO do VVA
				aEntrVei[09] := VVA->VVA_HREPRV	 // Hora de Entrega prevista pelo Usuario
				aEntrVei[10] := VVA->VVA_FIEPRV	 // Filial de Entrega prevista pelo Usuario
				aEntrVei[11] := VVA->VVA_BOEPRV	 // Box de Entrega prevista pelo Usuario
				aEntrVei[12] := VVA->VVA_USEPRV // Usuario de Entrega prevista pelo Usuario
				aEntrVei[13] := VVA->VVA_SEGMOD // Segmento de Modelo
				VEIXX006(nOpc,@aEntrVei,.t.)
			EndIf
		EndIf
		cFilAnt := cFilBkp
		FS_LEVANT(2)
	EndIf
Else
	MsgInfo(STR0045,STR0002) // Veiculo ja entregue. Impossivel alterar a Data de Entrega! / Atencao
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VERATEND ³ Autor ³ Andre Luis Almeida    ³ Data ³ 08/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Atendimento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERATEND()
Local cFilBkp     := cFilAnt
Private cCadastro := STR0008 // Atendimento
If !Empty(aVetor[oLbEnt:nAt,7])
	cFilAnt := aVetor[oLbEnt:nAt,15]
	DbSelectArea("VV9")
	DbSetOrder(1)
	If DbSeek( aVetor[oLbEnt:nAt,16] + aVetor[oLbEnt:nAt,7] )
		If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
			VEIXX002(NIL,NIL,NIL,2,)
		EndIf
	EndIf
	cFilAnt := cFilBkp
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_IMPRIMIR ³ Autor ³  Rafael Goncalves     ³ Data ³ 15/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do array                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Local ni 		:= 0
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private cTamanho:= "G"     // P/M/G
Private Limite  := 220     // 80/132/220
Private aOrdem  := {}      // Ordem do Relatorio
Private cTitulo := STR0003 // Controle de Entregas
Private cNomeRel:= "VEICC610"
Private nLastKey:= 0
Private cabec1  := left(aParam[2]+space(35),35) +"  " + cTipDt+ "  " + transform(aParam[3],"@D")+" "+STR0030+" "+ transform(aParam[4],"@D")+"  "+STR0022+" "+aParam[8]
Private cabec2  := left(STR0006+space(28),28)+" "+left(STR0028+space(15),15) +" "+ left(STR0036+space(05),05) +" "+left(STR0007+space(17),17) +" "+ left(STR0029+space(13),13) +" "+left(STR0020+space(14),14)+" "+left(STR0008+space(10),10) +" "+ left(STR0019+space(10),10) +" "+ left(STR0009+space(35),35)+" "+left(STR0010+space(14),14) +" "+ left(STR0011+space(18),18) +" "+STR0012
Private nCaracter:=15
Private m_Pag   := 1
If len(aVetor) > 0 .and. !Empty(aVetor[1,5])
	cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
	If nLastKey == 27
		Return
	EndIf
	SetDefault(aReturn,cAlias)
	Set Printer to &cNomeRel
	Set Printer On
	Set Device  to Printer
	nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
	For ni:= 1 to len(aVetor)
		If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
		EndIf               //Veiculo                             //Cor                                   // Estado Veiculo                      //chassi                                //NF/Serie                             // Filial                             //Atendimento                            //data                                                        //cliente                                                                  //Fone                                 //CPF/CNPJ
		@ nLin++ ,00 psay STR0039 + ": " + aVetor[ni,18] + " " + STR0040 + ": " + aVetor[ni,20]+" - "+aVetor[ni,22]+" "+strzero(aVetor[ni,21],2)+"h"
		@ nLin++ ,00 psay left(aVetor[ni,5]+space(28),28) +" "+ left(aVetor[ni,12]+space(15),15) +" "+ left(aVetor[ni,17]+space(05),05) +" "+ left(aVetor[ni,6]+space(17),17) +" "+ left(aVetor[ni,13]+space(13),13) +" "+left(aVetor[ni,16]+space(14),14) +" "+left(aVetor[ni,7]+space(10),10) +" "+ left(Transform(stod(aVetor[ni,10]),"@D")+space(10),10)+" "+ left(aVetor[ni,1]+"-"+aVetor[ni,2]+" "+aVetor[ni,3]+space(35),35) +" "+ left(aVetor[ni,4]+space(14),14) +" "+ left(aVetor[ni,9]+space(18),18) +" "+ left(aVetor[ni,8]+space(40),40)
		@ nLin++ ,00 psay repl("-",220)
	Next
	Ms_Flush()
	Set Printer to
	Set Device  to Screen
	If aReturn[5] == 1
		OurSpool( cNomeRel )
	EndIf
Else
	MsgAlert(STR0001,STR0002) // Nenhum Veiculo encontrado! / Atencao
EndIf
Return()