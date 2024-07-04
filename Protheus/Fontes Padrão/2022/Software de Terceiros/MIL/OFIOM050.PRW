// ษออออออออหออออออออป
// บ Versao บ 17     บ
// ศออออออออสออออออออผ
#INCLUDE "OFIOM050.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIOM050 ณ Autor ณ  Fabio                ณ Data ณ 03/04/00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Ausencias                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de concessionarias (SIGAOFI)                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑaฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM050

Local aCores := {{ 'VAI->VAI_FUNPRO == "1"','BR_VERDE' },;  //Produtivo
{ 'VAI->VAI_FUNPRO # "1"' ,'BR_VERMELHO'}} //Nao Produtivo

PRIVATE aRotina := MenuDef()
Private nOpcP

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE cCadastro := STR0006 //"Ausencia"

DbSelectArea("VAI")
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"VAI",,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIM050     บAutor  ณFabio               บ Data ณ  09/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela de ausencia                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IM050(cAlias,nReg,nOpc)

//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
////////////////////////////////////////////////////////////////////////////////////////////

Local bCampo   := { |nCPO| Field(nCPO) }
Local nUsado := 0 , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local nPosRec  :=0  // Posicao do registro dentro do aCols
Private nVO4_DATINI := 1
Private nVO4_HORINI := Iif(nOpc <> 7, 2, 3)
Private nVO4_DATFIN := Iif(nOpc <> 7, 3, 2)
Private nVO4_HORFIN := 4
Private nVO4_TIPAUS := 5

If VAI->VAI_FUNPRO # "1" .Or. VAI->(RecCount()) == 0
	Help("  ",1,"APEFUNPRO")
	Return .t.
EndIf

Private aCpoEnchoice  :={}
Private aCols := {}
Private aHeader:={}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VAI",.T.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAI")
While !Eof().and.(x3_arquivo=="VAI")
	
	If X3USO(x3_usado) .and. cNivel>=x3_nivel .And. (Alltrim(x3_campo) $ "VAI_CODTEC/VAI_NOMTEC/VAI_FUNCAO" )
		AADD(aCpoEnchoice,x3_campo)
		&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
	Endif
	
	dbSkip()
End

DbSelectArea("VAI")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

nOpcP := nOpc
If nOpc == 3 .Or. nOpc == 7
	nOpcE   := 2
	nOpcG   := 3
Elseif nOpc == 4
	nOpcE  := 2
	nOpcG := 4
Else
	nOpcE  := 2
	nOpcG := 2
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nUsado:=0
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VO4")
aHeader:={}

While !Eof().And.(x3_arquivo=="VO4")
	
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. (Alltrim(x3_campo) $ "VO4_DATINI/VO4_HORINI/VO4_DATFIN/VO4_HORFIN/VO4_TIPAUS")

		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv, &("n" + x3_campo) } )
		
		&("M->"+x3_campo) := CriaVar(x3_campo)
		
	Endif
	
	dbSkip()
	
End

// Ordena็ใo conforme posi็ใo 13
aSort(aHeader, 1,, {|x,y| x[13] < y[13]})

// Necessแrio limpar a posi็ใo 13 no padrใo do aHeader
aEval(aHeader, {|x| x[13] := nil})

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VO4")
ADHeadRec("VO4",aHeader)

// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta o aCols                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == 3 .Or. nOpc == 7
	// Incluir ou Inclusใo por Intervalo
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	
	For _ni:=1 to nUsado
		
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VO4"
		Else
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
		
	Next
	
Else
	
	DbSelectArea("VO4")
	DbSetOrder(2)
	DbSeek(xFilial("VO4")+VAI->VAI_CODTEC )
	
	Do While !Eof() .And.VO4->VO4_CODPRO == VAI->VAI_CODTEC .And. VO4->VO4_FILIAL == xFilial("VO4")
		
		If !Empty(VO4->VO4_TIPAUS)
			
			AADD(aCols,Array(nUsado+1))
			
			For _ni:=1 to nUsado
				
				// verifica se e a coluna de controle do walk-thru
				If IsHeadRec(aHeader[_ni,2])
					aCols[Len(aCols),_ni] := VO4->(RecNo())
				ElseIf IsHeadAlias(aHeader[_ni,2])
					aCols[Len(aCols),_ni] := "VO4"
				Else
					aCols[Len(aCols),_ni]:= If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
				EndIf
				
			Next
			
			aCols[Len(aCols),nUsado+1]:=.F.
			
		EndIf
		
		DbSkip()
		
	EndDo
	
EndIf

If Len(aCols)>0
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa a Modelo 3                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTitulo       :=STR0006
	cAliasEnchoice:="VAI"
	cAliasGetD    :="VO4"
	cLinOk        :="FS_VALIDIM050(.t.)"
	cTudOk        :="FS_VERAUS()"
	cFieldOk      :="FS_VALIDIM050()"
	
	// So para remover o WARNING de compilacao
	If cTudOk <> "FS_VERAUS"
		FS_VERAUS()
	EndIf
	//
	
	DbSelectArea("VAI")
	
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05 , 50 , .T. , .F. } )  //Cabecalho
	AAdd( aObjects, { 01 , 10 , .T. , .T. } )  //list box superior
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)
	//
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
	
	oEnchVAI := MSMGet():New(cAliasEnchoice, nReg,  2 /* Visualizar */ ,;
	/* aCRA */, /* cLetra*/, /* cTexto */, aCpoEnchoice, {aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]} , aCpoEnchoice, 3 /* nModelo */,;
	/* nColMens */, /* cMensagem */, "AllwaysTrue()", oDlg , .F. /* lF3 */, .t. /* lMemoria */ , .F. /* lColumn */ ,;
	"" /* caTela */ , .f. /* lNoFolder */, .f. /* lProperty */)
	
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"",If(nOpc==4.Or.(nOpcG > 2 .and. nOpcg < 5),.t.,.f.),,,,,cFieldOk)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(oGetDados:TudoOk() .And. FS_OM050GRA(nOpc,.t.), oDlg:End(),.f.) },{|| FS_OM050GRA(nOpc,.f.),oDlg:End() })
	
Else
	MsgInfo(STR0012,STR0014)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_OM050GRบAutor  ณFabio               บ Data ณ  09/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Ausencia                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_OM050GRA(nOpc,_lRet)
Local lRet := .t. , _ni := 0 , nQb := 0
Local  aQuebraPeriodo := {}
Local lAchou := .t.
Local nColRecno := 0
Local niDias := 0, ntDias := 0
Local dDia

If _lRet .and. (nOpc == 3 .Or. nOpc == 7)
	For _ni := 1 to Len(aCols)
		If !aCols[_ni,Len(aCols[_ni])] .and. Empty(aCols[_ni,FG_POSVAR("VO4_TIPAUS")])
			MsgInfo(STR0013,STR0014)
			Return .f.
		Endif
	Next _ni
Endif

// Se for alteracao ou exclusao, descobre o numero da coluna do RECNO
If nOpc == 4 .or. nOpc == 5
	For _ni := 1 to Len(aHeader)
		If IsHeadRec(aHeader[_ni,2])
			nColRecno := _ni
		EndIf
	Next _ni
EndIf
//

// Escalas
DbSelectArea("VOE")
DbSetOrder(1)
DbSeek(xFilial("VOE") + M->VAI_CODTEC)

// Horแrios de Trabalho
DbSelectArea("VOH")
DbSetOrder(1)
DbSeek(xFilial("VOH") + VOE->VOE_CODPER)

// Requisi็ใo de Servi็os
DbSelectArea("VO4")
DbSetOrder(2)

Begin Transaction
For _ni := 1 to Len(aCols)
	DbSeek( xFilial("VO4")+M->VAI_CODTEC+Dtos( aCols[_ni,FG_POSVAR("VO4_DATINI")] ) )
	If _lRet
		// Inclusao
		If nOpc == 3 .And. !aCols[_ni,Len(aCols[_ni])]
			aQuebraPeriodo := FG_TEMPTRA(M->VAI_CODTEC,aCols[_ni,FG_POSVAR("VO4_DATINI")],aCols[_ni,FG_POSVAR("VO4_HORINI")],aCols[_ni,FG_POSVAR("VO4_DATFIN")],aCols[_ni,FG_POSVAR("VO4_HORFIN")],"A",.f.,"D")
			lAchoTAb := .f.
			While !eof() .and. M->VAI_CODTEC+Dtos( aCols[_ni,FG_POSVAR("VO4_DATINI")] ) = VO4->VO4_CODPRO+Dtos(VO4->VO4_DATINI)
				If M->VO4_HORINI > VO4->VO4_HORINI
					If Empty(VO4->VO4_DATFIN) .and. !Empty(VO4->VO4_DATINI)
						lAchoTAb := .t.
						Exit
					EndIf
				Endif
				DbSelectArea("VO4")
				DbSkip()
			Enddo
			If lAchoTAb = .f.
				For nQb := 1 to Len(aQuebraPeriodo)
					IF VOH->VOH_INICF1 <> aQuebraPeriodo[nQb,2]
						RecLock("VO4",!Found())
						VO4->VO4_FILIAL := xFilial("VO4")
						VO4->VO4_NOSNUM := "99999999"
						VO4->VO4_SEQUEN := "99999999"
						VO4->VO4_CODPRO := VAI->VAI_CODTEC
						VO4->VO4_DATINI := aQuebraPeriodo[nQb,1]
						VO4->VO4_HORINI := aQuebraPeriodo[nQb,2]
						VO4->VO4_DATFIN := aQuebraPeriodo[nQb,3]
						VO4->VO4_HORFIN := aQuebraPeriodo[nQb,4]
						VO4->VO4_TEMAUS := aQuebraPeriodo[nQb,6]
						VO4->VO4_TIPAUS := aCols[_ni,FG_POSVAR("VO4_TIPAUS")]
						VO4->VO4_HOREXT := "A"
						MsUnLock()
					Endif
				Next
				
			Else
				MsgInfo(STR0015,STR0014)
				lRet := .f.
			Endif
			
			// Alteracao
		Elseif nOpc == 4 .And. !aCols[_ni,Len(aCols[_ni])]
			aQuebraPeriodo := FG_TEMPTRA(M->VAI_CODTEC,aCols[_ni,FG_POSVAR("VO4_DATINI")],aCols[_ni,FG_POSVAR("VO4_HORINI")],aCols[_ni,FG_POSVAR("VO4_DATFIN")],aCols[_ni,FG_POSVAR("VO4_HORFIN")],"A",.f.,"A")
			For nQb := 1 to Len(aQuebraPeriodo)
				IF VOH->VOH_INICF1 <> aQuebraPeriodo[nQb,2]
					dbSelectArea("VO4")
					dbSetOrder(2)
					if DbSeek( xFilial("VO4")+M->VAI_CODTEC+Dtos( aCols[_ni,FG_POSVAR("VO4_DATINI")] )+ alltrim(STR(aCols[_ni,FG_POSVAR("VO4_HORINI")])))
						RecLock("VO4",!Found())
						VO4->VO4_FILIAL := xFilial("VO4")
						VO4->VO4_NOSNUM := "99999999"
						VO4->VO4_SEQUEN := "99999999"
						VO4->VO4_CODPRO := VAI->VAI_CODTEC
						VO4->VO4_DATINI := aQuebraPeriodo[nQb,1]
						VO4->VO4_HORINI := aQuebraPeriodo[nQb,2]
						VO4->VO4_DATFIN := aQuebraPeriodo[nQb,3]
						VO4->VO4_HORFIN := aQuebraPeriodo[nQb,4]
						VO4->VO4_TEMAUS := aQuebraPeriodo[nQb,6]
						VO4->VO4_TIPAUS := aCols[_ni,FG_POSVAR("VO4_TIPAUS")]
						VO4->VO4_HOREXT := "A"
						MsUnLock()
					Endif
				Endif
			Next
			
			// Exclusao
		ElseIf (aCols[_ni,Len(aCols[_ni])] .Or. nOpc == 5) .and. nColRecno > 0
			// Deleta Servico
			VO4->(dbGoTo(aCols[_ni,nColRecno]))
			RecLock("VO4",.F.,.T.)
			dbdelete()
			MsUnlock()

			// Inclusใo por Intervalo
		ElseIf nOpc == 7 .And. !aCols[_ni, Len(aCols[_ni])]
			// Diferen็a de Dias entre Data Inicial e Data Final
			ntDias := ((aCols[_ni, FG_POSVAR("VO4_DATFIN")] - aCols[_ni, FG_POSVAR("VO4_DATINI")]) + 1)

			For niDias := 1 to ntDias
				// Dia Corrente
				dDia := aCols[_ni, FG_POSVAR("VO4_DATINI")] + (niDias - 1)

				// Verifica็ใo de Escala
				aQuebraPeriodo := FG_TEMPTRA(M->VAI_CODTEC, dDia, aCols[_ni, FG_POSVAR("VO4_HORINI")], dDia, aCols[_ni, FG_POSVAR("VO4_HORFIN")], "A", .f., "D")
				lAchoTAb := .f.

				While !eof() .And. M->VAI_CODTEC + Dtos(dDia) = VO4->VO4_CODPRO + Dtos(VO4->VO4_DATINI)
					If M->VO4_HORINI > VO4->VO4_HORINI
						If Empty(VO4->VO4_DATFIN) .And. !Empty(VO4->VO4_DATINI)
							lAchoTAb := .t.
							Exit
						EndIf
					EndIf

					DbSelectArea("VO4")
					DbSkip()
				EndDo

				If lAchoTAb = .f.
					For nQb := 1 to Len(aQuebraPeriodo)
						If VOH->VOH_INICF1 <> aQuebraPeriodo[nQb, 2]
							// Grava็ใo
							RecLock("VO4",!Found())

							VO4->VO4_FILIAL := xFilial("VO4")
							VO4->VO4_NOSNUM := "99999999"
							VO4->VO4_SEQUEN := "99999999"
							VO4->VO4_CODPRO := VAI->VAI_CODTEC
							VO4->VO4_DATINI := aQuebraPeriodo[nQb, 1]
							VO4->VO4_HORINI := aQuebraPeriodo[nQb, 2]
							VO4->VO4_DATFIN := aQuebraPeriodo[nQb, 3]
							VO4->VO4_HORFIN := aQuebraPeriodo[nQb, 4]
							VO4->VO4_TEMAUS := aQuebraPeriodo[nQb, 6]
							VO4->VO4_TIPAUS := aCols[_ni, FG_POSVAR("VO4_TIPAUS")]
							VO4->VO4_HOREXT := "A"

							MsUnLock()
						EndIf
					Next
				EndIf
			Next
		EndIf
	EndIf
Next
End Transaction

If !lRet .and. lAchou
	MostraErro()
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALIDIMบAutor  ณFabio               บ Data ณ  04/11/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALIDIM050(lLinOk)
Local nProCols := 0
Local dDIniHIni, dDIniHFim, dDFimHIni, dDFimHFim

If lLinOk == NIL .Or. !lLinOk
	FG_MEMVAR()
	For nProCols:=1 to Len(aCols)
		If Type("nOpcP") != "U"
			if nOpcP == 4
				return .f.
			endif
		endif

		If nOpcP == 7
			// Inclusใo por Intervalo
			dDIniHIni := Dtos(aCols[nProCols, FG_POSVAR("VO4_DATINI")]) + StrZero(aCols[nProCols, FG_POSVAR("VO4_HORINI")], 4)
			dDIniHFim := Dtos(aCols[nProCols, FG_POSVAR("VO4_DATINI")]) + StrZero(aCols[nProCols, FG_POSVAR("VO4_HORFIN")], 4)
			dDFimHIni := Dtos(aCols[nProCols, FG_POSVAR("VO4_DATFIN")]) + StrZero(aCols[nProCols, FG_POSVAR("VO4_HORINI")], 4)
			dDFimHFim := Dtos(aCols[nProCols, FG_POSVAR("VO4_DATFIN")]) + StrZero(aCols[nProCols, FG_POSVAR("VO4_HORFIN")], 4)

			If nProCols#n .And. !aCols[nProCols, Len(aCols[nProCols])] ;
				.And. ((!Empty(aCols[nProCols, FG_POSVAR("VO4_DATINI")]) .And. dDIniHIni > Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORINI, 4) .And. dDIniHIni < Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORFIN, 4))  ; // Data / Hora Inํcio entre valores jแ informados
				.Or.   (!Empty(aCols[nProCols, FG_POSVAR("VO4_DATINI")]) .And. dDIniHFim > Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORINI, 4) .And. dDIniHFim < Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORFIN, 4))  ;
				.Or.   (!Empty(aCols[nProCols, FG_POSVAR("VO4_DATFIN")]) .And. dDFimHIni > Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORINI, 4) .And. dDFimHIni < Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORFIN, 4))  ; // Data / Hora Fim entre valores jแ informados
				.Or.   (!Empty(aCols[nProCols, FG_POSVAR("VO4_DATFIN")]) .And. dDFimHFim > Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORINI, 4) .And. dDFimHFim < Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORFIN, 4))  ;
				.Or.   (!Empty(aCols[nProCols, FG_POSVAR("VO4_DATINI")]) .And. dDIniHIni < Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORINI, 4) .And. dDIniHFim > Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORINI, 4))  ; // Data Inํcio / Hora Inํcio antes e Data Inํcio / Hora Fim ap๓s เ algum valor Inicial jแ informado
				.Or.   (!Empty(aCols[nProCols, FG_POSVAR("VO4_DATINI")]) .And. dDIniHIni < Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORFIN, 4) .And. dDIniHFim > Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORFIN, 4))  ; // Data Inํcio / Hora Inํcio antes e Data Inํcio / Hora Fim ap๓s เ algum valor Final jแ informado
				.Or.   (!Empty(aCols[nProCols, FG_POSVAR("VO4_DATFIN")]) .And. dDFimHIni < Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORINI, 4) .And. dDFimHFim > Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORINI, 4))  ; // Data Fim / Hora Inํcio antes e Data Fim / Hora Fim ap๓s เ algum valor Inicial jแ informado
				.Or.   (!Empty(aCols[nProCols, FG_POSVAR("VO4_DATFIN")]) .And. dDFimHIni < Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORFIN, 4) .And. dDFimHFim > Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORFIN, 4))  ; // Data Fim / Hora Inํcio antes e Data Fim / Hora Fim ap๓s เ algum valor Final jแ informado
				.Or.   (!Empty(aCols[nProCols, FG_POSVAR("VO4_DATINI")]) .And. dDIniHIni == Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORINI, 4) .And. dDIniHFim == Dtos(M->VO4_DATINI) + StrZero(M->VO4_HORFIN, 4)); // Data / Hora Inํcio igual เ algum valor jแ informado
				.Or.   (!Empty(aCols[nProCols, FG_POSVAR("VO4_DATFIN")]) .And. dDFimHIni == Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORINI, 4) .And. dDFimHFim == Dtos(M->VO4_DATFIN) + StrZero(M->VO4_HORFIN, 4))) // Data / Hora Fim igual เ algum valor jแ informado

				Help("  ", 1, "DATNAUSENC",, Dtoc(aCols[nProCols, FG_POSVAR("VO4_DATINI")]) + "  " + Transform(aCols[nProCols, FG_POSVAR("VO4_HORINI")], "@R 99:99") + "  -  " + Dtoc(aCols[nProCols,FG_POSVAR("VO4_DATINI")]) + "  " + Transform(aCols[nProCols, FG_POSVAR("VO4_HORFIN")], "@R 99:99");
					+ CHR(13) + CHR(10) + " "+  Dtoc(aCols[nProCols, FG_POSVAR("VO4_DATFIN")]) + "  " + Transform(aCols[nProCols, FG_POSVAR("VO4_HORINI")], "@R 99:99") + "  -  " + Dtoc(aCols[nProCols,FG_POSVAR("VO4_DATFIN")]) + "  " + Transform(aCols[nProCols, FG_POSVAR("VO4_HORFIN")], "@R 99:99"), 5, 1)

				Return .f.
			EndIf
		Else
			// Demais Op็๕es
			If nProCols#n .And. !aCols[ nProCols , Len(aCols[nProCols]) ]  .And. ( ( !Empty( aCols[nProCols,FG_POSVAR("VO4_DATINI")] ) .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATINI")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORINI")] , 4 ) > Dtos(M->VO4_DATINI)+ StrZero( M->VO4_HORINI , 4 ) .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATINI")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORINI")] , 4 ) < Dtos(M->VO4_DATFIN)+ StrZero( M->VO4_HORFIN , 4 ) ) ;
				.Or. ( !Empty( aCols[nProCols,FG_POSVAR("VO4_DATFIN")] )   .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATFIN")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORFIN")] , 4 ) > Dtos(M->VO4_DATINI)+ StrZero( M->VO4_HORINI , 4 ) .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATFIN")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORFIN")] , 4 ) < Dtos(M->VO4_DATFIN)+ StrZero( M->VO4_HORFIN , 4 ) ) ;
				.Or. ( !Empty( aCols[nProCols,FG_POSVAR("VO4_DATINI")] )   .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATINI")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORINI")] , 4 ) < Dtos(M->VO4_DATINI)+ StrZero( M->VO4_HORINI , 4 ) .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATFIN")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORFIN")] , 4 ) > Dtos(M->VO4_DATINI)+ StrZero( M->VO4_HORINI , 4 ) ) ;
				.Or. ( !Empty( aCols[nProCols,FG_POSVAR("VO4_DATFIN")] )   .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATINI")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORINI")] , 4 ) < Dtos(M->VO4_DATFIN)+ StrZero( M->VO4_HORFIN , 4 ) .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATFIN")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORFIN")] , 4 ) > Dtos(M->VO4_DATFIN)+ StrZero( M->VO4_HORFIN , 4 ) ) ;
				.Or. ( !Empty( aCols[nProCols,FG_POSVAR("VO4_DATINI")] )   .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATINI")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORINI")] , 4 ) == Dtos(M->VO4_DATINI)+ StrZero( M->VO4_HORINI , 4 ) .And. Dtos( aCols[nProCols,FG_POSVAR("VO4_DATFIN")] )+ StrZero( aCols[nProCols,FG_POSVAR("VO4_HORFIN")] , 4 ) == Dtos(M->VO4_DATFIN)+ StrZero( M->VO4_HORFIN , 4 ) ) )
				
				Help("  ",1,"DATNAUSENC",,Dtoc(aCols[nProCols,FG_POSVAR("VO4_DATINI")])+"  "+Transform(aCols[nProCols,FG_POSVAR("VO4_HORINI")],"@R 99:99")+"  -  "+Dtoc(aCols[nProCols,FG_POSVAR("VO4_DATFIN")])+"  "+Transform(aCols[nProCols,FG_POSVAR("VO4_HORFIN")],"@R 99:99") ,5,1)
				Return(.f.)
			EndIf
		EndIf
	Next
	
	If ReadVar() $ "M->VO4_DATINI/M->VO4_DATFIN"
		If (!Empty(aCols[n,FG_POSVAR("VO4_DATINI")]).And.aCols[n,FG_POSVAR("VO4_DATINI")]#M->VO4_DATINI);
			.Or.(!Empty(aCols[n,FG_POSVAR("VO4_DATFIN")]).And.aCols[n,FG_POSVAR("VO4_DATFIN")]#M->VO4_DATFIN)
			
			Return(FG_TEMPTRA(M->VAI_CODTEC,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN,M->VO4_HORFIN))
		EndIf
	EndIf
	
	If ReadVar() $ "M->VO4_HORINI/M->VO4_HORFIN"
		Return(FG_TEMPTRA(M->VAI_CODTEC,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN,M->VO4_HORFIN))
	EndIf

	If !OM0500012_VerificaEscala(M->VAI_CODTEC, M->VO4_DATINI)
		Return .f.
	Endif

Else
	Return( FG_OBRIGAT() )
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IM050VALIDบAutor  ณFabio               บ Data ณ  04/11/00   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_IM050VALID()

If Dtos(M->VO4_DATFIN)+Str(M->VO4_HORFIN) > Dtos(dDataBase)+Str(M->VO4_HORFIN)
	Help("  ",1,"DTFUTINVAL")
	Return(.f.)
EndIf

Return(FG_TEMPTRA(M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN,M->VO4_HORFIN))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFS_OM50VL ณAutor  ณFabio               ณ Data ณ  17/12/2001 บฑฑ
ฑฑฬออออออออออุออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOfIOM050                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_OM50VL(nOpcao)

Local lRet := .T.

Default nOpcao := 2

If Type("nOpcP") != "U"
	nOpcao := nOpcP
endif

If Dtos(M->VO4_DATFIN)+StrZero(M->VO4_HORFIN,4) < Dtos(M->VO4_DATINI)+StrZero(M->VO4_HORINI,4)
	MsgStop(STR0009) // Data e hora final menor que a data e hora inicial!
	lRet := .F.
ElseIf nOpcao == 7 .And. StrZero(M->VO4_HORFIN, 4) < StrZero(M->VO4_HORINI, 4)
	// Inclusใo por Intervalo
	MsgStop(STR0009) // Data e hora final menor que a data e hora inicial!
	lRet := .F.
EndIf

Return lRet

Static Function MenuDef()
Local aRotina := {{ STR0001, "AxPesqui", 0, 1 },; // Pesquisar
	{ STR0002, "IM050"   , 0, 2 },;				  // Visualizar
	{ STR0003, "IM050"   , 0, 3 },;				  // Incluir
	{ STR0004, "IM050"   , 0, 4 },;				  // Alterar
	{ STR0005, "IM050"   , 0, 5 },;				  // Excluir
	{ STR0010, "OM040LEG", 0, 2, 0, .f. },;		  // Legenda
	{ STR0016, "IM050"   , 0, 7 }}				  // Aus๊ncia por Intervalo
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VERAUS บAutor  ณManoel              บ Data ณ  18/02/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se foi digitado o campo Tipo de Ausencia           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VERAUS()

Local ii

for ii := 1 to Len(acols)
	If Empty(aCols[ii,FG_POSVAR("VO4_DATINI")])
		MsgStop(STR0011)  //E' necessario informar o Tipo de Ausencia
		Return .f.
	Endif
Next

Return .t.

//////////////////////////////////////////////////////////////////
// Fun็ใo OM0500012_VerificaEscala() // Verifica se Produtivo tem Escala na Data
//
// Parโmetros
//   cCodPro -> C๓digo do Produtivo
//   dData   -> Data da Escala
//
Function OM0500012_VerificaEscala(cCodPro, dData )
Local cSQL    := ""
Local cSQLESC := "SQLESC"
Local lRet    := .t.
//
cSQL := "SELECT VOE_CODPRO "
cSQL +=  " FROM " + RetSQLName("VOE") + " VOE "
cSQL += " WHERE VOE.VOE_FILIAL = '" + xFilial("VOE") + "'"
cSQL +=   " AND VOE.VOE_CODPRO = '" + cCodPro + "'"
cSQL +=   " AND VOE.VOE_DATESC <= '" + dTos(dData) + "'"
cSQL +=   " AND VOE.D_E_L_E_T_ = ' '"
cSQL += " ORDER BY VOE.VOE_DATESC DESC "
//
dbUseArea(.T., "TOPCONN", TcGenQry(,, cSQL), cSQLESC, .T., .T.)
//
If (cSQLESC)->(Eof())
	Help(" ",1,"PROESCALA")
	lRet := .f.
Endif
//
(cSQLESC)->(DbCloseArea())
//
Return lRet
