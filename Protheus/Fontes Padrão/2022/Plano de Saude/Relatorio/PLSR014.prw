#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25


Static oFnt10C 		:= TFont():New("Arial",10,10,,.F., , , , .T., .F.)
Static oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .T., .F.)
Static oFnt14N		:= TFont():New("Arial",18,18,,.T., , , , .T., .F.)
static objCENFUNLGP := CENFUNLGP():New() 
static lautoSt := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR014
Imprime as Rda's que estão com o contrato para vencer em determinada qtd de dias
@author Karine Riquena Limp
@since 15/08/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSR014(lAuto)
Local oReport     	:= nil
Local cDirPath		:= Lower(GetMV("MV_RELT"))
Local cFileName		:= "RDA_CONTRATO_A_VENCER_"+DtoS(dDataBase) + "_" + SubStr(Time(),1,2) + SubStr(Time(),4,2)
Local lRet := .T.
private aRet 			:= {"",""}
private cPerg       	:= "PLSR014P"

default lAuto := .F.

lautoSt := lauto

//-- LGPD ----------
if !lAuto .ANd. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

if lAuto .OR. Pergunte(cPerg,.T.)

	If lauto
		mv_par01  := 10
	endif

	oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)
	
	oReport:cPathPDF	:= cDirPath
	oReport:setDevice(IMP_PDF)
	oReport:setResolution(72)
	oReport:SetPortrait()
	oReport:SetPaperSize(9)
	oReport:setMargin(05,05,05,05)
	
	If !lauto
		oReport:Setup()  //Tela de configurações

		If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return{"",""}
		EndIf
	endIf

	lRet := PLSRImpRda(oReport)
	
	if lRet
		aRet := {cFileName+".pdf",""}
	else
		aRet := {"",""}
	endif
	
	if !lauto .AND. lRet
			
		oReport:EndPage()
		oReport:Print()
				
	endIf
	
	FreeObj(oReport)
		
	//MS_FLUSH()
	
endIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRImpRda
Monta o relatório com os dados
@author Fábio S. dos Santos
@since 15/08/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSRImpRda(oReport)
Local nCont	:= 0
Local nLinha	:= 1
Local lFirst	:= .T.
Local nPag		:= 1
Local nColAux	:= 0
Local lRet 	:= .T.
Local cSql 	:= ""
Local nI		:= 1
Local dDtLim  := ddatabase + mv_par01 //data atual + qtd dias informada no pergunte
Local dDtMinInc 	:= YearSub(ddatabase,1) //no relatorio entra a RDA a vencer a partir da data atual
Local dDtMaxInc 	:= YearSub(dDtLim,1) //data maxima para data de inclusão é a data atual + qtdDias informado no parametro - 1 ano
// a vigencia do contrato é sempre 1 ano
// suponha data atual 15/08/2016
// parametro MV_PAR01 exemplo (Rdas a vencer nos próximos 10 dias) // entra quem vence o contrato dia 15/08 até 25/08
// quem foi incluido dia 14/08/2015 já venceu não entra
// quem foi incluido dia 26/08/2015 vence daqui a 11 dias, não entra na query

Private nLeft	 	:= 40
Private nRight 	:= 1730
Private nCol0  	:= nLeft
Private nTop	 	:= 130
Private nTopInt	:= nTop
Private nLinOri	:= 46

Private nTweb	:= 3
Private nLweb	:= 10

if oReport:GetOrientation() == 2 //se o usuário informou paisagem 
	nLeft	 := 40
	nRight	 := 2390
	nCol0   := nLeft
	nTop	 := 130
	nTopInt := nTop
	nLinOri := 30
endIf

cSql := " SELECT COUNT(*) AS QTD "
cSql += " FROM " + retSqlName("BAU")
cSql += " WHERE BAU_FILIAL = '" + xFilial("BAU") + "'"
cSql += " AND   BAU_DTINCL >= '" + DTOS(dDtMinInc) + "'"
cSql += " AND   BAU_DTINCL <= '"  + DTOS(dDtMaxInc) + "'"
cSql += " AND   D_E_L_E_T_ <> '*' "
cSql += " GROUP BY BAU_FILIAL, BAU_CODIGO, BAU_NOME, BAU_DTINCL "

cSql := ChangeQuery(cSql)
TcQuery cSql New Alias 'TRBBAU'

TRBBAU->(DbGoTop())

nCont := TRBBAU->QTD

TRBBAU->(dbCloseArea())

cSql := " SELECT BAU_CODIGO, BAU_NOME, BAU_DTINCL "
cSql += " FROM " + retSqlName("BAU")
cSql += " WHERE BAU_FILIAL = '" + xFilial("BAU") + "'"
cSql += " AND   BAU_DTINCL >= '" + DTOS(dDtMinInc) + "'"
cSql += " AND   BAU_DTINCL <= '"  + DTOS(dDtMaxInc) + "'"
cSql += " AND   D_E_L_E_T_ <> '*' "

cSql := ChangeQuery(cSql)
TcQuery cSql New Alias 'TRBBAU'

TRBBAU->(DbGoTop())
If !lautoSt
	ProcRegua(nCont)
endIf

oReport:StartPage()

nI := 1 //para fazer a quebra de pagina
While  TRBBAU->(!EOF()) 
		nI++

		If !lautoSt
			IncProc("Imprimindo...") 
		endIf

		If lFirst   
			ImpCab(oReport, nPag)
			lFirst := .F.
		EndIf
			
		nColAux := (nLeft/nTweb) //"Código"
		oReport:Say(nTop/nTweb, nColAux, TRBBAU->BAU_CODIGO, oFnt10c)
	
		if oReport:GetOrientation() == 1 //se é retrato
			nColAux += __NTAM1*3 //"Nome RDA"
			oReport:Say(nTop/nTweb, nColAux, SubStr(TRBBAU->BAU_NOME,1,23), oFnt10c)
		
			nColAux += __NTAM2*20 //"Data inclusão"
			oReport:Say(nTop/nTweb, nColAux, dtoc(stod(TRBBAU->BAU_DTINCL)), oFnt10c)
		
			nColAux += __NTAM3*3 //"Data vencimento"
			oReport:Say(nTop/nTweb, nColAux, dtoc(YearSum(stod(TRBBAU->BAU_DTINCL),1)), oFnt10c)
		
			nColAux += __NTAM4*3 //"Qtde de Dias até vencer"
			oReport:Say(nTop/nTweb, nColAux, alltrim(STR(YearSum(stod(TRBBAU->BAU_DTINCL),1)-ddatabase)), oFnt10c)
		else
			
			nColAux += __NTAM1*3 //"Nome RDA"
			oReport:Say(nTop/nTweb, nColAux, SubStr(TRBBAU->BAU_NOME,1,23), oFnt10c)
		
			nColAux += __NTAM2*35 //"Data inclusão"
			oReport:Say(nTop/nTweb, nColAux, dtoc(stod(TRBBAU->BAU_DTINCL)), oFnt10c)
		
			nColAux += __NTAM3*5 //"Data vencimento"
			oReport:Say(nTop/nTweb, nColAux, dtoc(YearSum(stod(TRBBAU->BAU_DTINCL),1)), oFnt10c)
		
			nColAux += __NTAM4*5 //"Qtde de Dias até vencer"
			oReport:Say(nTop/nTweb, nColAux, alltrim(STR(YearSum(stod(TRBBAU->BAU_DTINCL),1)-ddatabase)), oFnt10c)
		
		endIf
		
		nLinha++
		nTop += 45
			
		If nLinha > nLinOri .And. nI < nCont
			nLinha := 1
			oReport:EndPage()
			oReport:StartPage()
			nPag++
			ImpCab(oReport, nPag)
		EndIf
		
		TRBBAU->(dbSkip())
	
EndDo

if !lautoSt  .AND. (nCont <= 0)

	 MsgStop("Nenhum dado encontrado para os parametros informados.")
	 lRet := .F.
	 
endIf

TRBBAU->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCab
Monta o cabeçalho do relatório
@author Fábio S. dos Santos
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ImpCab(oReport, nPag)

local cTitulo := "RDA`s com contrato a vencer nos próximos: " + alltrim(str(mv_par01)) + " dias" 
local cMsg    := ""

oReport:EndPage() //Salta para proxima pagina

nTop		:= 15
nTopInt	:= nTop
nLeft		:= 40
nTop		+= _BL
nTopAux 	:= nTop

aBMP	:= {"lgesqrl.bmp"}

If File("lgesqrl" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMP := { "lgesqrl" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgesqrl" + FWGrpCompany() + ".bmp")
	aBMP := { "lgesqrl" + FWGrpCompany() + ".bmp" }
EndIf

oReport:SayBitmap(nTop/nTweb, nLeft/nTweb, aBMP[1], 100, 100)
		
cMsg := cTitulo
nTop += 150
oReport:Say(((nTop)/nTweb)+nLweb, IIF(oReport:GetOrientation() == 1, nLeft + 350, nLeft + 700)/nTweb, cMsg, oFnt14N)
cMsg := "Data: "+DtoC(dDataBase)
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)

cMsg := "Hora: "+time()
nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10N)

nTop += 35
oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, "Pagina: "+AllTrim(Str(nPag))+"", oFnt10N)

nTop += _BL
oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb, (nTop/nTweb)+nLweb, nRight/nTweb)
	
nTop += _BL + 40
nColAux := (nCol0/nTweb)
oReport:Say(nTop/nTweb, nColAux, "Código", oFnt10c)

if oReport:GetOrientation() == 1 //se é retrato
	nColAux += __NTAM1*3
	oReport:Say(nTop/nTweb, nColAux, "Nome RDA", oFnt10c)
	
	nColAux += __NTAM2*20
	oReport:Say(nTop/nTweb, nColAux, "Data inclusão", oFnt10c)
	
	nColAux += __NTAM3*3
	oReport:Say(nTop/nTweb, nColAux, "Data vencimento", oFnt10c)
	
	nColAux += __NTAM4*3
	oReport:Say(nTop/nTweb, nColAux, "Qtde de Dias até vencer", oFnt10c)
else

	nColAux += __NTAM1*3
	oReport:Say(nTop/nTweb, nColAux, "Nome RDA", oFnt10c)
	
	nColAux += __NTAM2*35
	oReport:Say(nTop/nTweb, nColAux, "Data inclusão", oFnt10c)
	
	nColAux += __NTAM3*5
	oReport:Say(nTop/nTweb, nColAux, "Data vencimento", oFnt10c)
	
	nColAux += __NTAM4*5
	oReport:Say(nTop/nTweb, nColAux, "Qtde de Dias até vencer", oFnt10c)
	
endIf

nTop += _BL
nTop += 43
oReport:Line((nTop/nTweb)-nLweb, nLeft/nTweb, (nTop/nTweb)-nLweb, nRight/nTweb)

Return
