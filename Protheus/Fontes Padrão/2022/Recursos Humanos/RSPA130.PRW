#include "Protheus.ch"           
#Include "font.ch"
#Include "colors.ch"
#include "RSPA130.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ?RSPA130  ?   Autor   ?Cristina Ogura        ?Data ?25.08.98 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ?Rotina de Realizacao de Testes.                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ?RSPA130()                                                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?RSPA130                                                         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ?Data   ?BOPS      ? Motivo da Alteracao                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.?9/07/14³TQENN4     ³Incluido o fonte da 11 para a 12 e efetua-³±?
±±?           ?       ?          ³da a limpeza.                             ³±?
±±³Renan Borges?4/10/14³TQQTQX     ³Ajuste no agendamento do teste para respei³±?    
±±?           ?       ?          ³tar as datas,informadas no periodo: De/Ate³±?
±±³Renan Borges?5/01/15³TREMH6		³Ajuste para montagem de avaliações de     ³±?
±±?           ?       ?		³acordo com a quantidade de questões, pr? ³±?
±±?           ?       ?		³determinada pelo tamanho do campo QQ_ITEM.³±?
±±³Oswaldo L.  ?3/04/17³DRHPONTP-9  ³Projeto cTree                            ³±?      
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPA130

Local aCores	:= {}
Local aAuxCor   := {}
Local _nX       := 0
Private cFiltraSQD	:= ""			//Variavel para filtro
Private aIndexSQD	:= {}			//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro
Private oBrwSQD

Private aFldRot 	:= {'QG_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F. 
Private aFldOfusca 	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "QG_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "QG_NOME" )
	ENDIF
EndIf

Private cCadastro:=OemtoAnsi(STR0001) //"Testes"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Define Array contendo as Rotinas a executar do programa      ?
//?----------- Elementos contidos por dimensao ------------     ?
//?1. Nome a aparecer no cabecalho                              ?
//?2. Nome da Rotina associada                                  ?
//?3. Usado pela rotina                                         ?
//?4. Tipo de Transa‡„o a ser efetuada                          ?
//?   1 - Pesquisa e Posiciona em um Banco de Dados             ?
//?   2 - Simplesmente Mostra os Campos                         ?
//?   3 - Inclui registros no Bancos de Dados                   ?
//?   4 - Altera o registro corrente                            ?
//?   5 - Remove o registro corrente do Banco de Dados          ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private aLegenda := {}
Private nOpMenu := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Definiao de cores por usuarios      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
aCores  := { 	{ "SQD->QD_DATA==dDataBase .And. SQD->QD_OK!='S'",'BR_VERDE', "" },;
				{ "SQD->QD_DATA < dDataBase .And. SQD->QD_OK!='S'",'BR_AZUL', "" },;
				{ "SQD->QD_OK=='S'",'BR_VERMELHO', "" },;
				{ "SQD->QD_DATA > dDataBase" ,'BR_AMARELO', "" }}
					

If ExistBlock("RSP130LEG")
	aAuxCor := ExecBlock("RSP130LEG",.F.,.F.,{aCores} )
	If ValType(aAuxCor) == "A" .AnD. Len(aAuxCor) > 0
		aCores    := {}
		aLegenda  := {}
		For _nX := 1 To Len(aAuxCor)
			aAdd(aCores,   {aAuxCor[_nX,1], aAuxCor[_nX,2]})
			aAdd(aLegenda, {aAuxCor[_nX,2], If(Empty(aAuxCor[_nX,3]), "-", aAuxCor[_nX,3])})
		Next _nX  
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Variaveis utilizadas para parametros                         ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// mv_par01		- Curriculo De
// mv_par02		- Curriculo Ate
// mv_par03		- Data De
// mv_par04		- Data Ate
// mv_par05		- Situacao Teste 1-Aberto 2-Realizado 3-Ambos

Pergunte("RSP130",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Inicializa o filtro utilizando a funcao FilBrowse                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQD")
dbSetOrder(1)

//Monta o Browse
oBrwSQD:= FwMBrowse():New()
oBrwSQD:SetAlias( 'SQD' )
oBrwSQD:SetDescription(cCadastro) 		//"Testes"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Array de Cores da Mbrowse											   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
//Legenda	
BrwSQDLeg(@oBrwSQD, aCores)

//Menu
oBrwSQD:SetmenuDef( 'RSPA130' )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
?Inicializa o filtro                                                    ?
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

  
cFiltraSQD 	:= 	"!Empty(SQD->QD_TESTE)"+;
				" .And. SQD->QD_CURRIC >= '"+mv_par01+"' .And. SQD->QD_CURRIC <= '"+mv_par02+"'"+;
				" .And. Dtos(SQD->QD_DATA) >= '"+Dtos(mv_par03)+"' .And. Dtos(SQD->QD_DATA) <= '"+Dtos(mv_par04)+"'"+;
				" .And. SQD->QD_OK $ '"+Iif( mv_par05 == 1, " N", Iif( mv_par05 == 2, "S", " SN" ) )+"'"

oBrwSQD:SetFilterDefault(cFiltraSQD)

oBrwSQD:Activate()
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Deleta o filtro utilizando a funcao FilBrowse                     	   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQD",aIndexSQD)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?A130Aciona?Autor ?Cristina Ogura       ?Data ?25.08.98 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Aciona o teste que sera executado pelo candidato.          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?A130Aciona(ExpC1,ExpN1,ExpN2)                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros?ExpC1 = Alias do arquivo                                   ³±?
±±?         ?ExpN1 = Numero do registro                                 ³±?
±±?         ?ExpN2 = Opcao selecionada                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?RSPA130                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Function A130Aciona(cAlias,nReg,nOpcx)

Local oDlg, oLbx, oFont, oBtn1, oBtn2, oGroup, oGroup1
Local aMSG		:= Array(4)
Local dData 	:= dDataBase
Local cNome		:= ""
Local cVar		:= ""
Local cMsg		:= GetMV("MV_RSPMSG")
Local aRet		:= {}
Local cArqTab	:= ""
Local nSavRec	:= 0
Local nOrder 	:= IndexOrd()
Local nx 		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Declaração de arrays para dimensionar tela		             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}	
Local aObj1Coords 	:= {}	
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}	
Local aObj2Coords 	:= {}	
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}	
Local aObj3Coords 	:= {}	
Local aAdv4Size		:= {}
Local aInfo4AdvSize	:= {}
Local aObj4Size		:= {}	
Local aObj4Coords 	:= {}
Local nTamItem		:= TamSx3("QQ_ITEM")[1] // Tamanho do campo item da tabela SQQ, que ?o limitador de questões por avaliação.

Local cBlqCV	:= SuperGetMv("MV_BLQCV",,"1")

Private oBrw13, oOK, oNOK, oRadio , oScroll
Private nListBox:= 0 
Private nSeq	:= 0 
Private nSeqAnt := 1
Private aAltern	:= {}
Private aListBox:= {}
Private aFinal	:= {}
Private aRad	:= {}
Private cCurric	:= SQD->QD_CURRIC
Private cMemo 	:= ""		
Private aCampos	:= {}
Private cArq	:= ""	//Arquivo temporario TRB
Private oTmpTRB 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Deleta o filtro utilizando a funcao FilBrowse                     	   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQD",aIndexSQD)
aIndexSQD := {}

oOk := LoadBitmap( GetResources(), "LBOK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

aFill(aMSG,Space(90))

If SQD->QD_OK == "S"
	Help("",1,"A130OK")			// Este candidato ja executou estes deste verifique outro teste a ser executado
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Inicializa o filtro utilizando a funcao FilBrowse                      ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bFiltraBrw)

	dbSelectArea("SQD")
	dbSetOrder(nOrder)
	Return .F.
EndIf

nSavRec:= RecNo()

// Busca o nome do candidato
dbSelectArea("SQG")
dbSetOrder(1)
If SQG->(dbSeek(xFilial("SQG")+SQD->QD_CURRIC) )
	if (SQG->(Columnpos("QG_ACTRSP")) > 0 .and. SQG->QG_ACTRSP <> '1') .or. SQG->(Columnpos("QG_ACTRSP")) <= 0  //1- sem aceite e 2-com aceite
		if (cBlqCV <> "2" .or. (cBlqCV == "2" .and. SQG->QG_ACEITE == "2")) //1=Sem aceite; 2=Aceite vigente gravado 
			cNome := SQG->QG_NOME
			cNome := If(lOfuscaNom,Replicate('*',15),cNome)
		else
			cNome := ''
		endif
	else
		cNome := ''
	ENDIF
ELSE
	cNome := ''
EndIf

// Monta o listbox com os teste do candidato
IF !EMPTY(CNOME) 
	dbSelectArea("SQD")
	dbSetOrder(2)
	dbSeek(xFilial("SQD")+cCurric)
	While !Eof() .And. xFilial("SQD")+cCurric ==;
							SQD->QD_FILIAL+SQD->QD_CURRIC
								
		If SQD->QD_OK == "S" .Or. DtoS(SQD->QD_DATA) # DtoS(dData) .or. Empty(SQD->QD_TESTE)
			dbSkip()
			Loop
		EndIf								 
								
		aRet:= RspxList(SQD->QD_TESTE)
		//1- Descricao   2- Qtde Questoes 3-Duracao 4- Cod.Teste
		Aadd(aListbox,{aRet[1],aRet[2],aRet[3],SQD->QD_TESTE})
		//1- Descricao   2- Qtde Questoes 3-Duracao 4- Tempo que levou 5- Qtde resolvida
		Aadd(aFinal,{aRet[1],aRet[2],aRet[3],"",""})
		dbSkip()
	EndDo	

	If Len(aListBox) <= 0
		dbGoto( nSavRec )
		Help("",1,"A130VAZIO")					// Nao existe nenhum candidato cadastrado no dia de hoje
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Inicializa o filtro utilizando a funcao FilBrowse                      ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Eval(bFiltraBrw)
		
		dbSelectArea("SQD")
		dbSetOrder(nOrder)
		
		Return .F.	
	EndIf

	If Val(aRet[2]) < 1  
		Help("",1,"A130QUEST") //Nao existe nenhuma questao cadastrada para o Teste
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Inicializa o filtro utilizando a funcao FilBrowse                      ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Eval(bFiltraBrw)
		
		dbSelectArea("SQD")
		dbSetOrder(nOrder)
		
		Return .F.	
	EndIf

	// Monta o array com a mensagem a ser mostrada para o candidato
	For nx:=1 To MLCount(cMsg,90)
		If nx > 4
			Exit
		EndIf	
		aMsg[nx]:=MemoLine(cMSG,90,nx,,.T.)
	Next nx

	// Monta o arquivo de trabalho para executar o teste
	aAdd(aCampos, {"TRB_TESTE"	, "C",	003		, 0})	// Codigo do Teste
	aAdd(aCampos, {"TRB_SEQ"	, "C",	nTamItem, 0})	// Sequencia das questoes
	aAdd(aCampos, {"TRB_QUESTA"	, "C",	003		, 0})	// Codigo da Questao
	aAdd(aCampos, {"TRB_TOPICO"	, "C",	003		, 0})	// Codigo do Topico  
	aAdd(aCampos, {"TRB_DQUEST"	, "M",	010		, 0})	// Descricao da Questao
	aAdd(aCampos, {"TRB_ALTERN"	, "C",	002		, 0})	// Codigo da Alternativa
	aAdd(aCampos, {"TRB_DALTER"	, "C",	250		, 0})	// Descricao da Alternativa
	aAdd(aCampos, {"TRB_PERCEN"	, "N",	006		, 2})	// Percentual de correcao
	aAdd(aCampos, {"TRB_RESPOS"	, "N",	001		, 0})	// Resposta 1= se nao marcou 2= se marcou 3= se for memo
	aAdd(aCampos, {"TRB_MEMO"	, "M",	010		, 0})	// Resposta dissertativa
	aAdd(aCampos, {"TRB_TIPOBJ"	, "C",	001		, 0})	// Tipo de Objeto das Respostas
	aAdd(aCampos, {"TRB_QTRESP"	, "N",	002		, 0})	// Qtde. Maxima de Respostas
	aAdd(aCampos, {"TRB_TIPO"	, "C",	003		, 0})	// Tipo de Avaliacao
			
	RspCriaTRB()

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	?Monta as Dimensoes dos Objetos         					   ?
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize( , .T., 390)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aAdd( aObjCoords , { 000 , 060 , .T. , .F. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

	aAdv1Size    := aClone(aObjSize[1])
	aInfo1AdvSize    := { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 1 }
	aAdd( aObj1Coords , { 080 , 000 , .T. , .T. } )
	aAdd( aObj1Coords , { 002 , 000 , .F. , .T. } )
	aAdd( aObj1Coords , { 050 , 000 , .F. , .T. } )
	aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords, .T., .T. )

	aAdv2Size    := aClone(aObjSize[2])
	aInfo2AdvSize    := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 2 }
	aAdd( aObj2Coords , { 080 , 000 , .T. , .T. } )
	aAdd( aObj2Coords , { 002 , 000 , .F. , .T. } )
	aAdd( aObj2Coords , { 050 , 000 , .F. , .T. } )
	aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords, .T., .T. )

	aAdv3Size    := aClone(aObj1Size[1])
	aInfo3AdvSize    := { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 10 , 10 }
	aAdd( aObj3Coords , { 000 , 010 , .T. , .F. } )
	aAdd( aObj3Coords , { 000 , 000 , .T. , .T., .T. } )
	aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords)

	aAdv4Size    := aClone(aObj2Size[1])
	aInfo4AdvSize    := { aAdv4Size[2] , aAdv4Size[1] , aAdv4Size[4] , aAdv4Size[3] , 5 , 1 }
	aAdd( aObj4Coords , { 000 , 010 , .T. , .F. } )
	aAdd( aObj4Coords , { 000 , 010 , .T. , .F. } )
	aAdd( aObj4Coords , { 000 , 010 , .T. , .F. } )
	aAdd( aObj4Coords , { 000 , 010 , .T. , .F. } )
	aAdd( aObj4Coords , { 000 , 010 , .T. , .F. } )
	aObj4Size := MsObjSize( aInfo4AdvSize , aObj4Coords)

	DEFINE FONT oFont 	NAME "Arial Negrito" SIZE 0,-11
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0005) From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL//"Efetuar Teste"

		@ aObj1Size[1,1], aObj1Size[1,2] GROUP oGroup TO aObj1Size[1,3],aObj1Size[1,4] LABEL "" OF oDlg PIXEL
		oGroup:oFont:= oFont		
		@ aObj3Size[1,1], aObj3Size[1,2] 		SAY OemToAnsi(STR0006) 		SIZE 70,10 OF oDlg PIXEL FONT oFont  //"Candidato:"
		@ aObj3Size[1,1], aObj3Size[1,2]+50 	SAY cCurric+" - "+cNome 	SIZE 200,10 OF oDlg PIXEL FONT oFont 
		
		@ aObj3Size[2,1], aObj3Size[2,2] LISTBOX oLbx VAR cVar ;
								FIELDS HEADERS 	OemtoAnsi(STR0007),;                         //"Teste"
												OemtoAnsi(STR0008),;                         //"Qtde Questoes"
												OemtoAnsi(STR0009) SIZE aObj3Size[2,3] ,aObj3Size[2,4] OF oDlg PIXEL //"Duracao" 
		oLbx:SetArray(aListBox)
		oLbx:bLine := { || {aListBox[oLbx:nAt,1],aListBox[oLbx:nAt,2],aListBox[oLbx:nAt,3]}}
		
		@ aObj2Size[1,1],aObj2Size[1,2] GROUP oGroup1 TO aObj2Size[1,3],aObj2Size[1,4] LABEL OemtoAnsi(STR0010) OF oDlg PIXEL //" Recados "
		oGroup1:oFont:= oFont
		
		@ aObj4Size[2,1], aObj4Size[2,2] SAY OemtoAnsi(Alltrim(aMSG[1]))	SIZE 280,7 OF oDlg PIXEL
		@ aObj4Size[3,1], aObj4Size[3,2] SAY OemtoAnsi(Alltrim(aMSG[2]))	SIZE 280,7 OF oDlg PIXEL
		@ aObj4Size[4,1], aObj4Size[4,2] SAY OemtoAnsi(Alltrim(aMSG[3]))	SIZE 280,7 OF oDlg PIXEL
		@ aObj4Size[5,1], aObj4Size[5,2] SAY OemtoAnsi(Alltrim(aMSG[4]))	SIZE 280,7 OF oDlg PIXEL
		
		@ aObj1Size[3,1]+05,aObj1Size[3,2]	BUTTON oBTN1 PROMPT OemtoAnsi(STR0011); //"INICIAR TESTE"
					SIZE 60,15 OF oDlg PIXEL ACTION (RspxCapa(),oDlg:End());
					FONT oFont 
					
		@ aObj1Size[3,1]+30,aObj1Size[3,2]	BUTTON oBTN2 PROMPT OemtoAnsi(STR0012); //"CANCELAR TESTE"
					SIZE 60,15 OF oDlg PIXEL ACTION oDlg:End();
					FONT oFont
					
	ACTIVATE MSDIALOG oDlg

	RspDelTRB()

	DeleteObject(oOk)
	DeleteObject(oNo)
ELSEif !EMPTY(SQD->QD_CURRIC)
	MsgAlert(OEMTOANSI( STR0015 ), OEMTOANSI( STR0016 ))
ELSEIF EMPTY(SQD->QD_CURRIC)
	Help("",1,"A130VAZIO")	
ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Inicializa o filtro utilizando a funcao FilBrowse                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bFiltraBrw)

dbSelectArea("SQD")
dbGoTo(nSavRec)
dbSetOrder(nOrder)
 
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡„o    ?A130Leg       ?Autor ³Emerson Grassi    ?Data ?21.03.01 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡„o ?Aciona Legenda de cores da Mbrowse.				          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?A130Leg()		                                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Uso       ?RSPA130                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Function a130Leg()

TrmLegenda(6,,, aLegenda)

Return(Nil)
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡„o    ?Rsp130Perg    ?Autor ³Emerson Grassi    ?Data ?21/05/04 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡„o ?Aciona Perguntas para filtro do Browse.			          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?Rsp130SX1		                                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Uso       ?RSPA130                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/                                    
Function Rsp130Perg()

Pergunte("RSP130",.T.)

cFiltraSQD 	:= 	"!Empty(SQD->QD_TESTE)"+;
				" .And. SQD->QD_CURRIC >= '"+mv_par01+"' .And. SQD->QD_CURRIC <= '"+mv_par02+"'"+;
				" .And. Dtos(SQD->QD_DATA) >= '"+Dtos(mv_par03)+"' .And. Dtos(SQD->QD_DATA) <= '"+Dtos(mv_par04)+"'"+;
				" .And. SQD->QD_OK $ '"+Iif( mv_par05 == 1, " N", Iif( mv_par05 == 2, "S", " SN" ) )+"'"
				
oBrwSQD:SetFilterDefault(cFiltraSQD)				

Return Nil

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ?
³Fun‡„o    ?BrwSQDLeg		³Autor? Mauricio MR     ?Data ?5/09/2014 ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ?
³Descri‡„o ³Adiciona Legenda ao Browse da Aplicacao de Testes		    ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
³Sintaxe   ? Vide Parametros Formais >									?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
?Uso      ³RSPA130                                                     ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
?Retorno  ³aRotina														?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
³Parametros? Vide Parametros Formais >									?
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?*/   
Static Function BrwSQDLeg(oObjBrw, aCores) 
Local nLenCor	:=	0
Local nElem		:=	0

nLenCor:=Len(aCores)

For nElem:=1 To nLenCor 			
	oObjBrw:AddLegend( aCores[nElem,1],aCores[nElem,2],"")	
Next nElem

Return(Nil)

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ?
³Fun‡„o    ?MenuDef		³Autor? Luiz Gustavo     ?Data ?7/12/2006?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ?
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ?
?         ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
³Sintaxe   ? Vide Parametros Formais >									?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
?Uso      ³RSPA130                                                     ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
?Retorno  ³aRotina														?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
³Parametros? Vide Parametros Formais >									?
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?*/   

Static Function MenuDef()

 Local aRotina :=  	  { 	{ STR0002,"PesqBrw"		,0,1,,.F.},; //"Pesquisar" c/ Filtro
							{ STR0003,"A130Aciona"	,0,3},; //"Acionar"   
							{ STR0014,"Rsp130Perg"	,0,3},; //"Parametros"  							
						   	{ STR0013,"A130Leg"		,0,2,,.F.}}	 //"Legenda"

Return aRotina
