#INCLUDE "PLSR996.ch"
#INCLUDE "rwmake.ch"
#include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#include "PLSMGER.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Report.ch"
Static objCENFUNLGP := CENFUNLGP():New() 
static lAutoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLSR996  º       ³ 				     º Data ³ 21/12/11	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Sinistralidade 			                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 					                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

function PLSR996()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis padroes para todos os relatorios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

local oReport 	:= nil
local aPergs	:= {}
Local aFilter 	:= {} 
local aTipo 	:= {"1- Fisica","2- Juridica"}
local aAnaliSt	:= {"1- Sintetico","2- Analitico"}
Local aRn309	:= {"1- Sim","2- Nao"}
Local aFilter   := {}
Local nLin          := 80
LOCAL cFileName		:= "SIN"+CriaTrab(NIL,.F.)
Local aAlias		:= {}

PRIVATE nQtdLin     := 60
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := STR0001 //"Relatório Sinistralidade"
PRIVATE cDesc1      := ""
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1"
PRIVATE cPerg 		:= PADR("PLR996R", Len(SX1->X1_GRUPO))
Private wnrel		 := "PLSR996" // Coloque aqui o nome do arquivo usado para impressao em disco
PRIVATE nli         := 80
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cNomeProg    := "PLSR996"
PRIVATE nTipo       := 18
PRIVATE aDadosBx9	:= ""
PRIVATE aDados		:= {}							// Array com os dados .
PRIVATE aCab		:= {}						// Array com os dados do cabecario Relatorio
PRIVATE aTipoCab   	:= {}							// Array com os dados do banco
PRIVATE nMaxLin		:= 56
PRIVATE aRet 		:= {}
PRIVATE cPathSrvJ		:=  GETMV("MV_RELT")
PRIVATE lRetW			:=.F.

DEFAULT lWeb			:= .F.

If ! PLSRelTop()
	Return .F.
Endif

aAlias := {"BA3","BA1","BQC","BG9"} 
objCENFUNLGP:setAlias(aAlias) 


aAdd( aPergs,{ 1, "Operadora"				, Space(4)  , "", "NaoVazio()", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Grupo Empresa De"		, Space(4)  , "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Grupo Empresa Ate"		, Space(4) 	, "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Contrato De"				, Space(12)	, "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Contrato Ate"			, Space(12) , "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Versao Contrato De"		, Space(3)  , "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Versao Contrato Ate"		, Space(3)  , "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Subcontrato De"			, Space(9) 	, "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Subcontrato Ate"			, Space(9) 	, "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Versao SubCont. De"		, Space(3)  , "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Versao SubCont. Ate"		, Space(3) 	, "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Familia De"				, Space(6)  , "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Familia Ate"				, Space(6)  , "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Usuario De"				, Space(2) 	, "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Usuario Ate"				, Space(2) 	, "", "", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Ano De"					, Space(4)  , "", "PLSR996Vld(2)", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Ano Ate"					, Space(4)  , "", "PLSR996Vld(4)", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Mes De"					, Space(2) 	, "", "PLSR996Vld(1)", ""		, "", 0, .f.})
aAdd( aPergs,{ 1, "Mes Ate"					, Space(2) 	, "", "PLSR996Vld(3)", ""		, "", 0, .f.})
aAdd( aPergs,{ 2, "Tipo"					, 2		   	, aTipo		, 50, ""		, .f.})
aAdd( aPergs,{ 2, "Sintetico/Analitico"		, 1 		, aAnaliSt	, 50, ""		, .f.})
aAdd( aPergs,{ 2, "Cliente RN 309"			, 2 		, aRn309 	, 50, ""		, .f.})

if (paramBox( aPergs,"Parametros",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSR996',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	
	oReport := reportDef(aFilter)
	oReport:printDialog()
	freeObj(oReport)
endif



return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR996
Relatório de Sinistralidade
@author César Almeida	
@since 13/05/2022
@version P12
/*/
//-------------------------------------------------------------------

Static Function ReportDef(aFilter)

local oReport	    := nil
local oEMP			:= nil
local oMESANO		:= nil
local cDesc1		:= "Sinistralidade"
local cDesc2		:= ""
local nCtaFor1		:= 0
local cCol			:= ""
local aQtdMes		:= {}
Local oBreak

CalcMes(aQtdMes)

oReport := TReport():new("PLSR996",cDesc1,,{|oReport| ReportPrint(oReport,aFilter)})
oReport:setTotalInLine(.T.)
//oReport:oPage:SetPaperSize(9)
oReport:setLandscape()

oEMP := TRSection():new(oReport, cDesc1, {"EMP"},NIL,.f.,.t.)
oEMP:SetAutoSize(.T.)
TRCell():new(oEMP,"Empresa"	,"EMP","Descrição", , )
oEMP:Cell("Empresa"):SetHeaderAlign("LEFT")

oMESANO := TRSection():new(oReport, cDesc1, {"MESANO"},,.f.,.t.)
oMESANO:SetAutoSize(.T.)
TRCell():new(oMESANO,"Nivel"       	,"MESANO", "Nivel"     		, , )
TRCell():new(oMESANO,"Tipo"			,"MESANO", "Tipo"       	, , )

// A quantidade de colunas é definida a partir do pergunte
For nCtaFor1 := 1 to len(aQtdMes)
	if nCtaFor1 == 1 .OR. nCtaFor1 == 2 .OR. nCtaFor1 ==3
		loop
	else
		cDesc2 := Space(6) +aQtdMes[nCtaFor1][1]
		cCol	:= "MES" + cValtoChar(nCtaFor1)
		TRCell():new(oMESANO,cCol	        ,"MESANO",cDesc2	 	,"@E 9,999,999,999.99" , 14)	
		oMESANO:Cell(cCol):SetHeaderAlign("RIGHT")	
	endif			
Next nCtaFor1

oEMP:SetPageBreak(.T.)
oEMP:SetTotalText(" ")

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR996
Relatório de Sinistralidade
@author César Almeida	
@since 13/05/2022
@version P12
/*/
//-------------------------------------------------------------------

static function ReportPrint(oReport,aFilter)

local oEMP			:= oReport:section(1)
local oMESANO		:= oReport:section(2)
local nCtaFor		:= 0
local nCtaLn		:= 0
local cdados 		:= ""
local ndados 		:= 0
Local nCtaFor1		:= ""
//Local nLin			:=80
Local dDataDe		:= cTod('')
Local dDataAte  	:= cTod('')
Local nCtaFor1		:=0
Local lRel			:=.T.
Local cSql    		:= ""
Local cBA1Name		:= RetSqlName("BA1")
Local cBA3Name		:= RetSqlName("BA3")
Local cBQCName		:= RetSqlName("BQC")
Local nCtaFor   	:= 1
Local cdados		:= ""
Local nCtaLn		:= 0
Local cCodEmp 		:=	""
Local cConEmp 		:=	""
Local cVerCon 		:=	""
Local cSubCon 		:=	""
Local cVerSub 		:=	""
Local cFamDe  		:=	""
Local cTipreg 		:=	""
Local cAno 	  		:= 	""
Local cAnoAte 		:= 	""
Local cMes 	  		:= 	""
Local cMesAte		:=	""
Local cAliasCab		:=	""
Local cCodEmpAnt 	:=	""
Local cConEmpAnt 	:=	""
Local cVerConAnt 	:=	""
Local cSubConAnt 	:=	""
Local cVerSubAnt 	:=	""
Local cCodOpeAnt 	:=	""
Local cFamDeAnt  	:=	""
Local cTipregAnt 	:=	""
Local lret			:=	.F.
Local lrt			:=.t.
Local cNomUsr		:=	""
local lFirst		:= .f.
Private cQbr1 		:= "",  cQbr2 := ""


//Trata parambox
cPar20 := MV_PAR20
cPar21 := MV_PAR21
cPar22 := MV_PAR22

if cvaltochar(cPar20) == "1- Fisica"
	MV_PAR20 := 1
endif

if cvaltochar(cPar21) == "2- Analitico"
	MV_PAR21 := 2
endif

if cvaltochar(cPar22) == "1- Sim"
	MV_PAR22 := 1
endif
	
If Select("QRY") > 0
	Dbselectarea("QRY")
	QRY->(DbClosearea())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Select BA1																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lAutoSt .Or. mv_par21 == iif (lWeb,cvaltochar(2),2)  // Opção Detalhado
	cSql := "SELECT BA3_CODINT, BA3_CODEMP, BA3_CONEMP,BA3_VERCON, BA3_SUBCON, BA3_VERSUB,BA3_MATRIC,BA1_TIPREG BA3_TIPREG ,BA1_NOMUSR BA3_NOMUSR  FROM "+cBA3Name + " BA3 "
	cSql += " JOIN " + RetSQLName("BA1") + " BA1 "
	cSql += " ON BA1_FILIAL = '" + xFilial("BA1") + "' AND "
	cSql += "    BA1_CODINT = BA3_CODINT AND "
	cSql += "    BA1_CODEMP = BA3_CODEMP AND "
	cSql += "    BA1_MATRIC = BA3_MATRIC AND "
	cSql += "    BA1.D_E_L_E_T_ <> '*' "
	
	If (!Empty(mv_par14) .or.  !Empty(mv_par15))
		cSql += "  AND BA1_TIPREG >= '"+cvaltochar(mv_par14)+"' AND BA1_TIPREG <= '"+cvaltochar(mv_par15)+"'  "
	Endif

	If (mv_par22 == 1 .AND. mv_par20 ==2) //Cliente RN 309 e Pessoa Jurídica
	
		cSql += "    	INNER JOIN " + RetSQLName("BQC") + " BQC " 
		cSql += "    	ON 		BQC_FILIAL	= '" + xFilial("BQC") + " ' 
		cSql += "    	AND		BQC_CODINT = BA3.BA3_CODINT  
		cSql += "    	AND		BQC_CODEMP = BA3.BA3_CODEMP  
		cSql += "    	AND		BQC_NUMCON = BA3.BA3_CONEMP  
		cSql += "    	AND		BQC_VERCON = BA3.BA3_VERCON  
		cSql += "    	AND		BQC_SUBCON = BA3.BA3_SUBCON  
		cSql += "    	AND		BQC_VERSUB = BA3.BA3_VERSUB  
		cSql += " 		AND		BQC.BQC_CIE309 = '"+cvaltochar(mv_par22)+"' "
		cSql += "    	AND		BQC.D_E_L_E_T_ = ' ' 

	Endif	   
	
	cSql += " WHERE BA3_FILIAL = '"+xFilial("BA3")+"' "
	cSql += " AND BA3_CODINT = '"+mv_par01+"' "
	cSql += " AND BA3_CODEMP >= '"+mv_par02+"' "
	cSql += " AND BA3_CODEMP <= '"+mv_par03+"' "
	cSql += " AND BA3_TIPOUS = '"+alltrim(str(mv_par20))+"' "
	
	If mv_par20 ==2 //Pessoa Juridica
		If (!Empty(mv_par04) .or.  !Empty(mv_par05))
			cSql += "  AND BA3_CONEMP >= '"+cvaltochar(mv_par04)+"' AND BA3_CONEMP <= '"+cvaltochar(mv_par05)+"'  "
		Endif
		If (!Empty(mv_par06) .or.  !Empty(mv_par07))
			cSql += "  AND BA3_VERCON >= '"+cvaltochar(mv_par06)+"' AND BA3_VERCON <= '"+cvaltochar(mv_par07)+"'  "
		Endif
		If (!Empty(mv_par08) .or.  !Empty(mv_par09))
			cSql += "  AND BA3_SUBCON >= '"+cvaltochar(mv_par08)+"' AND BA3_SUBCON <= '"+cvaltochar(mv_par09)+"'  "
		Endif
		If (!Empty(mv_par10) .or.  !Empty(mv_par11))
			cSql += "  AND BA3_VERSUB >= '"+cvaltochar(mv_par10)+"' AND BA3_VERSUB <= '"+cvaltochar(mv_par11)+"'  "
		Endif
	Endif
	
	If (!Empty(mv_par12) .or.  !Empty(mv_par13))
		cSql += "  AND BA3_MATRIC >= '"+cvaltochar(mv_par12)+"' AND BA3_MATRIC <= '"+cvaltochar(mv_par13)+"'  "
	Endif
	
	cSql += "  AND BA3.D_E_L_E_T_ = ' ' "
	cSql += "  ORDER BY BA3_CODINT, BA3_CODEMP, BA3_CONEMP,BA3_VERCON, BA3_SUBCON, BA3_VERSUB,BA3_MATRIC,BA1_TIPREG"
	cSql := ChangeQuery(cSql)
	
	TCQUERY cSQL NEW ALIAS "QRY"
	DbSelectArea("QRY")
	cAliasCab:="BA3"
	
Else  // opção Resumido
	
	If  mv_par20 ==2  //Juridica
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Select BQC																	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSql := "SELECT BQC_CODINT,BQC_CODEMP, BQC_NUMCON BQC_CONEMP ,BQC_VERCON,BQC_SUBCON,BQC_VERSUB,'' BQC_MATRIC,'' BQC_TIPREG,BQC_DESCRI BQC_NOMUSR FROM "+cBQCName+" BQC WHERE BQC_FILIAL = '"+xFilial("BQC")+"' "
		cSql += "  AND BQC.D_E_L_E_T_ <> '*' "
		cSql += "  AND BQC_CODINT = '" + mv_par01 + "' "
		cSQL += "  AND BQC_CODEMP >= '"+cvaltochar(mv_par02)+"' AND BQC_CODEMP <= '"+cvaltochar(mv_par03)+"'  "
		cSQL += "  AND BQC_VERCON >= '"+cvaltochar(mv_par06)+"' AND BQC_VERCON <= '"+cvaltochar(mv_par07)+"'  "
		cSQL += "  AND BQC_SUBCON >= '"+cvaltochar(mv_par08)+"' AND BQC_SUBCON <= '"+cvaltochar(mv_par09)+"'  "
		cSQL += "  AND BQC_VERSUB >= '"+cvaltochar(mv_par10)+"' AND BQC_VERSUB <= '"+cvaltochar(mv_par11)+"'  "

		If mv_par22 == 1
			cSQL += " AND		BQC.BQC_CIE309 = '"+cvaltochar(mv_par22)+"' " //Cliente RN 309
		Endif

		CSQL += "  ORDER BY BQC_CODINT,BQC_CODEMP,BQC_NUMCON,BQC_VERCON,BQC_SUBCON,BQC_VERSUB"
		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "QRY"
		DbSelectArea("QRY")
		cAliasCab:="BQC"
		
	Else   // Fisica
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Select BG9																	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cSql := "SELECT BG9_CODINT,BG9_CODIGO BG9_CODEMP, '' BG9_CONEMP ,'' BG9_VERCON,'' BG9_SUBCON,'' BG9_VERSUB,'' BG9_MATRIC,'' BG9_TIPREG,BG9_DESCRI BG9_NOMUSR"
		cSql += "FROM "+RetSQLName("BG9")+" BG9
		cSql += "    WHERE  BG9.BG9_FILIAL = '"  + xFilial("BG9") + "'"
		cSql += "    AND BG9.BG9_CODINT = '"  + mv_par01  + "'"
		cSql += "    AND BG9.D_E_L_E_T_ <> '*' "
		cSql += " 	 AND BG9_TIPO = '"+alltrim((cvaltochar(mv_par21)))+"' "
		cSql += "ORDER BY BG9_CODINT,BG9_CODIGO"
		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "QRY"
		DbSelectArea("QRY")
		cAliasCab:="BG9"
		
	Endif
	
Endif

cAno 	:= mv_par16
cAnoAte := mv_par17
cMes 	:= mv_par18
cMesAte	:= mv_par19

DbGoTop()

//Retirado return **Return({.F.,STR0023,cPathSrvJ+wnrel+".##R"})** 
If EOF()

	QRY->(DbCloseArea())	
	
	Return	
EndIF

While QRY->(!EOF())

	If oReport:Cancel()
		Exit
	EndIf
	
	IF 	(cCodEmpAnt <> &(QRY->(cAliasCab+"_CODEMP")) .or. cConEmpAnt <> &(QRY->(cAliasCab+"_CONEMP")) .or. ;
		cVerConAnt <> &(QRY->(cAliasCab+"_VERCON")) .or.  cSubConAnt <> &(QRY->(cAliasCab+"_SUBCON")) .or. ;
		cVerSubAnt <> &(QRY->(cAliasCab+"_VERSUB")) .or.  cFamDeAnt  <> &(QRY->(cAliasCab+"_MATRIC")) .or. ;
		cTipregAnt <> &(QRY->(cAliasCab+"_TIPREG"))  )
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Buscando Informações do Relatorio no Fonte PLSA790                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodEmp := Alltrim(&(QRY->(cAliasCab+"_CODEMP")))
		cVerCon := Alltrim(&(QRY->(cAliasCab+"_VERCON")))
		cSubCon := Alltrim(&(QRY->(cAliasCab+"_SUBCON")))
		cVerSub := Alltrim(&(QRY->(cAliasCab+"_VERSUB")))
		cCodOpe := Alltrim(&(QRY->(cAliasCab+"_CODINT")))
		cConEmp := Alltrim(&(QRY->(cAliasCab+"_CONEMP")))
		cFamDe  := Alltrim(&(QRY->(cAliasCab+"_MATRIC")))
		cTipreg := Alltrim(&(QRY->(cAliasCab+"_TIPREG")))
		cNomUsr := Alltrim(&(QRY->(cAliasCab+"_NOMUSR")))
		
		If mv_par20 ==2 //pessoa Juridica
			If lAutoSt .Or. mv_par21 == iif (lWeb,cvaltochar(1),1)
				//cAliasCab = "BQC"
				cDesc1:= 	STR0007 + objCENFUNLGP:verCamNPR( cAliasCab+"_CODEMP", cCodEmp ) + " - " + Alltrim(substr(objCENFUNLGP:verCamNPR( "BG9_DESCRI", Posicione("BG9",1,xFilial("BG9")+cCodOpe+cCodEmp,"BG9_DESCRI") ),1,30)) + Space(4) + STR0008 + objCENFUNLGP:verCamNPR( "BQC_NUMCON", cConEmp ) + Space(6) + STR0020 + objCENFUNLGP:verCamNPR( cAliasCab+"_SUBCON", cSubCon ) + " - " + Alltrim(substr(objCENFUNLGP:verCamNPR( "BQC_DESCRI", Posicione("BQC",1,xFilial("BQC")+cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub,"BQC_DESCRI") ),1,30)) //"Empresa :  "/"Contrato : "/"  Subcontrato: "
				
			Else 
				//cAliasCab = "BA3"
				cDesc1:= 	STR0007 + objCENFUNLGP:verCamNPR( cAliasCab+"_CODEMP", cCodEmp ) + " - " + Alltrim(substr( objCENFUNLGP:verCamNPR( "BG9_DESCRI", Posicione("BG9",1,xFilial("BG9")+cCodOpe+cCodEmp,"BG9_DESCRI") ),1,30)) + Space(4) + STR0008 + objCENFUNLGP:verCamNPR( cAliasCab+"_CONEMP", cConEmp ) + Space(6) + STR0020 + objCENFUNLGP:verCamNPR( cAliasCab+"_SUBCON", cSubCon ) + " - " + AllTrim(substr(objCENFUNLGP:verCamNPR( "BQC_DESCRI", Posicione("BQC",1,xFilial("BQC")+cCodOpe+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub,"BQC_DESCRI") ),1,30)) + Space(4) +  STR0009	+ objCENFUNLGP:verCamNPR( cAliasCab+"_MATRIC", cFamDe ) + "-" + objCENFUNLGP:verCamNPR( "BA1_TIPREG", cTipreg ) + " " + substr(objCENFUNLGP:verCamNPR( "BA1_NOMUSR", cNomUsr ),1,30) //" Empresa  "###"  Contrato  "###" Matricula  "
			Endif
		Else
			If lAutoSt .OR.  mv_par21 == iif (lWeb,cvaltochar(1),1)
				//cAliasCab = "BG9"
				cDesc1:= 	STR0007 + objCENFUNLGP:verCamNPR( cAliasCab+"_CODEMP", cCodEmp ) + " - " + Alltrim(substr(objCENFUNLGP:verCamNPR( "BG9_DESCRI", Posicione("BG9",1,xFilial("BG9")+cCodOpe+cCodEmp,"BG9_DESCRI") ),1,30))
				lret:=.T.
			Else 
				//cAliasCab = "BA3"
				cDesc1:= 	STR0007 + objCENFUNLGP:verCamNPR( cAliasCab+"_CODEMP", cCodEmp ) + " - " + Alltrim(substr(objCENFUNLGP:verCamNPR( "BG9_DESCRI", Posicione("BG9",1,xFilial("BG9")+cCodOpe+cCodEmp,"BG9_DESCRI") ),1,30))  + Space(6) + STR0009 + objCENFUNLGP:verCamNPR( cAliasCab+"_MATRIC", cFamDe ) + "-" + objCENFUNLGP:verCamNPR( "BA1_TIPREG", cTipreg ) + " " + substr(objCENFUNLGP:verCamNPR( "BA1_NOMUSR", cNomUsr ),1,30) //" Grupo Empresa  "###"  Empresa  "###" Matricula  "
			Endif
		Endif

		/*if oReport:page() == 1
			oReport:setTitle("Sinistralidade")
		endIf

		oReport:onPageBreak({|| oReport:setTitle("Sinistralidade"),.T.} )*/

		//define regua
		oReport:setMeter(0)
		
		
		oEMP:init()
		oReport:incMeter()
		oEMP:cell("Empresa"):setValue(cDesc1)
		oEMP:printLine()
				
		
		aDadosBx9:=PLS790BX9(dDataDe,dDataAte,cAlias,cAliasCab,cCodOpe ,cCodEmp ,cConEmp ,cVerCon ,cSubCon ,cVerSub,cFamDe ,cTipreg,cAno ,cAnoAte ,cMes,cMesAte,lRel )
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define variaveis...                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDados		:=aDadosBx9[1]
		aCab		:=aDadosBx9[2]
		aTipoCab	:=aDadosBx9[3]

		For nCtaFor = 1 to Len(adados)
			oReport:incMeter()
			oMESANO:init()
			
			For nCtaLn := 1 to len(adados[nCtaLn])

				If Valtype(aDados[nCtaFor, nCtaLn] )=="C"
					cdados := PadR((iif(empty(aDados[nCtaFor, nCtaLn]),space(len(aDados[nCtaFor, nCtaLn])),aDados[nCtaFor, nCtaLn])),15)

					if  EMPTY(cdados) .OR. AT("Empresa",cdados) > 0 .OR. AT("Sub",cdados) > 0 .OR. AT("Contrato",cdados) > 0 .OR. AT("Familia", cdados) .OR. AT("Beneficiário",cdados)
						oMESANO:cell("Nivel"):setValue(cdados)
					else 
						oMESANO:cell("Tipo"):setValue(cdados)	
					endif

				ElseIf Valtype(aDados[nCtaFor, nCtaLn] )=="U" .and. nCtaLn ==1
					ndados := Padl("",15)
				ElseIf Valtype(aDados[nCtaFor, nCtaLn] )=="U"
					ndados := 0
				Else
					If nCtaLn==3
						loop
					Else
						ndados := aDados[nCtaFor, nCtaLn]
					Endif
				Endif

				//setar o valor de acordo com as colunas criadas a partir do ReportDef
				// A quantidade de colunas é definida a partir do pergunte
				if	Valtype(aDados[nCtaFor, nCtaLn] )!="C"
					for nCtaFor1 := nCtaLn to len(aCab)
						If nCtaFor1==1 .OR. nCtaFor1==2 .OR. nCtaFor1==3
							loop
						Else
							cCol	:= "MES" + cValtoChar(nCtaFor1)
							oMESANO:cell(cCol):setValue(ndados)
						endif
					next nCtaFor1	
				endif
				cdados:=""
				
			Next nCtaLn
				
				oMESANO:printLine()		
				
		Next nCtaFor
		
		oMESANO:finish()
		oReport:SkipLine()
		oReport:ThinLine()
		oEMP:Finish()
		
	Endif

	DbSelectArea("QRY")
	
	cCodEmpAnt := &(QRY->(cAliasCab+"_CODEMP"))
	cVerConAnt := &(QRY->(cAliasCab+"_VERCON"))
	cSubConAnt := &(QRY->(cAliasCab+"_SUBCON"))
	cVerSubAnt := &(QRY->(cAliasCab+"_VERSUB"))
	cFamDeAnt  := &(QRY->(cAliasCab+"_MATRIC"))
	cTipregAnt := &(QRY->(cAliasCab+"_TIPREG"))
	
	DbSkip()
	
Enddo

QRY->( DbCloseArea() )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PLSR9960Vld  ³ Autor ³ 			        ³ Data ³ 04.01.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Valida mes e ano informado.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

Function PLSR996Vld(nVld)
LOCAL lRet := .T.

If     nVld == 1 //Mes De
	If Alltrim(Upper(mv_par18)) == "ZZ" .Or. Empty(mv_par18) .Or. (mv_par18 > mv_par19 .And. ! empty(mv_par19)) .Or. mv_par18 < "01" .Or. mv_par18 > "12"
		MsgStop("'"+STR0010+"' "+STR0011) //"Mes De"###"Invalido"
		lRet := .F.
	Endif
ElseIf nVld == 2 //Ano De
	If Alltrim(Upper(mv_par16)) == "ZZZZ" .Or. Empty(mv_par16) .Or. (mv_par18 > mv_par19 .And. ! empty(mv_par19))
		MsgStop("'"+STR0012+"' "+STR0011)  //"Ano De"###"Invalido"
		lRet := .F.
	Endif
	
	If ( val(mv_par16) / 1000 ) < 1
		MsgStop(STR0013)  //"Ano Invalido"
		lRet := .F.
	Endif
ElseIf nVld == 3 //Mes Ate
	If Alltrim(Upper(mv_par19)) == "ZZ" .Or. Empty(mv_par19) .Or. (mv_par19 < mv_par18 .And. ! empty(mv_par19)) .Or. mv_par19 < "01" .Or. mv_par19 > "12"
		MsgStop("'"+STR0014+"' "+STR0011)  //"Mes Ate"###"Invalido"
		lRet := .F.
	Endif
ElseIf nVld == 4 //Ano Ate
	If Alltrim(Upper(mv_par17)) == "ZZZZ" .Or. Empty(mv_par17) .Or. (mv_par17 < mv_par16 .And. ! empty(mv_par17))
		MsgStop("'"+STR0015+"' "+STR0011)  //"Ano Ate"###"Invalido"
		lRet := .F.
	Else
		If ( Val(mv_par17) - Val(mv_par16) ) > 1
			MsgStop(STR0016+" '"+STR0012+"' "+STR0017+" '"+STR0015+"' "+STR0018)  //"A diferença entre o"###"Ano De"###"e o"###"Ano Ate"###"nao pode passar de 1 ano."
			lRet := .F.
		Endif
	Endif
	
	If mv_par18+mv_par16 > mv_par19+mv_par17
		MsgStop(STR0019)  //"Mes e Ano De maior que Mes e Ano Ate"
		lRet := .F.
	Endif
	
	If ( val(mv_par17) / 1000 ) < 1
		MsgStop(STR0013)  //"Ano Invalido"
		lRet := .F.
	Endif
Endif

Return(lRet)

function PLSR996Sta(lValor)
lAutoSt := lValor
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ CalcMes  ³ Autor ³ 			        ³ Data ³ 18.05.22  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Calcula quantiade de meses                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

Static Function CalcMes(aQtdMes)

local cAno		:=	""
local cAnoAte 	:= 	""
local cMes		:=	""
local cMesAte	:=	""
local cAnoMes	:=  ""
local cAnoPara 	:= 	""
local aQtdMes	:= {}
local aMeses	:= {{'01','JAN'},;
					{'02','FEV'},;
					{'03','MAR'},;
					{'04','ABR'},;
					{'05','MAI'},;
					{'06','JUN'},;
					{'07','JUL'},;
					{'08','AGO'},;
					{'09','SET'},;
					{'10','OUT'},;
					{'11','NOV'},;
					{'12','DEZ'}}

DEFAULT dDataDe		:= cTod('')
DEFAULT dDataAte  	:= cTod('')

cAno 	:= mv_par16
cAnoAte := mv_par17
cMes 	:= mv_par18
cMesAte	:= mv_par19

cAnoPara:=cAno
cAnoMes := iif(Empty(cAno),Substr(dTos(dDataDe),1,6),cAno+""+cMes)
nMeses  := 0

Aadd(aQtdMes, {'Nivel','@C',40})
Aadd(aQtdMes, {'Tipo' ,'@C',45})
Aadd(aQtdMes, {'Filler', "@E 99", 07} )

While (cAnoMes <= iif(dDataAte==cTod(''),cAnoAte+""+cMesAte,dTos(dDataAte)))

	Aadd( aQtdMes, {Substr(cAnoMes,1,4)+"/"+aMeses[Val(Substr(cAnoMes,5,2))][2], "@E 999,999,999.99", 35} )
	cMes := StrZero((Val(Substr(cAnoMes,5,2)) + 1),2)
	cAno := Substr(cAnoMes,1,4)
	If cMes > '12'
		cMes := '01'
		cAno := Alltrim(Str(Val(Substr(cAnoMes,1,4))+1))
	Endif
	cAnoMes := cAno+cMes
	nMeses++
Enddo
	Aadd( aQtdMes, {"Total", "@E 999,999,999.99", 35} )

Return (aQtdMes)

