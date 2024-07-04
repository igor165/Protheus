// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 005    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "protheus.ch"
#INCLUDE "VEIVM150.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVM150  ³ Autor ³ Thiago               ³ Data ³ 15/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera a situacao do veiculo para imobilizado              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VEIVM150()    
*/

Local aObjects  := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Local cTitulo   := STR0002
Local cAlias    := "VV1"
Local ni        := 1
Local cAliasVV1 := "SQLVV1"
Local lImobi    := .f.

Private oVerme     := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Pedido
Private oVerde     := LoadBitmap( GetResources() , "BR_VERDE" ) 	// Reservados
Private aSX3Browse := {}
Private cChassi    := space(25)
Private aVeiculo   := {}

if VV1->(FieldPos("VV1_IMOBI")) == 0
   MsgStop(STR0019+CHR(13) + CHR(10)+STR0020)
   Return(.f.)
Endif

DbselectArea("VV2")
DbSetOrder(1)

cQuery := "SELECT DISTINCT VV1.VV1_CHAINT,VV1.VV1_CHASSI,VV1.VV1_PLAVEI,VV1.VV1_IMOBI,VV1.VV1_CODMAR,VV1.VV1_MODVEI,VV1.VV1_SEGMOD,SA1.A1_NOME "
cQuery += "FROM " + RetSqlName("VV1") + " VV1 "
cQuery += "LEFT JOIN " + RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD = VV1.VV1_PROATU AND SA1.A1_LOJA = VV1.VV1_LJPATU AND SA1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_SITVEI <> '1' AND VV1.D_E_L_E_T_=' ' "
cQuery += "ORDER BY VV1.VV1_CHASSI"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVV1, .T., .T. )

While !( cAliasVV1 )->( Eof() )
    
	VV2->(DbSeek(xFilial("VV2")+( cAliasVV1 )->VV1_CODMAR+(cAliasVV1 )->VV1_MODVEI+(cAliasVV1 )->VV1_SEGMOD))

	lImobi := ( cAliasVV1 )->VV1_IMOBI == "1"

	aAdd(aVeiculo,{( cAliasVV1 )->VV1_CHAINT,( cAliasVV1 )->VV1_CHASSI,VV2->VV2_DESMOD,( cAliasVV1 )->VV1_PLAVEI,substr(( cAliasVV1 )->A1_NOME,1,20),Iif(lImobi,"1","0")} )

	( cAliasVV1 )->(DbSkip())
	
Enddo
( cAliasVV1 )->( DbCloseArea() )

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While !Eof().and.( SX3->X3_ARQUIVO == cAlias )
	If SX3->X3_CAMPO $ "VV1->VV1_CHAINT.VV1->VV1_CHASSI.VV1->VV1_DESMOD.VV1->VV1_PLAVEI.VV1->VV1_NOMPRO"
		aAdd(aSX3Browse,{Alltrim(SX3->X3_CAMPO),SX3->X3_TITULO,SX3->X3_PICTURE,SX3->X3_CONTEXT,SX3->X3_INIBRW,SX3->X3_TAMANHO,"LEFT"})
		If SX3->X3_TIPO == "N"
			If Empty(aSX3Browse[len(aSX3Browse),3]) // SEM PICTURE
				aSX3Browse[len(aSX3Browse),3] := "@E "+repl("9",SX3->X3_TAMANHO)
			EndIf
			If Empty(aSX3Browse[len(aSX3Browse),5]) // SEM INICIALIZADOR DO BROWSE
				aSX3Browse[len(aSX3Browse),5] := "0"
			EndIf
			aSX3Browse[len(aSX3Browse),7] := "RIGHT"
		Else//If SX3->X3_TIPO == "C"
			aSX3Browse[len(aSX3Browse),3] := "@!"
			If Empty(aSX3Browse[len(aSX3Browse),5]) // SEM INICIALIZADOR DO BROWSE
				aSX3Browse[len(aSX3Browse),5] := ""
			EndIf
		EndIf
		aSX3Browse[len(aSX3Browse),6] := (aSX3Browse[len(aSX3Browse),6]*4)
	EndIf
	SX3->(DbSkip())
Enddo
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 11 , .T. , .F. } ) // Filtro por Periodo
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox ( Browse )
aAdd( aObjects, { 0 , 11 , .T. , .F. } ) // Legenda
aPosP := MsObjSize( aInfo, aObjects )
//
DEFINE MSDIALOG oImob FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cTitulo) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
oImob:lEscClose := .F.
@ aPosP[1,1]+001 , aPosP[1,2]+005 SAY STR0004 SIZE 40,08 OF oImob PIXEL COLOR CLR_BLUE
@ aPosP[1,1]+001 , aPosP[1,2]+042 MSGET oChassi VAR cChassi picture "@!" VALID FS_CHASSI() F3 "VV1" SIZE 100,06 OF oImob PIXEL COLOR CLR_BLUE
@ aPosP[1,1]+001 , aPosP[1,2]+220 BUTTON oInclImo  PROMPT OemToAnsi(STR0010) OF oImob SIZE 100,10 PIXEL  ACTION (FS_INC())
@ aPosP[1,1]+001 , aPosP[1,2]+370 BUTTON oCancImo  PROMPT OemToAnsi(STR0011) OF oImob SIZE 100,10 PIXEL  ACTION (FS_CAN())
@ aPosP[1,1]+001 , aPosP[1,2]+520 BUTTON oFecharT  PROMPT OemToAnsi(STR0023) OF oImob SIZE 100,10 PIXEL  ACTION oImob:End()

oImobLx:=TWBrowse():New(aPosP[2,1],aPosP[2,2],(aPosP[2,4]-2),(aPosP[2,3]-aPosP[2,1]),,,,oImob,,,,,{ || .T. },,,,,,,.F.,,.T.,,.F.,,,)
oImobLx:addColumn( TCColumn():New( "", { || IIf(aVeiculo[oImobLx:nAt,06]=="0",oVerde,oVerme) } ,,,,"LEFT" ,08,.T.,.F.,,,,.F.,) ) // Cor 2
For ni := 1 to len(aSX3Browse)
	oImobLx:addColumn( TCColumn():New( aSX3Browse[ni,2] , &("{ || Transform(aVeiculo[oImobLx:nAt,"+Alltrim(str(ni))+"],"+'"'+aSX3Browse[ni,3]+'"'+") }") , , , , aSX3Browse[ni,7] , aSX3Browse[ni,6] , .F. , .F. , , , , .F. , ) )
Next
oImobLx:bLDblClick := { || VEIVC140(aVeiculo[oImobLx:nAt,2], aVeiculo[oImobLx:nAt,1]) } // quando chama o PE OXC09PRC pelo DbClick, passa aMatriz de Preços e a posição na ListBox
oImobLx:nAT := 1
oImobLx:SetArray(aVeiculo)

@ aPosP[3,1]+001 , aPosP[3,2]+010 BITMAP oxVerde RESOURCE "BR_VERDE" OF oImob NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosP[3,1]+001 , aPosP[3,2]+020 SAY STR0024 SIZE 50,8 OF oImob PIXEL COLOR CLR_BLUE
@ aPosP[3,1]+001 , aPosP[3,2]+110 BITMAP oxVerme RESOURCE "BR_VERMELHO" OF oImob NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosP[3,1]+001 , aPosP[3,2]+120 SAY STR0025 SIZE 50,8 OF oImob PIXEL COLOR CLR_BLUE

ACTIVATE MSDIALOG oImob CENTER


Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CHASSI ³ Autor ³ Thiago               ³ Data ³ 15/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do campo chassi.					              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_CHASSI()
Local nPos := 0

if !Empty(cChassi)
	dbSelectArea("VV1")
	dbSetOrder(2)
	if !dbSeek(xFilial("VV1")+cChassi)
		dbSetOrder(9)
		if !dbSeek(xFilial("VV1")+cChassi)
			MsgInfo(STR0012)
			Return()
		Endif
	Endif   
	nPos := aScan(aVeiculo,{|x| x[2] == VV1->VV1_CHASSI})
	If nPos > 0
		oImobLx:nAT := nPos
	Endif
	oImobLx:SetArray(aVeiculo)
Endif

oImobLx:SetArray(aVeiculo)
oImobLx:refresh() 

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CAN    ³ Autor ³ Thiago               ³ Data ³ 15/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Botao cancelar.								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_CAN()                
Local lRet := .f.

dbSelectArea("VV1")
dbSetOrder(2)
if dbSeek(xfilial("VV1")+aVeiculo[oImobLx:nAT,2])
	if VV1->VV1_IMOBI <> "1"
	   MsgInfo(STR0021)
	   Return()
	Endif      
Endif      

If ExistBlock("VM150VLC")
	lRet := ExecBlock("VM150VLC",.f.,.f.,{aVeiculo[oImobLx:nAT,2]})   
	if !lRet
		Return()
	Endif	
EndIf

if MsgYesNo(STR0017, STR0015)
	dbSelectArea("VV1")
	dbSetOrder(2)
	if dbSeek(xfilial("VV1")+aVeiculo[oImobLx:nAT,2])
	   RecLock("VV1",.f.)
	   VV1->VV1_IMOBI  := "0"
	   MsUnlock()
	   aVeiculo[oImobLx:nAT,6] := "0"
	Else
	   MsgInfo(STR0012)
	   Return()
	Endif
Else
	Return()
Endif      
MsgInfo(STR0022)
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_INC    ³ Autor ³ Thiago               ³ Data ³ 15/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Botao incluir.								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_INC()
Local lRet := .f.

dbSelectArea("VV1")
dbSetOrder(2)
if dbSeek(xfilial("VV1")+aVeiculo[oImobLx:nAT,2])
	if VV1->VV1_IMOBI == "1"
	   MsgInfo(STR0016)
	   Return()
	Endif
Endif

If ExistBlock("VM150VLI")
	lRet := ExecBlock("VM150VLI",.f.,.f.,{aVeiculo[oImobLx:nAT,2]})   
	if !lRet
		Return()
	Endif	
EndIf

if MsgYesNo(STR0014, STR0015)
	dbSelectArea("VV1")
	dbSetOrder(2)
	if dbSeek(xfilial("VV1")+aVeiculo[oImobLx:nAT,2])
	   RecLock("VV1",.f.)
	   VV1->VV1_IMOBI  := "1"
	   MsUnlock()
	   aVeiculo[oImobLx:nAT,6] := "1"
	Else
	   MsgInfo(STR0012)
	   Return()
	Endif
Else
	Return()
Endif      
MsgInfo(STR0018)

Return()