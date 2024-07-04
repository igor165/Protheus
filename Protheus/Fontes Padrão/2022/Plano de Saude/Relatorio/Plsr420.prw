#include "PLSR420.CH"
#include "PROTHEUS.CH"   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSR420  ³ Autor ³ Natie Sugahara        ³ Data ³ 06.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Guia de Internacao Hospitalar                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSR420(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sandro H.    ³31/05/06³99495 ³ Permitir impressao de guias negadas    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSR420()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL CbCont,cabec1,cabec2,cabec3,nPos,wnrel
LOCAL tamanho	:= "M"
LOCAL titulo	:= OemtoAnsi(STR0001)  			//"GUIA DE INTERNACAO HOSPITALAR"
LOCAL cDesc1	:= OemtoAnsi(STR0002)  			//"Ira imprimir a Guia mentos do Credenciado"
LOCAL cDesc2	:= OemtoAnsi(STR0003)  			//"de acordo com a configuracao do usuario."
LOCAL cDesc3	:= " "               			//"de acordo com a configuracao do usuario."
Local lPrinter	:= .T.
//Local aArea		:= GetArea()

PRIVATE nSvRecno	:= BE4->( Recno() )												//Salva posicao do BE4 para Restaurar apos SetPrint()
PRIVATE aReturn 	:= { OemtoAnsi(STR0004), 1,OemtoAnsi(STR0005), 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
PRIVATE aLinha		:= { }
PRIVATE nomeprog	:="PLSR420",nLastKey := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos utilizados na impressao grafica                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oFont07,oFont08n, oFont08 ,oFont10, oFont10n, oFont12,oFont12n
Private oFont15,oFont15n, oFont21n,oFont16n, oFont09, oFont09n
Private oPrint

If ! (BE4->BE4_STATUS $ "1,2,3,4") // Alteracao para que Usuario NAO AUTORIZADO (3) tambem imprima - BOPS 99495
   Help("",1,"PLSR420")
   Return
Endif   

oFont07		:= TFont():New("Tahoma",07,07,,.F.,,,,.T.,.F.)
oFont08n	:= TFont():New("Tahoma",08,08,,.T.,,,,.T.,.F.)		//negrito
oFont08 	:= TFont():New("Tahoma",08,08,,.F.,,,,.T.,.F.)	
oFont09		:= TFont():New("Tahoma",09,09,,.F.,,,,.T.,.F.)                
oFont09n	:= TFont():New("Tahoma",09,09,,.T.,,,,.T.,.F.)                
oFont10 	:= TFont():New("Tahoma",10,10,,.F.,,,,.T.,.F.)		//Font padrao utilizado para impressao de detalhe
oFont10n	:= TFont():New("Tahoma",10,10,,.T.,,,,.T.,.F.)		//negrito 
oFont12		:= TFont():New("Tahoma",12,12,,.F.,,,,.T.,.F.)		//Normal s/negrito
oFont12n	:= TFont():New("Tahoma",12,12,,.T.,,,,.T.,.F.)		//Negrito
oFont15 	:= TFont():New("Tahoma",15,15,,.F.,,,,.T.,.F.)		
oFont15n	:= TFont():New("Tahoma",15,15,,.T.,,,,.T.,.F.)		//Negrito
oFont21n	:= TFont():New("Tahoma",21,21,,.T.,,,,.T.,.T.)      	//Negrito
oFont16n	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)        //Negrito


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbcont   := 0
cabec1   := OemtoAnsi(STR0001)  										//--"GUIA DE INTERNACAO HOSPITALAR"
cabec2   := " "
cabec3   := " "
cString  := "BE4"
aOrd     := {}
wnrel:="PLSR420"           											//--Nome Default do relatorio em Disco

//-- Objeto para impressao grafica
oPrint 	:=TMSPrinter():New("GUIA DE INTERNACAO HOSPITALAR ")
oPrint  :SetPortrait()										//--Modo retrato
oPrint	:StartPage() 										//--Inicia uma nova pagina
                                                        
//-- Verifica se existe alguma impressora  configurada para Impres.Grafica ...
lPrinter	:= oPrint:IsPrinterActive()
If !lPrinter
	oPrint:Setup()
Endif

wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.F.,tamanho)
If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| R420Imp(@lEnd,wnRel,cString)},Titulo)

oPrint:Preview()  		// Visualiza impressao grafica antes de imprimir
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//RestArea( aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R420IMP  ³ Autor ³ Natie Sugahara        ³ Data ³ 03/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSR420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R420Imp(lEnd,wnRel,cString)

Local cFileLogo		:= ""
//Local cStartPath 	:= GetSrvProfString("Startpath","")
Local nLinMax		:= 3200									//-- Numero maximo de Linhas
Local nColMax		:= 2350									//-- Numero maximo de Colunas
Local nColIni		:= 50                                   //-- Coluna Lateral (inicial) Esquerda
//Local nColIniDet	:= 60                                   //-- Coluna Lateral (inicial) Esquerda
Local li 			:= 30 									//-- Contador de Linhas
Local cDet 			:= ""
Local cPrazoLib		:= StrZero(GetNewPar("MV_PLPRZAI",30),02)
LOCAL lImpNAut		:= Iif(GetNewPar("MV_PLNAUT",0)==0,.F.,.T.) //0=Nao imprime procedimento nao autorizado 1=Sim imprime
Local nTotLin
Local nInd

DbSelectArea("BE4")
//-- Posiciona o ponteiro
BE4->( dbGoto( nSvRecno ) )	

BE4->(RecLock("BE4",.F.))
BE4->BE4_GUIIMP := "1"
If BE4->BE4_STATUS == "4"
   BE4->BE4_STATUS := "1"
Endif   
BE4->(MsUnLock())

BEA->(DbSetOrder(6))
If BEA->(DbSeek(xFilial("BEA")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
   BEA->(RecLock("BEA",.F.))
   BEA->BEA_GUIIMP := "1"
   If BEA->BEA_STATUS == "4"
      BEA->BEA_STATUS := "1"
   Endif   
   BEA->(MsUnLock())        
Endif
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Box Principal                                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:Box( 030,030,nLinMax, nColMax )

//  -- CABECALHO DA GUIA  -- //
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Carrega e Imprime Logotipo da Empresa                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
fLogoEmp(@cFileLogo)
oPrint:Line(30,50,30,nColMax)
If File(cFilelogo)
	oPrint:SayBitmap(080,50, cFileLogo,400,090) 		//-- Tem que estar abaixo do RootPath
Endif 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Nome da Operadora 										     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cDet	:= ""
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BE4")+ BE4->(BE4_OPEUSR)))
oPrint:say(100 ,500, BA0->BA0_NOMINT , oFont10)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Endereco                										 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(150 , 500 , BA0->BA0_END + space(02) + BA0->BA0_BAIRRO                         , oFont08)
oPrint:say(200 , 500 , BA0->BA0_CEP + space(2)+  BA0->BA0_CIDADE + space(2)+ BA0->BA0_EST , oFont08)


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³GUIA DE INTERNACAO HOSPITALAR No :                            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(040, 0500,OemToAnsi(STR0001) + oEmToAnsi(STR0006)            , oFont15n)
cDet	:= BE4->(BE4_CODOPE+"."+BE4_ANOINT+"."+BE4_MESINT+"-"+BE4_NUMINT)
oPrint:say(040 , 1650 , cDet                                             , oFont15n)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Senha                                                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If ! Empty(BE4->BE4_SENHA)
   oPrint:say(100 , ( nColMax-700) ,oEmToAnsi(STR0069)+ BE4->BE4_SENHA , oFont09n)
Endif   
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Codigo ANS                                                    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(150 , nColMax-700    ,oEmToAnsi(STR0076)                   , oFont09n)		//-- Codigo ANS
oPrint:say(150 , nColMax-500    ,BA0->BA0_SUSEP                       , oFont10n)	
oPrint:say(210 , nColMax-700    ,oEmToAnsi(STR0078)                   , oFont08 )		//-- Guia V lida por        a partir
oPrint:say(210 , nColMax-500    ,cPrazoLib			                   , oFont10n)		//-- Prazo de Validade
oPrint:say(210 , nColMax-200    ,dtoc(BE4_DTDIGI)                     , oFont10n)		//-- Data  da Autorizacao 
oPrint:line(250,nColIni,250, nColMax-050)

//  -- FIM CABECALHO DA GUIA  -- //

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Tipo de Internacao      										 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Li 	:= 280
oPrint:say(li , nColIni , OemToAnsi(STR0007)      , oFont10n)
oPrint:say(li , nColIni + 400 , BE4->BE4_TIPINT+' - '+X3COMBO("BE4_TIPINT",BE4->BE4_TIPINT)    , oFont10)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Data da Autorizacao     										 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li , nColIni + 0900 , OemToAnsi(STR0008)   , oFont10n )
cDet	:= dtoc(BE4->BE4_DATPRO) 
oPrint:say(li , nColIni + 1300 , dtoc(BE4->BE4_DATPRO), oFont10)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Tipo : Implementacao posterior                				 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If BE4->BE4_DIASIN > 0
   oPrint:say(li , nColIni + 1600 , OemToAnsi(STR0070)+Transform(BE4->BE4_DIASIN,"@R 99") , oFont10n) //Diarias autorizadas
Else
   oPrint:say(li , nColIni + 1600 , OemToAnsi(STR0070)+'0' , oFont10n) //Diarias autorizadas
Endif   
  

li += 50

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Padrao de Acomoda‡„o                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BI4->(DbSetOrder(1))
BI4->(DbSeek(xFilial("BE4")+BE4->BE4_PADINT))
oPrint:say(li, nColIni       , OemToAnsi(STR0009)                    , oFont10n )
oPrint:say(li, ncolIni + 450 , BI4->BI4_CODACO+" - "+BI4->BI4_DESCRI, oFont10)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Produto                                                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BA1->(DbSetOrder(2))
BA1->(DbSeek(xFilial("BA1")+BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG)))

BA3->(DbSetOrder(1))
BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
oPrint:say(li, nColIni + 1000  , OemToAnsi(STR0010)                                        , oFont10n)
oPrint:say(li, ncolIni + 1400  ,If(BA3->BA3_APLEI=="1","Regulamentado","Nao Regulamentado"), oFont10)
li +=50
oPrint:line(li,nColIni,li, nColMax-050)
li += 20


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Usuario                                                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni      , OemToAnsi(STR0011) , oFont10n)

//Caso seja Recen nascido imprime na frente do nome a mensagem "Atendimento Recem Nascido"
If BE4->BE4_ATERNA <> '1'
	oPrint:say(li, ncolIni + 250 , BA1->BA1_NOMUSR    , oFont10)
Else
	oPrint:say(li, ncolIni + 250 , AllTrim(BA1->BA1_NOMUSR) + " (Atendimento Recem Nascido)"    , oFont10)
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Codigo                                                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni + 1600 , OemToAnsi(STR0012)                                                           , oFont10n )
If  BA1->BA1_CODINT == BA1->BA1_OPEORI .or. empty(BA1->BA1_MATANT)
    oPrint:say(li, ncolIni + 1800 , BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"."+BA1_TIPREG+"-"+BA1_DIGITO)  , oFont10)
Else
    oPrint:say(li, ncolIni + 1800 , BA1->BA1_MATANT , oFont10)
Endif
Li+= 50 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Identidade                                                    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/                                                     
oPrint:say(li, nColIni       , OemToAnsi(STR0013) , oFont10n )
oPrint:say(li, ncolIni + 250 , BA1->BA1_DRGUSR    , oFont10)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Sexo                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/                                                     
oPrint:say(li, nColIni + 900 , OemToAnsi(STR0014)                , oFont10n )
oPrint:say(li, ncolIni +1050 , X3COMBO("BA1_SEXO",BA1->BA1_SEXO) , oFont10)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Data de Nascimento                                            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni + 1600 , OemToAnsi(STR0015)    , oFont10n )
oPrint:say(li, ncolIni + 2000 , dtoc(BA1->BA1_DATNAS) , oFont10)
Li+= 50

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Empresa                                                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BG9->(DbSetOrder(1))
BG9->(DbSeek( xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP) )  )
oPrint:say(li, nColIni       , OemToAnsi(STR0016)    , oFont10n )
oPrint:say(li, ncolIni + 250 ,BG9->BG9_DESCRI , oFont10)
li += 50
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Plano                                                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BI3->(DbSetOrder(1))
BI3->(DbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
oPrint:say(li, nColIni        , OemToAnsi(STR0017)    , oFont10n )
oPrint:say(li, ncolIni + 250  , BI3->(BI3_CODIGO + "-"+BI3_DESCRI )      , oFont10)
li +=50
oPrint:line(li,nColIni,li, nColMax-050)
li += 20

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Medico Solicitante                                            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BB0->( DbSetOrder(4) )
BB0->(DbSeek(xFilial("BB0")+BE4->(BE4_ESTSOL+BE4_REGSOL+BE4_SIGLA)))
oPrint:say(li, nColIni        , OemToAnsi(STR0018) , oFont10n )
oPrint:say(li, ncolIni + 400  , BB0->BB0_NOME      , oFont10)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³CRM                                                           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni + 1600 , OemToAnsi(STR0019) , oFont10n )
oPrint:say(li, ncolIni + 1800 , BB0->BB0_NUMCR     , oFont10)
Li +=50

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Hospital / Recurso :                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BAU->(DbSetOrder(1))
BAU->(DbSeek(xFilial("BAU")+BE4->BE4_CODRDA))
oPrint:say(li, nColIni        , OemToAnsi(STR0020) , oFont10n )
oPrint:say(li, ncolIni + 400  , BAU->BAU_NOME      , oFont10)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Codigo                                                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni + 1600  , OemToAnsi(STR0012) , oFont10n )
oPrint:say(li, ncolIni + 1800  , BAU->BAU_CODIGO    , oFont10)
li +=50
oPrint:line(li,nColIni,li, nColMax-050)
li += 20

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³CID PRINCIPAL                                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni         , OemToAnsi(STR0021)  , oFont10n  )
oPrint:say(li, ncolIni +  400  , BE4->BE4_CID        , oFont10)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Data da Internacao                                            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni + 1600  , OemToAnsi(STR0022)    , oFont10n )
oPrint:say(li, ncolIni + 2000  , dtoc(BE4->BE4_DATPRO) , oFont10)
li +=50 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³CID Secundario                                                ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni         , OemToAnsi(STR0023), oFont10n )
oPrint:say(li, ncolIni + 0400  , BE4->BE4_CIDSEC   , oFont10)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Hora da Interna‡„o :                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni + 1600  , OemToAnsi(STR0024)   , oFont10n )
oPrint:say(li, ncolIni + 2000  , substr(BE4->BE4_HORPRO,1,2)+":" +substr(BE4->BE4_HORPRO,3,2), oFont10)
Li +=50
oPrint:line(li,nColIni,li, nColMax-050)
Li += 20


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Impressao do Cabecalho da Linha de Detalhe                    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:Box(li,nColIni,Li+450, nColMax-50 )										//-- Box Detalhe AMB
LI +=20
//-- Cabecalho do Detalhe
oPrint:say(li,nColIni      ,oemToAnsi(STR0025) ,oFont10n )
oPrint:say(li,nColIni+ 350 ,oemToAnsi(STR0026) ,oFont10n )
oPrint:say(li,nColIni+1600 ,oemToAnsi(STR0081) ,oFont10n )
oPrint:say(li,nColIni+1800 ,oemToAnsi(STR0027) ,oFont10n )
oPrint:say(li,nColIni+1950 ,oemToAnsi(STR0029) ,oFont10n )
li += 50
oPrint:line(li,nColIni,li, nColMax-050)
li += 20

//-- Detalhe
//-- Imprime somente um lancamento ( implementacao posterior)
BEJ->(DbSetOrder(1))
If BEJ->(DbSeek(xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
   While ! BEJ->(Eof()) .And. BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) == ;
                               xFilial("BEJ")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao imprime procedimento negado	conforme parametro			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If !lImpNAut .And. BEJ->BEJ_STATUS == "0"
	        BEJ->(DbSkip())
            Loop
         EndIf
         cDet	:= PLSPICPRO(BEJ->BEJ_CODPAD,BEJ->BEJ_CODPRO)
         oPrint:say(li,nColIni+10   ,cDet                                ,oFont10n )		//-- AMB
         BR8->(DbSetOrder(1)) 
         BR8->(DbSeek(xFilial("BR8")+BEJ->(BEJ_CODPAD+BEJ_CODPRO)))
         nTotLin := MlCount(AllTrim(BR8->BR8_DESCRI), 60) // Verifica quantas linhas a descricao vai ocupar
         oPrint:say(li,nColIni+ 350 ,MemoLine(BR8->BR8_DESCRI, 60, 1) ,oFont10 ) // -- Imprime 1a. Linha de Descricao

         If BEJ->BEJ_STATUS == "0"
	         oPrint:say(li,nColIni+1610 ,OemToAnsi(STR0082) ,oFont10 )	//-- STATUS "Negado"
		 Else
		     oPrint:say(li,nColIni+1610 , OemToAnsi(STR0080),oFont10 )	//-- STATUS		 "Autorizado"
         EndIf

         oPrint:say(li,nColIni+1810 ,Transform(BEJ->BEJ_QTDPRO,"@R 99") ,oFont10 )	//-- Qtde
         oPrint:say(li,nColIni+1950 ," "                                ,oFont10 )		//-- Realizacao
         Li += 035               
         If nTotLin > 1 // Se ha mais de 1 linha de descricao, imprime as demais
            For nInd := 2 To nTotLin
                oPrint:say(li,nColIni+ 350 ,MemoLine(BR8->BR8_DESCRI, 60, nInd) ,oFont10 )	//-- Descricao             
                Li += 035               
            Next nInd
         EndIf
                                                                
   BEJ->(DbSkip())
   Enddo
Endif                               




Li := 1330
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Carimbo                                                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni + 1700 , OemToAnsi(STR0030), oFont10n )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Impressao Mensagem :                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni        , OemToAnsi(STR0073), oFont10n )
li += 50
oPrint:say(li, ncolIni,BE4->BE4_MSG01,oFont10)
li+= 50 
oPrint:say(li, ncolIni,BE4->BE4_MSG02,oFont10)
li+= 50 
oPrint:say(li, ncolIni,BE4->BE4_MSG03,oFont10)		
li+= 120

oPrint:line(li,nColIni,li, nColMax-050)
Li += 20

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Declaracao do usuario / Responsavel                           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:say(li, nColIni    , OemToAnsi(STR0031) , oFont10n )
li += 50
oPrint:say(li, nColIni+50 , OemToAnsi(STR0032) + Alltrim(BA0->BA0_NOMINT) + ", "              , oFont09 )
li += 50
oPrint:say(li, nColIni+50 , OemToAnsi(STR0033)                                                 , oFont09 )
li += 50
oPrint:say(li, nColIni+50 , OemToAnsi(STR0034)                                                 , oFont09 )
li += 50
oPrint:say(li, nColIni+50 , OemToAnsi(STR0035)                                                 , oFont09 )
li += 50
oPrint:say(li, nColIni+50 , OemToAnsi(STR0036) + Alltrim(BA0->BA0_NOMINT) + OemToAnsi(STR0037) , oFont09 )
Li += 100

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Local e Data / Assinatura do Usuario e/ou Responsavel         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:Line(li,nColIni+50,li, 0800)
oPrint:Line(li,1150      ,li, 1850)
Li += 10
oPrint:Say(li,nColIni+50, OemToAnsi(STR0039), oFont08)												//--Local e Data

If (BEA->BEA_STATUS == "2") // Imprime a frase de AUTORIZACAO NEGADA para usuarios negados e Assinatura para autorizados - BOPS 99495
	oPrint:Say(li,1150      , OemToAnsi(STR0083), oFont08)		//-- "AUTORIZACAO PARCIAL - IMPRESSAO SOLICITADA PELO USUARIO."
ElseIf ! (BEA->BEA_STATUS == "3") // Imprime a frase de AUTORIZACAO NEGADA para usuarios negados e Assinatura para autorizados - BOPS 99495
    oPrint:Say(li,1150      , OemToAnsi(STR0040), oFont08)												//-- Assinatura do Responsavel
Else
   	oPrint:say(li,1150      , OemToAnsi(STR0079), oFont08 )				//"AUTORIZACAO NEGADA - IMPRESSAO SOLICITADA PELO USUARIO." 
Endif  


Li +=50
oPrint:line(li,nColIni,li, nColMax-050)
Li += 20
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Dados para SIP - Obrigatorio o Preenchimento pelo Hospital    |
  |quando Internacao Obstetrica                                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/                                                                                
oPrint:Say(li,nColIni, OemToAnsi(STR0041) , oFont10N)
Li += 050
oPrint:Say(li,nColIni, "01- "+OemToAnsi(STR0042) , oFont09)										//--Gravidez terminou em  aborto
li += 50
fDrawBox(li,ncolIni+50)
oPrint:Say(li,150, OemToAnsi(STR0056) , oFont09)
fDrawBox(li,250) 
oPrint:Say(li,300, OemToAnsi(STR0057) +" " +OemToAnsi(STR0043)+ Repl("_",10) + OemToAnsi(STR0044) , oFont09)//--Total de Semanas / cid 10
Li	+=50
oPrint:Say(li,nColIni, "02- "+OemToAnsi(STR0045) , oFont09)										//--Transtornos maternos relacionados a gravidez : CID 10: "
Li	+=50
oPrint:Say(li,nColIni,"03- "+OemToAnsi(STR0046) , oFont09) 										 //--Termino da Gravidez (Parto) : Normal
li +=50
fDrawBox(li,nColini+50)
oPrint:Say(li,150   ,OemToAnsi(STR0038) 		, oFont09)  
fDrawBox(li,300)
oPrint:Say(li,350   ,OemToAnsi(STR0047) 		, oFont09)  
fDrawBox(li,500)
oPrint:Say(li,550   ,OemToAnsi(STR0048) 		, oFont09)  
fDrawBox(li,700)
oPrint:Say(li,750   ,OemToAnsi(STR0049) 		, oFont09)  
li += 50                              
oPrint:Say(li,nColIni, "04- "+OemToAnsi(STR0050) , oFont09)										//--Tipo de Alta Materno
li += 50
fDrawBox(li,nColIni+50)
oPrint:Say(li,150   ,OemToAnsi(STR0071) 		, oFont09)  
fDrawBox(li,300)
oPrint:Say(li,350   ,OemToAnsi(STR0051) 		, oFont09)  
fDrawBox(li,500)
oPrint:Say(li,550   ,OemToAnsi(STR0052) 		, oFont09)  
fDrawBox(li,700)
oPrint:Say(li,750   ,OemToAnsi(STR0053) 		, oFont09)  
fDrawBox(li,900)
oPrint:Say(li,950   ,OemToAnsi(STR0054) + space(5)+ OemToAnsi(STR0044), oFont09)  

Li	+=50
oPrint:Say(li,nColIni, "05- "+OemToAnsi(STR0055) , oFont09)										//--Pos-Nascimento - Complicacao no Periodo de Puerperio 
li += 50
fDrawBox(li,ncolIni+50)
oPrint:Say(li,150, OemToAnsi(STR0056) , oFont09)
fDrawBox(li,250) 
oPrint:Say(li,300, OemToAnsi(STR0057) +" " +OemToAnsi(STR0044) , oFont09)							//--Total de Semanas / cid 10
Li	+=50

oPrint:Say(li,nColIni, "06- "+OemToAnsi(STR0058) , oFont09)										//--Tipo de Alta Materno
li += 50
fDrawBox(li,nColIni+50)
oPrint:Say(li,150   ,OemToAnsi(STR0072) 		, oFont09)  
fDrawBox(li,300)
oPrint:Say(li,350   ,OemToAnsi(STR0059) 		, oFont09)  
fDrawBox(li,500)
oPrint:Say(li,550   ,OemToAnsi(STR0060) 		, oFont09)  
fDrawBox(li,700)
oPrint:Say(li,750   ,OemToAnsi(STR0049)+"-"		, oFont09)  
fDrawBox(li,900)
oPrint:Say(li,950   ,OemToAnsi(STR0061) 		, oFont09)  
oPrint:Say(li,1200  ,OemToAnsi(STR0063)+"______", oFont09) 
fDrawBox(li,1450)
oPrint:Say(li,1530  , OemToAnsi(STR0062) 		, oFont09)
oPrint:Say(li,1650  ,OemToAnsi(STR0063)+"______", oFont09)
fDrawBox(li,1900)
oPrint:Say(li,1950  ,OemToAnsi(STR0064)        , oFont09) 

Li	+=50
oPrint:Say(li,nColIni, "07- "+OemToAnsi(STR0065) , oFont09)
li += 50
fDrawBox(li,ncolIni+50)
oPrint:Say(li,150, OemToAnsi(STR0056) , oFont09)
fDrawBox(li,250) 
oPrint:Say(li,300, OemToAnsi(STR0057) +" " +OemToAnsi(STR0043)+ Repl("_",10) + OemToAnsi(STR0044) , oFont09)	//--Total de Semanas / cid 10

Li	+=50
oPrint:Say(li,nColIni, "08- "+OemToAnsi(STR0066) , oFont09)               										//--Complicacoes no periodo Neonatal
li += 50
fDrawBox(li,ncolIni+50)
oPrint:Say(li,150, OemToAnsi(STR0056) , oFont09)
fDrawBox(li,250) 
oPrint:Say(li,300, OemToAnsi(STR0057) +" " +OemToAnsi(STR0043)+ Repl("_",10) + OemToAnsi(STR0044) , oFont09)	//--Total de Semanas / cid 10

Li	+=50
oPrint:Say(li,nColIni, "09- "+OemToAnsi(STR0067) , oFont09)               										//--Rn foi encaminhado a UTI e/ou CTI 
li += 50
fDrawBox(li,ncolIni+50)
oPrint:Say(li,150, OemToAnsi(STR0056) , oFont09)
fDrawBox(li,250) 
oPrint:Say(li,300, OemToAnsi(STR0057) +" " +OemToAnsi(STR0043)+ Repl("_",10) + OemToAnsi(STR0044) , oFont09)	//--Total de Semanas / cid 10

li	+=50
oPrint:Say(li,nColIni, "10- "+OemToAnsi(STR0068) , oFont09)													//--Tipo de Alta RN :
li += 50
fDrawBox(li,nColIni+50)
oPrint:Say(li,150   ,OemToAnsi(STR0071) 		, oFont09)  
fDrawBox(li,300)
oPrint:Say(li,350   ,OemToAnsi(STR0051) 		, oFont09)  
fDrawBox(li,500)
oPrint:Say(li,550   ,OemToAnsi(STR0052) 		, oFont09)  
fDrawBox(li,700)
oPrint:Say(li,750   ,OemToAnsi(STR0053) 		, oFont09)  
fDrawBox(li,900)
oPrint:Say(li,950   ,OemToAnsi(STR0054) + space(5)+ OemToAnsi(STR0044), oFont09)  
Li +=50
oPrint:line(li,nColIni,li, nColMax-050)
Li +=100

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Carimbos e Assinaturas                                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oPrint:Line(li,nColIni+50,li, 0800)
oPrint:Line(li,1150      ,li, 1850)
Li += 10
oPrint:Say(li,nColIni+50  ,OemToAnsi(STR0074) 		, oFont08)			//--Carimbo e Assinatura do M‚dico Respons vel
oPrint:Say(li,1150        ,OemToAnsi(STR0075) 		, oFont08)			//--Carimbo da Unimed

oPrint:EndPage() 		// Finaliza a pagina
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
Default cTipo 	:= "1"

//-- Logotipo da Empresa
If cTipo =="1"
	cLogo := cStartPath + "LGRL"+FWCompany()+FWCodFil()+".BMP" 	// Empresa+Filial
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+FWCompany()+".BMP" 				// Empresa
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
Static Function  fDrawBox(nLIn,nCol)

oPrint:Box(nLin, nCol,nLin+40,nCol+40)


Return(nlin)