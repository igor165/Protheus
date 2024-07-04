#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFA012.CH"
/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³ TCFA012  ³ Autor ³ Marinaldo de Jesus    ³ Data ³20/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Cadastrar mensagens para a empresa toda                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³ TCFA012()                                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Cecilia Car.³24/07/14³TQEA22³Incluido o fonte da 11 para a 12 e efetua-³ 
³            ³        ³      ³da a limpeza.                             ³ 
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function TCFA012()

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}	
Local aObjSize		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local cMsg			:= Space( 01 )
Local cFile			:= "TCFEMP.MSG"
Local nOk			:= 0.00
Local oFont
Local oDlg
Local oMemo

Private cCadastro := OemtoAnsi( STR0001 ) //"Mensagem Para Todos os Funcion rios da Empresa"

IF File( cFile )
	IF Empty( cMsg := MemoRead( cFile ) )
		cMsg := Space( 01 )
	EndIF
EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

   	oMemo := TMultiget():New(aObjSize[1,1],aObjSize[1,2],{|u|if(Pcount()>0,cMsg:=u,cMsg)},;
                          oDlg,aObjSize[1,3],aObjSize[1,4],oFont,,,,,.T.,,,,,,.F.,,,,.T.)
	oMemo:lWordWrap:=.T.


	bSet15	:= { || nOk:=1, If ( Tcf012ok(cMsg), oDlg:End() , nOk:=2)  }
	bSet24	:= { || oDlg:End() }
	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

//Gravando a mensagem
IF ( nOk == 1 )
		While ( !( MemoWrit( cFile , cMsg ) ) .or. ( fError() != 0.00 ) )
			//"N„o Foi Possivel Gravar o Arquivo de Mensagens: "###
			//" Tentar Novamente? "###
			//"Aviso!"
			IF !( MsgYesNo( OemToAnsi( STR0002 ) + cFile + "." + OemToAnsi( STR0003 )  , OemToAnsi( STR0004 ) ) )
				//"A nova Mensasem n„o ser  gravada. Confirma?"
				IF ( MsgYesNo( OemToAnsi( STR0005 ) , OemToAnsi( STR0004 ) ) )
					Exit
				EndIF
			EndIF
		End While
EndIF
         
Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tcf012ok ³        Autor ³ Fabio G.        															    ³ Data ³ 06.11.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação Tamanho de Mensagem      																						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TCFA012                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tcf012ok(cMsg)
local lRet	:= .T.
	If len(cMsg) > 350 
		lRet := .F. 
		MsgInfo( OemToAnsi( STR0002 ) + OemToAnsi( STR0006 )  , OemToAnsi( STR0004 ) ) 
	EndIf	 
		
Return(lRet)    


