#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFA001.CH"
/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ TCFA001  ³ Autor ³ Cristina Ogura        ³ Data ³25/09/1997³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³ Define os campos do SRA a serem consultados e alterados 	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ Generico                                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Cecilia Car.³24/07/14³TQEA22³Incluido o fonte da 11 para a 12 e efetua-³ 
³            ³        ³      ³da a limpeza.                             ³ 
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function TCFA001()

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->( GetArea() )
Local nCont 	:= 0.00

Private aDicioT := {}
Private aDicioW := {}

SX3->( dbSetOrder(1) )
IF SX3->( dbSeek("SRA") )
	While SX3->( !Eof() .And. SX3->X3_ARQUIVO == 'SRA' )
    	IF 	SX3->X3_CONTEXT # 'V'
    		nCont := nCont + 1
	        SX3->( aAdd(aDicioT,OemToAnsi(X3Titulo())+Space(14)+CHR(179)+"["+IF(X3USO(X3_USADO),"X"," ")+"]"+SPACE(01)+CHR(179)+"["+If (X3USO(x3_usado),"X"," ")+"]"+Space(5)+SX3->X3_CAMPO+Space(3)+StrZero(X3_TAMANHO,3)+StrZero(X3_DECIMAL,2)+StrZero(nCont,3)) )
    	EndIF
	    SX3->( dbSkip() )
	End While
EndIF	

RestArea( aAreaSX3 )

Tc001Conf() //Funcao Para atualizar a configuracao da permissao de consulta
Tc001Dic() //Funcao para selecionar os campos permitidos para consulta/alteracao

RestArea( aArea )
	
Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Tc001Dic() 	  ³Autor³CrisTina Ogura     (V.1)³Data³30/09/1996³
³          ³              ³Autor³Marinaldo de Jesus (V.2)³Data³05/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Escolha dos campos no SX3 para permitir consulta/alteracao	 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³Tc001Dic()													 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Void>														 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TCFA001                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Tc001Dic()

Local aKeys		:= GetKeys()
Local aDicBkp	:= aClone( aDicioT )
Local cFile		:= If( SuperGetMv("MV_TCFFIL",,.F.), "GRHPER" + cEmpAnt + cFilAnt + ".FCH", "GRHPER" + cEmpAnt + ".FCH" )
Local cBuffer	:= ""
Local cDet		:= ""
Local cTitulo	:= ""
Local cGo		:= Space(03)
Local nOpt		:= 0.00
Local nHdl 		:= 0.00
Local nPos		:= 1.00
Local nX		:= 0.00
Local nCont		:= 0.00
Local nElem		:= Len( aDicioT )
Local oOK		:= LoadBitmap( GetResources(), "Enable" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oUso
Local oDlg
Local oFont
Local oGroup
Local oMkCInd
Local oMkCAll 
Local oMkAInd
Local oMkAAll
Local oUp
Local oDown
Local oGo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Local aAdv21Size	:= {}
Local aInfo21AdvSize:= {}
Local aObj21Size	:= {}
Local aObj21Coords	:= {}

Local aAdv22Size	:= {}
Local aInfo22AdvSize:= {}
Local aObj22Size	:= {}
Local aObj22Coords	:= {}

Local aAdv23Size	:= {}
Local aInfo23AdvSize:= {}
Local aObj23Size	:= {}
Local aObj23Coords	:= {}

Local bF4			:= { || CheckMark( oUso , @aDicioW , 1 , .F. ) }
Local bF5			:= { || CheckMark( oUso , @aDicioW , 1 , .T. ) }
Local bF6			:= { || CheckMark( oUso , @aDicioW , 2 , .F. ) }
Local bF7			:= { || CheckMark( oUso , @aDicioW , 2 , .T. ) }

Local oBtn1, oBtn2, oBtn3, oBtn4, oBtn5, oBtn6, oBtn7



aDicioW := {}

For nX := 1 To nElem
	aAdd(	aDicioW	,{	IF(Subs(aDicioT[nX],29,1) == "X",.T.,.F.),;
                    	IF(Subs(aDicioT[nX],34,1) == "X",.T.,.F.),;
                    	Subs(aDicioT[nX],59,3),;
				  		Subs(aDicioT[nX],1,12),;
                    	Subs(aDicioT[nX],41,18);
                     };
	         )
Next nX                      
             
cTitulo := OemToAnsi( STR0001 ) //"Dicion rio Consulta/Altera‡ao"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T. } )		//1-ListBox
aAdd( aObjCoords , { 000 , 040 , .T. , .F. } )				//2-Rodape
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

//Divisao da linha 2 em 3 colunas- Groups
aAdv2Size		:= aClone(aObjSize[2])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 1 , 5 }					 
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )			//1-Marcar-Desmarcar
aAdd( aObj2Coords , { 070 , 000 , .F. , .T. } )			//2-Alt. Ordem
aAdd( aObj2Coords , { 105 , 000 , .F. , .T. } )			//3-Inverter Ordem
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

//Divisao da coluna 1-Marcar-Desmarcar em 6 colunas
aAdv21Size		:= aClone(aObj2Size[1])
aInfo21AdvSize	:= { aAdv21Size[2] , aAdv21Size[1] , aAdv21Size[4] , aAdv21Size[3] , 1 , 11 }					 
aAdd( aObj21Coords , { 000 , 000 , .T. , .T. } )			//1-Espaco
aAdd( aObj21Coords , { 042 , 000 , .F. , .T. } )			//2-F4		
aAdd( aObj21Coords , { 042 , 000 , .F. , .T. } )			//3-F5		
aAdd( aObj21Coords , { 042 , 000 , .F. , .T. } )			//4-F6		
aAdd( aObj21Coords , { 042 , 000 , .F. , .T. } )			//5-F7		
aAdd( aObj21Coords , { 000 , 000 , .T. , .T. } )			//6-Espaco
aObj21Size		:= MsObjSize( aInfo21AdvSize , aObj21Coords,,.T. )

//Divisao da coluna 2-Alt. Ordem em 4 colunas
aAdv22Size		:= aClone(aObj2Size[2])
aInfo22AdvSize	:= { aAdv22Size[2] , aAdv22Size[1] , aAdv22Size[4] , aAdv22Size[3] , 2 , 11 }					 
aAdd( aObj22Coords , { 000 , 000 , .T. , .T. } )			//1-Espaco
aAdd( aObj22Coords , { 020 , 000 , .F. , .T. } )			//2-GET		
aAdd( aObj22Coords , { 043 , 000 , .F. , .T. } )			//3-Alterar
aAdd( aObj22Coords , { 000 , 000 , .T. , .T. } )			//4-Espaco
aObj22Size		:= MsObjSize( aInfo22AdvSize , aObj22Coords,,.T. )

//Divisao da coluna 3-Inverter Ordem em 4 colunas
aAdv23Size		:= aClone(aObj2Size[3])
aInfo23AdvSize	:= { aAdv23Size[2] , aAdv23Size[1] , aAdv23Size[4] , aAdv23Size[3] , 1 , 11 }					 
aAdd( aObj23Coords , { 000 , 000 , .T. , .T. } )			//1-Espaco
aAdd( aObj23Coords , { 050 , 000 , .F. , .T. } )			//2-Inverter Acima
aAdd( aObj23Coords , { 050 , 000 , .F. , .T. } )			//3-Inverter Abaixo
aAdd( aObj23Coords , { 000 , 000 , .T. , .T. } )			//4-Espaco
aObj23Size		:= MsObjSize( aInfo23AdvSize , aObj23Coords,,.T. )
                                                                  
SetaPilha()
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE cTitulo From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5]  OF oMainWnd PIXEL

	@ aObjSize[1,1],aObjSize[1,2] LISTBOX oUso FIELDS HEADER STR0002 , STR0003 , STR0004 , STR0005  SIZE aObjSize[1,3],aObjSize[1,4] PIXEL //"Consultar"###"Alterar"###"Ordem"###"Campos" 

	oUso:SetArray(aDicioW)
	oUso:bLine := { || { IF(aDicioW[oUso:nAt,1],oOk,oNo),IF(aDicioW[oUso:nAt,2],oOk,oNo),aDicioW[oUso:nAt,3],aDicioW[oUso:nAt,4]}}

	@ aObj2Size[1,1],aObj2Size[1,2] GROUP oGroup TO aObj2Size[1,3],aObj2Size[1,4] LABEL OemToAnsi( STR0006 )			OF oDlg PIXEL	//"Marcar/Desmarcar"
	oGroup:oFont:=oFont
	@ aObj2Size[2,1],aObj2Size[2,2] GROUP oGroup TO aObj2Size[2,3],aObj2Size[2,4] LABEL OemToAnsi( STR0007 )			OF oDlg PIXEL	//"Alterar Ordem"
	oGroup:oFont:=oFont                          	
	@ aObj2Size[3,1],aObj2Size[3,2] GROUP oGroup TO aObj2Size[3,3],aObj2Size[3,4] LABEL OemToAnsi( STR0008 )			OF oDlg PIXEL	//"Inverter Ordem"
	oGroup:oFont:=oFont

	oBtn1:= TBrowseButton():New( aObj21Size[2,1],aObj21Size[2,2], OemToAnsi(STR0009),oDlg, bF4,42,12,,,.F.,.T.,.F.,,.F.,,,)			//"Con.Ind <F4>"			         
	oBtn2:= TBrowseButton():New( aObj21Size[3,1],aObj21Size[3,2], OemToAnsi(STR0010),oDlg, bF5,42,12,,,.F.,.T.,.F.,,.F.,,,)			//"Con.Tod <F5>"			         
	oBtn3:= TBrowseButton():New( aObj21Size[4,1],aObj21Size[4,2], OemToAnsi(STR0011),oDlg, bF6,42,12,,,.F.,.T.,.F.,,.F.,,,)			//"Alt.Ind <F6>"			         
	oBtn4:= TBrowseButton():New( aObj21Size[5,1],aObj21Size[5,2], OemToAnsi(STR0012),oDlg, bF7,42,12,,,.F.,.T.,.F.,,.F.,,,)			//"Alt.Tod <F7>"			         

	SetKey(VK_F4,bF4 )
	SetKey(VK_F5,bF5 )
	SetKey(VK_F6,bF6 )
	SetKey(VK_F7,bF7 )
     
	@ aObj22Size[2,1]+1,aObj22Size[2,2] GET cGo SIZE 15,07	OF oDlg	PIXEL FONT oFont
	oBtn5:= TBrowseButton():New( aObj22Size[3,1],aObj22Size[3,2], OemToAnsi(STR0003),oDlg, {||TC001Move(3,oUso:nAt,@oUso,@aDicioW,@cGo)},42,12,,,.F.,.T.,.F.,,.F.,,,)			//"Alterar"			         

	oBtn6:= TBrowseButton():New( aObj23Size[2,1],aObj23Size[2,2], OemToAnsi(STR0013),oDlg, {||TC001Move(1,oUso:nAt,@oUso,@aDicioW)},50,12,,,.F.,.T.,.F.,,.F.,,,)			//"Inverter Acima"
	oBtn7:= TBrowseButton():New( aObj23Size[3,1],aObj23Size[3,2], OemToAnsi(STR0014),oDlg, {||TC001Move(2,oUso:nAt,@oUso,@aDicioW)},50,12,,,.F.,.T.,.F.,,.F.,,,)			//"Inverter Abaixo"				         
	
ACTIVATE DIALOG oDlg ON INIT EnchoiceBar( oDlg , { || nOpt:=1 , RestKeys(aKeys,.T.), oDlg:End() },{ || nOpt:=0, RestKeys(aKeys,.T.),oDlg:End() } ) CENTERED
SetaPilha()

SetKey( VK_F4 ,{ || NIL } )
SetKey( VK_F5 ,{ || NIL } )
SetKey( VK_F6 ,{ || NIL } )
SetKey( VK_F7 ,{ || NIL } )

//--volta o Array da tela para o aDicioT para ser gravado
IF nOpt == 1
	aDicioT := {}
	aEval(aDicioW,{|x|Aadd(aDicioT,Subst(x[3],1,3)+Subs(x[4],1,12)+Space(14)+CHR(179)+"["+If (x[1],"X"," ")+"]"+Space(01)+CHR(179)+"["+If (x[2],"X"," ")+"]"+Space(5)+x[5] )})
EndIF

DeleteObject(oOk)
DeleteObject(oNo)

//--Quando confirma grava o Arquivo 
IF nOpt == 1
   nHdl := MsFCreate(cFile)
   IF nHdl == -1
      Help(" ",1,"SAVECONS")
   Else
      For nX := 1 To nElem
          cDet := aDiciot[nX] + Chr(13)+Chr(10)
          fWrite(nHdl,cDet,Len(cDet))
       Next nX
   EndIF
Else
    aDicioT := aClone( aDicBkp )
EndIF

fClose(nHdl)

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Tc001Conf ³ Autor ³ Cristina Ogura        ³ Data ³31/05/1996³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Verifica se existe o arquivo e configura o array do SX3    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ TCFA001                                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Tc001Conf()

Local aDicFch	:= {}
Local cFile		:= If( SuperGetMv("MV_TCFFIL",, .F., )== .T., "GRHPER" + cEmpAnt + cFilAnt + ".FCH", "GRHPER" + cEmpAnt + ".FCH")
Local cBuffer	:= ""
Local nX		:= 0.00
Local nTamArq	:= 0.00
Local nFor		:= 0.00
Local nHdl		:= 0.00
Local nElem		:= 0.00
Local nPos		:= 0.00

IF File(cFile)
	nHdl := Fopen(cfile,64)
	fSeek(nHdl,0,0)
	nTamArq := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nFor := nTamArq / 63
	For nX := 1 To nFor
		cBuffer := Space(63)
		fRead(nHdl,@cBuffer,63)
		aAdd(aDicFch,cBuffer)
	Next nX                              	
	nElem := Len(aDicioT)	
	For nX:= 1 To nElem
		IF ( nPos := aScan(aDicFch,{ |x| Subs(x,44,10)=Subs(aDicioT[nX],41,10)}) ) > 0.00
			aDicioT[nX] :=	Subs(ADicioT[nX],1,28)		+;
							Subs(aDicFch[nPos],32,1)	+;
							Subs(aDicioT[nX],30,4)		+;
							Subs(aDicFch[nPos],37,1)	+;
							Subs(aDicioT[nX],35,24)		+;
							Subs(aDicFch[nPos],1,3)	
		EndIF
	Next nX
	fClose(nHdl)
EndIF
                                                    
aDicioT:= aSort(aDicioT,,,{|x,y| Substr(x,59,3) < Substr(y,59,3)})

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³CheckMark		 ³Autor³Marinaldo de Jesus   ³Data³05/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Marcar e Desmarcar os ChekBox para Selecao do Diocionario    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³CheckMark( oCheck , aMark , nMark , lAllMark  )				 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³oCheck   -> Objeto que Contem os CheckBox					 ³
³          ³aMark    -> Array Contendo os Elementos do oCheck			 ³
³          ³nMark    -> CheckBox a Ser Marcado 1 = Consultar; 2 = Alterar³
³          ³lAllMark ->	Se Deve Marcar/Desmarcar Todos os Checks		 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TCFA001                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function CheckMark( oCheck , aMark , nMark , lAllMark  )

Local nColPos		:= 0
Local nSize			:= Len( aMark )
Local nCount		:= 0.00

DEFAULT nMark		:= 1
DEFAULT lAllMark	:= .F.

IF nMark == 1
	nColPos := 0
ElseIF nMark == 2
	nColPos := 1
EndIF

IF oCheck:nAtCol(nColPos) > 2.00
	oCheck:nColPos := 1
EndIF

nColPos := oCheck:nAtCol(nColPos)

IF lAllMark
	While ++nCount <= nSize
		IF nColPos > 0.00 .and. nColPos <= 2.00
			aMark[nCount,nColPos] := !aMark[nCount,nColPos]
		EndIF	
	End While
Else
	IF nColPos > 0.00 .and. nColPos <= 2.00
		aMark[oCheck:nAt,nColPos] := !aMark[oCheck:nAt,nColPos]
	EndIF	
EndIF	

oCheck:Refresh()

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Tc001Move 	  ³Autor³CrisTina Ogura     (V.1)³Data³          ³
³          ³              ³Autor³Marinaldo de Jesus (V.2)³Data³05/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Reordenar os Elementos do Dicionario						 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³CheckMark( oCheck , aMark , nMark , lAllMark  )				 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³nQual    -> Tipo de Reordenacao			                	 ³
³          ³nEstou   -> Linha do ListBox oLbx:nAt						 ³
³          ³oLbx     -> Objeto ListBox									 ³
³          ³aLbx     ->	Array com os Elementos do ListBox       		 ³
³          ³cGo      ->	Va para a Posicao								 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³TCFA001                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Tc001Move( nQual , nEstou , oLbx , aLbx , cGo )

Local aAux 		:= {}            
Local nPos		:= 0.00
Local nCount	:= 0.00
Local nElem   	:= Len( aLbx )

IF nQual == 1		//Inverter Acima
	IF nEstou # 1
		aAux 						:= aClone( aLbx[ nEstou		] )
		aLbx[ nEstou      ]			:= aClone( aLbx[ nEstou - 1 ] )
		aLbx[ nEstou - 1  ]			:= aClone( aAux )
		oLbx:nAt					:= nEstou - 1
		aLbx[ oLbx:nAt 	   , 03 ]	:= StrZero( oLbx:nAt , 03 )
		aLbx[ oLbx:nAt + 1 , 03 ]	:= StrZero( oLbx:nAt + 1 , 03 )
	EndIF
ElseIF nQual == 2	//Inverter Abaixo
	IF 	nEstou # nElem
		aAux 						:= aClone( aLbx[ nEstou ]	  )
		aLbx[ nEstou      ]			:= aClone( aLbx[ nEstou + 1 ] )
		aLbx[ nEstou + 1  ]			:= aClone( aAux )
		oLbx:nAt					:= nEstou + 1
		aLbx[ oLbx:nAt 	   , 03 ]	:= StrZero( oLbx:nAt , 03 )
		aLbx[ oLbx:nAt - 1 , 03 ]	:= StrZero( oLbx:nAt - 1 , 03 )
	EndIF
ElseIF nQual == 3	//Mover Para
	IF !Empty( cGo )
		IF Val( cGo ) > nElem
			cGo := StrZero( nElem , 3 )
		ElseIF Val( cGo ) <= 0.00 
			cGo := StrZero( 1 , 3 )
		EndIF
		IF ( nPos := aScan( aLbx ,{ |x| Val( x[3] ) == Val( cGo ) } ) ) > 0.00
			aLbx[ nEstou , 03 ] := StrZero( nPos , 03 )
			aLbx[ nPos	 , 03 ] := StrZero( nPos , 03 )
			oLbx:nAt			:= nPos
			aSort( aLbx ,,, { |x,y| x[3] < y[3] } )
			While ++nCount <= nElem
				aLbx[ nCount , 03 ] := StrZero( nCount , 03 )
			End While
		EndIF
	EndIF
EndIF

oLbx:nColPos := 1
oLbx:Refresh()
cGo := Space(03)
	
Return( .T. )
