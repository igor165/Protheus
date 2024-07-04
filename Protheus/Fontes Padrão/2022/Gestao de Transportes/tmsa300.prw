#INCLUDE  "tmsa300.ch"
#include  "PROTHEUS.ch"

STATIC aFolder := {}  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Tabela de Seguro                                           บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ TMSA300()                                                 บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ Nenhum                                                    บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ NIL                                                       บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ Estrutura do Array de Folders                             บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑบ            บ [1] -> Tipo "N" , Numero do Folder                        บฑฑ
ฑฑบ            บ [2] -> Tipo "C" , Titulo do Folder                        บฑฑ
ฑฑบ            บ [3] -> Tipo "A" , aColsRecno ( Recno() de cada aCols )    บฑฑ
ฑฑบ            บ [4] -> Tipo "A  , aHeader   da GetDados do Folder         บฑฑ
ฑฑบ            บ [5] -> Tipo "A" , aCols     da GetDados do Folder         บฑฑ
ฑฑบ            บ [6] -> Tipo "C" , cLinhaOk  da GetDados do Folder         บฑฑ
ฑฑบ            บ [7] -> Tipo "C" , cTudoOk   da GetDados do Folder         บฑฑ
ฑฑบ            บ [8] -> Tipo "O" , oGetDados deste Folder                  บฑฑ
ฑฑบ            บ [9] -> Tipo "A" , Campos que podem ser alterados          บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑบ            บ Possui 2 pontos de Entrada TMSA300A e TMSA300B            บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION TMSA300(nRotina)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local aSavARot := If( Type("aRotina")  !="U",aRotina,	{}	)
Local cSavcCad := If( Type("cCadastro")!="U",cCadastro,"" )
Local aArea		:= GetArea()

Private cCadastro := STR0001 //"Tabela de Seguro"
Private aRotina	:=	MenuDef()

Mbrowse( 6, 1, 22, 75, "DU4")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura os dados de entrada                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RestArea( aArea )
aRotina   := aSavARot
cCadastro := cSavcCad

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Manutencao da Tabela de Seguro                             บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ  TMSA300Mnt( cAlias, nReg, nOpcx )                        บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ                                         			       บฑฑ
ฑฑบ         01 บ cAlias - Alias do arquivo                                 บฑฑ
ฑฑบ         02 บ nReg   - Registro do Arquivo                              บฑฑ
ฑฑบ         03 บ nOpcx  - Opcao da MBrowse                                 บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ NIL                                                       บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ                                                           บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TMSA300Mnt(cAlias,nReg,nOpcx)
      
Local aArea     := GetArea()
Local aAreaDUX  := DUX->( GetArea() )

Local aInfo     := {}
Local aPosObj   := {} 
Local aObjects  := {}                        
Local aSize     := MsAdvSize() 

Local aTitles   := {}
Local aPages    := {}

Local cCadastro := STR0001 //"Tabela de Seguro"

Local nGd1      := 0 
Local nGd2      := 0 
Local nGd3      := 0 
Local nGd4      := 0 
Local nLoop     := 0 

Local oDlg
Local oFolder
Local oEnchoice
Local nOpca		 := 0
Local cSeekKey
Local nOpc
Local cContrato
Local cItem
Local aAlter

Private nFolder := 1
Private aHeader := {}
Private aCols   := {}
Private aGets   := {}
Private aTela   := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define as posicoes da Getdados a partir do folder    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aObjects := { { 100, 065, .T., .T. },;
					{ 100, 100, .T., .T. } }

aInfo		:= { aSize[1], aSize[2], aSize[3], aSize[4], 5, 5 } 

aPosObj	:= MsObjSize( aInfo, aObjects, .T. ) 

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[2,3]-aPosObj[2,1]-15 
nGd4 := aPosObj[2,4]-aPosObj[2,2]-4 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega Enchoice ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RegToMemory( "DU4", nOpcx == 3 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega Folder   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

TMSA300Fol( nOpcx )

If Len(aFolder)==0
	Help("",1,"TMSA30002") //-- Nao Existem componentes cadastrados para a tabela de seguro ...
	Return Nil
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona Titles e Pages ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Aeval( aFolder, { | aFolderLine | 	Aadd( aTitles, aFolderLine[2] ), Aadd( aPages,  "AHEADER" ) } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem da Tela  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Desenha Enchoice ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oEnchoice := MsMGet():New( cAlias ,nReg, nOpcx, , , , , aPosObj[1], aAlter, 3,,,,,, .T. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Desenha Folders  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oFolder := TFolder():New(	aPosObj[2,1],aPosObj[2,2],aTitles,aPages, oDlg,,,,.T.,.F.,;
									aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega as GetDados na Ordem INVERSA de Apresentacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

For nLoop := Len( aFolder ) TO 1 STEP - 1
	aHeader := aClone( aFolder[nLoop][4] )
	aCols   := aClone( aFolder[nLoop][5] )
	aFolder[nLoop][8] := MSGetDados():New(	nGd1,nGd2,nGd3,nGd4,nOpcx,;
															aFolder[nLoop][6],aFolder[nLoop][7],"",nOpcx!=2,aFolder[nLoop][9],,,,,,,,;
															oFolder:aDialogs[nLoop]	)

	aFolder[nLoop][8]:oBrowse:lDisablePaint := .T.
	aFolder[nLoop][8]:nMax := 99999 //-- Qtde. de linhas


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Acerta OBRIGAT da MsGetDadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	TMSObgGetDados( aFolder[nLoop][8] )

Next nI	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Habilita o Trocador de Folderณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oFolder:bSetOption:={|nAtu| TMSA300Chg( nAtu, oFolder:nOption ) }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Chama Localizador de Folder Ativo ณ
//ณ Desenha a EnchoiceBar             ณ
//ณ Ativa Obrigat da Enchoice         ณ
//ณ Ativa Obrigat das GetDados        ณ
//ณ Ativa Dialog  Principal           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

ACTIVATE MSDIALOG oDlg ON INIT ( TMSA300Loc( nOpcx, oFolder, aFolder),;                                                                                                                
									TMSA300Bar(oDlg, {||nOpca:=1,If(TMSA300Ok(oFolder:nOption, nOpcx) ,;
											If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},;
												{||oDlg:End()}, nOpcx) )

If nOpcx!= 2 .And. nOpca==1

	Begin Transaction      
		                           	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Efetua a Gravacao de Tudo    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		TMSA300Grv( nOpcx )
		If ( __lSX8 )
			ConfirmSX8()
		EndIf
		EvalTrigger()
			
	End Transaction
Else
	If ( __lSX8 )
		RollBackSX8()
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a integridade dos dados                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MsUnLockAll()
RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Troca de Folder							 				   บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ  TMSA300Chg( nTargetFolder, nSourceFolder )               บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ                                         			       บฑฑ
ฑฑบ         01 บ nTargetFolder - Folder Destino                            บฑฑ
ฑฑบ         02 บ nSourceFolder - Folder Atual                              บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ .T. se a Troca de Folder foi permitida                    บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ Checa a validacao da Getdados Atual e copia corretamente  บฑฑ
ฑฑบ            บ aHeader e Acols dos Folders Atual e Destino               บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION TMSA300Chg( nTargetFolder, nSourceFolder )

Local nI
Local lRetorno
Local lEmpty 	:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se a GetDados nao esta deletada ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If !Acols[1][Len(aHeader)+1]

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ VerIfica se os campos obrigatorios estao vaziosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
																						Empty( aCols[1][aPosCol[2]] ), ;
																						lEmpty := .T.	, NIL ) } )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se TODOS estiverem vazios e nao sofre modIficacao ณ
	//ณ deleta para passar no 'OBRIGAT' 						ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If lEmpty .AND. ! aFolder[nSourceFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .T.
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua a Validacao da GetDados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If ( lRetorno := aFolder[nSourceFolder][8]:TudoOk() ) 

	aFolder[nSourceFolder][8]:oBrowse:lDisablePaint := .T.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava aHeader e Acols do Afolder com as mudancas     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aFolder[nSourceFolder][4] := aClone( aHeader )
	aFolder[	nSourceFolder][5] := aClone( aCols )
	n := Max( aFolder[nTargetFolder][8]:oBrowse:nAt,1)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava aHeader e Acols a partir do aFolder            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aHeader := aClone( aFolder[nTargetFolder][4] )
	aCols   := aClone( aFolder[nTargetFolder][5] )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ VerIfica se os campos obrigatorios estao vaziosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

   lEmpty := .F.
	Aeval( aFolder[nTargetFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
																						Empty( aCols[1][aPosCol[2]] ), ;
																						lEmpty := .T.	, NIL ) } )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se TODOS estiverem vazios e nao sofre modIficacao ณ
	//ณ dah RECALL porque esta funcao DELETOU !!          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If aCols[1][Len(aHeader)+1] .AND. lEmpty .AND. ;
      ! aFolder[nTargetFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .F.
	EndIf

	aFolder[nTargetFolder][8]:oBrowse:lDisablePaint := .F.
	aFolder[nTargetFolder][8]:oBrowse:Refresh(.T.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seta Variavel Private nFolder para o Folder Target ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	nFolder := nTargetFolder

EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Gravacao da Enchoice e das GetDados dos Folders            บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ TMSA300Grv( nOpcx, cMasterAlias, cSlaveAlias,  ;          บฑฑ
ฑฑบ            บ             nSlaveOrder, cSlaveSeek, bSlaveFor,;          บฑฑ
ฑฑบ            บ             bSlaveWhile, bMasterRec, bSlaveRec  )         บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ                                         			       บฑฑ
ฑฑบ         01 บ nOpcx        - Opcao do aRotina                           บฑฑ
ฑฑบ         02 บ cMasterAlias - Alias da Enchoice ( Pai )                  บฑฑ
ฑฑบ         03 บ cSlaveAlias  - Alias da GetDados ( Filhos )               บฑฑ
ฑฑบ         04 บ nSlaveOrder  - Ordem para Pesquisa dos Filhos             บฑฑ
ฑฑบ         05 บ cSlaveSeek   - Chave para Pesquisa dos Filhos             บฑฑ
ฑฑบ         06 บ cSlaveFor    - 'For' para Pesquisa dos Filhos             บฑฑ
ฑฑบ         07 บ bSlaveWhile  - 'While' para Pesquisa dos Filhos           บฑฑ
ฑฑบ         08 บ bMasterRec   - Gravacao de campos adicionais no Master    บฑฑ
ฑฑบ         09 บ cbSlaveRec   - Gravacao de campos adicionais no Slave     บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ .T. se a Troca de Folder foi permitida                    บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ - Efetua a gravacao de TUDO, Enchoice e Todas as GetDados บฑฑ
ฑฑบ            บ - O campo cbSlaveRec eh uma String porem em ForMATO de    บฑฑ
ฑฑบ            บ codeblock, porque o ultimo parametro eh o nome do campo   บฑฑ
ฑฑบ            บ que vai armazenar o Numero do Folder.                     บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION TMSA300Grv(nOpcx, cMasterAlias, cSlaveAlias, nSlaveOrder, ;
									cSlaveSeek, bSlaveFor, bSlaveWhile, bMasterRec, cbSlaveRec  )

Local aArea      		:=	GetArea()
Local lRetorno   		:=	.T. 
Local aNoEmptyField	

Default cMasterAlias :=	"DU4"
Default cSlaveAlias	:=	"DU5"
Default nSlaveOrder	:=	1
Default cSlaveSeek	:=	M->DU4_FILIAL + M->DU4_TABSEG + M->DU4_TPTSEG

Default bSlaveFor    := { || .T. } 
Default bSlaveWhile	:= { || 	DU5->DU5_FILIAL + DU5->DU5_TABSEG + DU5->DU5_TPTSEG + DU5->DU5_COMSEG}
Default bMasterRec   := { || NIL } 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Campos a serem gravados alem do ACOLS ( Slave )  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Default cbSlaveRec   := "{ || " + ; 
								"DU5->DU5_TABSEG := M->DU4_TABSEG , DU5->DU5_TPTSEG := M->DU4_TPTSEG, " +;
								"DU5->DU5_COMSEG := '"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao das Getdados ( Slave )ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If nOpcx <> 5 // Deleta
	Aeval( aFolder, { |aFolderGetDados, nI, cFolder | cFolder := aFolderGetDados[1], bRecFields := &(cbSlaveRec + cFolder + "' }"), ;
																		TMSRecGetDados( 	cSlaveAlias, aFolderGetDados[3], aFolderGetDados[4], ;
																		aFolderGetDados[5], bRecFields, aNoEmptyFields ) } )
Else
	( cSlaveAlias )->( dbSetOrder( nSlaveOrder ) )
	( cSlaveAlias )->( MsSeek( cSlaveSeek	) )
	( cSlaveAlias )->( dbEval( { ||	RecLock( cSlaveAlias, .F. ), dbDelete(), MsUnlock() },bSlaveFor, ;
												{ || 	!Eof() .AND. Eval( bSlaveWhile ) = cSlaveSeeK } ) )												
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao da Enchoice ( Master )ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RecLock( cMasterAlias, nOpcx== 3 )

If nOpcx <> 5
	Aeval( dbStruct(), { |	aFieldName, nI | 	FieldPut( nI, ;
															If( 	'FILIAL' $ aFieldName[1],;
																	xFilial( cMasterAlias ), ;
																	M->&( aFieldName[1] ) ) ) } ) 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGravacao Adicional da Enchoice se houver ( Master )ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Eval( bMasterRec )
Else
	dbDelete()   
	
EndIf

MsUnLockAll()
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Valida Tudo antes da Gravacao                              บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ TMSA300Ok( nSourceFolder, nOpcx )                         บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ nSourceFolder - Folder Atual              			       บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ .T. se a validacao foi aceita                             บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ - Valida Folder a Folder comecando pelo atual             บฑฑ
ฑฑบ            บ - Checa se existe PELO MENOS UM Folder preenchido         บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMSA300Ok( nSourceFolder, nOpcx )

Local lReturn := .F.
Local aSavHead := aClone(aHeader)
Local aSavCols := aClone(aCols)
Local nSavN    := N
Local nLoop    := 0 
Local lEmpty   := .F.     
Local nPosValCob,nPosValPag,nPosCod

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Testa a Inclusao de chave Duplicada  	       	     ณ 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู    
If nOpcx == 3 .And. !TMSA300Inc()
	Return .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ VerIfica se existe algum campo obrigatorio em Branco ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
																					Empty( aCols[1][aPosCol[2]] ), ;
																					lEmpty := .T.	, NIL ) } )
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se estah vazio e nao sofreu modIficacao deletaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lEmpty .AND. ! aFolder[nSourceFolder][8]:lChgField
	aCols[1][Len(aHeader)+1] := .T.
EndIf

lEmpty := .T.

If ( aFolder[nSourceFolder][8]:TudoOk() ) 

	aFolder[nSourceFolder][4] 	:= aClone( aHeader )
	aFolder[	nSourceFolder][5] 	:= aClone( aCols )
	n := Max(aFolder[nSourceFolder][8]:oBrowse:nAt,1)
	nPosValCob:=Ascan(aHeader, {|x| AllTrim(x[2]) == "DU5_VALCOB"} )
	nPosValPag:=Ascan(aHeader, {|x| AllTrim(x[2]) == "DU5_VALPAG"} )		
	nPosCod   :=Ascan(aHeader, {|x| AllTrim(x[2]) == "DU5_CODPRO"} )				

	lEmpty  := If( lEmpty, Ascan( aFolder[nSourceFolder][5], { |e| e[Len(e)] == .F. } ) = 0, lEmpty )

	lReturn := .T.

	For nLoop := 1 TO Len( aFolder )

		If nLoop == nSourceFolder
			Loop
		EndIf
		
		aHeader := aClone( aFolder[nLoop][4] )
		aCols   := aClone( aFolder[nLoop][5] )
		n := Max(aFolder[nLoop][8]:oBrowse:nAt,1)
		If !( aFolder[nLoop][8]:TudoOk() ) 
			lReturn := .F.
			Exit
        Else
			lEmpty  := If( lEmpty, Ascan( aCols, { |e| e[Len(e)] == .F. }  ) = 0, lEmpty )
		EndIf			

	Next nLoop
	
EndIf

If lReturn .And. lEmpty
	Help(" ",1,"TMSA01006") //"Todas as 'Pastas' estao vazias !!"
	lReturn := .F.
EndIf
           
aHeader := aClone(aSavHead)
aCols   := aClone(aSavCols)
N       := nSavN      

Return( lReturn )
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Enchoice bar especIfica                                    บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ TMSA300Bar( oDlg, bOk, bCancel, nOpcx )                   บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ                                         			       บฑฑ
ฑฑบ         01 บ oDlg    - Dialog da Window                                บฑฑ
ฑฑบ         02 บ bOk     - Evento Ok                                       บฑฑ
ฑฑบ         03 บ bCancel - Evento Cancel                                   บฑฑ
ฑฑบ         04 บ nOpc    - Opcao da Mbrowse                                บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ Objeto EnchoiceBar                                        บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ - Possui Ponto de Entrada para Botoes do Usuario          บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION TMSA300Bar( oDlg, bOk, bCancel, nOpcx )

Local aButtons 	 := {}
Local nCntFor      := 0
Local aSomaButtons  := {}

//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM300BUT')
	aSomaButtons:=ExecBlock('TM300BUT',.F.,.F.,{nOpcx})
	If	ValType(aSomaButtons) == 'A'
		For nCntFor:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCntFor])
		Next
	EndIf
EndIf

Return ( EnchoiceBar( oDlg, bOK, bCancel,, aButtons ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Localizador de Folder Preenchido                           บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ TMSA300Loc( nOpcx, oFolder)                               บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ                                         			       บฑฑ
ฑฑบ         01 บ nOpcx   - Opcao da Mbrowse                                บฑฑ
ฑฑบ         02 บ oFolder - Objeto Folder                                   บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ NIL                                                       บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ - Na Inclusao deleta TODOS os folders menos o 1           บฑฑ
ฑฑบ            บ - Caso contrario Localiza o primeiro folder preenchido    บฑฑ
ฑฑบ            บ - Se o Folder 1 nao estiver preenchido :                  บฑฑ
ฑฑบ            บ   - Deleta o Folder 1      					       	   บฑฑ
ฑฑบ            บ   - Forca Troca do Folder para o Primeiro Preenchido      บฑฑ
ฑฑบ            บ   - Troca Folder dentro do objeto Folder      			   บฑฑ
ฑฑบ            บ   - Refresh para refletir a mudanca no Objeto Folder      บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION TMSA300Loc( nOpcx, oFolder, aFolder)

Local nI
Local nJ                                                                                    
Local nFirstFolderOk := 0

If nOpcx == 3

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Deleta todos menos o Folder 1 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Aeval( aFolder, { | aFold | 	aFold[5][1][Len( aFold[4] ) + 1] := .T. }, 2 ) 

	nFirstFolderOk := 1
Else
	For nI := 1 TO Len( aFolder )
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Candidato a delecao ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Len( aFolder[nI][5] ) == 1
			lEmpty := .F.

			For nJ := 1 TO Len( aFolder[nI][8]:aPosCol ) // Valida Obrigat
				If !lEmpty .AND. Empty( aFolder[nI][5][1][aFolder[nI][8]:aPosCol[nJ, 2]] )
					lEmpty := .T.
					EXIT
				EndIf	
			Next nJ

			If lEmpty
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Deleta porque a FillGetDados colocou para Inclusao ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				aFolder[nI][5][1][Len( aFolder[nI][4] ) + 1] := .T.

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Se nao eh o Folder 1 e ainda nao Localizou nenhum ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

        	ElseIf nFirstFolderOk == 0
				nFirstFolderOk := nI
			EndIf	

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Se tem mais de uma linha e nao eh o Folder 1 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
        ElseIf nFirstFolderOk == 0
			nFirstFolderOk := nI
		EndIf

	Next nI										

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Habilita Todos os Folders ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Aeval( aFolder, { |aFold| 	aFold[8]:oBrowse:lDisablePaint := .F. } ) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Primeiro Folder Preenchido nao eh o 1 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nFirstFolderOk > 1

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Deleta o Folder 1 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	aCols[1][Len(aHeader)+ 1] := .T.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Forca Troca do Folder para o primeiro preenchido ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	TMSA300Chg( nFirstFolderOk, 1 )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Troca o Folder no Objeto Folder ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	oFolder:nOption := nFirstFolderOk

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Dah um Refresh para efetivar a mudanca ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	oFolder:Refresh()						

Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Padrao - Folder 1 estah preenchido ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	aFolder[1][8]:oBrowse:Refresh(.T.)

EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Carrega todos os Folder no aFolder				           บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ TMSA300Fol(nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile,;  บฑฑ
ฑฑบ            บ			bSeekFor, aNoFields, aYesFields, cLinhaOk, ;   บฑฑ
ฑฑบ            บ			cTudoOk )                                      บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ                                         			       บฑฑ
ฑฑบ         01 บ nOpcx      - Opcao do Mbrowse                             บฑฑ
ฑฑบ         02 บ cAlias     - Alias                                        บฑฑ
ฑฑบ         03 บ nOrder     - Ordem                                        บฑฑ
ฑฑบ         04 บ cSeekKey   - Chave de Seek para montar aCols              บฑฑ
ฑฑบ         05 บ bSeekWhile - Condicao While                               บฑฑ
ฑฑบ         06 บ bSeekFor   - Condicao For                                 บฑฑ
ฑฑบ         07 บ aNoFields  - Campos a serem excluidos                     บฑฑ
ฑฑบ         08 บ aYesFields - Campos a serem incluidos                     บฑฑ
ฑฑบ         09 บ cLinhaOk   - Valida Linha                                 บฑฑ
ฑฑบ         10 บ cTudoOk    - Valida Tudo                                  บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ NIL                                                       บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ Possui Ponto de Entrada p/ Mudanca de Folders pelo usuarioบฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑบ            บ Estrutura do Array de Folders                             บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑบ            บ [1] -> Tipo "N" , Numero do Folder ( DU3_COMSEG )         บฑฑ
ฑฑบ            บ [2] -> Tipo "C" , Titulo do Folder                        บฑฑ
ฑฑบ            บ [3] -> Tipo "A" , aColsRecno ( Recno() de cada aCols )    บฑฑ
ฑฑบ            บ [4] -> Tipo "A  , aHeader   da GetDados do Folder         บฑฑ
ฑฑบ            บ [5] -> Tipo "A" , aCols     da GetDados do Folder         บฑฑ
ฑฑบ            บ [6] -> Tipo "C" , cLinhaOk  da GetDados do Folder         บฑฑ
ฑฑบ            บ [7] -> Tipo "C" , cTudoOk   da GetDados do Folder         บฑฑ
ฑฑบ            บ [8] -> Tipo "O" , oGetDados deste Folder                  บฑฑ
ฑฑบ            บ [9] -> Tipo "A" , Campos que podem ser alterados          บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑบ            บ Estrutura do Array aFillGetDados                          บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑบ            บ [1] -> Tipo "C" , cAlias do Arquivo                       บฑฑ
ฑฑบ            บ [2] -> Tipo "N" , nOrder	do Indice                      บฑฑ
ฑฑบ            บ [3] -> Tipo "C" , cSeekKey, chave de Pesquisa             บฑฑ
ฑฑบ            บ [4] -> Tipo "B" , bSeekWhile, Pesquisa  While             บฑฑ
ฑฑบ            บ [5] -> Tipo "B" , bSeekFor, Pesquisa  For                 บฑฑ
ฑฑบ            บ [6] -> Tipo "A" , aNoFields, NAO vao aparecer no aHeader  บฑฑ
ฑฑบ            บ [7] -> Tipo "A" , aYesFields, VAO aparecer no aHeader     บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION TMSA300Fol( 	nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, bSeekFor, ;
										aNoFields, aYesFields, cLinhaOk, cTudoOk, aAlter )

Local nPosValAte	
Local nPosValor	
Local nPosValAju	
Local nPosPerAju	

Local aSX3Box
Local cFolderName
Local nAtalho			:= 0

Default cAlias 		:= "DU5"
Default nOrder       := 1
Default cSeekKey     :=	xFilial( "DU4" ) + M->DU4_TABSEG + DU4->DU4_TPTSEG

Default bSeekWhile	:= { || 	DU5->DU5_FILIAL + DU5->DU5_TABSEG + DU5->DU5_TPTSEG + DU5->DU5_COMSEG }

Default bSeekFor     := { || .T. } 

Default aNoFields		:= { 	"DU5_TABSEG", "DU5_TPTSEG", "DU5_COMSEG" }

Default cLinhaOk		:= "TMSA300LinOk"

aFolder := {}

DU5->( dbSetOrder( 1 ) )
DU3->( dbSetOrder( 1 ) )
DU3->( dbGoTop() )

Do While ! DU3->( Eof() )

	//-- Somente exibe todos componentes na inclusao ou alteracao
	If nOpcx <> 3 .And. nOpcx <> 4
		//-- Verifica se existe tabela para o componente
		If DU5->( !MsSeek( xFilial( 'DU5' ) + M->DU4_TABSEG + M->DU4_TPTSEG + DU3->DU3_COMSEG ) )
			DU3->( DbSkip() )
			Loop
		EndIf
	EndIf					

	aHeader := {}
	aCols   := {}
	nAtalho := 1

	Aadd( aFolder, {	DU3->DU3_COMSEG, ;
							AllTrim( DU3->DU3_DESCRI ), 	;
							TMSFillGetDados(	nOpcx, ;
													cAlias,	;
													nOrder,	;
													cSeekKey + DU3->DU3_COMSEG, ; 
													bSeekWhile, ;
													bSeekFor  , ;
													aNoFields ,	;
													aYesFields  ;
												 ), ;
							aClone( aHeader ), ;
							aClone( aCols ), ;
							cLinhaOk, ;
							cTudoOk, ;
							NIL, ;
							aAlter } )

	//-- Define letra de atalho para acessar o folder
	If	!Empty( DU3->DU3_ATALHO )
		nAtalho := At( DU3->DU3_ATALHO, UPPER(aFolder[ Len(aFolder), 2 ]) )
		If Empty( nAtalho )
			nAtalho := 1
		EndIf
	EndIf

	aFolder[ Len(aFolder), 2 ] := Stuff( aFolder[ Len(aFolder), 2 ], nAtalho, 0, '&' )

	DU3->( dbSkip() )

EndDo	

Return NIL		 	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Valida Linha da GetDados								   บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ  TMSA300LinOk()                                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ Nenhum                                   			       บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ .T. se a linha e'  valida                                 บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION TMSA300LinOk()

Local lRet       := .T.

If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DU5_CODPRO','DU5_CDRORI','DU5_CDRDES' }, 4 )

	If lRet .And. ! Empty(GDFieldGet( 'DU5_CDRORI', n )) .And. Empty(GDFieldGet( 'DU5_CDRDES', n ))
		Help('',1,'OBRIGAT2',,RetTitle('DU5_CDRDES'),4,1) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
		lRet := .F.
	EndIf
	
	If lRet .And. ! Empty(GDFieldGet( 'DU5_CDRDES', n )) .And. Empty(GDFieldGet( 'DU5_CDRORI', n ))
		Help('',1,'OBRIGAT2',,RetTitle('DU5_CDRORI'),4,1) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
		lRet := .F.
	EndIf

EndIf

Return lRet
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Valida Coluna da GetDados								   บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ  TMSA300Valid()                                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ Nenhum                                   			       บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ .T. se a coluna eh valida                                 บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION TMSA300Valid()

Local lReturn 		:= .T.

DO CASE

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Esta deletado                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	CASE 	aCols[n][Len( aHeader ) + 1]
			lReturn := .T.

			
ENDCASE

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Testa Inclusao Duplicada								   บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ  TMSA300Inc()                                             บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ Nenhum                                   			       บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ .T. se a chave eh valida                                  บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ                                                           บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION TMSA300Inc()

Local lRet := .T.
Local aArea:= DU4->(GetArea())
DU4->(dbSetOrder(1))		 

If DU4->(MsSeek(xFilial("DU4")+M->DU4_TABSEG + M->DU4_TPTSEG))			
    Help("",1,"JAGRAVADO") //Ja existe registro com esta informacao. 
    lRet := .F.
EndIf      

RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSA300   บ Autor บPatricia A. Salomao บ Data บ 28/02/02 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             Copia Tabela de Seguro 									   บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ  TMSA300Cop()                                             บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ Nenhum                                   			       บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ NIL                                                       บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SigaTMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ                                                           บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codIficacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION TMSA300Cop()
/*

LOCAL oDlg
LOCAL cNewOrig  := Space(Len(DU5->DU5_CDRORI))
LOCAL aAreaDU4  := DU4->(GetArea())
LOCAL nRecDU4   := DU4->( Recno() )
LOCAL nRecDU5   := DU5->( Recno() )
LOCAL nOpc      := 2
LOCAL cCodPas, cDesc, aArea
LOCAL cKeyDU4   := DU4->DU4_CDRORI
LOCAL cDescRegOri 
LOCAL cKeyDU5
LOCAL cFileName := CriaTrab( NIL, .F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ	Tabelas fora da vigencia e inativas nao poderao ser copiadas      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
DUR->(dbSetOrder(1))
If DUR->(MsSeek(xFilial('DUR')+DU4->DU4_TABSEG+DU4->DU4_TPTSEG))
	If DUR->DUR_ATIVO == '2' .Or. (dDataBase < DUR->DUR_DATDE .Or. ;
	     IIF(!Empty(DUR->DUR_DATATE),dDataBase > DUR->DUR_DATATE,.F.))
	   Help("",1,"TMSA010O" ) 
	   Return .F.
	EndIf               
EndIf	

DUY->(dbSetOrder(1))
DUY->( MsSeek( xFilial('DUY') + cKeyDU4, .F.) )

cDescRegOri := DUY->DUY_DESCRI
cDescNewOri := ""
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPara Funcionar ExistChav !ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Inclui := .T. 

DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0008 ) + " : " +  DU4->DU4_TABSEG + "/" +DU4->DU4_TPTSEG From 9,0 To 18,50 OF oMainWnd 

	@ 010,010 SAY 	 OemToAnsi( STR0008 ) SIZE 100,15 COLOR CLR_HBLUE PIXEL  //"Copia Tabelas de Seguro"
	@ 030,010 SAY 	 OemToAnsi( STR0009 ) SIZE 100,15 COLOR CLR_HBLUE PIXEL //Da Origem
	@ 030,053 SAY 	 cKeyDU4+ " - " + cDescRegOri  SIZE 200,15 PIXEL 
	@ 046,010 SAY 	 OemToAnsi( STR0010 ) SIZE 100,15 COLOR CLR_HBLUE PIXEL //Para a Origem
                                                                 										
	@ 046,050 MSGET cNewOrig  F3 "DUY"  PICTURE  PesqPict("DU4","DU4_CDRORI") SIZE 6,9 WHEN ( DbGoTo( nRecDU4 ), .T. ) ;
									VALID (cNewOrig<>DU4_CDRORI) .And. TMSA300Cpo(cNewOrig) PIXEL

	@ 046,080 MSGET  cDescNewOri  When .F.  SIZE 70,9  OF oDlg PIXEL 

	DEFINE SBUTTON FROM 12	,166	TYPE 1 ACTION (nOpc := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 26.5,166	TYPE 2 ACTION (nOpc := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

IF nOpc == 1 .AND. Aviso( "AVISO", STR0017	 + " " + DU4->DU4_CDRORI + " " + ;  //"Copiar todas as Tabela de Seguro de Origem"
									STR0010 + " " + cNewOrig, { STR0014, STR0015},,STR0016) == 1  //"Para a Origem"###"Confirma"###"Cancela"###"Confirmacao"

	cKeyDU4 := xFilial("DU4") + DU4->DU4_CDRORI                  

	CursorWait()

	dbSelectArea( "DU4" )
    dbSetOrder(2)
	MsSeek(xFilial()+ DU4->DU4_CDRORI)
    
	DO WHILE ckeyDU4 == DU4_FILIAL+ DU4_CDRORI                     
	
	    aArea :=DU4->(GetArea())
	    
	    If  DU4->(MsSeek(xFilial()+cNewOrig+DU4_CDRDES+DU4_TABSEG+DU4_TPTSEG))
		    RestArea(aArea)		                                                   	    
 			DU4->(dbSkip())
 			Loop	    
	    EndIf	        
	    
	    RestArea(aArea)		                                                   

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ 		
		//ณ Verifica se a Nova Regiao Origem e' igual a Regiao Destino        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		    
	    If (cNewOrig == DU4_CDRDES)
 			 DU4->(dbSkip())
 			 Loop	    	    
	    EndIf
	    	    
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ	Tabelas fora da vigencia e inativas nao poderao ser ajustadas     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
		If DUR->(MsSeek(xFilial('DUR')+DU4->DU4_TABSEG+DU4->DU4_TPTSEG))
			If DUR->DUR_ATIVO == '2' .Or. (dDataBase < DUR->DUR_DATDE .Or. ;
			     IIF(!Empty(DUR->DUR_DATATE),dDataBase > DUR->DUR_DATATE,.F.))
			   Help("",1,"TMSA010O" ) 
			   Return .F.
			EndIf               
		EndIf	
			    
		cKeyDU5 := xFilial("DU5") + DU4->DU4_TABSEG + DU4->DU4_TPTSEG + DU4->DU4_CDRORI + DU4->DU4_CDRDES 
		nRecDU4 := Recno()
		COPY TO &cFileName. NEXT 1	
		APPE FROM &cFileName.
		RecLock( "DU4", .F. )
		DU4->DU4_CDRORI := cNewOrig
		MsUnLock()
	
		DbSelectArea( "DU5" )
	
		MsSeek( cKeyDU5 )
		DO WHILE cKeyDU5 == xFilial("DU5") + DU5_TABSEG + DU5_TPTSEG + DU5_CDRORI + DU5_CDRDES
	
			nRecDU5 := Recno()
			COPY TO &cFileName. NEXT 1	
			APPE FROM &cFileName.
			RecLock( "DU5", .F. )
			DU5->DU5_CDRORI := cNewOrig
			MsUnLock()
	
			DU5->( DbGoTo( nRecDU5 ) )
	
			DU5->( DbSkip() )
	
		ENDDO			
        
		DbSelectArea( "DU4" )
		DU4->( DbGoTo( nRecDU4 ) )	
		DU4->( DbSkip() )

	ENDDO	

ENDIF	

DbSelectArea( "DU4" )
DU4->( DbGoto( nRecDU4 ) )
RestArea( aAreaDU4 )
CursorArrow()

*/
RETURN NIL

                       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณTMSA300Cpo() ณ Autor ณPatricia A. Salomao ณ Data ณ 27/05/2002 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Inicializa alguns campos a partir da Regiao Origem informada ณฑฑ
ฑฑณ          ณ na Copia da Tabela de Seguro                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Function TMSA300Cpo(cNewOrig)
Local lRet := .T.

/*
Local aAreaDU4 := DU4->(GetArea())
DU4->(dbSetOrder(2))
If DU4->(MsSeek(xFilial()+cNewOrig+DU4->DU4_CDRDES+DU4->DU4_TABSEG+DU4->DU4_TPTSEG ))
    Help("",1,"TMSA010Q")
    lRet := .F.
EndIf           

If lRet 
	If DUY->(MsSeek(xFilial()+cNewOrig))
		cDescNewOri := DUY->DUY_DESCRI
	    lRet := .T.		
	Else
	    Help("",1,"NORECNO")
	    lRet := .F.	
	EndIf    
EndIf
RestArea(aAreaDU4)

*/
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTMSA300Wheณ Autor ณPatricia A. Salomao    ณ Data ณ28.02.2002ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Validacoes antes de editar o campo                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ TMSA300Whe()                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Logico                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/
Function TMSA300Whe()

Local cCampo	:= ReadVar()  
Local nPosValCob := Ascan(aHeader, { |x| AllTrim(x[2]) == "DU5_VALCOB" } )
Local nPosValPag := Ascan(aHeader, { |x| AllTrim(x[2]) == "DU5_VALPAG" } )
Local lRet		:= .T.

If	cCampo == 'M->DU5_INTCOB'
	lRet := !Empty(aCols[n][nPosValCob] )
ElseIf	cCampo == 'M->DU5_INTPAG'
	lRet := !Empty(aCols[n][nPosValPag] )
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Marco Bianchi         ณ Data ณ01/09/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
     
Private aRotina	:=	{	{ STR0002 ,"AxPesqui"  , 0, 1,0,.F. },;	//"Pesquisar"
								{ STR0003 ,"TMSA300Mnt", 0, 2,0,NIL },;	//"Visualizar"
								{ STR0004 ,"TMSA300Mnt", 0, 3,0,NIL },;	//"Incluir"
								{ STR0005 ,"TMSA300Mnt", 0, 4,0,NIL },;	//"Alterar"
								{ STR0006 ,"TMSA300Mnt", 0, 5,0,NIL } }	//"Excluir"


If ExistBlock("TM300MNU")
	ExecBlock("TM300MNU",.F.,.F.)
EndIf

Return(aRotina)

