// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 20     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "protheus.ch"
#Include "TopConn.ch"
#Include "OFIGM070.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIGM070 ³ Autor ³ Antonio               ³ Data ³ 18/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao na Garantia Solicitada MF                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MODELO 3                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GARANTIA MASSEY FERGUSSON                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OFIGM070(cCodMar,cNumOsv,nOpc)

Private cIndex, cChave, cCond
PRIVATE aMemos  := {{"VG8_OBSMEM","VG8_OBSERV"}}

Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := STR0001 //"Garantia Massey Ferguson"
Private nIndex    := 0
Private cParMF    := GetNewPar("MV_GARMAFE","MF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("VGG")
DbSetOrder(1)

DbSelectArea("VG8")
DbSetOrder(3)

cIndex := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := 'VG8_EXPGAR=="S" .AND. ALLTRIM(VG8_CODMAR)==ALLTRIM(cParMF)'
IndRegua("VG8",cIndex,cChave,,cCond,STR0002) //"Aguarde, filtrando registros..."


DbSelectArea("VG8")
nIndex := RetIndex("VG8")+1
#IFNDEF TOP
	DbSetIndex(cIndex+ordBagExt())
#ENDIF
DbSetOrder(nIndex)

If cCodMar # NIL .And. cNumOsv # NIL
	DbSelectArea("VG8")
	DbSetOrder(3)
	DbSeek( xFilial("VG8") + cCodMar + cNumOsv )
	GM070("VG8",RecNo(),nOpc)
Else
	mBrowse( 6, 1,22,75,"VG8"/*,,,,"VG8_TRANSM == 'N'"*/)
EndIf

DbSelectArea("VG8")
RetIndex("VG8")
DbSetOrder(3)
#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM070     ³ Autor ³Antonio                ³ Data ³ 25/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera e visualiza dados no VG8/VG6/VGG modelo 3            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM070(cAlias,nReg,nOpc)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM070(cAlias,nReg,nOpc)

Local bCampo      := { |nCPO| Field(nCPO) }
Local nCntFor     := 0
Local nCntFor1    := 0
Local nCntFor2    := 0

Local _ni         := 0
Local nFlag       := 0
Local aSizeAut	  := MsAdvSize(.t.)
Local aPOPri	  := {} // Divisao Principal da Tela
Local aPOEnc	  := {} // Parte da tela onde ficarao os Enchoices (VG8 e VGG)
Local aObjects    := {} // Objetos Principal da Tela
Local aObjEnchoice:= {} // Objetos Enchoices (VG8 e VGG)
Local cATela      := ""
Private nUsado      := 0
Private aAlter      := {}
Private aCpos       := {}
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private cCpoAPeca   :="VG6_CODSER/VG6_DESSER/VG6_SERINT/VG6_TPOGAR"
Private cCpoASrv    :="VG6_GRUITE/VG6_CODITE/VG6_DESITE/VG6_PECINT/VG6_QTDITE/VG6_VALITE"
Private aCols       := {} , aHeader := {} , aCpoEnchVG8 := {}, aCpoEncRet := {}
Private naCols		:= 0
Private aControleG  := {}
Private aCtrCpoEnch := {} ,aCtrCpoE1 := {},  oEnchVG8, oEnchVGG, oDlg ,oDlgRet, oBox
Private aSavVGG     := {} // Salva Carta de Crécito por RO
Private nMax        := 1
//Private aTELA[0][0],aGETS[0]

If nIndex <= 0
	nIndex := 3
EndIf

DbSelectArea("VG8")
If nOpc # 3 .And. !&(cCond)
	DbSetOrder(nIndex)
	Return
EndIf

DbSetOrder(nIndex)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VG8",.t.)         // .t. para carregar campos virtuais

aCpoEnchVG8:={}

DbSelectArea("SX3")
DbSetOrder(1)                                              
DbSeek("VG8")

While !Eof().and.(x3_arquivo=="VG8")
	If X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VG8_ESPGAR/VG8_CODREV/VG8_GRUREV/;
		VG8_DNRESP/VG8_IMPOSV/VG8_SERIEN/VG8_TRANSM/VG8_ARQFAB/VG8_DATRET/VG8_DATTRA/VG8_VALCRE/VG8_TTPKST/;
		VG8_LANCRE/VG8_DATDEB/VG8_VALDEB/VG8_LANDEB/VG8_CODEST/VG8_DIFPGT/VG8_SITOSV/VG8_TRANSM/VG8_SERIEN/;
		VG8_SITUAC/VG8_EXPGAR/VG8_SERCON/VG8_TIPCON/VG8_CODCAM/VG8_TESCPO/VG8_KILPIC/VG8_KILGUI/VG8_ITEPGT/;
		VG8_SERPGT/VG8_DATEST/VG8_ITEEST/VG8_SEREST/VG8_NFIENT/VG8_CODPLU/VG8_SERENT/VG8_REPANT/VG8_NUMRRC/;
		VG8_ANORRC/VG8_DATDIS/VG8_NF1REM/VG8_NF2REM/VG8_RRCOLD/VG8_RRCNEW/VG8_VEIEXP/VG8_RECONS/VG8_SITRRC/;
		VG8_DESSIT/VG8_ITECAU/VG8_DESITE/VG8_SERINT/VG8_VLDACE/VG8_GRUSER/VG8_DESGRS/VG8_CODSER/VG8_GDWILL/;
		VG8_DESSER/VG8_GRUITE/VG8_DESGRU/VG8_PECINT/VG8_CODDEF/VG8_DESDEF/VG8_CODREC/VG8_DESREC/VG8_CODGAR/;
		VG8_DESGAR/VG8_MOTREC/VG8_MOTORE/VG8_KILANT/VG8_PRIREV/VG8_TIPONF/VG8_DTAANT/VG8_LIBVOP/VG8_LIBVOS])
		Aadd(aCpoEnchVG8,x3_campo)
	Endif
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.(Alltrim(x3_campo) $ [VG8_NUMOSV/VG8_CODMAR/VG8_ABEGAR/VG8_OBSERV/VG8_NFCRED/VG8_PORAPC/VG8_SERNFC/VG8_DATCRE/VG8_VALITE/VG8_PORAPC/VG8_VALSER/VG8_VLKMCA/VG8_VLRSET/VG8_DATNFI/VG8_NUMNFI/VG8_SERNFI])
		IF SX3->X3_VISUAL <> "V"
			Aadd(aCpos,SX3->X3_CAMPO)
		EndIf
	EndIf
	
	&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
	
	DbSkip()
End

If nOpc # 3
	DbSelectArea("VG8")
	DbSetOrder(3)
	
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

&& Carrega vetor de controle da enchoice
Aadd(aCtrCpoEnch,{ .t. , CriaVar("VG8_ANORRC")+CriaVar("VG8_NUMRRC"),{}})
Aadd(aCtrCpoEnch,{ .t. , VG8->VG8_ANORRC+VG8->VG8_NUMRRC            ,{}})
For nCntFor:=1 to Len(aCpoEnchVG8)
	Aadd( aCtrCpoEnch[1,3] , M->&(aCpoEnchVG8[nCntFor]) )
	Aadd( aCtrCpoEnch[2,3] , M->&(aCpoEnchVG8[nCntFor]) )
Next


aCpoEncRet:={}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VGG")

While !Eof().and.(x3_arquivo=="VGG")
	If X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VGG_NUMOSV])
		Aadd(aCpoEncRet,x3_campo)
	Endif
	
	&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
	
	DbSkip()
End

If nOpc # 3
	DbSelectArea("VGG")
	DbSetOrder(1)
	For nCntFor1 := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor1)) := FieldGet(nCntFor1)
	Next
Endif

&& Carrega vetor de controle da enchoice 1
Aadd(aCtrCpoE1,{ .t. , CriaVar("VGG_NUMOSV")+CriaVar("VGG_ANORO")+CriaVar("VGG_NUMRO"),{}})
Aadd(aCtrCpoE1,{ .t. , VGG->VGG_NUMOSV+VGG->VGG_ANORO+VGG->VGG_NUMRO ,{}})
For nCntFor1:=1 to Len(aCpoEncRet)
	Aadd( aCtrCpoE1[1,3] , M->&(aCpoEncRet[nCntFor1]) )
	Aadd( aCtrCpoE1[2,3] , M->&(aCpoEncRet[nCntFor1]) )
Next

If nOpc  == 3      //INCLUIR
	nOpcE := 3
	nOpcG := 3
Elseif nOpc == 4   //ALTERAR
	nOpcE := 4
	nOpcG := 4
Elseif nOpc == 2   //VIZUALIZAR
	nOpcE := 2
	nOpcG := 2
Else
	nOpcE := 5      //EXCLUIR
	nOpcG := 5
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0

DbSelectArea("SX3")
DbSeek("VG6")

aHeader    :={}

While !Eof().And.(x3_arquivo=="VG6")
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VG6_CODMAR/VG6_DESMAR/VG6_DESGRU/VG6_TRANSM/;
		VG6_NFIENT/VG6_SERENT/VG6_ITEEXT/VG6_SEREXT/VG6_RRCOLD/VG6_ANOANT/VG6_RRCANT/;
		VG6_RRCNEW/VG6_RRCOLD/VG6_ANOANT/VG6_RRCANT/VG6_RRCNEW/VG6_NOSNUS/VG6_NOSNUP/;
		VG6_USUEXC/VG6_HOREXC/VG6_DATEXC/VG6_ORDENS/VG6_PECINT/VG6_NOSNUP/VG6_SERINT/;
		VG6_TPOGAR/VG6_EXCLUI/VG6_TIPTEM/VG6_RENNF2/VG6_ITEMNF/VG6_NUMOSV/VG6_TPCUST/VG6_LIBVOO])
		
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		
		If AllTrim(aHeader[nUsado,2])=="VG6_ANORRC"
			aHeader[nUsado,1]:="Ano RO"
		Endif
		
		If AllTrim(aHeader[nUsado,2])=="VG6_NUMRRC"
			aHeader[nUsado,1]:="Nro RO"
		Endif
		
		If AllTrim(aHeader[nUsado,2])=="VG6_GRUITE"
			aHeader[nUsado,1]:="Grupo"
		Endif
		
		If AllTrim(aHeader[nUsado,2])=="VG6_CODITE"
			aHeader[nUsado,3]:="@!S10"
		Endif
		
		If AllTrim(aHeader[nUsado,2])=="VG6_DESITE"
			aHeader[nUsado,3]:="@!S20"
		Endif
		
		If AllTrim(aHeader[nUsado,2])=="VG6_QTDITE"
			aHeader[nUsado,1]:="Qtde"
			aHeader[nUsado,3]:="@E 99999"
		Endif
		
		If AllTrim(aHeader[nUsado,2])=="VG6_VALITE"
			aHeader[nUsado,3]:="@E 999,999.99"
		Endif
		
		If AllTrim(aHeader[nUsado,2])=="VG6_CODSER"
			aHeader[nUsado,1]:=STR0013
		Endif
		
	Endif
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.(Alltrim(x3_campo) $ [VG6_ANORRC/VG6_NUMRRC])
		IF SX3->X3_VISUAL <> "V"
			Aadd(aAlter,SX3->X3_CAMPO)
		EndIf
	EndIf
	
	&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
	DbSkip()
	
End

Aadd(aControleG ,{}) && GetDados Normal

If nOpc # 3
	
	aCols :={}
	DbSelectArea("VG6")
	DbSetOrder(6)
	DbSeek(xFilial()+M->VG8_CODMAR+M->VG8_NUMOSV)
	
	While !Eof() .And. VG6->VG6_CODMAR+VG6->VG6_NUMOSV == M->VG8_CODMAR+M->VG8_NUMOSV .And. VG6->VG6_FILIAL == xFilial("VG6")
		
		&& Pecas e servico normal
		If VG6->VG6_ITEEXT == "0"  .Or. VG6->VG6_SEREXT == "0" ;
			.Or. Empty(VG6->VG6_ITEEXT) .And. Empty(VG6->VG6_SEREXT)
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] == "V" .Or.;
				( ( VG6->VG6_ITEEXT == "1" .And. (Alltrim(aHeader[_ni,2]) $ cCpoAPeca) ) .Or. ;
				( VG6->VG6_SEREXT == "1" .And. (Alltrim(aHeader[_ni,2]) $ cCpoASrv) ) ) ,;
				CriaVar(aHeader[_ni,2]),;
				FieldGet(FieldPos(aHeader[_ni,2])))
			Next
			
			aCols[Len(aCols),nUsado+1]:=.F.
			
			&& Controle de registro para gravacao
			Aadd(aControleG[1], RecNo() )
			
		EndIf
		
		DbSelectArea("VGG")
		DbSetOrder(1)
		If DbSeek(xFilial("VGG")+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC)
			AADD(aSavVGG,Array(Len(aCpoEncRet)))
			
			For nCntFor2 := 1 TO Len(aCpoEncRet)
				aSavVGG[Len(aSavVGG),nCntFor2] := VGG->&(aCpoEncRet[nCntFor2])
			Next
			
			nPos := Ascan(aSavVGG,{ |x| x[1]+x[2] == VG6->VG6_NUMRRC+VG6->VG6_ANORRC })
			For nCntFor := 1 TO FCount()
				M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
			Next
			
			For nCntFor := 1 TO Len(aCpoEncRet)
				If nPos == 0
					aSavVGG[Len(aSavVGG),nCntFor] := M->&(aCpoEncRet[nCntFor])
				Endif
			Next
			
		EndIf
		
		DbSelectArea("VG6")
		DbSetOrder(6)
		DbSkip()
		
	EndDo
	/*Else
	DbSelectArea("VGG")
	For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := CriaVar(nCntFor)
	Next
	*/
Endif

naCols := Len(aCols)

If Len(aCols) == 0
	
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	
EndIf

//aSort(aCols   ,,,{|x,y| x[FG_POSVAR("VG6_CODSER","aHeader")]+x[FG_POSVAR("VG6_GRUITE","aHeader")]+x[FG_POSVAR("VG6_CODITE","aHeader")] < y[FG_POSVAR("VG6_CODSER","aHeader")]+y[FG_POSVAR("VG6_GRUITE","aHeader")]+y[FG_POSVAR("VG6_CODITE","aHeader")] })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo        := STR0003 //"Garantia Solicitada MF"
cAliasEncRet   := "VGG"
cAliasEnchoice := "VG8"
cAliasGetD     := "VG6"
cLinOk         := "OFGM70()"
cTudOk         := "FG_OBRIGAT() .AND. FS_070TUDOK()"
cFieldOk       := "FG_MEMVAR() .AND. FS_070CODINT() .AND. OFGM70('VG6_NUMRRC')"

nOpca := 0
DbSelectArea("VG6")
DbSetOrder(6)

//DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 to 40,123	of oMainWnd
DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Variaveis para Configuracao da Janela Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD( aObjects, { 90,  135, .T., .F. } ) // Enchoices (VG8 e VGG)
AADD( aObjects, { 90,  135, .T., .T. } ) // MSGET VG6

AADD( aObjEnchoice, { 60,  30, .T., .T. } ) // Enchoice - VG8
AADD( aObjEnchoice, { 130,  70, .F., .T. } ) // Enchoice - VGG

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Divisao principal da Tela                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPOPri := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] ,aSizeAut[ 3 ] , aSizeAut[ 4 ] , 1 , 1 } , aObjects , .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicao das Enchoices                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPOEnc := MsObjSize( { aPOPri[1,2] , aPOPri[1,1] , aPOPri[1,4] , aPOPri[1,3] , 2, 2 } , aObjEnchoice , .T. , .T. )


@ aPOEnc[2,1],aPOEnc[2,2] FOLDER oFolderVGG SIZE aPOEnc[2,4]-aPOEnc[2,2], aPOEnc[2,3]-aPOEnc[2,1] OF oDlg PROMPTS STR0004 PIXEL //"Retorno - Carta Crédito"
@ aPOPri[2,1],aPOPri[2,2] FOLDER oFolderVG6 SIZE aPOPri[2,4]-aPOPri[2,2], aPOPri[2,3]-aPOPri[2,1] OF oDlg    PROMPTS "Peças/Serviços"  PIXEL //""Peças/Serviços""

///&& Abas do Folder
FG_INIFOLDER("oFolderVG6")
FG_INIFOLDER("oFolderVGG")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Enchoice da VG8³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oEnchVG8 := MSMGet():New("VG8",nReg, nOpcE ,;
/*aCRA*/, /*cLetra*/, /*cTexto*/, aCpoEnchVG8, aPOEnc[1], aCpos, 3,;
/*nColMens*/, /*cMensagem*/, /*cTudoOk*/, oDlg, /*lF3*/, .T./*lMemoria*/, .t. /*lColumn*/ ,;
caTela, .F. /*lNoFolder */, /*lProperty*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Enchoice da VGG³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnchVGG := MSMGet():New( "VGG", nReg, nOpcE ,;
/*aCRA*/, /*cLetra*/, /*cTexto*/, aCpoEncRet, aPOEnc[2], , 3,;
/*nColMens*/, /*cMensagem*/, /*cTudoOk*/, oFolderVGG:aDialogs[1], /*lF3*/, .t., .t. /*lColumn*/ ,;
caTela, .F. /*lNoFolder */, /*lProperty*/)
oEnchVGG:oBox:Align := CONTROL_ALIGN_ALLCLIENT

&& "Peças/Serviços"
aHeader := aClone( aHeader )
aCols   := aClone( aCols )

oGetVG6:= MsGetDados():New(1,1,105,475,nOpcG,cLinOk,cTudOk,"",.F.,aAlter,,,nMax:=Len(acols),cFieldOk,,,,oFolderVG6:aDialogs[1])
//oGetVG6:= MsGetDados():New(aPOPri[2,1],aPOPri[2,2],aPOPri[2,3],aPOPri[2,4],nOpcG,cLinOk,cTudOk,"",.F.,aAlter,,,nMax:=Len(acols),cFieldOk,,,,oFolderVG6:aDialogs[1])
oGetVG6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetVG6:oBrowse:bGotFocus := {|| FS_070CARREGA() }
oGetVG6:oBrowse:bLostFocus:= {|| FG_MEMVAR() , FS_070CARREGA() }
oGetVG6:oBrowse:bChange   := {|| /*FG_AALTER("VG6",naCols,oGetVG6) ,*/ FS_070CARREGA(), OFGM70("VOLTA") }

oGetVG6:oBrowse:nAt := 1    //boby - 07/01/11 - Controle da Aba da carta de crédito (Tabela VVG)
n := 1                      //boby
OFGM70("VOLTA")             //boby

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If( oGetVG6:TudoOk()/*.And.obrigatorio(aGets,aTela)*/.And.FS_GRAMS( nOpc ),(nOpca := 1,oDlg:End()),.f.) },{|| nOpca := 2, oDlg:End() } )

DbSelectArea("VG8")
DbSetOrder(nIndex)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRAMS  ºAutor  ³Fabio               º Data ³  08/16/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava dados VG8/VG6/VGG                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Garantia                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAMS( nOpc )

Local nPosI   := 0 , lAdd := .t. , nPosReg:=0
Local nFlag   := 0
Local nI      := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc # 2

	FG_MEMVAR()
	FS_070CARREGA()
	
	Begin Transaction
	
	&& Normal
	DbSelectArea("VG6")
	DbSetOrder(6)
	
	For nPosI :=1 to len(aCols)
		
		lAdd := .f.
		If nPosI > Len(aControleG[1])
			lAdd := .t.
		Else
			DbGoTo( aControleG[1,nPosI] )
		EndIf
		
		If ( nOpc == 3 .Or. nOpc == 4 ) .And. !aCols[nPosI,len(aCols[nPosI])] ;
			.And. ( !Empty(aCols[nPosI,FG_POSVAR("VG6_ANORRC")]) .And. !Empty(aCols[nPosI,FG_POSVAR("VG6_NUMRRC")]) )
			
			If (nPosReg:=Ascan(aCtrCpoEnch,{ |x| x[2] == aCols[nPosI,FG_POSVAR("VG6_ANORRC")]+aCols[nPosI,FG_POSVAR("VG6_NUMRRC")] })) # 0 ;
				.And. aCtrCpoEnch[nPosReg,1]
				
				aCols  :=aClone(aCols)
				aHeader:=aClone(aHeader)
				n      := nPosI
				
				FS_070CARREGA(,,"V")
				
				DbSelectArea("VG8")
				DbSetOrder(3)
				If DbSeek(xFilial("VG8")+M->VG8_NUMOSV+M->VG8_CODMAR)
					RecLock("VG8", .F. )
				Else
					RecLock("VG8", .T. )
				EndIf
				
				VG8->VG8_FILIAL := xFilial("VG8")
				VG8->VG8_TRANSM := "N"
				VG8->VG8_EXPGAR := "S"
				VG8->VG8_PORAPC := M->VG8_PORAPC
				VG8->VG8_NFCRED := M->VG8_NFCRED
				VG8->VG8_SERNFC := M->VG8_SERNFC
				VG8->VG8_VLRAPC := M->VG8_VLRAPC
				VG8->VG8_DATCRE := M->VG8_DATCRE
				
				For nI :=1 to len(aCpoEnchVG8[nPosReg])
					VG8->&(aCpoEnchVG8[nI]) := aCtrCpoEnch[1][3][nI]
				Next
				
				MSMM(,TamSx3("VG8_OBSERV")[1],,M->VG8_OBSERV,1,,,"VG8","VG8_OBSMEM")
				VG8->(MsUnlock())
				aCtrCpoEnch[nPosReg,1] := .f.
				
			EndIf
			
			DbSelectArea("VG6")
			dBSetOrder(6)
			RecLock("VG6", lAdd )
			If nOpc == 3
				FG_GRAVAR("VG6",aCols,aHeader,nPosI)
				VG6->VG6_FILIAL := xFilial("VG6")
				VG6->VG6_CODMAR := VG8->VG8_CODMAR
				VG6->VG6_NUMOSV := VG8->VG8_NUMOSV
				VG6->VG6_TRANSM := "N"
			ElseIf nOpc == 4
				VG6->VG6_FILIAL := xFilial("VG6")
				VG6->VG6_ANORRC := aCols[nPosI,FG_POSVAR("VG6_ANORRC")]
				VG6->VG6_NUMRRC := aCols[nPosI,FG_POSVAR("VG6_NUMRRC")]
			EndIf
			MsUnlock()
			
			nPos := Ascan(aSavVGG,{ |x| x[1]+x[2] == VG6->VG6_NUMRRC+VG6->VG6_ANORRC })
			If nPos # 0
				DbSelectArea("VGG")
				DbSetOrder(1)
				If DbSeek(xFilial("VGG")+M->VG8_NUMOSV+aSavVGG[nPos,2]+aSavVGG[nPos,1])
					RecLock("VGG", .F. )
				Else
					RecLock("VGG", .T. )
				EndIf
				
				VGG->VGG_FILIAL := xFilial("VGG")
				VGG->VGG_NUMOSV := M->VG8_NUMOSV
				
				For nI :=1 to len(aSavVGG[nPos])
					
					VGG->&(aCpoEncRet[ni]) := aSavVGG[nPos,nI]
				Next
				MsUnlock()
			EndIf
			
			DbSelectArea("VG6")
			DbSetOrder(6)
			dBSkip()
			
		ElseIf !lAdd
			
			RecLock("VG6",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VG6")
			
			DbSelectArea("VGG")
			DbSetOrder(1)
			DbSeek(xFilial("VGG")+M->VG8_NUMOSV)
			While !Eof() .AND. M->VG8_NUMOSV == VGG->VGG_NUMOSV .AND. xFilial("VGG") == VGG->VGG_FILIAL
				RecLock("VGG",.F.,.T.)
				dbdelete()
				MsUnlock()
				WriteSx2("VGG")
				dBSkip()
			End
			
		Endif
		
	Next
	
	End Transaction
	
Endif

Return(.T.)



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_070CODI³ Autor ³Fabio                  ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca os codigos internos do item e do servico              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³FS_070CODINT()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_070CODINT()
*****************

If readvar() == 'M->VG6_ANORRC'
	
	M->VG8_ANORRC := M->VG6_ANORRC
	
Elseif  readvar() == 'M->VG6_NUMRRC'
	
	M->VG8_NUMRRC := M->VG6_NUMRRC
	
Endif

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_070TUDOK³ Autor ³Fabio                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Da um ok final nos dados informados                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_070TUDOK()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_070TUDOK()
***************

Local lRet := .T.
Local nI   := 0

For nI :=1 to Len(aCpoEnchVG8)
	If X3Obrigat(aCpoEnchVG8[nI]) .and. Empty(&("M->"+aCpoEnchVG8[nI]))
		Help(" ",1,"OBRIGAT2",,RetTitle(aCpoEnchVG8[nI]),4,1 )
		Return(.F.)
	EndIf
Next

Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM070P    ³ Autor ³Fabio                  ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os itens da acao de campo cadastrado no VSD           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM070P(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM070P(cAlias,nReg,nOpc)
**************************

DbSelectArea("VG8")
DbSetOrder(nIndex)

If !Pergunte("OFIG00",.t.)
	Return
Endif

Begin Transaction

FG_SEEK("VSD","MV_PAR03",1,.F.)

DbSelectArea("VSD")

While !eof() .and. VSD->VSD_NUMCAM == MV_PAR03 .And. VSD->VSD_FILIAL == xFilial("VSD")
	
	DbSelectArea("VG6")
	DbSetOrder(1)
	DbSeek(xFilial("VG6")+MV_PAR01+STRZERO(VAL(MV_PAR02),8)+VSD->VSD_PECINT)
	
	RecLock("VG6", !Found() )
	VG6->VG6_FILIAL := xFilial("VG6")
	VG6->VG6_CODMAR := MV_PAR01
	VG6->VG6_NUMOSV := STRZERO(VAL(MV_PAR02),8)
	VG6->VG6_GRUITE := VSD->VSD_GRUITE
	VG6->VG6_CODITE := VSD->VSD_CODITE
	VG6->VG6_PECINT := VSD->VSD_PECINT
	VG6->VG6_QTDITE := VSD->VSD_QTDITE
	VG6->VG6_CODDEF := VSD->VSD_CODDEF
	VG6->VG6_CODFOR := VSD->VSD_CODFOR
	VG6->VG6_CODSER := VSD->VSD_CODSER
	VG6->VG6_SERINT := VSD->VSD_SERINT
	VG6->VG6_ITEEXT := "1"
	VG6->VG6_SEREXT := "1"
	VG6->VG6_TRANSM := "N"
	MsUnlock()
	
	DbselectArea("VSD")
	Dbskip()
	
End

End Transaction

Help(" ",1,"OFIGM00012")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LIMPACPºAutor  ³FAbio               º Data ³  01/29/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa campo adicionais                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_070LIMPACPO()

Local nLimpa:=0

For nLimpa:=1 To Len(aHeader)
	
	If ( Substr(ReadVar(),4) $ cCpoASrv .And. aHeader[nLimpa,2] $ cCpoAPeca ) ;
		.Or. ( Substr(ReadVar(),4) $ cCpoAPeca .And. aHeader[nLimpa,2] $ cCpoASrv )
		
		aCols[n,nLimpa] := CriaVar(aHeader[nLimpa,2],.f.)
		
	EndIf
	
Next

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_070CARRºAutor  ³Fabio               º Data ³  08/23/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega conteudo da linha no cabecalho                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_070CARREGA(cNumRROld,cNumRRNew,cCarrega)

Local nCarrega:=0 , nPosCarrega:=0

Default cNumRROld := M->VG6_ANORRC+M->VG6_NUMRRC
Default cNumRRNew := aCols[n,FG_POSVAR("VG6_ANORRC")]+aCols[n,FG_POSVAR("VG6_NUMRRC")]
Default cCarrega  := "T"

&& Salva conteudo anterior
If cCarrega $ "T/S"
	If ( nPosCarrega:=Ascan( aCtrCpoEnch , { |x| x[2] == cNumRROld } ) ) == 0
		Aadd(aCtrCpoEnch,{ .t. , cNumRROld, aClone(aCtrCpoEnch[1,3])} )
		nPosCarrega:=Len(aCtrCpoEnch)
	EndIf
	
	For nCarrega:=1 to Len(aCpoEnchVG8)
		
		aCtrCpoEnch[nPosCarrega,3,nCarrega] := M->&(aCpoEnchVG8[nCarrega])
		
	Next
EndIf

&& Carrega novo conteudo
If cCarrega $ "T/V"
	If ( nPosCarrega:=Ascan( aCtrCpoEnch , { |x| x[2] == cNumRRNew } ) ) == 0
		Aadd(aCtrCpoEnch,{ .t. , cNumRRNew, aClone(aCtrCpoEnch[1,3])} )
		nPosCarrega:=Len(aCtrCpoEnch)
	EndIf
	
	For nCarrega:=1 to Len(aCpoEnchVG8)
		
		M->&(aCpoEnchVG8[nCarrega]) := aCtrCpoEnch[nPosCarrega,3,nCarrega]
		
	Next
EndIf

oEnchVG8:EnchRefreshAll()

Return



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FG_CCValor³ Autor ³Antonio Carlos Damaceno³ Data ³ 25/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calculo para informar nos campos de totais da garantia da   ³±±
±±³          ³ marca massey ferguson                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FG_CCValor()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia MF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FG_CCValor()

If ReadVar() == "M->VG8_PORAPC"
	M->VG8_VLRAPC:=(M->VG8_VALITE*M->VG8_PORAPC)/100
	M->VG8_VLPVLA:=(M->VG8_VALITE+M->VG8_VLRAPC)
ElseIf ReadVar() == "M->VG8_VLRAPC"
	M->VG8_PORAPC:=(M->VG8_VALITE/M->VG8_VLRAPC)*100
	M->VG8_VLPVLA:=(M->VG8_VALITE+M->VG8_VLRAPC)
Else
	M->VGG_VRAPCC:=(M->VGG_VLPECC*M->VGG_POAPCC)/100
	M->VGG_VPVLAC:=(M->VGG_VLPECC+M->VGG_VRAPCC)
	M->VGG_TPKSTC:=(M->VGG_VLMOCC+(M->VGG_VLPECC+M->VGG_VRAPCC)+M->VGG_VKMCAC+M->VGG_VRSETC)
Endif

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_ChecMar³ Autor ³Antonio Carlos Damaceno³ Data ³ 24/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação para aceitar somente garantia da marca           ³±±
±±³          ³ massey ferguson                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia MF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ChecMar()

Local lRet  := .T.
Local aArea := GetArea()

If AllTrim(M->VG8_CODMAR)<>AllTrim(cParMF)
	HS_MsgInf(STR0005,STR0006,STR0001) //"Garantia somente para Marca Massey Ferguson!  -  Verifique o conteúdo do parâmetro 'MV_GARMAFE', pois este deve ser igual a marca"###"Atenção"###"Garantia Massey Ferguson"
	lRet:=.F.
EndIf

RestArea(aArea)

Return lRet


////////////////////////////////
// Validação p/aceitar na VG4 marca massey ferguson e Scania, ja q os dois usam a msma tabela
// Antonio(Boby) - 24/11/09
/////////////////////////////

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_ChecMar³ Autor ³Antonio Carlos Damaceno³ Data ³ 24/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação p/aceitar na VG4 marca massey ferguson e Scania, ³±±
±±³ja q os dois usam a msma tabela										  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MarVG4()
Local cRet:="SCANIA"
If FUNNAME()=='OFIGM070'
	cRet:='MASSEY FERGUSON'
EndIf
Return cRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CheOSMF³ Autor ³Antonio Carlos Damaceno³ Data ³ 05/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação para aceitar somente OS cadastradas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia MF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CheOSMF()
Local lRet  := .T.
Local aArea := GetArea()

dbSelectArea("VO1")
dbSetOrder(1)
If !dbSeek(xFilial("VG8")+M->VG8_NUMOSV)
	HS_MsgInf(STR0007,STR0006,STR0001) //"Código da Ordem de Serviço informado inválido ou não cadastrado!"###"Atenção"###"Garantia Massey Ferguson"
	lRet:=.F.
ELSE
	M->VG8_CODMAR := VO1->VO1_CODMAR
	M->VG8_CHAINT := VO1->VO1_CHAINT
	M->VG8_CHASSI := VO1->VO1_CHASSI
	M->VG8_KILGAR := VO1->VO1_KILOME
	M->VG8_CODCLI := VO1->VO1_PROVEI
	M->VG8_LOJA   := VO1->VO1_LOJPRO
	M->VG8_NOMCLI := Posicione("SA1",1,xFilial("SA1")+M->VG8_CODCLI+M->VG8_LOJA,"A1_NOME")
EndIf

RestArea(aArea)

Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_InfNum ³ Autor ³Antonio Carlos Damaceno³ Data ³ 28/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação para aceitar somente Dados Numericos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia MF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_INFNUM(cVar)
Local lRet  := .T.
Local aArea := GetArea()

If !SUBSTR(cVar,1,1) $ "0123456789"
	HS_MsgInf(STR0014,STR0006,STR0001) //"###"Atenção"###"Garantia Massey Ferguson"
	lRet:=.F.
EndIf

RestArea(aArea)
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_RRACHEI³ Autor ³Antonio Carlos Damaceno³ Data ³ 29/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação para aceitar RRs Cadastradas                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia MF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_RRACHEI()
Local lRet  := .T.
Local aArea := GetArea()
If !Empty(M->VG6_NUMRRC)
	dBSelectArea("VG4")
	dBSetOrder(1)
	If !dbSeek(xFilial("VG4")+M->VG6_ANORRC+M->VG8_CODMAR+M->VG6_NUMRRC)
		HS_MsgInf(STR0015,STR0006,STR0001) //"###"Atenção"###"Garantia Massey Ferguson"
		lRet:=.F.
	EndIf
EndIf

RestArea(aArea)
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CHEGMF ³ Autor ³Antonio Carlos Damaceno³ Data ³ 29/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação para nao aceitar OS duplicadas e trazer dados da ³±±
±±³          ³ Os para getdados                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia MF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHEGMF()
Local lRet  := .T.
Local _ni
Local nPosVG8 := VG8->(RECNO())
Local aArea := GetArea()
//Local n:=1
Local lPassou:=.F.

If !(INCLUI)     //BOBY
	Return .T.
EndIf

If Len(aCols) == 1 .and. !Empty(aCols[1,FG_POSVAR("VG6_ANORRC","aHeader")])
	aCols := {}
Endif

dBSelectArea("VG8")
dBSetOrder(3)
If dbSeek(xFilial("VG8")+M->VG8_NUMOSV+M->VG8_CODMAR)
	HS_MsgInf(STR0016,STR0006,STR0001) //"###"Atenção"###"Garantia Massey Ferguson"
	lRet:=.F.
Else
	/*	dBSelectArea("VO1")   //OS
	dBSetOrder(1)
	IF dbSeek(xFilial("VO1")+M->VG8_NUMOSV)
	M->VG8_CODMAR := VO1->VO1_CODMAR
	M->VG8_CHAINT := VO1->VO1_CHAINT
	M->VG8_KILGAR := VO1->VO1_KILOME
	M->VG8_CODCLI := VO1->VO1_PROVEI
	M->VG8_LOJA   := VO1->VO1_LOJA
	EndIf
	*/
	nPosGI := FG_POSVAR("VG6_GRUITE","aHeader")// Grupo do Item
	nPosCI := FG_POSVAR("VG6_CODITE","aHeader")// Codigo do Item
	
	dBSelectArea("VO3")   //ITENS PECAS
	dBSetOrder(8)
	dbSeek(xFilial("VO3")+M->VG8_NUMOSV)
	
	Do While !eof() .and. VO3->VO3_NUMOSV == M->VG8_NUMOSV .And. VO3->VO3_FILIAL == xFilial("VO3")
		
		nPos := aScan(aCols,{|x| x[nPosGI]+x[nPosCI] == VO3->VO3_GRUITE+VO3->VO3_CODITE})
		If nPos == 0
			//			oGetVG6:AddLine(.F., .F.)
			//			oGetVG6:lNewLine := .F.
			//			AADD(aCols,Array(nUsado+1))
			//			For _ni:=1 to nUsado
			//				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] == "V" .Or.;
			//				( ( VG6->VG6_ITEEXT == "1" .And. (Alltrim(aHeader[_ni,2]) $ cCpoAPeca) ) .Or. ;
			//				( VG6->VG6_SEREXT == "1" .And. (Alltrim(aHeader[_ni,2]) $ cCpoASrv) ) ) ,;
			//				CriaVar(aHeader[_ni,2]),;
			//				FieldGet(FieldPos(aHeader[_ni,2])))
			//			Next
			AADD(aCols,Array(nUsado+1))
			aCols[Len(aCols),nUsado+1]:=.F.
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=CriaVar(aHeader[_ni,2])
			Next
			nPos := Len(aCols)
			aCols[nPos,FG_POSVAR("VG6_ANORRC","aHeader")] := str(year(DDatabase),4)
			aCols[nPos,FG_POSVAR("VG6_NUMRRC","aHeader")] := SPACE(TamSx3("VG6_NUMRRC")[1])
			aCols[nPos,FG_POSVAR("VG6_GRUITE","aHeader")] := VO3->VO3_GRUITE
			aCols[nPos,FG_POSVAR("VG6_CODITE","aHeader")] := VO3->VO3_CODITE
			aCols[nPos,FG_POSVAR("VG6_DESITE","aHeader")] := POSICIONE("SB1",7,xFilial("SB1")+VO3->VO3_GRUITE+VO3->VO3_CODITE,"B1_DESC")
		EndIf
		aCols[nPos,FG_POSVAR("VG6_QTDITE","aHeader")] += VO3->VO3_QTDREQ
		aCols[nPos,FG_POSVAR("VG6_VALITE","aHeader")] += (VO3->VO3_VALPEC*VO3->VO3_QTDREQ)
		
		dBSkip()
	EndDo
	
	//	oGetVG6:lNewLine := .F.
	nPosCS := FG_POSVAR("VG6_CODSER","aHeader")
	
	dBSelectArea("VO4")   //ITENS SERVICOS
	dBSetOrder(10)
	dbSeek(xFilial("VO4")+M->VG8_NUMOSV)
	
	Do While !eof() .and. VO4->VO4_NUMOSV == M->VG8_NUMOSV .And. VO4->VO4_FILIAL == xFilial("VO4")
		
		nPos := aScan(aCols,{|x| x[nPosCS] == VO4->VO4_CODSER})
		If nPos == 0
			//			oGetVG6:AddLine(.F., .F.)
			//			oGetVG6:lNewLine := .F.
			/*			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] == "V" .Or.;
			( ( VG6->VG6_ITEEXT == "1" .And. (Alltrim(aHeader[_ni,2]) $ cCpoAPeca) ) .Or. ;
			( VG6->VG6_SEREXT == "1" .And. (Alltrim(aHeader[_ni,2]) $ cCpoASrv) ) ) ,;
			CriaVar(aHeader[_ni,2]),;
			FieldGet(FieldPos(aHeader[_ni,2])))
			Next
			*/			AADD(aCols,Array(nUsado+1))
			aCols[Len(aCols),nUsado+1]:=.F.
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=CriaVar(aHeader[_ni,2])
			Next
			nPos := Len(aCols)
			
			aCols[nPos,FG_POSVAR("VG6_ANORRC","aHeader")] := str(year(DDatabase),4)
			aCols[nPos,FG_POSVAR("VG6_NUMRRC","aHeader")] := SPACE(TamSx3("VG6_NUMRRC")[1])
			//			aCols[nPos,FG_POSVAR("VG6_GRUITE","aHeader")] := VO4->VO4_GRUSER
			aCols[nPos,FG_POSVAR("VG6_CODSER","aHeader")] := VO4->VO4_CODSER
			aCols[nPos,FG_POSVAR("VG6_DESSER","aHeader")] := Posicione("VO6",2,xFilial("VO6")+M->VG8_CODMAR+VO4->VO4_CODSER,"VO6_DESSER")
			aCols[nPos,FG_POSVAR("VG6_VALSER","aHeader")] := ((VO4->VO4_TEMPAD*VO4->VO4_VALHOR)/100)  /*VO4->VO4_VALVEN*/ //VO4->VO4_VALHOR
			
		EndIf
		
		dBSkip()
	EndDo
	
	// 	oGetVG6:lNewLine := .F.
	
EndIf

If Len(aCols) == 0
	
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	
EndIf

oGetVG6:oBrowse:nAt := 1
n := 1

oGetVG6:Refresh()
DbGoTo(nPosVG8)

RestArea(aArea)

Return lRet

////////////Menu
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef   ³ Autor ³Antonio Carlos Damaceno³ Data ³ 29/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ menu														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia MF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { {  STR0008   ,"axPesqui", 0 , 1},; //"Pesquisar"
{ STR0009   ,"GM070"   , 0 , 2},; //"Vizualisar"
{ STR0010   ,"GM070"   , 0 , 3},; //"Incluir"
{ STR0011   ,"GM070"   , 0 , 4} } //"Alterar"
Return aRotina


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |  OFGM70    | Autor | BOBY                  | Data | 22/04/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Trata a mudanca de folders entre as aCols                    |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFGM70(cPar)

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0
Local cSavAlias := alias()

DEFAULT cPar := ""

//If !(INCLUI .or. ALTERA)
//	Return .T.
//EndIf

If cPar == "VG6_NUMRRC" .and. ReadVar() == "M->VG6_NUMRRC"
	nPos := Ascan(aSavVGG,{ |x| x[1]+x[2] == M->VG6_NUMRRC + M->VG6_ANORRC})
	If nPos > 0
		For nCntFor := 1 TO Len(aCpoEncRet)
			M->&(aCpoEncRet[nCntFor]) := aSavVGG[nPos,nCntFor]
		Next
	Endif
Endif

If cPar != "VOLTA"
	nPos := Ascan(aSavVGG,{ |x| x[1]+x[2] == aCols[n,FG_POSVAR("VG6_NUMRRC")]+aCols[n,FG_POSVAR("VG6_ANORRC")] })
	If !Empty(aCols[n,FG_POSVAR("VG6_NUMRRC")])
		If nPos == 0
			AADD(aSavVGG,Array(Len(aCpoEncRet)))
		Endif
		If nPos == 0
			nPos := Len(aSavVGG)
		Endif
		If Len(aSavVGG) > 0
			For nCntFor := 1 TO Len(aCpoEncRet)
				If nCntfor == 1
					aSavVGG[nPos,nCntFor] := aCols[n,FG_POSVAR("VG6_NUMRRC")]
				ElseIf nCntfor == 2
					aSavVGG[nPos,nCntFor] := aCols[n,FG_POSVAR("VG6_ANORRC")]
				Else
					aSavVGG[nPos,nCntFor] := M->&(aCpoEncRet[nCntFor])
				Endif
			Next
		Endif
	Endif
Else
	If Empty(aCols[n,FG_POSVAR("VG6_NUMRRC")])
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("VGG")
		While !Eof().and.(x3_arquivo=="VGG")
			&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
			DbSkip()
		End
	Else
		nPos := Ascan(aSavVGG,{ |x| x[1]+x[2] == aCols[n,FG_POSVAR("VG6_NUMRRC")]+aCols[n,FG_POSVAR("VG6_ANORRC")] })
		If nPos > 0
			For nCntFor := 1 TO Len(aCpoEncRet)
				M->&(aCpoEncRet[nCntFor]) := aSavVGG[nPos,nCntFor]
			Next
		Endif
	Endif
Endif

FG_CCVALOR()

oGetVG6:oBrowse:Refresh()
oEnchVGG:Refresh()

DbSelectArea(cSavAlias)

Return .T.



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  OFIG70  ³ Autor ³Antonio Carlos Damaceno³ Data ³ 26/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro para consulta padrao VO1 para trazer somente marcas ³±±
±±³          ³ cadastradas na VE4                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia MF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIG70()
Local lRet      := .F.
Local cArea     := "VO1"
Local cSql      := ""
Local cQryAlias := "ALIASSQL"

If !(VO1->VO1_STATUS $ 'D/F')
	Return lRet
EndIf
cSql := "SELECT VE4.VE4_QDOIMP FROM " + RetSqlName("VOO") + " VOO "
cSql += "JOIN " + RetSqlName("VOI") + " VOI ON ( VOI.VOI_FILIAL='" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM=VOO.VOO_TIPTEM AND VOI.VOI_SITTPO='2' AND VOI.D_E_L_E_T_=' ' ) "
cSql += "JOIN " + RetSqlName("VE4") + " VE4 ON ( VE4.VE4_FILIAL='" + xFilial("VE4") + "' AND VE4.VE4_PREFAB='"+VO1->VO1_CODMAR+"' AND VE4.D_E_L_E_T_=' ' ) "
cSql += "WHERE VOO.VOO_FILIAL='" + xFilial("VOO") + "' AND VOO.VOO_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VOO.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql ), cQryAlias, .F., .T. )
While !( cQryAlias )->( Eof() )
	If ( cQryAlias )->( VE4_QDOIMP ) == '1'
		If VO1->VO1_STATUS $ 'D/F'
			lRet := .t.
		EndIf
	ElseIf ( cQryAlias )->( VE4_QDOIMP ) == '2'
		If VO1->VO1_STATUS == 'F'
			lRet := .t.
		EndIf
	EndIf
	( cQryAlias )->( DbSkip() )
End
( cQryAlias )->( dbCloseArea() )
DbSelectArea(cArea)
Return lRet



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  OFIG70  ³ Autor ³Antonio Carlos Damaceno³ Data ³ 26/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro para consulta padrao VO1 para trazer somente marcas ³±±
±±³          ³ cadastradas na VE4                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia MF                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function vOFG70()
Local lRet      := .F.
Local cArea     := "VO1"
Local cSql      := ""
Local cQryAlias := "ALIASSQL"
Local cAliasVO2 := "ALIASQLVO2"
lOCAL iii := 1
local cNewStatus := ""
///////////////////////////////////////
//altera status da OS no cancelamento//
///////////////////////////////////////
cQuery    := "SELECT VO2.VO2_DEVOLU, "
cQuery    += "VO3.VO3_TIPTEM,VO3.VO3_DATFEC,VO3.VO3_DATDIS,VO3.VO3_DATCAN,VO3.VO3_QTDREQ,VO3.VO3_GRUITE,VO3.VO3_CODITE, "
cQuery    += "VO4.VO4_TIPTEM,VO4.VO4_DATFEC,VO4.VO4_DATDIS,VO4.VO4_DATCAN "
cQuery    += "FROM "+RetSqlName("VO2")+" VO2 "
cQuery    += "LEFT JOIN "+RetSqlName("VO3")+" VO3 ON (VO3.VO3_FILIAL='"+xFilial("VO3")+"' "
cQuery    += "AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_=' ') "
cQuery    += "LEFT JOIN "+RetSqlName("VO4")+" VO4 ON (VO4.VO4_FILIAL='"+xFilial("VO4")+"' "
cQuery    += "AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_=' ') "
cQuery    += "WHERE VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND
cQuery    += "VO2.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVO2, .F., .T. )

aTempos := {}
aVetVO3VO4 := {}
// 1o Elemento - Tipo de Tempo
// 2o Elemento - [P]ecas / [S]ervicos
// 3o Elemento - Grupo + Codigo
// 4o Elemento - Quantidade
// 5o Elemento - Data de Fechamento
// 6o Elemento - Data de Disponibilidade
// 7o Elemento - Data de Cancelamento

While ( cAliasVO2 )->(!Eof())

If     ( cAliasVO2 )->VO2_DEVOLU == "1" // Requisicao de Pecas
nPos := aScan(aVetVO3VO4,{|x| x[1]+x[3] == ( cAliasVO2 )->VO3_TIPTEM+( cAliasVO2 )->VO3_GRUITE+( cAliasVO2 )->VO3_CODITE})
If nPos == 0
aadd(aVetVO3VO4,{( cAliasVO2 )->VO3_TIPTEM,"P",( cAliasVO2 )->VO3_GRUITE+( cAliasVO2 )->VO3_CODITE,( cAliasVO2 )->VO3_QTDREQ,( cAliasVO2 )->VO3_DATFEC,( cAliasVO2 )->VO3_DATDIS,( cAliasVO2 )->VO3_DATCAN })
Else
aVetVO3VO4[nPos,4] += ( cAliasVO2 )->VO3_QTDREQ
Endif
ElseIf ( cAliasVO2 )->VO2_DEVOLU == "0" // Devolucao de Pecas
nPos := aScan(aVetVO3VO4,{|x| x[1]+x[3] == ( cAliasVO2 )->VO3_TIPTEM+( cAliasVO2 )->VO3_GRUITE+( cAliasVO2 )->VO3_CODITE})
If nPos == 0
aadd(aVetVO3VO4,{( cAliasVO2 )->VO3_TIPTEM,"P",( cAliasVO2 )->VO3_GRUITE+( cAliasVO2 )->VO3_CODITE,( cAliasVO2 )->VO3_QTDREQ*(-1),( cAliasVO2 )->VO3_DATFEC,( cAliasVO2 )->VO3_DATDIS,( cAliasVO2 )->VO3_DATCAN })
Else
aVetVO3VO4[nPos,4] -= ( cAliasVO2 )->VO3_QTDREQ
Endif
ElseIf ( cAliasVO2 )->VO2_DEVOLU == " " // Requisicao de Servicos
aadd(aVetVO3VO4,{( cAliasVO2 )->VO4_TIPTEM,"S","",1,( cAliasVO2 )->VO4_DATFEC,( cAliasVO2 )->VO4_DATDIS,( cAliasVO2 )->VO4_DATCAN })
Endif

( cAliasVO2 )->(DbSkip())

Enddo

( cAliasVO2 )->(dbCloseArea())

nPos   := aScan(aTempos,{|x| x[1] == .t.})
cTTSel := aTempos[nPos,2]

cNewStatus := ""
for iii := 1 to Len(aVetVO3VO4)
If aVetVO3VO4[iii,1] == cTTSel .and. !Empty(aVetVO3VO4[iii,5])
cNewStatus := "A"
exit
Else
If cNewStatus != "F" .and. !Empty(aVetVO3VO4[iii,7]) // Data de Cancelamento
cNewStatus := "C"
Else
If !Empty(aVetVO3VO4[iii,5]) // Data de Fechamento
cNewStatus := "F"
ElseIf !Empty(aVetVO3VO4[iii,6]) // Data de Disponibilidade
cNewStatus := "D"
Else
If aVetVO3VO4[iii,4] > 0
cNewStatus := "A"
exit
Endif
Endif
Endif
Endif
Next


DbSelectArea(cArea)
Return lRet
*/

Function FS_CAMPOSVG8()    
if !Empty(M->VG8_NUMOSV)
	dbSelectArea("VO1")
	dbSetOrder(1)
	if dbSeek(xFilial("VO1")+M->VG8_NUMOSV)
	   M->VG8_CODMAR := VO1->VO1_CODMAR
	   dbSelectArea("VE1")
	   dbSetOrder(1)
	   dbSeek(xFilial("VE1")+VO1->VO1_CODMAR)
	   M->VG8_DESMAR := VE1->VE1_DESMAR
	   M->VG8_CHAINT := VO1->VO1_CHAINT
	   M->VG8_CHASSI := VO1->VO1_CHASSI
	   M->VG8_CODCLI := VO1->VO1_PROVEI
	   M->VG8_LOJA   := VO1->VO1_LOJPRO
	   dbSelectArea("SA1")
	   dbSetOrder(1)
	   dbSeek(xFilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO)
	   M->VG8_NOMCLI := SA1->A1_NOME
	   M->VG8_KILGAR := VO1->VO1_KILOME
	Endif
eNDIF
Return(.t.)
