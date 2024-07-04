
#include "PLSR430.CH"
#include "PROTHEUS.CH"

#define nLinMax	    1430								//-- Numero maximo de Linhas
#define nColMax		2350								//-- Numero maximo de Colunas
#define nColIni		50                                  //-- Coluna Lateral (inicial) Esquerda

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSR430  ³ Autor ³ Natie Sugahara        ³ Data ³ 06.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Autorizacao de Guia                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSR430(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSR430(aPar)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL CbCont,cabec1,cabec2,cabec3,nPos,wnrel
LOCAL tamanho	:= "M"
LOCAL cDesc1	:= OemtoAnsi(STR0002)  			//"Impressao da Autoriza‡„o de Guia "
LOCAL cDesc2	:= OemtoAnsi(STR0003)  			//"de acordo com a configuracao do usuario."
LOCAL cDesc3	:= " "
LOCAL aArea		:= GetArea()
LOCAL lPrinter		:= .T.
Local lGerTXT   := .T.
Local lImpGuiNeg := GetNewPar("MV_IGUINE", .F.) //parametro para impressão de guia em análise

PRIVATE nSvRecno	:= BEA->( Recno() )												//Salva posicao do BEA para Restaurar apos SetPrint()
PRIVATE aReturn 	:= { OemtoAnsi(STR0004), 1,OemtoAnsi(STR0005), 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
PRIVATE aLinha		:= { }
PRIVATE nomeprog	:="PLSR430",nLastKey := 0
PRIVATE titulo	:= OemtoAnsi(STR0001)  			//"AUTORIZACAO DE GUIA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos utilizados na impressao grafica                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oFont07,oFont08n, oFont08, oFont09, oFont09n,oFont10, oFont10n
Private oFont12,oFont12n,oFont15,oFont15n, oFont21n,oFont16n
Private oPrint   
Private cPerg

DEFAULT aPar := {"1",.F.}

If aPar[1] == "1"
   cPerg := ""
Else
   cPerg := "PLR430"
Endif    

lGerTXT := aPar[2] // Imprime Direto sem passar pela tela de configuracao/preview do relatorio

If aPar[1] == "1" .And. ! (BEA->BEA_STATUS $ "1,2,4,3" .Or. (BEA->BEA_STATUS == '6' .And. getNewPar("MV_PLIBAUD",.F.) == .T.)) .AND. !lImpGuiNeg 
   Help("",1,"PLSR430")
   Return
   
Endif   

If aPar[1] == "2" .And. lGerTXT
   If ! Pergunte("PLR430", .T.)
      Return
   EndIf
EndIf

If BEA->BEA_ORIGEM == "2"
   titulo := "LIBERACAO DE GUIAS"
   cDesc1 := "Impressao da Liberacao de Guia "
Endif   

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbcont   := 0
cabec1   := OemtoAnsi(Titulo)  										//--"GUIA DE INTERNACAO HOSPITALAR"
cabec2   := " "
cabec3   := " "
cString  := "BEA"
aOrd     := {}
              
//-- Objeto para impressao grafica
If BEA->BEA_ORIGEM == "1"
   oPrint 		:= TMSPrinter():New("AUTORIZA€ŽO DE GUIA ")
Else
   oPrint 		:= TMSPrinter():New("LIBERACAO DE GUIA ")
Endif   
oPrint  :SetPortrait()										//--Modo retrato
oPrint	:StartPage() 										//--Inicia uma nova pagina

//-- Verifica se existe alguma impressora  configurada para Impres.Grafica ...
lPrinter	:= oPrint:IsPrinterActive()
If !lPrinter
	oPrint:Setup()
EndIf     

wnrel:="PLSR430"    										//--Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.F.,tamanho,,,,,lGerTXT)

If nLastKey = 27
	Set Filter To
	Return
Endif

If lGerTXT
   SetPrintFile(wnRel)
EndIf

RptStatus({|lEnd| R430Imp(@lEnd,wnRel,cString,aPar)},Titulo)

If lGerTXT
   oPrint:Print()  														// Imprime Relatorio
 Else
   oPrint:Preview()  													// Visualiza impressao grafica antes de imprimir
EndIf
//-- Posiciona o ponteiro
BEA->( dbGoto( nSvRecno ) )	

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestArea( aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R430IMP  ³ Autor ³ Natie Sugahara        ³ Data ³ 03/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSR430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R430Imp(lEnd,wnRel,cString,aPar, lAuto)

//Local li 			:= 30 									//-- Contador de Linhas
//Local cDet 			:= ""
//Local cChave		:= ""
LOCAL cCodOpe
LOCAL cGrupoDe
LOCAL cGrupoAte
LOCAL cContDe
LOCAL cContAte
LOCAL cSubDe
LOCAL cSubAte
LOCAL nTipo
LOCAL cSQL
DEFAULT aPar := {"1",.F.}
Default lAuto := .F.

If lAuto
  oPrint := TMSPrinter():New("TISS2_015")
EndIf

If aPar[1] == "1" .Or. BEA->(FieldPos("BEA_GUIIMP")) == 0 //impressao individual
     Imprime(lAuto)
Else //impressao por lote... de acordo com o pergunte
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Busca dados de parametros...                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Pergunte(cPerg,.F.)

     cCodOpe   := mv_par01
     cGrupoDe  := mv_par02
     cGrupoAte := mv_par03                                                                                        
     cContDe   := mv_par04
     cContAte  := mv_par05
     cSubDe    := mv_par06
     cSubAte   := mv_par07
     nTipo     := mv_par08
     
     cSQL := "SELECT R_E_C_N_O_ AS REG FROM "+RetSQLName("BEA")+" WHERE "
     cSQL += "BEA_FILIAL = '"+xFilial("BEA")+"' AND "
     cSQL += "BEA_OPEMOV = '"+cCodOpe+"' AND "
     cSQL += "( BEA_CODEMP >= '"+cGrupoDe+"' AND BEA_CODEMP <= '"+cGrupoAte+"' ) AND "
     cSQL += "( BEA_CONEMP >= '"+cContDe+"' AND BEA_CONEMP <= '"+cContAte+"' ) AND "
     cSQL += "( BEA_SUBCON >= '"+cSubDe+"' AND BEA_SUBCON <= '"+cSubAte+"' ) AND "
     
     If nTipo == 1
        cSQL += "BEA_STATUS = '4' AND "
     ElseIf nTipo == 2
        cSQL += "BEA_GUIIMP = '1' AND "
     Endif   
     
     cSQL += "D_E_L_E_T_ = ''"
     
     PLSQuery(cSQL,"Trb")
     
     If Trb->(Eof())
        Trb->(DbCloseArea())
        Help("",1,"RECNO")
       
        Return
     Else   
        While ! Trb->(Eof())
        
              BEA->(DbGoTo(Trb->REG))
              
              Imprime()
        
        Trb->(DbSkip())
        Enddo          
        
        Trb->(DbCloseArea())
     Endif                 
Endif



Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fImpCabec   ºAutor  ³Microsiga           º Data ³  03/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Desenha Box                                                   º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
Static Function fImpCabec(li, lAuto)
Local cFileLogo		:= ""
Local cPrazoLib		:= StrZero(GetMv("MV_PLPRZLB"),02)
Local cDet			:= "" 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Box Principal                                                 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lAuto
  oPrint:Box( 030,030,nLinMax, nColMax )
EndIf
//  -- CABECALHO DA GUIA  -- //

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Carrega e Imprime Logotipo da Empresa                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
fLogoEmp(@cFileLogo)
If !lAuto
  oPrint:Line(30,50,30,nColMax)
  If File(cFilelogo)
    oPrint:SayBitmap(080,50, cFileLogo,400,090) 		//-- Tem que estar abaixo do RootPath
  Endif 
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Nome da Operadora 										     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cDet	:= ""
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BEA")+ BEA->(BEA_OPEUSR)))
If !lAuto
  oPrint:say(100 ,500, BA0->BA0_NOMINT , oFont10)
EndIf
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Endereco                										 ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BID->(DbSetOrder(1))
BID->(DbSeek( xFilial("BID")+BA0->(BA0_CODMUN ) )  )
If !lAuto
  oPrint:say(150 , 500 , BA0->BA0_END + space(02) + BA0->BA0_BAIRRO                                    , oFont08)
  oPrint:say(200 , 500 , BA0->BA0_CEP + space(02) + Alltrim(BID->BID_DESCRI) + space(2)+ BA0->BA0_EST , oFont08)
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³AUTORIZACAO DE GUIA                                           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lAuto
  oPrint:say(040, 0500,OemToAnsi(Titulo)+ OemToAnsi(STR0006)              , oFont15n)
  cDet	:= BEA->(BEA_OPEMOV+"."+BEA_ANOAUT+"."+BEA_MESAUT+"-"+BEA_NUMAUT)
  oPrint:say(040 , 1650 , cDet                                             , oFont15n)
Else
  cDet	:= BEA->(BEA_OPEMOV+"."+BEA_ANOAUT+"."+BEA_MESAUT+"-"+BEA_NUMAUT)
EndIf
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Senha                                                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If ! Empty(BEA->BEA_SENHA) .And. !lAuto
   oPrint:say(100 , ( nColMax-700) ,oEmToAnsi(STR0069)+ BEA->BEA_SENHA , oFont09n)
Endif   
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Codigo ANS                                                    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lAuto
  oPrint:say(150 , nColMax-700    ,oEmToAnsi(STR0008)                   , oFont09n)		//-- Codigo ANS
  oPrint:say(150 , nColMax-500    ,BA0->BA0_SUSEP                       , oFont10n)
  oPrint:say(220 , nColMax-700    ,oEmToAnsi(STR0007)                   , oFont08 )		//-- Guia V lida por        a partir
  oPrint:say(220 , nColMax-500    ,cPrazoLib+" dias"   	                   , oFont10n)		//-- Prazo de Validade
  oPrint:say(220 , nColMax-200    ,dtoc(BEA_DATPRO)                     , oFont10n)		//-- Data
  oPrint:line(260,nColIni,260, nColMax-050)
EndIf

//  -- FIM CABECALHO DA GUIA  -- //

Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDadosUsua  ºAutor  ³Microsiga           º Data ³  03/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Desenha Box                                                   º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function fDadosUsua(li, lAuto)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Posiciona Usuario                                             ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BA1->(DbSetOrder(2))
BA1->(DbSeek(xFilial("BA1")+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG)))
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Usuario                                                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lAuto
  oPrint:say(li, nColIni      , OemToAnsi(STR0011)  , oFont09n)
  oPrint:say(li, nColIni + 250 , BEA->BEA_NOMUSR    , oFont09 )
  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Codigo                                                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  oPrint:say(li, nColIni + 1600 , OemToAnsi(STR0012)                                                           , oFont09n)
  If  BA1->BA1_CODINT == BA1->BA1_OPEORI .or. empty(BA1->BA1_MATANT)
      oPrint:say(li, nColIni + 1800 , BEA->(substr(BEA_OPEMOV,1,1)+substr(BEA_OPEMOV,2,3)+"."+BEA_CODEMP+"."+BEA_MATRIC+"."+BEA_TIPREG+"-"+BEA_DIGITO)	  , oFont09)
  Else
      oPrint:say(li, nColIni + 1800 , BA1->BA1_MATANT , oFont09)
  Endif
  Li+= 50

  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³Identidade                                                    ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 

  oPrint:say(li, nColIni       , OemToAnsi(STR0013) , oFont09n )
  oPrint:say(li, nColIni + 250 , BEA->BEA_IDUSR     , oFont09)
  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³Sexo                                                          ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/                                                     
  oPrint:say(li, nColIni + 900 , OemToAnsi(STR0014)                , oFont09n)
  oPrint:say(li, nColIni +1050 , X3COMBO("BA1_SEXO",BA1->BA1_SEXO) , oFont09)
  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³Data de Nascimento                                            ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  oPrint:say(li, nColIni + 1600 , OemToAnsi(STR0015)    , oFont09n )
  oPrint:say(li, nColIni + 2000 , dtoc(BEA->BEA_DATNAS) , oFont09)
  Li+= 50

  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³Empresa                                                       ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  BG9->(DbSetOrder(1))
  BG9->(DbSeek( xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP) )  )
  oPrint:say(li, nColIni       , OemToAnsi(STR0016)    , oFont09n)
  oPrint:say(li, nColIni + 250 ,BG9->BG9_DESCRI        , oFont09)
  li += 50

  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³Plano                                                         ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  BA3->( dbSetorder(01) )
  BA3->( dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
    
  BI3->(DbSetOrder(1))
  BI3->(DbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
  oPrint:say(li, nColIni        , OemToAnsi(STR0017)    , oFont09n )
  oPrint:say(li, nColIni + 250  , BI3->(BI3_CODIGO + "-"+BI3_DESCRI )      , oFont09)
  li +=50
  oPrint:line(li,nColIni,li, nColMax-050)
  li += 20

  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³CID PRINCIPAL                                                 ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/             	
  oPrint:say(li, nColIni         , OemToAnsi(STR0021)                  , oFont09n)
  oPrint:say(li, nColIni +  300  , BEA->BEA_CID                        , oFont09 )

  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³CID Secundario                                                ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  oPrint:say(li, nColIni + 1200   , OemToAnsi(STR0023) , oFont09n)
  oPrint:say(li, nColIni + 1500  , BEA->BEA_CIDSEC     , oFont09 )
  Li +=50
  oPrint:line(li,nColIni,li, nColMax-050)
  Li += 20
Else
  Li+= 290
  BG9->(DbSetOrder(1))
  BG9->(DbSeek( xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP) )  )

  BA3->( dbSetorder(01) )
  BA3->( dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
    
  BI3->(DbSetOrder(1))
  BI3->(DbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDDetCabec  ºAutor  ³Microsiga           º Data ³  03/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime cabecalho da Guia                                     º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function  fDetCabec(li, lAuto)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Impressao do Cabecalho da Linha de Detalhe                    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lAuto
  If BEA->BEA_ORIGEM == "1"
    oPrint:say(li,nColIni      ,oemToAnsi(STR0025) ,oFont09n )						//-- Procedimentos autorizados
  Else
    oPrint:say(li,nColIni      ,"Procedimentos Liberados" ,oFont09n )						//-- Procedimentos autorizados
  Endif   
  oPrint:Box(li,nColIni,Li+500, nColMax-50 )										//-- Box Detalhe AMB
  Li +=10
  //-- Cabecalho do Detalhe
  oPrint:say(li,nColIni+ 350 ,oemToAnsi(STR0026) ,oFont09n )
  oPrint:say(li,nColIni+1600 ,oemToAnsi(STR0080) ,oFont09n )
  oPrint:say(li,nColIni+1800 ,oemToAnsi(STR0027) ,oFont09n )
  If BEA->BEA_GUIACO <> "1"
    oPrint:say(li,nColIni+1900 ,oemToAnsi(STR0076) ,oFont09n )
  Else
    oPrint:say(li,nColIni+1900 ,"Valor da Compra",oFont09n )
  Endif   

  li += 50
  oPrint:line(li,nColIni,li, nColMax-050)
  li += 10
Else
  li += 70
EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fImpRoda    ºAutor  ³Microsiga           º Data ³  03/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime rodape                                                º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function  fImpRoda(li,lAuto)

Li	:= 1100

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Medico Solicitante                                            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BB0->( DbSetOrder(4) )
BB0->(DbSeek(xFilial("BB0")+BEA->(BEA_ESTSOL+BEA_REGSOL+BEA_SIGLA)))
If !lAuto
  oPrint:say(li, nColIni        , OemToAnsi(STR0018) , oFont09n )
  oPrint:say(li, nColIni + 350  , BB0->BB0_NOME  +" "+ OemToAnsi(STR0019)+ BB0->BB0_NUMCR     , oFont09)   	//-- Nome  + CRM
  oPrint:say(li, nColIni+1350  , OemToAnsi(STR0073)            ,oFont09n)									//-- Observacao
  li+= 50
  BB8->(DbSetOrder(1))
  BB8->(DbSeek(xFilial("BB8")+BEA->(BEA_CODRDA+BEA_OPERDA+ BEA_CODLOC+BEA_LOCAL )))
  oPrint:say(li, nColIni       , OemToAnsi(STR0022)            ,oFont09n)										//-- Executante
  oPrint:say(li, nColIni+350   , BB8->(BB8_CODLOC +"."+BB8_LOCAL + space(1) + Alltrim(BB8_DESLOC) ) ,oFont08)		//-- Local Executante
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
  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³Emitente                                                      ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  oPrint:say(li, nColIni+ 1350 , OemToAnsi(STR0010)      , oFont08  )
  oPrint:say(li, nColIni+ 1550 , Alltrim(BEA->BEA_DESOPE), oFont08 )

  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³Assinatura do Beneficiario                                    ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
  If (BEA->BEA_STATUS == "2") // Imprime a frase de AUTORIZACAO NEGADA para usuarios negados e Assinatura para autorizados - BOPS 99495
    oPrint:say(li, nColIni  , OemToAnsi(STR0083), oFont08 )				//"AUTORIZACAO PARCIAL - IMPRESSAO SOLICITADA PELO USUARIO."
  ElseIf ! (BEA->BEA_STATUS == "3") //IMPRIME A FRASE DE AUTORIZACAO NEGADA PARA USUARIOS NEGADOS E ASSINATURA PARA AUTORIZADOS
    oPrint:Line(li,nColIni  , li, 700)
    oPrint:say(li, nColIni  , OemToAnsi(STR0024), oFont08 )				//-- Assinatura do Beneficiario 
  Else
      oPrint:say(li, nColIni  , OemToAnsi(STR0079), oFont08 )				//"AUTORIZACAO NEGADA - IMPRESSAO SOLICITADA PELO USUARIO." 
  Endif  
  oPrint:say(nLinMax +30  , nColIni  , OemToAnsi(STR0030), oFont10n )	//--Aten‡„o : Esta guia ‚ v lida somente para o servi‡o discriminado
  oPrint:EndPage() 		// Finaliza a pagina
Else 
  li+= 280

  BB8->(DbSetOrder(1))
  BB8->(DbSeek(xFilial("BB8")+BEA->(BEA_CODRDA+BEA_OPERDA+ BEA_CODLOC+BEA_LOCAL )))

  BID->(DbSetOrder(1))
  BID->(DbSeek( xFilial("BID")+BB8->(BB8_CODMUN ) )  )
  BID->(Posicione("BID",1,xFilial("BID")+BB8->BB8_CODMUN,"BID_DESCRI") ) 

  oPrint:EndPage()
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fLogoEmp  ºAutor  ³RH - Natie          º Data ³  02/18/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega logotipo da Empresa                                º±±
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
    
Static Function  fDrawBox(nLIn,nCol)

oPrint:Box(nLin, nCol,nLin+40,nCol+40)

Return(nlin)
*/



Static Function Imprime(lAuto)
Local nCount		  := 0 
Local nLinDetMax	:= 10 									//-- Numero maximo de linhas detalhe
Local cPict			  := "@E 999,999,999.9999"
Local lImpGuiNeg  := GetNewPar("MV_IGUINE", .F.) //parametro para impressão de guia em análise
Default lAuto     := .F.

If ! (BEA->BEA_STATUS $ "1,2,4,3") .and. !lImpGuiNeg 
   Return
Endif   

BEA->(RecLock("BEA",.F.))
If BEA->BEA_STATUS == "4"
   BEA->BEA_STATUS := "1"
Endif   

If BEA->(FieldPos("BEA_GUIIMP")) > 0
   BEA->BEA_GUIIMP := "1"
Endif   

BEA->(MsUnLock())


DbSelectArea("BEA")

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Impressao do Cabecalho                                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fImpCabec(,lAuto)
    li := 280
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Dados do Usuario                                              |
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fDadosUsua(@li, lAuto)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Cabecalho do Detalhe                                          |
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fDetCabec(@li, lAuto)


BE2->(DbSetOrder(1))
cChave	:= xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT )
If BE2->(DbSeek( cChave ) )
	While !BE2->(EOF()) .and. cChave==BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
	
		If ncount =  nLinDetMax
			fImpRoda(@li, lAuto)
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³Impressao do Cabecalho                                        ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				fImpCabec(,lAuto)
			    li := 280
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³Dados do Usuario                                              |
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				fDadosUsua(@li, lAuto)
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³Cabecalho do Detalhe                                          |
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				fDetCabec(@li, lAuto)
		Endif

		//-- Linha de Detalhe
		//cDet	:= TransForm(BE2->BE2_CODPRO,"@R !!.!!.!!!-!")
		cDet	:= PLSPICPRO(BE2->BE2_CODPAD,BE2->BE2_CODPRO)

		oPrint:say(li,nColIni      ,cDet                                ,oFont09n   )	//-- AMB
		oPrint:say(li,nColIni+ 350 ,BE2->BE2_DESPRO                     ,oFont09    )	//-- Descricao

		If BE2->BE2_STATUS <> "1"
			oPrint:say(li,nColIni+ 1600 ,oemToAnsi(STR0081)             ,oFont09    )	//-- Status - Negado
		Else
			oPrint:say(li,nColIni+ 1600 ,oemToAnsi(STR0082)             ,oFont09    )	//-- Status	- Autorizado	
	    Endif   

		oPrint:say(li,nColIni+1800 ,Transform(BE2->BE2_QTDPRO,"@R 99") ,oFontMono10 )	//-- Qtde
		BD6->(dbSetOrder(6))
		If BD6->(dbSeek( xFilial("BD6") + BE2->BE2_OPEMOV+BEA->BEA_CODLDP+ BEA->BEA_CODPEG  + BE2->BE2_NUMERO+ BEA->BEA_ORIMOV+BE2->BE2_CODPAD + BE2->BE2_CODPRO  )     )
			oPrint:say(li,nColIni+ 1900  , Transform(BD6->BD6_VLRTPF,cPict )  ,oFontMono10)		//-- Vlr Co-Participacao
		Else
			oPrint:say(li,nColIni+1900 ,Transform( 0            ,cPict)  ,oFontMono10)
		Endif
		li 		+= 40
		nCount	++
		BE2->( DbSkip() )
	Enddo
EndIf                                                          

fImpRoda(@li, lAuto)

Return

