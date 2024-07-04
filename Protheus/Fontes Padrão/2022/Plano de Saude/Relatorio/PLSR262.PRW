
#include "PROTHEUS.CH"
static objCENFUNLGP := CENFUNLGP():New() 
static lAutoSt := .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PLSR262 ³ Autor ³ Paulo Carnelossi        ³ Data ³ 29/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio do Capital Social                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSR262()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSR262(lauto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel
LOCAL tamanho	:= "M"
LOCAL titulo	:= FunDesc() //"Relatório de Capital Social"
LOCAL cDesc1	:= "Impressao do relatorio de Capital Social "
LOCAL cDesc2	:= ""
LOCAL cDesc3	:= " "

Local lPrinter	:= .T.

Local aArea		:= GetArea()
Local lOk		:= .F.
Local aSays     := {}, aButtons := {}, nOpca := 0

default lAuto := .F.

PRIVATE nomeprog	:="PLSR262"
PRIVATE nLastKey := 0
PRIVATE cPerg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos utilizados na impressao grafica                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oFont06n, oFont06 , oFont08n, oFont08 ,oFont10, oFont10n, oFont12,oFont12n
Private oFont15,oFont15n, oFont18n
Private oCourier08, oCourier08n, oCourier12, oCourier12n

Private oPrint
Private cCodRDA, cCodOpe := PLSINTPAD()
Private nRegBAU := BAU->(Recno())

lAutoSt := lAuto

//-- LGPD ----------
if !lAuto .AND. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

cString  := "BZ4"
wnrel:="PLSR262"
cPerg:="PLR261"
M->BE4_OPERDA := PLSINTPAD()   // PARA XB FUNCIONAR (BQW)

//--Altera o Set Epch para 1910
If !lAuto
	nEpoca := SET( 5,1910)
endif

oFont06n	:= TFont():New("Tahoma",06,06,,.T.,,,,.T.,.F.)		//negrito
oFont06 	:= TFont():New("Tahoma",06,06,,.F.,,,,.T.,.F.)	
oFont08n	:= TFont():New("Tahoma",08,08,,.T.,,,,.T.,.F.)		//negrito
oFont08 	:= TFont():New("Tahoma",08,08,,.F.,,,,.T.,.F.)	
oFont10 	:= TFont():New("Tahoma",10,10,,.F.,,,,.T.,.F.)		//Font padrao utilizado para impressao de detalhe
oFont10n	:= TFont():New("Tahoma",10,10,,.T.,,,,.T.,.F.)		//negrito 
oFont12		:= TFont():New("Tahoma",12,12,,.F.,,,,.T.,.F.)		//Normal s/negrito
oFont12n	:= TFont():New("Tahoma",12,12,,.T.,,,,.T.,.F.)		//Negrito
oFont15 	:= TFont():New("Tahoma",15,15,,.F.,,,,.T.,.F.)		
oFont15n	:= TFont():New("Tahoma",15,15,,.T.,,,,.T.,.F.)		//Negrito
oFont18n	:= TFont():New("Tahoma",18,18,,.T.,,,,.T.,.F.)		//Negrito

oCourier08 	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)		//Font padrao utilizado para impressao de detalhe
oCourier08n	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)		//negrito 

oCourier12 	:= TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)		//Font padrao utilizado para impressao de detalhe
oCourier12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)		//negrito 

Pergunte(cPerg,.f.)

If lAuto
	mv_par01 := "0001"
	mv_par02 := ""
	mv_par03 := ""
	mv_par04 := date()
endif

AADD(aSays,"Impressao do relatorio do Capital Social")

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

If !lAuto
	FormBatch( Titulo, aSays, aButtons,, 160 )
endif

If !lAuto .AND. nOpca == 0
   Return
EndIf   

cCodOpe := mv_par01

//-- Objeto para impressao grafica
oPrint 	:=TMSPrinter():New("RELATORIO DO CAPITAL SOCIAL ")
oPrint  :SetPortrait()										//--Modo retrato

If !lauto .AND. nLastKey = 27
	Set Filter To
	Return
Endif

If !lAuto
	RptStatus({|lEnd| R262Imp(@lEnd,wnRel,cString)},Titulo)
	oPrint:Preview()  		// Visualiza impressao grafica antes de imprimir
else
	R262Imp(.F.,wnRel,cString)
endif
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//--Retornar Set Epoch Padrao
If !lAuto
	SET(5,nEpoca)
endif
BAU->(dbGoto(nRegBAU))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R262IMP  ³ Autor ³ Paulo Carnelossi      ³ Data ³ 29/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSR262                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R262Imp(lEnd,wnRel,cString)

Local lFirst	:= .T.

Private nLinMax		:= 3050				//-- Numero maximo de Linhas
Private nColMax		:= 2350				//-- Numero maximo de Colunas
Private nColIni		:= 50               //-- Coluna Lateral (inicial) Esquerda
Private nColIniDet	:= 60               //-- Coluna Lateral (inicial) Esquerda
Private li 			:= 30 				//-- Contador de Linhas
Private nLin
Private nIncrLin      := 060
Private nPag          := 0
Private cPicMoeda     := "@E 99,999,999.99"
Private nTotDeb := nTotCred := 0

DbSelectArea("BZ4")
dbSeek(xFilial("BZ4")+mv_par02, .T.)

While BZ4->(! Eof() .And. BZ4_FILIAL + BZ4_CODIGO <= xFilial("BZ4")+mv_par03)

	cCodRDA := BZ4->BZ4_CODIGO

	If BAU->(dbSeek(xFilial("BAU")+cCodRDA))
	    
	    If lFirst
			R262Pag(@nPag)
			lFirst := .F.
   		EndIf
   		
		R262ImpDet()
		
		If nLin > (nLinMax - 250)
			oPrint:Line(nLin,0050,nLin,nColMax-50)
			nLin += nIncrLin 
			oPrint:EndPage() 		// Finaliza a pagina
			R262Pag(@nPag)
		EndIf
	EndIf
	
	BZ4->(dbSkip())

End

If ! lFirst
	nLin += nIncrLin
	Iif(!lAutoSt, oPrint:say(nLin, 0300,"*** Total Geral ***", oFont08n), '')
	Iif(!lAutoSt, oPrint:say(nLin, 1100,Transform(nTotCred, cPicMoeda), oCourier12n), '')
	Iif(!lAutoSt, oPrint:say(nLin, 1450,Transform(nTotDeb, cPicMoeda), oCourier12n), '')
	Iif(!lAutoSt, oPrint:say(nLin, 1850,Transform(nTotCred - nTotDeb, cPicMoeda), oCourier12n), '')
	Iif(!lAutoSt, oPrint:say(nLin, 2250,If(nTotCred - nTotDeb<0,"D","C"), oCourier12n), '')
	nLin += nIncrLin
	
	oPrint:EndPage() 		// Finaliza a pagina

EndIf

Return .T.	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R262IMPDET ³ Autor ³ Paulo Carnelossi    ³ Data ³ 29/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Detalhe do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSR262                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R262ImpDet()
Local nCredito := nDebito := nSaldo := 0

dbSelectArea("BZ5")
dbSeek(xFilial("BZ5")+cCodRDA+BZ4->BZ4_FICMAT)
While BZ5->(!Eof() .And. BZ5_FILIAL+BZ5_CODIGO+BZ5_FICMAT == ; 
		xFilial("BZ5")+cCodRDA+BZ4->BZ4_FICMAT)
	
	If BZ5->BZ5_DATLCT <= mv_par04
		If BZ5->BZ5_TIPLCT=="1"
			nCredito += BZ5->BZ5_VLRLCT
		Else
			nDebito+= BZ5->BZ5_VLRLCT
		EndIf
	EndIf

	BZ5->(dbSkip())

End

Iif(!lAutoSt, oPrint:say(nLin, 0050,BZ4->BZ4_FICMAT, oCourier12n), '')
Iif(!lAutoSt, oPrint:say(nLin, 0300,Alltrim(BAU->BAU_NOME), oFont08n), '')
Iif(!lAutoSt, oPrint:say(nLin, 1100,Transform(nCredito, cPicMoeda), oCourier12n), '')
Iif(!lAutoSt, oPrint:say(nLin, 1450,Transform(nDebito, cPicMoeda), oCourier12n), '')
Iif(!lAutoSt, oPrint:say(nLin, 1850,Transform(nCredito - nDebito, cPicMoeda), oCourier12n), '')
Iif(!lAutoSt, oPrint:say(nLin, 2250,If(nCredito - nDebito<0,"D","C"), oCourier12n), '')

nLin += nIncrLin

nTotDeb += nDebito
nTotCred += nCredito

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fLogoEmp  ºAutor  ³RH - Natie          º Data ³  02/18/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fLogoEmp( cLogo,cTipo)
Local  cStartPath	:= GetSrvProfString("Startpath","")
cTipo 	:= If(cTipo == NIL, "1", cTipo)

//-- Logotipo da Empresa
If cTipo =="1"
	cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" 	// Empresa+Filial
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP" 				// Empresa
	endif
Else
	cLogo := cStartPath + "LogoSiga.bmp"
Endif


Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDrawBox    ºAutor  ³Microsiga           º Data ³  03/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Desenha Box                                                   º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR262   ºAutor  ³Microsiga           º Data ³  03/26/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R262Pag(nPag)
Local cFileLogo		:= ""

oPrint	:StartPage()
nPag++ 										//--Inicia uma nova pagina
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Box Principal                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Box( 030,030,nLinMax, nColMax )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega e Imprime Logotipo da Empresa                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fLogoEmp(@cFileLogo)
If !lAutoSt
	oPrint:Line(30,50,30,nColMax)
endif

If !lAutoSt .AND. File(cFilelogo)
	oPrint:SayBitmap(080,050, cFileLogo,242,194) 		//-- Tem que estar abaixo do RootPath
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome da Operadora 										     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BA0")+cCodOpe))
Iif(!lAutoSt, oPrint:say(040,350, PadR(BA0->BA0_NOMINT,50) , oFont15n), '')

Iif(!lAutoSt, oPrint:say(150, 650,"RELATORIO DO CAPITAL SOCIAL EM "+DTOC(mv_par04), oFont15n), '')

Iif(!lAutoSt, oPrint:say(130, 2000,"Pagina: ", oFont12n), '')
Iif(!lAutoSt, oPrint:say(130, 2200,StrZero(nPag, 3), oFont12n), '')

nLin := 300

nLin+=60
Iif(!lAutoSt, oPrint:say(nLin, 0050,"MATRICULA" , oFont10n), '')
Iif(!lAutoSt, oPrint:say(nLin, 0300,"NOME", oFont10n), '')
Iif(!lAutoSt, oPrint:say(nLin, 1250,"CREDITOS", oFont10n), '')
Iif(!lAutoSt, oPrint:say(nLin, 1610,"DEBITOS", oFont10n), '')
Iif(!lAutoSt, oPrint:say(nLin, 2050,"SALDO", oFont10n), '')
Iif(!lAutoSt, oPrint:say(nLin, 2230,"D/C", oFont10n), '')
nLin += nIncrLin

Return	

