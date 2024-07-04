#include "PROTHEUS.CH"
#include "OFIIA030.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIIA030 ³ Autor ³  Renata               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro das pecas atraves do arquivo VI9                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA030()

Private aCampos := {}
Private aCamposCamTec := {}
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004)  //Cadastro de pecas originais //"Cadastro de Peca (Arquivo Montadora)"
private cCodMar , cIndex , cChave , cCond , nIndexS := 0 , nIndSb1 := 0 , nIndex := 0

If !Pergunte("OFIMAR",.t.)
	Return
EndIf

cCodMar := MV_PAR01

dbSelectArea("SB1")
cIndex  := CriaTrab(nil,.f.)
cChave  := "SB1->B1_FILIAL+SB1->B1_CODITE"
IndRegua("SB1",cIndex,cChave,,,STR0005) //"Filtrando!!")

DbSelectArea("SB1")
nIndexS := RetIndex("SB1")
#IFNDEF TOP
	dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndexS+1)
nIndSb1 := nIndexS+1

dbSelectArea("VI9")
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := "VI9_CODMAR = '"+cCodMar+"' .and. (VI9->VI9_TIPREG = '01')"   //.or. VI9->VI9_TIPREG = '02')"
IndRegua("VI9",cIndex,cChave,,cCond,STR0005) //"Filtrando!!"

DbSelectArea("VI9")
nIndex := RetIndex("VI9")
#IFNDEF TOP
	dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

mBrowse( 6, 1,22,75,"VI9")

dbSelectArea("VI9")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

dbSelectArea("SB1")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³IA030A    ³ Autor ³Renata                 ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ chama a funcao fs_gravapc, feito dessa forma por causa do  ³±±
±±³          ³ termometro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA030A(cAlias,nReg,nOpc)

If xFilial("VI9") != VI9->VI9_FILIAL .or. (VI9->(EOF()) .and. VI9->(BOF()))
	Help(" ",1,"ARQVAZIO")
	Return .f.
Endif

PRIVATE aRotina := { {  ,"", , 3},;   && Pesquisar
{  ,"", , 3},;   && Visualizar
{  ,"", , 3}}    && Atualizar
Private lMSHelpAuto := .t. , lMSErroAuto := .f. , lRet := .t.

Begin Transaction

Processa({|| FS_GRAVAPC()})

End Transaction

FS_DELIA30()

If !lRet
	MostraErro()
EndIf

Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_GRAVAPC  Autor ³Renata                 ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que monta o vetor para o MATA010                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVAPC()

Local lAcheiSB1 := .t. , cPecInt , cDesIte
Private cCtaCtb , cCenCus , cAlmox , cTesEnt , cTesSai , cCodFab , cGruIte , cGruDes
Private aIncSB1 := {}

FG_SEEK("VE4","VI9->VI9_CODMAR",1,.F.)
cCtaCtb := VE4->VE4_CTACTB
cCenCus := VE4->VE4_CENCUS
cAlmox  := VE4->VE4_ALMPAD
cTesEnt := VE4->VE4_TESENT
cTesSai := VE4->VE4_TESSAI
cCodFab := VE4->VE4_CODFAB
cGruIte := VE4->VE4_GRUITE
cGruDes := VE4->VE4_GRUDES
cFEstCo := IIf(VE4->VE4_FESTCO="0","N","S")

FG_SEEK("VE1","VI3->VI3_CODMAR",1,.F.)
cFabric := left(VE1->VE1_DESMAR,20)

dbselectArea("VI9")
dbgotop()

ProcRegua( reccount() )

Do While !Eof() .And. VI9->VI9_FILIAL == xFilial("VI9")
	
	lAcheiSB1 := FG_SEEK("SB1","VI9->VI9_CODITE",nIndSB1,.F.)  //INDICE NOVO DO SB1 - B1_CODITE criado pela indregua
	
	If lAcheiSB1 = .T.
		Do While !SB1->(eof()) .AND. SB1->B1_CODITE == VI9->VI9_CODITE .AND. SB1->B1_FILIAL == xFilial("SB1")
			FG_SEEK("SBM","SB1->B1_GRUPO",1,.F.)
			If SBM->BM_CODMAR == cCodMar
				lAcheiSB1 = .T.
				Exit
			EndIf
			SB1->(DBSKIP())
			lAcheiSB1 = .F.
		EndDo
	EndIf
	
	FG_SEEK("VE5","cCodMar+cGruDes",1,.F.) //grupo de desconto pre definido
	
	cDesIte := VI9->VI9_DENPOR
	
	If lAcheiSB1 = .F.
		
		If GetNewPar("MV_ITESEQ","S") == "1"
			cPecInt := VI9->VI9_CODITE
		ElseIf GetNewPar("MV_ITESEQ","S") == "2"
			cPecInt := cGruIte+VI9->VI9_CODITE
		Else
			cPecInt := GetSXENum("SB1","B1_COD")
			ConfirmSX8()
		EndIf
		
		aIncSB1:= {}
		aAdd(aIncSB1,{"B1_COD"     ,cPecInt               ,Nil}) // Codigo
		aAdd(aIncSB1,{"B1_CODITE"  ,VI9->VI9_CODITE      ,Nil}) // Codigo
		
		aAdd(aIncSB1,{"B1_DESC"    ,cDesIte              ,Nil}) // Descricao
		
		aAdd(aIncSB1,{"B1_TIPO"    ,"ME"                   ,Nil}) // Tipo do Produto
		aAdd(aIncSB1,{"B1_UM"      ,"PC"                   ,Nil}) //
		aAdd(aIncSB1,{"B1_LOCPAD"  ,cAlmox                 ,Nil}) //
		aAdd(aIncSB1,{"B1_PICM"    ,0                      ,Nil}) //
		aAdd(aIncSB1,{"B1_TE"      ,cTesEnt                ,Nil}) //
		aAdd(aIncSB1,{"B1_TS"      ,cTesSai                ,Nil}) //
		aAdd(aIncSB1,{"B1_CONTA"   ,cCtaCtb                ,Nil}) //
		if !empty(cCenCus)
			aAdd(aIncSB1,{"B1_CC"   ,cCenCus                ,Nil}) //
		endif
		aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"                    ,Nil}) //
		aAdd(aIncSB1,{"B1_FABRIC"  ,cFabric                 ,Nil}) //
		aAdd(aIncSB1,{"B1_CONTRAT" ,"N"                    ,Nil}) //
		aAdd(aIncSB1,{"B1_LOCALIZ" ,"N"                    ,Nil}) //
		aAdd(aIncSB1,{"B1_IRRF"    ,"N"                    ,Nil}) //
		aAdd(aIncSB1,{"B1_CONTSOC" ,"N"                    ,Nil}) //
		aAdd(aIncSB1,{"B1_GRUPO"   ,cGruIte                ,Nil}) // Grupo
		aAdd(aIncSB1,{"B1_ENVOBR"  ,"0"                    ,Nil}) //
		aAdd(aIncSB1,{"B1_GRUDES"  ,cGruDes                ,Nil}) //
		aAdd(aIncSB1,{"B1_SITPROD"  ,"N"                    ,Nil}) //
		
		aAdd(aIncSB1,{"B1_SEGUN"   ,"PC"                     ,Nil}) //
		aAdd(aIncSB1,{"B1_MONO"    ,"S"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_FLAGSUG" ,"1"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_CLASSVE" ,"1"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_APROPRI" ,"D"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_FANTASM" ,"N"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_TIPODEC" ,"N"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_UREV   " ,DDATABASE                ,Nil}) //
		aAdd(aIncSB1,{"B1_PERINV"  ,180                      ,Nil}) //
		aAdd(aIncSB1,{"B1_GRADE"   ,"N"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_PROC"    ,VE4->VE4_CODFOR         ,Nil}) //
		aAdd(aIncSB1,{"B1_LOJPROC" ,VE4->VE4_LOJFOR         ,Nil}) //
		aAdd(aIncSB1,{"B1_FORAEST" ,cFestCo                  ,Nil}) //
		aAdd(aIncSB1,{"B1_ANUENTE" ,"2"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_BALANCA" ,"0"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_IMPZFRC" ,"N"                      ,Nil}) //
		aAdd(aIncSB1,{"B1_CONV"    ,1                        ,Nil}) //
		aAdd(aIncSB1,{"B1_ORIGEM"  ,"00"                     ,Nil}) //
		
		lMSHelpAuto := .t.
		lMSErroAuto := .f.
		
		MSExecAuto({|x| mata010(x)},aIncSB1)
		
		If !lMSErroAuto //deu certo  
			lAcheiSB1 := .t.
		Else  //deu erro
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		DbSelectArea("SB5")
		DbSetOrder(1)
		If !DbSeek( xFilial("SB5") + cPecInt )
			
			RecLock("SB5",.T.)
			SB5->B5_FILIAL := xFilial("SB5")
			SB5->B5_COD    := cPecInt
			MsUnLock()
			
		EndIf
		
	Else
		
		DbSelectArea("SB1")
		RecLock("SB1",.f.)
		
		SB1->B1_DESC := cDesIte
		
		MsUnLock()
		
		cPecInt := SB1->B1_COD
		
	EndIf
	
	If ExistBlock("IA030DPG")
		ExecBlock("IA030DPG",.f.,.f.,{cPecInt})
	EndIf
	
	IncProc(OemtoAnsi(STR0006))    //"Atualizando cadastro de Pecas!!"
	
	DbSelectArea("VI9")
	DbSkip()
EndDo

Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DELAIA30³ Autor ³Renata                ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apaga os dados do arquivo VI9                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DELIA30()

DbSelectarea("VI9")
DbGoTop()
IF Ma280Flock("VI9")
	DbClearInd()
	OpenIndx("VI9",.F.)
	delete all for VI9->VI9_TIPREG = "01"
	pack
	reindex
	DbCloseArea()
Endif

ChkFile("VI9",.F.)

DbSelectArea("VI9")
nIndex := RetIndex("VI9")
#IFNDEF TOP
	dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³IA030V    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ visualiza os dados dos arquivos                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IA030V(cAlias,nReg,nOpc)

CPOIA030()
AxVisual(cAlias,nReg,nOpc,aCampos)

return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CPOIA030  ³ Autor ³Renata                 ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Pega os campos no SX3 para serem mostrados na visualizacao  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPOIA030()
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VI9")
aCampos := {}
do While !Eof() .and. x3_arquivo == "VI9"
	If X3USO(x3_usado) .And. cNivel>=x3_nivel
		aadd(aCampos,x3_campo)
	EndIf
	DbSkip()
Enddo
DbSelectArea("VI9")
Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MenuDef   ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aRotina ( MENUDEF )                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { 	{ STR0001 ,"AxPesqui", 0 , 1},; //"Pesquisar"
					{ STR0002 ,"IA030V", 0 , 2},;    //"Visualizar"
					{ STR0003 ,"IA030A", 0 , 3  }}   //"Atualizardd
Return aRotina