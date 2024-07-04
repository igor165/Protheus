#include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "PLSR272.ch"

Static lAutoSt := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR272
Relatorio do Extrato de utilizacao do usuario

@author Renan Sakai
@version P12
@since 16/04/2018
/*/ 
//-------------------------------------------------------------------  
Function PLSR272(lAuto)
Local cPerg     := "PLSR272"

Default lAuto := .F.

Private oReport := Nil
Private cLocDig := space( 250 )
Private cEmp := space( 250 )

lAutoSt := lAuto

Pergunte(cPerg,.F.)

ReportDef()
oReport:PrintDialog()

Return(Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Relatorio do Extrato de utilizacao do usuario

@author Renan Sakai
@version P12
@since 16/04/2018
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local cPerg      := "PLSR272"
Local oOperadora
Local oEmpresa
Local oBeneficiarios

oReport := TReport():New(cPerg,STR0001,cPerg,{|oReport| PrintReport(oReport,oOperadora,oEmpresa,oBeneficiarios)},STR0002)//"Utilização de Beneficiários"##"Impressão de utilização de beneficiários para levantamento de repasse habitual/pós"
oReport:SetLandscape(.T.)

//Operadora
oOperadora := TRSection():New( oReport , STR0003, {"QRY"} ) //"Operadora"
oOperadora:SetHeaderBreak(.T.)	                          //Indica se cabecalho da secao sera impresso em cada quebra 
oOperadora:SetPageBreak(.T.)		                      //Indica quebra de pagina no final da secao
oOperadora:SetHeaderPage(.T.)    	                      //Indica que cabecalho da secao sera impresso no topo da pagina
oOperadora:SetHeaderSection(.F.)                        //Indica se cabecalho da secao sera impresso (padrao)

//Empresa
oEmpresa := TRSection():New( oReport , STR0004, {"QRY"} ) //"Empresa"

//Beneficiarios
oBeneficiarios := TRSection():New( oReport , STR0005, {"QRY"} ) //"Beneficiários"
TRCell():New( oBeneficiarios, "MATRICULA" ,      ,STR0006     ,"@R",30)//"Matrícula"
TRCell():New( oBeneficiarios, "NOMUSR"    , "QRY",STR0007     ,"@R",70)//"Nome"
TRCell():New( oBeneficiarios, "SADT"      , "QRY",STR0008     ,"@E 9999",10)//"Consulta/SADT"
TRCell():New( oBeneficiarios, "INTERN"    , "QRY",STR0009     ,"@E 9999",10) //"Internação"
TRCell():New( oBeneficiarios, "TOTAL"     ,      ,STR0010     ,"@E 9999",10)//"Total"
TRCell():New( oBeneficiarios, "CADAUTO"   ,      ,STR0011     ,"@R",10) //"Cadastro Automático"

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Relatorio do Extrado de utilização do usuário

@author Renan Sakai
@version P12
@since 16/04/2018
/*/  
//------------------------------------------------------------------- 
Static Function PrintReport(oReport,oOperadora,oEmpresa,oBeneficiarios)

Local cSql       := ""
Local cOpeDe     := ""
Local cOpeAte    := ""
Local cOpeRda    := ""     
Local cEmpDe     := ""
Local cEmpAte    := ""
Local cMatricDe  := ""
Local cMatricAte := ""
Local dDataDe
Local dDataAte
Local nCadVigenc := 0
Local nQtdeAtend := 0
Local dVigeIni
Local dVigeFim
Local cEmpExt   := ""

Local aLocDig    := {}
Local cLocNew    := ""
Local nX         := 0

Local oFontOpe :=  TFont():New(oReport:cFontBody,14,14,,.T.,,,,.T.,.F.)
Local oFontEmp :=  TFont():New(oReport:cFontBody,12,12,,.T.,,,,.T.,.F.)

Local (cTabTemp):= getNextAlias() //15-02
Local cTipAdm := ""

cOpeDe     := MV_PAR01
cOpeAte    := MV_PAR02
cEmpDe     := MV_PAR03
cEmpAte    := MV_PAR04
cMatricDe  := MV_PAR05
cMatricAte := MV_PAR06
dDataDe    := MV_PAR07
dDataAte   := MV_PAR08
cLocDig    := MV_PAR09
nCadVigenc := MV_PAR10
nQtdeAtend := MV_PAR11
dVigeIni   := MV_PAR12
dVigeFim   := MV_PAR13
cEmpExt    := strTran( allTrim(MV_PAR14 ),",","','")  + "' "

If nCadVigenc == 2 .And. Empty(dVigeIni) .AND. !lAutoSt
	MsgInfo(STR0012) //"Quando selecionada a opção de cadastro automático, é necessário informar a Vigência Inicial."
	Return
EndIf

If Empty(cLocDig) .AND. !lAutoSt
	MsgInfo(STR0013) //"É necessário informar pelo menos um local de digitação."
	Return
EndIf 

If !Empty(cOpeDe) .And. !Empty(cOpeAte) .And. cOpeDe == cOpeAte
	BAU->(DbSetOrder(7))//BAU_FILIAL+BAU_CODOPE
	If BAU->(MsSeek(xFilial("BAU")+cOpeDe))
		cOpeRda := BAU->BAU_CODIGO
	EndIf	
ElseIf !lAutoSt .AND. !MsgYesNo(STR0014) //"Selecionar múltiplas operadoras pode prejudicar a performance, deseja continuar?"
	Return
EndIf

//necessário trazer  guias que não sejam do tipo urgencia e emergencia 18-02
cSql := " SELECT BDR_CODTAD FROM " +RetSqlName("BDR")
cSql += " WHERE BDR_CARINT <> 'U'"
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cTabTemp,.F.,.T.)

While ! ((cTabTemp))->(eof())
	cTipAdm:= cTipAdm + "'"+ AllTrim((cTabTemp)->BDR_CODTAD) + "',"
	(cTabTemp)->(DbSkip())
EndDo

If !Empty(cTipAdm)
	cTipAdm := "( " +  Substr(cTipAdm, 1, len(cTipAdm) -1) + " )"
EndIf
cSql := "" //18-02

//Ajusta local de digitacao para a Query
aLocDig := strtokarr(AllTrim(cLocDig),",")
For nX = 1 To Len(aLocDig)
	cLocNew += "'" + aLocDig[nX] + "'"
	If nX <> Len(aLocDig)
		cLocNew += ","
	EndIf
Next	
cLocDig := "( " + cLocNew + " )"	

cSql += " SELECT CODOPE, CODEMP, MATRIC, TIPREG, DIGITO, NOMUSR, EMPRESA, "
If Empty(cOpeRda)
	cSql += " BAU_CODOPE, "
EndIf	
cSql += " SUM(QTDSADT) SADT, SUM(QTDINT) INTERN FROM ( "
cSql += " SELECT BD5_OPEUSR CODOPE, "
cSql += "        BD5_CODEMP CODEMP, "
cSql += "        BD5_MATRIC MATRIC, "
cSql += "        BD5_TIPREG TIPREG, "
cSql += "        BD5_DIGITO DIGITO, "
cSql += "        BD5_NOMUSR NOMUSR, "
cSql += "        BD5_CODEMP EMPRESA,
If Empty(cOpeRda)
	cSql += "    BAU_CODOPE BAU_CODOPE, "
EndIf	
cSql += "        1 as QTDSADT, "
cSql += "        0 as QTDINT "
cSql += " FROM "+RetSqlName("BD5")+" BD5 " 
//INNER BAU - se informado somente uma operadora, nao preciso fazer
If Empty(cOpeRda)
	cSql += " INNER JOIN "+RetSqlName("BAU")+" BAU " 
	cSql += "      ON ( BAU.BAU_FILIAL = '"+xFilial("BAU")+"' " 
	cSql += "      AND BAU.BAU_CODIGO = BD5.BD5_CODRDA " 
	cSql += "      AND BAU.BAU_CODOPE BETWEEN '"+cOpeDe+"' AND '"+cOpeAte+"' "  
	cSql += "      AND BAU.BAU_CODOPE <> ' ' "  
	cSql += "      AND BAU.D_E_L_E_T_ = ' ' ) "
EndIf
//INNER BG9
cSql += " INNER JOIN "+RetSqlName("BG9")+" BG9 " 
cSql += "      ON ( BG9.BG9_FILIAL = '"+xFilial("BG9")+"' " 
cSql += "      AND BG9.BG9_CODINT = BD5.BD5_CODOPE "
cSql += "      AND BG9.BG9_CODIGO = BD5.BD5_CODEMP "
cSql += "      AND BG9.BG9_TIPO = '2' " 
cSql += "      AND BG9.D_E_L_E_T_ = ' ' ) "     

//INNER BAX
cSql += " INNER JOIN (SELECT BAX_FILIAL, BAX_CODESP, MIN(BAX_DATBLO)BAX_DATBLO, MIN(BAX_DATINC) BAX_DATINC FROM " + RetSqlName("BAX") + " BAX " 
cSQl += " WHERE BAX.BAX_FILIAL = '"+xFilial("BAX")+" ' "
cSQl += " AND BAX.D_E_L_E_T_ = ' ' "
cSQl += " GROUP BY  BAX_FILIAL, BAX_CODESP) TMP2"
cSql += "      ON( TMP2.BAX_CODESP  = BD5.BD5_CODESP " 
cSql += "      AND (BD5.BD5_DATPRO <= TMP2.BAX_DATBLO OR TMP2.BAX_DATBLO = ' ' )"
cSql += "      AND BD5.BD5_DATPRO >= TMP2.BAX_DATINC) "
 

cSql += " WHERE BD5_FILIAL = '"+xFilial("BD5")+"' " 
//Filtro de empresa
cSql += "     AND BD5_CODOPE = '"+PlsIntPad()+"' " 
if !lAutoSt
	cSql += "     AND BD5_CODLDP IN " + cLocDig
	//filtro do tipo de guia
	cSql += " AND BD5_TIPADM IN " + cTipAdm //18-02
endif

If !Empty(cOpeRda)
	cSql += "  AND BD5_CODRDA = '"+ cOpeRda+"' " 
EndIf
cSql += "     AND BD5_CODEMP BETWEEN '"+cEmpDe+"' AND '"+cEmpAte+"' " 
//Filtro por matricula
cSql += "     AND BD5_OPEUSR BETWEEN '"+Substr(cMatricDe,1,4)+"' AND '"+Substr(cMatricAte,1,4)+"' "  
cSql += "     AND BD5_CODEMP BETWEEN '"+Substr(cMatricDe,5,4)+"' AND '"+Substr(cMatricAte,5,4)+"' "  
cSql += "     AND BD5_MATRIC BETWEEN '"+Substr(cMatricDe,9,6)+"' AND '"+Substr(cMatricAte,9,6)+"' "  
cSql += "     AND BD5_TIPREG BETWEEN '"+Substr(cMatricDe,15,2)+"' AND '"+Substr(cMatricAte,15,2)+"' " 
cSql += "     AND BD5_DIGITO BETWEEN '"+Substr(cMatricDe,17,1)+"' AND '"+Substr(cMatricAte,17,1)+"' " 
//Filtros gerais da guia
cSql += "     AND BD5_SEQIMP <> ' ' "  
cSql += "     AND BD5_SITUAC <> '2' "
cSql += "     AND BD5_TIPGUI NOT IN ('04','10') "
cSql += "     AND BD5_DATPRO BETWEEN '"+Dtos(dDataDe)+"' AND '"+Dtos(dDataAte)+"' " 
If !Empty(cEmpExt) .AND. !lAutoSt
	cSql += " AND BD5_CODEMP NOT IN ( '" + cEmpExt +") "
EndIf
cSql += "     AND BD5_GUESTO = ' '  "
cSql += "     AND BD5.D_E_L_E_T_ = ' ' " 

cSql += " UNION ALL " 
cSql += " SELECT BE4_OPEUSR CODOPE, "
cSql += "        BE4_CODEMP CODEMP, " 
cSql += "        BE4_MATRIC MATRIC, " 
cSql += "        BE4_TIPREG TIPREG, " 
cSql += "        BE4_DIGITO DIGITO, " 
cSql += "        BE4_NOMUSR NOMUSR, "
cSql += "        BE4_CODEMP EMPRESA, "
If Empty(cOpeRda)
	cSql += "    BAU_CODOPE BAU_CODOPE, "
EndIf	
cSql += "        0 as QTDSADT, " 
cSql += "        1 as QTDINT "  
cSql += " FROM "+RetSqlName("BE4")+" BE4 " 
//INNER BAU - se informado somente uma operadora, nao preciso fazer
If Empty(cOpeRda)
	cSql += " INNER JOIN "+RetSqlName("BAU")+" BAU " 
	cSql += " ON ( "
	cSql += "      BAU.BAU_FILIAL = '"+xFilial("BAU")+"' " 
	cSql += "      AND BAU.BAU_CODIGO = BE4.BE4_CODRDA " 
	cSql += "      AND BAU.BAU_CODOPE BETWEEN '"+cOpeDe+"' AND '"+cOpeAte+"' "   
	cSql += "      AND BAU.BAU_CODOPE <> ' ' " 
	cSql += "      AND BAU.D_E_L_E_T_ = ' ' ) " 
EndIf
//INNER BG9
cSql += " INNER JOIN "+RetSqlName("BG9")+" BG9 " 
cSql += "      ON ( BG9.BG9_FILIAL = '"+xFilial("BG9")+"' " 
cSql += "      AND BG9.BG9_CODINT = BE4.BE4_CODOPE "
cSql += "      AND BG9.BG9_CODIGO = BE4.BE4_CODEMP "
cSql += "      AND BG9.BG9_TIPO = '2' " 
cSql += "      AND BG9.D_E_L_E_T_ = ' ' ) "     

//INNER BAX
cSql += " INNER JOIN (SELECT BAX_FILIAL, BAX_CODESP, MIN(BAX_DATBLO)BAX_DATBLO, MIN(BAX_DATINC) BAX_DATINC FROM " + RetSqlName("BAX") + " BAX " 
cSQl += " WHERE BAX.BAX_FILIAL = '"+xFilial("BAX")+" ' "
cSQl += " AND BAX.D_E_L_E_T_ = ' ' "
cSQl += " GROUP BY  BAX_FILIAL, BAX_CODESP) TMP2"
cSql += "      ON (TMP2.BAX_CODESP  = BE4.BE4_CODESP " 
cSql += "      AND (BE4.BE4_DATPRO <= TMP2.BAX_DATBLO OR TMP2.BAX_DATBLO = ' ' )"
cSql += "      AND BE4.BE4_DATPRO >= TMP2.BAX_DATINC) "



cSql += " WHERE BE4_FILIAL = '"+xFilial("BE4")+"' " 
//Filtro por empresa
cSql += " AND BE4_CODOPE = '"+PlsIntPad()+"' "
if !lAutoSt
	//Filtro por tipo de guia
	cSql += " AND BE4_TIPADM IN " + cTipAdm
endif

If !Empty(cOpeRda)
	cSql += " AND BE4_CODRDA = '"+ cOpeRda+"' " 
EndIf
if !lAutoSt
	cSql += " AND BE4_CODLDP IN " + cLocDig 
endif
//Filtro por matricula
cSql += " AND BE4_OPEUSR BETWEEN '"+Substr(cMatricDe,1,4)+"' AND '"+Substr(cMatricAte,1,4)+"' "  
cSql += " AND BE4_CODEMP BETWEEN '"+Substr(cMatricDe,5,4)+"' AND '"+Substr(cMatricAte,5,4)+"' "  
cSql += " AND BE4_MATRIC BETWEEN '"+Substr(cMatricDe,9,6)+"' AND '"+Substr(cMatricAte,9,6)+"' "  
cSql += " AND BE4_TIPREG BETWEEN '"+Substr(cMatricDe,15,2)+"' AND '"+Substr(cMatricAte,15,2)+"' " 
cSql += " AND BE4_DIGITO BETWEEN '"+Substr(cMatricDe,17,1)+"' AND '"+Substr(cMatricAte,17,1)+"' " 
//Filtros gerais da guia
cSql += " AND BE4_SEQIMP <> ' ' "  
cSql += " AND BE4_CANCEL <> '1' "  
cSql += " AND BE4_TIPGUI <> '03' "
cSql += " AND BE4_CODEMP BETWEEN '"+cEmpDe+"' AND '"+cEmpAte+"' " 
cSql += " AND BE4_DATPRO BETWEEN '"+Dtos(dDataDe)+"' AND '"+Dtos(dDataAte)+"' " 
If !lAutoSt .AND. !Empty(cEmpExt)
	cSql += " AND BE4_CODEMP NOT IN ( '" + cEmpExt +") "
EndIf
cSql += " AND BE4_GUESTO = ' ' "

cSql += " AND BE4.D_E_L_E_T_ = ' ' " 

cSql += " ) TOTAL " 
cSql += " GROUP BY "
If Empty(cOpeRda)
	cSql += "BAU_CODOPE,"
EndIf	
cSql += "EMPRESA,CODOPE,CODEMP,MATRIC,TIPREG,DIGITO,NOMUSR "
cSql += " ORDER BY "
If Empty(cOpeRda)
	cSql += "BAU_CODOPE,"
EndIf	
cSql += "EMPRESA,CODOPE,CODEMP,MATRIC,TIPREG,DIGITO,NOMUSR "

cSQL := ChangeQuery(cSQL)

//Fecha area aberta
If Select("QRY") > 0
	Dbselectarea("QRY")
	QRY->(DbClosearea())
EndIf

TcQuery cSQL New Alias "QRY"

cCodOpe  := ""
cEmpresa := "" 
lSecOpen := .F.

While !QRY->(Eof()) .and. !oReport:Cancel() 
	If( !lAutoSt .AND. oReport:Cancel() )
		MsgInfo( STR0015 ) //'Processo cancelado pelo usuário'
		exit
	EndIf

	If !Empty(cOpeRda) .Or. QRY->BAU_CODOPE <> cCodOpe	
		BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		If BA0->(MsSeek(xFilial("BA0")+iif(!Empty(cOpeRda),cOpeRda,QRY->BAU_CODOPE)))
			If lSecOpen
				oReport:Section( 1 ):Finish()
			Else
				oReport:SkipLine( 8 )
			EndIf	
			oReport:Section( 1 ):Init()
			
			oReport:PrintText( "",oReport:Row(),010 )
			oReport:SkipLine( 1 )
			
			oReport:Say(oReport:Row(),10,Alltrim(BA0->BA0_NOMINT),oFontOpe)
			
			oReport:SkipLine( 2 )
			oReport:PrintText( STR0017 +iif(!Empty(cOpeRda),cOpeRda,QRY->BAU_CODOPE)+ Space(10)+STR0018+Alltrim(BA0->BA0_CIDADE),oReport:Row(),010 ) //"Codigo: " ## "Municipio: "
			//oReport:PrintText( QRY->BAU_CODOPE+" - "+Alltrim(BA0->BA0_NOMINT),oReport:Row(),010 )

			oReport:SkipLine( 2 )
			oReport:ThinLine()
			
			cCodOpe  := iif(!Empty(cOpeRda),cOpeRda,QRY->BAU_CODOPE)
			cEmpresa := ""
			lSecOpen := .T.
		EndIf	
	EndIf
	
	If QRY->EMPRESA <> cEmpresa
		BG9->(DbSetOrder(1))//BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
		If BG9->(MsSeek(xFilial("BG9")+PlsIntPad()+QRY->EMPRESA))
			If !Empty(cEmpresa)
				oReport:SkipLine( 4 )
				oReport:ThinLine()
				oReport:SkipLine( 1 )
			Else
				oReport:PrintText( "",oReport:Row(),010 )
				oReport:SkipLine( 1 )
			EndIf
			
			oReport:Say(oReport:Row(),10,STR0016 + BG9->BG9_CODIGO +" - "+ Alltrim(BG9->BG9_DESCRI),oFontEmp) //"Empresa: "
			//oReport:PrintText( "Empresa: " + BG9->BG9_CODIGO +" - "+ Alltrim(BG9->BG9_DESCRI),oReport:Row(),010 )
			
			oReport:SkipLine( 2 )
			oReport:ThinLine()
			cEmpresa := QRY->EMPRESA
			
			If lSecOpen
				oReport:Section( 2 ):Finish()
				oReport:Section( 3 ):Finish()
			EndIf	
			oReport:Section( 2 ):Init()
			oReport:Section( 3 ):Init()
		EndIf
	EndIf	
  	
  	cCadAut := STR0021 //"Não"
	//Verifica se cadastra automaticamente o benef habitual
	If nCadVigenc == 2 .And. QRY->SADT+QRY->INTERN >= nQtdeAtend
		cCadAut := grvHabB5F(IIF(!Empty(cOpeRda),cOpeDe,QRY->BAU_CODOPE),CODOPE,CODEMP,MATRIC,TIPREG,DIGITO,dVigeIni,dVigeFim)
	EndIf
  	cMatric := QRY->CODOPE+"."+QRY->CODEMP+"."+QRY->MATRIC+"."+QRY->TIPREG+"-"+QRY->DIGITO
	
	oBeneficiarios:Init()
	oBeneficiarios:cell("MATRICULA"):setValue(cMatric)
	oBeneficiarios:cell("TOTAL"):setValue(QRY->SADT+QRY->INTERN)
	oBeneficiarios:cell("CADAUTO"):setValue(cCadAut)
	oBeneficiarios:PrintLine()		

	QRY->(DbSkip())
	
EndDo	


Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} grvHabB5F
Relatorio do Extrato de utilização do usuário

@author Renan Sakai
@version P12
@since 16/04/2018
/*/  
//------------------------------------------------------------------- 
Static Function grvHabB5F(cOpeHab,cCodOpe,cCodEmp,cMatric,cTipReg,cDigito,dVigeIni,dVigeFim)
Local cCadAut := STR0019 //"Já cadastrado"

B5F->(DbSetOrder(1))//B5F_FILIAL+B5F_OPEORI+B5F_OPEHAB+B5F_CODINT+B5F_CODEMP+B5F_MATRIC+B5F_TIPREG+B5F_DIGITO+B5F_VIGINI
If !B5F->(MsSeek(xFilial("B5F")+PlsIntPad()+cOpeHab+cCodOpe+cCodEmp+cMatric+cTipReg+cDigito+dtos(dVigeIni)))
	B5F->(RecLock("B5F",.T.))
	B5F->B5F_FILIAL := xFilial('B5F') 
	B5F->B5F_OPEORI := PlsIntPad()
	B5F->B5F_OPEHAB := cOpeHab
	B5F->B5F_CODINT := cCodOpe
	B5F->B5F_CODEMP := cCodEmp
	B5F->B5F_MATRIC := cMatric
	B5F->B5F_TIPREG := cTipReg
	B5F->B5F_DIGITO := cDigito        
	B5F->B5F_VIGINI := dVigeIni
	B5F->B5F_VIGFIM := dVigeFim
	B5F->B5F_STATUS :=  "1"      
	B5F->(MsUnLock())
	cCadAut := STR0020 //"Sim"
EndIf	

Return cCadAut

//-------------------------------------------------------------------
/*/{Protheus.doc} PL272Emp
F3 da listagem das Empresas

@author  Roberto Barbosa
@version P12
@since   01/03/19
/*/
//-------------------------------------------------------------------
Function PL272Emp(cDado)

	Static objCENFUNLGP := CENFUNLGP():New()

Local oDlg		:= Nil
Local cSql		:= ""
Local aConjunto	:= {}
Local nFor		:= 0
Local nOpc		:= 0
Local bOK		:= { || nOpc := 1, oDlg:End() }
Local bCancel	:= { || oDlg:End() }
Default cDado	:= ''

cSql := " SELECT BG9_CODIGO, BG9_DESCRI"
cSql += "   FROM "+ RetSQLName("BG9")
cSql += "  WHERE BG9_FILIAL = '" + xFilial("BG9") + "' "
cSql += "  	 AND D_E_L_E_T_ <> '*' ORDER BY BG9_CODIGO"

cStm := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStm),"TRB",.F.,.T.)

While !TRB->( Eof() )
	aAdd( aConjunto , { TRB->BG9_CODIGO,TRB->BG9_DESCRI,.F. } )
	TRB->( DbSkip() )
EndDo
TRB->( DbCloseArea() )

DEFINE MSDIALOG oDlg TITLE 'Empresas a desconsiderar' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()
@ 020,012 SAY oSay PROMPT 'Selecione as empresas que não serão processadas' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
oConjunto:AddColumn(TcColumn():New(" "			,{ || IF(aConjunto[oConjunto:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) }	,"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))     
oConjunto:AddColumn(TcColumn():New('Codigo'		,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
oConjunto:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,2]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F.,"BG9_CODIGO","BG9_DESCRI"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oConjunto:aObfuscatedCols := aBls
	endif

oConjunto:SetArray(aConjunto)         
oConjunto:bLDblClick := { || aConjunto[oConjunto:nAt,3] := Eval( { || nIteMar := 0, aEval(aConjunto, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 50 .Or. aConjunto[oConjunto:nAt, 3],IF(aConjunto[oConjunto:nAt,3],.F.,.T.),.F.) })}
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpc == 1
                  
   cDado := ""
   For nFor := 1 To Len(aConjunto)
       If aConjunto[nFor,3]
          cDado += aConjunto[nFor,1]+","
       Endif 
   Next

Endif
                                  
//Tira a virgula do final
If Subs(cDado,Len(cDado),1) == ","
	cDado := Subs(cDado,1,Len(cDado)-1)
EndIf 

Return .T.
