#INCLUDE "TRMXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³28/07/14³TPZWA0³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Oswaldo L ³27-04-17³DRHPONTP-300 ³ Entre os dias 24-04-17 e 26-04-17   ³±±
±±³          ³        ³            ³ baixamos os fontes do TFS das pastas ³±±
±±³          ³        ³            ³ MAIN, 12.1.14 e 12.1.16. Conforme    ³±±
±±³          ³        ³            ³ solicitado fizemos merge delas,depois³±±
±±³          ³        ³            ³ removemos alteracoes em SX           ³±±
±±³Isabel N. ³01/08/17³DRHPONTP³Ajuste em TrmSitFol p/usar data final da  ³±±
±±³          ³        ³-807    ³tabela RA4 em treinamentos baixados.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TrmHeader   ³ Autor ³ Cristina Ogura      ³ Data ³ 14/11/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criar os Arrays do Header dos arquivos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrmHeader(aAuxHeader,aFields,cAlias,aFieldsObg)
	//Salva a integridade dos campos de Bancos de Dados
	Default aFieldsObg := {}

	DbSelectArea("SX2")  
	DbSetOrder(1)
	DbSeek(cAlias)
		
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAlias)
	While !EOF() .And. (x3_arquivo == cAlias)
		If ( x3uso(x3_usado) .Or. ASCAN(aFieldsObg,Trim(x3_campo)) > 0 ) .AND. cNivel >= x3_nivel .and. ASCAN(aFields,Trim(x3_campo)) == 0
			Aadd(aAuxHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_arquivo, x3_context } )
		EndIf
		DbSkip()
	EndDo
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TrmCols   ³ Autor ³ Cristina Ogura        ³ Data ³ 14/11/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criar os Arrays do aCols dos arquivos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Trma100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrmCols(aAuxCols,aFields,nOpcx,aColsRec,cAlias,cCond,cChave,aAuxHeader,nOrdem,nTamaCols,nQual)
Local nCntFor := 0
Local nUsado  := Len(aAuxHeader)
Local nAcols  := 0
Default nTamaCols := 0 
Default	nQual := 0

aAuxCols := {}    

nOrdem 	:= IIf(nOrdem==NIl,1,nOrdem)
If aColsRec==Nil
	aColsRec:={}
EndIf	

// Para tratamento dos inicializadores Padroes
// Quando uma matriz eh atribuida a outra seus enderecos sao
// iguais na memoria, assim alterando-se uma altera-se a outra.
aCols 	:= aAuxCols						
aHeader	:= aAuxHeader

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
If dbSeek(cCHAVE)
    While !Eof() .And. &cCond == cChave
		aadd(aAuxCols,Array(nUsado+If(nOpcx#2.And.nOpcx#5,1,0)))
		nAcols := Len(aAuxCols)
		For nCntFor := 1 To Len(aHeader)
			If ( aHeader[nCntFor][10] != "V")
				aAuxCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
			Else
				aAuxCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
			EndIf
		Next nCntFor
		If nOpcx # 2 .And. nOpcx # 5
			aAuxCols[nAcols][nUsado+1] := .F.
		EndIf
		dbSelectArea(cAlias)
		Aadd(aColsRec,Recno())
		dbSkip()
	EndDo
Else
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	aadd(aAuxCols,Array(nUsado+If(nOpcx#2.And.nOpcx#5,1,0)))
	nAcols := Len(aAuxCols)
	For nCntFor := 1 To Len(aHeader)
		aAuxCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
	Next nCntFor
	If nOpcx # 2 .And. nOpcx # 5
		aAuxCols[1][nUsado+1] := .F.
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utilizado na validacao da linha da getdados quando inclusao ou alteracao      ³
//³ para garantir o conteudo do Inicializador Padrao do Campo. Ex.: Rs150DTProc() ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamaCols := Len(aCols)

If  nQual == 4 
	nTamaCols:= 0
EndIf

aCols 	:= {}
aHeader	:= {}


Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TrmDesc      ³ Autor ³ Cristina Ogura    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Traz o retorno da descricao dos campos dos arquivo do TRM  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias do arquivo                                   ³±±
±±³          ³ ExpN1 : Variavel contendo os dados do Seek                 ³±±
±±³          ³ ExpN2 : Variavel de retorno da descricao                   ³±±
±±³          ³ ExpN3 : Variavel contendo a filial corrente                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRM           ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TrmDesc(cAuxAlias,cVar,cRetorno,cFil)
Local aSaveArea	:= GetArea()
Local cDescr	:= ""
Local nx		:= 0

dbSelectArea(cAuxAlias)
dbSetOrder(1)

If (cFil # Nil .AND. Len(Alltrim(cFil)) < FwGetTamFilial ) .OR. (cFil == Nil) .OR. (cFil <> xFilial(cAuxAlias))
	cFil := cFilial
Endif

If dbSeek(cFil+cVar)
	cDescr:= &(cRetorno)
Else 
	nx := At(">",cRetorno)
	If nx > 0
	    nx++
	    cRetorno := Subs(cRetorno,nx,10)
	EndIf	                         
	If FieldPos(cRetorno) > 0
		cDescr := Criavar(cRetorno,.F.) 
	EndIf
EndIf

RestArea(aSaveArea)

Return cDescr

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fSitCurso ³ Autor ³ RH - Kleber      	    ³ Data ³ 16/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecionar a Tipo de Reserva do Curso com Base no SX5.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fSitCurso() 			   									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico 					   								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fSitCurso(l1Elem)

Local cTitulo	:= ""
Local MvPar		:= ""
Local MvParDef	:= ""
Local oWnd

Private aSit	:= {}
l1Elem := If (l1Elem = Nil , .F. , .T.)

oWnd := GetWndDefault()

cAlias 	:= Alias() 					 // Salva Alias Anterior
MvPar	:= &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet	:= Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

dbSelectArea("SX5")
If dbSeek(cFilial+"00R7")
	cTitulo := Alltrim(Left(X5Descri(),20))
Endif
If dbSeek(cFilial+"R7")
	While !Eof() .And. SX5->X5_TABELA == "R7"
		Aadd(aSit,Alltrim(X5Descri()))
		MvParDef:=MvParDef+Left(SX5->X5_CHAVE,1)
		dbSkip()
	Enddo
Else
	Help(" ",1,"GPEXSITDEF") // Estou usando situacao Default, nao achei tabela
	aSit:={"LISTA ESPERA","RESERVA","SOLICITACAO"}
	MvParDef:="LRS"
	cTitulo :="Situacao"
Endif
f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,l1Elem) // Chama funcao f_Opcoes
&MvRet := mvpar										 // Devolve Resultado
dbSelectArea(cAlias) 								 // Retorna Alias

If oWnd != Nil
	GetdRefresh()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TrmLegenda    ³ Autor ³ Emerson Grassi   ³ Data ³ 01.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acionar Legenda das cores da Mbrowse.				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TrmLegenda(nGrupo)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nGrupo 	- Grupo de Legenda que programa utiliza.          ³±±
±±³			 ³ cTab		- Tabela do SX5							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TRMA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrmLegenda(nGrupo, cTab, aCores, aLegenda)
                  
Local aSaveArea := GetArea()
Local aTab		:= {}
Local cCor		:= ""
Local _nX		:= 0
              
nGrupo 	:= If(nGrupo	== Nil, 1	, nGrupo	)
cTab	:= If(cTab 		== Nil, ""	, cTab		)
aCores	:= If(aCores 	== Nil, {}	, aCores	)
aLegenda := If(aLegenda == Nil, {}	, aLegenda)
                                      
If nGrupo == 0    //SX5
    dbSelectArea("SX5")
    dbSetOrder(1)
    dbSeek(xFilial("SX5")+cTab)
    While !Eof() .And. cTab == SX5->X5_TABELA
    	_nX++
    	If Len(aCores) >= _nX
	    	cCor := aCores[_nX]
	    Else 
	    	cCor := "BR_PRETO"
	    EndIf
        Aadd(aTab,{ cCor,OemToAnsi(Alltrim(Left(X5Descri(),20))) })
    	dbSkip()
    EndDo
	If Len(aTab) > 0    
		BrwLegenda(cCadastro,STR0001,aTab)
	EndIf									
EndIf                                                        

If nGrupo == 1
	aAdd(aTab, {"BR_VERDE"	 	, OemToAnsi(STR0002)}) //"Situa‡„o Normal"
	aAdd(aTab, {"BR_PINK"    	, OemToAnsi(STR0054)}) //"Transferido 
	aAdd(aTab, {"BR_VERMELHO"	, OemToAnsi(STR0003)}) //"Demitido"
	aAdd(aTab, {"BR_AMARELO" 	, OemToAnsi(STR0004)}) //"Afastado"
	aAdd(aTab, {"BR_AZUL"	 	, OemToAnsi(STR0005)})
ElseIf nGrupo == 2								
	aAdd(aTab, {"ENABLE"		, OemToAnsi(STR0006)}) //"Em Aberto"
	aAdd(aTab, {"BR_VERMELHO" 	, OemToAnsi(STR0007)}) //"Encerrado"
ElseIf nGrupo == 3
	aAdd(aTab, {"ENABLE"		, OemToAnsi(STR0008)}) //"Teste em Aberto "
	aAdd(aTab, {"BR_VERMELHO"	, OemToAnsi(STR0009)}) //"Teste Realizado no dia "
	aAdd(aTab, {"BR_AMARELO"	, OemToAnsi(STR0010)}) //"Agendado para outro dia"	
ElseIf nGrupo == 4
	aAdd(aTab, {"ENABLE"		, OemToAnsi(STR0027)}) //"Agendado para o dia"
	aAdd(aTab, {"BR_VERMELHO"	, OemToAnsi(STR0028)}) //"Teste Realizado"
	aAdd(aTab, {"BR_AMARELO"	, OemToAnsi(STR0010)}) //"Agendado para outro dia"
ElseIf nGrupo == 5
	aAdd(aTab, {"ENABLE"		, OemToAnsi(STR0002)}) //"Situa‡„o Normal"
	aAdd(aTab, {"BR_PINK"       , OemToAnsi(STR0054)}) //"Transferido" 
	aAdd(aTab, {"BR_VERMELHO"	, OemToAnsi(STR0003)}) //"Demitido"
	aAdd(aTab, {"BR_AMARELO"	, OemToAnsi(STR0004)}) //"Afastado"
	aAdd(aTab, {"BR_AZUL"		, OemToAnsi(STR0005)}) //"F‚rias" 
	aAdd(aTab, {"BR_MARROM"		, OemToAnsi(STR0029)}) //"Programacao de F‚rias"  
ElseIf nGrupo == 6
	aAdd(aTab, {"BR_VERDE"		, OemToAnsi(STR0049)}) //"Teste em Aberto no dia "
	aAdd(aTab, {"BR_AZUL"		, OemToAnsi(STR0048)}) //"Teste em Aberto em atraso"
	aAdd(aTab, {"BR_VERMELHO"	, OemToAnsi(STR0050)}) //"Teste Realizado"
	aAdd(aTab, {"BR_AMARELO"	, OemToAnsi(STR0010)}) //"Agendado para outro dia"									
EndIf

If nGrupo != 0
	If !Empty(aLegenda)
		For _nX := 1 to Len(aTab)
			If ( (nPos := Ascan(aLegenda, {|x| x[1]== aTab[_nX][1]})) > 0 )
				aLegenda[nPos][2] := aTab[_nX][2]
			Else
				aAdd(aLegenda, aTab[_nX])
			EndIf
		Next _nX
	ElseIf Empty(aLegenda)
		aLegenda := aClone(aTab)
	EndIf
	BrwLegenda(cCadastro, STR0001, aLegenda)
EndIf

RestArea(aSaveArea)
Return(aCores)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TrmAleat ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 02/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera numero aleatorio respeitando um valor maximo.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Valor Maximo.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrmAleat(nMaximo) 	// Valor maximo
                                                                              
Static nSeed 				// Variavel geradora
                                                                              
Local nMulti 				// Multiplicador
Local nPI      				// PI                        
                                                                              
nMulti := 10000000
nPI    := (3.1415926535897932384626433)
nSeed  := Iif( nSeed = Nil, Seconds(), nSeed )
                                                                              
Return ( nMaximo * ( ( nSeed := Mod( nSeed * nPI + 1, nMulti ) ) / nMulti ) )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FVerFatG ³ Autor ³ Cristina Ogura        ³ Data ³ 16/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que verifica os Fatores Avaliacao Geral      		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Valor Maximo.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FVerFatG(aArray)
Local aArea 	:= GetArea()
Local nx		:= 0                         
Local cFil		:= ""
                         
For nx := 1 To Len(aArray)
	cFil := xFilial("SQV", aArray[nx][1])
	dbSelectArea("SQV")
	dbSetOrder(1)
	If 	!dbSeek(cFil+aArray[nx][2]+aArray[nx][3])
		RestArea(aArea)
		Return .F.
	EndIf
Next nx
                         
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TrmGraf  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 18/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Grafico.									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RsGraf()						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA = Dados do Grafico                                    ³±±
±±³          ³ 	   [n][1] Eixo X				                          ³±±
±±³          ³ 	   [n][2] Eixo Y				                          ³±±
±±³          ³ 	   [n][3] Grupo do Eixo X		                          ³±±
±±³          ³ ExpN = Tipo do grafico selecionado                         ³±±
±±³          ³ ExpC1= Titulo do grafico 			                      ³±±
±±³          ³ ExpC2= Titulo do Eixo X			                          ³±±
±±³          ³ ExpC3= Titulo do Eixo Y			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrmGraf(aDados,nCbx,cTitulo,cTituloX,cTituloY,aLegenda,aTabela,aPosCol,aPosGrh)

Local oDlg
Local obmp
Local oBold
Local oGraphic 
Local i			:= 0
Local j			:= 0
Local aSerie	:= {}
Local aArea     := GetArea()
Local aColors 	:= {}
Local aBmp		:= {}
Local nCor		:= 1  

Local aSize     := MsAdvSize( .T. ) 
Local aPosObj   := {} 
Local aObjects  := {}                        
Local aKeys		:= GetKeys()

Local bSet15 	:= {||oDlg:End(),.T.}
Local bSet24 	:= {||oDlg:End()}

Local aButtons  :=  {} 


If Len(aDados) > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua os calculos de Auto Size                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, , .T. )
	
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	
	@ aPosObj[1,1], aPosObj[1,2] MSGRAPHIC oGraphic SIZE aPosObj[1,4], aPosObj[1,3] OF oDlg PIXEL
	oGraphic:SetMargins( 2, 6, 6, 6 )
	
	// Adiciona as cores padrao
	AAdd( aColors,  CLR_HBLUE     )
	AAdd( aColors,  CLR_HGREEN    )
	AAdd( aColors,  CLR_HRED      )
	AAdd( aColors,  CLR_HMAGENTA  )
	AAdd( aColors,  CLR_RED       )
	AAdd( aColors,  CLR_GRAY      )
	AAdd( aColors,  CLR_HCYAN     )
	AAdd( aColors,  CLR_YELLOW    )
	AAdd( aColors,  CLR_WHITE     )
	AAdd( aColors,  CLR_BLACK     )
	
	Aadd( aBmp, "BR_AZUL"		)
	Aadd( aBmp, "BR_VERDE"		)
	Aadd( aBmp, "BR_VERMELHO"	)
	Aadd( aBmp, "BR_PINK"		)
	Aadd( aBmp, "BR_MARRON"		)
	Aadd( aBmp, "BR_CINZA"		)
	Aadd( aBmp, "LIGHTBLU"		)
	Aadd( aBmp, "BR_AMARELO"	)
	Aadd( aBmp, "BRANCO"		)
	Aadd( aBmp, "BR_PRETO"		)
	
	
	For i := 1 to Len(aDados[1])
		Aadd(aSerie, oGraphic:CreateSerie(nCbx))
	Next i
	For i := 1 to Len(aDados)
		For j := 1 to Len(aDados[i])
			If aSerie[j] != GRP_CREATE_ERR
				nCor := Iif(j <= Len(aColors), aColors[j],aColors[j-Len(aColors)])
				
				// Adiciona dados ao grafico
				oGraphic:Add(aSerie[j],aDados[i][j][2],aDados[i][j][3],nCor ) //Cor de cada barra
			Else
				MsgStop(STR0011)//"Tipo nao disponivel para este grafico."
				Exit
			Endif
		Next j
	Next i
	
	oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, GRP_SERIES, .F.)
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( cTituloY	, "", CLR_HRED , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetTitle( cTituloX	, "", CLR_GREEN, A_RIGHTJUS , GRP_FOOT  )

    aButtons:= TrmGrfBar(oDlg,@oGraphic,aSerie[1],aLegenda,aBmp,cTitulo,aTabela,aPosCol,aPosGrh)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15 , bSet24, Nil, aButtons  ) CENTERED 
	
    
Else
	AVISO(STR0021,STR0026,{"Ok"})	//"Atencao"###"Verifique se a Vaga esta relacionada a uma funcao."
EndIf

RestKeys(aKeys,.T.)
RestArea(aArea)

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TrmGrfBar ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 20/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao generica para montagem de EnchoiceBar dos graficos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³        01³ ExpO1 = Objeto da Dialog                                   ³±±
±±³        02³ ExpO2 = Objeto do Grafico                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TrmGrfBar(oDlgGraph, oGraphic,cSerie,aLegenda,aBmp,cTitulo,aTabela,aPosCol,aPosGrh)

Local i			:= 0        
Local aLeg		:= {}
Local bSetF4	:= {||oDlgGraph:End()}
Local bSetF5	:= {||oGraphic:l3D := !oGraphic:l3D}
Local bSetF6	:= {||GrafSavBmp( oGraphic )}
Local bSetF7	:= {||(Iif(oGraphic:l3D,oGraphic:ChgRotat( cSerie, 1, .F. ),Nil))}
Local bSetF8	:= {||(Iif(oGraphic:l3D,oGraphic:ChgRotat( cSerie, 1, .T. ),Nil))}
Local bSetF9	:= {||BrwLegenda(cCadastro,STR0001,aLeg)}



Local bSetF10	:= {||RspGrafPrint(oGraphic,cTitulo,{ cTitulo },aTabela, .F.,aPosCol,aPosGrh)}

Local bSetF11	:= {||PmsGrafMail(oGraphic,cTitulo,{cTitulo },aTabela)}
Local aButtons 	:= {}



SetKey(VK_F4 ,bSetF4)
SetKey(VK_F5 ,bSetF5)
SetKey(VK_F6 ,bSetF6)
SetKey(VK_F7 ,bSetF7)
SetKey(VK_F8 ,bSetF8)
SetKey(VK_F9 ,bSetF9)
SetKey(VK_F10,bSetF10)
SetKey(VK_F11,bSetF11)

For i := 1 to Len(aLegenda)
	If i <= Len(aBmp)
		Aadd(aLeg,{aBmp[i],aLegenda[i]})
	Else 
		Aadd(aLeg,{aBmp[i-Len(aBmp)],aLegenda[i]})	
	EndIf
Next i

aAdd(aButtons, { "GRAF3D", { || Eval(bSetF5) } , OemToAnsi(STR0019) } ) 	// "Dimensao <F5>"
aAdd(aButtons, { "SALVAR", { || Eval(bSetF6) }, OemToAnsi( STR0012 ) } ) 	// "Salva BMP <F6>
aAdd(aButtons, { "PREV", { || Eval(bSetF7) }, OemToAnsi( STR0013 ) } ) 		// "Rotacao - <F7>
aAdd(aButtons, { "NEXT", { || Eval(bSetF8) }, OemToAnsi( STR0014 ) } ) 		// "Rotacao + <F8>
aAdd(aButtons, { "BMPVISUAL", { || Eval(bSetF9) }, OemToAnsi( STR0025 ) } ) // "Legenda" <F9>
aAdd(aButtons, { "impressao", { || Eval(bSetF10) }, OemToAnsi( STR0023 ) } ) // Imprimir grafico <F10>
aAdd(aButtons, { "BMPPOST", { || Eval(bSetF11) }, OemToAnsi( STR0024 ) } ) 	// "Enviar por E-Mail <F11>"

RETURN (aButtons)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TrmFilBrw     ³ Autor ³ Emerson Grassi   ³ Data ³ 05/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro de Browse com chave unica.					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TrmFilBrw()			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ bFiltraBrw - Bloco da FilBrowse.					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrmFilBrw(bFiltraBrw)
UniqueKey()	 // Limpar variaveis
Eval(bFiltraBrw) 
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TrmHora  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 15/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Formatar campo Hora.									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TrmHora(cHorario)

Local lRet 		:= .F.
Local cCampo	:= ReadVar()
Local cHora		:= &cCampo
Local lHorario	:= (cHorario != Nil .And. ValType(cHorario) != "U")

If lHorario
	cHora := cHorario	
EndIf

If Len(cHora) == 8
	cHora 	:= 	Padl(Alltrim(Subs(cHora,1,2)),2,"0")+":"+;
				Padl(Alltrim(Subs(cHora,4,2)),2,"0")+":"+;
				Padl(Alltrim(Subs(cHora,7,2)),2,"0") 
				
Else
	cHora 	:= 	Padl(Alltrim(Subs(cHora,1,2)),2,"0")+":"+;
				Padl(Alltrim(Subs(cHora,4,2)),2,"0")
EndIf

If lHorario
	cHorario:= cHora	
Else
	&cCampo	:= cHora   
EndIf    

If Len(cHora) == 8
	If 	Val(Subs(cHora,1,2)) < 24 .AND. Val(Subs(cHora,4,2)) < 60 .And.;
		Val(Subs(cHora,7,2)) < 60 
		lRet := .T.
	EndIf  
	
ElseIf Val(Subs(cHora,1,2)) < 24 .AND. Val(Subs(cHora,4,2)) < 60 	
	lRet := .T.
EndIf
					
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TrmSitFol ³ Autor ³Eduardo Ju             ³ Data ³05.11.03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da Situacao do Funcionario                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dDtSituacao - Data referencia da situacao do funcionario    ³±±
±±³          ³cTipo - Identificacao da rotina que esta processando a si-  ³±±
±±³          ³        tuacao do funcionario, sendo:                       ³±±
±±³          ³        "C" - Registro coletivo de curso					  ³±±
±±³          ³        "B" - Treinamentos baixados                         ³±±
±±³          ³        "X" - Todas as outras, situacoes                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function TrmSitFol(dDtSituacao,cTipo) 

Local cSitfol 		:= ""     
Local dCalendFim 	:= cTod("")   
Local dSitFolIni 	:= cTod("")
Local nDiasFerias	:= 0
Local dSitFolFim 	:= cTod("")
Local nI			:= 0
Local aDatas		:= {}
Local aDias 		:= {}
Local aSaveSRA 		:= SRA->(GetArea())
Local aSaveRA2 		:= RA2->(GetArea())
Local aSaveSRF 		:= SRF->(GetArea())
             
DEFAULT dDtSituacao := RA2->RA2_DATAIN
DEFAULT cTipo		:= "X"

dCalendFim 	:= If( cTipo == "C", dDtSituacao, RA2->RA2_DATAFI )
dCalendFim 	:= If( cTipo == "B", RA4->RA4_DATAFI, dCalendFim )
cSitFol 	:= fBuscaSituacao(SRA->RA_FILIAL,SRA->RA_MAT,dDtSituacao, dDtSituacao, dCalendFim)

If cSitFol == " " 

	dbSelectArea("SRF")
	dbSetOrder(1)
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
		
		aDatas 	:= {SRF->RF_DATAINI,SRF->RF_DATINI2,SRF->RF_DATINI3}		                                     	
		aDias	:= {SRF->RF_DFEPRO1,SRF->RF_DFEPRO2,SRF->RF_DFEPRO3}
		For nI := 1 To Len(aDatas)
			If aDias[nI] > 0 .And. !Empty(aDatas[nI])
				dSitFolIni := aDatas[nI]           
				nDiasFerias:= aDias[nI]
				dSitFolFim := dSitFolIni + nDiasFerias 
				If !(dSitFolFim < dDtSituacao .Or. dSitFolIni > dCalendFim)
					cSitFol := "P"
					Exit
				EndIf				
			EndIf
		Next nI
	EndIf
Endif 

SRA->(RestArea(aSaveSRA))
RA2->(RestArea(aSaveRA2))
SRF->(RestArea(aSaveSRF))

Return(cSitFol)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TrmSitMsg ³ Autor ³Eduardo Ju             ³ Data ³06.11.03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mensagem da Situacao do Funcionario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TRMA060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrmSitMsg(cSitFol) 

Local dCalendIni 	:= cTod("")
Local dCalendFim 	:= cTod("")
Local dSitFolIni 	:= cTod("")
Local nDiasFerias	:= 0
Local dSitFolFim 	:= cTod("")
Local lRet			:= .T.     
Local nI		  	:= 0
Local aDatas	  	:= {}
Local aDias 	  	:= {}
Local aSaveSRA 		:= SRA->(GetArea())
Local aSaveRA2 		:= RA2->(GetArea())
Local aSaveSRF 		:= SRF->(GetArea())
Local aSaveSR8 		:= SR8->(GetArea())

cSitFol := TR1->TR1_SITFOL
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Opcao de Reserva para Funcionarios com Programacao de Ferias             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cSitFol == "P" 
	dbSelectArea("RA2")
	dbSetOrder(1)
			
	dCalendIni := RA2->RA2_DATAIN
	dCalendFim := RA2->RA2_DATAFI

	dbSelectArea( "SRF" )
	If dbSeek( TR1->TR1_FILIAL + TR1->TR1_MAT )
		
		aDatas 	:= {SRF->RF_DATAINI,	SRF->RF_DATINI2,SRF->RF_DATINI3}		                                     	
		aDias		:= {SRF->RF_DFEPRO1,SRF->RF_DFEPRO2,SRF->RF_DFEPRO3}
			
		For nI := 1 To Len(aDatas)
			If aDias[nI] > 0 .And. !Empty(aDatas[nI])
				dSitFolIni := aDatas[nI]           
				nDiasFerias:= aDias[nI]
				dSitFolFim := dSitFolIni + nDiasFerias
				If !(dSitFolFim < dCalendIni .Or. dSitFolIni > dCalendFim)
					lRet := MsgYesNo(OemToAnsi(STR0030)+dToc(dSitFolIni)+OemToAnsi(STR0031)+dToc(dSitFolFim)+" ?",OemToAnsi(STR0032)) 		//"Confirma Reserva de Treinamento para Funcionario com Ferias programada para ", " a ","Ferias Programadas"	
					Exit
				EndIf 
			EndIf
		Next nI	  	
	EndIf		
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Opcao de Reserva para Funcionarios em Ferias                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cSitFol == "F" 
	dbSelectArea("RA2")
	dbSetOrder(1)
			
	dCalendIni := RA2->RA2_DATAIN
	dCalendFim := RA2->RA2_DATAFI

	dbSelectArea( "SR8" )
	If dbSeek( TR1->TR1_FILIAL + TR1->TR1_MAT )
		If !Empty(SR8->R8_DATAINI)
			dSitFolIni := SR8->R8_DATAINI            
			dSitFolFim := SR8->R8_DATAFIM   	
		EndIf
	EndIf
			
	If !(dSitFolFim < dCalendIni .Or. dSitFolIni > dCalendFim)
		lRet := MsgYesNo(OemToAnsi(STR0033)+dToc(dSitFolIni)+OemToAnsi(STR0031)+dToc(dSitFolFim)+" ?",OemtoAnsi(STR0034)) //"Confirma Reserva de Treinamento para Funcionario em Ferias de "," a ","Ferias")			
	EndIf		
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Opcao de Reserva para Funcionarios em Afastamento                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cSitFol == "A"
	dbSelectArea("RA2")
	dbSetOrder(1)
			
	dCalendIni := RA2->RA2_DATAIN
	dCalendFim := RA2->RA2_DATAFI

	dbSelectArea( "SR8" )
	If dbSeek( TR1->TR1_FILIAL + TR1->TR1_MAT )
		If !Empty(SR8->R8_DATAINI)
			dSitFolIni := SR8->R8_DATAINI            
			dSitFolFim := SR8->R8_DATAFIM
		EndIf
	EndIf	 
   
	If !(dSitFolFim < dCalendIni .Or. dSitFolIni > dCalendFim)
		If !Empty(dSitFolFim)	
			lRet := MsgYesNo(OemToAnsi(STR0035)+dToc(dSitFolIni)+OemToAnsi(STR0031)+dToc(dSitFolFim)+" ?",OemToAnsi(STR0037))			//"Confirma Reserva de Treinamento para Funcionario afastado temporariamente em ","Afastado Temporariamente"	
		Else
			lRet := MsgYesNo(OemToAnsi(STR0036)+dToc(dSitFolIni)+" ?",OemToAnsi(STR0037)) //"Confirma Reserva de Treinamento para Funcionario afastado temporariamente desde ","Afastado Temporariamente"
		EndIf			
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Opcao de Reserva para Funcionarios Demitidos                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cSitFol == "D"
	dbSelectArea("RA2")
	dbSetOrder(1)
			
	dCalendIni := RA2->RA2_DATAIN
	dCalendFim := RA2->RA2_DATAFI

	dbSelectArea( "SRA" )
	If dbSeek( TR1->TR1_FILIAL + TR1->TR1_MAT )
		If !Empty(SRA->RA_ADMISSA)
			dSitFolIni := SRA->RA_ADMISSA            
			dSitFolFim := SRA->RA_DEMISSA
		EndIf
	EndIf	
   
	If (dSitFolFim <= dCalendFim) .Or. (dSitFolFim >= dCalendIni)
		lRet := MsgYesNo(OemToAnsi(STR0038)+dToc(dSitFolFim)+" ?",OemToAnsi(STR0039))		//"Confirma Reserva de Treinamento para Funcionario demitido/transferido desde ","Demitidos/Transferidos"
	EndIf
EndIf    

SRA->(RestArea(aSaveSRA))
RA2->(RestArea(aSaveRA2))
SRF->(RestArea(aSaveSRF))
SR8->(RestArea(aSaveSR8))

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TrmUsrAlter ³ Autor ³ Emerson Grassi Rocha ³ Data ³17/03/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona campos de Usuario no array aAlter.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TrmUsrAlter(@aAlter,cAlias)                    		   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 						                               	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TrmUsrAlter(aAlter, cAlias)
Local aSaveArea	:= GetArea()
Local aSaveSX3	:= SX3->(GetArea())

dbSelectArea("SX3")
dbSeek(cAlias)
While !Eof() .And. (X3_ARQUIVO == cAlias)
	If X3_PROPRI == "U"
		Aadd(aAlter,X3_CAMPO)
	EndIf	
	dbSkip()
EndDo

RestArea(aSaveSX3)     
RestArea(aSaveArea)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RhDescCC	   ³ Autor ³ Emerson Grassi Rocha ³ Data ³19/11/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Descricao do Centro de Custos					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RhDescCC(cCC)                    					   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 						                               	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RhDescCC(cCC)

Local cAliasCc	:= ""
Local cCpoDesCc	:= ""
Local cKeyOrder	:= ""
Local nOrder

cAliasCc	:= "CTT"
cCpoDesCc	:= "CTT_DESC01"
cKeyOrder	:= "CTT_FILIAL+CTT_CUSTO"
nOrder	:= RetOrdem( cAliasCc , cKeyOrder , .F. )

Return( fDesc( cAliasCc , cCc , cCpoDesCc ) )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RspGrapPrint³ Autor ³ Eduardo Ju          ³ Data ³ 23.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao de impressao de grafico usando TMsPrinter              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGACSA - SIGARSP - SIGATRM                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RspGrafPrint(oGraphic,cProcesso,aTexto,aTabela, lLandScape, aPosCol, aPosGrh)

DEFAULT lLandScape := .T.

Private cBmpName

Processa({ || 	RSPG10Cfg(cProcesso, "RspEnvPrint", cProcesso, .T., oGraphic, aTexto, aTabela, aPosCol, aPosGrh),;
				STR0051 }) //"Montando a impressao do grafico. Aguarde ..."

If oGraphic # Nil .and. cBmpName # Nil .And. File("\" + cBmpName) 
	Ferase("\" + cBmpName)
EndIf

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RspEnvPrint ³ Autor ³ Eduardo Ju          ³ Data ³ 23.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a impressao do Objeto TMsPrinter                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGACSA - SIGARSP - SIGATRM                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RspEnvPrint(oPrint,i,titulo,cProcesso,lLandScape,oGraphic,aTexto,aTabela,;
					 aPosCol,aPosGrh)

Local nx, x
Local lBmp 			:= !( oGraphic == NIL )

Local lin 			:= 2811
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local nMaxLin		:= If(lLandScape, 3120 - 1, 2350 - 1)      
Local cStartPath	:= GetSrvProfString("Startpath","")

DEFAULT aPosCol	:= { 360, 1300, 2100 }
DEFAULT aPosGrh	:= { 360, 2100, 1700 }
DEFAULT aTexto  := {}
Default aTabela := {}

ProcRegua(Len(aTabela)) 

If lBmp
	cBmpName := CriaTrab(,.F.)+".BMP"
	oGraphic:SaveToBMP( cBmpName, "\" )
	IncProc()
Endif

For nx := 2 to Len(aTabela)

	IncProc()
	
	If lin > 2810		
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nMaxLin )   	// horizontal                          			
		EndIf	
		i++                                                
		oPrint:EndPage() 	 				// Finaliza a pagina
		CtbCbcDem(oPrint,titulo,lLandScape)	// Funcao que monta o cabecalho de Demonstrativos
		Lin := 250

		If Len(aTabela) > 1
			oPrint:Line( lin,150,lin+50, 150 )   		// vertical
			For x := 1 to Len(aTexto)
				oPrint:Say(Lin,aPosCol[1],aTexto[x],oCouNew08N) 				
				If x > 1
					lin +=47
				Endif
			Next

			oPrint:Line( lin, nMaxLin,lin+50,nMaxLin)		// Separador vertical 
			oPrint:Line( lin + 35, 150,lin+35,nMaxLin)	// Separador Horizontal
			lin +=47

			oPrint:Line( lin,150,lin+50, 150 )   		// vertical
			For x := 1 to Len(aTabela[1])		
				oPrint:Say(Lin,aPosCol[x],aTabela[1,x],oCouNew08N)	
			Next

			oPrint:Line( lin, nMaxLin,lin+50,nMaxLin)		// Separador vertical 
			oPrint:Line( lin + 35, 150,lin+35,nMaxLin)	// Separador Horizontal
			lin +=47
		EndIf

		lFirstPage := .F.		
	End

	oPrint:Line( lin,150,lin+50, 150 )   		// vertical
    y := 0
	For x := 1 to Len(aTabela[nx])     
		y := x
		If x > 2
			y--
		EndIf	
		If x == 2
			TRMXBMP(aTabela[nx,x],cStartPath)   
			oPrint:Saybitmap(Lin,aPosCol[y]-50,aTabela[nx,x],40,40) //Impressao de Objeto do Tipo BitMap 
		Else					
			oPrint:Say(Lin,aPosCol[y],aTabela[nx,x],oFont08)
		EndIf		
	Next

	oPrint:Line( lin, nMaxLin,lin+50,nMaxLin)		// Separador vertical 

	lin +=47

	nTraco := lin + 1
Next

If (lin + aPosGrh[3] + 77) > 2810
	If !lFirstPage
		oPrint:Line( ntraco,150,ntraco,nMaxLin )   	// horizontal                          			
	EndIf	
	i++                                                
	oPrint:EndPage() 	 				// Finaliza a pagina
	CtbCbcDem(oPrint,titulo,lLandScape)	// Funcao que monta o cabecalho de Demonstrativos
	Lin := 250
Endif

oPrint:SayBitmap(lin+60,aPosGrh[1], "\" + cBmpName, aPosGrh[2], aPosGrh[3])
oPrint:Line(lin,150,lin + aPosGrh[3] + 77,150)                         			
oPrint:Line(lin,nMaxLin,lin + aPosGrh[3] + 77, nMaxLin)   	// Vertical

lin += (aPosGrh[3] + 77)

oPrint:Line(lin,150,lin,nMaxLin)   	// Horizontal

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³RSPG10Cfg ³ Autor ³ Eduardo Ju            ³ Data ³ 23.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria os objetos para Relatorio Grafico                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPG10Cfg(titulo,cFuncao,cProcesso,lLandScape,	uParam1,uParam2,uParam3,;
														uParam4, uParam5)
		
Local oPrint
Local i 	:= 1

DEFAULT lLandScape := .T.

If Upper(cFuncao) <> "RSPENVPRINT" 
	Return .F.
Endif

oFont08		:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
oCouNew08N	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)		// Negrito
oCouNew08S	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.T.)		// SubLinhado
oCouNew10	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
oCouNew14	:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)
oCouNew16	:= TFont():New("Courier New",16,16,,.F.,,,,.T.,.F.)

oArial08N	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
oArial10	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)

oPrint:= TMSPrinter():New( titulo )
If lLandScape
	oPrint:SetLandscape()
Else                                             
	oPrint:SetPortrait()
Endif

//oPrint:Setup()

(&cFuncao.(oPrint, i, Titulo, cProcesso, lLandScape, 	uParam1, uParam2, uParam3,;
														uParam4, uParam5))

oPrint:Preview()  				// Visualiza antes de imprimir

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TRMXBMP   ³ Autor ³Eduardo Ju             ³ Data ³24.05.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retira o BMP do RPO e salva em local especifico e retorna   ³±±
±±³          ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do BMP no RPO                                 ³±±
±±³          ³ ExpC2 = Path para salvar o arquivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGACSA - SIGARSP - SIGATRM                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TRMXBMP(cNome, cPath)

Local lReturn := .F.

cNome := Upper(cNome)

If !File(cPath+cNome,0) // 0 Default, 1 Server, 2 Remote
	lReturn := Resource2File(cNome, cPath+cNome)
Endif

Return lReturn

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ TRMLoadExec	³Autor³  Igor Franzoi     ³ Data ³29/06/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Funcao executada a cada rotina (menu) chamado pelo TRM		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³TRMLoadExec													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Generico													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function TRMLoadExec()

If FindFunction("SPFLoadExec()")
	SPFLoadExec()
EndIf

Return (Nil)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³TrmRelationFile³ Autor ³Fabio G.             ³ Data ³04/06/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Valida o Relacionamentos dos Arquivos do Modulo TRM            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³TrmRelationFile( lShowHelp )								   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                         					   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³lRetModo													   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generica                                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TrmRelationFile( lShowHelp )
         
Local cAlias1	:= "SRJ"
Local cAlias2	:= "RA1"
Local cAlias3	:= "RAL"
Local lRetModo	:= .T.
Local cSRJ
Local cRA1
Local cRAL

Static lTrmChkRel
Static cLastEmpChk

DEFAULT lShowHelp	:= .T.

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Coloca o Ponteiro do Mouse em Estado de Espera               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
IF ( lShowHelp )
	CursorWait()
EndIF	

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Consiste o Modo de Acesso dos Arquivos                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Begin Sequence
	DEFAULT lTrmChkRel 	:= .T.
	DEFAULT cLastEmpChk	:= cEmpAnt
	IF ( cLastEmpChk <> cEmpAnt )
		lTrmChkRel := .T.
	EndIF
	IF !( lTrmChkRel )
		Break
	EndIF
	
	cSRJ	:= FWModeAccess( "SRJ", 1)+FWModeAccess( "SRJ", 2)+FWModeAccess( "SRJ", 3)
	cRA1	:= FWModeAccess( "RA1", 1)+FWModeAccess( "RA1", 2)+FWModeAccess( "RA1", 3)
	cRAL	:= FWModeAccess( "RAL", 1)+FWModeAccess( "RAL", 2)+FWModeAccess( "RAL", 3)
	
	If (cSRJ != cRA1)
		cHelp := STR0055 + cAlias1 +  " - " 
		cHelp += STR0055 + cAlias2
		Help( "" , 1 , "MODOACESSO" , , cHelp, 5 , 0 )
		lRetModo	:= .F.
		Break
	Elseif(cSRJ != cRAL)
		cHelp := STR0055 + cAlias1 + " - " 
		cHelp += STR0055 + cAlias3
		Help( "" , 1 , "MODOACESSO" , , cHelp, 5 , 0 )
		lRetModo	:= .F.
		Break
	EndIf
	
End Sequence

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Ponteiro do Mouse                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
IF ( lShowHelp )
	CursorArrow()
EndIF	

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Se estiver Tudo Ok nao verifica Novamente					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
lTrmChkRel := !( lRetModo ) 

Return( lRetModo )