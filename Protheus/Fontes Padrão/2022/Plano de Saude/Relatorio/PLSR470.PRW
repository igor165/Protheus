#INCLUDE "PLSR470.ch"

#include "PROTHEUS.CH"

#define nLinMax	    1430								//-- Numero maximo de Linhas
#define nColMax		2350								//-- Numero maximo de Colunas
#define nColIni		50                                  //-- Coluna Lateral (inicial) Esquerda

Static objCENFUNLGP := CENFUNLGP():New()
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё PLSR470  Ё Autor Ё HELIO  F. R. LECCHI   Ё Data Ё 06.06.03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁEvolucao das Diarias						                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PLSR470(void)                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                   Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё  MOTIVO DA ALTERACAO                   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё        Ё      Ё                                        Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSR470(aPar)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL CbCont,cabec1,cabec2,cabec3,nPos,wnrel
LOCAL tamanho	:= "M"
LOCAL cDesc1	:= OemtoAnsi(STR0001)  			 //"Impressao da Evolucao de GIH "
LOCAL cDesc2	:= OemtoAnsi(STR0002)  			 //"de acordo com a configuracao do usuario."
LOCAL cDesc3	:= " "
LOCAL aArea		:= GetArea()
LOCAL lPrinter	:= .T.
LOCAL lGerTXT   := .T.
LOCAL nTamCamp  := IIf(!IsInCallStack("PLSA092IEV"), Iif(BQV->( FieldPos("BQV_SEQIMP") ) > 0,TamSX3("BQV_SEQIMP")[1],10), Iif(BQV->( FieldPos("BQV_SEQUEN") ) > 0,TamSX3("BQV_SEQUEN")[1],3))
LOCAL cSeqImp	:= ""
LOCAL lVeiPar	:= .F.
PRIVATE nSvRecno	:= BQV->( Recno() )												//Salva posicao do BEA para Restaurar apos SetPrint()
PRIVATE aReturn 	:= { OemtoAnsi(STR0003), 1,OemtoAnsi(STR0004), 2, 2, 1, "", 1 }   //"Zebrado"###"Administracao"
PRIVATE aLinha		:= { }
PRIVATE nomeprog	:="PLSR470",nLastKey := 0
PRIVATE titulo	:= OemtoAnsi(STR0005) //"Evolucao de GIH"
PRIVATE oFont07,oFont08n, oFont08, oFont09, oFont09n,oFont10, oFont10n
PRIVATE oFont12,oFont12n,oFont15,oFont15n, oFont21n,oFont16n
PRIVATE oPrint
PRIVATE cPerg
DEFAULT aPar := {"1",.F.}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona as tabelas										 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial("BA3")+BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC)))
BD5->(DbSetOrder(1))
BD5->(MsSeek(xFilial("BD5")+BE4->(BE4_OPEUSR+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)))
BD6->(DbSetOrder(1))
BD6->(MsSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё parametros													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If aPar[1] == "1"
   cPerg := ""
Else
   cPerg := "PLR470"
Endif

lGerTXT := aPar[2] // Imprime Direto sem passar pela tela de configuracao/preview do relatorio

If aPar[1] == "2"
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se o campo de sequenci existe									Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If BQV->( FieldPos("BQV_SEQIMP") ) == 0
       Alert("Campo nao existe ( BQV_SEQIMP )!")
       Return(.F.)
   EndIf
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se o indice existe												Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   SIX->(DbSetOrder(1))
   If !SIX->(MsSeek("BQV3"))
       Alert("Nao existe o indice ( BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQIMP )!")
       Return(.F.)
   EndIf
   
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Valida perguntas...                                                      Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If !Pergunte("PLR470", .T.)
      Return
   EndIf
   
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё True vai fazer com que seja procurado somentes os procedimentos ainda nao impresso	Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   lVeiPar := .T.
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Pega a Sequencia															Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   cSeqImp := Mv_Par01
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se a sequencia exites											Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

   If !IsInCallStack("PLSA092IEV")
   		BQV->( DbSetOrder(3) )
   Else
   		BQV->( DbSetOrder(1) )
   Endif
EndIf

oFont07		:= TFont():New("Tahoma",07,07,,.F.,,,,.T.,.F.)
oFont08n	:= TFont():New("Tahoma",08,08,,.T.,,,,.T.,.F.)		//negrito
oFont08 	:= TFont():New("Tahoma",08,08,,.F.,,,,.T.,.F.)
oFont09n	:= TFont():New("Tahoma",09,09,,.T.,,,,.T.,.F.)
oFont09    	:= TFont():New("Tahoma",09,09,,.F.,,,,.T.,.F.)
oFont10n 	:= TFont():New("Tahoma",10,10,,.T.,,,,.T.,.F.)
oFont10  	:= TFont():New("Tahoma",10,10,,.F.,,,,.T.,.F.)
oFontMono10	:= TFont():New("MonoAs",10,10,,.F.,,,,.T.,.F.)
oFont12		:= TFont():New("Tahoma",12,12,,.F.,,,,.T.,.F.)		//Normal s/negrito
oFont12n	:= TFont():New("Tahoma",12,12,,.T.,,,,.T.,.F.)		//Negrito
oFont15 	:= TFont():New("Tahoma",15,15,,.F.,,,,.T.,.F.)
oFont15n	:= TFont():New("Tahoma",15,15,,.T.,,,,.T.,.F.)		//Negrito
oFont21n	:= TFont():New("Tahoma",21,21,,.T.,,,,.T.,.T.)      	//Negrito
oFont16n	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)        //Negrito

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas para Impressao do Cabecalho e Rodape    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cbcont   := 0
cabec1   := OemtoAnsi(Titulo)
cabec2   := " "
cabec3   := " "
cString  := "BEA"
aOrd     := {}

//-- Objeto para impressao grafica
oPrint := TMSPrinter():New(STR0006) //"EVOLUCAO GIH "

oPrint:SetPortrait()										//--Modo retrato
oPrint:StartPage() 										//--Inicia uma nova pagina

//-- Verifica se existe alguma impressora  configurada para Impres.Grafica ...
lPrinter	:= oPrint:IsPrinterActive()
If !lPrinter
	oPrint:Setup()
EndIf

wnrel:="PLSR470"    										//--Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.F.,tamanho,,,,,lGerTXT)

If nLastKey = 27
	Set Filter To
	Return
Endif

If lGerTXT
   SetPrintFile(wnRel)
EndIf

RptStatus({|lEnd| R470Imp(@lEnd,wnRel,cString,aPar,cSeqImp,lVeiPar)},Titulo)

If lGerTXT
   oPrint:Print()  														// Imprime Relatorio
 Else
   oPrint:Preview()  													// Visualiza impressao grafica antes de imprimir
EndIf
//-- Posiciona o ponteiro
BQV->( dbGoto( nSvRecno ) )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRestaura Area e Ordem de Entrada                              Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
RestArea( aArea)

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё R470IMP  Ё Autor Ё  HELIO  F. R. LECCHI  Ё Data Ё 03/06/03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Chamada do Relatorio                                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PLSR470                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function R470Imp(lEnd,wnRel,cString,aPar,cSeqImp,lVeiPar)

DEFAULT aPar := {"1",.F.}

Imprime(cSeqImp,lVeiPar)

Return .t.

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁfImpCabec   ╨Autor  ЁMicrosiga           ╨ Data Ё  03/06/03   ╨╠╠
╠╠лммммммммммьммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁDesenha Box                                                   ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Generico                                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function fImpCabec(li)
Local cFileLogo		:= ""
Local cDet			:= ""

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁBox Principal                                                 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:Box( 030,030,nLinMax, nColMax )

//  -- CABECALHO DA GUIA  -- //

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁCarrega e Imprime Logotipo da Empresa                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
fLogoEmp(@cFileLogo)
oPrint:Line(30,50,30,nColMax)
If File(cFilelogo)
	oPrint:SayBitmap(080,50, cFileLogo,400,090) 		//-- Tem que estar abaixo do RootPath
Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁNome da Operadora 										     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
cDet	:= ""
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BE4")+ BE4->(BE4_CODOPE)))
oPrint:say(100 ,500, BA0->BA0_NOMINT , oFont10)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁEndereco                										 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
BID->(DbSetOrder(1))
BID->(DbSeek( xFilial("BID")+BA0->(BA0_CODMUN ) )  )
oPrint:say(150 , 500 , Alltrim(BA0->BA0_END)+ space(02)+BA0->BA0_NUMEND+space(2)+AllTrim(BA0->BA0_COMPEN)+ space(02) + BA0->BA0_BAIRRO                                    , oFont08)
oPrint:say(200 , 500 , BA0->BA0_CEP + space(02) + Alltrim(BID->BID_DESCRI) + space(2)+ BA0->BA0_EST , oFont08)
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁAUTORIZACAO DE GUIA                                           Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(040, 0500,OemToAnsi(Titulo)+ OemToAnsi(STR0007)              , oFont15n) //" No : "
cDet	:= BE4->(BE4_CODOPE+"."+BE4_ANOINT+"."+BE4_MESINT+"-"+BE4_NUMINT)
oPrint:say(040 , 1650 , cDet                                             , oFont15n)
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁSenha                                                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
If ! Empty(BE4->BE4_SENHA)
   oPrint:say(100 , ( nColMax-700) ,oEmToAnsi(STR0008)+ BE4->BE4_SENHA , oFont09n) //"Senha : "
Endif
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁCodigo ANS                                                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(150 , nColMax-700    ,oEmToAnsi(STR0009)                   , oFont09n) //"Codigo ANS"
oPrint:say(150 , nColMax-500    ,BA0->BA0_SUSEP                       , oFont10n)
oPrint:line(260,nColIni,260, nColMax-050)
//  -- FIM CABECALHO DA GUIA  -- //

Return(nil)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁfDadosUsua  ╨Autor  ЁMicrosiga           ╨ Data Ё  03/06/03   ╨╠╠
╠╠лммммммммммьммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁDesenha Box                                                   ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Generico                                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function fDadosUsua(li)
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁPosiciona Usuario                                             Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
BA1->(DbSetOrder(2))
BA1->(DbSeek(xFilial("BA1")+BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG)))
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁUsuario                                                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(li, nColIni      , OemToAnsi(STR0010)  , oFont09n) //"UsuАrio    : "
oPrint:say(li, nColIni + 250 , BE4->BE4_NOMUSR    , oFont09 )
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁCodigo                                                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(li, nColIni + 1600 , OemToAnsi(STR0011)                                                           , oFont09n) //"Codigo  : "
If  BA1->BA1_CODINT == BA1->BA1_OPEORI .or. empty(BA1->BA1_MATANT)
    oPrint:say(li, nColIni + 1800 , BE4->(substr(BE4_OPEUSR,1,1)+substr(BE4_OPEUSR,2,3)+"."+BE4_CODEMP+"."+BE4_MATRIC+"."+BE4_TIPREG+"-"+BE4_DIGITO)	  , oFont09)
Else
    oPrint:say(li, nColIni + 1800 , BA1->BA1_MATANT , oFont09)
Endif
Li+= 50
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁIdentidade                                                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(li, nColIni       , OemToAnsi(STR0012) , oFont09n ) //"Identidade : "
oPrint:say(li, nColIni + 250 , BE4->BE4_IDUSR     , oFont09)
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁSexo                                                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(li, nColIni + 900 , OemToAnsi(STR0013)                , oFont09n) //"Sexo :"
oPrint:say(li, nColIni +1050 , X3COMBO("BA1_SEXO",BA1->BA1_SEXO) , oFont09)
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁData de Nascimento                                            Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(li, nColIni + 1600 , OemToAnsi(STR0014)    , oFont09n ) //"Data de Nascimento:"
oPrint:say(li, nColIni + 2000 , dtoc(BE4->BE4_DATNAS) , oFont09)
Li+= 50
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁEmpresa                                                       Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
BG9->(DbSetOrder(1))
BG9->(DbSeek( xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP) )  )
oPrint:say(li, nColIni       , OemToAnsi(STR0015)    , oFont09n) //"Empresa    : "
oPrint:say(li, nColIni + 250 ,BG9->BG9_DESCRI        , oFont09)
li += 50
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁPlano                                                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
BA3->( dbSetorder(01) )
BA3->( dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
BI3->(DbSetOrder(1))
BI3->(DbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
oPrint:say(li, nColIni        , OemToAnsi(STR0016)    , oFont09n ) //"Plano      : "
oPrint:say(li, nColIni + 250  , BI3->(BI3_CODIGO + "-"+BI3_DESCRI )      , oFont09)
li +=50
oPrint:line(li,nColIni,li, nColMax-050)
li += 20
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁCID PRINCIPAL                                                 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(li, nColIni         , OemToAnsi(STR0017)                  , oFont09n) //"CID   Principal :"
oPrint:say(li, nColIni +  300  , BE4->BE4_CID                        , oFont09 )
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁCID Secundario                                                Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(li, nColIni + 1200   , OemToAnsi(STR0018) , oFont09n) //"CID SecundАrio : "
oPrint:say(li, nColIni + 1500  , BE4->BE4_CIDSEC     , oFont09 )
Li +=50
oPrint:line(li,nColIni,li, nColMax-050)
Li += 20

Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁfDDetCabec  ╨Autor  ЁMicrosiga           ╨ Data Ё  03/06/03   ╨╠╠
╠╠лммммммммммьммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁImprime cabecalho da Guia                                     ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Generico                                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function  fDetCabec(li)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁImpressao do Cabecalho da Linha de Detalhe                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:Box(li,nColIni,Li+500, nColMax-50 )										//-- Box Detalhe AMB
Li +=10
//-- Cabecalho do Detalhe
oPrint:say(li,nColIni      ,oemToAnsi(STR0019) ,oFont09n ) //"AMB/CBHPM"
oPrint:say(li,nColIni+ 350 ,oemToAnsi(STR0020) ,oFont09n ) //"DescriГДo"
oPrint:say(li,nColIni+1600 ,oemToAnsi(STR0021) ,oFont09n ) //"Qtde"
oPrint:say(li,nColIni+1900  ,oemToAnsi(STR0029) ,oFont09n )//"Dt.Emissao"

li += 50
oPrint:line(li,nColIni,li, nColMax-050)
li += 10

Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁfImpRoda    ╨Autor  ЁMicrosiga           ╨ Data Ё  03/06/03   ╨╠╠
╠╠лммммммммммьммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁImprime rodape                                                ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Generico                                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function  fImpRoda(li,lUmAut)

Li	:= 1100
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁMedico Solicitante                                            Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
BB0->( DbSetOrder(4) )
BB0->(DbSeek(xFilial("BB0")+BE4->(BE4_ESTSOL+BE4_REGSOL+BE4_SIGLA)))
oPrint:say(li, nColIni        , OemToAnsi(STR0022) , oFont09n ) //"MИdico Solicitante : "
oPrint:say(li, nColIni + 350  , BB0->BB0_NOME  +" "+ OemToAnsi(STR0023)+ BB0->BB0_NUMCR     , oFont09)   	//-- Nome  + CRM //"CRM     : "
oPrint:say(li, nColIni+1350  , OemToAnsi(STR0024)            ,oFont09n)									//-- Observacao //"ObservaГЖes: "

li+= 50
BB8->(DbSetOrder(1))
BB8->(DbSeek(xFilial("BB8")+BE4->(BE4_CODRDA+BE4_OPERDA+ BE4_CODLOC+BE4_LOCAL )))
BAU->(DbSetOrder(1))
BAU->(DbSeek(xFilial("BAU")+BE4->(BE4_CODRDA)))

oPrint:say(li, nColIni       , OemToAnsi(STR0025)            ,oFont09n)										//-- Executante //"Executante :"
oPrint:say(li, nColIni+350   , BAU->(BAU_NOME) ,oFont08)		//-- Local Executante
li+= 50
oPrint:Say(li, nColIni+350    , BB8->(Alltrim(BB8_END)+","+BB8_NR_END+"-"+Alltrim(BB8_COMEND) ),oFont08)
oPrint:Line(li,nColIni + 1350, li,nColMax-50)
li+= 50
BID->(DbSetOrder(1))
BID->(DbSeek( xFilial("BID")+BB8->(BB8_CODMUN ) )  )
BID->(Posicione("BID",1,xFilial("BID")+BB8->BB8_CODMUN,"BID_DESCRI") )
oPrint:Say(li, nColIni +350   , alltrim(BB8->BB8_BAIRRO) + "-" +Alltrim(BID->BID_DESCRI) +"-"+ BB8->BB8_EST, oFont08)
oPrint:Line(li,nColIni + 1350, li,nColMax-50)
li += 050
oPrint:Line(li,nColIni + 1350, li,nColMax-50)
li += 080
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁEmitente                                                      Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oPrint:say(li, nColIni+ 1350 , OemToAnsi(STR0026)      , oFont08  ) //"Emitente : "
oPrint:say(li, nColIni+ 1550 , Alltrim(BE4->BE4_DESOPE), oFont08 )
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁAssinatura do Beneficiario                                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
If lUmAut //IMPRIME A FRASE DE AUTORIZACAO NEGADA PARA USUARIOS NEGADOS E ASSINATURA PARA AUTORIZADOS
	oPrint:Line(li,nColIni  , li, 700)
	oPrint:say(li, nColIni  , OemToAnsi(STR0027), oFont08 )				//-- Assinatura do Beneficiario  //"Assinatura  do BeneficiАrio "
Else
   	oPrint:say(li, nColIni  , OemToAnsi(STR0028), oFont08 )				//"AUTORIZACAO NEGADA - IMPRESSAO SOLICITADA PELO USUARIO."  //"AUTORIZACAO NEGADA - IMPRESSAO SOLICITADA PELO USUARIO."
Endif

Return()

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁfLogoEmp  ╨Autor  ЁRH - Natie          ╨ Data Ё  02/18/02   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Carrega logotipo da Empresa                                ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function fLogoEmp( cLogo,cTipo)
Local  cStartPath	:= GetSrvProfString("Startpath","")
Default cTipo 	:= "1"

//-- Logotipo da Empresa
If cTipo =="1"
	cLogo := cStartPath + "LGRL"+FWGrpCompany()+FWCodFil()+".BMP" 	// Empresa+Filial
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+FWGrpCompany()+".BMP" 				// Empresa
	endif
Else
	cLogo := cStartPath + "LogoSiga.bmp"
Endif

Return(NIL)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁImprime     ╨Autor  ЁMicrosiga           ╨ Data Ё  05/10/06   ╨╠╠
╠╠лммммммммммьммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁImprime a evolucao da GIH										╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function Imprime(cSeqImp,lVeiPar)
LOCAL nI
LOCAL nCount		:= 1
LOCAL nLinDetMax	:= 10 									//-- Numero maximo de linhas detalhe
LOCAL cSeqI         := .T.
LOCAL lConfSx8		:= .T.
LOCAL bVld			:= { || If(IsInCallStack("PLSA092IEV"),BQV->BQV_SEQUEN  == cSeqImp,BQV->BQV_SEQIMP == cSeqImp) }
LOCAL lUmAut		:= .F.
LOCAL aMatRec		:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁArea															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("BQV")
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁImpressao do Cabecalho                                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	fImpCabec()
    li := 280
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁDados do Usuario                                              |
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	fDadosUsua(@li)
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁCabecalho do Detalhe                                          |
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	fDetCabec(@li)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁSe nao for informado set order								 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cSeqImp)
   BQV->( DbSetOrder(1) )
Else
   BQV->( DbSetOrder(3) )
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁWhile de Impressao											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cChave	:= xFilial("BE4")+BE4->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT)+Iif(Empty(cSeqImp),'',cSeqImp)
If BQV->( MsSeek( cChave ) )
	While !BQV->( Eof() ) .And. cChave==BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)+Iif(Empty(cSeqImp),'',cSeqImp)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁGrava a sequencia de impressao								 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Val(cSeqImp) == 0 .And. lConfSx8 .And. Empty(BQV->BQV_SEQIMP)
		    lConfSx8 := .F.
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁConfirma a sequencia de impressao							 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			//ConfirmSX8()
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁGrava														 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty(cSeqImp)	 .And. Empty(BQV->BQV_SEQIMP)
			BQV->(RecLock("BQV",.F.) )
			BQV->BQV_SEQIMP := BQV->BQV_SEQUEN
			BQV->(MsUnLock())
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁSe nao esta autorizado nao imprime							 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	    If BQV->BQV_STATUS == '0'
	       BQV->( DbSkip() )
	       Loop
	    EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁSe tem pelo menos um autorizado								 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	    lUmAut := .T.

		//-- Linha de Detalhe
		cDet	:= PLSPICPRO(BQV->BQV_CODPAD,BQV->BQV_CODPRO)

		BD6->(dbSetOrder(6))
		If BD6->(dbSeek( xFilial("BD6") + BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO+BE4->BE4_ORIMOV+BQV->BQV_CODPAD+BQV->BQV_CODPRO ) )
			oPrint:say(li,nColIni      ,cDet                                ,oFont09n   )	//-- AMB
			oPrint:say(li,nColIni+ 350 ,BD6->BD6_DESPRO                     ,oFont09    )	//-- Descricao
			oPrint:say(li,nColIni+1600 ,Transform(BQV->BQV_QTDPRO,"@R 99") ,oFontMono10 )	//-- Qtde
			oPrint:say(li,nColIni+1900 ,DTOC(BQV->BQV_DATPRO)				,oFontMono10 )	//-- Qtde
		Else
			oPrint:say(li,nColIni      ,cDet                                ,oFont09n   )	//-- AMB
			oPrint:say(li,nColIni+ 350 ," "				                     ,oFont09    )	//-- Descricao
			oPrint:say(li,nColIni+1600 ,Transform(BQV->BQV_QTDPRO,"@R 99") ,oFontMono10 )	//-- Qtde
			oPrint:say(li,nColIni+1900  ,DTOC(BQV->BQV_DATPRO) 				,oFontMono10 )	//-- Qtde
		Endif

		If nCount == nLinDetMax
			fImpRoda(@li,lUmAut)
			oPrint:EndPage() 		// Finaliza a pagina
			nCount := 1

			fImpRoda(@li,lUmAut)
			/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			  ЁImpressao do Cabecalho                                        Ё
			  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				fImpCabec()
			    li := 280
			/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			  ЁDados do Usuario                                              |
			  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				fDadosUsua(@li)
			/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			  ЁCabecalho do Detalhe                                          |
			  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				fDetCabec(@li)
		else
			li	+= 40
			nCount	++
		Endif

		BQV->( DbSkip() )
		If !Empty(cSeqImp)
			Exit
		EndIf	
	Enddo
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se nao usou o numero sx8 aborta								 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lConfSx8
   BQV->(RollBackSX8())
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁRodape														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
fImpRoda(@li,lUmAut)
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁImpressao do Cabecalho                                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/ 
fImpCabec()
li := 280
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁDados do Usuario                                              |
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
fDadosUsua(@li)
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁCabecalho do Detalhe                                          |
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
fDetCabec(@li)

/*
For nI := 1 To Len(aMatRec)
    BQV->( DbGoto() aMatRec[nI,1])
	BQV->(RecLock("BQV",.F.) )
	   BQV->BQV_SEQIMP := ALLTRIM(BQV->BQV_SEQIMP) + STR(1)
	BQV->(MsUnLock())
Next
*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da Rotina												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return