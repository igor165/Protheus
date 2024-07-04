#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "fileio.ch"
#INCLUDE "plstiss.ch"
	
#DEFINE	 IMP_PDF 6
#DEFINE	 TAM_CUSTOM 0 		//Tamanho customizavel pelo usuario, informado em nHeight/nWidth. Aplicavel apenas em impressoes do tipo PDF. oficio 2 216 x 330 .
#DEFINE	 TAM_CARTA 1 		//Letter   	216mm x 279mm  637 x 823
#DEFINE	 TAM_TABLOID 3 		//Tabloid  	279mm x 432mm  823 x 1275
#DEFINE	 TAM_EXECUTIVE 7	//Executive 184mm x 267mm  543 x 788
#DEFINE	 TAM_A3 8			//A3     	297mm x 420mm  876 x 1240
#DEFINE	 TAM_A4 9			//A4     	210mm x 297mm  620 x 876
#DEFINE  pMoeda1 "@E 999,999.99"
#DEFINE  pMoeda2 "@E 999,999,999.99"
#Define __NTAM1  10
#Define __NTAM2  25
#Define __NTAM3  40
#Define __NTAM4  10
#Define __NTAM5  20
#Define __NTAM6  10
#Define __NTAM7  5
#Define __NTAM8  15
#Define __NTAM9  15
#Define __NTAM10 15
#define lSrvUnix IsSrvUnix()
#define __aCdCri049 {"020","O valor contratato e diferente do valor informado/apresentado."}

static lautoSt := .F.

//Relatorios que forem convertidos em PDF referente a pagamento e cobrança
//devem ser criados dentro deste fonte

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRELDPM
Demonstrativo de Pagamento

@author  PLS TEAM
@version P12
@since   14.01.13
/*/
//-------------------------------------------------------------------
function PLSRELDPM(cCodRda,cAnoW,cMesW,lWeb,cPathW,cNmTitPg,cAlias,lAuto,cAutoTp,aParEx)
LOCAL nI			:= 0
LOCAL nX			:= 0
LOCAL nLinMax		:=	2350
LOCAL nColMax		:=	2950
LOCAL nLinIni		:= 0
LOCAL nColIni		:= 0
LOCAL nColA4    	:= 0
LOCAL cCodOpe   	:= ""
LOCAL cAno      	:= ""
LOCAL cMes      	:= ""
LOCAL cMsg			:= ""
LOCAL cFileName		:= ""
LOCAL cPathSrv 		:= lower(getMV("MV_RELT"))
LOCAL oFont01   	:= nil
LOCAL oFont02n		:= nil
LOCAL oFont04		:= nil
LOCAL lBox			:= .f.
LOCAL lContinua		:= .t.
LOCAL lPorData		:= .f.
LOCAL lOk			:= .f.
LOCAL cLogoGH		:= plGetImgRel()
LOCAL cDatPag		:= ""
LOCAL adadPag 		:= {}
LOCAL adadDebCre 	:= {}
LOCAL aDadRelat		:= {} 
LOCAL aDebCreDat 	:= {0,0} 
LOCAL aDebCreTot 	:= {0,0} 
LOCAL aSomadat 		:= {0, 0, 0, 0} 
LOCAL aSomatot 		:= {0, 0, 0, 0} 
LOCAL aE2Num 		:= {}
LOCAL aRetParam 	:= {}
LOCAL aParambox 	:= {}
Local aCombo 		:= {"Data de Pagamento","Competência"}
LOCAL cCompeten 	:= ""
LOCAL cDataAtu 		:= DtoS(DatE())
LOCAL nY 			:= 0
LOCAL nIni 			:= 1
Local nZ 			:= 0
local cDataPgEx		:= ""

PRIVATE oPrint		:= nil
DEFAULT lWeb		:= .f.
DEFAULT cCodRda		:= ""
DEFAULT cAnoW		:= ""
DEFAULT cMesW		:= ""
DEFAULT cPathW		:= ""
DEFAULT cNmTitPg 	:= ""
DEFAULT cAlias 		:= nil
Default lauto 		:= .F.
Default cAutoTp 	:= "1"
Default aParEx 		:= {}

lautoSt := lauto

If lauto
	if	!(empTy(aParEx))
		aRetParam := aclone(aParEx)
	elseIf cAutoTp == "1"
		aRetParam := {"0001","000008","Data de Pagamento",CtoD("31/07//2019"),"07","2019"}
	else
		aRetParam := {"0001","000008","teste 2",CtoD("31/07//2019"),"07","2019"}
	endIf
endIf
// Alimenta aParamBox para parametros de entrada
aAdd(aParamBox,{1,"Operadora"			,Space(4),"","","","",80,.T.})
aAdd(aParamBox,{1,"RDA"					,Space(6),"","","","",80,.T.})
aAdd(aParamBox,{2,"Período de Pagamento","Data de Pagamento",aCombo,80,"",.T.})
aAdd(aParamBox,{1,"Data de Pagamento"	,Ctod(Space(8)),"","","","mv_par03=='Data de Pagamento'",80,.F.})
aAdd(aParamBox,{1,"Mês Base"			,Space(2),"","","","mv_par03=='Competência'",80,.F.})
aAdd(aParamBox,{1,"Ano Base"			,Space(4),"","","","mv_par03=='Competência'",80,.F.})

// Parametros para pesquisa
While !lOk
	If lauto .OR. Parambox(aParambox,"Parametros para Demonstrativo de Pagamento",@aRetParam)
		cCodOpe	:= aRetParam[1]
		cCodRda := aRetParam[2]
		lPorData:= IIF(aRetParam[3]=="Data de Pagamento",.T.,.F.)
		cDatPag	:= substr(DTOC(aRetParam[4]),7,4)+substr(DTOC(aRetParam[4]),4,2)+substr(DTOC(aRetParam[4]),1,2)
		cMes    := aRetParam[5]
		cAno    := aRetParam[6]	
	Else
		return
	Endif
	If (lPorData .and. cDatPag != "        ") .or. (!lPorData .and. !Empty(cMes) .and. !Empty(cAno))
		lOk := .T.
	Else
		If lPorData
			msgAlert("Insira a data de pagamento para prosseguir!")
		Else
			msgAlert("Insira o mês e ano para prosseguir!")
		Endif
	Endif
EndDo

cCompeten := cAno+cMes

//Alimanta dados (mesmas querys do portal)
adadPag		:= QDemoPag(lPorData ,cDatPag, cCompeten,cCodRda) // Retorna valores da BD7 e SE2
adadDebCre	:= QDemoPagCD(lPorData ,cDatPag, cCompeten,cCodRda) // Retorna valores da BGQ e SE2
aDadRelat	:= QDemPagDad(cCodRda) // Retorna valores da BA0, BAU, BB8 e SA2

//verifica se foi encontrado conteudo
if Len(adadPag) < 1
	If !lauto
		msgAlert("Não foram encontrados dados para os parâmetros informados!")
	endIf
	lContinua := .f.
endIf

//se existe dados ou nao
if lContinua
	
	//Fonte Normal
	oFont01	 := TFont():New("Arial",  8,  8, , .F., , , , .T., .F.)
	oFont02n := TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont04	 := TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal	
		
	//DAHER - Tive que colocar esse Semaforo aqui pois por alguma razao
	//quando duas transacoes chamavam ao mesmo tempo o FWMSPRINTER
	//eventualmente alguma delas nao retornava, ou seja, ele entrava
	//no FWMSPRINTER e nunca saia	
	cFileName	:= lower("PLSRELDPM" + criaTrab(nil,.f.) + "_" + cCodRda) // Colocado a RDA no nome do arquivo pro filtro no portal
	nH := PLSAbreSem("PPLSRELDPM.SMF")
	oPrint := FWMSPrinter():New(cFileName,IMP_PDF,.t.,nil,.t.,nil,@oPrint,nil,nil,.f.,.f.,.t.)
	PLSFechaSem(nH,"PPLSRELDPM.SMF")

	oPrint:lInJob  	:= lWeb
	oPrint:lServer 	:= lWeb
	oPrint:cPathPDF	:= cPathSrv
	
	//Resolução do relatorio.
	oPrint:setResolution(72)
	
	//Modo paisagem	
	oPrint:setLandscape()
	
	//Papel A4	
	oPrint:setPaperSize(TAM_A4)	
	//Margem	
	oPrint:setMargin(05,05,05,05)
	
	//Verifica se existe alguma impressora configurada para Impressao Grafica	
	oPrint:setup()

	If nX > 1
		oPrint:EndPage()
	Endif

	nLinIni := 50
	nColIni := 0
	nColA4  := 0

	oPrint:StartPage() // Inicia uma nova pagina
		
	//Box Principal                                                 			
	oPrint:Box(nLinIni + 0010, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)

	if fLogoEmp(@cLogoGH)
		oPrint:sayBitmap(nLinIni + 0050, nColIni + 0020, cLogoGH, 400, 090)
	endIf

	oPrint:Say(nLinIni + 0080, nColIni + 1152, STR0285, oFont02n,,,, 2) //"DEMONSTRATIVO DE PAGAMENTO"

	oPrint:Say(nLinIni + 0080, nColIni + 2700, "2-  Nº "+cDataAtu+"0000001"  , oFont01) //"2 - Número do Demonstrativo"

	nLinIni += 0
	oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, (nColIni + nColMax)*0.15 - 0010)
	oPrint:Say(nLinIni + 0200, nColIni + 0020, "1 - "+STR0003, oFont01) //"1 - Registro ANS"
	oPrint:Say(nLinIni + 0240, nColIni + 0030, aDadRelat[1], oFont04)

	oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.15, nLinIni + 0269, (nColIni + nColMax)*0.65 - 0010)
	oPrint:Say(nLinIni + 0200, (nColIni + nColMax)*0.15 + 0020, "3 - "+STR0247, oFont01) //"3 - Nome da Operadora"
	oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.15 + 0030, aDadRelat[2], oFont04)

	oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.65, nLinIni + 0269, (nColIni + nColMax)*0.85 - 0010)
	oPrint:Say(nLinIni + 0200, (nColIni + nColMax)*0.65 + 0020, "4 - "+STR0248, oFont01) //"4 - CNPJ Operadora"
	oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.65 + 0030, Transform(aDadRelat[3], "@R 99.999.999/9999-99"), oFont04)
	
	oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.85, nLinIni + 0269, nColIni + nColMax - 0010)
	oPrint:Say(nLinIni + 0200, (nColIni + nColMax)*0.85 + 0020, "5 - "+STR0250, oFont01) //"5 - Data Emissão do Demonstrativo"
	oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.85 + 0030, substr(cDataAtu, 7, 2) + "/" + substr(cDataAtu, 5, 2) + "/" + substr(cDataAtu, 1, 4), oFont04)

	nLinIni += 20
	AddTBrush(oPrint, nLinIni + 0251, nColIni + 0010, nLinIni + 0282, nColIni + nColMax)
	oPrint:Say(nLinIni + 0274, nColIni + 0020, STR0251, oFont01) //"Dados do Prestador"

	nLinIni += 10
	oPrint:Box(nLinIni + 0284, nColIni + 0010, nLinIni + 0378, (nColIni + nColMax)*0.20 - 0010)
	oPrint:Say(nLinIni + 0309, nColIni + 0020, "6 - Código na Operadora", oFont01) //6 - Código na Operadora
	oPrint:Say(nLinIni + 0349, nColIni + 0030, cCodRDA, oFont04)
	
	oPrint:Box(nLinIni + 0284, (nColIni + nColMax)*0.20, nLinIni + 0378, (nColIni + nColMax)*0.85 - 0010)
	oPrint:Say(nLinIni + 0309, (nColIni + nColMax)*0.20 + 0020, "7- Nome do Contratado", oFont01) //7- Nome do Contratado
	oPrint:Say(nLinIni + 0349, (nColIni + nColMax)*0.20 + 0030, aDadRelat[4], oFont04)
	
	oPrint:Box(nLinIni + 0284, (nColIni + nColMax)*0.85, nLinIni + 0378, nColIni + nColMax- 0010)
	oPrint:Say(nLinIni + 0309, (nColIni + nColMax)*0.85 + 0020, "8 - "+STR0014, oFont01) //"8 - Código CNES"
	oPrint:Say(nLinIni + 0349, (nColIni + nColMax)*0.85 + 0030, aDadRelat[5], oFont04)
	
	nLinIni += 20
	AddTBrush(oPrint, nLinIni + 0360, nColIni + 0010, nLinIni + 0391, nColIni + nColMax)
	oPrint:Say(nLinIni + 0383, nColIni + 0020, STR0286, oFont01) //"Dados do Pagamento"

	nLinIni += 10
	cDataPgEx := iif( !empty(adadPag[nIni][15]), adadPag[nIni][15], adadPag[nIni][7])
	oPrint:Box(nLinIni + 0393, nColIni + 0010, nLinIni + 0487, (nColIni + nColMax)*0.15 - 0010)
	oPrint:Say(nLinIni + 0418, nColIni + 0020, "9 - "+STR0287, oFont01) //"9 - Data do Pagamento"
	oPrint:Say(nLinIni + 0458, nColIni + 0030, substr(cDataPgEx, 7, 2) + "/" + substr(cDataPgEx, 5, 2) + "/" + substr(cDataPgEx, 1, 4), oFont04)
	
	oPrint:Box(nLinIni + 0393, (nColIni + nColMax)*0.15, nLinIni + 0487, (nColIni + nColMax)*0.43 - 0010)
	oPrint:Say(nLinIni + 0418, (nColIni + nColMax)*0.15 + 0020, "10 - "+STR0288, oFont01) //"10 - Forma de Pagamento"
	oPrint:Say(nLinIni + 0458, (nColIni + nColMax)*0.15 + 0030, aDadRelat[6], oFont04)
	
	oPrint:Box(nLinIni + 0393, (nColIni + nColMax)*0.43, nLinIni + 0487, (nColIni + nColMax)*0.55 - 0010)
	oPrint:Say(nLinIni + 0418, (nColIni + nColMax)*0.43 + 0020, "11 - "+STR0292, oFont01) //"11 - Banco"
	oPrint:Say(nLinIni + 0458, (nColIni + nColMax)*0.43 + 0030, aDadRelat[7], oFont04)
	
	oPrint:Box(nLinIni + 0393, (nColIni + nColMax)*0.55, nLinIni + 0487, (nColIni + nColMax)*0.68 - 0010)
	oPrint:Say(nLinIni + 0418, (nColIni + nColMax)*0.55 + 0020, "12 - "+STR0293, oFont01) //"12 - Agência"
	oPrint:Say(nLinIni + 0458, (nColIni + nColMax)*0.55 + 0030, aDadRelat[8], oFont04)

	oPrint:Box(nLinIni + 0393, (nColIni + nColMax)*0.68, nLinIni + 0487, nColIni + nColMax - 0010)
	oPrint:Say(nLinIni + 0418, (nColIni + nColMax)*0.68 + 0020, "13 - Conta", oFont01) //"13 - Conta"
	oPrint:Say(nLinIni + 0458, (nColIni + nColMax)*0.68 + 0030, aDadRelat[9], oFont04)

	nLinIni += 10
	lBox := .F.
	AddTBrush(oPrint, nLinIni + 0489, nColIni + 0010, nLinIni + 0520, nColIni + nColMax)
	oPrint:Say(nLinIni + 0512, nColIni + 0020, STR0295, oFont01) //"Dados do Resumo"

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 522)
	For nI := 1 To Len(adadPag)

		lBox:=.F.
		if (nLinIni + (Len(adadPag) * 45)) < nLinMax
			oPrint:Box(nLinIni , nColIni + 0010, IIF((nLinIni + 5 + (Len(adadPag) * 45))<nLinMax,nLinIni + 5 + (Len(adadPag) * 45),nLinMax-50), nColIni + nColMax -0010)
		Else
						//Horizontal	//Vertical					//Rel.Bottom		//Right
			oPrint:Line(nLinIni , nColIni + 0010, 					nLinIni , 	nColIni + nColMax - 0010)	//linha superior								
			oPrint:Line(nLinIni , nColIni + 0010, 					50 + nLinMax, 	nColIni + 0010)					//linha esquerda
			oPrint:Line(nLinIni , nColIni + nColMax - 0010, 		50 + nLinMax, 	nColIni + nColMax - 0010)		//linha direita
			lBox:=.T.
		Endif

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10)

		oPrint:Say(nLinIni + 25,  nColIni + 0020, 		 "14 - Data do Protocolo", oFont01) //"Data do Protocolo"
		oPrint:Say(nLinIni + 25, (nColIni + nColMax)*0.15, "15 - Número do Protocolo", oFont01) //"Número do Protocolo"
		oPrint:Say(nLinIni + 25, (nColIni + nColMax)*0.30, "16 - Número do Lote", oFont01) //"Número do Lote"
		oPrint:Say(nLinIni + 25, (nColIni + nColMax)*0.45, "17 - "+STR0296, oFont01,,,,1) //"Valor Informado (R$)"
		oPrint:Say(nLinIni + 25, (nColIni + nColMax)*0.60, "18 - "+STR0268, oFont01,,,,1) //"Valor Processado (R$)"
		oPrint:Say(nLinIni + 25, (nColIni + nColMax)*0.75, "19 - "+STR0269, oFont01,,,,1) //"Valor Liberado (R$)"
		oPrint:Say(nLinIni + 25, (nColIni + nColMax)*0.90, "20 - "+STR0297, oFont01,,,,1) //"Valor da Glosa (R$)"

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 25)
		
		if lBox .and. nI != Len(adadPag)
			oPrint:Line(nLinIni + 0035, nColIni + 0010, 			nLinIni + 0115, nColIni  + 0010)
			oPrint:Line(nLinIni + 0010, nColIni + nColMax - 0010, 	nLinIni + 0115, nColIni + nColMax - 0010)
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10)
		Endif

		oPrint:Say(nLinIni + 0035, nColIni + 0020, substr(adadPag[nI][5], 7, 2) + "/" + substr(adadPag[nI][5], 5, 2) + "/" + substr(adadPag[nI][5], 1, 4), oFont04) //"14 - Data do Protocolo"
		oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.15, adadPag[nI][6], oFont04) //"15 - Número do Protocolo"
		oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.30, retNumLote(adadPag[nI][6]), oFont04) //"16 - Número do Lote"
		oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.45, IIf(!Empty(Str(adadPag[nI][1])),formatReal(adadPag[nI][1]),""), oFont04,,,,1) //"17 - Valor Informado"
		oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.60, IIf(!Empty(Str(adadPag[nI][2])),formatReal(adadPag[nI][2]),""), oFont04,,,,1) //"18 - Valor Processado"
		oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.75, IIf(!Empty(Str(adadPag[nI][3])),formatReal(adadPag[nI][3]),""), oFont04,,,,1) //"19 - Valor Liberado"
		oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.90, IIf(!Empty(Str(adadPag[nI][4])),formatReal(adadPag[nI][4]),""), oFont04,,,,1) //"20 - Valor da Glosa"
		fSomaLin(nLinMax+50, nColMax, @nLinIni, nColIni, 45)

		adadGuias := PLDemoFun()

		For nZ := 1 To Len(adadGuias)

			if nZ == 1

				oPrint:Say(nLinIni + 0015, (nColIni + 15), "Dados da Guia", oFont04) 

				if nI == Len(adadPag)
					oPrint:Line(nLinIni , nColIni + 0010, 					nLinIni , 	nColIni + nColMax - 0010)	//linha superior								
				else
					oPrint:Box(nLinIni + 0020, nColIni + 0010, IIF((nLinIni + 10 + 35 + (Len(adadGuias) * 35)) < nLinMax,(nLinIni + 10 + 35 + (Len(adadGuias) * 35)),nLinMax-50), nColIni + nColMax -0010)
				endif

				oPrint:Say(nLinIni + 0035, (nColIni + 20), "44 - Número da Guia no Prestador", oFont04) 
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.15, "45 - Número da Guia Atribuído pela Operadora", oFont04) 
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.30, "46 - Senha", oFont04) 
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.45, "47 - Tipo de Pagamento", oFont04) 

				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.60, "48 - Valor Processado", oFont04)
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.75, "49 - Valor Liberado", oFont04) 
				oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.90, "50 - Valor da Glosa", oFont04) 

				fSomaLin(nLinMax+50, nColMax, @nLinIni, nColIni, 25)

			endif

			oPrint:Say(nLinIni + 0035, (nColIni + 20), adadGuias[nZ][1], oFont04) //Valor do campo 44
			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.15, adadGuias[nZ][2], oFont04) //Valor do campo 45
			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.30, adadGuias[nZ][3], oFont04) //Valor do cmapo 46
			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.45, adadGuias[nZ][4], oFont04) //Valor do campo 47

			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.60, formatReal(adadGuias[nZ][5]), oFont04) //Valor do campo 48
			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.75, formatReal(adadGuias[nZ][6]), oFont04) //Valor do campo 49
			oPrint:Say(nLinIni + 0035, (nColIni + nColMax)*0.90, formatReal(adadGuias[nZ][7]), oFont04) //valor do campo 50

			fSomaLin(nLinMax+50, nColMax, @nLinIni, nColIni, 25)

		Next
		
		aSomadat[1] += adadPag[nI][1]
		aSomadat[2] += adadPag[nI][2]
		aSomadat[3] += adadPag[nI][3]
		aSomadat[4] += adadPag[nI][4]

		If nI == Len(adadPag) .OR. ( adadPag[nI][7] <> adadPag[nI+1][7] .AND. empty(cCompeten)) 

			//Linha do final das faturas quando possui > 1 página
			if lBox
				oPrint:Line(nLinIni + 0025, nColIni + 0010, nLinIni + 0025, nColIni + nColMax - 0010)
			Endif

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 70)

			AddTBrush(oPrint, nLinIni + 0002, nColIni + 0010, nLinIni + 0035, nColIni + nColMax)
			oPrint:Say(nLinIni + 0025, nColIni + 0020, STR0281, oFont01) //"Valores Totais do Demonstrativo - Bruto"
			
			oPrint:Box(nLinIni + 0042, nColIni + 0010, nLinIni + 0126, (nColIni + nColMax)*0.22 - 0010)
			oPrint:Say(nLinIni + 0066, nColIni + 0024, "21 - Valor Total Informado por Data de Pagamento(R$) (soma do campo 17)", oFont01)
			oPrint:Say(nLinIni + 0106, (nColIni + nColMax)*0.22 - 0130, formatReal(aSomadat[1]) , oFont04,,,,1)

			oPrint:Box(nLinIni + 0042, (nColIni + nColMax)*0.22, nLinIni + 0126, (nColIni + nColMax)*0.44 - 0005)
			oPrint:Say(nLinIni + 0066, (nColIni + nColMax)*0.22 + 0020, "22 - Valor Total Processado por Data de Pagamento (R$) (soma do campo 18)", oFont01)
			oPrint:Say(nLinIni + 0106, (nColIni + nColMax)*0.44 - 0130, formatReal(aSomadat[2]) , oFont04,,,,1)

			
			oPrint:Box(nLinIni + 0042, (nColIni + nColMax)*0.44, nLinIni + 0126, (nColIni + nColMax)*0.44 + 0615)
			oPrint:Say(nLinIni + 0066, (nColIni + nColMax)*0.44 + 0020, "23 - Valor Total Liberado por Data de Pagamento(R$)  (soma do campo 19)", oFont01) 
			oPrint:Say(nLinIni + 0106, (nColIni + nColMax)*0.65 - 0130, formatReal(aSomadat[3]) , oFont04,,,,1)
			
			oPrint:Box(nLinIni + 0042, (nColIni + nColMax)*0.65, nLinIni + 0126, (nColIni + nColMax)*0.80 + 0150)
			oPrint:Say(nLinIni + 0066, (nColIni + nColMax)*0.65 + 0020, "24 - Valor Total Glosa por Data de Pagamento(R$) (soma do campo 20)", oFont01)
			oPrint:Say(nLinIni + 0106, (nColIni + nColMax)*0.85 - 0130, formatReal(aSomadat[4]) , oFont04,,,,1)

			aSomatot[1] += aSomadat[1]
			aSomatot[2] += aSomadat[2]
			aSomatot[3] += aSomadat[3]
			aSomatot[4] += aSomadat[4]

			lZera := .T.
			nZ := nI + 1
			Exit
		else
			fSomaLin(nLinMax+50, nColMax, @nLinIni, nColIni, 25)
		Endif		
	Next nI

	If !lZera
		nZ := nZ + 1
	endIf

	aDebCrZ := {} // zeramos a cada passagem, porque trata-se de diferentes datas
	For nI := 1 To nZ - 1
		If ascan(aE2Num, adadPag[nI][14]) == 0
			aadd(aE2Num, adadPag[nI][14])
			For nY := 8 To 13
				If adadPag[nI][nY] > 0
					aadd(aDebCrZ, {'1', ;
						IIF(nY == 8, "01", IIF( nY == 9, "02", IIF( nY == 10, "03", IIF( nY == 11, "04", IIF( nY == 12, "05", "06"))))), ;
						IIF(nY == 8, "IRRF", IIF( nY == 9, "ISS", IIF( nY == 10, "INSS", IIF( nY == 11, "PIS", IIF( nY == 12, "COF", "CSLL"))))), ;
						adadPag[nI][nY]})
				endIf
			Next
		EndIf
	Next

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)

	AddTBrush(oPrint, nLinIni + 0036, nColIni + 0010, nLinIni + 0067, nColIni + nColMax)
	oPrint:Say(nLinIni + 0060, nColIni + 0020, "Demais débitos / créditos", oFont01) //Demais débitos / créditos

	oPrint:Box(nLinIni + 0080, nColIni + 0010, nLinIni + 150 + (Len(aDebCrZ) * 45), nColIni + nColIni + nColMax - 0010)
	nLinIni += 20
	oPrint:Say(nLinIni + 0090, nColIni + 0020, "25 - Indicação", oFont01) //"25 - Indicação"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.10, "26 - Código do Débito/Crédito", oFont01) //"26 - Código do Débito/Crédito"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.20, "27 - Descrição do Débito/Crédito", oFont01) //"27 - Descrição d Débito/Crédito"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.90, "28 - Valor (R$)", oFont01) //"28 - Valor (R$)"

	//Verifica se existe imposto no campo 25
	if Len(aDebCrZ) > 0
		
		//Para cada array do campo 25, isto é, cada linha de imposto, percorre os dados e inclui no relatório:
		For nI := 1 To Len(aDebCrZ)
			oPrint:Say(nLinIni + 0130, nColIni + 0020, 				aDebCrZ[nI][1], oFont04) //"25 - Indicação"
			oPrint:Say(nLinIni + 0130, (nColIni + nColMax)*0.10, 	aDebCrZ[nI][2], oFont04) //"26 - Código do Débito/Crédito"
			oPrint:Say(nLinIni + 0130, (nColIni + nColMax)*0.20, 	descTissSp('27', aDebCrZ[nI][2]), oFont04) //"27 - Descrição d Débito/Crédito"
			oPrint:Say(nLinIni + 0130, (nColIni + nColMax)*0.90, 	formatReal(aDebCrZ[nI][4]) , oFont04) //"28 - Valor (R$)"
			
			aDebCreDat[1] += aDebCrZ[nI][4]

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
		Next nI
	else
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
	endif

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140)

	AddTBrush(oPrint, nLinIni + 0007, nColIni + 0010, nLinIni + 0037, nColIni + nColMax)
	oPrint:Say(nLinIni + 0030, nColIni + 0020, "Valores Líquidos por Data de Pagamento", oFont01)
	
	oPrint:Box(nLinIni + 0040, nColIni + 0010, nLinIni + 0126, (nColIni + nColMax)*0.16 + 0090)
	oPrint:Say(nLinIni + 0060, nColIni + 0030, "29 - Valor Total de Demais Débitos por Data de Pagamento (R$)", oFont01) //"29 - Valor Total de Demais Débitos(R$)"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.19 - 0130, formatReal(aDebCreDat[1]) , oFont04,,,,1)

	oPrint:Box(nLinIni + 0040, (nColIni + nColMax)*0.20, nLinIni + 0126, (nColIni + nColMax)*0.39 - 0010)
	oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.20 + 0020, "30 - Valor Total de Demais Créditos por Data de Pagamento (R$)", oFont01) //"30 - Valor Total de Demais Créditos(R$)"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.39 - 0130, formatReal(aDebCreDat[2]), oFont04,,,,1)

	oPrint:Box(nLinIni + 0040, (nColIni + nColMax)*0.39, nLinIni + 0126, (nColIni + nColMax)*0.55 + 0100)
	oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.39 + 0020, "31 - Valor Final a Receber por Data de Pagamento (R$) (23-29+30)", oFont01) //"31 - Valor Final a Receber(R$)(23-29+30)"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.58 - 0130, formatReal( aSomadat[3] + aDebCreDat[2] - aDebCreDat[1] ), oFont04,,,,1)

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130)
	
	AddTBrush(oPrint, nLinIni + 0007, nColIni + 0010, nLinIni + 0037, nColIni + nColMax)
	oPrint:Say(nLinIni + 0030, nColIni + 0020, "Valores Totais do Demonstrativo - Bruto", oFont01) //"Valores Totais do Demonstrativo - Bruto"

	oPrint:Box(nLinIni + 0040, nColIni + 0010, nLinIni + 0126, (nColIni + nColMax)*0.15 - 0010)
	oPrint:Say(nLinIni + 0060, nColIni + 0030, "32 - Valor Total Informado(R$)(somat.campo 21)", oFont01) //"32 - Valor Total Informado(R$)"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.15 - 0130, formatReal(aSomatot[1]) , oFont04,,,,1)

	oPrint:Box(nLinIni + 0040, (nColIni + nColMax)*0.15, nLinIni + 0126, (nColIni + nColMax)*0.30 - 0010)
	oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.15 + 0020, "33-Valor Total Processado(R$) (somat.campo 22)", oFont01) //"33 - Valor Total Processado(R$) (somatório do campo 22)"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.30 - 0130, formatReal(aSomatot[2]) , oFont04,,,,1)

	oPrint:Box(nLinIni + 0040, (nColIni + nColMax)*0.30, nLinIni + 0126, (nColIni + nColMax)*0.45 - 0010)
	oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.30 + 0020, "34 - Valor Total Liberado (R$)  (somat.campo 23)", oFont01) //"34 - Valor Total Liberado (R$)  (somatório do campo 23)"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.45 - 0130, formatReal(aSomatot[3]) , oFont04,,,,1)

	oPrint:Box(nLinIni + 0040, (nColIni + nColMax)*0.45, nLinIni + 0126, (nColIni + nColMax)*0.60 - 0010)
	oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.45 + 0020, "35 - Valor Total Glosa (R$)   (somat.campo 24)", oFont01) //"35 - Valor Total Glosa (R$)   (somatório do campo 24)"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.60 - 0130, formatReal(aSomatot[4]) , oFont04,,,,1)

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)

	AddTBrush(oPrint, nLinIni + 0036, nColIni + 0010, nLinIni + 0067, nColIni + nColMax)
	oPrint:Say(nLinIni + 0060, nColIni + 0020, "Demais Débitos / Créditos do Demonstrativo", oFont01) //"Demais Débitos do Demonstrativo - Liquido"

	oPrint:Box(nLinIni + 0080, nColIni + 0010, nLinIni + 120 + Len(adadDebCre) * 45, nColIni + nColIni + nColMax - 0010)

	nLinIni += 20
	oPrint:Say(nLinIni + 0090, nColIni + 0020, "36 - Indicação", oFont01)
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.10, "37 - Código do Débito/Crédito", oFont01) 
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.20, "38 - Descrição do Débito/Crédito", oFont01) 
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.90, "39 - Valor (R$)", oFont01) 

	if !Empty(adadDebCre)
		For nI := 1 To Len(adadDebCre)
			oPrint:Say(nLinIni + 0130, nColIni + 0020, adadDebCre[nI][2], oFont04) //"36 - Indicação
			oPrint:Say(nLinIni + 0130, (nColIni + nColMax)*0.10, deParaSimpl('27', adadDebCre[nI][3]), oFont04) //"37 - Código do Débito/Crédito"
			oPrint:Say(nLinIni + 0130, (nColIni + nColMax)*0.20, descTissSp('27', deParaSimpl('27', adadDebCre[nI][3])), oFont04) //"38 - Descrição do Débito/Crédito"
			oPrint:Say(nLinIni + 0130, (nColIni + nColMax)*0.90, formatReal(adadDebCre[nI][1]), oFont04) //"39 - Valor (R$)"

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30)

			If adadDebCre[nI][2] == "2"
				aDebCreTot[2] += adadDebCre[nI][1]
			else
				aDebCreTot[1] += adadDebCre[nI][1]
			EndIf

		Next nI
	else
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30)
	endif
	
	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140)

	AddTBrush(oPrint, nLinIni + 0007, nColIni + 0010, nLinIni + 0037, nColIni + nColMax)
	oPrint:Say(nLinIni + 0030, nColIni + 0020, "Valores Totais do Demonstrativo - Bruto", oFont01) //"Valores Totais do Demonstrativo - Bruto"

	oPrint:Box(nLinIni + 0040, nColIni + 0010, nLinIni + 0126, (nColIni + nColMax)*0.15 - 0010)
	oPrint:Say(nLinIni + 0060, nColIni + 0030, "40 - Valor Total de Demais Débitos(R$)", oFont01) //"40 - Valor Total de Demais Débitos(R$)"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.15 - 0130, formatReal(aDebCreTot[1]) , oFont04,,,,1)

	oPrint:Box(nLinIni + 0040, (nColIni + nColMax)*0.15, nLinIni + 0126, (nColIni + nColMax)*0.30 - 0010)
	oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.15 + 0020, "41 - Valor Total de Demais Créditos(R$)", oFont01) //"41 - Valor Total de Demais Créditos"
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.30 - 0130, formatReal(aDebCreTot[2]) , oFont04,,,,1)

	oPrint:Box(nLinIni + 0040, (nColIni + nColMax)*0.30, nLinIni + 0126, (nColIni + nColMax)*0.45 - 0010)
	oPrint:Say(nLinIni + 0060, (nColIni + nColMax)*0.30 + 0020, "42 - Valor Final a Receber (R$) (34-40+41)", oFont01) 
	oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.45 - 0130, formatReal( aDebCreTot[2] - aDebCreTot[1] + aSomatot[3]), oFont04,,,,1) //"42 - Valor Final a Receber"

	AddTBrush(oPrint, nLinIni + 0150, nColIni + 0350 + nColA4, nLinIni + 0550, nColIni + nColMax - 0010)
	oPrint:Box(nLinIni + 0150, nColIni + 0010, nLinIni + 0380, nColIni + nColMax- 0010)
	oPrint:Say(nLinIni + 0170, nColIni + 0020, "43 - Observação / Justificativa", oFont01) //"43 - Observação / Justificativa"

	oPrint:Say(nLinIni + 0220, nColIni + 0400 + nColA4, "", oFont04)
	
	oPrint:EndPage()	// Finaliza a pagina

	//Visualiza impressao grafica antes de imprimir	
	oPrint:preview()
	
endIf

return( { cFileName + ".pdf",cMsg } )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRELDAC
Demostrativo de Analise de Contas

@author  PLS TEAM
@version P12
@since   19.01.13
/*/
//-------------------------------------------------------------------
function PLSRELDAC(cCodRda,cAnoW,cMesW,lWeb,cPathW,cNmTitPg,cAlias, lExbProt, cSoGlosa,lAutomacao)
LOCAL nI		:= 0
LOCAL nJ		:= 0
LOCAL nX		:= 0
LOCAL nX1		:= 0
LOCAL nX2		:= 0
LOCAL nX3		:= 0
LOCAL nX4		:= 0
LOCAL nInfGer   := 0
LOCAL nInfGui   := 0
LOCAL nInfFat   := 0
LOCAL nProcGui  := 0
LOCAL nLibGui   := 0
LOCAL nGloGui   := 0
LOCAL nLinMax	:=	2300
LOCAL nColMax	:=	2950
LOCAL nLinIni	:= 0
LOCAL nColIni	:= 0
LOCAL nColA4    := 0
LOCAL cCodOpe   := ""
LOCAL cRdaDe    := ""
LOCAL cRdaAte   := ""
LOCAL cAno      := ""
local cProtocolo := ""
LOCAL cMes      := ""
LOCAL cMsg		:= ""
LOCAL cFileName	:= ""
LOCAL cPathSrv 	:= lower(getMV("MV_RELT"))
LOCAL cPerg		:= "PLSRELDAC"
LOCAL oFont01   := nil
LOCAL oFont02n	:= nil
LOCAL oFont04	:= nil
LOCAL aDados	:= {}
LOCAL lBox		:= .f.
LOCAL lContinua	:= .t.
Local nTimeSleep := 2000
Local nQtdProc := 0
Local nQtdPagina := 0
local cLogoGH		:= plGetImgRel()

local nQtdGlo := 1
local aCodGlo := {}
local nQuebraLin := 1
local nAdcLinha := 1
local cGlosas := ""
local cDataIniF := ""
local cDataFimF := ""

Local aSomaProt := {0,0,0,0}

PRIVATE oPrint	:= nil
DEFAULT lWeb	:= .f.
DEFAULT cCodRda	:= ""
DEFAULT cAnoW	:= ""
DEFAULT cMesW	:= ""
DEFAULT cPathW	:= ""
DEFAULT cNmTitPg := ""
DEFAULT cAlias   := "SE2"
DEFAULT lExbProt := .F. //Se for remote, indica se exibe o pergunte conforme padrão TISS RDA + PROTOCOLO
default lAutomacao := .f.

//Somente se nao for web
if !lWeb .and. !lAutomacao

	//Tratamento no SX1
	if( lExbProt )
		cPerg := "PLSRELACP"
	endIf

	//Acessa parametros do relatorio...
	if !pergunte(cPerg,.T.)
		return
	endIf

	//Dados do pergunte
	if !lExbProt
		cCodOpe   := mv_par01
		cRdaDe    := mv_par02
		cRdaAte   := mv_par03
		cAno      := mv_par04
		cMes      := mv_par05
	else
		cCodOpe    := mv_par01
		cRdaDe     := mv_par02
		cRdaAte    := mv_par03
		cProtocolo := mv_par04
	endif
else
	cCodOpe   := plsintpad()
	cRdaDe    := cCodRda
	cRdaAte   := cCodRda
	cAno      := cAnoW
	cMes      := cMesW
	cPathSrv  := cPathW
endIf

//Montando dados
if !lWeb
	if !lExbProt
		msAguarde( {|| aadd(aDados, PLSDACMB(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, nil, nil , nil, nil,cNmTitPg) ) }, "DEMONSTRATIVO DE ANÁLISE DE CONTA", "", .t.)
	else
		msAguarde( {|| aadd(aDados, PLSDACMB(cCodOpe, cRdaDe, cRdaAte, nil, nil,nil,nil,nil,nil,nil,cProtocolo, cProtocolo) ) }, "DEMONSTRATIVO DE ANÁLISE DE CONTA", "", .t.)
	endif
else
	aadd(aDados, PLSDACMB(cCodOpe, cRdaDe, cRdaAte, /*cAno*/nil, /*cMes*/nil,  nil, nil , nil, nil,,cNmTitPg,cNmTitPg,iif(cSoGlosa = 'S', .T., .F.) ) )
endIf

//Verifica se foi encontrado conteudo
if len(aDados[1]) == 0
	if !lWeb .and. !lAutomacao
		msgAlert("Não foram encontrados dados para os parâmetros informados!")
	else
		cMsg := "Não foram encontrados dados para os parâmetros informados!"
	endIf

	if lAutomacao
		return {.f., cMsg}
	endif
	lContinua := .f.
endIf

//Se existe dados ou nao
if lContinua

	//Fonte Normal
	oFont01	 := TFont():New("Arial",  8,  8, , .F., , , , .T., .F.)
	oFont02n := TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont03n := TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04	 := TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal

	//DAHER - Tive que colocar esse Semaforo aqui pois por alguma razao
	//quando duas transacoes chamavam ao mesmo tempo o FWMSPRINTER
	//eventualmente alguma delas nao retornava, ou seja, ele entrava
	//no FWMSPRINTER e nunca saia
	if (!lAutomacao)
		cFileName	:= lower("PLSRELDAC" + criaTrab(nil,.f.) + "_" + cCodRda) // Colocado a RDA no nome do arquivo pro filtro no portal
	endif
	
	nH := PLSAbreSem("PPLSRELDAC.SMF")
	oPrint := FWMSPrinter():New(cFileName,IMP_PDF,.t.,nil,.t.,nil,@oPrint,nil,nil,.f.,.f.,.t.)
	PLSFechaSem(nH,"PPLSRELDAC.SMF")

	oPrint:lInJob  	:= lWeb
	oPrint:lServer 	:= lWeb
	oPrint:cPathPDF	:= cPathSrv
	
	//Resolução do relatorio
	oPrint:setResolution(72)

	//Modo paisagem
	oPrint:setLandscape()

	//Papel A4
	oPrint:setPaperSize(TAM_A4)
	
	//Margem
	oPrint:setMargin(05,05,05,05)
	
	//Verifica se existe alguma impressora configurada para Impressao Grafica
	if !lWeb .and. !lAutomacao
		oPrint:setup()
	endIf
	
	//Dados
	//Para todo relatório do aDados por PEG
	//TISS >= 3.XX.XX
	
	//Zera dados de qtd procedimentos e qtd paginas
	nQtdPaginas := 0
	nQtdProc := 0
	
	For nX := 1 To Len(aDados[1])

		If ValType(aDados[1,nX]) == 'U' .OR. Len(aDados[1,nX]) == 0
			Loop
		EndIf

		For nI := 23 To 33
			If Len(aDados[1,nX, nI]) < 1
				For nJ := Len(aDados[1,nX, nI]) + 1 To 5
					If AllTrim(Str(nI)) $ "23"
						aAdd(aDados[1,nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "28,29,30,31,32"
						aAdd(aDados[1,nX, nI], 0)
					Else
						aAdd(aDados[1,nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nX1 := 1 To Len(aDados[1,nX, 02])

			If nX1 > 1
				oPrint:EndPage()
			Endif

			nLinIni := 060
			nColIni := 060
			nColA4  := 000

			oPrint:StartPage()		// Inicia uma nova pagina
			
			//Box Principal
			oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinMax, nColIni + nColMax)

			//Carrega e Imprime Logotipo da Empresa
			if fLogoEmp(@cLogoGH)
				oPrint:sayBitmap(nLinIni + 0050, nColIni + 0020, cLogoGH, 400, 090)
			endIf

			oPrint:Say(nLinIni + 0080, nColIni + 1252, "DEMONSTRATIVO DE ANÁLISE DE CONTA", oFont02n,,,, 2)

			oPrint:Say(nLinIni + 0090, (nColIni + nColMax)*0.80, 		  "2- N", oFont01)
			oPrint:Say(nLinIni + 0080, (nColIni + nColMax)*0.80 + 0050, aDados[1,nX, 02, nX1], oFont03n)

			nLinIni += 60
			oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, (nColIni + nColMax)*0.1 - 0010)
			oPrint:Say(nLinIni + 0195, nColIni + 0020, "1 - Registro ANS", oFont01) //1-Registro ANS
			oPrint:Say(nLinIni + 0240, nColIni + 0030, aDados[1,nX, 01], oFont04)
			oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.1, nLinIni + 0269, (nColIni + nColMax)*0.67 - 0010)
			oPrint:Say(nLinIni + 0195, (nColIni + nColMax)*0.1 + 0010, "3 - Nome da Operadora", oFont01) //"3-Nome da Operadora
			oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.1 + 0020, aDados[1,nX, 03], oFont04)
			oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.67, nLinIni + 0269, (nColIni + nColMax)*0.87 - 0010)
			oPrint:Say(nLinIni + 0195, (nColIni + nColMax)*0.67 + 0010, "4 - CNPJ da Operadora", oFont01) //4-CNPJ da Operadora
			oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.67 + 0020, aDados[1,nX, 04], oFont04)
			oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.87, nLinIni + 0269, nColIni + nColMax - 0010)
			oPrint:Say(nLinIni + 0195, (nColIni + nColMax)*0.87 + 0010, "5 - Data de Emissão", oFont01) //5-Data de Emissao
			oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.87 + 0020, DtoC(aDados[1,nX, 05, nX1]), oFont04)

			nInfGer := 0
			nProcGer := 0
			nLibGer  := 0
			nGloGer  := 0
			nInfFat := 0
			nProcFat := 0
			nLibFat  := 0
			nGloFat  := 0
			
			nLinIni += 140
			For nX2 := 1 To Len(aDados[1,nX, 9, nX1])
				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 40)
				AddTBrush(oPrint, nLinIni , nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
				oPrint:Say(nLinIni + 0023, nColIni + 0020, "Dados do Prestador", oFont01) //Dados do Prestador
				
				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10, 40)
				oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127, (nColIni + nColMax)*0.22 - 0010)
				oPrint:Say(nLinIni + 0053, nColIni + 0020, "6 - Código na Operadora", oFont01) //6 - Código na Operadora
				oPrint:Say(nLinIni + 0093, nColIni +  0030, aDados[1,nX, 06, nX1], oFont04)
				oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.22, nLinIni + 0127, (nColIni + nColMax)*0.90 - 0010)
				oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.22 + 0010, "7 - Nome do Contratado", oFont01) //7- Nome do Contratado
				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.22 + 0020, aDados[1,nX, 07, nX1], oFont04)
				oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.90, nLinIni + 0127, nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.90 + 0010, "8 - Código CNES", oFont01) //8 - Código CNES
				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.90 + 0020, aDados[1,nX, 08, nX1], oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 40)
				AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
				oPrint:Say(nLinIni + 0023, nColIni + 0020, "Dados do Lote/Protocolo", oFont01) //Dados do Lote/Protocolo

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10, 40)
				oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127, (nColIni + nColMax)*0.18 - 0010)
				oPrint:Say(nLinIni + 0053, nColIni + 0020, "9 - Número do Lote", oFont01) //9 - Número do Lote
				oPrint:Say(nLinIni + 0093, nColIni + 0030, aDados[1,nX, 9, nX1, nX2], oFont04)
				oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.18, nLinIni + 0127, (nColIni + nColMax)*0.35 - 0010)
				oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.18 + 0010, "10 - Número do Protocolo", oFont01) //10 - Número do Protocolo
				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.18 + 0020, aDados[1,nX, 10, nX1, nX2], oFont04)
				oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.35, nLinIni + 0127, (nColIni + nColMax)*0.48 - 0010)
				oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.35 + 0010, "11 - Data do Protocolo", oFont01) //11 - Data do Protocolo
				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.35 + 0010, DtoC(aDados[1,nX, 11, nX1, nX2]), oFont04)
				oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.48, nLinIni + 0127, (nColIni + nColMax)*0.60 - 0010)
				oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.48 + 0010, "12 - Código da Glosa do Protocolo", oFont01) //12 - Código da Glosa do Protocolo
				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.55 + 0010, aDados[1,nX, 12, nX1, nX2], oFont04)
				oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.60, nLinIni + 0127, (nColIni + nColMax)*0.85 - 0010)
				oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.60 + 0010, "13 - Código da Situação do Protocolo", oFont01) //13 - Código da Situação do Protocolo
				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.65 + 0010, aDados[1,nX, 13, nX1, nX2], oFont04)

				For nX3 := 1 To Len(aDados[1,nX, 14, nX1,nX2])
					//Só adiciona a guia SE houver procedimentos
					if aDados[1,nX, 14, nX1,nX2, nX3] <> NIL .and. len(aDados[1,nX, 25, nX1,nX2, nX3]) > 0
													
						If nX3 > 1 .and. nQtdPaginas > 0
							oPrint:EndPage()
							oPrint:StartPage()		// Inicia uma nova pagina	
							
							//Imprime box principal
							oPrint:Box(060, 060, nLinMax, nColIni + nColMax)
							
							nLinIni := 080
							nColIni := 060														
						Else
							fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 150, 40)
						Endif							
						
						AddTBrush(oPrint, nLinIni - 0005, nColIni + 0010, nLinIni + 0026, nColIni + nColMax)
						oPrint:Say(nLinIni + 0013, nColIni + 0020, "Dados da Guia", oFont01) //Dados da Guia
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127, (nColIni + nColMax)*0.30 - 0010)
						oPrint:Say(nLinIni + 0053, nColIni + 0020, "14 - Número da Guia no Prestador", oFont01) //13 - Número da Guia no Prestador
						oPrint:Say(nLinIni + 0093, nColIni +  0030, aDados[1,nX, 14, nX1,nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0127,(nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.30 + 0010, "15 - Número da Guia Atribuído pela Operadora", oFont01) //14 - Número da Guia Atribuído pela Operadora
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.30 + 0020, aDados[1,nX, 15,nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.60, nLinIni + 0127, (nColIni + nColMax)*0.85 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.60 + 0010, "16 - Senha", oFont01) //15 -Senha
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.60 + 0020, aDados[1,nX, 16, nX1,nX2, nX3], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)

						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127,(nColIni + nColMax)*0.55 - 0010)
						oPrint:Say(nLinIni + 0053, nColIni + 0020, "48 - Nome Social", oFont01) //48 - Nome Social
						oPrint:Say(nLinIni + 0093, nColIni + 0030, aDados[1,nX, 49,nX1, nX2, nX3], oFont04) //posição 49 do array

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)

						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127,(nColIni + nColMax)*0.55 - 0010)
						oPrint:Say(nLinIni + 0053, nColIni + 0020, "17 - Nome do beneficiário", oFont01) //16 - Nome do beneficiário
						oPrint:Say(nLinIni + 0093, nColIni + 0030, aDados[1,nX, 17,nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.55, nLinIni + 0127, (nColIni + nColMax)*0.85 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.55 + 0010, "18 - Número da Carteira", oFont01) //17 - Número da Carteira
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.55 + 0020, aDados[1,nX, 18, nX1,nX2, nX3], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0127,(nColIni + nColMax)*0.15 - 0010)

						cDataIniF := iif(valType(aDados[1,nX, 19,nX1, nX2, nX3]) == "D", ;
											DtoC(aDados[1,nX, 19,nX1, nX2, nX3]), ; 
											aDados[1,nX, 19,nX1, nX2, nX3]) 
						cDataFimF := iif(valType(aDados[1,nX, 21,nX1, nX2, nX3]) == "D", ;
											DtoC(aDados[1,nX, 21,nX1, nX2, nX3]), ; 
											aDados[1,nX, 21,nX1, nX2, nX3]) 

						oPrint:Say(nLinIni + 0053, nColIni + 0020, "19 - Data do Início do Faturamento", oFont01) //18 - Data do Início do Faturamento
						oPrint:Say(nLinIni + 0093, nColIni + 0030, cDataIniF, oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.15, nLinIni + 0127, (nColIni + nColMax)*0.30 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.15 + 0010, "20 - Hora do Início do Faturamento", oFont01) //19 - Hora do Início do Faturamento
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.15 + 0020, aDados[1,nX, 20, nX1,nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0127, (nColIni + nColMax)*0.45 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.30 + 0010, "21 - Data do Fim do Faturamento", oFont01) //20 - Data do Fim do Faturamento
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.30 + 0020, cDataFimF, oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.45, nLinIni + 0127, (nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.45 + 0010, "22 - Hora do Fim do Faturamento", oFont01) //21 - Hora do Fim do Faturamento
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.45 + 0020, aDados[1,nX, 22, nX1,nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.60, nLinIni + 0127, (nColIni + nColMax)*0.75 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.60 + 0010, "23 - Código da Glosa da Guia", oFont01) //22 - Código da Glosa da Guia
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.60 + 0020, aDados[1,nX, 23, nX1,nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.75, nLinIni + 0127, (nColIni + nColMax)*0.85 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.75 + 0010, "24 - Código da Situação da Guia", oFont01) //24 - Código da Situação da Guia
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.75 + 0020, aDados[1,nX, 24, nX1,nX2, nX3], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)

						// valida se algum procedimento tem 3 glosas ou mais, sendo necessário
						// quebrar a linha, aumentando o tamanho do Box/Line com o nQuebraLin
						nQuebraLin := 0
						For nX4 := 1 To Len(aDados[1,nX, 25, nX1,nX2, nX3])
							
							aCodGlo := StrTokArr( aDados[1,nX, 35, nX1,nX2, nX3, nX4], "," )
							for nQtdGlo := 1 to len(aCodGlo)
								if(len(aCodGlo) > 2)
									if(nQtdGlo>=3 .and. mod(nQtdGlo, 2) == 1)
										nQuebraLin += 0020
									endif
								endif
							next nQtdGlo
						Next nX4

						lBox:=.F.
						if (nLinIni + 0110 + nQuebraLin + (Len(aDados[1,nX, 25, nX1,nX2, nX3]) * 45)) < nLinMax
							oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 110 + (Len(aDados[1,nX, 25, nX1,nX2, nX3]) * 45) + nQuebraLin, nColIni + nColMax -0010)
						Else
							oPrint:Line(nLinIni + 0030, nColIni + 0010, nLinIni + 0030, nColIni + nColMax - 0010)//linha superior
							
							oPrint:Line(nLinIni + 0030, nColIni + 0010, nLinIni + 0135 + nQuebraLin, nColIni + 0010)//linha esquerda
							oPrint:Line(nLinIni + 0030, nColIni + nColMax - 0010, nLinIni + 0135 + nQuebraLin, nColIni + nColMax - 0010)//linha direita
							lBox:=.T.
						Endif

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10, 40)
						oPrint:Say(nLinIni + 0045, nColIni + 0020, "25-Data de realização", oFont01) //23-Data de realização
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.10, "26-Tabela", oFont01) //24-Tabela
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.14, "27-Código do procedimento/", oFont01) //25-Código do procedimento/
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.14, "Item assistencial", oFont01) //Item assistencial
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.23, "28-Descrição", oFont01) //26-Descrição
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.60, "29-Grau de", oFont01) //27-Grau de
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.60, "Participação", oFont01) //Participação
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.65, "30-Valor Informado", oFont01,,,,1) //28-Valor Informado
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.72, "31-Quant.", oFont01,,,,1) //29-Quant.
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.72, "Executada", oFont01,,,,1) ////Executada
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.77, "32-Valor Processado", oFont01,,,,1) //30-Valor Processado
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.84, "33-Valor Liberado", oFont01,,,,1) //31-Valor Liberado
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.91, "34-Valor Glosa", oFont01,,,,1) //32-Valor Glosa
						oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.96, "35-Código", oFont01) //33-Código
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.96, "da Glosa", oFont01) //da Glosa

						nInfGui := 0
						nProcGui := 0
						nLibGui  := 0
						nGloGui  := 0

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10, 40)
						
						//Soma quantidade de procedimentos para cálculo do sleep
						nQtdProc += Len(aDados[1,nX, 25, nX1,nX2, nX3])
						nQtdPagina++
						
						For nX4 := 1 To Len(aDados[1,nX, 25, nX1,nX2, nX3])

							fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45, 40)
							
							if lBox									
								oPrint:Line(nLinIni , nColIni + 0010, nLinIni + 0050 + nQuebraLin, nColIni  + 0010)
								oPrint:Line(nLinIni , nColIni + nColMax - 0010, nLinIni + 0050 + nQuebraLin, nColIni + nColMax - 0010)
							Endif
							
							oPrint:Say(nLinIni + 0045, nColIni + 0020, IIf(Empty(aDados[1,nX, 25, nX1,nX2, nX3, nX4]), "", DtoC(aDados[1,nX, 25, nX1,nX2, nX3, nX4])), oFont04)
							oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.10, aDados[1,nX, 26, nX1,nX2, nX3, nX4], oFont04)
							oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.14, aDados[1,nX, 27, nX1,nX2, nX3, nX4], oFont04)
							oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.23, aDados[1,nX, 28, nX1,nX2, nX3, nX4], oFont04)
							oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.60, aDados[1,nX, 29, nX1,nX2, nX3, nX4], oFont04)
							oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.66, IIf(Empty(aDados[1,nX, 30, nX1, nX2, nX3, nX4]), "", Transform(aDados[1,nX, 30, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
							oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.72, IIf(Empty(aDados[1,nX, 31, nX1, nX2, nX3, nX4]), "", Transform(aDados[1,nX, 31, nX1, nX2, nX3, nX4], "@E 9999")), oFont04,,,,1)
							oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.78, IIf(Empty(aDados[1,nX, 32, nX1, nX2, nX3, nX4]), "", Transform(aDados[1,nX, 32, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
							oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.85, IIf(Empty(aDados[1,nX, 33, nX1, nX2, nX3, nX4]), "", Transform(aDados[1,nX, 33, nX1, nX2, nX3, nX4], "@E 999,999,999.99")), oFont04,,,,1)
							oPrint:Say(nLinIni + 0045, (nColIni + nColMax)*0.92, IIf(Empty(aDados[1,nX, 34, nX1, nX2, nX3, nX4]), "", Transform(aDados[1,nX, 34, nX1, nX2, nX3, nX4], "@E 9,999,999.99")), oFont04,,,,1)								

							// quebramos a string para saber se é necessário quebrar a linha quando
							// jogar os valores no pdf
							aCodGlo := StrTokArr( aDados[1,nX, 35, nX1,nX2, nX3, nX4], "," )
							nQuebraLin := 0
							nAdcLinha := 0045
							cGlosas := ""
							for nQtdGlo := 1 to len(aCodGlo)
								if(len(aCodGlo) == 1)
									oPrint:Say(nLinIni + nAdcLinha, (nColIni + nColMax)*0.95, aCodGlo[nQtdGlo], oFont04)
								else
									if(nQtdGlo>=3 .and. mod(nQtdGlo, 2) == 1)
										nAdcLinha += 0020
										nQuebraLin += 0020
									endif
									if(mod(nQtdGlo, 2) == 1)
										cGlosas += alltrim(aCodGlo[nQtdGlo]) + iif(nQtdGlo == len(aCodGlo), "", ", ")

										if(nQtdGlo == len(aCodGlo))
											oPrint:Say(nLinIni + nAdcLinha, (nColIni + nColMax)*0.95, cGlosas, oFont04)
											
										endif
									else
										cGlosas += alltrim(aCodGlo[nQtdGlo]) + iif(nQtdGlo == len(aCodGlo), "", ", ")
										oPrint:Say(nLinIni + nAdcLinha, (nColIni + nColMax)*0.95, cGlosas, oFont04)
										oPrint:Line(nLinIni + nAdcLinha, nColIni + 0010, nLinIni + nAdcLinha + 0025, nColIni + 0010)//linha esquerda
											oPrint:Line(nLinIni + nAdcLinha, nColIni + nColMax - 0010, nLinIni + nAdcLinha + 0025, nColIni + nColMax - 0010)//linha direita
										cGlosas := ""
									endif
								endif
							next nQtdGlo

							nLinIni += nQuebraLin
							
						Next nX4

						//Para arrumar o Box qdo tem muitos procedimentos e ultrapassam o tamanho da folha ->Luciano
						if lBox
							oPrint:Line(nLinIni + 0050, nColIni + 0010, nLinIni + 0050, nColIni + nColMax - 0010)
						Endif

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
						AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
						oPrint:Say(nLinIni + 0018, nColIni + 0020, "Total Guia", oFont01) //Total Guia

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10, 40)
						oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0137, (nColIni + nColMax)*0.15 - 0010)
						oPrint:Say(nLinIni + 0053, nColIni + 0020, "36 - Valor Informado da Guia (R$)", oFont01) //34 - Valor Informado da Guia (R$)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.15, nLinIni + 0137, (nColIni + nColMax)*0.30 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.15 + 0010, "37 - Valor Processado da Guia (R$)", oFont01) //35 - Valor Processado da Guia (R$)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0137, (nColIni + nColMax)*0.45 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.30 + 0010, "38 - Valor Liberado da Guia (R$)", oFont01) //36 - Valor Liberado da Guia (R$)
						oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.45, nLinIni + 0137, (nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.45 + 0010, "39 - Valor Glosa da Guia (R$)", oFont01) //37 - Valor Glosa da Guia (R$)

						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.15 - 0130, Transform(aDados[1,nX,36,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)//Transform(nInfGui, "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.30 - 0130, Transform(aDados[1,nX,37,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.45 - 0130, Transform(aDados[1,nX,38,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.60 - 0130, Transform(aDados[1,nX,39,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)

						aSomaProt[1] += aDados[1,nX,36,nX1,nX2,nX3]
						aSomaProt[2] += aDados[1,nX,37,nX1,nX2,nX3]
						aSomaProt[3] += aDados[1,nX,38,nX1,nX2,nX3]
						aSomaProt[4] += aDados[1,nX,39,nX1,nX2,nX3]

					end
				Next nX3

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 145, 40)
				AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
				oPrint:Say(nLinIni + 0018, nColIni + 0020, "Total do Protocolo", oFont01) //Total do Protocolo

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10, 40)
				oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0137, (nColIni + nColMax)*0.15 - 0010)
				oPrint:Say(nLinIni + 0053, nColIni + 0020, "40 - Valor Informado do Protocolo (R$)", oFont01) //38 - Valor Informado do Protocolo (R$)
				oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.15, nLinIni + 0137, (nColIni + nColMax)*0.30 - 0010)
				oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.15 + 0010, "41 - Valor Processado do Protocolo (R$)", oFont01) //39 - Valor Processado do Protocolo (R$)
				oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0137, (nColIni + nColMax)*0.45 - 0010)
				oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.30 + 0010, "42 - Valor Liberado do Protocolo (R$)", oFont01) //40 - Valor Liberado do Protocolo (R$)
				oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.45, nLinIni + 0137, (nColIni + nColMax)*0.60 - 0010)
				oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.45 + 0010, "43 - Valor Glosa do Protocolo (R$)", oFont01) //41 - Valor Glosa do Protocolo (R$)

				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.15 - 0130, Transform(aSomaProt[1], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.30 - 0130, Transform(aSomaProt[2], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.45 - 0130, Transform(aSomaProt[3], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.60 - 0130, Transform(aSomaProt[4], "@E 999,999,999.99"), oFont04,,,,1)
				aSomaProt := {0,0,0,0}
			Next nX2

		Next nX1

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 40)
		AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0031, nColIni + nColMax)
		oPrint:Say(nLinIni + 0018, nColIni + 0020, "Total Geral", oFont01) //Total Geral

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10, 40)
		oPrint:Box(nLinIni + 0033, nColIni + 0010, nLinIni + 0137, (nColIni + nColMax)*0.15 - 0010)
		oPrint:Say(nLinIni + 0053, nColIni + 0020, "44 - Valor Informado Geral (R$)", oFont01) //42 - Valor Informado Geral (R$)
		oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.15, nLinIni + 0137, (nColIni + nColMax)*0.30 - 0010)
		oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.15 + 0010, "45 - Valor Processado Geral (R$)", oFont01) //43 - Valor Processado Geral (R$)
		oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.30, nLinIni + 0137, (nColIni + nColMax)*0.45 - 0010)
		oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.30 + 0010, "46 - Valor Liberado Geral (R$)", oFont01) //44 - Valor Liberado Geral (R$)
		oPrint:Box(nLinIni + 0033, (nColIni + nColMax)*0.45, nLinIni + 0137, (nColIni + nColMax)*0.60 - 0010)
		oPrint:Say(nLinIni + 0053, (nColIni + nColMax)*0.45 + 0010, "47 - Valor Glosa Geral (R$)", oFont01) //45 - Valor Glosa Geral (R$)

		oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.15 - 0130, Transform(aDados[1,nX,44], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.30 - 0130, Transform(aDados[1,nX,45], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.45 - 0130, Transform(aDados[1,nX,46], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Say(nLinIni + 0093, (nColIni + nColMax)*0.60 - 0130, Transform(aDados[1,nX,47], "@E 999,999,999.99"), oFont04,,,,1)

		oPrint:EndPage()	// Finaliza a pagina

	Next nX

	//Visualiza impressao grafica antes de imprimir
	if (!lAutomacao)
		oPrint:Preview()
	endif

EndIF
	


//Checa se o arquivo PDF esta ponto para visualizacao na web e envio de e-mail.
if lWeb
	
	//Para até 20 procedimentos, mantém sempre o default da função PLSCHKRP que é 2000ms (2 segundos). Acima disso, adiciona 0.1segundo para cada procedimento
	if nQtdProc > 20
		nTimeSleep := nQtdProc * 300
	elseif nQtdPagina > 5
		nTimeSleep := nQtdPagina * 1000
	endif
	
	if nTimeSleep > 180000
		nTimeSleep := 180000
	endif

	PLSCHKRP(cPathSrv+cFileName+".pdf",nil,nTimeSleep)
endIf

if (lAutomacao)
	return {.t., aDados}
endif

//Fim da rotina
return( { cFileName + ".pdf",cMsg } )


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRELDPO
Demostrativo de Pagamento Odontologico

@author  PLS TEAM
@version P12
@since   19.01.13
/*/
//-------------------------------------------------------------------
function PLSRELDPO(cCodRda,cAnoW,cMesW,lWeb,cPathW,cNmTitPg)
LOCAL nI		:= 0
LOCAL nJ		:= 0
LOCAL nX		:= 0
LOCAL nX1		:= 0
LOCAL nX2		:= 0
LOCAL nX3		:= 0
LOCAL nX4		:= 0
LOCAL nProcGui  := 0
LOCAL nLibGui   := 0
LOCAL nGloGui   := 0
LOCAL nLinMax	:=	2300
LOCAL nColMax	:=	2950
LOCAL nLinIni	:= 0
LOCAL nColAjus	:= 250
LOCAL nColIni	:= 0
LOCAL nColA4    := 0
LOCAL cCodOpe   := ""
LOCAL cRdaDe    := ""
LOCAL cRdaAte   := ""
LOCAL cAno      := ""
LOCAL cMes      := ""
LOCAL cMsg		:= ""
LOCAL cFileName	:= lower("PLSRELDPO" + criaTrab(nil,.f.) + "_" + cCodRda) // Colocado a RDA no nome do arquivo pro filtro no portal
LOCAL cPathSrv 	:= lower(getMV("MV_RELT"))
LOCAL cPerg		:= "PLSRELDPO"
LOCAL oFont01   := nil
LOCAL oFont02n	:= nil
LOCAL oFont04	:= nil
LOCAL aDados	:= {}
LOCAL lBox		:= .f.
LOCAL lContinua	:= .t.
Local cTissVer := PLSTISSVER()
local cLogoGH		:= plGetImgRel()

PRIVATE oPrint	:= nil
DEFAULT lWeb	:= .f.
DEFAULT cCodRda	:= ""
DEFAULT cAnoW	:= ""
DEFAULT cMesW	:= ""
DEFAULT cPathW	:= ""
DEFAULT cNmTitPg := ""

//Somente se nao for web
if !lWeb
	
	//Acessa parametros do relatorio...	
	if !pergunte(cPerg,.T.)
		return
	endIf
	
	//dados do pergunte	
	cCodOpe   := mv_par01
	cRdaDe    := mv_par02
	cRdaAte   := mv_par03
	cAno      := mv_par04
	cMes      := mv_par05
else
	cCodOpe   := plsintpad()
	cRdaDe    := cCodRda
	cRdaAte   := cCodRda
	cAno      := cAnoW
	cMes      := cMesW
	cPathSrv  := cPathW
endIf

//montando dados
if !lWeb
	If (cTissVer < "3")
	msAguarde( {|| aadd(aDados, PLSDPGTOD(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, nil, cNmTitPg) ) }, "DEMONSTRATIVO DE PAGAMENTO ODONTOLÓGICO", "", .t.)
	Else
		msAguarde( {|| aadd(aDados, PLSDPGTODB(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, nil, cNmTitPg) ) }, "DEMONSTRATIVO DE PAGAMENTO ODONTOLÓGICO", "", .t.)
	EndIf
else
	If (cTissVer < "3")
	aadd(aDados, PLSDPGTOD(cCodOpe, cRdaDe, cRdaAte, cAno, cMes,nil, cNmTitPg) )
	Else
		aadd(aDados, PLSDPGTODB(cCodOpe, cRdaDe, cRdaAte, cAno, cMes,nil, cNmTitPg) )
	EndIf
endIf

//usar para teste no relatorio
/*
aDados  := { { "123456",;//1
				{"12345678901234567892"},;//2
				{Replicate("M",70)},;//3
				{"14.141.114/00001-35"},;//4
				{{CtoD("05/03/07"),CtoD("05/03/07")}},;//5
				{"14.141.114/00001-35"},;//6
				{Replicate("M",70)},;//7
				{"14.141.114/00001-35"},;//8
				{{"123456789012"}},;//9
				{{{"12345678901234567890"}}},;//10
				{{{Replicate("M",70)}}},;//11
				{{{"123456789012"}}},;//12
				{{{{"AA","BB","CC","DD","EE","FF","GG","HH","II","JJ","KK","LL","MM","NN","OO"}}}},;//13
				{{{{"1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890"}}}},;//14
				{{{{Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70)}}}},; //15
				{{{{"12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345","12345"}}}},;//16
				{{{{"ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD","ABCD"}}}},;//17
				{{{{CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07"),CtoD("05/03/07")}}}},;//18
				{{{{10,20,30,40,50,60,70,80,90,15,25,35,45,55,65}}}},;//19
				{{{{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99}}}},;//20
				{{{{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99}}}},;//21
				{{{{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99}}}},;//22
				{{{{"1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234"}}}},;//23
				{{{999999.99}}},;//24
				{{{999999.99}}},;//25
				{{{999999.99}}},;//26
				{{{999999.99}}},;//27
				{{{999999.99}}},;//28
				{{{999999.99}}},;//29
				{{{999999.99}}},;//30
				{{{999999.99}}},;//31
				{{{999999.99}}},;//32
		     	{{	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
				  	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
				  	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
				  	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
				  	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
				  	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
				  	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },;
				  	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 } }},; //33
				{{	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 } }},; //34
				{{	{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 },{ Replicate("M", 40), 999999999.99 } }},; //35
				{CtoD("30/12/07")},;//36
				{999999.99},;//37
				{999999.99},;//38
				{999999.99},;//39
				{99.99},;//40
				{99.99},;//41
				{""} } }//42
*/

//verifica se foi encontrado conteudo
if len(aDados[1]) == 0
	if !lWeb
		msgAlert("Não foram encontrados dados para os parâmetros informados!")
	else
		cMsg := "Não foram encontrados dados para os parâmetros informados!"
	endIf
	lContinua := .f.
endIf

//se existe dados ou nao
if lContinua
	
	//Fonte Normal	
	oFont01	 := TFont():New("Arial",  8,  8, , .F., , , , .T., .F.)
	oFont02n := TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont03n := TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04	 := TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	
	//DAHER - Tive que colocar esse Semaforo aqui pois por alguma razao
	//quando duas transacoes chamavam ao mesmo tempo o FWMSPRINTER
	//eventualmente alguma delas nao retornava, ou seja, ele entrava
	//no FWMSPRINTER e nunca saia	
	nH := PLSAbreSem("PPLSRELDPO.SMF")
	oPrint := FWMSPrinter():New(cFileName,IMP_PDF,.t.,nil,.t.,nil,@oPrint,nil,nil,.f.,.f.,.t.)
	PLSFechaSem(nH,"PPLSRELDPO.SMF")

	oPrint:lInJob  	:= lWeb
	oPrint:lServer 	:= lWeb
	oPrint:cPathPDF	:= cPathSrv
	
	//Resolução do relatorio.	
	oPrint:setResolution(72)
	
	//Modo paisagem	
	oPrint:setLandscape()
	
	//Papel A4	
	oPrint:setPaperSize(TAM_A4)
	
	//Margem	
	oPrint:setMargin(05,05,05,05)
	
	//Verifica se existe alguma impressora configurada para Impressao Grafica	
	if !lWeb
		oPrint:setup()
	endIf
	
	//Dados	
	If (cTissVer < "3")
	for nX := 1 to len(aDados)
		
		//retorno sem impressao		
		if len(aDados[nX]) == 0
			loop
		endIf
		
		//tratamento posicao 13 a 23 adados		
		for nI:= 13 to 23
			if len(aDados[nX, nI]) < 15
				for nJ := len(aDados[nX, nI]) + 1 to 15
					if AllTrim(Str(nI)) $ "19,20,21,22"
						aAdd(aDados[nX, nI], 0)
					elseIf AllTrim(Str(nI)) $ "18"
						aAdd(aDados[nX, nI], CToD(""))
					else
						aAdd(aDados[nX, nI],"")
					endIf
				next nJ
			endIf
		next nI
		
		//tratamento posicao 33		
		for nI := 33 to 33
			if len(aDados[nX, nI]) < 1
				aAdd(aDados[nX, nI], { "", 0 })
			endIf
		next nI
		
		//tratamento posicao 02		
		for nX1 := 1 to len(aDados[nX, 02])
			
			//fim da pagina			
			if nX1 > 1
				oPrint:EndPage()
			endIf

			nLinIni := 0
			nColIni := 0
			nColA4  := 0
			
			//Inicia uma nova pagina			
			oPrint:startPage()
			
			//Carrega e Imprime Logotipo da Empresa			
			if fLogoEmp(@cLogoGH)
				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
				oPrint:sayBitmap(nLinIni, nColIni + 0020, cLogoGH, 400, 090)
			endIf
			
			//Papél A4			
			nColA4  := -700
			nLinBox := 90
			
			//Titulo			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80)
			oPrint:say(nLinIni, nColIni + 1752 + nColA4, "GUIA TRATAMENTO ODONTOLÓGICO - DEMONSTRATIVO DE PAGAMENTO", oFont02n,,,, 2)
			
			//Numero			
			oPrint:say(nLinIni, nColIni + 3000 + nColA4, "2 - Nº", oFont02n)
			oPrint:say(nLinIni, nColIni + 3096 + nColA4, aDados[nX, 02,nX1], oFont03n)
			
			//proxima linha			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80)
			
			//Registro ans			
			oPrint:box(nLinIni, nColIni + 0010, nLinIni + nLinBox, nColIni + 0310)
			oPrint:say(nLinIni + 20 , nColIni + 0020, "1 - Registro ANS", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 0030, aDados[nX, 01], oFont04)
			
			//Nome da Operadora		
			oPrint:box(nLinIni, nColIni + 0320, nLinIni + nLinBox, nColIni + 2265 + nColA4)
			oPrint:say(nLinIni + 20, nColIni + 0330, "3 - Nome da Operadora", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 0340, aDados[nX, 03,nX1], oFont04)
			
			//CNPJ Operadora			
			oPrint:box(nLinIni, nColIni + 2270 + nColA4, nLinIni + nLinBox, nColIni + 2730 + nColA4)
			oPrint:say(nLinIni + 20, nColIni + 2275 + nColA4, "4 - CNPJ Operadora", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 2285 + nColA4, aDados[nX, 04,nX1], oFont04)
			
			//Período de Processamento			
			oPrint:box(nLinIni, nColIni + 2740 + nColA4, nLinIni + nLinBox, nColIni + 3289 + nColA4)
			oPrint:say(nLinIni + 20, nColIni + 2750 + nColA4, "5 - Período de Processamento", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 2760 + nColA4, DToC(aDados[nX, 05,nX1,1]), oFont04)
			oPrint:say(nLinIni + 50, nColIni + 2909 + nColA4, " à ", oFont04)
			oPrint:say(nLinIni + 50, nColIni + 2979 + nColA4, DToC(aDados[nX, 05,nX1,2]), oFont04)
			
			//proxima linha			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 120)
			
			//Dados do Prestador			
			oPrint:say(nLinIni, nColIni + 0010, "Dados do Prestador", oFont01)
			
			//proxima linha			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20)
			
			//Código na Operadora			
			oPrint:box(nLinIni, nColIni + 0010, nLinIni + nLinBox, nColIni + 0410)
			oPrint:say(nLinIni + 20, nColIni + 0020, "6 - Código na Operadora", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 0030, aDados[nX, 06,nX1], oFont04)
			
			//Nome do Contratado			
			oPrint:box(nLinIni, nColIni + 0420, nLinIni + nLinBox, nColIni + 2455)
			oPrint:say(nLinIni + 20, nColIni + 0430, "7 - Nome do Contratado", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 0440, aDados[nX, 07,nX1], oFont04)
			
			//CPF/ CNPJ Contratado			
			oPrint:box(nLinIni, nColIni + 2460, nLinIni + nLinBox, nColIni + 2875)
			oPrint:say(nLinIni + 20, nColIni + 2470, "8 - CPF/ CNPJ Contratado", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 2480, aDados[nX, 08,nX1], oFont04)
			
			//proxima linha			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 120)

			nProcGer := 0
			nLibGer  := 0
			nGloGer  := 0
			
			//posicao 9		
			for nX2 := 1 to len(aDados[nX, 09,nX1])
				nProcLot := 0
				nGloLot  := 0
				nLibLot  := 0
				
				//Dados do Pagamento				
				oPrint:say(nLinIni, nColIni + 0010, "Dados do Pagamento", oFont01)
				
				//proxima linha				
				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20)
				
				//Número do Lote				
				oPrint:box(nLinIni, nColIni + 0010, nLinIni + nLinBox, nColIni + 0365)
				oPrint:say(nLinIni + 20, nColIni + 0020, "9 - Número do Lote", oFont01)
				oPrint:say(nLinIni + 50, nColIni + 0030, aDados[nX, 09,nX1, nX2], oFont04)
				
				//Posicao 12				
				for nX3 := 1 to len(aDados[nX, 12,nX1, nX2])
					
					//Proxima linha					
					if nX3 <> 1
						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)
					endIf
					
					//Código do Beneficiário					
					oPrint:box(nLinIni, nColIni + 0375, nLinIni + nLinBox, nColIni + 0820)
					oPrint:say(nLinIni + 20, nColIni + 0385, "10 - Código do Beneficiário", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 0395, aDados[nX, 10,nX1, nX2, nX3], oFont04)
					
					//Nome do Beneficiário					
					oPrint:box(nLinIni, nColIni + 0825, nLinIni + nLinBox, nColIni + 2835 + nColA4/2)
					oPrint:say(nLinIni + 20, nColIni + 0835, "11 - Nome do Beneficiário", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 0845, aDados[nX, 11,nX1, nX2, nX3], oFont04)
					
					//Número da Guia					
					oPrint:box(nLinIni, nColIni + 2840 + nColA4/2, nLinIni + nLinBox, nColIni + 3200 + nColA4/2)
					oPrint:say(nLinIni + 20, nColIni + 2850 + nColA4/2, "12 - Número da Guia", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 2860 + nColA4/2, aDados[nX, 12 ,nX1, nX2, nX3], oFont04)

					lbox := .f.
					
					//Proxima linha					
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 120)
					
					//box ou line				
					if (nLinIni + (len(aDados[nX, 13,nX1, nX2, nX3]) * 45)) < nLinMax
						oPrint:box(nLinIni, nColIni + 0010, nLinIni + 50 + (len(aDados[nX, 13,nX1, nX2, nX3]) * 45), nColIni + 3695 + nColA4)
					else
						oPrint:line(nLinIni, nColIni + 0010, nLinIni + 45, nColIni + 0010)
						oPrint:line(nLinIni, nColIni + 0010, nLinIni, nColIni + 3695 + nColA4)
						oPrint:line(nLinIni, nColIni + 3695 + nColA4, nLinIni + 45, nColIni + 3695 + nColA4)
						lbox := .t.
					endIf
					
					//dados tabela codigo procedimeto....				
					oPrint:say(nLinIni + 20, nColIni + 0020, "13 - Tabela", oFont01)
					oPrint:say(nLinIni + 20, nColIni + 0140, "14 - Código do Procedimento", oFont01)
					oPrint:say(nLinIni + 20, nColIni + 0380, "15 - Descrição", oFont01)
					oPrint:say(nLinIni + 20, nColIni + 2100 + nColA4, "16 - Dente/Região", oFont01)
					oPrint:say(nLinIni + 20, nColIni + 2270 + nColA4, "17 - Face", oFont01)
					oPrint:say(nLinIni + 20, nColIni + 2390 + nColA4, "18 - Data de Realização", oFont01,,,,1)
					oPrint:say(nLinIni + 20, nColIni + 2600 + nColA4, "19 - Qtd", oFont01)
					oPrint:say(nLinIni + 20, nColIni + 2760 + nColA4, "20 - Valor Processado(R$)", oFont01,,,,1)
					oPrint:say(nLinIni + 20, nColIni + 3000 + nColA4, "21 - Valor Glosa/Estorno(R$)", oFont01)
					oPrint:say(nLinIni + 20, nColIni + 3250 + nColA4, "22 - Valor Liberado(R$)", oFont01)
					oPrint:say(nLinIni + 20, nColIni + 3500 + nColA4, "23 - Motivo da Glosa", oFont01,,,,1)

					nProcGui := 0
					nGloGui  := 0
					nLibGui  := 0
					
					//proxima linha					
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 10)
					
					//posicao 13					
					for nX4 := 1 to len(aDados[nX, 13,nX1, nX2, nX3])
						
						//box						
						if lbox
							oPrint:line(nLinIni, nColIni + 0010, nLinIni + 45, nColIni  + 0010)
							oPrint:line(nLinIni, nColIni + 3695 + nColA4, nLinIni + 45, nColIni  + 3695 + nColA4)
						endIf
						
						//dados						
						oPrint:say(nLinIni + 50, nColIni + 0020 + 20, aDados[nX, 13,nX1,  nX2, nX3 , nX4], oFont04)
						oPrint:say(nLinIni + 50, nColIni + 0140 + 20, aDados[nX, 14,nX1,  nX2, nX3 , nX4], oFont04)
						oPrint:say(nLinIni + 50, nColIni + 0380, aDados[nX, 15,nX1,  nX2, nX3 , nX4], oFont01)
						oPrint:say(nLinIni + 50, nColIni + 2120 + nColA4 + 20, aDados[nX, 16,nX1,  nX2, nX3 , nX4], oFont04)
						oPrint:say(nLinIni + 50, nColIni + 2270 + nColA4, aDados[nX, 17,nX1,  nX2, nX3 , nX4], oFont04)
						oPrint:say(nLinIni + 50, nColIni + 2380 + nColA4 + 20, DtoC(aDados[nX, 18,nX1 , nX2, nX3 , nX4]), oFont04)
						oPrint:say(nLinIni + 50, nColIni + 2600 + nColA4, iIf(empty(aDados[nX, 19 ,nX1, nX2, nX3 , nX4]), "", transform(aDados[nX, 19,nX1, nX2, nX3 , nX4], "@E 9999.99")), oFont04,,,,1)
						oPrint:say(nLinIni + 50, nColIni + 2760 + nColA4 + 20, iIf(empty(aDados[nX, 20 ,nX1, nX2, nX3 , nX4]), "", transform(aDados[nX, 20,nX1, nX2, nX3 , nX4], "@E 99,999,999.99")), oFont04,,,,1)
						oPrint:say(nLinIni + 50, nColIni + 3000 + nColA4 + 20, iIf(empty(aDados[nX, 21 ,nX1, nX2, nX3 , nX4]), "", transform(aDados[nX, 21,nX1, nX2, nX3 , nX4], "@E 99,999,999.99")), oFont04,,,,1)
						oPrint:say(nLinIni + 50, nColIni + 3250 + nColA4 + 20, iIf(empty(aDados[nX, 22 ,nX1, nX2, nX3 , nX4]), "", transform(aDados[nX, 22,nX1, nX2, nX3 , nX4], "@E 99,999,999.99")), oFont04,,,,1)
						oPrint:say(nLinIni + 50, nColIni + 3500 + nColA4 + 20, aDados[nX, 23,nX1, nX2, nX3 , nX4], oFont04)
						
						//proxima linha						
						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
					next nX4
					
					//box					
					if lbox
						oPrint:line(nLinIni, nColIni + 0010, nLinIni, nColIni + 3695 + nColA4)
					endIf
					
					//proxima linha					
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
					
					//Valor Total Processado Guia(R$)					
					oPrint:box(nLinIni, nColIni + 2485 + nColA4, nLinIni + nLinBox, nColIni + 2880 + nColA4)
					oPrint:say(nLinIni + 20, nColIni + 2495 + nColA4, "24 - Valor Total Processado Guia(R$)", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 2705 + nColA4, transform(aDados[nX, 24,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)
					
					//Valor Total Glosa Guia(R$)				
					oPrint:box(nLinIni, nColIni + 2890 + nColA4, nLinIni + nLinBox, nColIni + 3288 + nColA4)
					oPrint:say(nLinIni + 20, nColIni + 2900 + nColA4, "25 - Valor Total Glosa Guia(R$)", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 3110 + nColA4, transform(aDados[nX, 25,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)
					
					//Valor Total Liberado Guia (R$)					
					oPrint:box(nLinIni, nColIni + 3295 + nColA4, nLinIni + nLinBox, nColIni + 3695 + nColA4)
					oPrint:say(nLinIni + 20, nColIni + 3305 + nColA4, "26 - Valor Total Liberado Guia (R$)", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 3515 + nColA4, transform(aDados[nX, 26,nX1,nX2,nX3], "@E 999,999,999.99"), oFont04,,,,1)
					
					//proxima linha					
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100)
					
					//Valor Total Processado Lote(R$)					
					oPrint:box(nLinIni, nColIni + 1270 + nColA4, nLinIni + nLinBox, nColIni + 1665 + nColA4)
					oPrint:say(nLinIni + 20, nColIni + 1270 + nColA4 + 10, "27 - Valor Total Processado Lote(R$)", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 1270 + nColA4 + 200, transform(aDados[nX, 27,nX1,nX2], "@E 999,999,999.99"), oFont04,,,,1)
					
					//Valor Total Glosa Lote(R$)					
					oPrint:box(nLinIni, nColIni + 1675 + nColA4, nLinIni + nLinBox, nColIni + 2070 + nColA4)
					oPrint:say(nLinIni + 20, nColIni + 1675 + nColA4 + 10, "28 - Valor Total Glosa Lote(R$)", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 1675 + nColA4 + 200, transform(aDados[nX, 28,nX1,nX2], "@E 999,999,999.99"), oFont04,,,,1)
					
					//Valor Total Liberado Lote (R$)					
					oPrint:box(nLinIni, nColIni + 2080 + nColA4, nLinIni + nLinBox, nColIni + 2475 + nColA4)
					oPrint:say(nLinIni + 20, nColIni + 2080 + nColA4 + 10, "29 - Valor Total Liberado Lote (R$)", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 2080 + nColA4 + 200, transform(aDados[nX, 29,nX1,nX2], "@E 999,999,999.99"), oFont04,,,,1)
					
					//Valor Geral Processado (R$)					
					oPrint:box(nLinIni, nColIni + 2485 + nColA4, nLinIni + nLinBox, nColIni + 2880 + nColA4)
					oPrint:say(nLinIni + 20, nColIni + 2485 + nColA4 + 10, "30 - Valor Geral Processado (R$)", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 2485 + nColA4 + 200, transform(aDados[nX, 30,nX1,nX2], "@E 999,999,999.99"), oFont04,,,,1)
					
					//Valor Geral Glosa (R$)					
					oPrint:box(nLinIni, nColIni + 2890 + nColA4, nLinIni + nLinBox, nColIni + 3285 + nColA4)
					oPrint:say(nLinIni + 20, nColIni + 2890 + nColA4 + 10, "31 - Valor Geral Glosa (R$)", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 2890 + nColA4 + 200, transform(aDados[nX, 31,nX1], "@E 999,999,999.99"), oFont04,,,,1)
					
					//Valor General Liberado (R$)				
					oPrint:box(nLinIni, nColIni + 3295 + nColA4, nLinIni + nLinBox, nColIni + 3695 + nColA4)
					oPrint:say(nLinIni + 20, nColIni + 3295 + nColA4 + 10, "32 - Valor Geral Liberado(R$)", oFont01)
					oPrint:say(nLinIni + 50, nColIni + 3295 + nColA4 + 200, transform(aDados[nX, 32,nX1], "@E 999,999,999.99"), oFont04,,,,1)
				next nX3
			next nX2
			
			//proxima linha			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 90)
			
			//Demais débitos / Créditos			
			oPrint:say(nLinIni, nColIni + 0010, "Demais débitos / Créditos", oFont01)
			
			//proxima linha			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20)
			
			//box ou line			
			if (nLinIni + ( (len(aDados[nX, 33,nX1])/4) * 45)) < nLinMax
				oPrint:box(nLinIni, nColIni + 0010, nLinIni + 45 + ((len(aDados[nX, 33,nX1])/4) * 45), nColIni + 3695 + nColA4)
			else
				oPrint:line(nLinIni, nColIni + 0010, nLinIni + 45, nColIni + 0010)
				oPrint:line(nLinIni, nColIni + 0010, nLinIni, nColIni + 3695 + nColA4)
				oPrint:line(nLinIni, nColIni + 3695 + nColA4, nLinIni + 45, nColIni + 3695 + nColA4)
				lbox := .t.
			endIf

			nOldCol := nColIni
			nColIni := 0
			
			//Descrição -  Valor (R$)			
			oPrint:say(nLinIni + 20, nColIni + 0020, "33 - Descrição", oFont01)
			oPrint:say(nLinIni + 20, nColIni + 0620, "34 - Valor (R$)", oFont01)

			nColIni := 0
			
			//posicao 33		
			for nI := 1 to len(aDados[nX, 33,nX1])
				oPrint:say(nLinIni + 50, nColIni + 0020, aDados[nX, 33,nX1, nI, 1], oFont01)
				oPrint:say(nLinIni + 50, nColIni + 0620, iIf(empty(aDados[nX, 33,nX1, nI, 1]), "", transform(aDados[nX, 33,nX1, nI, 2], "@E 999,999,999.99")), oFont01,,,,1)

				nColini += 747
				
				//proxima linha				
				if Mod(nI,4) == 0 .or. (lBox .and. len(aDados[nX, 33,nX1]) == nI)
					nColIni := nOldCol
					fSomaLin(nLinMax, nColMax, @nLinIni, nOldCol, 45)
					
					//box					
					if lbox
						oPrint:line(nLinIni, nColIni + 0010, nLinIni + 45, nColIni  + 0010)
						oPrint:line(nLinIni, nColIni + 3695 + nColA4, nLinIni + 45, nColIni  + 3695 + nColA4)
					endIf
				endIf
			next nI
			
			//box			
			if lbox
				
				//proxima linha				
				fSomaLin(nLinMax, nColMax, @nLinIni, nOldCol, 45)
				nColIni := 0
				oPrint:line(nLinIni, nColIni + 0010, nLinIni, nColIni + 3695 + nColA4)

				fSomaLin(nLinMax, nColMax, @nLinIni, nOldCol, 45)
			else
				
				//proxima linha				
				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 120)
			endIf

			lbox := .f.
			nColIni := nOldCol
			
			//linha fin			
			if ( if(empty(aDados[nX, 34,nX1]),0,len(aDados[nX, 34,nX1])) ) > ( if(empty(aDados[nX, 35,nX1]),0,len(aDados[nX, 35,nX1])) )
				nLinFin := len(aDados[nX, 34,nX1])
			else
				nLinFin := len(aDados[nX, 35,nX1])
			endIf
			
			//Demais débitos / créditos não tributáveis - Impostos			
			oPrint:say(nLinIni, nColIni + 0010, "Demais débitos / créditos não tributáveis", oFont01)
			oPrint:say(nLinIni, nColIni + 1515, "Impostos", oFont01)
			
			//proxima linha			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20)
			
			//box ou line			
			oPrint:box(nLinIni, nColIni + 0010, nLinIni + 45 + ((nLinFin/2) * 45), nColIni + 1500)
			oPrint:box(nLinIni, nColIni + 1514, nLinIni + 45 + ((nLinFin/2) * 45), nColIni + 3695 + nColA4)
			nColIni := 0
			
			//Descrição - Valor (R$)			
			oPrint:say(nLinIni + 20, nColIni + 0020, "35 - Descrição", oFont01)
			oPrint:say(nLinIni + 20, nColIni + 0620, "36 - Valor (R$)", oFont01)
			
			//Descrição - Valor (R$)			
			oPrint:say(nLinIni + 20, nColIni + 1515, "37 - Descrição", oFont01)
			oPrint:say(nLinIni + 20, nColIni + 2115, "38 - Valor (R$)", oFont01)

			nColIni := 0
			nOldLin := nLinIni
			
			//posicao 34			
			for nI := 1 to len(aDados[nX, 34,nX1])
				
				//dados				
				oPrint:say(nLinIni + 50, nColIni + 0020, aDados[nX, 34,nX1, nI, 1], oFont01)
				oPrint:say(nLinIni + 50, nColIni + 0620, iIf(empty(aDados[nX, 34,nX1, nI, 2]), "", transform(aDados[nX, 34,nX1, nI, 2], "@E 999,999,999.99")), oFont01,,,,1)

				nColini += 750
				
				//proxima linha				
				if Mod(nI,2)== 0
					nColIni := nOldCol
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
				endIf
			next nI
			nColIni	:= 0
			nLinIni := nOldLin
			
			//posicao 35			
			for nI := 1 to len(aDados[nX, 35, nX1])
				
				//dados				
				oPrint:say(nLinIni + 50, nColIni + 1515, aDados[nX,35,nX1,nI,1], oFont01)
				oPrint:say(nLinIni + 50, nColIni + 2115, iIf(empty(aDados[nX, 35,nX1, nI, 2]), "", transform(aDados[nX, 35,nX1, nI, 2], "@E 999,999,999.99")), oFont01,,,,1)

				nColini  += 750
				
				//proxima linha				
				if Mod(nI,2)== 0 .or. (lBox .and. len(aDados[nX, 35,nX1]) == nI)
					nColIni := nOldCol
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45)
				endIf
			next nI
			nColIni := nOldCol
			
			//proxima linha			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 60)
			
			//Totais			
			oPrint:box(nLinIni, nColIni + 0010, nLinIni + nLinBox + 20, nColIni + 3695 + nColA4)

			oPrint:say(nLinIni + 20, nColIni + 0020, "Totais", oFont01)
			
			//proxima linha			
			nLinIni += 10
			
			//Data do Pagamento			
			oPrint:box(nLinIni, nColIni + 1435 + nColA4 + nColAjus, nLinIni + nLinBox, nColIni + 1830 + nColA4 + nColAjus)
			oPrint:say(nLinIni + 20, nColIni + 1445 + nColA4 + nColAjus, "39 - Data do Pagamento", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 1445 + nColA4 + nColAjus + 250, DtoC(aDados[nX, 36,nX1]), oFont04)
			
			//Valor Total Tributável (R$)			
			oPrint:box(nLinIni, nColIni + 1835 + nColA4 + nColAjus, nLinIni + nLinBox, nColIni + 2230 + nColA4 + nColAjus)
			oPrint:say(nLinIni + 20, nColIni + 1845 + nColA4 + nColAjus, "40 - Valor Total Tributável (R$)", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 1845 + nColA4 + nColAjus + 250, transform(aDados[nX, 37,nX1], "@E 999,999,999.99"), oFont04)
			
			//Valor Total Impostos Retidos (R$)			
			oPrint:box(nLinIni, nColIni + 2240 + nColA4 + nColAjus, nLinIni + nLinBox, nColIni + 2635 + nColA4 + nColAjus)
			oPrint:say(nLinIni + 20, nColIni + 2250 + nColA4 + nColAjus, "41 - Valor Total Impostos Retidos (R$)", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 2250 + nColA4 + nColAjus + 250, transform(aDados[nX, 38,nX1], "@E 999,999,999.99"), oFont04)
			
			//Valor Total Não Tributável (R$)			
			oPrint:box(nLinIni, nColIni + 2645 + nColA4 + nColAjus, nLinIni + nLinBox, nColIni + 3041 + nColA4 + nColAjus)
			oPrint:say(nLinIni + 20, nColIni + 2655 + nColA4 + nColAjus, "42 - Valor Total Não Tributável (R$)", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 2655 + nColA4 + nColAjus + 250, transform(aDados[nX, 39,nX1], "@E 999,999,999.99"), oFont04)
			
			//Valor Final a Receber (R$)			
			oPrint:box(nLinIni, nColIni + 3050 + nColA4 + nColAjus, nLinIni + nLinBox, nColIni + 3440 + nColA4 + nColAjus)
			oPrint:say(nLinIni + 20, nColIni + 3060 + nColA4 + nColAjus, "43 -  Valor Final a Receber (R$)", oFont01)
			oPrint:say(nLinIni + 50, nColIni + 3060 + nColA4 + nColAjus + 250, transform(aDados[nX, 40,nX1], "@E 99,999,999.99"), oFont04,,,,1)
			
			//Proxima linha			
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110)
			
			//Observação			
			oPrint:box(nLinIni, nColIni + 0010, nLinIni + nLinBox, nColIni + 3695 + nColA4)
			oPrint:say(nLinIni + 20, nColIni + 0020, "44 - Observação", oFont01)
			oPrint:say(nLinIni + 59, nColIni + 0020, "", oFont04,,,,1)
		next nX1
		
		//Fim de pagina		
		oPrint:endPage()
	next nX
	Else
		For nX := 1 To Len(aDados)

			If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
				Loop
			EndIf

			For nI:= 19 To 28
				If Len(aDados[nX, nI]) < 6
					For nJ := Len(aDados[nX, nI]) + 1 To 6
						If AllTrim(Str(nI)) $ "25,27,28,29,30"
							aAdd(aDados[nX, nI], 0)
						ElseiF AllTrim(Str(nI)) $ "24"
							aAdd(aDados[nX, nI], CToD(""))
						Else
							aAdd(aDados[nX, nI],"")
						EndIf
					Next nJ
				EndIf
			Next nI

			For nI := 43 To 46
				If Len(aDados[nX, nI]) < 2
					For nJ := Len(aDados[nX, nI]) + 1 To 2
						If AllTrim(Str(nI)) == "46"
							aAdd(aDados[nX, nI], 0)
						Else
							aAdd(aDados[nX, nI], "")
						EndIf
					Next
				EndIf
			Next nI

			For nI := 47 To 54
				If Len(aDados[nX, nI]) < 3
					For nJ := Len(aDados[nX, nI]) + 1 To 3
						If AllTrim(Str(nI)) $ "50,54"
							aAdd(aDados[nX, nI], 0)
						Else
							aAdd(aDados[nX, nI], "")
						EndIf
					Next
				EndIf
			Next nI


	  		For nX1 := 1 To Len(aDados[nX, 02])

				If nX1 > 1
			 		oPrint:EndPage()
				Endif

				nLinIni  := 060
				nColIni  := 060
				nColA4   := 000

				oPrint:StartPage()		// Inicia uma nova pagina
				
				//Box Principal                                                 				
				oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)
				
				//Carrega e Imprime Logotipo da Empresa                         				
				if fLogoEmp(@cLogoGH)
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
					oPrint:sayBitmap(nLinIni, nColIni + 0020, cLogoGH, 400, 090)
				endIf

				oPrint:Say(nLinIni + 0080, nColIni + 1100, "DEMONSTRATIVO DE PAGAMENTO - TRATAMENTO ODONTOLÓGICO", oFont02n,,,, 2) //DEMONSTRATIVO DE PAGAMENTO - TRATAMENTO ODONTOLÓGICO
				oPrint:Say(nLinIni + 0090, nColIni + 3000 + nColA4, "2 - "+STR0002, oFont01) //"Nº"
				oPrint:Say(nLinIni + 0070, nColIni + 3096 + nColA4, aDados[nX, 02, nX1], oFont03n)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 40)
				oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, (nColIni + nColMax)*0.1 - 0010)
				oPrint:Say(nLinIni + 0200, nColIni + 0020, "1 - Registro ANS", oFont01) //1 - Registro ANS
				oPrint:Say(nLinIni + 0240, nColIni + 0030, aDados[nX, 01], oFont04)
				oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.1, nLinIni + 0269, (nColIni + nColMax)*0.4 - 0010)
				oPrint:Say(nLinIni + 0200, (nColIni + nColMax)*0.1 + 0020, "3 - Nome da Operadora", oFont01) //3 - Nome da Operadora
				oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.1 + 0030, aDados[nX, 03, nX1], oFont04)
				oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.4, nLinIni + 0269, (nColIni + nColMax)*0.6 - 0010)
				oPrint:Say(nLinIni + 0200, (nColIni + nColMax)*0.4 + 0020, "4 - CNPJ Operadora", oFont01) //4 - CNPJ Operadora
				oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.4 + 0030, aDados[nX, 04, nX1], oFont04)
				oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.6, nLinIni + 0269, (nColIni + nColMax)*0.8 - 0010)
				oPrint:Say(nLinIni + 0200, (nColIni + nColMax)*0.6 + 0020, "5 - Data de Início do Processamento", oFont01) //5 – Data de Início do Processamento
				oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.6 + 0030, DToC(aDados[nX, 05, nX1]), oFont04)
				oPrint:Box(nLinIni + 0175, (nColIni + nColMax)*0.8, nLinIni + 0269, nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 0200, (nColIni + nColMax)*0.8 + 0020, "6 - Data de Fim do Processamento", oFont04) //6 - Data de Fim do Processamento
				oPrint:Say(nLinIni + 0240, (nColIni + nColMax)*0.8 + 0030, DToC(aDados[nX, 06, nX1]), oFont04)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 0, 40)
				AddTBrush(oPrint, nLinIni + 0271, nColIni + 0010, nLinIni + 0301, nColIni + nColMax)
				oPrint:Say(nLinIni + 0294, nColIni + 0020, "Dados do Prestador", oFont01) //Dados do Prestador
				oPrint:Box(nLinIni + 0304, nColIni + 0010, nLinIni + 0398, (nColIni + nColMax)*0.2 - 0010)
				oPrint:Say(nLinIni + 0329, nColIni + 0020, "7 - Código na Operadora", oFont01) //7 - Código na Operadora
				oPrint:Say(nLinIni + 0369, nColIni + 0030, aDados[nX, 07, nX1], oFont04)
				oPrint:Box(nLinIni + 0304, (nColIni + nColMax)*0.2, nLinIni + 0398, (nColIni + nColMax)*0.77 - 0010)
				oPrint:Say(nLinIni + 0329, (nColIni + nColMax)*0.2 + 0020, "8 - Nome do Contratado", oFont01) //8 - Nome do Contratado
				oPrint:Say(nLinIni + 0369, (nColIni + nColMax)*0.2 + 0030, aDados[nX, 08, nX1], oFont04)
				oPrint:Box(nLinIni + 0304, (nColIni + nColMax)*0.77, nLinIni + 0398, nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 0329, (nColIni + nColMax)*0.77 + 0020, "9 - CPF / CNPJ Contratado", oFont01) //9 - CPF / CNPJ Contratado
				oPrint:Say(nLinIni + 0369, (nColIni + nColMax)*0.77 + 0030, aDados[nX, 09, nX1], oFont04)

				nProcGer := 0
				nLibGer  := 0
				nGloGer  := 0

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 300, 40)

			   	For nX2 := 1 To Len(aDados[nX, 10,nX1])

			   		For nX3 := 1 To Len(aDados[nX, 10,nX1, nX2])

						nProcLot := 0
				   		nGloLot  := 0
				   		nLibLot  := 0

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 40)
						AddTBrush(oPrint, nLinIni + 0004, nColIni + 0010, nLinIni + 0034, nColIni + nColMax)
						oPrint:Say(nLinIni + 0027, nColIni + 0020, "Dados do Pagamento", oFont01) //Dados do Pagamento

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
						oPrint:Box(nLinIni + 0000, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.15 - 0010)
						oPrint:Say(nLinIni + 0025, nColIni + 0020, "10 - Data do Pagamento", oFont01) //10 - Data do Pagamento
						oPrint:Say(nLinIni + 0065, nColIni + 0030, DtoC(aDados[nX, 10, nX1, nX2, nX3]), oFont04)
						oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.15, nLinIni + 0094, (nColIni + nColMax)*0.23 - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.15 + 0010, "11 - Banco", oFont01) //11 - Banco
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.15 + 0020, aDados[nX, 11, nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.23, nLinIni + 0094, (nColIni + nColMax)*0.35 - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.23 + 0010, "12 - Agência", oFont01) //12 - Agência
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.23 + 0020, aDados[nX, 12, nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.35, nLinIni + 0094, (nColIni + nColMax)*0.65 - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.35 + 0010, "13 - Conta", oFont01) //13 - Conta
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.35 + 0020, aDados[nX, 13,nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.65, nLinIni + 0094, (nColIni + nColMax)*0.8 - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.65 + 0010, "14 - Número do lote", oFont01) //14 - Número do lote
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.65 + 0020, aDados[nX, 14, nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.8, nLinIni + 0094, nColIni + nColMax - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.8 + 0010, "15 - Número do Protocolo", oFont01) //15 - Número do Protocolo
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.8 + 0020, aDados[nX, 15,nX1, nX2, nX3], oFont04)

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
						oPrint:Box(nLinIni + 0000, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.25 - 0010)
						oPrint:Say(nLinIni + 0025, nColIni + 0020, "16 - Número da guia no prestador", oFont01) //16 - Número da guia no prestador
						oPrint:Say(nLinIni + 0065, nColIni + 0030, aDados[nX, 16, nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.25, nLinIni + 0094, (nColIni + nColMax)*0.50 - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.25 + 0010, "17 - Número da Carteira", oFont01) //17 - Número da Carteira
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.25 + 0020, aDados[nX, 17, nX1, nX2, nX3], oFont04)
						oPrint:Box(nLinIni + 0000, (nColIni + nColMax)*0.50, nLinIni + 0094, nColIni + nColMax - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.50 + 0010, "18 - Nome do Beneficiário", oFont01) //18 - Nome do Beneficiário
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.50 + 0020, aDados[nX, 18, nX1, nX2, nX3], oFont04)

						lBox:=.F.

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
						if (nLinIni + (Len(aDados[nX, 19,nX1, nX2, nX3]) * 75)) < nLinMax
							oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 60 + (Len(aDados[nX, 19,nX1, nX2, nX3]) * 75), nColIni + nColMax - 0010)
						Else
							oPrint:Line(nLinIni, nColIni + 0010, nLinIni + 0045, nColIni + 0010)
						 	oPrint:Line(nLinIni, nColIni + 0010, nLinIni, nColIni + nColMax)
						 	oPrint:Line(nLinIni, nColIni + nColMax, nLinIni + 0045, nColIni + nColMax)
						  	lBox:=.T.
						Endif

						oPrint:Say(nLinIni + 0022, nColIni + 0020, "19-Tabela", oFont01) //19-Tabela
						oPrint:Say(nLinIni + 0022, (nColIni + nColMax)*0.06, "20-Código do Procedimento", oFont01) //20-Código do Procedimento
						oPrint:Say(nLinIni + 0022, (nColIni + nColMax)*0.15, "21-Descrição", oFont01) //21-Descrição
						oPrint:Say(nLinIni + 0022, (nColIni + nColMax)*0.35, "22-Dente/Região", oFont01) //22-Dente/Região
						oPrint:Say(nLinIni + 0022, (nColIni + nColMax)*0.42, "23-Face", oFont01) //23-Face
						oPrint:Say(nLinIni + 0022, (nColIni + nColMax)*0.47, "24-Data de Realização", oFont01) //24-Data de Realização
						oPrint:Say(nLinIni + 0022, (nColIni + nColMax)*0.55, "25-Qtde", oFont01) //25-Qtde
						oPrint:Say(nLinIni + 0022, (nColIni + nColMax)*0.62, "26-Valor Informado(R$)", oFont01) //26-Valor Informado(R$)
						oPrint:Say(nLinIni + 0022, (nColIni + nColMax)*0.75, "27-Valor Processado(R$)", oFont01) //27-Valor Processado (R$)
						oPrint:Say(nLinIni + 0022, (nColIni + nColMax)*0.88, "28-Valor Glosa/Estorno(R$)", oFont01) //28-Valor Glosa/Estorno (R$)
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.06, "29-Valor Franquia(R$)", oFont01) //29-Valor Franquia(R$)
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.15, "30-Valor Liberado(R$)", oFont01) //30-Valor Liberado (R$)
						oPrint:Say(nLinIni + 0040, (nColIni + nColMax)*0.35, "31-Código da Glosa", oFont01) //31-Código da Glosa

						nProcGui := 0
						nGloGui  := 0
						nLibGui  := 0

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 40)
						For nX4 := 1 To Len(aDados[nX, 19, nX1, nX2, nX3])

							if lBox
								oPrint:Line(nLinIni + 0010, nColIni + 0010, nLinIni + 0055, nColIni  + 0010)
								oPrint:Line(nLinIni + 0010, nColIni  + 3695 + nColA4, nLinIni + 0055, nColIni  + 3695 + nColA4)
							Endif

							oPrint:Say(nLinIni, nColIni + 0020, aDados[nX, 19, nX1, nX2, nX3, nX4], oFont04)
							oPrint:Say(nLinIni, (nColIni + nColMax)*0.06, aDados[nX, 20, nX1, nX2, nX3, nX4], oFont04)
							oPrint:Say(nLinIni, (nColIni + nColMax)*0.15, aDados[nX, 21, nX1, nX2, nX3, nX4], oFont04)
							oPrint:Say(nLinIni, (nColIni + nColMax)*0.35, aDados[nX, 22, nX1, nX2, nX3, nX4], oFont04)
							oPrint:Say(nLinIni, (nColIni + nColMax)*0.42, aDados[nX, 23, nX1, nX2, nX3, nX4], oFont04)
							oPrint:Say(nLinIni, (nColIni + nColMax)*0.47, DtoC(aDados[nX, 24, nX1, nX2, nX3, nX4]), oFont04)
							oPrint:Say(nLinIni, (nColIni + nColMax)*0.55, IIF(Empty(aDados[nX, 25, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 25, nX1, nX2, nX3, nX4], "99")), oFont04)
							oPrint:Say(nLinIni, (nColIni + nColMax)*0.62 + 200, IIF(Empty(aDados[nX, 26, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 26, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)
							oPrint:Say(nLinIni, (nColIni + nColMax)*0.75 + 200, IIF(Empty(aDados[nX, 27, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 27, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)
							oPrint:Say(nLinIni, (nColIni + nColMax)*0.88 + 200, IIF(Empty(aDados[nX, 28, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 28, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)

							oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.06 + 200, IIF(Empty(aDados[nX, 29, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 29, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)
							oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.15 + 200, IIF(Empty(aDados[nX, 30, nX1, nX2, nX3, nX4]), "", Transform(aDados[nX, 30, nX1, nX2, nX3, nX4], "@E 99,999,999.99")), oFont04,,,,1)
							oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.35, aDados[nX, 31, nX1, nX2, nX3, 1], oFont04)

			 		   		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 75, 40)
						Next nX4

					    if lBox
							oPrint:Line(nLinIni + 0010, nColIni + 0010, nLinIni + 0010, nColIni + 3695 + nColA4)
						Endif

					    fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20, 40)
					    AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0220, nColIni + nColMax - 0010)
					 	oPrint:Box(nLinIni + 0000, nColIni + 0010, nLinIni + 0220, nColIni + nColMax - 0010)
						oPrint:Say(nLinIni + 0025, nColIni + 0020, "32-Observação / Justificativa", oFont01) //32-Observação / Justificativa

						For nI := 1 To MlCount(aDados[nX, 32,nX1,nX2,nX3], 130)
							cObs := MemoLine(aDados[nX, 32,nX1,nX2,nX3], 130, nI)
							oPrint:Say(nLinIni + 0020 + (nI*45), nColIni + 0030, cObs, oFont04)
						Next nI

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 230, 40)
						AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, nColIni + nColMax)
						oPrint:Say(nLinIni + 0023, nColIni + 0020, "Total da Guia", oFont01) //Dados do Pagamento

						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
					    oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.15 - 0010)
						oPrint:Say(nLinIni + 0025, nColIni + 0020, "33- Valor Total Informado Guia (R$)", oFont01) //33- Valor Total Informado Guia (R$)
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.15 - 0120, Transform(aDados[nX, 33, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni, (nColIni + nColMax)*0.15, nLinIni + 0094, (nColIni + nColMax)*0.30 - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.15 + 0010, "34 - Valor Total Processado Guia (R$)", oFont01) //34 - Valor Total Processado Guia (R$)
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.30 - 0120, Transform(aDados[nX, 34, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni, (nColIni + nColMax)*0.30, nLinIni + 0094, (nColIni + nColMax)*0.45 - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.30 + 0010, "35 - Valor Total Glosa Guia (R$)", oFont01) //35 - Valor Total Glosa Guia (R$)
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.45 - 0120, Transform(aDados[nX, 35, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni, (nColIni + nColMax)*0.45, nLinIni + 0094, (nColIni + nColMax)*0.60 - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.45 + 0010, "36 - Valor Total Franquia Guia (R$)", oFont01) //36 - Valor Total Franquia Guia (R$)
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.60 - 0120, Transform(aDados[nX, 36, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)
						oPrint:Box(nLinIni, (nColIni + nColMax)*0.60, nLinIni + 0094, (nColIni + nColMax)*0.75 - 0010)
						oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.60 + 0010, "37 - Valor Total Liberado Guia (R$)", oFont01) //37 - Valor Total Liberado Guia (R$)
						oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.75 - 0120, Transform(aDados[nX, 37, nX1, nX2, nX3], "@E 999,999,999.99"), oFont04,,,,1)

					Next nX3

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 40)
					AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, nColIni + nColMax)
					oPrint:Say(nLinIni + 0023, nColIni + 0020, "Total do Protocolo", oFont01) //Total do Protocolo

					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
				    oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.15 - 0010)
					oPrint:Say(nLinIni + 0025, nColIni + 0020, "38 - Valor Total Informado Protocolo (R$)", oFont01) //38 - Valor Total Informado Protocolo (R$)
					oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.15 - 0120, Transform(aDados[nX, 38, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni, (nColIni + nColMax)*0.15, nLinIni + 0094, (nColIni + nColMax)*0.30 - 0010)
					oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.15 + 0010, "39 - Valor Total Processado Protocolo (R$)", oFont01) //39 - Valor Total Processado Protocolo (R$)
					oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.30 - 0120, Transform(aDados[nX, 39, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni, (nColIni + nColMax)*0.30, nLinIni + 0094, (nColIni + nColMax)*0.45 - 0010)
					oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.30 + 0010, "40 - Valor Total Glosa Protocolo (R$)", oFont01) //40 - Valor Total Glosa Protocolo (R$)
					oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.45 - 0120, Transform(aDados[nX, 40, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni, (nColIni + nColMax)*0.45, nLinIni + 0094, (nColIni + nColMax)*0.60 - 0010)
					oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.45 + 0010, "41 - Valor Total Franquia Protocolo (R$)", oFont01) //41 - Valor Total Franquia Protocolo (R$)
					oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.60 - 0120, Transform(aDados[nX, 41, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)
					oPrint:Box(nLinIni, (nColIni + nColMax)*0.60, nLinIni + 0094, (nColIni + nColMax)*0.75 - 0010)
					oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.60 + 0010, "42 - Valor Total Liberado Protocolo (R$)", oFont01) //42 - Valor Total Liberado Protocolo (R$)
					oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.75 - 0120, Transform(aDados[nX, 42, nX1, nX2], "@E 999,999,999.99"), oFont04,,,,1)

				Next nX2

			 	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 40)
			 	AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, nColIni + nColMax)
				oPrint:Say(nLinIni + 0023, nColIni + 0020, "Demais débitos / créditos", oFont01) //Demais débitos / créditos

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
			 	oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 40 + (Len(aDados[nX, 43,nX1]) * 45), nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 0020, nColIni + 0020, "43-Indicação", oFont01) //43-Indicação
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.10, "44-Código do débito/crédito", oFont01)  //44-Código do débito/crédito
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.20, "45-Descrição do débito/crédito", oFont01)  //45-Descrição do débito/crédito
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.85, "46-Valor", oFont01,,,,1)  //46-Valor

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 20, 40)
			 	For nI := 1 To Len(aDados[nX, 43,nX1])
					oPrint:Say(nLinIni + 0030, nColIni + 0020, aDados[nX, 43,nX1, nI], oFont04)
					oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.10, aDados[nX, 44,nX1, nI], oFont04)
					oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.20, aDados[nX, 45,nX1, nI], oFont04)
					oPrint:Say(nLinIni + 0030, (nColIni + nColMax)*0.85, IIf(Empty(aDados[nX, 46,nX1, nI]), "", Transform(aDados[nX, 46,nX1, nI], "@E 999,999,999.99")), oFont04,,,,1)
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45, 40)
				Next nI

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45, 40)
				AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, (nColIni + nColMax)*0.5 - 0010)
				oPrint:Say(nLinIni + 0023, nColIni + 0020, "Demais débitos / créditos não tributáveis", oFont01) //Demais débitos / créditos não tributáveis

				AddTBrush(oPrint, nLinIni, (nColIni + nColMax)*0.5 + 0010, nLinIni + 0030, nColIni + nColMax)
				oPrint:Say(nLinIni + 0023, (nColIni + nColMax)*0.5 + 0020, "Impostos", oFont01) //Impostos

				nCount := Len(aDados[nX, 47,nX1])
				If (nCount < Len(aDados[nX, 51,nX1]))
					nCount := Len(aDados[nX, 51,nX1])
				EndIf

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
				oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 40 + (nCount * 45), (nColIni + nColMax)*0.5 - 0010)
				oPrint:Say(nLinIni + 0020, nColIni + 0020, "47-Indicação", oFont01) //47-Indicação
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.07, "48-Código do débito/crédito", oFont01) //48-Código do débito/crédito
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.17, "49-Descrição do débito/crédito", oFont01) //49-Descrição do débito/crédito
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.44, "50-Valor", oFont01,,,,1) //50-Valor

				oPrint:Box(nLinIni, (nColIni + nColMax)*0.5 + 0010, nLinIni + 40 + (nCount * 45), nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.5 + 0020, "51-Indicação", oFont01) //51-Indicação
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.57, "52-Código do débito/crédito", oFont01) //52-Código do débito/crédito
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.67, "53-Descrição do débito/crédito", oFont01) //53-Descrição do débito/crédito
				oPrint:Say(nLinIni + 0020, (nColIni + nColMax)*0.94, "54-Valor", oFont01,,,,1) //54-Valor

				If (nCount > 0)
					fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 40)

					For nI := 1 To nCount
						If (Len(aDados[nX, 47, nX1]) >= nI)
							oPrint:Say(nLinIni + 0003, nColIni + 0020, aDados[nX, 47, nX1, nI], oFont04) //47-Indicação
							oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.07, aDados[nX, 48, nX1, nI], oFont04) //48-Código do débito/crédito
							oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.17, aDados[nX, 49, nX1, nI], oFont04) //49-Descrição do débito/crédito
							oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.44, IIf(Empty(aDados[nX, 50,nX1, nI]), "", Transform(aDados[nX, 50,nX1, nI], "@E 999,999,999.99")), oFont04,,,,1) //50-Valor
						EndIf

						If (Len(aDados[nX, 51, nX1]) >= nI)
							oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.5 + 0020, aDados[nX, 51, nX1, nI], oFont04) //51-Indicação
							oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.57, aDados[nX, 52, nX1, nI], oFont04) //52-Código do débito/crédito
							oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.67, aDados[nX, 53, nX1, nI], oFont04) //53-Descrição do débito/crédito
							oPrint:Say(nLinIni + 0003, (nColIni + nColMax)*0.94, IIf(Empty(aDados[nX, 54,nX1, nI]), "", Transform(aDados[nX, 54,nX1, nI], "@E 999,999,999.99")), oFont04,,,,1) //54-Valor
						EndIf
						fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 45, 40)
					Next nI
				EndIf

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, IIF(nCount > 0, 25,50), 40)
				AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0030, nColIni + nColMax)
				oPrint:Say(nLinIni + 0023, nColIni + 0020, "Totais", oFont01) //Total do Protocolo

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 37, 40)
			    oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 0094, (nColIni + nColMax)*0.15 - 0010)
				oPrint:Say(nLinIni + 0025, nColIni + 0020, "55 - Valor Total Tributável (R$)", oFont01) //55 - Valor Total Tributável (R$)
				oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.15 - 0120, Transform(aDados[nX, 55, nX1], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Box(nLinIni, (nColIni + nColMax)*0.15, nLinIni + 0094, (nColIni + nColMax)*0.30 - 0010)
				oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.15 + 0010, "56- Valor Total Impostos Retidos (R$)", oFont01) //56- Valor Total Impostos Retidos (R$)
				oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.30 - 0120, Transform(aDados[nX, 56, nX1], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Box(nLinIni, (nColIni + nColMax)*0.30, nLinIni + 0094, (nColIni + nColMax)*0.45 - 0010)
				oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.30 + 0010, "57 - Valor Total Não Tributável (R$)", oFont01) //57 - Valor Total Não Tributável (R$)
				oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.45 - 0120, Transform(aDados[nX, 57, nX1], "@E 999,999,999.99"), oFont04,,,,1)
				oPrint:Box(nLinIni, (nColIni + nColMax)*0.45, nLinIni + 0094, (nColIni + nColMax)*0.60 - 0010)
				oPrint:Say(nLinIni + 0025, (nColIni + nColMax)*0.45 + 0010, "58 - Valor Final a Receber (R$)", oFont01) //58 - Valor Final a Receber (R$)
				oPrint:Say(nLinIni + 0065, (nColIni + nColMax)*0.60 - 0120, Transform(aDados[nX, 58, nX1], "@E 999,999,999.99"), oFont04,,,,1)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 105, 40)
				AddTBrush(oPrint, nLinIni, nColIni + 0010, nLinIni + 0220, nColIni + nColMax - 0010)
				oPrint:Box(nLinIni, nColIni + 0010, nLinIni + 0220, nColIni + nColMax - 0010)
				oPrint:Say(nLinIni + 0025, nColIni + 0020, "59 - Observação", oFont01) //59 - Observação

				For nI := 1 To MlCount(aDados[nX, 59, nX1], 130)
					cObs := MemoLine(aDados[nX, 59, nX1], 130, nI)
					oPrint:Say(nLinIni + 0020 + (nI*40), nColIni + 0030, cObs, oFont04)
				Next nI

			Next nX1

			oPrint:EndPage()	// Finaliza a pagina

		Next nX
	EndIf
	
	//Visualiza impressao grafica antes de imprimir	
	oPrint:Preview()
	
	//Checa se o arquivo PDF esta ponto para visualizacao na web e envio de e-mail.	
	if lWeb
		PLSCHKRP(cPathSrv+cFileName+".pdf")
	endIf
endIf

//fim da rotina
return( { cFileName + ".pdf",cMsg } )


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRELEPM
Extrato de Pagamento da RDA 

@author  PLS TEAM
@version P12
@since   03.02.13
/*/
//-------------------------------------------------------------------
function PLSRELEPM(cRdaW,cAnoW,cMesW,lWeb,cPathW,cNmTitPg,cAlias,lAuto)
LOCAL cFilename		:= lower("PLSRELEPM" + criaTrab(nil,.f.) + "_" + iif(ValType(cRdaW) == 'U',cRdaW := "",cRdaW)) // Colocado a RDA no nome do arquivo pro filtro no portal
LOCAL cPathSrv 		:= lower(getMV("MV_RELT"))
LOCAL cPerg			:= "PLSRELEPM"
LOCAL cMsg			:= ""

PRIVATE oPrint		:= nil
PRIVATE nLinIni    	:= 0
PRIVATE nLimite     := 132
PRIVATE nTamDes     := 35
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE cTitulo     := "Extrato da RDA"
PRIVATE lAnalitico 	:= .T.

DEFAULT lWeb	:= .f.
DEFAULT cRdaW	:= ""
DEFAULT cAnoW	:= ""
DEFAULT cMesW	:= ""
DEFAULT cPathW	:= ""
DEFAULT cNmTitPg:= ""
DEFAULT cAlias := "SE2"
Default lAuto := .F.

//Somente se nao for web
if lAuto .OR. !lWeb
	
	//Acessa parametros do relatorio...	
	if !pergunte(cPerg,.T.)
		return
	endIf
	
	//dados do pergunte	
	cCodOpe   := mv_par01
	cCodRda   := mv_par02
	cAno      := mv_par03
	cMes      := mv_par04
else
	cCodOpe   := plsintpad()
	cCodRda   := cRdaW
	cAno      := cAnoW
	cMes      := cMesW
	cPathSrv  := cPathW
endIf

//Fonte Normal
oFont02n := TFont():New("Courier", 13, 13, , .T., , , , .T., .F.) // Negrito
oFont04	 := TFont():New("Courier", 11, 11, , .F., , , , .T., .F.) // Normal

//DAHER - Tive que colocar esse Semaforo aqui pois por alguma razao
//quando duas transacoes chamavam ao mesmo tempo o FWMSPRINTER
//eventualmente alguma delas nao retornava, ou seja, ele entrava
//no FWMSPRINTER e nunca saia
nH := PLSAbreSem("PPLSRELEPM.SMF")
oPrint := FWMSPrinter():New(cFileName,IMP_PDF,.t.,nil,.t.,nil,@oPrint,nil,nil,.f.,.f.,.t.)
PLSFechaSem(nH,"PPLSRELEPM.SMF")

oPrint:lInJob  	:= lWeb
oPrint:lServer 	:= lWeb
oPrint:cPathPDF	:= cPathSrv

oPrint:setDevice(IMP_PDF)

//Resolução do relatorio.
oPrint:setResolution(72)

//Modo paisagem
oPrint:setLandscape()

//Papel A4
oPrint:setPaperSize(TAM_A4)

//Margem
oPrint:setMargin(05,05,05,05)

//Verifica se existe alguma impressora configurada para Impressao Grafica
if !lAuto .AND. !lWeb
	oPrint:setup()
endIf

//Emite relat¢rio                                                          
lRet := R018Imp(cCodOpe,cCodRda,cAno,cMes,cPathSrv,lWeb,cNmTitPg,cAlias)

if !lRet
	if !lAuto .AND. !lWeb
		msgAlert("Não foram encontrados dados para os parâmetros informados!")
	else
		cMsg := "Não foram encontrados dados para os parâmetros informados!"
	endIf
endIf

//Checa se o arquivo PDF esta ponto para visualizacao na web e envio de e-mail.
if lRet .and. lWeb
	PLSCHKRP(cPathSrv+cFileName+".pdf")
endIf

//fim da rotina
return( { cFilename + ".pdf",cMsg } )


//-------------------------------------------------------------------
/*/{Protheus.doc} R018Imp
Imprime o extrato mensal dos servicos prestados

@author  PLS TEAM
@version P12
@since   03.02.13
/*/
//-------------------------------------------------------------------
static function R018Imp(cCodOpe,cCodRda,cAno,cMes,cPathSrv,lWeb,cNmTitPg,cAlias)
LOCAL nI		:= 0
LOCAL nPos      := 0
LOCAL nFor		:= 0
LOCAL nPosLot   := 0
LOCAL nCont		:= 0
LOCAL nTotGlo   := 0
LOCAL NBINSSJF  := 0
LOCAL NINSSJF	:= 0
LOCAL nBINSSPJ  := 0
LOCAL nINSSPJ   := 0
LOCAL nBIss    	:= 0
LOCAL nIss    	:= 0
LOCAL nBPis    	:= 0
LOCAL nPis    	:= 0
LOCAL nBCofins  := 0
LOCAL nCofins   := 0
LOCAL nBCSLL    := 0
LOCAL nCSLL    	:= 0
LOCAL nBINSSPF  := 0
LOCAL nINSSPF   := 0
LOCAL nBIR    	:= 0
LOCAL nIR    	:= 0
LOCAL nPINSSPJ  := 0
LOCAL nPINSSPF  := 0
LOCAL nCrPINSS  := 0
LOCAL nVlrItem  := 0
LOCAL nVlrBD7Glo	:= 0
LOCAL nDebApo   := 0
LOCAL nVlrTot   := 0
LOCAL ntBIss    := 0
LOCAL ntIss     := 0
LOCAL ntBPis    := 0
LOCAL ntPis     := 0
LOCAL ntBCofins := 0
LOCAL ntCofins  := 0
LOCAL ntBIR     := 0
LOCAL ntIR      := 0
LOCAL ntBCSLL   := 0
LOCAL ntCSLL    := 0
LOCAL ntBINSSPF := 0
LOCAL ntINSSPF  := 0
LOCAL ntBINSSPJ := 0
LOCAL ntINSSPJ  := 0
LOCAL ntBINSSJF := 0
LOCAL ntINSSJF  := 0
LOCAL ntPINSSPJ := 0
LOCAL ntPINSSPF := 0
LOCAL ntCrPINSS := 0
LOCAL nVlrPag  	:= 0
LOCAL nVlrPagT 	:= 0
LOCAL nVlrGlo  	:= 0
LOCAL nCreTot  	:= 0
LOCAL nColAux   := 0
LOCAL cValor	:= ""
LOCAL cLotBD7 	:= ""
LOCAL cLotBMR 	:= ""
LOCAL cDepIr    := ""
LOCAL cUsuAnt   := ""
LOCAL cSQL      := ""
LOCAL cJusti	:= ""
LOCAL cTipGui 	:= ""
LOCAL cOpeLot   := ""
LOCAL cLotes    := ""
LOCAL cLinha 	:= ""
LOCAL cLotImp   := ""
LOCAL lFirst    := .t.
LOCAL lLotImp   := .f.
LOCAL lLisfor   := .t.
LOCAL lRet		:= .f.
LOCAL lInssUnic := .f.
LOCAL aNumLot 	:= {}
LOCAL aLotes    := {}
LOCAL aTrbBD7	:= {}
LOCAL aResProdT := {0,0,0,0,0,0,0}
LOCAL aResProd 	:= {0,0,0,0,0,0,0}
LOCAL aTabResT  := {}
LOCAL aGlosas  	:= {}
LOCAL alog  	:= {}
LOCAL cNmLotPg		:= ""
LOCAL cRdaLote		:= ""
LOCAL cTpLocExec	:= ""
LOCAL aLinDetal     := {}
LOCAL cMovime 		:= "NAO IDENTIFICADO"
PRIVATE nDebFix  	:= 0
PRIVATE nCreFix  	:= 0
PRIVATE nDebVar  	:= 0
PRIVATE nCreVar  	:= 0
PRIVATE nCreApo  	:= 0
PRIVATE nDebTot  	:= 0
PRIVATE ntDebFix  	:= 0
PRIVATE ntCreFix  	:= 0
PRIVATE ntDebVar  	:= 0
PRIVATE ntCreVar 	:= 0
PRIVATE ntDebApo  	:= 0
PRIVATE ntCreApo  	:= 0
PRIVATE nTotal   	:= 0
PRIVATE cEspecia	:= ""
PRIVATE cCodRdaAnt	:= ""
PRIVATE aTabRes  	:= {}
PRIVATE lTem 		:= .f.
PRIVATE lLisRes   	:= .t.
PRIVATE nPag			:= 1
PRIVATE cNmT			:= ""
PRIVATE dVencRea		:= ctod('')
PRIVATE cAnoMes		:= ""
DEFAULT cNmTitPg		:= ""
DEFAULT cAlias      	:= "SE2"

cNmT 		:= cNmTitPg
cAnoMes 	:= cAno+'\'+cMes

If lWeb
	cTpLocExec := '2'
Else
	cTpLocExec := '1'
Endif

//Monta novo nome do titulo do relatorio mostrando mes/ano                 
cTitulo := AllTrim(cTitulo) + " - " + PLRETMES(Val(cMes)) + "/" + cAno

//Seleciona indices                                                           
BA1->(dbSetOrder(2))
BD6->(dbSetOrder(1))
BDX->(dbSetOrder(1))

// Variaveis para buscar o BMR pelo numero do titulo.
If !Empty(cNmTitPg)
	If cAlias ="SE2"
		SE2->(dbSetorder(01))
		If SE2->(dbSeek(xFilial("SE2")+cNmTitPg))
			cCodOpe  := SE2->E2_PLOPELT
			cNmLotPg := SE2->E2_PLLOTE
			cRdaLote := SE2->E2_CODRDA
			cFornece:= SE2->E2_FORNECE
			cLoja    := SE2->E2_LOJA
			cAno := SE2->E2_ANOBASE
			cMes := SE2->E2_MESBASE
			dVencRea := SE2->E2_VENCREA
		Endif
	Else
		SC7->(dbSetorder(01))
		If SC7->(dbSeek(xFilial("SC7")+cNmTitPg))
			cCodOpe  := PLSINTPAD()
			cNmLotPg := SC7->C7_LOTPLS
			cRdaLote := SC7->C7_CODRDA
			cFornece:= SC7->C7_FORNECE
			cLoja    := SC7->C7_LOJA


			cAno := Substr(SC7->C7_LOTPLS,1,4)
			cMes := Substr(SC7->C7_LOTPLS,5,2)
		Endif
	Endif

Endif

//Monta Query																 
cSql := " SELECT BD6_OPELOT,BD6_NUMLOT,BD6_PAGRDA,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_SEQUEN,BD6_NOMUSR,BD6_VLRPAG,BD6_VLRGLO,BD6_VLRAPR,BD6_QTDPRO,BD6_DATPRO,"+RetSQLName("BD7")+".* "
cSql += " FROM " + RetSQLName("BD7") + ", " + RetSQLName("BD6")
cSql += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
cSql += " AND BD7_CODOPE = '"+ cCodOpe + "' "
cSql += " AND BD7_OPELOT = '" + cCodOpe + "' "
cSql += " AND BD7_CODRDA = '" + cCodRda + "' "

//Faturada																 
If !Empty(cNmLotPg)
	cSQL += "AND BD7_NUMLOT = '"+ cNmLotPg +"' "

Else
	cSql += " AND BD7_NUMLOT LIKE '" + cAno+cMes + "%' "

Endif

cSql += " AND BD7_BLOPAG <> '1' And BD7_SITUAC = '1' "

//Faturada																 
cSql += " AND BD7_FASE = '4' "
cSql += " AND (BD7_VLRPAG > 0 OR BD7_VLRGLO > 0)"

//Outros																	 
cSql += " AND "+RetSQLName("BD7")+".D_E_L_E_T_ = ' '"

//BD7 COM BD6                                                              
cSql += " AND BD6_FILIAL = BD7_FILIAL "
cSql += " AND BD6_CODOPE = BD7_CODOPE "
cSql += " AND BD6_CODLDP = BD7_CODLDP "
cSql += " AND BD6_CODPEG = BD7_CODPEG "
cSql += " AND BD6_NUMERO = BD7_NUMERO "
cSql += " AND BD6_ORIMOV = BD7_ORIMOV "
cSql += " AND BD6_SEQUEN = BD7_SEQUEN "
cSql += " AND BD6_CODPAD = BD7_CODPAD "
cSql += " AND BD6_CODPRO = BD7_CODPRO "
cSql += " AND "+RetSQLName("BD6")+".D_E_L_E_T_ = ' '"
cSql += " ORDER BY BD7_FILIAL,BD7_TIPGUI,BD7_DATPRO,BD6_NOMUSR,BD7_CODRDA,BD7_CODPAD "
PLSQuery(cSql,"TrbBD7")

//Posiciona no SE2
if !TrbBD7->( eof() ) .and. empty(cNmTitPg)
	SE2->(dbSetorder(12))//E2_FILIAL+E2_PLOPELT+E2_PLLOTE+E2_NOMFOR
	if SE2->(msSeek(xFilial("SE2")+TrbBD7->(BD6_OPELOT+BD6_NUMLOT)))
		while !SE2->(eof()) .and. xFilial("SE2")+TrbBD7->(BD6_OPELOT+BD6_NUMLOT) == SE2->(E2_FILIAL+E2_PLOPELT+E2_PLLOTE)

			if empty(SE2->E2_TITPAI) .and. SE2->E2_TIPO <> 'NDF' .and. SE2->E2_CODRDA == cCodRda
				cNmT	  := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
				cCodOpe  := SE2->E2_PLOPELT
				cNmLotPg := SE2->E2_PLLOTE
				cRdaLote := SE2->E2_CODRDA
				dVencRea := SE2->E2_VENCREA
				exit
			endIf

		SE2->(dbskip())
		endDo
	endIf
endif

//Montado Matriz															 
while !TrbBD7->( eof() )
	
	//Achou movimento															 
	lRet := .t.
	
	//Lote																	 	
	if At(TrbBD7->BD7_NUMLOT,cLotBD7) == 0
		cLotBD7 +=  IIf(empty(cLotBD7), "", ",") + "'" + TrbBD7->BD7_NUMLOT + "'"
		cLotBMR +=  IIf(empty(cLotBMR), "", ",") + "'" + SubStr(TrbBD7->BD7_NUMLOT, 7, 4) + "'"
	endIf

	If aScan(aTrbBD7,{|x| TrbBD7->BD7_CODOPE+TrbBD7->BD7_CODLDP+TrbBD7->BD7_CODPEG+TrbBD7->BD7_NUMERO+TrbBD7->BD7_SEQUEN == x[5]+x[6]+x[7]+x[8]+x[10] }) <> 0
		aTrbBD7[len(aTrbBD7),34] += TrbBD7->BD7_VLRPAG
		aTrbBD7[len(aTrbBD7),35] += TrbBD7->BD7_VLRGLO
		aTrbBD7[len(aTrbBD7),36] += TrbBD7->BD7_VLRAPR
		TrbBD7->( dbSkip() )
		loop
	Endif
	
	//Matriz																		
	AaDd(aTrbBD7,  {xFilial("BD7"),;		//01 - Filial
					TrbBD7->BD6_NOMUSR,;	//02 - Nome Usuario
					TrbBD7->BD7_CODRDA,;	//03 - Codigo Rda
					TrbBD7->BD7_NUMLOT,;	//04 - Numero Lote
					TrbBD7->BD7_CODOPE,;	//05 - Operadora
					TrbBD7->BD7_CODLDP,;	//06 - LOCAL Digitacao
					TrbBD7->BD7_CODPEG,;	//07 - Peg
					TrbBD7->BD7_NUMERO,;	//08 - Guia
					TrbBD7->BD7_ORIMOV,;	//09 - Origem Movimento
					TrbBD7->BD7_SEQUEN,;	//10 - Sequencia
					TrbBD7->BD7_CODEMP,;	//11 - Empresa
					TrbBD7->BD7_MATRIC,;	//12 - Matricula
					TrbBD7->BD7_TIPREG,;	//13 - Tipo Usuarios
					TrbBD7->BD7_CODPAD,;	//14 - Cd Tp Tabela
					TrbBD7->BD7_CODPRO,;	//15 - Codigo Procedimento
					TrbBD7->BD7_NUMIMP,;	//16 - Numero do Impresso
					TrbBD7->BD7_REFTDE,;	//17 - Referencia
					TrbBD7->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN),;	//18 - Chave BD7
					TrbBD7->BD6_VLRGLO,;	//19 - Valor Glosa
					TrbBD7->BD7_BLOPAG,;	//20 - Bloqueia Pagamento
					TrbBD7->BD7_SITUAC,;	//21 - Situacao
					TrbBD7->BD7_BLQAUG,;	//22 - Bloqueado pelo AG
					TrbBD7->BD7_DESBLO,;	//23 - Descricao do Bloqueio
					Iif(TrbBD7->( FieldPos("BD7_CLAINS") ) > 0,Iif(TrbBD7->BD7_CLAINS == "1" ,"F" ,"J" )," "),;//24 -
					TrbBD7->BD7_CODUNM,;	//25 - Unidade
					TrbBD7->BD7_UNITDE,;	//26 - Unidade
					TrbBD7->BD6_DATPRO,;	//27 - Data do Procedimento
					TrbBD7->BD7_MODCOB,;	//28 - Modalidade Cobranca
					TrbBD7->BD7_TIPUSR,;	//29 - Tipo de Usuario
					TrbBD7->BD7_INTERC,;	//30 - Intercambio Sim ou Nao
					TrbBD7->R_E_C_N_O_,;	//31 - Recno do campo
					TrbBD7->BD7_TIPGUI,; //32 - Tipo de Guia
					TrbBD7->BD6_PAGRDA,; //33 - Pagamento Rda
					TrbBD7->BD7_VLRPAG,; //34 - Valor Pago
					TrbBD7->BD7_VLRGLO,; //35 - Glosa
					TrbBD7->BD7_VLRAPR} )//36 - Apresentado

	TrbBD7->( dbSkip() )
endDo

//Fecha area de trabalho													 
TrbBD7->( DbCloseArea() )

//Seleciona indices                                                           
BA1->(dbSetOrder(2))
BD5->(dbSetOrder(1))
BE4->(dbSetOrder(1))
BD6->(dbSetOrder(1))
BR8->(dbSetOrder(1))
BDX->(dbSetOrder(1))
BAF->(dbSetOrder(1))
BB8->(dbSetOrder(1))
SA2->(dbSetOrder(1))

//Filtra BAU-Rede de Atendimento                                           
cSQL := " SELECT R_E_C_N_O_ BAU_RECNO FROM " + RetSQLName("BAU")
cSQL += " WHERE BAU_FILIAL = '" + xFilial("BAU") + "' "
cSQL += "   AND BAU_CODIGO = '" + cCodRda   + "' "
cSQL += "   AND D_E_L_E_T_ = '' "
PLSQUERY(cSQL,"TrbBAU")

//Imprime cada RDA                                                            
while ! TrbBAU->(eof())
	
	//Posiciona BAU-Rede de Atendimento                                        	
	BAU->(dbGoTo(TrbBAU->BAU_RECNO))
	
	//Posiciona SA2-Fornecedores                                               	
	if  lLisFor
		SA2->(msSeek(xFilial("SA2")+BAU->(BAU_CODSA2+BAU_LOJSA2)))
	endIf
	
	//Verifica se a RDA existe para a operadora desejada                       	
	BAW->(dbSetOrder(1))
	if  ! BAW->(msSeek(xFilial("BAW")+BAU->BAU_CODIGO+cCodOpe))
		TrbBAU->(dbSkip())
		Loop
	endIf
	
	//Verifica se existe movimento de producao para a rda		                 	
	lTemMov := .F.
	if aScan( aTrbBD7 , { |x| x[1]+x[3] == xFilial("BD7")+BAU->BAU_CODIGO } ) > 0
		lTemMov := .T.
	endIf
	
	//Verifica se faturas geradas                                              	
	cSQL := " SELECT DISTINCT BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT FROM " + RetSQLName("BMR")
	cSQL += " WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
	cSQL += " AND BMR_CODRDA =  '" + BAU->BAU_CODIGO + "' "

	If !Empty(cNmLotPg)
		cSQL += "AND BMR_NUMLOT = '" + Subs(cNmLotPg,7,4) + "'  "
	Else
		cSQL += " AND BMR_ANOLOT =  '" + cAno            + "' "
		cSQL += " AND BMR_MESLOT =  '" + cMes            + "' "
	Endif
	cSQL += "   AND D_E_L_E_T_ = ' ' "
	PLSQUERY(cSQL,"TrbBMR")
	while !TrbBMR->( eof() )
	    Aadd(aNumLot,{TrbBMR->BMR_ANOLOT+TrbBMR->BMR_MESLOT+TrbBMR->BMR_NUMLOT})
	    TrbBMR->(dbSkip())
	endDo
	TrbBMR->(DbCloseArea())
	
	//Verifica se tem debito/credito                                           	
	cSQL := " SELECT COUNT(*) QTD FROM " + RetSQLName("BGQ")
	cSQL += " WHERE BGQ_FILIAL =  '" + xFilial("BGQ") + "' "
	cSQL += "   AND BGQ_CODIGO =  '" + BAU->BAU_CODIGO + "' "
	cSQL += "   AND BGQ_ANO    =  '" + cAno            + "' "
	cSQL += "   AND (BGQ_MES   =  '" + cMes            + "' "
    if len(aNumLot)>0
		
		//Verifica lotes ja processados		
        cSQL += "   OR BGQ_NUMLOT IN ( "
        for nCont := 1 to len(aNumLot)
           cSQL += "'" + aNumLot[nCont][1] + " ' "
           if nCont <> len(aNumLot)
           		cSQL += ","
           endIf
        next
           cSQL += " ) ) "
    Else
        cSQL += " ) "
    endIf

	cSQL += "   AND BGQ_NUMLOT <> '" + space(10)       + "' AND "
	if ! empty(cLotBD7)
		cSQL += " BGQ_NUMLOT IN (" + cLotBD7 + ") AND "
	endIf
	cSQL += " D_E_L_E_T_ = '' "
	PLSQUERY(cSQL,"TrbBGQ")
	if  TrbBGQ->QTD > 0
		lRet := .t.
		lTemMov := .T.
	endIf
	TrbBGQ->(DbCloseArea())
	
	//Verifica se tem apontamento de producao                                  	
	cSQL := " SELECT COUNT(*) QTD FROM " + RetSQLName("BCE")
	cSQL += " WHERE BCE_FILIAL =  '" + xFilial("BCE") + "' AND "
	cSQL += "       BCE_CODIGO =  '" + BAU->BAU_CODIGO + "' AND "
	cSQL += "       BCE_ANOPAG =  '" + cAno            + "' AND "
	cSQL += "       BCE_MESPAG =  '" + cMes            + "' AND "
    cSQL += "   BCE_NUMLOT <> '" + space(10)       + "' AND "
    if ! empty(cLotBD7)
       cSQL += "   BCE_NUMLOT IN (" + cLotBD7 + ") AND "
    endIf
	cSQL += "D_E_L_E_T_ = ''"
	PLSQUERY(cSQL,"TrbBCE")
	if TrbBCE->QTD > 0
	   lTemMov := .T.
	endIf
	TrbBCE->(DbCloseArea())
	
	//Verifica se a RDA teve alguma movimentacao                               	
	if  ! lTemMov
		TrbBAU->(dbSkip())
		Loop
	endIf
	
	//Inicializa variaveis relativas a RDA                                     	
	if  BAU->BAU_CALIMP $ "1,3"
		cDepIr := " Dependentes IR: " + PLSDEPIR(BAU->BAU_CODIGO,cAno,cMes)
	Else
		cDepIr := ""
	endIf
	cEspecia  := PLSLISESP(BAU->BAU_CODIGO)
	aLotes    := {}
	lInssUnic := .F.
	
	//Monta query                                                         	
	cSQL := " SELECT BMR_FILIAL, BMR_OPERDA, BMR_CODRDA, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT "
	cSQL += "  FROM " + RetSQLName("BMR")
	cSQL += "  WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
	cSQL += "    AND BMR_CODRDA = '" + BAU->BAU_CODIGO + "' "
	cSQL += "    AND BMR_ANOLOT = '" + cAno    + "' "
	cSQL += "    AND BMR_MESLOT = '" + cMes    + "' "
	if  ! empty(cLotBMR)
		cSQL += "    AND BMR_NUMLOT IN (" + cLotBMR + ") "
	endIf
	cSQL += "    AND D_E_L_E_T_ = ' ' "
	cSQL += " GROUP BY BMR_FILIAL, BMR_OPERDA, BMR_CODRDA, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT "
	cSQL += " ORDER BY BMR_FILIAL, BMR_OPERDA, BMR_CODRDA, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT "
	
	//Executa query                                                       	
	PLSQUERY(cSQL,"Trb")
	BMR->(dbSetOrder(1))
	
	//Processa arquivo de trabalho                                        	
	cLotes := ""
	while ! Trb->(eof())
		cLotes += "'" + Trb->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "',"
		BMR->(msSeek(Trb->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)))
		
		//nao eh um lote apenas de impostos		
		if  BMR->BMR_CODLAN < "170"
			aadd(aLotes,{cCodOpe,Trb->BMR_ANOLOT+Trb->BMR_MESLOT+Trb->BMR_NUMLOT})
		Else
			aadd(aLotes,{cCodOpe,Trb->BMR_ANOLOT+Trb->BMR_MESLOT+Trb->BMR_NUMLOT})
			lLotImp := .T.
			cLotImp := Trb->BMR_ANOLOT+Trb->BMR_MESLOT+Trb->BMR_NUMLOT
		endIf
		Trb->(dbSkip())
	endDo
	Trb->(dbCloseArea())
	cLotes := alltrim(cLotes)
	if  right(cLotes,1) == ","
		clotes := "(" + substr(cLotes,1,len(cLotes)-1) + ")"
	endIf
	
	//Inicializa variaveis                                                     	
	aResProdT := {0,0,0,0,0,0,0}
	aTabResT  := {}
	ntBIss    := 0
	ntIss     := 0
	ntBPis    := 0
	ntPis     := 0
	ntBCofins := 0
	ntCofins  := 0
	ntBIR     := 0
	ntIR      := 0
	ntBCSLL   := 0
	ntCSLL    := 0
	ntBINSSPF := 0
	ntINSSPF  := 0
	ntBINSSPJ := 0
	ntINSSPJ  := 0
	ntBINSSJF := 0
	ntINSSJF  := 0
	ntPINSSPJ := 0
	ntPINSSPF := 0
	ntCrPINSS := 0
	lFirst    := .T.
	ntDebFix  := 0
	ntCreFix  := 0
	ntDebVar  := 0
	ntCreVar  := 0
	ntDebApo  := 0
	ntCreApo  := 0
	cCodRdaAnt:= BAU->BAU_CODIGO
	
	//Processa todos os lotes da RDA                                           	
	for nPosLot := 1 to len(aLotes)
		
		//Inicializa variaveis relativas ao lote                                   		
		cOpeLot := aLotes[nPosLot,1]
		cNumLot := aLotes[nPosLot,2]
		BAF->(msSeek(xFilial("BAF") + cOpeLot + cNumLot))
		cDesLot := BAF->BAF_HISTIT
		
		//Inicializa variaveis                                                     		
		aResProd := {0,0,0,0,0,0,0}
		aTabRes  := {}
		nVlrPag  := 0
		nVlrPagT := 0
		nVlrGlo  := 0
		nDebFix  := 0
		nCreFix  := 0
		nDebVar  := 0
		nCreVar  := 0
		nCreApo  := 0
		nDebTot  := 0
		nCreTot  := 0
		nTotal   := 0
		aGlosas  := {}

		lTem := .F.
		
		//Inicializa variaveis                                                     		
		cProAnt := ""
		cUsuAnt := ""
		cImpAnt := ""
		lFirst  := .T.
		
		//Processa todas as guias deste lote                                       		
		nPos := aScan( aTrbBD7 , { |x| x[1]+x[3]+x[4] == xFilial("BD7")+BAU->BAU_CODIGO+cNumLot } )
		if nPos > 0
			
			//Inicio das soma de valores e totais			
			for nI := nPos to len(aTrbBD7)

					if aTrbBD7[nI,3] <> BAU->BAU_CODIGO .Or. aTrbBD7[nI,4] <> cNumLot
						Exit
					endIf
					
					//Posiciona BD6-Item da Guia                                         					
					BD6->( msSeek( xFilial("BD6")+aTrbBD7[nI,5]+aTrbBD7[nI,6]+aTrbBD7[nI,7]+aTrbBD7[nI,8]+aTrbBD7[nI,9]+aTrbBD7[nI,10] ) )
					
					//Posiciona BD5,BE4-Capa da Guia                                     					
     				If !Empty(BD6->BD6_TIPGUI)
      					cTipGui := BD6->BD6_TIPGUI
     				Else
						If aTrbBD7[nI,9] == '2' .And. aTrbBD7[nI,1]+aTrbBD7[nI,5]+aTrbBD7[nI,6]+aTrbBD7[nI,7]+aTrbBD7[nI,8] <> BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
							BE4->( MsSeek( xFilial("BE4")+aTrbBD7[nI,5]+aTrbBD7[nI,6]+aTrbBD7[nI,7]+aTrbBD7[nI,8] ) )
							cTipGui := BE4->BE4_TIPGUI
						Else
							BD5->( MsSeek( xFilial("BD5")+aTrbBD7[nI,5]+aTrbBD7[nI,6]+aTrbBD7[nI,7]+aTrbBD7[nI,8] ) )
							cTipGui := BD5->BD5_TIPGUI
						EndIf
					EndIF

					If cTipGui == '01'
						cMovime := "CONSULTA"
					Elseif cTipGui == '02'
						cMovime := "SP_SADT"
					Elseif cTipGui == '03'
						cMovime := "INTERN."
					Elseif cTipGui == '04'
						cMovime := "REEMBOLSO"
					Elseif cTipGui == '05'
						cMovime := "INTERN."
					Elseif cTipGui == '06'
						cMovime := "HONOR."
					Endif
					
					//Posiciona BA1-Usuarios                                                   					
					if  BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) <> aTrbBD7[nI,5]+aTrbBD7[nI,11]+aTrbBD7[nI,12]+aTrbBD7[nI,13]
					if !BA1->( MsSeek( xFilial("BA1")+aTrbBD7[nI,5]+aTrbBD7[nI,11]+aTrbBD7[nI,12]+aTrbBD7[nI,13] ) )
						Loop
					endIf
					endIf
				
				//Total da Linha				
				nVlrItem 	:= 0
				nVlrBD7Glo	:= 0
				nVlrBD7Apr	:= 0

				nVlrItem	+= if(BAU->BAU_PAGPRO $ "1, ",round(aTrbBD7[nI,34],2),0)
				nVlrBD7Glo	+= if(BAU->BAU_PAGPRO $ "1, " .And. aTrbBD7[nI,33] <> "1",round(aTrbBD7[nI,35],2),0)
				nVlrBD7Apr	+= round(aTrbBD7[nI,36],2)

				If  BAU->BAU_PAGPRO $ "1, " .and. (aTrbBD7[nI,20] == "1" .OR. aTrbBD7[nI,21] == "3") .And. aTrbBD7[nI,33] <> "1"
					nVlrBD7Glo	:= nVlrItem
					nVlrItem  	:= 0
				Endif
					
					//Imprime linha de detalhe                                                 					
					nColAux    := 30
					aLinDetal  := {}
					Aadd(aLinDetal,{ Alltrim(cMovime),nColAux})//30

					nColAux +=  __NTAM1*16
					Aadd(aLinDetal,{ Alltrim(BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"."+BA1_TIPREG+'-'+BA1_DIGITO)),nColAux})//190

					nColAux += __NTAM2*16.2
					Aadd(aLinDetal,{ BA1->BA1_NOMUSR,nColAux})//595

	  				nColAux += __NTAM3*15.5
					Aadd(aLinDetal,{ Dtoc(aTrbBD7[nI,27]),nColAux})//1215

	  				nColAux += __NTAM4*16
					Aadd(aLinDetal,{ aTrbBD7[nI,7]+'.'+aTrbBD7[nI,8],nColAux})//1375

 					nColAux += __NTAM5*16
					Aadd(aLinDetal,{ aTrbBD7[nI,15],nColAux})//1695

	 				nColAux += __NTAM6*17
					Aadd(aLinDetal,{ alltrim(str(BD6->BD6_QTDPRO)),nColAux})//1865

  					nColAux += __NTAM7*20
  				Aadd(aLinDetal,{ TransForm(nVlrBD7Apr,pMoeda1),nColAux})//1965

	   				nColAux += __NTAM8*16.33333
				Aadd(aLinDetal,{ TransForm(nVlrBD7Glo,pMoeda1),nColAux})//2210

	   				nColAux += __NTAM9*16.66
				Aadd(aLinDetal,{ TransForm(nVlrItem,pMoeda1),nColAux})//2460
				
				//Para imprimir o total na mesma linha				
				R018Linha(cLinha,1,0,,aLinDetal)

				If BD7->BD7_VLRGLO > 0

					nTotGlo += BD7->BD7_VLRGLO

						BDX->(DbSetOrder(1))
						if BDX->(msSeek(xFilial("BDX")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN) ))
								while ! BDX->(eof()) .And. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == xFilial("BDX")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN)

									if BDX->BDX_TIPREG == "1"

										PLSPOSGLO(PLSINTPAD(),BDX->BDX_CODGLO,BDX->BDX_DESGLO,nil,'1',cTpLocExec)

										cLinha :=	PADR('',__NTAM1)			 			   		+ Space(1) + ;
													PADR('',__NTAM2+(__NTAM3/2)) 					+ Space(1) + ;
													If(Empty(BCT->BCT_GLTISS) .or. Empty(BCT->BCT_DESTIS),UPPER(BCT->BCT_CODGLO+' - '+BCT->BCT_DESCRI),UPPER(BCT->BCT_GLTISS+' - '+BCT->BCT_DESTIS))

										R018Linha(cLinha,1,0)

										if !empty(BDX->BDX_RESPAL)
											cJusti   := 'Justificativa.: ' + BDX->BDX_RESPAL
											cLinha :=	PADR('',__NTAM1)			 			   		+ Space(1) + ;
														PADR('',__NTAM2+(__NTAM3/2)) 					+ Space(1) + ;
														cJusti
											R018Linha(cLinha,1,0)
											cJusti:=""
										endIf
									endif
									
									cLinha:= ""

									BDX->(dbSkip())
								endDo
						endIf
				endIf
					lTem 	:= .T.
					
					//Acumula valores                                                          					
					nTotal   += nVlrItem
					nVlrPag  += nVlrItem
					nVlrPagT += nVlrItem

				Do Case
					
					//Custo Operacional PF					
					Case aTrbBD7[nI,28] <> '1' .And. aTrbBD7[nI,29] = '1' .And. aTrbBD7[nI,30] <> '1'
						aResProd[1]  += nVlrItem
						aResProdT[1] += nVlrItem
					
					//Custo Operacional PJ					
					Case aTrbBD7[nI,28] <> '1' .And. aTrbBD7[nI,29] = '2' .And. aTrbBD7[nI,30] <> '1'
						aResProd[2]  += nVlrItem
						aResProdT[2] += nVlrItem
					
					//Pre Pagamento PF					
					Case aTrbBD7[nI,28] = '1' .And. aTrbBD7[nI,29] = '1' .And. aTrbBD7[nI,30] <> '1'
						aResProd[3]  += nVlrItem
						aResProdT[3] += nVlrItem
					
					//Pre Pagamento PJ					
					Case aTrbBD7[nI,28] = '1' .And. aTrbBD7[nI,29] = '2' .And. aTrbBD7[nI,30] <> '1'
						aResProd[4]  += nVlrItem
						aResProdT[4] += nVlrItem
					
					//Intercambio				
					Case aTrbBD7[nI,30] = '1'
						aResProd[5]  += nVlrItem
						aResProdT[5] += nVlrItem
					
					//Outros					
					OtherWise
						aResProd[6]  += nVlrItem
						aResProdT[6] += nVlrItem
						aadd(aLog,{aTrbBD7[nI,5]+"."+aTrbBD7[nI,6]+"."+aTrbBD7[nI,7]+"."+aTrbBD7[nI,8]+"."+aTrbBD7[nI,9]+"."+aTrbBD7[nI,10],aTrbBD7[nI,29],aTrbBD7[nI,28],aTrbBD7[nI,30] } )
				EndCase
			next
		endIf
		
		//Lista cabecalho                                                          		

		//inicio nova pagina
		nLinIni := 5
		oPrint:endPage()
		oPrint:startPage()
		//fim nova pagina

		R018Linha("",1,0,.t.)
		cLinha := "R E S U M O"
		R018Linha(cLinha,1,0)
		R018Linha("",1,0,.t.)
		cLinha := "Debitos/Creditos              Descricao                                   Credito         Debito"
		R018Linha(cLinha,1,0)
		R018Linha("",1,0,.t.)
		
		//Lista outros debitos/creditos                                            		
		R018DC(cOpeLot,cNumLot,.T.,lLisRes,aNumLot,cAno,cMes,cCodOpe)
		
		//Total debitos/creditos                                                   		
		nDebTot := nDebFix + nDebVar + nDebApo
		nCreTot := nCreFix + nCreVar + nCreApo

		cValor  := transform(nTotGlo,pMoeda2)
		aadd(aTabRes,{"Total Glosa",cValor,space(len(cValor)),space(len(cValor)),""})

		aTabRes := {}
		nVlrTot := nVlrPag + nCreFix + nCreVar + nCreApo - nDebFix - nDebVar - nDebApo
		cValor  := transform(nVlrTot,pMoeda2)

		if  nVlrTot >= 0
			cValor  := transform(nVlrTot,pMoeda2)
			aadd(aTabRes,{"Total Bruto",cValor,space(len(cValor)),space(len(cValor)),""})
		Else
			cValor  := transform(nVlrTot * -1,pMoeda2)
			aadd(aTabRes,{"Total Bruto",space(len(cValor)),cValor,space(len(cValor)),""})
		endIf

			nBIss     := 0
			nIss      := 0
			nBPis     := 0
			nPis      := 0
			nBCofins  := 0
			nCofins   := 0
			nBIR      := 0
			nIR       := 0
			nBCSLL    := 0
			nCSLL     := 0
			nBINSSPF  := 0
			nINSSPF   := 0
			nBINSSPJ  := 0
			nINSSPJ   := 0
			nBINSSJF  := 0
			nINSSJF   := 0
			nPINSSPJ  := 0
			nPINSSPF  := 0
			nCrPINSS  := 0
			
			//Buscar imposto PIS, Cofins, CSLL, IR e INSS PF, INSSPJ			
			BMR->(dbSetOrder(3))
			if  BMR->(msSeek(xFilial("BMR")+cCodOpe+BAU->BAU_CODIGO+cOpeLot+cNumLot))
				while ! BMR->(eof()) .And. BMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) == ;
					xFilial("BMR")+cCodOpe+BAU->BAU_CODIGO+cOpeLot+cNumLot
					Do Case
						Case BMR->BMR_CODLAN == "182"
							nBINSSPJ  += BMR->BMR_VLRPAG
							ntBINSSPJ += BMR->BMR_VLRPAG
							lInssUnic := .T.
						Case BMR->BMR_CODLAN == "183"
							nINSSPJ   += BMR->BMR_VLRPAG
							ntINSSPJ  += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "184"
							nBIss     += BMR->BMR_VLRPAG
							ntBIss    += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "185"
							nIss      += BMR->BMR_VLRPAG
							ntIss     += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "186"
							nBPis     += BMR->BMR_VLRPAG
							ntBPis    += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "187"
							nPis      += BMR->BMR_VLRPAG
							ntPis     += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "188"
							nBCofins  += BMR->BMR_VLRPAG
							ntBCofins += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "189"
							nCofins   += BMR->BMR_VLRPAG
							ntCofins  += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "190"
							nBCSLL    += BMR->BMR_VLRPAG
							ntBCSLL   += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "191"
							nCSLL     += BMR->BMR_VLRPAG
							ntCSLL    += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "192"
							nBINSSPF  += BMR->BMR_VLRPAG
							ntBINSSPF += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "193"
							nINSSPF   += BMR->BMR_VLRPAG
							ntINSSPF  += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "194"
							nBINSSPJ  += BMR->BMR_VLRPAG
							ntBINSSPJ += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "195"
							nINSSPJ   += BMR->BMR_VLRPAG
							ntINSSPJ  += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "196"
							nBINSSPF  += BMR->BMR_VLRPAG
							ntBINSSPF += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "197"
							nINSSPF   += BMR->BMR_VLRPAG
							ntINSSPF  += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "198"
							nBIR      += BMR->BMR_VLRPAG
							ntBIR     += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "199"
							nIR       += BMR->BMR_VLRPAG
							ntIR      += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "179"
							nPINSSPJ  += BMR->BMR_VLRPAG
							ntPINSSPJ += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "180"
							nPINSSPF  += BMR->BMR_VLRPAG
							ntPINSSPF += BMR->BMR_VLRPAG
						Case BMR->BMR_CODLAN == "181"
							nCrPINSS  += BMR->BMR_VLRPAG
							ntCrPINSS += BMR->BMR_VLRPAG
					EndCase
					BMR->(dbSkip())
				endDo
			endIf
			
			//Busca impostos calculados                                                			
			if  len(aLotes) == 1 .and. lLotImp
				
				//Monta query                                                         				
				cSQL := " SELECT BMR_ANOLOT, BMR_MESLOT, BMR_CODLAN, BMR_VLRPAG, R_E_C_N_O_ AS BMR_RECNO"
				cSQL += "  FROM " + RetSQLName("BMR")
				cSQL += "  WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
				cSQL += "    AND BMR_CODRDA = '" + BAU->BAU_CODIGO + "' "
				cSQL += "    AND BMR_ANOLOT = '" + cAno    + "' "
				cSQL += "    AND BMR_MESLOT = '" + cMes    + "' "
				if ! empty(cLotBMR)
					cSQL += "    AND BMR_NUMLOT IN (" + cLotBMR + ") "
				endIf
				cSQL += "    AND BMR_CODLAN IN ('183','193','195','197','199') "
				cSQL += "    AND D_E_L_E_T_ = ' ' "
				cSQL += " ORDER BY BMR_ANOLOT, BMR_MESLOT ,R_E_C_N_O_ "
				
				//Executa query                                                       				
				PLSQUERY(cSQL,"Trb")
				
				
				//Processa arquivo de trabalho                                        				
				while ! Trb->(eof())
					Do Case
						Case TRB->BMR_CODLAN == "183" ; nINSSPJ  += Trb->BMR_VLRPAG ; lInssUnic := .T.  // inss PF
						Case TRB->BMR_CODLAN == "193" ; nINSSPF  += Trb->BMR_VLRPAG  // inss PF
						Case TRB->BMR_CODLAN == "195" ; nINSSPJ  += Trb->BMR_VLRPAG  // inss PJ
						Case TRB->BMR_CODLAN == "197" ; nINSSPF  += Trb->BMR_VLRPAG  // inss PJ filantropico
						Case TRB->BMR_CODLAN == "199" ; nIR      += Trb->BMR_VLRPAG  // ir
						Case TRB->BMR_CODLAN == "179" ; nPINSSPJ += TRB->BMR_VLRPAG  // Prov INSS PJ
						Case TRB->BMR_CODLAN == "180" ; nPINSSPF += TRB->BMR_VLRPAG  // Prov INSS PF
						Case TRB->BMR_CODLAN == "181" ; nCrPINSS += TRB->BMR_VLRPAG  // Cred Prov INSS
					EndCase
					Trb->(dbSkip())
				endDo
				Trb->(dbCloseArea())
			endIf
			
			//apenas para pegar o tamanho deste campo			
			cValor := transform(0,pMoeda2)
			
			//Monta resumo                                                             			
			if  nIss > 0 .or. nBIss > 0
				aadd(aTabRes,{"ISS"    ,space(len(cValor)),transform(nIss   ,pMoeda2),transform(nBIss   ,pMoeda2),""})
			endIf
			if  nPis > 0 .or. nBPis > 0
				aadd(aTabRes,{"PIS"    ,space(len(cValor)),transform(nPis   ,pMoeda2),transform(nBPis   ,pMoeda2),""})
			endIf
			if  nCofins > 0 .or. nBCofins > 0
				aadd(aTabRes,{"COFINS" ,space(len(cValor)),transform(nCofins,pMoeda2),transform(nBCofins,pMoeda2),""})
			endIf
			if  nCSLL   > 0 .or. nBCSLL > 0
				aadd(aTabRes,{"CSLL"   ,space(len(cValor)),transform(nCSLL  ,pMoeda2),transform(nBCSLL  ,pMoeda2),""})
			endIf
			if  nPINSSPF > 0
				aadd(aTabRes,{"Prov INSS PF",space(len(cValor)),transform(nPINSSPF,pMoeda2),transform(nBINSSPF,pMoeda2),""})
			endIf
			if  nPINSSPJ > 0
				aadd(aTabRes,{"Prov INSS PJ",space(len(cValor)),transform(nPINSSPJ,pMoeda2),transform(nBINSSPJ,pMoeda2),""})
			endIf
			if  nINSSPF > 0 .or. nBINSSPF > 0
				aadd(aTabRes,{"INSS PF",space(len(cValor)),transform(nINSSPF,pMoeda2),transform(nBINSSPF,pMoeda2),""})
			endIf
			if  nINSSPJ > 0 .or. nBINSSPJ > 0
				if  lInssUnic
					aadd(aTabRes,{"INSS"   ,space(len(cValor)),transform(nINSSPJ,pMoeda2),transform(nBINSSPJ,pMoeda2),""})
				Else
					aadd(aTabRes,{"INSS PJ",space(len(cValor)),transform(nINSSPJ,pMoeda2),transform(nBINSSPJ,pMoeda2),""})
				endIf
			endIf
			if  nINSSJF > 0 .or. nBINSSJF > 0
				aadd(aTabRes,{"INSS JF",space(len(cValor)),transform(nINSSJF,pMoeda2),transform(nBINSSJF,pMoeda2),""})
			endIf
			if  nIR > 0 .or. nBIR > 0
				aadd(aTabRes,{"I.R"    ,space(len(cValor)),transform(nIR    ,pMoeda2),transform(nBIR    ,pMoeda2),cDepIr})
			endIf
			if  nCrPINSS > 0
				aadd(aTabRes,{"Cred Prov INSS",transform(nCrPINSS,pMoeda2),space(len(cValor)),space(len(cValor)),""})
			endIf
			nVlrTot := nVlrPag + nCreTot - nDebTot - nIss - nPis - nCofins - nCSLL - nINSSPF - nINSSPJ - nINSSJF - nIR - nPINSSPF - nPINSSPJ + nCrPINSS
			if  nVlrTot > 0
				cValor := transform(nVlrTot,pMoeda2)
				aadd(aTabRes,{"Total Liquido",cValor,space(len(cValor)),space(len(cValor)),""})
			Else
				cValor := transform(nVlrTot * -1,pMoeda2)
				aadd(aTabRes,{"Total Liquido",space(len(cValor)),cValor,space(len(cValor)),""})
			endIf
			
			//Monta cabecalho                                                          			
			cCabec1 := "Tipo Debito/Credito           Descricao                                   Credito         Debito"
			cCabec2 := ""

			R018Res_Prod(aResProd)
			R018DC(cOpeLot,cNumLot,.F.,!lLisRes,aNumLot,cAno,cMes,cCodOpe)

			nDebTot := ntDebFix + ntDebVar + ntDebApo
			nCreTot := nVlrPag + ntCreFix + ntCreVar + ntCreApo

			cLinha  := Padr("Total Debitos/Creditos",65,".") + ": " + transform(nCreTot,pMoeda2) + " "  + transform(nDebTot,pMoeda2)

			R018Linha(cLinha,2,0)
			R018Res()
			
			//Mensagens de Extrato                                                     			
			aMsgExt := PLSEXTPRE(BAU->BAU_CODIGO,cCodOpe,cAno,cMes,BAU->BAU_COPCRE)

  			If  Len(aMsgExt) > 0
	 			R018Linha("",1,1,,{{"MENSAGENS DE EXTRATO",1270}})

   				For nFor := 1 To Len(aMsgExt)
	   		  		R018Linha("",1,0,,{{PadC(&(AllTrim(aMsgExt[nFor])), 70),900}})
   		   		Next

				R018Linha("",1,0,.t.)
			EndIf

	next

	TrbBAU->(dbSkip())
endDo

//Fecha arquivo de trabalho                                          
TrbBAU->(DbCloseArea())

//Visualiza impressao grafica antes de imprimir
if lRet
	oPrint:preview()
endIf

//Fim do Relat¢rio                                                         
return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} R018DC
Imprime outros debitos/creditos

@author  PLS TEAM03.02.13
@version P12
@since   03.02.13
/*/
//-------------------------------------------------------------------
static function R018DC(cOpeLot,cNumLot,lSoma,lLisRes,aNumLot,cAno,cMes,cCodOpe)
LOCAL cTit 		:= "Debitos/Creditos Fixos:       "
LOCAL nCont 	:= 0
LOCAL cValor	:= 0
DEFAULT cOpeLot := ""
DEFAULT cNumLot := ""
DEFAULT lSoma   := .T.
DEFAULT aNumLot := {}

nDebFix := 0
nCreFix := 0
nCreVar := 0
nDebVar := 0
nCreApo := 0
nDebApo := 0
lTem 	:= .F.

//Lista debitos/creditos fixos                                             
BGQ->(dbSetOrder(2))
if  BGQ->(msSeek(xFilial("BGQ")+BAU->BAU_CODIGO+cAno+cMes+cCodOpe))

	while ! BGQ->(eof()) .And. BGQ->(BGQ_FILIAL+BGQ_CODIGO+BGQ_ANO+BGQ_MES+BGQ_CODOPE) == xFilial("BGQ")+cCodRdaAnt+cAno+cMes+cCodOpe

		if  ! empty(cOpeLot+cNumLot) .And. BGQ->(BGQ_OPELOT+BGQ_NUMLOT) <> cOpeLot+cNumLot
			BGQ->(dbSkip())
			Loop
		endIf

		if  alltrim(BGQ->BGQ_NUMLAU) <> "BBC"
			BGQ->(dbSkip())
			Loop
		endIf

		BBB->(dbSetOrder(1))
		BBB->(msSeek(xFilial("BBB")+BGQ->BGQ_CODLAN))
		
		//lAnalitico		
		if  lLisRes
			cValor := transform(BGQ->BGQ_VALOR,pMoeda2)

			if  lLisRes
				cLinha := cTit + Padr(BGQ->BGQ_CODLAN + "-" + alltrim(BBB->BBB_DESCRI),nTamDes,".") + ": " + space(len(cValor)) + " " + cValor + " " + If(alltrim(BGQ->BGQ_NUMLAU) <> "BBC",substr(BGQ->BGQ_OBS,1,35),"")
				R018Linha(cLinha,1,0)
			Else
				if  BGQ->BGQ_TIPO == "2"
					if  lLisRes
						cLinha := cTit + Padr(BGQ->BGQ_CODLAN + "-" + alltrim(BBB->BBB_DESCRI),nTamDes,".") + ": " + cValor + " " + space(len(cValor)) + " " + If(alltrim(BGQ->BGQ_NUMLAU) <> "BBC",substr(BGQ->BGQ_OBS,1,35),"")
						R018Linha(cLinha,1,0)
					endIf
				endIf
				cTit := space(30)
			endIf

			if  BGQ->BGQ_TIPO == "1"
				nDebFix += BGQ->BGQ_VALOR
			Else
				if  BGQ->BGQ_TIPO == "2"
					nCreFix += BGQ->BGQ_VALOR
				endIf
			endIf

			lTem := .T.
		endIf

	BGQ->(dbSkip())
	endDo

endIf

if  lLisRes
	cLinha := cTit + Padr("Total Debitos/Creditos Fixos",nTamDes,".") + ": " + ;
			  transform(nCreFix,pMoeda2) + " " + ;
			  transform(nDebFix,pMoeda2)
	R018Linha(cLinha,1,0)
endIf

cTit := "Debitos/Creditos Variaveis:   "
lTem := .F.

cSQL := " SELECT BGQ_FILIAL, BGQ_OPELOT, BGQ_NUMLOT, BGQ_CODIGO, BGQ_ANO, BGQ_MES, BGQ_CODOPE, BGQ_VALOR, "
cSQL += " BGQ_CODLAN, BGQ_NUMLAU, BGQ_OBS, BGQ_TIPO FROM " + RetSQLName("BGQ")
cSQL += " WHERE BGQ_FILIAL =  '" + xFilial("BGQ") + "' "
cSQL += "   AND BGQ_CODIGO =  '" + BAU->BAU_CODIGO + "' "
cSQL += "   AND ( (BGQ_ANO =  '" + cAno          + "' "
cSQL += "   AND   BGQ_MES  =  '" + cMes          + "') "

if len (aNumLot) > 0
    cSQL += "   OR BGQ_NUMLOT IN ( "
	
	//Verifica lotes ja processados	
    for nCont := 1 to len(aNumLot)
        cSQL += "'" + aNumLot[nCont][1] + " ' "
    	if nCont <> len(aNumLot)
        	cSQL += ","
     	endIf
    next
    cSQL += " ) ) "
Else
    cSQL += " ) "
endif
cSQL += " AND D_E_L_E_T_ = ' ' "

PLSQUERY(cSQL,"DebCre")
while !DebCre->( eof() )

        if  ! empty(cOpeLot+cNumLot) .And. DebCre->(BGQ_OPELOT+BGQ_NUMLOT) <> cOpeLot+cNumLot
			DebCre->(dbSkip())
			Loop
		endIf

		if  alltrim(DebCre->BGQ_NUMLAU) == "BBC"
			DebCre->(dbSkip())
			Loop
		endIf

		if  empty(DebCre->BGQ_NUMLOT)
			DebCre->(dbSkip())
			Loop
		endIf

		BBB->(dbSetOrder(1))
		BBB->(msSeek(xFilial("BBB")+DebCre->BGQ_CODLAN))
		
		//lAnalitico		
		if  lLisRes

			cValor := transform(DebCre->BGQ_VALOR,pMoeda2)
			if  DebCre->BGQ_TIPO == "1"
				if  lLisRes
					cLinha := cTit + Padr(DebCre->BGQ_CODLAN + "-" + alltrim(BBB->BBB_DESCRI),nTamDes,".") + ": " + space(len(cValor)) + " " + cValor + " " + If(alltrim(DebCre->BGQ_NUMLAU) <> "BBC",substr(DebCre->BGQ_OBS,1,35),"")
					R018Linha(cLinha,1,0)
				endIf
			Else
				if  DebCre->BGQ_TIPO == "2"
					if  lLisRes
						cLinha := cTit + Padr(DebCre->BGQ_CODLAN + "-" + alltrim(BBB->BBB_DESCRI),nTamDes,".") + ": " + ;
								  cValor + " " + space(len(cValor)) + " " + If(alltrim(DebCre->BGQ_NUMLAU) <> "BBC",substr(DebCre->BGQ_OBS,1,35),"")
						R018Linha(cLinha,1,0)
					endIf
				endIf
			endIf
			cTit := space(30)
		endIf

		if  DebCre->BGQ_TIPO == "1"
			nDebVar += DebCre->BGQ_VALOR
		Else
			if  DebCre->BGQ_TIPO == "2"
				nCreVar += DebCre->BGQ_VALOR
			endIf
		endIf
		lTem := .T.

	DebCre->(dbSkip())
endDo
DebCre->( DbCloseArea() )

if  lLisRes
	cLinha := 	cTit + Padr("Total Debitos/Creditos variaveis",nTamDes,".") + ": " + ;
				transform(nCreVar,pMoeda2) + " " + ;
				transform(nDebVar,pMoeda2)
				R018Linha(cLinha,1,0)
endIf

cTit := "Apontamentos da Producao:     "
lTem := .F.
BCE->(dbSetOrder(2))
if  BCE->(msSeek(xFilial("BGQ")+cCodRdaAnt+cCodOpe+cAno+cMes))
	while ! BCE->(eof()) .And. BCE->(BCE_FILIAL+BCE_CODIGO+BCE_CODINT+BCE_ANOPAG+BCE_MESPAG) == xFilial("BGQ")+cCodRdaAnt+cCodOpe+cAno+cMes

	    if ! empty(cOpeLot+cNumLot) .And. BCE->(BCE_OPELOT+BCE_NUMLOT) <> cOpeLot+cNumLot
	        BCE->(dbSkip())
	        Loop
	    endIf
		
		//lAnalitico		
		if  lLisRes
			BBB->(dbSetOrder(1))
			BBB->(msSeek(xFilial("BBB")+BCE->BCE_CODPAG))
			cValor := transform(BCE->BCE_VLRAPT,pMoeda2)
			if  lLisRes
				cLinha := cTit + Padr(BCE->BCE_CODPAG + "-" + alltrim(BBB->BBB_DESCRI),nTamDes,".") + ": " + space(len(transform(BCE->BCE_VLRAPT,pMoeda2))) + " " + transform(BCE->BCE_VLRAPT,pMoeda2)
				R018Linha(cLinha,1,0)
			endIf
			cTit := space(30)
		endIf
		nCreApo += BCE->BCE_VLRAPT
		lTem := .T.
	BCE->(dbSkip())
	endDo
endIf

if  lLisRes
	cLinha := cTit + Padr("Total Apontamentos da Producao",nTamDes,".") + ": " + ;
			  transform(nCreApo,pMoeda2) + " " + ;
			  transform(nDebApo,pMoeda2)
	R018Linha(cLinha,1,0)
endIf

if  lSoma
	ntDebFix += nDebFix
	ntCreFix += nCreFix
	ntCreVar += nCreVar
	ntDebVar += nDebVar
	ntCreApo += nCreApo
	ntDebApo += nDebApo
endIf

return()


//-------------------------------------------------------------------
/*/{Protheus.doc} R018Res
Imprime resumo dos totais

@author  PLS TEAM
@version P12
@since   03.02.13
/*/
//-------------------------------------------------------------------
static function R018Res()
LOCAL cTit := ""
LOCAL nI   := 0

//Lista cabecalho                                                          
R018Linha("",1,0,.t.)

cLinha := "Resumo do Pagamento           Descricao                                   Credito         Debito           Base"
R018Linha(cLinha,1,0)

cLinha := "                              ------------------------------------        -------         ------           ----"
R018Linha(cLinha,1,0)

//Imprime resumo                                                           
cTit := "                              "
if  len(aTabRes) > 0
	for nI := 1 to len(aTabRes)
		cLinha 	:= cTit + Padr(aTabRes[nI,1],nTamDes,".") + ": " + aTabRes[nI,2] + " " + aTabRes[nI,3] + " " + aTabRes[nI,4] + " " + aTabRes[nI,5]
		R018Linha(cLinha,1,0)
		cTit 	:= space(30)
	next
endIf
R018Linha("",1,0,.t.)

return()


//-------------------------------------------------------------------
/*/{Protheus.doc} R018Res_Prod
Imprime resumo da producao

@author  PLS TEAM
@version P12
@since   03.02.13
/*/
//-------------------------------------------------------------------
static function R018Res_Prod(aRes)
LOCAL nX 	  := 0
LOCAL aTitulo := {  "Custo Operacional Pessoa Fisica",;
					"Custo Operacional Pessoa Juridica",;
					"Pre-Pagamento Pessoa Fisica",;
					"Pre-Pagamento Pessoa Juridica",;
					"Intercambio",;
					"Outros",;
					"Glosas" }

//Lista cabecalho                                                          
cTit 	:= "Producao:"+Space(21)
nTotal  := 0

for nX := 1 to len(aRes)
	if  aRes[nX] > 0
		cLinha := cTit + Padr(aTitulo[nX],nTamDes,".") + ": " + transform(aRes[nX],pMoeda2)
		R018Linha(cLinha,1,0)
		cTit := space(30)
		if  nX < 7
			nTotal += aRes[nX]
		endIf
	endIf
next

cLinha := cTit + Padr("Total da Producao",nTamDes,".") + ": " + transform(nTotal,pMoeda2)
R018Linha(cLinha,1,1)
return


//-------------------------------------------------------------------
/*/{Protheus.doc} R018Linha
Imprime linha de detalhe

@author  PLS TEAM
@version P12
@since   03.02.13
/*/
//-------------------------------------------------------------------
static function R018Linha(cLinha,nAntes,nApos,lLine,aLinDetal)
LOCAL nI 		:= 0
LOCAL nColAux   := 0
LOCAL nLinMax 	:= 2300
LOCAL nColMax	:= 1000
LOCAL nColIni	:= 20
LOCAL nLinCon	:= 10
LOCAL nColCon	:= 10
LOCAL oFnt10C		:= TFont():New("Lucida Console"		,,12,,.f.,,,,,.F.,.F.)
LOCAL oFnt14N		:= TFont():New("Arial"				,,18,,.T.,,,,,.F.,.F.)
DEFAULT aLinDetal   := {}

//Pagina inicial
if nLinIni == 0
	oPrint:startPage()
endIf

//Salta linhas antes                                                       
for nI := 1 to nAntes
	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
next

//Imprime cabecalho                                                        
if  nLinIni == 50

		nTop		:= 35
		nLeft		:= 40
		nTweb		:= 2.9
		nLweb		:= 10

		aBMP:={"lgrl.bmp"}
		If File("lgrl" + FWGrpCompany() + FWCodFil() + ".bmp")
			aBMP := { "lgrl" + FWGrpCompany() + FWCodFil() + ".bmp" }
		ElseIf File("lgrl" + FWGrpCompany() + ".bmp")
			aBMP := { "lgrl" + FWGrpCompany() + ".bmp" }
		EndIf
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
		oPrint:SayBitmap(nTop/nTweb, nLeft/nTweb, aBMP[1], 400/nTweb, 123/nTweb)


		cMsg := "Relatorio de Extrato de Pagamento"
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
		oPrint:Say( nLinIni + nLinCon, (nLeft + 1000), cMsg, oFnt14N)


		cMsg := "Data: "+dToc(dDataBase)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
		oPrint:Say( nLinIni + nLinCon, nColIni + nColCon, cMsg, oFnt10c)

		cMsg := "Hora: "+time()
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
		oPrint:Say( nLinIni + nLinCon, nColIni + nColCon, cMsg, oFnt10c)

		cMsg := "Prestador: "+BAU->BAU_CODIGO+" - "+BAU->BAU_NOME+""
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
		oPrint:Say( nLinIni + nLinCon, nColIni + nColCon, cMsg, oFnt10c)

		if !empty(cNmT)
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
			cMsg := "Nro Nota: "+cNmT
			oPrint:Say( nLinIni + nLinCon, nColIni + nColCon, cMsg, oFnt10c)
		endif

		if !empty(dVencRea)
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
			cMsg := "Vencimento: "+dtoc(dVencRea)
			oPrint:Say(nLinIni + nLinCon, nColIni + nColCon, cMsg, oFnt10c)
		endif

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
		cMsg := "Pagina: "+alltrim(str(nPag))+""
		oPrint:Say( nLinIni + nLinCon, nColIni + nColCon, cMsg, oFnt10c)

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
		oPrint:line(nLinIni, nColIni, nLinIni, nColMax*3)

		nPag++

		//Nota     Data     Matricula             Nome Usuario               T.S Servico Qt.Serv   Qt.Ch.    Vl.Pgto    Tot.Nota"

		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)

		nColAux := nColIni + nColCon
		oPrint:Say( nLinIni + nLinCon, nColAux, "Tp. Guia", oFnt10c)//30

		nColAux +=  __NTAM1*16
		oPrint:Say( nLinIni + nLinCon, nColAux, "Matricula", oFnt10c)//190

		nColAux += __NTAM2*16.2
		oPrint:Say( nLinIni + nLinCon, nColAux, "Nome do Beneficiario", oFnt10c)//595

		nColAux += __NTAM3*15.5
		oPrint:Say( nLinIni + nLinCon, nColAux, "Data ", oFnt10c)//1215

		nColAux += __NTAM4*16
		oPrint:Say( nLinIni + nLinCon, nColAux, "Num Guia", oFnt10c)//1375

		nColAux += __NTAM5*16
		oPrint:Say( nLinIni + nLinCon, nColAux, "Codigo", oFnt10c)//1695

		nColAux += __NTAM6*17
		oPrint:Say( nLinIni + nLinCon, nColAux, "Qtd", oFnt10c)//1865

		nColAux += __NTAM7*20
		oPrint:Say( nLinIni + nLinCon, nColAux, "Vlr Apres", oFnt10c)//1965

		nColAux += __NTAM8*16.33333
		oPrint:Say( nLinIni + nLinCon, nColAux, "Vlr Glosa", oFnt10c)//2210

		nColAux += __NTAM9*16.66
		oPrint:Say( nLinIni + nLinCon, nColAux, "Vlr Pagto", oFnt10c)//2460


		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
		oPrint:line(nLinIni, nColIni, nLinIni, nColMax*3)
		fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
endif

//Imprime linha de detalhe                                                 
if !empty(cLinha)
	oPrint:say(nLinIni + nLinCon, nColIni + nColCon, cLinha, oFnt10c)
endIf

//Imprime linha de detalhe - Com Array permite definir a coluna            
if len(aLinDetal) > 0
	For nI := 1 to len(aLinDetal)
    	oPrint:say(nLinIni + nLinCon, aLinDetal[nI][2], aLinDetal[nI][1], oFnt10c)
	Next
EndIf

//Imprime uma linha
if lLine
	oPrint:line(nLinIni, nColIni, nLinIni, nColMax*3)
endIf

//Salta linhas apos                                                        
for nI := 1 to nApos
	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50)
next

//Fim da funcao                                                            
return()


//-------------------------------------------------------------------
/*/{Protheus.doc} fSomaLin
Soma Linha

@author  PLS TEAM
@version P12
@since   14.01.13
/*/
//-------------------------------------------------------------------
static function fSomaLin(nLinMax, nColMax, nLinIni, nColIni, nValor, nDefault)
                
nLinIni += nValor

if nLinIni + 94 > nLinMax
	nLinIni := 50
	oPrint:endPage()
	oPrint:startPage()
	
	//Box Principal                                                 
	oPrint:Box(nLinIni + 0010, nColIni + 0000, nLinMax, nColIni + nColMax)
endIf

//Fim da rotina
return(nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} fLogoEmp
Logo

@author  PLS TEAM
@version P12
@since   14.01.13
/*/
//-------------------------------------------------------------------
static function fLogoEmp(cLogoEmp)
LOCAL lRet := .t.

//verifica se o img existe
if !empty(cLogoEmp) .and. !file(cLogoEmp)
	//cLogoGH := ''
endIf

if empty(cLogoEmp)
	lRet := .f.
endIf

//Fim da rotina
return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPRPLAN
Produção do prestador em planilha

@author  PLS TEAM
@version P12
@since   28.01.13
/*/
//-------------------------------------------------------------------
Function PLSPRPLAN(cCodRda,cAnoW,cMesW,lWeb,cPathW,cNmTitPg,cAliasP)
LOCAL cTitulo   := ""
LOCAL cCampos   := GetNewPar("MV_PLSCPP1","BD7_CODRDA, BD7_NUMLOTE, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_SEQUEN, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG,BD7_CODPAD, BD7_CODPRO")
LOCAL cCampos2  := GetNewPar("MV_PLSCPP2","BD7_NUMIMP,BD7_VLRPAG,BD7_CODUNM,BD7_DATPRO,BD7_TIPUSR,BD7_ITERC,BD7_TIPGUI,BD7_ANOPAG,BD7_MESPAG")
LOCAL cCampos3  := GetNewPar("MV_PLSCPP3","")
LOCAL cCamBD61  := GetNewPar("MV_PBD6CP1","")
LOCAL aCampos   := {}
LOCAL	aCamposBD6	:= {}
LOCAL aCpoDC	:= {{"Titulo","C"},{"Lote","C"},{"Mes/Ano","C"},{"Tipo","C"},{"Lançamento","C"},{"Valor","N"}}
LOCAL aCpoMens	:= {{"Mensagens de Extrato","C"}}
LOCAL aCpoImp	:= {}
LOCAL aLinha    := {}
LOCAL cPerg		:= "PLSRELDPM"
LOCAL cCodOpe   := ""
LOCAL cRdaDe    := ""
LOCAL cRdaAte   := ""
LOCAL cAno      := ""
LOCAL cMes      := ""
LOCAL nX1		:= 0
LOCAL nX2		:= 0
LOCAL cMsg		:= ""
LOCAL cFileName	:= lower("PLSRELPLAN" + criaTrab(nil,.f.) + "_" + cCodRda)
LOCAL cPathSrv 	:= lower(getMV("MV_RELT"))
LOCAL nTamPEG	:= TamSx3("BCI_CODPEG")[1]
LOCAL aDados	:= {}
LOCAL lContinua	:= .t.
LOCAL lFound		:= .f.
LOCAL cNmLotPg  := ""
LOCAL cRdaLote  := ""
LOCAL cSql 		:= ""
LOCAL cChaveBD7	:= ""
LOCAL aBD7		:= {}
LOCAL aBGQ		:= {}
LOCAL aBCE		:= {}
LOCAL aMsgExt   := {}
LOCAL aAreaBAU  := {}
LOCAL cPegDe
LOCAL cPegAte
LOCAL nDeb
LOCAL nCred
LOCAL cCHBMR
LOCAL nBIss     := 0
LOCAL nIss      := 0
LOCAL nBPis     := 0
LOCAL nPis      := 0
LOCAL nBCofins  := 0
LOCAL nCofins   := 0
LOCAL nBIR      := 0
LOCAL nIR       := 0
LOCAL nBCSLL    := 0
LOCAL nCSLL     := 0
LOCAL nBINSSPF  := 0
LOCAL nINSSPF   := 0
LOCAL nBINSSPJ  := 0
LOCAL nINSSPJ   := 0
LOCAL nBINSSJF  := 0
LOCAL nINSSJF   := 0
LOCAL nPINSSPJ  := 0
LOCAL nPINSSPF  := 0
LOCAL nCrPINSS  := 0
LOCAL nValTit	:= 0
LOCAL nValLiq	:= 0

PRIVATE oExcel	:= nil
DEFAULT lWeb	:= .f.
DEFAULT cCodRda	:= ""
DEFAULT cAnoW	:= ""
DEFAULT cMesW	:= ""
DEFAULT cPathW	:= ""
DEFAULT cNmTitPg := ""
DEFAULT cAliasP := "SE2"

//Somente se nao for web
if !lWeb
	
	//Acessa parametros do relatorio...	
	if !pergunte(cPerg,.T.)
		return
	endIf
	
	//dados do pergunte	
	cCodOpe   := mv_par01
	cRdaDe    := mv_par02
	cRdaAte   := mv_par03
	cAno      := mv_par04
	cMes      := mv_par05
	cPEGDe    := mv_par06
	cPEGAte   := mv_par07
	cTitulo   := "Produção Rede de Atendimento"
else
	cCodOpe   := plsintpad()
	cRdaDe    := cCodRda
	cRdaAte   := cCodRda
	cAno      := cAnoW
	cMes      := cMesW
	cPEGDe    := space(nTamPEG)
	cPEGAte   := replicate("Z",nTamPEG)
	cPathSrv  := cPathW
	cTitulo   := "Produção Rede de Atendimento"
endIf

DBSELECTAREA("SE2")
// Variaveis para buscar o BMR pelo numero do titulo.
If !Empty(cNmTitPg)
    If cAliasP == "SE2"
	SE2->(dbSetorder(01))
	If SE2->(dbSeek(xFilial("SE2")+cNmTitPg))
		cCodOpe  := SE2->E2_PLOPELT
		cNmLotPg := Subs(SE2->E2_PLLOTE,7,4)
		cRdaLote := SE2->E2_CODRDA

		cAnoW := SE2->E2_ANOBASE
		cMesW := SE2->E2_MESBASE
   	   cAno  := cAnoW
  	   cMes  := cMesW

			cPrefixo := SE2->E2_PREFIXO
			cNum	 := SE2->E2_NUM
			cParcela := SE2->E2_PARCELA
			cTipoTit := SE2->E2_TIPO
			cFornece := SE2->E2_FORNECE
			cLoja	 := SE2->E2_LOJA

			lAcheiSE2 := .T.
	Endif
	Else
		SC7->(DbSetOrder(1))
		If SC7->(MsSeek(xFilial("SC7")+cNmTitPg))

			cCodOpe  := SC7->C7_PLOPELT
			cNmLotPg := Substr(SC7->C7_LOTPLS,7,4)
			cRdaLote := SC7->C7_CODRDA

			cAno := Substr(SC7->C7_LOTPLS,1,4)
			cMes := Substr(SC7->C7_LOTPLS,5,2)

		EndIf

	EndIf

Endif

// BAU - Redes de Atendimento
BAU->(dbSetOrder(1))
BAU->(msSeek(xFilial("BAU")+cRdaLote))
cBAUCalImp	:= BAU->BAU_CALIMP
aDados := {}
cSQL := "SELECT BMR_ANOLOT, BMR_CODLAN, BMR_CODRDA, BMR_DEBCRE, BMR_FILIAL, BMR_MESLOT, BMR_NUMLOT, BMR_OPELOT, BMR_OPERDA, BMR_VLRPAG"
cSQL += "  FROM " + RetSqlName("BMR")

/*Se o cAliasP for SE2 pode ser:
 	a) Gera pagamento pelo financeiro; ou
	b) Gera pegamento por pedido de compras e ja foi dada entrada na NF
 Se o cAliasP for SC7, usa pedido de compras mas ainda nao deu entrada na NF
*/
If cAliasP == "SE2" .And. lAcheiSE2
	cSQL += " INNER JOIN " + RetSqlName("SE2") + " SE2 "
	cSQL += "    ON E2_FILIAL  = '"+xFilial("SE2")+"' "
	cSQL += "   AND E2_PREFIXO = '"+cPrefixo+"' "
	cSQL += "   AND E2_NUM 	   = '"+cNum+"' "
	cSQL += "   AND E2_PARCELA = '"+cParcela+"' "
	cSQL += "   AND E2_TIPO    = '"+cTipoTit+"' "
	cSQL += "   AND E2_FORNECE = '"+cFornece+"' "
	cSQL += "   AND E2_LOJA	   = '"+cLoja+"' "

	If	cBAUCalImp <>  '1'
		cSQL += "   AND E2_PLOPELT = BMR_OPELOT "
		cSQL += "   AND E2_PLLOTE  = BMR_ANOLOT || BMR_MESLOT || BMR_NUMLOT "
	EndIf
	cSQL += "   AND E2_CODRDA  = BMR_CODRDA "
	cSQL += "   AND SE2.D_E_L_E_T_ = ' ' "

	//Se gera pedido de compras, so vai ter o titulo quando ja tiver sido dado entrada no Documento de Entrada
	iF cBAUCalImp ==  '1'

		cSQL += "	 INNER JOIN " + RetSqlName("SD1") + " SD1 "
		cSQL += "	    ON D1_FILIAL  = E2_FILORIG "
		cSQL += "	   AND D1_DOC 	  = E2_NUM "
		cSQL += "	   AND D1_FORNECE = E2_FORNECE  "
		cSQL += "	   AND D1_LOJA 	  = E2_LOJA "
		cSQL += "	   AND D1_DTDIGIT = SE2.E2_EMIS1 "
		cSQL += "	   AND SD1.D_E_L_E_T_ = ' '"

		cSQL += "	 INNER JOIN " + RetSqlName("SC7") + " SC7 "
		cSQL += "	    ON C7_FILIAL  = D1_FILIAL "
		cSQL += "	   AND C7_NUM     = D1_PEDIDO "
		cSQL += "	   AND C7_ITEM	  = D1_ITEMPC "
		cSQL += "	   AND C7_PLOPELT = BMR_OPELOT "
		cSQL += "	   AND C7_LOTPLS  = BMR_ANOLOT || BMR_MESLOT || BMR_NUMLOT "
		cSQL += "	   AND C7_CODRDA  = BMR_CODRDA "
		cSQL += "	   AND SC7.D_E_L_E_T_ = ' ' "

	EndIf
Else
	iF !Empty(cNmTitPg)
		cSQL += " INNER JOIN " + RetSqlName("SC7") + " SC7 "
		cSQL += "    ON C7_FILIAL = '"+xFilial("SC7")+"' "
		cSQL += "   AND C7_NUM    = '"+cNmTitPg+"'
		cSQL += "   AND C7_PLOPELT = BMR_OPELOT
		cSQL += "   AND C7_LOTPLS  = BMR_ANOLOT || BMR_MESLOT || BMR_NUMLOT
		cSQL += "   AND C7_CODRDA  = BMR_CODRDA
		cSQL += "   AND SC7.D_E_L_E_T_ = ' '
	EndIf
EndIf

cSQL += " WHERE BMR_FILIAL = '" + xFilial("BMR") + "' AND "
cSQL += "  BMR_OPELOT = '" + cCodOpe + "' AND "
If !Empty(cNmLotPg)
	cSQL += "BMR_CODRDA = '" + cRdaLote + "' AND "
	//Se usa pedido de compras nao posso filtrar pelo lote na BMR, pois um titulo/pedido pode ter mais de um lote
	iF cBAUCalImp <> '1'
	cSQL += "BMR_NUMLOT = '" + cNmLotPg + "' AND "
	EndIf
Else
	cSQL += "( BMR_CODRDA >= '" + cRdaDe + "' AND BMR_CODRDA <= '" + cRdaAte + "' ) AND "

Endif

cSQL += " BMR_ANOLOT = '" + cAno + "' AND "
cSQL += " BMR_MESLOT = '" + cMes + "' AND "
cSql += RetSQLName("BMR")+".D_E_L_E_T_ = ' '"
cSQL += " ORDER BY BMR_FILIAL, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT, BMR_OPERDA, BMR_CODRDA, BMR_CODLAN "

cSQL := ChangeQuery(cSQL)
PlsQuery(cSQL,"TrbBMR")

//verifica se foi encontrado conteudo
if TrbBMR->(Eof())
	if !lWeb
		msgAlert("Não foram encontrados dados para os parâmetros informados!")
	else
		cMsg := "Não foram encontrados dados para os parâmetros informados!"
	endIf
	lContinua := .f.

	TrbBMR->(dbCloseArea())
endIf

//se existe dados ou nao
If lContinua
	BA0->(dbSetOrder(1))
	BA0->(msSeek(xFilial("BA0")+TrbBMR->(BMR_OPERDA)))
   	
	//Define o obj	
	oExcel := FWMSEXCEL():New()
    
	//Define titulo da planilha...	
	oExcel:AddworkSheet("Produção")
	
	//Imprime todas as colunas determinadas no MV - BD6	
   oExcel:AddTable("Produção","Produção")

		aBD7		:= {}
		aBGQ		:= {}
		aBCE		:= {}
	While ! TrbBMR->(Eof())

		// Posiciona o SE2 pois será necessário.
		If Empty(cNmTitPg) .and. Empty(cNmLotPg) .And. !lAcheiSE2
			cSQL := " SELECT R_E_C_N_O_  AS E2_RECNO,E2_VENCTO,E2_FORNECE,E2_LOJA "
			cSQL += "  FROM " + RetSQLName("SE2")
			cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
			cSQL += "    AND E2_PLOPELT = '" + TrbBMR->BMR_OPELOT + "'"
			cSQL += "    AND E2_PLLOTE = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
			cSQL += "    AND E2_CODRDA = '" + TrbBMR->BMR_CODRDA + "'"
			cSQL += "    AND D_E_L_E_T_ = ' ' "
			PlsQuery(cSQL,"TrbSE2")

			If ! TrbSE2->(Eof())
				SE2->(dbGoTo(TrbSE2->(E2_RECNO)))
			EndIf

			TrbSE2->(DbCloseArea())
		Endif

		// Valor do titulo.
		//Alterado pois Valor do SE2 já é com os Descontos de Impostos
		//nValTit := SE2->E2_VALOR
		//nValTit:=TrbBMR->BMR_VLRPAG
		// Seleciona todos os bd7 envovidos
		cSQL := "SELECT R_E_C_N_O_ AS REC "
		cSQL += "  FROM " + RetSqlName("BD7")
		cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "'"
		cSQL += "   AND BD7_CODOPE = '" + cCodOpe + "' "
		cSQL += "   AND BD7_OPELOT = '" + TrbBMR->(BMR_OPELOT) + "'"
		cSQL += "   AND BD7_NUMLOT = '" + TrbBMR->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "'"
		cSQL += "   AND BD7_CODRDA = '" + TrbBMR->(BMR_CODRDA)+ "'"
		cSQL += "   AND D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY BD7_CODLDP,BD7_CODPEG"
		PlsQuery(cSQL,"TrbBD7")

		Do While !TrbBD7->(Eof())
			Aadd(aBD7, TrbBD7->REC )

			TrbBD7->(dbSkip())
		Enddo
		TrbBD7->(dbCloseArea())

		// Pega os debitos / creditos.
		nDeb :=0
		nCred:=0
		nImpostos := 0

		nBIss     := 0
		nIss      := 0
		nBPis     := 0
		nPis      := 0
		nBCofins  := 0
		nCofins   := 0
		nBIR      := 0
		nIR       := 0
		ntIR	  := 0
		nBCSLL    := 0
		nCSLL     := 0
		nBINSSPF  := 0
		nINSSPF   := 0
		nBINSSPJ  := 0
		nINSSPJ   := 0
		nBINSSJF  := 0
		nINSSJF   := 0
		nPINSSPJ  := 0
		nPINSSPF  := 0
		nCrPINSS  := 0
		ntBIss    := 0

		ntIss     := 0
		ntBPis    := 0
		ntPis     := 0
		ntBCofins := 0
		ntCofins  := 0
		ntBIR     := 0
		ntIR      := 0
		ntBCSLL   := 0
		ntCSLL    := 0
		ntBINSSPF := 0
		ntINSSPF  := 0
		ntBINSSPJ := 0
		ntINSSPJ  := 0
		ntBINSSJF := 0
		ntINSSJF  := 0
		ntPINSSPJ := 0
		ntPINSSPF := 0
		ntCrPINSS := 0
		lFirst    := .T.
		ntDebFix  := 0
		ntCreFix  := 0
		ntDebVar  := 0
		ntCreVar  := 0
		ntDebApo  := 0
		ntCreApo  := 0

		cChBMR := TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA)
		Do While ! TrbBMR->(Eof()) .And. TrbBMR->(BMR_FILIAL+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_OPERDA+BMR_CODRDA) == cChBMR
            
			//Alterado a verificacao do valor total pois preciso rodar todos os BMRs   			
	    	If TrbBMR->BMR_DEBCRE == "2"
				nValTit += TrbBMR->BMR_VLRPAG
			ElseIf TrbBMR->BMR_DEBCRE == "1" .And. !TrbBMR->BMR_CODLAN $ "182/183/184/185/186/187/188/189/190/191/192/193/194/195/196/197/198/199/179/180/181"
		  		nValTit := nValTit -  TrbBMR->BMR_VLRPAG
			EndIf

			If TrbBMR->BMR_CODLAN == "182"
				nBINSSPJ  += TrbBMR->BMR_VLRPAG
				ntBINSSPJ += TrbBMR->BMR_VLRPAG

			Elseif TrbBMR->BMR_CODLAN == "183"
				nINSSPJ   += TrbBMR->BMR_VLRPAG
				ntINSSPJ  += TrbBMR->BMR_VLRPAG

			Elseif TrbBMR->BMR_CODLAN == "184"
				nBIss     += TrbBMR->BMR_VLRPAG
				ntBIss    += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "185"
				nIss      += TrbBMR->BMR_VLRPAG
				ntIss     += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "186"
				nBPis     += TrbBMR->BMR_VLRPAG
				ntBPis    += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "187"
				nPis      += TrbBMR->BMR_VLRPAG
				ntPis     += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "188"
				nBCofins  += TrbBMR->BMR_VLRPAG
				ntBCofins += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "189"
				nCofins   += TrbBMR->BMR_VLRPAG
				ntCofins  += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "190"
				nBCSLL    += TrbBMR->BMR_VLRPAG
				ntBCSLL   += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "191"
				nCSLL     += TrbBMR->BMR_VLRPAG
				ntCSLL    += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "192"
				nBINSSPF  += TrbBMR->BMR_VLRPAG
				ntBINSSPF += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "193"
				nINSSPF   += TrbBMR->BMR_VLRPAG
				ntINSSPF  += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "194"
				nBINSSPJ  += TrbBMR->BMR_VLRPAG
				ntBINSSPJ += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "195"
				nINSSPJ   += TrbBMR->BMR_VLRPAG
				ntINSSPJ  += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "196"
				nBINSSPF  += TrbBMR->BMR_VLRPAG
				ntBINSSPF += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "197"
				nINSSPF   += TrbBMR->BMR_VLRPAG
				ntINSSPF  += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "198"
				nBIR      += TrbBMR->BMR_VLRPAG
				ntBIR     += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "199"
				nIR       += TrbBMR->BMR_VLRPAG
				ntIR      += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "179"
				nPINSSPJ  += TrbBMR->BMR_VLRPAG
				ntPINSSPJ += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "180"
				nPINSSPF  += TrbBMR->BMR_VLRPAG
				ntPINSSPF += TrbBMR->BMR_VLRPAG
			Elseif TrbBMR->BMR_CODLAN == "181"
				nCrPINSS  += TrbBMR->BMR_VLRPAG
				ntCrPINSS += TrbBMR->BMR_VLRPAG
			Endif

			BMS->(dbSetOrder(1))
			If BMS->(msSeek(TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)))

				Do While ! BMS->(Eof()) .And. BMS->(BMS_FILIAL+BMS_OPERDA+BMS_CODRDA+BMS_OPELOT+BMS_ANOLOT+BMS_MESLOT+BMS_NUMLOT+BMS_CODLAN) == ;
											TrbBMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT+BMR_CODLAN)

					If TrbBMR->BMR_CODLAN $ "102,103,104,105" // Debitos/Creditos Fixos e Variaveis
						aAdd(aBGQ, {	SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO),;
										TrbBMR->BMR_ANOLOT+TrbBMR->BMR_MESLOT+TrbBMR->BMR_NUMLOT,;
										BMS->BMS_MESLOT+"/"+BMS->BMS_ANOLOT,;
										IIf(BMS->BMS_DEBCRE == "1", "(-) ", "(+) "),;
										BMS->BMS_CODSER + " - " + Posicione("BBB", 1, xFilial("BBB")+BMS->BMS_CODSER, "BBB_DESCRI"),;
										Iif(TrbBMR->BMR_DEBCRE == "1",BMS->BMS_VLRPAG*-1,BMS->BMS_VLRPAG)})

				    Elseif TrbBMR->BMR_CODLAN <> "101" .And. TrbBMR->BMR_DEBCRE <> "3"
						aAdd(aBCE, {	SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO),;
								TrbBMR->BMR_ANOLOT+TrbBMR->BMR_MESLOT+TrbBMR->BMR_NUMLOT,;
								TrbBMR->BMR_ANOLOT+"/"+TrbBMR->BMR_MESLOT,;
								IIf(BMS->BMS_DEBCRE == "1", "(-) ", "(+) "),;
								BMS->BMS_CODSER + " - " + Posicione("BBB", 1, xFilial("BBB")+BMS->BMS_CODSER, "BBB_DESCRI"),;
								Iif(TrbBMR->BMR_DEBCRE == "1",BMS->BMS_VLRPAG*-1,BMS->BMS_VLRPAG)})

				  	Endif

					BMS->(dbSkip())
				EndDo
			EndIf
			TrbBMR->(dbSkip())
		EndDo
	Enddo
	TrbBMR->(dbCloseArea())

	// Monta os cabeçalhos
	aadd(aCpoImp,{"Valor Titulo","N",nValTit})
	if  nIss > 0 .or. nBIss > 0
		aadd(aCpoImp,{"ISS","N",nIss})
	endIf

	if  nPis > 0 .or. nBPis > 0
		aadd(aCpoImp,{"PIS","N",nPis})
	endIf

	if  nCofins > 0 .or. nBCofins > 0
		aadd(aCpoImp,{"COFINS","N",nCofins})
	endIf

	if  nCSLL   > 0 .or. nBCSLL > 0
		aadd(aCpoImp,{"CSLL","N",nCSLL})
	endIf

	if  nPINSSPF > 0
		aadd(aCpoImp,{"Prov INSS PF","N",nPINSSPF})
	endIf

	if  nPINSSPJ > 0
		aadd(aCpoImp,{"Prov INSS PJ","N",nPINSSPJ})
	endIf

	if  nINSSPF > 0 .or. nBINSSPF > 0
		aadd(aCpoImp,{"INSS PF","N",nINSSPF})
	endIf

	if  nINSSPJ > 0 .or. nBINSSPJ > 0 .or. nINSSJF > 0 .or. nBINSSJF > 0
		aadd(aCpoImp,{"INSS","N",nINSSPJ+nINSSPF})
	endIf

	if  nIR > 0 .or. nBIR > 0
		aadd(aCpoImp,{"I.R","N",nIR})
	endIf

	if  nCrPINSS > 0
		aadd(aCpoImp,{"Cred Prov INSS","N",nCrPINSS})
	endIf

	// Calcula o valor liquido do titulo.
	nValLiq := nValTit - nIss - nPis - nCofins - nCSLL - nINSSPF - nINSSPJ - nIR - nPINSSPF - nPINSSPJ + nCrPINSS
	aadd(aCpoImp,{"Valor Liquido","N",nValLiq})

	
	//Dados do BD6	
	if !empty(cCamBD61)
   		STORE FIELDS "BD6" TO aCamposBD6 FOR AllTrim(SX3->X3_CAMPO) $ cCamBD61
	endIf
	
	//Cria aColuna com as colunas que serão impressas...	
   STORE FIELDS "BD7" TO aCampos FOR AllTrim(SX3->X3_CAMPO) $ cCampos+cCampos2+cCampos3
	
	//Seleciona a área...	
   DbSelectArea("BD7")

   if len(aCamposBD6) >0
	   SX3->(DbSetOrder(2))
		for nX1 := 1 To Len(aCamposBD6)
	        SX3->(DbSeek(aCamposBD6[nX1]))
	        if SX3->X3_CONTEXT <> "V"
	           oExcel:AddColumn("Produção","Produção",X3TITULO(),1,PLSDPExcel(SX3->X3_TIPO,SX3->X3_DECIMAL),IF(SX3->X3_TIPO=="N",.T.,.F.))
	        endif
	   	next
   endIf
	
	//Imprime todas as colunas determinadas no MV - BD7	
   SX3->(DbSetOrder(2))
	For nX1 := 1 To Len(aCampos)
        SX3->(DbSeek(aCampos[nX1]))
        If SX3->X3_CONTEXT <> "V"
           oExcel:AddColumn("Produção","Produção",X3TITULO(),1,PLSDPExcel(SX3->X3_TIPO,SX3->X3_DECIMAL),IF(SX3->X3_TIPO=="N",.T.,.F.))
        Endif
   Next
	
	//Ordena a BD6	
   if !empty(cCamBD61)
   		BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
   endIf
	
	//Dados	
	For nX2 := 1 To Len(aBD7)
		
		//Posiciona no BD7 ...    	
		BD7->(DbGoTo(aBD7[nX2]))
		
      //Monta array com a linha da produção...      
      aLinha := {}
		
		//Posiciona no BD6...    	
    	if !empty(cCamBD61)
    		if cChaveBD7 <> BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO)
    			cChaveBD7 := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODPAD+BD7_CODPRO)

				lFound := BD6->(msSeek(xFilial("BD6")+cChaveBD7) )
			endIf
			
			//BD6	      	
			SX3->(DbSetOrder(2))
	      	if lFound
	      		DbSelectArea('BD6')
		      for nX1 := 1 to len(aCamposBD6)

		        	SX3->(dbSeek(aCamposBD6[nX1]))

      			 	if SX3->X3_CONTEXT <> "V"
		      			aadd(aLinha,&(aCamposBD6[nX1]))
        		  	endIf

		      next
	      		DbSelectArea('BD7')
	      	else
	      		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Erro integridade BD6 com BD7 [" + cChaveBD7 + "] chave [BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO]" , 0, 0, {})

		      for nX1 := 1 to len(aCamposBD6)

		        	SX3->(dbSeek(aCamposBD6[nX1]))

      			 	if SX3->X3_CONTEXT <> "V"
		      			aadd(aLinha,'')
        		  	endIf

		      next

		   endIf
		endIf
		
		//BD7     	
		SX3->(DbSetOrder(2))
      for nX1 := 1 to len(aCampos)
        	SX3->(dbSeek(aCampos[nX1]))

      		if SX3->X3_CONTEXT <> "V"
	        	aadd(aLinha,&(aCampos[nX1]))
        	endIf
      next

      oExcel:AddRow("Produção","Produção",aLinha)
  	Next

  	If Len(aBGQ) > 0
	   
		//Define titulo da planilha...		
		oExcel:AddworkSheet("Débito/Crédito")
	   oExcel:AddTable("Débito/Crédito","Débito/Crédito")

		For nX1 := 1 To Len(aCpoDC)
 			oExcel:AddColumn("Débito/Crédito","Débito/Crédito",aCpoDC[nX1][1],1,PLSDPExcel(aCpoDC[nX1][2],Iif(aCpoDC[nX1][2]=="N",2,0)),IF(aCpoDC[nX1][2]=="N",.T.,.F.))
	   Next
		
		//Dados		
		For nX2 := 1 To Len(aBGQ)
			
       	//Monta array com a linha da produção...	  		
  			aLinha := {}
   			For nX1 := 1 To Len(aBGQ[nX2])
		    	aadd(aLinha,aBGQ[nX2][nX1])
	      Next
    	   oExcel:AddRow("Débito/Crédito","Débito/Crédito",aLinha)
	   	Next
	Endif

	If Len(aBCE) > 0
	   
		//Define titulo da planilha...		
		oExcel:AddworkSheet("Apontamentos")
	   oExcel:AddTable("Apontamentos","Apontamentos")

		For nX1 := 1 To Len(aCpoDC)
 			oExcel:AddColumn("Apontamentos","Apontamentos",aCpoDC[nX1][1],1,PLSDPExcel(aCpoDC[nX1][2],Iif(aCpoDC[nX1][2]=="N",2,0)),IF(aCpoDC[nX1][2]=="N",.T.,.F.))
	   Next
		
		//Dados		
		For nX2 := 1 To Len(aBCE)
			
       	//Monta array com a linha da produção...	  		
  			aLinha := {}
   			For nX1 := 1 To Len(aBCE[nX2])
		    	aadd(aLinha,aBCE[nX2][nX1])
	      Next
    	   oExcel:AddRow("Apontamentos","Apontamentos",aLinha)
	   	Next
   	Endif
	
	//Define titulo da planilha...	
	oExcel:AddworkSheet("Impostos")
   oExcel:AddTable("Impostos","Impostos")

	For nX1 := 1 To Len(aCpoImp)
		oExcel:AddColumn("Impostos","Impostos",aCpoImp[nX1][1],1,PLSDPExcel(aCpoImp[nX1][2],Iif(aCpoImp[nX1][2]=="N",2,0)),.F.)
	Next
	
	//Dados	
	aLinha := {}
	For nX2 := 1 To Len(aCpoImp)
	   	aadd(aLinha,aCpoImp[nX2][3])
   	Next

   	If Len(aLinha) > 0
		oExcel:AddRow("Impostos","Impostos",aLinha)
	Endif

	aAreaBAU := BAU->(GetArea())

	BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO
	If BAU->(DbSeek(xFilial("BAU")+cCodRda))
		aMsgExt := PLSEXTPRE(BAU->BAU_CODIGO,PlsIntPad(),cAnoW,cMesW,BAU->BAU_COPCRE)
	Endif
	RestArea(aAreaBAU)

	If len(aMsgExt) > 0
		
		//Define titulo da planilha...		
		oExcel:AddworkSheet("Mensagens")
	   oExcel:AddTable("Mensagens","Mensagens")

		For nX1 := 1 To Len(aCpoMens)
	 		oExcel:AddColumn("Mensagens","Mensagens",aCpoMens[nX1][1],1,PLSDPExcel(aCpoMens[nX1][2],Iif(aCpoMens[nX1][2]=="N",2,0)),IF(aCpoMens[nX1][2]=="N",.T.,.F.))
		Next
	 	
		//Dados		
		For nX1 := 1 To Len(aMsgExt)
  			aLinha := {}
			aadd(aLinha,&(AllTrim(aMsgExt[nX1])))
 			oExcel:AddRow("Mensagens","Mensagens",aLinha)
	   	Next
    EndIf
    
	//Visualiza impressao grafica antes de imprimir	
	oExcel:Activate()
	oExcel:GetXMLFile(cPathSrv+cFileName + ".xls")

	if lWeb
		PLSCHKRP(cPathSrv+cFileName + ".xls")
	endIf

endIf

//fim da rotina
return( { cFileName + ".xls",cMsg } )


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSTJBMAIL
recebe rotina, parametros e email para envio do relatorio e executa em StartJob (processo paralelo)

@author  PLS TEAM
@version P12
@since   01.02.13
/*/
//-------------------------------------------------------------------
Function PLSTJBMAIL(cNomRot,cMailSend, cTitRel, lExcel, aParFuncao, cTipoRel)
LOCAL cEmpPls		:= GetNewPar("MV_EMPRPLS", "99")	// Pega a empresa de trabalho do PLS
LOCAL cFilPls		:= PADR(GetNewPar("MV_FILIPLS", "01"),FWSizeFilial())	// Pega a filial de trabalho do PLS
LOCAL cPathSrv 	:= lower(getMV("MV_RELT"))
Local oServer		:= nil
Local cRpcServer	:= GetNewPar("MV_PLSSRV", "")
Local nRPCPort 	:= GetNewPar("MV_PLSPRT", 0)
Local cRPCEnv 	:= GetNewPar("MV_PLSENV", GetEnvServer())

//realiza todo o processamento do relatorio, geracao de excel e envio de email atraves de StartJOB
if empty(cRpcServer)
	startJob("PLSRJBMAIL",GetEnvServer(),.F.,cEmpPls, cFilPls, cNomRot,cMailSend, cTitRel, lExcel,aParFuncao, cPathSrv, cTipoRel)
else
	oServer := TRPC():New( cRPCEnv )

	if oServer:Connect( cRpcServer, nRPCPort )
		oServer:StartJob("PLSRJBMAIL", .F., cEmpPls, cFilPls, cNomRot,cMailSend, cTitRel, lExcel,aParFuncao, cPathSrv, cTipoRel)
		oServer:Disconnect()
	else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Conexao indisponivel com o servidor: " + cRPCServer , 0, 0, {})
	endIf
endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRJBMAIL
Gera relatorio em processo paralelo e envia por email

@author  PLS TEAM
@version P12
@since   01.02.13
/*/
//-------------------------------------------------------------------
Function PLSRJBMAIL(cEmpTrab, cFilTrab, cRotRel, cMail, cNomRel, lGerXLS, aParFuncR, cPathSrvR, cTipoRel )
Local cStrMacro	:= "" // Macro que sera executada montada com o nome da rotina do relatorio e os parametros informados
Local aRetRel	:= {} // Retorno da rotina do relatorio em questao
Local cArqRet	:= "" // nome do arquivo de  retorno
Local cMsgRet	:= "" // Mensagem de retorno
Local aRetExc	:= {} // Retorno da rotina geração do excel
Local cArqExc	:= "" // nome do arquivo de  retorno
Local cMsgExc	:= "" // Mensagem de retorno
Local nLin		:= 0  // contador do FOR
Local aAnexos	:= {}
Local cNomeArqZip := ''
Local nMaxSizeF	:= 0
Local lEnvio	:= .T.
Local lZip		:= .T.
Local aAnexoAux	:= {}
Local aRetAux	:= {}
Local aDadosRet	:= {}
Local aRetTrans	:= {}
Local cEncod	:= "ISO-8859-1"
Local cTranRet := ""
Local cNumeSeq := StrTran(Day2Str(date())+"/"+Month2Str(date())+"/"+Year2Str(date()),"/","") + StrTran(SubStr(time(),1,5),":","")
Local cOrigem  := ""
Local cTagOri  := "" //CPF ou CNPJ, depende da origem
Local cNomApl  := ""
Local cVerApl  := ""
Local cFabApl  := ""
Local cDirRaiz := ""
Local cDirCaiSa:= ""
Local cArqAux	:= ""
local lFrmCompac	:= .T. 
local cExtCompac	:= ""

Private aParFunc := aParFuncR

If !File(PLSMUDSIS("\workflow\wfRelPCPadrao.htm"))
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Nao foi possivel encontrar o arquivo ["+PLSMUDSIS("\workflow\wfRelPCPadrao.htm")+"] na pasta workflow do servidor" , 0, 0, {})
	Return()
EndIf
FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PREPARANDO AMBIENTE" , 0, 0, {})

rpcSetType(3)
rpcSetEnv(cEmpTrab, cFilTrab)

nMaxSizeF	:= getNewPar("MV_PLSTMF",0)

lFrmCompac	:= getNewPar("MV_PLSRARZ",.T.)
cExtCompac	:= iif(lFrmCompac, 'rar', 'zip') 

If cTipoRel == "2"
	cDirRaiz := PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\") )
	cDirCaiSa:= PLSMUDSIS( cDirRaiz+"CAIXASAIDA\" )
	If cRotRel == "PLSRELDPM"
		cTranRet := "DEMONSTRATIVO_PAGAMENTO=demonstrativosRetorno_demonstrativoPagamento"
		aRetTrans := PLSDPGTB(PlsIntPad(), aParFuncR[1], aParFuncR[1], aParFuncR[2], aParFuncR[3], nil, nil, nil, nil, nil, nil)
	ElseIf cRotRel == "PLSRELDPO"
		cTranRet := "DEMONSTRATIVO_ODONTOLOGIA=demonstrativosRetorno_demonstrativoPagamentoOdonto"
		aRetTrans := PLSDPGTODB(PlsIntPad(), aParFuncR[1], aParFuncR[1], aParFuncR[2], aParFuncR[3], nil, nil, nil, nil, nil, nil)
	EndIf

	BAU->( DbSetOrder( 1 ) ) //BAU_FILIAL + BAU_CPFCGC ou  BAU_CODIGO ou BAU_CODBB0
	BAU->( DbSeek( xFilial("BAU")+aParFuncR[1] ) )

	If Len(AllTrim(BAU->BAU_CPFCGC)) > 11
		cTagOri  := "CNPJ"
	Else
		cTagOri  := "CPF"
	EndIf
	cOrigem		:= AllTrim(BAU->BAU_CPFCGC)

	aRetAux := {}

	aAdd(aRetAux, AllTrim(BAU->BAU_TIPPE))		//1
	aAdd(aRetAux, AllTrim(BAU->BAU_CPFCGC))		//2
	aAdd(aRetAux, BAU->BAU_CODIGO) 				//3
	aAdd(aRetAux, AllTrim(BAU->BAU_NOME)) 		//4
	aAdd(aRetAux, AllTrim(BAU->BAU_TIPPE))		//5
	aAdd(aRetAux, AllTrim(BAU->BAU_CPFCGC))		//6
	aAdd(aRetAux, "") 							//7
	aAdd(aRetAux, "") 							//8
	aAdd(aRetAux, cNumeSeq) 					//9
	aAdd(aRetAux, "") 							//10
	aAdd(aRetAux, .T.) 							//11
	aAdd(aRetAux, .T.) 							//12
	aAdd(aRetAux, cNumeSeq) 					//13
	aAdd(aRetAux, dDatabase) 					//14
	aAdd(aRetAux, BAU->BAU_CODIGO) 				//15
	aAdd(aRetAux, AllTrim(BAU->BAU_CNES))		//16
	aAdd(aRetAux, 0)							//17
	aAdd(aRetAux, "")							//18

	aAdd(aDadosRet, aRetAux)

	For nLin := 1 To Len(aDadosRet)
		aAdd(aRetRel, { ;
			Iif(Len(aDadosRet) < nLin, aDadosRet[Len(aDadosRet)], aDadosRet[nLin]), ;
			Iif(Len(aRetTrans) == 0, Nil, Iif(Len(aRetTrans) < nLin, aRetTrans[Len(aRetTrans)], aRetTrans[nLin])) ;
		})

	Next

	aadd(aRetRel,cTranRet)
	aadd(aRetRel,cNumeSeq)
	aadd(aRetRel,cOrigem)
	aadd(aRetRel,cTagOri)
	aadd(aRetRel,cNomApl)
	aadd(aRetRel,cVerApl)
	aadd(aRetRel,cFabApl)
	aadd(aRetRel,aRetTrans)
	//exemplo do retorno da função: "000002\nome do arquivo", sendo que o 000002 é a pasta com o código da rda
	//caso mude essa estrutura, adaptar o retorno, para que o resto da função consiga visualizar o arquivo
	cArqRet := PLSPROCRES(aRetRel,cEncod,,,,,,aParFuncR[1],,,{}, aRetRel[9])
	cArqAux := lower("PLSRELDPM" + criaTrab(nil,.f.) + "_" + aParFuncR[1])+".xml"
	__CopyFile( cDirCaiSa + cArqRet, cPathSrvR + SubStr(cArqRet,AT("\",cArqRet)+1,LEN(cArqRet)))
	If frename(cPathSrvR + SubStr(cArqRet,AT("\",cArqRet)+1,LEN(cArqRet)),cPathSrvR + cArqAux) != -1
		cArqRet := cPathSrvR + cArqAux
	EndIf
	cMsgRet := ""
Else
	
	//MONTAGEM DA STRING DA MACRO PARA EXECUCAO	
	If Len(aParFunc) > 0
		cStrMacro := Alltrim(cRotRel) + "("  // Ex: PLSRELDPM(
		For nLin := 1 to Len(aParFunc)
			cStrMacro += "aParFunc[" + Alltrim(Str(nLin)) + "]" // aParFunc[1],aParFunc[2] ...... aParFunc[n]
			cStrMacro += IIf(nLin < Len(aParFunc), ",", "")     // Concatena a virgula de separacao dos parametros caso nao seja o ultimo
		Next nLin
		cStrMacro += ")" //Fecha parenteses da funcao PLSRELDPM(aParFunc[1],aParFunc[2],aParFunc[n])
	Else
		cStrMacro := cRotRel + "()" //nap possui passagem por parametro
	EndIf

	
	//executa a macro gerando o relatorio PDF	
	aRetRel := &(cStrMacro)
	cArqRet := cPathSrvR + aRetRel[1]
	cMsgRet := aRetRel[2]

EndIf

if !empty(cMsgRet)
	cMsgRet += chr(10)+chr(13)
endIf

aadd(aAnexos, cArqRet)

//executa a macro de geração do Excel
if lGerXLS .and. empty(cMsgRet)

	cStrMacro	:= strTran(cStrMacro,cRotRel,"PLSPRPLAN")
	aRetExc 	:= &(cStrMacro)
	cArqExc 	:= cPathSrvR + aRetExc[1]
	cMsgExc 	:= aRetExc[2]

	if !empty(cMsgExc)
		cMsgExc += chr(10)+chr(13)
	endIf

	aadd(aAnexos, cArqExc)
endIf

//compactacao do arquivo
if empty(cMsgRet) .or. (lGerXLS .and. empty(cMsgExc))

	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Compactando arquivo" , 0, 0, {})

	for nLin:=1 to len(aAnexos)
		If lGerXLS
			cNomeArqZip := strTran(lower(aAnexos[nLin]),'xls',cExtCompac)
		elseIf UPPER(Right(allTrim(aAnexos[nLin]), 3)) == "XML"
			cNomeArqZip := strTran(lower(aAnexos[nLin]),'xml',cExtCompac)
		else
			cNomeArqZip := strTran(lower(aAnexos[nLin]),'pdf',cExtCompac)
		EndIf

		cFunc	:= "GzCompress"
		lZip 	:= .f.
		lEnvio := .f.

		if &cFunc.(aAnexos[nLin], cNomeArqZip)
			fErase(aAnexos[nLin])
			
			//verifica o tamanho do zip			
			if nMaxSizeF > 0
				nH := fOpen(aAnexos[nLin],2)

		   		if (fSeek(nH,0,2)/1000) > nMaxSizeF
		   			lEnvio := .f.
		   		endIf
		   	endIf

		   	lZip 	:= .t.
		   	lEnvio := .t.
		endIf


		if !lZip
			cMsgRet += "Nao foi possivel compactar o arquivo: ["+aAnexos[nLin]+"]"+chr(10)+chr(13)
		elseIf !lEnvio
			cMsgRet += 'Arquivo: [' + aAnexos[nLin] + '] excedeu o tamanho permitido.'+chr(10)+chr(13)
		else
			aadd(aAnexoAux,cNomeArqZip)
			PLSCHKRP(aAnexoAux[nLin])
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Envio do arquivo [" + cNomeArqZip + "] para e-mail: " + cMail , 0, 0, {})
		endIf

	next
else
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "" , 0, 0, {})

	if !empty(cArqExc)
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Atencao [" + cMsgExc + "] " , 0, 0, {})
	endIf
endIf

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Aviso: '+ cMsgRet + chr(10) + chr(13) + cMsgExc , 0, 0, {})

//Envia os anexo PDF ou XML
if len(aAnexoAux)>0
	PlsWFProc(/* StrZero(Randomize(0, 1000000))*/, "WF_Retorno_Relatorio", cNomRel, cNomRel, cMail, "", SuperGetMv("MV_RSPCMAIL",,""), PLSMUDSIS("\workflow\wfRelPCPadrao.htm"), {{"TEXTO","Relatorio: " + cNomRel + " - Gerado em: " + DtoC(dDataBase) + iif(!empty(cMsgRet+cMsgExc)," - Obs: " + cMsgRet + chr(13)+chr(10) + cMsgExc,"") }},aAnexoAux,.F.)

//Caso tenha mensagem de retorno, envia por email para que o usuario nao necessite aguardar o relatorio gerado
elseIf !empty(cMsgRet)
	PlsWFProc( /*StrZero(Randomize(0, 1000000))*/, "WF_Retorno_Relatorio", cNomRel, cNomRel, cMail, "", SuperGetMv("MV_RSPCMAIL",,""), PLSMUDSIS("\workflow\wfRelPCPadrao.htm"), {{"TEXTO",cMsgRet + chr(13)+chr(10) + cMsgExc}},,.F.)
endIf

//RpcClearEnv()

//Fim da Rotina
return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSJXAUTP
Permite o processamento da PLSXAUTP em startjob(multithread)

@author  PLS TEAM
@version P12
@since   12.06.2015
/*/
//-------------------------------------------------------------------
Function PLSJXAUTP(aDados, aItens)
Local oServer	:= nil
Local cRpcServer:= GetNewPar("MV_PLSSRV", "")
Local nRPCPort 	:= GetNewPar("MV_PLSPRT", 0)
Local cRPCEnv 	:= GetNewPar("MV_PLSENV", GetEnvServer())
RpcSetType(3)

//realiza todo o processamento do PLSXAUTP atraves de StartJOB
If empty(cRpcServer)
	StartJob("PLSXAUTP",GetEnvServer(),.F., aDados, aItens)
Else
	oServer := TRPC():New( cRPCEnv )
	If oServer:Connect( cRpcServer, nRPCPort )
		oServer:StartJob("PLSXAUTP", .F., aDados, aItens)
		oServer:Disconnect()
	Else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Conexao indisponivel com o servidor: " + cRPCServer , 0, 0, {})
	EndIf
EndIf
RpcClearEnv()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRELEP
Estatistica de parto

@author  PLS TEAM
@version P12
@since   15.10.15
/*/
//-------------------------------------------------------------------
function PLSRELEP(cCodOpe, cCodRdaHC, cCodRdaM, lWeb, cPathSrv)
local cFileLogo	:= GetNewPar("MV_PLSRELO","")
local cFileName	:= ''
local cMsg		:= ''
local cRel      := "estpart"
local lContinua	:= .t.
local oFont01	:= nil
local oFont02n	:= nil
local oFont03n	:= nil
local oFont04	:= nil
local oFont05n	:= nil
local oPrint	:= nil
local nLinMax	:= 0
local nColMax	:= 0
local nLinIni	:= 0		// Linha Lateral (inicial) Esquerda
local nColIni	:= 0		// Coluna Lateral (inicial) Esquerda
local nColA4    := 0
local nWeb		:= 0
local nTweb		:= 1
local nLweb		:= 0
local nLwebC	:= 0
local aDados  	:= {}
local cPerg 	:= "PLSREPA"
default cCodOpe		:= ''
default cCodRdaHC	:= ''
default cCodRdaM	:= ''
default lWeb		:= .f.
default cPathSrv 	:= getMV("MV_RELT")

cTitulo	 := STR0468 // "Estatística de Partos"

if !lWeb
	//Acessa parametros do relatorio...
	if !pergunte(cPerg,.T.)
		return
	endIf

	cCodOpe		:= mv_par01
	cCodRdaHC	:= mv_par02
	cCodRdaM	:= mv_par03
endIf

//processa requisicao
if !lWeb
	msAguarde( {|| aadd(aDados, PLSRN368(cCodOpe, cCodRdaHC, cCodRdaM) ) }, cTitulo, "", .t.)
else
	aadd(aDados, PLSRN368(cCodOpe, cCodRdaHC, cCodRdaM) )
endIf

//exemplo do relatorio
/*aDados := { {	"123456",; //1 - Protocolo
				dtoc(date()) + ' às ' + time(),; //2 - Data e hora
				'2015',; //3 - Ano
				{"Nome da Operadora",10,10},; //4 - nome da opradora-parto nomal-parto cesarea
				{"Nome do estabelecimento",10,10},; //5 - nome do estabelecimento-parto nomal-parto cesarea
				{"Nome do Medico",10,10} } } //6 - nome do medico-parto nomal-parto cesarea
*/

if len(aDados[1]) == 0
	if !lWeb
		msgAlert("Não foi encontrado registro ou não informado os eventos de parto e cesárea")
	else
		cMsg := "Não foi encontrado registro ou não informado os eventos de parto e cesárea"
	endIf
	lContinua := .f.
endIf

if lContinua
	//preparando para impressao
	nLinMax	:=	2275
	nColMax	:=	3270

	oFont01 := TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
	oFont02n:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont03n:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04	:= TFont():New("Arial", 12, 12, , .F., , , , .T., .F.) // Normal
	oFont05n:= TFont():New("Arial", 20, 20, , .T., , , , .T., .F.) // Negrito

	//Nao permite acionar a impressao quando for na web.
	if lWeb
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	else
		cFileName := cRel+CriaTrab(NIL,.F.)
	endIf

	//New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
	nH := PLSAbreSem("PPLSESTPAR.SMF")
	if lWeb
		oPrint := FWMSPrinter():New( cFileName,,.f.,cPathSrv,.t.,,@oPrint,,,.f.,.f.)
	else
		oPrint := FWMSPrinter():New( cFileName,,.f.,cPathSrv,.t.,,,,,.f.,,)
	endIf
	PLSFechaSem(nH,"PPLSESTPAR.SMF")

	oPrint:lServer 	:= lWeb
	oPrint:cPathPDF	:= cPathSrv

	nTweb	:= 3.9
	nLweb	:= 10
	nLwebC	:= -3
	nWeb	:= 25
	nColMax := iIf(lWeb,2980,3100)

	oPrint:setLandscape()// Modo paisagem
	oPrint:setPaperSize(9)// Papél A4

	//Device
	if lWeb
		oPrint:setDevice(IMP_PDF)
	else
		oPrint:Setup()
		if !(oPrint:nModalResult == 1)// Botao cancelar da janela de config. de impressoras.
			return
		endif
	endif

	nLinIni := 080
	nColIni := 080
	nColA4  := 000

	//Inicia uma nova pagina
	oPrint:startPage()

	//Box Principal
	oPrint:box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)

	//Carrega e Imprime Logotipo da Empresa
	fLogoEmp(@cFileLogo)

	if file(cFilelogo)
		oPrint:SayBitmap((nLinIni + 0050)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, (400)/nTweb, (090)/nTweb) 		// Tem que estar abaixo do RootPath
	endIf

	nColA4 := -0335

	oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.39)/nTweb, STR0457, oFont05n,,,, 2) //"Informação sobre Partos"

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)

	oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 689)/nTweb, STR0458, oFont03n) //"Protocolo"
	oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 480)/nTweb, aDados[1,1], oFont04)

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)

	oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 722)/nTweb, STR0459, oFont03n) //"Data e Hora:"
	oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 480)/nTweb, aDados[1,2], oFont04)

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)

	oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 820)/nTweb, STR0460, oFont03n)// "Referente ao ano:"
	oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 480)/nTweb, aDados[1,3], oFont04)

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)

	oPrint:Say((nLinIni + 197)/nTweb, (nColIni + 0020)/nTweb, space(50) + STR0461 + space(80) + STR0462 + space(80) + STR0463, oFont04)//"Descrição" + space(10) + "Partos Normais" + space(10) + "Cirurgias Cesáreas"
	AddTBrush(oPrint, (nLinIni + 215)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 216)/nTweb, (nColIni + nColMax)/nTweb)

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)

	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 0020)/nTweb, STR0464, oFont03n) //"Operadora"
	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 500)/nTweb, aDados[1,4,1], oFont04)
	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 1550)/nTweb, transform(aDados[1,4,2], "@E 999.99") + " %", oFont04)
	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 2700)/nTweb, transform(aDados[1,4,3], "@E 999.99") + " %", oFont04)

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)

	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 0020)/nTweb, STR0465, oFont03n)//"Hospital:"
	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 500)/nTweb, aDados[1,5,1], oFont04)
	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 1550)/nTweb, transform(aDados[1,5,2], "@E 999.99") + " %", oFont04)
	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 2700)/nTweb, transform(aDados[1,5,3], "@E 999.99") + " %", oFont04)

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)

	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 0020)/nTweb, STR0466, oFont03n) //"Médico:"
	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 500)/nTweb, aDados[1,6,1], oFont04)
	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 1550)/nTweb, transform(aDados[1,6,2], "@E 999.99") + " %", oFont04)
	oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 2700)/nTweb, transform(aDados[1,6,3], "@E 999.99") + " %", oFont04)

	fSomaLin(nLinMax, nColMax, @nLinIni, nColIni,300, 80)

	oPrint:say((nLinIni + 195)/nTweb, (nColIni + 0020)/nTweb, STR0467, oFont03n) //"Informações referem-se ao dados vinculados apenas aos partos efetuados pela Operadora acima."

	oPrint:endPage() //Finaliza a pagina

	if lWeb
		oPrint:Print()
	else
		oPrint:Preview()
	endIf
endIf

return( { cFileName, cMsg } )


//-------------------------------------------------------------------
/*/{Protheus.doc} plGetImgRel
carrega imagem do parâmetro

@author  PLS TEAM
@version P12
@since   15.10.15
/*/
//-------------------------------------------------------------------
static function plGetImgRel
local cImagem := GetNewPar("MV_PLSRELO","")
return cImagem

//-------------------------------------------------------
/*/{Protheus.doc} QDemPagDad
Retorna valores referentes a demonstração de pagamento
@author Eduardo Bento
@since 04.02.20
@version 1.0
/*///-----------------------------------------------------
function QDemPagDad(cCodRDA)
local aDadRelat := {}
local aDadBan	:= {"","",""}
local cCodOpe := PLSINTPAD()
local cRegANSOpe:= ""
local cNomeOpe	:= ""
local cCNPJOpe 	:= ""
local cCnes		:= ""
local cForPGt	:= ""
local cfornec	:= ""
local cNomeRDA  := ""

default cCodRDA	:= ""

//Dados Operadora
BA0->(dbSetOrder(1))
If BA0->(MsSeek(xfilial("BA0") + cCodOpe))
	cRegANSOpe := BA0->BA0_SUSEP
	cNomeOpe := BA0->BA0_NOMINT
	cCNPJOpe := BA0->BA0_CGC
EndIf


//Dadps Prestador
BAU->(DbSetOrder(1))
If BAU->(MsSeek(xFilial("BAU") + alltrim(cCodRDA)))
	cNomeRDA := BAU->BAU_NOME //Nome do prestadpr
	cForPGt := BAU->BAU_FORPGT
	cfornec := BAU->BAU_CODSA2
	//cCPFCNPJR := BAU->BAU_CPFCGC
endIf

BB8->(dbsetOrder(1))
If BB8->(MsSeek(xfilial("BB8") + cCodRDA + cCodOpe))
	While !(BB8->(EoF())) .AND. BB8->(BB8_CODIGO+BB8_CODINT) == cCodRDA + cCodOpe .AND. (empTy(BB8->BB8_CNES) .OR. BB8->BB8_CNES == '9999999')
		BB8->(DbSkip())
	EndDo
	If BB8->(BB8_CODIGO+BB8_CODINT) == cCodRDA + cCodOpe .AND. !(empTy(BB8->BB8_CNES) .OR. BB8->BB8_CNES == '9999999')
		cCnes := BB8->BB8_CNES
	else
		cCnes := '9999999'
	EndIF
else
	cCnes := '9999999'
endIf

If cForPGt == "1"
	SA2->(dbSetOrder(1))
	If SA2->(MsSeek(xfilial("SA2") + cfornec))
		aDadBan[1] := SA2->A2_BANCO
		aDadBan[2] := SA2->A2_AGENCIA
		aDadBan[3] := SA2->A2_NUMCON
	endIf
endIf

aadd(aDadRelat,cRegANSOpe) //Registro na ANS da Operadora
aadd(aDadRelat,cNomeOpe	 ) //Nome da operadora
aadd(aDadRelat,cCNPJOpe	 ) //CNPJ da operadora
aadd(aDadRelat,cNomeRDA	 ) //Codigo do prestador na operadora
aadd(aDadRelat,cCnes	 ) //CNES -> normalmente vai o default
aadd(aDadRelat,cForPGt	 ) //Forma de pagamento
aadd(aDadRelat,aDadBan[1]) //Banco
aadd(aDadRelat,aDadBan[2]) //Agencia
aadd(aDadRelat,aDadBan[3]) //Numero da conta

return aDadRelat	//[1]RegistroANS,[2]NomeOperadora,[3]CNPJOperadora,[4]cNomeRDA,[5]cCnes,
					//[6]FormaPagamento,[7]Banco,[8]Agencia,[9]numeroConta]

//-------------------------------------------------------
/*/{Protheus.doc} formatReal
Converte numeral em string com formato moeda
@author Eduardo Bento
@since 06.02.20
@version 1.0
/*///-----------------------------------------------------
Function formatReal(nValor)
LOCAL cValFormat := ""
LOCAL cValorStr	:= ""
LOCAL nTamanho	:= 0
LOCAL nI:= 1
DEFAULT nValor := 0

//Formata para R$XXXX,XX
cValorStr := alltrim(str(nValor*100))
if nValor == 0
	cValorStr := "000"
elseif nValor < 1
	cValorStr := "0"+cValorStr
endif
nTamanho := len(cValorStr)
cValFormat := "R$"+substr(cValorStr,1,nTamanho-2)+","+substr(cValorStr,nTamanho-1,2)

//Coloca ponto a cada 3 decimais
nTamanho := len(cValFormat)-5
While nTamanho > 3
	nTamanho := nTamanho - 3
	cValFormat := substr(cValFormat,1,nTamanho+2)+"."+substr(cValFormat,nTamanho+3,nI+3+(3*nI))
	nI++
EndDo

Return cValFormat
