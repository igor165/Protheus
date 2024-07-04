#INCLUDE "PROTHEUS.CH"
#INCLUDE "ATFA175.CH" 
#Include "ApWizard.ch"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipos de a็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE ATIVACAO	1
#DEFINE TERMINO		2

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipos de sele็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE RANGE		1
#DEFINE ENTIDADE	2

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipos de aceleracao de depreciacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE TURNO		1
#DEFINE PERCENTUAL	2 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipos de turnoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE NORMAL 		1
#DEFINE DUPLO 		2 
//ฺฤฤฤฤฤฤฤฟ
//ณWizardsณ
//ภฤฤฤฤฤฤฤู
#DEFINE INTRODUCAO			1
#DEFINE SEL_MODO			2
#DEFINE PAR_ATIVACAO		3
#DEFINE SEL_SELECAO			4
#DEFINE PAR_RANGE	 		5
#DEFINE PAR_ENTIDADE		6
#DEFINE PROCESSAMENTO		7

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณContabiliza็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE SIM			1
#DEFINE NAO			2

Static lMultMoed := .T.

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA175   บAutor  ณAlvaro Camillo Neto บ Data ณ  06/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAcelera็ใo de deprecia็ใo por grupo de bens e entidades     บฑฑ
ฑฑบ          ณcontแbeis                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Ativo Fixo                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFA175()
Local oWizard 	:= Nil
Local nA		:= 0
Local cPergEnt		:= "AF175En"  
Local cPergCont		:= "AF175Co"
Local cLockBy			:= "ATFA175"
Local cTipDepr	:= AllTrim(GetMV("MV_TIPDEPR"))
Local cAtfRtBx	:= AllTrim(GetNewPar("MV_ATFRTBX", "ATFA036"))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetos do Wizard 2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oGrp2 	:= Nil
Local oRad2		:= Nil 
Local nRadTip	:= Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetos do Wizard 3ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aPMetAtiv := {} 
Local aRetMet	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetos do Wizard 4ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oGrp4 	:= Nil
Local oRad4		:= Nil 
Local nRadSel	:= Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetos do Wizard 5ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aPRange	:= {}
Local aRetRange	:= {}
Local aCpoRange	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariแveis para o processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cQuery 	:= ""


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetos do Wizard 7ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aPContab		:= {}
Local aRetContab	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetos do Wizard 6ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aCpoBrw		:= {}
Local aTitles		:= {} 
Local aPages   		:= {}
Local nOpc			:= 3
Local dUltDepr 		:= GETMV("MV_ULTDEPR")
Local lDefTop		:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)

Private aTmpTabs	:= {}
Private aMarks		:= {}
Private aPanels		:= {}
Private aIndexCab	:= {}
Private oFolder, oGetMod 
Private cMarca 		:= GetMark()	
Private lPrim		:= .T.

Private aVlrAtual	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Private aVlResid 	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Private aValBaixa	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Private aValDepr 	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Private aDepr 		:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
// Ajuste para compatibilidade com o fonte ATFA035
Private aVRDACM 	:= If(lMultMoed,AtfMultMoe(,,{|x| 0}), {0,0,0,0,0} )

If !lDefTop
	Help(" ",1,"AF175NaoTop",,STR0001+CRLF+STR0002,1,0) //"Este programa foi desenvolvido " ## "exclusivamente Para ambiente TopConnect"
	Return( .F. ) 
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica os parโmetros de rotina e tipo de baixa	ณ
//ณ estใo coerentes.                        			ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (cAtfRtBx == "ATFA036") .And. (cTipDepr != "0")
	Help(" ",1,"AF175RTBX")		//"Rotina nใo compatํvel com o parโmetro MV_TIPDEPR. Os parโmetros MV_ATFRTBX e MV_TIPDEPR estใo incompatํveis entre si."
	Return						//"O parโmetro MV_ATFRTBX deve estar compatํvel com a op็ใo informada no parโmetro MV_TIPDEPR e vice-versa."
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a data  v lida                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (dDataBase <= dUltDepr) .Or. (dDataBase > LastDay(dUltDepr+1))
	Help(" ",1,"AF175DEPREC",,STR0071+CRLF+STR0072+CRLF+STR0073+DTOC(dUltDepr),1,0)//"A Acelera็ใo s๓ deve ocorrer no mes"##"imediatamente posterior ao cแculo da "##"deprecia็ใo : "
	Return
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApenas um usuario pode usar a rotina por vezณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !LockByName( cLockBy, .F., .F. )
	Help(" ",1,"AF175User",,STR0083,1,0) //"Outro usuario estแ usando a rotina "
	Return( .F. ) 
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem dos paineis do wizardณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณWizard 1: Introdu็ใo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE WIZARD oWizard TITLE STR0003 ; //"Introdu็ใo" 
       HEADER STR0004 ;  // "Introdu็ใo" 
       MESSAGE STR0005 ; // "Introdu็ใo" 
       TEXT STR0006+CRLF+ ;	 //"Esta rotina tem o objetivo"	
       		STR0007+CRLF+; //"de criar ou baixar automaticamente "	
       		STR0008+CRLF+; //"tipos de ativo 07 de deprecia็ใo acelerada "
       		STR0009; //"dos bens selecionados"	
       NEXT {||.T.} ;
       FINISH {||.T.} ;
       PANEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณWizard 2: A็ใo a ser executada : Ativa็ใo de acelera็ใo, T้rmino de acelera็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   CREATE PANEL oWizard;
          HEADER STR0010; 						//"Acao de Acelera็ใo" 
          MESSAGE  STR0011; //"Selecione o tipo de acao a ser feita" 	
          BACK {|| .T. };
          NEXT {|| AF175Next(IIF(nRadTip == ATIVACAO,PAR_ATIVACAO,SEL_SELECAO), @oWizard) };
          FINISH {|| .T. };
          PANEL
          
	oGrp2 := TGroup():New(005,005,070,100,"",oWizard:GetPanel(SEL_MODO),,,.T.)
	oRad2 := TRadMenu():New(012,012,{STR0012,STR0013},bSetGet(nRadTip),oWizard:GetPanel(2),,,,,,,,070,020,,,,.T.) //"Ativacao da Acelera็ใo"##"T้rmino da Acelera็ใo"
	oRad2:nOption := 1
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณWizard 3: Parametros de ativa็ใo Acelera็ใo/ Tela de t้mino da acelera็ใo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  CREATE PANEL oWizard ;
          HEADER STR0014 ; //"Parametros Basicos"  
          MESSAGE  STR0015;	//"Selecione os parametros para a acelera็ใo" 
          BACK {|| .T. } ;
          NEXT {|| AF175ValPer(aRetMet,aPMetAtiv)} ;
          FINISH {|| .T. } ;
          PANEL
          
	// Montagem do Parambox de Ativacao da aceleracใo
	aAdd(aPMetAtiv,{2,STR0016,1,{STR0017,STR0018},50,"",.T.}) 	//"M้todo:" ## "Turno" ## "Percentual"
	aAdd(aPMetAtiv,{2,STR0019,1,{STR0069,STR0070},50,"",.F.})		//"Turno a acelerar"
	aAdd(aPMetAtiv,{1,STR0020,6,"@E 999.99","","",,0,.F.})  		//"Percentual a Acelerar"
	AAdd(aRetMet,STR0017)
	AAdd(aRetMet,1)
	AAdd(aRetMet,0)
	ParamBox(aPMetAtiv,STR0021,@aRetMet,,,,,,oWizard:GetPanel(PAR_ATIVACAO)) //"Parโmetros..."
    aRetMet := AjRetParam(aRetMet,aPMetAtiv)
    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณWizard 4: Opc๕es de sele็ใo: Range / Entidade    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  CREATE PANEL oWizard ;
          HEADER STR0022 ; 	//"Opc๕es de sele็ใo"
          MESSAGE  STR0023; 	//"Selecione o tipo sel็ใo dos Bens" 
          BACK {|| AF175Back(IIF(nRadTip == ATIVACAO,PAR_ATIVACAO,SEL_MODO), @oWizard) } ; 
          NEXT {|| AF175Next(IIF(nRadSel == RANGE,PAR_RANGE,PAR_ENTIDADE), @oWizard) };
          FINISH {|| .T. } ;
          PANEL
	oGrp4 := TGroup():New(005,005,070,100,"",oWizard:GetPanel(SEL_SELECAO),,,.T.)
	oRad4 := TRadMenu():New(012,012,{STR0024,STR0025},bSetGet(nRadSel),oWizard:GetPanel(SEL_SELECAO),,,,,,,,070,020,,,,.T.) //"Range"##"Por entidade"
	oRad4:nOption := 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณWizard 5: Tipos de Sele็ใo: Range          	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู    
  CREATE PANEL oWizard;
          HEADER STR0026;	//"Sele็ใo dos Registros" 
          MESSAGE  STR0027;	//"Selecione os registros" 
          BACK {|| .T. };
          NEXT {|| IIF(AF175Range(@cQuery,nRadTip,aRetRange,aCpoRange),AF175Next(PROCESSAMENTO, @oWizard),.F.) } ;
          FINISH {|| .T. };
          PANEL
	
	// Montagem do Parambox de selecao pro Range  
	aAdd(aPRange,{1,STR0028		,Space(TAMSX3("N1_CBASE")[1])	,"@!","","SN1"	,""	,60,.F.,"N1_CBASE"})		//"Do C๓digo do Bem "
	aAdd(aPRange,{1,STR0029		,Space(TAMSX3("N1_CBASE")[1])	,"@!","","SN1"	,""	,60,.F.,"N1_CBASE"})		//"At้ C๓digo do Bem "
	aAdd(aPRange,{1,STR0030		,Space(TAMSX3("N1_ITEM")[1])	,"@!","",""		,""	,20,.F.,"N1_ITEM"})			//"Do Item  "
	aAdd(aPRange,{1,STR0031		,Space(TAMSX3("N1_ITEM")[1])	,"@!","",""		,""	,20,.F.,"N1_ITEM"})			//"At้ o Item "
	aAdd(aPRange,{1,STR0032		,Space(TAMSX3("NG_GRUPO")[1])	,"@!","","SNG"	,""	,42,.F.,"N1_GRUPO"})		//"Do Grupo  "
	aAdd(aPRange,{1,STR0033		,Space(TAMSX3("NG_GRUPO")[1])	,"@!","","SNG"	,""	,42,.F.,"N1_GRUPO"})		//"At้ o Grupo "
	aAdd(aPRange,{1,STR0034		,Space(TAMSX3("CT1_CONTA")[1])	,"@!","","CT1"	,""	,100,.F.,"N3_CCONTAB"})		//"Da Conta "
	aAdd(aPRange,{1,STR0035		,Space(TAMSX3("CT1_CONTA")[1])	,"@!","","CT1"	,""	,100,.F.,"N3_CCONTAB"})		//"At้ a Conta "
	aAdd(aPRange,{1,STR0036		,Space(TAMSX3("CTT_CUSTO")[1])	,"@!","","CTT"	,""	,55,.F.,"N3_CUSTBEM"})		//"Do o Centro de Custo "	
	aAdd(aPRange,{1,STR0037		,Space(TAMSX3("CTT_CUSTO")[1])	,"@!","","CTT"	,""	,55,.F.,"N3_CUSTBEM"})		//"At้ o Centro de Custo "	
	aAdd(aPRange,{1,STR0038   	,Space(TAMSX3("CTD_ITEM")[1])	,"@!","","CTD"	,""	,55,.F.,"N3_SUBCCON"})		//"Do Item Contabil  " 
	aAdd(aPRange,{1,STR0039		,Space(TAMSX3("CTD_ITEM")[1])	,"@!","","CTD"	,""	,55,.F.,"N3_SUBCCON"})		//"At้ o Item Contabil "
	aAdd(aPRange,{1,STR0040		,Space(TAMSX3("CTH_CLVL")[1])	,"@!","","CTH"	,""	,55,.F.,"N3_CLVLCON"})		//"Da Classe Contabil  "
	aAdd(aPRange,{1,STR0041		,Space(TAMSX3("CTH_CLVL")[1])	,"@!","","CTH"	,""	,55,.F.,"N3_CLVLCON"})		//"At้ a Classe Contabil "
                   
	For nA := 1 To Len(aPRange)
		aAdd(aRetRange,aPRange[nA][3])
		aAdd(aCpoRange,aPRange[nA][10])
		&("MV_PAR"+STRZERO(nA,2)) := aRetRange[nA] := ParamLoad(cPergEnt,aPRange,nA,aPRange[nA][3])	
	Next nA

	ParamBox(aPRange,STR0021,@aRetRange,,,,,,oWizard:GetPanel(PAR_RANGE))//"Parโmetros..."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณWizard 6: Tipos de Sele็ใo: Entidade          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  CREATE PANEL oWizard ;
          HEADER STR0042 ; //"Sele็ใo dos Registros"
          MESSAGE  STR0043;//"Selecione os registros"
          BACK {|| AF175Back( SEL_SELECAO , @oWizard) } ;
          NEXT {|| IIF(AF175Entid(@cQuery,nRadTip,aMarks),AF175Next(PROCESSAMENTO, @oWizard),.F.) } ;
          FINISH {|| .T. } ;
          PANEL   
          
	oFolder := TFolder():New(0,0,aTitles,aPages,oWizard:GetPanel(PAR_ENTIDADE),,,, .T., .T.,30,30,)
	oFolder:Align 		:= CONTROL_ALIGN_ALLCLIENT
	oFolder:nOption 	:= 1
    
	// Montagem dos getdados 
	aCpoBrw := {}
	aAdd( aCpoBrw,  { "NG_OK",, 		"", "" } ) 
	aAdd( aCpoBrw,  { "NG_GRUPO",40, 	"", "" } ) 
	aAdd( aCpoBrw,  { "NG_DESCRIC",40, 	"", "" } ) 
	MsgRun( STR0044, STR0045, {|| aAdd( aTmpTabs, ADMSQLMARK('SNG', @oFolder, aCpoBrw, STR0084, nOpc)) } )  //'Coletando Grupos '###'Aguarde...'###"Grupo Bens"
	
	aCpoBrw := {}
	aAdd( aCpoBrw,  { "CT1_OK",, 		"", "" } ) 
	aAdd( aCpoBrw,  { "CT1_CONTA",40, 	"", "" } ) 
	aAdd( aCpoBrw,  { "CT1_DESC01",40, 	"", "" } ) 
	MsgRun( STR0046, STR0045, {|| aAdd( aTmpTabs, ADMSQLMARK('CT1', @oFolder, aCpoBrw, STR0085, nOpc)) } )  //'Coletando Contas '###'Aguarde...'###"Conta Deprecia็ใo"
	
	aCpoBrw := {}
	aAdd( aCpoBrw,  { "CTT_OK",, 		"", "" } ) 
	aAdd( aCpoBrw,  { "CTT_CUSTO",40, 	"", "" } ) 
	aAdd( aCpoBrw,  { "CTT_DESC01",40, 	"", "" } ) 
	MsgRun( STR0047, STR0045, {|| aAdd( aTmpTabs, ADMSQLMARK('CTT', @oFolder, aCpoBrw, STR0086, nOpc)) } ) //'Coletando Centros de Custo '###'Aguarde...'###"Centro de Custo"
	
	aCpoBrw := {}
	aAdd( aCpoBrw,  { "CTD_OK",, 		"", "" } ) 
	aAdd( aCpoBrw,  { "CTD_ITEM",40, 	"", "" } ) 
	aAdd( aCpoBrw,  { "CTD_DESC01",40, 	"", "" } ) 
	MsgRun( STR0048, STR0045, {|| aAdd( aTmpTabs, ADMSQLMARK('CTD', @oFolder, aCpoBrw, STR0087, nOpc)) } ) //'Coletando Itens Contabeis '###'Aguarde...'###"Itens Contabeis"
	
	aCpoBrw := {}
	aAdd( aCpoBrw,  { "CTH_OK",, 		"", "" } ) 
	aAdd( aCpoBrw,  { "CTH_CLVL",40,	"", "" } ) 
	aAdd( aCpoBrw,  { "CTH_DESC01",40, 	"", "" } ) 
	MsgRun( STR0049, STR0045, {|| aAdd( aTmpTabs, ADMSQLMARK('CTH', @oFolder, aCpoBrw, STR0088, nOpc)) } )  //'Coletando Classes de Valor '###'Aguarde...'###"Classe de Valor"
	
	oFolder:bSetOption 	:= {|nPasta| aEval(oFolder:aDialogs[nPasta]:aControls, {|x| x:Refresh() }), aMarks[nPasta, 1]:oBrowse:SetFocus(), aMarks[nPasta,1]:oBrowse:Refresh() } 
	          
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณWizard 7: Confirma็ใo do processamento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  CREATE PANEL oWizard ;
          HEADER STR0050 ; //"Confirma็ใo" 
          MESSAGE  STR0051;//"A rotina serแ processada com os dados selecionados" 
          BACK {|| AF175Back( SEL_SELECAO , @oWizard) } ;
          NEXT {|| .F. } ;
          FINISH {|| AF175IProc(cQuery,nRadTip,aRetMet,aRetContab,aPMetAtiv,aPContab),.T.  }  ;
          PANEL
	// Montagem do Parambox de contabilizacao
	aAdd(aPContab,{2,STR0063,1,{STR0066,STR0067},50,"",.T.})// "Contabiliza"##"SIM"##"NAO"
	aAdd(aPContab,{2,STR0064,1,{STR0066,STR0067},50,"",.F.})//"Mostra Lanc "##"SIM"##"NAO"
	aAdd(aPContab,{2,STR0065,1,{STR0066,STR0067},50,"",.F.})//"Aglutina Lanc"##"SIM"##"NAO"
	AAdd(aRetContab,2)
	AAdd(aRetContab,2)
	AAdd(aRetContab,2)
	
	For nA := 1 To Len(aPContab)
		&("MV_PAR"+STRZERO(nA,2)) := aRetContab[nA] := ParamLoad(cPergCont,aPContab,nA,aPContab[nA][3])	
	Next nA
	
	ParamBox(aPContab,STR0021,@aRetContab,,,,,,oWizard:GetPanel(PROCESSAMENTO)) //"Parโmetros..."
    aRetContab := AjRetParam(aRetContab,aPContab)
oWizard:Activate()



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSalva as perguntasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nA := 1 To Len(aRetRange)
	&("MV_PAR"+STRZERO(nA,2)) := aRetRange[nA]
Next nA

ParamSave(cPergEnt,aPRange,"1")


For nA := 1 To Len(aRetContab)
	&("MV_PAR"+STRZERO(nA,2)) := aRetContab[nA]
Next nA

ParamSave(cPergCont,aPContab,"1")                 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApaga as tabelas temporariasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nA := 1 To Len( aTmpTabs ) 
	(aTmpTabs[nA])->( dbCloseArea() ) 
	MsErase(aTmpTabs[nA])
Next nA

UnLockByName( cLockBy, .F., .F. )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175Back บAutor  ณAlvaro Camillo Neto บ Data ณ  11/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControle de fluxo do wizard - comando voltar                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175Back( nOpc , oWizard)
	oWizard:nPanel := nOpc + 1
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175Next บAutor  ณAlvaro Camillo Neto บ Data ณ  11/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControle de fluxo do wizard - comando Pr๓ximo               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175Next( nOpc , oWizard)
	oWizard:nPanel := nOpc - 1 
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175EntidบAutor  ณAlvaro Camillo Neto บ Data ณ  13/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a sele็ใo realizada e formata a Query a ser processa บฑฑ
ฑฑบ          ณda                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175Entid(cQuery,nTipoAcao,aMarks)
Local lRet 			:= .T.
Local nPosSNG		:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'SNG' } ) 
Local nPosCT1		:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CT1' } ) 
Local nPosCTT		:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CTT' } ) 
Local nPosCTD		:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CTD' } ) 
Local nPosCTH  		:= aScan( aMarks, {|x| Upper(AllTrim(x[4])) == 'CTH' } ) 

cQuery := ""
cQuery	+= " SELECT " 
cQuery	+= " 	N3_FILIAL, " 
cQuery	+= " 	N3_CBASE,  "
cQuery	+= " 	N3_ITEM,  "
cQuery	+= " 	N3_TIPO,  "
cQuery	+= " 	N3_BAIXA,  "
cQuery	+= " 	N3_SEQ "
cQuery += " 	FROM "+RetSqlTab("SN1")+" "
cQuery += " 		INNER JOIN "+RetSqlTab("SN3")+" ON SN3.D_E_L_E_T_ = ' ' "
cQuery += " 									AND SN3.N3_FILIAL	= SN1.N1_FILIAL "
cQuery += " 									AND SN3.N3_CBASE	= SN1.N1_CBASE "
cQuery += " 									AND SN3.N3_ITEM	= SN1.N1_ITEM "
cQuery += " 									AND SN3.N3_BAIXA ='0' "

If lIsRussia
	cQuery += " 								AND SN3.N3_OPER ='1' " // CAZARINI - 22.01.2017 - Asset Into Operation?
Endif
If AF175Marc(aMarks[nPosSNG,6],"SNG") 
	cQuery += " 		INNER JOIN "+aMarks[nPosSNG,6]+" SNG ON SNG.NG_OK <> '' "
	cQuery += " 									AND SN1.N1_GRUPO = SNG.NG_GRUPO "
EndIf
If AF175Marc(aMarks[nPosCT1,6],"CT1") 
	cQuery += " 		INNER JOIN "+aMarks[nPosCT1,6]+" CT1 ON CT1_OK <> '' "                       
	cQuery += " 									AND SN3.N3_CCONTAB	= CT1_CONTA	"
EndIf
If AF175Marc(aMarks[nPosCTT,6],"CTT") 
	cQuery += " 		INNER JOIN "+aMarks[nPosCTT,6]+" CTT ON CTT_OK <> '' "
	cQuery += " 									AND SN3.N3_CCUSTO = CTT_CUSTO "
EndIF
If AF175Marc(aMarks[nPosCTD,6],"CTD") 
	cQuery += " 		INNER JOIN "+aMarks[nPosCTD,6]+" CTD ON CTD_OK <> '' "
	cQuery += " 									AND SN3.N3_SUBCTA = CTD_ITEM "
EndIf
If AF175Marc(aMarks[nPosCTH,6],"CTH") 
	cQuery += " 		INNER JOIN "+aMarks[nPosCTH,6]+" CTH ON CTH_OK <> '' "
	cQuery += " 									AND SN3.N3_CLVL = CTH_CLVL " 
EndIf
cQuery += " 	WHERE SN1.D_E_L_E_T_ = ' ' AND "

If nTipoAcao == TERMINO
	cQuery	+= " N3_TIPO = '07' AND " 
ElseIf nTipoAcao == ATIVACAO
	cQuery	+= " N3_TIPO = '01' AND "
EndIf  

cQuery += " SN1.N1_FILIAL = '"+xFilial('SN1')+"' "


cQuery := ChangeQuery(cQuery)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se a query irแ estorar o tamanho permitido pelo bancoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(cQuery) > 65500
	Help("AF175MONTQRY",1,"HELP",STR0052,STR0053+CRLF+STR0054+CRLF+STR0055,1,0)//"Filtro incorreto"##"Sele็ใo muito extensa:"##"Restrinja a sua sele็ใo ou utilize a op็ใo"##" de Range"
	cQuery := ""
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175RangeบAutor  ณAlvaro Camillo Neto บ Data ณ  07/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a sele็ใo realizada e formata a Query a ser processa บฑฑ
ฑฑบ          ณda                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175Range(cQuery,nTipoAcao,aRange,aCpoRange)
Local lRet 			:= .T.
Local aFiltro   	:= {}
Local nI			:= 0
Local cCampo		:= ""
Local nPosCampo		:= 0
Default aRange 		:= {}
Default aCpoRange	:= {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPrepara o Array de aFiltro                                                         ณ
//ณaFiltro deve ser estruturado da seguinte forma                                     ณ
//ณ[1] = Campo a ser filtrado                                                         ณ
//ณ[2] = Filtro - Max e Min para range(separados por /)                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI := 1 to Len(aRange)
	If Empty ( nPosCampo := aScan(aFiltro,{|x| x[1] == aCpoRange[nI]} ) )
   		AADD(aFiltro,{aCpoRange[nI],aRange[nI]})		
   	Else
   		aFiltro[nPosCampo][2] += "/"+aRange[nI]
   	EndIf
Next nI		


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a query de processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lRet := AF175MontQry(@cQuery,aFiltro,nTipoAcao)

If lRet
	lRet := MsgYesNo(STR0056,STR0057)//"Confirma os dados?"##"Aten็ใo"
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175MontQryบAutorณAlvaro Camillo Neto บ Data ณ  07/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta e valida a query para o processamento da rotina      บฑฑ
ฑฑบ          ณ de range                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175MontQry(cQuery,aFiltro,nTipoAcao)
Local lRet 		:= .T.
Local nI		:= 0
Local nPosSinal	:= 0

cQuery	:= " "
cQuery	+= " SELECT " 
cQuery	+= " 	N3_FILIAL, " 
cQuery	+= " 	N3_CBASE,  "
cQuery	+= " 	N3_ITEM,  "
cQuery	+= " 	N3_TIPO,  "
cQuery	+= " 	N3_BAIXA,  "
cQuery	+= " 	N3_SEQ "
cQuery	+= " FROM "+ RetSQLTab("SN3")
cQuery	+= " INNER JOIN "+ RetSQLTab("SN1")
cQuery	+= " ON "
cQuery	+= " N3_CBASE = N1_CBASE AND "
cQuery	+= " N3_ITEM  = N1_ITEM  "
cQuery	+= " WHERE "
cQuery	+= RetSqlCond("SN3") + " AND "
cQuery	+= RetSqlCond("SN1") + " AND "

If nTipoAcao == TERMINO
	cQuery	+= " N3_TIPO = '07' AND" 
ElseIf nTipoAcao == ATIVACAO
	cQuery	+= " N3_TIPO = '01' AND "
EndIf  

cQuery += " N3_BAIXA ='0' "
cQuery += " AND N1_PATRIM <> 'T' "

For nI := 1 to Len(aFiltro)
	nPosSinal := AT("/",aFiltro[nI][2])
	cQuery	+= " AND " + aFiltro[nI][1] + " BETWEEN '" + ALLTRIM(LEFT(aFiltro[nI][2] , nPosSinal-1 )) + "' AND '" + ALLTRIM(RIGHT(aFiltro[nI][2] , LEN(aFiltro[nI][2]) - nPosSinal)) + "'" 		
Next nI

If lIsRussia
	cQuery += " AND N3_OPER ='1' " // CAZARINI - 22.01.2017 - Asset Into Operation?
Endif
cQuery  := ChangeQuery(cQuery)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se a query irแ estorar o tamanho permitido pelo bancoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(cQuery) > 65500
	Help("AF175MONTQRY",1,"HELP",STR0052,STR0053+CRLF+STR0054+CRLF+STR0055,1,0)//"Filtro incorreto"##"Sele็ใo muito extensa:"##"Restrinja a sua sele็ใo ou utilize a op็ใo"##" de Range"
	cQuery := ""
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175IProcบAutor  ณAlvaro Camillo Neto บ Data ณ  10/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa o processo de inclusao da deprecia็ใo            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATF175                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175IProc(cQuery,nTipoDep,aParamDep,aParamContab,aPMetAtiv,aPContab)
Local lEnd 		:= .F.                                                                    
Local oProcess 	:= nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPrepara os arrays dos paramboxณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aParamDep 		:= AjRetParam(aParamDep,aPMetAtiv)
aParamContab 	:= AjRetParam(aParamContab,aPContab)

oProcess := MsNewProcess():New({|lEnd| AF175Proc(cQuery,nTipoDep,aParamDep,aParamContab,oProcess,@lEnd)},STR0058,STR0059,.T.)//"Processando..."##"Depreciacao Acelerada"
oProcess:Activate()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175Proc บAutor  ณAlvaro Camillo Neto บ Data ณ  10/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processo de geracao dos tipos de deprecia็ใo acelerada     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATF175                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175Proc(cQuery,nTipoDep,aParamDep,aParamContab,oProcess,lEnd)
Local aArea := GetArea()
Local cTab	:= GetNextAlias()
Local nReg	:= 0
Local nTipoAtiv  := aParamDep[1]
Local nTipoTurno := aParamDep[2]
Local nPercentual:= 0 
Local lRet	:= .T.
Local nCont := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariแveis de contabiliza็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cLoteAtf 	:= LoteCont("ATF")
Private lPrim 	 	:= .T.  
Private lAuto		:= .T.
Private nTotal		:= 0
Private cArquivo    
Private nHdlPrv     	:= 0
Private lPadrao 		:= .F.
Private lContabiliza    := aParamContab[1]== SIM 
Private lMostra	    	:= aParamContab[2]== SIM 
Private lAglutina    	:= aParamContab[3]== SIM 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAvalia qual serแ o percentual a ser aceleradoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipoAtiv == PERCENTUAL
	nPercentual := aParamDep[3]
Else
   If nTipoTurno == NORMAL // 50%
   	nPercentual := 0.5 
   Else //100%
   	nPercentual := 1 
   EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .F., .T.)
(cTab)->(dbGotop())
(cTab)->(dbEval({|| nReg++ }))
(cTab)->(dbGotop())

If (cTab)->(EOF())
	Help("AF175Proc",1,"HELP"	,,STR0060,1,0)//"Nใo hแ registros a processar" 
	RestArea(aArea)
	Return
EndIf

oProcess:SetRegua1(nReg)

BEGIN TRANSACTION

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPara inibir as mensagens de Help e mostrar no Final os ณ
//ณerros ocorridos                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lMSHelpAuto := .T.

While (cTab)->(!EOF())
	oProcess:IncRegua1(STR0061+(cTab)->N3_CBASE + STR0062 + (cTab)->N3_ITEM )//"Processando Ativo: "## " ITEM: "
	ProcessMessage()
	nCont++
	If lEnd
		Exit
	EndIf
	If nCont > 1
		lPrim := .F.
	EndIf
	
	If nTipoDep == ATIVACAO   
		If !AF175GrvAc((cTab)->(N3_FILIAL),(cTab)->(N3_CBASE),(cTab)->(N3_ITEM),nPercentual,nTipoAtiv)                           
			//"O seguinte bem nใo foi acelerado"##"pelo motivo acima"##"Bem: "##"Item: "
			Help("AF175GrvAc",1,"HELP"	,,STR0077+CRLF+STR0078+CRLF+STR0079+(cTab)->(N3_CBASE) +CRLF+ STR0080+ (cTab)->(N3_ITEM) ,1,0)	
		EndIf
	ElseIf nTipoDep == TERMINO
		If !AF175BaixAc((cTab)->(N3_FILIAL),(cTab)->(N3_CBASE),(cTab)->(N3_ITEM),(cTab)->(N3_TIPO),(cTab)->(N3_BAIXA),(cTab)->(N3_SEQ))		 
	   		//"A acelera็ใo do seguinte bem nao foi"##"terminada pelo motivo acima"##"Bem: "##"Item: "
	   		Help("AF175BaixAc",1,"HELP"	,,STR0081+CRLF+STR0082+CRLF+STR0079+ (cTab)->(N3_CBASE) +CRLF+ STR0080+ (cTab)->(N3_ITEM) ,1,0)	
		EndIf
	End 
	
	(cTab)->(dbSkip())	
EndDo

If  nTotal > 0 .And. lCOntabiliza
	RodaProva(nHdlPrv,nTotal)
	cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,lMostra,lAglutina)
Endif

cFileLog := NomeAutoLog()
If !Empty(cFileLog)
   MostraErro("",cFileLog)
Endif

END TRANSACTION

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175GrvAcบAutor  ณAlvaro Camillo Neto บ Data ณ  11/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a grava็ใo do registro de depreciacao acelerada     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATF175                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175GrvAc(cN3Filial,cN3CBase,cN3Item,nPercentual,nTipoAtiv)
Local aArea 	:= GetArea()
Local aAreaSN3  := SN3->(GetArea())
Local aAreaSN1	:= SN1->(GetArea())
Local lRet 		:= .T.
Local nPosTipo	:= 0
Local nPosHist := 0
Local nPosCont := 0
Local nPosAcum	:= 0
Local nPosDep		:= 0
Local nPosDep1	:= 0
Local nPosDep2	:= 0
Local nPosDep3	:= 0
Local nPosDep4	:= 0
Local nPosDep5	:= 0
Local nValOri1  := 0
Local nValOri2  := 0
Local nValOri3  := 0
Local nValOri4  := 0
Local nValOri5  := 0
Local nValAmp1	:= 0
Local nValAmp2	:= 0
Local nValAmp3	:= 0
Local nValAmp4	:= 0
Local nValAmp5	:= 0  
Local nPosAquis	:= 0
Local nPosDtAq	:= 0
Local nPosSeq  := 0
LOcal cSeq     := "00"
Local aPosNum	:= {}
Local nX		:= 0
Local uRet	    := Nil
Local aCab		:= {}
Local aItens	:= {}
Local aAux		:= {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis Private para a fun็ใo AF010Incluiณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aHeader := AF175CHead("SN3")
Private aCols	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis Privates utilizadas pela funcao af010Gravaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lCopia			:= .F.
Private lProva          := lPrim
Private lHeader			:= lPrim
Private lTrailler		:= .F.
Private lCProva			:= !lPrim
Private Inclui			:= .F.
Private Altera			:= .T.
Private uCampo			:= ""
Private n				:= 0 
Private nUsado			:= 0
Private cMoedaAtf 		:= ALLTRIM(GetMV("MV_ATFMOEDA"))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdena็ใo das tabelas envolvidasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SN1->(dbSetOrder(1))	//N1_FILIAL+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(1))	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosi็ใo dos campos no Aheader que serใo modificados no tipo 07ณ
//ณTodos os outro serใo c๓pia do tipo 01                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosTipo	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_TIPO") })
nPosDep1	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_TXDEPR1") })
nPosDep2	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_TXDEPR2") })
nPosDep3	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_TXDEPR3") })
nPosDep4	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_TXDEPR4") })
nPosDep5	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_TXDEPR5") })
nPosDtAq	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_AQUISIC") }) 
nPosDinDep	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_DINDEPR") }) 
nValOri1	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_VORIG1") })
nValOri2	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_VORIG2") })
nValOri3	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_VORIG3") })
nValOri4	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_VORIG4") })
nValOri5	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_VORIG5") })
nValAmp1	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_AMPLIA1") })
nValAmp2	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_AMPLIA2") })
nValAmp3	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_AMPLIA3") })
nValAmp4	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_AMPLIA4") })
nValAmp5	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_AMPLIA5") })
nDataBaix	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_DTBAIXA") })
nPosHist	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_HISTOR") })
nPosCont	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_CCONTAB") })
nPosSeq	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_SEQ") })
nPosAcum	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_CCDEPR") })
nPosDep	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_CDEPREC") })


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosi็ใo dos campos num้ricos.                   ณ
//ณApenas os campos de valor de origem se manterใo,ณ
//ณos outros ficarใo zerados                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aHeader)
	If Alltrim(aHeader[nX][08]) == 'N' .And. !( "VORIG" $ Alltrim(aHeader[nX][02]) ) .AND. !( "TXDEPR" $ Alltrim(aHeader[nX][02]) ) .AND. !( "AMPLIA" $ Alltrim(aHeader[nX][02]) ) 
		aAdd(aPosNum,aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim(aHeader[nX][02])} ))
	EndIf 
Next
                                          
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se jแ hแ algum registro do tipo 07 no ativoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !AF175Val07(cN3CBase,cN3Item)
	Help("AF175Val07",1,"HELP"	,,STR0074,1,0)// "O bem jแ estแ acelerado"
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona no SN1 e carrega as informa็๕es na mem๓riaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SN1->(MsSeek(cN3Filial+cN3CBase+cN3Item))
	RegToMemory("SN1",.F.)
Else
	Help("AF175NoRec",1,"HELP"	,,STR0075,1,0)// "O bem nใo existe na base de dados"
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o aColsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	aCols := AF175CAcol(aHeader,"SN3",1,cN3Filial+cN3CBase+cN3Item,"N3_FILIAL+N3_CBASE+N3_ITEM")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEncontra a posi็ใo no acols o tipo aquisi็ใo 01ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPosAquis := aScan(aCols,{|aItem| ALLTRIM(aItem[nPosTipo]) == '01' })
	
	If !Empty(nPosAquis)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria a nova linha de acelera็ใoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AADD(aCols,aClone(aCols[nPosAquis]))

	 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณA variavel ้ inicializada pois a funcao af010grava realizaณ
		//ณuma valida็ใo de tipo, sendo que serแ sempre '07'         ณ
		//ณnใo afetara em nada a rotina e ela funcionara como        ณ
		//ณna MATA103                                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		n := Len(aCols)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida se o bem foi depreciadoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If AF175ValDepr(aHeader,aCols[n])

		    //
		    aAdd(aCab,{"N1_CBASE", cN3CBase})
		    aAdd(aCab,{"N1_ITEM",  cN3Item})
		    //Obter a Ultima Sequencia utilizada e usar a proxima
		    cSeq := aCols[n-1, nPosSeq]
		    aAdd(aAux,{"N3_SEQ", Soma1(cSeq)})   
		    aAdd(aAux,{"N3_TIPO", "07"})
		    aAdd(aAux,{"N3_AQUISIC", dDataBase})
		    aAdd(aAux,{"N3_DINDEPR", RetDinDepr(dDatabase)})
		    aAdd(aAux,{"N3_DTBAIXA", CtoD("")})
		    aAdd(aAux,{"N3_HISTOR",aCols[n][nPosHist]}) 
		    aAdd(aAux,{"N3_CCONTAB",aCols[n][nPosCont]})
		    aAdd(aAux,{"N3_CCDEPR",aCols[n][nPosAcum]})
		    aAdd(aAux,{"N3_CDEPREC",aCols[n][nPosDep]})
		    
		    
			If nTipoAtiv != PERCENTUAL	    
				
			    aCols[n][nPosDep1] *= IIF(aCols[n][nPosDep1] > 0  , nPercentual,0)    	    		
				aCols[n][nPosDep2] *= IIF(aCols[n][nPosDep2] > 0  , nPercentual,0)    	    		
				aCols[n][nPosDep3] *= IIF(aCols[n][nPosDep3] > 0  , nPercentual,0)    	    		
				aCols[n][nPosDep4] *= IIF(aCols[n][nPosDep4] > 0  , nPercentual,0)    	    		
				aCols[n][nPosDep5] *= IIF(aCols[n][nPosDep5] > 0  , nPercentual,0)
				
				aAdd(aAux,{"N3_TXDEPR1", aCols[n][nPosDep1] })
				aAdd(aAux,{"N3_TXDEPR2", aCols[n][nPosDep2] })
				aAdd(aAux,{"N3_TXDEPR3", aCols[n][nPosDep3] })
				aAdd(aAux,{"N3_TXDEPR4", aCols[n][nPosDep4] })
				aAdd(aAux,{"N3_TXDEPR5", aCols[n][nPosDep5] })		 
				   	
			Else
							
				aAdd(aAux,{"N3_TXDEPR1", IIF(aCols[n][nPosDep1] > 0  , nPercentual,0) })
				aAdd(aAux,{"N3_TXDEPR2", IIF(aCols[n][nPosDep2] > 0  , nPercentual,0) })
				aAdd(aAux,{"N3_TXDEPR3", IIF(aCols[n][nPosDep3] > 0  , nPercentual,0) })
				aAdd(aAux,{"N3_TXDEPR4", IIF(aCols[n][nPosDep4] > 0  , nPercentual,0) })
				aAdd(aAux,{"N3_TXDEPR5", IIF(aCols[n][nPosDep5] > 0  , nPercentual,0) })		
				
		    EndIf
		    
		    aAdd(aAux,{"N3_VORIG1", IIF(aCols[n][nPosDep1] > 0  , aCols[n][nValOri1],0) })
			aAdd(aAux,{"N3_VORIG2", IIF(aCols[n][nPosDep2] > 0  , aCols[n][nValOri2],0) })
			aAdd(aAux,{"N3_VORIG3", IIF(aCols[n][nPosDep3] > 0  , aCols[n][nValOri3],0) })
			aAdd(aAux,{"N3_VORIG4", IIF(aCols[n][nPosDep4] > 0  , aCols[n][nValOri4],0) })
			aAdd(aAux,{"N3_VORIG5", IIF(aCols[n][nPosDep5] > 0  , aCols[n][nValOri5],0) })	
		     	    
		    If nValAmp1 > 0 // O update de campos foi executado
		    	
		    	aAdd(aAux,{"N3_AMPLIA1", IIF(aCols[n][nPosDep1] > 0 , aCols[n][nValAmp1] ,0) })
				aAdd(aAux,{"N3_AMPLIA2", IIF(aCols[n][nPosDep2] > 0 , aCols[n][nValAmp2] ,0) })
				aAdd(aAux,{"N3_AMPLIA3", IIF(aCols[n][nPosDep3] > 0 , aCols[n][nValAmp3] ,0) })
				aAdd(aAux,{"N3_AMPLIA4", IIF(aCols[n][nPosDep4] > 0 , aCols[n][nValAmp4] ,0) })
				aAdd(aAux,{"N3_AMPLIA5", IIF(aCols[n][nPosDep5] > 0 , aCols[n][nValAmp5] ,0) })	
		    	  
		    EndIf
	  
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPonto de entrada para a grava็ใo de outrosณ
			//ณdados na linha da acelera็ใo              ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If ExistBlock("AF175GRV")
				uRet := ExecBlock("AF175GRV",.F.,.F.,{aHeader,aCols[n]})
				If ValType(uRet) == "A"
					aAdd(aAux,{aHeader[n][2], uRet }) 
				EndIf
			EndIf
			
			aAdd(aItens, aAux)
			DbSelectArea("SN1")
			Pergunte("AFA012",.F.)
			MSExecAuto({|x,y,z,w| ATFA012(x,y,z,w)},aCab,aItens,4)						
		EndIf
	Else
		Help("AF175No01",1,"HELP"	,,STR0076,1,0)// "Nใo ้ possํvel acelerar um bem em forma็ใo"
		lRet := .F.	
	EndIf
EndIf
	
aSize(aAux, 0)
aSize(aItens,0)
aSize(aCab, 0)
aAux := Nil
aItens := Nil
aCab 	:= Nil
RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aArea)
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175CHeadบAutor  ณAlvaro Camillo Neto บ Data ณ  10/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o Aheader da getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175CHead(cAlias)
Local 	aArea		:= GetArea()
Local   aHeader 	:= {}
Local 	aCpoObr		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampos obrigat๓rios do aheaderณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aCpoObr,"N3_TIPO")
AADD(aCpoObr,"N3_TXDEPR1")
AADD(aCpoObr,"N3_TXDEPR2")
AADD(aCpoObr,"N3_TXDEPR3")
AADD(aCpoObr,"N3_TXDEPR4")
AADD(aCpoObr,"N3_TXDEPR5")
AADD(aCpoObr,"N3_AQUISIC") 
AADD(aCpoObr,"N3_DINDEPR") 
AADD(aCpoObr,"N3_VORIG1")
AADD(aCpoObr,"N3_VORIG2")
AADD(aCpoObr,"N3_VORIG3")
AADD(aCpoObr,"N3_VORIG4")
AADD(aCpoObr,"N3_VORIG5")
AADD(aCpoObr,"N3_AMPLIA1")
AADD(aCpoObr,"N3_AMPLIA2")
AADD(aCpoObr,"N3_AMPLIA3")
AADD(aCpoObr,"N3_AMPLIA4")
AADD(aCpoObr,"N3_AMPLIA5")
AADD(aCpoObr,"N3_DTBAIXA")

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If (X3USO(SX3->X3_USADO) .AND. (cNivel >= SX3->X3_NIVEL)) .Or.;
		( aScan(aCpoObr,{|x| ALLTRIM(x) == SX3->X3_CAMPO }) > 0 ) 
		aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
		SX3->X3_CAMPO	, ;			// 02 - Campo
		SX3->X3_Picture	, ;			// 03 - Picture
		SX3->X3_TAMANHO	, ;			// 04 - Tamanho
		SX3->X3_DECIMAL	, ;			// 05 - Decimal
		SX3->X3_Valid  	, ;			// 06 - Valid
		SX3->X3_USADO  	, ;			// 07 - Usado
		SX3->X3_TIPO   	, ;			// 08 - Tipo
		SX3->X3_F3		   , ;		// 09 - F3
		SX3->X3_CONTEXT   , ;       // 10 - Contexto
		SX3->X3_CBOX	  , ; 		// 11 - ComboBox
		SX3->X3_RELACAO    } )   // 12 - Relacao
		
	Endif
	SX3->(dbSkip())
End
RestArea(aArea)
Return(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175CAcolบAutor  ณAlvaro Camillo Neto บ Data ณ  10/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunc๕a que cria Acols                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeader : aHeader aonde o aCOls serแ baseado                บฑฑ
ฑฑบ          ณcAlias  : Alias da tabela                                   บฑฑ
ฑฑบ          ณnIndice : Indice da tabela que sera usado para              บฑฑ
ฑฑบ          ณcComp   : Informacao dos Campos para ser comparado no While บฑฑ
ฑฑบ          ณcINDICE : Chave de compara็ใo da tabela de item             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175CAcol(aHeader,cAlias,nIndice,cComp,cINDICE)
Local nX	:= 0
Local nCols	:= 0
Local aArea	:= GetArea()

(cAlias)->(dbSetOrder(nIndice))
(cAlias)->(dbSeek(cComp))
While (cAlias)->(!Eof()) .And. ALLTRIM((cAlias)->(&(cINDICE))) == ALLTRIM(cComp)
	aAdd(aCols,Array(Len(aHeader)+1))
	nCols ++
	For nX := 1 To Len(aHeader)
		If ( aHeader[nX][10] != "V")
			aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
		Else
			aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
		Endif
	Next nX
	aCols[nCols][Len(aHeader)+1] := .F.
	(cAlias)->(dbSkip())
End

RestArea(aArea)
Return(aCols)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175BaixAcบAutor ณAlvaro Camillo Neto บ Data ณ  10/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a baixa da acelera็ใo                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175BaixAc(cN3Filial,cN3CBase,cN3Item,cN3Tipo,cN3Baixa,cN3Seq)
Local cFunBaixa	 := GetNewPar("MV_ATFRTBX", "ATFA036" )
Local aArea 	:= GetArea()
Local aAreaSN3  := SN3->(GetArea())
Local aAreaSN1	:= SN1->(GetArea())
Local lRet		:= .T.                                        
Local aPergunte	:= {}
Local nX		:= 0     
Local xAtivo := {}
Local xCab := {}
Local aParam	:= {}

Private lMsErroAuto := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdena็ใo das tabelas envolvidasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SN1->(dbSetOrder(1))	//N1_FILIAL+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(1))	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

If SN1->(MSSeek(cN3Filial+cN3CBase+cN3Item)) .And. SN3->(MSSeek(cN3Filial+cN3CBase+cN3Item+cN3Tipo+cN3Baixa+cN3Seq))
	If lContabiliza .And. lMostra
		aAdd( aParam, {"MV_PAR01", 1} )
		aAdd( aParam, {"MV_PAR03", 1} )		
	ElseIf lContabiliza
   		aAdd( aParam, {"MV_PAR01", 2} )
		aAdd( aParam, {"MV_PAR03", 1} )		
	Else
		aAdd( aParam, {"MV_PAR03", 2} )	
	EndIf  
	aAdd( aParam, {"MV_PAR02", IIF(lAglutina,1,2) } )	 

	xCab :={	{"FN6_FILIAL"	,xFilial("FN6")		,NIL},;
				{"FN6_CBASE"	,SN3->N3_CBASE		,NIL},;
				{"FN6_CITEM"	,SN3->N3_ITEM			,NIL},;
				{"FN6_QTDATU"	,SN1->N1_QUANTD		,NIL},;
				{"FN6_MOTIVO"	,"08" 					,NIL},;
				{"FN6_BAIXA"	,100					,NIL},;
				{"FN6_QTDBX"	,0						,NIL},;
				{"FN6_DTBAIX"	,dDatabase				,NIL},;
				{"FN6_NUMNF"	,""						,NIL},;
				{"FN6_SERIE"	,""						,NIL},;
				{"FN6_PERCBX"	,100					,NIL},;
				{"FN6_VALNF"	,0						,NIL},;
				{"FN6_DEPREC"	,'0'					,NIL}}

	xAtivo:={	{"N3_FILIAL"	,xFilial("SN3")		,NIL},;
				{"N3_CBASE"	,SN3->N3_CBASE		,NIL},;
				{"N3_ITEM"		,SN3->N3_ITEM			,NIL},;
				{"N3_TIPO"		,SN3->N3_TIPO			,NIL},;
				{"N3_BAIXA"	,SN3->N3_BAIXA		,NIL},;
				{"N3_TPSALDO"	,SN3->N3_TPSALDO		,NIL}}

	MsExecAuto({|a,b,c,d,e,f|ATFA036(a,b,c,d,e,f)},xCab,xAtivo,3,,.F.,aParam)
	If lMsErroAuto
		MostraErro()
	Endif
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura as perguntasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 To Len(aPergunte)
	&("MV_PAR"+STRZERO(nX,2)) := aPergunte[nX]
Next nX
	
RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aArea)
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175Val07บAutor  ณAlvaro Camillo Neto บ Data ณ  16/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a existencia de um tipo 07 no bem                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175Val07(cBase,cItem)
Local lRet 		:= .T.
Local cQuery    := ""
Local cTab 		:= getNextAlias()
Local aArea		:= GetArea()

cQuery += " SELECT Count(*) CONTSN3" 
cQuery += " FROM " + RetSQLTab("SN3")
cQuery += " WHERE " 
cQuery += " N3_CBASE = '"+cBase+"' AND "  
cQuery += " N3_ITEM = '"+cItem+"' AND "    
cQuery += " N3_TIPO = '07' AND "  
cQuery += " N3_BAIXA ='0' AND"
cQuery += RetSqlCond("SN3") 
cQuery := ChangeQuery(cQuery)
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .F., .T.)

lRet := Empty((cTab)->CONTSN3)
 
(cTab)->(dbCloseArea())
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175ValDeprบAutorณAlvaro Camillo Neto บ Data ณ  17/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o bem a ser acelerado jแ estแ depreciado          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175ValDepr(aHeader,aLinhaCols)
Local lOk 		:= .T.
Local nMoeda	:= 5
Local nX		:= 0
Local nDepre	:= 0
Local nVOrig	:= 0
Local nVAmpl	:= 0
Local nVAcm		:= 0
Local nPosDepr	:= 0
Local nPosVOrig	:= 0
Local nPosVAmpl	:= 0
Local nPosVAcm	:= 0
Local nMoedaAtf := Val(GetMV("MV_ATFMOEDA"))

For nX:= 1 to nMoeda
	nPosDepr	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_TXDEPR"+cValToChar(nX)) })
	nPosVOrig	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_VORIG"+cValToChar(nX)) })
	nPosVAmpl	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_AMPLIA"+cValToChar(nX)) })
	nPosVAcm	:= aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_VRDACM"+cValToChar(nX)) })
	nDepre		:= IIF( nPosDepr  > 0 ,aLinhaCols[nPosDepr] , 0 )
	nVOrig		:= IIF( nPosVOrig > 0 ,aLinhaCols[nPosVOrig], 0 )
	nVAmpl		:= IIF( nPosVAmpl > 0 ,aLinhaCols[nPosVAmpl], 0 )
	nVAcm		:= IIF( nPosVAcm  > 0 ,aLinhaCols[nPosVAcm] , 0 )
	// Caso o bem esteja depreciado na moeda, a taxa da deprecia็ใo acelerada serแ 0	
	If nVOrig + nVAmpl <= nVAcm
		nDepre := 0
		// Verifica se a moeda depreciada ้ a moeda 1 ou a oficial
		If nX == 1 .Or. nX == nMoedaAtf
			lOk := .F.
			Exit
		EndIf  
	EndIf
	
	aLinhaCols[nPosDepr] := nDepre  
Next nX

// Valida se o bem esta depreciado em todas as moedas,significando que o bem estแ depreciado
If lOk
	lOk := .F.
	For nX:= 1 to nMoeda
		nPosDepr := aScan(aHeader, {|aItem| AllTrim(aItem[2]) == AllTrim("N3_TXDEPR"+cValToChar(nX)) })
		If aLinhaCols[nPosDepr] > 0
			lOk := .T.
			Exit	
		EndIf	
	Next nX
EndIf
Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175Marc บAutor  ณAlvaro Camillo Neto บ Data ณ  16/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a tabela temporaria possui marca็ใo             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175Marc(cTabela,cAlias)
Local lRet := .T.
Local aArea:= GetArea()
Local cTab := GetNextAlias()
Local cQuery := ""
Local cCampo := PrefixoCpo( cAlias )+"_OK"
If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf

cQuery += " SELECT COUNT(*) CONTOK "
cQuery += " FROM " +cTabela
cQuery += " WHERE "+ cCampo + " <> '' "
cQuery := ChangeQuery(cQuery)
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .F., .T.)
lRet := !Empty((cTab)->CONTOK)
 
(cTab)->(dbCloseArea())

RestArea(aArea)
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjRetParamบAutor  ณAlvaro Camillo Neto บ Data ณ  17/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjusta as repostas do aParambox                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjRetParam(aRet,aParamBox)
Local nX	:= 1

IF ValType(aRet) == "A" .AND. Len(aRet) == Len(aParamBox)
	For nX := 1 to Len(aParamBox)
		If aParamBox[nX][1] == 1
			aRet[nX] := aRet[nX]
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "N"
			aRet[nX] := aRet[nX]
		Endif	
	Next nX
ENDIF

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF175ValPerบAutor ณAlvaro Camillo Neto บ Data ณ  17/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o percentual a ser acelerado                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF175ValPer(aRetMet,aPMetAtiv)
Local lRet := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPrepara os arrays dos paramboxณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRetMet := AjRetParam(aRetMet,aPMetAtiv)

If (aRetMet[1]) == PERCENTUAL .And. ( aRetMet[3] > 100 .Or. Empty(aRetMet[3]))
	Help("AF175ValPer",1,"HELP"	,,STR0068,1,0)//"Valor Invalido" 
	lRet := .F.
EndIf

Return lRet
