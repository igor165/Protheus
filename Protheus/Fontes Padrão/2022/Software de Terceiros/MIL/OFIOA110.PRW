///////////////
// VERSAO 14 //
///////////////

#INCLUDE "OFIOA110.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "OFIXDEF.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOA110 ³ Autor ³  Fabio                ³ Data ³ 06/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Campanha/Pendencia tecnica                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIOA110

PRIVATE aMemos := {{"VOP_ASSMEM","VOP_ASSCAM"}}
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0006) //"Campanha/Pendencia Tecnica"

If .f.
	OFA1100076_DeletaListboxRelacionamento()
	OFA1100086_MostraLegendaStatus()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VOP")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OF110    ºAutor  ³Fabio               º Data ³  08/25/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tela                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OF110(cAlias, nReg, nOpc,cTexto)

Local aObjects := {} , aPosObj := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Local bCampo   := { |nCPO| Field(nCPO) }
Local cTitulo ,oDlg1 ,cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nCntFor := 0 , _ni := 0 , nUsado := 0
Local nPosRec := 0

Private aMemos := {{"VOP_ASSMEM","VOP_ASSCAM"}} , aCpoEnchoice  :={}
Private aTELA[0][0],aGETS[0], nLenaCols:=0
Private oGetDados
Private cNumCamp := ""

aObjects := {}
AAdd( aObjects, { 1 , 50 , .t. , .t. } )
AAdd( aObjects, { 1 , 50 , .t. , .t. } )

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VOP",.t.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VOP")
While !Eof().and.(x3_arquivo=="VOP")
   If X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VOP_NUMINT])
      AADD(aCpoEnchoice,x3_campo)
   Endif
   &("M->"+x3_campo) := CriaVar(x3_campo)
   dbSkip()
End

&("M->"+x3_campo) := CriaVar("VOP_NUMINT")

If !(Inclui)
   DbSelectArea("VOP")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

// Variável de posterior validação de existência em VO4
cNumCamp := M->VOP_NUMCAM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
   Case nOpc == 3 && Incluir
        nOpcE:=3
        nOpcG:=3
        Inclui:=.t.
        Altera:=.f.
   Case nOpc == 4 && Alterar
        nOpcE :=4
        nOpcG :=4
        Altera:= .t.
        Inclui:= .f.
   Case nOpc == 2 && Visualizar
        nOpcE:=2
        nOpcG:=2
   Otherwise      && Excluir
        nOpcE:=5
        nOpcG:=5
EndCase

If nOpc == 4
	if ! EMPTY(M->VOP_CODMAR)
		dbSelectArea("VE1")
		dbSetOrder(1)
		DbSeek(xFilial("VE1")+M->VOP_CODMAR)
	EndIf
	//Alert('posicionar na marca se estiver preenchida')
EndIf

//VVR_FILIAL+VVR_CODMAR+VVR_GRUMOD                                                                                                                                

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VOU")
aHeader:={}
While !Eof().And.(x3_arquivo=="VOU")
   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VOU_NUMINT])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      &("M->"+x3_campo) := CriaVar(x3_campo)
   Endif
   dbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VOU")
ADHeadRec("VOU",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

dbSelectArea("VOU")
dbSetOrder(1)
dbSeek(xFilial("VOU")+M->VOP_NUMINT)

If nOpc == 3 .Or. !(Found())
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VOU"
		Else	
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf	
   Next
Else
   aCols:={}
   While !Eof() .And. VOU->VOU_FILIAL == xFilial("VOU") .And. M->VOP_NUMINT == VOU_NUMINT
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VOU->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VOU"
			Else
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()
   End
   nLenaCols:=Len(aCols)
Endif

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       :=STR0006
	If cTexto<>Nil .and. ValType(cTexto) == "C"
		cTitulo := cTexto
	Endif
   cAliasEnchoice := "VOP"
   cAliasGetD     := "VOU"
   cLinOk         := "If(FS_LOA110(nOpcG),FG_OBRIGAT(),.f.)"
   cTudOk         := "OA110OK()"
   cFieldOk       := "FG_MEMVAR()"
                    
	DEFINE MSDIALOG oDlg1 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] TITLE cTitulo OF oMainWnd PIXEL
		EnChoice(cAliasEnchoice,nReg,nOpc,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
//		If nOpc == 3
//			oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],2,cLinOk,cTudOk,"",.f.,,,,,cFieldOk)
//		Else
			oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,cLinOk,cTudOk,"",If(nOpc > 2 .and. nOpc < 5,.t.,.f.),,,,,cFieldOk)
//		EndIf
		oGetDados:oBrowse:bChange := {|| FG_AALTER("VOU",nLenaCols,oGetDados)}

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| if(FS_OA110GRA(nOpc),oDlg1:End(), .f. ) },{|| oDlg1:End() }, ,)

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OA110Repl  ºAutor  ³Vinicius Gati      º Data ³  08/25/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Druplica para aproveitar cadastro                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA110Repl()
	Local aVOP  := {}
	Local aVOUs := {}
	Local aVOUF := {} // campos
	Local nIdx  := 1
	Local nIdx2 := 1
	Local cOriCod := VOP->VOP_NUMINT

	if !MsgYesNo(STR0016 /*"Tem certeza que deseja replicar o registro?"*/, STR0015 /*"Atenção"*/)
		return
	endif 
	//
	if FM_SQL(" SELECT count(*) from "+RetSqlName('VOP')+" where VOP_NUMINT = '"+cOriCod+"' AND D_E_L_E_T_ = ' ' ") <= 0
		Alert( STR0019 /*"Registro não cadastrado no Banco de dados, salve o registro primeiro."*/, STR0015 /*Atenção*/)
		return
	endif
	
	BEGIN TRANSACTION

		dbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(dbSeek("VOP"))
		aHeader:={}
		While !SX3->(Eof()).And.(SX3->X3_ARQUIVO=="VOP")
			If SX3->X3_CONTEXT != "V" .AND. SX3->X3_CAMPO != "VOP_NUMINT"
				AADD(aVOP, { SX3->X3_CAMPO, VOP->&(SX3->X3_CAMPO) } )
			Endif
			SX3->(dbSkip())
		End
	
		// Duplicando VOP
		RecLock("VOP", .T.)
		VOP->VOP_NUMINT := GetSXENum("VOP","VOP_NUMINT")
		ConfirmSX8()
		For nIdx := 1 to LEN(aVOP)
			VOP->&(aVOP[nIdx,1]) := aVOP[nIdx,2]
		Next
		VOP->(MsUnlock())
	
		// fazer para VOUS
		dbSelectArea("VOU")
		VOU->( dbSetOrder(1) )
		VOU->( dbSeek(xFilial('VOU')+cOriCod) )
		While !VOU->(Eof()) .And. VOU->VOU_NUMINT == cOriCod .AND. VOU->VOU_FILIAL == xFilial("VOU")
			SX3->(dbSeek("VOU"))         
			aVOUF := {}
			While !SX3->(Eof()).And.(SX3->X3_ARQUIVO=="VOU")
				If SX3->X3_CONTEXT != "V" .AND. SX3->X3_CAMPO != "VOU_NUMINT"
					AADD(aVOUF, { SX3->X3_CAMPO, VOU->&(SX3->X3_CAMPO) })
				Endif
				SX3->(dbSkip())
			End		
			AADD(aVOUs, aVOUF)
			VOU->(dbSkip())
		End // while

		//Duplicando VOU
		For nIdx := 1 to Len(aVOUs)
			aVOU := aVOUs[nIdx]
			
			RecLock("VOU", .T.)
			For nIdx2 := 1 to LEN(aVOU)
				VOU->&(aVOU[nIdx2,1]) := aVOU[nIdx2,2]
			Next
			VOU->VOU_NUMINT := VOP->VOP_NUMINT
			VOU->(MsUnlock())
		Next
		//
	END TRANSACTION
	//
	MSGINFO(STR0018 /*"Replicado com sucesso, código: "*/ + VOP->VOP_NUMINT)
	//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIOA110  ºAutor  ³Microsiga           º Data ³  08/25/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OA110GRA(nOpc)
Local aCadVOP := {}
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
Local aVV1    := {}
Local nOpcao  := 1
Local ni      := 0
Local lRet    := .t. 
Local i       := 0 
Local aObjects := {} , aPos := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
// inicio crm
Local cCrmVei := ""
// fim crm
Private lMsHelpAuto := .t., lMsFinalAuto := .f.
Private oVerd := LoadBitmap( GetResources() , "BR_VERDE" )	// Selecionado
Private oVerm := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Nao Selecionado

// Verificações Tp Pendencia
If M->VOP_TIPPEN == "1"
	If Empty(M->VOP_NUMCAM)
		MsgStop(STR0020, STR0007) // Impossível continuar! Favor informar o Nro Campanha para a Campanha Técnica. / Atenção

		Return .f.
	Else
		If !OFA1100116_AlteracaoNumeroCampanhaVOP()
			Return .f.
		EndIf
	EndIf
EndIf

If Empty(M->VOP_CODMAR)
	MsgStop(STR0008, STR0007) // Impossível continuar! Favor informar a Marca para a Campanha/Pendência/Assunto Técnico. / Atenção

	Return .f.
EndIf

lMsHelpAuto := .f.
For ni :=1 to Len(aCpoEnchoice)
	If X3Obrigat(aCpoEnchoice[ni]) .and. Empty(&("M->"+aCpoEnchoice[ni]))
		Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(aCpoEnchoice[ni])) + " (" + aCpoEnchoice[ni] + ")" ,4,1)

		Return .f.
	EndIf
Next
lMsHelpAuto := .t.

If Inclui

	aObjects := {}
	AAdd( aObjects, { 1 , 18 , .t. , .f. } )
	AAdd( aObjects, { 1 , 50 , .t. , .t. } )
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPos := MsObjSize (aInfo, aObjects,.F.)    

	If !Empty(M->VOP_CHAINI) .or. !Empty(M->VOP_CHAFIN)

		cQuery := "SELECT VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV2.VV2_DESMOD FROM "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 WHERE "
		cQuery += "VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND "
		If !Empty(M->VOP_CODMAR)
			cQuery += "VV1.VV1_CODMAR='"+M->VOP_CODMAR+"' AND "
		EndIf
		cQuery += "VV1.VV1_CHASSI>='"+M->VOP_CHAINI+"' AND VV1.VV1_CHASSI<='"+(M->VOP_CHAFIN)+"' AND "
		If !Empty(M->VOP_MODINI) .or. !Empty(M->VOP_MODFIN)
			cQuery += "VV1.VV1_MODVEI>='"+M->VOP_MODINI+"' AND VV1.VV1_MODVEI<='"+(M->VOP_MODFIN)+"' AND "
		EndIf
		If !Empty(M->VOP_GMDINI) .or. !Empty(M->VOP_GMDFIN)
			cQuery += "VV1.VV1_MODVEI>='"+M->VOP_GMDINI+"' AND VV1.VV1_MODVEI<='"+(M->VOP_GMDFIN)+"' AND "
		EndIf
		cQuery += "VV1.D_E_L_E_T_=' ' AND VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHASSI"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		If !( cQAlSQL )->( Eof() )
			While !( cQAlSQL )->( Eof() )
				aAdd(aVV1,{ .t. , Alltrim(( cQAlSQL )->( VV1_CHASSI )) , ( cQAlSQL )->( VV1_CODMAR )+" "+( cQAlSQL )->( VV1_MODVEI )+" "+( cQAlSQL )->( VV2_DESMOD ) })
				( cQAlSQL )->( DbSkip() )
			EndDo
			nOpcao := 0
			If len(aVV1) > 0
				DEFINE MSDIALOG oConsVeic FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0009 OF oMainWnd PIXEL                     // Faixa de Chassi - Veiculos Cadastrados
					@ aPos[1,1]+005,aPos[1,2]+005 SAY STR0010 SIZE 350,10 OF oConsVeic PIXEL COLOR CLR_BLACK                               // Selecione os Veiculos desejados...
					@ aPos[1,1]+005,aPos[1,4]-180 BITMAP oxVerd RESOURCE "BR_VERDE" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
					@ aPos[1,1]+005,aPos[1,4]-170 SAY STR0011 SIZE 50,10 OF oConsVeic PIXEL COLOR CLR_BLACK                                // selecionados 
					@ aPos[1,1]+005,aPos[1,4]-090 BITMAP oxVerm RESOURCE "BR_VERMELHO" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
					@ aPos[1,1]+005,aPos[1,4]-080 SAY STR0012 SIZE 50,10 OF oConsVeic PIXEL COLOR CLR_BLACK                                //nao selecionados
					@ aPos[2,1],aPos[2,2]+001 LISTBOX oLbVeic FIELDS HEADER "",STR0013,STR0014 COLSIZES 10,50,180 SIZE aPos[2,4]-3,aPos[2,3]-aPos[2,1] OF oConsVeic PIXEL ON DBLCLICK ( aVV1[oLbVeic:nAt,1] := !aVV1[oLbVeic:nAt,1] )  //Chassi / Veiculo
					oLbVeic:SetArray(aVV1)
					oLbVeic:bLine := { || { IIf(aVV1[oLbVeic:nAt,1],oVerd,oVerm) , aVV1[oLbVeic:nAt,2] , aVV1[oLbVeic:nAt,3] }}
				ACTIVATE MSDIALOG oConsVeic ON INIT EnchoiceBar(oConsVeic,{ || nOpcao := 1 , oConsVeic:End() }, { || oConsVeic:End() })
			EndIf
		EndIf
		( cQAlSQL )->( DbCloseArea() )
		DbSelectArea("VOP")
		If nOpcao == 0	
			Return(.f.)
		Else
			aAdd(aCadVOP,{M->VOP_CHAINI,""}) // Chassi Inicial 
			For ni := 1 to len(aVV1)
				If !(aVV1[ni,1])
					// Gravar ate chassi anterior ao nao selecionado
					aCadVOP[len(aCadVOP),2] := left(aVV1[ni,2],len(aVV1[ni,2])-6)+strzero(val(right(aVV1[ni,2],6))-1,6)
					// Gravar novo registro no Vetor
					aAdd(aCadVOP,{left(aVV1[ni,2],len(aVV1[ni,2])-6)+strzero(val(right(aVV1[ni,2],6))+1,6),M->VOP_CHAFIN})
				EndIf
			Next
			aCadVOP[len(aCadVOP),2] := M->VOP_CHAFIN // Chassi Final
		EndIf
    Else
    	aAdd(aCadVOP,{M->VOP_CHAINI,M->VOP_CHAFIN})
    EndIf
Else
   	aAdd(aCadVOP,{M->VOP_CHAINI,M->VOP_CHAFIN})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2
   
	// inicio CRM
	cCrmVei := ""
	If Substr(GetMv("MV_CRMVEI",,"NN"),1,2)=="SS"
	 	 If FG_PESQTAB("VOU_CRMOK") .and. Pergunte("CRMVEI",.T.)
	 	  	cCrmVei	:= MV_PAR01  			
	   Endif 
	Endif
	// final CRM
	
	Begin Transaction
	
		For ni := 1 to len(aCadVOP)
	
			If Inclui
				M->VOP_NUMINT := "INCLUIR" // Quando Incluir criar novo registro
			EndIf

	      DbSelectArea("VOP")
	      DbSetOrder(1)
	      DbSeek(xFilial("VOP")+M->VOP_NUMINT)
	                                  
	      && Grava arquivo pai
	      If Inclui .or. Altera
	
	         If !RecLock("VOP", !Found() )
	            Help("  ",1,"REGNLOCK")
	            lRet := .f.
	            DisarmTransaction()
	            Break               
	         EndIf
	         
	         If Inclui
	            M->VOP_NUMINT := GetSXENum("VOP","VOP_NUMINT")
	            ConfirmSX8()
	         EndIf
	         
	         M->VOP_CHAINI := aCadVOP[ni,1] // Chassi Inicial 
	         M->VOP_CHAFIN := aCadVOP[ni,2] // Chassi Final

			// Caso Pendência/Assunto Técnico
			If M->VOP_TIPPEN $ "23"
				// Limpa o campo desabilitado (já que o usuário pode alterar o X3)
				M->VOP_NUMCAM := Space(TamSX3("VOP_NUMCAM")[1])

				// Força valor do campo desabilitado (já que o usuário pode alterar o X3)
				M->VOP_OBRIGA := "0"
			EndIf

	         FG_GRAVAR("VOP")
	         cVar := aMemos[1][2]
	         MSMM(,TamSx3("VOP_ASSCAM")[1],,&cVar,1,,,"VOP","VOP_ASSMEM")
	         MsUnlock()
	                         
	      EndIf

	      && grava arquivo filho
	      For i:=1 to len(aCols)
	
			 if Empty(aCols[I,FG_POSVAR("VOU_CHASSI")])
			 	loop
			 endif
			 
	         DbSelectArea("VOU")                                        
	         DbSetOrder(1)
	         DbSeek(xFilial("VOU")+M->VOP_NUMINT+aCols[I,FG_POSVAR("VOU_CHASSI")])
	         
	         If (Inclui .or. Altera) .And. !aCols[i,len(aCols[i])]

	            if !Empty(aCols[I,FG_POSVAR("VOU_CHASSI")])
		            If !RecLock("VOU", !Found() )
		               Help("  ",1,"REGNLOCK")
		               lRet := .f.
		               DisarmTransaction()
		               Break               
		            EndIf
		            
		            FG_GRAVAR("VOU",aCols,aHeader,i)
		            VOU->VOU_FILIAL := xFilial("VOU")
		            VOU->VOU_NUMINT := M->VOP_NUMINT
		            If Inclui
		               VOU->VOU_NUMOSV := ""
		            EndIf
					VV1->(DbsetOrder(2))
	
	            	MsUnlock()
	             Endif
	         ElseIf Found() .And. nLenaCols >= i
	            
	            && Deleta
	            If !RecLock("VOU",.F.,.T.)
	               Help("  ",1,"REGNLOCK")
	               lRet := .f.
	               DisarmTransaction()
	               Break               
	            EndIf
	            
	            dbdelete()
	            MsUnlock()               
	            WriteSx2("VOU")
	
	         EndIf
	      
	      Next                  
	      
	      && Exclui arquivo pai   
	      DbSelectArea("VOP")
	      
	      If !(Inclui .or. Altera) .And. Found()
	                                   
        	 && Deleta
    	     If !RecLock("VOP",.F.,.T.)
	            Help("  ",1,"REGNLOCK")
    	        lRet := .f.
        	    DisarmTransaction()
	            Break               
    	     EndIf
	         
        	 dbdelete()
	         MsUnlock()
	         WriteSx2("VOP")
	
	      EndIf
	
		Next
		
	End Transaction

EndIf                      
            
If !lRet 
   MostraErro()
EndIf
lMsHelpAuto := .f. 


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LOA110 ºAutor  ³Fabio               º Data ³  10/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida registro duplicado                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function FS_LOA110(nOpc)

Local nValLin:=0

FG_MEMVAR()
        
If !aCols[n,Len(aCols[n])]   

	If nOpc==3 .And. !ExistChav("VOU",M->VOP_NUMINT+M->VOU_CHASSI)
	
		Return(.f.)     
	
	EndIf
	
	For nValLin:=1 to Len(aCols)
	    
		If !aCols[nValLin,Len(aCols[nValLin])] .And. aCols[nValLin,FG_POSVAR("VOU_CHASSI")] == M->VOU_CHASSI .and. nValLin#n
           
			Help("  ",1,"EXISTCHAV")
			Return(.f.)

		EndIf
	                           
	Next          

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ OA110OK    ³ Autor ³  Ednilson           ³ Data ³ 24/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao para o TudoOk                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OA110OK()

Local lRet := .t.

If M->VOP_DATCAM > M->VOP_DATVEN
   	Help(" ",1,"A110DATCAM")
   	lRet := .f.
EndIf

Return lRet

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;   //Pesquisar
                     { STR0002 ,"OF110", 0 , 2},;    //Visualizar
                     { STR0003 ,"OF110", 0 , 3},;    //Incluir
                     { STR0004 ,"OF110", 0 , 4},;    //Alterar
                     { STR0005 ,"OF110", 0 , 5},;    //Excluir
                     { STR0017 ,"OA110Repl", 0 , 5}} //Replicar
Return aRotina

/*/{Protheus.doc} OA110TIPPEN
Validação do campo VOP_TIPPEN

@author Fernando Vitor Cavani
@since 28/06/2018
@version undefined

@type function
/*/
Function OA110TIPPEN()
	If M->VOP_TIPPEN $ "23"
		// Aviso de Não Obrigatoriedade
		If M->VOP_OBRIGA == "1"
			MsgAlert(STR0021, STR0007) // Pendência/Assunto Técnico não podem ser obrigatórios. / Atenção
		EndIf

		// Limpa o campo desabilitado
		M->VOP_NUMCAM := Space(TamSX3("VOP_NUMCAM")[1])

		// Força valor do campo desabilitado
		M->VOP_OBRIGA := "0"
	EndIf
Return

/*/{Protheus.doc} OFA1100016_PesquisaCampanha
Pesquisa Existencia de Campanha/Pendencia/Assunto

@author Fernando Vitor Cavani
@since 29/06/2018
@version undefined
@param cChassi, caracter, chassi
@type function
/*/
Function OFA1100016_PesquisaCampanha(cChassi)
Local cSQLAlias := "SQLVOP"
Local cQuery    := ""

Local cCodMod   := ""
Local ni        := 1
Local lChoice   := .f.
Local nCT       := 0
Local nPT       := 0
Local nAT       := 0
Local cMsg1     := ""
Local cMsg2     := ""

Private aCamVei  := {}
Private nLinha   := 1
Private oDlgRecVOP
Private oEnchVOP
Private oLboxVOP
Private oOk := LoadBitmap(GetResources(), "LBTIK")
Private oNo := LoadBitmap(GetResources(), "LBNO")

// VV1
DbSelectArea("VV1")
DbSetOrder(2) // VV1_FILIAL + VV1_CHASSI
DbSeek(xFilial("VV1") + cChassi)

// VO5
dbSelectArea("VO5")
dbSetOrder(1) // VO5_FILIAL + VO5_CHAINT
dbSeek(xFilial("VO5") + VV1->VV1_CHAINT)

// Modelo
cCodMod := VV1->VV1_MODVEI

//VVR => Grupo de modelo
//VV2 => Modelo
dbSelectArea("VV2")
VV2->(DbSetOrder(1)) // VV2_FILIAL + VV2_CODMAR + VV2_MODVEI + VV2_SEGMOD
VV2->(DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI))

cSelect := alias()

// Verifica se tem faixa de chassi / modelo / data venda com campanha
cQuery := "SELECT * FROM "
cQuery += "  (SELECT VOU_CHASSI, VOP_DATVEN, VOP_ASSMEM, VOP_NUMINT, VOP_TIPPEN, VOP_DATCAM, VOP_NUMCAM, VOP_NOMCAM, VOP_OBRIGA, "
cQuery += "  (SELECT COUNT(*) FROM " + RetSQLName("VOU") + " VOU2 WHERE VOU_FILIAL = '" + xFilial("VOU") + "' AND VOU2.VOU_NUMINT = VOP_NUMINT AND VOU2.D_E_L_E_T_ = ' ') QTD_VOUS "
cQuery += "FROM " + RetSQLName("VOP") + " VOP "
cQuery += "LEFT JOIN " + RetSQLName("VOU") + " VOU ON VOU.VOU_FILIAL = '" + xFilial("VOU") + "' AND VOU_NUMINT = VOP_NUMINT AND VOU.D_E_L_E_T_ = ' ' AND VOU_NUMOSV = '   ' "

If VOU->(FieldPos("VOU_FILCAM")) > 0
	cQuery += "  AND (VOU_FILCAM = ' ' OR VOU_FILCAM = '" + xFilial("SF2") + "') "
EndIf

cQuery += "WHERE VOP_FILIAL = '" + xFilial("VOP") + "' "
cQuery += "  AND ( "
cQuery += "((VOP_CHAINI = ' ' AND VOP_CHAFIN = ' ') OR ('" + VV1->VV1_CHASSI + "' BETWEEN VOP_CHAINI AND VOP_CHAFIN) OR ('" + VV1->VV1_CHARED + "' BETWEEN VOP_CHAINI AND VOP_CHAFIN)) "
cQuery += "  AND "
cQuery += "((VOP_MODINI = ' ' AND VOP_MODFIN = ' ') OR ('" + cCodMod + "' BETWEEN VOP_MODINI AND VOP_MODFIN)) "
cQuery += "  AND "
cQuery += "((VOP_GMDINI = ' ' AND VOP_GMDFIN = ' ') OR ('" + VV2->VV2_GRUMOD + "' BETWEEN VOP_GMDINI AND VOP_GMDFIN))) "

If !Empty(VO5->VO5_DATVEN)
	cQuery += "  AND ((VOP_DATINI = ' ' AND VOP_DATFIN = ' ') OR ('" + dtos(VO5->VO5_DATVEN) + "' BETWEEN VOP_DATINI AND VOP_DATFIN)) "
EndIf

cQuery += "  AND (VOP_DATVEN = ' ' OR VOP_DATVEN >= '" + dtos(dDataBase) + "') AND VOP_CODMAR = '" + VV1->VV1_CODMAR + "' AND VOP.D_E_L_E_T_ = ' ' "
cQuery += ") TB "
cQuery += "WHERE (QTD_VOUS = 0 OR VOU_CHASSI IN ('" + VV1->VV1_CHARED + "','" + VV1->VV1_CHASSI + "')) "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLAlias, .F., .T.)

While !(cSQLAlias)->(Eof())
	aAdd(aCamVei, {                     ;
		(cSQLAlias)->(VOP_ASSMEM),      ;
		(cSQLAlias)->(VOP_NUMINT),      ;
		(cSQLAlias)->(VOP_TIPPEN),      ;
		stod((cSQLAlias)->(VOP_DATCAM)),;
		(cSQLAlias)->(VOP_NUMCAM),      ;
		stod((cSQLAlias)->(VOP_DATVEN)),;
		(cSQLAlias)->(VOP_NOMCAM),      ;
		(cSQLAlias)->(VOP_OBRIGA)       ;
	})

	(cSQLAlias)->(dbSkip())
EndDo

(cSQLAlias)->(dbCloseArea())

DbSelectArea("VOP")

aSort(aCamVei,,, {|x,y| x[3] + x[2] < y[3] + y[2]})

If !Empty(aCamVei)
	For ni := 1 to len(aCamVei)
		// Tipo de Campanha/Pendência/Assunto Técnico
		Do Case
			Case aCamVei[ni,3] == "1"
				nCT++
			Case aCamVei[ni,3] == "2"
				nPT++
			Case aCamVei[ni,3] == "3"
				nAT++
		EndCase
	Next

	// Pergunta
	cMsg1 += STR0022 + CHR(13) + CHR(10) + CHR(13) + CHR(10) // Veículo possui:

	If nCT > 0
		cMsg1 += STR0023 + " " + STR0025 + " - " + STR0024 + " " + Alltrim(Str(nCT)) + CHR(13) + CHR(10) // Tipo: / Campanha Técnica / Quantidade:
	EndIf

	If nPT > 0
		cMsg1 += STR0023 + " " + STR0026 + " - " + STR0024 + " " + Alltrim(Str(nPT)) + CHR(13) + CHR(10) // Tipo: / Pendência Técnica / Quantidade:
	EndIf

	If nAT > 0
		cMsg1 += STR0023 + " " + STR0027 + " - " + STR0024 + " " + Alltrim(Str(nAT)) + CHR(13) + CHR(10) // Tipo: / Assunto Técnico / Quantidade:
	EndIf

	cMsg2 := STR0028 // Deseja visualizar os dados?

	lChoice := MsgYesNo((cMsg2), (cMsg1))
	If lChoice
		OFA1100026_VisualizaCampanha()

		ACTIVATE MSDIALOG oDlgRecVOP ON INIT EnchoiceBar(oDlgRecVOP,;
			{|| oDlgRecVOP:End()},                                  ;
			{|| oDlgRecVOP:End()})
	EndIf
EndIf

If !Empty(cSelect)
	dbSelectArea(cSelect)
EndIf
Return .t.

/*/{Protheus.doc} OFA1100026_VisualizaCampanha
Tela de Consulta referentes a Campanha/Pendência/Assunto

@author Fernando Vitor Cavani
@since 11/07/2018
@version undefined

@type function
/*/
Static Function OFA1100026_VisualizaCampanha()
Local oSizePrinc
Local oIntHelper := DMS_InterfaceHelper():New()

oIntHelper:nOpc := 2

oSizePrinc := oIntHelper:CreateDefSize(.t., {;
	{"LISTBOX", 100, 100, .t., .t.},         ;
	{"DETALHE", 100, 100, .t., .t.}          ;
})
oSizePrinc:Process()

oIntHelper:SetDefSize(oSizePrinc)
oDlgRecVOP := oIntHelper:CreateDialog(STR0029) // Campanha/Pendência/Assunto Técnico

oIntHelper:SetOwnerPvt("OFA1100016_PesquisaCampanha")

// Listbox
oIntHelper:Clean()
oIntHelper:SetDefSize(oSizePrinc, "LISTBOX")

oIntHelper:AddColLBox({{"X3", "VOP_NUMCAM"}})
oIntHelper:AddColLBox({  ;
	{"CABEC"  , STR0030},; // Tp Pendência (VOP_TIPPEN)
	{"TAMANHO", 100}     ;
})
oIntHelper:AddColLBox({{"X3", "VOP_NOMCAM"}})
oIntHelper:AddColLBox({{"X3", "VOP_OBRIGA"}})

oLboxVOP := oIntHelper:CreateLBox("oLboxVOP")
oLboxVOP:bChange := {|| OFA1100046_PreencheListboxCampanha()}
oLboxVOP:SetArray(OFA1100036_PreencheMSMGetCampanha())
oLboxVOP:Refresh()

// Msmget
oIntHelper:Clean()
oIntHelper:SetDefSize(oSizePrinc, "DETALHE")
oIntHelper:AddMGet("VOP_DATCAM", {{"X3_VISUAL", "V"}})
oIntHelper:AddMGet("VOP_NUMINT", {{"X3_VISUAL", "V"}})
oIntHelper:AddMGet("VOP_DATVEN", {{"X3_VISUAL", "V"}})
oIntHelper:AddMGet("VOP_NUMCAM", {{"X3_VISUAL", "V"}})
oIntHelper:AddMGet("VOP_ASSCAM", {{"X3_VISUAL", "V"}})
oIntHelper:AddMGet("VOP_OBRIGA", {{"X3_VISUAL", "V"}})

oEnchVOP := oIntHelper:CreateMSMGet(.f.)
Return

/*/{Protheus.doc} OFA1100036_PreencheMSMGetCampanha
Preencher as informações do Listbox Campanha/Pendência/Assunto

@author Fernando Vitor Cavani
@since 11/07/2018
@version undefined

@type function
/*/
Static Function OFA1100036_PreencheMSMGetCampanha()
Local aRetorno := {}
Local ni       := 0

If !Empty(aCamVei)
	For ni := 1 to Len(aCamVei)
		AADD(aRetorno, {                                ;
			aCamVei[ni,5],                              ; // VOP_NUMCAM // 01
			UPPER(X3COMBO("VOP_TIPPEN", aCamVei[ni,3])),; // VOP_TIPPEN // 02
			aCamVei[ni,7],                              ; // VOP_NOMCAM // 03
			UPPER(X3COMBO("VOP_OBRIGA", aCamVei[ni,8])) ; // VOP_OBRIGA // 04
		})
	Next
EndIf

If Len(aRetorno) == 0
	AADD(aRetorno, {;
		"",         ; // VOP_NUMCAM // 01
		"",         ; // VOP_TIPPEN // 02
		"",         ; // VOP_NOMCAM // 03
		""          ; // VOP_OBRIGA // 04
	})
EndIf
Return aRetorno

/*/{Protheus.doc} OFA1100046_PreencheListboxCampanha
Atualizar as informações referentes a Campanha/Pendência/Assunto selecionado

@author Fernando Vitor Cavani
@since 11/07/2018
@version undefined

@type function
/*/
Static Function OFA1100046_PreencheListboxCampanha()
Local cAssMem := ""

If oLboxVOP:nAt > 0
	nLinha := oLboxVOP:nAt
Else
	nLinha := 1
EndIf

cAssMem := MSMM(aCamVei[nLinha,1], TamSx3("VOP_ASSCAM")[1])
cAssMem := aCamVei[nLinha,7] + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cAssMem

M->VOP_DATCAM := aCamVei[nLinha,4]
M->VOP_NUMINT := aCamVei[nLinha,2]
M->VOP_DATVEN := aCamVei[nLinha,6]
M->VOP_NUMCAM := aCamVei[nLinha,5]
M->VOP_ASSCAM := cAssMem
M->VOP_OBRIGA := aCamVei[nLinha,8]

oEnchVOP:Refresh()
Return .t.

/*/{Protheus.doc} OFA1100056_RelacionaCampanha
Relacionar Serviço com Campanha/Pendência/Assunto (VOU)

@author Fernando Vitor Cavani
@since 12/07/2018
@version undefined
@return lValApl, logico  , validação da liberação de OS
@param  cAlias , caracter, alias
@param  nReg   , numerico, código do registro
@param  nOpc   , numerico, opção do menu
@param  lLiber , logico  , liberação de OS
@type function
/*/
Function OFA1100056_RelacionaCampanha(cAlias, nReg, nOpc, lLiber)
Local oSizePrinc
Local oIntHelper  := DMS_InterfaceHelper():New()
Local nPosVO2Soft := 0
Local cCodMod     := ""
Local cSQLAlias   := "SQLVOP"
Local cQuery      := ""
Local nPos        := 0
Local aPesqSrvc   := {}
Local lValApl     := .t.

Private oDlgRecVOU
Private oLboxVO4
Private oLboxVOP
Private oLboxVOU
Private oOk        := LoadBitmap(GetResources(), "LBTIK")
Private oNo        := LoadBitmap(GetResources(), "LBNO")
Private oBranco    := LoadBitmap(GetResources(), "BR_BRANCO")
Private oAmarelo   := LoadBitmap(GetResources(), "BR_AMARELO")
Private oVerde     := LoadBitmap(GetResources(), "BR_VERDE")
Private aServicos  := {}
Private aCampanhas := {}
Private aRelacaoSC := {}
Private aRelDelSC  := {}

Default lLiber := .f.

If VOU->(FieldPos("VOU_SERINT")) > 0
	// Verificação de OS Aberta (VO1)
	If VO1->VO1_STATUS # "A"
		Help("  ", 1, "OSNABERTA")
		DbSelectArea("VO1")
		DbSetOrder(1) // VO1_FILIAL + VO1_NUMOSV

		Return .f.
	EndIf

	// Serviços
	aPesqSrvc := FMX_CALSER(VO1->VO1_NUMOSV,,,, .t., .f., .t., .f., .f., .f.,,)
	For nPos := 1 to Len(aPesqSrvc)
		Aadd(aServicos, {                   ;
			.f.,                            ; //                                   // 01
			oBranco,                        ; //                                   // 02
			aPesqSrvc[nPos, SRVC_TIPTEM],   ; // VO4_TIPTEM                        // 03
			aPesqSrvc[nPos, SRVC_GRUSER],   ; // VO4_GRUSER                        // 04
			aPesqSrvc[nPos, SRVC_CODSER],   ; // VO4_CODSER                        // 05
			aPesqSrvc[nPos, SRVC_DESCRICAO],; // Posicione("VO6", 2, xFilial("VO6") + FG_MARSRV(Posicione("VV1", 1, xFilial("VV1") + VO1->VO1_CHAINT, "VV1_CODMAR"), VO4->VO4_CODSER) + VO4->VO4_CODSER, "VO6_DESSER") // 06
			aPesqSrvc[nPos, SRVC_SERINT]    ; // VO4_SERINT (Apenas para Gravação) // 07
		})
	Next nPos

	If Len(aServicos) == 0
		If !(lLiber)
			Help(" ", 1, "ITENSOSV")
		EndIf

		Return .t.
	EndIf

	// VO4_TIPTEM + VO4_CODSER
	Asort(aServicos, 1,, {|x,y| x[3] + x[6] < y[3] + y[6]})

	// VV1
	DbSelectArea("VV1")
	DbSetOrder(1) // VV1_FILIAL + VV1_CHAINT
	DbSeek(xFilial("VV1") + VO1->VO1_CHAINT)

	// VO5
	dbSelectArea("VO5")
	dbSetOrder(1) // VO5_FILIAL + VO5_CHAINT
	dbSeek(xFilial("VO5") + VV1->VV1_CHAINT)

	// Modelo
	cCodMod := VV1->VV1_MODVEI

	//VVR => Grupo de modelo
	//VV2 => Modelo
	dbSelectArea("VV2")
	VV2->(DbSetOrder(1)) // VV2_FILIAL + VV2_CODMAR + VV2_MODVEI + VV2_SEGMOD
	VV2->(DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI))

	cSelect := Alias()

	// Campanhas
	cQuery := "SELECT VOU_CHASSI, VOP_DATVEN, VOP_NUMINT, VOP_TIPPEN, VOP_DATCAM, VOP_NUMCAM, VOP_NOMCAM, VOP_OBRIGA, VOU_SERINT "
	cQuery += "FROM " + RetSQLName("VOP") + " VOP "
	cQuery += "LEFT JOIN " + RetSQLName("VOU") + " VOU ON VOU.VOU_FILIAL = '" + xFilial("VOU") + "' AND VOU_NUMINT = VOP_NUMINT AND VOU.D_E_L_E_T_ = ' ' "
	cQuery += "  AND VOU_NUMOSV = '" + VO1->VO1_NUMOSV + "' "

	If VOU->(FieldPos("VOU_FILCAM")) > 0
		cQuery += "  AND (VOU_FILCAM = ' ' OR VOU_FILCAM = '" + xFilial("SF2") + "') "
	EndIf

	cQuery += "WHERE VOP_FILIAL = '" + xFilial("VOP") + "' "
	cQuery += "  AND ( "
	cQuery += "((VOP_CHAINI = ' ' AND VOP_CHAFIN = ' ') OR ('" + VV1->VV1_CHASSI + "' BETWEEN VOP_CHAINI AND VOP_CHAFIN) OR ('" + VV1->VV1_CHARED + "' BETWEEN VOP_CHAINI AND VOP_CHAFIN)) "
	cQuery += "  AND "
	cQuery += "((VOP_MODINI = ' ' AND VOP_MODFIN = ' ') OR ('" + cCodMod + "' BETWEEN VOP_MODINI AND VOP_MODFIN)) "
	cQuery += "  AND "
	cQuery += "((VOP_GMDINI = ' ' AND VOP_GMDFIN = ' ') OR ('" + VV2->VV2_GRUMOD + "' BETWEEN VOP_GMDINI AND VOP_GMDFIN))) "

	If !Empty(VO5->VO5_DATVEN)
		cQuery += "  AND ((VOP_DATINI = ' ' AND VOP_DATFIN = ' ') OR ('" + dtos(VO5->VO5_DATVEN) + "' BETWEEN VOP_DATINI AND VOP_DATFIN)) "
	EndIf

	cQuery += "  AND VOP_CODMAR = '" + VV1->VV1_CODMAR + "' AND VOP.D_E_L_E_T_ = ' ' "
	cQuery += "  AND ( "
	cQuery += "(VOP_DATVEN = ' ' OR VOP_DATVEN >= '" + dtos(dDataBase) + "') OR (VOP_DATVEN < '" + dtos(dDataBase) + "' AND VOU_SERINT IS NOT NULL)) "   // Trazer também as Campanhas vencidas mas já relacionadas VOU
	cQuery += "  AND ( "
	cQuery += "(VOU_DATEXE IS NULL OR VOU_DATEXE = ' ') OR (VOU_CHASSI IN ('" + VV1->VV1_CHARED + "','" + VV1->VV1_CHASSI + "') AND VOU_DATEXE = ' ')) " // Complementando o filtro acima, trazer somente o que não foi Liberado
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLAlias, .F., .T.)

	While !(cSQLAlias)->(Eof())
		aAdd(aCampanhas, {                                                                   ;
			.f.,                                                                             ; // 01
			oBranco,                                                                         ; // 02
			(cSQLAlias)->(VOP_NUMCAM),                                                       ; // 03
			(cSQLAlias)->(VOP_NOMCAM),                                                       ; // 04
			UPPER(X3COMBO("VOP_TIPPEN", (cSQLAlias)->(VOP_TIPPEN))),                         ; // 05
			UPPER(X3COMBO("VOP_OBRIGA", (cSQLAlias)->(VOP_OBRIGA))),                         ; // 06
			stod((cSQLAlias)->(VOP_DATCAM)),                                                 ; // 07
			stod((cSQLAlias)->(VOP_DATVEN)),                                                 ; // 08
			(cSQLAlias)->(VOP_NUMINT),                                                       ; // 09
			(cSQLAlias)->(VOP_TIPPEN),                                                       ; // 10 (Apenas para Verificação)
			(cSQLAlias)->(VOP_OBRIGA),                                                       ; // 11 (Apenas para Verificação)
			(cSQLAlias)->(VOU_SERINT),                                                       ; // 12 (Apenas para Verificação)
			Iif(Empty((cSQLAlias)->(VOU_CHASSI)), VV1->VV1_CHASSI, (cSQLAlias)->(VOU_CHASSI)); // 13 (Apenas para Gravação)
		})

		// Verificações
		If lValApl
			If (cSQLAlias)->(VOP_TIPPEN) == "1" .And. (cSQLAlias)->(VOP_OBRIGA) == "1" .And. Empty((cSQLAlias)->(VOU_SERINT))
				// Campanha Técnica obrigatória mas não Relacionada com Serviço
				lValApl := .f.
			ElseIf !Empty((cSQLAlias)->(VOU_SERINT))
				// Serviço e Campanha Relacionados mas não Liberados
				lValApl := .f.
			EndIf
		EndIf

		(cSQLAlias)->(dbSkip())
	EndDo

	(cSQLAlias)->(dbCloseArea())

	If Len(aCampanhas) == 0
		If !(lLiber)
			Help(" ", 1, "A110CAMOSV")
		EndIf

		Return .t.
	EndIf

	// VOP
	DbSelectArea("VOP")

	// VOP_TIPPEN + VOP_NUMINT
	aSort(aCampanhas,,, {|x,y| x[9] + x[3] < y[9] + y[3]})

	// Montagem da Tela
	oSizePrinc := oIntHelper:CreateDefSize(.t., {;
		{"TOP"   , 100, 040, .t., .t.},          ;
		{"BOTTOM", 100, 060, .t., .t.}           ;
	})
	oSizePrinc:Process()

	oIntHelper:SetDefSize(oSizePrinc)
	oDlgRecVOU := oIntHelper:CreateDialog(STR0029 + " - " + Alltrim(RetTitle("VO1_NUMOSV")) + ": " + VO1->VO1_NUMOSV) // Campanha/Pendência/Assunto Técnico / Nro OS

	oIntHelper:SetOwnerPvt("OFA1100056_RelacionaCampanha")

	// TOP será dividido conforme
	oSizeTOP := oIntHelper:CreateDefSize(.f., {;
		{"LEFT_TOP"  , 040, 100, .t., .t.},    ;
		{"MIDDLE_TOP", 050, 100, .t., .t.},    ;
		{"RIGHT_TOP" , 010, 050, .t., .f.}     ;
	}, oSizePrinc:GetNextCallArea("TOP"))
	oSizeTOP:lLateral := .t. // Calcula em colunas
	oSizeTOP:Process()

	// BOTTOM será dividido conforme
	oSizeBOTTOM := oIntHelper:CreateDefSize(.f., {;
		{"LEFT_BOTTOM" , 090, 100, .t., .t.},     ;
		{"RIGHT_BOTTOM", 010, 030, .t., .f.}      ;
	}, oSizePrinc:GetNextCallArea("BOTTOM"))
	oSizeBOTTOM:lLateral := .t. // Calcula em colunas
	oSizeBOTTOM:Process()

	// Dados da Tela
	// Listbox (LEFT TOP)
	oIntHelper:Clean()
	oIntHelper:nOpc := 2
	oIntHelper:cAlias := "VO4"
	oIntHelper:SetDefSize(oSizeTOP, "LEFT_TOP")

	oIntHelper:AddColLBox({{"SELECAO", .t.}, {"SELECAO_UNICO", .t.}})
	oIntHelper:AddColLBox({{"IMAGEM", .t.}})
	oIntHelper:AddColLBox({{"X3", "VO4_TIPTEM"}})
	oIntHelper:AddColLBox({{"X3", "VO4_GRUSER"}})
	oIntHelper:AddColLBox({{"X3", "VO4_CODSER"}})
	oIntHelper:AddColLBox({  ;
		{"CABEC"  , STR0031},; // Descrição (VO6_DESSER)
		{"TAMANHO", 80}      ;
	})

	oLboxVO4 := oIntHelper:CreateLBox("oLboxVO4")
	oLboxVO4:SetArray(aServicos)
	oLboxVO4:Refresh()

	// Listbox (MIDDLE TOP)
	oIntHelper:Clean()
	oIntHelper:nOpc := 2
	oIntHelper:cAlias := "VOP"
	oIntHelper:SetDefSize(oSizeTOP, "MIDDLE_TOP")

	oIntHelper:AddColLBox({{"SELECAO", .t.}})
	oIntHelper:AddColLBox({{"IMAGEM", .t.}})
	oIntHelper:AddColLBox({{"X3", "VOP_NUMCAM"}})
	oIntHelper:AddColLBox({{"X3", "VOP_NOMCAM"}})
	oIntHelper:AddColLBox({  ;
		{"CABEC"  , STR0030},; // Tp Pendência (VOP_TIPPEN)
		{"TAMANHO", 60}      ;
	})
	oIntHelper:AddColLBox({{"X3", "VOP_OBRIGA"}})
	oIntHelper:AddColLBox({{"X3", "VOP_DATCAM"}})
	oIntHelper:AddColLBox({{"X3", "VOP_DATVEN"}})
	oIntHelper:AddColLBox({{"X3", "VOP_NUMINT"}})

	oLboxVOP := oIntHelper:CreateLBox("oLboxVOP")
	oLboxVOP:SetArray(aCampanhas)
	oLboxVOP:Refresh()

	// Botão (RIGHT TOP)
	oIntHelper:Clean()
	oIntHelper:nOpc := 2
	oIntHelper:cAlias := "VOU"
	oIntHelper:SetDefSize(oSizeTOP, "RIGHT_TOP")

	oIntHelper:AddButton({                                          ;
		{"NOMEOBJ", "oBtnVOURelacao"},                              ;
		{"CAPTION", STR0032},                                       ; // Relacionar
		{"COMANDO", "OFA1100066_PreencheListboxRelacionamento(.f.)"};
	})
	oIntHelper:AddButton({{"NOMEOBJ","ESPACO"}})
	oIntHelper:AddButton({                             ;
		{"NOMEOBJ", "oBtnVOULegenda"},                 ;
		{"CAPTION", STR0033},                          ; // Legenda
		{"COMANDO", "OFA1100086_MostraLegendaStatus()"};
	})
	oIntHelper:CreateGrpButton()

	// Listbox (LEFT BOTTOM)
	oIntHelper:Clean()
	oIntHelper:nOpc := 2
	oIntHelper:cAlias := "VOU"
	oIntHelper:SetDefSize(oSizeBOTTOM, "LEFT_BOTTOM")

	oIntHelper:AddColLBox({{"SELECAO", .t.}})
	oIntHelper:AddColLBox({{"X3", "VO4_TIPTEM"}})
	oIntHelper:AddColLBox({{"X3", "VO4_GRUSER"}})
	oIntHelper:AddColLBox({{"X3", "VO4_CODSER"}})
	oIntHelper:AddColLBox({  ;
		{"CABEC"  , STR0031},; // Descrição (VO6_DESSER)
		{"TAMANHO", 80}      ;
	})
	oIntHelper:AddColLBox({{"X3", "VOP_NUMCAM"}})
	oIntHelper:AddColLBox({{"X3", "VOP_NOMCAM"}})
	oIntHelper:AddColLBox({  ;
		{"CABEC"  , STR0030},; // Tp Pendência (VOP_TIPPEN)
		{"TAMANHO", 60}      ;
	})
	oIntHelper:AddColLBox({{"X3", "VOP_OBRIGA"}})
	oIntHelper:AddColLBox({{"X3", "VOP_DATCAM"}})
	oIntHelper:AddColLBox({{"X3", "VOP_DATVEN"}})
	oIntHelper:AddColLBox({{"X3", "VOP_NUMINT"}})

	oLboxVOU := oIntHelper:CreateLBox("oLboxVOU")
	oLboxVOU:SetArray(aRelacaoSC)
	oLboxVOU:Refresh()

	// Botão (RIGHT BOTTOM)
	oIntHelper:Clean()
	oIntHelper:nOpc := 2
	oIntHelper:cAlias := "VOU"
	oIntHelper:SetDefSize(oSizeBOTTOM, "RIGHT_BOTTOM")

	oIntHelper:AddButton({                                     ;
		{"NOMEOBJ", "oBtnVOUDeletarRelacao"},                  ;
		{"CAPTION", STR0034},                                  ;
		{"COMANDO", "OFA1100076_DeletaListboxRelacionamento()"};
	})
	oIntHelper:CreateGrpButton()

	OFA1100066_PreencheListboxRelacionamento(.t.)

	ACTIVATE MSDIALOG oDlgRecVOU ON INIT EnchoiceBar(oDlgRecVOU,                                       ;
		{|| IIf(OFA1100096_TUDOOK_RelacionamentoVOU(lLiber), (lValApl := .t., oDlgRecVOU:End()), NIL)},;
		{|| oDlgRecVOU:End()})

	// VO2
	If nPosVO2Soft <> 0
		VO2->(dbGoTo(nPosVO2Soft))
		VO2->(MSUnlock())
	EndIf
Else
	MsgStop(STR0043, STR0007) // Essa opção só está disponível após a atualização do dicionário de dados de acordo com a última versão disponível. / Atenção

	Return .f.
EndIf
Return lValApl

/*/{Protheus.doc} OFA1100066_PreencheListboxRelacionamento
Preencher as informações do Listbox de Relacionamento
	entre Serviços e Campanhas conforme gravação na tabela VOU
	ou selecionando os Listbox's de Serviços e Campanhas]

@author Fernando Vitor Cavani
@since 16/07/2018
@version undefined
@param lDadosVOU, logico, dados tabela VOU ou não
@type function
/*/
Static Function OFA1100066_PreencheListboxRelacionamento(lDadosVOU)
Local ni        := 0
Local nj        := 0
Local nPos      := 0
Local lServico  := .f.
Local lCampanha := .f.
Local lRelacao  := .f.
Local cTipTem   := ""
Local cGruSer   := ""
Local cCodSer   := ""
Local cDesser   := ""

Default lDadosVOU := .f.

If lDadosVOU
	// Campanhas
	For ni := 1 to Len(aCampanhas)
		// Serviço já relacionado (VOU_SERINT)
		If !Empty(aCampanhas[ni,12])
			// Retornando os dados de Serviços
			nPos := aScan(aServicos, {|x| x[7] == aCampanhas[ni,12]})
			If nPos > 0
				cTipTem := aServicos[nPos,3]
				cGruSer := aServicos[nPos,4]
				cCodSer := aServicos[nPos,5]
				cDesser := aServicos[nPos,6]

				// Alterando Status de Serviços
				aServicos[nPos,2] := oVerde
			EndIf

			// Alterando Status de Campanhas
			aCampanhas[ni,2] := oVerde

			// Adicionando no array de Relacionamento
			aAdd(aRelacaoSC, {   ;
				.f.,             ; //                                               // 01
				cTipTem,         ; // VO4_TIPTEM                                    // 02
				cGruSer,         ; // VO4_GRUSER                                    // 03
				cCodSer,         ; // VO4_CODSER                                    // 04
				cDesser,         ; // Descricao (VO6_DESSER)                        // 05
				aCampanhas[ni,3],; // VOP_NUMCAM                                    // 06
				aCampanhas[ni,4],; // VOP_NOMCAM                                    // 07
				aCampanhas[ni,5],; // Tp Pendencia (VOP_TIPPEN)                     // 08
				aCampanhas[ni,6],; // Obrigatório (VOP_OBRIGA)                      // 09
				aCampanhas[ni,7],; // VOP_DATCAM                                    // 10
				aCampanhas[ni,8],; // VOP_DATVEN                                    // 11
				aCampanhas[ni,9],; // VOP_NUMINT                                    // 12
				aCampanhas[ni,12]; // VOU_SERINT (Apenas para Gravação)             // 13
			})

			// Adicionando no array auxiliar de Relacionamento para Deletar a diferença (caso exista na Gravação)
			aAdd(aRelDelSC, {    ;
				.f.,             ; //                                               // 01
				cTipTem,         ; // VO4_TIPTEM                                    // 02
				cGruSer,         ; // VO4_GRUSER                                    // 03
				cCodSer,         ; // VO4_CODSER                                    // 04
				cDesser,         ; // Descricao (VO6_DESSER)                        // 05
				aCampanhas[ni,3],; // VOP_NUMCAM                                    // 06
				aCampanhas[ni,4],; // VOP_NOMCAM                                    // 07
				aCampanhas[ni,5],; // Tp Pendencia (VOP_TIPPEN)                     // 08
				aCampanhas[ni,6],; // Obrigatório (VOP_OBRIGA)                      // 09
				aCampanhas[ni,7],; // VOP_DATCAM                                    // 10
				aCampanhas[ni,8],; // VOP_DATVEN                                    // 11
				aCampanhas[ni,9],; // VOP_NUMINT                                    // 12
				aCampanhas[ni,12]; // VOU_SERINT (Apenas para Gravação)             // 13
			})
		EndIf
	Next
Else
	// Serviços
	For ni := 1 to Len(aServicos)
		// Serviço selecionado
		If aServicos[ni,1]
			lServico := .t.

			// Campanhas
			For nj := 1 to Len(aCampanhas)
				// Campanha selecionada
				If aCampanhas[nj,1]
					lCampanha := .t.

					// Campanha não Relacionada
					If aCampanhas[nj,2]["CNAME"] == "BR_BRANCO"
						lRelacao := .t.

						// Adicionando no array de Relacionamento
						aAdd(aRelacaoSC, {   ;
							.f.,             ; //                                               // 01
							aServicos[ni,3], ; // VO4_TIPTEM                                    // 02
							aServicos[ni,4], ; // VO4_GRUSER                                    // 03
							aServicos[ni,5], ; // VO4_CODSER                                    // 04
							aServicos[ni,6], ; // Descricao (VO6_DESSER)                        // 05
							aCampanhas[nj,3],; // VOP_NUMCAM                                    // 06
							aCampanhas[nj,4],; // VOP_NOMCAM                                    // 07
							aCampanhas[nj,5],; // Tp Pendencia (VOP_TIPPEN)                     // 08
							aCampanhas[nj,6],; // Obrigatório (VOP_OBRIGA)                      // 09
							aCampanhas[nj,7],; // VOP_DATCAM                                    // 10
							aCampanhas[nj,8],; // VOP_DATVEN                                    // 11
							aCampanhas[nj,9],; // VOP_NUMINT                                    // 12
							aServicos[ni,7]  ; // VO4_SERINT (Apenas para Gravação)             // 13
						})

						// Alterando Status de Campanhas
						aCampanhas[nj,2] := oAmarelo
					EndIf
					aCampanhas[nj,1] := .f.
				EndIf
			Next

			If lRelacao
				// Alterando Status de Serviços
				aServicos[ni,2] := oAmarelo
			EndIf
			aServicos[ni,1] := .f.

			Exit
		EndIf
	Next
EndIf

// Serviços
oLboxVO4:Refresh()

// Campanhas
oLboxVOP:Refresh()

If lDadosVOU
	// Relacionamento
	oLboxVOU:SetArray(aRelacaoSC)
	oLboxVOU:nAt := 1
	oLboxVOU:Refresh()
Else
	If !(lServico) .Or. !(lCampanha)
		// Verificando se houve alteração após percorrer o array de Serviços
		MsgAlert(STR0035, STR0007) // Favor selecionar ao menos um Serviço e uma Campanha/Pendência/Assunto Técnico. / Atenção

		Return .f.
	ElseIf !(lRelacao)
		// Verificando se houve alteração após percorrer o array de Serviços e Campanhas
		MsgAlert(STR0036, STR0007) // Serviço e Campanha/Pendência/Assunto Técnico selecionados já estão Relacionados. / Atenção

		Return .f.
	Else
		// Relacionamento
		oLboxVOU:SetArray(aRelacaoSC)
		oLboxVOU:Refresh()
	EndIf
EndIf
Return .t.

/*/{Protheus.doc} OFA1100076_DeletaListboxRelacionamento
Deletar as informações do Listbox de Relacionamento
	entre Serviços e Campanhas conforme linha selecionada

@author Fernando Vitor Cavani
@since 19/07/2018
@version undefined

@type function
/*/
Static Function OFA1100076_DeletaListboxRelacionamento()
Local ni       := 1
Local nPos     := 0
Local lRelacao := .f.
Local cSerInt  := ""
Local cNumInt  := ""

// Relacionamento
While ni <= Len(aRelacaoSC)
	// Relacionamento selecionado
	If aRelacaoSC[ni,1]
		lRelacao := .t.

		// Serviço e Campanha
		cSerInt := aRelacaoSC[ni,13]
		cNumInt := aRelacaoSC[ni,12]

		// Deletando o Relacionamento
		aDel(aRelacaoSC, ni)
		aSize(aRelacaoSC, Len(aRelacaoSC) - 1)

		// Alterando Status de Campanhas
		nPos := aScan(aCampanhas, {|x| x[9] == cNumInt}) // VOP_NUMINT
		If nPos > 0
			aCampanhas[nPos,2] := oBranco
		EndIf

		// Verificando se o Serviço está no array de Relacionamento
		nPos := aScan(aRelacaoSC, {|x| x[13] == cSerInt}) // VO4_SERINT / VOU_SERINT
		If nPos == 0
			// Alterando Status de Serviços
			nPos := aScan(aServicos, {|x| x[7] == cSerInt}) // VO4_SERINT / VOU_SERINT
			If nPos > 0
				aServicos[nPos,2] := oBranco
			EndIf
		EndIf

		// Organizando o array de Relacionamento
		If Len(aRelacaoSC) < 0
			aRelacaoSC := {}

			Exit
		EndIf

		ni--
	EndIf

	ni++
EndDo

// Verificando se houve alteração após percorrer o array de Relacionamento
If !(lRelacao)
	MsgAlert(STR0037, STR0007) // Favor selecionar ao menos um Relacionamento. / Atenção

	Return .f.
Else
	// Serviços
	oLboxVO4:Refresh()

	// Campanhas
	oLboxVOP:Refresh()

	// Relacionamento
	oLboxVOU:SetArray(aRelacaoSC)
	oLboxVOU:nAt := 1
	oLboxVOU:Refresh()
EndIf
Return .t.

/*/{Protheus.doc} OFA1100086_MostraLegendaStatus
Legenda dos Status de Serviços e Campanhas

@author Fernando Vitor Cavani
@since 20/07/2018
@version undefined

@type function
/*/
Static Function OFA1100086_MostraLegendaStatus()
Local aLegenda := {}

aAdd(aLegenda, {"BR_BRANCO" , STR0038 }) // Não Relacionado
aAdd(aLegenda, {"BR_AMARELO", STR0039 }) // Selecionado para Relação
aAdd(aLegenda, {"BR_VERDE"  , STR0040 }) // Relacionado

BrwLegenda(STR0041, STR0033, aLegenda) // Relacionar Campanha - LEGENDA / Legenda
Return

/*/{Protheus.doc} OFA1100096_TUDOOK_RelacionamentoVOU
Gravação do Relacionamento entre Serviços e Campanhas na tabela VOU

@author Fernando Vitor Cavani
@since 20/07/2018
@version undefined
@param lLiber, logico, liberação de OS
@type function
/*/
Static Function OFA1100096_TUDOOK_RelacionamentoVOU(lLiber)
Local ni       := 0
Local nPos     := 0
Local lObrigat := .f.
Local cSQL     := ""
Local cRecNo   := ""

Default lLiber := .f.

Begin Transaction

// Verificando Campanha Técnica obrigatória mas não relacionada com Serviço
If lLiber
	For ni := 1 to Len(aCampanhas)
		If aCampanhas[ni,10] == "1" .And. aCampanhas[ni,11] == "1" .And. aCampanhas[ni,2]["CNAME"] == "BR_BRANCO"
			lObrigat := .t.

			Exit
		EndIf
	Next
EndIf

If lObrigat
	MsgStop(STR0042, STR0007) // Impossível continuar! Favor selecionar a Campanha Técnica informada como obrigatória. / Atenção
	DisarmTransaction()

	Return .f.
Else
	If !(Empty(aRelacaoSC))
		// Relacionamento (Gravação)
		For ni := 1 to Len(aRelacaoSC)
			// Verificando se o Relacionamento também existe no array auxiliar (caso tenha uma Gravação anterior)
			nPos := aScan(aRelDelSC, {|x| x[12] == aRelacaoSC[ni,12]}) // VOP_NUMINT
			If nPos > 0
				// Deletando o Serviço e Campanha já selecionados
				aDel(aRelDelSC, nPos)
				aSize(aRelDelSC, Len(aRelDelSC) - 1)

				// Organizando o array de Relacionamento auxiliar
				If Len(aRelDelSC) < 0
					aRelDelSC := {}
				EndIf
			EndIf

			// RECVOU
			cSQL := "SELECT VOU.R_E_C_N_O_ RECVOU "
			cSQL += "FROM " + RetSQLName("VOU") + " VOU "
			cSQL += "WHERE VOU_FILIAL = '" + xFilial("VOU") + "' "
			cSQL += "  AND VOU_CHASSI = '" + VV1->VV1_CHASSI + "' AND VOU_NUMOSV = '" + VO1->VO1_NUMOSV + "' "
			cSQL += "  AND VOU_NUMINT = '" + aRelacaoSC[ni,12] + "' AND VOU.D_E_L_E_T_ = ' ' "
			cRecNo := FM_SQL(cSQL)

			If !Empty(cRecNo)
				VOU->(dbGoTo(cRecNo))

				RecLock("VOU", .F.)
			Else
				RecLock("VOU", .T.)
			EndIf

			VOU->VOU_FILIAL := xFilial("VOU")
			VOU->VOU_NUMINT := aRelacaoSC[ni,12]
			VOU->VOU_CHASSI := VV1->VV1_CHASSI
			VOU->VOU_NUMOSV := VO1->VO1_NUMOSV
			VOU->VOU_KILVEI := VO1->VO1_KILOME

			If VOU->(FieldPos("VOU_FILCAM")) <> 0
				VOU->VOU_FILCAM := xFilial("SF2")
			EndIf

			If VOU->(FieldPos("VOU_FILOSV")) <> 0
				VOU->VOU_FILOSV := xFilial("VO1")
			EndIf

			If VOU->(FieldPos("VOU_TIPTEM")) <> 0
				VOU->VOU_TIPTEM := aRelacaoSC[ni,2]
			EndIf

			If VOU->(FieldPos("VOU_GRUSER")) <> 0
				VOU->VOU_GRUSER := aRelacaoSC[ni,3]
			EndIf

			If VOU->(FieldPos("VOU_CODSER")) <> 0
				VOU->VOU_CODSER := aRelacaoSC[ni,4]
			EndIf

			If VOU->(FieldPos("VOU_SERINT")) <> 0
				VOU->VOU_SERINT := aRelacaoSC[ni,13]
			EndIf
			MsUnlock()
		Next
	EndIf

	// Deletando a diferença de uma Gravação anterior dos Serviços e Campanhas que não estão mais relacionados
	If !(Empty(aRelDelSC))
		For ni := 1 to Len(aRelDelSC)
			// VOU
			DbSelectArea("VOU")
			DbSetOrder(1) // VOU_FILIAL + VOU_NUMINT + VOU_CHASSI
			If DbSeek(xFilial("VOU") + aRelDelSC[ni,12] + VV1->VV1_CHASSI)
				While !VOU->(Eof()) .And. xFilial("VOU") == VOU->VOU_FILIAL .And. VV1->VV1_CHASSI == VOU->VOU_CHASSI .And. VO1->VO1_NUMOSV == VOU->VOU_NUMOSV
					If aRelDelSC[ni,12] == VOU->VOU_NUMINT
						RecLock("VOU", .F., .T.)
						DbDelete()
						MsUnLock()
					EndIf

					VOU->(dbSkip())
				EndDo
			EndIf
		Next
	EndIf
EndIf

End Transaction
Return .t.

/*/{Protheus.doc} OFA1100106_PercentualCampanhaVOP
Gravação do Percentual das Campanhas na tabela VOP

@author Fernando Vitor Cavani
@since 24/07/2018
@version undefined

@type function
/*/
Function OFA1100106_PercentualCampanhaVOP(cNumInt)
Local nQtdTot := 0
Local nQtdExe := 0
Local cSQL    := ""

Default cNumInt := ""

If !Empty(cNumInt)
	// Verificando percentual da Campanha
	// Total
	cSQL := "SELECT COUNT(R_E_C_N_O_) AS QTD_TOT "
	cSQL += "FROM " + RetSQLName("VOU") + " VOU "
	cSQL += "WHERE VOU.VOU_FILIAL = '" + xFilial("VOU") + "' "
	cSQL += "  AND VOU.VOU_NUMINT = '" + cNumInt + "' "
	cSQL += "  AND VOU.D_E_L_E_T_ = ' ' "
	nQtdTot := FM_SQL(cSQL)

	// Total Executado
	cSQL := "SELECT COUNT(R_E_C_N_O_) AS QTD_EXE "
	cSQL += "FROM " + RetSQLName("VOU") + " VOU "
	cSQL += "WHERE VOU.VOU_FILIAL = '" + xFilial("VOU") + "' "
	cSQL += "  AND VOU.VOU_NUMINT = '" + cNumInt + "' "
	cSQL += "  AND VOU.VOU_DATEXE <> ' ' "
	cSQL += "  AND VOU.D_E_L_E_T_ = ' ' "
	nQtdExe := FM_SQL(cSQL)

	// VOP
	DbSelectArea("VOP")
	DbSetOrder(1) // VOU_FILIAL + VOP_NUMINT
	If DbSeek(xFilial("VOP") + cNumInt)
		RecLock("VOP", .f.)
		VOP->VOP_PEREXE := (nQtdExe / nQtdTot) * 100
		MsUnLock()
	EndIf
EndIf
Return .t.

/*/{Protheus.doc} OFA1100116_AlteracaoNumeroCampanhaVOP
Verificação da existência do campo VOP_NUMCAM
já relacionado em Requisição de Serviço (VO4)

@author Fernando Vitor Cavani
@since 23/08/2018
@version undefined

@type function
/*/
Function OFA1100116_AlteracaoNumeroCampanhaVOP()
Local cSQL     := ""
Local lNumCamp := .f.

If M->VOP_TIPPEN == "1"
	If !Empty(cNumCamp) .And. cNumCamp <> M->VOP_NUMCAM
		cSQL := "SELECT COUNT(R_E_C_N_O_) AS QTD_CAM "
		cSQL += "FROM " + RetSQLName("VO4") + " VO4 "
		cSQL += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' "
		cSQL += "  AND VO4.VO4_CODCAM = '" + cNumCamp + "' "
		cSQL += "  AND VO4.D_E_L_E_T_ = ' ' "
		If FM_SQL(cSQL) <> 0
			lNumCamp := .t.
		EndIf

		If lNumCamp
			MsgAlert(STR0044, STR0007) // Número da Campanha não pode ser alterada pois já existe relação com uma Requisição de Serviço em uma Ordem de Serviço! / Atenção

			M->VOP_NUMCAM := cNumCamp

			Return .f.
		EndIf
	EndIf
EndIf
Return .t.