#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "VDFR060.CH"

#DEFINE VBOX      080
#DEFINE VSPACE    003
#DEFINE HSPACE    005
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   014
#DEFINE VMARGEM   030
#DEFINE MAXITEM   Max((022-Max(0,Len(aMensagem)-02)),1)
#DEFINE MAXITEMP2 055
#DEFINE MAXMENLIN 070
#DEFINE HSPCBOX   003
#DEFINE VSPCBOX   001
#DEFINE RMARGEM   592
#DEFINE LMARGBOX  007

// Constantes para identificar o tipo de impressão.
#DEFINE IMP_DISCO 1
#DEFINE IMP_SPOOL 2
#DEFINE IMP_PORTA 3
#DEFINE IMP_EMAIL 4
#DEFINE IMP_HTML  5
#DEFINE IMP_PDF   6

Static aUltChar2pix
Static aUltVChar2pix
Static cVdCert1 := SuperGetMv("MV_VDCERT1",,"")//MINISTÉRIO PÚBLICO DO ESTADO DE MATO GROSSO
Static cVdCert2 := SuperGetMv("MV_VDCERT2",,"")//PROCURADORIA - GERAL DE JUSTIÇA
Static cVdCert3 := SuperGetMv("MV_VDCERT3",,"")//DEPARTAMENTO DE GESTÃO DE PESSOAS
Static cVdCert4 := SuperGetMv("MV_VDCERT4",," - MPE")
Static cVdCert5 := SuperGetMv("MV_VDCERT5",,"/MT")


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ VDFR060  ³ Autor ³Tania Bronzeri         ³ Data ³05/12/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Certidão de Tempo de Contribuição                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VDFR060(cRaFilial,cRaMat,cNumCert,cTpImpr,cVia)

Local aAreaSRA	:= GetArea("SRA")
Local aAreaRIE	:= GetArea("RIE")
Local aAreaRIF	:= GetArea("RIF")
Local aAreaRIG	:= GetArea("RIG")

Local nCount		:= 0
Local nAcTpBru		:= 0
Local nAcFaltas	:= 0
Local nAcLicen		:= 0
Local nAcLicSb		:= 0
Local nAcSuspe		:= 0
Local nAcDispo		:= 0
Local nAcOutra		:= 0
Local nAcTpLiq		:= 0
Local nAcAvTot		:= 0
Local nAcLfTot		:= 0
Local cAux         := ""

//-- Variaveis Private
Private cAlsRif	:= GetNextAlias()
Private cAlsRig	:= GetNextAlias()
Private cAlsLfRi	:= GetNextAlias()
Private oCerTmp
Private nFolhas	:= 0
Private nFolhAtu	:= 1
Private nMM		:= 0
Private nPixLin	:= 0
Private nPixCol	:= 0

//Variaveis declaradas também na função VDFR060A
Private cStartPath	:= GetSrvProfString("Startpath","")
Private cLogoTp  		:= cStartPath + "LogoCGL.bmp"
Private nLInic		:= 0 		// Linha Inicial
Private nCol		:= 0
Private nTBox		:= 0
Private nLBox		:= 0
Private nBBox		:= 0
Private nRBox		:= 0
Private nSoma		:= 15
Private nColMed	:= Int((RMARGEM - LMARGBOX) / 2)	// Meio da Folha
Private nIdText	:= (nColMed * 1.20) + HSPCBOX
Private nId2Div	:= (nColMed * 1.60) + HSPCBOX
Private aInfo		:= {}

Private nDifCol	:= 65
Private nCAno		:= LMARGBOX
Private nCTpBru	:= nDifCol
Private nFaltas	:= nDifCol * 2
Private nCLic		:= nDifCol * 3
Private nCLicSub	:= nDifCol * 4
Private nCSus		:= nDifCol * 5
Private nCDisp		:= nDifCol * 6
Private nCOutras	:= nDifCol * 7
Private nCTpLiq	:= nDifCol * 8
Private nCASess	:= LMARGBOX
Private nCAData	:= nCTpBru + (HSPACE * 2) + 8
Private nCAOrga	:= nDifCol * 2
Private nCAPeri	:= nCLicSub
Private nCATot		:= nCOutras
Private cOCTDocAnt	:= ''

//-- Fontes utilizadas no relatório
Private oFont05	:= TFont():New("Arial",05,05,,.F.,,,,.T.,.F.)
Private oFont06	:= TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
Private oFont06N  := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
Private oFont07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
Private oFont07N  := TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
Private oFont08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Private oFont08N	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oFont08I	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.,.T.)
Private oFont09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
Private oFont09N	:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Private oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFont10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFont11	:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
Private oFont11N	:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
Private oFont12	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont12N	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Private oFont16N	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Private oTFon12N	:= TFont():New("Times New Roman",12,12,,.F.,,,,.T.,.F.)
Private oTFon14N	:= TFont():New("Times New Roman",14,14,,.F.,,,,.T.,.F.)
Private oTFon16N	:= TFont():New("Times New Roman",16,16,,.F.,,,,.T.,.F.)
Private oCNFon10	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
Private oCNFon11	:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ INICIO ROTINA DE IMPRESSAO                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilePrint	:= STR0001 + Dtos(MSDate()) +"_" + StrTran(Time(),":","")             //"Certidão_"
lAdjustToLegacy := .T. // Mantem compatibilidade com TMSPRINTER
oCerTmp := FWMSPrinter():New(cFilePrint, IMP_PDF,/*lAdjustToLegacy*/.F.,/*cPathInServer*/,.T.,.F.,@oCerTmp,/*cPrinter*/,/*lServer*/,.F.,.F.,.T.,/*nQtdPags*/)
oCerTmp:SetResolution(72) // Tamanho 72 conforme orientação do TDN
oCerTmp:SetPortrait()
oCerTmp:SetPaperSize(DMPAPER_A4)
oCerTmp:SetMargin(03,01,03,03) // nEsquerda, nSuperior, nDireita, nInferior
//oCerTmp:Setup() PERGUNTE DOS PARAMENTROS DE IMPRESSAO FWPRINTE

nPixLin	:= oCerTmp:nLogPixelX()
nPixCol	:= oCerTmp:nLogPixelY()
nMM     := 0

oCerTmp:StartPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controla o documento a ser enviado para montagem do cabecalho.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCount += 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao responsavel por montar o cabecalho do relatorio                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFolhAtu := 1
lSeqDes  :=.F.
Vdfr60Cab(oCerTmp)

DbSelectArea("RIE")
DbSetOrder(1)
DbSeek(cRaFilial+cRaMat)


// Cria Arquivo de Trabalho - Certidão
BeginSql alias cAlsRif
	SELECT	RIF.*
	FROM	%table:RIF% RIF
	WHERE 	RIF.%notDel% And RIF_FILIAL = %exp:cRaFilial% And RIF_MAT = %exp:cRaMat%
	ORDER BY RIF_FILIAL, RIF_MAT, RIF_ANO
EndSql


DbSelectArea("RIG")
DbSetOrder(1)
DbSeek(cRaFilial+cRaMat)


// Cria Arquivo de Trabalho - Averbações
BeginSql alias cAlsRig
	SELECT	RIG.*
	FROM	%table:RIG% RIG
	WHERE 	RIG.%notDel% And RIG_FILIAL = %exp:cRaFilial% And RIG_MAT = %exp:cRaMat%
			And RIG_TIPAVE = '1'
	ORDER BY RIG_FILIAL, RIG_MAT, RIG_PERDE
EndSql


// Cria Arquivo de Trabalho - Licenças e Férias
BeginSql alias cAlsLfRi
	SELECT	RIG.*
	FROM	%table:RIG% RIG
	WHERE 	RIG.%notDel% And RIG_FILIAL = %exp:cRaFilial% And RIG_MAT = %exp:cRaMat%
			And RIG_TIPAVE = '2'
	ORDER BY RIG_FILIAL, RIG_MAT, RIG_PERDE
EndSql

nLInic += nSoma
//"C E R T I D Ã O   D E   T E M P O   D E   C O N T R I B U I Ç Ã O"
oCerTmp:SayAlign(nLInic, HMARGEM, Upper(STR0002) + " "+ IIF(cVia=="2"," ("+cVia+"ª via)",IIF( "REI" $ cVia ,"("+cVia+")","")), oFont16N,590,20,,2,0 )

Cab060Imp(oCerTmp)

nTBox  := nLInic + VSPCBOX
nBBox	:= nTBox + nSoma + VSPCBOX
nLInic	:= nBBox - VSPACE

nLInic += (Int(nSoma /3) - (VSPCBOX * 2))
oCerTmp:SayAlign(nLInic, HMARGEM, Upper(STR0003), oFont10N, 590,20,,2,1)  //"1 - Frequência"

nTBox	:= nLInic + Int(nSoma * 0.75) + VSPCBOX
nLInic += nSoma
nBBox	:= nLInic + Int(nSoma * 2.5) + VSPCBOX
oCerTmp:Line(nTBox, nLBox  , nTBox, nRBox  )				//Top    Box 1 - Frequencia
oCerTmp:Line(nTBox, nCAno  , nBBox, nCAno  )				//Left   Box 1 - Frequencia
oCerTmp:Line(nTBox, nRBox  , nBBox, nRBox  )				//Right  Box 1 - Frequencia
oCerTmp:Line(nBBox, nLBox  , nBBox, nRBox  )				//Bottom Box 1 - Frequencia
oCerTmp:Line(nTBox, nCTpBru, nBBox, nCTpBru)				//Divise Ano / Tempo Bruto
oCerTmp:Line(nTBox, nFaltas , nBBox, nFaltas )				//Divise Tempo Bruto / Deduções
oCerTmp:Line(nTBox, nCTpLiq, nBBox, nCTpLiq)				//Divise Deduções / Tempo Líquido
oCerTmp:SayAlign(nLInic, nCTpBru, STR0004     , oFont09N, 65,2,,2,1)		//"Tempo"
oCerTmp:SayAlign(nLInic, HMARGEM, Upper(STR0005), oFont08N,590,2,,2,1)   //"Deduções"
oCerTmp:SayAlign(nLInic, nCTpLiq, STR0004     , oFont09N, 65,2,,2,1)     //"Tempo"
nLInic	+= nSoma
nTBox	:= nLInic + VSPCBOX
oCerTmp:Line(nTBox, nFaltas, nTBox, nCTpLiq)				//Divise Deduções / Faltas e Licenças
oCerTmp:Line(nTBox, nCLic  , nBBox, nCLic  )				//Divise Faltas / Licenças
oCerTmp:Line(nTBox, nCLicSub, nBBox, nCLicSub  )			//Divise Licença / Licença sem SubSidio
oCerTmp:Line(nTBox, nCSus  , nBBox, nCSus  )				//Licenças sem SubSidio / Suspensões
oCerTmp:Line(nTBox, nCDisp  , nBBox, nCDisp  )				//Suspensões / Outras
oCerTmp:Line(nTBox, nCOutras , nBBox, nCOutras )				//Outras / Soma

oCerTmp:SayAlign(nLInic, nCAno  , STR0006       	, oFont09N, 65,2,,2,1)    //"Ano"
oCerTmp:SayAlign(nLInic, nCTpBru, STR0007    	, oFont09N, 65,2,,2,1)        //"Bruto"
oCerTmp:SayAlign(nLInic + 2, nFaltas, STR0008, oFont09N,65,2,,2,1)           //"Faltas"
oCerTmp:SayAlign(nLInic, nCTpLiq, STR0009   , oFont09N, 65,2,,2,1)         //"Líquido"
nLInic	+= Int(nSoma / 2)
nTBox	:= nLInic + Int(nSoma / 2) + VSPCBOX
oCerTmp:Line(nTBox, nFaltas , nBBox, nFaltas)				//Faltas
oCerTmp:Line(nTBox - 3, nFaltas, nTBox - 3, nCLic)		//Divide Faltas e Licencas
oCerTmp:SayAlign(nLInic, nCLic  , STR0010  , oFont09N, 65,2,,2,1)              //"Licenças"
oCerTmp:SayAlign(nLInic - 3, nCLicSub, STR0011  , oFont09N, 65,2,,2,1)   	//"Licenças sem"
oCerTmp:SayAlign(nLInic, nCSus  , STR0012, oFont09N, 65,2,,2,1)     		//"Suspensões"
oCerTmp:SayAlign(nLInic, nCDisp , STR0013	, oFont09N, 65,2,,2,1) 	//"Disponibilidade"
oCerTmp:SayAlign(nLInic, nCOutras , STR0014      		, oFont09N, 65,2,,2,1)   //"Outros"
oCerTmp:SayAlign(nLInic, nCTpLiq, STR0015    , oFont09N, 65,2,,2,1)  //"(dias)"
nLInic	+= (Int(nSoma / 2)) - 2
oCerTmp:SayAlign(nLInic, nFaltas , STR0016, oFont09N, 65,2,,2,1)   //"não Just."
oCerTmp:SayAlign(nLInic, nCLicSub + 2, STR0017, oFont09N, 65,2,,2,1)  //"Subsídios"


DbSelectArea(cAlsRif)
DbGoTop()
While (cAlsRif)->(!EOF())
	Vd60Break(oCerTmp)
	nTBox	:= nBBox
	nBBox	:= nTBox + nSoma
	nLInic	:= nBBox - nSoma
	oCerTmp:Line(nTBox,nCTpBru, nBBox, nCTpBru)				//Divise Ano / Tempo Bruto
	oCerTmp:Line(nTBox,nFaltas , nBBox, nFaltas)				//Faltas Justificadas / Faltas Não Justificadas
	oCerTmp:Line(nTBox,nCLic  , nBBox, nCLic  )				//Faltas / Licenças
	oCerTmp:Line(nTBox,nCLicSub, nBBox, nCLicSub )			//Licenca / Licenças com Subsidio
	oCerTmp:Line(nTBox,nCSus  , nBBox, nCSus  )				//Licenças / Suspensões
	oCerTmp:Line(nTBox,nCDisp  , nBBox, nCDisp  )				//Suspensões / Outras
	oCerTmp:Line(nTBox,nCOutras , nBBox, nCOutras )			//Outras / Soma
	oCerTmp:Line(nTBox,nCTpLiq, nBBox, nCTpLiq)				//Soma / Tempo Líquido
	oCerTmp:Line(nTBox,nLBox  , nTBox, nRBox  )				//Moldura Top do Quadro
	oCerTmp:Line(nTBox,nCAno  , nBBox, nCAno  )				//Moldura Left do Quadro
	oCerTmp:Line(nTBox,nRBox  , nBBox, nRBox  )				//Moldura Right do Quadro
	oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro
	oCerTmp:SayAlign(nLInic, nCAno  	, (cAlsRif)->RIF_ANO   , oFont09, 65,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCTpBru	, Alltrim(Str((cAlsRif)->RIF_TMPBRU)), oFont09, 65,2,,2,1)
	oCerTmp:SayAlign(nLInic, nFaltas 	, Alltrim(Str((cAlsRif)->RIF_FALNJU)), oFont09, 65,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCLic  	, Alltrim(Str((cAlsRif)->RIF_LICENC)), oFont09, 65,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCLicSub	, Alltrim(Str((cAlsRif)->RIF_LICSUB)), oFont09, 65,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCSus  	, Alltrim(Str((cAlsRif)->RIF_SUSPEN)), oFont09, 65,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCDisp  	, Alltrim(Str((cAlsRif)->RIF_DISPON)), oFont09, 65,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCOutras 	, Alltrim(Str((cAlsRif)->RIF_OUTRAS)), oFont09, 65,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCTpLiq	, Alltrim(Str((cAlsRif)->RIF_TMPLIQ)), oFont09, 65,2,,2,1)

	nAcTpBru	+= (cAlsRif)->RIF_TMPBRU
	nAcFaltas	+= (cAlsRif)->RIF_FALNJU
	nAcLicen	+= (cAlsRif)->RIF_LICENC
	nAcLicSb	+= (cAlsRif)->RIF_LICSUB
	nAcSuspe	+= (cAlsRif)->RIF_SUSPEN
	nAcDispo	+= (cAlsRif)->RIF_DISPON
	nAcOutra	+= (cAlsRif)->RIF_OUTRAS
	nAcTpLiq	+= (cAlsRif)->RIF_TMPLIQ

	(cAlsRif)->(DbSkip())
EndDo

nTBox	:= nBBox
nBBox	:= nTBox + nSoma
nLInic	:= nBBox - nSoma
oCerTmp:Line(nTBox,nCTpBru, nBBox, nCTpBru)				//Divise Ano / Tempo Bruto
oCerTmp:Line(nTBox,nFaltas , nBBox, nFaltas )				//Divise Tempo Bruto / Faltas
oCerTmp:Line(nTBox,nCLic  , nBBox, nCLic  )				//Faltas / Licenças
oCerTmp:Line(nTBox,nCLicSub, nBBox, nCLicSub)				//Licenças / Licenca sem Subsidio
oCerTmp:Line(nTBox,nCSus  , nBBox, nCSus  )				//Licenças / Suspensões
oCerTmp:Line(nTBox,nCDisp  , nBBox, nCDisp  )				//Suspensões / Outras
oCerTmp:Line(nTBox,nCOutras , nBBox, nCOutras )				//Outras / Soma
oCerTmp:Line(nTBox,nCTpLiq, nBBox, nCTpLiq)				//Soma / Tempo Líquido
oCerTmp:Line(nTBox,nCAno  , nBBox, nCAno  )				//Moldura Left do Quadro
oCerTmp:Line(nTBox,nRBox  , nBBox, nRBox  )				//Moldura Right do Quadro
oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro
oCerTmp:SayAlign(nLInic, nCAno  	, Upper(STR0018), oFont09, 65,2,,2,1) //"Total"
oCerTmp:SayAlign(nLInic, nCTpBru	, Alltrim(Str(nAcTpBru)), oFont09, 65,2,,2,1)
oCerTmp:SayAlign(nLInic, nFaltas 	, Alltrim(Str(nAcFaltas)), oFont09, 65,2,,2,1)
oCerTmp:SayAlign(nLInic, nCLic  	, Alltrim(Str(nAcLicen)), oFont09, 65,2,,2,1)
oCerTmp:SayAlign(nLInic, nCLicSub	, Alltrim(Str(nAcLicSb)), oFont09, 65,2,,2,1)
oCerTmp:SayAlign(nLInic, nCSus  	, Alltrim(Str(nAcSuspe)), oFont09, 65,2,,2,1)
oCerTmp:SayAlign(nLInic, nCDisp  	, Alltrim(Str(nAcDispo)), oFont09, 65,2,,2,1)
oCerTmp:SayAlign(nLInic, nCOutras 	, Alltrim(Str(nAcOutra )), oFont09, 65,2,,2,1)
oCerTmp:SayAlign(nLInic, nCTpLiq	, Alltrim(Str(nAcTpLiq)), oFont09, 65,2,,2,1)

Vd60Break(oCerTmp)
nLInic += (Int(nSoma * 1.25) - (VSPCBOX * 2))
oCerTmp:SayAlign(nLInic, HMARGEM, Upper(STR0019), oFont10N, 590,20,,2,1)    //"2 - Averbação de Tempo de Contribuição em Outras Repartições"

nTBox	:= nLInic + Int(nSoma * 0.75) + VSPCBOX
nLInic += nSoma
nBBox	:= nLInic + nSoma + VSPCBOX
oCerTmp:Line(nTBox, nLBox  , nTBox, nRBox  )				//Top    Box 2 - Averbações
oCerTmp:Line(nTBox, nCASess, nBBox, nCASess)				//Left   Box 2 - Averbações
oCerTmp:Line(nTBox, nRBox  , nBBox, nRBox  )				//Right  Box 2 - Averbações
oCerTmp:Line(nBBox, nLBox  , nBBox, nRBox  )				//Bottom Box 2 - Averbações
oCerTmp:Line(nTBox, nCAData, nBBox, nCAData)				//Divise Sessão / Data
oCerTmp:Line(nTBox, nCAOrga, nBBox, nCAOrga)				//Divise Data / Orgão
oCerTmp:Line(nTBox, nCAPeri, nBBox, nCAPeri)				//Divise Orgão / Período
oCerTmp:Line(nTBox, nCATot , nBBox, nCATot )				//Divise Período / Total
oCerTmp:SayAlign(nLInic, nCASess, Upper(STR0020 ), oFont09N,  65,2,,2,1)     //"Sessão"
oCerTmp:SayAlign(nLInic, nCAData, Upper(STR0021   ), oFont09N,  50,2,,2,1)    //"Data"
oCerTmp:SayAlign(nLInic, nCAOrga, Upper(STR0022  ), oFont09N, 130,2,,2,1)     //"Órgão"
oCerTmp:SayAlign(nLInic, nCAPeri, Upper(STR0023), oFont09N, 195,2,,2,1)     //"Período"
oCerTmp:SayAlign(nLInic, nCATot , Upper(STR0024  ), oFont09N, 130,2,,2,1)    //"Total"


DbSelectArea(cAlsRig)
DbGoTop()
While (cAlsRig)->(!EOF())
	Vd60Break(oCerTmp)
	nTBox	:= nBBox
	nLInic	:= nBBox

	oCerTmp:SayAlign(nLInic, nCASess, 	Left((cAlsRig)->RIG_SESSAO,20)    , oFont07,  80,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCAData, dtoc(stod((cAlsRig)->RIG_DTAVERB)), oFont08, 50,4,,2,1)
	oCerTmp:SayAlign(nLInic, nCAOrga, 	Left((cAlsRig)->RIG_ORGEXP,30)    , oFont08, 130,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCAPeri, 	dtoc(stod((cAlsRig)->RIG_PERDE)) + " A " + dtoc(stod((cAlsRig)->RIG_PERATE)), oFont08, 195,4,,2,1)
	oCerTmp:SayAlign(nLInic, nCATot , 	Alltrim(Str((cAlsRig)->RIG_TMPLIQ)) + "." + R060Util((cAlsRig)->RIG_TMPLIQ), oFont09, 130,4,,2,1)
	If ! Empty(AllTrim(Substr((cAlsRig)->RIG_SESSAO,21,10) + Substr((cAlsRig)->RIG_ORGEXP,31,30)))
		nLInic	+= nSoma
		oCerTmp:SayAlign(nLInic, nCASess, Substr((cAlsRig)->RIG_SESSAO,21,10), oFont07,  65,2,,2,1)
		oCerTmp:SayAlign(nLInic, nCAOrga, Substr((cAlsRig)->RIG_ORGEXP,31,30), oFont08, 130,2,,2,1)
	EndIf

	nBBox:= nLInic + nSoma
	oCerTmp:Line(nTBox,nCAData, nBBox, nCAData)				//Divise Sessão / Data
	oCerTmp:Line(nTBox,nCAOrga, nBBox, nCAOrga)				//Divise Data / Orgão
	oCerTmp:Line(nTBox,nCAPeri, nBBox, nCAPeri)				//Divise Orgão / Período
	oCerTmp:Line(nTBox,nCATot , nBBox, nCATot )				//Divise Periodo / Total
	oCerTmp:Line(nTBox,nLBox  , nTBox, nRBox  )				//Moldura Top do Quadro
	oCerTmp:Line(nTBox,nLBox  , nBBox, nLBox  )				//Moldura Left do Quadro
	oCerTmp:Line(nTBox,nRBox  , nBBox, nRBox  )				//Moldura Right do Quadro
	oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro

	nAcAvTot	+= (cAlsRig)->RIG_TMPLIQ
	(cAlsRig)->(DbSkip())
EndDo

nTBox	:= nBBox
nBBox	:= nTBox + nSoma
nLInic	:= nBBox - nSoma
oCerTmp:Line(nTBox,nLBox  , nTBox, nRBox  )				//Moldura Top do Quadro
oCerTmp:Line(nTBox,nLBox  , nBBox, nLBox  )				//Moldura Left do Quadro
oCerTmp:Line(nTBox,nRBox  , nBBox, nRBox  )				//Moldura Right do Quadro
oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro

oCerTmp:SayAlign(nLInic, nCASess, Upper(STR0025), oFont09, 65,2,,2,1)      //"Soma"
cAux := "-*-"
If nAcAvTot > 0
	cAux := Alltrim(Str(nAcAvTot)) + "." + R060Util(nAcAvTot)
EndIf
oCerTmp:SayAlign(nLInic, nCATot , cAux, oFont09, 130,2,,2,1)

Vd60Break(oCerTmp)
nLInic += (Int(nSoma * 1.25) - (VSPCBOX * 2))
oCerTmp:SayAlign(nLInic, HMARGEM, Upper(STR0026), oFont10N, 590,20,,2,1)      //"3 - Averbação Simples ou em Dobro de Licença-Prêmio e Férias Não Gozadas"

nTBox	:= nLInic + Int(nSoma * 0.75) + VSPCBOX
nLInic += nSoma
nBBox	:= nLInic + nSoma + VSPCBOX
oCerTmp:Line(nTBox, nLBox  , nTBox, nRBox  )				//Top    Box 2 - Averbações
oCerTmp:Line(nTBox, nCASess, nBBox, nCASess)				//Left   Box 2 - Averbações
oCerTmp:Line(nTBox, nRBox  , nBBox, nRBox  )				//Right  Box 2 - Averbações
oCerTmp:Line(nBBox, nLBox  , nBBox, nRBox  )				//Bottom Box 2 - Averbações
oCerTmp:Line(nTBox, nCAData, nBBox, nCAData)				//Divise Sessão / Data
oCerTmp:Line(nTBox, nCAOrga, nBBox, nCAOrga)				//Divise Data / Orgão
oCerTmp:Line(nTBox, nCAPeri, nBBox, nCAPeri)				//Divise Orgão / Período
oCerTmp:Line(nTBox, nCATot , nBBox, nCATot )				//Divise Período / Total
oCerTmp:SayAlign(nLInic, nCASess, Upper(STR0020 ), oFont09N,  65,2,,2,1)     //"Sessão"
oCerTmp:SayAlign(nLInic, nCAData, Upper(STR0021   ), oFont09N,  50,2,,2,1)		//"Data"
oCerTmp:SayAlign(nLInic, nCAOrga, Upper(STR0022  ), oFont09N, 130,2,,2,1)		//"Órgão"
oCerTmp:SayAlign(nLInic, nCAPeri, Upper(STR0023), oFont09N, 195,2,,2,1)      //"Período"
oCerTmp:SayAlign(nLInic, nCATot , Upper(STR0024  ), oFont09N, 130,2,,2,1)       //"Total"

DbSelectArea(cAlsLfRi)
DbGoTop()
While (cAlsLfRi)->(!EOF())
	Vd60Break(oCerTmp)
	nTBox	:= nBBox
	nLInic	:= nBBox

	oCerTmp:SayAlign(nLInic, nCASess, Left((cAlsLfRi)->RIG_SESSAO,20)    , oFont07,  80,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCAData, dtoc(stod((cAlsLfRi)->RIG_DTAVERB)) , oFont08,  50,4,,2,1)
	oCerTmp:SayAlign(nLInic, nCAOrga, Left((cAlsLfRi)->RIG_ORGEXP,30)    , oFont08, 130,2,,2,1)
	oCerTmp:SayAlign(nLInic, nCAPeri, dtoc(stod((cAlsLfRi)->RIG_PERDE)) + " A " + dtoc(stod((cAlsLfRi)->RIG_PERATE)), oFont08, 195,4,,2,1)
	oCerTmp:SayAlign(nLInic, nCATot , Alltrim(Str((cAlsLfRi)->RIG_TMPLIQ)) + "." + R060Util((cAlsLfRi)->RIG_TMPLIQ), oFont09, 130,4,,2,1)
	If ! Empty(AllTrim(Substr((cAlsLfRi)->RIG_SESSAO,21,10) + Substr((cAlsLfRi)->RIG_ORGEXP,31,30)))
		nLInic	+= nSoma
		oCerTmp:SayAlign(nLInic, nCASess, Substr((cAlsLfRi)->RIG_SESSAO,21,10), oFont07,  65,2,,2,1)
		oCerTmp:SayAlign(nLInic, nCAOrga, Substr((cAlsLfRi)->RIG_ORGEXP,31,30), oFont08, 130,2,,2,1)
	EndIf

	nBBox:= nLInic + nSoma
	oCerTmp:Line(nTBox,nCAData, nBBox, nCAData)				//Divise Sessão / Data
	oCerTmp:Line(nTBox,nCAOrga, nBBox, nCAOrga)				//Divise Data / Orgão
	oCerTmp:Line(nTBox,nCAPeri, nBBox, nCAPeri)				//Divise Orgão / Período
	oCerTmp:Line(nTBox,nCATot , nBBox, nCATot )				//Divise Periodo / Total
	oCerTmp:Line(nTBox,nLBox  , nTBox, nRBox  )				//Moldura Top do Quadro
	oCerTmp:Line(nTBox,nLBox  , nBBox, nLBox  )				//Moldura Left do Quadro
	oCerTmp:Line(nTBox,nRBox  , nBBox, nRBox  )				//Moldura Right do Quadro
	oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro
	nAcLfTot	+= (cAlsLfRi)->RIG_TMPLIQ
	(cAlsLfRi)->(DbSkip())
EndDo

nTBox	:= nBBox
nBBox	:= nTBox + nSoma
nLInic	:= nBBox - nSoma
oCerTmp:Line(nTBox,nLBox  , nTBox, nRBox  )				//Moldura Top do Quadro
oCerTmp:Line(nTBox,nLBox  , nBBox, nLBox  )				//Moldura Left do Quadro
oCerTmp:Line(nTBox,nRBox  , nBBox, nRBox  )				//Moldura Right do Quadro
oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro

oCerTmp:SayAlign(nLInic, nCASess, Upper(STR0025), oFont09, 65,2,,2,1)     //"Soma"
cAux := "-*-"
If nAcLfTot > 0
	cAux := Alltrim(Str(nAcLfTot)) + "." + R060Util(nAcAvTot)
EndIf
oCerTmp:SayAlign(nLInic, nCATot, cAux, oFont09, 130,2,,2,1)

nTBox	:= nBBox
nBBox	:= nTBox + nSoma
nLInic	:= nBBox - nSoma
oCerTmp:Line(nTBox,nLBox  , nTBox, nRBox  )				//Moldura Top do Quadro
oCerTmp:Line(nTBox,nLBox  , nBBox, nLBox  )				//Moldura Left do Quadro
oCerTmp:Line(nTBox,nRBox  , nBBox, nRBox  )				//Moldura Right do Quadro
oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro

oCerTmp:SayAlign(nLInic, nCASess, Upper(STR0027), oFont09, 65,2,,2,1)    //"Soma Geral"
cAux := "1= " + AllTrim(Str(nAcTpLiq)) + " + 2= "
If nAcAvTot > 0
	cAux += AllTrim(Str(nAcAvTot))
Else
	cAux += "-*-"
EndIf
cAux += " + 3= "
If nAcLfTot > 0
	cAux += AllTrim(Str(nAcLfTot))
Else
	cAux += "-*-"
EndIf
cAux += STR0028 + AllTrim(Str(nAcTpLiq + nAcAvTot + nAcLfTot)) + STR0029 + R060Util(nAcTpLiq + nAcAvTot + nAcLfTot)   //" => Totalizando " ##" dias "

oCerTmp:SayAlign(nLInic, nCAData, cAux, oFont10N, 525,2,,2,1)

Vd60Break(oCerTmp)

//Impressão do memo
nLInic += (Int(nSoma * 1.25) - (VSPCBOX * 2))

PrintLine(oCerTmp, oCNFon11, 114, AllTrim(RIE->RIE_TXTCER), HMARGEM)

nTBox		:= nBBox + 1
nLargBox	:= nTBox
nBBox		:= nTBox + nSoma
nMergem	:= 7
oCerTmp:Box(nTBox,nLBox,nLargBox+0140,nRBox  )

oCerTmp:Say(nLargBox+0015,HMARGEM + HSPACE,STR0030,oFont10N)       //"Lavrei a Certidão que não contém emendas nem rasuras."

oCerTmp:Say(nLargBox+0025,HMARGEM + HSPACE,	Alltrim(SM0->M0_CIDENT) + ", " + StrZero(Day(dDataBase), 2) + STR0031 +;    //" de "
													MesExtenso(Month(dDataBase)) + STR0031 + Str(Year(dDataBase), 4) + ".",oFont10N)  //" de "

oCerTmp:SayAlign(nLargBox+0060,nMergem,alltrim(RIE->RIE_NOMDGP),oFont11N, 590,2,,2,1)
oCerTmp:SayAlign(nLargBox+0070,nMergem,alltrim(RIE->RIE_CRGDGP),oFont10, 590,2,,2,1)

oCerTmp:SayAlign(nLargBox+0110,nMergem,alltrim(RIE->RIE_NOMDIR),oFont11N, 590,2,,2,1)
oCerTmp:SayAlign(nLargBox+0120,nMergem,alltrim(RIE->RIE_CRGDIR),oFont10, 590,2,,2,1)

oCerTmp:Box(nLargBox+0140,nLBox,nLargBox+0220,nRBox  )
oCerTmp:Say(nLargBox+0150,HMARGEM + HSPACE,	Alltrim(SM0->M0_CIDENT) + ", " + StrZero(Day(dDataBase), 2) + STR0031 +;   //" de "
													MesExtenso(Month(dDataBase)) + STR0031 + Str(Year(dDataBase), 4) + ".",oFont10N)//" de "

oCerTmp:SayAlign(nLargBox+0190,nMergem,alltrim(RIE->RIE_NOMPGJ),oFont11N, 590,2,,2,1)
oCerTmp:SayAlign(nLargBox+0200,nMergem,alltrim(RIE->RIE_CRGPGJ),oFont10, 590,2,,2,1)

oCerTmp:SayAlign(nLargBox+0230,LMARGBOX,STR0032,oFont10N, 590,2,,2,1)     //E S T A   C E R T I D Ã O   N Ã O   C O N T É M   E M E N D A S   N E M   R A S U R A S

oCerTmp:EndPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TERMINO ROTINA DE IMPRESSAO                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCerTmp:Preview()

(cAlsRif)->(dbCloseArea())

RestArea(aAreaSRA)
RestArea(aAreaRIE)
RestArea(aAreaRIF)
RestArea(aAreaRIG)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Cab060Imp ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 17.07.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do cabeçalho da certidão (usado na relação de sub- ³±±
±±³          ³ sidios)                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cab060Imp(oCerTmp)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Cab060Imp(oCerTmp)

Local cNumCert := RIE->RIE_CERNUM

fInfo(@aInfo,cFilant)

nLInic  += nSoma
nBBox	:= nLInic + VSPCBOX
nTBox	:= nBBox  + VSPCBOX
nLBox	:= LMARGBOX
nBBox	:= nTBox + Int(nSoma * 2) + VSPCBOX
nRBox	:= RMARGEM

oCerTmp:Box(nTBox, nLBox, nBBox, nRBox)							//Box Nome Servidor	(99,7,122.5,592)
oCerTmp:Line(nTBox, nIDText, nBBox, nIDText)						// 2 Colunas Identificação
oCerTmp:Line(nTBox, nID2Div, nBBox - (VSPACE * 6), nID2Div)		// Divisão da coluna da esquerda
nLInic	:= nBBox - (VSPACE * 4)
oCerTmp:Say(nLInic                , HMARGEM, Upper(cVdCert1 +' '+ cVdCert4+ cVdCert5), oFont10)
oCerTmp:Say(nLInic - (VSPACE * 3), nIDText + HSPACE * 8, 'N.º ' + cNumCert, oFont10n)
oCerTmp:Say(nLInic - (VSPACE * 3), nID2Div + HSPACE * 4, Str(Year(dDataBase)), oFont10n)

oCerTmp:Line(nLInic - (VSPACE * 2), nIDText, nLInic - (VSPACE * 2), RMARGEM)	// Linha entre o número/ano e CNPJ
oCerTmp:Say(nLInic + 5, nIDText + HSPACE, STR0033 + Transform(aInfo[08],"@R 99.999.999/9999-99"), oFont08)            //"CNPJ: "

nTBox	:= nBBox + VSPCBOX
nBBox	:= nTBox + nSoma + VSPCBOX
nLInic	:= nBBox - VSPACE

oCerTmp:Line(nLInic - 14, LMARGBOX, nLInic + 2, LMARGBOX)	// Lado Direito Nome do Servidor, Sexo e Matricula
cRieEx	:= Iif(Empty(RIE->RIE_DEMISS),"","EX-")
oCerTmp:Say(nLInic - 3, HMARGEM, STR0034 + cRieEx + STR0035 + Upper(RIE->RIE_NOME), oFont08)  //"NOME DO " ## "SERVIDOR: "
oCerTmp:Line(nTBox - 1, nIDText, nBBox, nIDText)				// 2 Colunas Identificação
cAux := If(RIE->RIE_SEXO == "F", STR0036, STR0037)  //"FEMININO"##"MASCULINO"
oCerTmp:Say(nLInic - 3, nIDText + (HSPACE * 8), STR0038 + cAux, oFont08)   //"SEXO: "

cAux := STR0039 + RIE->RIE_MAT                 //"MATRICULA: "
nColAux := RMARGEM - (HSPACE * (Len(cAux) - 1))
oCerTmp:Line(nTBox, nColAux - (HSPACE * 2), nBBox - 2, nColAux - (HSPACE * 2))		// Divisão Sexo e Matricula
oCerTmp:Say(nLInic - 3, nColAux, cAux, oFont08)
oCerTmp:Line(nLInic - 14, RMARGEM, nLInic + 2, RMARGEM)		// Lado Esquerdo Nome do Servidor, Sexo e Matricula

nTBox  := nLInic + VSPCBOX
nBBox	:= nTBox + nSoma + VSPCBOX
nLInic	:= nBBox - VSPACE

oCerTmp:Line(nTBox, nLBox  , nTBox, nRBox  )					// Acima Rg, Orgao Expedidor, Cpf e Pis/Pasep
oCerTmp:Line(nLInic - 14, LMARGBOX, nLInic + 2, LMARGBOX)	// Lado Direito Rg, Orgao Expedidor, Cpf e Pis/Pasep
oCerTmp:Say(nLInic - 3, HMARGEM, STR0040 + AllTrim(RIE->RIE_RG) + " - " + AllTrim(RIE->RIE_RGORG) + "/" + AllTrim(RIE->RIE_RGUF), oFont08)       //"N.º RG/ORGÃO EXPEDIDOR: "
oCerTmp:Line(nTBox, nIDText, nBBox, nIDText)					// 2 Colunas Identificação
cAux := STR0041 + Trans(RIE->RIE_CPF, "@R 999.999.999-99")       //"CPF: "
oCerTmp:Say(nLInic - 3, nIDText + HSPACE, cAux, oFont08)

nColAux := nIdText + ((Len(cAux) + 2) * HSPACE)
oCerTmp:Line(nTBox, nColAux - (HSPACE * 2), nBBox - 2, nColAux - (HSPACE * 2))		// Divisão CPF e PIS/PASEP

oCerTmp:Say(nLInic - 3, nColAux + HSPACE, STR0042 + RIE->RIE_PASEP, oFont08)        //"PIS/PASEP: "
oCerTmp:Line(nLInic - 14, RMARGEM, nLInic + 2, RMARGEM)		// Lado Esquerdo Rg, Orgao Expedidor, Cpf e Pis/Pasep

nTBox := nLInic + 2
oCerTmp:Line(nTBox, nLBox  , nTBox, nRBox  )					// Acima Filiação e Data de Nascimento

nTBox  := nLInic + VSPCBOX
nBBox	:= nTBox + nSoma + VSPCBOX
nLInic	:= nBBox - VSPACE

oCerTmp:Line(nLInic - 14, LMARGBOX, nLInic + 2, LMARGBOX)	// Lado Direito Filiação e Data de Nascimento
cAux := AllTrim(RIE->RIE_MAE)
If ! Empty(RIE->RIE_PAI)
 	cAux += " / " + AllTrim(RIE->RIE_PAI)
 EndIf
oCerTmp:Say(nLInic - 3, HMARGEM, STR0043 + cAux, oFont08)      //"FILIAÇÃO: "
oCerTmp:Line(nTBox, nIDText, nBBox - 1, nIDText)				// 2 Colunas Identificação
oCerTmp:Say(nLInic - 3, nIDText + HSPACE, STR0044 + Dtoc(RIE->RIE_NASC), oFont08) //"DATA DE NASCIMENTO: "
oCerTmp:Line(nLInic - 14, RMARGEM, nLInic + 2, RMARGEM)		// Lado Esquerdo Filiação e Data de Nascimento

nTBox := nLInic + 2
nBox  := nTBox
oCerTmp:Line(nTBox, nLBox  , nTBox, nRBox  )					// Acima Procuradoria, Cep e UF

cAux := AllTrim(RIE->RIE_DEPTOR) + " - " + AllTrim(RIE->RIE_ENDR) + "/ " + AllTrim(RIE->RIE_MAILR)
PrintLine(oCerTmp, oCNFon11, 65, cAux, HMARGEM)

oCerTmp:Line(nBox, nIDText, nBBox, nIDText)				// 2 Colunas Identificação
cAux := STR0045 + Trans(RIE->RIE_CEP, "@R 99999-999")              //"CEP: "
oCerTmp:Say(nBox + (nBBox - nBox) / 2, nIDText + HSPACE, cAux, oFont08)

nColAux := nIdText + ((Len(cAux) + 7) * HSPACE)
oCerTmp:Line(nBox, nColAux, nBBox - 1, nColAux)				// Divisão CPF e PIS/PASEP

nColAux += HSPACE
oCerTmp:Say(nBox + (nBBox - nBox) / 2, nColAux, "UF: " + AllTrim(RIE->RIE_MUNICI) + "/" + RIE->RIE_ESTADO, oFont08)

nBox := nBBox
cAux := STR0046 + alltrim(RIE->RIE_DDEPTO)    //"ORGAO DE LOTAÇÃO: "
If ! Empty(RIE->RIE_COMARC)
	cAux += STR0047 + RIE->RIE_COMARC  //" DA COMARCA "
EndIf
PrintLine(oCerTmp, oCNFon11, 40, cAux, nIDText + HSPACE)

oCerTmp:Say(nBox + (nBBox - nBox) / 2, HMARGEM, STR0048 + alltrim(RIE->RIE_DCARGO), oFont08)  //"CARGO EFETIVO: "
oCerTmp:Line(nBox, nIDText, nBBox, nIDText)				// Divisão Cargo Efetivo e Orgão de Lotação

nLInic	:= nBBox - VSPACE

nLInic := nLInic + 3
nTBox  := nLInic + VSPCBOX
nBBox	:= nTBox + nSoma + VSPCBOX
nLInic	:= nBBox - VSPACE

oCerTmp:Line(nLInic - 14, LMARGBOX, nLInic + 2, LMARGBOX)	// Lado Direito Data de Admissao e Exoneracao
oCerTmp:Say(nLInic - 3, HMARGEM, STR0049 + Dtoc(RIE->RIE_ADMISS), oFont08)       //"DATA DE ADMISSAO: "
nColAux := nIDText - (HSPACE * 12)
oCerTmp:Line(nTBox, nColAux, nBBox, nColAux)					// 2 Colunas Identificação
cAux := STR0050               //"DATA DE EXONERAÇÃO/DEMISSÃO: "
If ! Empty(RIE->RIE_DEMISS)
	cAux += STR0051 + Dtoc(RIE->RIE_DEMISS + 1)    //"A PARTIR DE "
EndIf
oCerTmp:Say(nLInic - 3, nColAux + HSPACE, cAux, oFont08)
oCerTmp:Line(nLInic - 14, RMARGEM, nLInic + 2, RMARGEM)		// Lado Esquerdo Data de Admissao e Exoneracao

nTBox := nLInic + 3
nBox  := nTBox
oCerTmp:Line(nTBox, nLBox  , nTBox, nRBox  )					// Acima Periodo de contribuição

PrintLine(oCerTmp, oCNFon11, 114, STR0052 + DtoC(RIE->RIE_DTCTDE) + " A " + DtoC(RIE->RIE_DTCTAT), HMARGEM)     //"PERÍODO DE CONTRIBUIÇÃO COMPREENDIDO NESTA CERTIDÃO: "

PrintLine(oCerTmp, oCNFon11, 114, STR0053 + AllTrim(RIE->RIE_FONTE), HMARGEM)           //"FONTE DE INFORMAÇÃO: "

PrintLine(oCerTmp, oCNFon11, 114, STR0054 + AllTrim(RIE->RIE_ORGDES), HMARGEM)          //"DESTINAÇAO DO TEMPO DE CONTRIBUIÇÃO: "

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AntDUtil ³ Autor ³ Marcos Pereira          ³ Data ³ 06.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Para calculo da quantidade de anos, mês e dias               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R060Util(nTempo)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function R060Util(nTempo)
Local nDias   := 0
Local nAnos   := 0
Local nMeses  := 0
Default nTempo:= 0

nAnos	:= NoRound(nTempo/365,0)  //Fator divisor de 365 dias por ano, conforme regra do MP
nTempo	-= nAnos*365
nMeses	:= NoRound(nTempo/30,0)
nTempo	-= nMeses*30
nDias	:= nTempo

Return "(" + Strzero(nAnos,2) + "a." + Strzero(nMeses,2) + "m." + Strzero(nDias,2) + "d.)"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PrintLine ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 04.07.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime linha montando realizando quebra de linha de  acordo ³±±
±±³          ³ com o tamanho do texto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintLine(oCerTmp, oFonte, nTLin, cTexto, nMargem)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PrintLine(oCerTmp, oFonte, nTLin, cTexto, nMargem)

Local nICer     := 0
Local nDifSp 	 := nPos := 0
Local cMemoImp := cMemoLin := cSpace := ""
Local aPrint  	 := {}, lTraco := .F.

If Len(AllTrim(cTexto)) > 0
	cTexto     := StrTran(cTexto, "chr(192)", Chr(192))	//-- ENTER
	cTexto     := StrTran(cTexto, "chr(193)", Chr(193))	//-- TRACO
	cMemoLin	:= cTexto

	For nICer	:= 1 to Len(AllTrim(cTexto))
		Vd60Break(oCerTmp)
		nTBox	:= nBBox
		nBBox	:= nTBox + nSoma
		nLInic	:= nBBox - nSoma
		cSpace	:= "X"
		nDifSp	:= 0

		cMemoImp := Left(cMemoLin, nTLin)

		// -- Procura por TRACO
		lTraco := .F.
		If (nPos := (At(Chr(193), cMemoImp) + 1)) > 1
			cMemoImp := Left(AllTrim(cMemoImp), At(Chr(192), AllTrim(cMemoImp)) - 1)
			lTraco := .T.
		// -- Procura por ENTER
		ElseIf (nPos := (At(Chr(192), cMemoImp) + 1)) > 1
			cMemoImp := Left(AllTrim(cMemoImp), At(Chr(192), AllTrim(cMemoImp)) - 1)
		Else
			Do While !(Empty(cSpace))
				cSpace := Substr(cMemoLin, (nTLin - nDifSp - 1), 1)
				nDifSp++
			EndDo

			nDifSp	  := Iif(nDifSp > 0, (nDifSp+1), nDifSp)
			cMemoImp := Left(AllTrim(cMemoLin), nTLin-nDifSp)
			nPos     := Len(Left(cMemoLin, nTLin-nDifSp)) + 1
		EndIf

		If ! Empty(cMemoImp)
			oCerTmp:Line(nTBox,nLBox  , nBBox, nLBox  )				//Moldura Left do Quadro
			oCerTmp:Line(nTBox,nRBox  , nBBox, nRBox  )				//Moldura Right do Quadro
			oCerTmp:SayAlign(nLInic, nMargem, cMemoImp, oFonte, 590,2,,0,1)
		EndIf
		If lTraco
			oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )
		EndIf

		nICer	  += nPos
		cMemoLin := Substr(cMemoLin, nPos, Len(cMemoLin))

	 	Aadd(aPrint, cMemoImp)
	Next nICer
	oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro
EndIf

Return

/*/
/*/
Function Vdfr60Cab(oCerTmp)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: Cabeçalho                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

fInfo(@aInfo,cFilant)

nLInic := 0
oCerTmp:SayBitmap(nLInic, 20, cLogoTp, 60, 48)	//
nLInic	+= nSoma
oCerTmp:Say(nLInic, 92,Iif(Empty(cVdCert1),aInfo[3],cVdCert1),oTFon16N)	//"Ministério Público do Estado de Mato Grosso"
nLInic	+= nSoma
oCerTmp:Say(nLInic, 92,cVdCert2,oTFon16N)	//"Procuradoria-Geral de Justiça"
nLInic	+= nSoma
oCerTmp:Say(nLInic, 92,cVdCert3,oTFon16N)	//"Departamento de Gestão de Pessoas - DGP"

Return

Function Vd60Break(oCerTmp)
If nLInic > 700
	oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro
	oCerTmp:EndPage()
   	oCerTmp:StartPage()
	Vdfr60Cab(oCerTmp)
	nLInic  += nSoma
	nBBox	:= nLInic
	oCerTmp:Line(nBBox,nLBox  , nBBox, nRBox  )				//Moldura Bottom do Quadro
EndIf

Return Nil
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} VDFR060A()
Relação dos subsidios de contribuições
@protected
@author        Everson S.P Junior
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function VDFR060A(cRaFilial,cRaMat,cVia)
Local lAdjustToLegacy := .F., aArea := GetArea()

Private nLin      := 0
//Variaveis declaradas também na função VDFR060
Private cStartPath	:= GetSrvProfString("Startpath","")
Private cLogoTp  		:= cStartPath + "LogoCGL.bmp"
Private nLInic		:= 0 		// Linha Inicial
Private nCol		:= 0
Private nTBox		:= 0
Private nLBox		:= 0
Private nBBox		:= 0
Private nRBox		:= 0
Private nSoma		:= 15
Private nColMed	:= Int((RMARGEM - LMARGBOX) / 2)	// Meio da Folha
Private nIdText	:= (nColMed * 1.20) + HSPCBOX
Private nId2Div	:= (nColMed * 1.60) + HSPCBOX
Private aInfo		:= {}

//-- Fontes utilizadas no relatório
Private nLargLin		:= "-1"
Private oFont06		:= TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
Private oFont06N    	:= TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
Private oFont07		:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
Private oFont07N    	:= TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
Private oFont08		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Private oFont08N		:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oFont08I		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.,.T.)
Private oFont09		:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
Private oFont09N		:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Private oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFont10N		:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFontD 		:= TFont():New("Arial",  ,07,,.F.)
Private oFont11		:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
Private oFont11N		:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
Private oCNFon11		:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.)
Private oFont12		:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont12n		:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont14N		:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Private oFont16N		:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Private oTFon16N		:= TFont():New("Times New Roman",16,16,,.F.,,,,.T.,.F.)
Private oPrint

RptStatus({|| LayBOX(@oPrint,cRaFilial,cRaMat,cVia)})

If ValType(oPrint) == 'O'
	oPrint:Print()
Else
	MsgStop(STR0055)  //"Não há dados para imprimir."
EndIf

RestArea(aArea)

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} LayBOX(oPrint)
Impressao do Relatório
@protected
@author        Everson S.P Junior
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Static Function LayBOX(oPrint,cRaFilial,cRaMat,cVia)
Local nLin    		:= 0000
Local nLinBack		:= 0
Local nX,nAno,nTotAno:= 0
Local nY			:= 0
Local nCol			:= 0000
Local nIni			:= 0
Local nL			:= 0
Local aMes 		:= {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Local Mv_Mes		:= SuperGetMv("MV_IMPPORC",,"")

DbSelectArea("RIE")
DbSetOrder(1)
DbSeek(cRaFilial+cRaMat)

cFilePrint 	 	:= "CTRC_"+cEmpAnt+"_"+cFilAnt+"_"+Dtos(MSDate())+"_"+StrTran(Time(),":","")
lAdjustToLegacy 	:= .F.
oPrint	    		:= FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, , .T.)
oPrint:SetResolution(72) // Tamanho 72 conforme orientação do TDN
oPrint:SetPortrait()
oPrint:SetPaperSize(DMPAPER_A4)
oPrint:SetMargin(03,01,03,03)
//oPrint:Setup()
If Empty(RIE->RIE_DEMISS)
	dDemissa := dDataBase
Else
	dDemissa := RIE->RIE_DEMISS
EndIf

nTotAno := ceiling(((Year(dDemissa) - Year(RIE->RIE_ADMISS))+1) / 4)   //Arredonda sempre pra cima
dData := If(Empty(RIE->RIE_DTSOLI), dDataBase, RIE->RIE_DTSOLI)

//================
QueryRIH(cRaFilial,cRaMat)
//================
For nAno := 1 To nTotAno
	If nLin >= 582 .Or. nAno == 1
		oPrint:EndPage()
		oPrint:StartPage()
		Vdfr60Cab(oPrint)

		nLInic += 7
		oPrint:SayAlign(nLInic, HMARGEM, STR0056+ " "+ IIF(cVia=="2"," ("+cVia+"ª via)",IIF( "REI" $ cVia ,"("+cVia+")","")), oFont16N,590,20,,2,0 )    //"RELAÇÃO DOS SUBSIDIOS E CONTRIBUIÇÕES PREVIDENCIÁRIAS"
		nLInic += nSoma

		oPrint:SayAlign(nLInic, HMARGEM, STR0057+ TRBRIH->RIH_CERNUM +", "+dTOC(dData), oFont07,590,20,,2,0 )     //"REFERENTE À CERTIDÃO DE TEMPO DE CONTRIBUIÇÃO N° "

		Cab060Imp(oPrint)

		nLin := nBBox - 090
		nColBack := nCol
	EndIf

	nLinBack := nLin

	For nY := 1 To 4
		//MEs
		If	nY == 1
			oPrint:Box( nLin+0100, 0010, nLin+0120, 0050 ,nLargLin)
			oPrint:Say( nLin+0116, 0012, "MÊS", oFont10)       //"MÊS"
			oPrint:Box( nLin+0120, 0010, nLin+0170, 0050 ,nLargLin)
			For nX:= 1 To 6
				oPrint:Say( nLin+0128+nl, 0015,SUBSTR(Mv_Mes,01+nIni,6), oFont08)
				nL += 0008
				nIni += 6
			Next
		EndIf
		//Ano:
		nLin := nLinBack
		oPrint:Box( nLin+0100,nCol+0050, nLin+0120, IIF(nY== 4,nCol+0173+0052 ,nCol+0173) ,nLargLin)
		oPrint:Say( nLin+0116,nCol+0052, STR0059+ TRBRIH->RIH_ANO, oFont10)          //"Ano: "

		oPrint:Box( nLin+0120,nCol+0050, nLin+0170, nCol+0110 ,nLargLin)
		oPrint:Say( nLin+0130,nCol+0062, STR0060, oFont08)                      //"Valor do"
		oPrint:Say( nLin+0140,nCol+0062, STR0061, oFont08)                      //"Subsídio"
		oPrint:Say( nLin+0160,nCol+0062, STR0062, oFont08)                      //"em reais"

		oPrint:Box( nLin+0120,nCol+0110, nLin+0170, IIF(nY== 4,nCol+0173+0052 ,nCol+0173) ,nLargLin)
		oPrint:Say( nLin+0130,nCol+0122, STR0063, oFont08)                  //"Contribuição"
		oPrint:Say( nLin+0140,nCol+0122, STR0064, oFont08)                //"Previdenciária"
		oPrint:Say( nLin+0160,nCol+0122, STR0065, oFont08)	                   //"em reais"

		For nX:= 1 To 12

			oPrint:Box( nLin+0170,nCol+0050, nLin+0184,nCol+0110 ,nLargLin)
			oPrint:Say( nLin+0180,nCol+0050, IIF(TRBRIH->RIH_SUBMES == 0,'XXXXXXX',Transform(	TRBRIH->RIH_SUBMES,"@E 999,999,999.99 ")), oFont09)//Valor do Sub
			oPrint:Box( nLin+0170,nCol+0110, nLin+0184,IIF(nY== 4,nCol+0173+0052 ,nCol+0173 ),nLargLin)
			oPrint:Say( nLin+0180,nCol+0112, IIF(TRBRIH->RIH_PREVID == 0,'XXXXXXX',Transform(TRBRIH->RIH_PREVID,"@E 999,999,999.99 ")), oFont09)//Contribui Previ
			If nY == 1
				oPrint:Box( nLin+0170,nCol+0010, nLin+0184,nCol+0050 ,nLargLin)
				oPrint:Say( nLin+0180,nCol+0012, aMes[nX], oFont09)//mês
			EndIf
			nLin+=0014
			TRBRIH->(DBSKIP())
		Next
			nCol+=0122
	Next
	nCol := nColBack
	nLin += 73
Next

nLin 	 := nLin - 0020
nMergem := 7

//Rodapé
oPrint:Box( nLin+0130,0010, nLin+0174, 0592 ,nLargLin)

oPrint:Say( nLin+144,nCol+0012,STR0066, oFont11N) //'HOMOLOGO '
oPrint:Say( nLin+144,nCol+0065,STR0067, oFont11) //o presente e declaro que as informações nele constantes correspondem com a verdade.
oPrint:Say( nLin+164,nCol+0012,AllTrim(SM0->M0_CIDENT)+", "+ALLTRIM(STR(Day(dData)))+" de "+MesExtenso(Month(dData))+" de "+ALLTRIM(STR(Year(dData))), oFont08)

oPrint:Box( nLin+0193,0010, nLin+0284, 0592 ,nLargLin)
oPrint:Line(nLin+0193,0296, nLin+0284, 0296  )

oPrint:SayAlign(nLin+0253,nMergem,alltrim(RIE->RIE_NOMSB1),oFont11N, 590/2,2,,2,1)
oPrint:SayAlign(nLin+0263,nMergem,alltrim(RIE->RIE_CRGSB1),oFont10, 590/2,2,,2,1)

oPrint:SayAlign(nLin+0253,nMergem + (nRBox/2),alltrim(RIE->RIE_NOMSB2),oFont11N, 590/2,2,,2,1)
oPrint:SayAlign(nLin+0263,nMergem + (nRBox/2),alltrim(RIE->RIE_CRGSB2),oFont10, 590/2,2,,2,1)

oPrint:Say( nLin+0294,nCol+0160,STR0068, oFont11) //ESTE DOCUMENTO NÃO CONTÉM EMENDAS NEM RASURAS

oPrint:EndPage()
TRBRIH->(dbcloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |QueryRIH³ Autor ³Everson S P          ³ Data ³04/12/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Query usada para imprimir o relatorio						  ³±±
±±³          ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   |                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QueryRIH(cRaFilial,cRaMat)
Local cQuery := ""

If Select('TRBRIH')>0
   TRBRIH->( dbCloseArea() )
Endif

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("RIH") +  " RIH "
cQuery += " where "
cQuery += " RIH.RIH_FILIAL = '"+cRaFilial+"' AND "
cQuery += " RIH.RIH_MAT = '"+cRaMat+"' AND "
cQuery += " D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY RIH_ANO, RIH_MES "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),'TRBRIH',.T.,.T.)

Return
