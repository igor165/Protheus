#INCLUDE "HSPAHA85.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HSPAHA85 ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 10.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grupo de Precaucoes x Precaucoes                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HSPAHA85(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Eduardo Alves³23/03/06³ XXXX ³  Implantacao das funcoes               ³±±
±±³              ³        ³      ³   - HS_Bdados()                        ³±±
±±³              ³        ³      ³   - MsNewGwtDados()                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHA85()

Private aRotina :=	MenuDef()

Private cCadastro := OemToAnsi(STR0006) //"Grupo Precaucoes X Precaucoes"

DbSelectArea("GCJ")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"GCJ",,,,,,)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_A85    ºAutor  ³Eduardo Alves       º Data ³  03/22/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Funcao de Tratamento do Cadastro de Grupo de Precaucoes    ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_A85(cAlias, nReg, nOpc)
	Local nOpA
	Local nGDOpc := IIf(Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
	Local nLenGD := 0
	
	Private aTela 		:= {}, aGets := {}
 Private aHeader	:= {}, aCols := {}, nUsado := 0 	//Variaveis utilizadas na funcao HS_BDados
 Private oGCI 																																					//Variavel utilizada para criacao do objeto MSGetDados()
	
	// Funcao utilizada para alocar o conteudo da tabela pai na memoria, para ser utilizada na funcao HS_BDados
	RegToMemory("GCJ", (nOpc == 3)) 
	
	// Carrega as variaveis para a funcao MSGetDados(), ou seja, tabela filho que aparecera do Grid
	nLenGD := HS_BDados("GCI", @aHeader, @aCols, @nUsado, 1, M->GCJ_GRPPRE, IIf((nOpc == 3), Nil, "'" + M->GCJ_GRPPRE + "' == GCI->GCI_GRPPRE"))//
 
 // Obs.: O Status do campo X3_BROWSE deve ser igual a "S"
 nGCI_ITEM   := aScan(aHeader, {| aVet | AllTrim(aVet[2]) == "GCI_ITEM"})
 nGCI_CODPRE := aScan(aHeader, {| aVet | AllTrim(aVet[2]) == "GCI_CODPRE"})
 nGCI_DESPRE := aScan(aHeader, {| aVet | AllTrim(aVet[2]) == "GCI_DESPRE"})
 nGCI_STATUS := aScan(aHeader, {| aVet | AllTrim(aVet[2]) == "GCI_STATUS"})
 
 // Atribui o valor 001 ao campo GCI_ITEM em caso de inclusao, apenas na primeira linha do Grid, Ou em caso de alteracao e o Grid vazio.
 If (nOpc == 3) .Or. ((nOpc == 4) .And. (nLenGD == 0))
  aCols[1, nGCI_ITEM] := Soma1(aCols[1, nGCI_ITEM], Len(aCols[1, nGCI_ITEM])) 
 EndIf 
 
 aSize 			:= MsAdvSize(.T.)
 aObjects := {}
 
 AAdd( aObjects, { 100, 040, .T., .T. } )	
 AAdd( aObjects, { 100, 060, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )        
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
  
  oEnchoi := MsMGet():New("GCJ",nReg,nOpc, , , , ,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , , ,oDlg)
  oEnchoi :oBox:align:= CONTROL_ALIGN_TOP    

  oGCI := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,"+GCI_ITEM",,, 99999,,,, oDlg, aHeader, aCols)
  oGCI:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
		oGCI:bLinhaOk      := {|| HS_DuplAC(oGCI:oBrowse:nAt, oGCI:aCols, {nGCI_CODPRE}) }         
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {	|| nOpA := 1,;
                                                    	IIF(Obrigatorio(aGets, aTela) .And. oGCI:TudoOk(), oDlg:End(), nOpA := 0)},;  
                                                   		{|| nOpA := 0, oDlg:End()})


// Em caso de Inclusao , Alteracao ou Exclusao e o botao OK pressionado.
If (nOpA == 1) .And. (nOpc <> 2)
 Begin Transaction
  FS_GrvA85(aHeader, nUsado)
 End Transaction 
EndIf
                                                            
Return(Nil)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_A85    ºAutor  ³Eduardo Alves       º Data ³  23/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Funcao de Gravacao ou Exclusao dos Dados    															 ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GrvA85(aHeader, nUsado)

 Local nForGrv := 0
 Local lFoundGCI := .F.
 
 // Grava dados da Enchoice

 If Inclui .Or. Altera

  RecLock("GCJ", Inclui)
   HS_GrvCpo("GCJ")
   GCJ->GCJ_FILIAL := xFilial("GCJ")
   GCJ->GCJ_LOGARQ := HS_LogArq()
  MsUnLock() 
 
 // Exclui dados da Enchoice
 Else 
  
  DbSelectArea("GA7")
		DBSetOrder(6)
		
		// Verifica se existe relacionamento com a tabela GA7 - Cadastro de Procedimento.  
  If !DbSeek(xFilial("GA7") + GCJ->GCJ_GRPPRE) 

  	DbSelectArea("GCJ")
  	DBSetOrder(1)

  	RecLock("GCJ", .F., .T.)
   	DbDelete()
  	MsUnlock()
  	WriteSx2("GCJ") 
		Else
			HS_MsgInf(STR0009, STR0008, STR0010)//"Este Codigo esta sendo usado pelo Cadastro de Procedimento. Impossivel Exclui-lo!"###"Atencao"###"Exclusão não Permitida"
			Return(.F.)
		EndIf  
 
 Endif
 
 // Grava, altera ou exclui dados do Grid
  
 For nForGrv := 1 To Len(oGCI:aCols)
  
  DbSelectArea("GCI")
  DBSetOrder(3)
  
  lFoundGCI := DbSeek(xFilial("GCI") + M->GCJ_GRPPRE + oGCI:aCols[nForGrv, nGCI_CODPRE])
  
  If Inclui .Or. Altera
   
   // Se registro foi encontrado da tabela, mas o usuario marcou como deletado, entao exclui da tabela.
   If (oGCI:aCols[nForGrv, nUsado + 1]) .And. (lFoundGCI)

    RecLock("GCI", .F., .T.)
     DbDelete()
    MsUnlock()
    WriteSx2("GCI")
  	
  	Else
    
    //Verifica se a linha nao foi deletada no Grid, entao inicia a gravacao.
    If !oGCI:aCols[nForGrv, Len(oGCI:aCols[nForGrv])] 

  			DBSetOrder(1)
					lFoundGCI := DbSeek(xFilial("GCI") + M->GCJ_GRPPRE + oGCI:aCols[nForGrv, nGCI_ITEM])

	    RecLock("GCI", If(lFoundGCI, .F., .T.))
	     HS_GrvCpo("GCI", oGCI:aCols, aHeader, nForGrv)
	     GCI->GCI_FILIAL := xFilial("GCI")
	     GCI->GCI_GRPPRE := M->GCJ_GRPPRE
	     GCI->GCI_LOGARQ := HS_LogArq()
	    MsUnlock()
	
	   EndIf 
	  
	  EndIf
  
  Else  	
   
   // Exclui linha(s)
   If lFoundGCI
    
    RecLock("GCI", .F., .T.)
     DbDelete()
    MsUnlock()
    WriteSx2("GCI")       
   
   Endif   
  
  Endif
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
Local aRotina :=	{{ OemToAnsi(STR0001),	"AxPesqui",	0, 1, 0, nil},; //"Pesquisar"
					 { OemToAnsi(STR0002),	"HS_A85"  ,	0, 2, 0, nil},; //"Visualizar"
					 {	OemToAnsi(STR0003),	"HS_A85"  ,	0, 3, 0, nil},; //"Incluir"
					 { OemToAnsi(STR0004),	"HS_A85"  ,	0, 4, 0, nil},; //"Alterar"
					 {	OemToAnsi(STR0005),	"HS_A85"  ,	0, 5, 0, nil}}  //"Excluir"
Return(aRotina)