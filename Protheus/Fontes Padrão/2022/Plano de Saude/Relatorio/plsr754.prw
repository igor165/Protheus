
#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define _LF Chr(13)+Chr(10) // Quebra de linha.
#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25
#Define __NTAM5  38
#Define __NTAM6  15
#Define __NTAM7  5
#Define __NTAM8  9
#Define __NTAM9  7
#Define __NTAM10 30
#Define __NTAM11 8
#Define __NTAM12 7  

#define G_CONSULTA  "01"
#define G_SADT_ODON "02"
#define G_SOL_INTER "03"
#define G_REEMBOLSO "04"
#define G_RES_INTER "05"
#define G_HONORARIO "06"
#define G_ANEX_QUIM "07"
#define G_ANEX_RADI "08"
#define G_ANEX_OPME "09"
#define G_REC_GLOSA "10"
#define G_PROR_INTE "11"

STATIC oFnt10C 		:= TFont():New("courier",10,10,,.f., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("courier",18,18,,.t., , , , .t., .f.)
Static objCENFUNLGP := CENFUNLGP():New()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR754    ºAutor  ³Paulo Carnelossi   º Data ³  21/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relacao de autorizacoes e negativas ocorridas por   º±±
±±º          ³RDA em determinado periodo por operadora                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR754(cCodRda,cLocRda,lWeb,aParWeb,cDirPath,cProtocolo, lAutoma)
LOCAL lCent 		:= __SetCentury() // Salva formato ano/data 2 ou 4 digitos
local aParW2		:= {}
DEFAULT cCodRda		:= ""
DEFAULT cLocRda		:= ""
DEFAULT lWeb			:= .f.
DEFAULT aParWeb		:= {}
DEFAULT cDirPath		:= lower(getMV("MV_RELT"))
DEFAULT cProtocolo  	:= ""
default lAutoma 	:= .f.

PRIVATE cTitulo 		:= FunDesc() //"Relação de Autorizações"
PRIVATE cPerg       	:= Padr("PLR754",Len(SX1->X1_GRUPO))
PRIVATE oReport     	:= nil
PRIVATE cFileName		:= lower("mvtorda"+CriaTrab(NIL,.F.))
PRIVATE nTweb			:= 2.9
PRIVATE nLweb			:= 10
PRIVATE aRetWeb		:= {}
PRIVATE aRet 			:= {"",""}
PRIVATE nLeft			:= 40
PRIVATE nRight			:= 2100
PRIVATE nCol0  		:= nLeft
PRIVATE nTop			:= 100
PRIVATE nTopInt		:= nTop
PRIVATE nPag			:= 1

__SetCentury( "off" )   // habilita ano para 2 digitos
//Print
If !lWeb
	//Acessa parametros do relatorio...
	if !pergunte(cPerg,.T.)
		return
	endIf
endIf

oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)

oReport:lInJob  	:= lWeb
oReport:lServer 	:= lWeb
oReport:cPathPDF	:= cDirPath

oReport:setDevice(IMP_PDF)
oReport:setResolution(72)
oReport:SetLandscape()
oReport:SetPaperSize(9)
oReport:setMargin(05,05,05,05)

If !lWeb
	oReport:Setup()

	If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
		aRet := {"",""}
		Return(aRet)
	EndIf
endIf

if (lAutoma .and. valtype(aParWeb) == "A")
	aParW2 := aParWeb
endif

lRet := PLSR754Imp(oReport,lWeb,aParWeb,cProtocolo,aParW2)

if lRet
	aRet := {cFileName+".pdf",""}
else
	aRet := {"",""}
endif

oReport:EndPage()
oReport:Print()

//Checa se o arquivo PDF esta ponto para visualizacao na web e envio de e-mail.
if lWeb .and. !lAutoma
	PLSCHKRP(cDirPath+cFileName+".pdf")
endIf

__SetCentury(If(lCent,"on","off")) // Retorna formato ano salvo anteriormente 2 ou 4 digitos

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLSR754Imp³ Autor ³ Paulo Carnelossi      ³ Data ³ 07/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Impressao relacao de autor. internacao/SADT no periodo      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³PLSR754Imp(lEnd,nRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSR754Imp(oReport,lWeb,aParWeb,cProtocolo,aParW2,lGerPag,cContCa,lFmrTxt,cTipGui, lVlrApr)
LOCAL nTotRda		:= 0
LOCAL nTotGeral		:= 0
LOCAL nQtdAutE		:= 0
LOCAL nQtdNegE		:= 0
LOCAL nQtdAutC		:= 0
LOCAL nQtdNegC		:= 0
LOCAL nQtdTAutE		:= 0
LOCAL nQtdTNegE		:= 0
LOCAL nQtdTAutC		:= 0
LOCAL nQtdTNegC		:= 0
LOCAL nTot			:= 0
LOCAL nColAux		:= 0
LOCAL nQtd			:= 0
LOCAL cSQL			:= ""
LOCAL cCodRDA		:= ""
LOCAL cLocRDA		:= ""
LOCAL cCodGlo   	:= ""
LOCAL cMsg			:= ""
LOCAL lTitulo		:= .f.
LOCAL lConsult  	:= .F.
LOCAL lRet			:= .T.
LOCAL cNumGuia		:= "" 
local cRetTxt		:= Encode64("<div class='txt'> <h2 class='titulo'> Não foi possível gerar a Consulta </h2> </div>")
LOCAL nPosTotal     := 0 
LOCAL nQtdReg		:= 0 
LOCAL nSomaItem		:= 0
LOCAL aDadosIte			:= {}
Local cValOrig		:= ""
local cValorPag		:= ""
local lTipVlAp      := GetNewPar("MV_TIPVLAP",.T.) 

DEFAULT oReport     := nil
DEFAULT cContCa    	:= ""
DEFAULT cProtocolo	:= ""
DEFAULT aParW2	   	:= {}
DEFAULT lGerPag		:= .T.
Default lFmrTxt     := .f.
Default cTipGui		:= ""
default lVlrApr		:= .f.

	aAlias := {"BD5","BEA","BD6","BEJ"}
	objCENFUNLGP:setAlias(aAlias)

/*
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Extrato de Utilização
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RDA : 000161 - CENTRO DE IMAGEM DIAGNOSTICOS S/C LTDA
Periodo de.: 10/12/12 a 08/01/13
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Data Proc. 	Tipo Guia	Num Guia	Matricula 				Nome do Beneficiario   				Procedimento	QTD. 	CID		Negado	Motivo
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

10/12/2012	SP/SADT	20120900000345	0001.0001.011606.00-5	CLAUDIO DELANDRE ELIAS 				41101227   		1  		M511 	N
10/12/2012	SP/SADT	20120900000456	0001.0001.005766.00-4 	DEBORA FONSECA RESENDE MARTINS 		41001044   		1	 			S  		Atendimento cancelado
10/12/2012	SP/SADT	20121000000741	0001.0001.020662.02-8 	ROSIANE CARVALHO SILVA 				41101189   		1  		Z00		N
10/12/2012																	   					90509684   		1  		Z00		N
10/12/2012																						90513908   		1  		Z00		N
10/12/2012																						90508610  		1 		Z00		N
10/12/2012				   																		0000025576		1 		Z00		N
10/12/2012	SP/SADT	20120900000345	0001.0001.011606.00-5	CLAUDIO DELANDRE ELIAS 				41101227  		1 		M511 	N
10/12/2012	SP/SADT	20120900000456	0001.0001.005766.00-4 	DEBORA FONSECA RESENDE MARTINS 		41001044  		1	  			S		Atendimento cancelado


Qtd. Iten(s):	9
Qtd. Consulta(s):	Aut.: 0 	Neg.: 0
Qtd. Proc.(s) :	Aut.: 8	Neg.: 1
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/

If ! lWeb

	cCodOpe  	:= mv_par01
	cRdaDe   	:= mv_par02
	cRdaAte  	:= mv_par03
	cDatPDe  	:= mv_par04
	cDatPAte 	:= mv_par05
	nSaIn		:= mv_par06
	nLiNe    	:= mv_par07
	nTp		 	:= mv_par08
	
Else

	cCodOpe		:= PlsIntPad()
	cRdaDe   	:= Iif(Len(aParW2)>=1,aParW2[1],substr(aParWeb:rda,1,6))
	cRdaAte  	:= Iif(Len(aParW2)>=2,aParW2[2],substr(aParWeb:rda,1,6))
	cLocRda		:= Iif(Len(aParW2)>=3,aParW2[3],substr(aParWeb:rda,8,3))
	cDatPDe  	:= Iif(Len(aParW2)>=4,aParW2[4],aParWeb:dtDe)
	cDatPAte 	:= Iif(Len(aParW2)>=5,aParW2[5],aParWeb:dtAte)
	nSaIn    	:= Iif(Len(aParW2)>=6,aParW2[6],val(aParWeb:guia))
	nLiNe    	:= Iif(Len(aParW2)>=7,aParW2[7],val(aParWeb:tipo))
	nTp		 	:= Iif(Len(aParW2)>=8,aParW2[8],val(aParWeb:tp))

Endif

cSql := pQry754(nSaIn,cCodOpe,cRdaDe,cRdaAte,cDatPDe,cDatPAte,nLiNe,nTp,cProtocolo,cLocRda,cTipGui)
cSql := ChangeQuery(cSql) 

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"cArqTrab",.F.,.T.) 

Count To nQtdReg 

//Trata se nao existir registros...                                        
cArqTrab->(DbGoTop())

cArqTrab->(DBEval( { | | nQtd ++ }))

If !lWeb
	ProcRegua(nQtd)
Endif

cArqTrab->(DbGoTop())

nTotGeral 	:= 0
nQtdTAutE 	:= 0
nQtdTNegE 	:= 0
nQtdTAutC 	:= 0
nQtdTNegC 	:= 0
nLi		  	:= 1
lFirst 		:= .T.

If lGerPag .And. ! lFmrTxt 
	oReport:StartPage()
Endif

If ! cArqTrab->(Eof())

	While !cArqTrab->(Eof())
     	nTot++
        If ! lFirst .And. ! lFmrTxt
			oReport:EndPage()
			oReport:StartPage()
        Endif
        lFirst := .F.


		cCodRDA  := cArqTrab->(CODRDA)
		BAU->(DbSetOrder(1))
		BAU->(msseek(xFilial("BAU")+cCodRDA))
		If !lFmrTxt
			Cab974PGR(oReport,lWeb)
		EndIf	

		lTitulo  := .T.
		nTotRda  := 0
		nQtdAutE := 0
		nQtdAutC := 0
		nQtdNegE := 0
		nQtdNegC := 0
		While !cArqTrab->(Eof())  .And. cArqTrab->CODRDA == cCodRDA
			
			If nLi > 25 .And. !lFmrTxt
				nLi := 1
				oReport:EndPage()
				oReport:StartPage()
				Cab974PGR(oReport,lWeb,@lTipVlAp)
			EndIf
			
			If lTipVlAp
				If !EMPTY(cNumGuia) .AND. cNumGuia != cArqTrab->OPERADORA + cArqTrab->NUMAUT
					
					cNumGuia := cArqTrab->OPERADORA + cArqTrab->NUMAUT
					
					nTop += 25 
					oReport:Say(nTop/nTweb, nPosTotal, "TOTAL APRESENTADO ---------------------------> R$" + ALLTRIM(TRANSFORM(nSomaItem,'@E 99,999,999,999,999.99')), oFnt10c) 
					nTop += 25
					nLi++
					nSomaItem := 0
				EndIf 
			EndIf 
						
			If !lFmrTxt
				nTop += 10
			EndIf
			lConsult := PLSISCON(cArqTrab->CODPAD,cArqTrab->CODPRO)

			If cArqTrab->CANCELADO == '2' 
				cCodGlo := "Cancelada"
			Else
				cCodGlo := "Critica nao encontrada"
			Endif

			If cArqTrab->STATUSP == '0'
			    If cArqTrab->TIPO = 'S'
			       BEG->(DbSetOrder(1))
			       If BEG->( MsSeek(xFilial("BEG")+cArqTrab->CHAVECRI) )
				       While !BEG->(Eof()) .And. BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == cArqTrab->CHAVECRI
				       	  If !Empty(BEG->BEG_CODGLO)
		          	          cCodGlo := BEG->(BEG_CODGLO+"-"+BEG_DESGLO)
		          	          exit
					      EndIf
			  		      BEG->(dbSkip())
					   EndDo
				   EndIf
			    Else
			  	   BEL->(DbSetOrder(1))
			       If BEL->( MsSeek(xFilial("BEL")+cArqTrab->CHAVECRI) )
				       While !BEL->(Eof()) .And. BEL->(BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN) == cArqTrab->CHAVECRI
				       	  If !Empty(BEL->BEL_CODGLO)
						      cCodGlo := BEL->(BEL_CODGLO+"-"+BEL_DESGLO)
					      	  exit
					      EndIf
			  		      BEL->(dbSkip())
					   EndDo
				   EndIf
			    EndIf
			    If lConsult
					nQtdNegC  := nQtdNegC + cArqTrab->QTD
					nQtdTNegC := nQtdTNegC + cArqTrab->QTD
				Else
					nQtdNegE  := nQtdNegE + cArqTrab->QTD
					nQtdTNegE := nQtdTNegE + cArqTrab->QTD
				EndIf
			Else
			    If lConsult
					nQtdAutC  := nQtdAutC + cArqTrab->QTD
					nQtdTAutC := nQtdTAutC + cArqTrab->QTD
				Else
					nQtdAutE  := nQtdAutE + cArqTrab->QTD
					nQtdTAutE := nQtdTAutE + cArqTrab->QTD
				EndIf
			EndIf
			If cArqTrab->STATUSP <> '0'
				cCodGlo := ""
			Endif
			
			If lFmrTxt
				cDataProc := dtoc(StoD(cArqTrab->DTPROC))
				cTipGui   := IIf(cArqTrab->TIPGUI == G_SADT_ODON, 'SP_SADT', Iif(cArqTrab->TIPGUI == G_SOL_INTER,"INTERNAÇÃO", Iif (cArqTrab->TIPGUI == G_RES_INTER, "RESUMO INTER.", ;
				             Iif (cArqTrab->TIPGUI == G_HONORARIO, "HONORÁRIO", "CONSULTA"))))
				cNumAut   := cArqTrab->OPERADORA+"."+cArqTrab->NUMAUT
				cMatric   := cArqTrab->(OPERAUSR+"."+EMPRESA+"."+MATRIC+"."+TIPREG+'-'+DIGITO)
				cNomUsr   := cArqTrab->NOMUSR
				cCodPro   := Trim(cArqTrab->CODPRO)
				cQtd      := alltrim(str(cArqTrab->QTD))
				cNegado   := If(cArqTrab->STATUSP == '0', "S", "N")
				cMotivo   := Iif(cArqTrab->TP =='1',"Liber.","Exec.")
				//cValApre  := "R$ " + ALLTRIM(TRANSFORM((cArqTrab->VALORIG /cArqTrab->QTD) ,'@E 99,999,999,999,999.99')) 	//Valor original armazena o apresentado * quantidade	
				cValApre  := cArqTrab->VALORIG /cArqTrab->QTD 	//Valor original armazena o apresentado * quantidade
				cValOrig	:= cArqTrab->VALORIG	
				cValorPag	:= cArqTrab->VALPAG
				
				aAdd(aDadosIte,{cDataProc,cTipGui,cNumAut,cMatric,cNomUsr,cCodPro,cQtd,cNegado,cMotivo,cValApre,cValOrig,cValorPag})
			Else	

				nTop += _BL
	
				//Data Proc. 	Tipo Guia	Num Guia	Matricula 				Nome do Beneficiario   				Procedimento	QTD. 	CID		Negado	Motivo
				nColAux := (nLeft/nTweb)
				oReport:Say(nTop/nTweb, nColAux, objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_DATPRO","BE4_DATPRO"),;
																		Iif (nSaIn == 2, dtoc(StoD(cArqTrab->DATPRO)),;
																		objCENFUNLGP:verCamNPR("BE4_DATPRO",dtoc(StoD(cArqTrab->DATPRO))))), oFnt10c)
	
				nColAux += __NTAM1*4.5
				oReport:Say(nTop/nTweb, nColAux, iif(cArqTrab->TIPGUI == G_SADT_ODON, 'SP_SADT', iif(cArqTrab->TIPGUI == G_SOL_INTER,"INTERNAÇÃO", ;
				                                 iif (cArqTrab->TIPGUI == G_RES_INTER, "RESUMO INTER.", iif (cArqTrab->TIPGUI == G_HONORARIO, "HONORÁRIO", "CONSULTA")))), oFnt10c)
	
				nColAux += __NTAM2*5
				oReport:Say(nTop/nTweb, nColAux, objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_OPEMOV","BE4_CODOPE"),;
																		Iif (nSaIn == 2, alltrim(cArqTrab->OPERADORA),;
																		objCENFUNLGP:verCamNPR("BE4_CODOPE",alltrim(cArqTrab->OPERADORA))))+"."+;
												objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_NUMAUT","BE4_NUMINT"),;
																		Iif (nSaIn == 2, cArqTrab->NUMAUT,;
																		objCENFUNLGP:verCamNPR("BE4_NUMINT",cArqTrab->NUMAUT))),;
												oFnt10c)
				
				//variável que controla a exibição do valor total
				cNumGuia := cArqTrab->OPERADORA + cArqTrab->NUMAUT 
				
				cMatricUsr := 	objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_OPEUSR","BE4_OPEUSR"),;
																		Iif (nSaIn == 2, alltrim(cArqTrab->(OPERAUSR)),;
																		objCENFUNLGP:verCamNPR("BE4_OPEUSR",alltrim(cArqTrab->(OPERAUSR))))) + "." +;
								objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_CODEMP","BE4_CODEMP"),;
																		Iif (nSaIn == 2, alltrim(cArqTrab->(EMPRESA)),;
																		objCENFUNLGP:verCamNPR("BE4_CODEMP",alltrim(cArqTrab->(EMPRESA))))) + "." +;
								objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_MATRIC","BE4_MATRIC"),;
																		Iif (nSaIn == 2, alltrim(cArqTrab->(MATRIC)),;
																		objCENFUNLGP:verCamNPR("BE4_MATRIC",alltrim(cArqTrab->(MATRIC))))) + "." +;
								objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_TIPREG","BE4_TIPREG"),;
																		Iif (nSaIn == 2, alltrim(cArqTrab->(TIPREG)),;
																		objCENFUNLGP:verCamNPR("BE4_TIPREG",alltrim(cArqTrab->(TIPREG))))) + "." +;
								objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_DIGITO","BE4_DIGITO"),;
																		Iif (nSaIn == 2, alltrim(cArqTrab->(DIGITO)),;
																		objCENFUNLGP:verCamNPR("BE4_DIGITO",alltrim(cArqTrab->(DIGITO)))))			 
				
				nColAux += __NTAM3*5.7
				oReport:Say(nTop/nTweb, nColAux, cMatricUsr, oFnt10c)
	
				nColAux += __NTAM4*4.6
				oReport:Say(nTop/nTweb, nColAux, objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_NOMUSR","BE4_NOMUSR"),;
																		Iif (nSaIn == 2, rtrim(SubStr(cArqTrab->NOMUSR,1,36)),;
																		objCENFUNLGP:verCamNPR("BE4_NOMUSR",rtrim(SubStr(cArqTrab->NOMUSR,1,36))))),;
												 oFnt10c)
	
				nColAux += __NTAM5*4.7
				oReport:Say(nTop/nTweb, nColAux, objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD6_CODPRO",cAlias + "_CODPRO"),;
																		Iif (nSaIn == 2, Trim(cArqTrab->CODPRO),;
																		objCENFUNLGP:verCamNPR(cAlias + "_CODPRO",Trim(cArqTrab->CODPRO)))),;
												 oFnt10c)
				
				//variável utilizada para posicionar o valor total 
				nPosTotal := nColAux 
	
				nColAux += __NTAM6*4.5
				oReport:Say(nTop/nTweb, nColAux, objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD6_QTDPRO",cAlias + "_QTDPRO"),;
																		Iif (nSaIn == 2, alltrim(str(cArqTrab->QTD)),;
																		objCENFUNLGP:verCamNPR(cAlias + "_QTDPRO",alltrim(str(cArqTrab->QTD))))),;
												 oFnt10c)
	
				nColAux += __NTAM7*4.6
				oReport:Say(nTop/nTweb, nColAux, objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD5_CID","BE4_CID"),;
																		Iif (nSaIn == 2, alltrim(cArqTrab->CID),;
																		objCENFUNLGP:verCamNPR("BE4_CID",alltrim(cArqTrab->CID)))), oFnt10c)
	
				nColAux += __NTAM8*4.3
				oReport:Say(nTop/nTweb, nColAux, If(cArqTrab->STATUSP == '0', "S", "N"), oFnt10c)
	
				nColAux += __NTAM9*4.8
				oReport:Say(nTop/nTweb, nColAux, Iif(cArqTrab->TP =='1',"Liber.","Exec."), oFnt10c)
				
				If lTipVlAp
					nColAux += __NTAM12*8.0 
					oReport:Say(nTop/nTweb, nColAux, "R$" + objCENFUNLGP:verCamNPR(IIF(nSaIn == 1 .or. nSaIn == 3,"BD6_VLRAPR",cAlias + "_VLRAPR"),;
																		Iif (nSaIn == 2, ALLTRIM(TRANSFORM(cArqTrab->VALAPRE,'@E 99,999,999,999,999.99')),;
																		objCENFUNLGP:verCamNPR(cAlias + "_VLRAPR",ALLTRIM(TRANSFORM(cArqTrab->VALAPRE,'@E 99,999,999,999,999.99'))))),;
													 oFnt10c) 
				EndIf
				nSomaItem += cArqTrab->VALAPRE * cArqTrab->QTD
				
				nLi++
			EndIf

			If !empty(cCodGlo) .And. !lFmrTxt
				cMsg := cCodGlo
				nTop += _BL
				oReport:Say(nTop/nTweb, (nLeft+400)/nTweb, cMsg, oFnt10c)
				nLi++
			Endif
			nTotRda++
			nTotGeral++
			cArqTrab->(dbSkip())
		If nLi > 25 .And. !lFmrTxt
			nLi := 1
			oReport:EndPage()
			oReport:StartPage()
			Cab974PGR(oReport,lWeb,@lTipVlAp)
		EndIf
			
		EndDo
		
		If !lFmrTxt
		    If lTipVlAp
				//total do ultimo registro
				nTop += 25 
				oReport:Say(nTop/nTweb, nPosTotal, "TOTAL APRESENTADO ---------------------------> R$" + ALLTRIM(TRANSFORM(nSomaItem,'@E 99,999,999,999,999.99')), oFnt10c) 
				nLi++
			EndIf
			nTop += _BL
			oReport:Line(nTop/nTweb, nLeft/nTweb, nTop/nTweb, nRight/nTweb)
			nLi++
		Endif
		If nLi > 25 .And. !lFmrTxt
			nLi := 1
			oReport:EndPage()
			oReport:StartPage()
			Cab974PGR(oReport,lWeb)
		EndIf

		If !lFmrTxt
			cMsg := "Qtd. Iten(s): "+allTrim(Transform(nTotRda,"9,999"))+Space(1)
			nTop += _BL
			oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)
			nLi++
			cMsg := "Qtd. Consulta(s) Aut.: "+allTrim(Transform(nQtdAutC,"9,999"))+Space(1)+"Neg.: "+allTrim(Transform(nQtdNegC,"9,999"))+Space(1)
		    nTop += _BL
			oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)
			nLi++
			cMsg := "Qtd. Exame(s) Aut.: "+allTrim(Transform(nQtdAutE,"9,999"))+Space(1)+"Neg.: "+allTrim(Transform(nQtdNegE,"9,999"))
		    nTop += _BL
		    oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)
			nLi++
		Endif
	EndDo
	If nTot > 1

		If nLi > 25 .And. !lFmrTxt
			oReport:EndPage()
			oReport:StartPage()
			Cab974PGR(oReport,lWeb)
		EndIf

		If !lFmrTxt
			nTop += _BL
			oReport:Line(nTop/nTweb, nLeft/nTweb, nTop/nTweb, nRight/nTweb)
			cMsg := "Qtd Total de Iten(s):"+Transform(nTotGeral,"9,999")+Space(2)
			nTop += _BL
			oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)
			cMsg := "Qtd Total Consulta(s) Aut.:"+Transform(nQtdTAutC,"9,999")+Space(2)+"Neg.:"+Transform(nQtdTNegC,"9,999")+Space(4)
			nTop += _BL
			oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)
			cMsg := "Qtd Total Exame(s) Aut.:"+Transform(nQtdTAutE,"9,999")+Space(2)+"Neg.:"+Transform(nQtdTNegE,"9,999")
			nTop += _BL
			oReport:Say(nTop/nTweb, nLeft/nTweb, cMsg, oFnt10c)
		EndIf
	Endif		
			
	//COMEÇAR A CRIAÇÃO DO HTML.
	if lFmrTxt
		
		cNomPrest 	:= BAU->BAU_CODIGO+" - "+BAU->BAU_NOME
		cQtdItens 	:= allTrim(Transform(nTotRda,"9,999"))			
		cConsAut  	:= allTrim(Transform(nQtdAutC,"9,999"))
		cConsNeg  	:= allTrim(Transform(nQtdNegC,"9,999"))
		cExAut    	:= allTrim(Transform(nQtdAutE,"9,999"))
		cExNeg    	:= allTrim(Transform(nQtdNegE,"9,999"))
		 
		cRetTxt	:= PLCRPROT(aDadosIte,,{cNomPrest,cQtdItens,cConsAut,cConsNeg,cExAut,cExNeg},.F.,cContCa,.f.,lVlrApr)
		
	endIf	
	
elseIf ! lFmrTxt
	
	if ! lWeb
         MsgStop("Nenhum dado encontrado para os parametros informados.")
    endIf
    
    lRet := .f.
    
endIf

cArqTrab->(DbCloseArea())

Return( iIf( lFmrTxt, cRetTxt, lRet ) )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLSR754Imp³ Autor ³ Paulo Carnelossi      ³ Data ³ 07/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Impressao relacao de autor. internacao/SADT no periodo      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³PLSR754Imp(lEnd,nRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function pQry754(nSaIn,cCodOpe,cRdaDe,cRdaAte,cDatPDe,cDatPAte,nLiNe,nTp,cProtocolo,cLocRda,cTipGui)
LOCAL cSQL 			:= ""
LOCAL nColAux 		:= 0
LOCAL lCpoProto 	:= PlsCpoProto()
Local cResQTip		:= Iif(cTipGui == G_RES_INTER,"05","03")
PUBLIC cAlias		:= Iif(cTipGui == G_RES_INTER,"BD6","BEJ")
Default cProtocolo 	:= ""

DEFAULT cProtocolo := ""

If nSaIn == 1 .or. nSaIn == 3  // SADT OU Todas 

	cSQL += " SELECT 'S' AS TIPO, BD5_TIPGUI TIPGUI, BD5_CODRDA AS CODRDA, BD5_DATPRO AS DATPRO, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, "
	cSQL += " BD5_MATRIC AS MATRIC, BD5_TIPREG AS TIPREG, BD5_DIGITO AS DIGITO, BD5_NOMUSR AS NOMUSR, BD5_CID AS CID, BD5_OPEUSR AS OPERAUSR, "
	
	cSQL += " BD5_ANOAUT || '.' || BD5_MESAUT || '.' || BD5_NUMAUT NUMAUT, BD5_OPEMOV OPERADORA, BD5_CODEMP EMPRESA, BD5_LIBERA TP, "
	
	cSQL += " BD6_SITUAC AS CANCELADO, BD6_CODPRO AS CODPRO, BD6_CODPAD AS CODPAD, BD6_SEQUEN AS SEQUEN, BD6_STATUS AS STATUSP, "
	cSQL += " BD6_VLRAPR AS VALAPRE, BD5_OPEMOV || BD5_ANOAUT || BD5_MESAUT || BD5_NUMAUT || BD6_SEQUEN AS CHAVECRI, BD6_QTDPRO AS QTD, "
	cSQL += " BD6_VALORI VALORIG, BD6_VLRPAG VALPAG, BD6_DATPRO DTPROC"

	cSQL += " FROM  "+ RetSqlName("BD5") + ", " + RetSQLName("BD6")
	cSQL += " WHERE BD5_FILIAL = '" + xFilial("BD5") + "' "
	cSQL += "   AND BD6_FILIAL = '" + xFilial("BD6") + "' "

	If ! empty(cProtocolo)

		//o indice de codigo de peg esta com a posicao 14 no updplsae
		BCI->(DbSetOrder(14)) 
		if BCI->( msSeek(xFilial("BCI") + cProtocolo))
			cSQL += " AND BD5_CODOPE  = '" + BCI->BCI_CODOPE + "' "
			cSQL += " AND BD5_CODLDP  = '" + BCI->BCI_CODLDP + "' "
			cSQL += " AND BD5_CODPEG  = '" + BCI->BCI_CODPEG + "' "
		endIf
			
	endIf	

	cSQL += " AND BD6_CODOPE  = BD5_CODOPE "
	cSQL += " AND BD6_CODLDP  = BD5_CODLDP "
	cSQL += " AND BD6_CODPEG  = BD5_CODPEG "
	cSQL += " AND BD6_NUMERO  = BD5_NUMERO "
	cSQL += " AND BD6_ORIMOV  = BD5_ORIMOV "
	//cSQL += " AND BD5_NUMAUT <> '' "  //Será definido se iremos deixar a PEG vinda do Portal igual de XML, sem pode incluir guias pelo remote. Enquanto isso, pode visualizar as guias no PEG.
	cSQL += " AND BD5_CODRDA >= '" + cRdaDe + "' AND BD5_CODRDA <= '" + cRdaAte + "' "
	
	if ! empty(cLocRda)
		cSQL += " AND BD5_CODLOC = '" + cLocRda + "' "
	endIf
	
	if ! empty(cDatPAte)
		cSQL += " AND BD5_DATPRO >= '" + dtos(cDatPDe) + "' AND BD5_DATPRO <= '" + dtos(cDatPAte) + "' "
	endIf
	
	If nTp <> 3
	
		if nTp == 1
		
			cSQL += " AND BD5_LIBERA = '1' "
			
		elseIf nTp == 2
		
			cSQL += " AND BD5_LIBERA <> '1' "
			
		endIf
		
	endIf
	
	// somente liberadas
	If nLiNe == 1 
		
		cSQL += " AND BD6_STATUS  = '1' "  //1=Autorizada;0=Nao Autorizada
	
	ElseIf nLiNe == 2 
	
		cSQL += " AND BD6_STATUS  = '0' " // somente negadas
		
	EndIf
	
	cSQL += " AND " + RetSQLName("BD5") + ".D_E_L_E_T_ = ' ' "
	cSQL += " AND " + RetSQLName("BD6") + ".D_E_L_E_T_ = ' ' "
	
EndIf 

If nSaIn == 3
   cSQL += " UNION ALL "
EndIf

If nSaIn == 2 .or. nSaIn == 3  // SADT OU Todas

	cSQL += " SELECT 'I' AS TIPO, '" + cResQTip + "' TIPGUI, BE4_CODRDA  AS CODRDA, BE4_DATPRO AS DATPRO, BE4_CODLDP, BE4_CODPEG, BE4_NUMERO, "
	cSQL += " 	     BE4_MATRIC AS MATRIC, BE4_TIPREG AS TIPREG, BE4_DIGITO AS DIGITO, 	BE4_NOMUSR AS NOMUSR, BE4_CID AS CID, BE4_OPEUSR AS OPERAUSR, "
	
	cSQL += " 	BE4_ANOINT || '.' || BE4_MESINT || '.' || BE4_NUMINT NUMAUT, BE4_CODOPE OPERADORA, BE4_CODEMP EMPRESA, '1' TP, "

	cSQL += IIf( (cAlias) == "BD6", cAlias + "_SITUAC CANCELADO, ", "BE4_CANCEL CANCELADO, ") 
	cSQL += cAlias + "_CODPRO AS CODPRO, "  + cAlias + "_CODPAD AS CODPAD, " + cAlias + "_SEQUEN AS SEQUEN, " + cAlias + "_STATUS AS STATUSP, " 
	
	cSQL += cAlias + "_VLRAPR AS VALAPRE, " + cAlias + "_CODOPE ||" + cAlias + "_ANOINT ||" + cAlias + "_MESINT ||" + cAlias + "_NUMINT ||" + cAlias + "_SEQUEN AS CHAVECRI, " + cAlias + "_QTDPRO AS QTD, "

	cSQL += iif(cResQTip == "05", " BD6_VALORI VALORIG, ", " 0 VALORIG, ") + " BE4_VLRPAG VALPAG, BE4_DATPRO DTPROC "
	
	cSQL += " FROM " + RetSQLName("BE4") + ", " + RetSQLName(cAlias)
	
	cSQL += " WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
	cSQL += "   AND " + cAlias + "_FILIAL ='"+xFilial(cAlias) + "' "
	
	If ! empty(cProtocolo)
		
		//o indice de codigo de peg esta com a posicao 14 no updplsae
		BCI->(DbSetOrder(14)) 
		if BCI->( msSeek(xFilial("BCI") + cProtocolo))
			cSQL += " AND BE4_CODOPE  = '" + BCI->BCI_CODOPE + "' "
			cSQL += " AND BE4_CODLDP  = '" + BCI->BCI_CODLDP + "' "
			cSQL += " AND BE4_CODPEG  = '" + BCI->BCI_CODPEG + "' "
		endIf
		
	endIf
	
	cSQL += " AND " + cAlias + "_CODOPE = BE4_CODOPE "
	
	if cTipGui <> G_RES_INTER
	
		cSQL += " AND " + cAlias + "_ANOINT = BE4_ANOINT "
		cSQL += " AND " + cAlias + "_MESINT = BE4_MESINT "
		cSQL += " AND " + cAlias + "_NUMINT = BE4_NUMINT "
		
	else
	
		cSQL += " AND " + cAlias + "_CODOPE  = BE4_CODOPE "
		cSQL += " AND " + cAlias + "_CODLDP  = BE4_CODLDP "
		cSQL += " AND " + cAlias + "_CODPEG  = BE4_CODPEG "
		cSQL += " AND " + cAlias + "_NUMERO  = BE4_NUMERO "
		cSQL += " AND " + cAlias + "_ORIMOV  = BE4_ORIMOV "
				
	endIf
	
	cSQL += " AND BE4_CODRDA >= '" + cRdaDe + "' AND BE4_CODRDA <= '" + cRdaAte + "' "
	
	if ! empty(cLocRda)
		cSQL += " AND BE4_CODLOC = '" + cLocRda + "' "
	endIf
	
	If ! empty(cDatPAte)
		cSQL += " AND BE4_DATPRO >= '" + dtos(cDatPDe)+"' AND BE4_DATPRO <= '" + dtos(cDatPAte) + "' "
	EndIf
	
	cSQL += " AND BE4_SITUAC = '1' "

	If nLiNe == 1 // somente liberadas
		cSQL += " AND " + cAlias + "_STATUS = '1' "
	ElseIf nLiNe == 2 // somente negadas
		cSQL += " AND " + cAlias + "_STATUS = '0' "
	EndIf

	cSQL += " AND " + RetSQLName("BE4") + ".D_E_L_E_T_ = ''  "
	cSQL += " AND " + RetSQLName(cAlias) + ".D_E_L_E_T_ = ''  "
	
EndIf

cSQL += " ORDER BY CODRDA, DATPRO, NUMAUT "

return cSql


Static Function Cab974PGR(oReport,lWeb,lTipVlAp)

oReport:EndPage() //Salta para proxima pagina

nTop		:= 10
nTopInt	:= nTop
nLeft		:= 40

nTop	+= _BL
nTopAux := nTop

aBMP:={"lgrl.bmp"}
If File("lgrl" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMP := { "lgrl" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgrl" + FWGrpCompany() + ".bmp")
	aBMP := { "lgrl" + FWGrpCompany() + ".bmp" }
EndIf

oReport:SayBitmap(nTop/nTweb, nLeft/nTweb, aBMP[1], 400/nTweb, 123/nTweb)
/*
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Extrato de Utilização
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RDA : 000161 - CENTRO DE IMAGEM DIAGNOSTICOS S/C LTDA
Periodo de.: 10/12/12 a 08/01/13
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Data Proc. 	Tipo Guia	Num Guia	Matricula 				Nome do Beneficiario   				Procedimento	QTD. 	CID		Negado	Motivo
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
cMsg := cTitulo
nTop += 125
oReport:Say(((nTop)/nTweb)+nLweb, (nLeft + 1000)/nTweb, cMsg, oFnt14N)
cMsg := "Data: "+dToc(dDataBase)
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10c)
cMsg := "Hora: "+time()
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10c)
cMsg := "Prestador: "+	objCENFUNLGP:verCamNPR("BAU_CODIGO",BAU->BAU_CODIGO)+" - "+;
						objCENFUNLGP:verCamNPR("BAU_NOME",BAU->BAU_NOME)+""
nTop += 35
If !Empty(cDatPAte)
	oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10c)
	cMsg := "Periodo de:"+dtoc(cDatPDe)+" a "+dtoc(cDatPAte)+""
Endif
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10c)
cMsg := "Pagina: "+alltrim(str(nPag))+""
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10c)
nTop += _BL
oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb, (nTop/nTweb)+nLweb, nRight/nTweb)
nTop += _BL
nPag++

//Data Proc. 	Tipo Guia	Num Guia	Matricula 				Nome do Beneficiario   				Procedimento	QTD. 	CID		Negado	Motivo
nTop += 40

nColAux := (nCol0/nTweb)
oReport:Say(nTop/nTweb, nColAux, "Data", oFnt10c)

nColAux += __NTAM1*4.5
oReport:Say(nTop/nTweb, nColAux, "Tp. Guia", oFnt10c)

nColAux += __NTAM2*6.4
oReport:Say(nTop/nTweb, nColAux, "Num Guia", oFnt10c)

nColAux += __NTAM3*6.1
oReport:Say(nTop/nTweb, nColAux, "Matricula", oFnt10c)

nColAux += __NTAM4*4.6
oReport:Say(nTop/nTweb, nColAux, "Nome do Beneficiario", oFnt10c)

nColAux += __NTAM5*4.2
oReport:Say(nTop/nTweb, nColAux, "Codigo", oFnt10c)

nColAux += __NTAM6*4.5
oReport:Say(nTop/nTweb, nColAux, "Qtd.", oFnt10c)

nColAux += __NTAM7*4.4
oReport:Say(nTop/nTweb, nColAux, "Cid", oFnt10c)

nColAux += __NTAM8*4.3
oReport:Say(nTop/nTweb, nColAux, "Neg", oFnt10c)

nColAux += __NTAM9*4.8
oReport:Say(nTop/nTweb, nColAux, "Exe/Lib", oFnt10c)

If lTipVlAp
	nColAux += __NTAM12*7.2 
	oReport:Say(nTop/nTweb, nColAux, "Valor Apresentado", oFnt10c) 
EndIf
nTop += _BL
nTop += 40
oReport:Line((nTop/nTweb)-nLweb, nLeft/nTweb, (nTop/nTweb)-nLweb, nRight/nTweb)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR754   ºAutor  ³Microsiga           º Data ³  02/13/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PlsCpoProto()
LOCAL lRet := .T.

If BD5->(FieldPos("BD5_OPEMOV")) == 0
	lRet := .F.
Elseif BD5->(FieldPos("BD5_ANOAUT")) == 0
	lRet := .F.
Elseif BD5->(FieldPos("BD5_MESAUT")) == 0
	lRet := .F.

Elseif BD5->(FieldPos("BD5_NUMAUT")) == 0
	lRet := .F.

Endif

Return(lRet)
