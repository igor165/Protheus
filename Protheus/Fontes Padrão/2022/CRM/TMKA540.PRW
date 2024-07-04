#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA540.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA540   ºAutor  ³Vendas CRM          º Data ³  18/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro de itens das habilidades dos operadores com opcao  º±±
±±º          ³de selecionar o peso de cada item                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA540                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA540()

Private aRotina := MenuDef()
Private cCadastro := STR0001 //"Itens das habilidades dos operadores"

dbSelectArea("AGM")
dbSetOrder(1)

mBrowse(,,,,"AGM")

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³ Vendas CRM            ³ Data ³19/11/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := {	{STR0002,"AxPesqui"	,0,1} ,;		//"Pesquisar"
		            {STR0003,"AxVisual"	,0,2} ,;		//"Visualizar"
		            {STR0004,"Tk540Inc"	,0,3} ,;		//"Incluir"
		            {STR0005,"AxAltera"	,0,4} ,;		//"Alterar"
		            {STR0006,"AxDeleta"	,0,5} ,;		//"Excluir"
		            {STR0007,"TK540Peso",0,4}}		//"Peso"
Return aRotina  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk540Inc  ºAutor  ³Vendas CRM          º Data ³  19/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de inclusao do item da habilidade, adequada para     º±±
±±º          ³atribuir um peso inicial a cada novo registro.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk540Inc(cAlias, nReg, nOpc)

AxInclui(cAlias,nReg,nOpc,/*aAcho*/,/*cFunc**/,/*aCpos*/,/*cTudoOk*/,/*lF3*/,"Tk540InPes()")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk540InPesºAutor  ³Vendas CRM          º Data ³  19/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa o peso de um item de habilidade recem incluido   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA540                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk540InPes()

Local aArea     := GetArea()       // Salva a área atual antes de iniciar esse processo.
Local aAreaAGM	:= AGM->(GetArea())
Local cPeso		:= ""

DbSelectArea("AGM")
DbSetOrder(2)

AGM->(DbGoBottom())

If AGM->(Eof()) .OR. Empty(AGM->AGM_PESO)
	cPeso := StrZero(1,TamSX3('AGM_PESO')[1],0)
Else
	cPeso := StrZero(Val(AGM->AGM_PESO)*2,TamSX3('AGM_PESO')[1],0)
EndIf
       
RestArea(aAreaAGM)

lRec := RecLock("AGM",.F.)
AGM->AGM_PESO := cPeso
MsUnLock()

RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TK540Peso | Autor ³ Vendas CRM                    ³ Data ³21.01.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao na prioridade (peso) do tipo de habilidade               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMKA540                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TK540Peso(cAlias, nOpc, nRec)  

Local aArea             := getArea()        // Salva a área atual antes de iniciar esse processo.
Local nOpcA             := 0                // Opcao escolhida no fechamento da janela
Local oDlg                                  // Janela
Local aCpoEnch  	    := NIL              // Campos da enchoice
Local aAlterEnch	    := NIL              // Campos alteraveis da echoice
Local cTudoOk           := .T.              // Validacao do fechamento da janela
Local aAlter      	 	:= NIL              // Array de campos alteraveis da getdados
Local cLinOk    		:= "AllwaysTrue"    // Funcao executada para Validar o contexto da linha atual do aCols
Local cTudoOkGet   		:= "AllwaysTrue"    // Funcao executada para Validar o contexto geral da MsNewGetDados ( todo aCols )
Local cIniCpos  	   	:= ""
Local nFreeze      		:= 000
Local nMax         		:= 999
Local cFieldOk  		:= "AllwaysTrue"    // Funcao executada na Validacao do campo
Local cSuperDel     	:= NIL
Local cDelOk    		:= "AllwaysTrue"   	// Funcao executada para Validar a exclusao de uma linha do aCols
Local aSize             := {}              // Definicao do tamanho da janela
Local aObjects          := {}              // Definicao do tamanho da janela
Local aInfo             := {}              // Definicao do tamanho da janela
Local nI                := 0               // Auxiliar do laco
Local nOpcAux           := nOpc            // Auxiliar nOpc
Local oUp               := LoadBitmap( GetResources(), "TriUp" ) //Imagem da seta para cima
Local oDown             := LoadBitmap( GetResources(), "TriDown" )//Imagem da seta para baixo

Local oGet
Local aHeader         := {}
Local aCols           := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando inclusao mudar para alteracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3)
   nOpc := 4 
   INCLUI := .F.
EndIf

aAdd( aHeader, { '', 'UP'  , '@BMP', 2, 0,,, 'C',, 'V' ,  , } )
aAdd( aHeader, { '', 'DOWN', '@BMP', 2, 0,,, 'C',, 'V' ,  , } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega aHeader³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
DbSetOrder(2)
DbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == cAlias
	If (X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL) .Or. AllTrim(SX3->X3_CAMPO) == "AGM_PESO"
		aAdd(aHeader,{ TRIM(X3Titulo()) ,;
		                SX3->X3_CAMPO        ,;
		                SX3->X3_PICTURE      ,;
		                SX3->X3_TAMANHO      ,; 
		                SX3->X3_DECIMAL      ,; 
		                SX3->X3_VALID        ,;
		                SX3->X3_USADO        ,;
		                SX3->X3_TIPO         ,;
		                SX3->X3_F3           ,;
		                SX3->X3_CONTEXT      ,;
		                SX3->X3_CBOX		 ,;   
		                SX3->X3_RELACAO      })
		           
	Endif
	SX3->(dbSkip())
EndDo

DbSelectArea(cAlias)
DbSetOrder(2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAlias)->(RecCount()) > 0
   	(cAlias)->(DbGoTop()) 
   	While !(cAlias)->(Eof()) 
   		aAdd(aCols, Array(Len(aHeader)+1))
		For nI := 3 To Len(aHeader)
			If ( aHeader[nI,10] !=  "V" )   		  
				aCols[Len(aCols)][nI] := FieldGet(FieldPos(aHeader[nI,2]))
	  		Else
				aCols[Len(aCols)][nI] := CriaVar(aHeader[nI,2],.T.)
	  		Endif
      	Next nI
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Iserindo a imagem UP/Down³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols[Len(aCols)][1] := oUp
    	aCols[Len(aCols)][2] := oDown
	    aCols[Len(aCols)][Len(aHeader)+1] := .F.
      	(cAlias)->(dbSkip())
   	EndDo
Else
   	Help(" ", 1, "REGNOIS")
Endif                                                                     -

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 50, 50, .T., .T. } )
aInfo := { aSize[1], aSize[2], Round(aSize[3]/1.5,0), Round(aSize[4]/1.5,0), 5, 5 } 
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM Round(aSize[7]/1.5,0),0 TO Round(aSize[6]/1.5,0),Round(aSize[5]/1.5,0) OF oMainWnd PIXEL

    oGet  := MsNewGetDados():New( aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], if(nOpc==2 .or. nOpc==5, Nil,GD_UPDATE),cLinOk, cTudoOkGet, cIniCpos, aAlter, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oDlg, aHeader, aCols )
    oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	
    
 	oGet:oBrowse:bLDblClick := {|| Tk540Upd(@oGet)}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpcA:=1,If(cTudoOk,oDlg:End(),nOpcA:=0)},{||nOpca:=0,oDlg:End()})

If nOpcA == 1
	Begin Transaction
	 	If TK540GrP(cAlias,nOpc, @oGet)
			EvalTrigger()
			If __lSX8
				ConfirmSX8()
			Endif
		Else
		    DisarmTransaction()
		EndIf
	End Transaction
Else
	If __lSX8
		RollBackSX8()
	Endif
Endif                
If (nOpc == 3)
   nOpc := nOpcAux
EndIf
RestArea(aArea)
Return  

          
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TK540GrP  | Autor ³ Vendas CRM                    ³ Data ³21.01.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gravacao da alteracao na prioridade (peso) no tipo da regra         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMKA540                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TK540GrP(cAlias, nOpc,oGet)

Local aArea              := getArea()          // Salva a área atual antes de iniciar esse processo.
Local nI                 := 0                  // Auxiliar do laco
Local nCodPos            := aScan(oGet:aHeader,{|x| AllTrim(x[2])=="AGM_COD"})  // Posicao do campo AGM_COD
Local nPesoPos           := aScan(oGet:aHeader,{|x| AllTrim(x[2])=="AGM_PESO"}) // Posicao do campo AGM_PESO 

DbSelectArea(cAlias)
DbSetOrder(1)

For nI := 1 To Len(oGet:aCols)

	If (cAlias)->(dbSeek(xFilial(cAlias) + oGet:aCols[nI,nCodPos]))

 		RecLock(cAlias,.F.)
        (cAlias)->AGM_PESO :=  oGet:aCols[nI][nPesoPos]
    	MsUnLock()

	EndIf
	   		
Next nI
                       
RestArea(aArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Tk540Upd  | Autor ³ Vendas CRM                    ³ Data ³21.01.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera a prioridade (peso) do tipo de regra                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMKA540                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tk540Upd(oGet)

Local nPesoPos  := aScan(oGet:aHeader,{|x| AllTrim(x[2])=="AGM_PESO"}) // Posicao do campo AGM_PESO
Local nPeso     := ""    //Peso
Local nIncrem   := 0     // Incremento +1 sobe -1 desce

If oGet:oBrowse:nColPos==1 .And. oGet:nAt > 1 
	nIncrem := -1
EndIf
If oGet:oBrowse:nColPos==2 .And. oGet:nAt < Len(oGet:aCols)
	nIncrem := +1
EndIf

If nPesoPos > 0
	If nIncrem <> 0
	    nPeso :=oGet:aCols[oGet:nAt][nPesoPos]
	   	oGet:aCols[oGet:nAt][nPesoPos] := oGet:aCols[oGet:nAt + nIncrem][nPesoPos]
	    oGet:aCols[oGet:nAt+nIncrem][nPesoPos] := nPeso
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reordena aCols³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	oGet:aCols  := aSort( oGet:aCols,,, {|x,y| x[nPesoPos] < y[nPesoPos]} )
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Mantem posicao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    oGet:nAt := oGet:nAt+nIncrem
	  	
	  	oGet:oBrowse:Refresh()
	EndIf
EndIf
	
Return