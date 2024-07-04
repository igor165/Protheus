#INCLUDE "HSPAHA91.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HSPAHA91 ³ Autor ³ Eduardo Alves         ³ Data ³ 22/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grupo de Perguntas x Perguntas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAHA91(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Eduardo Alves³23/03/06³ XXXX ³Implantacao das funcoes                 ³±±
±±³              ³        ³      ³   - HS_Bdados()                        ³±±
±±³              ³        ³      ³   - MsNewGwtDados()                    ³±±
±±³ Eduardo Alves³23/06/06³ XXXX ³Verificação na GFT antes de excluir ou  ³±±
±±³              ³        ³      ³alterar os dados.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHA91()

Private aRotina := MenuDef()

Private cCadastro := OemToAnsi(STR0006) //"Grupo Perguntas X Perguntas"

DbSelectArea("GCO")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"GCO",,,,,,)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_A91    ºAutor  ³Eduardo Alves       º Data ³  03/22/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Funcao de Tratamento do Cadastro de Grupo de Precaucoes    ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_A91(cAlias, nReg, nOpc)

Local nOpA 		:= ""
Local nGDOpc := IIf( Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
Local nLenGD := 0

Private aTela := {}, aGets := {}
Private aHGCG := {}, aCGCG := {}, nUGCG := 0
Private oDlg, oGCG, oEnchoi

RegToMemory("GCO", (nOpc == 3))
	
nLenGD := HS_BDados("GCG", @aHGCG, @aCGCG, @nUGCG, 1, M->GCO_GRPPER, IIf((nOpc == 3), Nil, "'" + M->GCO_GRPPER + "' == GCG->GCG_GRPPER"))
 
nGCG_ITEM   := aScan(aHGCG, {| aVet | AllTrim(aVet[2]) == "GCG_ITEM"})
nGCG_CODPER := aScan(aHGCG, {| aVet | AllTrim(aVet[2]) == "GCG_CODPER"})
nGCG_DESPER := aScan(aHGCG, {| aVet | AllTrim(aVet[2]) == "GCG_DESPER"})
nGCG_STATUS := aScan(aHGCG, {| aVet | AllTrim(aVet[2]) == "GCG_STATUS"})
 
If (nOpc == 3) .Or. ((nOpc == 4) .And. (nLenGD == 0))
	aCGCG[1, nGCG_ITEM] := Soma1(aCGCG[1, nGCG_ITEM], Len(aCGCG[1, nGCG_ITEM]))
EndIf
 
aSize 		:= MsAdvSize(.T.)
aObjects	:= {}
 
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T. } )
 
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
  
	oEnchoi := MsMGet():New("GCO",nReg,nOpc, , , , ,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , , ,oDlg)
	oEnchoi :oBox:align:= CONTROL_ALIGN_TOP

	oGCG := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,"+GCG_ITEM",,, 99999,,,, oDlg, aHGCG, aCGCG)
	oGCG:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
	oGCG:bLinhaOk      := {|| HS_DuplAC(oGCG:oBrowse:nAt, oGCG:aCols, {nGCG_CODPER}) }
  
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {	|| nOpA := 1,;
                                                  	IIF(Obrigatorio(aGets, aTela) .And. oGCG:TudoOk(), oDlg:End(), nOpA := 0)},;
                                               		{|| nOpA := 0, oDlg:End()})

If (nOpA == 1) .And. (nOpc <> 2)
	Begin Transaction
		FS_GrvA91(aHGCG, nUGCG)
	End Transaction
EndIf
                                                            
Return(Nil)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GrvA91 ºAutor  ³Eduardo Alves       º Data ³  23/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Funcao de Gravacao ou Exclusao dos Dados    				  ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GrvA91(aHGCG, nUGCG)

Local nForGrv		:= 0
Local lFoundGCG		:= .F.
Local nPosOrdPer	:= aScan(aHGCG, {|aVet| aVet[2] == "GCG_ORDPER"})
 
// Grava dados da Enchoice

If Inclui .Or. Altera
 	
//	If Altera
	/* Verifica se existe relacionamento com a tabela GFT - GRUPO PERGUNTASXQUEST ANAMNESE*/
//		If HS_CountTB("GFT", "GFT_GRPPER = '" + GCO->GCO_GRPPER + "'") > 0
//			HS_MsgInf(STR0011, STR0009, STR0012) //"Alteração não permitida pois este Grupo de Perguntas possui relacionamento com Questionário de Anamnese"###"Atenção"###"Alteração dos Dados"
//			Return(.F.)
//		EndIf
//	EndIf

	RecLock("GCO", Inclui)
		HS_GrvCpo("GCO")
		GCO->GCO_FILIAL := xFilial("GCO")
		GCO->GCO_LOGARQ := HS_LogArq()
	MsUnLock()
 
	// Exclui dados da Enchoice
Else
  
	/* Verifica se existe relacionamento com a tabela GA7 - Cadastro de Procedimento. */
	DbSelectArea("GA7")
	DBSetOrder(5)
	If DbSeek(xFilial("GA7") + GCO->GCO_GRPPER)
		HS_MsgInf(STR0008, STR0009, STR0010)//"Este Codigo esta sendo usado pelo Cadastro de Procedimento. Impossivel Exclui-lo!"###"Atencao"###"Exclusao nao Permitida"
		Return(.F.)
	EndIf
  
	/* Verifica se existe relacionamento com a tabela GFT - GRUPO PERGUNTASXQUEST ANAMNESE*/
	If HS_CountTB("GFT", "GFT_GRPPER = '" + GCO->GCO_GRPPER + "'") > 0
		HS_MsgInf(STR0013, STR0009, STR0014) //"Exclusão não permitida pois este Grupo de Perguntas possui relacionamento com Questionário de Anamnese"###"Atenção"###"Exclusão dos Dados"
		Return(.F.)
	EndIf
		
	DbSelectArea("GCO")
	DBSetOrder(1)
	RecLock("GCO", .F., .T.)
		DbDelete()
	MsUnlock()
	WriteSx2("GCO")

EndIf
 
// Grava, altera ou exclui dados do Grid
  
For nForGrv := 1 To Len(oGCG:aCols)
  
	DbSelectArea("GCG")
	DBSetOrder(1)
  
	lFoundGCG := DbSeek(xFilial("GCG") + M->GCO_GRPPER + oGCG:aCols[nForGrv, nGCG_ITEM])
  
	If Inclui .Or. Altera
  
	//Se registro foi encontrado da tabela, mas o usuario marcou como deletado, entao exclui da tabela.
		If (oGCG:aCols[nForGrv, nUGCG + 1]) .And. (lFoundGCG)
			RecLock("GCG", .F., .T.)
				DbDelete()
			MsUnlock()
			WriteSx2("GCG")
		Else
			//Verifica se a linha nao foi deletada no Grid, entao inicia a gravacao.
			If !oGCG:aCols[nForGrv, Len(oGCG:aCols[nForGrv])]
    
				RecLock("GCG", !lFoundGCG)
					HS_GrvCpo("GCG", oGCG:aCols, aHGCG, nForGrv)
					GCG->GCG_FILIAL := xFilial("GCG")
					GCG->GCG_GRPPER := M->GCO_GRPPER
					GCG->GCG_ORDPER := STRZERO(VAL(oGCG:aCols[nForGrv,nPosOrdPer]),3)
					GCG->GCG_LOGARQ := HS_LogArq()
				MsUnlock()	
	    
			EndIf 	  
		EndIf  
	Else  	
		// Exclui linha(s)
		If lFoundGCG
			RecLock("GCG", .F., .T.)
				DbDelete()
			MsUnlock()
			WriteSx2("GCG")       
		EndIf   
	EndIf
Next   
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 06/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{ OemToAnsi(STR0001),	"AxPesqui",	0, 1, 0, nil},;		//"Pesquisar"
					 { OemToAnsi(STR0002),	"HS_A91"  ,	0, 2, 0, nil},;		//"Visualizar"
					 { OemToAnsi(STR0003),	"HS_A91"  ,	0, 3, 0, nil},;		//"Incluir"
					 { OemToAnsi(STR0004),	"HS_A91"  ,	0, 4, 0, nil},;		//"Alterar"
					 { OemToAnsi(STR0005),	"HS_A91"  ,	0, 5, 0, nil} }		//"Excluir"
Return(aRotina)