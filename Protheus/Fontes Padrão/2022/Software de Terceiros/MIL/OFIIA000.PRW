#Include "OFIIA000.CH"
#Include "Protheus.ch"
#include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIIA000 ³ Autor ³  Renata               ³ Data ³ 07/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Entrada NF de peca                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA000()

Local cFiltro := ""

Private aRotina   := MenuDef()                 
Private cCadastro := OemToAnsi(STR0006)
Private cMarcar:=GetMark()
Private cParam := ""
Private nFormEnt := 0

DbSelectArea("VI0")

If ExistBlock("PEIA000")      // Ponto de Entrada para desviou de chamada da Rotina de Entrada de NF Peça
	ExecBlock("PEIA000",.f.,.f.,{})
	Return
EndIf

If ExistBlock("IA000FIL")
	cFiltro	:=	ExecBlock("IA000FIL",.f.,.f.)
Endif

// Cria pergunte da rotina
IA200PERG(.f.)

SetKey(VK_F12,{ || IA200PERG(.t.) })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Markbrow("VI0","VI0_OK","FS_FILIA000BROW()",,.f.,cMarcar,,,,,,,IIF(!Empty(cFiltro),cFiltro,))

SetKey(VK_F12,Nil)

DbSelectArea("VI0")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³IA000     ºAutor  ³Fabio               º Data ³  09/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Monta tela                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA000(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
////////////////////////////////////////////////////////////////////////////////////////////
Local bCampo   := { |nCPO| Field(nCPO) }
Local nUsado := 0 , nCntFor := 0 , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local nPosRec := 0
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice:={} , aCols := {} , aHeader := {} , aCtrReg:={}

aRotina := { 	{ "","",0 , 1},;
				{ "","",0 , 2},;
				{ "","",0 , 3},;
				{ "","",0 , 4},;
				{ "","",0 , 5 }}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RegToMemory("VI0",.t.)         // .t. para carregar campos virtuais

If nOpc == 2
	nOpcE := 2
	nOpcG := 2
ElseIf nOpc == 3
	nOpc  := 4
	nOpcE := 4
	nOpcG := 4
Else
	nOpc  := 5
	nOpcE := 5
	nOpcG := 5
EndIf

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VI0")

While !Eof().and.(x3_arquivo=="VI0")
	if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $[VI0_CODCON/VI0_TIPREG/VI0_DATRET])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo):= CriaVar(x3_campo)
	dbSkip()
End

If nOpc # 3
	DbSelectArea("VI0")
	For nCntFor := 1 To FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado := 0

dbSelectArea("SX3")
dbgotop()
dbSeek("VIA")

aHeader := {}
While !Eof().And.(x3_arquivo=="VIA")
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VIA_CODMAR/VIA_TIPREG/VIA_DATRET])
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
	Endif
	dbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VIA")
ADHeadRec("VIA",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

aCols := {}
DbSelectArea("VIA")
DbSetOrder(3)
DbSeek(xFilial()+M->VI0_CODMAR+M->VI0_NUMNFI+M->VI0_SERNFI+M->VI0_CODFOR+M->VI0_LOJFOR)

If nOpc == 3 .Or. !Found()
	
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VIA"
		Else
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
	Next
	
Else
	
	While !Eof() .And. VIA->VIA_FILIAL == xFilial("VIA") .And. M->VI0_CODMAR+M->VI0_SERNFI+M->VI0_NUMNFI+M->VI0_CODFOR+Alltrim(M->VI0_LOJFOR);
																			   == VIA->VIA_CODMAR+VIA->VIA_SERNFI+VIA->VIA_NUMNFI+VIA->VIA_CODFOR+Alltrim(VIA->VIA_LOJFOR)
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VIA->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VIA"
			Else
				aCols[Len(aCols),_ni]:=IIf(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		
		DbSelectArea("VIA")
		Aadd(aCtrReg,Recno())
		
		dbSkip()
	End
	
Endif

If Len(aCols)>0
	If ExistBlock("OI000AM3")
		ExecBlock("OI000AM3",.f.,.f.)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       := STR0001    //"Entrada NF Peca"
	cAliasEnchoice:= "VI0"
	cAliasGetD    := "VIA"
	cLinOk        := "FG_OBRIGAT()"
	cTudOk        := "AllwaysTrue()"
	cFieldOk      := "FG_MEMVAR()"
	lRefresh	  := .t.
	
	If nOpc # 3
		DbSelectArea("VI0")
		dbgotop()
		DbSetOrder(2)
		dbSeek(xFilial("VI0")+M->VI0_CODMAR+M->VI0_NUMNFI+M->VI0_SERNFI+M->VI0_CODFOR+M->VI0_LOJFOR)
	Endif
	
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05, 150, .T., .F. } )  //Cabecalho
	AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)

	oDlg1 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cTitulo,,,,128,,,,,.t.)
	
	EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
	
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]/*-aPosObj[2,1]*/,aPosObj[2,4]-004,nOpcG,cLinOk,cTudOk,"",IIf(nOpc > 2 .and. nOpc < 5,.t.,.f.),,,,,cFieldOk)
	
	oDlg1:bInit := {|| EnchoiceBar(oDlg1,{||nOpca:=1,IIf(oGetDados:TudoOk(),IIf(!obrigatorio(aGets,aTela),nOpca := 0,IIf(FS_GRAIA000(nOpc),oDlg1:End(),nOpca := 0) ),nOpca := 0)},{||nOpca := 0,oDlg1:End()}) }
	oDlg1:lCentered := .F.
	oDlg1:Activate()
	
Endif

DbSelectArea("VI0")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS_GRAIA00ºAutor  ³Fabio               º Data ³  08/15/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Grava Importacao                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAIA000(nOpc)

Local ni      := 0
Local cGruIte := ""
Local cTesEnt := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

// Grava Arquivo Pai
DbSelectArea("VI0")
If nOpc == 4
	
	If !RecLock("VI0",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	FG_GRAVAR("VI0")
	MsUnlock()
	
EndIf

For ni := 1 to Len( aCols )
	
	DbSelectArea("VIA")
	DbSetOrder(1)
	
	If ni <= Len(aCtrReg)
		DbGoTo(aCtrReg[ni])
	Else
		DbSeek(xFilial()+M->VI0_CODMAR+M->VI0_SERNFI+M->VI0_NUMNFI + aCols[ ni , FG_POSVAR("VIA_GRUITE") ] + aCols[ ni , FG_POSVAR("VIA_CODITE") ] + aCols[ ni , FG_POSVAR("VIA_PEDCON") ] )
	EndIf
	
	If (nOpc == 3 .or. nOpc == 4) .And. !(aCols[ni,len(aCols[ni])])
		
		DbSelectArea("VE4")
		DbSetOrder(1)
		If DbSeek( xFilial("VE4") + VIA->VIA_CODMAR )
			
			If !Empty( aCols[ ni , FG_POSVAR("VIA_GRUITE") ] )
				cGruIte := aCols[ ni , FG_POSVAR("VIA_GRUITE") ]
			Else
				cGruIte := VE4->VE4_GRUITE
			EndIf
			
			DbSelectArea("SB1")
			DbSetOrder(7)
			If DbSeek( xFilial("SB1") + cGruIte + aCols[ ni , FG_POSVAR("VIA_CODITE") ] )
				cTesEnt := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TE")
			EndIf
			
		EndIf
		
		DbSelectArea("VIA")
		If !RecLock("VIA", IIf(ni <= Len(aCtrReg),.f.,!Found()) )
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		FG_GRAVAR("VIA",aCols,aHeader,ni)
		VIA->VIA_FILIAL := xFilial("VIA")
		VIA->VIA_CODMAR := M->VI0_CODMAR
		VIA->VIA_SERNFI := M->VI0_SERNFI
		VIA->VIA_NUMNFI := M->VI0_NUMNFI
		VIA->VIA_CODFOR := M->VI0_CODFOR
		VIA->VIA_LOJFOR := M->VI0_LOJFOR
		
		If Empty(VIA->VIA_TESENT) .And. !Empty(cTesEnt)
			VIA->VIA_TESENT := cTesEnt
		EndIf
		
		MsUnlock()
		
	ElseIf ( Found() .Or. ni <= Len(aCtrReg) ) .and. nOpc <> 2
		
		RecLock("VIA",.F.,.T.)
		DbDelete()
		MsUnLock()
		WRITESX2("VIA")
		
	EndIf
	
Next

If nOpc == 5
	
	DbSelectArea("VI0")
	
	If !RecLock("VI0",.F.,.T.)
		
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
		
	EndIf
	
	DbDelete()
	MsUnLock()
	WRITESX2("VI0")
	
EndIf

// Ponto de Entrada para verificação da gravação das tabelas VIA e VI0 após a gravação das mesmas na alteração da rotina de Importação de NF de Entrada
If ExistBlock("OFA000FG")
	if !ExecBlock("OFA000FG",.f.,.f.)   
		DisarmTransaction()
		Break
	Endif
Endif

End Transaction

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³IA000IMP  ºAutor  ³Fabio               º Data ³  08/15/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Grava Importacao                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA000IMP(cAlias,nReg,nOpc)

Local aRotOld := {}, cMsgNF := ""
Local cTesE  := ""
Local nTBaseIPI := 0


Local nItNovo := 0
Local cNumIte := Repl( "0", Len(SD1->D1_ITEM) )

Local lMsgRet := .F.

Local lIAutSB1 := ( GetNewPar("MV_MIL0135","1") == "1" ) // Caso nao exista o Item no Cadastro de Produtos? - 1-Inclui automaticamente / 0-Nao Inclui e aborta processo
Local cSemafor := ""

Private cPecInt , cGruIte
Private aCab := {} , aItem := {}, aIncSB1:= {}
Private lMSHelpAuto := .t. , lMSErroAuto := .f. , lMsFinalAuto := .f.
Private cCdPecAut   := GetNewPar("MV_CDPCAUT","S")  //PRIMEIRA POSICAO SE DEIXA CADASTRAR ITEM PELA ENTRADA DA NF
//SEGUNDA POSICAO EM DIANTE PECA QUE NAO PODE SER CADASTRADA PELA ENTRADA DA NF

If !MsgYesNo(OemToAnsi(STR0007), OemToAnsi(STR0008))
	Return
EndIf

If Select("TMPVI0") > 0
	TMPVI0->(DbCloseArea())
EndIf	

cQuery := " SELECT VI0.R_E_C_N_O_ AS NROREG ,"
cQUery += "        ( COUNT(VI0.R_E_C_N_O_) OVER( PARTITION BY ' ' ) ) AS NTOTREG "
cQuery += "   FROM "+ RetSqlName("VI0") +" VI0 "
cQuery += "  WHERE VI0.VI0_FILIAL = '"+xFilial("VI0")+"'"
cQuery += "    AND VI0.VI0_OK='"+ThisMark()+"'"
cQuery += "    AND VI0.D_E_L_E_T_ = ' '"

TCQUERY cQuery NEW ALIAS "TMPVI0"

ProcRegua( TMPVI0->NTOTREG )

Do While !TMPVI0->( Eof() )

	DbSelectArea("VI0")
	DbGoTo(TMPVI0->NROREG)

	If IsMark("VI0_OK",ThisMark(),ThisInv()) .And. !FS_FILIA000BROW()
		if !OFIOM390(VI0->VI0_CODMAR+VI0->VI0_NUMNFI+VI0->VI0_SERNFI+VI0->VI0_CODFOR+VI0->VI0_LOJFOR)
			MsgInfo(STR0011+" "+VI0->VI0_NUMNFI+"-"+VI0->VI0_SERNFI+" "+STR0012,STR0010)
			TMPVI0->( DbSkip() )
			loop
		endif
		
		If Select("TMPSB1A") > 0
			TMPSB1A->(DbCloseArea())     
		EndIf	

		cQuery := "SELECT VIA.VIA_FILIAL,  "
		cQuery +=       " VIA.VIA_NUMNFI,  "
		cQuery +=       " VIA.VIA_SERNFI,  "
		cQuery +=       " VIA.VIA_CODFOR,  "
		cQuery +=       " VIA.VIA_LOJFOR,  "
		cQuery +=       " ( CASE WHEN VIA.VIA_GRUITE <> ' ' THEN VIA.VIA_GRUITE ELSE VE4.VE4_GRUITE END ) AS VIA_GRUITE, "
		cQuery +=       " VIA.VIA_CODITE,  "
		cQuery +=       " SB1.B1_GRUPO,  "
		cQuery +=       " SB1.B1_CODITE,  "
		cQuery +=       " SB1.R_E_C_N_O_ AS NROREGSB1  "
		cQuery += "  FROM "+ RetSqlName("VIA") +" VIA "
		cQuery += "  JOIN "+ RetSqlName("VE4") +" VE4 ON ( VE4.VE4_FILIAL = '"+xFilial("VE4")+"' AND VE4.VE4_PREFAB = VIA.VIA_CODMAR AND VE4.D_E_L_E_T_ = ' ' ) "
		cQuery += "  LEFT JOIN "+ RetSqlName("SB1") +" SB1 ON ( SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND ( ( VIA.VIA_GRUITE <> ' ' AND SB1.B1_GRUPO = VIA.VIA_GRUITE ) Or ( VIA.VIA_GRUITE = ' ' AND SB1.B1_GRUPO = VE4.VE4_GRUITE ) ) AND SB1.B1_CODITE = VIA.VIA_CODITE AND SB1.D_E_L_E_T_ = ' ' ) "
		cQuery += " WHERE VIA.VIA_FILIAL = '"+xFilial("VIA")+"'"  
		cQuery +=   " AND VIA.VIA_NUMNFI = '"+VI0->VI0_NUMNFI+"'"  
		cQuery +=   " AND VIA.VIA_SERNFI = '"+VI0->VI0_SERNFI+"'"  
		cQuery +=   " AND VIA.VIA_CODFOR = '"+VI0->VI0_CODFOR+"'"  
		cQuery +=   " AND VIA.VIA_LOJFOR = '"+VI0->VI0_LOJFOR+"'"  
		cQuery +=   " AND VIA.D_E_L_E_T_ = ' '"

		TCQUERY cQuery NEW ALIAS "TMPSB1A"
		DbSelectArea("TMPSB1A")

		If !lIAutSB1 // NAO Inclui automaticamente - Valida se existe o Item na tabela SB1 do banco

			cMsgItem := ""								
			Do While !TMPSB1A->(Eof())

				If Empty( TMPSB1A->B1_CODITE )

					If Empty(cMsgItem)
						cMsgItem += STR0026+Chr(13)+chr(10) // Há itens não cadastrados no Cadastro de Produtos!
						cMsgItem += STR0011+": "+TMPSB1A->VIA_NUMNFI+" - "+TMPSB1A->VIA_SERNFI+Chr(13)+chr(10) // Nota Fiscal: 
						cMsgItem += STR0027+TMPSB1A->VIA_CODFOR+" - "+TMPSB1A->VIA_LOJFOR+Chr(13)+chr(10) // Fornecedor: 
					EndIf

					cMsgItem += STR0020+" "+TMPSB1A->VIA_GRUITE+" - "+TMPSB1A->VIA_CODITE+Chr(13)+chr(10)

				EndIf

				DbSelectArea("TMPSB1A")
				DbSkip()

			EndDo
			
			If !Empty(cMsgItem)

				MsgStop(cMsgItem,STR0010) // Atencao
				Exit // Abortar caso nao exista o Item na tabela SB1 do banco

			EndIf

		EndIf

		cSemafor := Alltrim("OFIIA000|"+Alltrim(cUserName)+"|"+xFilial("VI0")+"|"+VI0->VI0_NUMNFI+"|"+VI0->VI0_SERNFI+"|"+VI0->VI0_CODFOR+"|"+VI0->VI0_LOJFOR)
		If !OFIIA00011_CriaSemaforo( cSemafor )
			Exit
		EndIf

		Begin Transaction

		// Lock em todos os produtos antes de processar para garantir o processamento
		DbSelectArea("TMPSB1A")
		dbgotop()
		Do While !TMPSB1A->(Eof())

			DbSelectArea("SB1")
			DbGoTo( TMPSB1A->NROREGSB1 )

			If !SB1->(DBRLock())

				lMsgRet := .T.

				DisarmTransaction()
				Break

			EndIf

			// O Mata103/SIGACUSA bloqueia todos os registro do produto na SB2 por isso desse tratamento
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek( xFilial("SB2") + SB1->B1_COD )
			Do While !SB2->(Eof()) .And. SB2->B2_FILIAL + SB2->B2_COD == xFilial("SB2") + SB1->B1_COD

				If !SB2->(DBRLock())

					lMsgRet := .T.

					DisarmTransaction()
					Break

				EndIf

				DbSelectArea("SB2")
				DbSkip()

			EndDo

			DbSelectArea("TMPSB1A")
			DbSkip()

		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PE para fazer checagens antes da geracao das notas             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("OFIIACHK")
			ExecBlock("OFIIACHK",.F.,.F.)
		EndIf
		
		DbSelectArea("VIA")
		DbSetOrder(3)
		DbSeek(xFilial("VIA")+VI0->VI0_CODMAR+VI0->VI0_NUMNFI+VI0->VI0_SERNFI+VI0->VI0_CODFOR+VI0->VI0_LOJFOR)
		
		DbSelectArea("VE4")
		DbSetOrder(1)
		DbSeek( xFilial("VE4") + VI0->VI0_CODMAR )
		
		// Utilizacao da funcao de NF Entrada MATA140
		// Entrada da Nota Fiscal - Cabecalho
		DbSelectArea("SA2")
		If !Empty(VI0->VI0_CODFOR)
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + VI0->VI0_CODFOR + VI0->VI0_LOJFOR )
		Else
			DbSetOrder(3)
			If !DbSeek( xFilial("SA2") + VIA->VIA_CGCFOR )
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek( xFilial("SA2") + VE4->VE4_CODFOR + VE4->VE4_LOJFOR )
			EndIf
		EndIf
		
		cParam := GetNewPar("MV_ESPECNF","NF")
		aCab := {;
		{"F1_TIPO"	   , "N"			       ,NIL},;
		{"F1_DOC"	   , VIA->VIA_NUMNFI	 ,NIL},;
		{"F1_SERIE"	   , VIA->VIA_SERNFI	 ,NIL},;
		{"F1_EMISSAO"  , VI0->VI0_DTAFAT	 ,NIL},;
		{"F1_FORNECE"  , SA2->A2_COD 	    ,NIL},;
		{"F1_LOJA"	   , SA2->A2_LOJA  	 ,NIL},;
		{"F1_ESPECIE"  , cParam    	   	 ,NIL},;
		{"F1_COND"	   , IIf(!Empty(VI0->VI0_CODPAG),VI0->VI0_CODPAG,VE4->VE4_PGTNFP) ,NIL},;
		{"F1_SEGURO"  	, VI0->VI0_SEGURO ,NIL},;
		{"F1_FRETE"    , VI0->VI0_FRETES	 ,NIL},;
		{"F1_DESPESA"  , VI0->VI0_DESPES ,NIL},;
		{"F1_VALICM"	, VI0->VI0_VLTICM	 ,Nil},;
		{"F1_VALIPI"	, VI0->VI0_VLTIPI	 ,Nil},;
		{"F1_FORMUL"	, "N"	      		 ,Nil},;
		{"F1_RECBMTO"	, dDataBase			 ,Nil}}
		if !Empty(VI0->VI0_BASSUB) .and. !Empty(VI0->VI0_ICMSUB)
			aAdd(aCab,{"F1_BRICMS", VI0->VI0_BASSUB, NIL})
			aAdd(aCab,{"F1_ICMSRET", VI0->VI0_ICMSUB, Nil})                   
		endif
		
		DbSelectArea("VIA")
		Do While !eof() .and. ;
				VIA->VIA_FILIAL+VIA->VIA_CODMAR+VIA->VIA_SERNFI+VIA->VIA_NUMNFI+VIA->VIA_CODFOR+Alltrim(VIA->VIA_LOJFOR) == ;
				xFilial("VIA") +VI0->VI0_CODMAR+VI0->VI0_SERNFI+VI0->VI0_NUMNFI+VI0->VI0_CODFOR+Alltrim(VI0->VI0_LOJFOR)
			
			DbSelectArea("VE4")
			DbSetOrder(1)
			If DbSeek( xFilial("VE4") + VIA->VIA_CODMAR )
				
				If !Empty(VIA->VIA_GRUITE)
					cGruIte:=VIA->VIA_GRUITE
				Else
					cGruIte:=VE4->VE4_GRUITE
				EndIf
				
				DbSelectArea("SBM")
				DbSetOrder(1)
				DbSeek( xFilial("SBM") + cGruIte )
				
				DbSelectArea("SB1")
				FS_ITEIA000(cGruIte,VIA->VIA_CODITE)

				DbSelectArea("SB1")
				DbSetOrder(7)
				SB1->(DbSeek( xFilial("SB1") + cGruIte + VIA->VIA_CODITE ))

				If lIAutSB1 .and. !Found() // Incluir automaticamente o SB1 caso nao exista o Item na tabela do banco

					If subs(cCdPecAut,1,1) == "S" .and. !(cGruite $ subs(cCdPecAut,3)) .or.;
						subs(cCdPecAut,1,1) == "S" .and. empty(subs(cCdPecAut,3))
						
						If GetNewPar("MV_ITESEQ","S") == "1"
							cPecInt := VIA->VIA_CODITE
						ElseIf GetNewPar("MV_ITESEQ","S") == "2"
							cPecInt := cGruIte+VIA->VIA_CODITE
						Else
							cPecInt := GetSXENum("SB1","B1_COD")
							ConfirmSX8()
						EndIf
						
						aIncSB1:= {}
						aAdd(aIncSB1,{"B1_COD"     ,cPecInt               ,Nil}) // Codigo
						aAdd(aIncSB1,{"B1_CODITE"  , VIA->VIA_CODITE      ,Nil}) // Codigo
						aAdd(aIncSB1,{"B1_TIPO"    ,"ME"                  ,Nil}) // Tipo do Produto
						aAdd(aIncSB1,{"B1_UM"      ,"PC"                  ,Nil}) //
						aAdd(aIncSB1,{"B1_SEGUM"   ,"PC"                  ,Nil}) //
						
						If !Empty(VIA->VIA_ALMPAD)
							aAdd(aIncSB1,{"B1_LOCPAD"  ,VIA->VIA_ALMPAD   ,Nil}) //
						Else
							aAdd(aIncSB1,{"B1_LOCPAD"  ,VE4->VE4_ALMPAD   ,Nil}) //
						EndIf
						
						aAdd(aIncSB1,{"B1_TE"      ,VE4->VE4_TESENT       ,Nil}) //
						aAdd(aIncSB1,{"B1_TS"      ,VE4->VE4_TESSAI       ,Nil}) //
						aAdd(aIncSB1,{"B1_CONTA"   ,VE4->VE4_CTACTB       ,Nil}) //
						if !empty(VE4->VE4_CENCUS)
							aAdd(aIncSB1,{"B1_CC"   ,VE4->VE4_CENCUS      ,Nil}) //
						endif
						aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_FABRIC"  ,VE4->VE4_CODFAB        ,Nil}) //
						aAdd(aIncSB1,{"B1_CONTRAT" ,"N"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_LOCALIZ" ,"N"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_IRRF"    ,"N"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_CONTSOC" ,"N"                    ,Nil}) //
						
						aAdd(aIncSB1,{"B1_GRUPO"   , cGruIte               ,Nil}) // Grupo
						aAdd(aIncSB1,{"B1_GRUDES"  ,VE4->VE4_GRUDES        ,Nil}) //
						aAdd(aIncSB1,{"B1_SITPROD" ,"N"                    ,Nil}) //
						
						aAdd(aIncSB1,{"B1_FLAGSUG" ,"1"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_CLASSVE" ,"1"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_APROPRI" ,"D"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_FANTASM" ,"N"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_TIPODEC" ,"N"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_UREV   " ,DDATABASE              ,Nil}) //
						aAdd(aIncSB1,{"B1_PERINV"  ,180                    ,Nil}) //
						aAdd(aIncSB1,{"B1_GRADE"   ,"N"                    ,Nil}) //
						
						aAdd(aIncSB1,{"B1_FORAEST" ,IIf(VE4->VE4_FESTCO="0","N","S") ,Nil}) //
						aAdd(aIncSB1,{"B1_ANUENTE" ,"2"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_BALANCA" ,"0"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_IMPZFRC" ,"N"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_CONV"    ,1                      ,Nil}) //
						aAdd(aIncSB1,{"B1_ORIGEM"  ,"0"                    ,Nil}) //
						aAdd(aIncSB1,{"B1_PESO"    ,VIA->VIA_PESPEC        ,Nil}) //
						aAdd(aIncSB1,{"B1_PICM"    ,VE5->VE5_ALIICM        ,Nil}) //
						aAdd(aIncSB1,{"B1_IPI"     ,VIA->VIA_TXAIPI        ,Nil}) //
						aAdd(aIncSB1,{"B1_DESC"    ,VIA->VIA_DESITE        ,Nil}) // Descricao
						aAdd(aIncSB1,{"B1_PRV1"    ,VE5->VE5_ALTVLR        ,Nil}) //
                        if VIA->(FieldPos("VIA_CODIF")) > 0
							aAdd(aIncSB1,{"B1_CODIF"   ,VIA->VIA_CODIF     ,Nil}) //
						Endif
                        if VIA->(FieldPos("VIA_CODSIM")) > 0
							aAdd(aIncSB1,{"B1_CODSIMP"   ,VIA->VIA_CODSIM  ,Nil}) //
						Endif
						lMSHelpAuto := .t.
						lMSErroAuto := .f.
						
						If ( ExistBlock("OFMT010A") )
							aIncSB1 := ExecBlock("OFMT010A",.f.,.f.,{aIncSB1})
						EndIf
						
						MSExecAuto({|x| mata010(x)},aIncSB1)
						
						if lMSErroAuto
							MostraErro()
							DisarmTransaction()
							Break
						endif
						
						dbselectarea("SB5")
						DbSetOrder(1)
						DbSeek( xFilial("SB5") + cPecInt )
						
						If !RecLock("SB5", !Found() )
							Help("  ",1,"REGNLOCK")
							lRet := .f.
							DisarmTransaction()
							Break
						EndIf
						
						SB5->B5_FILIAL := xFilial("SB5")
						SB5->B5_COD    := cPecInt
						SB5->B5_CEME   := SB1->B1_DESC
						MsUnLock()
						
						// Abre tela para o usuaria complementar o cadastro do item
						If GetNewPar("MV_COMPITE","N") == "S"
							
							cCadastro  := STR0022
							aRotOld    := aClone(aRotina)
							aCpoAltSB1 := {}
							lCopia     := .f.
							aRotina    := {	{ STR0001 ,"A010Pesqui", 0 , 1},;	//Pesquisar
											{ STR0002 ,"AxVisual", 0 , 2},;		//Visualizar
											{ STR0009 ,"A010Inclui", 0 , 3},;	//Incluir
											{ STR0003 ,"A010Altera", 0 , 4},;	//Alterar
											{ STR0004 ,"Mata010Deleta", 0 , 5}}	//Excluir
							
							DbSelectArea("SB1")
							A010ALTERA("SB1",Recno(),4)
							aRotina := aClone(aRotOld)
							cCadastro := OemToAnsi(STR0006)   //Garantia Solicitada VW //Importacao do Retorno de Garantia da Fabrica
							
						EndIf
						
					EndIf

				EndIf

				dbselectarea("SB5")
				DbSetOrder(1)
				DbSeek( xFilial("SB5") + SB1->B1_COD )

				DbSelectArea("VEI")
				DbSetOrder(2)
				DbSeek( xFilial("VEI") + VIA->VIA_CODMAR + VIA->VIA_PEDCON )
				
				If ( ExistBlock("OFMT010D") )
					ExecBlock("OFMT010D",.f.,.f.,{aIncSB1})
				EndIf				
				
				// Utilizacao da funcao de NF Entrada MATA140
				// Entrada da Nota Fiscal - Itens
				cTesE := ""
				If !Empty(VIA->VIA_TESENT)
					cTesE := VIA->VIA_TESENT
				ElseIf !Empty(VE4->VE4_TESENT)
					cTesE := VE4->VE4_TESENT
				Else
					cTesE := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TE")
				EndIf
				
				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek( xFilial("SF4") + cTesE )
				
				If Len(aItem) > 0
					cNumIte := aItem[Len(aItem),1,2]
				EndIf
				cNumIte := SOMA1(cNumIte)
				Aadd(aItem , {	{"D1_ITEM"		, cNumIte								  						,NIL},;
								{"D1_COD"		, SB1->B1_COD                      								,NIL},;
								{"D1_UM"    	, "PC"         	                 								,NIL},;
								{"D1_QUANT"		, VIA->VIA_QTDFAT                  								,NIL},;
								{"D1_VUNIT"		, VIA->VIA_VALITE/VIA->VIA_QTDFAT 								,NIL},;
								{"D1_TOTAL"		, VIA->VIA_VALITE                 								,NIL},;
								{"D1_VALIPI"   	, VIA->VIA_VALIPI                 								,NIL},;
								{"D1_IPI"      	, VIA->VIA_TXAIPI                 								,NIL},;
								{"D1_BASEIPI"   , Round( ( VIA->VIA_VALIPI / ( VIA->VIA_TXAIPI/100 ) ) ,2 )	,NIL},;
								{"D1_VALICM"   	, VIA->VIA_VALICM                 								,NIL},;
								{"D1_TES"	   	, cTesE                           								,NIL},;
								{"D1_RATEIO"	, "2"				                   							,NIL},;
								{"D1_CONBAR"	, "0"				                   							,NIL},;								
								{"D1_DESC"	    , VIA->VIA_PERDES	                   							,NIL},;
								{"D1_LOCAL"		, FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")						,NIL}})

				If VIA->(FieldPos("VIA_BASSUB")) > 0 .and. VIA->(FieldPos("VIA_ICMSUB")) > 0
					if !Empty(VIA->VIA_BASSUB) .and. !Empty(VIA->VIA_ICMSUB)
						aAdd( aItem[Len(aItem)], {"D1_BRICMS",  VIA->VIA_BASSUB, NIL})
						aAdd( aItem[Len(aItem)], {"D1_ICMSRET", VIA->VIA_ICMSUB, Nil})
					endif
				EndIf
				
				nTBaseIPI += ( VIA->VIA_VALIPI / ( VIA->VIA_TXAIPI/100 ) )
				
				// Se o item foi subst da baixa no pedido do item antigo e da entrada na NF do item novo
				If !Empty(VIA->VIA_ITESUB)
					
					DbSelectArea("SB1")
					DbSetOrder(7)
					DbSeek( xFilial("SB1") + cGruIte + VIA->VIA_ITESUB )
					
					// Se o item foi subs, procura com item subs, se nao encontrar o item usa o codigo normal
					DbSelectArea("SC7")
					DbSetOrder(4)
					If !DbSeek( xFilial("SC7") + SB1->B1_COD + VEI->VEI_NUM )
						
						DbSelectArea("SB1")
						DbSetOrder(7)
						DbSeek( xFilial("SB1") + cGruIte + VIA->VIA_CODITE )
						
						DbSelectArea("SC7")
						DbSetOrder(4)
						DbSeek( xFilial("SC7") + SB1->B1_COD + VEI->VEI_NUM )
						
					EndIf
					
				Else
					
					DbSelectArea("SC7")
					DbSetOrder(4)
					DbSeek( xFilial("SC7") + SB1->B1_COD + VEI->VEI_NUM )
					
				EndIf
				
				DbSelectArea("SC7")
				DbSetOrder(1)
				
				If SC7->(Found()) .and. nFormEnt == 1 // apenas atualiza SC7 quando Forma de Entrada igual a Nota

					If VIA->VIA_QTDFAT > ( SC7->C7_QUANT - SC7->C7_QUJE )
						cMsgNF += STR0013+" "+SB1->B1_GRUPO+" "+SB1->B1_CODITE+" "+STR0014+" "+VIA->VIA_PEDCON+" "+STR0015+Chr(13)+Chr(10)
						cMsgNF += STR0016+Transform(SC7->C7_QUANT  ,"999999999999")+Chr(13)+Chr(10)
						cMsgNF += STR0017+Transform(SC7->C7_QUJE   ,"999999999999")+Chr(13)+Chr(10)
						cMsgNF += STR0018+Transform(VIA->VIA_QTDFAT,"999999999999")+Chr(13)+Chr(10)
						
						RecLock("SC7",.F.)
						SC7->C7_QUANT := ( VIA->VIA_QTDFAT + SC7->C7_QUJE )
						MsUnLock()
						
					EndIf
					
					RecLock("SC7",.F.)
					SC7->C7_COND  := IIf(!Empty(VI0->VI0_CODPAG),VI0->VI0_CODPAG,VE4->VE4_PGTNFP)
					MsUnLock()
					
					If !Empty(VIA->VIA_ITESUB)
						RecLock("SC7",.F.)
						SC7->C7_QUJE += VIA->VIA_QTDFAT
						MsUnLock()
					Else
						
						// adiciona o numero do pedido antes do valor devido a nao conformidade com a integracao.
						// ( Estava considerando o valor do pedido na nota de entrada )
						aItemNovo := {}
						For nItNovo := 1 to Len(aItem[Len(aItem)])
							
							If Alltrim( aItem[Len(aItem),nItNovo,1] ) == "D1_QUANT"
								
								Aadd( aItemNovo , {"D1_PEDIDO"	   , VEI->VEI_NUM    ,NIL} )
								Aadd( aItemNovo , {"D1_ITEMPC"	   , SC7->C7_ITEM    ,NIL} )
								
							EndIf
							
							Aadd( aItemNovo, aItem[Len(aItem),nItNovo] )
							
						Next
						
						aItem[Len(aItem)] := aClone( aItemNovo )

					EndIf

				EndIf

				If ( ExistBlock("OFIIANFE") )
					aItem := ExecBlock("OFIIANFE",.f.,.f.,{aItem})
				EndIf

			EndIf

			DbSelectArea("VIA")
			DbSkip()
			
		EndDo
		
		aAdd(aCab,{"F1_BASEIPI", nTBaseIPI , Nil})  // Carrega o total da base do IPI
		
		// Seleciona a ordem dos arquivos SA2,SB1 p/ funcionar MATA140
		SA2->( DbSetOrder(1) )
		SB1->( DbSetOrder(1) )
		
		If nFormEnt == 1 // Nota
			MSExecAuto({|x,y| MATA103(x,y)},aCab,aItem)
		ElseIf nFormEnt == 2 // Pre-Nota
			MSExecAuto({|x,y| MATA140(x,y)},aCab,aItem)
		Endif

		aCab  := {}
		aItem := {}
		
		If lMSErroAuto
			MostraErro()
			DisarmTransaction()
			Break
		else
			DBSelectArea("SD1")
			DBSetOrder(1)
			DBSeek(xFilial("SD1")+VI0->VI0_NUMNFI+VI0->VI0_SERNFI+VI0->VI0_CODFOR+VI0->VI0_LOJFOR)
        	while xFilial("SD1")+VI0->VI0_NUMNFI+VI0->VI0_SERNFI+VI0->VI0_CODFOR+VI0->VI0_LOJFOR == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
	        	reclock("SD1",.f.)
    	    	SD1->D1_CONBAR := "0"
        		msunlock()
	        	DBSkip()
	        enddo
		EndIf
		
		If ExistBlock("OFA000DPG")
			ExecBlock("OFA000DPG",.f.,.f.,{VI0->VI0_NUMNFI,VI0->VI0_SERNFI,VI0->VI0_CODFOR,VI0->VI0_LOJFOR})
		Endif
		
		DbSelectArea("VI0")
		RecLock("VI0",.f.)
		VI0->VI0_OK := Space(Len(VI0->VI0_OK))
		MsUnLock()
		
		IncProc( OemToAnsi( VI0->VI0_CODMAR+VI0->VI0_SERNFI+VI0->VI0_NUMNFI ) )

		// Deleta o registro apos importacao
		If GetNewPar("MV_EXCVI0","S") == "S"
		
			DbSelectArea("VIA")
			DbSetOrder(3)
			DbSeek(xFilial()+VI0->VI0_CODMAR+VI0->VI0_NUMNFI+VI0->VI0_SERNFI+VI0->VI0_CODFOR+VI0->VI0_LOJFOR)
	
			Do While !eof() .And. VIA->VIA_FILIAL == xFilial("VIA") .And. VIA->VIA_CODMAR+VIA->VIA_SERNFI+VIA->VIA_NUMNFI+VIA->VIA_CODFOR+Alltrim(VIA->VIA_LOJFOR) == VI0->VI0_CODMAR+VI0->VI0_SERNFI+VI0->VI0_NUMNFI+VI0->VI0_CODFOR+Alltrim(VI0->VI0_LOJFOR)
				
							
				DbSelectArea("VIA")
				If !RecLock("VIA",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				DbDelete()
				MsUnLock()
				WRITESX2("VIA")
				
	
				DbSelectArea("VIA")
				DbSkip()
				
			EndDo

			
			DbSelectArea("VI0")
			If !RecLock("VI0",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			DbDelete()
			MsUnLock()
			WRITESX2("VI0")
			
		EndIf

		End Transaction


		If Select("TMPSB1A") > 0
			TMPSB1A->(DbCloseArea())     
		EndIf	

		OFIIA00021_LiberaSemaforo( cSemafor )

		DbSelectArea("SB1")
		DBUnlockAll()

		DbSelectArea("SB2")
		DBUnlockAll()

		If lMsgRet

			MsgStop(STR0028,STR0010) // Não foi possível reservar todos os produtos da nota fiscal! Favor tentar novamente. / Atencao

		EndIf

		lMsgRet := .F.

	EndIf
	
	TMPVI0->( DbSkip() )
	
EndDo

If Select("TMPVI0") > 0
	TMPVI0->(DbCloseArea())     
EndIf	

OFIIA00021_LiberaSemaforo( cSemafor )

If !Empty(cMsgNF)
	
	MsgAlert(cMsgNF,STR0010)
	
EndIf

DbSelectArea("VI0")

Return( !lMsErroAuto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS_FILIA000BROW ºAutor  ³Fabio         º Data ³  08/15/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Grava Importacao                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FILIA000BROW()

Local nRec   := 0
Local cQuery := ""
Local lRet   := .f.
If !Empty(VI0->VI0_CODFOR)
	cQuery := "SELECT SF1.R_E_C_N_O_ AS RECSF1 FROM "+RetSqlName("SF1")+" SF1 WHERE SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_DOC='"+VI0->VI0_NUMNFI+"' AND SF1.F1_SERIE='"+VI0->VI0_SERNFI+"' AND SF1.F1_FORNECE = '"+VI0->VI0_CODFOR+"' AND SF1.F1_LOJA = '"+VI0->VI0_LOJFOR+"' AND SF1.D_E_L_E_T_ = ' ' "
Else
	VIA->(DbSetOrder(1))
	VIA->(DbSeek(xFilial("VIA")+VI0->VI0_CODMAR+VI0->VI0_SERNFI+VI0->VI0_NUMNFI))
	cQuery := "SELECT SF1.R_E_C_N_O_ AS RECSF1 FROM "+RetSqlName("SF1")+" SF1 "
	cQuery += "JOIN "+RetSqlName("VE4")+" VE4 ON ( VE4.VE4_FILIAL='"+xFilial("VE4")+"' AND VE4.VE4_PREFAB='"+VI0->VI0_CODMAR+"' AND VE4.D_E_L_E_T_ = ' ' ) "
	If !Empty(VIA->VIA_CGCFOR)
		cQuery += "JOIN "+RetSqlName("SA2")+" SA2 ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_CGC='"+VIA->VIA_CGCFOR+"' AND SA2.D_E_L_E_T_ = ' ' ) "
	Else
		cQuery += "JOIN "+RetSqlName("SA2")+" SA2 ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=VE4.VE4_CODFOR AND SA2.A2_LOJA=VE4.VE4_LOJFOR AND SA2.D_E_L_E_T_ = ' ' ) "
   EndIf
	cQuery += "WHERE SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_DOC='"+VI0->VI0_NUMNFI+"' AND SF1.F1_SERIE='"+VI0->VI0_SERNFI+"' AND SF1.F1_FORNECE=SA2.A2_COD AND SF1.F1_LOJA=SA2.A2_LOJA AND SF1.D_E_L_E_T_ = ' ' "
Endif
nRec := FM_SQL(cQuery)
If nRec > 0
	lRet := .t.
EndIf

DbSelectArea("VI0")

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MenuDef   ºAutor  ³Fabio               º Data ³  09/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Cria aRotina ( MENUDEF )                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ STR0001 ,"axPesqui", 0 , 1},;   //Pesquisar
					{ STR0002 ,"IA000"   , 0 , 2},;   //Visualizar
					{ STR0003 ,"IA000"   , 0 , 4},;   //Alterar
					{ STR0004 ,"IA000"   , 0 , 5},;   //Excluir
					{ STR0005 ,"Processa( {|| IA000IMP() } )"  , 0 , 4}}    //Importar
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ITEIA00ºAutor  ³Fabio               º Data ³  10/18/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Identifica se o produto esta cadastrado como original sendo º±±
±±º          ³que deveria estar como nao original.                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ITEIA000(cGruIte,cCodIte)

Local nIndSB1 := SB1->(IndexOrd()), nRegSB1 := SB1->(Recno())
Local nIndSB2 := SB2->(IndexOrd()), nRegSB2 := SB2->(Recno())
Local nIndSD1 := SD1->(IndexOrd()), nRegSD1 := SD1->(Recno())
Local lIgual := .t.

If GetNewPar("MV_COMPITE","N") == "S" .and. ( Type("lMSHelpAuto")== "U" .or. !lMSHelpAuto )
	
	If VE4->VE4_FILIAL # xFilial("VE4")
		VE4->(DbSetOrder(1))
		VE4->(DbSeek( xFilial("VE4") ))
	EndIf
	
	SB1->(DbSetOrder(7))
	If ( SB1->(DbSeek( xFilial("SB1") + cGruIte + cCodIte )) ;                     // Procura produto informado
		.or. SB1->(DbSeek( xFilial("SB1") + VE4->VE4_GRUITE + cCodIte )) )         // Se nao achar o produto informado procura com o grupo padrao
		
		SB2->(DbSetOrder(1))
		If ( !SB2->(DbSeek( xFilial("SB2") + SB1->B1_COD )) .or. Empty(SB2->B2_QATU) )
			
			SD1->(DbSetOrder(5))
			If !SD1->(DbSeek( xFilial("SD1") + SB1->B1_COD ))
				
				// Abre tela para o usuaria complementar o cadastro do item
				cCadastro := OemtoAnsi(STR0022)
				aRotOld := aClone(aRotina)
				aRotina := {{ STR0001 ,"A010Pesqui", 0 , 1},;     //Pesquisar
							{ STR0002  ,"AxVisual", 0 , 2},;      //Visualizar
							{ STR0009 ,"A010Inclui", 0 , 3},;     //Incluir
							{ STR0003 ,"A010Altera", 0 , 4},;     //Alterar
							{ STR0004 ,"Mata010Deleta", 0 , 5} }  //Excluir
				Do While lIgual
					
					DbSelectArea("SB1")
					A010ALTERA("SB1",Recno(),4)
					aRotina := aClone(aRotOld)
					cCadastro := OemToAnsi(STR0006)   //"Garantia Solicitada VW" //"Importacao do Retorno de Garantia da Fabrica"
					
					lIgual := .f.
					If cGruIte # SB1->B1_GRUPO
						lIgual := MsgYesNo(STR0019 + Chr(13)+Chr(10) ;
						+STR0020+" "+ cGruIte       + " - " + cCodIte + Chr(13)+Chr(10) ;
						+STR0021+" "+ SB1->B1_GRUPO + " - " + cCodIte + Chr(13)+Chr(10),STR0010)
					EndIf
					
				EndDo
				
			EndIf
			
		EndIf
		
	EndIf
	
EndIf

SB1->(DbSetOrder(nIndSB1))
SB1->(DbGoTo(nRegSB1))
SB2->(DbSetOrder(nIndSB2))
SB2->(DbGoTo(nRegSB2))
SD1->(DbSetOrder(nIndSD1))
SD1->(DbGoTo(nRegSD1))

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  º Autor ³ Manoel / Rubens 			   º Data ³ 15/10/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³  IA200PERG              									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IA200PERG(lPergunte)

Local cPerg := "IA200PER"

SetKey(VK_F12,Nil)

// AADD(aRegs,{STR0023,STR0023,STR0023,'MV_CH1','N',01,0,0,'C','','MV_PAR01',STR0024,STR0024,STR0024,'','',STR0025,STR0025,STR0025,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})

Pergunte(cPerg,lPergunte,,,,.f.)
While Empty(MV_PAR01)
	Pergunte(cPerg,.t.,,,,.f.)
Enddo

nFormEnt := MV_PAR01

SetKey(VK_F12,{ || IA200PERG(.T.) })

Return

/*/{Protheus.doc} OFIIA00011_CriaSemaforo
Cria Semaforo para Inclusao dos Itens / NF de Entrada

@author Andre Luis Almeida
@since  20/08/2019
/*/
Static Function OFIIA00011_CriaSemaforo( cSemafor )
	Local nCntTent := 1
	Local lOk
	While !( lOk := LockByName( cSemafor , .f. /* lEmpresa */ , .t. /* lFilial */ , .t. ))
		MsAguarde( {|| Sleep(10000) } , STR0029 + ALLTRIM(STR(nCntTent)), STR0030) // Semaforo de processamento... tentativa / Aguarde
		nCntTent++
		If nCntTent > 10
			lOk := .f.
			Exit
		EndIf
	EndDo
Return lOk

/*/{Protheus.doc} OFIIA00021_LiberaSemaforo
Libera Semaforo para Inclusao dos Itens / NF de Entrada

@author Andre Luis Almeida
@since  20/08/2019
/*/
Static Function OFIIA00021_LiberaSemaforo( cSemafor )
	UnLockByName( cSemafor, .f. /* lEmpresa */ , .t. /* lFilial */ , .t. )
Return