// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "PROTHEUS.CH"
#include "VEIVC260.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  04/12/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007481_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VEIVC260  ºAutor  ³Renato Vinicius     º Data ³  12/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta de Veiculos Entrada e Saida por Remessa            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculo                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC260()

Local nTam      := 0
Local aFilAtu   := {}
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cChaveCha := space(VV1->(TamSx3("VV1_CHASSI")[1]))
Local dDatIni   := Ctod("")
Local dDatFin   := dDataBase

Private aFilVV1    := {}
Private aVeicu     := {}
Private aTipVeic   := {"0="+STR0010,"1="+STR0011,"2="+STR0012} // Entrada / Saida / Todos
Private cTipVeic   := "2"
Private nQtdDiaRet := 0

aFilAtu := FWArrFilAtu()
aFilVV1 := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
aAdd( aFilVV1 , "" )
Asort(aFilVV1)

aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 020 , .T. , .F. } ) // Filtro
aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox 
aPos := MsObjSize( aInfo, aObjects )
Processa( {|| FS_FILTRA(0) } )
DEFINE MSDIALOG oPEquEstq FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0002 OF oMainWnd PIXEL // "Consulta Remessa de Veiculos"

	oPEquEstq:lEscClose := .F.

	@ aPos[1,1],aPos[1,2] TO aPos[1,3],140 LABEL "" OF oPEquEstq PIXEL
	@ aPos[1,1]+005,007 MSGET oChaveCha VAR cChaveCha PICTURE "@!" SIZE 95,08 OF oPEquEstq PIXEL
	@ aPos[1,1]+005,105 BUTTON oPesq PROMPT STR0001 OF oPEquEstq SIZE 30,10 PIXEL ACTION ( FS_PESQ(cChaveCha) ) // Pesquisar
	@ aPos[1,1],145       TO aPos[1,3],420 LABEL "" OF oPEquEstq PIXEL
	@ aPos[1,1]+005,150 MSCOMBOBOX oFilTot VAR cTipVeic SIZE 90,08 COLOR CLR_BLACK ITEMS aTipVeic OF oPEquEstq  PIXEL
	@ aPos[1,1]+007,250 SAY STR0014 SIZE 45,08 OF oPEquEstq PIXEL  // Movimento de
	@ aPos[1,1]+005,287 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE 40,08 OF oPEquEstq PIXEL
	@ aPos[1,1]+007,330 SAY STR0015 SIZE 45,08 OF oPEquEstq PIXEL // até
	@ aPos[1,1]+005,342 MSGET oDatFin VAR dDatFin PICTURE "@D" SIZE 40,08 OF oPEquEstq PIXEL
	@ aPos[1,1]+005,385 BUTTON oFiltro PROMPT STR0016 OF oPEquEstq SIZE 30,10 PIXEL ACTION ( FS_FILTRA(1,dDatIni,dDatFin) ) // Filtrar
	@ aPos[1,1],425       TO aPos[1,3],520 LABEL "" OF oPEquEstq PIXEL
	@ aPos[1,1]+007,430 SAY STR0013 SIZE 90,08 OF oPEquEstq PIXEL // Qtd de dias para retorno
	@ aPos[1,1]+005,495 MSGET oQTDDR VAR nQtdDiaRet Valid FS_FILTRA(2) PICTURE "@E 999" SIZE 18,08 OF oPEquEstq PIXEL 
	
	@ aPos[2,1],aPos[2,2] LISTBOX oLbVeic FIELDS HEADER STR0003 ,; // Tipo de Movimento
							STR0004 ,; // Data
							STR0005 ,; // Chassi
							STR0006 ,; // Marca
							STR0007 ,; // Modelo
							STR0008 ,; // Prazo Retorno
							COLSIZES 60,60,60,50,40,60 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oPEquEstq PIXEL ON DBLCLICK IIF(!Empty(aVeicu[oLbVeic:nAt,03]),VEIVC140(aVeicu[oLbVeic:nAt,03], aVeicu[oLbVeic:nAt, LEN(aVeicu[oLbVeic:nAt])] ),.t.)
	oLbVeic:SetArray(aVeicu)
	oLbVeic:bLine := { || {	aVeicu[oLbVeic:nAt,01],;
							Transform(aVeicu[oLbVeic:nAt,02],"@D") ,;
							aVeicu[oLbVeic:nAt,03] ,;
							aVeicu[oLbVeic:nAt,04] ,;
							aVeicu[oLbVeic:nAt,05] ,;
							Transform(aVeicu[oLbVeic:nAt,06],"@D") }}

ACTIVATE MSDIALOG oPEquEstq ON INIT EnchoiceBar(oPEquEstq, { || oPEquEstq:End() },{|| oPEquEstq:End() },,)

SetKey(VK_F12,Nil)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRA³ Autor ³  Renato Vinicius      ³ Data ³ 12/05/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra/Levanta Veiculos                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRA(nTp, dDatInic, dDatFini)
Local aQUltMov:= {}
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
Local lVV1_DTFATT := VV1->(FieldPos("VV1_DTFATT")) <> 0
Local cVV1Fil := ""
Local cVV2Fil := ""
Local cVVFFil := ""
Local nFil    := 0
Local nAtuQDR := 0
Local dDtConf := dDataBase
Local cTipoES := ""
Local cBkpFil := cFilAnt // Salva cFilAnt principal ( Filial Atual )
local nj

Default dDatInic := Ctod("")
Default dDatFini := Ctod("")

If nTp <> 2 // processa o campo Qtd de dias para Retorno
	aVeicu := {}
Endif

ProcRegua(len(aFilVV1))

///////////////////////////////////////
// For das Filiais possiveis no VV1  //
///////////////////////////////////////
For nFil := 1 to Len(aFilVV1)
	
	If nTp == 2 // processa o campo Qtd de dias para Retorno

		For nAtuQDR := 1 to Len(aVeicu)
				aVeicu[nAtuQDR,6] := aVeicu[nAtuQDR,2]+nQtdDiaret
		Next

	Else // Faz o levantamento das Remessas

		IncProc(STR0009) // Levantando Veiculos...   
		
		cTipoES := ""
		dDtConf := dDataBase
				
		cFilAnt := aFilVV1[nFil] // Multi Filial -> Muda cFilAnt para utilizar xFilial dos arquivos

		cVV1Fil := xFilial("VV1")
		cVV2Fil := xFilial("VV2")
		cVVFFil := xFilial("VVF") // Utiliza a filial do VVF pois a funcao FGX_AMOVVEI grava VV1_FILENT := xFilial("VVF")

		cQuery := "SELECT DISTINCT VV1.VV1_FILIAL , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_FILENT , VV1.VV1_FABMOD , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_PLAVEI , VV1.VV1_TRACPA , VV2.VV2_DESMOD "
		If lVV1_DTFATT
			cQuery += " , VV1.VV1_DTFATT "
		EndIf
		cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
		cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+cVV2Fil+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VV1.VV1_FILIAL='"+cVV1Fil+"' AND "
		cQuery += "VV1.VV1_SITVEI IN ('3') AND VV1.VV1_TRACPA<>' ' AND " // Remessa	
		cQuery += "VV1.VV1_FILENT='"+cVVFFil+"' AND VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHAINT "
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		
		While !( cQAlSQL )->( Eof() )
			lMostra := .f.

			aQUltMov := FGX_VEIMOVS( ( cQAlSQL )->( VV1_CHASSI ) , , )
			For nj := 1 to len(aQUltMov)
				cTipoES := aQUltMov[nj,1]
				dDtConf := aQUltMov[nj,6]
				If aQUltMov[nj,1]=="E" 		// Entrada
					Exit
				ElseIf aQUltMov[nj,1]=="S"	// Saida por Remessa
					If len(aQUltMov) >= ( nj+1 )
						If aQUltMov[nj+1,1]=="S" // Saida por Venda
							If aQUltMov[nj+1,5]=="0" // Venda
								Loop
							EndIf
						EndIf
					EndIf
					Exit
				EndIf
			Next

			If cTipVeic == "2" .or.; // Entrada e Saida por Remessa
				cTipoES == "E" .and. cTipVeic == "0" .or.; //Entrada por Remessa
				cTipoES == "S" .and. cTipVeic == "1" // Saida por Remessa
				lMostra := .t.
			EndIf
	
			If lMostra

				If !Empty(dDatInic) .and. dDatInic > dDtConf
						( cQAlSQL )->( DbSkip() )
						Loop
				Endif

				If !Empty(dDatFini) .and. dDatFini < dDtConf
						( cQAlSQL )->( DbSkip() )
						Loop
				Endif
				
				aAdd(aVeicu,{If(cTipoES == "E",STR0010,STR0011),;
				dDtConf,;
				( cQAlSQL )->( VV1_CHASSI ),;
				( cQAlSQL )->( VV1_CODMAR ),;
				left(Alltrim(( cQAlSQL )->( VV1_MODVEI ))+" - "+( cQAlSQL )->( VV2_DESMOD ),33),;
				dDtConf+nQtdDiaret, ( cQAlSQL )->( VV1_CHAINT ) })

			EndIf
			
			( cQAlSQL )->( DbSkip() )

		EndDo

		( cQAlSQL )->( dbCloseArea() )

	Endif

Next
cFilAnt := cBkpFil // Volta cFilAnt principal ( Filial Atual )
// Ordem ListBox de Veiculos: Decrescente ( Dias Estouro )
Asort(aVeicu,,,{|x,y| x[2] < y[2] })
If len(aVeicu) <= 0
	aAdd(aVeicu,{"",ctod(""),"","","",ctod(""), ""})
EndIf
If nTp <> 0
	oLbVeic:nAt   := 1
	oLbVeic:SetArray(aVeicu)
	oLbVeic:bLine := { || {	aVeicu[oLbVeic:nAt,01],;
							Transform(aVeicu[oLbVeic:nAt,02],"@D") ,;
							aVeicu[oLbVeic:nAt,03] ,;
							aVeicu[oLbVeic:nAt,04] ,;
							aVeicu[oLbVeic:nAt,05] ,;
							Transform(aVeicu[oLbVeic:nAt,06],"@D") }}
	oLbVeic:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PESQ  ³ Autor ³ Renato Vinicius            ³ Data ³ 12/05/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa chassi dentro da listbox                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQ(cChaveCha)

Default cChaveCha := space(VV1->(TamSx3("VV1_CHASSI")[1]))

cTamPesq := Len(Alltrim(cChaveCha))
nCntFor := aScan(aVeicu,{|x,y| Subs(x[3],1,cTamPesq) == alltrim(cChaveCha)})
	
oLbVeic:nAt := If(nCntFor = 0, 1, nCntFor)
oLbVeic:Refresh()

Return

