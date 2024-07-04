#INCLUDE "TOTVS.CH"
#INCLUDE "QIPM020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'Fileio.CH'
#DEFINE NORMAL   "1"
#DEFINE ATRIBUTO "2"       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIPM020	³ Autor ³ Marcelo Pimentel      ³ Data ³ 14/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de geracao das Cartas de Controle				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaQIP													  ³±±
±±³			 ³ Obs.: Se nao especificar a revisao do produto, considera a ³±±
±±³			 ³ revisao vigente na data producao   limite (ate), para exi- ³±±
±±³			 ³ bir os ensaios para escolha e para identificar os Limites  ³±±
±±³			 ³ Engenharia. Neste caso (revisao em branco) serao conside-  ³±±
±±³			 ³ radas as medicoes de todas as revisoes que existirem no	  ³±±
±±³			 ³ periodo, mesmo que haja diferenca de especificacao do en-  ³±±
±±³			 ³ saio, de uma revisao para outra. 						  ³±±
±±³			 ³ Obs.: por enquanto, somente estao disponiveis os graficos  ³±±
±±³			 ³ 		das cartas IND, XBR e XBS. 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³													          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio  ³25/07/00³------³ Retirada da Funcao HotAreas            ³±±
±±³Paulo Emidio  ³26/07/00³Melhor³Retirada das chamadas das Funcoes       ³±±
±±³              ³        ³      ³Diskname e DirChange. 				  ³±±
±±³Paulo Emidio  ³03/10/00³------³Passagem dos valores: Nominal, LIE e LSE³±±
±±³              ³        ³      ³para a montagem do grafico.             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QIPM020
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 									         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAlias := Alias()
Local cRevi
Local cTit  := OemToAnsi(STR0001) // "Cartas de Controle"
Local lCont := .t.

PRIVATE cIndex1
PRIVATE nIndex,nOpt1 := 1
PRIVATE cMarca := GetMark()
Private cLIE := Space(TamSX3("QE7_LIE")[1])
Private cLSE := Space(TamSX3("QE7_LSE")[1])   
Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto    := .F.
Private lFase3      := IIF(QP6->(FieldPos("QP6_SITREV"))<>0,.T.,.F.)
Private lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecao da geracao das Cartas de Controle:				     ³
//³ mv_par01: Produto			   ?							 ³
//³ mv_par02: Revisao			   ?							 ³
//³ mv_par03: Data de Producao De  ?							 ³
//³ mv_par04: Data de Producao Ate'?                             ³
//³ mv_par05: Ensaiador De 		   ?			     			 ³
//³ mv_par06: Ensaiador Ate'       ?                    		 ³
//³ mv_par07: Operacao 	De 		   ?			     			 ³
//³ mv_par08: Operacao Ate'        ?                			 ³
//³ mv_par09: Laboratorio De 	   ?			     			 ³
//³ mv_par10: Laboratorio Ate'     ?                			 ³
//³ mv_par11: Roteiro De     	   ?			     			 ³
//³ mv_par12: Roteiro Ate'	       ?                			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    

If Pergunte("QPM020",.T.)
	// Se nao definiu os parametros Ate', assume "ZZZZ"
	mv_par06 := Iif(Empty(mv_par06),Replicate("Z",TamSx3("QPR_ENSR")[1]),mv_par06)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o Produto / Revisao													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mv_par01 := Upper(mv_par01)
	If Empty(mv_par02)	// Nao especificou a revisao
		If !QP6->(dbSeek(xFilial("QP6")+mv_par01))
			Help(" ",1,"QIEPRODNAO")   // "Produto nao cadastrado."
			lCont := .F.
		EndIf
	Else
		If !QP6->(dbSeek(xFilial("QP6")+mv_par01+Inverte(mv_par02)))
			Help(" ",1,"QIEPRRVNAO")   // "Produto/Revisao nao cadastrados."
			lCont := .F.
		EndIf
	EndIf
	If lCont
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Identifica a revisao a ser adotada 										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Se nao especificou a revisao, assume a revisao vigente na data final
		If !Empty(mv_par02)
			cRevi := mv_par02
		Else
			cRevi := QA_UltRevEsp(mv_par01,mv_par04,,,"QIP")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada da Funcao para montar o Browse para escolha dos ensaios  ³
		//³ e chamada da funcao para gerar os arquivos	                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M020MontBrw(cRevi,cTit)
	EndIf
Endif 
dbSelectArea(cAlias)
Return NIL
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M020MontBrw³ Autor ³ Marcelo Pimentel    ³ Data ³ 14/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta browse para a escolha dos ensaios - MarkBrowse		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ M020MontBrw(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Revisao											  ³±±
±±³			 ³ ExpC2 = Titulo da Janela									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIPM020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M020MontBrw(cRevi,cTit)

Local oTempTable	:= NIL
Local aStru 		:= {}
Local nOpcA 		:= 0
Local cArqTrab
Local aCpos 		:= {}
Local cDir			:= ""
Local oMark
Local oDlg
Local nCount		:= 1
Local aEnsaios	:= {}
Local nPos			:= 0
Local aButtons	:= {}
Local oLIE
Local oLSE

Private lInverte	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho para a escolha dos ensaios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TB_OK"      ,	"C",02,0})
Aadd( aStru,{ "TB_ENSAIO"  ,	"C",12,0})
Aadd( aStru,{ "TB_DESCRI"  ,	"C",TamSX3("QP1_DESCPO")[1],0})
Aadd( aStru,{ "TB_CARTA"	,	"C",TamSX3("QP1_CARTA")[1],0})
Aadd( aStru,{ "TB_SELECAO"	,	"C",TamSX3("QP1_CARTA")[1],0})
Aadd( aStru,{ "TB_TAMAMO"	,  	"N",TamSX3("QP1_QTDE")[1],0})
Aadd( aStru,{ "TB_LABOR"  	,	"C",TamSX3("QP7_LABOR")[1],0})
Aadd( aStru,{ "TB_OPERAC"  ,  	"C",TamSX3("QP7_OPERAC")[1],0})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_ENSAIO"} )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefinicao do aCpos para utilizar no MarkBrow ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpos := {	{"TB_OK"		,"","  "},;
			{"TB_ENSAIO"	,"",OemToAnsi(STR0003)},;	// "Ensaio"
			{"TB_DESCRI"	,"",OemToAnsi(STR0004)},;	// "Descricao"
			{"TB_CARTA"		,"",AllTrim(TitSX3("QP1_CARTA")[1])},;
			{"TB_SELECAO"	,"",STR0014},; //"Selecao"
			{"TB_TAMAMO"	,"",STR0015},; //"Tamanho Amostra"
			{"TB_LABOR"		,"",AllTrim(TitSX3("QP7_LABOR")[1])},;
			{"TB_OPERAC"	,"",AllTrim(TitSX3("QP7_OPERAC")[1])}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta arquivo temporario com os ensaios dos Produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QP7->(dbSetOrder(1))
QP7->(dbSeek(xFilial("QP7")+mv_par01+cRevi))
While !QP7->(Eof()) .And. QP7->QP7_FILIAL == xFilial("QP7")	.And. ;
	QP7->QP7_PRODUT == mv_par01 .And. QP7->QP7_REVI == cRevi
                                            
	//Filtra as Operacoes selecionadas
	If QP7->QP7_CODREC < mv_par11 .Or. QP7->QP7_CODREC > mv_par12
		QP7->(dbSkip())
		Loop
	EndIf

	//Filtra as Operacoes selecionadas
	If QP7->QP7_OPERAC < mv_par07 .Or. QP7->QP7_OPERAC > mv_par08
		QP7->(dbSkip())
		Loop
	EndIf
	
	//Filtra os Laboratorios selecionados	
	If QP7->QP7_LABOR < mv_par09 .Or. QP7->QP7_LABOR > mv_par10
		QP7->(dbSkip())
		Loop
	EndIf    
	
	// Verifica a Carta do Ensaio
	QP1->(dbSeek(xFilial("QP1")+QP7->QP7_ENSAIO))
	If QP1->QP1_CARTA $ "IND.XBR.XBS.HIS"
		If QPCarta(QP1->QP1_ENSAIO) <> "TMP"	
			RecLock("TRB",.T.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Vetor para efetuar a contagem dos ensaios sequencialmente        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos := Ascan(aEnsaios,{|x| x[1] == QP7->QP7_ENSAIO })
			If nPos <> 0
				aEnsaios[nPos,2]++
				nCount := aEnsaios[nPos,2]
			Else
				Aadd(aEnsaios,{QP7->QP7_ENSAIO,1})
			EndIf
			
			//TRB->TB_ENSAIO := QP7->QP7_ENSAIO+"["+StrZero(nCount,2)+"]"
			TRB->TB_ENSAIO := QP7->QP7_ENSAIO+"["+QP7->QP7_OPERAC+"]"
			TRB->TB_DESCRI	:= QIPXDeEn(QP7->QP7_ENSAIO)
			TRB->TB_CARTA	:= QP1->QP1_CARTA
			TRB->TB_LABOR	:= QP7->QP7_LABOR
			TRB->TB_OPERAC	:= QP7->QP7_OPERAC
			TRB->TB_TAMAMO	:= QP1->QP1_QTDE
			MsUnlock()
		EndIf
	EndIf
	QP7->(dbSkip())
EndDo

dbSelectArea("TRB")
dbGoTop()
If BOF() .and. EOF()
	HELP(" ",1,"RECNO")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem o diretorio para a criacao dos arquivos SPC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDir := GetMv("MV_QDIRGRA") 
	While .T.
		DEFINE MSDIALOG oDlg TITLE cTit  FROM 0,0 TO 350,740 TITLE STR0020 Of oMainWnd PIXEL //-- Cartas de Controle
		
		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:AddObject( "CABECALHO",  100, 70, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "GETDADOS" ,  100, 30, .T., .T. ) // Totalmente dimensionavel 

		oSize:lProp 	:= .T. // Proporcional             
		oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
		
		oSize:Process() 	   // Dispara os calculos
		
		oMark := MsSelect():New("TRB","TB_OK",,acpos,lInverte,cMarca,{oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI"),;
					  														   oSize:GetDimension("CABECALHO","LINEND"),oSize:GetDimension("CABECALHO","COLEND")},,oDlg)
		oMark:oBrowse:lCanAllMark:=.T.
		oMark:oBrowse:lHasMark	 :=.T.
		oMark:bMark 			:= {| | M020Escol(cMarca,lInverte,oDlg)}
		oMark:oBrowse:bAllMark	:= {| | M020MarkAll(cMarca,oDlg)}
		Aadd(aButtons,{"BMPPARAM",{||QPBuildGraf(Substr(TRB->TB_ENSAIO,1,8),TRB->TB_CARTA)},STR0016,STR0024}) //"Escolha da Carta de Controle..."###"Esc.Cart"
		
		@ oSize:GetDimension("GETDADOS","LININI") ,oSize:GetDimension("GETDADOS","COLINI") TO oSize:GetDimension("GETDADOS","LINEND")-3 ,oSize:GetDimension("GETDADOS","COLEND")-3 LABEL OemToAnsi("") Of oDlg Pixel 
   
		@ oSize:GetDimension("GETDADOS","LININI")+10 ,oSize:GetDimension("GETDADOS","COLINI")+5 Say OemToAnsi(STR0022) Size  50,6 Of oDlg Pixel //"Valor Limite LSI :"
		@ oSize:GetDimension("GETDADOS","LININI")+20 ,oSize:GetDimension("GETDADOS","COLINI")+5 Say OemToAnsi(STR0023) Size  50,6 Of oDlg Pixel //"Valor Limite LSE :"
		
		@ oSize:GetDimension("GETDADOS","LININI")+10 ,oSize:GetDimension("GETDADOS","COLINI")+45 MSGET	oLIE VAR cLIE VALID If(!QA_VerNum(@cLIE),(HELP(" ",1,"QA_NUMINV"),.F.),.T.) OF oDlg PIXEL SIZE 53.5,7
		oLIE:cSX1Hlp := "QE7_LIE"
		@ oSize:GetDimension("GETDADOS","LININI")+20 ,oSize:GetDimension("GETDADOS","COLINI")+45 MSGET	oLSE VAR cLSE VALID If(!QA_VerNum(@cLSE),(HELP(" ",1,"QA_NUMINV"),.F.),.T.) OF oDlg	PIXEL SIZE 53.5,7
		oLSE:cSX1Hlp := "QE7_LSE"
		
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpcA:=0,oDlg:End()},,aButtons)
		If nOpcA == 1			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o diretorio do grafico e um  diretorio Local     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !QA_VerQDir(cDir) 
				Return
			EndIf  
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Rotina que gera os graficos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M020GerCC(cRevi,cDir)
		Endif
		Exit
	EndDo
EndIf

oTempTable:Delete() //-- Deleta Arquivo Temporario

Return Nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M020Marca  ³ Autor ³ Marcelo Pimentel    ³ Data ³ 14/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Avalia Marca.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIPM020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M020Marca()

If LastKey() == K_ENTER
	RecLock("TRB",.F.)
	TRB->TB_OK := Iif(Empty(TRB->TB_OK),cMarca," ")
	MsUnlock()
ElseIf LastKey() == K_ALT_M				// Marca todos
	dbSelectArea("TRB")
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := cMarca
		MsUnlock()
		dbSkip()
	EndDo
	dbSelectArea("TRB")
	dbGotop()
ElseIf LastKey() == K_ALT_R				// Remove todas as marcas
	dbSelectArea("TRB")
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := " "
		MsUnlock()
		dbSkip()
	EndDo
	dbSelectArea("TRB")
	dbGotop()
EndIf
Return Nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M020Escol  ³ Autor ³ Marcelo Pimentel    ³ Data ³ 14/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe os Ensaios										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIPM020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M020Escol(cMarca,lInverte,oDlg)
iF IsMark("TB_OK",cMarca,lInverte)
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
Else
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= "  "
	Else
		TRB->TB_OK	:= cMarca
	Endif
	MsUnlock()
Endif
oDlg:Refresh()
Return .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M020MarkAll³ Autor ³Marcelo Pimentel     ³ Data ³ 14/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inverte os Ensaios Marcados/Desmarcados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIPM020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M020MarkAll(cMarca,oDlg)
LOCAL nRecno:=Recno()
dbGotop()
Do While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³M020GerCC ³ Autor ³ Marcelo Pimentel      ³ Data ³ 14/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera arquivo (SPC) para gerar o grafico					  ³±±
±±³			 ³ Gera 1 arquivo para cada ensaio selecionado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ M020GerCC(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Revisao do Produto								  ³±±
±±³			 ³ ExpC2: Diretorio para a geracao dos arquivos SPC			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPM020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M020GerCC(cRevi,cDir)
//Local oTempTable	:= NIL
Local aEnsaios   := {}
Local aFxOP      := {}
Local aLimites   := {}
Local aMed       := {}
Local aMed64     := {}
Local aMedAux    := {}
Local aMedPerEns := {}
Local aMedEnsaio := {}
Local aMedicoes  := {}
Local aOrdProd   := {}
Local aRecTMP    := {}
Local aStru      := {}
Local aTabela    := {}
Local aTitCarCon := {}
Local cAlias     := Alias()
Local cArqSPC    := ''
Local cCarta     := ""
Local cCartaOri  := ""
Local cChvMed    := ''
Local cChvQPR    := ''
Local cCpo       := ''
Local cEnsaio    := ''
Local cMedi      := ''
Local cModelo    := ''
Local cOperac    := ''
Local cReviQPK   := ''
Local cRoteiro   := ''
Local cSenhas    := "1"
Local cTpCarEns  := ""
Local cTpCarEsc  := ""
Local lGera      := .F.
Local lMVQCALLIM := GetMV("MV_QCALLIM")
Local lQIPM020F  := ExistBlock("QIPM020F")
Local lQIPM020OP := ExistBlock("QIPM020OP")
Local lQIPM020T  := ExistBlock("QIPM020T")
Local lValida    := .F.
Local lXbXbr     := .F.
Local nAmostra   := 0
Local nCnt       := 0
Local nCountGrp  := 0
Local nDec       := 0
Local nI         := 0
Local nLoop      := 0
Local nPos       := 0
Local nQtde      := 0
Local nTamAmo    := 0
Local nY         := 0
Local oDlg       := NIL
Local oLbx       := NIL

Private aGrafAtivo :={}
Private oTempTable := NIL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho para guardar as meds. dos ensaios   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TMP_ENSAIO"  ,  "C",12,0} )
Aadd( aStru,{ "TMP_OPERAC"	,  "C",2,0} )
Aadd( aStru,{ "TMP_LABOR"	,  "C",6,0} )
Aadd( aStru,{ "TMP_DTMEDI"  ,  "D",8,0} )
Aadd( aStru,{ "TMP_HRMEDI"  ,  "C",TamSX3("QPR_HRMEDI")[1],0} )
Aadd( aStru,{ "TMP_MEDI01"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI02"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI03"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI04"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI05"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI06"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI07"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI08"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI09"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI10"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_VERIFI"  ,  "C",1,0} )	//Verificador 
Aadd( aStru,{ "TMP_CARTA"	,  "C",3,0} )
Aadd( aStru,{ "TMP_CARTOR"	,  "C",3,0} )
Aadd( aStru,{ "TMP_TAMAMO"	,  "N",2,0} )

If Select("TMP") <> 0
	DbSelectArea("TMP")
	DbCloseArea()
Endif

oTempTable := FWTemporaryTable():New( "TMP" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TMP_ENSAIO","TMP_DTMEDI","TMP_HRMEDI"} )
oTempTable:Create()

dbSelectArea("TRB")
dbGoTop()
While !Eof()
	If !Empty(TB_OK)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ [1] - Ensaio                            ³
		//³ [2] - Tem Medicoes                      ³
		//³ [3] - Nome do Arquivo                   ³
		//³ [4] - Modelo                            ³
		//³ [5] - Laboratorio                       ³
		//³ [6] - Operacao                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aEnsaios,{ TB_ENSAIO,.F.,cArqSpc,"",TB_LABOR,TB_OPERAC,TB_CARTA,TB_SELECAO,TB_TAMAMO})
		Aadd(aMed,{})
	EndIf
	dbSkip()
EndDo

//Seleciona as entregas com medicoes no periodo
QPK->(dbSetOrder(2))
QPK->(dbSeek(xFilial("QPK")+mv_par01, .T.))
cReviQPK := Iif(Empty(QPK->QPK_REVI),QA_UltRevEsp(QPK->QPK_PRODUT,,,,"QIP"),QPK->QPK_REVI)

If ExistBlock("QIPM020OP")
	aFxOP := ExecBlock("QIPM020OP")
EndIf 

While !QPK->(Eof()) .And. QPK->QPK_FILIAL == xFilial("QPK") .And. QPK->QPK_PRODUT == mv_par01

	If	QPK->QPK_DTPROD < mv_par03 .Or. QPK->QPK_DTPROD > mv_par04        
		QPK->(dbSkip())
		Loop
	EndIf
	
	If lQIPM020OP .And. ValType(aFxOP) == 'A'
   		If QPK->QPK_OP < aFxOP[1] .Or. QPK->QPK_OP > aFxOP[2]
   			QPK->(dbSkip())
   			Loop	
        Endif                	
	EndIf
	
                                                                                   
	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+QPK->QPK_OP)) 
	cRoteiro := SC2->C2_ROTEIRO
	cReviQPK := Iif(Empty(QPK->QPK_REVI),QA_UltRevEsp(QPK->QPK_PRODUT,,,,"QIP"),QPK->QPK_REVI)
	
	// Verifica a revisao do Produto
	If !Empty(mv_par02) .And. cReviQPK <> mv_par02
		QPK->(dbSkip())
		Loop
	EndIf

	//Seleciona as medicoes da entrega
	cChvQPR	:= (xFilial("QPR")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER)
	QPR->(dbSetOrder(9))
	QPR->(dbSeek(cChvQPR))
	While !QPR->(Eof()) .And. QPR->QPR_FILIAL == xFilial("QPR") .And.;
		QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER ==;
		QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER 

		aMedTmp := {}

		// Verifica o Ensaiador
		If (!Empty(mv_par05) .And. QPR->QPR_ENSR < mv_par05) .Or. ;
			(!Empty(mv_par06) .And. QPR->QPR_ENSR > mv_par06)
 			QPR->(dbSkip())
			Loop
		EndIf
		
		// Verifica o Roteiro
		If (!Empty(mv_par07) .And. QPR->QPR_OPERAC < mv_par07) .Or. ;
			(!Empty(mv_par08) .And. QPR->QPR_OPERAC > mv_par08)
 			QPR->(dbSkip())
			Loop
		EndIf

		//Array utilizado na impressao do grafico
		If Ascan(aOrdProd, { |x| x[1] == QPK->QPK_OP}) == 0
			Aadd(aOrdProd,{QPK->QPK_OP,QPK->QPK_EMISSA,QPR->QPR_LOTE,QPK->QPK_TAMLOT})
		EndIf

		// Guarda as medicoes de acordo com o ensaio, se ele foi escolhido
		nPos := Ascan(aEnsaios, { |x| Substr(x[1],1,8) == QPR->QPR_ENSAIO})
		If nPos <> 0
			// Posiciona no arquivo de ensaios para saber a carta
			QP1->(dbSetOrder(1))
			QP1->(dbSeek(xFilial("QP1")+QPR->QPR_ENSAIO))

			// Obtem a chave de ligacao da medicao com os outros arquivos
			cChvMed := QPR->QPR_CHAVE
			cCartaOri	:= aEnsaios[nPos,7]
			cCarta		:= Iif(Empty(aEnsaios[nPos,8]),aEnsaios[nPos,7],aEnsaios[nPos,8])

			// Grava no arquivo auxiliar de medicoes
			RecLock("TMP", .T.)
			TMP->TMP_ENSAIO	:= QPR->QPR_ENSAIO
			TMP->TMP_OPERAC	:= QPR->QPR_OPERAC
			TMP->TMP_LABOR	:= QPR->QPR_LABOR
			TMP->TMP_DTMEDI	:= QPR->QPR_DTMEDI
			TMP->TMP_HRMEDI	:= QPR->QPR_HRMEDI
			TMP->TMP_CARTA	:= cCarta
			TMP->TMP_CARTOR	:= cCartaOri
			TMP->TMP_TAMAMO	:= aEnsaios[nPos,9]

			nPos := 0
			nPos := ASCAN(aRecTMP, {|x| x[1]+x[2] == TMP->TMP_ENSAIO+TMP->TMP_OPERAC})
			If nPos == 0
				AADD( aRecTMP, {TMP->TMP_ENSAIO,;	
								TMP->TMP_OPERAC,;
								TMP->TMP_LABOR,;	
								TMP->TMP_DTMEDI,;	
								TMP->TMP_HRMEDI,;
								TMP->TMP_CARTA,;	
								TMP->TMP_CARTOR,;	
								TMP->TMP_TAMAMO, {} } )
			EndIf
			// Grava as medicoes
			nI := 1
			// Para cartas C e NP grava o Tamanho da Amostra antes de cada medicao
			If QP1->QP1_CARTA $ "C  .NP "
				TMP->TMP_MEDI01 := StrZero(QP1->QP1_QTDE,8)
				AADD(aMedTmp, TMP->TMP_MEDI01)
				nI++
			EndIf

			QPS->(dbSetOrder(1))
			QPS->(dbSeek(xFilial("QPS")+cChvMed))
			While QPS->QPS_FILIAL+QPS->QPS_CODMED == xFilial("QPS")+cChvMed .And. !QPS->(Eof())
				cCpo := "TMP_MEDI"+StrZero(nI,2)
				// Troca "," por "." pq. o WINCEP nao reconhece "," como decimal
				TMP->&(cCpo) := QPS->QPS_MEDICA

				AADD( aMedTmp, TMP->&(cCpo) )

				QPS->(dbSkip())
				nI++
			EndDo

			nPos := 0
			nPos := ASCAN(aRecTMP, {|x| x[1]+x[2] == TMP->TMP_ENSAIO+TMP->TMP_OPERAC})
			If nPos <> 0
				AADD( aRecTMP[nPos, 9], aMedTmp )
			EndIf

		EndIf
		QPR->(dbSkip())
	EndDo
	QPK->(dbSkip())
EndDo
QPK->(dbSetOrder(1))

nCnt:= 0
// Gera os arquivos de grafico 
TMP->(dbGoTop())
While !TMP->(Eof())
	If 	TMP->TMP_VERIFI	==	"1"
		TMP->(dbSkip())
		Loop
	EndIf
	
	cEnsaio   := Substr(TMP->TMP_ENSAIO,1,8)
	cOperac	  := TMP->TMP_OPERAC
	cLabor	  := TMP->TMP_LABOR
	cCarta	  := TMP->TMP_CARTA
	cCartaOri := TMP->TMP_CARTOR
   
    //Posiciona a medição no ensaio correto.
	nCnt := Ascan(aEnsaios,{|x| Substr(x[1],1,8) == cEnsaio .And. x[6] == cOperac }) 

	if nCnt == 0
		TMP->(dbSkip())
		Loop
	EndIf

	If Ascan(aMed64,{|x| Substr(x[1],1,8)+Substr(x[1],10,2)+x[3] == cEnsaio + cOperac + cLabor }) == 0
		Aadd(aMed64,{ aEnsaios[nCnt][1], {}, aEnsaios[nCnt][5]})
	Else
		TMP->(dbSkip())
		Loop 
	EndIf
	
	QP1->(dbSetOrder(1))
	QP1->(dbSeek(xFilial("QP1")+cEnsaio))

	// Define o modelo do grafico e a qtde de medicoes
	// Modelo 5: IND (IndMovRng), 6: XBR (XbarRange), 7:XBS (XbarStd)
	nQtde := QP1->QP1_QTDE	// Tamanho da Amostra

	Do Case
		Case TMP->TMP_CARTA == 'XBR'
				cModelo := "6"
		Case TMP->TMP_CARTA == 'XBS'
				cModelo := "7"
		Case TMP->TMP_CARTA == 'IND' .OR. TMP->TMP_CARTA == 'HIS'
				cModelo := "5"
			If cCarta == cCartaOri .and. TMP->TMP_CARTA == 'IND'
				nQtde := 1
			EndIf
	EndCase
	nQtdeOri	:= nQtde
	nTamAmo	    := TMP->TMP_TAMAMO

	// Identifica o no. de casas decimais
	QP7->(dbSetOrder(1))
	QP7->(dbSeek(xFilial("QP7")+mv_par01+cRevi+cRoteiro+cOperac+cEnsaio))
	nDec := QA_NumDec(QP7->QP7_NOMINA)

	// Monta vetor com os valores das medicoes e checa as menores/maiores datas
	aMedicoes := {}
	Aadd(aMedicoes,"QACHART.DLL - NORMAL")
                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica se os Limites serao recalculados na Carta de Controle					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cLSE) .And. Empty(cLIE) .And. !lMVQCALLIM // Verifica o parametro somente quando os limites manuais nao forem informados
		Aadd(aMedicoes,"[CALCULA LIMITE]")
		Aadd(aMedicoes,"FALSE")	
	Endif    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o LSE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aMedicoes,"[USL]")
	If Empty(cLSE)
		Aadd(aMedicoes,StrTran(Str(SuperVal(If(!Empty(QP7->QP7_LSC),QP7->QP7_LSC,QP7->QP7_LSE)),8,nDec),".",","))    
	Else
		Aadd(aMedicoes,StrTran(Str(SuperVal(cLSE),8,nDec),".",","))
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o LIE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aMedicoes,"[LSL]")
	If Empty(cLIE)
		Aadd(aMedicoes,StrTran(Str(SuperVal(If(!Empty(QP7->QP7_LIC),QP7->QP7_LIC,QP7->QP7_LIE)),8,nDec),".",","))
	Else
		Aadd(aMedicoes,StrTran(Str(SuperVal(cLIE),8,nDec),".",","))
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o Nominal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aMedicoes,"[TARGET]")
	Aadd(aMedicoes,StrTran(Str(SuperVal(QP7->QP7_NOMINA),8,nDec),".",","))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto Entrada para impressao do titulo no grafico.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQIPM020T
		Aadd(aMedicoes,"[TITLE]")
		Aadd(aMedicoes,ExecBlock("QIPM020T",.F.,.F.))
	Else
		aAdd( aMedicoes,"[TITLE]" )
		aAdd( aMedicoes," - " + AllTrim(QP7->QP7_PRODUT) + " / " + QP7->QP7_REVI)
	EndIf  

	Aadd(aMedicoes,"[LANGUAGE]")
	Aadd(aMedicoes,Upper(__Language) )
	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto Entrada para impressao do rodape no grafico.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQIPM020F
		Aadd(aMedicoes,"[FOOT]")
		Aadd(aMedicoes,ExecBlock("QIPM020F",.F.,.F.))
	Else
		aAdd( aMedicoes,"[FOOT]" )
		aAdd( aMedicoes,OemToansi(STR0003) + ": " + AllTrim(QP1->QP1_ENSAIO) + " - " + QP1->QP1_DESCPO) // "Ensaio"
	EndIf

	Aadd(aMedicoes,"[INICIO DE DADOS]")
	nRecno := TMP->(Recno())
	nAmostra:= 0
	
	nPos := 0
	nPos := ASCAN(aRecTMP, {|x| ALLTRIM(x[1])+ALLTRIM(x[2])+ALLTRIM(x[3]) == ALLTRIM(cEnsaio)+ALLTRIM(cOperac)+ALLTRIM(cLabor)})
	If nPos <> 0
		For nY := 1 To Len(aRecTMP[nPos, 9])

			If aRecTMP[nPos, 6] <> aRecTMP[nPos, 7] 
				If aRecTMP[nPos, 7]  == "IND"
					nQtde := 1
					nCountGrp:= 0
				EndIf
			EndIf

			cMedi := StrZero(Day(aRecTMP[nPos,4]),2)+"/"+;
						StrZero(Month(aRecTMP[nPos,4]),2)+"/"+Str(Year(aRecTMP[nPos,4]),4)+;
						Substr(aRecTMP[nPos,5],1,3)+StrZero(nCountGrp,2)

			Aadd(aMed[nCnt],{})
			nAmostra++
			For nLoop := 1 to nQtde
				cCpo := "TMP_MEDI"+StrZero(nLoop,2)
				cMedicao := cMedi+StrTran(AllTrim(aRecTMP[nPos,9,nY,nLoop]),".",",")
				Aadd(aMedicoes,cMedicao)
				Aadd(aMed[nCnt,nAmostra],StrTran(AllTrim(aRecTMP[nPos,9,nY,nLoop]),".",","))
				Aadd(aMed64[LEN(aMed64)][2],StrTran(AllTrim(aRecTMP[nPos,9,nY,nLoop]),".",","))
				Aadd(aMedAux,StrTran(AllTrim(aRecTMP[nPos,9,nY,nLoop]),".",","))
				Aadd(aMedPerEns,StrTran(AllTrim(aRecTMP[nPos,9,nY,nLoop]),".",","))
			Next

		Next nY

		Aadd(aMedEnsaio, aMedPerEns)
		aMedPerEns := {}

		ADel( aRecTMP, nPos )
		ASize( aRecTMP, len(aRecTMP)-1 )

	EndIf
	TMP->(dbGoto(nRecno))
	
	If nAmostra <= 3 .And. Len(aMed64[Len(aMed64)][2]) < 3
		MessageDlg(OemtoAnsi(STR0009),,3)	// "Nao há  ensaios com medições suficientes para gerar o gráfico."
		Return Nil
	Endif

	Aadd(aMedicoes,"[FIM DE DADOS]")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reavalia o Tamanho da Amostra caso seja alterada a carta.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCarta <> cCartaOri
		nQtde := Iif(nTamAmo>0,nTamAmo,1)
	EndIf
	
	If TMP->TMP_CARTOR == "IND"
		nQtde := Len(aMed[Len(aMed)])
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o tamanho do sub-grupo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aMedicoes,"[SUBGRUPO]")
	Aadd(aMedicoes,Str(nQtde,4))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o ensaio apresenta mais de 2 sub-grupos de medicoes,³
	//³ necessarios para a geracao dos graficos.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aMedicoes) > 5	// Header, Linha de Inicio e Fim de Dados

		nPos := Ascan(aEnsaios, { |x| 	Substr(x[1],1,8) == cEnsaio .And. ;
										x[5] == cLabor .And. x[6] == cOperac	 })
										
		If nPos <> 0
			// Atualiza aEnsaios indicando que tem medicoes suficientes p/ o grafico
			aEnsaios[nPos][2] := .T.
			
			// Identifica o modelo do grafico
			aEnsaios[nPos][4] := cModelo
		EndIf

		IF !lExistChart
			// Gera o nome do arquivo SPC
			cArqSPC := M020NoArq(cDir)

			If !Empty(cArqSPC)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o arquivo SPC ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lGera := GeraTxt32(aMedicoes ,cArqSPC, cDir)

				If !lGera
					Exit
				EndIf

				// Atualiza o nome do arquivo SPC gerado no array de ensaios
				If nPos <> 0
					aEnsaios[nPos][3] := cArqSpc
				EndIf
			EndIf
		Else
			lGera := .T.
		EndIF
	EndIf

	nPosTar := ASCAN( aMedicoes, "[TARGET]" ) + 1
	nPosLSL := ASCAN( aMedicoes, "[LSL]" ) + 1
	nPosUSL := ASCAN( aMedicoes, "[USL]" ) + 1
	aAdd(aLimites, { Pad(TMP->(TMP_ENSAIO), GetSX3Cache("QP7_ENSAIO","X3_TAMANHO")) + '[' + TMP->(TMP_OPERAC) + ']', SUPERVAL(aMedicoes[nPosTar]), SUPERVAL(aMedicoes[nPosLSL]), SUPERVAL(aMedicoes[nPosUSL])})

	TMP->(dbSkip())
EndDo
QP7->(dbSetOrder(1))

If lGera	
	
	If Len(aMed64) < Len(aEnsaios) 
		lValida := .T.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega array para o ListBox somente os que estao marcados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoop := 1 to Len(aEnsaios)
		If aEnsaios[nLoop][2]
			Aadd( aTabela, {aEnsaios[nLoop][1], aEnsaios[nLoop][3], aEnsaios[nLoop][4],aEnsaios[nLoop][5], mv_par01, cReviQPK, aOrdProd, aMed[nLoop] } )

			lXbXbr := .F.

			If nLoop == 1 .Or. lValida
				aMed64  := {}
				lValida := .F.
			EndIf

			If !Empty(aEnsaios[nLoop][8])

				cTpCarEsc := aEnsaios[nLoop][8]
				cTpCarEns := aEnsaios[nLoop][7]

				DO CASE
				CASE aEnsaios[nLoop][7] = "IND" 	
					If aEnsaios[nLoop][8] = "XBR"
						aTitCarCon := {"Media", "Amplitude"}
						lXbXbr := .T.
						AADD( aMed64, {aEnsaios[nLoop][1], aMed[nLoop], aMed[nLoop], aTitCarCon, lXbXbr} )
					Else
						aTitCarCon := {"Media", "Desvio Padrao"}
						lXbXbr := .T.
						AADD( aMed64, {aEnsaios[nLoop][1], aMed[nLoop], aMed[nLoop], aTitCarCon, lXbXbr} )
					Endif
				CASE aEnsaios[nLoop][7] = "XBR" .Or. aEnsaios[nLoop][7] = "XBS"  
					If aEnsaios[nLoop][8] = "IND"
						aTitCarCon := {"Valores Individuais", "Amplitude Movel"}
						AADD( aMed64, {aEnsaios[nLoop][1], aMedEnsaio[nLoop], aMed[nLoop], aTitCarCon, lXbXbr} )
					ElseIf aEnsaios[nLoop][8] = "XBR"
						aTitCarCon := {"Media", "Amplitude"}
						lXbXbr := .T.
						AADD( aMed64, {aEnsaios[nLoop][1], QIPA215Med(aMed[nLoop]), aMed[nLoop], aTitCarCon, lXbXbr} )
					Else
						aTitCarCon := {"Media", "Desvio Padrao"}
						lXbXbr := .T.
						AADD( aMed64, {aEnsaios[nLoop][1], QIPA215Med(aMed[nLoop]), aMed[nLoop], aTitCarCon, lXbXbr} )
					Endif
				OTHERWISE 
					IF aEnsaios[nLoop][7] == "HIS" .And. aEnsaios[nLoop][8] == "IND"
						aTitCarCon := {"Valores Individuais", "Amplitude Movel"}
						AADD( aMed64, {aEnsaios[nLoop][1], aMedEnsaio[nLoop], aMed[nLoop], aTitCarCon, lXbXbr} )
					Else
						aTitCarCon := {"Media", "Amplitude"}
						lXbXbr := .T.
						AADD( aMed64, {aEnsaios[nLoop][1], QIPA215Med(aMed[nLoop]), aMed[nLoop], aTitCarCon, lXbXbr} )
					Endif
				ENDCASE
			Else
				cTpCarEns := aEnsaios[nLoop][7]
				
				If aEnsaios[nLoop][7] = "XBS"
					aTitCarCon := {"Media", "Desvio Padrao"}
					lXbXbr := .T.
				ElseIf aEnsaios[nLoop][7] = "XBR"
					aTitCarCon := {"Media", "Amplitude"}
					lXbXbr := .T.
				Else
					aTitCarCon := {"Valores Individuais", "Amplitude Movel"}
				EndIf
			
				If aEnsaios[nLoop][7] == "HIS"
					AADD( aMed64, {aEnsaios[nLoop][1], aMedEnsaio[nLoop], aMed[nLoop], aTitCarCon, lXbXbr} )
				Else
					AADD( aMed64, {aEnsaios[nLoop][1], QIPA215Med(aMed[nLoop]), aMed[nLoop], aTitCarCon, lXbXbr} )
				Endif
			Endif
			AADD(aMed64[LEN(aMed64)], aEnsaios[nLoop,9])
			nPos := Ascan(aLimites,{|x| x[1] == aEnsaios[nLoop,1] })
			IF nPos > 0
				AADD(aMed64[LEN(aMed64)], {aLimites[nPos][2], aLimites[nPos][3], aLimites[nPos][4]})
			EndIf
		EndIf
	Next nLoop

	If Len(aTabela) > 0

		DEFINE MSDIALOG oDlg FROM	18,16 TO 246,561 TITLE OemToAnsi(STR0007) PIXEL // "Dados gerados"
		PtInternal(9,"FALSE")

		@ 0.3,0.3 LISTBOX oLbx FIELDS HEADER AllTrim(TitSX3("QP1_ENSAIO")[1]),OemToAnsi(STR0008);	// "Arquivo"
				SIZE 225,100 OF oDlg
		
		If lExistChart
			oLbx:blDblClick:= {|| QIEMGRAFIC(aMed64[oLbx:nAT, 2], 1, aMed64[oLbx:nAT, 3], aMed64[oLbx:nAT, 4], aMed64[oLbx:nAT, 7],,,aMed64[oLbx:nAT, 5],,cTpCarEns,cTpCarEsc, aMed64[oLbx:nAT, 6])}
		Else
			oLbx:blDblClick:= {|| Calldll32("ShowChart",aTabela[oLbx:nAt,2],aTabela[oLbx:nAt,3],cDir,NORMAL,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO")),A020StBtn(cDir,oBtn1,oBtn2)}
		EndIf

		oLbx:SetArray( aTabela )
		oLbx:bLine := { || {aTabela[oLbx:nAT,1],aTabela[oLbx:nAT,2]} }
		
		If lExistChart
			DEFINE SBUTTON FROM 005, 228 TYPE 1 ENABLE OF oDlg Action (QIEMGRAFIC(aMed64[oLbx:nAt, 2], 1, aMed64[oLbx:nAT, 3], aMed64[oLbx:nAT, 4], aMed64[oLbx:nAT, 7],,,aMed64[oLbx:nAT, 5],,cTpCarEns,cTpCarEsc, aMed64[oLbx:nAT, 6]))
		Else
			DEFINE SBUTTON FROM 005, 228 TYPE 1 ENABLE OF oDlg Action (Calldll32("ShowChart",aTabela[oLbx:nAt,2],aTabela[oLbx:nAt,3],cDir,NORMAL,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO")),A020StBtn(cDir,oBtn1,oBtn2))
		EndIf

		DEFINE SBUTTON FROM 18, 228 TYPE 2 ENABLE OF oDlg Action oDlg:End()
		
		If lExistChart
			@ 031,228 BUTTON oBtn3 PROMPT OemToAnsi(STR0028) OF oDlg PIXEL SIZE 45,13 ; //"Histograma"
			ACTION QIEMGRAFIC(aMed64[oLbx:nAt, 2], 3, aMed64[oLbx:nAt, 3],,aMed64[oLbx:nAT, 7],,,aMed64[oLbx:nAt, 5],,,,aMed64[oLbx:nAT, 6])

			@ 044,228 BUTTON oBtn1 PROMPT OemToAnsi(STR0020) OF oDlg PIXEL SIZE 45,13 ;//"Impr. Histograma"
			ACTION QM020Impr(1,aTabela[oLbx:nAt], {aMed64[oLbx:nAt, 2], 3, aMed64[oLbx:nAT, 3], ,aMed64[oLbx:nAT, 7],,,aMed64[oLbx:nAT, 5]}) // QIPR170

			oBtn1:lReadOnly := .F.
			oBtn3:lReadOnly := .F.
		Else
			@ 031,228 BUTTON oBtn1 PROMPT OemToAnsi(STR0020) OF oDlg PIXEL SIZE 45,13 ;
			ACTION QM020Impr(1,aTabela[oLbx:nAt]) //"Impr. Histograma" //QIPR170
			
			@ 044,228 BUTTON oBtn2 PROMPT OemToAnsi(STR0021) OF oDlg PIXEL SIZE 45,13 ;
			ACTION QM020Impr(2,aTabela[oLbx:nAt]) //"Impr. Carta Crtl" //QIPR170
		
			oBtn1:lReadOnly := .T.
			oBtn2:lReadOnly := .T.
		EndIf
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui os arquivos (SPC) gerados agora ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A020DelSpc( cDir, aTabela )
		PtInternal(9,"TRUE")
	Else
		MessageDlg(OemtoAnsi(STR0009),,3)	// "Nao há ensaios com medi‡äes suficientes para gerar o gr fico."
	Endif
EndIf

oTempTable:Delete() //-- Deleta o arquivo auxiliar

dbSelectArea(cAlias)
Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³M020NoArq ³ Autor ³ Marcelo Pimentel      ³ Data ³ 14/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera nome do arquivo SPC									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPM020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M020NoArq(cDir)
Local cArq	:= ""
Local nI 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o arquivo disponivel com extensao SPC ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to 99999
	cArq := "QIP" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI

Return cArq
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A020DelSpc³ Autor ³ Fernando Godoy		³ Data ³ 14/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Deleta os arquivos SPC gerados 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Diretorio dos SPC									  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 		    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A020DelSpc( cDir, aTabela )

Local lImpEst := GetMv("MV_QIMPEST",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta os arquivos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval(aTabela,{ |aFile| Ferase(cDir+aFile[2]) } )

fErase(cDir+"CARTA.BMP")
fErase(cDir+"HISTO.BMP")
If lImpEst
	fErase(cDir+"ESTAT.BMP")
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPBuildGraf ³ Autor ³Marcelo Pimentel       ³ Data ³ 13/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o acols NConformidade no vetor corretamente         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Cadastro de Resultados								        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPBuildGraf(cEnsaio,cCarta)
Local oDlg
Local oPanel
Local oRadio
Local nRadio
Local oTamAmo
Local cRadCarta	:= "INDXBRXBS"
Local nOpca		:= 0
Local nTamAmo	:= CriaVar("QP1_QTDE")

cRadCarta	:= StrTran(cRadCarta,cCarta,"")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o Tamanho da Amostra com 5      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamAmo := Iif(Substr(cRadCarta,1,3) == "IND",1,5)

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE STR0017 From 19,0 To 31.5,46 OF oMainWnd //"Selecao da Carta de Controle"

@ 21,02 SAY cEnsaio SIZE 40,7 OF oDlg PIXEL COLOR CLR_BLUE
@ 21,50 SAY cCarta  SIZE 20,7 OF oDlg PIXEL COLOR CLR_BLUE
oPanel	:= 	TPanel():New(35,2,,oDlg,,,,,,179,58,.F.,.F.)

@ 7,2 SAY STR0018 SIZE 150,7 OF oPanel PIXEL FONT oFont COLOR CLR_BLUE //'Selecione o tipo do grafico:'
@ 17,80 Radio oRadio VAR nRadio ITEMS Substr(cRadCarta,1,3),Substr(cRadCarta,4,6) 3D ;
ON CLICK QPChgRadio(nRadio,cRadCarta,@nTamAmo,@oTamAmo)  SIZE 50,10 OF oPanel PIXEL

@ 42,2	SAY STR0019	SIZE 80, 7 OF oPanel PIXEL FONT oFont COLOR CLR_BLUE //"Tamanho das Amostras:"
@ 40,80	MSGET oTamAmo VAR nTamAmo	PICTURE "99" Valid QPVldTam(nTamAmo) SIZE 20, 9 OF oPanel PIXEL
oTamAmo:cSX1Hlp := "QP1_QTDE"
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpca:=0,oDlg:End()})
If nOpca == 1
	RecLock("TRB",.F.)
	TRB->TB_SELECAO	:= Iif(nRadio==1,Substr(cRadCarta,1,3),Substr(cRadCarta,4,6))
	TRB->TB_TAMAMO	:= nTamAmo
	MsUnlock()
EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPVldTam    ³ Autor ³Marcelo Pimentel       ³ Data ³ 13/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o Tamanho da Amostra - Devera estar entre 5 e 10      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Cadastro de Resultados								        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPVldTam(nTamAmo)
Local lRet	:= .T.
If nTamAmo < 2 .Or. nTamAmo > 10
	Help(" ",1,"QPNTAMAMO")
	lRet	:= .F.
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPChgRadio  ³ Autor ³Marcelo Pimentel       ³ Data ³ 13/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o Tamanho da Amostra conforme a Carta               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Cadastro de Resultados								        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPChgRadio(nRadio,cRadCarta,nTamAmo,oTamAmo)

If nRadio == 1 .And. Substr(cRadCarta,1,3) == "IND"
	nTamAmo	:= 1
	oTamAmo:Disable()
	oTamAmo:Refresh()
Else
	nTamAmo	:= 5
	oTamAmo:EnaBle()
	oTamAmo:Refresh()
EndIf
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³A020StBtn ³ Autor ³ Eduardo de Souza      ³ Data ³ 26/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita/Desabilita o botao para impressao        		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A020StBtn(cDir,oBtn1,oBtn2)          					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPM020   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A020StBtn(cDir,oBtn1,oBtn2)

If File(cDir+"HISTO.BMP")
	oBtn1:lReadOnly := .F.
Else
	oBtn1:lReadOnly := .T.
Endif

If File(cDir+"CARTA.BMP")
	oBtn2:lReadOnly := .F.
Else
	oBtn2:lReadOnly := .T.
Endif

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIM020    ºAutor  ³Iolanda Vilanova    º Data ³  18/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a chamada do relatorio padrao ou do usuario          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIM020                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QM020Impr(nOpt,aOpcoes,aGraf64)

IF !lExistChart
	If aOpcoes[1] <> aGrafAtivo[1]
		Alert(STR0027) // Clique em Ok para gerar o Grafico referente a este Ensaio.
		Return
	Endif
ENDIF

If ExistBlock("QIPIMPR")
	ExecBlock("QIPIMPR",.f.,.f.)
Else	
	QIPR170(nOpt,aOpcoes,aGraf64)
Endif 

Return
