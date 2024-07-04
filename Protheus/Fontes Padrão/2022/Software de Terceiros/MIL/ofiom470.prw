// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "PROTHEUS.CH"
#Include "OFIOM470.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIOM470 º Autor ³ Thiago º				 Data ³  04/11/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Manutenção nas respostas para cada inconveniente da OS .	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM470(lNoMBrowse)

Private cCadastro:= STR0001
Private aRotina  := MenuDef()
Private cAliasGetD , cLinOk , cTudOk , cFieldOk
Private aHeader := {}
Private aCols   := {}
Default lNoMBrowse := .f.

If lNoMBrowse
	dbSelectArea("VO1")
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	mBrowse( 6, 1,22,75,"VO1",,,,,,)
Endif	

Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Thiago  ³				  Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento do menu aRotina							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Private aRotina := {{ STR0002,"axPesqui"   , 0 , 1},;	// Pesquisar
{ STR0003,"OM470"   , 0 , 2},;	// Visualizar
{ STR0004,"OM470"   , 0 , 4},;	// Alterar
{ STR0005,"OM470L"   , 0 , 9}}	// Legenda
Return aRotina

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM470L  ³ Autor ³ Thiago  ³				  Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda.												      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM470L(nReg)

Local uRetorno := .t.
Local aLegenda := {{'BR_VERDE'     ,STR0006},; // Aberta
  			       {'BR_AZUL'   ,STR0007}} // Liberada

If nReg == NIL 	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	AADD( uRetorno , {'VO1->VO1_STATUS=="A"',aLegenda[1,1],aLegenda[1,2]} ) // 1 = Aberto
	AADD( uRetorno , {'VO1->VO1_STATUS=="D"',aLegenda[2,1],aLegenda[2,2]} ) // 2 = Liberada
Else
	BrwLegenda(cCadastro,STR0005,aLegenda) //Legenda
EndIf
Return uRetorno

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM470 ³ Autor ³ Thiago  ³	  			  Data ³ 04/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutenção nas respostas para cada inconveniente da OS.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM470(cAlias,nReg,nOpc)
Local ni := 0
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aCpoEnchoice := {} 
cFieldOk   := "FG_MEMVAR()"


dbSelectArea("SX3")
dbSeek("VO1")
	
While !Eof().and.(x3_arquivo=="VO1")
	If X3USO(SX3->X3_USADO).and.cNivel>=SX3->X3_NIVEL .and. (Alltrim(SX3->X3_CAMPO) $ "VO1_NUMOSV/VO1_CHASSI/VO1_PLACA/VO1_KILOME/VO1_PROVEI/VO1_LOJPRO/VO1_NOMPRO/VO1_DATABE/VO1_HORABE/VO1_FUNABE")
		AADD(aCpoEnchoice,SX3->X3_CAMPO)
	EndIf
	If SX3->X3_CONTEXT == "V"
		&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
	Else
		&("M->"+SX3->X3_CAMPO):= &("VO1->"+SX3->X3_CAMPO)
	EndIf
	SX3->(DbSkip())
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VST")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado := 0
             
aHeader := {}
While !Eof() .And. (X3_ARQUIVO == "VST")
	IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. (x3_campo $ [VST_SEQINC/VST_GRUINC/VST_CODINC/VST_DESINC/VST_INFREP])     
		if x3_campo <> "VST_DESINC"
			nUsado:=nUsado+1
			AADD(aHeader,{ Trim(X3Titulo()),;
			X3_CAMPO,;
			X3_PICTURE,;
			X3_TAMANHO,;
			X3_DECIMAL,;
			X3_VALID,;
			X3_USADO,;
			X3_TIPO,;
			X3_ARQUIVO,;
			X3_CONTEXT,;
			X3_RELACAO,;
			X3_RESERV  } )
		Else
			nUsado:=nUsado+1
			AADD(aHeader,{ Trim(X3Titulo()),;
			X3_CAMPO,;
			X3_PICTURE,;
			50,;
			X3_DECIMAL,;
			X3_VALID,;
			X3_USADO,;
			X3_TIPO,;
			X3_ARQUIVO,;
			X3_CONTEXT,;
			X3_RELACAO,;
			X3_RESERV  } )
		Endif	
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	EndIF
	dbSkip()
Enddo


aCols       := {}
dbSelectArea("VST")
dbSetOrder(1)
if VST->(dbSeek(xFilial("VST")+"2"+VO1->VO1_NUMOSV))
	nReg := 1     
	While !Eof() .And. VST->VST_TIPO == "2" .and. VST->VST_CODIGO ==VO1->VO1_NUMOSV .and. xFilial("VST")==VST->VST_FILIAL
		Aadd(aCols, Array(Len(aHeader)+1) )
		aCols[1,nUsado+1]:=.F.
		For ni:=1 to nUsado
			aCols[nReg,ni]:=CriaVar(aHeader[ni,2])
		Next
		aCols[nReg,FG_POSVAR("VST_SEQINC")] := VST->VST_SEQINC
		aCols[nReg,FG_POSVAR("VST_GRUINC")] := VST->VST_GRUINC
		aCols[nReg,FG_POSVAR("VST_CODINC")] := VST->VST_CODINC
		aCols[nReg,FG_POSVAR("VST_DESINC")] := VST->VST_DESINC
		aCols[nReg,FG_POSVAR("VST_INFREP")] := VST->VST_INFREP
		aCols[nReg,Len(aCols[1])] := .f.
		nReg += 1
		dbSelectArea("VST")
		dbSkip()
	EndDo
Endif

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 78 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 01, 20, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

if nOpc == 2
	nOpcE := 2
Else	
	nOpcE := 3
Endif
DEFINE MSDIALOG oOfm470 TITLE STR0001 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
 //
EnChoice("VO1",nReg,2,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcE,cLinOk,cTudOk,"",.T.,{"VST_INFREP"},,,,cFieldOk)

ACTIVATE MSDIALOG oOfm470 CENTER ON INIT EnchoiceBar(oOfm470, {|| IIf(FS_OK(),(oOfm470:End(),nOpca := 1),.f.) } , {|| oOfm470:End(),nOpca := 2},,)


Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_OK  ³ Autor ³ Thiago  ³				  Data ³ 21/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de gravaçao da tabela.						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Agendamento OFICINA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OK()
Local ni_ := 0                    

For ni_ := 1 to Len(aCols)
	dbSelectArea("VST")
	dbSetOrder(1)
	if dbSeek(xFilial("VST")+"2"+VO1->VO1_NUMOSV+aCols[ni_,FG_POSVAR("VST_SEQINC")])
		RecLock("VST",.f.)
		VST->VST_INFREP := aCols[ni_,FG_POSVAR("VST_INFREP")]
		MsUnlock()
	Endif	
Next           

Return(.t.)