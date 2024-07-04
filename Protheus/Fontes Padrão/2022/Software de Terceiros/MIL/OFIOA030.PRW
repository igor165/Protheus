////////////////
// Versao 13  //
////////////////

#INCLUDE "OFIOA030.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIOA030 ณ Autor ณ  Fabio                ณ Data ณ 06/07/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Tabela de Servicos                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de concessionarias (SIGAOFI)                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOA030
Local aCores    := {{ 'VO6_AGRSER == "S"','BR_VERMELHO' },;  //Tabela de Revisoes
							{'VO6_AGRSER # "S"','BR_VERDE'}} //Tabela de Servicos

Private aMemos := {{"VO6_DESMEM","VO6_DESDET"}}
Private aRotina := MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cCadastro := OemToAnsi(STR0006) //"Tabela de Servicos"
Private nUsado := 0 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DbSelectArea("VO6")
DbSetOrder(1)

mBrowse( 6, 1,22,75,"VO6",,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOP030     บAutor  ณFabio               บ Data ณ  08/24/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AP030(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
////////////////////////////////////////////////////////////////////////////////////////////

Local bCampo   := { |nCPO| Field(nCPO) }
Local _ni := 0 , aArea := {}
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cFieldOk,cTudok
Local nPosRec  :=0  // Posicao do registro dentro do aCols
Private aTELA[0][0],aGETS[0], nOpcX := nOpc
Private aCpoEnchoice  :={} , wAltera := .t. , wInclui := .t.
Private aCols := {} , aHeader := {}
Private nLenAcols := 0
Private aNewBot  := {}

If FindFunction("FM_NEWBOT")
	FM_NEWBOT("OA030BOT","aNewBot") // Ponto de Entrada de Manutencao da aNewBot - Definicao de Novos Botoes na EnchoiceBar
	// Exemplo de PE
	// Local aRet := {}
	//	aadd(aRet,{"FILTRO",{|| U_FS_teste1()},"BOTAO1"})
	//	return(aRet)                            
Endif

If nOpc # 3 .And. VO6->VO6_AGRSER == "S"
//   Help("  ",1,"DOCINVALID")
	MsgStop(STR0016,STR0014)  //Somente e permitido manutencao em servico que nao seja agrupado!  # Atencao!

   DbSelectArea("VO6")
   DbSetOrder(1)
   Return .t.
EndIf

aArea := sGetArea(aArea,cAlias)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VO6",.t.)         // .t. para carregar campos virtuais

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO6")
While !Eof().and.(x3_arquivo=="VO6")
	If X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $ [VO6_AGRSER/VO6_TMPFAB/VO6_TMPCON])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo):= CriaVar(x3_campo)
	dbSkip()
End
If !(Inclui)
	DbSelectArea("VO6")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

if nOpc == 3
	wAltera := .F.
	wInclui := .T.
	nOpcE := 3
	nOpcG := 3
elseif nOpc == 4
	wAltera := .T.
	wInclui := .F.
	nOpcE := 4
	nOpcG := 4
elseif nOpc == 2
	wAltera := wInclui := .F.
	nOpcE := 2
	nOpcG := 2
else
	wAltera := wInclui := .F.
	nOpcE := 5
	nOpcG := 5
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nUsado:=0
dbSelectArea("SX3")
dbSeek("VO7")
aHeader:={}
While !Eof().And.(x3_arquivo=="VO7")
	if X3_CAMPO # [VO7_CODMAR] .and. X3_CAMPO # [VO7_CODSER]
		If X3USO(x3_usado).And.cNivel>=x3_nivel
			nUsado:=nUsado+1
			Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		Endif
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	dbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VO7")
ADHeadRec("VO7",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

dbSelectArea("VO7")
dbSetOrder(1)
dbSeek( xFilial() + FG_MARSRV(M->VO6_CODMAR,M->VO6_CODSER)+M->VO6_CODSER )

aCols:={}
While !eof() .And. VO7->VO7_FILIAL == xFilial("VO7") .And. VO7->VO7_CODMAR == M->VO6_CODMAR .And. VO7->VO7_CODSER == M->VO6_CODSER
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := VO7->(RecNo())
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VO7"
		Else
			aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
		EndIf	
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	dbSkip()
End

nLenaCols := Len(aCols)

If Len(aCols) == 0
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VO7"
		Else	
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf	
	Next
EndIf

/*
nUsado:=0
dbSelectArea("SX3")
dbSeek("VO7")
While !Eof().And.(x3_arquivo=="VO7")
	&("M->"+x3_campo) := CriaVar(x3_campo)
	dbSkip()
End

// Montagem de aCols e aHeader
FillGetDados(nOpcG,"VO7",1,xFilial("VO7")+FG_MARSRV(M->VO6_CODMAR,M->VO6_CODSER)+M->VO6_CODSER,{|| VO7->VO7_FILIAL+VO7->VO7_CODMAR+VO7->VO7_CODSER },{|| .T.},{"VO7_CODMAR","VO7_CODSER"})
// Posicao da coluna de registro
nPosRec:=GDFieldPos("REC_WT")
M->VO7_ALI_WT := "VO7"
M->VO7_REC_WT := 0

nLenaCols := Len(aCols)
nUsado    := Len(aHeader)
*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Executa a Modelo 3                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTitulo       :=STR0006
cAliasEnchoice:="VO6"
cAliasGetD    :="VO7"
cLinOk        :="If( FS_VLTABSER() .AND. FS_VLSEGTO(),.t., .f. )"
cFieldOk      :="FG_MEMVAR()"
cTudOk		  :="OA030TUDOK()"

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 172 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior
//tamanho para resolucao 1024*768
//aSizeAut[3]:= 508 
//aSizeAut[5]:= 1016  
// Fator de reducao de 0.8
//for nCntFor := 1 to Len(aSizeAut)
//	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
//next   

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)    

DEFINE MSDIALOG oDlg1 TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
   
   oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOK,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,999,cFieldOk)
   
   oGetDados:oBrowse:bChange := {|| FG_AALTER("VO7",nLenaCols,oGetDados) }

//ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||nOpca:=1,if(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,If(FS_GRASRV(nOpc),oDlg1:End(),nOpca := 0) ),nOpca := 0)},{||nOpca := 0,oDlg1:End()},,If(wAltera .or. wInclui,{{"DBG06",{||FS_TEMPFAB()},STR0008}},NIL)) //"Inclui/Atualiza Modelos na Tabela de Servico"
ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||nOpca:=1,if(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,If(FS_GRASRV(nOpc),oDlg1:End(),nOpca := 0) ),nOpca := 0)},{||nOpca := 0, OA030RBXE(),oDlg1:End()},,aNewBot)

DbSelectArea("VO6")
&& Volta posicoes originais
sRestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRASRV บAutor  ณFabio               บ Data ณ  08/09/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava servicos                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRASRV(nOpc)
Private lMsHelpAuto := .t., lMsFinalAuto := .t.
If !FS_VALGRASRV( nOpc , .t. )
	Return( .f. )
EndIf

Begin Transaction
FS_VALGRASRV(nOpc)
End Transaction
lMsHelpAuto := .f.
lMsFinalAuto := .f.
Return( .t. )

Static Function FS_VALGRASRV( nOpc , lValid )

Local nTotalFab := 0 , lMudaTmp := .f. , nTotalCon := 0 , cCodSer
Local lRet := .t. , i := 0 , aVetValid := {}
Local lExiste := .f.
Local cRet := ""
Private lMsHelpAuto := .F.

Default lValid := .f.

If !lValid
	lMsHelpAuto := .T.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Grava ou Deleta                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If nOpc # 2
	
	&& Grava Arquivo Pai
	DbSelectArea("VO6")
	If nOpc == 3 .or. nOpc == 4
		
		If !lValid
			
			If !RecLock("VO6",If(nOpc == 3,.T.,.F.))
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			FG_GRAVAR("VO6")
			VO6->VO6_AGRSER := [N]
			                                      
			aMemos := {{"VO6_DESMEM","VO6_DESDET"}}
			cVar := aMemos[1][2]
			MSMM(,TamSx3("VO6_DESDET")[1],,&cVar,1,,,"VO6","VO6_DESMEM")
			
			ConfirmSx8()
			MsUnlock()
			
		EndIf
		
	EndIf
	
	&& Grava/Exclui arquivo filho
	For i:=1 to len(aCols)
	
        If i > nLenaCols .and. aCols[i,Len(aCols[i])]
           Loop
        EndIf
		
		If !Empty(aCols[I,FG_POSVAR("VO7_MODVEI")]+aCols[I,FG_POSVAR("VO7_SEGMOD")])
			DbSelectArea("VO7")
			DbSetOrder(1)
			DbSeek(xFilial()+M->VO6_CODMAR+M->VO6_CODSER+aCols[I,FG_POSVAR("VO7_MODVEI")]+aCols[I,FG_POSVAR("VO7_SEGMOD")])
			
			If (nOpc == 3 .or. nOpc == 4) .And. !(aCols[I,len(aCols[i])])
				
				If !lValid
					
                   If VO7->VO7_TEMFAB # aCols[I,FG_POSVAR("VO7_TEMFAB")] .Or. VO7->VO7_TEMCON # aCols[I,FG_POSVAR("VO7_TEMCON")]
                      lMudaTmp := .t.
                   EndIf
					
					If !RecLock("VO7", !Found() )
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
					
					FG_GRAVAR("VO7",aCols,aHeader,i)
					VO7->VO7_FILIAL := xFilial("VO7")
					VO7->VO7_CODMAR := M->VO6_CODMAR
					VO7->VO7_CODSER := M->VO6_CODSER
					MsUnlock()
					
					&& Atualiza tempos do servico agrupado
					
					If lMudaTmp
						
						DbSelectArea("VO8")
						DbSetOrder(2)
						DbSeek( xFilial("VO8") + M->VO6_CODMAR + aCols[I,FG_POSVAR("VO7_MODVEI")] )
						
						cCodSer := VO8->VO8_CODSER
						
						Do While !Eof() .And. VO8->VO8_FILIAL == xFilial("VO8") .And. VO8->VO8_CODMAR == M->VO6_CODMAR .And. VO8->VO8_MODVEI == aCols[I,FG_POSVAR("VO7_MODVEI")]
							
							DbSelectArea("VO7")
							DbSetOrder(1)
							DbSeek( xFilial() + M->VO6_CODMAR + VO8->VO8_CODSRV + aCols[I,FG_POSVAR("VO7_MODVEI")] + aCols[I,FG_POSVAR("VO7_SEGMOD")] )
							
							nTotalFab := nTotalFab + VO7->VO7_TEMFAB
							nTotalCon := nTotalCon + VO7->VO7_TEMCON
							
							DbSelectArea("VO8")
							DbSkip()
							
							If VO8->VO8_CODSER # cCodSer
								
								DbSkip(-1)
								
								DbSelectArea("VO6")
								DbSetOrder(2)
								
								If DbSeek( xFilial("VO6") + FG_MARSRV(M->VO6_CODMAR, VO8->VO8_CODSER)+VO8->VO8_CODSER )
									
									RecLock("VO6" , .F. )
									VO6->VO6_TEMFAB := nTotalFab
									VO6->VO6_TEMCON := nTotalCon
									MsUnLock()
									
								EndIf
								
								nTotalFab := 0
								nTotalCon := 0
								cCodSer   := VO8->VO8_CODSER
								
								DbSelectArea("VO8")
								DbSkip()
								
							EndIf
							
						EndDo
						
					EndIf
					
					lMudaTmp := .f.
					
				EndIf
				
			ElseIf Found()
				
				If lValid
					
					aVetValid := {}
					Aadd(aVetValid,{"VO8" , "VO8_CODMAR+VO8_MODVEI+VO8_CODSRV" , M->VO6_CODMAR+aCols[I,FG_POSVAR("VO7_MODVEI")]+M->VO6_CODSER  , NIL })
					
					If !FG_DELETA(aVetValid)
						Return( .f. )
					EndIf
					
				Else
					
					If !RecLock("VO7",.F.,.T.)
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
					
					dbdelete()
					MsUnlock()
					WriteSx2("VO7")
					
				EndIf
				
			Endif
		EndIf
	Next
	
	&& Exclui arquivo pai
	DbSelectArea("VO6")
	
	If nOpc # 3 .And. nOpc # 4
		
		If lValid
			
			aVetValid := {}
			If Empty(VO6->VO6_CODMAR)
				Aadd(aVetValid,{"VFB" , "VFB_CODSER" , VO6->VO6_CODSER  , NIL })
				Aadd(aVetValid,{"VS4" , "VS4_CODSER" , VO6->VO6_CODSER  , NIL })
				Aadd(aVetValid,{"VSD" , "VSD_CODSER" , VO6->VO6_CODSER  , NIL })
				Aadd(aVetValid,{"VE3" , "VE3_CODSER" , VO6->VO6_CODSER  , NIL })
				Aadd(aVetValid,{"VO4" , 4 , VO6->VO6_CODSER  , NIL })
			EndIf
			Aadd(aVetValid,{"VSC" , "VSC_CODMAR+VSC_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VFA" , "VFA_CODMAR+VFA_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VG5" , "VG5_CODMAR+VG5_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VG6" , "VG6_CODMAR+VG6_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VG8" , "VG8_CODMAR+VG8_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			Aadd(aVetValid,{"VOC" , "VOC_CODMAR+VOC_CODSER" , VO6->VO6_CODMAR+VO6->VO6_CODSER  , NIL })
			If !FG_DELETA(aVetValid)
				Return( .f. )
			Else
				If !Empty(VO6->VO6_CODMAR)
					lExiste := .f.
// 				Aadd(aVetValid,{"VFB" , "VFB_CODSER" , VO6->VO6_CODSER  , NIL })
					DbSelectArea("VFB")
					DbSetOrder(1)
					DbSeek(xFilial("VFB"))
					Do While !Eof() .and. xFilial("VFB")==VFB->VFB_FILIAL .and. !lExiste
					   If VFB->VFB_CODSER == VO6->VO6_CODSER
							DbSelectArea("VV1")
							DbSetOrder(1)
							If DbSeek(xFilial("VV1")+VFB->VFB_CHAINT)
								If VV1->VV1_CODMAR == VO6->VO6_CODMAR
									lExiste := .t.
									cRet := "VFB"
								EndIf
							EndIf
							DbSelectArea("VFB")
					   EndIf
						DbSkip()
					EndDo
					If !lExiste
//						Aadd(aVetValid,{"VS4" , "VS4_CODSER" , VO6->VO6_CODSER  , NIL })
						DbSelectArea("VS4")
						DbSetOrder(1)
						DbSeek(xFilial("VS4"))
						Do While !Eof() .and. xFilial("VS4")==VS4->VS4_FILIAL .and. !lExiste
						   If VS4->VS4_CODSER == VO6->VO6_CODSER
								DbSelectArea("VS1")
								DbSetOrder(1)
								If DbSeek(xFilial("VS1")+VS4->VS4_NUMORC)
									If VS1->VS1_CODMAR == VO6->VO6_CODMAR
										lExiste := .t.
										cRet := "VS4"
									EndIf
								EndIf
								DbSelectArea("VS4")
						   EndIf
							DbSkip()
						EndDo
					EndIf
					If !lExiste
//						Aadd(aVetValid,{"VO4" , 4 , VO6->VO6_CODSER  , NIL })
						DbSelectArea("VO4")
						DbSetOrder(4)
						DbSeek(xFilial("VO4"))
						Do While !Eof() .and. xFilial("VO4")==VO4->VO4_FILIAL .and. VO4->VO4_CODSER==VO6->VO6_CODSER .and. !lExiste
							DbSelectArea("VO1")
							DbSetOrder(1)
							If DbSeek(xFilial("VO1")+VO4->VO4_NUMOSV)
								If VO1->VO1_CODMAR == VO6->VO6_CODMAR
									lExiste := .t.
									cRet := "VO1"
								EndIf
							EndIf
							DbSelectArea("VO4")
							DbSkip()
						EndDo
					EndIf
					If lExiste
						SX2->(DbSeek(cRet))
						Help("  ",1,"CANCELDEL",,cRet+"- "+OemToAnsi(X2Nome() ),4,1)
						Return( .f. )
					EndIf
				EndIf
			EndIf
			
		Else
			
			DbSelectArea("SYP")
			DbSetOrder(1)
			If DbSeek(xFilial()+VO6->VO6_DESMEM)
				If !RecLock("SYP",.f.,.t.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbDelete()
				MsUnlock()
				WriteSx2("SYP")
			EndIf
			
			DbSelectArea("VO6")
			If !RecLock("VO6",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			dbdelete()
			MsUnlock()
			WriteSx2("VO6")
			
		EndIf
		
	Endif
	
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLSEGTOบAutor  ณFabio               บ Data ณ  02/21/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o segmento do modelo foi informado               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VLSEGTO()

Local nReg := 0

FG_MEMVAR()

nReg := Ascan(aCols,{|x| x[FG_POSVAR("VO7_MODVEI")] == M->VO7_MODVEI .and. x[FG_POSVAR("VO7_SEGMOD")] == M->VO7_SEGMOD })

If ( nReg # 0 .And. nReg # n .and. !aCols[nReg,Len(aCols[nReg])] .and. !aCols[n,Len(aCols[n])] ) .Or. ( nOpcG == 3 .and. FG_Seek('VO7','M->VO6_CODMAR+M->VO6_CODSER+M->VO7_MODVEI+M->VO7_SEGMOD',1,.f.) )
	
	Help("  ",1,"EXISTCHAV")
	Return( .f. )
	
EndIf

If Len(aCols) == 1 .and. !aCols[1,Len(aCols[1])] .and. Empty(aCols[1,FG_POSVAR("VO7_MODVEI")])
	Return .T.
EndIf
If (!aCols[n,Len(aCols[1])]) .and. (Empty(aCols[n,FG_POSVAR("VO7_TEMFAB")]))
	Help( 1 ," ","OBRIGAT")
	Return .F.
EndIf

If !aCols[n,Len(aCols[n])] .And. Posicione('VE4',1,xFilial('VE4')+M->VO6_CODMAR,'VE4_SEGMOD') == '1' .And. Empty( M->VO7_SEGMOD )	
	Help( 1 ," ","SEGMODNVAL")	
	Return( .f. )
EndIf

Return( .t. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLTABSERบAutor  ณFabio               บ Data ณ  04/10/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se a Opcional ja foi cadastrado                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VLTABSER()

Local nReg    := 0   
Local ix1     := 0   
              
FG_MEMVAR()
               
For ix1 := 1 to len(aCols)

   If aCols[ix1,nUsado+1]
      loop
   EndIf                                                         
   If aCols[ix1,FG_POSVAR("VO7_MODVEI")]+aCols[ix1,FG_POSVAR("VO7_SEGMOD")] == M->VO7_MODVEI+M->VO7_SEGMOD
      nReg ++
      If nReg > 1
         Help("  ",1,"EXISTCHAV")
         Return( .f. )
      EndIf
   Else 
      Loop
   EndIf
   
Next              

Return(OA030TUDOK())

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA030TUDOKบAutor  ณRicardo Farinelli   บ Data ณ  12/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a validacao da getdados dos modelos informados       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function OA030TUDOK()
Local nwnk, nwnk2,lvalida  := .F.

If nOpcX <> 3 .and. nOpcX <> 4
	Return .T.
Endif	

For nwnk := 1 to Len(aCols)
   If !Empty(aCols[nwnk,1])
		If aCols[nwnk,Len(aCols[nwnk])]
			Loop
		Endif                                  
		For nwnk2 := 1 to (Len(aCols[nwnk])-1)
			If !Empty(aCols[nwnk,nwnk2])
				lValida := .T.
				Exit	
			Endif
		Next nwnk2
	EndIf
Next nwnk

If lValida
	Return FG_OBRIGAT()
Endif		

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณOA030LEG   ณ Autor ณ Valdir F. Silva      ณ Data ณ 02/01/02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณCria uma janela contendo a legenda da mBrowse               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณOA030LEG                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA030LEG()
Local aLegenda := { {"BR_VERDE",STR0006},{"BR_VERMELHO",STR0017}}     //Tabela de Servicos  # Tabela de Revisoes
						  
BrwLegenda(cCadastro,STR0024 ,aLegenda)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DUPSRV บAutor  ณFabio               บ Data ณ  09/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDuplica Srv para outras marcas                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_DUPSRV()

Local oFonte   := TFont():New( "System", 8, 12 )
Local nOpcA := 2
Local aRegSrv := {}
Local nCount := 0, nCount1 := 0
Local lChkDup := .f.
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private cCodMar := VO6->VO6_CODMAR
Private cCodSer := VO6->VO6_CODSER
Private cDesSer := VO6->VO6_DESSER
Private aMarcasDup := {}
Private lMarcaOK := .t.
Private lCriaReg := .t.

DbSelectArea("VO6")
For nCount := 1 to FCount()
	Aadd( aRegSrv , &(FieldName(nCount)) )
Next
        
DbSelectArea("VE1")      
DbSetOrder(1)
DbSeek(xFilial("VE1"))
Do While !Eof() .And. VE1->VE1_FILIAL == xFilial("VE1")
   if ( ExistBlock("OF030MAR") )
      lMarcaOK := ExecBlock("OF030MAR",.f.,.f.)
   Endif

   If VE1->VE1_CODMAR # VO6->VO6_CODMAR .and. lMarcaOK
		Aadd( aMarcasDup, { .f., VE1->VE1_CODMAR, VE1->VE1_DESMAR })           
   EndIf	
                                                      
	DbSelectArea("VE1")     
	DbSkip() 

EndDo      

If Len(aMarcasDup) # 0
      
	&& Define a tela
	DEFINE MSDIALOG oDlgDup TITLE STR0018 From 9,0 to 26,64	of oMainWnd    //Duplica servico
	
	@ 001,001 SCROLLBOX oDupScroll VERTICAL SIZE 55,217 OF oDlgDup BORDER PIXEL
	
	@ 001,003 SAY STR0019 Font oFonte OF oDupScroll PIXEL COLOR CLR_BLUE    //Marca
	@ 008,003 MSGET oCodMar VAR cCodMar PICTURE "@!" SIZE 30,4 OF oDupScroll PIXEL COLOR CLR_BLUE when .f.
	@ 018,003 SAY STR0020 Font oFonte OF oDupScroll PIXEL COLOR CLR_BLUE  //Cod Servico
	@ 025,003 MSGET oCodSer VAR cCodSer PICTURE "@!" SIZE 80,4 OF oDupScroll PIXEL COLOR CLR_BLUE when .f.
	@ 035,003 SAY STR0021 Font oFonte OF oDupScroll PIXEL COLOR CLR_BLUE   //Descricao
	@ 042,003 MSGET oDesSer VAR cDesSer PICTURE "@!" SIZE 100,4 OF oDupScroll PIXEL COLOR CLR_BLUE when .f.
	
	DEFINE SBUTTON oBtOk     FROM 005,221 TYPE 1 ACTION (nOpcA:=1,oDlgDup:End()) ENABLE OF oDlgDup
	DEFINE SBUTTON oBtCancel FROM 020,221 TYPE 2 ACTION (nOpcA:=2,oDlgDup:End()) ENABLE OF oDlgDup
	
	@ 57,001 LISTBOX oLbMarcas FIELDS HEADER  OemToAnsi(""),; 
	                                           OemToAnsi(STR0019),;    //Marca
	                                           OemToAnsi(STR0021); //Descricao
	   COLSIZES 10,30,60;
	   SIZE 252,064 OF oDlgDup ON DBLCLICK (aMarcasDup[oLbMarcas:nAt,1] := !aMarcasDup[oLbMarcas:nAt,1] ) PIXEL
	
	oLbMarcas:SetArray(aMarcasDup)
	oLbMarcas:bLine := { || { If(aMarcasDup[oLbMarcas:nAt,1],oOk,oNo) ,;
	                            aMarcasDup[oLbMarcas:nAt,2] ,;
	                            aMarcasDup[oLbMarcas:nAt,3] }}
	                 
   @ 121, 002 CHECKBOX oChkDup VAR lChkDup PROMPT STR0022 ; //Marca/Desmaca todos
                               OF oDlgDup ;
                               ON CLICK ( FS_TIKDUP( lChkDup ) , oLbMarcas:SetFocus() , oLbMarcas:Refresh() ) ;
                               SIZE 100,10 PIXEL 
	
	ACTIVATE MSDIALOG oDlgDup                            

	If nOpcA == 1
   
		Begin Transaction
		               
			For nCount := 1 to Len(aMarcasDup)
                                        
				If aMarcasDup[nCount,1]
					
					DbSelectArea("VO6")
					DbSetOrder(2)
					DbSeek( xFilial("VO6") + FG_MARSRV( aMarcasDup[nCount,2], cCodSer )+cCodSer )
					If Empty(VO6->VO6_CODMAR)
						lCriaReg := .t.
					Else
						lCriaReg := !Found()
					EndIf
					RecLock("VO6",lCriaReg)
						For nCount1 := 1 to Len(aRegSrv)
							&( FieldName(nCount1) ) := aRegSrv[nCount1]
						Next          
						If !Found()
							VO6->VO6_SERINT := GetSxeNum("VO6","VO6_SERINT")
							ConfirmSX8()
						EndIf	
						VO6->VO6_CODMAR := aMarcasDup[nCount,2]
					MsUnLock()
				
				EndIf	
				
			Next
		
      End Transaction

	EndIf
	
EndIf

Return

Static Function FS_TIKDUP( lChkDup )

Local nCount := 0
      
For nCount := 1 to Len(aMarcasDup)
	aMarcasDup[nCount,1] := lChkDup
Next	

Return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;    	//Pesquisar
                     { STR0002 ,"AP030",    0 , 2},;    //Visualizar
                     { STR0003 ,"AP030",    0 , 3},;    //Incluir
                     { STR0004 ,"AP030",    0 , 4},; 	//Alterar
                     { STR0005 ,"AP030",    0 , 5},; 	//Excluir
                     { STR0023 ,"FS_DUPSRV",    0 , 6},;//Duplicar
                     {STR0024,"OA030LEG",0,2,0,.f.}}    //Legenda
Return aRotina

/*/{Protheus.doc} OA030RBXE

	@author       Vinicius Gati
	@since        29/01/2015
	@description  feito para evitar updates e mair complicacao de controle dos sxe de servicos

/*/
Static Function OA030RBXE()
	local nLoop := 0
	for nLoop := 10 to 0 step -1
		ROLLBACKSXE()
	next
Return .T.
