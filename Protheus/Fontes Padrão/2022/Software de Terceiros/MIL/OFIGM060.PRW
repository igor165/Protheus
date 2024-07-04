#Include "OFIGM060.ch"
#Include "protheus.ch"
#Include "Fileio.ch"
#Include "TopConn.ch"
#include "ofixdef.ch"

Static FMXAjustaSX1 := FindFunction("FMX_AJSX1")
Static cGetVersao := GetVersao(.f.,.f.)
Static lDEBUG := .F.

#DEFINE _Parts_PartNumber_    1
#DEFINE _Parts_Quantity_      2
#DEFINE _Parts_ExternalRowId_ 3

#DEFINE _Labour_OperationCode_ 1
#DEFINE _Labour_NoOfHours_     2
#DEFINE _Labour_Quantity_      3
#DEFINE _Labour_Description_   4
#DEFINE _Labour_ExternalRowId_ 5

#DEFINE _LabourU_Description_     1
#DEFINE _LabourU_NoOfHours_       2
#DEFINE _LabourU_ExternalRowId_   3
#DEFINE _LabourU_CodeDescription_ 4

#DEFINE _SpecCost_Description_     1
#DEFINE _SpecCost_CostAmount_      2
#DEFINE _SpecCost_TypeSpc_         3
#DEFINE _SpecCost_ExternalRowId_   4
#DEFINE _SpecCost_CodeDescription_ 5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIGM060 ³ Autor ³  Fabio                ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao na Garantia Solicitada SC                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MODELO 3                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GARANTIA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIGM060(cCodMar,cNumOsv,nOpc)

//Local aRegs := {}

Private cIndex, cChave, cCond
PRIVATE aMemos  := {{"VG8_OBSMEM","VG8_OBSERV"}}

Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0001)   //"Garantia Solicitada SC"
Private nIndex:=0

Private cClawMeiaH  // Controla os servicos de meia hora da scanis
Private nClawAcesso // controla como sera feito o acesso ao Claw

Private lRecons := .f.

//AADD(aRegs,{STR0022,STR0022,STR0022,'MV_CH1','C',40,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{STR0024},{STR0024},{STR0024}})  // "Cod. Srvc. (Meia Hora)"
//AADD(aRegs,{STR0023,STR0023,STR0023,'MV_CH2','N',01,0,1,'C','','MV_PAR02',STR0026,'','','','',STR0027,'','','','','','','','','','','','','','','','','','','','','','','',{STR0025},{STR0025},{STR0025}}) // "Acesso ao Claw"

Pergunte("OFIGM060",.f.,,,,.f.)

cClawMeiaH  := MV_PAR01
nClawAcesso := MV_PAR02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("VG8")
DbSetOrder(1)

cCond   := 'VG8_EXPGAR=="S"' // Utilizado como condicao para editar ou nao o registro

If cCodMar # NIL .And. cNumOsv # NIL

	DbSelectArea("VG8")
	DbSetOrder(1)
	DbSeek( xFilial("VG8") + cCodMar + cNumOsv )

	GM060("VG8",RecNo(),nOpc)

Else
	SetKey(VK_F12,{ || Pergunte( "OFIGM060" ,.T.,,,,.f.) , cClawMeiaH  := MV_PAR01 , nClawAcesso := MV_PAR02 })
	mBrowse( 6, 1,22,75                     ,"VG8"   ,       ,      ,         ,"VG8_TRANSM == 'N'",           ,         ,         ,         ,        ,           ,              ,         ,         ,"VG8_EXPGAR = 'S'")
//	MBrowse ( nLin1 , nCol1 , nLin2 , nCol2 , cAlias , aFixe , cCpo , nPar08 , cFun               , nClickDef , aColors , cTopFun , cBotFun , nPar14 , bInitBloc , lNoMnuFilter , lSeeAll , lChgAll , cExprFilTop , nInterval , bTimerAction , uPar22 , uPar23 )
	SetKey(VK_F12,Nil)
EndIf

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM060     ³ Autor ³Fabio                  ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera e visualiza dados no VG8/VG6 modelo 3                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM060(cAlias,nReg,nOpc)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM060(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
////////////////////////////////////////////////////////////////////////////////////////////
Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0 , nUsado := 0 , nUsadoAd := 0, _ni := 0 , oDlg

Private cCpoAPeca      := "VG6_GRUITE/VG6_CODITE/VG6_DESITE/VG6_PECINT/VG6_QTDITE/VG6_VALITE"
Private cCpoASrv       := "VG6_QTDITE/VG6_CODSER/VG6_DESSER/VG6_SERINT/VG6_TPOGAR"
Private aColsNormal    := {} , aHeaderNormal    := {} , aAlterN  := {}
Private aColsAdicional := {} , aHeaderAdicional := {} , aAlterA  := {}
Private aTELA[0][0],aGETS[0]
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private aCtrCpoEnch    := {} , oEnchoice , aCpoEnchoice := {}
Private aControleG := {}

If nIndex <= 0
	nIndex := 1
EndIf

DbSelectArea("VG8")
If nOpc # 3 .And. !&(cCond)
	Return
EndIf

//DbSetOrder(nIndex)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VG8",IIF(nOpc==3,.t.,.f.))
//RegToMemory("VG8",.t.)         // .t. para carregar campos virtuais

aCpoEnchoice:={}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VG8")

While !Eof().and.(x3_arquivo=="VG8")

	//		/VG8_DNRESP/VG8_IMPOSV/VG8_NUMNFI/VG8_SERIEN/VG8_TRANSM/VG8_ARQFAB/VG8_DATRET/VG8_DATTRA/VG8_DATCRE;
	If X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VG8_ESPGAR/VG8_CODREV/VG8_GRUREV;
		/VG8_DNRESP/VG8_IMPOSV/VG8_NUMNFI/VG8_SERIEN/VG8_TRANSM/VG8_ARQFAB/VG8_DATRET/VG8_DATTRA;
		/VG8_VALCRE/VG8_LANCRE/VG8_DATDEB/VG8_VALDEB/VG8_LANDEB/VG8_CODEST/VG8_DIFPGT/VG8_SITOSV/VG8_TRANSM;
		/VG8_NUMNFI/VG8_SERIEN/VG8_SITUAC/VG8_EXPGAR/VG8_PORAPC/VG8_VLRAPC/VG8_VLPVLA/VG8_VLKMCA/VG8_VLRSET;
		/VG8_TTPKST/VG8_REGACO/VG8_VLDACE/VG8_VLMOCC/VG8_VLPECC/VG8_POAPCC/VG8_VRAPCC/VG8_VPVLAC/VG8_VKMCAC;
		/VG8_VRSETC/VG8_TPKSTC/VG8_CACREC/VG8_DATDIS/VG8_CODSER/VG8_DESSER/VG8_SERINT/VG8_PECINT/VG8_DTAANT/VG8_MOTREC;
		/VG8_RRCOLD/VG8_RRCNEW/VG8_NF2REM])    // Do VG8_PORAPC ate VG8_CACREC - Boby 30/11/09 - Alteração p/MF
		Aadd(aCpoEnchoice,x3_campo)            // campos somente para garantia Massey Ferguson
	Endif

	&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)

	DbSkip()

End

If nOpc # 3

	DbSelectArea("VG8")

	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next

Endif

&& Carrega vetor de controle da enchoice
Aadd(aCtrCpoEnch,{ .t. , CriaVar("VG8_ANORRC")+CriaVar("VG8_NUMRRC"),{}})
Aadd(aCtrCpoEnch,{ .t. , VG8->VG8_ANORRC+VG8->VG8_NUMRRC            ,{}})
For nCntFor:=1 to Len(aCpoEnchoice)
	Aadd( aCtrCpoEnch[1,3] , M->&(aCpoEnchoice[nCntFor]) )
	Aadd( aCtrCpoEnch[2,3] , M->&(aCpoEnchoice[nCntFor]) )
Next

If nOpc  == 3       //INCLUIR
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
nUsadoAd:=0

DbSelectArea("SX3")
DbSeek("VG6")

aHeaderNormal    :={}
aHeaderAdicional :={}

While !Eof().And.(x3_arquivo=="VG6")

	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VG6_NUMOSV/VG6_CODMAR/VG6_DESMAR/;
		VG6_DESGRU/VG6_TRANSM/VG6_NUMNFI/VG6_SERIEN/VG6_ITEEXT/VG6_SEREXT/VG6_NF2REM])

		nUsadoAd:=nUsadoAd+1

		If Alltrim(x3_campo) != "VG6_TPCUST"
			nUsado:=nUsado+1

			Aadd(aHeaderNormal   ,{ TRIM(X3Titulo()),  SX3->X3_CAMPO  , SX3->X3_PICTURE, SX3->X3_TAMANHO, ;
			SX3->X3_DECIMAL, SX3->X3_VALID  , SX3->X3_USADO  , ;
			SX3->X3_TIPO   , SX3->X3_F3     , SX3->X3_CONTEXT, ;
			X3CBOX()       , SX3->X3_RELACAO } )
		Endif

		Aadd(aHeaderAdicional,{ TRIM(X3Titulo()),  SX3->X3_CAMPO  , SX3->X3_PICTURE, SX3->X3_TAMANHO, ;
		SX3->X3_DECIMAL, SX3->X3_VALID  , SX3->X3_USADO  , ;
		SX3->X3_TIPO   , SX3->X3_F3     , SX3->X3_CONTEXT, ;
		X3CBOX()       , SX3->X3_RELACAO } )

	Endif

	IF SX3->X3_VISUAL <> "V"
		Aadd(aAlterN,SX3->X3_CAMPO) && GetDados Normal
		Aadd(aAlterA,SX3->X3_CAMPO) && GetDados Adicional
	ENDIF

	&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)

	DbSkip()

End

Aadd(aControleG,{})  && GetDados Normal
Aadd(aControleG,{})  && GetDados Adicional

If nOpc # 3

	aColsNormal   :={}
	aColsAdicional:={}

	DbSelectArea("VG6")
	DbSetOrder(5)
	DbSeek(xFilial()+M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC)

	While !Eof() .And. VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC == M->VG8_CODMAR+;
		M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC .And. VG6->VG6_FILIAL == xFilial("VG6")

		&& Pecas e servicos normais
		If VG6->VG6_ITEEXT == "0" .Or. VG6->VG6_SEREXT == "0"
			//			.Or. Empty(VG6->VG6_ITEEXT) .And. Empty(VG6->VG6_SEREXT)

			AADD(aColsNormal,Array(nUsado+1))
			For _ni:=1 to nUsado
				aColsNormal[Len(aColsNormal),_ni] := If( aHeaderNormal[_ni,10] == "V" , Criavar(aHeaderNormal[_ni,2]), FieldGet(FieldPos(aHeaderNormal[_ni,2])))
			Next

			aColsNormal[Len(aColsNormal),nUsado+1]:=.F.

			&& Controle de registro para gravacao - Normais
			Aadd(aControleG[1], RecNo() )

		EndIf

		&& Pecas e Servicos adicionais
		If VG6->VG6_ITEEXT == "1" .or. VG6->VG6_SEREXT == "1"
			AADD(aColsAdicional,Array(nUsadoAd+1))
			For _ni:=1 to nUsadoAd
				aColsAdicional[Len(aColsAdicional),_ni] := If(aHeaderAdicional[_ni,10] == "V" ,;
				CriaVar( aHeaderAdicional[_ni,2] ), FieldGet(FieldPos(aHeaderAdicional[_ni,2])))
			Next

			aColsAdicional[Len(aColsAdicional),nUsadoAd+1]:=.F.

			&& Controle de registro para gravacao - Adicionais
			Aadd(aControleG[2], RecNo() )

		EndIf

		DbSkip()

	EndDo

Endif

//(aColsNormal)
If nOpc == 3
	aColsNormal:={Array(nUsado+1)}
	aColsNormal[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aColsNormal[1,_ni]:=CriaVar(aHeaderNormal[_ni,2])
	Next
EndIf

//(aColsAdicional)
If nOpc == 3
	aColsAdicional:={Array(nUsadoAd+1)}
	aColsAdicional[1,nUsadoAd+1]:=.F.
	For _ni:=1 to nUsadoAd
		aColsAdicional[1,_ni]:=CriaVar(aHeaderAdicional[_ni,2])
	Next
EndIf

aSort(aColsNormal   ,,,{|x,y| x[FG_POSVAR("VG6_CODSER","aHeaderNormal")]+x[FG_POSVAR("VG6_GRUITE","aHeaderNormal")]+x[FG_POSVAR("VG6_CODITE","aHeaderNormal")] < y[FG_POSVAR("VG6_CODSER","aHeaderNormal")]+y[FG_POSVAR("VG6_GRUITE","aHeaderNormal")]+y[FG_POSVAR("VG6_CODITE","aHeaderNormal")] })
aSort(aColsAdicional,,,{|x,y| x[FG_POSVAR("VG6_CODSER","aHeaderAdicional")]+x[FG_POSVAR("VG6_GRUITE","aHeaderAdicional")]+x[FG_POSVAR("VG6_CODITE","aHeaderAdicional")] < y[FG_POSVAR("VG6_CODSER","aHeaderAdicional")]+y[FG_POSVAR("VG6_GRUITE","aHeaderAdicional")]+y[FG_POSVAR("VG6_CODITE","aHeaderAdicional")] })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo          :=STR0001    //"Garantia Solicitada"
cAliasEnchoice   :="VG8"
cAliasGetD       :="VG6"
cLinOk           :="FG_OBRIGAT()"
cTudOk           :="FS_060TUDOK()"
cFieldOkNormal   :="FS_060CODINT()"
cFieldOkAdicional:="FS_060CODINT(),FS_060LIMPACPO()"
cLinOkAdicional  :="AllwaysTrue()"

If nOpc # 3

	DbSelectArea("VG8")
	DbSetOrder(1)
	DbSeek( xFilial("VG8") + M->VG8_CODMAR + M->VG8_NUMOSV + M->VG8_ANORRC + M->VG8_NUMRRC )

Endif

nOpca := 0

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 140 , .T. , .F. } )  //Cabecalho
AAdd( aObjects, {  1,  10 , .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

//           1       2     3   4 5 6       7                                          8                         9       10  11 12   13     14   15   16  17  18  19  20
oEnChoice := MsMGet():New(cAliasEnchoice,nReg,nOpcE, , , ,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},aCpoEnchoice ,3 ,  ,  ,      ,oDlg  ,.f.,.t.,.f.,"",.f.,.f.)

&& Abas do Folder
@ aPosObj[2,1],aPosObj[2,2] FOLDER oFolder SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] OF oDlg PROMPTS STR0008,STR0009  PIXEL

&& Normais                         1  2                3                       4                            5                               6                7      8       9     10  11       12            13 14         15                16           17
oGetNormal := MsNewGetDados():New(01,01,(aPosObj[2,3]-aPosObj[2,1]-14),aPosObj[2,4]-004,IIf(nOpcG==2,0,GD_INSERT+GD_UPDATE+GD_DELETE),cLinOk          ,cTudOk ,   , aAlterN ,000,999,cFieldOkNormal    ,  ,  ,oFolder:aDialogs[1],aHeaderNormal,aColsNormal)
//oGetNormal:oBrowse:bChange := {|| FG_MEMVAR(oGetNormal:aHeader,oGetNormal:aCols,oGetNormal:nAt) }
oGetNormal:oBrowse:bChange   := {|| FS_060CARREGA() }
&& Adicionais
oGetAdicional := MsNewGetDados():New(01,01,aPosObj[2,3]-aPosObj[2,1]-14,aPosObj[2,4]-004,IIf(nOpcG==2,0,GD_INSERT+GD_UPDATE+GD_DELETE),cLinOkAdicional ,cTudOk ,   , aAlterA ,000,999,cFieldOkAdicional,  ,  ,oFolder:aDialogs[2],aHeaderAdicional,aColsAdicional)
//oGetAdicional:oBrowse:bChange := {|| FG_MEMVAR(oGetAdicional:aHeader,oGetAdicional:aCols,oGetAdicional:nAt) }
oGetAdicional:oBrowse:bChange   := {|| FS_060CARREGA() }

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(OGM060011_TudoOk_PE(nOpc).and.oGetNormal:TudoOk().And.oGetAdicional:TudoOk().And.obrigatorio(aGets,aTela).And.FS_GRAMS( nOpc ),(nOpca := 1,oDlg:End()),.f.) },{|| nOpca := 2, oDlg:End() } )

DbSelectArea("VG8")
DbSetOrder(nIndex)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRAMS  ºAutor  ³Fabio               º Data ³  08/16/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Garantia                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAMS( nOpc )

Local i := 0 , lAdd := .t. , nPosReg:=0
Local nFlag := 0
Local cPosIniVE
Local ii := 0
Local nPos := 0
Local lObrg := .f. // Se igual a .t., e' sinal que existem campos obrigatorios que não foram validados na ENCHOICE
Local lPassItNor := .f. // no caso de nao haver itens normais (so' adicionais), faz a validacao do OBRIGAT da ENCHOICE no for do ADICIONAIS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2

	FS_060CARREGA()

	Begin Transaction

	&& Normal
	DbSelectArea("VG6")

	For i:=1 to len(oGetNormal:aCols)

		lAdd := .f.
		If i > Len(aControleG[1])
			lAdd := .t.
		Else
			DbGoTo( aControleG[1,i] )
		EndIf

		If ( nOpc == 3 .Or. nOpc == 4 ) .And. !oGetNormal:aCols[i,len(oGetNormal:aCols[i])] ;
			.And. ( !Empty(oGetNormal:aCols[i,FG_POSVAR("VG6_ANORRC","oGetNormal:aHeader")]) .And. !Empty(oGetNormal:aCols[i,FG_POSVAR("VG6_NUMRRC","oGetNormal:aHeader")]) )

			If (nPosReg:=Ascan(aCtrCpoEnch,{ |x| x[2] == oGetNormal:aCols[i,FG_POSVAR("VG6_ANORRC","oGetNormal:aHeader")]+oGetNormal:aCols[i,FG_POSVAR("VG6_NUMRRC","oGetNormal:aHeader")] })) # 0 ;
				.And. aCtrCpoEnch[nPosReg,1]
				oFolder:nOption   := 1
				oGetNormal:nAt := i
				n :=i

				FS_060CARREGA(,,"V")

				// Verifica campos obrigatórios da Enchoice
				for ii := 1 to len(aCtrCpoEnch)
					If Len(Alltrim(aCtrCpoEnch[ii,2])) > 4 // elemento de vetor que tem RR digitada
						cPosIniVE := ii
						ii := len(aCtrCpoEnch) + 1
					Endif
				Next
				nPos := ascan(aCpoEnchoice,"VG8_NUMRRC")
				for ii := 1 to len(aCpoEnchoice)
					If x3obrigat(aCpoEnchoice[ii])
						If Empty(aCtrCpoEnch[nPosReg,3,ii])
							msgStop(STR0011+" "+aCtrCpoEnch[nPosReg,3,nPos]+" "+STR0012) // A RR está sem Peça Causadora!
							lObrg  := .t.
							DisarmTransaction()
							Break
						Endif
					Endif
				Next
				lPassItNor := .t.
				///////////////

				DbSelectArea("VG8")
				DbSetOrder(1)
				DbSeek(xFilial("VG8")+M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC)

				RecLock("VG8", !Found() )
				FG_GRAVAR("VG8")
				VG8->VG8_FILIAL := xFilial("VG8")
				VG8->VG8_CODMAR := M->VG8_CODMAR
				VG8->VG8_NUMOSV := M->VG8_NUMOSV
				VG8->VG8_ANORRC := M->VG8_ANORRC
				VG8->VG8_NUMRRC := M->VG8_NUMRRC
				VG8->VG8_TRANSM := "N"
				VG8->VG8_EXPGAR := "S"
				MSMM(,TamSx3("VG8_OBSERV")[1],,&(aMemos[1][2]),1,,,"VG8","VG8_OBSMEM")
				MsUnlock()

				aCtrCpoEnch[nPosReg,1] := .f.

			EndIf

			DbSelectArea("VG6")
			RecLock("VG6", lAdd )
			FG_GRAVAR("VG6",oGetNormal:aCols,oGetNormal:aHeader,i)
			VG6->VG6_FILIAL := xFilial("VG6")
			VG6->VG6_CODMAR := VG8->VG8_CODMAR
			VG6->VG6_NUMOSV := VG8->VG8_NUMOSV
			VG6->VG6_TRANSM := "N"

			&& Marca Flag do Item
			VG6->VG6_ITEEXT := ""
			For nFlag:=1 To Len(cCpoAPeca) Step 11
				If !Empty(oGetNormal:aCols[i,FG_POSVAR(Substr(cCpoAPeca,nFlag,10),"oGetNormal:aHeader")])
					VG6->VG6_ITEEXT := "0"
				EndIf
			Next
			&& Marca Flag do Servico
			VG6->VG6_SEREXT := ""
			For nFlag:=1 To Len(cCpoASrv) Step 11
				If !Empty(oGetNormal:aCols[i,FG_POSVAR(Substr(cCpoASrv,nFlag,10),"oGetNormal:aHeader")])
					VG6->VG6_SEREXT := "0"
				EndIf
			Next
			MsUnlock()

		ElseIf !lAdd

			RecLock("VG6",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VG6")

		Endif

	Next

	&& Adicional
	DbSelectArea("VG6")

	For i:=1 to len(oGetAdicional:aCols)

		lAdd := .f.
		If i > Len(aControleG[2])
			lAdd := .t.
		Else
			DbGoTo( aControleG[2,i] )
		EndIf

		If ( nOpc == 3 .Or. nOpc == 4 ) .And. !oGetAdicional:aCols[i,len(oGetAdicional:aCols[i])] ;
			.And. ( !Empty(oGetAdicional:aCols[i,FG_POSVAR("VG6_ANORRC","oGetAdicional:aHeader")]) .And. !Empty(oGetAdicional:aCols[i,FG_POSVAR("VG6_NUMRRC","oGetAdicional:aHeader")]) )

			If (nPosReg:=Ascan(aCtrCpoEnch,{ |x| x[2] == oGetAdicional:aCols[i,FG_POSVAR("VG6_ANORRC","oGetAdicional:aHeader")]+oGetAdicional:aCols[i,FG_POSVAR("VG6_NUMRRC","oGetAdicional:aHeader")] })) # 0 ;
				.And. aCtrCpoEnch[nPosReg,1]
				oFolder:nOption   := 2
				oGetAdicional:nAt := i
				n :=i

				FS_060CARREGA(,,"V")


				If !lPassItNor
					// Verifica campos obrigatórios da Enchoice
					for ii := 1 to len(aCtrCpoEnch)
						If Len(Alltrim(aCtrCpoEnch[ii,2])) > 4 // elemento de vetor que tem RR digitada
							cPosIniVE := ii
							ii := len(aCtrCpoEnch) + 1
						Endif
					Next
					nPos := ascan(aCpoEnchoice,"VG8_NUMRRC")
					for ii := 1 to len(aCpoEnchoice)
						If x3obrigat(aCpoEnchoice[ii])
							If Empty(aCtrCpoEnch[nPosReg,3,ii])
								msgStop(STR0011+" "+aCtrCpoEnch[nPosReg,3,nPos]+" "+STR0012)
								lObrg  := .t.
								DisarmTransaction()
								Break
							Endif
						Endif
					Next
				Endif
				///////////////

				DbSelectArea("VG8")
				DbSetOrder(1)
				DbSeek(xFilial("VG8")+M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC)

				RecLock("VG8", !Found() )
				FG_GRAVAR("VG8")
				VG8->VG8_FILIAL := xFilial("VG8")
				VG8->VG8_CODMAR := M->VG8_CODMAR
				VG8->VG8_NUMOSV := M->VG8_NUMOSV
				VG8->VG8_ANORRC := M->VG8_ANORRC
				VG8->VG8_NUMRRC := M->VG8_NUMRRC
				VG8->VG8_TRANSM := "N"
				VG8->VG8_EXPGAR := "S"
				MSMM(,TamSx3("VG8_OBSERV")[1],,&(aMemos[1][2]),1,,,"VG8","VG8_OBSMEM")
				MsUnlock()

				aCtrCpoEnch[nPosReg,1] := .f.

			EndIf

			RecLock("VG6", lAdd )
			FG_GRAVAR("VG6",oGetAdicional:aCols,oGetAdicional:aHeader,i)
			VG6->VG6_FILIAL := xFilial("VG6")
			VG6->VG6_CODMAR := VG8->VG8_CODMAR
			VG6->VG6_NUMOSV := VG8->VG8_NUMOSV
			VG6->VG6_TRANSM := "N"

			&& Marca Flag do Item
			VG6->VG6_ITEEXT := ""
			For nFlag:=1 To Len(cCpoAPeca) Step 11
				If !Empty(oGetAdicional:aCols[i,FG_POSVAR(Substr(cCpoAPeca,nFlag,10),"oGetAdicional:aHeader")])
					VG6->VG6_ITEEXT := "1"
				EndIf
			Next
			&& Marca Flag do Servico
			VG6->VG6_SEREXT := ""
			For nFlag:=1 To Len(cCpoASrv) Step 11
				If !Empty(oGetAdicional:aCols[i,FG_POSVAR(Substr(cCpoASrv,nFlag,10),"oGetAdicional:aHeader")])
					VG6->VG6_SEREXT := "1"
				EndIf
			Next
			MsUnlock()

		ElseIf !lAdd

			RecLock("VG6",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VG6")

		Endif

	Next

	End Transaction
	If lObrg
		Return .f.
	Endif
Endif

Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_060CODI ³ Autor ³Fabio                  ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca os codigos internos do item e do servico              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³FS_060CODINT()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_060CODINT()
*****************

If readvar() == 'M->VG6_CODITE'

	If !Empty(M->VG6_CODITE)
		If oFolder:nOption==1
			oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_PECINT","oGetNormal:aHeader")]:=SB1->B1_COD   //[5]
			oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_DESITE","oGetNormal:aHeader")]:=SB1->B1_DESC
		Elseif oFolder:nOption==2
			oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_PECINT","oGetAdicional:aHeader")]:=SB1->B1_COD   //[5]
			oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_DESITE","oGetAdicional:aHeader")]:=SB1->B1_DESC
		Endif
	Endif

Elseif  readvar() == 'M->VG6_CODSER'

	If !Empty(M->VG6_CODSER)
		If oFolder:nOption==1
			oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_SERINT","oGetNormal:aHeader")]:=VO6->VO6_SERINT    //[12]
			oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_DESSER","oGetNormal:aHeader")]:=VO6->VO6_DESSER    //[12]
		Elseif oFolder:nOption==2
			oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_SERINT","oGetAdicional:aHeader")]:=VO6->VO6_SERINT    //[12]
			oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_DESSER","oGetAdicional:aHeader")]:=VO6->VO6_DESSER    //[12]
		Endif
	Endif

Elseif  readvar() == 'M->VG6_ANORRC'

	If oFolder:nOption==1
		FS_060CARREGA( oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_ANORRC","oGetNormal:aHeader")]+oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_NUMRRC","oGetNormal:aHeader")] , M->VG6_ANORRC+M->VG6_NUMRRC,,.t. )
	Elseif oFolder:nOption==2
		FS_060CARREGA( oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_ANORRC","oGetAdicional:aHeader")]+oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_NUMRRC","oGetAdicional:aHeader")] , M->VG6_ANORRC+M->VG6_NUMRRC,,.t. )
	Endif

	M->VG8_ANORRC := M->VG6_ANORRC

Elseif  readvar() == 'M->VG6_NUMRRC'

	If oFolder:nOption==1
		FS_060CARREGA( oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_ANORRC","oGetNormal:aHeader")]+oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_NUMRRC","oGetNormal:aHeader")] , M->VG6_ANORRC+M->VG6_NUMRRC,,.t. )
	ElseIf oFolder:nOption==2
		FS_060CARREGA( oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_ANORRC","oGetAdicional:aHeader")]+oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_NUMRRC","oGetAdicional:aHeader")] , M->VG6_ANORRC+M->VG6_NUMRRC,,.t. )
	Endif

	M->VG8_NUMRRC := M->VG6_NUMRRC

Endif

oEnchoice:EnchRefreshAll()

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_060TUDOK ³ Autor ³Fabio                ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Da um ok final nos dados informados                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_060TUDOK()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_060TUDOK()
//***************

Local lvol := .T.

/*
If M->VG8_KILGAR > 0 .and. alltrim(M->VG8_CODGAR) $ "4/5"
Help(" ",1,"OFIGM00005")
lVol := .F.
Elseif Empty(M->VG8_KILGAR) .and. !(alltrim(M->VG8_CODGAR) $ "3/4/5")
Help(" ",1,"OFIGM00006")
lVol := .F.
Endif

If Empty(M->VG8_CHAINT) .and. !alltrim(M->VG8_CODGAR) $ "4/5"
Dbgotop()
DbSeek(xFilial("VO1")+M->VG8_NUMOSV)
M->VG8_CHAINT := VO1->VO1_CHAINT
Endif
*/
Return lvol


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
Function FS_060LIMPACPO()

Local nLimpa:=0

For nLimpa:=1 To Len(oGetAdicional:aHeader)

	If ( Substr(ReadVar(),4) $ cCpoASrv .And. oGetAdicional:aHeader[nLimpa,2] $ cCpoAPeca ) ;
		.Or. ( Substr(ReadVar(),4) $ cCpoAPeca .And. oGetAdicional:aHeader[nLimpa,2] $ cCpoASrv )

		oGetAdicional:aCols[n,nLimpa] := CriaVar(oGetAdicional:aHeader[nLimpa,2],.f.)

	EndIf

Next

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_060CARRºAutor  ³Fabio               º Data ³  08/23/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega conteudo da linha no cabecalho                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_060CARREGA(cNumRROld,cNumRRNew,cCarrega,lNMuda)

Local nCarrega:=0 , nPosCarrega:=0
Default lNMuda := .f.
Default cNumRROld := M->VG6_ANORRC+M->VG6_NUMRRC
If oFolder:nOption==1
	Default cNumRRNew := oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_ANORRC","oGetNormal:aHeader")]+oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR("VG6_NUMRRC","oGetNormal:aHeader")]
Elseif oFolder:nOption==2
	Default cNumRRNew := oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_ANORRC","oGetAdicional:aHeader")]+oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR("VG6_NUMRRC","oGetAdicional:aHeader")]
Endif
Default cCarrega  := "T"

&& Salva conteudo anterior
If cCarrega $ "T/S"
	If ( nPosCarrega:=Ascan( aCtrCpoEnch , { |x| x[2] == cNumRROld } ) ) == 0
		Aadd(aCtrCpoEnch,{ .t. , cNumRROld, aClone(aCtrCpoEnch[1,3])} )
		nPosCarrega:=Len(aCtrCpoEnch)
	EndIf

	For nCarrega:=1 to Len(aCpoEnchoice)

		aCtrCpoEnch[nPosCarrega,3,nCarrega] := M->&(aCpoEnchoice[nCarrega])

	Next
EndIf

&& Carrega novo conteudo
If cCarrega $ "T/V"
	If ( nPosCarrega:=Ascan( aCtrCpoEnch , { |x| x[2] == cNumRRNew } ) ) == 0
		Aadd(aCtrCpoEnch,{ .t. , cNumRRNew, aClone(aCtrCpoEnch[1,3])} )
		nPosCarrega:=Len(aCtrCpoEnch)
	EndIf

	For nCarrega:=1 to Len(aCpoEnchoice)

		M->&(aCpoEnchoice[nCarrega]) := aCtrCpoEnch[nPosCarrega,3,nCarrega]

	Next
EndIf

if !lNMuda
	If oFolder:nOption==1
		for nCarrega := 1 to Len(aHeaderNormal)
			M->&(aHeaderNormal[nCarrega,2]) := oGetNormal:aCols[oGetNormal:nAt,FG_POSVAR(aHeaderNormal[nCarrega,2],"oGetNormal:aHeader")]
		next
	Elseif oFolder:nOption==2
		for nCarrega := 1 to Len(aHeaderAdicional)
			M->&(aHeaderAdicional[nCarrega,2]) := oGetAdicional:aCols[oGetAdicional:nAt,FG_POSVAR(aHeaderAdicional[nCarrega,2],"oGetAdicional:aHeader")]
		next
	Endif
endif


oEnchoice:EnchRefreshAll()

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | GM060PSW   | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Alterar senha do usuario no Claw                             |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function GM060PSW(cAlias,nReg,nOpc)

Local oWS
Local aParamBox := {}
Local aRetParam := {}

If !VAI->(FieldPos("VAI_FABUSR")) <> 0
	MsgInfo(STR0028,STR0005) // "Opção não disponível"
	Return .t.
EndIf

// Procura Equipe técnica...
VAI->(DbSetOrder(4))
If !VAI->(MsSeek(xFilial("VAI")+__cUserID))
	MsgStop(STR0014,STR0005) // "Usuário sem cadastro na equipe técnica"
	Return .t.
EndIf
//

AADD(aParamBox,{1,RetTitle("VAI_FABUSR"),VAI->VAI_FABUSR,PesqPict("VAI","VAI_FABUSR"),"","",IIf( !Empty(VAI->VAI_FABUSR) , ".F." , ".T.") ,50,.T.})
AADD(aParamBox,{8,RetTitle("VAI_FABPWD"),Space(TamSX3("VAI_FABPWD")[1]),PesqPict("VAI","VAI_FABPWD"),"","","",50,.T.})

If !ParamBox(aParamBox,STR0013,@aRetParam,,,,,,,,.f.) // "Alterar Senha"
	Return .f.
EndIf

// So tenta atualizar a senha, quando existir uma senha ja gravada
If !Empty(VAI->VAI_FABPWD)
	// Solicita um token de conexao ...
	oWS := WSMIL_ScaniaClaw():New()
	//oWS:SetDebug()

	oWS:oWSrequest:cusername         := AllTrim(aRetParam[1])
	oWS:oWSrequest:cpreviousPassword := AllTrim(VAI->VAI_FABPWD)
	oWS:oWSrequest:cnewPassword      := AllTrim(aRetParam[2])

	lProcessado	:= .f.
	MsgRun(STR0015 , STR0016,{|| lProcessado := oWS:ChangePassword() })  // "Alterando senha"
	If !lProcessado
		oWS:ExibeErro("ChangePassword")
		Return .f.
	EndIf

	If oWS:oWSChangePasswordResult:cresultCode <> "00"
		MsgInfo(oWS:oWSChangePasswordResult:cdescription)
		Return .f.
	EndIf
EndIf

// Altera senha ...
RecLock("VAI",.f.)
VAI->VAI_FABUSR := aRetParam[1]
VAI->VAI_FABPWD := aRetParam[2]
VAI->VAI_DATPWD := dDataBase
VAI->(MsUnlock())
//

MsgInfo(STR0017,STR0005) // "Senha atualizada"

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | GM060TRA   | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Transmitir Solicitacao de Garantia                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function GM060TRA(cAlias,nReg,nOpc)

Local oWS
Local aAuxSrvc
Local nCont
Local nApont
Local cMecanico := ""

INCLUI := .F.

If !VAI->(FieldPos("VAI_FABUSR")) <> 0
	MsgInfo(STR0028,STR0005) // "Opção não disponível"
	Return .t.
EndIf

If !GM060VLDPSW()
	Return .t.
EndIf

If Empty(VG8->VG8_NUMRRC)
	MsgInfo(STR0029,STR0005) // "Selecione um registro com número de RR"
	Return .t.
EndIf

If !Empty(VG8->VG8_RRCFAB)
	MsgInfo(STR0030,STR0005) // "Solicitação de garantia já foi transmitida para o Claw"
	Return .t.
EndIf

If !MsgYesNo(STR0031,STR0005) // "Confirma transmissão da garantia"
	Return .t.
EndIf

If VG8->VG8_TIPRRC <> "4" // Garantia de peca em estoque nao tem chassi ...
	VV1->(DbSetOrder(1))
	VV1->(dbSeek(xFilial("VV1") + VG8->VG8_CHAINT ))
EndIf

VO1->(dbSetOrder(1))
VO1->(dbSeek(xFilial("VO1") + VG8->VG8_NUMOSV ))

// Solicita um token de conexao ...
oWS := WSMIL_ScaniaClaw():New()
//oWS:SetDebug()

oWS:oWSSaveClaim:oWSSaveClaimRec := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRec():New()

oAuxGar := MIL_ScaniaClaw_claimRequestClaimRec():New()

oAuxGar:cnationCode	:= "BR"
oAuxGar:ccustNo		:= GetNewPar("MV_MIL0005","")
oAuxGar:cworkOrdNo	:= VG8->VG8_NUMOSV
oAuxGar:cjobNo			:= VG8->VG8_NUMRRC

If VG8->VG8_TIPRRC <> "4" // Garantia de peca em estoque nao tem chassi ...
	oAuxGar:cchassiNo	:= AllTrim(VV1->VV1_CHARED) // Chassi reduzido
	oAuxGar:cmileage	:= AllTrim(Str(Int(VO1->VO1_KILOME/1000))) // Kilometragem do caminhao
EndIf

oAuxGar:cdistrNationCode	:= "BR"
oAuxGar:cmaingroup			:= VG8->VG8_GRUSER
oAuxGar:cdamagePartNo		:= Alltrim(VG8->VG8_ITECAU)
oAuxGar:cclaimType			:= VG8->VG8_TIPRRC

If VG8->VG8_TIPRRC == "2"
	oAuxGar:cmountDate		:= FormatDate(1,VG8->VG8_REPANT)
	oAuxGar:cmountMileage	:= AllTrim(Str(Int(VG8->VG8_KILANT/1000)))
EndIf

If VG8->VG8_TESCPO <> 0
	oAuxGar:cfieldTestNo  := StrZero(VG8->VG8_TESCPO,6)
EndIf
oAuxGar:cprodType  := Alltrim(VG8->VG8_CODREC)

If VG8->VG8_CODCAM <> 0
	oAuxGar:ccampNo   := AllTrim(Str(VG8->VG8_CODCAM))
	oAuxGar:oWSclawValues:ccampType := AllTrim(VG8->VG8_CAMTIP)
EndIf

oAuxGar:ccustText			:= E_MSMM(VO1->VO1_OBSMEM,TamSX3("VO1_OBSERV")[1])
oAuxGar:cworkshopText	:= E_MSMM(VG8->VG8_OBSMEM,TamSX3("VG8_OBSERV")[1])
oAuxGar:copenDate			:= FormatDate(1,VO1->VO1_DATABE)
oAuxGar:ccomplainDate	:= FormatDate(1,VG8->VG8_ABEGAR)

oAuxGar:oWSclawValues:cdmsRefNo      := VG8->VG8_ANORRC + VG8->VG8_NUMRRC
oAuxGar:oWSclawValues:cstartClaiming := "Y"

cCodGar := Left(VG8->VG8_CODGAR,5)
Do Case
Case cCodGar >= "00000" .AND. cCodGar <= "02999"
	oAuxGar:cdemType := "0" // garantia básica
Case cCodGar >= "03000" .and. cCodGar <= "03999"
	oAuxGar:cdemType := "2" // Goodwill
Case cCodGar >= "04000" .and. cCodGar <= "04999"
	oAuxGar:cdemType := "3" // EPS
Case cCodGar >= "05000" .and. cCodGar <= "05999"
	oAuxGar:cdemType := "8" // Manutenção Especial
EndCase

dDataReparo := CtoD("01/01/1990")

VG6->(dbSetOrder(5))
VG6->(dbSeek(xFilial("VG6") + VG8->VG8_CODMAR + VG8->VG8_NUMOSV + VG8->VG8_ANORRC + VG8->VG8_NUMRRC ))
While !VG6->(Eof()) .and. VG6->VG6_FILIAL == VG8->VG8_FILIAL .AND. ;
						  VG6->VG6_CODMAR == VG8->VG8_CODMAR .AND. ;
						  VG6->VG6_NUMOSV == VG8->VG8_NUMOSV .AND. ;
						  VG6->VG6_ANORRC == VG8->VG8_ANORRC .AND. ;
						  VG6->VG6_NUMRRC == VG8->VG8_NUMRRC

	// Pecas ou servicos normais
	If VG6->VG6_ITEEXT == "0" .Or. VG6->VG6_SEREXT == "0"
		// Processa Pecas
		If !Empty(VG6->VG6_PECINT)

			oAuxCostP := MIL_ScaniaClaw_claimRequestClaimRecCostP():New()

			oAuxCostP:cpartNo         := AllTrim(VG6->VG6_CODITE)
			oAuxCostP:cqty            := AllTrim(Str(VG6->VG6_QTDITE))
			//oAuxCostP:cassortmentCode :=
			oAuxCostP:cextRowId       := AllTrim(Str(VG6->(Recno())))

			If oAuxGar:oWScostP == NIL
				oAuxGar:oWScostP := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostP():New()
			EndIf
			AADD(oAuxGar:oWScostP:oWSSaveClaimRequestClaimRecCostP, oAuxCostP )

		// Processa Servicos
		Else

			aAuxSrvc := FMX_CALSER( VG6->VG6_NUMOSV ,; // cNumOS
									VG6->VG6_TIPTEM ,; // cTipTem
									,; // cGruSer
									VG6->VG6_CODSER ,; // cCodSer
									.T. ,;             // lApont
									.F. ,;             // lNegoc
									.T. ,;             // lRetAbe
									.T. ,;             // lRetLib
									.T. ,;             // lRetFec
									.T. ,;             // lRetCan
									"" ,;              // cLibVOO
									"" )               // cFiltroSQL


			// Processa servicos ...
			For nCont := 1 to Len(aAuxSrvc)

				// Adiciona servicos ...
				oAuxCostL := MIL_ScaniaClaw_claimRequestClaimRecCostL():New()

				oAuxCostL:copCode   := AllTrim(VG6->VG6_CODSER)

				// Servicos especiais que o Claw considera de meia hora ...
				If AllTrim(VG6->VG6_CODSER) $ cClawMeiaH
					oAuxCostL:cqty := AllTrim(Str(Int(VG6->VG6_TPOGAR / 50)))
				ElseIf VG6->VG6_QTDITE <> 0 // quantidade de requisicao do mesmo servico
					oAuxCostL:cqty := AllTrim(Str(VG6->VG6_QTDITE))
				Else
					oAuxCostL:cqty := "1"
				EndIf
				oAuxCostL:cextRowId := AllTrim(Str(VG6->(Recno())))

				If oAuxGar:oWScostL == NIL
					oAuxGar:oWScostL := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostL():New()
				EndIf
				AADD(oAuxGar:oWScostL:oWSSaveClaimRequestClaimRecCostL, oAuxCostL)
				//

				// Adiciona apontamentos ...
				For nApont := 1 to Len(aAuxSrvc[nCont, SRVC_APONT])

					If aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_DATFIN] > dDataReparo
						dDataReparo := aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_DATFIN]
					EndIf

					cMecanico := aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_CODIGO]

					oAuxApont := MIL_ScaniaClaw_claimRequestClaimRecTimeStamp():New()

					oAuxApont:cStartTime := FormatDate(1,aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_DATINI]) + " " + PadL(AllTrim(Transform(aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_HORINI],"@R 99:99")),5,"0") + ":00"
					oAuxApont:cstopTime  := FormatDate(1,aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_DATFIN]) + " " + PadL(AllTrim(Transform(aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_HOTFIN],"@R 99:99")),5,"0") + ":00"

					If oAuxGar:oWStimeStamp == NIL
						oAuxGar:oWStimeStamp := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecTimeStamp():New()
					EndIf
					AADD(oAuxGar:oWStimeStamp:oWSSaveClaimRequestClaimRecTimeStamp, oAuxApont )
				Next nApont

			Next nCont
		EndIf
	EndIf

	// Item Extra ou Servico Adicional
	If VG6->VG6_ITEEXT == "1" .or. VG6->VG6_SEREXT == "1"

		// Tempo não catalogado
		If VG6->VG6_TPCUST == "MO "

			oAuxCostU := MIL_ScaniaClaw_claimRequestClaimRecCostU():New()

			oAuxCostU:oWSdescr := MIL_ScaniaClaw_claimRequestClaimRecCostUDescr():New()

			oAuxCostU:cdescription := AllTrim(VG6->VG6_DESSER)
			oAuxCostU:cextRowId    := AllTrim(Str(VG6->(Recno())))
			oAuxCostU:nnoOfHours   := VG6->VG6_TPOGAR / 100

			If oAuxGar:oWScostU == NIL
				oAuxGar:oWScostU := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostU():New()
			EndIf
			AADD( oAuxGar:oWScostU:oWSSaveClaimRequestClaimRecCostU, oAuxCostU )

			// Se houver codigo de servico, sobe os apontamentos ...
			If !Empty(VG6->VG6_CODSER) .and. !Empty(VG6->VG6_TIPTEM)

				aAuxSrvc := FMX_CALSER( VG6->VG6_NUMOSV ,; // cNumOS
										VG6->VG6_TIPTEM ,; // cTipTem
										,; // cGruSer
										VG6->VG6_CODSER ,; // cCodSer
										.T. ,;             // lApont
										.F. ,;             // lNegoc
										.T. ,;             // lRetAbe
										.T. ,;             // lRetLib
										.T. ,;             // lRetFec
										.T. ,;             // lRetCan
										"" ,;              // cLibVOO
										"" )               // cFiltroSQL


				// Processa servicos ...
				For nCont := 1 to Len(aAuxSrvc)

					// Adiciona apontamentos ...
					For nApont := 1 to Len(aAuxSrvc[nCont, SRVC_APONT])

						If aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_DATFIN] > dDataReparo
							dDataReparo := aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_DATFIN]
						EndIf

						cMecanico := aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_CODIGO]

						oAuxApont := MIL_ScaniaClaw_claimRequestClaimRecTimeStamp():New()

						oAuxApont:cStartTime := FormatDate(1,aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_DATINI]) + " " + PadL(AllTrim(Transform(aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_HORINI],"@R 99:99")),5,"0") + ":00"
						oAuxApont:cstopTime  := FormatDate(1,aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_DATFIN]) + " " + PadL(AllTrim(Transform(aAuxSrvc[nCont, SRVC_APONT, nApont, SRVC_APONT_HOTFIN],"@R 99:99")),5,"0") + ":00"

						If oAuxGar:oWStimeStamp == NIL
							oAuxGar:oWStimeStamp := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecTimeStamp():New()
						EndIf
						AADD(oAuxGar:oWStimeStamp:oWSSaveClaimRequestClaimRecTimeStamp, oAuxApont )
					Next nApont

				Next nCont
			EndIf

		Else

			// Adiciona custos especiais ...
			oAuxCostS := MIL_ScaniaClaw_claimRequestClaimRecCostS():New()

			oAuxCostS:oWSdescr := MIL_ScaniaClaw_claimRequestClaimRecCostSDescr():New()

			oAuxCostS:cdescription  := AllTrim(VG6->VG6_DESSER)
			oAuxCostS:cextRowId     := AllTrim(Str(VG6->(Recno())))
			oAuxCostS:nspCostAmt    := VG6->VG6_VALSER //AllTrim(Transform(VG6->VG6_VALSER,"@R 99999999.99"))

			If oAuxGar:oWScostS == NIL
				oAuxGar:oWScostS := MIL_ScaniaClaw_ArrayOfclaimRequestClaimRecCostS():New()
			EndIf
			AADD( oAuxGar:oWScostS:oWSSaveClaimRequestClaimRecCostS, oAuxCostS )
		EndIf

	EndIf

	VG6->(DbSkip())
End

dDataReparo := GM060DATAREPARO(dDataReparo)
//
// Se nao houver apontamento será enviado o codigo do usuario que esta transmitindo
// Ou se for garantia de pecas, utiliza o codigo do usuario que esta transmitindo
If Empty(cMecanico) .or. VG8->VG8_TIPRRC == "4"
	VAI->(DbSetOrder(4))
	If VAI->(MsSeek(xFilial("VAI")+__cUserID))
		oAuxGar:cmechanic := VAI->VAI_FABUSR
	EndIf
	VAI->(DbSetOrder(1))
Else
	oAuxGar:cmechanic := cMecanico
EndIf
//

oAuxGar:crepDate  := FormatDate(1,dDataReparo) // Data do Reparo ???
AADD( oWS:oWSSaveClaim:oWSSaveClaimRec:oWSSaveClaimRequestClaimRec , oAuxGar)

lProcessado:= .f.
MsgRun(STR0032,STR0033,{|| lProcessado := oWS:SaveClaimData() }) // "Transmitindo registro de garantia"
If !lProcessado
	oWS:ExibeErro("SaveClaimData")
	Return .f.
EndIf

If oWS:oWSSaveClaimDataResult:oWSSaveClaimRec:oWSSaveClaimRequestReplyClaimRec[1]:cResultCode <> "00"
	MsgInfo(STR0034 + chr(13) + chr(10) + chr(13) + chr(10) +;
			STR0035 + ": " + oWS:oWSSaveClaimDataResult:oWSSaveClaimRec:oWSSaveClaimRequestReplyClaimRec[1]:cResultCode + chr(13) + chr(10) +;
			STR0036 + ": " + oWS:oWSSaveClaimDataResult:oWSSaveClaimRec:oWSSaveClaimRequestReplyClaimRec[1]:cDescription) //
	Return .f.
EndIf

// Marca registro de garantia como ENVIADO...
dbSelectArea("VG8")
RecLock("VG8",.f.)
VG8->VG8_WEBSIT := "S"
MsUnLock()
//

If MsgYesNo(STR0037) // "Deseja abrir o Claw"
	cTokenClaw := oWS:oWSSaveClaimDataResult:oWSSaveClaimRec:oWSSaveClaimRequestReplyClaimRec[1]:oWSclawValues:cSSOToken
	GM060OPCLA(cTokenClaw)
EndIf

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FormatDate | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Função Aux. para formatar data para envio ao Claw            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FormatDate(nFormat, dAuxData, nHora)
	Local cRetorno := (Str(Year(dAuxData),4) + "-" + StrZero(Month(dAuxData),2) + "-" + StrZero(Day(dAuxData),2))
	If nFormat == 2
		If Empty(nHora)
			cRetorno += "T00:00:00"
		Else
			cRetorno += "T" + PadL(AllTrim(Transform(nHora, "@R 99:99")),5,"0") + ":00"
		EndIf
	EndIf
Return cRetorno

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | GM060CLAW  | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Acessa o Claw                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function GM060CLAW(cAlias,nReg,nOpc)
Return GM060OPCLA()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | GM060OPCLA | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Acessa o Claw                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GM060OPCLA(cTokenClaw)
Local cURL
Local oWs
Local lChared := .f.
Local aParam := StrTokArr(GetMV("MV_MIL0004"),"¨")

Default cTokenClaw := ""

// Validacao da senha
If !GM060VLDPSW()
	Return .f.
Endif

If Empty(cTokenClaw)

	If !Empty(VG8->VG8_CHAINT)
		VV1->(DbSetOrder(1))
		VV1->(dbSeek(xFilial("VV1") + VG8->VG8_CHAINT ))

		If Empty(VV1->VV1_CHARED)
			MsgStop(STR0053,STR0005) // "Veículo sem número de chassi reduzido"
		Else
			lChared := .t.
		EndIf
	EndIf

	// Requisita um Token de Conexao ...
	If !OFCSC01TOK(@oWS)
		Return .f.
	EndIf
	//

	cTokenClaw := oWS:oWSGetSSOTokenResult:cSSOToken

EndIf

cURL := aParam[4] + '?t=' + AllTrim(cTokenClaw)
If lChared
	cURL += "&cn=" + VV1->VV1_CHARED
EndIf

If nClawAcesso == 1

	// Calculo da Janela Principal
	oSizePrinc := FwDefSize():New(.t.)

	DEFINE MSDIALOG oDlgClaw TITLE "Claw" OF oMainWnd PIXEL;
		FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

	// cria objeto de Browser
	oBrowser := TIBrowser():New( 0 , 0 , 100 , 100 , cURL ,oDlgClaw )
	oBrowser:Align := CONTROL_ALIGN_ALLCLIENT
	//

	ACTIVATE MSDIALOG oDlgClaw

Else
	ShellExecute( "Open", cURL , "", "C:\", 1 )
EndIf

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | GM060IRC   | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Importa Reconsideração                                       |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function GM060IRC(cAlias,nReg,nOpc)

lRecons := .t.

GM060ATU("VG8",VG8->(Recno()),3)

lRecons := .f.

Return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | GM060ATU   | Autor |  Takahashi            | Data | 26/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza Garantia a partir do Claw                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function GM060ATU(cAlias,nReg,nOpc)

Local oWS
Local nCont
Local aParamBox := {}
Local aRetParam := {}

Local nTotPeca := 0
Local nTotSrvc := 0
Local nTotCustEsp  := 0
Local nTotNCatalog := 0

Local oAuxCostP
Local oAuxCostL
Local oAuxCostU
Local oAuxCostS

Local cSQL := ""

VISUALIZA := (nOpc == 2)
INCLUI    := (nOpc == 3)
ALTERA    := (nOpc == 4)
EXCLUI    := (nOpc == 5)
FECHA     := (nOpc == 6)

If !VAI->(FieldPos("VAI_FABUSR")) <> 0
	MsgInfo(STR0028,STR0005) // "Opção não disponível"
	Return .t.
EndIf

If Empty(VG8->VG8_NUMRRC)
	MsgInfo(STR0029,STR0005) // "Selecione um registro com número de RR"
	Return .t.
EndIf

If !lRecons .and. VG8->VG8_WEBSIT <> "S"
	MsgInfo(STR0038,STR0005) // "Solicitação de garantia não foi transmitida."
	Return .t.
EndIf

If !MsgYesNo(STR0039,STR0005) // "Confirma atualização/importação da garantia."
	Return .t.
EndIf

If !GM060VLDPSW()
	Return .t.
EndIf

VV1->(DbSetOrder(1))
VV1->(dbSeek(xFilial("VV1") + VG8->VG8_CHAINT ))

VO1->(dbSetOrder(1))
VO1->(dbSeek(xFilial("VO1") + VG8->VG8_NUMOSV ))

// Solicita um token de conexao ...
oWS := WSMIL_ScaniaClaw():New()
//oWS:SetDebug()

// Se for a primeira atualização, procura o numero da RR (Scania)
If Empty(VG8->VG8_RRCFAB) .or. lRecons

	If !lRecons
		oWS:oWSclaim:oWSclaimStatusRec := MIL_ScaniaClaw_ArrayOfclaimStatusClaimStatusRec():New()

		oAuxGar := MIL_ScaniaClaw_claimStatusClaimStatusRec():New()
		oAuxGar:cnationCode             := "BR"
		oAuxGar:ccustNo                 := GetNewPar("MV_MIL0005","") //"00221"
		oAuxGar:cprodType               := VG8->VG8_CODREC // "1" // Alltrim(VG8->VG8_CODREC)

		If VG8->VG8_TIPRRC <> "4"
			oAuxGar:cchassiNo           := AllTrim(VV1->VV1_CHARED) // "3833052" // VV1->VV1_CHARED // Chassi reduzido
		EndIf

		// Se encontrar numero da RR da Scania, pesquisa informacoes pelo numero da RR
//		If !Empty(VG8->VG8_RRCFAB)
//			oAuxGar:cclaimNo := AllTrim(VG8->VG8_RRCFAB)
//			oAuxGar:cReconNo := AllTrim(VG8->VG8_NRECON)
//			oAuxGar:cfailNo  := AllTrim(VG8->VG8_NFALHA)
		// Procura pelo numero da OS do Protheus
//		Else
			oAuxGar:cworkOrdNo              := VG8->VG8_NUMOSV
			oAuxGar:cjobNo                  := IIf(Empty(VG8->VG8_NFALHA),"99999",AllTrim(VG8->VG8_NFALHA))
//		EndIf
//		oAuxGar:oWSclawValues:cdmsRefNo := VG8->VG8_NUMRRC

		AADD( oWS:oWSclaim:oWSclaimStatusRec:oWSclaimStatusClaimStatusRec , oAuxGar )

		lProcessado:= .f.
		MsgRun(STR0040,STR0033,{|| lProcessado := oWS:GetClaimData() }) // "Consultando número da RR (Scania)"
		If !lProcessado
			oWS:ExibeErro("GetClaimData")
			Return .f.
		EndIf

		If Len(oWS:oWSGetClaimDataResult:oWSClaimRec:oWSClaimStatusReplyClaimRec) == 0
			MsgStop(STR0041,STR0033) // "WebService não retornou informação, verifique se a Solicitação de Garantia foi transmitida."
			Return .f.
		EndIf

		oRequestValues := oWS:oWSGetClaimDataResult:oWSClaimRec:oWSClaimStatusReplyClaimRec[1]:oWSRequestValues

		If Empty(oRequestValues:cClaimNo)
			MsgStop(STR0042)
			Return .f.
		EndIf
	EndIf

	AADD(aParambox,{1,RetTitle("VG8_NUMOSV"),VG8->VG8_NUMOSV,"","","",".F.",50,.F.})
	AADD(aParambox,{1,RetTitle("VG8_ANORRC"),VG8->VG8_ANORRC,"","","",".F.",30,.F.})
	AADD(aParambox,{1,RetTitle("VG8_NUMRRC"),VG8->VG8_NUMRRC,"","","",".F.",50,.F.})
	// Exibe tela para o usuário informar o número da falha
	If lRecons
		AADD(aParamBox,{1,RetTitle("VG8_RRCFAB"),VG8->VG8_RRCFAB,"","","",".F.",50,.T.})
		AADD(aParamBox,{1,RetTitle("VG8_NFALHA"),VG8->VG8_NFALHA,PesqPict("VG8","VG8_NFALHA"),"","",".F.",15,.T.})
		AADD(aParamBox,{1,RetTitle("VG8_NRECON"),Space(TamSX3("VG8_NRECON")[1]),PesqPict("VG8","VG8_NRECON"),"","","",15,.T.})
		cNumRRCScania := VG8->VG8_RRCFAB
	Else
		AADD(aParamBox,{1,RetTitle("VG8_RRCFAB"),oRequestValues:cClaimNo,"","","",".F.",50,.T.})
		AADD(aParamBox,{1,RetTitle("VG8_NFALHA"),Space(TamSX3("VG8_NFALHA")[1]),PesqPict("VG8","VG8_NFALHA"),"","","",15,.T.})
		cNumRRCScania := oRequestValues:cClaimNo
		oWS:Reset()
	Endif

	If !ParamBox(aParamBox,STR0043,@aRetParam,,,,,,,,.f.)
		Return .f.
	EndIf
	//

	cNumFalScania := StrZero(Val(aRetParam[5]),2)
	If lRecons
		cNumRecScania := StrZero(Val(aRetParam[6]),2)
	Else
		cNumRecScania := "00"
	Endif

	// Verifica se ja existe garantia com numero informado ...
	cSQL := "SELECT R_E_C_N_O_"
	cSQL +=  " FROM " + RetSQLName("VG8") + " VG8 "
	cSQL += " WHERE VG8_FILIAL = '" + xFilial("VG8") + "'"
	cSQL +=   " AND VG8_NUMOSV = '" + VG8->VG8_NUMOSV + "'"
	cSQL +=   " AND VG8_RRCFAB = '" + cNumRRCScania + "'"
	cSQL +=   " AND VG8_NFALHA = '" + cNumFalScania + "'"
	cSQL +=   " AND VG8_NRECON = '" + cNumRecScania + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	If FM_SQL(cSQL) <> 0
		MsgStop(STR0044,STR0005) // "Solicitação de garantia já cadastrada"
		Return .f.
	EndIf
	//

Else
	cNumRRCScania := VG8->VG8_RRCFAB
	cNumFalScania := VG8->VG8_NFALHA
	cNumRecScania := VG8->VG8_NRECON
EndIf

oWS:oWSclaim:oWSclaimStatusRec := MIL_ScaniaClaw_ArrayOfclaimStatusClaimStatusRec():New()
oAuxGar := MIL_ScaniaClaw_claimStatusClaimStatusRec():New()
oAuxGar:cnationCode             := "BR"
oAuxGar:ccustNo                 := GetNewPar("MV_MIL0005","")
oAuxGar:cprodType               := VG8->VG8_CODREC
If VG8->VG8_TIPRRC <> "4"
	oAuxGar:cchassiNo           := AllTrim(VV1->VV1_CHARED)
EndIf
oAuxGar:cclaimNo := AllTrim(cNumRRCScania)
oAuxGar:cReconNo := AllTrim(Str(Val(cNumRecScania),2))
oAuxGar:cfailNo  := AllTrim(Str(Val(cNumFalScania),2))
AADD( oWS:oWSclaim:oWSclaimStatusRec:oWSclaimStatusClaimStatusRec , oAuxGar )

lProcessado:= .f.
MsgRun(STR0045,STR0033,{|| lProcessado := oWS:GetClaimData() })  // "Consultando status da RR (Claw)"
If !lProcessado
	oWS:ExibeErro("GetClaimData")
	Return .f.
EndIf

// TO DO - Verificar se no retorno do WebService é possivel verificar que a Garantia nao foi encontrada
If Len(oWS:oWSGetClaimDataResult:oWSClaimRec:oWSClaimStatusReplyClaimRec) == 0
	MsgStop(STR0046,STR0005)  // "Dados não encontrados com o filtro solicitado!"
	Return .f.
Endif
oRequestValues  := oWS:oWSGetClaimDataResult:oWSClaimRec:oWSClaimStatusReplyClaimRec[1]:oWSRequestValues
oResponseValues := oWS:oWSGetClaimDataResult:oWSClaimRec:oWSClaimStatusReplyClaimRec[1]:oWSresponseValues

Begin Transaction

dbSelectArea("VG8")

cNumRRC := VG8->VG8_NUMRRC

If lRecons

	nAuxRecNO := FM_SQL(;
		"SELECT R_E_C_N_O_ " + ;
		 " FROM " + RetSQLName("VG8") + ;
		" WHERE VG8_FILIAL = '" + xFilial("VG8") + "'" + ;
		  " AND VG8_NUMOSV = '" + VG8->VG8_NUMOSV + "'" + ;
		  " AND VG8_RRCFAB = '" + cNumRRCScania + "'" + ;
		  " AND VG8_NRECON = '" + cNumRecScania + "'" + ;
		  " AND VG8_NFALHA = '" + cNumFalScania + "'" + ;
		  " AND D_E_L_E_T_ = ' '" )

	If nAuxRecNO <> 0
		MsgStop(STR0047,STR0005)  // "Reconsideração já importada!"
		DisarmTransaction()
		Return .f.
	Endif

	RegToMemory("VG8",.F.)
	RecLock("VG8", .t. )
	FG_GRAVAR("VG8")
	VG8->VG8_NUMRRC := StrZero(Val(cNumRecScania),2) + Right(VG8->VG8_NUMRRC,5)
	VG8->VG8_RECONS := "1"
	VG8->VG8_GRUSER := PadL(AllTrim(oRequestValues:cmaingroup),2,"0")
	VG8->VG8_ITECAU := oRequestValues:cdamagePartNo

	M->VG8_OBSERV := AllTrim(oRequestValues:cworkshopText)
Else
	RecLock("VG8", .f. )
Endif

/*
01=Critica RR
02=Aviso Recebimento RR
03=Atendimento RR - Liquidada
04=Atendimento RR - Estornada
05=Atendimento RR - Recusada

VG8_SITRRC  // FG_Strzero("M->VG8_SITRRC",2,.F.).AND.PERTENCE("0102030405") --

VG8_ITEPGT -> Valor de Item Pago
VG8_SERPGT -> Valor de Servico Pago
VG8_ITEEST -> Valor de Item Estornado
VG8_SEREST -> Valor Servico Estornado
*/

VG8->VG8_RRCFAB := oRequestValues:cClaimNo
VG8->VG8_NRECON := StrZero(Val(oRequestValues:cReconNo),2)
VG8->VG8_NFALHA := StrZero(Val(oRequestValues:cfailNo ),2)

VG8->VG8_FONTE  := FM_SQL("SELECT X5_CHAVE FROM " + RetSQLName("SX5") + " WHERE X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = '80' AND X5_DESCRI LIKE '(" + AllTrim(oRequestValues:csourceCode)   + ")%' AND D_E_L_E_T_ = ' '")
VG8->VG8_SINTOM := FM_SQL("SELECT X5_CHAVE FROM " + RetSQLName("SX5") + " WHERE X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = '82' AND X5_DESCRI LIKE '(" + AllTrim(oRequestValues:csymptomCode)  + ")%' AND D_E_L_E_T_ = ' '")
VG8->VG8_CODDEF := AllTrim(oRequestValues:cfailureCode)
VG8->VG8_LOCFAL := FM_SQL("SELECT X5_CHAVE FROM " + RetSQLName("SX5") + " WHERE X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = '84' AND X5_DESCRI LIKE '(" + AllTrim(oRequestValues:clocationCode) + ")%' AND D_E_L_E_T_ = ' '")
VG8->VG8_METREP := FM_SQL("SELECT X5_CHAVE FROM " + RetSQLName("SX5") + " WHERE X5_FILIAL = '" + xFilial("SX5") + "' AND X5_TABELA = '85' AND X5_DESCRI LIKE '(" + AllTrim(oRequestValues:crepairCode)   + ")%' AND D_E_L_E_T_ = ' '")

VG8->VG8_SITRRC := AllTrim(oResponseValues:cresultCode)
VG8->VG8_DESSIT := AllTrim(oResponseValues:oWSResultCodeDescr:cDescription)

VG8->VG8_TRANSM := "S"

VG8->VG8_DATCRE := IIf( Left(oResponseValues:ccreditDate,10) <> "0001-01-01" , StoD(StrTran(Left(oResponseValues:ccreditDate,10),"-","")) , CtoD(" ") )
VG8->VG8_NFCRED := oResponseValues:ccreditNote

// Dependendo do Status, utiliza os dados do trecho do Request ou do Response ...
// 01 Error in indata, se faultDescr for full desription text
// 11 Claim waiting for goods inspection
// 12 Claim waiting for manual assessment (or attest)
// 61 Claim totally accepted
// 62 Claim partly accepted
// 63 Claim totally rejected
// 991 Saved in Claw
If VG8->VG8_SITRRC > "30"
	oAuxCostP := oResponseValues:oWSCostP:oWSclaimStatusReplyClaimRecResponseValuesCostP
	oAuxCostL := oResponseValues:oWSCostL:oWSclaimStatusReplyClaimRecResponseValuesCostL
	oAuxCostU := oResponseValues:oWSCostU:oWSclaimStatusReplyClaimRecResponseValuesCostU
	oAuxCostS := oResponseValues:oWSCostS:oWSclaimStatusReplyClaimRecResponseValuesCostS
Else
	oAuxCostP := oRequestValues:oWSCostP:oWSclaimStatusReplyClaimRecRequestValuesCostP
	oAuxCostL := oRequestValues:oWSCostL:oWSclaimStatusReplyClaimRecRequestValuesCostL
	oAuxCostU := oRequestValues:oWSCostU:oWSclaimStatusReplyClaimRecRequestValuesCostU
	oAuxCostS := oRequestValues:oWSCostS:oWSclaimStatusReplyClaimRecRequestValuesCostS
EndIf

For nCont := 1 to Len(oAuxCostP)
	oPecas := oAuxCostP[nCont]

	nAuxRecNO := FM_SQL(;
		"SELECT R_E_C_N_O_ " + ;
 	 	 " FROM " + RetSQLName("VG6") + ;
		" WHERE VG6_FILIAL = '" + xFilial("VG6") + "'" + ;
		  " AND VG6_NUMOSV = '" + VG8->VG8_NUMOSV + "'" + ;
		  " AND VG6_NUMRRC = '" + cNumRRC + "'" + ;
		  " AND VG6_CODITE = '" + oPecas:cPartNo + "'" + ;
		  " AND D_E_L_E_T_ = ' '" )

	If nAuxRecNO <> 0
		VG6->(dbGoTo(nAuxRecNo))

		If lRecons
			RegToMemory("VG6",.F.)
			RecLock("VG6", .t. )
			FG_GRAVAR("VG6")
			VG6->VG6_NUMRRC := VG8->VG8_NUMRRC
		Else
			RecLock("VG6" , .F. )
		EndIf

		VG6->VG6_TRANSM := "S"

		// Informacoes so existem quando o codigo do retorno for maior que "30"
		If VG8->VG8_SITRRC > "30"
			If oPecas:cresultGoodsCode == "00"		// 00 No instruction
				VG6->VG6_ENVPEC := "N"
			ElseIf oPecas:cresultGoodsCode == "01"	// 01 Sent to factory
				VG6->VG6_ENVPEC := "S"
			ElseIf oPecas:cresultGoodsCode == "02"	// 02 Inspection at dealer
				VG6->VG6_ENVPEC := "I"
			EndIf

			VG6->VG6_QTDAPR := Val(oPecas:cCompQty)
			VG6->VG6_LIQUID := IIf( VG6->VG6_QTDAPR <> 0 , "S" , "N" )


			nTotPeca += oPecas:nCompAmt

		EndIf
		//
		VG6->(MsUnLock())
	EndIf

Next nCont

For nCont := 1 to Len(oAuxCostL)
	oServico := oAuxCostL[nCont]

	nAuxRecNO := FM_SQL(;
		"SELECT R_E_C_N_O_ " + ;
 	 	 " FROM " + RetSQLName("VG6") + ;
		" WHERE VG6_FILIAL = '" + xFilial("VG6") + "'" + ;
		  " AND VG6_NUMOSV = '" + VG8->VG8_NUMOSV + "'" + ;
		  " AND VG6_NUMRRC = '" + cNumRRC + "'" + ;
		  " AND VG6_CODSER = '" + oServico:cOpCode + "'" + ;
		  " AND D_E_L_E_T_ = ' '" )

	If nAuxRecNO <> 0
		VG6->(dbGoTo(nAuxRecNo))

		If lRecons
			RegToMemory("VG6",.F.)
			RecLock("VG6", .t. )
			FG_GRAVAR("VG6")
			VG6->VG6_NUMRRC := VG8->VG8_NUMRRC
		Else
			RecLock("VG6" , .F. )
		EndIf

		VG6->VG6_TRANSM := "S"

		// Informacoes so existem quando o codigo do retorno for maior que "30"
		If VG8->VG8_SITRRC > "30"
			VG6->VG6_LIQUID := IIf( oServico:nCompAmt <> 0 , "S" , "N" )

			nTotSrvc += oServico:nCompAmt

		EndIf
		//
		VG6->(MsUnLock())
	EndIf

Next nCont

For nCont := 1 to Len(oAuxCostU)
	oNCatalog := oAuxCostU[nCont]

	// Posiciona pelo RECNO para utilizar a descricao do servico ...
	VG6->(dbGoTo(Val(oNCatalog:cExtRowID)))
	//

	nAuxRecNO := FM_SQL(;
		"SELECT R_E_C_N_O_ " + ;
 	 	 " FROM " + RetSQLName("VG6") + ;
		" WHERE VG6_FILIAL = '" + xFilial("VG6") + "'" + ;
		  " AND VG6_NUMOSV = '" + VG8->VG8_NUMOSV + "'" + ;
		  " AND VG6_NUMRRC = '" + cNumRRC + "'" + ;
		  " AND VG6_DESSER = '" + VG6->VG6_DESSER + "'" + ;
		  " AND VG6_TPCUST = 'MO ' " + ;
		  " AND D_E_L_E_T_ = ' '" )

	If nAuxRecNO <> 0
		VG6->(dbGoTo(nAuxRecNo))

		If lRecons
			RegToMemory("VG6",.F.)
			RecLock("VG6", .t. )
			FG_GRAVAR("VG6")
			VG6->VG6_NUMRRC := VG8->VG8_NUMRRC
		Else
			RecLock("VG6" , .F. )
		EndIf

		VG6->VG6_TRANSM := "S"

		// Informacoes so existem quando o codigo do retorno for maior que "30"
		If VG8->VG8_SITRRC > "30"
			VG6->VG6_LIQUID := IIf( oNCatalog:nCompAmt <> 0 , "S" , "N" )

			nTotNCatalog += oNCatalog:nCompAmt

		EndIf
		//

		VG6->(MsUnLock())
	EndIf

Next nCont

For nCont := 1 to Len(oAuxCostS)
	oCustEsp := oAuxCostS[nCont]

	// Posiciona pelo RECNO para utilizar a descricao do servico ...
	VG6->(dbGoTo(Val(oCustEsp:cExtRowID)))
	//

	nAuxRecNO := FM_SQL(;
		"SELECT R_E_C_N_O_ " + ;
 	 	 " FROM " + RetSQLName("VG6") + ;
		" WHERE VG6_FILIAL = '" + xFilial("VG6") + "'" + ;
		  " AND VG6_NUMOSV = '" + VG8->VG8_NUMOSV + "'" + ;
		  " AND VG6_NUMRRC = '" + cNumRRC + "'" + ;
		  " AND VG6_DESSER = '" + VG6->VG6_DESSER + "'" + ;
		  " AND VG6_TPCUST <> 'MO ' " + ;
		  " AND D_E_L_E_T_ = ' '" )

	If nAuxRecNO <> 0
		VG6->(dbGoTo(nAuxRecNo))

		If lRecons
			RegToMemory("VG6",.F.)
			RecLock("VG6", .t. )
			FG_GRAVAR("VG6")
			VG6->VG6_NUMRRC := VG8->VG8_NUMRRC
		Else
			RecLock("VG6" , .F. )
		EndIf

		VG6->VG6_TRANSM := "S"

		// Informacoes so existem quando o codigo do retorno for maior que "30"
		If VG8->VG8_SITRRC > "30"
			VG6->VG6_LIQUID := IIf( oCustEsp:ncompSpCostAmt <> 0 , "S" , "N" )

			nTotCustEsp += oCustEsp:ncompSpCostAmt

		EndIf
		//

		VG6->(MsUnLock())
	EndIf

Next nCont

VG8->VG8_ITEPGT := nTotPeca
VG8->VG8_SERPGT := nTotSrvc
VG8->VG8_CUSESP := nTotCustEsp
VG8->VG8_TPONCT := nTotNCatalog

If lRecons
	MSMM(,TamSx3("VG8_OBSERV")[1],,M->VG8_OBSERV,1,,,"VG8","VG8_OBSMEM")
EndIf
VG8->(MsUnlock())

End Transaction

Return


/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | GM060VLDPSW | Autor |  Takahashi           | Data | 26/12/13 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Validacao de senha                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora Scania                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function GM060VLDPSW()

// Procura Equipe técnica...
VAI->(DbSetOrder(4))
If !VAI->(MsSeek(xFilial("VAI")+__cUserID))
	MsgStop(STR0014,STR0005) // "Usuário sem cadastro na equipe técnica"
	Return
EndIf
//

If dDataBase > (VAI->VAI_DATPWD + 90)
	MsgStop(STR0048,STR0005) // "Senha do CLAW expirada! Impossivel continuar!"
	Return .f.
ElseIf dDataBase == (VAI->VAI_DATPWD + 90)
	MsgStop(STR0049,STR0005) // "Senha do CLAW expira hoje! Favor atualize para não perder o acesso!"
ElseIf dDataBase >= (VAI->VAI_DATPWD + 80)
	MsgStop(STR0050 + CHR(13) + CHR(10) + STR0051 + CHR(13) + CHR(10) + STR0052 + ": " + StrZero( (VAI->VAI_DATPWD + 90) - dDataBase,2) ,STR0005) // "Senha do CLAW está para expirar!" / "Favor atualize para não perder o acesso!" / "Dias para expirar"
Endif

Return .t.

/*/{Protheus.doc} GM060PLF
Transmissão de planos flexiveis 
@author Rubens
@since 17/12/2018
@version 1.0
@param cAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpc, numeric, descricao
@type function
/*/
Function GM060PLF(cAlias,nReg,nOpc)

	Local aAuxSrvc
	Local nCont
	Local nApont
	Local cMecanico := ""

	Local lRet
	Local oWS

	Local nResultado
	Local cSave := "N"
	Local aVG6Proc := {} // Controla os itens processados para gravação dos valores da VG6

	Private aVG6Parts := {}
	Private aVG6Labour := {}
	Private aVG6_U_Labour := {}
	Private aVG6_SpecCost := {}

	Private dDataReparo := CtoD("01/01/1990")
	Private nHoraReparo := 0

	INCLUI := .F.

	If GM060FaltaDados()
		Return .t.
	EndIF

	If VG8->VG8_WEBSIT == "S"
		MsgInfo(STR0054,STR0005) // "Solicitação de garantia já foi transmitida." 
		Return .t.
	EndIf

	If !MsgYesNo(STR0055,STR0005) // "Confirma transmissão do registro ?"
		Return .t.
	EndIf

	If Aviso(STR0056, STR0057 , { STR0058 , STR0059 } ) == 2 // "Planos flexíveis" # "Deseja validar RR ou enviar?" # "Validar" # "Enviar"
		cSave := "S"
	EndIf

	If VG8->VG8_TIPRRC <> "4" // Garantia de peca em estoque nao tem chassi ...
		VV1->(DbSetOrder(1))
		VV1->(dbSeek(xFilial("VV1") + VG8->VG8_CHAINT ))
	EndIf

	VO1->(dbSetOrder(1))
	VO1->(dbSeek(xFilial("VO1") + VG8->VG8_NUMOSV ))

	oAuxGar := MIL_ScaniaARMS_ClaimRecReq():New()

	GM060PLF01_CarregaItens(@aVG6Proc)

	GM060PLF02_DefComplex(oAuxGar)

	GM060PLF05_DefSimple(oAuxGar, cSave)
	GM060PLF04_SetComplex(oAuxGar)

	oWS := WSMIL_ScaniaARMS():New()
	//oWS:SetDebug()
	AADD( oWS:oWSClaimsRecReq:oWSClaimRecReq , oAuxGar)
	lProcessado:= .f.
	FWMsgRun(;
		,;
		{|| lProcessado := oWS:ClaimVerify() },;
		STR0033,;
		STR0032 ) // "Transmitindo registro de garantia"
	If !lProcessado
		oWS:ExibeErro("ClaimVerify")
		Return .f.
	EndIf

	GM060PLF07_ProcResultado(oWS, cSave, aVG6Proc)

Return

/*/{Protheus.doc} GM060PLF07_ProcResultado
Processa retorno do web service
@author Rubens
@since 17/12/2018
@version 1.0
@param oWS, object, descricao
@param cSave, characters, descricao
@param aVG6Proc, array, descricao
@type function
/*/
Static Function GM060PLF07_ProcResultado(oWS, cSave, aVG6Proc)
	Local cMsgRetorno := ""
	Local oResultado := oWS:oWSClaimRecRes:oWSClaimRecRes[1]
	Local oFaultDescription
	Local nPos

	If oResultado:nResultCode == 1 .or. oResultado:nResultCode == 2

		Do Case
		Case oResultado:nResultCode == 1 ; cMsgRetorno := STR0060 // "Dados errados na solicitação" // Claim Error in Data
		Case oResultado:nResultCode == 2 ; cMsgRetorno := STR0061 // "Solicitação Rejeitada" // Claim Rejected
		End Case

		oFaultDescription := oWS:oWSClaimRecRes:oWSClaimRecRes[1]:oWSFaultDescription
		For nPos := 1 to Len(oFaultDescription:oWSFaultDescription)
			cMsgRetorno += ;
				CHR(13) + CHR(10) +;
				STR0062 + ": " + cValToChar(oFaultDescription:oWSFaultDescription[nPos]:cFaultSource) + CHR(13) + CHR(10) + ; // Origem
				STR0063 + ": " + cValToChar(oFaultDescription:oWSFaultDescription[nPos]:cFaultColumn) + CHR(13) + CHR(10) + ; // Campo
				STR0064 + ": " + cValToChar(oFaultDescription:oWSFaultDescription[nPos]:cFaultValue) + CHR(13) + CHR(10) + ; // Valor transmitido
				STR0065 + ": " + cValToChar(oFaultDescription:oWSFaultDescription[nPos]:cFaultMessage) + CHR(13) + CHR(10) + ; // Mensagem de Falha
				"-------------------------------------------------------------------" + CHR(13) + CHR(10)
		Next nPos

		Aviso(;
			STR0066,; // "Problema na transmissão"
			cMsgRetorno,;
			{STR0067},; // "OK"
			3 )

	ElseIf oResultado:nResultCode == 3
		cMsgRetorno := STR0068 // "Solicitação aguardando avaliação manual." // Claim Waiting for Manual Assessment
		GM060PLF08_SolAceita(oResultado, cSave, aVG6Proc, cMsgRetorno)
		MsgAlert(cMsgRetorno)

	ElseIf oResultado:nResultCode == 4
		cMsgRetorno := STR0069 // "Solicitação aceita." // Claim Accepted
		GM060PLF08_SolAceita(oResultado, cSave, aVG6Proc, cMsgRetorno)
		MsgInfo(cMsgRetorno)
	EndIf

Return

/*/{Protheus.doc} GM060PLF08_SolAceita
Atualiza solicitacao de garantia quando esta é aceita 
@author Rubens
@since 17/12/2018
@version 1.0
@param oResultado, object, descricao
@param cSave, characters, descricao
@param aVG6Proc, array, descricao
@param cMsgRetorno, characters, descricao
@type function
/*/
Static Function GM060PLF08_SolAceita(oResultado, cSave, aVG6Proc, cMsgRetorno)

	Local nPos

	If cSave <> "S"
		Return 
	EndIf

	dbSelectArea("VG8")
	RecLock("VG8", .f. )
	// Campos a serem gravados de acordo com o retorno:
	VG8->VG8_DATTRA := dDataBase // Data Transm.
	VG8->VG8_DATRET := dDataBase  // Data Retorno
	VG8->VG8_TRANSM := "S" // Transmitida
	VG8->VG8_WEBSIT := "S" // Trans. Web
	VG8->VG8_SITRRC := AllTrim(Str(oResultado:nResultCode))
	VG8->VG8_DESSIT := AllTrim(Upper(FwNoAccent(StrTran(cMsgRetorno,".",""))))
	VG8->(MsUnLock())

	For nPos := 1 to Len(aVG6Proc)
		VG6->(dbGoTo(aVG6Proc[nPos]))
		RecLock("VG6", .f. )
		VG6->VG6_TRANSM := "S"
		VG6->(MsUnLock())
	Next nPos

Return



/*/{Protheus.doc} GM060PLF01_CarregaItens
Carrega itens da solicitacao de garantia
@author Rubens
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param aVG6Proc, array, descricao
@type function
/*/
Static Function GM060PLF01_CarregaItens(aVG6Proc)

	aVG6Proc := {}

	VG6->(dbSetOrder(5))
	VG6->(dbSeek(xFilial("VG6") + VG8->VG8_CODMAR + VG8->VG8_NUMOSV + VG8->VG8_ANORRC + VG8->VG8_NUMRRC ))
	While !VG6->(Eof()) .and. VG6->VG6_FILIAL == VG8->VG8_FILIAL .AND. ;
							VG6->VG6_CODMAR == VG8->VG8_CODMAR .AND. ;
							VG6->VG6_NUMOSV == VG8->VG8_NUMOSV .AND. ;
							VG6->VG6_ANORRC == VG8->VG8_ANORRC .AND. ;
							VG6->VG6_NUMRRC == VG8->VG8_NUMRRC

		// Pecas ou servicos normais
		If VG6->VG6_ITEEXT == "0" .Or. VG6->VG6_SEREXT == "0"
			// Processa Pecas
			If !Empty(VG6->VG6_PECINT)

				AADD( aVG6Parts , Array(3) )
				nAuxPos := Len(aVG6Parts)
				aVG6Parts[nAuxPos, _Parts_PartNumber_    ] := AllTrim(VG6->VG6_CODITE)
				aVG6Parts[nAuxPos, _Parts_Quantity_      ] := VG6->VG6_QTDITE
				aVG6Parts[nAuxPos, _Parts_ExternalRowId_ ] := AllTrim(Str(VG6->(Recno())))

				AADD( aVG6Proc , VG6->(Recno()) )

			// Processa Servicos
			Else

				Do Case
	//				Case AllTrim(VG6->VG6_CODSER) $ cClawMeiaH
	//					nQtdeLabour := AllTrim(Str(Int(VG6->VG6_TPOGAR / 50)))
				Case VG6->VG6_QTDITE <> 0 // quantidade de requisicao do mesmo servico
					nQtdeLabour := VG6->VG6_QTDITE
				Otherwise
					nQtdeLabour := 1
				EndCase

				AADD( aVG6Labour , Array(5) )
				nAuxPos := Len(aVG6Labour)
				aVG6Labour[nAuxPos , _Labour_OperationCode_ ] := Val(VG6->VG6_CODSER)
				aVG6Labour[nAuxPos , _Labour_NoOfHours_     ] := VG6->VG6_TPOGAR / 100
				aVG6Labour[nAuxPos , _Labour_Quantity_      ] := nQtdeLabour
				aVG6Labour[nAuxPos , _Labour_Description_   ] := AllTrim(VG6->VG6_DESSER)
				aVG6Labour[nAuxPos , _Labour_ExternalRowId_ ] := AllTrim(Str(VG6->(Recno())))

				dDataReparo := GM060ULTDTAPONT(dDataReparo, VG8->VG8_NUMOSV, VG6->VG6_CODSER, VG6->VG6_TIPTEM, @nHoraReparo)

				AADD( aVG6Proc , VG6->(Recno()) )

			EndIf
		EndIf

		// Item Extra ou Servico Adicional
		If VG6->VG6_ITEEXT == "1" .or. VG6->VG6_SEREXT == "1"

			// Tempo não catalogado
			If VG6->VG6_TPCUST == "MO "

				AADD( aVG6_U_Labour , Array(3) )
				nAuxPos := Len(aVG6_U_Labour)
				aVG6_U_Labour[ nAuxPos , _LabourU_Description_     ] := AllTrim(VG6->VG6_DESSER)
				aVG6_U_Labour[ nAuxPos , _LabourU_NoOfHours_       ] := VG6->VG6_TPOGAR / 100
				aVG6_U_Labour[ nAuxPos , _LabourU_ExternalRowId_   ] := AllTrim(Str(VG6->(Recno())))
				//aVG6_U_Labour[ nAuxPos , _LabourU_CodeDescription_ ] := AllTrim(VG6->VG6_DESSER)

				dDataReparo := GM060ULTDTAPONT(dDataReparo, VG8->VG8_NUMOSV, VG6->VG6_CODSER, VG6->VG6_TIPTEM, @nHoraReparo)

				AADD( aVG6Proc , VG6->(Recno()) )

			Else

				AADD( aVG6_SpecCost , Array(4) )
				nAuxPos := Len(aVG6_SpecCost)
				aVG6_SpecCost[ nAuxPos , _SpecCost_Description_     ] := AllTrim(VG6->VG6_DESSER)
				aVG6_SpecCost[ nAuxPos , _SpecCost_CostAmount_      ] := VG6->VG6_VALSER
				aVG6_SpecCost[ nAuxPos , _SpecCost_TypeSpc_         ] := AllTrim(VG6->VG6_TPCUST)
				aVG6_SpecCost[ nAuxPos , _SpecCost_ExternalRowId_   ] := AllTrim(Str(VG6->(Recno())))
				//aVG6_SpecCost[ nAuxPos , _SpecCost_CodeDescription_ ] :=

				AADD( aVG6Proc , VG6->(Recno()) )

			EndIf

		EndIf

		VG6->(DbSkip())
	End

	dDataReparo := GM060DATAREPARO(dDataReparo, @nHoraReparo)

Return


/*/{Protheus.doc} GM060PLF05_DefSimple
Grava campos do cabecalho da solicitacao de garantia a ser transmitida
@author Rubens
@since 17/12/2018
@version 1.0
@param oWSDL, object, descricao
@param cSave, characters, descricao
@type function
/*/
Static Function GM060PLF05_DefSimple(oWSDL,cSave)

	//GM060PLF06_SetValue(oWSDL, aSimple, cParent, cParametro, uValor)
	oAuxGar:cSave                  := cSave
	oAuxGar:nDealerCode            := Val(GetNewPar("MV_MIL0005","0"))
 	oAuxGar:nClaimNumber           := Val(VG8->VG8_NUMRRC)
	oAuxGar:nClaimYear             := Val(VG8->VG8_ANORRC)
	oAuxGar:nFailureNumber         := Val("01") // Obs.: default 01 (para ‘Reclamação’ de Contrato de Reparo e Manutenção’)
	oAuxGar:cDealerRefNumber       := VG8->VG8_ANORRC + VG8->VG8_NUMRRC
	oAuxGar:cReconsiderationId     := IIf( VG8->VG8_RECONS == "1" , "S" , "N" )
	If !Empty(VG8->VG8_IDMODC)
		oAuxGar:cModuleCommonVersionId := Alltrim(VG8->VG8_IDMODC) // Identificador do Modulo a ser executado; Obs.: Identificador gerado pelo sistema MPP/MAC;
	EndIf
	If !Empty(VG8->VG8_IDPLAM)
		oAuxGar:cPlanCommonCode        := VG8->VG8_IDPLAM // Identificador do Plano de Manutenção; Obs.: Identificador gerado pelo sistema MPP/MAC;
	EndIf
	If VG8->VG8_TIPRRC <> "4" // Garantia de peca em estoque nao tem chassi ...
		oAuxGar:nChassiNumber       := Val( VV1->VV1_CHARED )
	EndIf
	oAuxGar:nEngineNumber          := VG8->VG8_MOTORE
	oAuxGar:nProductType           := Val( VG8->VG8_CODREC )
	oAuxGar:nWorkOrder             := Val( VG8->VG8_NUMOSV )
	oAuxGar:nDamageCausingPart     := Val( VG8->VG8_ITECAU )
	oAuxGar:cFaultCode             := Alltrim(VG8->VG8_CODDEF)
	oAuxGar:nMainGroup             := Val( VG8->VG8_GRUSER )
	//oAuxGar:nSubGroup :=
	oAuxGar:nNatureCode            := Val( VG8->VG8_CODGAR )

	oAuxGar:cDeliveryCodeId        := IIf( Empty(VG8->VG8_PRIREV) , "N" , "S" )
	oAuxGar:cDeliveryDate          := FormatDate(2, VG8->VG8_PRIREV, "" )

	oAuxGar:cExportVehicleId       := IIF( VG8->VG8_VEIEXP == "1" , "S" , "N" )

	oAuxGar:cRegistrationDate      := FormatDate(1, dDataBase ) + "T" + Time()

	//oAuxGar:cInvoiceDate :=
	oAuxGar:cMileageId             := "K" // 'H' – Horas (reclamações de Motores) / 'K' – Kilometros (diferente de Motores
	oAuxGar:nRepairMileage         := VG8->VG8_KILGAR
	oAuxGar:nPreviousMileage       := VG8->VG8_KILANT
	oAuxGar:nPickUpMileage         := VG8->VG8_KILPIC
	oAuxGar:nRoadRideMileage       := VG8->VG8_KILGUI

	oAuxGar:cRepairDate            := FormatDate(2, dDataReparo, nHoraReparo)

	If !Empty(VG8->VG8_REPANT)
		oAuxGar:cPreviousRepairDate := FormatDate(2, VG8->VG8_REPANT, "")
	EndIf

	oAuxGar:cScaniaAssistanceCase  := GM060NUMTOCHAR( VG8->VG8_CODPLU , "VG8_CODPLU" )
	oAuxGar:nCampaignCode          := VG8->VG8_CODCAM

	oAuxGar:cClaimReason           := AllTrim(E_MSMM(VG8->VG8_OBSMEM,GetSx3Cache("VG8_OBSERV", "X3_TAMANHO") ))

	oAuxGar:nFieldTestCode         := VG8->VG8_TESCPO

	If !Empty(VG8->VG8_CDTMOD)
		oAuxGar:cModuleTypeCode     := AllTrim(VG8->VG8_CDTMOD)
	EndIf

	oAuxGar:nPlannedMileage        := VG8->VG8_KMPLAN

Return

/*/{Protheus.doc} GM060PLF02_DefComplex
Inicializa propriedades da classe que receberao os itens da solicitacao de garantia
@author Rubens
@since 17/12/2018
@version 1.0
@param oAuxGar, object, descricao
@type function
/*/
Static Function GM060PLF02_DefComplex(oAuxGar)

	If Len(aVG6Parts) > 0
		oAuxGar:oWSParts       := MIL_ScaniaARMS_ArrayOfPartsType():New()
	EndIf
	If Len(aVG6Labour) > 0
		oAuxGar:oWSLabour      := MIL_ScaniaARMS_ArrayOfLabourType():New()
	EndIf
	If Len(aVG6_U_Labour) > 0
		oAuxGar:oWSLabourU     := MIL_ScaniaARMS_ArrayOfLabourUnsType():New()
	EndIf
	If Len(aVG6_SpecCost) > 0
		oAuxGar:oWSSpecialCost := MIL_ScaniaARMS_ArrayOfSpecialCostType():New()
	EndIf

Return

/*/{Protheus.doc} GM060PLF04_SetComplex
Adiciona os itens da solicitacao de garantia a ser transmitida

@author Rubens
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oAuxGar, object, descricao
@type function
/*/
Static Function GM060PLF04_SetComplex( oAuxGar )
	Local nPos
	Local oAuxItem

	For nPos := 1 to Len(aVG6Parts)
		oAuxItem := MIL_ScaniaARMS_PartsType():New()
		oAuxItem:cPartNumber    := aVG6Parts[ nPos , _Parts_PartNumber_    ]
		oAuxItem:nQuantity      := aVG6Parts[ nPos , _Parts_Quantity_      ]
		oAuxItem:cExternalRowId := aVG6Parts[ nPos , _Parts_ExternalRowId_ ]
		AADD(oAuxGar:oWSParts:oWSPartsType, oAuxItem )
	Next nPos

	For nPos := 1 to Len(aVG6Labour)
		oAuxItem := MIL_ScaniaARMS_LabourType():New()
		oAuxItem:nOperationCode := aVG6Labour[ nPos , _Labour_OperationCode_ ]
		oAuxItem:nNoOfHours     := aVG6Labour[ nPos , _Labour_NoOfHours_     ]
		oAuxItem:nQuantity      := aVG6Labour[ nPos , _Labour_Quantity_      ]
		oAuxItem:cExternalRowId := aVG6Labour[ nPos , _Labour_ExternalRowId_ ]
		oAuxItem:cDescription   := aVG6Labour[ nPos , _Labour_Description_ ]
		AADD(oAuxGar:oWSLabour:oWSLabourType, oAuxItem )
	Next nPos

	For nPos := 1 to Len(aVG6_U_Labour)
		oAuxItem := MIL_ScaniaARMS_LabourUnsType():New()
		oAuxItem:cDescription     := aVG6_U_Labour[ nPos , _LabourU_Description_   ]
		oAuxItem:nNoOfHours       := aVG6_U_Labour[ nPos , _LabourU_NoOfHours_     ]
//		oAuxItem:cCodeDescription := aVG6_U_Labour[ nPos , _LabourU_NoOfHours_     ]
		oAuxItem:cExternalRowId   := aVG6_U_Labour[ nPos , _LabourU_ExternalRowId_ ]
		AADD(oAuxGar:oWSLabourU:oWSLabourUnsType, oAuxItem )
	Next nPos

	For nPos := 1 to Len(aVG6_SpecCost)
		oAuxItem := MIL_ScaniaARMS_SpecialCostType():New()
		oAuxItem:cDescription     := aVG6_SpecCost[ nPos , _SpecCost_Description_     ]
		oAuxItem:nCostAmount      := aVG6_SpecCost[ nPos , _SpecCost_CostAmount_      ]
		oAuxItem:cTypeSpc         := aVG6_SpecCost[ nPos , _SpecCost_TypeSpc_         ]
//		oAuxItem:cCodeDescription := aVG6_SpecCost[ nPos , _SpecCost_CodeDescription_ ]
		oAuxItem:cExternalRowId   := aVG6_SpecCost[ nPos , _SpecCost_ExternalRowId_   ]
		AADD(oAuxGar:oWSSpecialCost:oWSSpecialCostType, oAuxItem )
	Next nPos

Return

/*/{Protheus.doc} GM060FaltaDados
Verifica se todos os itens obrigatorios foram informados
@author Rubens
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GM060FaltaDados()

	If Empty(VG8->VG8_NUMRRC)
		MsgInfo(STR0029,STR0005) // "Selecione um registro com número de RR"
		Return .t.
	EndIf

	If !Empty(VG8->VG8_RRCFAB)
		MsgInfo(STR0030,STR0005) // "Solicitação de garantia já foi transmitida para o Claw"
		Return .t.
	EndIf

Return .f.

/*/{Protheus.doc} GM060NUMTOCHAR
Transforma numerico para string
@author Rubens
@since 17/12/2018
@version 1.0
@param nValor, numeric, descricao
@param cCpoMascara, characters, descricao
@type function
/*/
Static Function GM060NUMTOCHAR(nValor,cCpoMascara)
Return AllTrim(Str(nValor,GetSx3Cache(cCpoMascara,"X3_TAMANHO"),GetSx3Cache(cCpoMascara,"X3_DECIMAL")))


/*/{Protheus.doc} GM060DATAREPARO
Retorna data do reparo da solicitacao de garantias
@author Rubens
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param dParDataReparo, date, descricao
@param nParHoraReparo, numeric, descricao
@type function
/*/
Static Function GM060DATAREPARO(dParDataReparo, nParHoraReparo)

	Default nParHoraReparo := 0

	// Se nao encontrar data de reparo considerar a ultima data de requisicao de pecas ...
	If dParDataReparo <> CtoD("01/01/1990")
		Return dParDataReparo
	EndIf

	VG6->(dbSetOrder(5))
	VG6->(dbSeek(xFilial("VG6") + VG8->VG8_CODMAR + VG8->VG8_NUMOSV + VG8->VG8_ANORRC + VG8->VG8_NUMRRC ))
	While !VG6->(Eof()) .and. VG6->VG6_FILIAL == VG8->VG8_FILIAL .AND. ;
									VG6->VG6_CODMAR == VG8->VG8_CODMAR .AND. ;
									VG6->VG6_NUMOSV == VG8->VG8_NUMOSV .AND. ;
									VG6->VG6_ANORRC == VG8->VG8_ANORRC .AND. ;
									VG6->VG6_NUMRRC == VG8->VG8_NUMRRC

		// Procura a ultima requisicao de pecas
		If (VG6->VG6_ITEEXT == "0" .Or. VG6->VG6_SEREXT == "0") .and. !Empty(VG6->VG6_PECINT)
			cSQL := "SELECT VO2_DATREQ, VO2_HORREQ "
			cSQL += " FROM " + RetSQLName("VO3") + " VO3"
			cSQL += " JOIN " + RetSQLName("VO2") + " VO2"
			cSQL +=        " ON VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
			cSQL +=       " AND VO2.VO2_NOSNUM = VO3_NOSNUM "
			cSQL +=       " AND VO2.D_E_L_E_T_ = ' ' "
			cSQL += " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
			cSQL +=   " AND VO3.VO3_NUMOSV = '" + VG8->VG8_NUMOSV + "'"
			cSQL +=   " AND VO3.VO3_TIPTEM = '" + VG6->VG6_TIPTEM + "'"
			cSQL +=   " AND VO3.VO3_GRUITE = '" + VG6->VG6_GRUITE + "'"
			cSQL +=   " AND VO3.VO3_CODITE = '" + VG6->VG6_CODITE + "'"
			cSQL +=   " AND VO3.D_E_L_E_T_ = ' '"
			cSQL += " ORDER BY VO2.VO2_DATREQ DESC, VO2.VO2_HORREQ DESC "
			TCQUERY cSQL NEW ALIAS "TULTREQ"
			If !TULTREQ->(Eof()) .and. StoD(TULTREQ->VO2_DATREQ) > dParDataReparo
				dParDataReparo := StoD(TULTREQ->VO2_DATREQ)
				nParHoraReparo := TULTREQ->VO2_HORREQ
			EndIf
			TULTREQ->(dbCloseArea())

		EndIF
		//

		VG6->(dbSkip())
	End

	// Se nao houver requisicao, considera a data de abertura da OS
	If dParDataReparo == CtoD("01/01/1990")
		dParDataReparo := VO1->VO1_DATABE
		nParHoraReparo := VO1->VO1_HORABE
	EndIf
	//

	// Quando informado a data de Reparo na Garantia, ela será utilizada na transmissão do Claw
	If !Empty(VG8->VG8_DTREPA)
		dParDataReparo := VG8->VG8_DTREPA
		nParHoraReparo := 0
	EndIf

Return dParDataReparo


/*/{Protheus.doc} GM060ULTDTAPONT
Retorna o ultimo apontamento da OS
@author Rubens
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param dParDataReparo, date, descricao
@param cNumosv, characters, descricao
@param cCodSer, characters, descricao
@param cTipTem, characters, descricao
@param nParHoraReparo, numeric, descricao
@type function
/*/
Static Function GM060ULTDTAPONT(dParDataReparo, cNumosv, cCodSer, cTipTem, nParHoraReparo)
	Local cSQL

	If !Empty(cCodSer) .and. !Empty(cTipTem)
		cSQL := "SELECT VO4_DATFIN DATFIN , VO4_HORFIN HORFIN" +;
				  " FROM " + RetSQLName("VO4") + " VO4 " +;
				 " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'" + ;
				   " AND VO4.VO4_NUMOSV = '" + cNumOsv + "'" + ;
				   " AND VO4.VO4_CODSER = '" + cCodSer + "'" + ;
				   " AND VO4.VO4_TIPTEM = '" + cTipTem + "'" + ;
				   " AND VO4.VO4_DATCAN <> '        ' " + ;
				   " AND VO4.D_E_L_E_t_ = ' ' " +;
				 " ORDER BY VO4_DATFIN DESC, VO4_HORFIN DESC"
		TCQUERY cSQL NEW ALIAS "TULTAPONT"
		If !TULTAPONT->(Eof()) .and. StoD(TULTAPONT->DATFIN) > dParDataReparo
			dParDataReparo := StoD(TULTAPONT->DATFIN)
			nParHoraReparo := TULTAPONT->HORAFIN
		EndIf
		TULTAPONT->(dbCloseArea())
	EndIf

Return dParDataReparo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Fabio               º Data ³  08/23/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Menu									                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { STR0002 ,"axPesqui" , 0 , 1},;
				   { STR0003 ,"GM060"    , 0 , 2},;  // VIZUALIZAR
				   { STR0010 ,"GM060"    , 0 , 3},;  // INCLUIR
				   { STR0004 ,"GM060"    , 0 , 4} }  // ALTERAR

AADD( aRotina , { STR0018 , "GM060TRA"  , 0 , 4 } )  // "Trans. Gar. - Claw"
AADD( aRotina , { STR0019 , "GM060IRC"  , 0 , 3 } )  // "Imp. Recons. - Claw"
AADD( aRotina , { STR0020 , "GM060CLAW" , 0 , 2 } )  // "Acessar Claw"
AADD( aRotina , { STR0021 , "GM060ATU"  , 0 , 4 } )  // "Atual. Gar. - Claw"
AADD( aRotina , { STR0013 , "GM060PSW"  , 0 , 6 } )  // "Alt. Senha - Claw"
AADD( aRotina , { STR0056 , "GM060PLF"  , 0 , 4 } ) // "Planos Flexiveis"

Return aRotina

/*/{Protheus.doc} OGM060011_TudoOk_PE
	Chamada do Ponto de Entrada para fazer o Tudo OK customizado
	
	@type function
	@author Andre Luis Almeida
	@since 06/05/2022
/*/
Static Function OGM060011_TudoOk_PE(nOpc)
Local lRet := .t.
If ( ExistBlock("OM060TOK") )
	lRet := ExecBlock("OM060TOK",.f.,.f.,{nOpc})
EndIf
Return lRet