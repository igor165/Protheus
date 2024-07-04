#INCLUDE "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#include "RSPA190.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ProgramA  ³ RSPA190  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³  28/06/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Modelos de Testes.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³29/07/2014³TQENN4³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³          ³      ³da a limpeza.                             ³±±
±±³Christiane V³18/10/2014³TQPLKF³Correção de posicionamento da tela e lim- ³±±
±±³            ³          ³      ³peza de campos ao mudar de linha.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPA190()
LOCAL cFiltra		:= ""			//Variavel para filtro 
LOCAL cFiltraSQW	:= ""			//Variavel para filtro

Private aIndFil		:= {}			//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro

Private cCadastro 	:= OemToAnsi(STR0006)	//"Cadastro de Modelos de Testes"

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQW")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"SQW","1")
cFiltraSQW 	:= "QW_SEQ == '01'"
If !Empty(cFiltra)
	cFiltraSQW := cFiltraSQW + ".And." + cFiltra
EndIf

bFiltraBrw 	:= {|| FilBrowse("SQW",@aIndFil,@cFiltraSQW) }
Eval(bFiltraBrw)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQW")
dbGoTop()

mBrowse( 6, 1,22,75,"SQW")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQW",aIndFil,.T.)

dbSelectArea("SQW")
dbSetOrder(1)

Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RSP190Rot ³ Autor ³ Emerson Grassi Rocha ³ Data ³ 28/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina Principal			                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA190       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RSP190Rot(cAlias,nReg,nOpcx)
Local oDlgMain, oGet
Local nOpca		:= 0
Local lTrDel	:= If(nOpcx=2.Or.nOpcx=5,.F.,.T.)
Local lInc1		:= .F.
Local lInc2		:= .F.
Local cDTipo	:= CriaVar("QW_DTIPO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

//Variaveis para Walk Thru
Local cChave	:= ""
Local nPosSeq	:= 0
Local aNoFields := {"QW_FILIAL","QW_MODELO","QW_DESCRIC","QW_SEQ","QW_DURACAO","QW_TIPO","QW_DTIPO"}
Local nSqwOrd	:= RetOrdem("SQW","SQW->QW_FILIAL + SQW->QW_MODELO")
Local bSeekWhile:= {|| SQW->QW_FILIAL + SQW->QW_MODELO }

// Private da Getdados
Private aCols  		:= {}
Private aHeader		:= {}
Private Continua	:= .F.
Private cCodSQW		:= ""
Private cDescSQW	:= CriaVar("QW_DESCRIC")
Private cDuraca		:= CriaVar("QW_DURACAO")
Private cRhTpAval	:= CriaVar("QW_TIPO")
Private nOpcao 		:= nOpcx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SQW",aIndFil,.T.)
aIndFil := {}
dbGoto(nReg)

If nOpcx == 3

	dbSelectArea("SQW")
	lInc1 	:= 	lInc2 := .T.
	cCodSQW	:= GetSxeNum("SQW","QW_MODELO")
Else	
	lInc1		:= .F.   
	lInc2 		:= If(nOpcx == 4, .T., .F.)
	cCodSQW		:= SQW->QW_MODELO
	cDescSQW	:= SQW->QW_DESCRIC
	cDuraca 	:= SQW->QW_DURACAO
	cRhTpAval	:= SQW->QW_TIPO
EndIf	

dbSelectArea("SQW")
cChave := xFilial(cAlias)+cCodSQW

//==> Monta FilGetDados para Walk Thru
FillGetDados(nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
			 "SQW"					,; //2-cAlias - area a ser utilizada;
			 nSqwOrd				,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			 cChave					,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
			 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
			 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
			 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
			 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
			 NIL					,; //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
			 nOpcx==3				,;	//nOpcx==3 12-lEmpty – Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
			 NIL					,; //13-aHeaderAux, eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
			 NIL					)  //14-aColsAux eh Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )

nPosSeq := GdFieldPos("QW_SEQ")

// Coloca "01" na primeira sequencia 
If Len(aCols) == 1 .And. nPosSeq > 0
	aCols[Len(aCols)][nPosSeq] := "01"
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 045 , .T. , .F. } )					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlgMain FROM	0,0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL

	@ aObjSize[1,1],aObjSize[1,2] TO aObjSize[1,3],aObjSize[1,4] OF oDlgMain PIXEL

	@ aObjSize[1,1]+10, aObjSize[1,2]+5 	SAY OemtoAnsi(STR0007) SIZE 55,7 OF oDlgMain PIXEL //"Codigo do Modelo:"
	@ aObjSize[1,1]+10, aObjSize[1,2]+63 	GET cCodSQW	VALID Rs190Ver() WHEN lInc1	SIZE 10,7 OF oDlgMain PIXEL
	@ aObjSize[1,1]+10, aObjSize[1,2]+98 	GET CDESCSQW WHEN lInc2 VALID !Empty(cDescSQW) PICTURE "@!" SIZE 100,7 OF oDlgMain PIXEL 
	@ aObjSize[1,1]+10, aObjSize[1,2]+213 	SAY OemtoAnsi(STR0008) SIZE 55,7 OF oDlgMain PIXEL //"Duracao:"
	@ aObjSize[1,1]+10, aObjSize[1,2]+243 	GET cDuraca	WHEN lInc2 VALID !Empty(cDuraca) .And. TrmHora(@cDuraca) PICTURE PesqPict("SQW","QW_DURACAO") SIZE 10,7 OF oDlgMain PIXEL
	@ aObjSize[1,1]+25, aObjSize[1,2]+5 	SAY OemtoAnsi(STR0009) SIZE 55,7 OF oDlgMain PIXEL //"Tipo Avaliacao:"
	@ aObjSize[1,1]+25, aObjSize[1,2]+63 	MsGET cRhTpAval WHEN lInc2	F3 "RJ" VALID (!Empty(cRhTpAval) .And. ExistCpo('SX5','RJ'+cRhTpAval) .And. Rs190DTipo(@cDtipo) ) SIZE 15,7 OF oDlgMain PIXEL HASBUTTON
	@ aObjSize[1,1]+25, aObjSize[1,2]+98 	MsGet cDTipo WHEN .F. PICTURE "@!" SIZE 100,7 OF oDlgMain PIXEL 

	oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"Rs190Ok","AlwaysTrue","+QW_SEQ",lTrDel,,,,300,,,,,oDlgMain)

ACTIVATE MSDIALOG oDlgMain ON INIT (EnchoiceBar(oDlgMain,{||nOpca:=1,If(Rs190TudOk(nOpcx),oDlgMain:End(),) },{|| nOpca := 2,oDlgMain:End()}))

If nOpca == 1
	If nOpcx # 5 .And. nOpcx # 2	// Se nao for Exclusao e visual
			Rs190Grava("SQW",nReg,nOpcx)    
		If __lSX8 .And. nOpcx == 3		// Inclusao
			ConfirmSX8()
		EndIf	

	ElseIf nOpcx == 5
		Begin Transaction
			Rs190Dele()
		End Transaction
	EndIf
Else
	If __lSX8 .And. nOpcx == 3
		RollBackSX8()
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bFiltraBrw)
dbGoto(nReg)

Return(Nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs190Ok   ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 28/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a linha da getdados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA190                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RS190Ok()     
Local nPosDtIni		:= GdFieldPos("QW_DTQUEDE")
Local nPosDtFim		:= GdFieldPos("QW_DTQUEAT")
Local nPosNivIni	:= GdFieldPos("QW_NIVELDE")
Local nPosNivFim	:= GdFieldPos("QW_NIVELAT")
Local lRet 			:= .T.
Local nx            := 0

If nOpcao # 5 .And. nOpcao # 2

	For nx := 1 to (Len(aHeader)-1)
		If !aCols[n,Len(aCols[n])]      // Se nao esta Deletado
			If Empty(aCols[n][nx])	.And. ;
				aHeader[nx][2] <> "QW_ALI_WT"	.And.	;
				aHeader[nx][2] <> "QW_REC_WT"
				lRet := .F.
			EndIf
		EndIf	
	Next nx   

	If !lRet
		Help("",1,"Rs190VAZIO")	  // Nao deixe nenhum campo sem preencher.
	EndIf          

	// Verifica se o Nivel inicial menor que Nivel final
	If lRet
		If 	(nPosNivIni > 0) .And. (nPosNivFim > 0) .And.;
			aCols[n][nPosNivIni] > aCols[n][nPosNivFim]
			Help(" ",1,"Rs190NIVEL")
			lRet := .F.
		EndIf	
	EndIf
	
	// Verifica se a data inicial menor que dt final
	If lRet
		If 	(nPosDtIni > 0) .And. (nPosDtFim > 0) .And.;
			aCols[n][nPosDtIni] > aCols[n][nPosDtFim]
			Help(" ",1,"Rs190DATA")
			lRet := .F.
		EndIf	
	EndIf
EndIf

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs190Grava³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 28/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao Modelo de Teste.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA190                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RS190Grava(cAlias,nReg,nOpcx)
Local cMsgErr	:= ""
Local nx		:= 0
Local ny		:= 0 
Local nItem		:= 0 
Local lTravou	:=.F.      
Local nPosRec := GdfieldPos("QW_REC_WT")

dbSelectArea(cAlias)
dbSetOrder(1)

If nOpcx == 2		// Visualizacao
	Return .T.
Else
	dbSelectArea(cAlias) 
	For nx :=1 to Len(aCols) 
	    Begin Transaction   
	        If (!(aCols[nx][Len(aCols[nx])]),nItem++,)		
			If aCols[nx][nPosRec]>0
				MsGoto(aCols[nX][nPosRec])
				RecLock(cAlias,.F.)
				lTravou:=.T.
			Else
			    If !(aCols[nx][Len(aCols[nx])])
					RecLock(cAlias,.T.)
					lTravou:=.T.
				EndIf
			EndIf
			If lTravou
				//--Verifica se esta deletado
				If aCols[nx][Len(aCols[nx])] 
					IF !(cAlias)->( FkDelete( @cMsgErr ) )
						RollBackDelTran( cMsgErr )
					EndIF
				   //	nItem--
		        Else
					Replace SQW->QW_FILIAL 	WITH xFilial(cAlias)
					Replace SQW->QW_MODELO 	WITH cCodSQW
					Replace SQW->QW_DESCRIC	WITH cDescSQW
					Replace SQW->QW_DURACAO	WITH cDuraca
					Replace SQW->QW_TIPO	WITH cRhTpAval
					Replace SQW->QW_SEQ		WITH Strzero(nItem,TamSx3("QW_SEQ")[1])
	
					For ny := 1 To Len(aHeader)
						If aHeader[ny][10] <> "V" .And. Trim(aHeader[ny][2])!= "QW_SEQ"
							SQW->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nx][ny]))
						EndIf	
					Next nY
				EndIf
				MsUnlock()
				lTravou:=.F.
			EndIf	        
		End Transaction	
	Next nx
EndIf

Return Nil
          

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs190Dele ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 28/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta todos os registros referentes ao Modelo.		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³RSPA190                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RS190Dele()
         
dbSelectArea("SQW")
If dbSeek(xFilial("SQW")+cCodSQW)
	While !Eof() .And. SQW->QW_FILIAL+SQW->QW_MODELO == ;
						 xFilial("SQW")+cCodSQW
		RecLock("SQW",.F.)
			dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
EndIf	

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs190TudOk³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 28/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no Ok da enchoicebar                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Rs190TudOk(nExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³RSPA190                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RS190TudOk(nOpcx)  
                                                         
Local nNotDel := 0 
aEval(aCols,{|x|If( !x[len(x)],nNotDel++, )})  
                       		
If nOpcx == 2
	Return .T.
ElseIf Empty(cDescSQW) .Or. Empty(cDuraca) .Or. Empty(cRhTpAval)
	Help(" ",1,"Rs190DESC")	
	Return .F.
ElseIf nOpcx == 3 .and. nNotDel == 0         // Inclusao e os itens estao deletados
	Help( "", 1, "REGNOIS" )
	Return .F.
EndIf

Return RS190Ok()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs190Desc ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 03/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Traz descricao dos Campos.					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTabela 	=	Tabela do SX5.					              ³±±
±±³			 ³cCampo 	=	Campo de Descricao.				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³RS190DESC()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA190  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Rs190Desc(cTabela,cCampo)
Local aSaveArea := GetArea()
Local cVar		:= &(ReadVar())          
Local cDesc		:= ""              
Local nPos 		:= 0
Local nPosGrupo	:= 0

nPos:= GdFieldPos(cCampo)

dbSelectArea("SX5")
dbSetOrder(1)
If dbSeek(xFilial("SX5")+cTabela+cVar)	
	cDesc:= X5DESCRI()
EndIf

If nPos > 0
	aCols[n][nPos] := cDesc
EndIf	

RestArea(aSaveArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs190DTipo³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 07/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Traz descricao do Tipo de Avaliacao.			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³RS190DTipo()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA190  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Rs190DTipo(cDTipo)

Local aSaveArea	:= GetArea()

dbSelectArea("SX5")
dbSetOrder(1)
If dbSeek(xFilial("SX5")+"RJ"+cRhTpAval)
	cDTipo := X5DESCRI()
EndIf

RestArea(aSaveArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Rs190Ver ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 09/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica Validacao do Codigo do Modelo de Testes.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs190Ver()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA190                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs190Ver()
Local aSaveArea := GetArea()
Local lRet 		:= .T.

dbSelectArea("SQW")
dbSetOrder(1)
If dbSeek(xFilial("SQW")+cCodSQW)
	Aviso(STR0010,STR0011,{"Ok"})	// "Atencao"###"Modelo ja cadastrado"
	lRet := .F.
EndIf

If lRet .And. !FreeForUse("SQW",cCodSQW)
	lRet := .F.
EndIf
          
RestArea(aSaveArea)

Return lRet               


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Rs190Sx3DesºAutor  ³Tania Bronzeri      º Data ³ 21/12/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca descricao dos campos para Get Dados                    º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGARSP                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Rs190Sx3Des(cAliasSx3,cCampo,cDesc,cBusca,cTab,nTam)
Local nPos			:= GdFieldPos(cCampo)
Local cRet			:= ""           
Default cAliasSx3	:= "SQW"
Default cTab		:= ""  
Default nTam		:= 20

If Len(aCols)>0 .And. Empty(aCols[Len(aCols)][nPos])
	cRet	:= CriaVar(cDesc,.F.)
Else
	cRet	:= FDesc(cBusca,cTab+&((cAliasSx3)->(cCampo)),cDesc,nTam)
EndIf

Return cRet

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³15/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA190                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

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
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//³    6 - Alteracao sem inclusao de registro                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=  { 	{ STR0001	,"PesqBrw",  0 , 1,,.F.},;	//"Pesquisar"
						{ STR0002	,"RSP190Rot", 0 , 2},;	//"Visualizar"
						{ STR0003	,"RSP190Rot", 0 , 3},;	//"Incluir"
						{ STR0004	,"RSP190Rot", 0 , 4},;	//"Alterar"
						{ STR0005	,"RSP190Rot", 0 , 5} }	//"Excluir"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs190DSX5 ³ Autor ³ Alexandre Conselvan   ³ Data ³ 05/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a descrição do Sx5 conforme Linguagem em uso      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs190DSX5(parametro1,parametro2,parametro3)                ³±±
±±³          ³    Parametro1 - Tabela a ser pesquisada no SX5             ³±±
±±³          ³    Parametro2 - Campo de Origem do codigo a ser pesquisado ³±±
±±³          ³    Parametro3 - Campo de Destino do conteudo do SX5        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA190 e TRMA090 - No campo de Relação dos campos         ³±±
±±³          ³ QW_DAREA, QW_DTIPO, QW_DTOPICO, QW_DNIVDE, QW_DNIVAT e     ³±±
±±³          ³ RAA_DESC   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs190DSX5(cTabela,cCpoOrig,cCpoDest)
Local aSaveArea := GetArea()
Local cVar		:= ""
Local nPos		:= 0
Local cDesc		:= ""         
Local nPos 		:= 0
Local nPosGrupo	:= 0

If cCpoOrig == "SQW->QW_NIVELAT"
	cCpoOrig := "SQW->QW_NIVELAT"
Endif

cVar:= &(cCpoOrig)
If Type("aHeader") <> "U" .and. Type("n") <> "U" .and. ( altera .or. inclui )
	If (nPos := GdFieldPos(SubStr(cCpoOrig,6))) > 0
		cVar := aCols[Len(aCols),nPos]
	EndIf
EndIf

cDesc := FDesc("SX5",cTabela+cVar,"X5_DESCRI") 
Return (cDesc)
