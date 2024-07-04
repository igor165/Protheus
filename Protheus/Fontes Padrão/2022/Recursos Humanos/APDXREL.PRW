#include "APDXREL.CH"
#include "PROTHEUS.CH"
#include "MSGRAPHI.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณCecilia Car.ณ04/07/14ณTPZWF1ณIncluido o fonte da 11 para a 12 e efetua-ณฑฑ
ฑฑณ            ณ        ณ      ณda a limpeza.                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณfStartGrafica ณ Autor ณ RH - Natie            ณ Data ณ 20/03/02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao generica iniciliazar impressao Grafica                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                                ณฑฑ
ฑฑณ        01ณ ExpO1 = Objeto grafico                                         ณฑฑ
ฑฑณ        02ณ ExpO2 = Titulo do Relatorio                                    ณฑฑ
ฑฑณ        03ณ ExpO3 = .T. -> Paisagem ; .F. - Retrato                        ณฑฑ
ฑฑณ        04ณ ExpO4 = Rotina a ser executada                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function  fStartGrafica(cTitulo, lLandScape, bProcesso  )

Private	nLinMax		:= 0
Private	nColMax		:= 0

Private  oCouNew07 :=TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)     //-- Modo Normal 
Private  oCouNew07N:=TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.) 	//-- Modo Negrito(5o parametro New() )  
Private  oCouNew08 :=TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
Private  oCouNew08N:=TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.) 
Private  oCouNew10 :=TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.) 
Private  oCouNew10N:=TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.) 
Private  oCouNew12 :=TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)             
Private  oCouNew12N:=TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.) 
Private  oCouNew15 :=TFont():New("Courier New",15,15,,.F.,,,,.T.,.F.) 
Private  oCouNew15N:=TFont():New("Courier New",15,15,,.T.,,,,.T.,.F.) 
Private  oCouNew21 :=TFont():New("Courier New",21,21,,.F.,,,,.T.,.T.) 
Private  oCouNew21N:=TFont():New("Courier New",21,21,,.T.,,,,.T.,.T.) 
Private  oArial08  :=TFont():New("Arial"      ,08,08,,.F.,,,,.T.,.F.) 
Private  oArial08N :=TFont():New("Arial"      ,08,08,,.T.,,,,.T.,.F.) 
Private  oArial12  :=TFont():New("Arial"      ,12,12,,.F.,,,,.T.,.F.) 
Private  oArial12N :=TFont():New("Arial"      ,12,12,,.T.,,,,.T.,.F.) 		
Private  oArial16  :=TFont():New("Arial"      ,16,16,,.F.,,,,.T.,.F.) 
Private  oArial16N :=TFont():New("Arial"      ,16,16,,.T.,,,,.T.,.F.)

_SetOwnerPrvt("oPrint", )


//-- Objeto para Impressao grafica
oPrint 	:= TMSPrinter():New( cTitulo )

If  lLandScape
	oPrint  :SetLandScape()		//Modo paisagem
	nLinMax	:= 2500
	nColMax	:= 3100
Else
	oPrint  :SetPortrait()		//Modo retrato
	nLinMax	:= 3100
	nColMax	:= 2350
Endif	

oPrint  :StartPage() 			//Inicia uma nova pagina
If bProcesso !=NIL 
	eval( bProcesso )
Endif 
oPrint:EndPage() 	   			// Finaliza a pagina
oPrint:Preview()  				// Visualiza antes de imprimir

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprGraf  บAutor  ณMicrosiga           บ Data ณ  18/02/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrio ณ Linha Detalhe   								              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ 						                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cDetalhe	 = Detalhe p/impressao                            ณฑฑ
ฑฑบ          ณ cFimFolha = F->Fim Folha                                   บฑฑ
ฑฑบ          ณ             P->Fim Pagina                                  บฑฑ
ฑฑบ          ณ nReg      = Numero de Registros a Serem Impressos no Rodapeบฑฑ
ฑฑบ          ณ nColun    = Coluna para impressao da linha detalhe         บฑฑ
ฑฑบ          ณ lSalta    = Incrementa ou nao o salto de linha             บฑฑ
ฑฑบ          ณ oFont     = Fonte padrao                                   บฑฑ
ฑฑบ          ณ lLandScape= .T.-> paisagem / .F.->Retrato                  บฑฑ
ฑฑบ          ณ bCbcEspecif= Cabeclaho especifico do relartorio            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ImprGraf( cDetalhe , cFimFolha , nReg , cRoda , nColun , lSalta , oFont ,lLandScape, bCbcEspecif )
Local aCabec := {}
Local cDetCab:= ""
Local cWCabec:= ""
Local nCb	 := 0

Static lPerg

DEFAULT cDetalhe	:= IF( cDetalhe			== NIL							  		, ""		, cDetalhe	)
DEFAULT cFimFolha	:= IF( cFimFolha		== NIL							  		, ""		, cFimFolha	)
DEFAULT nReg		:= IF( nReg				== NIL							  		, 0.00		, nReg		)
DEFAULT nColun 		:= IF( nColun			== NIL							  		, 0			, nColun	)
DEFAULT lSalta		:=  .T.
DEFAULT oFont		:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.) 			//--oCouNew08
DEFAULT lLandScape	:= IF( lLandScape       == NIL							  		, .T. 		, lLandScape)
DEFAULT	bCbcEspecif	:= NIL

wCabec0 	:= IF( Type("wCabec0")	== "U"							  		, 0			, wCabec0	)
wCabec1 	:= IF( Type("wCabec1")	== "U"							  		, ""		, wCabec1	)
wCabec2 	:= IF( Type("wCabec2")	== "U"							  		, ""		, wCabec2	)
wCabec3 	:= IF( Type("wCabec3")	== "U"							  		, ""		, wCabec3	)
wnRel		:= IF( Type("wnRel")	== "U" .and. Type("nomeprog") != "U"	, nomeprog	, wnRel		)
ContFl		:= IF( Type("ContFl")  == "U" , 1   , ContFl   )
Li			:= IF( Type("Li")	    == "U" , 0   , Li		)
nTamanho	:= IF( Type("nTamanho")== "U" , "P" , nTamanho )
nChar		:= IF( Type("nChar")   == "U" , 18 , nChar     ) 						// Quando nao for compactado nChar deve ser Nil para tratamento da Cabec.
m_pag		:= ContFl

IF Upper(cFimFolha) $ "FP" .or. li >= nLinMax
	IF li != 0.00
		IF Upper(cFimFolha) $ "F" .or. cRoda != NIL
			IF nReg == 0.00 .or. cRoda == NIL
				fRodaPeGraf( 0.00 , ""    , lLandScape)
			Else
				fRodaPeGraf( nReg , cRoda , lLandScape)
			EndIF
		EndIF
		Li := 0.00
		oPrint:EndPage()
	EndIF
	IF Upper(cFimFolha) $ "FP"
	    oPrint:EndPage() 	   													//-- Finaliza a pagina
		Return( NIL )
	EndIF
EndIF

IF Li == 0.00
	oPrint:StartPage() 															//--Inicia uma nova pagina
	SendCabGraf( )
	For nCb := 1 to wCabec0
		IF Type((cWCabec := "wCabec"+Alltrim(Str(nCb)))) != "U"
			cDetCab := &(cWCabec)
			aAdd(aCabec,cDetCab)
		EndIf
	Next nCb
	CabecGraf( cTitulo , "" , "" , wnrel , nTamanho ,aCabec, lPerg , bCbcEspecif 	)
	Li 		+= 50
	ContFl++
EndIF                         

//-- Imprime linha de detalhe
oPrint:say(Li,nColun,cDetalhe,oFont)

IF lSalta
	Li += 50
Endif

nColuna	:= nColun

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSendCabGrafบAutor  ณMicrosiga           บ Data ณ  18/12/02   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SendCabGraf()

Local cDetCab 	:= ""
Local nEspaco 	:= 0
Local cFileLogo	:= ""

//-- Carrega Logotipo para impressao 
fLogoEmp(@cFileLogo)

Li 	+= 20
// Nome da Empresa / Pagina  / Logotipo
oPrint:Line(li,50,li,nColMax)
If File(cFilelogo)
	li += 50
	oPrint:SayBitmap(li,50, cFileLogo,400,090) 		//-- Tem que estar abaixo do RootPath
Endif	
cDetCab 	:= RptFolha +" " + TRANSFORM(m_pag,'999999')
li 			+= 75 
oPrint:say(li , nColMax- 400  ,cDetCab,oCouNew10)

// Versใo     
cDetCab := "SIGA /"+wnrel+"/v."+cVersao+"  "
li 			+= 50 
oPrint:say(li ,50 ,cDetCab,oCouNew10)

//-- Titulo
cDetCab := Trim(cTitulo)
nEspaco	:= (nColMax - Len(AllTrim(cTitulo)) *100 / 6 ) / 2
oPrint:say(li , nEspaco , cDetCab, oCouNew12n)

cDetCab :=  RptDtRef +" "+ DTOC(dDataBase)
oPrint:say(li ,nColMax- 400,cDetCab,oCouNew10)

// Hora da emissใo / Data Emissao
cDetCab := RptHora+" "+time()
li 			+= 50
oPrint:say( li ,50,cDetCab,oCouNew10)

cDetCab := RptEmiss+" "+DToC(MsDate())
oPrint:say( li ,nColMax- 400,cDetCab,oCouNew10)
li 			+= 50 
oPrint:Line(li ,50,li,nColMax)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLogoEmp  บAutor  ณRH - Natie          บ Data ณ  02/18/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fLogoEmp( cLogo,cTipo)
Local  cStartPath	:= GetSrvProfString("Startpath","")
Default cTipo 	:= "1"

//-- Logotipo da Empresa
If cTipo =="1"
	cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+FWGETCODFILIAL+".BMP" 	// Empresa+Filial
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP" 				// Empresa
	endif
Else		
	cLogo := cStartPath + "LogoSiga.bmp"
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCabecGraf บAutor  ณMicrosiga - Natie   บ Data ณ  20/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrio ณ Cabecalho       								              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ 						                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cTitulo 	= titulo relatorio                                ณฑฑ
ฑฑบ          ณ cCabec1  =                                                 บฑฑ
ฑฑบ          ณ cCabe                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION CabecGraf(cTitulo,cCabec1,cCabec2,cNomPrg,nTamanho,aCustomText,lPerg, bCbcEspecif)

Local nCustom  	:= 0

Default aCustomText := Nil 								// Parametro que se passado suprime o texto padrao desta fun็ใo por outro customizado

cTitulo := Iif(TYPE("NewHead")!="U",NewHead,cTitulo)
cNomPrg := Alltrim(cNomPrg)
	
//Box Itens
oPrint:Box( li, 30, nLinMax + 50 , nColMax )
                  
Li		+= 50
nColuna	:= 50
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Imprime texto de outro cabecalho passado no array            ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
If  Len(aCustomText) > 0
	For nCustom  := 1 to len(aCustomText)
		oPrint:say(Li,ncoluna,aCustomText[nCustom],oCouNew10)
		Li += 50
	Next nCustom
	li += 50
	oPrint:Line(Li,nColuna-20,Li,nColMax)	
Endif

nColuna := 50

If Len(Trim(cCabec1)) != 0
	Li  += 50
	oPrint:say(Li,nColuna, cCabec1,oCouNew12)  
	If LEN(Trim(cCabec2)) != 0
		oPrint:say(Li,nColuna, cCabec2,oCouNew12)
	EndIf 
	oPrint:Line(Li,nColuna-20,Li,nColMax)
	Li+=50
EndIf

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Imprime Cabecalho especifico (qdo necessแrio posicionar campos )   |
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
If  bCbcEspecif != NIL
	Eval(  bCbcEspecif )
EndIF

m_pag++
Return Li

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfRodaPeGrafบAutor  ณMicrosiga           บ Data ณ  02/19/02   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Rodape Grafico                                       บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fRodaPeGraf(wcbcont,lLandScape)

Local cFileLogo	:= ""

//-- Carrega Logotipo para impressao
fLogoEmp(@cFileLogo,"2")

oPrint:Line(nLinMax+060,050,nLinMax+060,nColMax)			      	// Linha horizontal
IF File(cFilelogo)
	oPrint:SayBitmap(nLinMax + 080,50, cFileLogo,300,080) 			// Tem que estar abaixo do RootPath
Endif
oPrint:say(nLinMax +110,nColMax-  400 , RptEnd+" "+Time(),oCouNew08)
oPrint:Line(nLinMax+150,050,nLinMax+150,nColMax)			      	// Linha horizontal 
oPrint:EndPage()

Return
                     

Function  ImprTraco()

Default lGrafica := .T.

If lGrafica
	oPrint:line(li,ncol+050,li, nColMax-050)
Else
	Impr( __PrtThinLine() , "C")
Endif	

Return