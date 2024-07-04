#INCLUDE "Acda035.ch" 
#INCLUDE "PROTHEUS.CH"

Static lEncLock	:= .F.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Function  ³ ACDA035  ³ Autor ³ Erike Yuri da Silva   ³ Data ³ 17.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de atualizacao de Lancamento de Inventario         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void ACDA035(void)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function AcdA035()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nI,nPos               
Local cNCampos		:= "CBC_FILIAL|CBC_NUM|CBC_QTDORI|"			//Campos que nao devem ser visualizados no browse independendo de estiver ativado ou nao para visualiar no browse
Local aHeadAux		:= {}
Local aCores 		:= {}
Local aLegenda 	:= {	{"BR_PRETO"		, STR0001 },; //"Contagem nao Batida"
								{"BR_VERDE"		, STR0002 },; //"Contagem Batida"
								{"BR_VERMELHO"	, STR0003 } } //"Nao Inventariado"
Local lWmsNew	 := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO := CBC->(ColumnPos("CBC_IDUNIT")) > 0
Local aHeadAUX:= {}

PRIVATE aRotina 	:= Menudef()
PRIVATE aCor		:= {	LoadBitmap( GetResources(), aLegenda[1,1] ), ;
								LoadBitmap( GetResources(), aLegenda[2,1] ),;
								LoadBitmap( GetResources(), aLegenda[3,1] )}

PRIVATE cCadastro := OemToAnsi(STR0010) //"Lancamento de Inventario"
PRIVATE cProduto	:= Space(Tamsx3("B1_COD")[1])
PRIVATE cArmazem	:= Space(Tamsx3("B1_LOCPAD")[1])
PRIVATE cEndereco	:= Space(TamSX3("BF_LOCALIZ")[1])
PRIVATE lUsaCB001 := UsaCB0("01")
PRIVATE lModelo1  := GetMv("MV_CBINVMD")=="1"
PRIVATE cNumCont	:= ""
PRIVATE cCondInv	:= ""                 
PRIVATE lConfOk	:= .F.
PRIVATE lBloq		:= .F.
PRIVATE __cStatus	:= '1'
PRIVATE oGetDad
PRIVATE aHeadCBC  := {}     
PRIVATE aProdEnd  := {}
PRIVATE lCBBOk			:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeadCBB para otimizacao das rotinas     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CBB")
CBB->(DbSetOrder(3))

aCores := {	{"Empty(CBB_STATUS).OR.CBB_STATUS=='0'",'ENABLE' 		},;		//Contagem nao iniciada
				{"CBB_STATUS=='1'"							,'BR_AMARELO'	},;	  	//Contagem em andamento
				{"CBB_STATUS=='2'"							,'DISABLE'		}}			//Contagem finalizada

aHeadAUX	:= aClone(APBuildHeader("CBC"))
For nI := 1 to Len(aHeadAUX)
	If X3USO(aHeadAUX[nI,7]) .and. !Trim(aHeadAUX[nI,2]) $ cNCampos .and. Trim(aHeadAUX[nI,2])!= 'CBC_CODINV' .and. cNivel >= GetSx3Cache(trim(aHeadAUX[nI,2]), "X3_NIVEL") 
		If	!(Trim(aHeadAUX[nI,2]) == 'CBC_CONTOK' .AND. lModelo1) .and. Trim(aHeadAUX[nI,2]) != 'CBC_IDUNIT' .and. Trim(aHeadAUX[nI,2]) != 'CBC_CODUNI' 
			Aadd (aHeadCBC,aHeadAUX[nI])
		EndIf
	EndIf
Next nI 					   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Muda a visualizacao do MsGetDados quando se tem CB0  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := Ascan(aHeadCBC,{|x| Trim(x[2])=="CBC_CODETI"})
If lUsaCB001 .and. nPos > 0
	Aadd(aHeadAux,{aHeadCBC[nPos,1],aHeadCBC[nPos,2],aHeadCBC[nPos,3],TamSX3("CB0_CODET2")[1],aHeadCBC[nPos,5],;
						aHeadCBC[nPos,6],aHeadCBC[nPos,7],aHeadCBC[nPos,8],aHeadCBC[nPos,9],aHeadCBC[nPos,10]})
	For nI:= 1 To Len(aHeadCBC)
		If Trim(aHeadCBC[nI,2])=="CBC_CODETI"
			Loop
		EndIf
		Aadd(aHeadAux,{aHeadCBC[nI,1],aHeadCBC[nI,2],aHeadCBC[nI,3],aHeadCBC[nI,4],aHeadCBC[nI,5],;
							If(Trim(aHeadCBC[nI,2])=="CBC_QUANT",aHeadCBC[nI,6],".F."),aHeadCBC[nI,7], ;
							aHeadCBC[nI,8],aHeadCBC[nI,9],aHeadCBC[nI,10]})
	Next
	aHeadCBC := aClone(aHeadAux)
ElseIf nPos > 0
	aDel(aHeadCBC,nPos)
	aSize(aHeadCBC,Len(aHeadCBC)-1)
EndIf

mBrowse( 6, 1,22,75,"CBB",,,,,,aCores)

dbSelectArea("CBB")
CBB->(dbSetOrder(1))
dbClearFilter()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ACDA035V  ³Autor  ³Erike Yuri da Silva    ³ Data ³17.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualizacao do Lancamento de Inventario                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do lancamento de inventario       ³±±
±±³          ³ExpN2: Recno do cabecalho do lancamento de inventario       ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a interface com o usua³±±
±±³          ³rio do lancamento de inventario                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ACD/Materiais                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ACDA035V(cAlias,nReg,nOpc)
Local aArea    := GetArea()
Local aBackRot := aClone(aRotina)      
Local nOpcA    := 0
Local nUsado   := 0
Local nI			:= 0
Local oGetd
Local oDlg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a Variaveis Privates.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTrocaF3  := {}
PRIVATE aTELA[0][0]
PRIVATE aHeader	  := {}
PRIVATE aCols	  := {}
If Type("Inclui") == "U"
	Inclui := .F.
	Altera := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a Variaveis da Enchoice.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( "CBB", .F., .F. )
aHeader := aClone(aHeadCBC)
nUsado  := Len(aHeader)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
SB1->(DbSetOrder(1))
dbSelectArea("CBC")
CBC->(dbSetOrder(3))
CBC->(DbSeek(xFilial("CBC")+CBB->CBB_CODINV+CBB->CBB_NUM))
While CBC->( !Eof() .And. CBC_FILIAL == xFilial("CBC") .And. CBC_CODINV == CBB->CBB_CODINV .And. CBC_NUM == CBB->CBB_NUM )
		AADD(aCols,Array(Len(aHeader)))
		For nI:=1 To Len(aHeader)
			If ( aHeader[nI,10] <>  "V" )
				aCOLS[Len(aCols)][nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Else
				aCOLS[Len(aCols)][nI] := CriaVar(aHeader[nI,2])
			EndIf
		Next nI
	CBC->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao ache nenhum item , abandona rotina.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( Len(aCols) == 0 )
	Aviso(STR0011,STR0012,{STR0013}) //"Aviso"###"Nao existem itens para serem visualizados"###"Ok"
	aRotina := aClone(aBackRot)
	RestArea(aArea)
	Return( nOpcA )
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro From oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 of oMainWnd PIXEL
oEnc:= MsMGet():New("CBB" ,nReg ,nOpc,,,,,{0,0,50,300},,3,,,,oDlg,,,.F.,)    
oEnc:oBox:align 		:= CONTROL_ALIGN_TOP
oGetd:=MsGetDados():New(0,0,200,200 ,nOpc,,,"",,,1,,999)
oGetd:oBrowse:align  := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg ON INIT ACDA033Bar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()},nOpc)
aRotina := aClone(aBackRot)
RestArea(aArea)
Return( nOpcA )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ACDA035A  ³ Rev.  ³ERIKE YURI DA SILVA    ³ Data ³26.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alteracao do Lancamento de Inventario                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do lancamento de inventario       ³±±
±±³          ³ExpN2: Recno do cabecalho do lancamento de inventario       ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a interface com o usua³±±
±±³          ³rio e o lancamento de inventario                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ACD                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function ACDA035A(cAlias,nReg,nOpc)
Local cUltCont		:= ""     
Local cCodInv		:= ""
Local aArea			:= GetArea()
Local nOpcA			:= 0
Local nI		   	:= 0
Local nUsado   	:= 0
Local nRecCBB		:= 0
Local oDlg,oGetd
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na LinhaOk                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE N          := 1
PRIVATE oEnc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ponto de entrada esta ativado            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! SuperGetMV("MV_CBPE012",.F.,.F.)
	Alert(STR0014) //"Necessario ativar o parametro MV_CBPE012"
	Return .F.
EndIf

CBA->(DbSetOrder(1))
CBA->(DbSeek(xFilial('CBA')+CBB->CBB_CODINV))              

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se o Mestre de inventario ja esta processado|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CBA->CBA_STATUS=='5' // 5=Processado
	Aviso(STR0011,STR0015+; //"Aviso"###"Nao eh possivel realizar alteracao, pois o mestre de "
			STR0016,{STR0013}) //"inventario ja esta processado!"###"Ok"
	Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se o Mestre de inventario ja esta finalizado|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CBA->CBA_STATUS=='4'  // 4=Finalizado
	Aviso(STR0011,STR0015+; //"Aviso"###"Nao eh possivel realizar alteracao, pois o mestre de "
			STR0017,{STR0013}) //"inventario ja esta finalizado!"###"Ok"
	Return
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se eh Modelo 2 e so permite alterar a ultima|
//| contagem                                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !lModelo1        
	nRecCBB	:= CBB->(RecNo())
   cUltCont	:= Space(6)	   
   cCodInv	:= CBB->CBB_CODINV
   CBB->(DbSetorder(3))
  	CBB->(DbSeek(xFilial('CBB')+cCodInv))
   While CBB->(!Eof() .and. xFilial('CBB')+cCodInv == CBB_FILIAL+CBB_CODINV)
      cUltCont:=CBB->CBB_NUM
  	   CBB->(DbSkip())
   EndDo 
   CBB->(DbGoto(nRecCBB))            
   If CBB->CBB_NUM<>cUltCont
		Aviso(STR0011,I18N(STR0070,{cUltCont}),{STR0013}) //'Aviso' ### "Ok"
		Return   
   EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se esta utilizando outra filial             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ( CBB->CBB_FILIAL<> xFilial("CBB") )
	Help(" ",1,"A000FI")
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa desta forma para criar uma nova instancia de variaveis private ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( "CBB", .F., .F. )
RegToMemory( "CBA", .F., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader   := aClone(aHeadCBC)
nUsado    := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CBC->(dbSetOrder(3))
CBC->(DbSeek(xFilial("CBC")+CBB->CBB_CODINV+CBB->CBB_NUM))
While CBC->( !Eof() .And. CBC_FILIAL == xFilial("CBC") .And. CBC_CODINV == CBB->CBB_CODINV .And. CBC_NUM == CBB->CBB_NUM )
	AADD(aCols,Array(nUsado+1))
	For nI:=1 To Len(aHeader)
		If ( aHeader[nI,10] <>  "V" )
			aCOLS[Len(aCols)][nI] := CBC->(FieldGet(FieldPos(aHeader[nI,2])))
		Else
			aCOLS[Len(aCols)][nI] := CriaVar(aHeader[nI,2])
		EndIf
	Next nI
	aCols[Len(aCols)][nUsado+1] := .F.
	CBC->(dbSkip())
EndDo                              

cArmazem	:= CBA->CBA_LOCAL
cEndereco	:= Space(TamSX3("BF_LOCALIZ")[1])
If CBA->CBA_TIPINV== "2"
	cEndereco := CBA->CBA_LOCALI
EndIf
lCBBOk			:= .T.
DEFINE MSDIALOG oDlg TITLE cCadastro From oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 of oMainWnd PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do Enchoice                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnc:= MsMGet():New("CBB" ,nReg ,nOpc,,,,,{0,0,50,300},,3,,,,oDlg,,,.F.,)    
oEnc:oBox:lReadOnly			:= .T.
oEnc:oBox:align 			:= CONTROL_ALIGN_TOP          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do MsGetDados                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetd:=MsGetDados():New(0,0,200,200 ,nOpc,"ACDA035M(1)","ACDA035M(3)"     ,"",.T.,   ,1  ,  ,999,"ACDA035M(2)")
oGetd:oBrowse:align			:= CONTROL_ALIGN_ALLCLIENT 
oGetd:oBrowse:bAdd			:= {||oGetd:lchgField := .f., oGetd:AddLine(),VldNLinha()}
oGetDad:=oGetd
ConfigCols()
ACTIVATE MSDIALOG oDlg ON INIT ACDA033Bar(oDlg,{|| If(obrigatorio(aGets,aTela),(nOpcA:=2,If(ACDA035M(3),oDlg:End(),(nOpcA := 0,.T.))),.T.)},{|| oDlg:End(),},nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Gravacao do Lancamento de Inventario                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpcA == 2 )
	cNumCont := M->CBB_NUM
	cCondInv	:= M->CBB_CODINV
	ACDA035Grv(nOpcA)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()
RestArea(aArea)
Return( nOpcA )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ACDA035I  ³ Rev.  ³Erike Yuri da Silva    ³ Data ³17.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao do Lancamento de Inventario                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do Lancamento de Inventario       ³±±
±±³          ³ExpN2: Recno do cabecalho do Lancamento de Inventario       ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±³          ³ExpL4: Indica se o acols e aheader foram inicializados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a interface com o usua³±±
±±³          ³rio e o Lancamento de inventario                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ACD/Materiais                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ACDA035I(cAlias,nReg,nOpc)
Local nOpcA 			:= 0
Local nI					:= 0
Local nUsado			:= 0
Local oDlg,oGetD
PRIVATE lVldTudoOk	:= .F.
PRIVATE nPosCodInv	:= 0
PRIVATE nPosUser    	:= 0
PRIVATE aTela[0][0]
PRIVATE aGets[0]
PRIVATE aHeader   	:= {}
PRIVATE aCols     	:= {} 
PRIVATE oEnc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ponto de entrada esta ativado            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! SuperGetMV("MV_CBPE012",.F.,.F.)
	Alert(STR0014) //"Necessario ativar o parametro MV_CBPE012"
	Return .F.
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CBA")
CBB->(dbSetOrder(1))
dbSelectArea("CBB")
CBB->(dbSetOrder(3))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa desta forma para criar uma nova instancia de variaveis private ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( "CBB", .T., .F. )
RegToMemory( "CBA", .F., .F. )  
M->CBB_NUM := CBPROXCOD("MV_USUINV")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(aHeadCBC)
nUsado  := Len(aHeader)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aCols                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCOLS,Array(nUsado+1))
For nI	:= 1 To nUsado
	aCols[1][nI] := CriaVar(aHeader[nI][2])
Next
aCOLS[1][Len(aHeader)+1] := .F.

cArmazem		:= Space(Tamsx3("B1_LOCPAD")[1])
cEndereco	:= Space(TamSX3("BF_LOCALIZ")[1])
lBloq		:= .F.
lCBBOk		:= .F.
lEncLock := .F. // Variavel de controle de tela
DEFINE MSDIALOG oDlg TITLE cCadastro From oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 of oMainWnd PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do Enchoice                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnc			:= MsMGet():New("CBB" ,nReg ,nOpc,,,,,{0,0,50,300},,3,,,,oDlg,,,.F.,)        
nPosCodInv 	:= AsCan(oEnc:aENTRYCTRLS,{|x| UPPER(TRIM(x:cReadVar))=="M->CBB_CODINV"})
nPosUser 	:= AsCan(oEnc:aENTRYCTRLS,{|x| UPPER(TRIM(x:cReadVar))=="M->CBB_USU"})

oEnc:AENTRYCTRLS[nPosCodInv]:bVALID	:= {|X,LRESVALID,O| O := oEnc:AENTRYCTRLS[nPosCodInv], ;
				(LRESVALID := IF(O:LMODIFIED .OR. (O:CARGO <> NIL .AND. O:CARGO <> M->CBB_CODINV),;
				(ACDA035M(5)),.T.)),(IF(LREFRESH,oEnc:ENCHREFRESHALL(),)),LRESVALID}
oEnc:AENTRYCTRLS[nPosUser]:bVALID 	:= {|X,LRESVALID,O| O := oEnc:AENTRYCTRLS[nPosUser],;
				(LRESVALID := IF(O:LMODIFIED .OR. (O:CARGO <> NIL .AND. O:CARGO <> M->CBB_USU),;
				(If(ACDA035M(6),.T.,(.T.,oEnc:AENTRYCTRLS[nPosUser]:BUFFER := Space(TamSx3("CBB_USU")[1]), ;
				SetFocus(oEnc:AENTRYCTRLS[nPosCodInv]:hWnd)))),.T.)), (IF(LREFRESH,oEnc:ENCHREFRESHALL(),)),LRESVALID}
oEnc:AENTRYCTRLS[nPosCodInv]:bWhen	:= {||!lEncLock} 
oEnc:AENTRYCTRLS[nPosUser]:bWhen 	:= {||!lEncLock} 				
oEnc:oBox:align 		:= CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do MsGetDados                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


oGetd:=MsGetDados():New(0,0,200,200 ,nOpc,"ACDA035M(1)","ACDA035M(3)","",.T.,   ,1  ,  ,999,"ACDA035M(2)")                            
oGetd:oBrowse:bGOTFOCUS 	:= {||If(!obrigatorio(aGets,aTela),SetFocus(oEnc:AENTRYCTRLS[nPosCodInv]:hWnd),EnchoiceOk())}
oGetd:oBrowse:align  	 	:= CONTROL_ALIGN_ALLCLIENT   
oGetd:oBrowse:bAdd			:= {||oGetd:lchgField := .f., oGetd:AddLine(),VldNLinha()}
oGetDad		:= oGetd
ACTIVATE MSDIALOG oDlg 	ON INIT(ACDA033Bar(oDlg,{|| If(obrigatorio(aGets,aTela),(nOpcA:=1,If(ACDA035M(3),oDlg:End(),(nOpcA := 0,.T.))),.T.)},{||ACDA035M(4),oDlg:End()},nOpc)) VALID (ACDA035M(4))

SetKey( VK_F12	, { || .T. } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Gravacao do Lancamento de Inventario                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpcA == 1 )
	cNumCont := M->CBB_NUM
	cCondInv	:= M->CBB_CODINV
	ACDA035Grv(1)
Else
	If ( __lSX8 )
		RollBackSX8()
	EndIf
EndIf
lEncLock := .F. // Variavel de controle de tela
Return( nOpcA )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ACDA035D  ³ Rev.  ³Erike Yuri da Silva    ³ Data ³27.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Delecao do Lancamento de Inventario                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do lancamento de inventario       ³±±
±±³          ³ExpN2: Recno do cabecalho do lancamento de inventario       ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a interface com o usua³±±
±±³          ³rio e o lancamento de inventario                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ACD                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ACDA035D(cAlias,nReg,nOpc)
Local aArea     := GetArea()
Local nOpcA		 := 0
Local nUsado    := 0
Local nI		    := 0
Local oDlg,oGetd,oEnc
PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE aTELA[0][0],aGETS[0]

CBA->(DbSetOrder(1))
CBA->(DbSeek(xFilial('CBA')+CBB->CBB_CODINV))           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se o Mestre de inventario ja esta processado|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CBA->CBA_STATUS=='5' // 5=Processado
	Aviso(STR0011,STR0018+; //"Aviso"###"Nao eh possivel excluir esta contagem, pois o mestre de "
			STR0016,{STR0013}) //"inventario ja esta processado!"###"Ok"
	Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se o Mestre de inventario ja esta finalizado|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CBA->CBA_STATUS=='4' // 4=Finalizado
	Aviso(STR0011,STR0015+; //"Aviso"###"Nao eh possivel realizar alteracao, pois o mestre de "
			STR0017,{STR0013}) //"inventario ja esta finalizado!"###"Ok"
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se esta utilizando outra filial             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ( CBB->CBB_FILIAL<> xFilial("CBB") )
	Help(" ",1,"A000FI")
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa desta forma para criar uma nova instancia de variaveis private ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( "CBB", .F., .F. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader   := aClone(aHeadCBC)
nUsado    := Len(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CBC->(dbSetOrder(3))
CBC->(DbSeek(xFilial("CBC")+CBB->CBB_CODINV+CBB->CBB_NUM))
While CBC->( !Eof() .And. CBC_FILIAL == xFilial("CBC") .And. CBC_CODINV == CBB->CBB_CODINV .And. CBC_NUM == CBB->CBB_NUM )
	AADD(aCols,Array(nUsado+1))
	For nI:=1 To Len(aHeader)
		If ( aHeader[nI,10] <>  "V" )
			aCOLS[Len(aCols)][nI] := CBC->(FieldGet(FieldPos(aHeader[nI,2])))
		Else
			aCOLS[Len(aCols)][nI] := CriaVar(aHeader[nI,2])
		EndIf
	Next nI
	aCols[Len(aCols)][nUsado+1] := .F.
	CBC->(dbSkip())
EndDo

lEncLock := .F. // Variavel de controle de tela

DEFINE MSDIALOG oDlg TITLE cCadastro From oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 of oMainWnd PIXEL
oEnc:= MsMGet():New("CBB" ,nReg ,nOpc,,,,,{0,0,50,300},,3,,,,oDlg,,,.F.,)
oEnc:oBox:align 		:= CONTROL_ALIGN_TOP
oGetd:=MsGetDados():New(0, 0, 200, 200, nOpc, "ACDA035M(1)", "ACDA035M(3)", "", .T.,, 1,,999, "ACDA035M(2)")
oGetd:oBrowse:align  := CONTROL_ALIGN_ALLCLIENT
oGetDad:=oGetd
ACTIVATE MSDIALOG oDlg ON INIT ACDA033Bar(oDlg,;
												{|| If(obrigatorio(aGets,aTela),(nOpcA:=3,If(ACDA035M(3),oDlg:End(),(nOpcA := 0,.T.))),.T.)},;
												{|| oDlg:End(),},;
												nOpc)

If ( nOpcA == 3  )
	cNumCont := M->CBB_NUM
	cCondInv	:= M->CBB_CODINV
	ACDA035Grv(nOpcA)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()
RestArea(aArea)
lEncLock := .F. // Variavel de controle de tela
Return nOpcA

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ACDA035L  ³Autor  ³ Erike Yuri da Silva   ³ Data ³27.07.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ACD                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß /*/
Function ACDA035L() 
Local aLegenda 	:= {	{"BR_VERDE"		, STR0019 },; //"Contagem nao iniciada"
								{"BR_AMARELO"	, STR0020 },; //"Contagem em andamento"
								{"BR_VERMELHO"	, STR0021 } } //"Contagem finalizada"

BrwLegenda(cCadastro,STR0010,aLegenda) //"Lancamento de Inventario"
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ACDA033Bar³ Autor ³ Erike Yuri da Silva   ³ Data ³ 18.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ EnchoiceBar especifica do Mata410                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oDlg: 	Objeto Dialog                                     ³±±
±±³          ³ bOk:  	Code Block para o Evento Ok                       ³±±
±±³          ³ bCancel: Code Block para o Evento Cancel                   ³±±
±±³          ³ nOpc:		nOpc transmitido pela mbrowse                     ³±±
±±³          ³ aForma: Array com as formas de pagamento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ACDA033Bar(oDlg,bOk,bCancel,nOpc)
Local aButtons  := {}
Local lWmsNew		:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO		:= CBM->(ColumnPos("CBM_IDUNIT")) > 0
Local lCbaUti		:= CBA->(ColumnPos("CBA_CODUNI")) > 0
If	lWmsNew .And. lUniCPO .And. lCbaUti
	AAdd(aButtons,{'PRODUTO',{|| AcdWmsUni() },STR0073 }) //"Unit.Fech.WMS"   
EndIf 
Return (EnchoiceBar(oDlg,bOK,bcancel,,aButtons))


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ACDA035Grv³ Autor ³Erike Yuri da Silva    ³ Data ³18.07.04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a Gravacao de Lancamento de Inventario               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se houve gravacao de itens                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Tipo de Operacao a ser executada  ( Opcional )       ³±±
±±³          ³       [1] Inclusao                                         ³±±
±±³          ³       [2] Alteracao                                        ³±±
±±³          ³       [3] Exclusao                                         ³±±
±±³          ³ExpA2: Registros do CBC                ( Opcional )         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Necessita das variaveis: aHeader,aCols e INCLUI             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Static Function ACDA035Grv(nOpcao)
Local cbBlock		:= ""
Local cAux			:= ""  
Local cCodInv		:= CBB->CBB_CODINV
Local lGravou		:= .F.
Local lContinua	:= .F.
Local lWmsNew		:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO		:= CBM->(ColumnPos("CBM_IDUNIT")) > 0
Local nMax			:= Len(aCols)
Local nCpos		:= Len(aHeader)
Local nPProduto 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "CBC_COD"})
Local nX        	:= 0
Local nY        	:= 0
Local nk        	:= 0
Local nPosDel  	:= Len( aHeader ) + 1
Local nPosChave	:= If(lUsaCB001,RetPosCpo('CBC_CODETI'),RetPosCpo('CBC_COD'))
Local nPosLOCAL	    := RetPosCpo('CBC_LOCAL')
Local nPosENDE	    := RetPosCpo('CBC_LOCALI')
Local nPosLOTE	    := RetPosCpo('CBC_LOTECT')
Local nPosNLote		:= RetPosCpo('CBC_NUMLOT')
Local nPosQtd		:= RetPosCpo('CBC_QUANT')
Local nPosNSer		:= RetPosCpo('CBC_NUMSER')
Local nPos			:= 0
Local aArea		:= CBB->(GetArea())
Local aIncCBC		:= {}
Local aDelCBC		:= {}
Local aColsAux 	:= {}
Local lACDA35GR  	:= ExistBlock('ACDA35GR') 
DEFAULT nOpcao	:= 0

If nOpcao == 3
	//Apaga Produtos Inventariados (Itens)
	Begin Transaction
		DbSelectArea("CBC")
		CBC->(DbSetOrder(1))
		CBC->(DbSeek(xFilial("CBC")+CBB->CBB_NUM))
		While CBC->(!Eof() .AND. CBC_FILIAL+CBC_NUM==xFilial("CBC")+CBB->CBB_NUM)
			RecLock("CBC",.F.)
			CBC->(DbDelete())
			CBC->(MsUnLock())
			CBC->(DbSkip())
		EndDo
		//Apaga o Cabecalho
		RecLock("CBB",.F.)
		CBB->(DbDelete())
		CBB->(MsUnLock())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Decrementa numero de contagens realizadas do mestre          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CBAtuContR(cCodInv, 2)
		
		CBB->(DbSetOrder(3))
		If !CBB->(DbSeek(xFilial('CBB')+cCodInv))    
			//Desbloqueia o Estoque e apaga o espelho do CBM
			Finalizar()			                       
			       
			//Altera o Status do Mestre de Inventario
			CBA->(DbSetOrder(1))
			CBA->(DbSeek(xFilial('CBA')+cCodInv))		
			RecLock("CBA",.F.)
			CBA->CBA_STATUS	:= '0'
			CBA->CBA_AUTREC	:= '1'
			CBA->(MsUnLock())
			ACDA30Exc()
		EndIf 
	End Transaction 	
	Return .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Bloco de codigo para ascan                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbBlock := "{|x| Trim(x[1])"
cAux	  := "==Trim(aCols[nX,1])"	
SX3->(dbSetOrder(2))
For nX:=2 To nCpos                  
	If Upper(Trim(aHeader[nX,2]))=="CBC_QUANT" .or. GetSx3Cache(aHeader[nX,2], "X3_PROPRI") = 'U' .or. GetSx3Cache(aHeader[nX,2], "X3_PROPRI") = 'M'
   		Loop
   	EndIf
	If GetSx3Cache(aHeader[nX,2], "X3_TIPO") = 'N'
		cbBlock 	+= "+cValTochar(x["+StrZero(nX,2)+"])"			
		cAux 		+="+cValToChar(aCols[nX,"+StrZero(nX,2)+"])"
	elseif GetSx3Cache(aHeader[nX,2], "X3_TIPO") = 'D'
			cbBlock 	+= "+dToS(x["+StrZero(nX,2)+"])"			
			cAux 		+="+dToS(aCols[nX,"+StrZero(nX,2)+"])"		
		elseif GetSx3Cache(aHeader[nX,2], "X3_TIPO") = 'L'
				cbBlock 	+= "+iif (x["+StrZero(nX,2)+"],'T','F')"			
				cAux 		+="+iif (aCols[nX,"+StrZero(nX,2)+"],'T','F')"
			Else
				cbBlock 	+= "+x["+StrZero(nX,2)+"]"			
				cAux 		+="+aCols[nX,"+StrZero(nX,2)+"]"	
			EndiF
Next
cbBlock += cAux +"}"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aglutina Produtos e Desconsidera deletados   (CBC)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1 To Len(aCols)
	If aCols[ nX, nPosDel ] .OR. Empty(aCols[ nX,nPosChave])
		Loop
	EndIf                       
	
	If (!lModelo1) .AND. !Empty(aCols[ nX,RetPosCpo('CBC_CONTOK')])
		Loop	
	EndIf
	                         
	For nY:=1 To Len(aHeader)
		If ValType(aCols[nX,nY])=="C" .AND. Len(aCols[nX,nY])==0
			aCols[nX,nY] := Space(aHeader[nY,4])
		EndIf
	Next

	nPos := AsCan(aColsAux,&cbBlock)		
	If Empty(nPos)
		Aadd(aColsAux,Array(Len(aHeader)))
		For nk:=1 To Len(aHeader)
			aColsAux[Len(aColsAux),nk] := aCols[nX,nK]  
	   Next
	Else
		aColsAux[nPos,nPosQtd]+= aCols[nX,nPosQtd]
	EndIf
Next

Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera o Status do Mestre de Inventario                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("CBA",.F.)                      
	If ! lModelo1 				// se for modelo 2 tem que verificar se tem autorizacao
	   CBA->CBA_AUTREC:="2" // BLOQUEADO
	EndIf
	CBA->CBA_STATUS := "1"  // 1=Em andamento
	CBA->(MsUnlock())    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera o Status do Cabecalho da contagem                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("CBB",.F.)	
	CBB->CBB_STATUS := __cStatus
	CBB->(MsUnLock())
	  
	If nOpcao==1
		aCols := aClone(aColsAux)
		For nX :=1 To Len(aCols)
			RecLock("CBC",INCLUI)
			For nY:=1 TO nCpos
				If ( aHeader[nY,10] <>  "V" )
					CBC->&(aHeader[nY,2]) := aCols[nX,nY]
				EndIf
			Next                                    
			CBC->CBC_QTDORI	:= aCols[nX,nPosQtd]
			CBC->CBC_FILIAL 	:= xFilial("CBC")
			CBC->CBC_CODINV	:= CBA->CBA_CODINV
			CBC->CBC_NUM		:= cNumCont
			CBC->(MsUnLock())
			If lWmsNew .And. lUniCPO
				ACD35CBM(3,CBA->CBA_CODINV,CBC->CBC_COD,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_LOTECT,CBC->CBC_NUMLOT,CBC->CBC_NUMSER,CBC->CBC_IDUNIT,CBC->CBC_CODUNI)
			Else
				ACD35CBM(3,CBA->CBA_CODINV,CBC->CBC_COD,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_LOTECT,CBC->CBC_NUMLOT,CBC->CBC_NUMSER)	
			EndIf	
		Next
		RecLock("CBA",.F.)
		CBA->CBA_STATUS := "1"
		CBA->(MsUnLock())
	ElseIf nOpcao==2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda o numero do registro do itens que serao alterados                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRegCBC := {}
		CBC->(dbSetOrder(2))
		If lUsaCB001
			CBC->(DbSetOrder(1))
		EndIf
		CBC->(DbSeek(xFilial("CBC")+cNumCont))
		While CBC->( !Eof() .And. CBC_FILIAL+CBC_NUM==xFilial("CBC")+cNumCont)
			If CBC->CBC_CODINV == CBB->CBB_CODINV
				aadd(aRegCBC,Array(Len(aHeader)))
				For nX:=1 To nCpos
					aRegCBC[Len(aRegCBC),nX] := CBC->&(aHeader[nX,2])
				Next
				If lACDA35GR   
					ExecBlock('ACDA35GR',.F.,.F.)
				EndIf
			EndIf
			CBC->(dbSkip())
		EndDo
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Deleta registros marcados com deletado no MSGETDADOS                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX:=1 To nMax
			If !CBC->(DbSeek(xFilial("CBC")+cNumCont+aCols[nX,nPosChave]))
				Loop
			EndIf
			If !aCols[nX,nPosDel]
				Loop
			EndIf
			If lWmsNew .And. lUniCPO
				ACD35CBM(5,CBA->CBA_CODINV,CBC->CBC_COD,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_LOTECT,CBC->CBC_NUMLOT,CBC->CBC_NUMSER,CBC->CBC_IDUNIT,CBC->CBC_CODUNI)		
			Else
				ACD35CBM(5,CBA->CBA_CODINV,CBC->CBC_COD,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_LOTECT,CBC->CBC_NUMLOT,CBC->CBC_NUMSER)
			EndIf
		   RecLock('CBC',.F.)
		   CBC->(DBDelete())
		   CBC->(MsUnLock())
		Next
	   aCols := aClone(aColsAux)
		For nX:=1 To Len(aCols) 
			nPos := Ascan(aRegCBC,&cbBlock) 
			If nPos > 0 .and. CBC->(DbSeek(xFilial("CBC")+cNumCont+aCols[nX,nPosChave]+IIf(lUsaCB001 , "", aCols[nX,nPosLOCAL] + aCols[nX,nPosENDE] + aCols[nX,nPosLOTE] +  aCols[nX,nPosNLote] + aCols[nX,nPosNSer] ) )) 
			   RecLock('CBC',.F.)
			Else
			   RecLock('CBC',.T.)  
   			CBC->CBC_QTDORI	:= aCols[nX,nPosQtd]
			EndIf
			For nY:=1 TO nCpos
				If ( aHeader[nY,10] <>  "V" ) 
					CBC->&(aHeader[nY,2]) := aCols[nX,nY]
				EndIf
			Next
			CBC->CBC_FILIAL 	:= xFilial("CBC")
			CBC->CBC_NUM		:= cNumCont
			CBC->CBC_CODINV	:= CBA->CBA_CODINV
			CBC->(MsUnLock())
			If lWmsNew .And. lUniCPO                
				ACD35CBM(3,CBA->CBA_CODINV,CBC->CBC_COD,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_LOTECT,CBC->CBC_NUMLOT,CBC->CBC_NUMSER,CBC->CBC_IDUNIT,CBC->CBC_CODUNI)		
			Else
				ACD35CBM(3,CBA->CBA_CODINV,CBC->CBC_COD,CBC->CBC_LOCAL,CBC->CBC_LOCALI,CBC->CBC_LOTECT,CBC->CBC_NUMLOT,CBC->CBC_NUMSER)
			EndIf
		Next
	EndIf	
End Transaction 		

RestArea( aArea )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve ser feita analise de inventario     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMV("MV_ANAINV") # "1" .or.  __cStatus=="1"
	Return .T.
EndIf       

Private lMsErroAuto	:= .F.

CBAnaInv(.F.)

Return .T.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ACDA035M  ³Autor  ³Erike Yuri da Silva    ³ Data ³17.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao generica do Cadastro para MsGetDados              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Acao a ser executada na para validacao               ³±±
±±³          ³      1 - Validacao de Linha do MsGetDados                  ³±±
±±³          ³      2 - Validacao de Coluna (campo)                       ³±±
±±³          ³      3 - Validacao de todo cadastro                        ³±±
±±³          ³      4 - Validacao do cancelamento do lancamento           ³±±
±±³          ³      5 - Validacao do campo CBB->CBB_CODINV                ³±±
±±³          ³      6 - Validacao do campo CBB->CBB_USU                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ACD                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ACDA035M(nAcao)
Local lRet := .F.                     

If nAcao==0
	lRet := VldNLinha()
ElseIf nAcao==1
	lRet := VldLinha()
ElseIf nAcao==2
	lRet := VldCpo()
ElseIf nAcao==3
   lRet := VldLinha() .And. VldTudoOk()
ElseIf nAcao==4
   lRet := VldClose()
ElseIf nAcao==5
   lRet := VldCodInv()     
ElseIf nAcao==6
	lRet := VldCodOper()
	If !lRet
		lEncLock := .F. // Variavel de controle de tela
	EndIf 
ElseIf nAcao==99
	lRet := .t.
EndIf                       
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³VldLinha()          ³Autor³Erike Yuri da Silva³27/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Validacao de linha do MsGetDados                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Logico                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function VldLinha()
Local lRet 		:= .T.  
Local nI			:= 0 
Local nUsado		:= 0
Local nPosDel		:= Len(aHeader)+1
Local nLinha  	:= oGetDad:oBrowse:nAt
Local nPosEtiq	:= 0
Local nPosProd 	:= 0
Local nPosArm		:= 0
Local nPosEnder	:= 0
Local nPosLote	:= 0
Local nPosNLote	:= 0
Local nPosNSer  	:= 0
Local nPosQtd		:= 0                
                    
If !Empty(aCols) 
	For nI:=1 To Len(aHeader)
		If ValType(aCols[nLinha,nI])=="C" .AND. Len(aCols[nLinha,nI])==0
			aCols[nLinha,nI] := Space(aHeader[nI,4])
		EndIf
	Next
EndIf

If aCols[ nLinha, nPosDel  ]                   
	If lUsaCB001
		nPosEtiq   := RetPosCpo('CBC_CODETI')
		nPosQtd    := RetPosCpo('CBC_QUANT') 		
		CBC->(DbSetOrder(1))
		CBC->(DbSeek(xFilial("CBC")+M->CBB_NUM+aCols[nLinha,nPosEtiq]))
	Else
		CBC->(dbSetOrder(2))  
		nPosProd 	:= RetPosCpo('CBC_COD')
		nPosArm		:= RetPosCpo('CBC_LOCAL')
		nPosEnder	:= RetPosCpo('CBC_LOCALI') 
		nPosLote		:= RetPosCpo('CBC_LOTECT') 
		nPosNLote	:= RetPosCpo('CBC_NUMLOT')
		nPosNSer		:= RetPosCpo('CBC_NUMSER')
		nPosQtd     := RetPosCpo('CBC_QUANT') 
		CBC->(DbSeek(xFilial("CBC")+M->CBB_NUM+aCols[nLinha,nPosProd]+aCols[nLinha,nPosArm]+ ;
						  aCols[nLinha,nPosEnder]+aCols[nLinha,nPosLote]+aCols[nLinha,nPosNLote]+aCols[nLinha,nPosNSer]))				
	EndIf
	If CBC->(Found())
		RecLock("CBC",.F.)
		CBC->CBC_QUANT -= aCols[nLinha,nPosQtd]
		If CBC->CBC_QUANT <= 0
			CBC->(DbDelete())
		EndIf
		CBC->(MsUnLock())
	EndIf 
	aDel(aCols,nLinha)
	aSize(aCols,Len(aCols)-1)
	If Empty(aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aCols                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUsado := Len(aHeader)
		aadd(aCOLS,Array(nUsado+1))
		For nI	:= 1 To nUsado
			aCols[1][nI] := CriaVar(aHeader[nI][2])
		Next
		aCOLS[1][nUsado+1] := .F.			
	EndIf
	//oGetDad:oBrowse:Refresh()
	oGetDad:Refresh()
EndIf

If Len(aCols)< nLinha
	nLinha := Len(aCols)
EndIf
If !aCols[ nLinha, nPosDel  ] .AND. Empty(aCols[nLinha,RetPosCpo('CBC_COD')])
	IW_MSGBOX(STR0022,STR0023) //"Existem campos obrigatorios que nao foram preenchidos!!!"###"Atencao"
	lRet := .F.
EndIf
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³VldCpo()            ³Autor³Erike Yuri da Silva³27/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Funcao de validacao de campos                      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Logico                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function VldCpo()
Local cNomeCpo	:= ""    
Local cEtiqProd	:= ""
Local cProd		:= ""
Local nQtdEtiq2 	:= 0
Local cLote     	:= ""
Local cSLote     	:= ""
Local cNumSeri  	:= ""
Local cTipId		:= ""
Local nLinha		:=	oGetDad:oBrowse:nAt
Local nColuna		:=	oGetDad:oBrowse:nCOLPOS
Local nPosEtiq	:= 0
Local nPosCodP	:= RetPosCpo('CBC_COD')
Local nPosArm		:= RetPosCpo('CBC_LOCAL')
Local nPosEnd		:= RetPosCpo('CBC_LOCALI')
Local nPosLote 	:= RetPosCpo('CBC_LOTECT')
Local nPosNumL	:= RetPosCpo('CBC_NUMLOT')
Local nPosNumS 	:= RetPosCpo('CBC_NUMSER')
Local nPosQtd		:= RetPosCpo('CBC_QUANT')
Local aEtiqueta	:= {}
Local aAreaSB1 	:= SB1->(GetArea())
Local aAreaSB2 	:= SB2->(GetArea())

If ValType(aHeadCBC)=="U" .OR. ValType(oGetDad)=="U"
	Return .F.
EndIf

If !lModelo1 .AND.  !aCols[nLinha,Len(aHeader)+1] .AND. !Empty(aCols[nLinha,RetPosCpo('CBC_CONTOK')])
	IW_MSGBOX(STR0024,STR0025)	 //'Nao eh possivel realizar alteracao!'###'Produto ja auditado'
	Return .F.
EndIf

cNomeCpo	:= aHeadCBC[nColuna,2]            
CBA->(DbSetOrder(1))
CBA->(DbSeek(xFilial('CBA')+M->CBB_CODINV)) 


If Trim(cNomeCpo) == "CBC_COD"                        
	If (CBA->CBA_TIPINV=='1') .AND. !Empty(CBA->CBA_PROD) .AND. !(CBA->CBA_PROD==M->CBC_COD)
		IW_MSGBOX(STR0026+; //'O mestre de inventario esta configurado para inventariar somente '
					 STR0027+CBA->CBA_PROD+'"!',STR0023)				 //'o produto "'###"Atencao"
		Return .F.
	EndIf                         

	If !lModelo1 .AND. AsCan(aCols,{|x| x[nColuna]==M->CBC_COD .AND. !Empty(x[RetPosCpo('CBC_CONTOK')])}) > 0
		IW_MSGBOX(STR0028,STR0029)	 //'Nao eh possivel incluir um produto ja auditado!'###'Atencao'
		Return .F.	
	EndIf                             
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xFilial("SB1")+M->CBC_COD+cArmazem))
		IW_MSGBOX(STR0030,STR0023) //"Produto nao cadastrado!"###"Atencao"
		RestArea(aAreaSB1)
		Return .F.
	EndIf                        	
	SB2->(DbSetOrder(1))
	If !SB2->(DbSeek(xFilial("SB2")+M->CBC_COD+cArmazem))
		CriaSB2(M->CBC_COD,cArmazem)
	EndIf                        	

	If GetMv('MV_LOCALIZ') =="S"
	  	If CBA->CBA_TIPINV == "2" .and. RetFldProd(M->CBC_COD,"B1_LOCALIZ") # "S"
			IW_MSGBOX(STR0032,STR0023) //"Produto sem controle de endereco"###"Atencao"
			RestArea(aAreaSB1)
			RestArea(aAreaSB2)
			Return .F.
	  	EndIf
	  	
	  	If (CBA->CBA_TIPINV == "2") .or. (CBA->CBA_TIPINV == "1" .and. RetFldProd(M->CBC_COD,"B1_LOCALIZ") == "S")	
	  		If Empty(cArmazem) .or. Empty(cEndereco)
			  	If !GetEndereco()                                   
				  	IW_MSGBOX(STR0033,STR0023) //"Favor informar o Armazem e Endereco - Tecle: F12"###"Atencao"
			  		Return .F.
			  	EndIf
	  		EndIf
	  	EndIf
   EndIf
   aEtiqueta := CBRetEtiEan(M->CBC_COD)
	If Len(aEtiqueta) == 0
		IW_MSGBOX(STR0034,STR0011) //"Produto/Etiqueta invalida!!"###"Aviso"
		Return .f.
	EndIf
	cProd		 := aEtiqueta[01]
	nQtdEtiq2 := aEtiqueta[02]
	cLote     := aEtiqueta[03]
   cNumSeri  := aEtiqueta[05]
	nQE       := 1                
	If ! CBProdUnit(aEtiqueta[1])
		nQE := CBQtdEmb(aEtiqueta[1])                   
		If empty(nQE)
			Return .f.
		EndIf
	EndIf	                  

	If CBA->CBA_TIPINV == "1"  
	   If ! CBA->CBA_PROD == cProd  .and. ! Empty(CBA->CBA_PROD)
			IW_MSGBOX(STR0035,STR0023) //"Produto diferente do que deve ser inventariado."###"Atencao"
			Return .F.
	   EndIf                           
	EndIf            

   	aCols[nLinha,nPosLote] 	:= cLote
	aCols[nLinha,nPosNumL]	:= cSLote
  	aCols[nLinha,nPosNumS]	:= cNumSeri
	aCols[nLinha,nPosEnd ] 	:= cEndereco
  	aCols[nLinha,nPosArm ] 	:= cArmazem
  	oGetDad:oBrowse:nCOLPOS 	:= nPosQtd-1	  	//Apos sua validacao posiciona na Quantidade a ser digitada
ElseIf Trim(cNomeCpo) == "CBC_CODETI"
	cEtiqProd	:= M->CBC_CODETI
	If lUsaCB001 
		nPosEtiq   := RetPosCpo('CBC_CODETI')
	   	If !AnaEtiqCB0(@cEtiqProd,aEtiqueta)
	   		Return .F.
	   	EndIf              
		If (CBA->CBA_TIPINV=='1') .AND. !Empty(CBA->CBA_PROD) .AND. !(CBA->CBA_PROD==aEtiqueta[01])
			IW_MSGBOX(STR0026+; //'O mestre de inventario esta configurado para inventariar somente '
						 STR0027+CBA->CBA_PROD+'"	!',STR0023)				 //'o produto "'###"Atencao"
			Return .F.
		EndIf	   	                                           

		aCols[nLinha,nPosEtiq]	:= cEtiqProd
		aCols[nLinha,nPosCodP]	:= aEtiqueta[01]
	  	aCols[nLinha,nPosArm ] 	:= aEtiqueta[10]   
	  	aCols[nLinha,nPosQtd ] 	:= If(Empty(aEtiqueta[02]),1,aEtiqueta[02])
	  	aCols[nLinha,nPosEnd ] 	:= aEtiqueta[09]
	    aCols[nLinha,nPosLote] 	:= aEtiqueta[16]
	  	aCols[nLinha,nPosNumL]	:= aEtiqueta[17]
	  	aCols[nLinha,nPosNumS]	:= aEtiqueta[23]    
 		oGetDad:Refresh()
		//oGetDad:AddLine()
	  	//	aCols[nLinha,RetPosCpo('CB0_CODET2')]	:= aEtiqueta[23] 			
	Else // Esta situacao so nao foi apagada pois usarei este codigo posteriormente
	   	If ! CBLoad128(@cEtiqProd)
			IW_MSGBOX(STR0036,STR0023) //"Leitura invalida"###"Atencao"
			Return .F.
	   	Endif                          
		cTipId:=CBRetTipo(cEtiqProd)
		If ! cTipId $ "EAN8OU13-EAN14-EAN128" 
			IW_MSGBOX(STR0037,STR0023) //"Etiqueta invalida"###"Atencao"
			Return .F.
		EndIf      
	   	aEtiqueta := CBRetEtiEan(cEtiqProd)
		If Len(aEtiqueta) == 0
			IW_MSGBOX(STR0036,STR0023) //"Leitura invalida"###"Atencao"
			Return .F.
		EndIf			
		aCols[nLinha,nPosCodP]	:= aEtiqueta[01]
	  	aCols[nLinha,nPosArm ] 	:= CBA->CBA_LOCAL
	   	aCols[nLinha,nPosLote] 	:= aEtiqueta[03]
	  	aCols[nLinha,nPosNumS]	:= aEtiqueta[05]	
	EndIf   
ElseIf  Trim(cNomeCpo) == "CB0_CODETI2"
	cEtiqProd	:= M->CB0_CODET2
  	If !AnaEtiqCB0(cEtiqProd,aEtiqueta)
  		Return .F.
  	EndIf     	
	aCols[nLinha,nPosCodP]	:= aEtiqueta[01]
  	aCols[nLinha,nPosArm ] 	:= aEtiqueta[10]
  	aCols[nLinha,nPosEnd ] 	:= aEtiqueta[09]
   aCols[nLinha,nPosLote] 	:= aEtiqueta[16]
  	aCols[nLinha,nPosNumL]	:= aEtiqueta[17]
  	aCols[nLinha,nPosNumS]	:= aEtiqueta[23]
  	CB0->(DbSetOrder(2))                                                            
   CB0->(DbSeek(xFilial('CB0')+Padr(cEtiqProd,TamSx3('CB0_CODET2')[1])))  	
  	aCols[nLinha,RetPosCpo('CB0_CODET')]	:= CB0->CB0_CODETI
ElseIf Trim(cNomeCpo) == "CBC_LOCALI"
	SBE->(DbSetOrder(1))  	
	If !SBE->(DbSeek(xFilial('SBE')+CBA->CBA_LOCAL+M->CBC_LOCALI))
		IW_MSGBOX(STR0038,STR0023) //"Endereco Invalido"###"Atencao"
		Return .F.
	EndIf
ElseIf Trim(cNomeCpo) == "CBC_CONTOK"                        
	Return .F.	
ElseIf lUsaCB001 .AND. Trim(cNomeCpo) == "CBC_QUANT"
	If Empty(aCols[nLinha,nPosCodP]) //Codigo do Produto
		Return .F.	
	EndIf     
	
	If !CBQTDVAR(aCols[nLinha,nPosCodP])
		 IW_MSGBOX(STR0039,STR0023) //"Produto nao possui quantidade variavel!"###"Atencao"
		 Return .F.
	EndIf
EndIf
RestArea(aAreaSB1)
RestArea(aAreaSB2)
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³VldTudoOk()         ³Autor³Erike Yuri da Silva³27/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Funcao de avaliacao apos confirmacao do botao Ok   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Logico                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function VldTudoOk()
Local nX
Local nPosDel  	:= Len( aHeader ) + 1
Local nPosChave	:= If(lUsaCB001,RetPosCpo('CBC_CODETI'),RetPosCpo('CBC_COD'))
Local lExitRow 	:= .F.

If !INCLUI .and. !ALTERA
	Return MsgYesNo(STR0040,STR0011) //"Deseja realmete excluir este lancamento de inventario?"###"Aviso"
EndIf

For nX:=1 To Len(aCols)
	If aCols[ nX, nPosDel ] .OR. Empty(aCols[ nX,nPosChave])
		Loop
	EndIf                       
	lExitRow := .T.
	Exit
Next

If !lExitRow
	IW_MSGBOX(STR0041,STR0023) //"Nao existem itens a serem gravados!"###"Atencao"
	Return .F.
EndIf

If MsgYesNo(STR0042,STR0011) //"Deseja finalizar a contagem?"###"Aviso"
	__cStatus	:= '2'
	lBloq 		:= .T.
Else
	__cStatus	:= '1'
	lBloq 		:= .F.
EndIf             

If INCLUI
	lVldTudoOk  := .T.
EndIf

Return .T.
                   



Static Function VldClose()
If lBloq
	Finalizar()
EndIf
If !lVldTudoOk
	DelCBB(M->CBB_CODINV+M->CBB_NUM)
	If !lModelo1 .AND. lCBBOk
		RecLock("CBA")
		CBA->CBA_AUTREC:= '1'
		CBA->(MsUnLock())  
	EndIf
EndIf
Return .T.

Static Function Finalizar()
Local nX			:= 0
Local cProd,cArm,cEnd,cLote,cSLote,cNumSeri
Local cCodUnit	:= CriaVar('D14_IDUNIT', .F.)
Local cTpunit		:= CriaVar('CBC_CODUNI', .F.)
Local lWmsNew		:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO		:= CBM->(ColumnPos("CBM_IDUNIT")) > 0

aProdEnd   := {}  
CBLoadEst(aProdEnd,.f.)
For nX := 1 to len(aProdEnd)
   cProd := aProdEnd[nX,1]
  	cArm     := aProdEnd[nX,4]
   cEnd     := aProdEnd[nX,5]
   cLote    := aProdEnd[nX,2]
   cSLote   := aProdEnd[nX,3]
  	cNumSeri := aProdEnd[nX,6]                 
   nQtdOri  := aProdEnd[nX,7]                      
   CBUnBlqInv(CBA->CBA_CODINV,cProd)
   If lWmsNew .And. lUniCPO .And. !Len(aProdEnd[nX]) <= 9
   	  cCodUnit:= aProdEnd[nX,9]
   	  cTpunit := aProdEnd[nX,10]
   	EndIf	
   //Exclui Historico CBM       
	ACD35CBM(5,CBA->CBA_CODINV,cProd,cArm,cEnd,cLote,cSLote,cNumSeri,cCodUnit,cTpunit)		      
Next          	
Return

//Retorna a possicao do Campo no aHeader
Static Function RetPosCpo(cCpo)
Return AsCan(aHeader,{|x| Trim(x[2])==Trim(cCpo)})


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Function  ³AnaEtiqCB0³ Autor ³ Totvs                 ³ Data ³ 17.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida etiqueta digitada 								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := AnaEtiqCB0(ExpC1,ExpA1)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cod. da Etiqueta                                    ³±±
±±³          ³ ExpA1 - Array com dados da etiqueta ref. CB0                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 - .T. / .F. => Validacao OK ou nao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ACD                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AnaEtiqCB0(cEtiqProd,aEtiqueta)
If AsCan(aCols,{|x| Trim(x[1])==Trim(cEtiqProd)}) > 0
	IW_MSGBOX(STR0043,STR0023) //"Codigo de Etiqueta ja lida!"###"Atencao"
	Return .F.
EndIf

aEtiqueta := CBRetEti(cEtiqProd,"01",.T.)
If Len(aEtiqueta) == 0
	IW_MSGBOX(STR0044,STR0023) //"Codigo de Etiqueta Invalido"###"Atencao"
	Return .F.
EndIf	                    
If aEtiqueta[10] <> cArmazem
	IW_MSGBOX(STR0069,STR0023) //"Armazém da etiqueta difere do Mestre de Inventário!"###"Atencao"
	Return .F.
EndIf	                    
SB1->(DbSetOrder(1))
If !SB1->(DbSeek(xFilial("SB1")+aEtiqueta[01]))
	IW_MSGBOX(STR0030,STR0023) //"Produto nao cadastrado!"###"Atencao"
	Return .F.
EndIf        
If GetMv('MV_LOCALIZ') =="S" 			   
  	If RetFldProd(SB1->B1_COD,"B1_LOCALIZ") == "S" .and. Empty(aEtiqueta[09])
		IW_MSGBOX(STR0045,STR0023) //"Etiqueta de produto sem endereco"###"Atencao"
		Return .F.
  	Elseif CBA->CBA_TIPINV == "2" .and. RetFldProd(SB1->B1_COD,"B1_LOCALIZ") # "S"
		IW_MSGBOX(STR0032,STR0023) //"Produto sem controle de endereco"###"Atencao"
		Return .F.                                            
  	Endif						
Endif	  

If Localiza(aEtiqueta[1])                  
	If GetMV("MV_ALTENDI") == "0"
		IF CBA->CBA_TIPINV== "2" .and. !Empty(aEtiqueta[09]) .and. ! aEtiqueta[10]+aEtiqueta[09] == CBA->CBA_LOCAL+CBA->CBA_LOCALI
			IW_MSGBOX(STR0046+CBA->CBA_LOCALI,STR0023) //"Produto pertence ao endereco:"###"Atencao"
			Return .F.                                           
		EndIf      
	ElseIF   !aEtiqueta[10]+aEtiqueta[09] == CBA->CBA_LOCAL+CBA->CBA_LOCALI
	   RecLock('CB0',.F.)
	   CB0->CB0_LOCALI := CBA->CBA_LOCALI
	   CB0->CB0_LOCAL  := CBA->CBA_LOCAL 
	   CB0->(MsUnlock())
	EndIf	
EndIf


If Len(Trim(cEtiqProd))> TamSX3('CB0_CODETI')[1]
	CB0->(DbSetOrder(2))                                                            
   CB0->(DbSeek(xFilial()+Padr(cID,TamSx3("CB0_CODET2")[1])))	
   cEtiqProd := CB0->CB0_CODETI
   CB0->(DbSetOrder(1)) 	   
EndIf
Return .T.
         
         

Static Function VldCodInv()
CBA->(DbSetOrder(1))
If !CBA->(DbSeek(xFilial('CBA')+M->CBB_CODINV))
	Return .F.
EndIf
If CBA->CBA_STATUS=='5' // 5=Processado
	IW_MSGBOX(STR0047,STR0029) //'Este mestre de inventario ja esta processado!'###'Atencao'
	Return .F.
EndIf
If CBA->CBA_STATUS=='4' // 4=Finalizado
	IW_MSGBOX(STR0048,STR0029) //'Este mestre de inventario ja esta finalizado!'###'Atencao'
	Return .F.
EndIf                    
Return .T.         

//-------------------------------------------------------------------
/*/{Protheus.doc} VldNLinha
Validação de Linha
@return NIL
/*/
//-------------------------------------------------------------------
Static Function VldNLinha()   
Local nPosProd	:= RetPosCpo('CBC_COD')
Local nPosArm		:= RetPosCpo('CBC_LOCAL')
Local nPosEnd		:= RetPosCpo('CBC_LOCALI')
Local nPosLote	:= RetPosCpo('CBC_LOTECT')
Local nPosSLote	:= RetPosCpo('CBC_NUMLOT')
Local nPosNSer	:= RetPosCpo('CBC_NUMSER')

If !lCBBOK .OR. !Empty(aCols[Len(aCols),nPosProd])
	Return NIL
EndIf

cArmazem := CBA->CBA_LOCAL  
If CBA->CBA_TIPINV=="2"
	cEndereco := CBA->CBA_LOCALI	
ElseIf CBA->CBA_TIPINV=="1" .AND. !Empty(CBA->CBA_PROD)
	cProduto := CBA->CBA_PROD
EndIf

If VldaCols(cProduto, cArmazem)           
	aCols[Len(aCols),nPosProd]	:= cProduto
	aCols[Len(aCols),nPosArm]	:= cArmazem
	aCols[Len(aCols),nPosEnd]	:= cEndereco
	aCols[Len(aCols),nPosLote]	:= Space(aHeader[nPosLote ,4])
	aCols[Len(aCols),nPosSLote]	:= Space(aHeader[nPosSLote,4])  
	aCols[Len(aCols),nPosNSer]	:= Space(aHeader[nPosNSer ,4])
	oGetDad:oBrowse:Refresh()
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCodOper
Valida código da Operação
@since 
@return .T.
/*/
//-------------------------------------------------------------------
Static Function VldCodOper()
Local cUltCont 	:= ""        
Local nX			:= 0
Local nY 			:= 0  
Local aCBC			:= {}

If Empty(M->CBB_CODINV)
	IW_MSGBOX(STR0049,STR0029) //'O codigo do mestre de inventario nao pode estar vazio!'###'Atencao'
	Return .F.	
EndIf
If Empty(M->CBB_USU)
	IW_MSGBOX(STR0050,STR0029) //'O codigo do operador nao pode estar vazio!'###'Atencao'
	Return .F.	
EndIf
CB1->(DbSetOrder(1))
If !CB1->(DbSeek(xFilial('CB1')+M->CBB_USU))
	Return .F.
EndIf        
If (CB1->CB1_INVPVC<>"1")// mesmo operador executar o mesmo inventario
   CBB->(dbSetOrder(2))
	If CBB->(dbSeek(xFilial('CBB')+"2"+M->CBB_USU+M->CBB_CODINV ))
		IW_MSGBOX(STR0051,STR0052) //'Operador ja realizou contagem para o inventario!'###'Sem Permissao'
		Return .F.
	EndIf	  
EndIf

CBA->(DbSetOrder(1))
CBA->(DbSeek(xFilial('CBA')+M->CBB_CODINV))

If CBA->CBA_CONTS == 1
   CBB->(DbSetOrder(1))
	If CBB->(DbSeek(xFilial('CBB')+CBA->CBA_CODINV )) .and. CBB->CBB_USU # M->CBB_USU
		IW_MSGBOX(STR0053+CBB->CBB_USU+STR0054,STR0055) //"Somente o Operador "###" pode dar continuidade a este inventario"###"Contagens == 1"
		Return .F.
	Endif
Endif
CBB->(DbSetOrder(2))
If CBB->(DbSeek(xFilial('CBB')+"1"+M->CBB_USU+CBA->CBA_CODINV ))
   If ! CBB->(RLock())
		IW_MSGBOX(STR0056,STR0029) //'Operador executando inventario em outro terminal!'###'Atencao'
		Return .F.                 
	EndIf	  	
	CBB->(DBUnLock())
Else                             
   cUltCont:=Space(6)	   
   If ! lModelo1 // se for modelo 2 tem que verificar se tem autorizacao
      If CBA->CBA_AUTREC=="2" // BLOQUEADO
			IW_MSGBOX(STR0057,STR0029) //'Inventario bloqueado para auditoria!'###'Atencao'
			Return .F.                 
      EndIf
	   CBB->(DbSetorder(3))
   	CBB->(DbSeek(xFilial('CBB')+CBA->CBA_CODINV))
	   While CBB->(!Eof() .and. xFilial('CBB')+CBA->CBA_CODINV == CBB_FILIAL+CBB_CODINV)
 	      cUltCont:=CBB->CBB_NUM
   	   CBB->(DbSkip())
	   EndDo             
   EndIf   
   /*    
   Reclock("CBB",.T.)
   CBB->CBB_FILIAL := xFilial("CBB")
	CBB->CBB_NUM    := CBProxCod('MV_USUINV')
	CBB->CBB_CODINV := CBA->CBA_CODINV
	CBB->CBB_USU    := cCodOpe
	CBB->CBB_STATUS := "1"
	CBB->(MsUnlock())
//	Reclock("CBB",.F.)	                            
	*/
	// transpor as contagens batidas par este usuario
   If ! lModelo1 .and. ! Empty(cUltCont)
		CBC->(DbSetOrder(1))
		CBC->(DbSeek(xFilial('CBC')+cUltCont))
		While CBC->(!Eof() .and. xFilial('CBC')+cUltCont == CBC_FILIAL+CBC_NUM)
		   If CBC->CBC_CONTOK=="1"
		      aadd(aCBC,array(CBC->(FCount())))
		      For nX:= 1 to CBC->(FCount())
		         aCBC[len(aCBC),nX] := CBC->(FieldGet(nX))
		      Next
		   EndIf
			CBC->(DbSkip())
		End    
		For nX:= 1 to len(aCBC)  
		   Reclock("CBC",.t.)
			For nY := 1 to CBC->(FCount())    
			   If CBC->(FieldName(nY)) == "CBC_CODINV"
			      CBC->CBC_CODINV := CBB->CBB_CODINV
			   ElseIf CBC->(FieldName(nY)) == "CBC_NUM"
     				CBC->CBC_NUM    := CBB->CBB_NUM
			   Else
			   	CBC->(FieldPut(nY,aCBC[nX,nY])) 		
			   EndIf	
			Next              
			CBC->(MsUnLock())
		Next		 
	EndIf
EndIf   

Return .T.         


Static Function IniciaCBM(aProdEnd)
Local nX
Local cProd,cArm,cEnd,cLote,cSLote,cNumSeri,nQtdOri,cCoduni,cTpuni
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lUniCPO	  := CBM->(ColumnPos("CBM_IDUNIT")) > 0
For nX := 1 to len(aProdEnd)            
   cProd 		:= aProdEnd[nX,1]
   cArm		:= aProdEnd[nX,4]
   cEnd		:= aProdEnd[nX,5]
   cLote		:= aProdEnd[nX,2]
   cSLote		:= aProdEnd[nX,3]
   cNumSeri	:= aProdEnd[nX,6]                 
   nQtdOri		:= aProdEnd[nX,7]
   If lWmsNew .And. lUniCPO .And. !Len(aProdEnd[nX]) <= 9
   		 cCoduni:= aProdEnd[nX,9] 
   		 cTpuni := aProdEnd[nX,10] 
   EndIF                 
   RecLock("CBM",.T.)
   CBM->CBM_FILIAL := xFilial("CBM")
   CBM->CBM_CODINV := CBA->CBA_CODINV
	CBM->CBM_LOCAL  := cArm
	CBM->CBM_LOCALI := cEnd
	CBM->CBM_COD    := cProd
	CBM->CBM_LOTECT := cLote
	CBM->CBM_NUMLOT := cSLote
   CBM->CBM_NUMSER := cNumSeri
   CBM->CBM_QTDORI := nQtdOri
   If lWmsNew .And. lUniCPO .And. !Len(aProdEnd[nX]) <= 9
   		CBM->CBM_IDUNIT	:=	cCoduni
   		CBM->CBM_CODUNI	:=	cTpuni
   	EndIf
   CBM->CBM_AJUST := "2"
	CBM->(MsUnLock())
Next	   
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EnchoiceOk
Verificação da Enchoice
@return NIL
/*/
//-------------------------------------------------------------------
Static Function EnchoiceOk()
Local cUltCont	:= Space(6)
Local nY			:= 0
Local nX			:= 0
Local nPos			:= 0
Local lInicio		:= If(CBA->CBA_STATUS=='0',.T.,.F.)
Local aCBC			:= {}
Local bCampo 		:= {|nCPO| Field(nCPO) }

If !lModelo1 // se for modelo 2 tem que verificar se tem autorizacao
	If CBA->CBA_AUTREC=="2" // BLOQUEADO
		IW_MSGBOX(STR0057,STR0029) //'Inventario bloqueado para auditoria!'###'Atencao'
		Return .F.
	EndIf
	CBB->(DbSetorder(3))
	CBB->(DbSeek(xFilial('CBB')+M->CBB_CODINV))
	While CBB->(!Eof() .and. xFilial('CBB')+M->CBB_CODINV == CBB_FILIAL+CBB_CODINV)
		cUltCont:=CBB->CBB_NUM
		CBB->(DbSkip())
	EndDo
EndIf

//Não grava Enchoice se o operador não estiver OK
If !VldCodOper() .Or. lEncLock
	Return .F.
End

Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o cabecalho do Lancamento de Inventario                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CBB")
	RecLock("CBB",INCLUI)
	For nY := 1 TO CBB->(FCount())
		FieldPut(nY,M->&(EVAL(bCampo,nY)))
	Next nY
	CBB->CBB_STATUS	:= "1"
	CBB->CBB_FILIAL 	:= xFilial("CBB")
	CBB->(MsUnLock())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa numero de contagens realizadas do mestre          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CBAtuContR(CBB->CBB_CODINV, 1)

	// transpor as contagens batidas par este usuario
	If !lModelo1 .and. !Empty(cUltCont)
		CBC->(DbSetOrder(1))
		CBC->(DbSeek(xFilial('CBC')+cUltCont))
		While CBC->(!Eof() .and. xFilial('CBC')+cUltCont == CBC_FILIAL+CBC_NUM)
			If CBC->CBC_CONTOK=="1"
				aadd(aCols,array(Len(aHeader)+1))
				aadd(aCBC,array(CBC->(FCount())))
				For nX:= 1 to CBC->(FCount())
					aCBC[len(aCBC),nX] := CBC->(FieldGet(nX))
			      //GRAVA NO ACOLS
					nPos := Ascan(aHeader,{|x| TRIM(x[2])==TRIM(CBC->(FieldName(nX))) })
					If nPos > 0
						aCols[Len(aCols),nPos] := CBC->(FieldGet(nX))
					EndIf
				Next
				aCols[Len(aCols)][Len(aHeader)+1] := .F.
			EndIf
			CBC->(DbSkip())
		End
		If Len(aCols) > 1 .and. Empty(aCols[1,1])
			ADel(aCols,1)
			ASize(aCols,Len(aCols)-1)
		EndIf
		
		oGetDad:Refresh()
		For nX:= 1 to len(aCBC)
			Reclock("CBC",.t.)
			For nY := 1 to CBC->(FCount())
				If CBC->(FieldName(nY)) == "CBC_CODINV"
					CBC->CBC_CODINV := CBB->CBB_CODINV
				ElseIf CBC->(FieldName(nY)) == "CBC_NUM"
					CBC->CBC_NUM    := M->CBB_NUM
				Else
					CBC->(FieldPut(nY,aCBC[nX,nY]))
				EndIf
			Next
			CBC->(MsUnLock())
		Next
	EndIf
End Transaction
	   
If lInicio
	lBloq 		:= .T.
	aProdEnd   	:= {}
	CBLoadEst(aProdEnd)
	IniciaCBM(aProdEnd)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera o Status do Mestre de Inventario                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("CBA",.f.)
If ! lModelo1 // se for modelo 2 tem que verificar se tem autorizacao
	CBA->CBA_AUTREC:="2" // BLOQUEADO
EndIf
CBA->CBA_STATUS := "1"  // 1=Em andamento
CBA->(MsUnlock())

lCBBOk := .T.
ConfigCols()
//Atualiza a MsGetDados
VldNLinha()
lEncLock := .T.
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ConfigCols
Configura o aCols
@return NIL
/*/
//-------------------------------------------------------------------
Static Function ConfigCols()
Local nPosProd 	:= RetPosCpo('CBC_COD')
Local nPosEnder	:= RetPosCpo('CBC_LOCALI')
Local nPosQtd		:= RetPosCpo('CBC_QUANT')    
Local nPosContOk	:= RetPosCpo('CBC_CONTOK')
Local lVldQtdInv 	:= If(lUsaCB001,(GetMv("MV_VQTDINV")=="1"),.t.)

If lUsaCB001
	oGetDad:AINFO[nPosProd, 1]	:= ""
	oGetDad:AINFO[nPosProd, 5]	:= "V"	
	If !lVldQtdInv .or. CBQtdVar(CBC->CBC_COD) 
		oGetDad:AINFO[nPosQtd, 5]	:= "V"		
	EndIf		
Else
	oGetDad:AINFO[nPosProd, 1]	:= "SB1"
	oGetDad:AINFO[nPosProd, 5]	:= "A"	
EndIf
If CBA->CBA_TIPINV=="1"
	oGetDad:AINFO[nPosEnder,1]	:= "CBA"
	oGetDad:AINFO[nPosEnder,5]	:= "A"
EndIf	
If nPosContOk > 0  // So existira para o Inventario Modelo2
	oGetDad:AINFO[nPosEnder,5]	:= "V"
EndIf

Return NIL

Static Function DelCBB(cNum)
Local cCodInv   := ""

CBB->(DbSetOrder(3))
If CBB->(DbSeek(xFilial('CBB')+cNum))
	cCodInv := CBB->CBB_CODINV
	RecLock("CBB",.F.)
	CBB->(DbDelete())
	CBB->(MsUnLock())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Decrementa numero de contagens realizadas do mestre          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CBAtuContR(cCodInv, 2)
	
EndIf
Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿
³Funcao³GetEndereco()       ³Autor³Erike Yuri da Silva³17/07/04³
ÃÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´
³Descricao ³Janela que permite informar o endereco usado para  ³ 
³          ³contagem                                           ³ 
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno:  ³Nenhum                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function GetEndereco()
Local oDlg,oGetArm,oGetEnd

If GetMv('MV_LOCALIZ') <>"S" 
	IW_MSGBOX(STR0058,STR0029) //'Controle de Localizacao Desativado.'###'Atencao'
	Return .F.
EndIf                     

If !Empty(CBA->CBA_PROD) .AND. !Localiza(CBA->CBA_PROD)
	IW_MSGBOX(STR0059,STR0029) //'Produto nao tem Localizacao.'###'Atencao'
	Return .F.
EndIf

DEFINE DIALOG oDlg TITLE STR0060 FROM 0, 0 TO 22, 75 SIZE 200, 95 //"Informar Localizacao"
	TSay():New( 005, 002, {||STR0061},oDlg, ,, , , ,.T., , , 22, 12) //"Local:"
	TSay():New( 020, 002, {||STR0062},oDlg, ,, , , ,.T., , , 70, 12) //"Endereco:"
	oGetArm := TGet():New( 003, 030, bSETGET(cArmazem), oDlg , 20, 10, "@!", {|| !Empty(cArmazem) }, , , , .T. , , .T., STR0063, .F. , {||.T.}) //"Informe o Armazem"
	oGetEnd := TGet():New( 018, 030, bSETGET(cEndereco), oDlg , 60, 10, "@!", {|| VldEnd(@oGetArm,@oGetEnd) }, , , , .T. , , .T., STR0063, .F. , {||!Empty(cArmazem)}) //"Informe o Armazem"
	TButton():New(030,070, STR0064, oDlg, {|| If(VldEnd(@oGetArm,@oGetEnd),oDlg:End(),.T.)}, 30, 14, , , .F., .T., , , .T.) //"&Confirmar"
ACTIVATE DIALOG oDlg   CENTER

If Empty(cArmazem) .or. Empty(cEndereco)
	Return .F.
EndIf        

Return .T.



Static Function VldEnd(oGetArm,oGetEnd)
If ExistBlock('CBINV02')
	If ! ExecBlock("CBINV02",,,{cArmazem,cEndereco})
		cEndereco := Space(TamSX3("BF_LOCALIZ")[1])
		oGetEnd:Refresh()
		Return .f.
	EndIf
EndIf

If CBA->CBA_TIPINV == "2"  // 2=Por Endereco     
   If ! CBA->CBA_LOCAL == cArmazem .or. ! CBA->CBA_LOCALI == cEndereco   
		IW_MSGBOX(STR0065+chr(13)+CHR(10)+STR0066+CBA->CBA_LOCAL+"-"+CBA->CBA_LOCALI,STR0029) //'Armazem e endereco incorreto.'###'O correto seria:'###'Atencao'
		cEndereco:= Space(TamSX3("BF_LOCALIZ")[1])
		oGetEnd:Refresh()		
		oGetArm:SetFocus()
		Return .f.
   EndIf           
Else
   SBE->(DbSetOrder(1))
   If !SBE->(DbSeek(xFilial()+cArmazem+cEndereco))
		IW_MSGBOX(STR0067,STR0029) //'Endereco nao cadastrado.'###'Atencao'
		cEndereco:= Space(TamSX3("BF_LOCALIZ")[1])
		oGetArm:SetFocus()
		oGetEnd:Refresh()		
		Return .f.
   EndIf                
EndIf
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldaCols
Validação de Saldo de Produtos
@author marco.guimaraes
@since 25/07/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function VldaCols(cProdSld, cArmSld)
Local lRet			:= .T.
Local aAreaSB2	:= SB2->(GetArea())
Local aEtiqueta   := {}
Default cProdSld	:= ""
Default cArmSld	:= ""

If !SB2->(dbSeek(xFilial('SB2')+cProdSld+cArmSld))
	If !Empty(cProdSld) .And. !Empty(cArmSld)
		CriaSB2(cProdSld,cArmSld) //"Produto e armazem nao cadastrado de saldos!"###"Atencao"
	EndIf	
EndIf

If lRet .And. !Empty(cProdSld)
	aEtiqueta := CBRetEtiEan(cProdSld)
	If !( Len(aEtiqueta) > 0 )
		IW_MSGBOX(STR0034,STR0011) //"Produto/Etiqueta invalida!!"###"Aviso"
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaSB2)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AcdCopVal
Funçao de validões WMS

@author Andre Maximo
@since 04/10/17
@version 1.0
@Param Cod, Armazem, Endereço,Unitizador
/*/
//-------------------------------------------------------------------

Function AcdaCopVal(cIdUnit)

Local lWmsNew		:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lRet 		:= .F.
Local cCoduni		:= CriaVar('D14_CODUNI', .F.)

Local nPosArm		:= RetPosCpo('CBC_LOCAL')
Local nPosEnd		:= RetPosCpo('CBC_LOCALI')
Local nPosCod  	:= RetPosCpo('CBC_NUMSER')
Local nPosUnit  	:= RetPosCpo('CBC_CODUNI')

Default cIdUnit:= CriaVar('D14_IDUNIT', .F.)



IF lWmsNew
	If  !Empty(aCols[Len(aCols),nPosArm]) .And.  !Empty(aCols[Len(aCols),nPosEnd])
		 cArmazem := aCols[Len(aCols),nPosArm]	 
		 cEndereco:= aCols[Len(aCols),nPosEnd]	
		 If WmsVldEti(cArmazem,cEndereco,cIdUnit,@cCoduni)
			 lRet := .T.
			 aCols[Len(aCols),nPosUnit]	:= cCoduni
		 EndIf
	Else
		IW_MSGBOX(STR0071,STR0011)
	EndIf
Else
	IW_MSGBOX(STR0072,STR0011)
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AcdWmsUni
Funçao de criacao de lancamento de unitizador fechado.

@author Andre Maximo
@since 04/10/17
@version 1.0
@Param 
/*/
//-------------------------------------------------------------------

Function AcdWmsUni()
Local oDlg	:= Nil
Local oFont1	:= Nil 
Local oSize    
Local cCodUnit := Replicate(" ", (TamSx3('CBC_IDUNIT')[1]))
Local cEnd 	:= CBA->CBA_LOCALI
Local cLocal := CBA->CBA_LOCAL
Local cOpUni	:= CBA->CBA_CODUNI
Local cTitulos
Local nCpoUnit:= TamSx3('CBC_IDUNIT')[1]

cTitulo := ESTFwSX3Util():xGetDescription( "CBC_IDUNIT" )

DEFINE MSDIALOG oDlg FROM  25,000 TO 125,200 TITLE OemToAnsi(cTitulo) PIXEL //"Unitizador"
@ 01,02 TO 47,100 LABEL Alltrim(RetTitle("CBC_IDUNIT"))OF oDlg PIXEL
@ 13,13 MSGET cCodUnit Picture PesqPict("CBC","CBC_IDUNIT") Valid WmsVldEti(cLocal,cEnd,cCodUnit) SIZE nCpoUnit,13 OF oDlg PIXEL
DEFINE SBUTTON FROM 35,13 TYPE 1 ACTION (oDlg:End(),lOk:=.T.) ENABLE OF oDlg
DEFINE SBUTTON FROM 35,42 TYPE 2 ACTION (oDlg:End(),lOk:=.F.) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

If lOk .And. !Empty(cCodUnit) .And. Iif(cOpUni== "2",!MsgYesNo(STR0074,STR0011),Iif(cOpUni== "1",.T.,.F.))
	AProdUni := WmsSldUni(cCodUnit)
	If Len(AProdUni) > 0 
		lProcUnit:= AcdWMSaCol(CBB->CBB_NUM,CBB->CBB_CODINV,AProdUni)
	EndIf
EndIf
	   
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AcdWMSaCol
Funçao de criacao de lancamento de unitizador fechado.

@author Andre Maximo
@since 04/10/17
@version 1.0
/*/
//-------------------------------------------------------------------

Function AcdWmsAcol(cNum,cInvent,aProdUni)
Local nI			:=	0
Local nPosProd	:=	RetPosCpo('CBC_COD')
Local nPosArm		:=	RetPosCpo('CBC_LOCAL')
Local nPosQtd		:=	RetPosCpo('CBC_QUANT')
Local nPosEnd		:=	RetPosCpo('CBC_LOCALI')
Local nPosLot		:=	RetPosCpo('CBC_LOTECT')
Local nPosSlot  	:=	RetPosCpo('CBC_NUMLOT')
Local nPosSer  	:=	RetPosCpo('CBC_NUMSER')
Local nPosUnit	:=	RetPosCpo('CBC_IDUNIT')
Local nPosTpUni	:=	RetPosCpo('CBC_CODUNI')
Local nPosAjus	:=	RetPosCpo('CBC_AJUST ')
Local nPosOk		:=	RetPosCpo('CBC_CONTOK')
Local cPosOk		:=	CriaVar('CBC_CONTOK',.F.)

//Retorno array WMS unitizado.
//[1]  Local            
//[2]  Endereço         
//[3]  Lote             
//[4]  Sub-lote         
//[5]  Número de Série  
//[6]  Quantidade       
//[7]  Seg. Un medida   
//[8]  Data de Validade 
//[9]  Produto origem   
//[10] Produto          
//[11] Id Unitizador    
//[12] Tipo Unitizador  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:=1 To Len(aProdUni)
	If empty(aCOLS[n][nPosProd]) .And. !aCOLS[Len(aCols)][Len(aHeader)+1]  
		aCOLS[n][nPosProd]	:=	AProdUni[nI,10]
		aCOLS[n][nPosArm]		:=	AProdUni[nI,1]
		aCOLS[n][nPosQtd] 	:=	AProdUni[nI,6]
		aCOLS[n][nPosEnd] 	:=	AProdUni[nI,2]
		aCOLS[n][nPosSlot] 	:=	AProdUni[nI,4]
		aCOLS[n][nPosLot] 	:=	AProdUni[nI,3]
		aCOLS[n][nPosSer] 	:=	AProdUni[nI,5]
		aCOLS[n][nPosAjus] 	:=	"2"
		aCOLS[n][nPosTpUni] 	:=	AProdUni[nI,12]
		aCOLS[n][nPosUnit] 	:=	AProdUni[nI,11]
		aCOLS[n][nPosOk] 		:=	cPosOk
	Else
		AADD(aCols,Array(Len(aHeader)+1))
		aCOLS[Len(aCols)][nPosProd] 	:=	AProdUni[nI,10]
		aCOLS[Len(aCols)][nPosArm] 		:=	AProdUni[nI,1]
		aCOLS[Len(aCols)][nPosQtd] 		:=	AProdUni[nI,6]
		aCOLS[Len(aCols)][nPosEnd] 		:=	AProdUni[nI,2]
		aCOLS[Len(aCols)][nPosSlot] 	:=	AProdUni[nI,4]
		aCOLS[Len(aCols)][nPosLot] 		:=	AProdUni[nI,3]
		aCOLS[Len(aCols)][nPosSer] 		:=	AProdUni[nI,5]
		aCOLS[Len(aCols)][nPosAjus] 	:=	"2"
		aCOLS[Len(aCols)][nPosTpUni]	:=	AProdUni[nI,12]
		aCOLS[Len(aCols)][nPosUnit]		:=	AProdUni[nI,11]
		aCOLS[Len(aCols)][nPosOk]		:=	cPosOk
		
		aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
	EndIf
Next nI


Return .T.

/*/{Protheus.doc} Menudef
	(long_description)
	@type  Static Function
	@author TOTVS
	@since 24/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function MenuDef()

Local aRotMenu := { }


aRotMenu :=  {		{ OemToAnsi(STR0004)	 	,"AxPesqui"	,0,1},; //"Pesquisar"
					{ OemToAnsi(STR0005)		,"ACDA035V"	,0,2},; //"Visualisar"
					{ OemToAnsi(STR0006)		,"ACDA035I"	,0,3},; //"Incluir"
					{ OemToAnsi(STR0007)		,"ACDA035A"	,0,4,17},; //"Alterar"
					{ OemToAnsi(STR0008)		,"ACDA035D"	,0,5,17},; //"Excluir"
					{ OemToAnsi(STR0009)		,"ACDA035L" ,0,3,0} } //"Legenda"

 
 RETURN aRotMenu
