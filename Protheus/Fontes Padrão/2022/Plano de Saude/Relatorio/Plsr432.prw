#include "PLSR432.CH"
#include "PROTHEUS.CH"

#define nLinMax	    1430								//-- Numero maximo de Linhas
#define nColMax		2350								//-- Numero maximo de Colunas
#define nColIni		50                                  //-- Coluna Lateral (inicial) Esquerda

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSR432  � Autor � Natie Sugahara        � Data � 06.06.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Autorizacao de Guia                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSR432(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSR432(aPar)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL CbCont,cabec1,cabec2,cabec3,nPos,wnrel
LOCAL tamanho	:= "M"
LOCAL cDesc1	:= OemtoAnsi(STR0002)  			//"Impressao da Autoriza��o de Guia "
LOCAL cDesc3	:= " "
LOCAL aArea		:= GetArea()
LOCAL lPrinter		:= .T.
Local lGerTXT   := .T.

PRIVATE nSvRecno	:= BEA->( Recno() )												//Salva posicao do BEA para Restaurar apos SetPrint()
PRIVATE aReturn 	:= { OemtoAnsi(STR0025), 1,OemtoAnsi(STR0026), 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
PRIVATE aLinha		:= { }
PRIVATE nomeprog	:="PLSR432",nLastKey := 0
PRIVATE titulo	:= OemtoAnsi(STR0001)  			//"Procedimentos complementares"

//��������������������������������������������������������������Ŀ
//� Objetos utilizados na impressao grafica                      �
//����������������������������������������������������������������
Private oFont07,oFont08n, oFont08, oFont09, oFont09n,oFont10, oFont10n
Private oFont12,oFont12n,oFont15,oFont15n, oFont21n,oFont16n
Private oPrint   
Private cPerg

DEFAULT aPar := {"1",.F.}

If aPar[1] == "1"
   cPerg := ""
EndIf 

lGerTXT := aPar[2] // Imprime Direto sem passar pela tela de configuracao/preview do relatorio

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

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbcont   := 0
cabec1   := OemtoAnsi(Titulo)  										//--"GUIA DE INTERNACAO HOSPITALAR"
cabec2   := " "
cabec3   := " "
cString  := "BEA"
aOrd     := {}
              
//-- Objeto para impressao grafica
oPrint 		:= TMSPrinter():New("PROCEDIMENTOS COMPLEMENTARES ") 
oPrint  :SetPortrait()										//--Modo retrato
oPrint	:StartPage() 										//--Inicia uma nova pagina

//-- Verifica se existe alguma impressora  configurada para Impres.Grafica ...
lPrinter	:= oPrint:IsPrinterActive()

Iif(!lPrinter, oPrint:Setup(), "") 

wnrel:="PLSR432"    										//--Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,,cDesc3,.T.,aOrd,.F.,tamanho,,,,,lGerTXT)

If lGerTXT
   SetPrintFile(wnRel)
EndIf

RptStatus({|lEnd| R432Imp(@lEnd,wnRel,cString,aPar)},Titulo)

If lGerTXT
   oPrint:Print()  														// Imprime Relatorio
 Else
   oPrint:Preview()  													// Visualiza impressao grafica antes de imprimir
EndIf

BEA->( dbGoto( nSvRecno ) )	

RestArea( aArea)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R430IMP  � Autor � Natie Sugahara        � Data � 03/06/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR432                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R432Imp(lEnd,wnRel,cString,aPar)

DEFAULT aPar := {"1",.F.}

If aPar[1] == "1" 
     Imprime()
EndIf

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fImpCabec   �Autor  �Microsiga           � Data �  03/06/03   ���
���������������������������������������������������������������������������͹��
���Desc.     �Desenha Box                                                   ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/    
Static Function fImpCabec(li)
Local cFileLogo		:= ""
Local cDet			:= "" 

/*��������������������������������������������������������������Ŀ
  �Box Principal                                                 �
  ����������������������������������������������������������������*/
oPrint:Box( 030,030,nLinMax, nColMax )

//  -- CABECALHO DA GUIA  -- //

/*��������������������������������������������������������������Ŀ
  �Carrega e Imprime Logotipo da Empresa                         �
  ����������������������������������������������������������������*/
fLogoEmp(@cFileLogo)
oPrint:Line(30,50,30,nColMax)
If File(cFilelogo)
	oPrint:SayBitmap(080,50, cFileLogo,400,090) 		//-- Tem que estar abaixo do RootPath
Endif 

/*��������������������������������������������������������������Ŀ
  �Nome da Operadora 										     �
  ����������������������������������������������������������������*/
cDet	:= ""
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BEA")+ BEA->(BEA_OPEUSR)))
oPrint:say(100 ,500, BA0->BA0_NOMINT , oFont10)

/*��������������������������������������������������������������Ŀ
  �Endereco                										 �
  ����������������������������������������������������������������*/
BID->(DbSetOrder(1))
BID->(DbSeek( xFilial("BID")+BA0->(BA0_CODMUN ) )  )
oPrint:say(150 , 500 , BA0->BA0_END + space(02) + BA0->BA0_BAIRRO                                    , oFont08)
oPrint:say(200 , 500 , BA0->BA0_CEP + space(02) + Alltrim(BID->BID_DESCRI) + space(2)+ BA0->BA0_EST , oFont08)


/*��������������������������������������������������������������Ŀ
  �AUTORIZACAO DE GUIA                                           �
  ����������������������������������������������������������������*/
oPrint:say(040, 0500,OemToAnsi(Titulo)+ OemToAnsi(STR0003)              , oFont15n)
cDet	:= BEA->(BEA_OPEMOV+"."+BEA_ANOAUT+"."+BEA_MESAUT+"-"+BEA_NUMAUT)
oPrint:say(040 , 1650 , cDet                                             , oFont15n)

/*��������������������������������������������������������������Ŀ
  �Senha                                                         �
  ����������������������������������������������������������������*/
If ! Empty(BEA->BEA_SENHA) 
   oPrint:say(100 , ( nColMax-700) ,oEmToAnsi(STR0019)+ BEA->BEA_SENHA , oFont09n)
Endif   
/*��������������������������������������������������������������Ŀ
  �Codigo ANS                                                    �
  ����������������������������������������������������������������*/
oPrint:say(150 , nColMax-700    ,oEmToAnsi(STR0004)                   , oFont09n)		//-- Codigo ANS
oPrint:say(150 , nColMax-500    ,BA0->BA0_SUSEP                       , oFont10n)
oPrint:say(220 , nColMax-200    ,dtoc(BEA_DATPRO)                     , oFont10n)		//-- Data
oPrint:line(260,nColIni,260, nColMax-050)


//  -- FIM CABECALHO DA GUIA  -- //

Return(nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fDadosUsua  �Autor  �Microsiga           � Data �  03/06/03   ���
���������������������������������������������������������������������������͹��
���Desc.     �Desenha Box                                                   ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function fDadosUsua(li)

/*��������������������������������������������������������������Ŀ
  �Posiciona Usuario                                             �
  ����������������������������������������������������������������*/
BA1->(DbSetOrder(2))
BA1->(DbSeek(xFilial("BA1")+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG)))
/*��������������������������������������������������������������Ŀ
  �Usuario                                                       �
  ����������������������������������������������������������������*/
oPrint:say(li, nColIni      , OemToAnsi(STR0027)  , oFont09n)
oPrint:say(li, nColIni + 250 , BEA->BEA_NOMUSR    , oFont09 )
/*��������������������������������������������������������������Ŀ
  �Codigo                                                        �
  ����������������������������������������������������������������*/
oPrint:say(li, nColIni + 1600 , OemToAnsi(STR0005)                                                           , oFont09n)
If  BA1->BA1_CODINT == BA1->BA1_OPEORI .or. empty(BA1->BA1_MATANT)
    oPrint:say(li, nColIni + 1800 , BEA->(substr(BEA_OPEMOV,1,1)+substr(BEA_OPEMOV,2,3)+"."+BEA_CODEMP+"."+BEA_MATRIC+"."+BEA_TIPREG+"-"+BEA_DIGITO)	  , oFont09)
Else
    oPrint:say(li, nColIni + 1800 , BA1->BA1_MATANT , oFont09)
Endif
Li+= 50

/*��������������������������������������������������������������Ŀ
  �Identidade                                                    �
  ����������������������������������������������������������������*/ 
oPrint:say(li, nColIni       , OemToAnsi(STR0006) , oFont09n )
oPrint:say(li, nColIni + 250 , BEA->BEA_IDUSR     , oFont09)
/*��������������������������������������������������������������Ŀ
  �Sexo                                                          �
  ����������������������������������������������������������������*/                                                     
oPrint:say(li, nColIni + 900 , OemToAnsi(STR0007)                , oFont09n)
oPrint:say(li, nColIni +1050 , X3COMBO("BA1_SEXO",BA1->BA1_SEXO) , oFont09)
/*��������������������������������������������������������������Ŀ
  �Data de Nascimento                                            �
  ����������������������������������������������������������������*/
oPrint:say(li, nColIni + 1600 , OemToAnsi(STR0008)    , oFont09n )
oPrint:say(li, nColIni + 2000 , dtoc(BEA->BEA_DATNAS) , oFont09)
Li+= 50

/*��������������������������������������������������������������Ŀ
  �Empresa                                                       �
  ����������������������������������������������������������������*/
BG9->(DbSetOrder(1))
BG9->(DbSeek( xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP) )  )
oPrint:say(li, nColIni       , OemToAnsi(STR0009)    , oFont09n)
oPrint:say(li, nColIni + 250 ,BG9->BG9_DESCRI        , oFont09)
li += 50

/*��������������������������������������������������������������Ŀ
  �Plano                                                         �
  ����������������������������������������������������������������*/
BA3->( dbSetorder(01) )
BA3->( dbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
  
BI3->(DbSetOrder(1))
BI3->(DbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
oPrint:say(li, nColIni        , OemToAnsi(STR0010)    , oFont09n )
oPrint:say(li, nColIni + 250  , BI3->(BI3_CODIGO + "-"+BI3_DESCRI )      , oFont09)
li +=50
oPrint:line(li,nColIni,li, nColMax-050)
li += 20

/*��������������������������������������������������������������Ŀ
  �CID PRINCIPAL                                                 �
  ����������������������������������������������������������������*/             	
oPrint:say(li, nColIni         , OemToAnsi(STR0013)                  , oFont09n)
oPrint:say(li, nColIni +  300  , BEA->BEA_CID                        , oFont09 )

/*��������������������������������������������������������������Ŀ
  �CID Secundario                                                �
  ����������������������������������������������������������������*/
oPrint:say(li, nColIni + 1200   , OemToAnsi(STR0015) , oFont09n)
oPrint:say(li, nColIni + 1500  , BEA->BEA_CIDSEC     , oFont09 )
Li +=50
oPrint:line(li,nColIni,li, nColMax-050)
Li += 20

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fDDetCabec  �Autor  �Microsiga           � Data �  03/06/03   ���
���������������������������������������������������������������������������͹��
���Desc.     �Imprime cabecalho da Guia                                     ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function  fDetCabec(li)

/*��������������������������������������������������������������Ŀ
  �Impressao do Cabecalho da Linha de Detalhe                    �
  ����������������������������������������������������������������*/

oPrint:say(li,nColIni      ,oemToAnsi(STR0028) ,oFont09n )						//-- Procedimentos autorizados
  
oPrint:Box(li,nColIni,Li+500, nColMax-50 )										//-- Box Detalhe AMB
Li +=10
//-- Cabecalho do Detalhe
oPrint:say(li,nColIni+ 350 ,oemToAnsi(STR0017) ,oFont09n )
oPrint:say(li,nColIni+1600 ,oemToAnsi(STR0022) ,oFont09n )
oPrint:say(li,nColIni+1800 ,oemToAnsi(STR0018) ,oFont09n )
oPrint:say(li,nColIni+1900 ,oemToAnsi(STR0021) ,oFont09n )

li += 50
oPrint:line(li,nColIni,li, nColMax-050)
li += 10

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fImpRoda    �Autor  �Microsiga           � Data �  03/06/03   ���
���������������������������������������������������������������������������͹��
���Desc.     �Imprime rodape                                                ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function  fImpRoda(li)

Li	:= 1100

/*��������������������������������������������������������������Ŀ
  �Medico Solicitante                                            �
  ����������������������������������������������������������������*/
BB0->( DbSetOrder(4) )
BB0->(DbSeek(xFilial("BB0")+BEA->(BEA_ESTSOL+BEA_REGSOL+BEA_SIGLA)))
oPrint:say(li, nColIni        , OemToAnsi(STR0011) , oFont09n )
oPrint:say(li, nColIni + 350  , BB0->BB0_NOME  +" "+ OemToAnsi(STR0012)+ BB0->BB0_NUMCR     , oFont09)   	//-- Nome  + CRM
oPrint:say(li, nColIni+1350  , OemToAnsi(STR0020)            ,oFont09n)									//-- Observacao

li+= 50
BB8->(DbSetOrder(1))
BB8->(DbSeek(xFilial("BB8")+BEA->(BEA_CODRDA+BEA_OPERDA+ BEA_CODLOC+BEA_LOCAL )))
oPrint:say(li, nColIni       , OemToAnsi(STR0014)            ,oFont09n)										//-- Executante
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

oPrint:EndPage() 		// Finaliza a pagina

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fLogoEmp  �Autor  �RH - Natie          � Data �  02/18/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega logotipo da Empresa                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fLogoEmp( cLogo,cTipo)
Local  cStartPath	:= GetSrvProfString("Startpath","")
Default cTipo 	:= "1"

//-- Logotipo da Empresa
If cTipo =="1"
	cLogo := cStartPath + "\LGRL" +Alltrim(FWCompany())+ Alltrim(FWCodFil())+".BMP" 	// Empresa+Filial
	If !File( cLogo )
		cLogo := cStartPath + "\LGRL"+Alltrim(FWCompany())+".BMP" 				// Empresa
	endif
Else
	cLogo := cStartPath + "\LogoSiga.bmp"
Endif


Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fDrawBox    �Autor  �Microsiga           � Data �  03/06/03   ���
���������������������������������������������������������������������������͹��
���Desc.     �Desenha Box                                                   ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Imprime()
Local nCount		:= 0 
Local nLinDetMax	:= 10 									//-- Numero maximo de linhas detalhe
Local cPict			:= "@E 999,999,999.99"
Local lImpNAut	:= IIf(GetNewPar("MV_PLNAUT",0) == 0, .F., .T.) 

DbSelectArea("BEA")

/*��������������������������������������������������������������Ŀ
  �Impressao do Cabecalho                                        �
  ����������������������������������������������������������������*/
	fImpCabec()
    li := 280
/*��������������������������������������������������������������Ŀ
  �Dados do Usuario                                              |
  ����������������������������������������������������������������*/
	fDadosUsua(@li)
/*��������������������������������������������������������������Ŀ
  �Cabecalho do Detalhe                                          |
  ����������������������������������������������������������������*/
	fDetCabec(@li)


BQV->(DbSetOrder(1))
cChave	:= xFilial("BQV")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT )
If BQV->(DbSeek( cChave ) )
	While !BQV->(EOF()) .and. cChave==BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)   
		If !lImpNAut .And. BQV->BQV_STATUS == "0" 
			BQV->(dbSkip())
			Loop
		Endif
	
		If ncount =  nLinDetMax
			fImpRoda(@li)
			/*��������������������������������������������������������������Ŀ
			  �Impressao do Cabecalho                                        �
			  ����������������������������������������������������������������*/
				fImpCabec()
			    li := 280
			/*��������������������������������������������������������������Ŀ
			  �Dados do Usuario                                              |
			  ����������������������������������������������������������������*/
				fDadosUsua(@li)
			/*��������������������������������������������������������������Ŀ
			  �Cabecalho do Detalhe                                          |
			  ����������������������������������������������������������������*/
				fDetCabec(@li)
		Endif

		cDet	:= PLSPICPRO(BQV->BQV_CODPAD,BQV->BQV_CODPRO)

		oPrint:say(li,nColIni      ,cDet                                ,oFont09n   )	//-- AMB
		oPrint:say(li,nColIni+ 350 ,BQV->BQV_DESPRO                     ,oFont09    )	//-- Descricao

		If BQV->BQV_STATUS <> "1"
			oPrint:say(li,nColIni+ 1600 ,oemToAnsi(STR0023)             ,oFont09    )	//-- Status - Negado
		Else
			oPrint:say(li,nColIni+ 1600 ,oemToAnsi(STR0024)             ,oFont09    )	//-- Status	- Autorizado	
	    Endif   

		oPrint:say(li,nColIni+1800 ,Transform(BQV->BQV_QTDPRO,"@R 99") ,oFontMono10 )	//-- Qtde		
		oPrint:say(li,nColIni+1900 ,Transform(BQV->BQV_VLRAPR,cPict)    ,oFontMono10)    //-- Valor
		
		li 		+= 40
		nCount	++
		BQV->( DbSkip() )
	Enddo
EndIf                                                          

fImpRoda(@li)

Return