// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 06     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch" 
#include "VEIVC240.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC240 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 25/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Ponto de Equilibrio do Estoque                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC240()
Local nTam      := 0
Local aFilAtu   := {}
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private aFilVV1 := {}
Private oVerd   := LoadBitmap( GetResources() , "BR_VERDE" )
Private oAmar   := LoadBitmap( GetResources() , "BR_AMARELO" )
Private oVerm   := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private aParam  := {space(VVG->(TamSx3("VVG_FILIAL")[1])),;	// 1
					10,;										// 2
					space(VV1->(TamSx3("VV1_CODMAR")[1])),;	// 3
					space(VV1->(TamSx3("VV1_MODVEI")[1])),;	// 4
					" ",;										// 5
					ctod(" "),;									// 6
					dDataBase,;									// 7
					10,;										// 8
					"0"}										// 9
Private aVeicu  := {}
Private aNewBot := { { "FILTRO" , { || Processa( {|| FS_FILTRA(1) } ) } , STR0011 } , { "IMPRESSAO" , { || FS_IMPRIMIR() } , STR0012 } } // Parametros / Imprimir

aFilAtu := FWArrFilAtu()
aFilVV1 := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
aAdd( aFilVV1 , "" )
Asort(aFilVV1)

aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox 
aAdd( aObjects, { 0 , 012 , .T. , .F. } ) // Legenda 
aPos := MsObjSize( aInfo, aObjects )
Processa( {|| FS_FILTRA(0) } )
DEFINE MSDIALOG oPEquEstq FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL // Consulta Ponto de Equilibrio do Estoque
	oPEquEstq:lEscClose := .F.
	@ aPos[1,1],aPos[1,2] LISTBOX oLbVeic FIELDS HEADER "" ,;
							STR0002 ,; // Dias p/Estouro
							STR0017 ,; // Dias Carencia
							STR0003 ,; // Dias Estoque
							STR0004 ,; // Veiculo
							STR0005+"/"+STR0023 ,; // Marca/Modelo
							STR0006 ,; // Cor
							STR0007 ,; // Chassi
							STR0013 ,; // Fab/Mod
							STR0008 ,; // Placa
							STR0009 ,; // Dt Compra
							STR0010 ,; // Vlr Compra
							STR0015 ,; // Filial
							STR0014  ; // Vlr Venda
							COLSIZES 10,40,40,40,50,120,40,60,25,25,25,30,25,30 SIZE aPos[1,4]-2,aPos[1,3]-aPos[1,1] OF oPEquEstq PIXEL ON DBLCLICK IIF(!Empty(aVeicu[oLbVeic:nAt,08]),VEIVC140(aVeicu[oLbVeic:nAt,09], aVeicu[oLbVeic:nAt, LEN(aVeicu[oLbVeic:nAt])]),.t.)
	oLbVeic:SetArray(aVeicu)
	oLbVeic:bLine := { || { IIf(aVeicu[oLbVeic:nAt,01]=="1",oVerd,IIf(aVeicu[oLbVeic:nAt,01]=="2",oAmar,oVerm)) ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,02],"@E 9,999,999")) ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,03],"@E 9,999,999")) ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,04],"@E 9,999,999")) ,;
							aVeicu[oLbVeic:nAt,05] ,;
							aVeicu[oLbVeic:nAt,06]+" "+aVeicu[oLbVeic:nAt,07] ,;
							aVeicu[oLbVeic:nAt,08] ,;
							aVeicu[oLbVeic:nAt,09] ,;
							Transform(aVeicu[oLbVeic:nAt,10],"@R 9999/9999") ,;
							Transform(aVeicu[oLbVeic:nAt,11],VV1->(X3PICTURE("VV1_PLAVEI"))) ,;
							Transform(aVeicu[oLbVeic:nAt,12],"@D") ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,13],"@E 9,999,999.99")) ,;
							aVeicu[oLbVeic:nAt,14] ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,15],"@E 9,999,999.99")) }}

	@ aPos[2,1],007 SAY STR0018 SIZE 150,8 OF oPEquEstq PIXEL COLOR CLR_BLUE // Risco:

	@ aPos[2,1],035 BITMAP oxVerm RESOURCE "BR_VERMELHO" OF oPEquEstq NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[2,1],044 SAY STR0019 SIZE 150,8 OF oPEquEstq PIXEL COLOR CLR_BLUE // Critico

	@ aPos[2,1],075 BITMAP oxAmar RESOURCE "BR_AMARELO" OF oPEquEstq NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[2,1],084 SAY STR0020 SIZE 150,8 OF oPEquEstq PIXEL COLOR CLR_BLUE // Limite

	@ aPos[2,1],115 BITMAP oxVerd RESOURCE "BR_VERDE" OF oPEquEstq NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[2,1],124 SAY STR0021 SIZE 150,8 OF oPEquEstq PIXEL COLOR CLR_BLUE // Baixo
							
ACTIVATE MSDIALOG oPEquEstq ON INIT EnchoiceBar(oPEquEstq, { || oPEquEstq:End() },{|| oPEquEstq:End() },,aNewBot)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRA³ Autor ³  Andre Luis Almeida   ³ Data ³ 25/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra/Levanta Veiculos em Estoque / Transito              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRA(nTp)
Local aQUltMov:= {}
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
Local cQAlAux := "ALIASSQLAUX"
Local lVV1_DTFATT := VV1->(FieldPos("VV1_DTFATT")) <> 0
Local cVQ0Fil := ""
Local cVV1Fil := ""
Local cVV2Fil := ""
Local cVVCFil := ""
Local cVVFFil := ""
Local nFil    := 0
Local _cVV1   := ""
Local nDiasEst:= 0 
Local nEstouro:= 0
Local cVeicu  := ""
Local nVlrCpa := 0
Local nVlrVda := 0
Local nDiaCar := 0
Local dDtConf := dDataBase
Local cBkpFil := cFilAnt // Salva cFilAnt principal ( Filial Atual )
If nTp == 1 .and. !FS_PARAM() // Parametros da Consulta
	Return()
EndIf
aVeicu := {}

ProcRegua(len(aFilVV1))

///////////////////////////////////////
// For das Filiais possiveis no VV1  //
///////////////////////////////////////
For nFil := 1 to Len(aFilVV1)
	
	IncProc(STR0016) // Levantando Veiculos...   
	
	If Empty(aFilVV1[nFil])
		Loop
	EndIf
	If !Empty(aParam[1])
		If aParam[1] <> aFilVV1[nFil]
			Loop
		EndIf
	EndIf

	cFilAnt := aFilVV1[nFil] // Multi Filial -> Muda cFilAnt para utilizar xFilial dos arquivos

	cVV1Fil := xFilial("VV1")
	cVQ0Fil := xFilial("VQ0")
	cVV2Fil := xFilial("VV2")
	cVVCFil := xFilial("VVC")
	cVVFFil := xFilial("VVF") // Utiliza a filial do VVF pois a funcao FGX_AMOVVEI grava VV1_FILENT := xFilial("VVF")

	cQuery := "SELECT DISTINCT VV1.VV1_FILIAL , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_FILENT , VV1.VV1_FABMOD , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_PLAVEI , VV1.VV1_TRACPA , VV2.VV2_DESMOD , VVC.VVC_DESCRI "
	If lVV1_DTFATT
		cQuery += " , VV1.VV1_DTFATT "
	EndIf
	cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
	cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+cVV2Fil+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+cVVCFil+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VV1.VV1_FILIAL='"+cVV1Fil+"' AND "
	If aParam[9] == "0" // Estoque/Transito
		cQuery += "VV1.VV1_SITVEI IN ('0','2') AND " // Estoque/Transito
	Else // Pedido
		cQuery += "VV1.VV1_SITVEI='8' AND " // Pedido
	EndIf
	If !Empty(aParam[3])
		cQuery += "VV1.VV1_CODMAR='"+aParam[3]+"' AND "
	EndIf
	If !Empty(aParam[4])
		cQuery += "VV1.VV1_MODVEI='"+aParam[4]+"' AND "
	EndIf
	If !Empty(aParam[5])
		cQuery += "VV1.VV1_ESTVEI='"+aParam[5]+"' AND "
	EndIf
	cQuery += "VV1.VV1_FILENT='"+cVVFFil+"' AND VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHAINT "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		If _cVV1 # ( cQAlSQL )->( VV1_CHAINT )
			_cVV1   := ( cQAlSQL )->( VV1_CHAINT )
			dDtConf := dDataBase
			nVlrCpa := 0
			nDiaCar := 0
			If ( cQAlSQL )->( VV1_SITVEI ) == "0" // Estoque
				If Empty(( cQAlSQL )->( VV1_TRACPA ))
					( cQAlSQL )->( DbSkip() )
					Loop
				EndIf
				// Posicionamento no VVF / VVG //
				cQuery := "SELECT VVF.VVF_DATEMI , VVG.VVG_VCNVEI , VVG.VVG_DIACAR FROM "+RetSqlName("VVF")+" VVF "
				cQuery += "INNER JOIN "+RetSqlName("VVG")+" VVG ON ( VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVG.D_E_L_E_T_=' ' ) "
				cQuery += "WHERE VVF.VVF_FILIAL='"+( cQAlSQL )->( VV1_FILENT )+"' AND VVF.VVF_TRACPA='"+( cQAlSQL )->( VV1_TRACPA )+"' AND VVG.VVG_CHAINT='"+( cQAlSQL )->( VV1_CHAINT )+"' AND VVF.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
				If !( cQAlAux )->( Eof() )
					dDtConf := stod(( cQAlAux )->( VVF_DATEMI ))
					nVlrCpa := ( cQAlAux )->( VVG_VCNVEI )
					nDiaCar := ( cQAlAux )->( VVG_DIACAR )
				Endif
				( cQAlAux )->( dbCloseArea() )
			ElseIf ( cQAlSQL )->( VV1_SITVEI ) == "2" // Transito
				nDiaCar := aParam[8]
				If lVV1_DTFATT .and. !Empty(( cQAlSQL )->( VV1_DTFATT ))
					dDtConf := stod(( cQAlSQL )->( VV1_DTFATT ))
				EndIf
			ElseIf ( cQAlSQL )->( VV1_SITVEI ) == "8" // Pedido
				nDiaCar  := aParam[8]
				If !Empty(( cQAlSQL )->( VV1_CHASSI ))
					aQUltMov := FM_VEIUMOV( ( cQAlSQL )->( VV1_CHASSI ) , "E" , )
					If len(aQUltMov) > 0
						( cQAlSQL )->( DbSkip() )
						Loop
					EndIf
				EndIf
				dDtConf := ctod("")
				cQuery  := "SELECT VQ0.VQ0_DATCON FROM "+RetSqlName("VQ0")+" VQ0 "
				cQuery  += "WHERE VQ0.VQ0_FILIAL='"+cVQ0Fil+"' AND VQ0.VQ0_CHAINT='"+( cQAlSQL )->( VV1_CHAINT )+"' AND VQ0.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
				If !( cQAlAux )->( Eof() )
					dDtConf := stod(( cQAlAux )->( VQ0_DATCON ))
				EndIf
				( cQAlAux )->( dbCloseArea() )
				If Empty(dDtConf)
					( cQAlSQL )->( DbSkip() )
					Loop
				EndIf
            EndIf
			If aParam[6] <= dDtConf .and. aParam[7] >= dDtConf
				If ( cQAlSQL )->( VV1_SITVEI ) <> "8" // Diferente de Pedido
					nDiasEst := ( dDataBase - dDtConf )
					nEstouro := ( nDiaCar - nDiasEst )
				Else
					nDiasEst := 0
					nEstouro := ( ( ( dDtConf + nDiaCar ) - aParam[2] ) - dDataBase )
				EndIf
				cVeicu   := Alltrim(X3CBOXDESC("VV1_SITVEI",( cQAlSQL )->( VV1_SITVEI )))+" - "+Alltrim(X3CBOXDESC("VV1_ESTVEI",( cQAlSQL )->( VV1_ESTVEI )))
				nVlrVda  := FGX_VLRSUGV( ( cQAlSQL )->( VV1_CHAINT ) , ( cQAlSQL )->( VV1_CODMAR ) , ( cQAlSQL )->( VV1_MODVEI ) , ( cQAlSQL )->( VV1_SEGMOD ) , ( cQAlSQL )->( VV1_CORVEI ) , .t. )
				aAdd(aVeicu,{IIf(nEstouro>aParam[2],"1",IIf(nEstouro<0,"3","2")),nEstouro,nDiaCar,nDiasEst,cVeicu,( cQAlSQL )->( VV1_CODMAR ),left(Alltrim(( cQAlSQL )->( VV1_MODVEI ))+" - "+( cQAlSQL )->( VV2_DESMOD ),33),left(( cQAlSQL )->( VVC_DESCRI ),18),( cQAlSQL )->( VV1_CHASSI ),( cQAlSQL )->( VV1_FABMOD ),( cQAlSQL )->( VV1_PLAVEI ),dDtConf,nVlrCpa,( cQAlSQL )->( VV1_FILENT ),nVlrVda, ( cQAlSQL )->( VV1_CHAINT )})
			EndIf
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( dbCloseArea() )
Next
cFilAnt := cBkpFil // Volta cFilAnt principal ( Filial Atual )
// Ordem ListBox de Veiculos: Decrescente ( Dias Estouro )
Asort(aVeicu,,,{|x,y| x[2] < y[2] })
If len(aVeicu) <= 0
	aAdd(aVeicu,{"3",0,0,0,"","","","","","","",ctod(""),0,"",0, ""})
EndIf
If nTp == 1
	oLbVeic:nAt   := 1
	oLbVeic:SetArray(aVeicu)
	oLbVeic:bLine := { || { IIf(aVeicu[oLbVeic:nAt,01]=="1",oVerd,IIf(aVeicu[oLbVeic:nAt,01]=="2",oAmar,oVerm)) ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,02],"@E 9,999,999")) ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,03],"@E 9,999,999")) ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,04],"@E 9,999,999")) ,;
							aVeicu[oLbVeic:nAt,05] ,;
							aVeicu[oLbVeic:nAt,06]+" "+aVeicu[oLbVeic:nAt,07] ,;
							aVeicu[oLbVeic:nAt,08] ,;
							aVeicu[oLbVeic:nAt,09] ,;
							Transform(aVeicu[oLbVeic:nAt,10],"@R 9999/9999") ,;
							Transform(aVeicu[oLbVeic:nAt,11],VV1->(X3PICTURE("VV1_PLAVEI"))) ,;
							Transform(aVeicu[oLbVeic:nAt,12],"@D") ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,13],"@E 9,999,999.99")) ,;
							aVeicu[oLbVeic:nAt,14] ,;
							FG_AlinVlrs(Transform(aVeicu[oLbVeic:nAt,15],"@E 9,999,999.99")) }}
	oLbVeic:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PARAM ³ Autor ³ Andre Luis Almeida         ³ Data ³ 25/10/11 ³±±
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
Local aTipVeic  := {"0="+STR0030,"1="+STR0031} // Estoque/Transito / Pedido
Local aEstVeic  := {" ","0="+Alltrim(X3CBOXDESC("VV1_ESTVEI","0")),"1="+Alltrim(X3CBOXDESC("VV1_ESTVEI","1"))}
AADD(aParamBox,{2,STR0015,aParam[1],aFilVV1,80,"",.f.})												// Filial
AADD(aParamBox,{1,STR0022,aParam[2],"@E 99999999",'MV_PAR02>=0',"","",25,.f.})						// Qtd de dias antes do limite
AADD(aParamBox,{1,STR0005,aParam[3],"@!",'Empty(MV_PAR03) .or. FG_Seek("VE1","MV_PAR03",1)',"VE1","",25,.f.}) 		// Marca
AADD(aParamBox,{1,STR0023,aParam[4],"@!",'Empty(MV_PAR04) .or. FG_Seek("VV2","MV_PAR03+MV_PAR04",1)',"VV2","",80,.f.})// Modelo
AADD(aParamBox,{2,STR0024,aParam[5],aEstVeic,80,"",.f.}) 												// Estado do Veiculo
AADD(aParamBox,{1,STR0025,aParam[6],"@D",'Empty(MV_PAR06) .or. MV_PAR06 <= dDataBase',"","",48,.f.})	// Data Inicial de Compra
AADD(aParamBox,{1,STR0026,aParam[7],"@D",'MV_PAR07 >= MV_PAR06',"","",48,.f.})						// Data Final de Compra
AADD(aParamBox,{1,STR0027,aParam[8],"@E 99999999",'MV_PAR08>=0',"","",25,.f.})						// Carencia Transito/Pedido
AADD(aParamBox,{2,STR0032,aParam[9],aTipVeic,80,"",.f.}) 												// Tipo do Veiculo
If ParamBox(aParamBox,STR0028,@aRet,,,,,,,,.f.) // Parametros
	lRet   := .t.
	aParam := aClone(aRet) // Parametros do Filtro
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR³ Autor ³  Andre Luis Almeida  ³ Data ³ 26/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Ponto de Equilibrio do Estoque                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local ni       := 0
Local cQuebra  := ""
Private cDesc1 := ""
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "G"
Private limite := 220
Private cString:= "VV1"
Private titulo := STR0001 // Consulta Ponto de Equilibrio do Estoque
Private cabec1 := 	left(STR0028+space(14),14)+" "+;									// Parametros
					left(STR0015+": "+aParam[1]+space(24),24)+" "+;					// Filial
					left(STR0022+": "+Alltrim(str(aParam[2]))+space(41),41)+" "+;		// Qtd de dias antes do limite
 					left(STR0004+": "+IIf(!Empty(aParam[5]),Alltrim(X3CBOXDESC("VV1_ESTVEI",aParam[5]))+" ","")+aParam[3]+" "+aParam[4]+space(57),57)+" "+; // Veiculo
					left(STR0029+": "+Transform(aParam[6],"@D")+" - "+Transform(aParam[7],"@D")+space(37),37)+" "+;	// Compra
					left(STR0027+": "+Alltrim(str(aParam[8]))+space(42),42)			// Carencia Transito/Pedido
Private cabec2 := 	right(space(14)+STR0002,14)+;					// Dias p/Estouro
					right(space(14)+STR0017,14)+;					// Dias Carencia
					right(space(14)+STR0003,14)+" "+;				// Dias Estoque
					left(STR0004+space(20),20)+" "+;				// Veiculo
					left(STR0005+"/"+STR0023+space(38),38)+" "+;	// Marca/Modelo
					left(STR0006+space(15),15)+" "+;				// Cor
					left(STR0007+space(22),22)+" "+;				// Chassi 
					left(STR0013+space(10),10)+" "+;				// Fab/Mod 
					left(STR0008+space(10),10)+" "+;				// Placa 
					left(STR0009+space(10),10)+" "+;				// Dt Compra 
					right(space(14)+STR0010,14)+" "+;				// Vlr Compra
					left(STR0015+space(15),15)+" "+;				// Filial
					right(space(14)+STR0014,14)						// Vlr Venda
Private aReturn:= {"",1,"",1,2,1,"",1}  
Private nomeprog:= "VEIVC240"
Private nLastKey:= 0
nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf     
SetDefault(aReturn,cString)
nLin  := 60
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
For ni := 1 to len(aVeicu)
	If nLin >= 58
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	EndIf
	If cQuebra <> aVeicu[ni,01]
		cQuebra := aVeicu[ni,01]
		nLin++
		@ nLin++, 00 PSAY STR0018+" "+IIf(cQuebra=="3",STR0019,IIf(cQuebra=="2",STR0020,STR0021)) // Risco: / Critico / Limite / Baixo
		nLin++
	EndIf
	@ nLin++, 00 PSAY 	Transform(aVeicu[ni,02],"@E 99,999,999,999")+;						// Dias p/Estouro
						Transform(aVeicu[ni,03],"@E 99,999,999,999")+;						// Dias Carencia
						Transform(aVeicu[ni,04],"@E 99,999,999,999")+" "+;					// Dias Estoque
						left(aVeicu[ni,05]+space(20),20)+" "+;								// Veiculo
						left(Alltrim(aVeicu[ni,06])+" "+aVeicu[ni,07]+space(38),38)+" "+; // Marca/Modelo
						left(aVeicu[ni,08]+space(15),15)+" "+;								// Cor
						left(aVeicu[ni,09]+space(22),22)+" "+;								// Chassi
						left(Transform(aVeicu[ni,10],"@R 9999/9999")+space(10),10)+" "+;	// Fab/Mod
						left(Transform(aVeicu[ni,11],VV1->(X3PICTURE("VV1_PLAVEI")))+space(10),10)+" "+;	// Placa
						left(Transform(aVeicu[ni,12],"@D")+space(10),10)+" "+;				// Dt Compra
						Transform(aVeicu[ni,13],"@E 999,999,999.99")+" "+;					// Vlr Compra
						left(aVeicu[oLbVeic:nAt,14]+space(15),15)+" "+;					// Filial
						Transform(aVeicu[ni,15],"@E 999,999,999.99")						// Vlr Venda
Next
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return()