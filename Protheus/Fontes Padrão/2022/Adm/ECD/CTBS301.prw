#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "APWIZARD.CH"
#INCLUDE "ECD.CH"

//Compatibiliza็ใo de fontes 30/05/2018

Static __lDefTop	:= IfDefTopCTB()
Static __LALCodRev  := ""
Static __cGetDB := Alltrim(Upper(TCGetDB()))
//variavel static para objeto Wizard
Static __oWzrdLAL		:= Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณCTBS301   บAutor  ณMicrosiga		    	บ Data ณ17/11/2016บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณRotina para extracao de dados contabeis  para LALUR         บฑฑ
ฑฑบ          ณ														      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Function CTBS301(cEmp , cModEsc, bIncTree)
Local aArea    		:= GetArea()
Local aHeader		:= {}
Local aFils			:= {}	
Local lFWCodFil		:= FindFunction( "FWCodFil" )
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local lFim    		:= .F.
Local oFil 			:= Nil		//Objeto Filiais

Local oOk			:= Nil		//Botใo OK				
Local oNo			:= Nil		//Botใo No
Local cMatriz		:= Space(CtbTamFil("033",2))	//Filial Centralizadora

Private aPerWiz2	:= {}		//Parametros Wizard 2 
Private aPerWiz3	:= {}		//Parametros Wizard 3 
Private aPerWiz4	:= {}		//Parametros Wizard 4 
Private aResWiz2	:= {}		//Respostas Wizard 2 
Private aResWiz3	:= {}		//Respostas Wizard 3
Private aResWiz4	:= {}		//Respostas Wizard 4
Private aRespFils := {}

Default cEmp		:= ""	//C๓digo da Emp
Default bIncTree := {||.T.}

//---------------------------------------------
//Continua somente se for LALUR
//---------------------------------------------
If !(cModEsc == "LAL")
	Return
EndIf

//---------------------------------------------
//Verifica ambiente
//---------------------------------------------
If !__lDefTop
	Alert('Rotina disponํvel somemente para ambiente TOPCONNECT')
	Return
EndIf

LALAj_SXB()  //ajusta SXB para criar consulta padrao CV5001

//---------------------------------------------
//Carrega todas as filiais existentes
//---------------------------------------------
aHeader	:= ARRAY(5)
aHeader[1]	:= ""  		
aHeader[2]	:= IIF(lGestao,"Filial","Empresa/Unidade/Filial")
aHeader[3]	:= "Razใo Social"
aHeader[4]	:= "CNPJ"
aHeader[5]	:= ""
aFils		:= GetEmpEcd( cEmp )

//---------------------------------------------
//Carrega imagens dos botoes
//---------------------------------------------
oOk 		:= LoadBitmap( GetResources(), "LBOK")
oNo			:= LoadBitmap( GetResources(), "LBNO")

//---------------------------------------------
//ณ Montagem da Wizard                      
//---------------------------------------------
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

// Wizard1
DEFINE WIZARD __oWzrdLAL ;
	TITLE "Passo 01 - Assistente de Importa็ใo de Dados de Escritura็ใo Contแbil - Empresa: " + cEmp;
	HEADER "Aten็ใo";
	MESSAGE "" ;
	TEXT "Essa rotina tem como objetivo ajudแ-lo na Importa็ใo de Movimentos Contแbeis para o LALUR" + CRLF + "Siga atentamente os passos, pois iremos efetuar a exporta็ใo dos seus dados contแbeis." ;
	NEXT 	{||.T.} ;
	FINISH {||.T.}
	
// Wizard2
CREATE PANEL __oWzrdLAL  ;
	HEADER "Passo 02 - Escolha qual o tipo de escritura็ใo que irแ efetuar.";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValidaParam(aPerWiz2,aResWiz2)} ;
	PANEL   
	
	//Define os Paremtros
	ParamLAL( "02", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz2,"", @aResWiz2,,,,,,__oWzrdLAL:GetPanel(2))  

// Wizard3
CREATE PANEL __oWzrdLAL  ;
	HEADER "Passo 03 - Quais sใo as filiais que essa empresa centralizadora?";
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| ValidaEmpEcd(aFils,,aResWiz2,cMatriz)} ;
	PANEL

	oFil := TWBrowse():New( 0.5, 0.5 , 280, 100,Nil,aHeader, Nil, __oWzrdLAL:GetPanel(3), Nil, Nil, Nil,Nil,;
					      {|| aFils := EmpTrocEcd( oFil:nAt, aFils, .T. ,"LAL"), oFil:Refresh() })      

	oFil:SetArray( aFils )
	
	oFil:bLine := {|| {;
					If( aFils[oFil:nAt,1] , oOk , oNo ),;
						aFils[oFil:nAt,3],;
						aFils[oFil:nAt,4],;
						aFils[oFil:nAt,5];
					}}
   
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo utilizado para preenchimento da matriz	ณ
	//ณcaso a escritura็ใo seja com centraliza็ใo	ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู						
	@ 110,005 SAY "Matriz"  SIZE 070,010 PIXEL OF __oWzrdLAL:GetPanel(3)
	@ 110,025 MSGET cMatriz SIZE 015,005 PIXEL OF __oWzrdLAL:GetPanel(3) F3 "SM0_01" 
	
// Wizard4
CREATE PANEL __oWzrdLAL  ;
	HEADER "Passo 04 - Informe os dados para imporda็ใo dos dados para LALUR.";
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValidaParam(aPerWiz4,aResWiz4)} ;
	PANEL   
	
	//Define os Paremtros
	ParamLAL( "04", cModEsc )
	
	//Carrega parametros na tela do Wizard
	ParamBox( aPerWiz4,"", @aResWiz4,,,,,,__oWzrdLAL:GetPanel(4))

		
// Wizard Finaliza
CREATE PANEL __oWzrdLAL  ;
	HEADER "Etapa de Configura็ใo Finalizada!";
	MESSAGE ""	;
	BACK {|| .T.} ;
	FINISH {|| LALProcessa( cEmp,aFils,cMatriz,cModEsc,bIncTree,aResWiz2,aResWiz4)  };
	PANEL

	@ 050,010 SAY "Clique no botใo finalizar para fechar o wizard e iniciarmos a exporta็ใo dos dados para LALUR." SIZE 270,020 FONT oBold PIXEL OF __oWzrdLAL:GetPanel(5)
		
ACTIVATE WIZARD __oWzrdLAL CENTERED

RestArea( aArea )

//reseta variavel static do wizard
__oWzrdLAL := Nil

Return lFim

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณParamSped    บAutor  ณMicrosiga		 	บ Data ณ17/11/2016บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณDefine as perguntas e respostas especificas do Sped         บฑฑ
ฑฑบ          ณ														      บฑฑ
ฑฑบ          ณExemplo:												      บฑฑ
ฑฑบ          ณaRet[1]-> retorna as perguntas						      บฑฑ
ฑฑบ          ณaRet[2]-> retorna as respostas 						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function ParamLAL( cPasso, cModEsc )
Local aArea    		:= GetArea()
Local aEscrit		:= {"ECD","FCONT","ECF", "LALUR"}
Local aCentraliza	:= {"Com Centraliza็ใo", "Sem Centraliza็ใo"}

Local aOpta		:= {"S - Sim", "N - Nใo"}
Local aOpca		:= {"N - Normais", "E - Extemporโneos", "A - Ambos"}

//---------------------------------------------
//Wizard1 - Tela de Apresenta็ใo
//---------------------------------------------


//---------------------------------------------
//Wizard 02 - Define as op็๕es do Modo de Escritura็ใo
//---------------------------------------------
If cPasso = '02'	
	//Cria Perguntas
	aAdd(aPerWiz2 ,{3,"Centraliza็ใo"					,1,aCentraliza	,90,"",.T.,.T.})
	aAdd(aPerWiz2 ,{3,"Qual o Tipo de Escritura็ใo?"	,4,aEscrit		,90,"",.T.,.F.})
	
	//Seta a resposta padrใo
	aResWiz2	:= Array(Len(aPerWiz2))
	aResWiz2[1]	:= 1
	aResWiz2[2]	:= 4
EndIf


//---------------------------------------------
//Wizard3 - Define as empresas/filiais
//---------------------------------------------


//---------------------------------------------
//Wizard 04 - 
//---------------------------------------------
If cPasso = '04'
	If CV5->(ColumnPos("CV5_DESCRI")) > 0
		aAdd(aPerWiz4,{1,"Cod.Filtro LALUR"				,Space(Len(CV5->CV5_COD)),"@!","ExistCpo('CV5')","CV5002",,03,.T.})
	Else
		aAdd(aPerWiz4,{1,"Cod.Filtro LALUR"				,Space(Len(CV5->CV5_COD)),"@!","ExistCpo('CV5')","CV5001",,03,.T.})
	EndIf
	aAdd(aPerWiz4,{1,"Data Inicial"					,CTOD("20140101"),"","","",,60,.T.})
	aAdd(aPerWiz4,{1,"Data Final"					,CTOD("20141231"),"","","",,60,.T.})
	aAdd(aPerWiz4,{1,"Moeda"						,Space(CTO->(TamSx3("CTO_MOEDA")[1])) ,"@!","ExistCpo('CTO')","CTO",,05,.T.}) 
	aAdd(aPerWiz4,{1,"Tipo de Saldo"				,Space(1)	,"@!","","SLD" ,,05,.T.})
	aAdd(aPerWiz4,{3,"Processa C. Custo "			,2			,aOpta,65,"",.T.})
	aAdd(aPerWiz4,{3,"Carga Saldo Inicial "		,2			,aOpta,65,"",.T.})
	aAdd(aPerWiz4,{3,"Extrai movimentos "			,1			,aOpca,65,"",.T.})

	aResWiz4	:= Array(Len(aPerWiz4))
	aResWiz4[1]	:= Space(Len(CV5->CV5_COD))
	aResWiz4[2]	:= CTOD("")
	aResWiz4[3]	:= CTOD("")
	aResWiz4[4]	:= Space(CTO->(TamSx3("CTO_MOEDA" )[1]))
	aResWiz4[5]	:= Space(1)
	aResWiz4[6]:= 2
	aResWiz4[7]:= 2
	aResWiz4[8]:= 1

EndIf
	
RestArea( aArea )
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbTamFil บAutor  ณFelipe Cunha		 บ Data ณ  17/11/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o tamanho do campo do grupo informado  		      บฑฑ
ฑฑบ          ณ por ex. FILIAL                                                  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbTamFil(cGrupo,nTamPad)
Local nSize := 0

DbSelectArea("SXG")
DbSetOrder(1)

IF DbSeek(cGrupo)
	nSize := SXG->XG_SIZE
Else
	nSize := nTamPad
Endif

Return nSize


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLALProcessaบAutor ณEquipe CTB          บ Data ณ  17/11/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento da extracao de dados para LALUR              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LALProcessa( cEmp,aFils,cMatriz,cModEsc,bIncTree,aResWiz2,aResWiz4)
Local lRet := .T.
Local nRecCS0 := 0

Local cFiltLalur
Local dDataini
Local dDatafim
Local cMoeda
Local cTpSald
Local lProcCusto := .F.
Local lCargaIni  := .F.
Local oProcess

Private lExtem := .F.
Private lAmbos := .F.

cFiltLalur 	:= aResWiz4[1]
dDataini 	:= aResWiz4[2]
dDatafim 	:= aResWiz4[3]
cMoeda 		:= aResWiz4[4]
cTpSald 	:= aResWiz4[5]
lProcCusto 	:= (aResWiz4[6]==1)
lCargaIni 	:= (aResWiz4[7]==1)
lExtem	 	:= (aResWiz4[8]==2)
lAmbos	 	:= (aResWiz4[8]==3)

If Empty(dDataIni)
	dDataini 	:= CTOD("01/01/1980")
EndIf

If lCargaIni .And. !MsgNoYes("A carga inicial dos saldos somente deve ser efetuada uma unica vez."+CRLF+"Confirma a exportacao do saldo inicial de "+ DtoC(dDataIni)+ " ? ", "Carga Inical dos Saldos")
	lCargaIni 	:= .F.
EndIf

aParamLAL := Array( ECD_NUMCOLS )

aParamLAL[ ECD_CODEMP		] := cEmp
aParamLAL[ ECD_AFILS		] := aFils
aParamLAL[ ECD_TIPOESC		] := aResWiz2[1]
aParamLAL[ ECD_SIT_ESP		] := 1  //normal

aParamLAL[ ECD_DATA_INI		] := dDataini
aParamLAL[ ECD_DATA_FIM		] := dDataFim
aParamLAL[ ECD_DATA_LP		] := CtoD("")
aParamLAL[ ECD_CALENDARIO	] := ""
aParamLAL[ ECD_MOEDA		] := cMoeda
aParamLAL[ ECD_TIPO_SALDO	] := cTpSald
aParamLAL[ ECD_CONTA_INI	] := ""
aParamLAL[ ECD_CONTA_FIM	] := "ZZZZZZZZZZ"

aParamLAL[ ECD_PROC_CUSTO	] := lProcCusto

oProcess:= MsNewProcess():New( {|lEnd| LalurExpor( lEnd, oProcess, aParamLAL, cMatriz, afils, dDataini, dDatafim, cMoeda, cTpSald, lProcCusto,cModEsc, cFiltLalur, bIncTree, @nRecCS0, lCargaIni), EcdGetMsg()} )
oProcess:Activate()

nTamChv := Len(CT2->CT2_FILIAL) + 8  + Len(CT2->CT2_LOTE)+ Len(CT2->CT2_SBLOTE)+ Len(CT2->CT2_DEBITO) + Len(CT2->CT2_CCD)  //8 - CT2_DATA
If nTamChv > Len(CSB->CSB_NUMLOT)
	MsgAlert("Erro - Acertar tamanho dos campos CSA_NUMLOT/CSB_NUMLOT/CSB_NUMARQ para comportar a chave - Sugestao "+Alltrim(Str(nTamChv+25)) )
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLalurExpor บAutor ณEquipe CTB          บ Data ณ  17/11/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento da extracao de dados para LALUR              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LalurExpor( lEnd, oProcess, aParamLAL, cMatriz, afils, dDataini, dDatafim, cMoeda, cTpSald, lProcCusto, cModEsc, cFiltLalur, bIncTree, nRecCS0, lCargaIni)
Local lRet := .F.
Local oProc_1

DEFAULT lCargaIni := .F.

//Gera revisao na CS0
lRet := GeraRevisao( oProcess, aParamLAL, cMatriz, cModEsc, /*cEntRef*/, bIncTree, @nRecCS0 )


lRet := lRet .And. ExportaHistPadrao( oProcess )

If lRet
	CS0->( dbGoto( nRecCS0 ) )
	__LALCodRev := CS0->CS0_CODREV  //atribui na variavel static o codigo da revisao incluida
	LalurExMov( lEnd, oProcess, cFiltLalur, afils, dDataini, dDatafim, cMoeda, cTpSald, lProcCusto, cModEsc)   //exporta movimentos CT2 para CSA/CSB
	If lCargaIni
		LalurSldIni(lEnd, oProcess, cFiltLalur, afils, dDataini, dDatafim, cMoeda, cTpSald, lProcCusto, cModEsc)   //exporta saldo inicial como movimentos para CSA/CSB
	EndIf
	
	//------------------------------------------
	//Inicia a integra็ใo com a tabela TAFST1
	//------------------------------------------
	CS0->( dbGoto( nRecCS0 ) )
	
	oProc_1:= MsNewProcess():New( {|lEnd| CTBS301GER( CS0->CS0_CODREV, oProc_1, "TAFST1" ), "Integrando TAF" } )
	oProc_1:Activate()
	
EndIf
	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLalurExMov     บAutor  ณEquipe CTB     บ Data ณ  17/11/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para LALUR                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LalurExMov( lEnd, oProcess, cFiltLalur, afils, dDataini, dDatafim, cMoeda, cTpSald, lProcCusto, cModEsc)

Local aArea		:= GetArea()
Local aStruct	:= {}

Local cAliasCT2 := GetNextAlias()

Local cAliasCV5	:= "CV5"
Local cFilCT2	:= xFilial( "CT2" )
Local cFilCV5   := xFilial( "CV5" )
Local cChave	:= ""
Local cDoc     	:= ""
Local cIndDC    := ""

Local cQuery	:= ""
Local cWhere	:= ""
Local cQryGrp	:= ""
Local cQryOrd	:= ""

Local nIx		:= 0

Local lRet		:= .T.
Local lCplLote 	:= .F.
Local bCondCV5	:= {|| .T. }
Local bCondCt2	:= {|| .T. }
Local aProc     := {}
Local cProc     := ""
Local iX        := 0
Local iRet      := 0
Local axFil		:= {}
Local cExecDrop := ""
Local cAuxTpSald := ""
Local nX
Local cAuxEntid
Local cCpoEntid
Local cCpoFinal
Local cEmpOri := ""
Local cFilOri := ""
Local cLinha := ""
Local dDataExt := stod( "19801231" )


Private aResult := {}
Private lFoundCSQ := .F.

Default afils		:= {xFilial( "CT2" )}
Default dDataini	:= Ctod( "" )
Default dDatafim	:= stod( "19801231" )
Default cMoeda		:= "01"
Default cTpSald		:= "1"
Default lProcCusto	:= .F.

If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Movimenta็ใo" ) //"Exportando Movimenta็ใo"
Endif

For nIx := 1 To Len( aFils )  
    If aFils[nIx][1]
		Aadd( axFil , PadR( aFils[nIx][3], LEN(CT2->CT2_FILIAL) ) )
	EndIf
Next

	If __lDefTop
		cQuery := "SELECT "
		cQuery += " CV5.CV5_FILIAL, CV5.CV5_COD, CV5.CV5_EMPORI, CV5.CV5_FILORI, CV5.CV5_CT1ORI, "
		cQuery += " CV5.CV5_CT1FIM, CV5.CV5_CTTORI, CV5.CV5_CTTFIM, CV5.CV5_CTDORI, CV5.CV5_CTDFIM, "
		cQuery += " CV5.CV5_CTHORI, CV5.CV5_CTHFIM, CV5.CV5_EMPDES, CV5.CV5_FILDES "
		//DEMAIS ENTIDADES
		For nX := 5 to 9 //At้ no maximo nove entidades

			cAuxEntid := StrZero(nX, 2)
			cCpoEntid := "CV5_E"+cAuxEntid+"ORI"
			cCpoFinal := "CV5_E"+cAuxEntid+"FIM"

			If CV5->(FieldPos(cCpoEntid)) > 0  //se existir campo
				cQuery += ", CV5."+cCpoEntid+", CV5."+cCpoFinal
			Else
				Exit
			EndIf
					
		Next nX

		cQuery += " FROM " + RetSqlName( "CV5" ) + " CV5 "

		cQuery += " WHERE CV5.CV5_FILIAL " + GetRngFil( aXFil, "CV5" ) 
		cQuery += " AND CV5_COD = '"+cFiltLalur+"' " 
		cQuery += " AND CV5.D_E_L_E_T_ = ' ' " 
		cQuery += " ORDER BY "
		cQuery += " CV5.CV5_FILIAL, CV5.CV5_COD, CV5.CV5_EMPORI, CV5.CV5_FILORI, CV5.CV5_CT1ORI, "
		cQuery += " CV5.CV5_CT1FIM, CV5.CV5_CTTORI, CV5.CV5_CTTFIM, CV5.CV5_CTDORI, CV5.CV5_CTDFIM, "
		cQuery += " CV5.CV5_CTHORI, CV5.CV5_CTHFIM, CV5.CV5_EMPDES, CV5.CV5_FILDES "
		//DEMAIS ENTIDADES
		For nX := 5 to 9 //At้ no maximo nove entidades

			cAuxEntid := StrZero(nX, 2)
			cCpoEntid := "CV5_E"+cAuxEntid+"ORI"
			cCpoFinal := "CV5_E"+cAuxEntid+"FIM"

			If CV5->(FieldPos(cCpoEntid)) > 0  //se existir campo
				cQuery += ", CV5."+cCpoEntid+", CV5."+cCpoFinal
			Else
				Exit
			EndIf
					
		Next nX

		cQuery := ChangeQuery( cQuery )
		
		cAliasCV5 := GetNextAlias()
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCV5 )
		
		aStruct   := CV5->(dbStruct())
		
		For nIx := 1 To Len(aStruct)
			If aStruct[nIx][2] <> "C" .And. FieldPos(aStruct[nIx][1])<>0
				TcSetField(cAliasCV5,aStruct[nIx][1],aStruct[nIx][2],aStruct[nIx][3],aStruct[nIx][4])
			EndIf
		Next nIx
	Else
		
		dbSelectArea("CV5")
		dbSetOrder(1)
		MsSeek( cFilCV5 + cFiltLalur )
		
		bCondCV5 := {|| CV5->CV5_FILIAL+CV5->CV5_COD == cFilCV5 + cFiltLalur }
	EndIf
	
	While (cAliasCV5)->( !Eof() ) .And. Eval( bCondCV5 )
	
		cChave := ''

		cQuery := "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_DEBITO CONTA, CT2_CCD CCUSTO, CT2_LINHA, CT2_EMPORI, CT2_FILORI, SUM(CT2_VALOR)*-1 DEBITO, 0 CREDITO "
		cQuery += " FROM " + RetSqlName( "CT2" ) + " CT2 "
		cWhere := " WHERE CT2.CT2_FILIAL " + GetRngFil( aXFil, "CT2" ) 
        cWhere += " AND CT2_DC IN ('3','1') "    //DEBITOS

		//CONTA CONTABIL
		IF !Empty( (cAliasCV5)->CV5_CT1ORI ) .Or. !Empty( (cAliasCV5)->CV5_CT1FIM )
			cWhere := AddSqlExpr( cWhere ,	"  CT2_DEBITO BETWEEN '" + (cAliasCV5)->CV5_CT1ORI + "' AND '" + (cAliasCV5)->CV5_CT1FIM + "' " )
		Endif
		//CENTRO DE CUSTO
		IF !Empty( (cAliasCV5)->CV5_CTTORI ) .Or. !Empty( (cAliasCV5)->CV5_CTTFIM )
			cWhere := AddSqlExpr( cWhere ,	"  CT2_CCD BETWEEN '" + (cAliasCV5)->CV5_CTTORI + "' AND '" + (cAliasCV5)->CV5_CTTFIM + "' "  )
		Endif
		
		If !Empty( dDataIni )
			cWhere := AddSqlExpr( cWhere , "CT2.CT2_DATA >=" , dDataIni)
		Endif
		
		If !Empty( dDataFim )
			cWhere := AddSqlExpr( cWhere , "CT2.CT2_DATA <=" , dDataFim)
		Endif
		
		cWhere := AddSqlExpr( cWhere , "CT2.CT2_MOEDLC ="	, cMoeda  )
		cWhere := AddSqlExpr( cWhere , "CT2.CT2_TPSALD ="	, cTpSald )
		cWhere := AddSqlExpr( cWhere , "CT2.D_E_L_E_T_ = ' '" )
		
		cQuery += cWhere 
		cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_DEBITO, CT2_CCD, CT2_LINHA, CT2_EMPORI, CT2_FILORI"

		cWhere := " "
		cQuery += " UNION " 

		cQuery += "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_CREDIT CONTA, CT2_CCC CCUSTO,CT2_LINHA, CT2_EMPORI, CT2_FILORI, 0 DEBITO, SUM(CT2_VALOR) CREDITO"
		cQuery += " FROM " + RetSqlName( "CT2" ) + " CT2 "
		cWhere := " WHERE CT2.CT2_FILIAL " + GetRngFil( aXFil, "CT2" ) 
        cWhere += " AND CT2_DC IN ('3','2') "    //CREDITOS

		//CONTA CONTABIL
		IF !Empty( (cAliasCV5)->CV5_CT1ORI ) .Or. !Empty( (cAliasCV5)->CV5_CT1FIM )
			cWhere := AddSqlExpr( cWhere ,	"  CT2_CREDIT BETWEEN '" + (cAliasCV5)->CV5_CT1ORI + "' AND '" + (cAliasCV5)->CV5_CT1FIM + "' " )
		Endif
		//CENTRO DE CUSTO
		IF !Empty( (cAliasCV5)->CV5_CTTORI ) .Or. !Empty( (cAliasCV5)->CV5_CTTFIM )
			cWhere := AddSqlExpr( cWhere ,	"  CT2_CCC BETWEEN '" + (cAliasCV5)->CV5_CTTORI + "' AND '" + (cAliasCV5)->CV5_CTTFIM + "' "  )
		Endif
		
		If !Empty( dDataIni )
			cWhere := AddSqlExpr( cWhere , "CT2.CT2_DATA >=" , dDataIni)
		Endif
		
		If !Empty( dDataFim )
			cWhere := AddSqlExpr( cWhere , "CT2.CT2_DATA <=" , dDataFim)
		Endif
		
		cWhere := AddSqlExpr( cWhere , "CT2.CT2_MOEDLC ="	, cMoeda  )
		cWhere := AddSqlExpr( cWhere , "CT2.CT2_TPSALD ="	, cTpSald )
		cWhere := AddSqlExpr( cWhere , "CT2.D_E_L_E_T_ = ' '" )
		
		cQuery += cWhere 
		cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_CREDIT, CT2_CCC, CT2_LINHA, CT2_EMPORI, CT2_FILORI"


		cQuery += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CONTA, CCUSTO"

		If Alltrim(Upper(TcGetDb())) != "ORACLE"
			cQuery := ChangeQuery( cQuery )
		EndIf
		
		cAliasCT2Cab := GetNextAlias()
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCT2Cab )
		
		aStruct   := CT2->(dbStruct())
		
		For nIx := 1 To Len(aStruct)
			If aStruct[nIx][2] <> "C" .And. (cAliasCT2Cab)->(FieldPos(aStruct[nIx][1]))<>0
				TcSetField(cAliasCT2Cab,aStruct[nIx][1],aStruct[nIx][2],aStruct[nIx][3],aStruct[nIx][4])
			EndIf
		Next nIx
			

		While (cAliasCT2Cab)->( !Eof() )

			nValor	:= (cAliasCT2Cab)->( If(CREDITO==0, DEBITO, CREDITO) )
			cFilMov	:= (cAliasCT2Cab)->CT2_FILIAL
			dData	:= (cAliasCT2Cab)->CT2_DATA
			cLote	:= (cAliasCT2Cab)->CT2_LOTE
			cSbLote	:= (cAliasCT2Cab)->CT2_SBLOTE
			cDoc    := (cAliasCT2Cab)->CT2_DOC
				cLinha	:= (cAliasCT2Cab)->CT2_LINHA
			cEmpOri := (cAliasCT2Cab)->CT2_EMPORI
			cFilOri := (cAliasCT2Cab)->CT2_FILORI
		
			cIndDC  := If((cAliasCT2Cab)->CREDITO==0, "D", "C")
			
			cChave		:= cFilMov + DTOS( dData ) + cLote + cSbLote
			lFoundCSQ  :=  CSQ->(dbSeek(cFilMov+DTOS(dData)+cLote+cSbLote+cDoc+cLInha+cEmpOri+cFilOri))
			lFoundCSQ  :=  IIF(lFoundCSQ , IIF(CSQ->CSQ_NATLCT == '2', .T., .F.), .F.)
			If  lFoundCSQ 
				//gravar data informado no movimento (CT2)
				dDataExt := CSQ-> CSQ_DTEXT
			EndIf

			If lFoundCSQ .and. !lExtem .and. !lAmbos	
				(cAliasCT2Cab)->( dbSkip() )
				Loop
			ElseIf !lFoundCSQ .and. lExtem
				(cAliasCT2Cab)->( dbSkip() )
				Loop
			EndIf

			If cChave + cIndDC == (cAliasCT2Cab)->CT2_FILIAL + DTOS((cAliasCT2Cab)->CT2_DATA) + (cAliasCT2Cab)->CT2_LOTE + (cAliasCT2Cab)->CT2_SBLOTE + If((cAliasCT2Cab)->CREDITO==0, "D", "C")

				If CSA->( !dbSeek( xFilial("CSA") + __LALCodRev + DTOS( dData ) + cChave  ) )

					RecLock( "CSA" , .T. )
					CSA->CSA_FILIAL := xFilial("CSA")
					CSA->CSA_CODREV := __LALCodRev
					CSA->CSA_DTLANC := dData
					CSA->CSA_NUMLOT := cChave
					CSA->CSA_VLLCTO := Abs(nValor)
					CSA->CSA_INDTIP := IIF(lFoundCSQ, "X","N")  //ECDIndTip( cTpSald )
					If lFoundCSQ
						CSA->CSA_DTEXT  :=  dDataExt
					EndIf
					MsUnLock()
				EndIf
			EndIf 
			
			LALProcMov( cFilMov, dData, cLote, cSbLote,  cDoc, cIndDC, cMoeda, cTpSald, lProcCusto, oProcess, cModEsc, cAliasCT2, cAliasCV5, (cAliasCT2Cab)->(CONTA),(cAliasCT2Cab)->(CT2_LINHA),(cAliasCT2Cab)->(CCUSTO) , dDataExt,(cAliasCT2Cab)->CT2_EMPORI,(cAliasCT2Cab)->CT2_FILORI )
			(cAliasCT2Cab)->( dbSkip() )

		EndDo
		
		(cAliasCT2Cab)->( dbCloseArea() )

		DbSelectArea( cAliasCV5 )
		DbSkip()
		
	EndDo
	If __lDefTop
		DbSelectArea(cAliasCV5)
		DbCloseArea()
	EndIf
	
	//Ap๓s processar os movimentos acertar o valor da cabeca processando pela CSB pois como sใo por filtro na CV5 o valor pode nใo estar correto
	dbSelectArea("CSA")
	dbSetOrder(1)

	cQuery := " SELECT  CSB_DTLANC, CSB_NUMLOT, SUM(DEBITO) DEBITO, SUM(CREDITO) CREDITO FROM "
	cQuery += "      ( SELECT CSB_DTLANC, CSB_NUMLOT, SUM(CSB_VLPART) DEBITO, 0 CREDITO FROM " + RetSqlName("CSB")
	cQuery += "                  WHERE CSB_FILIAL = '" + xFilial("CSB") + "' "
	cQuery += "                    AND CSB_CODREV = '" + __LALCodRev + "' "
	cQuery += "                    AND CSB_INDDC = 'D' "
	cQuery += "                    AND D_E_L_E_T_ = ' ' "
	cQuery += "         GROUP BY  CSB_DTLANC, CSB_NUMLOT "

	cQuery += "         UNION "

	cQuery += "        SELECT CSB_DTLANC, CSB_NUMLOT, 0 DEBITO, SUM(CSB_VLPART) CREDITO FROM " + RetSqlName("CSB")
	cQuery += "                  WHERE CSB_FILIAL = '" + xFilial("CSB") + "' "
	cQuery += "                    AND CSB_CODREV = '" + __LALCodRev + "' "
	cQuery += "                    AND CSB_INDDC = 'C' "
	cQuery += "                    AND D_E_L_E_T_ = ' ' "
	cQuery += "         GROUP BY  CSB_DTLANC, CSB_NUMLOT "
	cQuery += "      ) DB_CR_CSB "
	cQuery += " GROUP BY  CSB_DTLANC, CSB_NUMLOT "
	cQuery += " ORDER BY  CSB_DTLANC, CSB_NUMLOT  "
 
	cQuery := ChangeQuery( cQuery )
		
	cAliasCT2Cab := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCT2Cab )
		
	TcSetField(cAliasCT2Cab,"CSB_DTLANC","D",8,0)
	TcSetField(cAliasCT2Cab,"DEBITO","N",18,2)
	TcSetField(cAliasCT2Cab,"CREDITO","N",18,2)
		
	While (cAliasCT2Cab)->( !Eof() )
	
		dbSelectArea("CSA")
		If dbSeek( xFilial("CSA") + __LALCodRev + DTOS( (cAliasCT2Cab)->CSB_DTLANC ) + (cAliasCT2Cab)->CSB_NUMLOT )
			RecLock( "CSA" , .F. )
			CSA->CSA_VLLCTO := MAX( (cAliasCT2Cab)->DEBITO, (cAliasCT2Cab)->CREDITO )
			MsUnLock()
		EndIf
	
		(cAliasCT2Cab)->( dbSkip() )
	
	EndDo

	(cAliasCT2Cab)->( dbCloseArea() )

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLALProcMov     บAutor  ณEquipe CTB     บ Data ณ  17/11/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para LALUR                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LALProcMov( cFilMov, dData, cLote, cSbLote, cDoc, cIndDC, cMoeda, cTpSald, lProcCusto, oProcess, cModEsc, cAliasCT2, cAliasCV5 ,cConta, cLinha, cCusto, dDataExt,cEmpOrig, cFilOrig)
Local aArea		:= GetArea()
Local aStruct	:= {}
Local nIx		:= 0

Local cSeqLan
Local cDtLP
Local cQuery	:= ""
Local cWhere	:= "" 
Local cQryOrd	:= ""
Local cChave	:= ""
Local lMovZerado:= GetNewPar( "MV_SPDAPZR" , .F. ) 	// parametro de verifica็ใo de movimento de apura็ใo zerado, se .T. irแ filtrar as movimenta็๕es
													// a ativa็ใo deste parametro poderแ implicar em uma aumento no tempo de processamento. ษ recomendado
Local cAliasHis	:= Criatrab(,.F.)


Default cFilMov		:= xFilial('CT2')
Default dData		:= cTod('')
Default cLote		:= ""
Default cSbLote		:= ""
Default lProcCusto	:= .F.
Default cAliasCT2 	:= GetNextAlias()
Default cConta		:= ""
Default cLinha		:= ""
Default cCusto		:= ""
Default cEmpOrig	:= ""
Default cFilOrig	:= ""



If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Movimenta็ใo" ) //"Exportando Movimenta็ใo"
	oProcess:SetRegua2(0)
Endif

If __lDefTop
	cQuery := "SELECT CT2.CT2_FILIAL, CT2.CT2_DATA	, CT2.CT2_LOTE	, CT2.CT2_SBLOTE, CT2.CT2_DOC	, CT2.CT2_LINHA" ;
				+ " , CT2.CT2_SEQLAN, CT2.CT2_DC	, CT2.CT2_DEBITO, CT2.CT2_CREDIT, CT2.CT2_HP 	, CT2.CT2_HIST"	 ;
				+ " , CT2.CT2_CCD	, CT2.CT2_CCC	, CT2.CT2_DTLP	, CT2.CT2_SEQHIS, CT2.CT2_MOEDLC, CT2.CT2_TPSALD";
				+ " , CT2.CT2_VALOR	, CT2.CT2_EMPORI, CT2.CT2_FILORI, CT2.CT2_CODPAR";
				+ " FROM " + RetSqlName( "CT2" ) + " CT2"
				
	cWhere := ""
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_FILIAL ="	, cFilMov )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_DATA ="		, dData   )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_LOTE ="		, cLote   )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_SBLOTE ="	, cSbLote )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_DOC ="	    , cDoc  )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_MOEDLC ="	, cMoeda  )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_TPSALD ="	, cTpSald )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_LINHA ="	, cLinha )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_EMPORI ="	, cEmpOrig )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_FILORI ="	, cFilOrig )

	If cIndDC  == "D" 
		//CONTA CONTABIL
		IF !Empty( (cAliasCV5)->CV5_CT1ORI ) .Or. !Empty( (cAliasCV5)->CV5_CT1FIM )
			cWhere := AddSqlExpr( cWhere ,	" CT2_DEBITO ='"+cConta +"'")
		Endif
		//CENTRO DE CUSTO
		IF !Empty( (cAliasCV5)->CV5_CTTORI ) .Or. !Empty( (cAliasCV5)->CV5_CTTFIM )
			cWhere := AddSqlExpr( cWhere ,	" CT2_CCD ='"+cCusto+"'")
		Endif
	Else
		//CONTA CONTABIL
		IF !Empty( (cAliasCV5)->CV5_CT1ORI ) .Or. !Empty( (cAliasCV5)->CV5_CT1FIM )
			cWhere := AddSqlExpr( cWhere ,	" CT2_CREDIT ='"+cConta+ "'")
		Endif
		//CENTRO DE CUSTO
		IF !Empty( (cAliasCV5)->CV5_CTTORI ) .Or. !Empty( (cAliasCV5)->CV5_CTTFIM )
			cWhere := AddSqlExpr( cWhere ,	" CT2_CCC ='"+cCusto+"'")
		Endif
	EndIf

	cWhere := AddSqlExpr( cWhere , "CT2.D_E_L_E_T_ = ' '" )
	cQryOrd := " ORDER BY " + SqlOrder( CT2->(IndexKey(10) ) )
	
	If Alltrim(Upper(TcGetDb())) != "ORACLE"
		cQuery := ChangeQuery( cQuery + cWhere + cQryOrd )
	Else
		cQuery := cQuery + cWhere + cQryOrd
	EndIf

//	cAliasCT2 := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2)
	
	aStruct   := CT2->(dbStruct())
	For nIx := 1 To Len(aStruct)
		If aStruct[nIx][2] <> "C" .And. (cAliasCT2)->( FieldPos(aStruct[nIx][1]) ) <>0
			TcSetField(cAliasCT2,aStruct[nIx][1],aStruct[nIx][2],aStruct[nIx][3],aStruct[nIx][4])
		EndIf
	Next nX
Endif

While (cAliasCT2)->( !Eof() )
	cFilMov	:= (cAliasCT2)->CT2_FILIAL
	dData	:= (cAliasCT2)->CT2_DATA
	cLote	:= (cAliasCT2)->CT2_LOTE
	cSbLote	:= (cAliasCT2)->CT2_SBLOTE
	cDoc 	:= (cAliasCT2)->CT2_DOC
	nValor	:= (cAliasCT2)->CT2_VALOR
	
	cChave	:= (cAliasCT2)->CT2_FILIAL 
	cChave	+= DTOS( (cAliasCT2)->CT2_DATA ) 
	cChave	+= (cAliasCT2)->CT2_LOTE 
	cChave	+= (cAliasCT2)->CT2_SBLOTE
	
	cMoeda	:= (cAliasCT2)->CT2_MOEDLC
	cTpSald	:= (cAliasCT2)->CT2_TPSALD
	cCodHis	:= (cAliasCT2)->CT2_HP
	cLinha	:= (cAliasCT2)->CT2_LINHA
	cCodPart:= (cAliasCT2)->CT2_CODPAR
	cEmpOri	:= (cAliasCT2)->CT2_EMPORI
	cFilOri	:= (cAliasCT2)->CT2_FILORI
	cSeqLan	:= (cAliasCT2)->CT2_SEQLAN
	cDtLP	:= (cAliasCT2)->CT2_DTLP
	
	If oProcess <> Nil 
		oProcess:IncRegua2( "Exportando Movimenta็ใo"+" "+ cChave )
	EndIf

	IF lMovZerado
		IF ! EcdMovZera( cFilMov, dData, (cAliasCT2)->CT2_DEBITO, (cAliasCT2)->CT2_CREDIT, cMoeda, cTpSald, lProcCusto, (cAliasCT2)->CT2_CCD , (cAliasCT2)->CT2_CCC )
			dbSelectArea( cAliasCT2 )
			dbSkip()
			Loop
		Endif
	Endif

	If (nValor <> 0)
		dbselectArea(cAliasCT2)
		cDescHist := Alltrim( (cAliasCT2)->CT2_HIST ) + LGetMovHist(cFilMov, dData, cLote, cSbLote, cDoc, cMoeda, cTpSald, cSeqLan, cAliasHis)
	
		If cIndDC == "D"   //(cAliasCT2)->CT2_DC == '1' .Or. (cAliasCT2)->CT2_DC == '3'
			LALGravaMov( cChave, cFilMov, dData, cLote, cSbLote, cDoc, 'D', (cAliasCT2)->CT2_DEBITO, IIF(lProcCusto,(cAliasCT2)->CT2_CCD,""), cMoeda, cTpSald, nValor, cCodHis, cDescHist, cLinha, cCodPart, cEmpOri, cFilOri, lProcCusto,dDataExt )
		Endif
		
		If cIndDC == "C"  //(cAliasCT2)->CT2_DC == '2' .Or. (cAliasCT2)->CT2_DC == '3'
			LALGravaMov( cChave, cFilMov, dData, cLote, cSbLote, cDoc, 'C', (cAliasCT2)->CT2_CREDIT, IIF(lProcCusto,(cAliasCT2)->CT2_CCC,""), cMoeda, cTpSald, nValor, cCodHis, cDescHist, cLinha, cCodPart, cEmpOri, cFilOri, lProcCusto,dDataExt) 
		Endif
	
		If ! Empty( (cAliasCT2)->CT2_DTLP )
			SetMovLpCSA( dData,cChave, cMoeda, cTpSald, cFilMov )
		Endif
	Endif
	
	DbSelectArea(cAliasCT2)
	(cAliasCT2)->(DbSkip())
EndDo

If __lDefTop
	DbSelectArea(cAliasCT2)
	DbCloseArea()
EndIf

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLALGravaMov    บAutor  ณEquipe CTB     บ Data ณ  17/11/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para LALUR                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LALGravaMov( cChave, cFilMov, dData, cLote, cSbLote, cDoc, cIndDc, cCodCta, cCCusto, cMoeda, cTpSald, nValor, cCodHis, cDescHist, cLinha, cCodPart, cEmpOri, cFilOri, lProcCusto,dDataExt )
Local aArea		:= GetArea()

DEFAULT cCCusto := " "

If Empty(cCCusto)
	cCCusto := Space( TAMSX3("CTT_CUSTO")[1] )
Endif

RecLock( "CSB" , .T. )
CSB->CSB_FILIAL := xFilial("CSB")
CSB->CSB_CODREV	:= __LALCodRev
CSB->CSB_NUMLOT	:= cChave
CSB->CSB_INDDC	:= cIndDc
CSB->CSB_CODCTA	:= cCodCta

If lProcCusto
	CSB->CSB_CCUSTO	:= cCCusto
EndIf         

CSB->CSB_CODHIS	:= cCodHis
CSB->CSB_HISTOR	:= cDescHist
CSB->CSB_CODPAR	:= cCodPart
CSB->CSB_LINHA	:= cLinha
CSB->CSB_VLPART	:= nValor
CSB->CSB_NUMARQ	:= cChave + cDoc + cLinha + cIndDc + cMoeda + cTpSald + cEmpOri + cFilOri
CSB->CSB_DTLANC := dData
If lFoundCSQ
	CSB->CSB_DTEXT  := dDataExt
EndIf
MsUnLock()

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLGetMovHistบAutor ณEquipe CTB          บ Data ณ  17/11/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LGetMovHist(cFilMov, dData, cLote, cSbLote, cDoc, cMoeda, cTpSald, cSeqLan, cAliasHist)
Local aArea		 := GetArea()
Local cQuery 	 := ""
Local cWhere 	 := ""
Local cQryOrd	 := ""
Local cDescHist	 := ""

Default cAliasHist := GetNextAlias()

If __lDefTop
	cQuery := "SELECT CT2_HIST HISTORICO" ;
			+ "  FROM " + RetSqlName( "CT2" ) + " CT2"
	
	cWhere := ""
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_FILIAL ="	, cFilMov )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_DATA ="		, dData   )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_LOTE ="		, cLote   )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_SBLOTE ="	, cSbLote )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_DOC ="		, cDoc	  )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_MOEDLC ="	, cMoeda  )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_TPSALD ="	, cTpSald )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_SEQLAN ="	, cSeqLan  )
	cWhere := AddSqlExpr( cWhere , "CT2.CT2_DC = '4'"	)
	cWhere := AddSqlExpr( cWhere , "CT2.D_E_L_E_T_ = ' '" )
	
	cQryOrd := " ORDER BY " + SqlOrder( CT2->(IndexKey(10) ) )
	
	If Alltrim(Upper(TcGetDb())) != "ORACLE"
		cQuery := ChangeQuery( cQuery + cWhere + cQryOrd )
	Else
		cQuery := cQuery + cWhere + cQryOrd
	EndIf

	IF Select( cAliasHist ) > 0
		DbSelectArea( cAliasHist )
		DbCloseArea()
		FErase(cAliasHist+GetDBExtension())
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasHist)
	
	While (cAliasHist)->(!Eof())
		
		cDescHist += " "+Alltrim( (cAliasHist)->HISTORICO )
		
		DbSelectArea( cAliasHist )
		DbSkip()
	EndDo
Endif

If __lDefTop
	DbSelectArea( cAliasHist )
	DbCloseArea()
Endif

RestArea( aArea )

Return cDescHist


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLalurSldIni    บAutor  ณEquipe CTB     บ Data ณ  17/11/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exporta็ใo dos dados para LALUR                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LalurSldIni( lEnd, oProcess, cFiltLalur, afils, dDataini, dDatafim, cMoeda, cTpSald, lProcCusto, cModEsc)

Local aArea		:= GetArea()
Local aStruct	:= {}

Local cAliasCT1 := GetNextAlias()

Local cAliasCV5	:= "CV5"
Local cFilCT1	:= xFilial( "CT1" )
Local cFilCV5   := xFilial( "CV5" )
Local cChave	:= ""
Local cDoc     	:= ""

Local cQuery	:= ""
Local cWhere	:= ""
Local cQryGrp	:= ""
Local cQryOrd	:= ""

Local nIx		:= 0

Local lRet		:= .T.
Local lCplLote 	:= .F.
Local bCondCV5	:= {|| .T. }
Local bCondCT1	:= {|| .T. }
Local aProc     := {}
Local cProc     := ""
Local iX        := 0
Local iRet      := 0
Local axFil		:= {}
Local cExecDrop := ""
Local cAuxTpSald := ""
Local nX
Local cAuxEntid
Local cCpoEntid
Local cCpoFinal
Local dData
Local cConta
Local cCusto
Local aValor
Local nTamChv
Private aResult := {}

Default afils		:= {xFilial( "CT1" )}
Default dDataini	:= Ctod( "19800101" )
Default dDatafim	:= stod( "19801231" )
Default cMoeda		:= "01"
Default cTpSald		:= "1"
Default lProcCusto	:= .F.


nTamChv := Len(CT2->CT2_FILIAL) + 8  + Len(CT2->CT2_LOTE)+ Len(CT2->CT2_SBLOTE)+ Len(CT2->CT2_DEBITO) + Len(CT2->CT2_CCD)  //8 - CT2_DATA
If nTamChv > Len(CSB->CSB_NUMLOT)
	MsgAlert("Erro - Acertar tamanho dos campos CSA_NUMLOT/CSB_NUMLOT/CSB_NUMARQ para comportar a chave - Sugestao "+Alltrim(Str(nTamChv+25)) )
EndIf

If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Saldo Inicial " )
Endif

For nIx := 1 To Len( aFils )  
    If aFils[nIx][1]
		Aadd( axFil , PadR( aFils[nIx][3], LEN(CT2->CT2_FILIAL) ) )
	EndIf
Next

	If __lDefTop
		cQuery := "SELECT "
		cQuery += " CV5.CV5_FILIAL, CV5.CV5_COD, CV5.CV5_EMPORI, CV5.CV5_FILORI, CV5.CV5_CT1ORI, "
		cQuery += " CV5.CV5_CT1FIM, CV5.CV5_CTTORI, CV5.CV5_CTTFIM, CV5.CV5_CTDORI, CV5.CV5_CTDFIM, "
		cQuery += " CV5.CV5_CTHORI, CV5.CV5_CTHFIM, CV5.CV5_EMPDES, CV5.CV5_FILDES "
		//DEMAIS ENTIDADES
		For nX := 5 to 9 //At้ no maximo nove entidades

			cAuxEntid := StrZero(nX, 2)
			cCpoEntid := "CV5_E"+cAuxEntid+"ORI"
			cCpoFinal := "CV5_E"+cAuxEntid+"FIM"

			If CV5->(FieldPos(cCpoEntid)) > 0  //se existir campo
				cQuery += ", CV5."+cCpoEntid+", CV5."+cCpoFinal
			Else
				Exit
			EndIf
					
		Next nX

		cQuery += " FROM " + RetSqlName( "CV5" ) + " CV5 "

		cQuery += " WHERE CV5.CV5_FILIAL " + GetRngFil( aXFil, "CV5" ) 
		cQuery += " AND CV5_COD = '"+cFiltLalur+"' " 
		cQuery += " AND CV5.D_E_L_E_T_ = ' ' " 
		cQuery += " ORDER BY "
		cQuery += " CV5.CV5_FILIAL, CV5.CV5_COD, CV5.CV5_EMPORI, CV5.CV5_FILORI, CV5.CV5_CT1ORI, "
		cQuery += " CV5.CV5_CT1FIM, CV5.CV5_CTTORI, CV5.CV5_CTTFIM, CV5.CV5_CTDORI, CV5.CV5_CTDFIM, "
		cQuery += " CV5.CV5_CTHORI, CV5.CV5_CTHFIM, CV5.CV5_EMPDES, CV5.CV5_FILDES "
		//DEMAIS ENTIDADES
		For nX := 5 to 9 //At้ no maximo nove entidades

			cAuxEntid := StrZero(nX, 2)
			cCpoEntid := "CV5_E"+cAuxEntid+"ORI"
			cCpoFinal := "CV5_E"+cAuxEntid+"FIM"

			If CV5->(FieldPos(cCpoEntid)) > 0  //se existir campo
				cQuery += ", CV5."+cCpoEntid+", CV5."+cCpoFinal
			Else
				Exit
			EndIf
					
		Next nX

		cQuery := ChangeQuery( cQuery )
		
		cAliasCV5 := GetNextAlias()
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCV5 )
		
		aStruct   := CV5->(dbStruct())
		
		For nIx := 1 To Len(aStruct)
			If aStruct[nIx][2] <> "C" .And. FieldPos(aStruct[nIx][1])<>0
				TcSetField(cAliasCV5,aStruct[nIx][1],aStruct[nIx][2],aStruct[nIx][3],aStruct[nIx][4])
			EndIf
		Next nIx
	Else
		
		dbSelectArea("CV5")
		dbSetOrder(1)
		MsSeek( cFilCV5 + cFiltLalur )
		
		bCondCV5 := {|| CV5->CV5_FILIAL+CV5->CV5_COD == cFilCV5 + cFiltLalur }
	EndIf
	
	While (cAliasCV5)->( !Eof() ) .And. Eval( bCondCV5 )
		

		cQuery := "SELECT CT1_FILIAL, CT1_CONTA "
		cQuery += " FROM " + RetSqlName( "CT1" ) + " CT1 "
		cWhere := " WHERE CT1.CT1_FILIAL " + GetRngFil( aXFil, "CT1" ) 
		//CONTA CONTABIL
		IF !Empty( (cAliasCV5)->CV5_CT1ORI ) .Or. !Empty( (cAliasCV5)->CV5_CT1FIM )
			cWhere := AddSqlExpr( cWhere ,	" CT1_CONTA BETWEEN '" + (cAliasCV5)->CV5_CT1ORI + "' AND '" + (cAliasCV5)->CV5_CT1FIM + "' "  )
		Endif
		cWhere := AddSqlExpr( cWhere , "CT1.D_E_L_E_T_ = ' '" )
		
		cQuery += cWhere 
		
		cQuery += " GROUP BY CT1_FILIAL, CT1_CONTA"
		cQuery += " ORDER BY CT1_FILIAL, CT1_CONTA"

		cQuery := ChangeQuery( cQuery )
		
		cAliasCT1Cab := GetNextAlias()
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCT1Cab )
		

		While (cAliasCT1Cab)->( !Eof() )
		
			cFilMov	:= xFilial("CT2") 
			cConta  := (cAliasCT1Cab)->CT1_CONTA
			dData	:= dDataIni-1  //SEMPRE A DATA ANTERIOR A DATA INICIAL
			cCusto  := Space(Len(CTT->CTT_CUSTO))
			cLote	:= "SLDINI"
			cSbLote	:= "001"

			If ! lProcCusto .OR. Empty( (cAliasCV5)->CV5_CTTORI )
			 
				aValor	:= SaldoCT7Fil(cConta,dData,cMoeda,cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,aXFil/*aSelFil*/,/*cArqCt7*/,/*lTodasFil*/)
				nValor  := aValor[1]  //saldo atual
				cChave		:= cFilMov + DTOS( dData ) + cLote + cSbLote + cConta + cCusto
				
				If nValor <> 0  //somente grava saldo se valor diferente de zero
					LALSldIni( cFilMov, dData, cLote, cSbLote, cMoeda, cTpSald, lProcCusto, oProcess, cModEsc, cAliasCT1, cAliasCV5, cConta, cCusto, cChave )
				EndIf

			Else
				aValor := {}
				dbSelectArea("CTT")
				dbSeek( xFilial("CTT")+(cAliasCV5)->CV5_CTTORI )
				While CTT->( !Eof() .And. CTT_CUSTO <= (cAliasCV5)->CV5_CTTFIM )
					cCusto := CTT->CTT_CUSTO
					aValor := SaldoCT3Fil(cConta,cCusto,dData,cMoeda,cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,aXFil/*aSelFil*/,/*lTodasFil*/)
					
					nValor  := aValor[1]  //saldo atual
					cChave		:= cFilMov + DTOS( dData ) + cLote + cSbLote + cConta + cCusto
					
					If nValor <> 0  //somente grava saldo se valor diferente de zero
						LALSldIni( cFilMov, dData, cLote, cSbLote, cMoeda, cTpSald, lProcCusto, oProcess, cModEsc, cAliasCT1, cAliasCV5, cConta, cCusto, cChave )
					EndIf
					
					cSbLote := Soma1(cSbLote)
					
					CTT->( dbSkip() )
				EndDO 
			EndIf
			
			(cAliasCT1Cab)->( dbSkip() )

		EndDo
		
		(cAliasCT1Cab)->( dbCloseArea() )
		
		DbSelectArea( cAliasCV5 )
		DbSkip()
		
	EndDo
	
	If __lDefTop
		DbSelectArea(cAliasCV5)
		DbCloseArea()
	EndIf

RestArea( aArea )

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLALSldIni   บAutorณPaulo Carnelossi     บ Data ณ  24/11/2016บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados  Contabeis	para LALUR - Saldo Inicial        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS301                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LALSldIni( cFilMov, dData, cLote, cSbLote, cMoeda, cTpSald, lProcCusto, oProcess, cModEsc, cAliasCT1, cAliasCV5, cConta, cCusto, cChave )
Local aArea := GetArea()
Local cDoc
Local cLinha
Local cIndDC
Local cEmpOri
Local cFilOri

If CSA->( !dbSeek( xFilial("CSA") + __LALCodRev + DTOS( dData ) + cChave  ) )
	RecLock( "CSA" , .T. )
	CSA->CSA_FILIAL := xFilial("CSA")
	CSA->CSA_CODREV := __LALCodRev
	CSA->CSA_DTLANC := dData
	CSA->CSA_NUMLOT := cChave
	CSA->CSA_VLLCTO := ABS( nValor )
	CSA->CSA_INDTIP := "I"
	MsUnLock()

	cDoc := '000001'
	cLinha := '001'
	cIndDC := If(nValor < 0, 'D', 'C')
	cEmpOri := cEmpAnt
	cFilOri := cFilMov
	
	RecLock( "CSB" , .T. )
	CSB->CSB_FILIAL := xFilial("CSB")
	CSB->CSB_CODREV	:= __LALCodRev
	CSB->CSB_NUMLOT	:= cChave
	CSB->CSB_INDDC	:= cIndDC 
	CSB->CSB_CODCTA	:= cConta
	
	If lProcCusto
		CSB->CSB_CCUSTO	:= cCusto
	EndIf         
	
	CSB->CSB_CODHIS	:= ""
	CSB->CSB_HISTOR	:= "CARGA SALDO INICIAL" 
	CSB->CSB_CODPAR	:= ""
	CSB->CSB_LINHA	:= cLinha
	CSB->CSB_VLPART	:= ABS(nValor)
	CSB->CSB_NUMARQ	:= cChave + cDoc + cLinha + cIndDc + cMoeda + cTpSald + cEmpOri + cFilOri
	CSB->CSB_DTLANC := dData
	MsUnLock()
EndIf

RestArea( aArea )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS301GER  บAutorณPaulo Carnelossi     บ Data ณ  24/11/2016บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados  Contabeis	para LALUR  		              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS301                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBS301GER( cCodRev, oProcess, cAlias )
Local aArea		:= GetArea()
Local aAreaCS0	:= CS0->(GetArea())
Local cAliasCSB	:= "CSB"
Local cAliasCS7	:= "CS7"
Local cFilCSB  	:= xFilial( "CSB" )
Local cFilCSA  	:= xFilial( "CSA" )
Local cFilCS7  	:= xFilial( "CS7" )
Local cMsg		:= ''
Local cQuery	:= ''
Local cKey		:= ''
Local lRet		:= .T.
Local cSeq		:= '001'
Local lTafInteg	:= FindFunction( "TAFAPIERP" )
Local lSldIni := .F.
Local lPGravado := .F.
Local cPer := ""
Local nTamCta := TamSx3("CSB_CODCTA")[1]
Local nVlLcto  := 0	
Local lAvanca := .T.

Default cCodRev 	:= ''
Default oProcess	:= Nil
Default cAlias		:= 'TAFST1'

Private cTicket
Private cData
Private cHora

cTicket	:= "LAL" + AllTrim(CS0->CS0_CODEMP) + AllTrim(CS0->CS0_CODFIL) + AllTrim(CS0->CS0_CODREV) +  Dtos(Date()) + StrTran(Time(),':','')
cData	:= Date()
cHora	:= Time()

If ! LALLmpSt1(cAlias)
	Alert('Exporta็ใo TAF abortada!', 'Aten็ใo')
	lRet := .F.
	Return(lRet)
EndIf

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando historico padrใo" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )
Endif

DbSelectArea( "CS7" )
DbSetOrder(1)

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	//Query sele็ใo Dados
	cQuery := ''
	cQuery := "	SELECT CS7.CS7_FILIAL,	"
	cQuery += "		   CS7.CS7_CODREV,	"
	cQuery += "		   CS7.CS7_CODHIS,	"
	cQuery += "		   CS7.CS7_DESCRI	"
	cQuery += "  FROM " + RetSqlName( "CS7" ) + " CS7"	
	cQuery += "	 WHERE   CS7.D_E_L_E_T_ = ' '				"	
	cQuery += "	 AND   CS7_FILIAL = '" + cFilCS7 + "'"	
	cQuery += "	 AND   CS7_CODREV = '" + cCodRev + "'"
	cQuery += "	 Order By  CS7.CS7_FILIAL, CS7.CS7_CODREV, CS7.CS7_CODHIS"
	
	cQuery := ChangeQuery( cQuery )
	cAliasCS7 := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCS7 )	
Endif

//-----------------------------------------------------
// Grava Dados TAFST1
//-----------------------------------------------------
While (cAliasCS7)->CS7_FILIAL == cFilCS7 .AND. (cAliasCS7)->(!Eof())

	//Monta a chave do registro
	cKey := (cAliasCS7)->CS7_FILIAL + (cAliasCS7)->CS7_CODREV + 'T125' + (cAliasCS7)->CS7_CODHIS 	

	//----------------------------------------
	// T125 - HISTORICO PADRONIZADO
	//----------------------------------------	
	//Montagem campo TAFMSG
	cMsg := ''
	cMsg := "|" + 'T125'							//REGISTRO
	cMsg += "|" + Alltrim((cAliasCS7)->CS7_CODHIS )
	cMsg += "|" + (cAliasCS7)->CS7_DESCRI
	cMsg += "|" + CRLF
	
	//Grava Dados na tabela TAFST1
	lRet := EcfGrvSt1(cAlias, cFilCS7, cKey, 'T125', cMsg , cSeq)	
	
	(cAliasCS7)->( dbSkip() )
EndDo

(cAliasCS7)->(dbCloseArea())


//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Movimentacao Contabil LALUR" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )
Endif

DbSelectArea( "CSB" )
DbSetOrder(1)

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	//Query sele็ใo Dados
	cQuery := ''
	cQuery := "	SELECT CSA.CSA_FILIAL,	"
	cQuery += "		   CSA.CSA_CODREV,	"
	cQuery += "		   CSA.CSA_DTLANC,	"
	cQuery += "		   CSA.CSA_NUMLOT,	"
	cQuery += "		   CSA.CSA_INDTIP,	"
	cQuery += "		   CSA.CSA_VLLCTO,	"
	cQuery += "	       CSB.CSB_FILIAL,	"
	cQuery += "		   CSB.CSB_CODREV,	"
	cQuery += "		   CSB.CSB_DTLANC,	"
	cQuery += "		   CSB.CSB_NUMLOT,	"
	cQuery += "		   CSB.CSB_LINHA,	"
	cQuery += "		   CSB.CSB_CODCTA,	"
	cQuery += "		   CSB.CSB_CCUSTO,	"
	cQuery += "		   CSB.CSB_VLPART,	"
	cQuery += "		   CSB.CSB_INDDC,	"
	cQuery += "		   CSB.CSB_NUMARQ,	"
	cQuery += "		   CSB.CSB_CODHIS,	"
	cQuery += "		   CSB.CSB_HISTOR,	"
	cQuery += "		   CSB.CSB_CODPAR   "
	cQuery += "  FROM " + RetSqlName( "CSB" ) + " CSB," +  RetSqlName( "CSA" ) + " CSA "	
	cQuery += "	 WHERE CSB.CSB_FILIAL = CSA.CSA_FILIAL	"
	cQuery += "	 AND   CSB.CSB_CODREV = CSA.CSA_CODREV	"
	cQuery += "	 AND   CSB.CSB_NUMLOT = CSA.CSA_NUMLOT	"
	cQuery += "	 AND   CSB.D_E_L_E_T_ = ' '				"
	cQuery += "	 AND   CSA.D_E_L_E_T_ = ' '				"	
	cQuery += "	 AND   CSB_FILIAL = '" + cFilCSB + "'"	
	cQuery += "	 AND   CSB_CODREV     = '" + cCodRev	+ "'"
	cQuery += "	 AND   CSA_FILIAL = '" + cFilCSA + "'"
	cQuery += "	 AND   CSA_CODREV     = '" + cCodRev	+ "'"

	cQuery += "	  Order By  CSB.CSB_FILIAL, CSB.CSB_CODREV, CSB.CSB_DTLANC, CSB.CSB_NUMLOT, CSB.CSB_LINHA "
	
	cQuery := ChangeQuery( cQuery )
	cAliasCSB := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSB )	
Endif

	/* Acumular o valor*/
While (cAliasCSB)->CSB_FILIAL == cFilCSB .AND. (cAliasCSB)->(!Eof())
	lSldIni := IIF(Alltrim((cAliasCSB)->CSA_INDTIP) = 'I', .T., .F. )
	cPer := Alltrim((cAliasCSB)->CSA_DTLANC)

	If lSldIni .And. (Empty(cPer) .or. cPer == Alltrim((cAliasCSB)->CSA_DTLANC) )	
		nVlLcto += (cAliasCSB)->CSA_VLLCTO
		
	EndIf
	(cAliasCSB)->( dbSkip() )	
EndDo

(cAliasCSB)->(DBGOTOP())
//-----------------------------------------------------
// Grava Dados TAFST1
//-----------------------------------------------------
While (cAliasCSB)->CSB_FILIAL == cFilCSB .AND. (cAliasCSB)->(!Eof())
	//controla o Skip no preenchimento do T124AA
	lAvanca := .T.	

	//Monta a chave do registro
	cKey := (cAliasCSB)->CSA_FILIAL + (cAliasCSB)->CSA_CODREV + 'T124' + (cAliasCSB)->CSB_NUMLOT 	
	lSldIni := IIF(Alltrim((cAliasCSB)->CSA_INDTIP) = 'I', .T., .F. )

	//----------------------------------------
	// T124 - CABECA LALUR CSA
	//----------------------------------------	
	//Montagem campo TAFMSG
	
	If !lSldIni // Se nใo for saldo inicial 
		cMsg := ''
		cMsg := "|" + 'T124'							//REGISTRO
		cMsg += "|" + Alltrim((cAliasCSB)->CSA_NUMLOT)	//LOTE/CHAVE DO LANCAMENTO
		cMsg += "|" + Alltrim((cAliasCSB)->CSA_DTLANC)	//DATA  LANCAMENTO
		cMsg += "|" + AllTrim(Str((cAliasCSB)->CSA_VLLCTO))				//VALOR DA PARTIDA
		cMsg += "|" + If(Alltrim((cAliasCSB)->CSA_INDTIP) = 'I','3', If(Alltrim((cAliasCSB)->CSA_INDTIP) = 'X', '4','1')) //INDTIP = I -->SALDO INICIAL  N - MOV.NORMAL 
		cMsg += "|" + CRLF
	/*Se for saldo inicial e eu jแ tiver gravado um T124 */
	ElseIf lSldIni .And. !lPGravado .And. ( Empty(cPer) .or. cPer <> Alltrim((cAliasCSB)->CSA_DTLANC) )
		cMsg := ''
		cMsg := "|" + 'T124'							//REGISTRO
		cMsg += "|" + Substr(Alltrim((cAliasCSB)->CSA_NUMLOT),1,( Len(Alltrim((cAliasCSB)->CSA_NUMLOT)) - nTamCta ))	//LOTE/CHAVE DO LANCAMENTO
		cMsg += "|" + Alltrim((cAliasCSB)->CSA_DTLANC)	//DATA  LANCAMENTO
		cMsg += "|" + AllTrim(Str(nVlLcto))	//VALOR DA PARTIDA
		cMsg += "|" + If(Alltrim((cAliasCSB)->CSA_INDTIP) = 'I','3', If(Alltrim((cAliasCSB)->CSA_INDTIP) = 'X', '4','1')) //INDTIP = I -->SALDO INICIAL  N - MOV.NORMAL 
		cMsg += "|" + CRLF
		cPer := Alltrim((cAliasCSB)->CSA_DTLANC)
	EndIf

	cSeq	:=  '001'
	//DETALHE LALUR - CSB
	If !lPGravado
		
		While (cAliasCSB)->( ! Eof() .And. (CSB_FILIAL + CSB_CODREV + 'T124' + CSB_NUMLOT == cKey .Or. lSldIni) )

			cMsg += "|T124AA" 									//REGISTRO
			cMsg += "|" + Alltrim((cAliasCSB)->CSB_CODCTA)		//COD_CTA
			cMsg += "|" + Alltrim((cAliasCSB)->CSB_CCUSTO)		//COD_CCUS
			
			cMsg += "|" + AllTrim(Str((cAliasCSB)->CSB_VLPART))				//VALOR DA PARTIDA
			cMsg += "|" + If(Alltrim((cAliasCSB)->CSB_INDDC) = 'D','1','2') //INDDC
			cMsg += "|" + Alltrim((cAliasCSB)->CSB_NUMARQ)	//LOTE/CHAVE DO LANCAMENTO+DOC ETC
			cMsg += "|" + Alltrim((cAliasCSB)->CSB_CODHIS)	//CODIGO DO HISTORICO
			cMsg += "|" + Alltrim((cAliasCSB)->CSB_CODPAR)	//CODIGO DO PARTICIPANTE
			cMsg += "|" + CRLF
			lPGravado := .T. 

			//Tratamento para gravar os dados na tabela TAFST1 
			// quando ultrapassar 10000 registros
			If Len( cMsg ) > 10000
				lRet := EcfGrvSt1(cAlias, cFilCSB, cKey, 'T124', cMsg ,cSeq)
				cMsg := ""
				cSeq := Soma1(cSeq)
			EndIf


			(cAliasCSB)->( dbSkip() )
			lSldIni := IIF(Alltrim((cAliasCSB)->CSA_INDTIP) = 'I', .T., .F. )
			lAvanca := .F.
		EndDo
	Endif
	lPGravado := .F.
	cMsg := cMsg + " "
	
	

	//Grava Dados na tabela TAFST1
	lRet := EcfGrvSt1(cAlias, cFilCSB, cKey, 'T124', cMsg , cSeq)
	if lAvanca 
	(cAliasCSB)->( dbSkip() )
	endIf
EndDo

(cAliasCSB)->(dbCloseArea())

If lTafInteg
	//--------------------------------
	//Prote็ใo para ambientes oracle
	// Nใo retirar esta instru็ใo
	//--------------------------------
	TcRefresh(cAlias)
	
	If Select(cAlias) >0
		(cAlias)->(dbCloseArea())
	EndIf

		If Aviso('Aten็ใo','Deseja continuar o processo de exporta็ใo dos dados para o TAF?' + CRLF + ;
		                                    'Este processo irแ executar os Jobs 0 e 2, Continuar?', {'Sim', 'Nใo'},2) == 1
			TAFAPIERP( '3' )
		EndIf
EndIf

If !lRet
	Alert('Exporta็ใo TAF abortada ou executada parcialmente!', 'Aten็ใo')
Else
	MsgInfo('Exporta็ใo TAF executada com sucesso!', '')
EndIf 

//--------------------------------
//Prote็ใo para ambientes oracle
// Nใo retirar esta instru็ใo
//--------------------------------
TcRefresh(cAlias)

If Select(cAlias) >0
	(cAlias)->(dbCloseArea())
EndIf

RestArea(aAreaCS0)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLALLmpSt1  บAutorณFelipe Cunha          บ Data ณ  24/11/2016บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Limpa dados na tabela TAFST1				                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS301                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LALLmpSt1(cAlias,lAutomato)
Local lRet			:= .T.
Local cQuery 		:= ''
Local cQryCount		:= ''
Local cAliasCount	:= ''
Local lFOpnTab		:= FindFunction( "FOpnTabTAf" )
Local aCamposAux	:= {}

Default cAlias	:= 'TAFST1'
Default lAutomato	:= .F.

//--------------------------------------------------------------
// Cria conexใo com a tabela TAFST1
//--------------------------------------------------------------
//Carrega estrutura da tabela
If lFOpnTab
	aCamposAux 	:= aClone(aCampos)
	lRet		:= FOpnTabTAf(cAlias,cAlias)
	aCampos 	:= aClone(aCamposAux)
Else
	lRet := .F.
EndIf

If !lRet 
	Alert('Tabela TAFST1 nใo localizada ou nใo existente. Execute o Wizard de Configura็ใo do TAF.')
	lRet:= .F.
	Return lRet
EndIf

//-------------------------------------------
// NรO RETIRAR ESTA INSTRIวรO
//  Prote็ใo para for็ar a atualiza็ใo do TOP
//-------------------------------------------
TcRefresh(cAlias)	
DbSelectArea(cAlias)
DbGobottom()
DbGoTop()

If __lDefTop .AND. lRet
	
	//Verifica se existe registro na TAFST1
	cQryCount := ''
	cQryCount := 'Select Count(*) TAFCOUNT from TAFST1'
	cAliasCount := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryCount) , cAliasCount,.T.,.T.)
	
	//------------------------------------------------------------
	//Se nใo existir for็o a cria็ใo de um registro
	// Isso ira atualizar a tabela e evitar os seguintes erros
	// 1 - Gravar o campo TAFMSG em branco
	// 2 - Gravar os dados do campo TAFMSG errado
	//------------------------------------------------------------
	If (cAliasCount)->(Eof()) .Or. (cAliasCount)->TAFCOUNT <= 0
		RecLock( "TAFST1" , .T. )
			nRecno := TAFST1->(Recno())
			DbSelectArea("TAFST1")
		MsUnlock()
		(cAliasCount)->( dbCloseArea() )
		
		//-----------------------------------------
		//Quando for ambiente Oracle o registro jแ 
		//  ้ incluso deletado
		//-----------------------------------------
		If Upper(__cGetDB) == "MSSQL"
			DbGoTo(nRecno)
			RecLock( "TAFST1" , .F. )
				DbDelete()
			MsUnlock()		
		EndIf
	//Caso exista fa็o a limpeza
	ElseIf lAutomato
	
		cQuery := ''
		cQuery := "UPDATE TAFST1           "
		cQuery += " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_   "
		cQuery += " WHERE TAFTICKET LIKE 'LAL%' "
		cQuery += " AND TAFFIL = '" + CS0->CS0_CODEMP + CS0->CS0_CODFIL + "'"
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		TcSQLExec(cQuery)
		DbCommit()
	
	ElseIf Aviso('Aten็ใo','Deseja continuar o processo de exporta็ใo dos dados para o TAF?' + CRLF + ;
                                    'Este processo irแ fazer a limpeza da tabela TAFST1, Continuar?', {'Sim', 'Nใo'},2) == 1
		cQuery := ''
		cQuery := "UPDATE TAFST1           "
		cQuery += " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_  "
		cQuery += " WHERE TAFTICKET LIKE 'LAL%' "
		cQuery += " AND TAFFIL = '" + CS0->CS0_CODEMP + CS0->CS0_CODFIL + "'"
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		TcSQLExec(cQuery)
		DbCommit()
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLALAj_SXB  บAutorณPaulo Carnelossi      บ Data ณ  24/11/2016บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria SXB CV5001 - Filtro LALUR        	                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS301                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LALAj_SXB()

//  XB_ALIAS XB_TIPO XB_SEQ XB_COLUNA XB_DESCRI XB_DESCSPA XB_DESCENG XB_CONTEM

Local aSXB   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local cAlias := ''
Local lSXB   := .F.

If (cPaisLoc == "BRA")
	aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}
Else
	aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}
EndIf

// -------------------------------------------------------
aAdd(aSXB,{"CV5001","1","01","DB","Cod.Filtro LALUR","Cod.Filtro LALUR","Cod.Filtro LALUR","CV5"})
aAdd(aSXB,{"CV5001","2","01","02","Cod.Filtro LALUR","Cod.Filtro LALUR","Cod.Filtro LALUR",""})
aAdd(aSXB,{"CV5001","4","01","01","Cod Filtro          ","Cod Filtro          ","Cod Filtro          ","CV5_COD"})
aAdd(aSXB,{"CV5001","4","01","02","Conta De            ","Conta De            ","Conta De            ","CV5_CT1ORI"})
aAdd(aSXB,{"CV5001","4","01","03","Conta Ate           ","Conta Ate           ","Conta Ate           ","CV5_CT1FIM "})
aAdd(aSXB,{"CV5001","4","01","04","Centro Custo De     ","Centro Custo De     ","Centro Custo De     ","CV5_CTTORI "})
aAdd(aSXB,{"CV5001","4","01","05","Centro Custo Ate    ","Centro Custo Ate    ","Centro Custo Ate    ","CV5_CTTFIM "})
aAdd(aSXB,{"CV5001","5","01",""  ,""                    ,""                    ,""                    ,"CV5->CV5_COD"})
aAdd(aSXB,{"CV5001","6","01",""  ,""                    ,""                    ,""                    ,"CV5->CV5_FILIAL==xFilial('CV5') .And. CV5->CV5_EMPORI==CV5->CV5_EMPDES .And. CV5->CV5_FILORI==CV5->CV5_FILDES .And. Alltrim(CV5->CV5_CT1DES) == 'LALUR'"})

dbSelectArea("SXB")
dbSetOrder(1)
For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !dbSeek(Padr(aSXB[i,1], Len(SXB->XB_ALIAS))+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
			lSXB := .T.
			If !(aSXB[i,1]$cAlias)
				cAlias += aSXB[i,1]+"/"
			EndIf
			
			RecLock("SXB",.T.)
			
			For j:=1 To Len(aSXB[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
			//IncProc("Atualizando Consultas Padroes...") // //"Atualizando Consultas Padroes..."
		EndIf
	EndIf
Next i

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CtbFilLal
Funcao para consulta padrao especifica CV5002 - Cad.Filtro LALUR

@author TOTVS
@since 02/05/2018
@version P12
/*/
//-------------------------------------------------------------------

Function CtbFilLal()

Local cCodigo := ""
Local cTitulo := ""
Local aDados  := {}
Local aRegs   := {}
Local aTitCab := {}
Local lOk     := .F.

cTitulo := "Pesquisa Filtro Lalur"
aAdd(aTitCab, "Codigo")
aAdd(aTitCab, "Descri็ใo")

If FwIsInCallStack("CTBS301")
	cCodigo	:= aResWiz4[1]
EndIf

CtbLe_Dado(aDados, aRegs, .T.)

lOk := Ctb_LBOpc(cTitulo, aTitCab,aDados, aRegs, @cCodigo)

If FwIsInCallStack("CTBS301")
	&(READVAR()) := cCodigo
	aResWiz4[1]	:= cCodigo
	Ctbs301Rfh()
EndIf

Return(lOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbLe_Dado
Leitura dos dados da CV5 e armazenagem em array de dados e de recnos

@author TOTVS
@since 02/05/2018
@version P12
/*/
//-------------------------------------------------------------------

Static Function CtbLe_Dado(aDados, aRegs, lCarRecno)
Local cDBType
Local lOracle
Local lPostgres
Local lDB2
Local lInformix
Local cSrvType
Local cOpConcat
Local cQuery := ''

Default aDados := {}
Default aRegs  := {} 
Default lCarRecno := .F.

cDBType		:= Alltrim(Upper(TCGetDB()))
cSrvType 	:= Alltrim(Upper(TCSrvType()))
lOracle		:= "ORACLE"   $  cDBType
lPostgres 	:= "POSTGRES" $  cDBType
lDB2		:= "DB2"      $  cDBType
lInformix 	:= "INFORMIX"   $  cDBType
cOpConcat  	:= If(  lOracle .Or.  lPostgres .Or.  lDB2 .Or.  lInformix, " || ", " + " )

If CV5->(ColumnPos("CV5_DESCRI")) > 0
	cQuery := " SELECT DISTINCT CV5_COD, CV5_DESCRI FROM "+RetSqlName("CV5")
Else
	cQuery := " SELECT DISTINCT CV5_COD, 'FILTRO LALUR '"+cOpConcat+"CV5_COD CV5_DESCRI FROM "+RetSqlName("CV5")
EndIf

cQuery += " WHERE "
cQuery += "     CV5_FILIAL = '"+xFilial("CV5")+"' "
cQuery += " AND CV5_CT1DES = '"+PADR("LALUR",LEN(CV5->CV5_CT1DES))+"' "
cQuery += " AND CV5_EMPORI = CV5_EMPDES  "
cQuery += " AND CV5_FILORI = CV5_FILDES "
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery  )

//abre a query com mesmo alias da dimensao
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMP_CV5", .T., .T. )

While TMP_CV5->(! Eof() )
	
	If Empty(TMP_CV5->CV5_DESCRI)
		aAdd(aDados,{ TMP_CV5->CV5_COD, "FILTRO LALUR "+Alltrim( TMP_CV5->CV5_COD ) })
	Else
		aAdd(aDados,{ TMP_CV5->CV5_COD, TMP_CV5->CV5_DESCRI })
	EndIf  
	
	If lCarRecno
		
		If CV5->( dbSeek( xFilial("CV5")+TMP_CV5->CV5_COD ) )
			aAdd( aRegs, CV5->( Recno() ) )
		EndIf
		
	EndIf	
	
	TMP_CV5->( dbSkip() )
EndDo

TMP_CV5->( dbCloseArea() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb_LBOpc
List Box para selecionar codigo Filtro Lalur

@author TOTVS
@since 02/05/2018
@version P12
/*/
//-------------------------------------------------------------------

Static Function Ctb_LBOpc(cTitulo, aTitCab,aDados, aRegs, cCodigo)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oListBox
Local oPanel
Local cConteudo := ""
Local nPosList  := 0
Local lOk		:= .F.

Default cTitulo := ""
Default aTitCab := {}
Default aDados := {}
Default aRegs  := {} 
Default cCodigo := ""

If Len(aDados) > 0 .And. Len(aTitCab) > 0

	cConteudo := cCodigo
	If !Empty(cConteudo)
		nPosList := ASCAN(aDados, {|aVal| aVal[1] == Upper(cConteudo)})
	EndIf


	DEFINE MSDIALOG oDlg FROM 00,00 TO 390,590 PIXEL TITLE OemToAnsi(cTitulo) 

	oPanel := TPanel():New(1,1,'',oDlg,oDlg:oFont, .T., .T.,,,204,140,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 0,0 BITMAP oBmp RESNAME "PARAMETROS" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
	oListBox := TWBrowse():New( 40,05,204,140,,aTitCab,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox:SetArray(aDados)
	oListBox:bLine := { ||{aDados[oListBox:nAT][1],aDados[oListBox:nAT][2]}}
	oListBox:bLDblClick := { ||Eval(oConf:bAction), oDlg:End()}
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT


	@ 170,125  BUTTON oConf Prompt 'Visualiza' SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.T.,CTBS301View( aRegs[oListBox:nAT] ) )  OF oDlg PIXEL 

	@ 170,175 BUTTON oConf Prompt 'Confirma' SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.T.,CV5->(dbGoto(aRegs[oListBox:nAT])), cCodigo:=aDados[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL //'Confirma'
	@ 170,225 BUTTON oCanc Prompt 'Cancela' SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.F.,oDlg:End())  OF oDlg PIXEL //'Cancela'

	If nPosList > 0
		oListBox:nAT   := nPosList
		oListBox:bLine := { ||{aDados[oListBox:nAT][1],aDados[oListBox:nAT][2]}}
		oConf:SetFocus()
	EndIf

	ACTIVATE MSDIALOG oDlg CENTERED

	If ! lOk  //se nao confirmou limpar a variavel cCodigo
		cCodigo := Space(Len(cConteudo))
	EndIf

EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctbs301View
Visualizar cadastro do filtro Lalur posicionado no List Box

@author TOTVS
@since 02/05/2018
@version P12
/*/
//-------------------------------------------------------------------

Static Function Ctbs301View(nRegCV5)

CV5->(dbGoto(nRegCV5))
FWExecView("Filtro Lalur","CTBS300",MODEL_OPERATION_VIEW)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Ctbs301Rfh
Refresh de tela para contemplar cons padrao Cod.Filtro Lalur

@author TOTVS
@since 02/05/2018
@version P12
/*/
//-------------------------------------------------------------------
Function Ctbs301Rfh()
__oWzrdLAL:oBack:SetFocus()
__oWzrdLAL:GetPanel(4):refresh()
Return(.T.)


