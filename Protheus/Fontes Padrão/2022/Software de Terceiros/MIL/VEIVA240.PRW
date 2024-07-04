// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 24     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "VEIVA240.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVA240 ³ Autor ³  Fabio                ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de F&I                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA240()
Private aRotina     := MenuDef()
Private cCadastro   := STR0006 // Cadastro de F&I
Private lVAS_CODINT := ( VAS->(FieldPos("VAS_CODINT")) > 0 ) // Codigo Interno dos registros VAS
DbSelectArea("VAR")
mBrowse( 6, 1,22,75,"VAR")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVA240 ³ Autor ³  Fabio                ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aRotina ( MenuDef )                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ STR0001,"axPesqui", 0 , 1  },;				// Pesquisar
	  				{ STR0002,"VA240"   , 0 , 2  },;				// Visualizar
					{ STR0003,"VA240"   , 0 , 3  },;				// Incluir
					{ STR0004,"VA240"   , 0 , 4  },;				// Alterar
					{ STR0005,"VA240"   , 0 , 5  },;				// Excluir
					{ STR0034,"VA240PARAM()"     , 0 , 2 },;		// Parametros
					{ STR0007,"VA240EXPIMP('E')" , 0 , 3 },;		// Exportar
					{ STR0008,"VA240EXPIMP('I')" , 0 , 3 } }		// Importar
If ExistBlock("VM240IMP") // Ponto de Entrada que importa tabela da Instituicao Financeira
	aadd(aRotina,{STR0035,"U_VM240IMP()",0,3}) // Integracao Banco
Endif
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VA240    º Autor ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Tela                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA240(cAlias, nReg, nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aInfo := {} //aPosObjApon := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
//
Local bCampo   := { |nCPO| Field(nCPO) } , _ni := 0 , nCntFor := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice  :={}
Private nOpcG:=nOpc
Private nOpcE:=nOpc
Private nLenAcols := 0
Private aVetEmp := {}//vetor com as filias que usam a tabela!
Private aNewBot := {}
Private nUsado := 0
If FindFunction("VX005F3RET")
	If VAS->(FieldPos("VAS_NIVRET")) > 0
		aNewBot := { {"BAIXATIT",{|| M->VAS_NIVRET:=aCols[n,FG_POSVAR("VAS_NIVRET")]:=VX005F3RET(nOpc,aCols[n,FG_POSVAR("VAS_NIVRET")]) },STR0036},; // Nivel de Retorno F&I
		{"PREDIO",{||FS_FILUTI()},STR0037},; // Filiais
		{"SDUIMPORT",{||FS_VAREPLI()},STR0038}} // Replicar
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VAR",.T.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAR")
While !Eof().and.(x3_arquivo=="VAR")
	If X3USO(x3_usado).and.cNivel>=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	EndIf
	&("M->"+x3_campo) := CriaVar(x3_campo)
	dbSkip()
End
If !(Inclui)
	DbSelectArea("VAR")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VAS")
aHeader:={}
While !Eof().And.(x3_arquivo=="VAS")
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And. !(Alltrim(x3_campo) $ [VAS_CODBCO/VAS_CODIGO/VAS_TIPTAB])
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
	EndIf
	
	&("M->"+x3_campo) := CriaVar(x3_campo)
	
	dbSkip()
End

DbSelectArea("VAS")
if VAS->(FieldPos("VAS_NIVRET")) > 0
	DbSetOrder(2)
Else
	DbSetOrder(1)
EndIf

if VAR->(FieldPos("VAR_TIPTAB")) > 0
	DbSeek(xFilial("VAS")+M->VAR_CODBCO+M->VAR_CODIGO+M->VAR_TIPTAB)
else
	DbSeek(xFilial("VAS")+M->VAR_CODBCO+M->VAR_CODIGO)
endif

If nOpc == 3 .Or. !Found()
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Else
	aCols:={}
	While !eof() .And. VAS->VAS_FILIAL+VAS->VAS_CODBCO+VAS->VAS_CODIGO == xFilial("VAS")+M->VAR_CODBCO+M->VAR_CODIGO
		If lVAS_CODINT
			/////////////////////////////////////////////
			// ACERTAR TODOS OS "VAS_CODINT" EM BRANCO //
			/////////////////////////////////////////////
			If Empty(VAS->VAS_CODINT)
				RecLock("VAS",.f.)
					VAS->VAS_CODINT := GetSXENum("VAS","VAS_CODINT")
					ConfirmSX8()
				MsUnLock()
			EndIf
			/////////////////////////////////////////////
		EndIf
		if VAR->(FieldPos("VAR_TIPTAB")) > 0
			if M->VAR_TIPTAB != VAS->VAS_TIPTAB
				dbSkip()
				loop
			endif
		endif
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
	End
	nLenaCols     := Len(aCols)
EndIf

If Len(aCols)>0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       := STR0006 //Cadastro de F&I"
	cAliasEnchoice:="VAR"
	cAliasGetD    :="VAS"
	cLinOk        :="IIf( FS_VLVAS() , FG_OBRIGAT() , .f. )"
	cTudOk        :="AllwaysTrue() .and. FS_VLCOE()" // FNC 6471 - BOBY - 01/06/10
	cFieldOk      :="FS_VLVAS()"
	
	AAdd( aObjects, { 05,110, .T. , .F. } )   		//Label Superior
	AAdd( aObjects, { 05, 00, .T. , .T. } )   		//Label Superior

	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)

	DEFINE MSDIALOG oDlg1 TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd STYLE DS_MODALFRAME STATUS PIXEL
	oDlg1:lEscClose := .F.
	
	EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1]+5,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
	oGetDados := MsGetDados():New(aPosObj[2,1]+002,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
	oGetDados:oBrowse:bChange    := {|| FG_AALTER("VAS",nLenaCols,oGetDados),FG_MEMVAR()  }
	oGetDados:oBrowse:bDelete    := {|| ( aCols[n,Len(aCols[n])] := !aCols[n,Len(aCols[n])] ),Iif(!FS_VLVAS(),( ( aCols[n,Len(aCols[n])] := !aCols[n,Len(aCols[n])] ) ),.t.),,oGetDados:oBrowse:Refresh() }
	
	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| if(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_VA240GRA(nOpc),( FS_GRAVFIL(nOpc),oDlg1:End() ),.f.) },{|| oDlg1:End() },,aNewBot)
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VA240GRºAutor  ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chama gravacao                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VA240GRA(nOpc)

Private lMsHelpAuto := .t., lMsFinalAuto := .f.

If !FS_GRAVA240( nOpc , .t. )
	MostraErro()
	Return( .f. )
EndIf

Begin Transaction

FS_GRAVA240(nOpc)

End Transaction
lMsHelpAuto := .f.

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRAVA240 ³ Autor ³  Fabio             ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVA240( nOpc , lValid )

Local lRet := .t. , i := 0 //, aVetValid := {}
Private lMsHelpAuto := .t.

lValid := If( lValid == NIL , .f. , lValid )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2
	
	DbSelectArea("VAR")
	DbSetOrder(1)
	if VAR->(FieldPos("VAR_TIPTAB")) > 0
		DbSeek( xFilial("VAR") + M->VAR_CODBCO + M->VAR_CODIGO + M->VAR_TIPTAB)
	else
		DbSeek( xFilial("VAR") + M->VAR_CODBCO + M->VAR_CODIGO )
	endif
	// Grava arquivo pai
	If !lValid
		
		If Inclui .Or. Altera
			
			If !RecLock("VAR", !Found() )
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			FG_GRAVAR("VAR")
			MsUnlock()
			
		EndIf
		
		// grava arquivo filho
		For i:=1 to len(aCols)
			
			If i > nLenaCols .and. aCols[i,Len(aCols[i])]
				Loop
			EndIf
 
			DbSelectArea("VAS")
			If lVAS_CODINT
				DbSetOrder(3)
				If Empty(aCols[I,FG_POSVAR("VAS_CODINT")])
					aCols[I,FG_POSVAR("VAS_CODINT")] := GetSXENum("VAS","VAS_CODINT")
					ConfirmSX8()
				EndIf
				DbSeek( xFilial("VAS") + aCols[I,FG_POSVAR("VAS_CODINT")])
			Else
				DbSetOrder(1)
				if VAR->(FieldPos("VAR_TIPTAB")) > 0 .AND. VAS->(FieldPos("VAS_NIVRET")) > 0
					DbSeek( xFilial("VAS") + M->VAR_CODBCO + M->VAR_CODIGO + M->VAR_TIPTAB + aCols[I,FG_POSVAR("VAS_QTDPAR")]+aCols[I,FG_POSVAR("VAS_NIVRET")])
				else
					DbSeek( xFilial("VAS") + M->VAR_CODBCO + M->VAR_CODIGO + aCols[I,FG_POSVAR("VAS_QTDPAR")])
				endif
			EndIf
			If (Inclui .Or. Altera)
				If !aCols[i,Len(aCols[i])]
					If !RecLock("VAS", !Found() )
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf					
					FG_GRAVAR("VAS",aCols,aHeader,i)
					VAS->VAS_FILIAL := xFilial("VAS")
					VAS->VAS_CODBCO := M->VAR_CODBCO
					VAS->VAS_CODIGO := M->VAR_CODIGO
					if VAR->(FieldPos("VAR_TIPTAB")) > 0
						VAS->VAS_TIPTAB := M->VAR_TIPTAB
					endif
					MsUnlock()
				Else					
					If Found()
						If !RecLock("VAS",.F.,.T.)
							Help("  ",1,"REGNLOCK")
							lRet := .f.
							DisarmTransaction()
							Break
						EndIf
						dbdelete()
						MsUnlock()
						WriteSx2("VAS")
					EndIf
				EndIf
			ElseIf Found()
				// Deleta
				If !RecLock("VAS",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				dbdelete()
				MsUnlock()
				WriteSx2("VAS")
			EndIf
			
		Next
		
	EndIf
	
	// Exclui arquivo pai
	DbSelectArea("VAR")
	
	If !(Inclui .Or. Altera) .And. Found()
		
		If !lValid
			
			// Deleta
			If !RecLock("VAR",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			dbdelete()
			MsUnlock()
			WriteSx2("VAR")
			
		EndIf
		
	EndIf
	
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VLVAS  ºAutor  ³Fabio               º Data ³  02/21/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao no VAS ( digitacao )                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLVAS()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VLCOE  ºAutor  ³Antonio             º Data ³  28/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida Coeficiente                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLCOE()
Local lRet := .T.
Local ix1:=0
If 1 == 2
	FS_VLCOE() // Somente para nao dar Warning de Compilacao
EndIf
For ix1 := 1 to len(aCols)
	If aCols[ix1,FG_POSVAR("VAS_COEFIC")] == 0 .and. !aCols[ix1,len(aCols[ix1])]//valida se a linha esta valida
		MsgStop(STR0039,STR0009) // Coeficiente não pode ser igual a zero! / Atencao
		lRet := .F.
	EndIf
Next
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |VA240EXPIMPº Autor ³ Andre Luis Almeida º Data ³ 20/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exporta / Importa Tabelas F&I por filias                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA240EXPIMP(cTip)
Local lOK         := .f.
Local cMask       := ""
Local cArquivo    := ""
Local aSX3VAR     := {}
Local aSX3VAS     := {}
Local	aCampos   := {}
Local nj          := 0
Local ni          := 0
Private lMarcar   := .f.
Private aVAR      := {}
Private oOk       := LoadBitmap( GetResources(), "LBTIK" )
Private oNo       := LoadBitmap( GetResources(), "LBNO" )
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAR")
While !Eof() .and. SX3->X3_ARQUIVO == "VAR"
	If SX3->X3_CONTEXT <> "V" .and. Alltrim(SX3->X3_CAMPO) <> "VAR_FILIAL"  // Levanta Campos Reais VAR (Pai)
		aAdd(aSX3VAR,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_PICTURE})
	EndIf
	DbSelectArea("SX3")
	DbSkip()
EndDo
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAS")
While !Eof() .and. SX3->X3_ARQUIVO == "VAS"
	If SX3->X3_CONTEXT <> "V" .and. Alltrim(SX3->X3_CAMPO) <> "VAS_FILIAL" // Levanta Campos Reais VAS (Filho)
		aAdd(aSX3VAS,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_PICTURE})
	EndIf
	DbSelectArea("SX3")
	DbSkip()
EndDo
If cTip == "E" // Exportar *.FAI
	DbSelectArea("VAR")
	DbSetOrder(1)
	DbSeek(xFilial("VAR"))
	While !Eof() .and. VAR->VAR_FILIAL == xFilial("VAR")
		lok := .f.
		if VAS->(FieldPos("VAS_DATFIN")) <> 0
			DbSelectArea("VAS")
			DbSetOrder(1)
			DbSeek(xFilial("VAS")+VAR->VAR_CODBCO+VAR->VAR_CODIGO)
			While !Eof() .and. VAS->VAS_FILIAL == xFilial("VAS") .and. VAR->VAR_CODBCO == VAS->VAS_CODBCO .and. VAR->VAR_CODIGO == VAS->VAS_CODIGO
				if !Empty(VAS->VAS_DATFIN)
					if (VAS->VAS_DATINI > dDataBase) .or. (VAS->VAS_DATFIN < dDataBase)
						lOk := .t.
						Exit
					Endif
				Endif
				DbSelectArea("VAS")
				DbSkip()
			EndDo
		ElseIf VAR->(FieldPos("VAR_DATFIN")) <> 0
			if !Empty(VAR->VAR_DATFIN)
				if (VAR->VAR_DATINI > dDataBase) .or. (VAR->VAR_DATFIN < dDataBase)
					lOk := .t.
				Endif
			Endif
		EndIf
		aAdd(aVAR,{lOk,VAR->VAR_CODBCO+" - "+VAR->VAR_NOMBCO,VAR->VAR_CODIGO+" - "+VAR->VAR_DESCOD,VAR->(RecNo())})
		DbSelectArea("VAR")
		DbSkip()
	EndDo
	If len(aVAR) > 0 // Tela com os Bancos/Tabelas da Filial
		DEFINE MSDIALOG oTabFAI FROM 000,000 TO 038,100 TITLE (STR0010+" - "+STR0011+" "+cFilAnt+" - "+FWFilialName()) OF oMainWnd // Tabelas F&I / Filial:
		@ 002,002 LISTBOX oLbVAR FIELDS HEADER " ",STR0012,STR0013 10,85,85 SIZE 392,267 OF oTabFAI PIXEL ON DBLCLICK (aVAR[oLbVAR:nAt,1]:=!aVAR[oLbVAR:nAt,1]) // Banco / Tabela / Data Inicio / Data Final
		oLbVAR:SetArray(aVAR)
		oLbVAR:bLine := { || { IIf(aVAR[oLbVAR:nAt,1],oOk,oNo) ,;
		aVAR[oLbVAR:nAt,2] ,;
		aVAR[oLbVAR:nAt,3]}}
		@ 002,003 CHECKBOX oTK VAR lMarcar PROMPT "" OF oTabFAI ON CLICK FS_TIK() SIZE 08,08 PIXEL
		@ 273,290 BUTTON oBotOK   PROMPT STR0016 OF oTabFAI SIZE 43,11 PIXEL ACTION (lOK:=.t.,oTabFAI:End()) //OK
		@ 273,343 BUTTON oBotSair PROMPT STR0017 OF oTabFAI SIZE 43,11 PIXEL ACTION oTabFAI:End() // Sair
		ACTIVATE MSDIALOG oTabFAI CENTER
		If !lOk
			Return()
		EndIf
	EndIf
EndIf
cMask := STR0010+" (*.FAI) |*.FAI|" // Tabelas F&I
cArquivo := cGetFile(cMask,STR0010,,,IIf(cTip=="I",.t.,.f.),,.t.) // Tabelas F&I
If cTip == "E" .and. lOk // Exportar *.FAI
	If left(right(cArquivo,4),1) == "."
		cArquivo := left(cArquivo,len(cArquivo)-4)
	EndIf
	If !( ".FAI" $ cArquivo )
		cArquivo := cArquivo+".FAI"
	EndIf
	nHnd := FCREATE(cArquivo,0) // Cria Arquivo FAI
	If nHnd >=0
		For nj := 1 to len(aVAR)
			If aVAR[nj,1] // Grava arquivo FAI somente com o(s) "VAR" selecionado(s)
				DbSelectArea("VAR")
				DbSetOrder(1)
				DbGoTo(aVAR[nj,4])
				FWrite(nHnd,"VAR"+VAR->VAR_CODBCO+VAR->VAR_CODIGO+"|")
				For ni := 1 to len(aSX3VAR)
					If aSX3VAR[ni,2] == "D" // Data
						FWrite(nHnd,dtos(&(aSX3VAR[ni,1]))+"|")
					ElseIf aSX3VAR[ni,2] == "N" // Numerico
						FWrite(nHnd,strzero(&(aSX3VAR[ni,1])*10000000,20)+"|")
					ElseIf !Empty(aSX3VAR[ni,3]) // Com Mascara
						FWrite(nHnd,Transform(&(aSX3VAR[ni,1]),VAR->(X3PICTURE(aSX3VAR[ni,1])))+"|")
					Else // Sem Mascara
						FWrite(nHnd,&(aSX3VAR[ni,1])+"|")
					EndIf
				Next
				FWrite(nHnd,chr(13)+chr(10))
				DbSelectArea("VAS")
				DbSetOrder(1)
				DbSeek(xFilial("VAS")+VAR->VAR_CODBCO+VAR->VAR_CODIGO)
				While !Eof() .and. VAS->VAS_FILIAL == xFilial("VAS") .and. VAR->VAR_CODBCO == VAS->VAS_CODBCO .and. VAR->VAR_CODIGO == VAS->VAS_CODIGO
					if VAR->(FieldPos("VAR_TIPTAB")) > 0
						if VAR->VAR_TIPTAB != VAS->VAS_TIPTAB
							dbSkip()
							loop
						endif
					endif
					if VAR->(FieldPos("VAR_TIPTAB")) > 0
						FWrite(nHnd,"VAS"+VAS->VAS_CODBCO+VAS->VAS_CODIGO+VAS->VAS_TIPTAB+VAS->VAS_QTDPAR+"|")
					else
						FWrite(nHnd,"VAS"+VAS->VAS_CODBCO+VAS->VAS_CODIGO+VAS->VAS_QTDPAR+"|")
					endif
					For ni := 1 to len(aSX3VAS)
						If aSX3VAS[ni,2] == "D" // Data
							FWrite(nHnd,dtos(&(aSX3VAS[ni,1]))+"|")
						ElseIf aSX3VAS[ni,2] == "N" // Numerico
							FWrite(nHnd,strzero(&(aSX3VAS[ni,1])*10000000,20)+"|")
						ElseIf !Empty(aSX3VAS[ni,3]) // Com Mascara
							FWrite(nHnd,Transform(&(aSX3VAS[ni,1]),VAS->(X3PICTURE(aSX3VAS[ni,1])))+"|")
						Else // Sem Mascara
							FWrite(nHnd,&(aSX3VAS[ni,1])+"|")
						EndIf
					Next
					FWrite(nHnd,chr(13)+chr(10))
					DbSelectArea("VAS")
					DbSkip()
				EndDo
			EndIf
		Next
		FClose(nHnd)
		VAR->(DbSeek(xFilial("VAR")))
		VAS->(DbSeek(xFilial("VAS")))
		MsgInfo(STR0018+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cArquivo,STR0009) // Arquivo exportado com sucesso! / Atencao
	Else
		MsgStop(STR0019+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cArquivo,STR0009) // Impossivel criar o arquivo! / Atencao
	EndIf
ElseIf cTip == "I" // Importar *.FAI
	if (nHandle:= FT_FUse( cArquivo )) == -1
		MsgStop(STR0020+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cArquivo,STR0009) // Impossivel abrir o arquivo! / Atencao
		Return()
	EndIf
	FT_FGotop()
	While !FT_FEof() // Grava VAR e VAS com arquivo *.FAI
		cStr := FT_FReadLN()
		cTab := left(cStr,3)
		If cTab == "VAR"
			aCampos := aClone(aSX3VAR)
		ElseIf cTab == "VAS"
			aCampos := aClone(aSX3VAS)
		EndIf
		Campo := substr(cStr,4,AT("|",cStr)-4)
		DbSelectArea(cTab)
		DbSetOrder(1)
		DbSeek(xFilial(cTab)+Campo)
		RecLock(cTab,!Found())
		&(cTab+"->"+cTab+"_FILIAL") := xFilial(cTab)
		For ni := 1 to len(aCampos)
			cStr := substr(cStr,AT("|",cStr)+1)
			Campo := substr(cStr,1,AT("|",cStr)-1)
			If aCampos[ni,2] == "D" // Data
				&(cTab+"->"+aCampos[ni,1]) := stod(Campo)
			ElseIf aCampos[ni,2] == "N" // Numerico
				&(cTab+"->"+aCampos[ni,1]) := (val(Campo)/10000000)
			Else // Caracter
				&(cTab+"->"+aCampos[ni,1]) := Campo
			EndIf
		Next
		MsUnLock()
		FT_FSkip()
	End
	FT_FUse()
	MsgInfo(STR0021+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cArquivo,STR0009) // Arquivo importado com sucesso! / Atencao
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³   FS_TIK   ³ Autor ³ Andre Luis Almeida   ³ Data ³ 21/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ TIK TOTAL (marcar/desmarcar)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK()
Local ni := 0
For ni := 1 to Len(aVAR)
	If lMarcar
		aVAR[ni,1] := .t.
	Else
		aVAR[ni,1] := .f.
	EndIf
Next
oLbVAR:SetFocus()
oLbVAR:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VA240PARAM ³ Autor ³ Rafael Goncalves     ³ Data ³ 08/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Funcao para manutencao dos parametros de F&I                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA240PARAM()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aInfo := {} //aPosObjApon := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
Local aObjlist := {}
Local aPosObjList := {}
//
Local cNivRet  := GetMV("MV_FIBTABR") // Niveis de Retorno possiveis quando nao informado o Cliente
Local cBcoTab  := GetMV("MV_FIBCTBV")+space(20) // Banco, Tabela e Tipo da Tabela utilizado na Simulacao ( TAXA DO DIA )
Local lFIAllBc := ( GetMv("MV_FIALLBC") == "S" ) // caso nao esteja preenchido o banco, mostrar todas as tabelas de f&i de todos os bancos
//
Local cCodBco  := substr(cBcoTab,1,len(VAS->VAS_CODBCO))
Local cCodTab  := substr(cBcoTab,len(cCodBco)+1,len(VAS->VAS_CODIGO))
Local cNomBco  := space(len(VAR->VAR_NOMBCO))
Local cTipTab  := substr(cBcoTab,len(cCodBco+cCodTab)+1,1)
Local aDesab   := {}
Local aHabil   := {}
Local ni := 1
Local aTipTab := X3CBOXAVET("VAR_TIPTAB","1")  //Funcao para retornar as opcoes do combobox - VEIFUNB
aObjects := {}
AAdd( aObjects, { 05, 80, .T. , .F. } ) 	// Label Superior
AAdd( aObjects, { 05, 50, .T. , .T. } )   	// Label Inferior
// objetos do label inferior.
AADD( aObjlist, { 55,  10, .T., .T. } ) 	// Caixa
AADD( aObjlist, { 90,  10, .F., .T. } ) 	// Caixa
AADD( aObjlist, { 75,  10, .F., .T. } ) 	// Caixa
AADD( aObjlist, { 90,  10, .F., .T. } ) 	// Caixa
AADD( aObjlist, { 55,  10, .T., .T. } ) 	// Caixa

// Fator de reducao de 0.8
for nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
next

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

aPosObjList := MsObjSize( { aPosObj[2,2] , aPosObj[2,1] , aPosObj[2,4] , aPosObj[2,3] , 1, 1 } , aObjlist , .T. , .T. )

If !Empty(cCodBco) //carrega o nome do banco.
	DbSelectArea("VAR")
	DbSetOrder(1)
	IF DbSeek(xFilial("VAR")+cCodBco)
		cNomBco:=VAR->VAR_NOMBCO
	EndIf
EndIf

//carrega os niveis de retornos  contigos no parametro.
For ni := 0 to 50
	if StrZero(ni,2) $ cNivRet
		aAdd(aHabil,{StrZero(ni,2)})
	Else
		aAdd(aDesab,{StrZero(ni,2)})
	EndIF
Next

//verifica o conteudo dos array para adcionar em branco.
IF Len(aHabil)<=0
	aAdd(aHabil,{" "})
EndIF
IF Len(aDesab)<=0
	aAdd(aDesab,{" "})
EndIF

nTam := 28  // linhas do cabecalho a desconsiderar
DEFINE MSDIALOG oVEA240P TITLE STR0022 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd STYLE DS_MODALFRAME STATUS PIXEL // Parametros de F&I
oVEA240P:lEscClose := .F.
@ aPosObj[1,1]+02,aPosObj[1,2]+01 TO aPosObj[1,3],aPosObj[1,4]/2 LABEL STR0042 OF oVEA240P PIXEL  // Taxa do Dia
@ aPosObj[1,1]+13,aPosObj[1,2]+10 SAY STR0043 SIZE (aPosObj[1,4]/2)-15,40 OF oVEA240P PIXEL COLOR CLR_RED // Informe o Codigo do Banco, Tabela e Tipo de Tabela que serão considerados na Taxa do Dia.

@ aPosObj[1,1]+11+nTam,aPosObj[1,2]+12 SAY (STR0023+":") SIZE 60,10 OF oVEA240P PIXEL COLOR CLR_BLUE //Codigo Banco
@ aPosObj[1,1]+10+nTam,aPosObj[1,2]+50 MSGET oCodBco VAR cCodBco PICTURE "@!" F3 "VARPAR" SIZE 37,8 OF oVEA240P PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+10+nTam,aPosObj[1,2]+91 MSGET oNomBco VAR cNomBco PICTURE "@!" SIZE 100,8 OF oVEA240P PIXEL COLOR CLR_BLUE WHEN .F.

@ aPosObj[1,1]+26+nTam,aPosObj[1,2]+12 SAY (STR0024+":") SIZE 30,10 OF oVEA240P PIXEL COLOR CLR_BLUE //Tabela
@ aPosObj[1,1]+25+nTam,aPosObj[1,2]+50 MSGET oCodTab VAR cCodTab PICTURE "@!" SIZE 30,8 OF oVEA240P PIXEL COLOR CLR_BLUE WHEN .F.
@ aPosObj[1,1]+26+nTam,aPosObj[1,2]+91 SAY (STR0025+":") SIZE 50,10 OF oVEA240P PIXEL COLOR CLR_BLUE //Tipo Tabela
@ aPosObj[1,1]+25+nTam,aPosObj[1,2]+131 MSCOMBOBOX OTipTab VAR cTipTab SIZE 60,10 ITEMS aTipTab OF oVEA240P PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+02,(aPosObj[1,4]/2)+01 TO aPosObj[1,3],aPosObj[1,4] LABEL STR0044 OF oVEA240P PIXEL // Tela de Financiamento/Leasing
@ aPosObj[1,1]+13,(aPosObj[1,4]/2)+10 SAY STR0045 SIZE (aPosObj[2,4]/2)-15,40 OF oVEA240P PIXEL COLOR CLR_RED // Informe se na Tela de Financiamento/Leasing do Atendimento serão visualizados todos os Bancos e suas respectivas Tabelas F&I, caso não for informado o campo Banco na Tela.
@ aPosObj[1,1]+11+nTam,(aPosObj[1,4]/2)+12 CHECKBOX oFIAllBc VAR lFIAllBc PROMPT STR0048 OF oVEA240P SIZE 200,08 PIXEL COLOR CLR_BLUE // Mostrar todos os Bancos/Tabelas de F&I

@ aPosObj[2,1]+02,aPosObj[2,2]+01 TO aPosObj[2,3],aPosObj[2,4] LABEL STR0046 OF oVEA240P PIXEL // Niveis de Retorno
@ aPosObj[2,1]+11,aPosObj[2,2]+10 SAY STR0047 SIZE aPosObj[2,4],30 OF oVEA240P PIXEL COLOR CLR_RED // Informe quais Niveis de Retorno serao considerados no Atendimento quando nao for informado o Codigo/Loja do Cliente.

//LIST BOX DESABILITADOS
@ aPosObjList[2,1]+25 ,aPosObjList[2,2]+1 LISTBOX oLbDesab FIELDS HEADER STR0026 COLSIZES 20 ; //Desabilitado(s)
						SIZE aPosObjList[2,4] - aPosObjList[2,2] - 4, aPosObjList[2,3] - aPosObjList[2,1] - 27  OF oVEA240P PIXEL
oLbDesab:SetArray(aDesab)
oLbDesab:bLine := { || { aDesab[oLbDesab:nAt,01] }}
//label + botoes
@ aPosObjList[3,1]+25,aPosObjList[3,2]+1 TO aPosObjList[3,3]-2,aPosObjList[3,4] LABEL "" OF oVEA240P PIXEL
@ aPosObjList[3,1]+037,aPosObjList[3,2]+((75-60)/2) BUTTON oBotIncl PROMPT ( STR0027+" >"  ) OF oVEA240P SIZE 60,11 PIXEL ACTION (FS_MUDNIV(@aHabil,@aDesab,"1",oLbDesab:nAt,"1"),oLbDesab:Refresh(),oLbHabil:Refresh()) //ADCIONAR
@ aPosObjList[3,1]+057,aPosObjList[3,2]+((75-60)/2) BUTTON oBotIncl PROMPT ( STR0028+" >>" ) OF oVEA240P SIZE 60,11 PIXEL ACTION (FS_MUDNIV(@aHabil,@aDesab,"1",oLbDesab:nAt,"2"),oLbDesab:Refresh(),oLbHabil:Refresh()) //ADCIONAR TODOS
@ aPosObjList[3,1]+077,aPosObjList[3,2]+((75-60)/2) BUTTON oBotIncl PROMPT ( "< " +STR0029 ) OF oVEA240P SIZE 60,11 PIXEL ACTION (FS_MUDNIV(@aHabil,@aDesab,"2",oLbHabil:nAt,"1"),oLbDesab:Refresh(),oLbHabil:Refresh()) //REMOVER
@ aPosObjList[3,1]+097,aPosObjList[3,2]+((75-60)/2) BUTTON oBotIncl PROMPT ( "<< "+STR0030 ) OF oVEA240P SIZE 60,11 PIXEL ACTION (FS_MUDNIV(@aHabil,@aDesab,"2",oLbHabil:nAt,"2"),oLbDesab:Refresh(),oLbHabil:Refresh()) //REMOVER TODOS

//LIST BOX HABILITADOS.
@ aPosObjList[4,1]+25 ,aPosObjList[4,2]+4 LISTBOX oLbHabil FIELDS HEADER STR0031 COLSIZES 20 ;   //Ativo(s)
						SIZE aPosObjList[4,4] - aPosObjList[4,2] - 4, aPosObjList[4,3] - aPosObjList[4,1] - 27  OF oVEA240P PIXEL
oLbHabil:SetArray(aHabil)
oLbHabil:bLine := { || { aHabil[oLbHabil:nAt,01] }}

ACTIVATE MSDIALOG oVEA240P CENTER ON INIT  EnchoiceBar(oVEA240P,{ || nOpca := 1, iif(FS_GRVPRM(cCodBco,cCodTab,cTipTab,aHabil,lFIAllBc),oVEA240P:End(),.f.)}  ,  {|| nOpca := 2, oVEA240P:End() })
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_GRVPRM  ³ Autor ³ Rafael Goncalves     ³ Data ³ 08/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Grava as alteracoes nos parametros de F&I                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro| cCodBco - Codigo do Branco                                  ³±±
±±³         | cCodTab - Codigo da Tabela                                  ³±±
±±³         | cTipTab - Tipo da tebela                                    ³±±
±±³         | aHabil - Array com tabelas ativas                           ³±±
±±³         | lFIAllBc - Mostra Todos os Bancos/Tabelas FI                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRVPRM(cCodBco,cCodTab,cTipTab,aHabil,lFIAllBc)
Local lRet := .t.
Local nx := 1
Local cValPar := ""
Default cCodBco :=""
Default cCodTab :=""
Default cTipTab :=""
Default aHabil := {}

If !Empty(cCodBco)
	DbSelectArea("VAR")
	DbSetOrder(1)
	IF !DbSeek(xFilial("VAR")+cCodBco)
		MsgInfo(STR0032,STR0009) //Codigo do banco inválido!
		lRet := .f.
	EndIf
End
If Empty(cCodBco) .or. Empty(cCodTab) .and. lRet
	MsgInfo(STR0033,STR0009)  //Codigo do banco não informado!
	lRet := .f.
Else
	//alterado o valor do paraemtro para o informado.
	PutMv("MV_FIBCTBV",cCodBco+cCodTab+cTipTab)
	//alterado o valor do paraemtro para o informado.
	For nx:=1 to len(aHabil)
		IF nx <> len(aHabil)
			cValPar += 	aHabil[nx,1]+"/"
		Else
			cValPar += 	aHabil[nx,1]
		EndIF
	next
	PutMv("MV_FIBTABR",cValPar)
	PutMv("MV_FIALLBC",IIf(lFIAllBc,"S","N"))
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_MUDNIV  ³ Autor ³ Rafael Goncalves     ³ Data ³ 08/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Habilita / Desabilita vetor                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro| 1 - Array Habilitado                                        ³±±
±±³         | 2 - Array Desabilitado                                      ³±±
±±³         | 3 - Tipo Movimentacao 1-Desabi->Habil/2Habil->Desabilitado  ³±±
±±³         | 4 - Linha selecionada                                       ³±±
±±³         | 5 - 1-individual ou 2-todos                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MUDNIV(aHabil,aDesab,cTipMov,nLinSel,cIndTod)
Local ny:=1
Local ni := 0
Local nf := 0

default cIndTod := "1"

iF cTipMov=="1"//remove do deasbilitado adcinando no Habilitado.
	IF cIndTod == "1"//Individual
		ni := nLinSel
		nf := nLinSel
	Elseif cIndTod == "2"//Todos
		ni := 1
		nf := Len(aDesab)
	EndIf
	If len(aHabil) == 1 .and. Empty(aHabil[1,1])
		aHabil := {}
	EndIf
	//adiciona no Array Habilitados
	For ny:=ni to nf
		if !Empty(aDesab[ny,01])
			aAdd(aHabil,{aDesab[ny,01]})
		EndIf
	next
	//remove selecionado do array Desabilitados
	aDesab := {}
	For ny:=0 to 50
		IF aScan(aHabil,{|x| x[1] == Strzero(ny,2) }) <= 0
			aAdd(aDesab,{Strzero(ny,2)})
		Endif
	Next
Elseif cTipMov=="2"//remove do Habilitado adcinando no desabilitado.
	IF cIndTod == "1"//Individual
		ni := nLinSel
		nf := nLinSel
	Elseif cIndTod == "2"//Todos
		ni := 1
		nf := Len(aHabil)
	EndIf
	If len(aDesab) == 1 .and. Empty(aDesab[1,1])
		aDesab := {}
	EndIf
	//adiciona no Array Habilitados
	For ny:=ni to nf
		if !Empty(aHabil[ny,01])
			aAdd(aDesab,{aHabil[ny,01]})
		EndIf
	next
	//remove selecionado do array Desabilitados
	aHabil := {}
	For ny:=0 to 50
		IF aScan(aDesab,{|x| x[1] == Strzero(ny,2) }) <= 0
			aAdd(aHabil,{Strzero(ny,2)})
		Endif
	Next
EndIF

If Len(aDesab)<=0
	aAdd(aDesab,{""})
EndIf

If Len(aHabil)<=0
	aAdd(aHabil,{""})
EndIf

aSort(aDesab,,,{|x,y| x[1]<y[1]})
aSort(aHabil,,,{|x,y| x[1]<y[1]})
//desabilitados
oLbDesab:SetArray(aDesab)
oLbDesab:bLine := { || { aDesab[oLbDesab:nAt,01] }}
//Habilitados
oLbHabil:SetArray(aHabil)
oLbHabil:bLine := { || { aHabil[oLbHabil:nAt,01] }}

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VAREPLIºAutor  ³Rafael Goncalves    º Data ³  20/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta Tela Replicacao de valores no Acols                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAREPLI()
//variaveis controle de janela
Local aObjects 	:= {} , aPosObj := {} , aInfo := {} //aPosObjApon := {}
Local aSizeAut 	:= MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam 	:= 0
Local nTam 		:= 0
Local _ni 		:= 0
Local nOpcao 	:= 0

Private dDtInic := ctod("")
Private lDtInic	:= .f.
Private dDtFim 	:= ctod("")
Private lDtFim	:= .f.
Private nComRet	:= 0
Private lComRet	:= .f.
Private nPePlus	:= 0
Private lPePlus	:= .f.
Private nCusRec	:= 0
Private lCusRec	:= .f.
Private nVlrTac	:= 0
Private lVlrTac	:= .f.
Private nPerCtb	:= 0
Private lPerCtb	:= .f.
Private nSubFin	:= 0
Private lSubFin	:= .f.
Private nTacLiq	:= 0
Private lTacLiq	:= .f.
Private nPerent	:= 0
Private lPerent	:= .f.
Private aTacSub := X3CBOXAVET("VAS_TACSUB","1")  //Funcao para retornar as opcoes do combobox - VEIFUNB
Private cTacSub	:= space(Len(VAS->VAS_TACSUB))
Private lTacSub	:= .f.
Private nVlrEnt	:= 0
Private lVlrEnt	:= .f.
Private cPParvi	:= space(Len(VAS->VAS_PPARVI))
Private lPParvi	:= .f.
Private cInTerv := space(Len(VAS->VAS_INTERV))
Private lInTerv := .f.
Private cCodAco := space(Len(VAS->VAS_CODACO))
Private lCodAco := .f.
Private lMarTds := .f. //marcar todos
Private lLstRlp := .f. //marca todos da getdados
Private lPerret := .f. //percentual de retorno, controlar o campo % Contrib
Private aLstRpl	:={}
Private aColsTemp	:={}
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

aColsTemp := aClone(aCols)//clona acols para manipular valores.

For _ni:=1 to Len(aColsTemp)//carrega listbox com informacoes do aColsTemp
	aAdd(aLstRpl, { .f.,;
	aColsTemp[_ni,FG_POSVAR("VAS_DATINI","aHeader")],;//02
	aColsTemp[_ni,FG_POSVAR("VAS_DATFIN","aHeader")],;//03
	aColsTemp[_ni,FG_POSVAR("VAS_COMRET","aHeader")],;//04
	aColsTemp[_ni,FG_POSVAR("VAS_PEPLUS","aHeader")],;//05
	aColsTemp[_ni,FG_POSVAR("VAS_VLRTAC","aHeader")],;//06
	aColsTemp[_ni,FG_POSVAR("VAS_TACLIQ","aHeader")],;//07
	aColsTemp[_ni,FG_POSVAR("VAS_CUSREC","aHeader")],;//08
	aColsTemp[_ni,FG_POSVAR("VAS_PERCTB","aHeader")],;//09
	aColsTemp[_ni,FG_POSVAR("VAS_SUBFIN","aHeader")],;//10
	aColsTemp[_ni,FG_POSVAR("VAS_PERENT","aHeader")],;//11
	aColsTemp[_ni,FG_POSVAR("VAS_VLRENT","aHeader")],;//12
	aColsTemp[_ni,FG_POSVAR("VAS_TACSUB","aHeader")],;//13
	aColsTemp[_ni,FG_POSVAR("VAS_PPARVI","aHeader")],;//14
	aColsTemp[_ni,FG_POSVAR("VAS_INTERV","aHeader")],;//15
	aColsTemp[_ni,FG_POSVAR("VAS_PERRET","aHeader")],;//16
	aColsTemp[_ni,FG_POSVAR("VAS_CODACO","aHeader")]})//17
	If !lPerret
		If aColsTemp[_ni,FG_POSVAR("VAS_PERRET","aHeader")] <= 0
			lPerret := .t.
		EndIF
	EndIf
Next

If Len(aLstRpl)<=0
	aAdd(aLstRpl, { .f.,"","","","","","","","","","","","","","","",""}	)
EndIf

AAdd( aObjects, { 05,100, .T. , .F. } )   		//Label Superior
AAdd( aObjects, { 05,000, .T. , .T. } )   		//Label Inferior
// Fator de reducao de 0.8
for nCntTam := 1 to Len(aSizeAut)
	aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)
next

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlgRp TITLE STR0038 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd STYLE DS_MODALFRAME STATUS PIXEL // Replicar
oDlgRp:lEscClose := .F.
nTam := ( aPosObj[1,4] / 8 ) //varaivel que armazena o resutlado da divisao da tela.
@ aPosObj[1,1]+002,aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL "" OF oDlgRp PIXEL
//data inicial


@ aPosObj[1,1]+011,010+aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) SAY oDtIni VAR VAS->(RetTitle("VAS_DATINI")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+009,aPosObj[1,2]+000+(nTam*1)+((((nTam*2)-(nTam*1))-60)/2) MSGET oDtInic VAR dDtInic VALID(FS_VALDT("1")) PICTURE "@D" SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE
//data final
@ aPosObj[1,1]+011,004+aPosObj[1,2]+005+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) SAY oDtFi VAR VAS->(RetTitle("VAS_DATFIN")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+009,aPosObj[1,2]+000+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2) MSGET oDtFim VAR dDtFim VALID(FS_VALDT("2")) PICTURE "@D" SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE
//comissao retorno
@ aPosObj[1,1]+011,004+aPosObj[1,2]+005+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) SAY oComRe VAR VAS->(RetTitle("VAS_COMRET")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+009,aPosObj[1,2]+000+(nTam*7)+((((nTam*8)-(nTam*7))-70)/2) MSGET oComRet VAR nComRet VALID(FS_VALCPO()) PICTURE "@E 99.99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE

//Perce. Plus
@ aPosObj[1,1]+026,010+aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) SAY OPePlu VAR VAS->(RetTitle("VAS_PEPLUS")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+024,aPosObj[1,2]+000+(nTam*1)+((((nTam*2)-(nTam*1))-60)/2) MSGET OPePlus VAR nPePlus VALID(FS_VALCPO()) PICTURE "@E 99.99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE
//Custo receber
@ aPosObj[1,1]+026,004+aPosObj[1,2]+005+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) SAY oCusRe VAR VAS->(RetTitle("VAS_CUSREC")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+024,aPosObj[1,2]+000+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2) MSGET oCusRec VAR nCusRec VALID(FS_VALCPO()) PICTURE "@E 99.99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE
//Valor TAc
@ aPosObj[1,1]+026,004+aPosObj[1,2]+005+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) SAY oVlrTa VAR VAS->(RetTitle("VAS_VLRTAC")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+024,aPosObj[1,2]+000+(nTam*7)+((((nTam*8)-(nTam*7))-70)/2) MSGET oVlrTac VAR nVlrTac VALID(FS_VALCPO()) PICTURE "@E 999,999,999.99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE

//Perce. Contribuicao
@ aPosObj[1,1]+041,010+aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) SAY oPerCt VAR VAS->(RetTitle("VAS_PERCTB")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+039,aPosObj[1,2]+000+(nTam*1)+((((nTam*2)-(nTam*1))-60)/2) MSGET oPerCtb VAR nPerCtb VALID(FS_VALCPO()) PICTURE "@E 99.99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE When lPerret
//% Subsid. Fin
@ aPosObj[1,1]+041,004+aPosObj[1,2]+005+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) SAY oSubFi VAR VAS->(RetTitle("VAS_SUBFIN")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+039,aPosObj[1,2]+000+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2) MSGET oSubFin VAR nSubFin VALID(FS_VALCPO()) PICTURE "@E 99.99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE
//Valor loquido da TAC
@ aPosObj[1,1]+041,004+aPosObj[1,2]+005+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) SAY oTacLi VAR VAS->(RetTitle("VAS_TACLIQ")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+039,aPosObj[1,2]+000+(nTam*7)+((((nTam*8)-(nTam*7))-70)/2) MSGET oTacLiq VAR nTacLiq VALID(FS_VALCPO()) PICTURE "@E 999,999,999.99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE

//Perce. Entrada
@ aPosObj[1,1]+056,010+aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) SAY oPeren VAR VAS->(RetTitle("VAS_PERENT")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+054,aPosObj[1,2]+000+(nTam*1)+((((nTam*2)-(nTam*1))-60)/2) MSGET oPerent VAR nPerent VALID(FS_VALCPO()) PICTURE "@E 99.99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE when lPerent
//TAC Calculo subsidiado
@ aPosObj[1,1]+056,004+aPosObj[1,2]+005+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) SAY oTacSu VAR VAS->(RetTitle("VAS_TACSUB")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+054,aPosObj[1,2]+000+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2) MSCOMBOBOX oTacSub VAR cTacSub SIZE 54,10 ITEMS aTacSub OF oDlgRp PIXEL COLOR CLR_BLUE
//Valor Entrada
@ aPosObj[1,1]+056,004+aPosObj[1,2]+005+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) SAY oVlrEn VAR VAS->(RetTitle("VAS_VLRENT")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+054,aPosObj[1,2]+000+(nTam*7)+((((nTam*8)-(nTam*7))-70)/2) MSGET oVlrEnt VAR nVlrEnt VALID(FS_VALCPO()) PICTURE "@E 999,999,999.99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE WHEN lVlrEnt

//Dias 1 parcela
@ aPosObj[1,1]+071,010+aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) SAY oPParv VAR VAS->(RetTitle("VAS_PPARVI")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+069,aPosObj[1,2]+000+(nTam*1)+((((nTam*2)-(nTam*1))-60)/2) MSGET oPParvi VAR cPParvi PICTURE "99" SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE
//Intervalo parcelas
@ aPosObj[1,1]+071,004+aPosObj[1,2]+005+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) SAY oInTer VAR VAS->(RetTitle("VAS_INTERV")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+069,aPosObj[1,2]+000+(nTam*4)+((((nTam*5)-(nTam*4))-60)/2) MSGET oInTerv VAR cInTerv PICTURE "99"  SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE
//codigo acordo
@ aPosObj[1,1]+071,004+aPosObj[1,2]+005+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) SAY oCodAC VAR VAS->(RetTitle("VAS_CODACO")) SIZE 50,08 OF oDlgRp PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+069,aPosObj[1,2]+000+(nTam*7)+((((nTam*8)-(nTam*7))-70)/2) MSGET oCodAco VAR cCodAco F3 "VZU" VALID(FG_SEEK("VZU","cCodAco",1,.F.)) SIZE 55,08 OF oDlgRp PIXEL COLOR CLR_BLUE


//botao replicar
@ aPosObj[1,1]+084,aPosObj[1,2]+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) CHECKBOX oMarTds VAR lMarTds PROMPT STR0040 OF oDlgRp ON CLICK FS_TIK2() SIZE 50,10 PIXEL // Marca Todos
@ aPosObj[1,1]+084,aPosObj[1,2]+(nTam*7)+((((nTam*8)-(nTam*7))-50)/2) BUTTON oBotSair PROMPT STR0038 OF oDlgRp SIZE 43,11 PIXEL ACTION FS_REPACLS() // Replicar

//checkbox
@ aPosObj[1,1]+009,aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) CHECKBOX oCDtInic VAR lDtInic PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+009,aPosObj[1,2]+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) CHECKBOX oCDtFim VAR lDtFim PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+009,aPosObj[1,2]+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) CHECKBOX oCComRet VAR lComRet PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+024,aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) CHECKBOX oCPePlus VAR lPePlus PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+024,aPosObj[1,2]+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) CHECKBOX oCCusRec VAR lCusRec PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+024,aPosObj[1,2]+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) CHECKBOX oCVlrTac VAR lVlrTac PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+039,aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) CHECKBOX oPerCtb VAR lPerCtb PROMPT "" OF oDlgRp SIZE 40,10 PIXEL When lPerret
@ aPosObj[1,1]+039,aPosObj[1,2]+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) CHECKBOX oCSubFin VAR lSubFin PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+039,aPosObj[1,2]+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) CHECKBOX oCTacLiq VAR lTacLiq PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+054,aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) CHECKBOX oCPerent VAR lPerent PROMPT "" OF oDlgRp  ON CLICK FS_TIK3("1") SIZE 40,10 PIXEL
@ aPosObj[1,1]+054,aPosObj[1,2]+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) CHECKBOX oCTacSub VAR lTacSub PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+054,aPosObj[1,2]+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) CHECKBOX oCVlrEnt VAR lVlrEnt PROMPT "" OF oDlgRp  ON CLICK FS_TIK3("2") SIZE 40,10 PIXEL
@ aPosObj[1,1]+069,aPosObj[1,2]+005+(nTam*0)+((((nTam*1)-(nTam*0))-50)/2) CHECKBOX oCPParvi VAR lPParvi PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+069,aPosObj[1,2]+(nTam*3)+((((nTam*4)-(nTam*3))-50)/2) CHECKBOX oCInTerv VAR lInTerv PROMPT "" OF oDlgRp SIZE 40,10 PIXEL
@ aPosObj[1,1]+069,aPosObj[1,2]+(nTam*6)+((((nTam*7)-(nTam*6))-50)/2) CHECKBOX oCCodAco VAR lCodAco PROMPT "" OF oDlgRp SIZE 40,10 PIXEL



@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLstRpl FIELDS HEADER 	"" ,; //
								VAS->(RetTitle("VAS_DATINI")) ,; //
								VAS->(RetTitle("VAS_DATFIN")) ,; //
								VAS->(RetTitle("VAS_COMRET")) ,; //
								VAS->(RetTitle("VAS_PEPLUS")) ,; //
								VAS->(RetTitle("VAS_VLRTAC")) ,; //
								VAS->(RetTitle("VAS_CUSREC")) ,; //
								VAS->(RetTitle("VAS_PERCTB")) ,; //
								VAS->(RetTitle("VAS_TACLIQ")) ,; //
								VAS->(RetTitle("VAS_SUBFIN")) ,; //
								VAS->(RetTitle("VAS_PERENT")) ,; //
								VAS->(RetTitle("VAS_TACSUB")) ,; //
								VAS->(RetTitle("VAS_VLRENT")) ,; //
								VAS->(RetTitle("VAS_PPARVI")) ,; //
								VAS->(RetTitle("VAS_INTERV")) ,; //
								VAS->(RetTitle("VAS_CODACO"))  ; //
								COLSIZES 10,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50 SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[1,3]-2 OF oDlgRp PIXEL  ON DBLCLICK (aLstRpl[oLstRpl:nAt,1] := !aLstRpl[oLstRpl:nAt,1])
oLstRpl:SetArray(aLstRpl)
oLstRpl:bLine := { || {	IIf(aLstRpl[oLstRpl:nAt,1],oOk,oNo) ,;
						aLstRpl[oLstRpl:nAt,2] ,;
						aLstRpl[oLstRpl:nAt,3] ,;
						Transform( aLstRpl[oLstRpl:nAt,4],  "@E 99.99" )  ,;
						Transform( aLstRpl[oLstRpl:nAt,5],  "@E 99.99" )  ,;
						Transform( aLstRpl[oLstRpl:nAt,6],  "@E 999,999,999.99" )  ,;
						Transform( aLstRpl[oLstRpl:nAt,8],  "@E 99.99" )  ,;
						Transform( aLstRpl[oLstRpl:nAt,9],  "@E 99.99" )  ,;
						Transform( aLstRpl[oLstRpl:nAt,7],  "@E 999,999,999.99" )  ,;
						Transform( aLstRpl[oLstRpl:nAt,10], "@E 99.99" )  ,;
						Transform( aLstRpl[oLstRpl:nAt,11], "@E 99.99" )  ,;
						aLstRpl[oLstRpl:nAt,13]  ,;
						Transform( aLstRpl[oLstRpl:nAt,12], "@E 999,999,999.99" )  ,;
						Transform( aLstRpl[oLstRpl:nAt,14], "99" )  ,;
						Transform( aLstRpl[oLstRpl:nAt,15], "99" ) ,;
						aLstRpl[oLstRpl:nAt,17] }}

@ aPosObj[2,1],aPosObj[2,2]+002 CHECKBOX oCLstRlp VAR lLstRlp PROMPT "" OF oDlgRp ON CLICK FS_TIK4() SIZE 40,10 PIXEL

ACTIVATE MSDIALOG oDlgRp ON INIT EnchoiceBar(oDlgRp,{|| nOpcao := 1, oDlgRp:End() },{|| nOpcao := 0, oDlgRp:End() },,) Center

If nOpcao == 1
	aCols := aClone(aColsTemp)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_REPACLSºAutor  ³Rafael Goncalves    º Data ³  20/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Manipula valores da acolsTemp de acordo com o informado.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REPACLS()
Local _ni := 0
For _ni:=1 to Len(aLstRpl)
	If aLstRpl[_ni,1]//se tiver ticado .t.
		if lDtInic//alterar data inicial
			aColsTemp[_ni,FG_POSVAR("VAS_DATINI","aHeader")]:= aLstRpl[_ni,2] := dDtInic
		EndIF
		If lDtFim
			aColsTemp[_ni,FG_POSVAR("VAS_DATFIN","aHeader")]:= aLstRpl[_ni,3] := dDtFim
		EndIf
		If lComRet
			aColsTemp[_ni,FG_POSVAR("VAS_COMRET","aHeader")]:= aLstRpl[_ni,4] := nComRet
		EndIf
		If lPePlus
			aColsTemp[_ni,FG_POSVAR("VAS_PEPLUS","aHeader")]:= aLstRpl[_ni,5] := nPePlus
		EndIf
		If	lVlrTac
			aColsTemp[_ni,FG_POSVAR("VAS_VLRTAC","aHeader")]:= aLstRpl[_ni,6] := nVlrTac
		EndIf
		If lTacLiq
			aColsTemp[_ni,FG_POSVAR("VAS_TACLIQ","aHeader")]:= aLstRpl[_ni,7] := nTacLiq
		EndIf
		If lCusRec
			aColsTemp[_ni,FG_POSVAR("VAS_CUSREC","aHeader")]:= aLstRpl[_ni,8] := nCusRec
		EndIf
		If lPerCtb
			if aColsTemp[_ni,FG_POSVAR("VAS_PERRET","aHeader")] <= 0
				aColsTemp[_ni,FG_POSVAR("VAS_PERCTB","aHeader")]:= aLstRpl[_ni,9] := nPerCtb
			EndIF
		EndIf
		If lSubFin
			aColsTemp[_ni,FG_POSVAR("VAS_SUBFIN","aHeader")]:= aLstRpl[_ni,10] := nSubFin
		EndIf
		If lPerent
			aColsTemp[_ni,FG_POSVAR("VAS_PERENT","aHeader")]:= aLstRpl[_ni,11] := nPerent
		EndIf
		If lVlrEnt
			aColsTemp[_ni,FG_POSVAR("VAS_VLRENT","aHeader")]:= aLstRpl[_ni,12] := nVlrEnt
		EndIf
		If lTacSub
			aColsTemp[_ni,FG_POSVAR("VAS_TACSUB","aHeader")]:= aLstRpl[_ni,13] := cTacSub
		EndIf
		If lPParvi
			aColsTemp[_ni,FG_POSVAR("VAS_PPARVI","aHeader")]:= aLstRpl[_ni,14] := cPParvi
		EndIf
		If lInTerv
			aColsTemp[_ni,FG_POSVAR("VAS_INTERV","aHeader")]:= aLstRpl[_ni,15] := cInTerv
		EndIf
		If lCodAco //CODACO
			aColsTemp[_ni,FG_POSVAR("VAS_CODACO","aHeader")]:= aLstRpl[_ni,17] := cCodAco
		EndIf
	EndIF
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_TIK2  ºAutor  ³Rafael Goncalves    º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Efetua o tick de todos check box menos perent e valent     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK2()
lDtInic	:= lMarTds
lDtFim	:= lMarTds
lComRet	:= lMarTds
lPePlus	:= lMarTds
lCusRec	:= lMarTds
lVlrTac	:= lMarTds
If lPerret
	lPerCtb	:= lMarTds
EndIf
lSubFin	:= lMarTds
lTacLiq	:= lMarTds
lTacSub	:= lMarTds
lPParvi	:= lMarTds
lInTerv := lMarTds
lCodAco := lMarTds
oDtInic:SetFocus()
oDtInic:Refresh()
oDtFim:SetFocus()
oDtFim:Refresh()
oComRet:SetFocus()
oComRet:Refresh()
oPePlus:SetFocus()
oPePlus:Refresh()
oCusRec:SetFocus()
oCusRec:Refresh()
oVlrTac:SetFocus()
oVlrTac:Refresh()
oPerCtb:SetFocus()
oPerCtb:Refresh()
oSubFin:SetFocus()
oSubFin:Refresh()
oTacLiq:SetFocus()
oTacLiq:Refresh()
oTacSub:SetFocus()
oTacSub:Refresh()
oPParvi:SetFocus()
oPParvi:Refresh()
oInTerv:SetFocus()
oInTerv:Refresh()
OCodAco:SetFocus()
OCodAco:Refresh()
oDlgRp:SetFocus()
oDlgRp:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_TIK3  ºAutor  ³Rafael Goncalves    º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tik alterando entre percentual da entrada e vlr da entrada º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK3(cTipo)
If cTipo = "1"
	IF lVlrEnt
		lVlrEnt:= !lPerent
		nVlrEnt:=0
	EndIF
	oCPerent:SetFocus()
	oCPerent:Refresh()
	oCVlrEnt:SetFocus()
	oCVlrEnt:Refresh()
	oVlrEnt:SetFocus()
	oVlrEnt:Refresh()
	oPerent:SetFocus()
	oPerent:Refresh()
ElseIf cTipo = "2"
	if lPerent
		lPerent:=!lVlrEnt
		nPerent:=0
	EndIF
	oCPerent:SetFocus()
	oCPerent:Refresh()
	oCVlrEnt:SetFocus()
	oCVlrEnt:Refresh()
	oPerent:SetFocus()
	oPerent:Refresh()
	oVlrEnt:SetFocus()
	oVlrEnt:Refresh()
EndIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_TIK4  ºAutor  ³Rafael Goncalves    º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tik todos os campos da get dados                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK4()
Local _ni := 1
If len(aLstRpl)>1
	For _ni:=1 to len(aLstRpl)
		aLstRpl[_ni,1] := lLstRlp
	Next
	oLstRpl:Refresh()
EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALDT  ºAutor  ³Rafael Goncalves    º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao da data informada                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ 1 = data inicial    /    2 = Data final                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALDT(nTipo)
Local lRet := .t.
Default nTipo := "1"//1-inicial - 2-Dt Final

If nTipo="1"
	if lDtInic
		if Empty(dDtInic)
			lRet := .f.
		EndIF
	EndIf
ElseIf nTipo="2"
	if lDtFim
		if !Empty(dDtFim)
			If dDtInic>dDtFim
				lRet := .f.
			EndIf
		Else
			lRet := .f.
		EndIF
	EndIf
EndIF

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALCPO ºAutor  ³Rafael Goncalves    º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao dos campos                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALCPO()
Local lRet := .t.
If lComRet
	If nComRet < 0
		lRet := .f.
	EndIf
EndIf
If lPePlus
	If nPePlus < 0
		lRet := .f.
	EndIf
EndIf
If	lVlrTac
	If nVlrTac < 0
		lRet := .f.
	EndIf
EndIf
If lTacLiq
	If nTacLiq < 0
		lRet := .f.
	EndIf
EndIf
If lCusRec
	If nCusRec < 0
		lRet := .f.
	EndIf
EndIf
If lPerCtb
	if nPerCtb < 0
		lRet := .f.
	EndIf
EndIf
If lSubFin
	If nSubFin < 0
		lRet := .f.
	EndIf
EndIf
If lPerent
	if nPerent < 0
		lRet := .f.
	EndIf
EndIf
If lVlrEnt
	if nVlrEnt < 0
		lRet := .f.
	EndIf
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FILUTI ºAutor  ³Rafael Goncalves    º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Filiais que utilizao a tabela                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILUTI(lTela)
Local ni        := 0
Local cEmpLibs  := ""
Local lMarcar   := .f.
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local nCont     := 0
Local cBkpFilAnt:= cFilAnt
Private oOk     := LoadBitmap( GetResources(), "LBOK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Default lTela   := .t.
aVetEmp := {}
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aAdd( aVetEmp, { .f. , cFilAnt , FWFilialName() }) // utilizar sempre cFilAnt, pois o VEIXX005 tambem utiliza o cFilAnt para posicionar no VZV
Next
cFilAnt := cBkpFilAnt
//verifica se existe registro na tabela para colcoar como .t.
For ni := 1 to Len(aVetEmp)
	DbSelectArea("VZV")
	DbSetOrder(1)
	If DbSeek(xFilial("VZV")+M->VAR_CODIGO+aVetEmp[ni,2])
		aVetEmp[ni,1] := .t.
	EndIf
Next
If lTela
	If Len(aVetEmp) > 0
		DEFINE MSDIALOG oDlgFil FROM 05,01 TO 250,400 TITLE STR0041 PIXEL // Selecione as Filiais
		DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgFil:End()) ENABLE OF oDlgFil
		@ 013,001 LISTBOX oLbEmp FIELDS HEADER "",STR0011,STR0049 COLSIZES 10,50,80 SIZE 198,108 OF oDlgFil ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL // Filial / Nome
		oLbEmp:SetArray(aVetEmp)
		oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) , aVetEmp[oLbEmp:nAt,2] , aVetEmp[oLbEmp:nAt,3] }}
		@ 014, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgFil ON CLICK FS_TIK5(lMarcar)	SIZE 70,08 PIXEL COLOR CLR_BLUE
		ACTIVATE MSDIALOG oDlgFil CENTER
	EndIf
EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_TIK5  ºAutor  ³Rafael Goncalves    º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tik todas as Filiais                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK5(lMarcar)
Local ni:=0
For ni:=1 to Len(aVetEmp)
	aVetEmp[ni,1] := lMarcar
Next
oLbEmp:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRAVFILºAutor  ³Rafael Goncalves    º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inclui/Altera/Exclui as Filiais                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVFIL(nOpc)
Local ni  := 0
If VZV->(FieldPos("VZV_FILIAL")) <= 0
	Return
EndIf
If nOpc == 3 .or. nOpc == 4 // inclusao ou alteracao
	If nOpc == 3 .and. len(aVetEmp) <= 0
		aAdd( aVetEmp, { .t. , cFilAnt , FWFilialName() })
	EndIf
	For ni := 1 to Len(aVetEmp)
		DbSelectArea("VZV")
		DbSetOrder(1)
		DbSeek(xFilial("VZV")+M->VAR_CODIGO+aVetEmp[ni,2])
		If aVetEmp[ni,1]//se tiver ticado.
			reclock("VZV",!Found())
			VZV->VZV_FILIAL := xFilial("VZV")
			VZV->VZV_CODIGO := M->VAR_CODIGO
			VZV->VZV_FILULT := aVetEmp[ni,2]
			msunlock()
		ElseIf Found()
			RecLock("VZV",.F.,.T.)
			dbdelete()
			MsUnlock()
		EndIf
	Next
ElseIf nOpc=5 //exclusao                          '
	//carrega array
	FS_FILUTI(.f.)
	For ni:=1 to Len(aVetEmp)
		DbSelectArea("VZV")
		DbSetOrder(1)
		If DbSeek(xFilial("VZV")+M->VAR_CODIGO+aVetEmp[ni,2])
			RecLock("VZV",.F.,.T.)
			dbdelete()
			MsUnlock()
		EndIf
	Next
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VA240VAL ºAutor  ³Rafael Goncalves    º Data ³  08/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao SX3 grupo modelo e modelo do veiculo             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculo                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA240VAL()
Local cQuery  := ""
Local cQAlMOD := "SQLMOD"
Local lRet := .t.
If ReadVar() == "M->VAR_GRUMOD"
	If !Empty(M->VAR_MODVEI)
		cQuery := "SELECT VV2.VV2_GRUMOD FROM "+RetSqlName("VV2")+" VV2 WHERE "
		cQuery += "VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND " 
		if !Empty(M->VAR_CODMAR)
			cQuery += "VV2.VV2_CODMAR='"+ M->VAR_CODMAR+"' AND "
		Endif
		cQuery += "VV2.VV2_MODVEI='"+ M->VAR_MODVEI +"' AND VV2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlMOD , .F., .T. )
		IF !( cQAlMOD )->( Eof() )
			If !( Alltrim(( cQAlMOD )->( VV2_GRUMOD )) $ Alltrim(M->VAR_GRUMOD) )
				M->VAR_MODVEI := space(len(VAR->VAR_MODVEI))
			EndIF
		Else
			M->VAR_MODVEI := space(len(VAR->VAR_MODVEI))
		EndIF
		( cQAlMOD )->( dbCloseArea() )
	EndIf
ElseIf ReadVar() == "M->VAR_MODVEI"
	If !Empty(M->VAR_MODVEI)
		cQuery := "SELECT VV2.VV2_CODMAR , VV2.VV2_GRUMOD  , VV2.VV2_DESMOD FROM "+RetSqlName("VV2")+" VV2 WHERE "
		cQuery += "VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND " 
		if !Empty(M->VAR_CODMAR)
			cQuery += "VV2.VV2_CODMAR='"+ M->VAR_CODMAR+"' AND "
		Endif
		cQuery += "VV2.VV2_MODVEI='"+ M->VAR_MODVEI +"' AND VV2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlMOD , .F., .T. )
		If ( cQAlMOD )->( Eof() )
			lRet := .f.
		Else
			M->VAR_GRUMOD := left(( cQAlMOD )->( VV2_GRUMOD )+space(70),70)
			M->VAR_DESMOD := ( cQAlMOD )->( VV2_DESMOD )
			If VAR->(FieldPos("VAR_CODMAR")) > 0
				M->VAR_CODMAR := ( cQAlMOD )->( VV2_CODMAR )
			EndIf
		EndIF
		( cQAlMOD )->( dbCloseArea() )
	EndIf
EndIf
DbSelectArea("VAR")
Return(lRet)