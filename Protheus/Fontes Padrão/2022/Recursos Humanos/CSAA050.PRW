#include "dbtree.ch"
#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#INCLUDE "CSAA050.CH"

/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     ³ CSAA050  ³ Autor ³ Cristina Ogura       ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o  ³ Verificar os dados dos Resultados da Pesquisa Salarial    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador³Data    ³BOPS  ³Manutencao Efetuada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C. ³07/07/14³TPZVTW³Incluido o fonte da 11 para a 12 e efetuada³±±
±±³           ³        ³      ³a limpeza.                                 ³±±
±±³Sidney O.  ³08/08/14³TQFICR³Alterada a tabela na consulta da funcao    ³±±
±±³           ³        ³      ³Cs050V0. Nao funcionava com gestao corp.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAA050                                

Local cFiltra			// Variavel para filtro
Local aIndFil:= {}		// Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		// Variavel para Filtro

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
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0003)	//"Resultado da Pesquisa Salarial"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RB1")
dbSetOrder(1)
 
cFiltra 	:= CHKRH(FunName(),"RB1","1")
bFiltraBrw 	:= {|| FilBrowse("RB1",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

dbSelectArea("RB1")
dbGotop()

mBrowse(6, 1, 22, 75, "RB1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RB1",aIndFil)

dbSelectArea("RB1")
dbSetOrder(1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs050Rot ³ Autor ³ Cristina Ogura        ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina que monta a tela com os Resultado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Rot(cExpC1,nExpN1,nExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Rot(cAlias,nReg,nOpc)
Local oDlg
Local nOpca		:= 0          
Local cNome		:= RB1->RB1_DESCRI
Local aButtons	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords		:= {}
Local aGDCoord		:= {}

Private cPesq		:= RB1->RB1_PESQ
Private aCols		:={}
Private aColsAnt 	:={}
Private aHeader	:={}
Private Continua	:=.F.

Private oGet

Pergunte("CSA050",.F.)

// Monta o aHeader da Getdados
Cs050Getdados(cPesq)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aGdCoord	:= { (aObjSize[1,1]+5), (aObjSize[1,2]+5)	, (aObjSize[1,3]-5), (aObjSize[1,4]-5) }	

DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
                                            
	@ aGdCoord[1],aGdCoord[2] GROUP oGroup0 TO aGdCoord[3],aGdCoord[4] PIXEL  
	                     
	@ aGdCoord[1]+5,aGdCoord[2]+05	SAY OemToAnsi(STR0004) PIXEL	//"Pesquisa: "
	@ aGdCoord[1]+5,aGdCoord[2]+45	MSGET cPesq		WHEN .F. SIZE 10,7	PIXEL
	@ aGdCoord[1]+5,aGdCoord[2]+75	MSGET cNome		WHEN .F. SIZE 200,7	PIXEL
	
	oGet:= MSGetDados():New(aGdCoord[1]+20,aGdCoord[2]+5,aGdCoord[3]-5,aGdCoord[4]-5,nOpc,"Cs050Ok","AlwaysTrue","",.T.,,1, ,900,,,,,oDlg)	
 	aButtons:= {;
					{"GRAF2D",{||CSA050Gra(cAlias,nReg)},OemtoAnsi(STR0038)};
                }  //"Grafico"
	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()},,aButtons)  
  
If nOpca == 1
	Begin Transaction
		Cs050GrRB5()
	End Transaction
EndIf		

dbSelectArea("RB1")

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs050Getdad³ Autor ³ Cristina Ogura       ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o aHeader e aCols do RB5                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Cs050Getdad(aFields,cPesq)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aFields: Array dos campos que nao devem sair                ³±±
±±³          ³cPesq  : Codigo da Pesquisa Salarial                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Getdados(cPesq)

Local cFuncao, cRegiao, cPorte, cTipo
Local l1Vez:= .T.
Local aV0:={}, aV1:={}, aV2:={}

dbSelectArea("RB5")
dbSetOrder(1)
If dbSeek(xFilial("RB5")+cPesq)
	cFuncao := RB5->RB5_FUNCAO
	cRegiao := RB5->RB5_REGIAO
	cPorte  := RB5->RB5_PORTE       
	cTipo	:= RB5->RB5_TIPO
	While !Eof() .And. xFilial("RB5")+cPesq ==;
						RB5->RB5_FILIAL+RB5->RB5_PESQ
	
		If 	cFuncao#RB5->RB5_FUNCAO .Or. ;
			cRegiao#RB5->RB5_REGIAO .Or. ;
			cPorte #RB5->RB5_PORTE
			If l1Vez        
				Cs050Header(aV0)	    	
		    	l1Vez:= .F.
		    EndIf  
			Cs050GeraAcols(cFuncao,cRegiao,cPorte,cTipo,aV0,aV1,aV2)
			cFuncao := RB5->RB5_FUNCAO
			cRegiao := RB5->RB5_REGIAO
			cPorte  := RB5->RB5_PORTE                   
			cTipo   := RB5->RB5_TIPO
			
			aV0:={}
			aV1:={}
			aV2:={}
		EndIf			          
		
		Aadd(aV0,RB5_CODVL)				
		Aadd(aV1,{RB5->RB5_CODVL,RB5->RB5_VALOR})			 
		Aadd(aV2,{RB5->RB5_CODVL,RB5->RB5_VLOUTROS})
	    
		dbSkip()
	EndDo
	If l1Vez        
		Cs050Header(aV0)	    	
    EndIf  
    Cs050GeraAcols(cFuncao,cRegiao,cPorte,cTipo,aV0,aV1,aV2)
Else
	cFuncao := CriaVar("RB5_FUNCAO")
	cRegiao := CriaVar("RB5_REGIAO")
	cPorte	:= CriaVar("RB5_PORTE")
	cTipo	:= CriaVar("RB5_TIPO")
	Cs050V0(@aV0,@aV1,@aV2)	                        
	Cs050Header(aV0)	    	                  
    Cs050GeraAcols(cFuncao,cRegiao,cPorte,cTipo,aV0,aV1,aV2)
EndIf

Return .T. 

/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs050Header ³ Autor ³ Cristina Ogura     ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montar o aHeader da Getdados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CS050Header(aExpA1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aVO:= Array com os valores                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Header(aV0)                    

Local aSaveArea	:= GetArea()
Local cAux		:= ""
Local aFields 	:= {"RB5_FILIAL","RB5_PESQ","RB5_CORTE","RB5_VLCORT","RB5_CODVL","RB5_VALOR","RB5_VLOUTROS"}
Local aAux		:= {}
Local nx		:= 0

aV0:= aSort(aV0,,,{|x,y| x < y})

For nx:= 1 To Len(aV0)
	dbSelectArea("SX5")
	dbSetOrder(1)
	If dbSeek(xFilial("SX5")+"RF"+aV0[nx])
		Aadd(aAux,{aV0[nx],Substr(X5Descri(),1,30)})
	EndIf	
Next nx

aHeader:={}

dbSelectArea("SX3")
dbSeek("RB5")
While !EOF() .And. (X3_ARQUIVO == "RB5")
	If x3uso(X3_USADO) .AND. cNivel >= X3_NIVEL .And. ASCAN(aFields,Trim(X3_CAMPO)) == 0
		Aadd(aHeader,{ TRIM(X3Titulo())	, X3_CAMPO	, X3_PICTURE,;
							X3_TAMANHO	, X3_DECIMAL, X3_VALID,;
							X3_USADO	, X3_TIPO	, X3_ARQUIVO, X3_CONTEXT ,"S"} )
	EndIf
	dbSkip()
EndDo

// Cria aHeader para os dados do Salario Base
cAux:= STR0005		//" (Salario Base)"
For nx:=1 To Len(aAux)                
	Aadd(aHeader,{Alltrim(aAux[nx][2])+cAux,"RB51_"+aAux[nx][1],"@E 999,999,999,999,999.99",18,2,"Cs050Ver()","û","N","RB5","V","N" } )
Next nx                                      

// Cria aHeader para os dados do Salario Base para outras Remuneracoes
cAux:= STR0006 		//" (Remuneracao Total)"
For nx:= 1 To Len(aAux)
	Aadd(aHeader,{Alltrim(aAux[nx][2])+cAux,"RB52_"+aAux[nx][1],"@E 999,999,999,999,999.99",18,2,"Cs050Ver()","û","N","RB5","V","N" } )	
Next nx                    

RestArea(aSaveArea)

Return .T.                  
                                             
/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs050GeraAcols ³ Autor ³ Cristina Ogura  ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera o acols da Getadados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CS050GeraAcols(cExpC1,cExpC2,cExpC3,cExpC4,aExpA1,aExpA2)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFuncao := Codigo da funcao                                ³±±
±±³          ³ cRegiao := Codigo da regiao                                ³±±
±±³          ³ cPorte  := Porte da Empresa                                ³±±
±±³          ³ cTipo   := Tipo de Empresa                                 ³±±
±±³          ³ aV0     := Array com os codigo dos valores                 ³±±
±±³          ³ aV1     := Array com os valores                            ³±±
±±³          ³ aV2     := Array com os valores e outros beneficios        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050GeraAcols(cFuncao,cRegiao,cPorte,cTipo,aV0,aV1,aV2)      

Local nUsado 	:= Len(aHeader)
Local nAcols 	:= 0                           
Local aSaveArea := GetArea()
Local cAux   := "" 
Local nx     := 0
Local ny     := 0

Aadd(aCols,Array(nUsado+1))
nAcols := Len(aCols)

dbSelectArea("RB5")
dbSetOrder(1)
dbSeek(xFilial("RB5")+cPesq+cFuncao+cRegiao+cPorte)

For nx:=1 To Len(aHeader)
	If 	aHeader[nx][11] == "S"
		If ( aHeader[nx][10] != "V")
			aCols[nAcols][nx] := FieldGet(FieldPos(aHeader[nx][2]))
		Else
			aCols[nAcols][nx] := CriaVar(aHeader[nx][2],.T.)
		EndIf
	Else		
		For ny:=1 To Len(aV1)		
			cAux := "RB51_"+aV1[ny][1]
			If Alltrim(aHeader[nx][2]) == Alltrim(cAux)
				aCols[nAcols][nx] := aV1[ny][2]
			EndIf
		Next ny		
		For ny:=1 To Len(aV2)		             
			cAux := "RB52_"+aV2[ny][1]
			If Alltrim(aHeader[nx][2]) == Alltrim(cAux)
				aCols[nAcols][nx] := aV2[ny][2]
			EndIf
		Next ny		
	EndIf	

Next nx

aCols[Len(aCols)][nUsado+1] := .F.

aColsAnt := aCols

RestArea(aSaveArea)

Return .T.

/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs050Desc      ³ Autor ³ Cristina Ogura  ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Traz as descricao dos campos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CS050Desc(nFlag)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - Descricao da Funcao                                    ³±±
±±³          ³ 2 - Descricao da Regiao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Desc(nFlag)

Local nPosTipo 	:= 0
Local nPosDFun 	:= 0
Local nPosDReg 	:= 0
Local aSaveArea	:= GetArea()
Local cVar		:= &(ReadVar())
Local cDescr	:= ""

If nFlag == 1 			// Descricao da Funcao
	nPosTipo := Ascan(aHeader,{|x| AllTrim(x[2])=="RB5_TIPO"})	
	nPosDFun := Ascan(aHeader,{|x| AllTrim(x[2])=="RB5_DESCFU"})
	dbSelectArea("SRJ")
	dbSetOrder(1)
	If dbSeek(xFilial("SRJ")+cVar)
		cDescr:= SRJ->RJ_DESC
	EndIf	      
	aCols[n][nPosDFun] := cDescr
	If Empty(aCols[n][nPosTipo])
		aCols[n][nPosTipo]:= "I"
	EndIf	
ElseIf nFlag == 2		// Descricao da Regiao	
	nPosDReg := Ascan(aHeader,{|x| AllTrim(x[2])=="RB5_DESCRE"})
	dbSelectArea("SX5")
	dbSetOrder(1)
	If dbSeek(xFilial("SX5")+"RC"+cVar)
		cDescr := Substr(X5Descri(),1,30)
	EndIf                        
	aCols[n][nPosDReg] := cDescr
EndIf
               
RestArea(aSaveArea)

Return .T.
                         
/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs050Ok        ³ Autor ³ Cristina Ogura  ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a linha Ok da Getdados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CS050Ok()       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Ok()

Local nPosFunc  := Ascan(aHeader,{ |x| x[2] = "RB5_FUNCAO"})
Local nPosReg   := Ascan(aHeader,{ |x| x[2] = "RB5_REGIAO"})
Local nPosPort  := Ascan(aHeader,{ |x| x[2] = "RB5_PORTE "})
Local nPosTipo  := Ascan(aHeader,{ |x| x[2] = "RB5_TIPO  "})
Local nx

If aCols[n][nPosTipo] == "G" .And. aCols[n,Len(aCols[n])]
	aCols[n,Len(aCols[n])] := .F.
	Help("",1,"CS050NDELE")
	Return .F.
EndIf	

If !aCols[n,Len(aCols[n])]
	If  aCols[n][nPosTipo] # "G"	.And.;
		(Empty(aCols[n][nPosFunc]) 	.Or.;
		Empty(aCols[n][nPosPort]))
		Help("",1,"CS050BRANCO")
		Return .F.
	EndIf	
	
	For nx:=1 To Len(aCols)
		If 	aCols[n][nPosFunc] == aCols[nx][nPosFunc]	.And.;
			aCols[n][nPosReg]  == aCols[nx][nPosReg]	.And.;
			aCols[n][nPosPort]	== aCols[nx][nPosPort]	.And.;
			n#nx	
			Help("",1,"CS050IGUAL")
			Return .F.
		EndIf	
	Next nx 
EndIf

oGet:oBrowse:Refresh(.T.)
Return .T.

/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs050GrRB5     ³ Autor ³ Cristina Ogura  ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o resultado da pesquisa quando informado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CS050GrRB5()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050GrRB5()        

Local nPosTipo	:= Ascan(aHeader,{ |x| x[2] = "RB5_TIPO  "})
Local nPosFunc	:= Ascan(aHeader,{ |x| x[2] = "RB5_FUNCAO"})
Local nPosReg		:= Ascan(aHeader,{ |x| x[2] = "RB5_REGIAO"})
Local nPosPort	:= Ascan(aHeader,{ |x| x[2] = "RB5_PORTE "})
Local nPosCodvl	:= Ascan(aHeader,{ |x| x[2] = "RB5_CODVL "})
Local nx, nQuantos              
Local nPos:=0 
Local aRB51:={}, aRB52:={}   

dbSelectArea("RB5")
dbSetOrder(1)

If !fCompArray( aCols , aColsAnt )
	For nx:=1 To Len(aCols)
		If 	aCols[nx][nPosTipo] == "I"
			If len(aColsAnt) >= nx .AND. dbSeek(xFilial("RB5")+cPesq+aColsAnt[nx][nPosFunc]+aColsAnt[nx][nPosReg]+aColsAnt[nx][nPosPort])
				While !Eof() .And. xFilial("RB5")+cPesq+aColsAnt[nx][nPosFunc]+aColsAnt[nx][nPosReg]+aColsAnt[nx][nPosPort]==;
						RB5->RB5_FILIAL+RB5->RB5_PESQ+RB5->RB5_FUNCAO+RB5->RB5_REGIAO+RB5->RB5_PORTE
	
					RecLock("RB5",.F.)
						dbDelete()
					MsUnlock()								
					dbSkip()	
				EndDo		
			EndIf
		EndIf
		
		If !aCols[nx][Len(aCols[nx])]
			aRB51:={}
			aRB52:={}
			Cs050GrArray(@aRB51,@aRB52,nx)
				
			For nQuantos:=1 To Len(aRB51)
				RecLock("RB5",.T.)
				Replace RB5_FILIAL 	WITH	xFilial("RB5")
				Replace RB5_PESQ		WITH	cPesq
				Replace RB5_FUNCAO	WITH	aCols[nx][nPosFunc]
				Replace RB5_REGIAO	WITH	aCols[nx][nPosReg]
				Replace RB5_PORTE		WITH	aCols[nx][nPosPort]
				Replace RB5_TIPO		WITH	"I"
				Replace RB5_CODVL		WITH	aRB51[nQuantos][1]
				Replace RB5_VALOR		WITH	aRB51[nQuantos][2]
			
				nPos := Ascan(aRB52,{|x| x[1] == aRB51[nQuantos][1]})
				If 	nPos > 0
					Replace RB5_VLOUTROS WITH aRB52[nPos][2]
				EndIf
			Next nQuantos
			MsUnlock()
		EndIf
	Next nx
EndIf
	
Return .T.
/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs050Ver       ³ Autor ³ Cristina Ogura  ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se posso altera os campos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CS050Ver()      											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Ver()

Local nPosTipo := Ascan(aHeader,{|x| AllTrim(x[2])=="RB5_TIPO"})

If aCols[n][nPosTipo] == "G"
	Help("",1,"Cs050NPODE")
	Return .F.
EndIf

Return .T.

/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs050VO        ³ Autor ³ Cristina Ogura  ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o array quando nao existir os Resultadso Pesquisa    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CS050VO(aExpA1,aExpA2,aExpA3)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aV0 := Array com os codigos dos valores                    ³±±
±±³          ³ aV1 := Array com os valores                                ³±±
±±³          ³ aV2 := Array com os valores e outros beneficios            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050V0(aV0,aV1,aV2)

Local aSaveArea	:= GetArea()

dbSelectArea("SX5")
dbSetOrder(1)
If dbSeek(xFilial("SX5")+"RF")
While !Eof() .And. xFilial("SX5")+"RF" ==;
						SX5->X5_FILIAL+SX5->X5_TABELA
						
		Aadd(aV0,SX5->X5_CHAVE)									
		Aadd(aV1,{SX5->X5_CHAVE,0})									
		Aadd(aV2,{SX5->X5_CHAVE,0})									
						
		dbSkip()
	EndDo					
EndIf
	
RestArea(aSaveArea)

Return

/*                                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cs050GrArray   ³ Autor ³ Cristina Ogura  ³ Data ³ 16.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta os arrays para atualizacao do arquivo RB5            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050GrArray(aRB51,aRB52,nx) 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRB51= Array com os valores                    			  ³±±
±±³          ³ aRB52= Array com os valores e outros beneficios            ³±±
±±³          ³ nx   = Posicao do acols                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050GrArray(aRB51,aRB52,nx)

Local ny
For ny:=1 To Len(aHeader)
	If 	aHeader[ny][11] == "N"
		If Substr(aHeader[ny][2],1,4) == "RB51"    
			Aadd(aRB51,{Substr(aHeader[ny][2],6,5),aCols[nx][ny]})
		ElseIf  Substr(aHeader[ny][2],1,4) == "RB52"		
			Aadd(aRB52,{Substr(aHeader[ny][2],6,5),aCols[nx][ny]})	
		EndIf	
	EndIf	
Next ny
Return .T.        

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fPesqSal  ³ Autor ³ Eduardo Ju     	    ³ Data ³ 21.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Selecionar os Valores de Pesquisa Salarial                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fPesqSal() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fPesqSal(l1Elem,lTipoRet)

Local cTitulo := ""
Local MvPar
Local MvParDef:= ""

Private aSit:={}
l1Elem := If (l1Elem = Nil , .F. , .T.)

DEFAULT lTipoRet := .T.

cAlias := Alias() 					 // Salva Alias Anterior

IF lTipoRet
	MvPar:=&(Alltrim(ReadVar()))	 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())		 // Iguala Nome da Variavel ao Nome variavel de Retorno
EndIF

aSit := {;
			"A - " + "Primeiro Decil",;	//"Normal"
			"B - " + "Nono Decil",;	//"Afastado"
			"C - " + "Primeiro Quartil",;	//"Demitido"
			"D - " + "Terceiro Quartil",;	//"Transferido"
			"E - " + "Mediana",;
			"F - " + "Media";
		}  
MvParDef:=	"ABCDEF"
cTitulo :=  OemToAnsi(STR0039) //"Valores de Pesquisa Salarial"

IF lTipoRet
	IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,l1Elem)  // Chama funcao f_Opcoes
		&MvRet := mvpar                                                                          // Devolve Resultado
	EndIF	
EndIF

dbSelectArea(cAlias) 								 // Retorna Alias

Return( IF( lTipoRet , .T. , MvParDef ) )    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CSA050Gra ³ Autor ³ Eduardo JU            ³ Data ³ 22.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina Principal do Grafico.						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSA050Gra()						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = N£mero do registro                                 ³±±
±±³          ³ ExpN2 = N£mero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CSA050Gra                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSA050Gra(cAlias,nReg)

Local oDlgSer
Local oSer
Local cCbx 		:= STR0008	//"Barras"		
Local nCbx 		:= 3		
Local aCbx 		:= {STR0009, STR0010, STR0016 }	//Pontos"#"Barras"#"Pizza"
Local cTitulo	:= STR0022	//"Comparativo - Resultado da Pesquisa Salarial x Salario"
Local cTituloX	:= STR0023	//"Resultado da Pesquisa e Media Salarial da Empresa" 
Local cTituloY	:= STR0024	//"Salario"
Local aDados	:= {}
Local aLegenda	:= {}
Local aTabela	:= {}
Local aPosCol	:= { 360, 1300, 2100 }
Local aPosGrh	:= { 360, 2100, 1300 }
Local aSays 	:= {}
Local aButtons	:= {}
Local nOpca		:= 0
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords 	:= {}
Local aObjSize		:= {}
Local bSet15
Local bSet24  

AADD(aSays,OemToAnsi(STR0030) )  //"Grafico Comparativo - Salario x Resultado da Pesquisa Salarial"
AADD(aSays,OemToAnsi(STR0023) )  //"Resultado da Pesquisa Salarial e a Media Salarial da Empresa"

AADD(aButtons, { 5,.T.,{|| Pergunte("CSA050",.T.) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}} )
AADD(aButtons, { 2,.T.,{|o| nOpca := 0,FechaBatch()}} )
	
FormBatch( cCadastro, aSays, aButtons )


If nOpca == 1
   	
   	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[3] -= 10 
	aAdvSize[4] -= 10
	aAdvSize[6] := (aAdvSize[6] / 100) * 30 
	aAdvSize[5] := (aAdvSize[5] / 100) * 55	
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
  	DEFINE MSDIALOG oDlgSer TITLE STR0025 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL OF oMainWnd //"Tipo do grafico"
  		bSet15	:= { || aLegenda:={}, aDados:={}, aTabela:= {},CSA050Ger(@aDados,@aLegenda,@aTabela),;
						TrmGraf(aDados,nCbx,cTitulo,cTituloX,cTituloY,aLegenda,aTabela,aPosCol,aPosGrh); 
					}
		bSet24	:= { || oDlgSer:End(); 
					}

		@ aObjSize[1,1]+18, (aAdvSize[5]/100)*5 SAY STR0026 PIXEL OF oDlgSer	//"Escolha o tipo de serie:"
		@ aObjSize[1,1]+18, (aAdvSize[5]/100)*23 MSCOMBOBOX oSer VAR cCbx ITEMS aCbx SIZE 077, 120 OF oDlgSer PIXEL ON CHANGE nCbx:= CSA050CBX(oSer:nAt)

	ACTIVATE MSDIALOG oDlgSer On Init Enchoicebar( oDlgSer , bSet15 , bSet24 ) CENTERED

EndIf
Return Nil  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CSA050Ger ³ Autor ³ Eduardo Ju            ³ Data ³ 23.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Dados para Grafico.							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CSA050Ger()						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 							                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CSAA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSA050Ger(aDados,aLegenda,aTabela)

Local aFaixas	:= {}
Local aPesq1	:= {} // {Eixo X, Eixo Y, Nome} 
Local cNome		:= ""
Local cLegenda	:= 0
Local nX 		:= 0
Local cCampo    := ""  
Local nPos		:= 0
Local nPosCampo := 0
Local nSalComp	:= 0
Local nSalEmp   := 0
Local nI        := 0
Local dUltDt     := Ctod("  /  /  ")
  
// Variaveis de Perguntas
Local cEmpresa	:= ""
Local cFuncao	:= ""
Local cValPesq	:= ""
Local nTipoSal	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na pergunte                                 ³
//³ mv_par01	// Empresa                                           ³
//³ mv_par02	// Funcao                                            ³
//³ mv_par03	// Valores da Pesquisa                               ³
//³ mv_par04	// Tipo de Salario            		 	             ³
//³						1- Salario Base                              ³ 
//³                     2- Remuneracao Total                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEmpresa := mv_par01
cFuncao  := mv_par02
cValPesq := mv_par03
nTipoSal := mv_par04     

For nX := 1 To 6 	
	If Substr(cValPesq,nX,1) != "*"
		cCampo:= "RB5"+Alltrim(Str(nTipoSal))+"_"+StrZero(nX,4) //Vou obter: RB51_0001 por exemplo	
		nPosCampo:= GdFieldPos(cCampo)  
		cNome := Iif(nX == 1,OemToAnsi(STR0031)," ") //"Resultado da Pesquisa",	 		
		IF nPosCampo > 0
			Aadd(aPesq1,{aHeader[nPosCampo][1],aCols[n][nPosCampo],cNome})  
			Aadd(aLegenda,aHeader[nPosCampo][1])
		ENDIF
	EndIf	
End For 		 	
		
dbSelectArea("RB2")
dbSetOrder(1)

If dbSeek(xFilial("RB2")+cEmpresa+cFuncao)
	
	cLegenda:= OemToAnsi(STR0033)//"Salario Pesquisado da Empresa"	
	cNome	:= OemToAnsi(STR0032)+cFuncao+"-"+FDESC("SRJ",cFuncao,"RJ_DESC") //"Salario Cargo: "
	
	If Alltrim(Str(nTipoSal)) == "1" //Salario Base
		nSalEmp := RB2->RB2_SALARI	
	Else
		nSalEmp := RB2->RB2_SALARI+RB2->RB2_VLBENE+RB2->RB2_ADICIO  
	EndIf 
	
	While !Eof() .And. xFilial("RB2")+cEmpresa+cFuncao == RB2->RB2_FILIAL+RB2->RB2_EMPRES+RB2->RB2_FUNCAO
		dUltDt 	:= RB2->RB2_DTBASE
		nSalComp:= RB2->RB2_SALARI+RB2->RB2_VLBENE+RB2->RB2_ADICIO
		If( nPos := aScan(aFaixas, {|x| x[1] == dUltDt .and. x[2] == nSalComp }) ) == 0.00
            aAdd(aFaixas, {dUltDt, nSalComp} )
			If Alltrim(Str(nTipoSal)) == "1" //Salario Base
				nSalEmp := RB2->RB2_SALARI	
			Else
				nSalEmp := RB2->RB2_SALARI+RB2->RB2_VLBENE+RB2->RB2_ADICIO  
			EndIf 
			aAdd(aPesq1,{cLegenda,nSalEmp,cNome}) //Utilizado a mesma Descricao da Legenda para exibir no Relatorio
		EndIf		
		dbSkip()
	EndDo
EndIf
				
Aadd(aLegenda,cLegenda)

Aadd(aDados,aPesq1) 

Aadd(aTabela,{OemToAnsi(STR0034) + cEmpresa + " - " + FDESC("RB0",cEmpresa,"RB0_NOME"),;
              OemToAnsi(STR0035) + cFuncao + " - " + FDESC("SRJ",cFuncao,"RJ_DESC")}) //"Empresa: " # "Cargo Pesquisado: " 
Aadd(aTabela,{" "," "})              
Aadd(aTabela,{OemToAnsi(STR0036),OemToAnsi(STR0037)})              
Aadd(aTabela,{" "," "})  

For nI:=1 To Len(aPesq1) 
	Aadd(aTabela,{aPesq1[nI][1],Transform(aPesq1[nI][2],"@E 999,999,999.99")})	
End For   

Return Nil  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³CSA050CBX ³ Autor ³ Eduardo Ju     	    ³ Data ³ 06.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Selecionar os Valores de Pesquisa Salarial                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³CSA050CBX() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³CSAA050    												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CSA050CBX(nCbx)    	
      
Local nTipo := 0
If nCbx == 1	
	nTipo := 3	//Grafico do Tipo Pontos
ElseIf nCbx == 2
	nTipo := 4	//Grafico do Tipo Barras
ElseIf nCbx == 3
	nTipo := 10	//Grafico do Tipo Pizza	 
End	
 
Return nTipo   


/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³28/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAA050                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()

 Local aRotina := { 	{ STR0001, 'PesqBrw', 0, 1,,.F.}, ;	//'Pesquisar'
						{ STR0002, 'Cs050Rot', 0, 4}}	//'Resultado Pesq'

Return aRotina
