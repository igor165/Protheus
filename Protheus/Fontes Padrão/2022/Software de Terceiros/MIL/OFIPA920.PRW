// ษออออออออหออออออออป
// บ Versao บ 12     บ
// ศออออออออสออออออออผ
#include "PROTHEUS.CH"
#include "DBTREE.CH"
#include "OFIPA920.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIPA920 ณ Autor ณ  Fabio                ณ Data ณ 11/11/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Kit's                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico  (Modelo3)                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIPA920()

Private oTree,oGrupo,cGrupo := Space(03),nNivel,aCampos := {},cCadastro := OemToAnsi(STR0001) //Kit's
Private aRotina := MenuDef()
Private nUsado    := 0
                        
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de  Oficina e Auto Pe็as        //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIPA920"})
    Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"VEH")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA920     บAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VA920(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
//
Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0 , _ni := 0

Private aCols  := {} , aHeader := {} , aCpoEnchoice  := {}
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private aTELA[0][0],aGETS[0]
Private nLenAcols := 0

DbSelectArea("SBM")
DbSetOrder(1)
Dbseek( xFilial("SBM")+VEH->VEH_GRUKIT )

DbSelectArea("VE1")
DbSetOrder(1)
Dbseek( xFilial("VE1")+SBM->BM_CODMAR )

DbSelectArea("VEH")

If nOpc == 3
	nOpcE := 3
	nOpcG := 3
ElseIf nOpc == 4
	nOpcE := 4
	nOpcG := 4
ElseIf nOpc == 2
	nOpcE := 2
	nOpcG := 2
Else
	nOpcE := 5
	nOpcG := 5
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VEH",.T.)

aCpoEnchoice  := {}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VEH")
Do While !Eof().and.(x3_arquivo=="VEH")
	If X3USO(x3_usado).and.cNivel >=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo):= CriaVar(x3_campo)
	DbSkip()
EndDo

If nOpc # 3
	DbSelectArea("VEH")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nUsado:=0
DbSelectArea("SX3")
DbSeek("VE8")
aHeader:={}

While !Eof().And.(x3_arquivo=="VE8")
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo)$[VE8_GRUKIT/VE8_CODKIT/VE8_DESKIT/VE8_PERPEC])
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Endif
	DbSkip()
Enddo

aCols:={}
dbSelectArea("VE8")
DbSetOrder(1)
DbSeek( xFilial("VE8") + VEH->VEH_GRUKIT + VEH->VEH_CODKIT )

If nOpc == 3 .Or. !Found()
	
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	
Else
	
	While !eof() .And. VE8->VE8_FILIAL == xFilial("VE8") .And. VE8->VE8_GRUKIT+VE8->VE8_CODKIT == VEH->VEH_GRUKIT+VEH->VEH_CODKIT
		
		AADD(aCols,Array(nUsado+1))
		
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
		Next
		
		aCols[Len(aCols),nUsado+1]:=.F.
		
		dbSkip()
		
	End
	nLenaCols     := Len(aCols)
Endif

//DbSkip(-1)

If Len(aCols)>0
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa a Modelo 3                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTitulo       :=STR0001
	cAliasEnchoice:="VEH"
	cAliasGetD    :="VE8"
	cLinOk        :="FG_OBRIGAT()"
	cTudOk        :="FS_PERC920()"
	cFieldOk      :="FG_MEMVAR() .and. FS_VALPA920()"
	
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05, 75 , .T. , .F. } ) 	//Cabecalho
	AAdd( aObjects, { 01, 10 , .T. , .T. } )  	//list box superior
	//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
	//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior
	//tamanho para resolucao 1024*768
	//aSizeAut[3]:= 508
	//aSizeAut[5]:= 1016
	// Fator de reducao de 0.8
	//for nCntTam := 1 to Len(aSizeAut)
	//	aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)
	//next
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5]	of oMainWnd PIXEL
	
	EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,,,,,,,.F.)
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
	oGetDados:oBrowse:bChange := {|| FG_AALTER("VE8",nLenaCols,oGetDados) }
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_GRAPA920( nOpc ),oDlg:End(),.f.) },{|| oDlg:End() })
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRAPA92บAutor  ณMicrosiga           บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava็ใo das Informa็๕es do KIT                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRAPA920( nOpc )

Local i := 0
Private lMsHelpAuto := .t., lMsFinalAuto := .f.
if M->VEH_TIPO == "1"
	dbSelectArea("SBM")
	dbSetOrder(1)
	if !dbSeek(xFilial("SBM")+M->VEH_GRUKIT)
		MsgStop(STR0019,STR0016) // / Atencao
		Return(.f.)
	Endif
	dbSelectArea("SB1")
	dbSetOrder(7)
	if !dbSeek(xFilial("SB1")+M->VEH_GRUKIT+M->VEH_CODKIT)
		MsgStop(STR0020,STR0016) // / Atencao
		Return(.f.)
	Endif
Endif
If nOpc # 2
	
	Begin Transaction
	
	DbSelectArea("SBM")
	DbSetOrder(1)
	DbSeek(xFilial("SBM")+M->VEH_GRUKIT)
	
	DbselectArea("VE4")
	DbSetOrder(1)
	Dbseek(xFilial("VE4")+SBM->BM_CODMAR)
	
	DbSelectArea("VEH")
	DbSetOrder(1)
	DbSeek(xFilial("VEH")+M->VEH_GRUKIT+M->VEH_CODKIT)
	
	RecLock("VEH", !Found() )
	
	FG_GRAVAR("VEH")
	
	MsUnLock()
	
	for i:=1 to len(aCols)
		
		If i > nLenaCols .and. aCols[i,Len(aCols[i])]
			Loop
		EndIf
		
		DbSelectArea("VE8")
		DbSetOrder(1)
		DbSeek( xFilial("VE8") + VEH->VEH_GRUKIT + VEH->VEH_CODKIT + aCols[I,FG_POSVAR("VE8_GRUITE")] + aCols[I,FG_POSVAR("VE8_CODITE")] )
		
		If ( nOpc == 3 .or. nOpc == 4 ) .And. !aCols[ I , len(aCols[i]) ]
			
			RecLock("VE8", !Found() )
			FG_GRAVAR("VE8",aCols,aHeader,i)
			VE8->VE8_FILIAL := xFilial("VE8")
			VE8->VE8_GRUKIT := VEH->VEH_GRUKIT
			VE8->VE8_CODKIT := VEH->VEH_CODKIT
			MsUnlock()
			
		ElseIf Found()
			
			RecLock("VE8",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VE8")
			
		Endif
		
	Next
	
	If nOpc == 5 .And. VEH->(Found())
		
		RecLock("VEH",.F.,.T.)
		dbdelete()
		MsUnlock()
		WriteSx2("VEH")
		
	EndIf
	
	End Transaction
	
Endif
lMsHelpAuto := .f.


Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALPA92บAutor  ณMicrosiga           บ Data ณ  05/26/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo da aCols                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALPA920()

Local nwnk := 0
Local nPosGru
Local nPosIte

nPosGru := FG_POSVAR("VE8_GRUITE")
nPosIte := FG_POSVAR("VE8_CODITE")

If ReadVar() == "M->VE8_CODITE" .and. !aCols[n,Len(aCols[n])]
	
	If !ExistChav("VE8","M->VEH_GRUKIT+M->VEH_CODKIT+M->VE8_GRUITE+M->VE8_CODITE",1)
		
		Return(.f.)
		
	EndIf
	
	For nwnk := 1 to len(aCols)
		If nwnk <> n .and. !aCols[nwnk,Len(aCols[nwnk])] .and.;
			aCols[nwnk,nPosGru]+aCols[nwnk,nPosIte]==aCols[n,nPosGru]+M->VE8_CODITE
			HELP(" ",1,"JAGRAVADO")
			Return(.f.)
		Endif
	Next
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFS_PERC920ณAutor  ณ  Fabio                ณ Data ณ 18/11/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Verifica Percentual do Valor da Peca.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_PERC920(nPercentual)

//Local nQtd := 0 , 
Local i := 0 , nReg := 0
FG_MEMVAR()
If M->VEH_TIPO == "2" // Kit"
	For i:=1 to Len(aCols)
		If aCols[i,nUsado+1]
			loop
		EndIf
		If aCols[i,FG_POSVAR("VE8_QTDADE")] == 0
			Help("  ",1,"QTDINVAL")
			Return(.f.)
		EndIf
//		If aCols[i,FG_POSVAR("VE8_PERPEC")] == 0
//			Help("  ",1,"PERCINVAL")
//			Return(.f.)
//		EndIf
		If aCols[i,FG_POSVAR("VE8_GRUITE")]+aCols[i,FG_POSVAR("VE8_CODITE")] == M->VE8_GRUITE+M->VE8_CODITE
			nReg ++
			If nReg > 1
				Help("  ",1,"EXISTCHAV")
				Return( .f. )
			EndIf
		EndIf
//		If !(aCols[i,Len(aCols[i])])
//			nQtd:=nQtd+IF(Pcount()==1.And.i==n,nPercentual,aCols[i,FG_POSVAR("VE8_PERPEC")])
//		EndIf
	Next
//	If (Pcount()==1 .And. nQtd>100) .Or. (PCount()==0 .And. nQtd#100)
//		Help("  ",1,"PERCINVAL")
//		Return(.f.)
//	EndIf
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA920V    บAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela de visualizacao "Tree"                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VA920V()

Private oDlg,oTree

DEFINE MSDIALOG oDlg FROM  015, 006 TO 499, 637 TITLE STR0001 PIXEL //"Kit's"

DEFINE DBTREE oTree FROM 015, 001 TO 242, 315 OF oDlg  // ON CHANGE FS_POSIC920() ON RIGHT CLICK FS_POPUP920()

ACTIVATE MSDIALOG oDlg ON INIT (ENCHOICEBAR(oDlg,{||oDlg:End()},{||oDlg:End()}),FS_ADDITEM())

Release Objects oTree

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ADDITEMบAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona itens no tree                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ADDITEM()

Local cItens

DbSelectArea("VEH")

DBADDTREE oTree PROMPT VEH->VEH_GRUKIT+" "+VEH->VEH_CODKIT+" "+Posicione("SB1",7,xFilial("SB1")+VEH->VEH_GRUKIT+VEH->VEH_CODKIT,"B1_DESC")+Space(30) RESOURCE "Folder5","Folder6" // CARGO 1

DbSelectArea("VE8")
DbSetOrder(1)
DbSeek(xFilial("VE8")+VEH->VEH_GRUKIT+VEH->VEH_CODKIT)

Do While !Eof() .And. VE8->VE8_FILIAL == xFilial("VE8") .And. VE8->VE8_GRUKIT == VEH->VEH_GRUKIT .And. VE8->VE8_CODKIT == VEH->VEH_CODKIT
	
	cItens:=VE8->VE8_GRUITE+" "+VE8->VE8_CODITE+" "+Posicione("SB1",7,xFilial("SB1")+VE8->VE8_GRUITE+VE8->VE8_CODITE,"B1_DESC")+"   "+ Transform(VE8->VE8_QTDADE,"@E 999,999,999") +"   "+Transform(VE8->VE8_PERPEC,"@E 999.9999")
	
	DBADDITEM oTree PROMPT cItens  RESOURCE  "Folder6" CARGO cItens
	
	DbSelectArea("VE8")
	DbSkip()
	
EndDo

DBENDTREE oTree
DBENDTREE oTree

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณVA920IMPORTณAutor ณ  Fabio                ณ Data ณ 11/11/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Importa Kit's da Fabrica                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VA920IMPORT()

Local lMostraTela := .t.
Private oDlg,oLbTexto,oMarca,aVetor:={},aIteKit :={},aBitmaps := {},cBitMap := Space(8) , lMarca := .t.
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private nNumeroImp := 0 , nRegistro  := 0

If PERGUNTE("VPA920")
	
	DbSelectArea("VE4")
	DbSetOrder(1)
	DbSeek(xFilial("VE4")+mv_par01)
	
	DbSelectArea("SBM")
	DbSetOrder(1)
	DbSeek(xFilial("SBM")+VE4->VE4_GRUITE)
	
	&& Monta vetor
	Processa( { |lEnd| lMostraTela := FS_KIT() } ,, STR0008 , .T.) //"Processando.."
	
	If lMostraTela
		
		DEFINE MSDIALOG oDlg TITLE STR0001+" - "+mv_par01+"  "+mv_par02 From 1,08 to 36,92      of oMainWnd //"Kit's"
		
		@ 015,.1 TO 188,333 LABEL "" OF oDlg PIXEL
		
		@ 016, 003 CHECKBOX oMarca  VAR lMarca   PROMPT STR0009 ; //"Marcar"
		OF oDlg ;
		ON CLICK (FS_MARCA920(lMarca),oLbTexto:Refresh()) ;
		SIZE 33,11 font TFont():New( "Arial", 06, 12 ) PIXEL
		
		@ 026,001 LISTBOX oLbTexto FIELDS HEADER OemToAnsi(" ")     ,;
		OemToAnsi(STR0001),; //"Kit's"
		OemToAnsi(STR0010); //"Descricao"
		COLSIZES 30,80,100;
		SIZE 331,160 OF oDlg PIXEL ON DBLCLICK (aVetor[oLbTexto:nAt,1] := !aVetor[oLbTexto:nAt,1], aVetor[oLbTexto:nAt,2] := .t. ,FS_NNUMEROIMP(aVetor[oLbTexto:nAt,1]) ) ;
		ON CHANGE (FS_ITEKIT( aVetor[oLbTexto:nAt,5] ))
		
		//   SIZE 331,160 OF oDlg PIXEL ON DBLCLICK (If(aVetor[oLbTexto:nAt,2],(aVetor[oLbTexto:nAt,1]:=.F.,aVetor[oLbTexto:nAt,2]:=.F.),(aVetor[oLbTexto:nAt,1]:=.T.,aVetor[oLbTexto:nAt,2]:=.T.))) ;
		
		oLbTexto:bGotFocus := {|| oLbItens:nClrPane := CLR_HGRAY , oLbTexto:nClrPane := CLR_WHITE }
		
		@ 190,001 TO 264,333 LABEL STR0011 OF oDlg PIXEL //"Itens"
		
		@ 197,001 LISTBOX oLbItens FIELDS HEADER OemToAnsi(STR0012),; //"Item"
		OemToAnsi(STR0010),; //"Descricao"
		OemToAnsi(STR0013) ; //"Quantidade"
		COLSIZES 090,120,100;
		SIZE 331,63 OF oDlg PIXEL
		
		oLbItens:nClrPane := CLR_HGRAY
		
		oLbItens:bGotFocus := {|| oLbTexto:nClrPane := CLR_HGRAY , oLbItens:nClrPane := CLR_WHITE }
		
		FS_JOGALIST("1")
		
		ACTIVATE MSDIALOG oDlg ON INIT (ENCHOICEBAR(oDlg,{|| Processa( {|lEnd| If( FS_IMPORTAKIT() , oDlg:End() , .f. ) },,STR0008 , .T.)} , {|| oDlg:End() } ) ) CENTER //"Processando.."
		
	EndIf
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MARCA92บAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca itens no vetor para importacao                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MARCA920(lMarca)

Local i := 0

For i:=1 to Len(aVetor)
	
	If !aVetor[i,2]
		
		aVetor[i,1] := lMarca
		
		FS_NNUMEROIMP(lMarca)
		
	EndIf
	
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_NNUMEROบAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSoma a quantidade de itens que serao importados             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_NNUMEROIMP(lSomaSub)

nNumeroImp := If(lSomaSub,nNumeroImp + 1 ,nNumeroImp - 1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_KIT    บAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta vetor com os kit's que serao mostrados na tela        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_KIT()

Local cDesIte := "" , nPosReg := 0 , nCont := 0
Local cQuebra := ""

Private lAbortPrint := .f.

aVetor:={}

DbSelectArea("VI9")

DbSetOrder(1)
DbSeek(xFilial("VI9")+mv_par01+StrZero(6,2))

Count To nCont For VI9->VI9_FILIAL == xFilial("VI9") .And. VI9->VI9_CODMAR == mv_par01 .And. VI9->VI9_TIPREG == StrZero(6,2)

ProcRegua( nCont )

DbSetOrder(1)
DbSeek(xFilial("VI9")+mv_par01+StrZero(6,2))

Do While !Eof() .And. VI9->VI9_FILIAL == xFilial("VI9") .And. VI9->VI9_CODMAR == mv_par01 .And. VI9->VI9_TIPREG== StrZero(6,2)
	
	If VI9->VI9_CODMAR + VI9->VI9_CODITE # cQuebra
		
		nPosReg := RecNo()
		
		DbSeek(xFilial("VI9")+mv_par01+StrZero(1,2)+VI9->VI9_CODITE)
		
		cDesIte := VI9->VI9_DENPOR
		
		DbGoTo(nPosReg)
		
		Aadd(aVetor,{lMarca,.F.,VI9->VI9_CODMAR,VI9->VI9_TIPREG,VI9->VI9_CODITE, cDesIte ," "})
		
		FS_NNUMEROIMP(lMarca)
		
		cQuebra := VI9->VI9_CODMAR + VI9->VI9_CODITE
		
	EndIf
	
	IncProc(STR0014+"  "+mv_par02) //"Gerando Kit's"
	
	If lAbortPrint
		
		If MsgYesNo(STR0015,STR0016) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
			
			Return( .f. )
			
		Else
			
			lAbortPrint := .f.
			
		EndIf
		
	EndIf
	
	DbSelectArea("VI9")
	DbSkip()
	
EndDo

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ITEKIT บAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta vetor com os itens do kit                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ITEKIT(cKit)

Local cDesIte := "" , nPosReg := 0

aIteKit :={}

DbSelectArea("VI9")
DbSetOrder(1)
DbSeek(xFilial("VI9")+mv_par01+StrZero(6,2)+cKit)
Do While !Eof() .And. VI9->VI9_FILIAL == xFilial("VI9")  .And. VI9->VI9_CODMAR == mv_par01 .And. VI9->VI9_TIPREG == StrZero(6,2) .And. VI9->VI9_CODITE == cKit
	
	nPosReg := RecNo()
	
	DbSeek(xFilial("VI9")+mv_par01+StrZero(1,2)+VI9->VI9_ITEKIT)
	
	cDesIte := VI9->VI9_DENPOR
	
	DbGoTo(nPosReg)
	
	Aadd(aIteKit,{VI9->VI9_ITEKIT, cDesIte , VI9->VI9_QTDADE })
	
	DbSelectArea("VI9")
	DbSkip()
	
EndDo

FS_JOGALIST("2")

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_JOGALISบAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMosta kit's e itens nos list Box                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_JOGALIST(cList)

If cList == NIL .Or. cList == "1"
	
	If Len(aVetor) == 0
		Aadd(aVetor,{.F.,.F.," "," "," "," " })
	EndIf
	
	Asort(aVetor,1,,{|x,y|x[3]+x[4]+x[5] < y[3]+y[4]+y[5]})
	
	oLbTexto:SetArray(aVetor)
	oLbTexto:bLine := { || { If(aVetor[oLbTexto:nAt,1],oOk,oNo) ,;
	aVetor[oLbTexto:nAt,5] ,;
	aVetor[oLbTexto:nAt,6] }}
	oLbTexto:SetFocus()
	
EndIf

If cList == NIL .Or. cList == "2"
	
	If Len(aIteKit) == 0
		Aadd(aIteKit,{"","",0 })
	EndIf
	
	Asort(aIteKit,1,,{|x,y|x[1] < y[1] })
	
	oLbItens:SetArray(aIteKit)
	oLbItens:bLine := { || { aIteKit[oLbItens:nAt,1] ,;
	aIteKit[oLbItens:nAt,2] ,;
	aIteKit[oLbItens:nAt,3] }}
	
	oLbItens:SetFocus()
	oLbTexto:SetFocus()
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IMPORTAบAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava kit                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_IMPORTAKIT()

Local lRet := .t. , nCont := 0 , nImp := 0 , cPecInt , cDesIte := "" , nPosReg := 0

Private lMSHelpAuto := .t. , lMSErroAuto := .f. , lAbortPrint := .f.

DbselectArea("VE4")
DbSetOrder(1)
Dbseek(xFilial("VE4")+mv_par01)

DbselectArea("VE1")
DbSetOrder(1)
Dbseek(xFilial("VE1")+mv_par01)

DbSelectArea("SBM")
DbSetOrder(1)
DbSeek(xFilial("SBM")+VE4->VE4_GRUITE)

DbselectArea("VE5")
DbSetOrder(1)
Dbseek(xFilial("VE5")+mv_par01+"2")

ProcRegua( nNumeroImp )

Begin Transaction

For nImp:=1 to Len(aVetor)
	
	If aVetor[nImp,1]
		
		IncProc(STR0017+"  "+aVetor[nImp,6]) //"Importando Kit's -"
		
		If lAbortPrint
			
			If MsgYesNo(STR0015,STR0016) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
				
				lRet := .f.
				DisarmTransaction()
				Break
				
			Else
				
				lAbortPrint := .f.
				
			EndIf
			
		EndIf
		
		DbSelectArea("VI9")
		DbSetOrder(1)
		DbSeek( xFilial("VI9") + mv_par01 + StrZero(6,2) + aVetor[nImp,5] )
		
		Do While !Eof() .And. VI9->VI9_FILIAL == xFilial("VI9") .And. VI9->VI9_CODMAR == mv_par01 .And. VI9->VI9_TIPREG == StrZero(6,2) .And. VI9->VI9_CODITE == aVetor[nImp,5]
			
			&& Quando a quantidade e zero e que o item nao faz mais parte do kit.
			If VI9->VI9_QTDADE # 0
				
				DbSelectArea("VEH")
				DbSetOrder(1)
				If !DbSeek( xFilial("VEH") + VE4->VE4_GRUITE + VI9->VI9_CODITE )
					
					RecLock("VEH",.t.)
					VEH->VEH_FILIAL := xFilial("VEH")
					VEH->VEH_GRUKIT := VE4->VE4_GRUITE
					VEH->VEH_CODKIT := VI9->VI9_CODITE
					MsUnLock()
					
				EndIf
				
				DbSelectArea("VE8")
				DbSetOrder(1)
				DbSeek( xFilial("VE8") + VE4->VE4_GRUITE + VI9->VI9_CODITE + VE4->VE4_GRUITE + VI9->VI9_ITEKIT )
				
				RecLock("VE8",!Found())
				VE8->VE8_FILIAL := xFilial("VE8")
				VE8->VE8_GRUKIT := VE4->VE4_GRUITE
				VE8->VE8_CODKIT := VI9->VI9_CODITE
				VE8->VE8_GRUITE := VE4->VE4_GRUITE
				VE8->VE8_CODITE := VI9->VI9_ITEKIT
				VE8->VE8_QTDADE := VI9->VI9_QTDADE
				MsUnLock()
				
				&& Entrada Automatica do Kit
				**************************
				
				cDesIte := aVetor[ nImp , 6 ]     // Descricao do Kit
				
				DbSelectArea("SB1")
				DbSetOrder(7)
				
				If !DbSeek( xFilial("SB1") + VE4->VE4_GRUITE + VI9->VI9_CODITE )
					
					//              cGruIte := VE4->VE4_GRUITE
					
					If GetNewPar("MV_ITESEQ","S") == "1"
						cPecInt := VI9->VI9_CODITE
					ElseIf GetNewPar("MV_ITESEQ","S") == "2"
						cPecInt := VE4->VE4_GRUITE+VI9->VI9_CODITE
					Else
						cPecInt := GetSXENum("SB1","B1_COD")
					EndIf
					
					aIncSB1:= {}
					aAdd(aIncSB1,{"B1_COD"     ,cPecInt               ,Nil}) // Codigo
					aAdd(aIncSB1,{"B1_CODITE"  ,VI9->VI9_CODITE      ,Nil}) // Codigo
					
					aAdd(aIncSB1,{"B1_DESC"    ,cDesIte               ,Nil}) // Descricao
					
					aAdd(aIncSB1,{"B1_TIPO"    ,"ME"                  ,Nil}) // Tipo do Produto
					aAdd(aIncSB1,{"B1_UM"      ,"PC"                  ,Nil}) //
					aAdd(aIncSB1,{"B1_LOCPAD"  ,VE4->VE4_ALMPAD       ,Nil}) //
					aAdd(aIncSB1,{"B1_PICM"    ,VE5->VE5_ALIICM       ,Nil}) //
					aAdd(aIncSB1,{"B1_TE"      ,VE4->VE4_TESENT       ,Nil}) //
					aAdd(aIncSB1,{"B1_TS"      ,VE4->VE4_TESSAI       ,Nil}) //
					aAdd(aIncSB1,{"B1_CONTA"   ,VE4->VE4_CTACTB       ,Nil}) //
					if !empty(VE4->VE4_CENCUS)
						aAdd(aIncSB1,{"B1_CC"   ,VE4->VE4_CENCUS        ,Nil}) //
					endif
					aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_FABRIC"  ,Left(VE1->VE1_DESMAR,20),Nil}) //
					aAdd(aIncSB1,{"B1_CONTRAT" ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_LOCALIZ" ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_IRRF"    ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_CONTSOC" ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_GRUPO"   ,VE4->VE4_GRUITE       ,Nil}) // Grupo
					aAdd(aIncSB1,{"B1_ENVOBR"  ,"0"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_GRUDES"  ,"2"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_SITPRO"  ,"N"                    ,Nil}) //
					
					aAdd(aIncSB1,{"B1_ANUENTE" ,"2"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_SEGUN"   ,"PC"                     ,Nil}) //
					aAdd(aIncSB1,{"B1_MONO"    ,"S"                      ,Nil}) //
					aAdd(aIncSB1,{"B1_FLAGSUG" ,"1"                      ,Nil}) //
					aAdd(aIncSB1,{"B1_CLASSVE" ,"1"                      ,Nil}) //
					aAdd(aIncSB1,{"B1_APROPRI" ,"D"                      ,Nil}) //
					aAdd(aIncSB1,{"B1_FANTASM" ,"N"                      ,Nil}) //
					aAdd(aIncSB1,{"B1_TIPODEC" ,"N"                      ,Nil}) //
					aAdd(aIncSB1,{"B1_UREV   " ,dDataBase                ,Nil}) //
					aAdd(aIncSB1,{"B1_PERINV"  ,180                      ,Nil}) //
					aAdd(aIncSB1,{"B1_GRADE"   ,"N"                      ,Nil}) //
					aAdd(aIncSB1,{"B1_PROC"    ,VE4->VE4_CODFOR         ,Nil}) //
					aAdd(aIncSB1,{"B1_LOJPROC" ,VE4->VE4_LOJFOR         ,Nil}) //
					aAdd(aIncSB1,{"B1_BALANCA" ,"0"                      ,Nil}) //
					aAdd(aIncSB1,{"B1_IMPZFRC" ,"N"                      ,Nil}) //
					aAdd(aIncSB1,{"B1_CONV"    ,1                        ,Nil}) //
					aAdd(aIncSB1,{"B1_ORIGEM"  ,"00"                     ,Nil}) //
					aAdd(aIncSB1,{"B1_FORAEST" ,IF(VE4->VE4_FESTCO="0","N","S") ,Nil}) //
					
					lMSHelpAuto := .t.
					lMSErroAuto := .f.
					
					MSExecAuto({|x| mata010(x)},aIncSB1)
					
					If lMsErroAuto
						
						lRet := .f.
						DisarmTransaction()
						Break
						
					EndIf
					
					ConfirmSX8()
					
					DbSelectArea("SB5")
					DbSetOrder(1)
					If !DbSeek( xFilial("SB5") + cPecInt )
						
						RecLock("SB5",.T.)
						SB5->B5_FILIAL := xFilial("SB5")
						SB5->B5_COD    := cPecInt
						MsUnLock()
						
					EndIf
					
				Else
					
					RecLock("SB1",.f.)
					SB1->B1_DESC := cDesIte
					MsUnLock()
					
				EndIf
				
				&& Entrada Automatica do Item do Kit
				**************************
				DbSelectArea( "VI9" )
				nPosReg := RecNo()
				
				DbSeek(xFilial("VI9")+mv_par01+StrZero(1,2)+VI9->VI9_ITEKIT)
				
				cDesIte := VI9->VI9_DENPOR    // Descricao
				
				DbGoTo( nPosReg )
				
				DbSelectArea( "SB1" )
				DbSetOrder(7)
				
				If !DbSeek( xFilial("SB1") + VE4->VE4_GRUITE + VI9->VI9_ITEKIT )
					
					//                 cGruIte := VE4->VE4_GRUITE
					
					If GetNewPar("MV_ITESEQ","S") == "1"
						cPecInt := VI9->VI9_ITEKIT
					ElseIf GetNewPar("MV_ITESEQ","S") == "2"
						cPecInt := VE4->VE4_GRUITE+VI9->VI9_ITEKIT
					Else
						cPecInt := GetSXENum("SB1","B1_COD")
					EndIf
					
					aIncSB1:= {}
					aAdd(aIncSB1,{"B1_COD"     ,cPecInt               ,Nil}) // Codigo
					aAdd(aIncSB1,{"B1_CODITE"  ,VI9->VI9_ITEKIT      ,Nil}) // Codigo
					aAdd(aIncSB1,{"B1_DESC"    ,cDesIte               ,Nil}) // Descricao do Item do Kit
					aAdd(aIncSB1,{"B1_TIPO"    ,"ME"                  ,Nil}) // Tipo do Produto
					aAdd(aIncSB1,{"B1_UM"      ,"PC"                  ,Nil}) //
					aAdd(aIncSB1,{"B1_LOCPAD"  ,VE4->VE4_ALMPAD       ,Nil}) //
					aAdd(aIncSB1,{"B1_PICM"    ,VE5->VE5_ALIICM       ,Nil}) //
					aAdd(aIncSB1,{"B1_TE"      ,VE4->VE4_TESENT       ,Nil}) //
					aAdd(aIncSB1,{"B1_TS"      ,VE4->VE4_TESSAI       ,Nil}) //
					aAdd(aIncSB1,{"B1_CONTA"   ,VE4->VE4_CTACTB       ,Nil}) //
					if !empty(VE4->VE4_CENCUS)
						aAdd(aIncSB1,{"B1_CC"   ,VE4->VE4_CENCUS        ,Nil}) //
					endif
					aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_FABRIC"  ,Left(VE1->VE1_DESMAR,20),Nil}) //
					aAdd(aIncSB1,{"B1_CONTRAT" ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_LOCALIZ" ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_IRRF"    ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_CONTSOC" ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_GRUPO"   ,VE4->VE4_GRUITE       ,Nil}) // Grupo
					aAdd(aIncSB1,{"B1_ENVOBR"  ,"0"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_GRUDES"  ,"2"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_SITPRO"  ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_ANUENTE" ,"2"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_SEGUN"   ,"PC"                   ,Nil}) //
					aAdd(aIncSB1,{"B1_MONO"    ,"S"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_FLAGSUG" ,"1"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_CLASSVE" ,"1"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_APROPRI" ,"D"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_FANTASM" ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_TIPODEC" ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_UREV   " ,dDataBase              ,Nil}) //
					aAdd(aIncSB1,{"B1_PERINV"  ,180                    ,Nil}) //
					aAdd(aIncSB1,{"B1_GRADE"   ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_PROC"    ,VE4->VE4_CODFOR       ,Nil}) //
					aAdd(aIncSB1,{"B1_LOJPROC" ,VE4->VE4_LOJFOR       ,Nil}) //
					aAdd(aIncSB1,{"B1_BALANCA" ,"0"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_IMPZFRC" ,"N"                    ,Nil}) //
					aAdd(aIncSB1,{"B1_CONV"    ,1                      ,Nil}) //
					aAdd(aIncSB1,{"B1_ORIGEM"  ,"00"                   ,Nil}) //
					aAdd(aIncSB1,{"B1_FORAEST" ,IF(VE4->VE4_FESTCO="0","N","S")  ,Nil}) //
					
					lMSHelpAuto := .t.
					lMSErroAuto := .f.
					
					MSExecAuto({|x| mata010(x)},aIncSB1)
					
					If lMsErroAuto
						
						lRet := .f.
						DisarmTransaction()
						Break
						
					EndIf
					
					ConfirmSX8()
					
					DbSelectArea("SB5")
					DbSetOrder(1)
					If !DbSeek( xFilial("SB5") + cPecInt )
						
						RecLock("SB5",.T.)
						SB5->B5_FILIAL := xFilial("SB5")
						SB5->B5_COD    := cPecInt
						MsUnLock()
						
					EndIf
					
				Else
					
					RecLock("SB1",.f.)
					SB1->B1_DESC := cDesIte
					MsUnLock()
					
				EndIf
				
				If ExistBlock("PA920DPG")
					ExecBlock("PA920DPG",.f.,.f.,{cPecInt})
				EndIf
				
			Else
				
				DbSelectArea("VE8")
				DbSetOrder(1)
				
				If DbSeek( xFilial("VE8") + VE4->VE4_GRUITE + VI9->VI9_CODITE + VE4->VE4_GRUITE + VI9->VI9_ITEKIT )
					
					RecLock("VE8",.F.,.T.)
					Dbdelete()
					MsUnlock()
					WriteSX2("VE8")
					
				EndIf
				
				DbSetOrder(1)
				DbSeek( xFilial("VE8") + VE4->VE4_GRUITE + VI9->VI9_CODITE )
				
				Count To nCont For VE8->VE8_FILIAL == xFilial("VE8") .And. VE8->VE8_GRUKIT == VE4->VE4_GRUITE .And. VE8->VE8_CODKIT == VI9->VI9_CODITE
				
				If nCont == 0
					
					DbSelectArea("VEH")
					DbSetOrder(1)
					
					If DbSeek( xFilial("VEH") + VE4->VE4_GRUITE + VI9->VI9_CODITE )
						
						RecLock("VEH",.F.,.T.)
						Dbdelete()
						MsUnlock()
						WriteSX2("VEH")
						
					EndIf
					
				EndIf
				
			EndIf
			
			DbSelectArea("VI9")
			
			RecLock("VI9",.F.,.T.)
			Dbdelete()
			MsUnlock()
			WriteSX2("VI9")
			
			DbSkip()
			
		EndDo
		
	EndIf
	
Next

End Transaction

If !lRet .And. !lAbortPrint
	MostraErro()
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_KITIGUAบAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava kit                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_KITIGUAL()
if M->VE8_CODITE == M->VEH_CODKIT
	MsgStop(STR0018,STR0016)  //O item escolhido e' o proprio kit. Impossivel continuar  ## Atencao
	return .f.
endif
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณFabio               บ Data ณ  10/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := { { STR0002 ,"AxPesqui", 0 , 1},;      //Pesquisar
					{ STR0003 ,"VA920", 0 , 2},;     //Visualizar
					{ STR0004 ,"VA920", 0 , 3},;      //Incluir
					{ STR0005 ,"VA920", 0 , 4},;      //Alterar
					{ STR0006 ,"VA920", 0 , 5}}      //Excluir
//
					//{ STR0007 ,"VA920IMPORT", 0 , 6}} //Importar
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOPA920FIL บAutor  ณThiago              บ Data ณ  16/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OPA920FIL()



Return(.t.)