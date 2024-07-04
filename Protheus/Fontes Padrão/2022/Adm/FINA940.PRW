#Include 'Protheus.CH'
#Include 'FINA940.CH'
#Include "ApWizard.ch"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES DE NOPC DA ROTINAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE VISUALIZAR		2
#DEFINE INCLUIR			3
#DEFINE EFETIVAR		4

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do array para controle do processamento MultThreadณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE ARQUIVO		 		1
#DEFINE MARCA		  		2
#DEFINE QTD_REGISTROS		3

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine cores do checkณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE	COR_MARCA		"LBOK"
#DEFINE	COR_NAOMARCA	"LBNO"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES DE TIPOS DE CALCULOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE	CONSTITUICAO	'C'
#DEFINE	AJUSTE_AVP		'A'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES de Tipos de Metodos de AVPณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE	TAXA_INFORMADA			1
#DEFINE	FORMULA					2
#DEFINE	INDICE_FINANCEIRO		3

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDEFINES Posi็๕es do array de respostasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE PROCESSO			01
#DEFINE DATA_PROC			02
#DEFINE VALOR_DE			03
#DEFINE VALOR_ATE			04
#DEFINE VENCTO_DE			05
#DEFINE VENCTO_ATE			06
#DEFINE EMISSAO_DE          07
#DEFINE EMISSAO_ATE			08
#DEFINE NATUREZA_DE			09
#DEFINE NATUREZA_ATE		10
#DEFINE PORTADOR_DE			11
#DEFINE PORTADOR_ATE		12
#DEFINE CLIENTE_DE			13
#DEFINE LOJA_DE				14
#DEFINE CLIENTE_ATE			15
#DEFINE LOJA_ATE	  		16
#DEFINE METODO		  		17

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFlag de processamento escrito no arquivo de controle ณ
//ณde threads                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE OK		 		"OK"
#DEFINE ERRO		 	"ERRO"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA940 บAutor  ณAlvaro Camillo Neto   บ Data ณ  15/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajuste a valor presente da carteira de contas a receber    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA940()
Local aCores   		:= Fin940Leg(.T.)
Local nNumProc		:= GetMv("MV_AVPTHR", .F., 1 )
Local cFilSQL		:= Nil
Private cCadastro 	:= STR0001 //"Ajuste de Valor Presente (Contas a Receber)"
Private aRotina 	:= MenuDef()

ChkFile("FIN")
ChkFile("FIO")
ChkFile("FIP")

If nNumProc < 1 .or. nNumProc > 15
	Help(" ",1,"AVPTHREAD",,STR0004,1,0)//"O valor do parโmetro MV_AVPTHR estแ definido com valor fora da faixa permitida (entre 1 e 15 threads)"
	Return( .F. )
EndIf

dbSelectArea("FIO")
FIO->( dbSetOrder( 1 ) )

If ExistBlock("F940FSQL")	// Filtro SQL na MBrowser
	cFilSQL := ExecBlock("F940FSQL",.F.,.F.)
EndIf

mBrowse(,,,,"FIO",,,,,,aCores,,,,,,,,cFilSQL)

Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSimula็ใo da constitui็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN940Sim บAutor  ณAlvaro Camillo Neto บ Data ณ  29/12/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Simula็ใo da constitui็ใo do AVP                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function FIN940Sim(cAlias, nReg, nOpc)
Local cTitulo 		:= STR0005//"Simulacao da contitui็ใo do Ajuste do valor presente : Contas a Receber"
Local cMsg	  		:= STR0006//"Esta rotina tem o objetivo de realizar a simulacao das constiui็๕es do AVP de novos tํtulos"
Local lEfetiva   	:= .F.
Local aRetPer		:= {}

F940WizCon(cTitulo,cMsg,lEfetiva,@aRetPer,.F.)

If Inclui
	MBrChgLoop(.F.)
Endif

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940WizConบAutor ณAlvaro Camillo Neto บ Data ณ  29/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o wizard de processamento de constituicao            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F940WizCon(cTitulo,cMsg,lEfetiva,aRetPer, lProcessar)
Local oWizard 		:= Nil
Local aPWiz1 		:= {}
Local aPWiz2 		:= {}
Local aPWiz3 		:= {}
Local aPWiz4 		:= {}
Local aRetWiz1		:= {}
Local aRetWiz2		:= {}
Local aRetWiz3		:= {}
Local aRetWiz4		:= {}
Local nOpcRot		:= 0
Local nSaveSx8Len 	:= GetSx8Len()
Local cCodAVP		:= GetSxeNum('FIO','FIO_PROC')
Local nX			:= 0
Local lRet			:= .F.
Local lF940PAR1 := ExistBlock("F940PAR1")
Local lF940PAR2 := ExistBlock("F940PAR2")

Default lProcessar := .F. // variavel para indicar que a chamada veio pelo menu Processar

//Wizard 1: Defini็ใo do c๓digo do processo
//Wizard 2: Relevancia de tํtulos : Valor de At้ / Vencimento de At้ / Em AVP ou novos
//Wizard 3: Filtro de titulos: Tipo / Natureza de Ate / Portador	de ate/ Cliente 	de ate
//Wizard 4: M้todo : Taxa Global / F๓rmula / Indice
//MBROWSE: GetDados com os titulos

//Wizard 1
aAdd(aPWiz1,{ 1,	STR0007,	Space(TamSx3('FIO_PROC')[1]),"@!","","","AllwaysFalse()",100,	.T.})//"Processo"
aAdd(aPWiz1,{ 1,	STR0008,	Space(TamSx3('E1_VENCTO')[1]),X3Picture('E1_VENCTO'),"","","INCLUI",50,	.T.})//"Data Processamento"
aAdd(aRetWiz1,cCodAVP)
aAdd(aRetWiz1,dDataBase)

//Wizard 2
aAdd(aPWiz2,{ 1,	STR0009,	Space(TamSx3('E1_VALOR')[1]),X3Picture('E1_VALOR')    ,"","","",100,	.F.})//"Valor De  "
aAdd(aPWiz2,{ 1,	STR0010,	Space(TamSx3('E1_VALOR')[1]),X3Picture('E1_VALOR')    ,"","","",100,	.F.})//"Valor At้ "
aAdd(aPWiz2,{ 1,	STR0011,	Space(TamSx3('E1_VENCTO')[1]),X3Picture('E1_VENCTO')  ,"","","",50,	.F.})//"Vencimento de "
aAdd(aPWiz2,{ 1,	STR0012,	Space(TamSx3('E1_VENCTO')[1]),X3Picture('E1_VENCTO')  ,"","","",50,	.F.})//"Vencimento At้ "
aAdd(aPWiz2,{ 1,	STR0085,	Space(TamSx3('E1_EMISSAO')[1]),X3Picture('E1_EMISSAO'),"","","",50,	.F.})//"Emissใo de "
aAdd(aPWiz2,{ 1,	STR0086,	Space(TamSx3('E1_EMISSAO')[1]),X3Picture('E1_EMISSAO'),"","","",50,	.F.})//"Emissใo At้ "

aAdd(aRetWiz2,0)
aAdd(aRetWiz2,99999999.99)
aAdd(aRetWiz2,cTod(""))
aAdd(aRetWiz2,ddatabase)
aAdd(aRetWiz2,cTod(""))
aAdd(aRetWiz2,ddatabase)

//Wizard 3
aAdd(aPWiz3,{ 1,	STR0013	,Space(TamSx3('E1_NATUREZ')[1])	,X3Picture('E1_NATUREZ')	,"","SED","",100,	.F.}) //"Natureza De"
aAdd(aPWiz3,{ 1,	STR0014	,Space(TamSx3('E1_NATUREZ')[1])	,X3Picture('E1_NATUREZ')	,"","SED","",100,	.F.}) //"Natureza At้"
aAdd(aPWiz3,{ 1,	STR0015	,Space(TamSx3('E1_PORTADO')[1])	,X3Picture('E1_PORTADO')	,"","SA6","",100,	.F.}) //"Portador De "
aAdd(aPWiz3,{ 1,	STR0016	,Space(TamSx3('E1_PORTADO')[1])	,X3Picture('E1_PORTADO')	,"","SA6","",100,	.F.}) //"Portador At้ "
aAdd(aPWiz3,{ 1,	STR0017	,Space(TamSx3('E1_CLIENTE')[1])	,X3Picture('E1_CLIENTE')	,"","SA1","",100,	.F.}) //"Cliente De "
aAdd(aPWiz3,{ 1,	STR0018	,Space(TamSx3('E1_LOJA')[1])	,X3Picture('E1_LOJA')		,"",""	 ,"",30, 	.F.}) //"Loja De "
aAdd(aPWiz3,{ 1,	STR0019	,Space(TamSx3('E1_CLIENTE')[1])	,X3Picture('E1_CLIENTE')	,"","SA1","",100,	.F.}) //"Cliente At้ "
aAdd(aPWiz3,{ 1,	STR0020	,Space(TamSx3('E1_LOJA')[1])	,X3Picture('E1_LOJA')		,"",""	 ,"",30,	.F.}) //"Loja At้ "

IF lF940PAR1
	aPWiz3 := ExecBlock("F940PAR1",.F.,.F.,{aPWiz3})
EndIf

aAdd(aRetWiz3,Space(TamSx3('E1_NATUREZ')[1]))
aAdd(aRetWiz3,Replicate( "Z" , TamSx3('E1_NATUREZ')[1]) )
aAdd(aRetWiz3,Space(TamSx3('E1_PORTADO')[1]))
aAdd(aRetWiz3,Replicate( "Z" ,TamSx3('E1_PORTADO')[1]))
aAdd(aRetWiz3,Space(TamSx3('E1_CLIENTE')[1]))
aAdd(aRetWiz3,Space(TamSx3('E1_LOJA')[1]))
aAdd(aRetWiz3,Replicate( "Z" ,TamSx3('E1_CLIENTE')[1]))
aAdd(aRetWiz3,Replicate( "Z" ,TamSx3('E1_LOJA')[1]))

IF lF940PAR2
	aOriRWiz3 := AClone(aRetWiz3)
	aRetWiz3  := ExecBlock("F940PAR2",.F.,.F.,{aRetWiz3})
EndIf

//Wizard 4
aAdd(aPWiz4,{ 3,	STR0021,1,{STR0022,STR0023,STR0024},50,"",.T.})//"M้todo"##"Taxa Informada"##"F๓rmula"##"Indice"
aAdd(aRetWiz4,1)

DEFINE WIZARD oWizard TITLE cTitulo;
       HEADER STR0025 ; //"Parametrizacao"
       MESSAGE STR0026 ;//"Parโmetros Iniciais..."
       TEXT cMsg;
       NEXT {||.T.} ;
       FINISH {|| .F. } ;
       PANEL

	//Wizard 1
   CREATE PANEL oWizard ;
          HEADER STR0027; 	//"Tipos de A็ใo"
          MESSAGE "";
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .F. } ;
          PANEL

	//Wizard 2
   CREATE PANEL oWizard ;
          HEADER STR0028;  //"Relevancia de tํtulos"
          MESSAGE "";
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .F. } ;
          PANEL

	//Wizard 3
   CREATE PANEL oWizard ;
          HEADER STR0029; //"Filtro de titulos"
          MESSAGE "";
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .F. } ;
          PANEL

 	//Wizard 4
   CREATE PANEL oWizard ;
          HEADER STR0030;//"M้todo"
          MESSAGE "";
          BACK {|| .T. } ;
          NEXT {|| .F. } ;
          FINISH {|| nOpcRot := 1 , .T. } ;
          PANEL

ParamBox(aPWiz1,STR0031,@aRetWiz1,,,,,,oWizard:GetPanel(2))//"Parโmetros..."
ParamBox(aPWiz2,STR0031,@aRetWiz2,,,,,,oWizard:GetPanel(3))//"Parโmetros..."
ParamBox(aPWiz3,STR0031,@aRetWiz3,,,,,,oWizard:GetPanel(4))//"Parโmetros..."
ParamBox(aPWiz4,STR0031,@aRetWiz4,,,,,,oWizard:GetPanel(5))//"Parโmetros..."

ACTIVATE WIZARD oWizard CENTERED

// Consolida as perguntas em um array
For nX := 1 to Len(aRetWiz1)
	aAdd(aRetPer,aRetWiz1[nX])
Next nX

For nX := 1 to Len(aRetWiz2)
	aAdd(aRetPer,aRetWiz2[nX])
Next nX

If ! lF940PAR2
	For nX := 1 to Len(aRetWiz3)
		aAdd(aRetPer,aRetWiz3[nX])
	Next nX
Else
	For nX := 1 to Len(aOriRWiz3)
		aAdd(aRetPer,aOriRWiz3[nX])
	Next nX
EndIf

For nX := 1 to Len(aRetWiz4)
	aAdd(aRetPer,aRetWiz4[nX])
Next nX

If lF940PAR2
	For nX := Len(aOriRWiz3) + 1 to Len(aRetWiz3)
		aAdd(aRetPer,aRetWiz3[nX])
	Next nX
EndIf

If nOpcRot == 1
	lRet := F940SelCon(aRetPer,lEfetiva,lProcessar)
	nOpcRot	:= IIF( lRet, 1, 0)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฐ
//ณRetorna a numera็ใo caso o usuแrio nใo confirmeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If nOpcRot == 0
	While GetSx8Len() > nSaveSx8Len
		RollBackSx8()
	End
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940SelConบAutor  ณAlvaro Camillo Netoบ Data ณ  21/12/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra a tela de sele็ใo do titulo para processamento      บฑฑ
ฑฑบ          ณ da constituicao dos titulos                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940SelCon(aRetPer,lEfetiva,lProcessar)
Local lRet 			:= .T.
Local lMostra		:= .T.
Local nPosMarca		:= 0
Local cPeriod		:= ""
Local nTxInfor		:= 0
Local cFormula		:= Space(TamSx3('FIN_FORMUL')[1])
Local cIndice		:= Space(TamSx3('FIN_CODIND')[1])
Local nOpcA			:= 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsNewGetDados()      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aHeader  		:= {}
Local aCols			:= {}
Local nOpcX			:= GD_UPDATE							 	//GD_INSERT+GD_UPDATE+GD_DELETE					// Op็ใo da MsNewGetDados
Local cLinhaOk     	:= "AllwaysTrue"  							// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"							// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""			               			  	// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              						// Campos estaticos na GetDados.
Local nMax         	:= 999              						// Numero maximo de linhas permitidas.
Local aAlter    	:= {}                                      	// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"			 				// Funcao executada na validacao do campo
Local cSuperDel     := "AllwaysTrue"        	  			    // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        := "AllwaysTrue" 			 				// Funcao executada para validar a exclusao de uma linha do aCols

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis para a MsAdvSize e MsObjSizeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lEnchBar   	:= .F. // Se a janela de diแlogo possuirแ enchoicebar (.T.)
Local lPadrao    	:= .F. // Se a janela deve respeitar as medidas padr๕es do Protheus (.T.) ou usar o mแximo disponํvel (.F.)
Local nMinY	    	:= 400 // Altura mํnima da janela
Local aSize	   		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects	  	:= {}
Local aPosObj	   	:= {}

Local oDlg			:= Nil
Local oPanelSup		:= Nil
Local oPanelMed		:= Nil

Private oGetTitulos	:= Nil

Default lProcessar := .F. // variavel para indicar que a chamada veio pelo menu Processar
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefini็ใo das posi็๕es dos objetos na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para os dados Enchoice
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.})
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o a Header e o acolsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeader  := F940HeadCon(aRetPer)
aCols	 := F940aColCon(aHeader , aRetPer)

If Empty(aCols) .And. !lEfetiva
	Help (" ",1,"FIN940NOTI",,STR0032,1,0)//"Nใo foram encontrados registros para este processo. Por favor, verifique a parametriza็ใo do processo"
	lRet 		:= .F.
	lMostra  := .F.
ElseIf Empty(aCols)
	lRet 		:= MsgYesNo(STR0033, STR0034)//"Nใo hแ constitui็๕es para o perํodo, deseja continuar para ajustar os titulo em processo de AVP?"##"Aten็ใo"
	lMostra  := .F.
EndIf

If lRet .And. lMostra
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefini็ใod dos Objetosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEstrutura de Panelsณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPanelSup 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,60,60,.T.,.T. )
	oPanelSup:Align 	:= CONTROL_ALIGN_TOP
	oPanelMed 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,100,100,.T.,.T. )
	oPanelMed:Align 	:= CONTROL_ALIGN_ALLCLIENT

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMsNewGetDadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(aAlter,'CHECKBOL'		)
	aAdd(aAlter,'FIN_TAXAVP'	)
	aAdd(aAlter,'FIN_PERIOD'	)
	aAdd(aAlter,'FIN_FORMUL'	)
	aAdd(aAlter,'FIN_CODIND'	)

	oGetTitulos	:= 	MsNewGetDados():New(0,0,100,100,nOpcX,;
	cLinhaOk ,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oPanelMed,aHeader,aCols)
	oGetTitulos:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

	nPosMarca	:= aScan(oGetTitulos:aHeader,{|x|AllTrim(Upper(x[2]))== 'CHECKBOL'})

	oGetTitulos:oBrowse:bLDblClick := ;
	{|| Iif(oGetTitulos:oBrowse:nColPos==nPosMarca,;
	Iif(	oGetTitulos:aCols[oGetTitulos:nAt,nPosMarca]==COR_NAOMARCA,;
	oGetTitulos:aCols[oGetTitulos:nAt,nPosMarca]:=COR_MARCA,;
	oGetTitulos:aCols[oGetTitulos:nAt,nPosMarca]:=COR_NAOMARCA;
	),oGetTitulos:EditCell()),;
	oGetTitulos:oBrowse:Refresh()}

	If aRetPer[METODO] == TAXA_INFORMADA
		oGrpTxInfor		:= TGroup():New(010,010,053,225,"",oPanelSup,,,.T.)
		oSayTxInfor		:= TSay():New(018,020,{|| STR0035},oPanelSup,,,,,,.T.,CLR_BLACK,CLR_WHITE,120,20)//"Taxa AVP Informada:"
		oGetTxInfor		:= TGet():New(018,100,bSetGet(nTxInfor),oPanelSup,050,010,X3Picture('FIN_TAXAVP') ,,,,,,,.T.)
		oSayTxPeriod	:= TSay():New(033,020,{|| STR0036},oPanelSup,,,,,,.T.,CLR_BLACK,CLR_WHITE,120,20)//"Periodicidade Taxa:"
		oComboTxPeriod	:= tComboBox():New(033,100,{|u|if(PCount()>0,cPeriod:=u,cPeriod)},GetAVPCombo('FIN_PERIOD'),70,20,oPanelSup,,,,,,.T.,,,,,,,,,'cPeriod')
		oButTxInfor		:= tButton():New(018,180,STR0037, oPanelSup ,{||FinAVPTInf(oGetTitulos,nTxInfor,cPeriod,'FIN_TAXAVP','FIN_PERIOD')},40,15,,,,.T.)//'Aplicar'
	ElseIf aRetPer[METODO] == FORMULA
		oGrpFormula		:= TGroup():New(010,010,053,225,STR0038,oPanelSup,,,.T.)//"F๓rmula"
		oSayFormula		:= TSay():New(018,020,{|| STR0038+":"},oPanelSup,,,,,,.T.,CLR_BLACK,CLR_WHITE,120,20)//"F๓rmula"
		oGetFormula		:= TGet():New(018,100,bSetGet(cFormula),oPanelSup,050,010,"@!",,,,,,,.T.,,,,,,,,,"SM4")
		oButFormula		:= tButton():New(018,180,STR0037, oPanelSup ,{||FinAVPTFor(oGetTitulos,cFormula,"FIN_FORMUL")},40,15,,,,.T.)//'Aplicar'
	ElseIf aRetPer[METODO] == INDICE_FINANCEIRO
		oGrpIndice		:= TGroup():New(010,010,053,225,STR0039,oPanelSup,,,.T.)//"อndice"
		oSayIndice		:= TSay():New(018,020,{||STR0039},oPanelSup,,,,,,.T.,CLR_BLACK,CLR_WHITE,120,20)//"อndice"
		oGetIndice		:= TGet():New(018,100,bSetGet(cIndice),oPanelSup,050,010,"@!",{|o|FinAVPIDOK(cIndice,aRetPer)},,,,,,.T.,,,,,,,,,"FIT")
		oButIndice		:= tButton():New(018,180,STR0037, oPanelSup ,{||FinAVPTInd(oGetTitulos,cIndice,'FIN_CODIND')},40,15,,,,.T.)//'Aplicar'
	EndIf

	oGrpTxInfo2		:= TGroup():New(008,230,053,292,STR0040,oPanelSup,,,.T.)//"Sele็ใo de Registros"
	oButMarcaTds	:=tButton():New(018,240,STR0041, oPanelSup ,{||FinAVPMTodG(oGetTitulos)},40,15,,,,.T.)//'Todos'
	oButInverte 	:=tButton():New(035,240,STR0042, oPanelSup ,{||FinAVPInvG(oGetTitulos)},40,15,,,,.T.)//'Inverte'

	oDlg:bInit 		:= EnchoiceBar(oDlg,{||nOpca:=1,If(FinAVPTOK(oGetTitulos,aRetPer,{nTxInfor,cPeriod,cFormula,cIndice},'FIN_TAXAVP','FIN_PERIOD',"FIN_FORMUL",'FIN_CODIND'),oDlg:End(),nOpca:=0)},{||RollBackSX8(),oDlg:End()})
	oDlg:lCentered	:= .T.
	oDlg:Activate()


	If nOpcA == 1
		MsgRun( STR0043,, {|| lRet := F940ConAVP(oGetTitulos,aRetPer,lEfetiva,lProcessar)  } )//"Realizando as constitui็๕es de AVP do periodo..."
	Else
		If Empty(aCols)
			lRet := MsgYesNo( STR0084 ) //"Deseja continuar o processamento do AVP ?"
		Else
			lRet := .F.
		EndIF
	EndIf

EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940HeadConบAutorณAlvaro Camillo Neto บ Data ณ  21/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o aHeader da getdados para processamento da        บฑฑ
ฑฑบ          ณ constituicao dos titulos                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940 e FINA950                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940HeadCon(aRetPer)
Local aHeader 	:= {}
Local aCpos	  	:= {}
Local nX		  	:= 0
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

aAdd(aCpos,"E1_PREFIXO"	)
aAdd(aCpos,"E1_NUM"		)
aAdd(aCpos,"E1_PARCELA"	)
aAdd(aCpos,"E1_TIPO"	)
aAdd(aCpos,"E1_CLIENTE"	)
aAdd(aCpos,"E1_LOJA"	)
aAdd(aCpos,"E1_EMISSAO"	)
aAdd(aCpos,"E1_VENCTO"	)
aAdd(aCpos,"E1_VALOR"	)
aAdd(aCpos,"E1_SALDO"	)

If aRetPer[METODO] == TAXA_INFORMADA
	aAdd(aCpos,'FIN_TAXAVP'	)
	aAdd(aCpos,'FIN_PERIOD'	)
ElseIf aRetPer[METODO] == FORMULA
	aAdd(aCpos,'FIN_FORMUL'	)
ElseIf aRetPer[METODO] == INDICE_FINANCEIRO
	aAdd(aCpos,'FIN_CODIND'	)
EndIf

aAdd(aHeader, { '', 'CHECKBOL', '@BMP', 10, 0,,, 'C',, 'V' ,  ,  , } )

SX3->(dbSetOrder(2)) //X3_CAMPO
For nX := 1 to Len(aCpos)
	If SX3->( MsSeek(aCpos[nX]) )
			aAdd( aHeader, { AlLTrim( X3Titulo() ), ; 	// 01 - Titulo
			SX3->X3_CAMPO	, ;							// 02 - Campo
			SX3->X3_Picture	, ;							// 03 - Picture
			SX3->X3_TAMANHO	, ;							// 04 - Tamanho
			SX3->X3_DECIMAL	, ;							// 05 - Decimal
			SX3->X3_Valid  	, ;							// 06 - Valid
			SX3->X3_USADO  	, ;							// 07 - Usado
			SX3->X3_TIPO   	, ;							// 08 - Tipo
			SX3->X3_F3		, ;	  						// 09 - F3
			SX3->X3_CONTEXT , ;    				   	    // 10 - Contexto
			SX3->X3_CBOX	, ;				 	 	    // 11 - ComboBox
			SX3->X3_RELACAO    } )  				 	// 12 - Relacao
	EndIf
Next nX


RestArea( aAreaSX3 )
RestArea( aArea )
Return aHeader


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940aColConบAutor ณALvaro Camillo Neto บ Data ณ  21/12/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche o array acols com os dados dos titulos para       บฑฑ
ฑฑบ          ณ processamento da constitui็ใo dos titulos                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940aColCon( aHeader , aRetPer)
Local aCols 	:= {}
Local cQuery    := ""
Local cTab		:= FAVPNextAlias()
Local nX		:= 0
Local aStruSE1  := SE1->( DbStruct() )
Local cCpos		:= ""
Local nPos		:= 0
Local aArea		:= GetArea()
Local nCols		:= 0
Local cSepNeg   := If("|"$MV_CPNEG,"|",",")
Local cSepPag   := If("|"$MVPAGANT,"|",",")
Local cSepProv  := If("|"$MVPROVIS,"|",",")
Local cSepTxa   := If("|"$MVTXA,"|",",")
Local cSepTx	:= If("|"$MVTAXA,"|",",")
Local lF940PAR3 := ExistBlock("F940PAR3")

cQuery := " SELECT "
For nX := 1 to Len(aHeader)
	If  'E1' $ aHeader[nX][2]
		cQuery += aHeader[nX][2]+ ","
	EndIf
Next nX
cQuery := Left(cQuery,Len(cQuery)-1)
cQuery += " FROM " + RetSQLTab("SE1")
cQuery += " WHERE "
cQuery += " E1_VALOR 	>= " + cValToChar(aRetPer[VALOR_DE]) + " AND "
cQuery += " E1_VALOR 	<= " + cValToChar(aRetPer[VALOR_ATE])+ " AND "
cQuery += " E1_VENCTO 	>= '" + dToS(aRetPer[VENCTO_DE])  + "' AND "
cQuery += " E1_VENCTO 	<= '" + dToS(aRetPer[VENCTO_ATE]) + "' AND "
cQuery += " E1_EMISSAO 	>= '" + dToS(aRetPer[EMISSAO_DE]) + "' AND "
cQuery += " E1_EMISSAO 	<= '" + dToS(aRetPer[EMISSAO_ATE])+ "' AND "
cQuery += " E1_TIPO NOT IN " + FormatIn(MVABATIM,"|")      + " AND "
cQuery += " E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " AND "
cQuery += " E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
cQuery += " E1_TIPO NOT IN " + FormatIn(MVRECANT,cSepPag)  + " AND "
cQuery += " E1_TIPO NOT IN " + FormatIn(MVTXA,cSepTxa)  + " AND "
cQuery += " E1_TIPO NOT IN " + FormatIn(MVTAXA,cSepTx)  + " AND "
cQuery += " E1_NATUREZ 	>= '" + aRetPer[NATUREZA_DE]  + "' AND "
cQuery += " E1_NATUREZ 	<= '" + aRetPer[NATUREZA_ATE] + "' AND "
cQuery += " E1_PORTADO 	>= '" + aRetPer[PORTADOR_DE]  + "' AND "
cQuery += " E1_PORTADO 	<= '" + aRetPer[PORTADOR_ATE] + "' AND "
cQuery += " E1_CLIENTE 	>= '" + aRetPer[CLIENTE_DE]   + "' AND "
cQuery += " E1_LOJA 	>= '" + aRetPer[LOJA_DE]      + "' AND "
cQuery += " E1_CLIENTE 	<= '" + aRetPer[CLIENTE_ATE]  + "' AND "
cQuery += " E1_LOJA 	<= '" + aRetPer[LOJA_ATE]     + "' AND "
If lF940PAR3
	cQuery += ExecBlock("F940PAR3",.F.,.F.,{aRetPer})
EndIf
cQuery +=  RetSQLCond('SE1') + " AND "
cQuery += " NOT EXISTS ( "
cQuery += " SELECT FIN_NUM "
cQuery += " FROM "+RetSqlTab("FIN")+" "
cQuery += " WHERE "
cQuery += " E1_FILIAL  = FIN_FILIAL AND "
cQuery += " E1_PREFIXO = FIN_PREFIX AND "
cQuery += " E1_NUM	   = FIN_NUM 	AND "
cQuery += " E1_PARCELA = FIN_PARCEL AND "
cQuery += " E1_TIPO    = FIN_TIPO 	AND "
cQuery += " E1_CLIENTE = FIN_CLIENT AND "
cQuery += " E1_LOJA	   = FIN_LOJA   AND "
cQuery += " FIN_STATUS IN ('A','R') AND "
cQuery += RetSQLCond('FIN') +")"
cQuery += " ORDER BY " + SQLOrder( SE1->( IndexKey(1) ) )
cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab )

For nX := 1 To Len( aHeader )
	cCpos := ALLTRIM(aHeader[nX][2])

	nPos	:= aScan( aStruSE1 , {|x| ALLTRIM(x[1]) == cCpos } )
	If nPos > 0 .And. aStruSE1[nPos][2] <> "C"
		TcSetField( cTab, aStruSE1[nPos][1], aStruSE1[nPos][2], aStruSE1[nPos][3], aStruSE1[nPos][4] )
	EndIf

Next nX

While (cTab)->(!Eof())
	aAdd(aCols,Array(Len(aHeader)+1))
	nCols ++
	For nX := 1 To Len(aHeader)
		If ( aHeader[nX][10] != "V") .And. 'E1' $ aHeader[nX][2]
			aCols[nCols][nX] := (cTab)->(&(aHeader[nX][2]))
		ElseIf  aHeader[nX][2] == 'CHECKBOL'
			aCols[nCols][nX] := COR_NAOMARCA
		Else
			aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
		Endif
	Next nX
	aCols[nCols][Len(aHeader)+1] := .F.
	(cTab)->(dbSkip())
End

RestArea(aArea)
Return aCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940ConAVPบAutor  ณAlvaro Camillo Neto บ Data ณ 22/12/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a constitui็ใo do AVP de novos titulos              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940ConAVP(oGet,aRetPer,lEfetiva,lProcessar)
Local lRet    	:= .T.
Local nX	  	:= 0
Local aProcs 	:= {}
Local aArea	  	:= GetArea()
Local cTabMult	:= ""// Tabela para o processamento multi thread
Local nNumProc	:= GetMv("MV_AVPTHR", .F., 1 )
Local cProcesso	:= aRetPer[PROCESSO]
Local dDataProc	:= aRetPer[DATA_PROC]
Local nTotalReg	:= 0
Local cRaizNome	:= 'FIN940PROC'
Local aStruSQL	:= {}

Default lProcessar := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o arquivo de trabalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTabMult := F940ConArq(oGet)

If !Empty(cTabMult) .And. (cTabMult)->(!EOF())

	(cTabMult)->(dbGoTop())
	(cTabMult)->(dbEval({|| nTotalReg++ }))
	(cTabMult)->(dbGoTop())

	If nTotalReg > nNumProc .And. nNumProc > 1 // MultiThread
		aStruSQL := (cTabMult)->( DbStruct() )

		aProcs := FAVPPrepProc(nNumProc,cTabMult,nTotalReg,"SE1FLAG",cRaizNome)

		//Inicializa as Threads Transa็ใo controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("F940JOBCON",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"SE1FLAG",cTabMult, aStruSQL ,cProcesso,dDataProc,lEfetiva,cValToChar(nX))
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o controle das Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Sleep(3000)
		lRet := FAVPMonitor(aProcs)
	Else
		Begin Transaction
		lRet := F940CalAVP(cTabMult,cProcesso,dDataProc,lEfetiva,!lProcessar)
		End Transaction
	EndIf
Else
	lRet := .F.
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava o processoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	FGRV940CAB(cProcesso,IF(lEfetiva,"E","S"),aRetPer)
	ConfirmSX8()
EndIf

(cTabMult)->( dbCloseArea() )

MsErase(cTabMult)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940ConArqบAutor  ณAlvaro Camillo Neto บ Data ณ  22/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrepara o arquivo para a o calculo da constituicao do AVP   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940ConArq(oGet)
Local aStruSQL		:= {}
Local aArea 		:= GetArea()
Local cTab			:= FAVPNextAlias()
Local nX			:= 0
Local nPosPrefixo	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='E1_PREFIXO'})
Local nPosNum 		:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='E1_NUM'})
Local nPosParcela	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='E1_PARCELA'})
Local nPosTipo		:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='E1_TIPO'})
Local nPosTaxaVP	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='FIN_TAXAVP'})
Local nPosPeriod	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='FIN_PERIOD'})
Local nPosFormul	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='FIN_FORMUL'})
Local nPosCodInd	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='FIN_CODIND'})
Local nPosMarca		:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))=='CHECKBOL'})
Local aCols			:= oGet:aCols

SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

//Estrutura do arquivo de trabalho
AADD(aStruSQL,{'FIN_TAXAVP'	,"N",TAMSX3('FIN_TAXAVP')[1]		,TAMSX3('FIN_TAXAVP')[2]})
AADD(aStruSQL,{'FIN_PERIOD' ,"C",TAMSX3('FIN_PERIOD')[1]		,TAMSX3('FIN_PERIOD')[2]})
AADD(aStruSQL,{'FIN_FORMUL'	,"C",TAMSX3('FIN_FORMUL')[1]		,TAMSX3('FIN_FORMUL')[2]})
AADD(aStruSQL,{'FIN_CODIND'	,"C",TAMSX3('FIN_CODIND')[1]		,TAMSX3('FIN_CODIND')[2]})
AADD(aStruSQL,{"SE1RECNO" 	,"N",08,00})
AADD(aStruSQL,{"SE1FLAG" 	,"C",02,00})

MsErase(cTab)
MsCreate(cTab, aStruSQL, 'TOPCONN' )
dbUseArea( .T., 'TOPCONN', cTab, cTab, .T., .F. )
dbSelectArea( cTab )

For nX := 1 to Len(aCols)
	If aCols [nX][nPosMarca] == COR_MARCA .And. SE1->( MsSeek(xFilial("SE1") + aCols[nX][nPosPrefixo] + aCols[nX][nPosNum] + aCols[nX][nPosParcela] + aCols[nX][nPosTipo]  ) )
		RecLock(cTab,.T.)

		If nPosTaxaVP > 0
			(cTab)->FIN_TAXAVP 	:= aCols[nX][nPosTaxaVP]
		EndIf

		If nPosPeriod > 0
			(cTab)->FIN_PERIOD 	:= aCols[nX][nPosPeriod]
		EndIf

		If nPosFormul > 0
			(cTab)->FIN_FORMUL 	:= aCols[nX][nPosFormul]
		EndIf

		If nPosCodInd > 0
			(cTab)->FIN_CODIND 	:= aCols[nX][nPosCodInd]
		EndIf

		(cTab)->SE1RECNO 		:= SE1->(Recno())
		(cTab)->SE1FLAG 		:= ''

		MsUnLock()
	EndIf
Next nX

RestArea(aArea)
Return cTab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940JOBCONบAutor  ณAlvaro Camillo Neto บ Data ณ 28/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJob respnsavel por subir o ambiente e processar a contituicao บฑฑ
ฑฑบ          ณde seus registros                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940JOBCON(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cProcesso,dDataProc,lEfetiva,cId)
Local nHandle	 := 0
Local cTabJob	 := ""
Local lRet		 := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o arquivo de Lock parao controle externo das threadsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := FAVPLock(cFileLck)

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX, cFilX,,,'FIN')

Conout(STR0044+ cProcesso +STR0045+ cId + STR0046 + TIME() + STR0047)//"Processando Calculo do AVP do Contas a Receber "##" Thread: "##" as "## " horas"

cTabJob	 := FAVPSelJob(cTabMaster,aStructTab,cCpoFlag,cMarca)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Begin Transaction
	lRet := F940CalAVP(cTabJob,cProcesso,dDataProc,lEfetiva,.T.)
End Transaction

FAVPUnLock(nHandle,lRet)
Conout(STR0048 + cProcesso +STR0045+cId + STR0046 + TIME() + STR0047)//"Fim do calculo do AVP do Contas a Receber "##" Thread: "##" as "## " horas"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940CalAVPบAutor  ณAlvaro Camillo Neto บ Data ณ  23/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo e gravacao dos movimentos de AVP                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940CalAVP(cTab,cProcesso,dDataProc,lEfetiva,lConstituicao)
Local lRet			:= .F.
Local aArea	  		:= GetArea()
Local nRecnoTit		:= 0
Local nValVP		:= 0
Local nValAVP		:= 0
Local cCritica		:= ""
Local cTipoProc		:= ""
Local nTaxa			:= 0
Local cFormula		:= ""
Local cCodInd		:= ""
Local nValInd		:= 0
Local cPeriodo		:= ""
Local cAliasTit		:= "SE1"
Local cIdMov

Default lConstituicao := .F.

lRet := !lConstituicao

While (cTab)->(!Eof())

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฐฟ
	//ณDefine o tipo de calculoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฐู
	cCritica := " "
	If lConstituicao
		cTipoProc := CONSTITUICAO
	Else
		cTipoProc := AJUSTE_AVP
	EndIf

	If !Empty((cTab)->FIN_CODIND)
		cCodInd	:=	(cTab)->FIN_CODIND
		cPeriodo:= GetAdvFVal("FIT","FIT_PERIOD", xFilial("FIT") + (cTab)->FIN_CODIND)
		nValInd	:= FinRetInd(cCodInd,dDataProc)
		nTaxa 	:= nValInd
	ElseIf !Empty((cTab)->FIN_FORMUL)
		cFormula := (cTab)->FIN_FORMUL
	Else
		nTaxa 	 := (cTab)->FIN_TAXAVP
		cPeriodo := (cTab)->FIN_PERIOD
	EndIf

	nRecnoTit := (cTab)->SE1RECNO

	FCalcAVP(cProcesso,@cTipoProc,cAliasTit,nRecnoTit,nTaxa,cFormula,cCodInd,nValInd,cPeriodo,dDataProc,@nValVP,@nValAVP,@cCritica)

	If !(nValAVP == 0)
	   cIdMov := GetSxENum("FIP","FIP_IDMOV","FIP_IDMOV"+cEmpAnt,2)
		ConfirmSX8()
		//Grava Movimento
	   nRecnoMov := FGRVAVPMOV(cProcesso,cTipoProc,"FIP",nTaxa,cFormula,cCodInd,nValInd,cPeriodo,dDataProc,nValAVP,cIdMov,cCritica)

	   lRet := .T.	// Quando gerar qualquer quantidade. 
	   
	   If lEfetiva
	   	FAvpEfet("FIP",nRecnoMov)
	   EndIf
   EndIf

	(cTab)->(dbSkip())
End

If !lConstituicao .and. !lRet
	Help (" ",1,"FIN940NOTI",,STR0032,1,0)//"Nใo foram encontrados registros para este processo. Por favor, verifique a parametriza็ใo do processo"
EndIf

RestArea(aArea)
Return lRet



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEstorno de Processo AVP						ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN940Est บAutor  ณMauricio Pequim Jr  บ Data ณ  07/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o estorno de processo de AVP                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN940Est(cAlias, nReg, nOpc)
Local aArea 		:= GetArea()
Local lRet 			:= .T.
Local nOpcA			:= 0
Local cProcesso		:= FIO->FIO_PROC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsNewGetDados()      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aHeader  		:= {}
Local aCols			:= {}
Local nOpcX			:= 0							// Op็ใo da MsNewGetDados
Local cLinhaOk     	:= "AllwaysTrue"  				// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"				// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""			               	// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              			// Campos estaticos na GetDados.
Local nMax         	:= 999              			// Numero maximo de linhas permitidas.
Local aAlter    	:= {}                           // Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"				// Funcao executada na validacao do campo
Local cSuperDel     := "AllwaysTrue"    			// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        := "AllwaysTrue" 				// Funcao executada para validar a exclusao de uma linha do aCols

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis para a MsAdvSize e MsObjSizeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lEnchBar   		:= .F. // Se a janela de diแlogo possuirแ enchoicebar (.T.)
Local lPadrao    		:= .F. // Se a janela deve respeitar as medidas padr๕es do Protheus (.T.) ou usar o mแximo disponํvel (.F.)
Local nMinY	    		:= 400 // Altura mํnima da janela
Local aSize	   			:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 			:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects	  		:= {}
Local aPosObj	   		:= {}

Local oDlg				:= Nil
Local oPanelMed			:= Nil

Local oGetMov			:= Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefini็ใo das posi็๕es dos objetos na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para os dados Enchoice
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.})
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal

If F940EstOK()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega o a Header e o acolsณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aHeader := F940HeadEfe()
	aCols	:= F940aColEst(aHeader,cProcesso)

	If Empty(aCols)
		Help(" ",1,"FIN940NOT1",,STR0049,1,0)//"Nใo foram encontrados registros para este processo. Por favor, verifique o status do processo"
		lRet := .F.
	Else

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDefini็ใod dos Objetosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEstrutura de Panelsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oPanelMed 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,100,100,.T.,.T. )
		oPanelMed:Align 	:= CONTROL_ALIGN_ALLCLIENT


		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMsNewGetDadosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oGetMov	:= 	MsNewGetDados():New(0,0,100,100,nOpcX,;
		cLinhaOk ,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oPanelMed,aHeader,aCols)
		oGetMov:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

		oDlg:bInit 		:= EnchoiceBar(oDlg,{|| nOpcA:=1,oDlg:End() },{||RollBackSX8(),nOpcA:=0,oDlg:End()})
		oDlg:lCentered	:= .T.
		oDlg:Activate()

	Endif

EndIf

If nOpcA == 1
	MsgRun( STR0050,, {|| F940EstAVP(cProcesso) } )//"Estornando o processo de AVP selecionado..."
EndIf

RestArea(aArea)
Return .F.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA940ESTOKบAutor  ณMicrosiga           บ Data ณ  07/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida possibilidade do processo AVP ser estornado         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                              	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940EstOK()

Local cAliasQry := ""
Local lRet 		:= .T.
Local cQuery 	:= ""

If FIO->FIO_STATUS != "E"
	Help(" ",1,"F940NOEFET",,STR0051,1,0)
	lRet := .F.
EndIf

If lRet
  	cAliasQry := GetNextAlias()
	cQuery := " SELECT "
	cQuery += " 	MAX(FIO_PROC) FIOMAXPROC  "
	cQuery += " FROM "  + RetSQLTab("FIO")
	cQuery += " WHERE FIO_STATUS <> 'X' AND "
	cQuery += RetSqlCond("FIO")

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry )

   If FIO->FIO_PROC < (cAliasQry)->FIOMAXPROC
		Help(" ",1,"F940NOLAST",,STR0052,1,0)//"Existem processos de AVP posteriorea ao processo que estแ se tentando cancelar. Por seguran็a, os processos devem ser cancelados do mais atual para o mais antigo."
		lRet := .F.
	Endif

	dbSelectArea(cAliasQry)
	dbCloseArea()
	dbSelectArea("FIO")

Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940EstAVPบAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a efetivavacao dos movimentos simulados de          บฑฑ
ฑฑบ          ณconstitui็ใo.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940EstAVP(cProcesso)
Local aArea 		:= GetArea()
Local lRet    		:= .T.
Local nX	  		:= 0
Local aProcs 		:= {}
Local cTabMult		:= ""// Tabela para o processamento multi thread
Local nNumProc		:= GetMv("MV_AVPTHR", .F., 1 )
Local nTotalReg		:= 0
Local cRaizNome		:= 'FIN940PROC'
Local aStruSQL		:= {}
Local cCpoChave		:= "FIP_CLIENT+FIP_LOJA+FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_IDMOV"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o arquivo de trabalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTabMult := F940EstArq(cProcesso)

If !Empty(cTabMult) .And. (cTabMult)->(!EOF())

	(cTabMult)->(dbGoTop())
	(cTabMult)->(dbEval({|| nTotalReg++ }))
	(cTabMult)->(dbGoTop())

	If nTotalReg > nNumProc .And. nNumProc > 1 // MultiThread
		aStruSQL := (cTabMult)->( DbStruct() )

		aProcs := FAVPPrepProc(nNumProc,cTabMult,nTotalReg,"FIPFLAG",cRaizNome,cCpoChave)

		//Inicializa as Threads Transa็ใo controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("F940JOBEST",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"FIPFLAG",cTabMult, aStruSQL ,cValToChar(nX))
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o controle das Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Sleep(3000)
		lRet := FAVPMonitor(aProcs)
	Else
		Begin Transaction
			lRet := F940EstCon(cTabMult)
		End Transaction
	EndIf
Else
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava o processoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	FGRV940CAB(cProcesso,"X")
EndIf

(cTabMult)->( dbCloseArea() )

MsErase(cTabMult)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940EstArqบAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrepara o arquivo para a efetivacao da constituicao do AVP  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940EstArq(cProcesso)
Local aStruSQL		:= {}
Local aArea 		:= GetArea()
Local cTab			:= FAVPNextAlias()
Local cQuery		:= ""

//Estrutura do arquivo de trabalho
AADD(aStruSQL,{'FIP_CLIENT'	,"C",TAMSX3('FIP_CLIENT')[1]		,TAMSX3('FIP_CLIENT')[2]})
AADD(aStruSQL,{'FIP_LOJA'	,"C",TAMSX3('FIP_LOJA')[1]	  		,TAMSX3('FIP_LOJA')[2]})
AADD(aStruSQL,{'FIP_PREFIX'	,"C",TAMSX3('FIP_PREFIX')[1]		,TAMSX3('FIP_PREFIX')[2]})
AADD(aStruSQL,{'FIP_NUM'	,"C",TAMSX3('FIP_NUM')[1]			,TAMSX3('FIP_NUM')[2]})
AADD(aStruSQL,{'FIP_PARCEL'	,"C",TAMSX3('FIP_PARCEL')[1]		,TAMSX3('FIP_PARCEL')[2]})
AADD(aStruSQL,{'FIP_TIPO'	,"C",TAMSX3('FIP_TIPO')[1]			,TAMSX3('FIP_TIPO')[2]})
AADD(aStruSQL,{'FIP_IDMOV'	,"C",TAMSX3('FIP_IDMOV')[1]			,TAMSX3('FIP_IDMOV')[2]})
AADD(aStruSQL,{"FIPRECNO" 	,"N",08,00})
AADD(aStruSQL,{"FIPFLAG" 	,"C",02,00})

MsErase(cTab)
MsCreate(cTab, aStruSQL, 'TOPCONN' )
dbUseArea( .T., 'TOPCONN', cTab, cTab, .T., .F. )

cQuery += " SELECT "
cQuery += "FIP_CLIENT,FIP_LOJA,FIP_PREFIX,FIP_NUM,FIP_PARCEL,FIP_TIPO,FIP_IDMOV, "
cQuery += " 	FIP.R_E_C_N_O_ FIPRECNO ,  "
cQuery += " 	'  ' FIPFLAG  "
cQuery += " FROM "  +RetSQLTab("FIP")
cQuery += " WHERE "
cQuery += " 	FIP_PROC   = '" + cProcesso + "' AND "
cQuery += " 	FIP_STATUS = 'E' AND  "
//cQuery += " 	FIP_VLRAVP > 0 AND  "
cQuery += RetSQLCond("FIP")
cQuery += " ORDER BY FIP_CLIENT,FIP_LOJA,FIP_PREFIX,FIP_NUM,FIP_PARCEL,FIP_TIPO,FIP_IDMOV DESC"

SqlToTrb(cQuery, aStruSQL, cTab)

RestArea(aArea)
Return cTab


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940EstConบAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a efetivacao dos movimentos de constituicao         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940EstCon(cTabMult)
Local aArea := GetArea()
Local lRet  := .T.

(cTabMult)->(dbGoTop())
While (cTabMult)->(!EOF())

	FAvpEst("FIP",(cTabMult)->FIPRECNO)
	(cTabMult)->(dbSkip())

EndDo

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940JOBEstบAutor  ณAlvaro Camillo Neto บ Data ณ 28/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJob respnsavel por subir o ambiente e processar a efetivacao  บฑฑ
ฑฑบ          ณda constituicao dos movimentos                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940JOBEst(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cId)
Local nHandle	 := 0
Local cTabJob	 := ""
Local lRet		 := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o arquivo de Lock parao controle externo das threadsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := FAVPLock(cFileLck)

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX, cFilX,,,'FIN')

Conout( STR0053 + cId+ STR0046 + TIME() + STR0047)//"Processando Estorno do processo de AVP selecionado   Thread: "##" as "## " horas

cTabJob	 := FAVPSelJob(cTabMaster,aStructTab,cCpoFlag,cMarca)

//ณRealiza o processamentoณ
Begin Transaction
	lRet := F940EstCon(cTabJob)
End Transaction

FAVPUnLock(nHandle,lRet)
Conout( STR0054 + cId + STR0046 + TIME() + STR0047)//"Fim do Estorno do processo de AVP selecionado  Thread: "##" as "## " horas

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940aColESTบAutor ณALvaro Camillo Neto บ Data ณ  29/12/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o aCols com os movimentos de constituicao que serใo  บฑฑ
ฑฑบ          ณ efetivados                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                        	                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940aColEst(aHeader,cProcesso)
Local nX		:= 0
Local nCols	    := 0
Local aArea		:= GetArea()
Local aCols		:= {}

FIP->(dbSetOrder(1)) //FIP_FILIAL+FIP_PROC+FIP_IDMOV
If FIP->(MsSeek(xFilial("FIP") + cProcesso ))
	While FIP->(!Eof()) .And. FIP->(FIP_FILIAL+FIP_PROC) == xFilial("FIP") + cProcesso
		If FIP->FIP_STATUS == "E"
			aAdd(aCols,Array(Len(aHeader)+1))
			nCols ++
			For nX := 1 To Len(aHeader)
				If ( aHeader[nX][10] != "V")
					aCols[nCols][nX] := FIP->(FieldGet(FieldPos(aHeader[nX][2])))
				Else
					aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
				Endif
			Next nX
			aCols[nCols][Len(aHeader)+1] := .F.
		EndIf
		FIP->(dbSkip())
	End
EndIf
RestArea(aArea)

Return aCols




//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEfetiva็ใo da Simula็ใo da constitui็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN940Efe บAutor  ณAlvaro Camillo Neto บ Data ณ  29/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a efetiva็ใo da simulacao da constituicao do        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN940Efe(cAlias, nReg, nOpc)
Local aArea 		:= GetArea()
Local lRet 			:= .T.
Local nOpcA			:= 0
Local cProcesso	:= FIO->FIO_PROC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsNewGetDados()      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aHeader  		:= {}
Local aCols			:= {}
Local nOpcX			:= 0						// Op็ใo da MsNewGetDados
Local cLinhaOk     	:= "AllwaysTrue"  			// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"			// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""			            // Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              		// Campos estaticos na GetDados.
Local nMax         	:= 999              		// Numero maximo de linhas permitidas.
Local aAlter    	:= {}                       // Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"			// Funcao executada na validacao do campo
Local cSuperDel    	:= "AllwaysTrue"        	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk       	:= "AllwaysTrue"    		// Funcao executada para validar a exclusao de uma linha do aCols

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis para a MsAdvSize e MsObjSizeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lEnchBar   	:= .F. // Se a janela de diแlogo possuirแ enchoicebar (.T.)
Local lPadrao    	:= .F. // Se a janela deve respeitar as medidas padr๕es do Protheus (.T.) ou usar o mแximo disponํvel (.F.)
Local nMinY	    	:= 400 // Altura mํnima da janela
Local aSize	   		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects	  	:= {}
Local aPosObj	   	:= {}

Local oDlg			:= Nil
Local oPanelMed		:= Nil

Local oGetMov		:= Nil

If FIO->FIO_STATUS != "S"
	Help(" ",1,"F940NOEFET",,STR0055,1,0)//"Somente poderใo ser efetivados os processos de simulacao do AVP. Por favor, verifique o status do processo"
	lRet := .F.
Endif


If lRet

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefini็ใo das posi็๕es dos objetos na telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para os dados Enchoice
	aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
	aAdd(aObjects,{100,015,.T.,.F.})
	aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega o a Header e o acolsณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aHeader  := F940HeadEfe()
	aCols	 := F940aColEfe(aHeader,cProcesso)

	If Empty(aCols)
		Help(" ",1,"FIN940NOT2",,STR0056,1,0)
	lRet := .F.
	EndIf

	If lRet
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefini็ใod dos Objetosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEstrutura de Panelsณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPanelMed 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,100,100,.T.,.T. )
	oPanelMed:Align 	:= CONTROL_ALIGN_ALLCLIENT


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMsNewGetDadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oGetMov	:= 	MsNewGetDados():New(0,0,100,100,nOpcX,;
	cLinhaOk ,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oPanelMed,aHeader,aCols)
	oGetMov:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

	oDlg:bInit 		:= EnchoiceBar(oDlg,{|| nOpcA:=1,oDlg:End() },{||RollBackSX8(),nOpcA:=0,oDlg:End()})
	oDlg:lCentered	:= .T.
	oDlg:Activate()

	EndIf

	If nOpcA == 1
		MsgRun( STR0057,, {|| F940EfeAVP(cProcesso) } ) //"Efetivando as constitui็๕es de AVP do periodo..."
	EndIf

Endif

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940HeadEfeบAutor ณAlvaro Camillo Neto บ Data ณ  29/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o aHeader da getdados de efetivacao da simulacao     บฑฑ
ฑฑบ          ณ da constituicao do AVP                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940HeadEfe()

Local aHeader 	:= {}
Local aCpos	  	:= {}
Local nX		:= 0
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

aAdd(aCpos,'FIP_PROC'  )
aAdd(aCpos,'FIP_PREFIX')
aAdd(aCpos,'FIP_NUM'   )
aAdd(aCpos,'FIP_PARCEL')
aAdd(aCpos,'FIP_TIPO'  )
aAdd(aCpos,'FIP_CLIENT')
aAdd(aCpos,'FIP_LOJA'  )
aAdd(aCpos,'FIP_TIPAVP')
aAdd(aCpos,'FIP_DTAVP' )
aAdd(aCpos,'FIP_VLRAVP')
aAdd(aCpos,'FIP_TAXAVP')
aAdd(aCpos,'FIP_FORMUL')
aAdd(aCpos,'FIP_CODIND')
aAdd(aCpos,'FIP_VLRIND')
aAdd(aCpos,'FIP_PERIOD')

SX3->(dbSetOrder(2)) //X3_CAMPO
For nX := 1 to Len(aCpos)
	If SX3->( MsSeek(aCpos[nX]) )
			aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
			SX3->X3_CAMPO	, ;			   	    	  // 02 - Campo
			SX3->X3_Picture	, ;				 		  // 03 - Picture
			SX3->X3_TAMANHO	, ;				 		  // 04 - Tamanho
			SX3->X3_DECIMAL	, ;				 		  // 05 - Decimal
			SX3->X3_Valid  	, ;			 		      // 06 - Valid
			SX3->X3_USADO  	, ;			 		      // 07 - Usado
			SX3->X3_TIPO   	, ;			 		  	  // 08 - Tipo
			SX3->X3_F3		, ;	  		 		  	  // 09 - F3
			SX3->X3_CONTEXT , ;       	 		  	  // 10 - Contexto
			SX3->X3_CBOX	, ; 	  	 		  	  // 11 - ComboBox
			SX3->X3_RELACAO    } )   		 		  // 12 - Relacao
	EndIf
Next nX

RestArea( aAreaSX3 )
RestArea( aArea )

Return aHeader


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940aColEfeบAutor ณALvaro Camillo Neto บ Data ณ  29/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o aCols com os movimentos de constituicao que serใo  บฑฑ
ฑฑบ          ณ efetivados                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940aColEfe(aHeader,cProcesso)
Local nX		:= 0
Local nCols		:= 0
Local aArea		:= GetArea()
Local aCols		:= {}

FIP->(dbSetOrder(1)) //FIP_FILIAL+FIP_PROC+FIP_IDMOV
If FIP->(MsSeek(xFilial("FIP") + cProcesso ))
	While FIP->(!Eof()) .And. FIP->(FIP_FILIAL+FIP_PROC) == xFilial("FIP") + cProcesso
		If FIP->FIP_STATUS == "S" .And. !Empty(FIP->FIP_VLRAVP) .And. FIP->FIP_TIPAVP == "C"
			aAdd(aCols,Array(Len(aHeader)+1))
			nCols ++
			For nX := 1 To Len(aHeader)
				If ( aHeader[nX][10] != "V")
					aCols[nCols][nX] := FIP->(FieldGet(FieldPos(aHeader[nX][2])))
				Else
					aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
				Endif
			Next nX
			aCols[nCols][Len(aHeader)+1] := .F.
		EndIf
		FIP->(dbSkip())
	End
EndIf
RestArea(aArea)

Return aCols


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940EfeAVPบAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a efetivavacao dos movimentos simulados de          บฑฑ
ฑฑบ          ณconstitui็ใo.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940EfeAVP(cProcesso)
Local aArea 		:= GetArea()
Local lRet    		:= .T.
Local nX	  		:= 0
Local aProcs 		:= {}
Local cTabMult		:= ""// Tabela para o processamento multi thread
Local nNumProc		:= GetMv("MV_AVPTHR", .F., 1 )
Local nTotalReg		:= 0
Local cRaizNome		:= 'FIN940PROC'
Local aStruSQL		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o arquivo de trabalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTabMult := F940EfeArq(cProcesso)

If !Empty(cTabMult) .And. (cTabMult)->(!EOF())

	(cTabMult)->(dbGoTop())
	(cTabMult)->(dbEval({|| nTotalReg++ }))
	(cTabMult)->(dbGoTop())

	If nTotalReg > nNumProc .And. nNumProc > 1 // MultiThread
		aStruSQL := (cTabMult)->( DbStruct() )

		aProcs := FAVPPrepProc(nNumProc,cTabMult,nTotalReg,"FIPFLAG",cRaizNome)

		//Inicializa as Threads Transa็ใo controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("F940JOBEFE",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"FIPFLAG",cTabMult, aStruSQL ,cValToChar(nX))
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o controle das Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Sleep(3000)
		lRet := FAVPMonitor(aProcs)
	Else
		Begin Transaction
			lRet := F940EfeCon(cTabMult)
		End Transaction
	EndIf
Else
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava o processoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	FGRV940CAB(cProcesso,"E")
EndIf

(cTabMult)->( dbCloseArea() )

MsErase(cTabMult)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940EfeArqบAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrepara o arquivo para a efetivacao da constituicao do AVP  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940EfeArq(cProcesso)
Local aStruSQL		:= {}
Local aArea 		:= GetArea()
Local cTab			:= FAVPNextAlias()
Local cQuery		:= ""

//Estrutura do arquivo de trabalho
AADD(aStruSQL,{"FIPRECNO" 		,"N",08,00})
AADD(aStruSQL,{"FIPFLAG" 		,"C",02,00})

MsErase(cTab)
MsCreate(cTab, aStruSQL, 'TOPCONN' )
dbUseArea( .T., 'TOPCONN', cTab, cTab, .T., .F. )

cQuery += " SELECT "
cQuery += " 	FIP.R_E_C_N_O_ FIPRECNO ,  "
cQuery += " 	'  ' FIPFLAG  "
cQuery += " FROM "  +RetSQLTab("FIP")
cQuery += " WHERE "
cQuery += " 	FIP_PROC   = '" + cProcesso + "' AND "
cQuery += " 	FIP_STATUS = 'S' AND  "
cQuery += " 	FIP_VLRAVP <> 0 AND  "
cQuery += " 	FIP_TIPAVP = 'C' AND "
cQuery += RetSQLCond("FIP")

SqlToTrb(cQuery, aStruSQL, cTab)

RestArea(aArea)
Return cTab


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940EfeConบAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a efetivacao dos movimentos de constituicao         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940EfeCon(cTabMult)
Local aArea := GetArea()
Local lRet  := .T.

(cTabMult)->(dbGoTop())
While (cTabMult)->(!EOF())
	FAvpEfet("FIP",(cTabMult)->FIPRECNO)
	(cTabMult)->(dbSkip())
EndDo

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940JOBEFEบAutor  ณAlvaro Camillo Neto บ Data ณ 28/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJob respnsavel por subir o ambiente e processar a efetivacao  บฑฑ
ฑฑบ          ณda constituicao dos movimentos                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940JOBEFE(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cId)
Local nHandle	 := 0
Local cTabJob	 := ""
Local lRet		 := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o arquivo de Lock parao controle externo das threadsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := FAVPLock(cFileLck)

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX, cFilX,,,'FIN')

Conout(STR0058 +cId + STR0046 + TIME() + STR0047)//"Processando Calculo do AVP do Contas a Receber  Thread: "##" as "## " horas

cTabJob	 := FAVPSelJob(cTabMaster,aStructTab,cCpoFlag,cMarca)

//ณRealiza o processamentoณ
Begin Transaction
	lRet := F940EfeCon(cTabJob)
End Transaction

FAVPUnLock(nHandle,lRet)

Conout(STR0059 + cId + STR0046 + TIME() + STR0047)//"Fim do calculo do AVP do Contas a Receber  Thread: "##" as "## " horas

Return



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcessamento do Ajuste de AVP (Constituicao, Baixa e Ajuste)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN940Proc บAutor  ณAlvaro Camillo Neto บ Data ณ  29/12/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento do calculo de AVP : Constitui็๕es, Baixa e   บฑฑ
ฑฑบ          ณ Ajustes                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function FIN940Proc(cAlias, nReg, nOpc)
Local cTitulo 		:= STR0060//"Calculo do Ajuste do valor presente : Contas a Receber"
Local cMsg	  		:= STR0061//"Esta rotina tem o objetivo de realizar a constiui็๕es do AVP de novos tํtulos, o ajuste dos titulos em processo de AVP e a realiza็ใo das baixas do perํodo"
Local lEfetiva 		:= .T.
Local lRet			:= .T.
Local aRetPer		:= {}

// Wizard de sele็ใo e constitui็ใo dos novos Tํtulos
lRet	:=	F940WizCon(cTitulo,cMsg,lEfetiva,@aRetPer,.T.)


if lRet
	// Baixa dos tํtulos do periodo
	MsgRun( STR0062,, {|| lRet := F940BxAVP(aRetPer)  } ) //"Realizando o AVP das baixas do periodo..."
	
	// Ajuste dos titulos em AVP do periodo
	MsgRun( STR0063,, {|| lRet := F940AjuAVP(aRetPer) } )//"Realizando o AVP do periodo..."
EndIf

If Inclui
	MBrChgLoop(.F.)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ บAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o ajuste do AVP dos tํtulo em AVP                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940BxAVP(aRetPer)
Local aArea 	:= GetArea()
Local lRet		:= .T.
Local nX	  	:= 0
Local aProcs 	:= {}
Local cTabMult	:= ""// Tabela para o processamento multi thread
Local nNumProc	:= GetMv("MV_AVPTHR", .F., 1 )
Local cProcesso	:= aRetPer[PROCESSO]
Local nTotalReg	:= 0
Local cRaizNome	:= 'FIN940PROC'
Local aStruSQL	:= {}
Local cCpoChave	:= "E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o arquivo de trabalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTabMult := F940BxArq(aRetPer)

If !Empty(cTabMult) .And. (cTabMult)->(!EOF())

	(cTabMult)->(dbGoTop())
	(cTabMult)->(dbEval({|| nTotalReg++ }))
	(cTabMult)->(dbGoTop())

	If nTotalReg > nNumProc .And. nNumProc > 1 // MultiThread
		aStruSQL := (cTabMult)->( DbStruct() )

		aProcs := FAVPPrepProc(nNumProc,cTabMult,nTotalReg,"SE5FLAG",cRaizNome,cCpoChave)

		//Inicializa as Threads Transa็ใo controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("F940JOBBX",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"SE5FLAG",cTabMult,aStruSQL,cProcesso,cValToChar(nX))
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o controle das Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Sleep(3000)
		lRet := FAVPMonitor(aProcs)
	Else
		Begin Transaction
			lRet := F940BxProc(cTabMult,cProcesso)
		End Transaction
	EndIf
Else
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava o processoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	FGRV940CAB(cProcesso,"E",aRetPer)
	ConfirmSX8()
EndIf

(cTabMult)->( dbCloseArea() )

MsErase(cTabMult)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940BxArqบAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o arquivo de trabalho para o processamento do ajuste  บฑฑ
ฑฑบ          ณdos titulos baixados                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940BxArq(aRetPer)
Local aStruSQL		:= {}
Local aArea 		:= GetArea()
Local cTab			:= FAVPNextAlias()
Local cQuery		:= ""

//Estrutura do arquivo de trabalho
AADD(aStruSQL,{'E5_CLIFOR'		,"C",TAMSX3('E5_CLIFOR')[1]			,TAMSX3('E5_CLIFOR')[2]})
AADD(aStruSQL,{'E5_LOJA'		,"C",TAMSX3('E5_LOJA')[1]	  		,TAMSX3('E5_LOJA')[2]})
AADD(aStruSQL,{'E5_PREFIXO'		,"C",TAMSX3('E5_PREFIXO')[1]		,TAMSX3('E5_PREFIXO')[2]})
AADD(aStruSQL,{'E5_NUMERO'		,"C",TAMSX3('E5_NUMERO')[1]			,TAMSX3('E5_NUMERO')[2]})
AADD(aStruSQL,{'E5_PARCELA'		,"C",TAMSX3('E5_PARCELA')[1]		,TAMSX3('E5_PARCELA')[2]})
AADD(aStruSQL,{'E5_TIPO'		,"C",TAMSX3('E5_TIPO')[1]			,TAMSX3('E5_TIPO')[2]})
AADD(aStruSQL,{'E5_SEQ'			,"C",TAMSX3('E5_SEQ')[1]			,TAMSX3('E5_SEQ')[2]})
AADD(aStruSQL,{'FIN_TAXAVP'		,"N",TAMSX3('FIN_TAXAVP')[1]		,TAMSX3('FIN_TAXAVP')[2]})
AADD(aStruSQL,{'FIN_PERIOD' 	,"C",TAMSX3('FIN_PERIOD')[1]		,TAMSX3('FIN_PERIOD')[2]})
AADD(aStruSQL,{'FIN_FORMUL'		,"C",TAMSX3('FIN_FORMUL')[1]		,TAMSX3('FIN_FORMUL')[2]})
AADD(aStruSQL,{'FIN_CODIND'		,"C",TAMSX3('FIN_CODIND')[1]		,TAMSX3('FIN_CODIND')[2]})
AADD(aStruSQL,{"SE5RECNO" 		,"N",08,00})
AADD(aStruSQL,{"SE5FLAG" 		,"C",02,00})

MsErase(cTab)
MsCreate(cTab, aStruSQL, 'TOPCONN' )
dbUseArea( .T., 'TOPCONN', cTab, cTab, .T., .F. )

cQuery := "SELECT E5_CLIFOR "
cQuery +=         ",E5_LOJA "
cQuery +=         ",E5_PREFIXO "
cQuery +=         ",E5_NUMERO "
cQuery +=         ",E5_PARCELA "
cQuery +=         ",E5_TIPO "
cQuery +=         ",E5_SEQ "
cQuery +=         ",FIN_TAXAVP "
cQuery +=         ",FIN_PERIOD "
cQuery +=         ",FIN_FORMUL "
cQuery +=         ",FIN_CODIND "
cQuery +=         ",SE5.R_E_C_N_O_ SE5RECNO "
cQuery +=         ",'  ' SE5FLAG "
cQuery += " FROM " + RetSqlTab("SE5")
cQuery += " INNER JOIN "+RetSqlTab("FIN")+" ON "
cQuery += " E5_FILIAL  = FIN_FILIAL 		AND "
cQuery += " E5_PREFIXO = FIN_PREFIX 		AND "
cQuery += " E5_NUMERO  = FIN_NUM 			AND "
cQuery += " E5_PARCELA = FIN_PARCEL 		AND "
cQuery += " E5_TIPO    = FIN_TIPO 			AND "
cQuery += " E5_CLIFOR  = FIN_CLIENT 		AND "
cQuery += " E5_LOJA	   = FIN_LOJA 			AND "
cQuery += " E5_DTDISPO > FIN_DTAVP	 		AND "
cQuery += " FIN_STATUS = 'A' AND "
cQuery += RetSQLCond('FIN')
cQuery += " WHERE E5_RECPAG = '" + "R" + "' AND "
cQuery += "      E5_DATA    <= '" + DTOS(aRetPer[DATA_PROC]) + "' AND "
cQuery += "		  E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','VA') AND "
cQuery += " 	  E5_SITUACA NOT IN ('C','E','X') AND "
cQuery += "      ((E5_TIPODOC = 'CD' AND E5_VENCTO <= E5_DATA) OR "
cQuery += "      (E5_TIPODOC <> 'CD')) AND"
cQuery +=  RetSQLCond('SE5') + " "
cQuery += " AND NOT EXISTS ( "
cQuery += " SELECT A.E5_NUMERO "
cQuery += " FROM "+RetSqlName("SE5")+" A "
cQuery += " WHERE A.E5_FILIAL='"+xFilial("SE5")+"' AND "
cQuery +=		"A.E5_NATUREZ=SE5.E5_NATUREZ AND "
cQuery +=		"A.E5_PREFIXO=SE5.E5_PREFIXO AND "
cQuery +=		"A.E5_NUMERO=SE5.E5_NUMERO AND "
cQuery +=		"A.E5_PARCELA=SE5.E5_PARCELA AND "
cQuery +=		"A.E5_TIPO=SE5.E5_TIPO AND "
cQuery +=		"A.E5_CLIFOR=SE5.E5_CLIFOR AND "
cQuery +=		"A.E5_LOJA=SE5.E5_LOJA AND "
cQuery +=		"A.E5_SEQ=SE5.E5_SEQ AND "
cQuery +=		"A.E5_TIPODOC='ES' AND "
cQuery +=		"A.E5_RECPAG <> 'R' AND "
cQuery +=		"A.D_E_L_E_T_= ' ' ) "
cQuery += " ORDER BY E5_CLIFOR,E5_LOJA,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO "

SqlToTrb(cQuery, aStruSQL, cTab)

RestArea(aArea)
Return cTab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940BaiProcบAutor  ณAlvaro Camillo Neto บ Data ณ  05/01/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o processo de ajuste de baixa do AVP               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940BxProc(cTab,cProcesso)
Local lRet			:= .T.
Local aArea	  		:= GetArea()
Local nRecnoTit		:= 0
Local nRecnoBx		:= 0
Local nRecnoMov		:= 0
Local nValVP		:= 0
Local nValAVP		:= 0
Local cCritica		:= ""
Local nTaxa			:= 0
Local cFormula		:= ""
Local cCodInd		:= ""
Local nValInd		:= 0
Local cPeriodo		:= ""
Local cAliasTit		:= "SE1"
Local cAliasMov		:= "FIP"
Local nVlrBaixa		:= 0
Local nPropBx		:= 0
Local nValAVPRlz	:= 0
Local nRecnoAVP		:= 0
Local cSeqBx		:= (cTab)->E5_SEQ
Local nVA			:= 0
Local lLoadFk6      := ExistFunc("FxLoadFK6")
Local cSeqBxOld	:= " "
Local dDtProcOld  := CTOD("  /  /  ")
Local cChvSe1     := ""
Local cChvSe1Ant  := ""
Local lPrim       := .T.

//Posiciono no titulo SE1
SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

While (cTab)->(!EOF())
	cSeqBx		:= (cTab)->E5_SEQ
	nRecnoBx := (cTab)->SE5RECNO
	SE5->(DbGoTo(nRecnoBx))
	//Obtenho a data da baixa
	dDataProc := SE5->E5_DTDISPO

	SE1->(MsSeek(XFilial("SE1")+SE5->(E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
	nRecnoTit := SE1->(Recno())
	cChvSe1 := ( XFilial("SE1")+SE5->(E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO))
	/* caso seja outro titulo reinicializo as seq anterior de bx e dtprc proc anterior branco*/
	If cChvSe1 != cChvSe1Ant .and. !lPrim
		cSeqBxOld := ' '
		dDtProcOld  := CTOD("  /  /  ")
	EndIf
	lPrim := .F.
	If !Empty((cTab)->FIN_CODIND)
		cCodInd	:=	(cTab)->FIN_CODIND
		cPeriodo:= GetAdvFVal("FIT","FIT_PERIOD", xFilial("FIT") + (cTab)->FIN_CODIND)
		nValInd	:= FinRetInd(cCodInd,dDataProc)
		nTaxa 	:= nValInd
	ElseIf !Empty((cTab)->FIN_FORMUL)
		cFormula	:= (cTab)->FIN_FORMUL
	Else
		nTaxa 		:= (cTab)->FIN_TAXAVP
		cPeriodo 	:= (cTab)->FIN_PERIOD
	EndIf

	//Calculo o AVP
	FCalcAVP(cProcesso,"A",cAliasTit,nRecnoTit,nTaxa,cFormula,cCodInd,nValInd,cPeriodo,dDataProc,@nValVP,@nValAVP,@cCritica)

	cIdMov := GetSxENum("FIP","FIP_IDMOV","FIP_IDMOV"+cEmpAnt,2)
	ConfirmSX8()
	//Grava Movimento 
	If (cSeqBx > cSeqBxOld) .and. (dDtProcOld < dDataProc)
		nRecnoMov := FGRVAVPMOV(cProcesso,"A",cAliasMov,nTaxa,cFormula,cCodInd,nValInd,cPeriodo,dDataProc,nValAVP,cIdMov,cCritica,cSeqBx)
	EndIf
	nRecnoAVP := FAvpEfet(cAliasMov,nRecnoMov)

	//---------------------------------------------------------------------------
	//Gravo a realiza็ใo do valor
	FIN->( DbGoto(nRecnoAVP) )
	cIdMov := GetSxENum("FIP","FIP_IDMOV","FIP_IDMOV"+cEmpAnt,2)
	ConfirmSX8()

	//---------------------------------------------------------------------------
	//Valores Acessorios
	//---------------------------------------------------------------------------	
	If lLoadFk6
		nVA	:= FxLoadFK6("FK1",SE5->E5_IDORIG,"VA")[1,2]	//Pego o valor Informado
	Endif

	//Calculo o valor baixado do principal do titulo
	nVlrBaixa := SE5->(E5_VALOR+E5_VLDESCO-E5_VLJUROS-E5_VLMULTA) - nVA

	//Calculo a proporcao entre o valor baixado do principal e a atual base de AVP
	nPropBx := ( nVlrBaixa /FIN->FIN_BASE )

	//Calculo o Valor da Realizacao (Base AVP Atual - Valor Ajustado ao Valor Presente) * proporcao da baixa
	nValAVPRlz := (FIN->(FIN_BASE - FIN_VLRAVP)) * nPropBx

	//Gravo movimento de Realizacao
	nRecnoMov := FGRVAVPMOV(cProcesso,"R",cAliasMov,nPropBx,"","",0,"",dDataProc,nValAVPRlz,cIdMov,"",cSeqBx)

	//Ajusto o AVP (FIN/FIQ)
	FAvpEfet(cAliasMov,nRecnoMov)

	//---------------------------------------------------------------------------
	//Gravo a baixa
	cIdMov := GetSxENum("FIP","FIP_IDMOV","FIP_IDMOV"+cEmpAnt,2)
	ConfirmSX8()

	//Gravo movimento de Baixa
	nRecnoMov := FGRVAVPMOV(cProcesso,"B",cAliasMov,nTaxa,cFormula,cCodInd,nValInd,cPeriodo,dDataProc,nVlrBaixa,cIdMov,"",cSeqBx)

	//Baixo o AVP e gero novo AVP com o saldo do titulo (FN/FIQ)
	FAvpEfet(cAliasMov,nRecnoMov)

	cChvSe1Ant := XFilial("SE1")+SE5->(E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)
	dDtProcOld := dDataProc
	cSeqBxOld  := cSeqBx  	
	(cTab)->(DbSkip())
Enddo

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940JOBBX บAutor  ณAlvaro Camillo Neto บ Data ณ 28/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJob respnsavel por subir o ambiente e processar o ajuste AVP บฑฑ
ฑฑบ          ณdas baixas do periodo                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940JOBBX(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cProcesso,cId)
Local nHandle	 := 0
Local cTabJob	 := ""
Local lRet		 := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o arquivo de Lock parao controle externo das threadsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := FAVPLock(cFileLck)

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX, cFilX,,,'FIN')

Conout(STR0044+ cProcesso +STR0045+ cId + STR0046 + TIME() + STR0047)//"Processando Calculo do AVP do Contas a Receber "##" Thread: "##" as "## " horas"

cTabJob	:= FAVPSelJob(cTabMaster,aStructTab,cCpoFlag,cMarca)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Begin Transaction
	lRet := F940BxProc(cTabJob,cProcesso)
End Transaction

FAVPUnLock(nHandle,lRet)
Conout(STR0048 + cProcesso +STR0045+cId + STR0046 + TIME() + STR0047)//"Fim do calculo do AVP do Contas a Receber "##" Thread: "##" as "## " horas"

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ บAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o ajuste do AVP dos tํtulo em AVP                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940AjuAVP(aRetPer)
Local aArea 	:= GetArea()
Local lRet		:= .T.
Local nX	 	:= 0
Local aProcs 	:= {}
Local cTabMult	:= ""// Tabela para o processamento multi thread
Local nNumProc	:= GetMv("MV_AVPTHR", .F., 1 )
Local cProcesso	:= aRetPer[PROCESSO]
Local dDataProc	:= aRetPer[DATA_PROC]
Local nTotalReg	:= 0
Local cRaizNome	:= 'FIN940PROC'
Local aStruSQL	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o arquivo de trabalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTabMult := F940AjuArq(aRetPer)
If !Empty(cTabMult) .And. (cTabMult)->(!EOF())

	(cTabMult)->(dbGoTop())
	(cTabMult)->(dbEval({|| nTotalReg++ }))
	(cTabMult)->(dbGoTop())

	If nTotalReg > nNumProc .And. nNumProc > 1 // MultiThread
		aStruSQL := (cTabMult)->( DbStruct() )

		aProcs := FAVPPrepProc(nNumProc,cTabMult,nTotalReg,"SE1FLAG",cRaizNome)

		//Inicializa as Threads Transa็ใo controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("F940JOBAJU",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"SE1FLAG",cTabMult, aStruSQL ,cProcesso,dDataProc,cValToChar(nX))
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o controle das Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Sleep(3000)
		lRet := FAVPMonitor(aProcs)
	Else
		Begin Transaction
			lRet := F940CalAVP(cTabMult,cProcesso,dDataProc,.T.,.F.)
		End Transaction
	EndIf
Else
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava o processoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	FGRV940CAB(cProcesso,"E",aRetPer)
	ConfirmSX8()
EndIf

(cTabMult)->( dbCloseArea() )

MsErase(cTabMult)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940AjuArqบAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o arquivo de trabalho para o processamento do ajuste  บฑฑ
ฑฑบ          ณdo AVP                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940AjuArq(aRetPer)
Local aStruSQL		:= {}
Local aArea 		:= GetArea()
Local cTab			:= FAVPNextAlias()
Local cQuery		:= ""


//Estrutura do arquivo de trabalho
AADD(aStruSQL,{'FIN_TAXAVP'	,"N",TAMSX3('FIN_TAXAVP')[1]		,TAMSX3('FIN_TAXAVP')[2]})
AADD(aStruSQL,{'FIN_PERIOD'	,"C",TAMSX3('FIN_PERIOD')[1]		,TAMSX3('FIN_PERIOD')[2]})
AADD(aStruSQL,{'FIN_FORMUL'	,"C",TAMSX3('FIN_FORMUL')[1]		,TAMSX3('FIN_FORMUL')[2]})
AADD(aStruSQL,{'FIN_CODIND'	,"C",TAMSX3('FIN_CODIND')[1]		,TAMSX3('FIN_CODIND')[2]})
AADD(aStruSQL,{"SE1RECNO" 	,"N",08,00})
AADD(aStruSQL,{"SE1FLAG" 	,"C",02,00})

MsErase(cTab)
MsCreate(cTab, aStruSQL, 'TOPCONN' )
dbUseArea( .T., 'TOPCONN', cTab, cTab, .T., .F. )

cQuery += " SELECT "
cQuery += " FIN_TAXAVP , "
cQuery += " FIN_PERIOD , "
cQuery += " FIN_FORMUL , "
cQuery += " FIN_CODIND , "
cQuery += " SE1.R_E_C_N_O_ SE1RECNO , "
cQuery += " '  ' SE1FLAG "
cQuery += " FROM " + RetSQLTab("SE1")
cQuery += " INNER JOIN "+RetSqlTab("FIN")+" ON "
cQuery += " E1_FILIAL  = FIN_FILIAL 		AND "
cQuery += " E1_PREFIXO = FIN_PREFIX 		AND "
cQuery += " E1_NUM	   = FIN_NUM 			AND "
cQuery += " E1_PARCELA = FIN_PARCEL 		AND "
cQuery += " E1_TIPO    = FIN_TIPO 			AND "
cQuery += " E1_CLIENTE = FIN_CLIENT 		AND "
cQuery += " E1_LOJA	   = FIN_LOJA AND "
cQuery += " FIN_STATUS = 'A' AND "
cQuery += RetSQLCond('FIN')
cQuery += " WHERE "
cQuery +=  RetSQLCond('SE1')

SqlToTrb(cQuery, aStruSQL, cTab)

RestArea(aArea)
Return cTab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940JOBAJUบAutor  ณAlvaro Camillo Neto บ Data ณ 28/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJob respnsavel por subir o ambiente e processar o ajuste AVP บฑฑ
ฑฑบ          ณde seus registros                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940JOBAJU(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,cProcesso,dDataProc,cId)
Local nHandle	 := 0
Local cTabJob	 := ""
Local lRet		 := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o arquivo de Lock parao controle externo das threadsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := FAVPLock(cFileLck)

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX, cFilX,,,'FIN')

Conout(STR0044+ cProcesso +STR0045+ cId + STR0046 + TIME() + STR0047)//"Processando Calculo do AVP do Contas a Receber "##" Thread: "##" as "## " horas"

cTabJob	 := FAVPSelJob(cTabMaster,aStructTab,cCpoFlag,cMarca)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Begin Transaction
	lRet := F940CalAVP(cTabJob,cProcesso,dDataProc,.T.,.F.)
End Transaction

FAVPUnLock(nHandle,lRet)
Conout(STR0048 + cProcesso +STR0045+cId + STR0046 + TIME() + STR0047)//"Fim do calculo do AVP do Contas a Receber "##" Thread: "##" as "## " horas"
Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณContabiliza็ใo dos movimentosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIN940Ctb บAutor  ณAlvaro Camillo Neto บ Data ณ  31/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Contabiliza็ใo do AVP                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FIN940Ctb()

Local nOpcA 	:= 0
Local cPerg 	:= "AFI940"

Private cCadastro 	:= STR0063//"Contabiliza็ใo do Calculo do AVP"
Private aSay 		:= {}
Private aButton 	:= {}
Private oProcess  	:= Nil

Pergunte(cPerg,.F.)


aAdd( aSay, STR0064  ) //"Esta rotina tem como objetivo a contabilizacao"
aAdd( aSay, STR0065  ) //"dos movimentos de calculo de AVP "
aAdd( aSay, STR0087  ) //"gerados pela rotina"

aAdd( aButton, { 5,.T.,{|| Pergunte(cPerg,.T.)}})
aAdd( aButton, { 1,.T.,{|| nOpca := 1 ,FechaBatch()}})
aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSay, aButton )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ฟ
//ณVerifica se o usuario concorda que o lan็amento aglutinadoณ
//ณquebre em n documentos por causa do processamento         ณ
//ณmultithread                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ[ู
If nOpcA == 1 .And. F940VAgl(cPerg)
	MsgRun( STR0088,, {|| F940CtbAVP( MV_PAR01, MV_PAR02, MV_PAR03 == 1, MV_PAR04 == 1 ) } )//"Contabilizando..."
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940CtbAVPบAutor  ณAlvaro Camillo Neto บ Data ณ  31/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa a contabiliza็ใo dos movimentos                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940CtbAVP( cProcDe , cProcAte , lMostra, lAglutina )

Local aArea 	:= GetArea()
Local lRet		:= .T.
Local nX	 	:= 0
Local aProcs 	:= {}
Local cTabMult	:= ""// Tabela para o processamento multi thread
Local nNumProc	:= GetMv("MV_AVPCTB", .F., 1 )
Local nTotalReg	:= 0
Local cRaizNome	:= 'FIN940PROC'
Local aStruSQL	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o arquivo de trabalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTabMult := F940CtbArq(cProcDe,cProcAte)

If !Empty(cTabMult) .And. (cTabMult)->(!EOF())

	(cTabMult)->(dbGoTop())
	(cTabMult)->(dbEval({|| nTotalReg++ }))
	(cTabMult)->(dbGoTop())

	If nTotalReg > nNumProc .And. nNumProc > 1 // MultiThread
		aStruSQL := (cTabMult)->( DbStruct() )

		aProcs := FAVPPrepProc(nNumProc,cTabMult,nTotalReg,"FIPFLAG",cRaizNome)

		//Inicializa as Threads Transa็ใo controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("F940JOBCTB",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],"FIPFLAG",cTabMult, aStruSQL,lAglutina,cValToChar(nX))
		Next nX
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza o controle das Threadsณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Sleep(3000)
		lRet := FAVPMonitor(aProcs)
	Else
		Begin Transaction
			lRet := F940CtbProc(cTabMult,lMostra,lAglutina)
		End Transaction
	EndIf
Else
	lRet := .F.
EndIf

(cTabMult)->( dbCloseArea() )

MsErase(cTabMult)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940CtbProcบAutor  ณAlvaro Camillo Neto บ Data ณ  04/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa os lan็amentos contabeis dos registros              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940CtbProc(cTabCtb,lMostra,lAglutina)
Local aArea 	 := GetArea()
Local aAreaSE1	 := SE1->(GetArea())
Local aAreaSA1	 := SA1->(GetArea())
Local aAreaSED	 := SED->(GetArea())
Local aAreaFIN	 := FIN->(GetArea())
Local aAreaFIP	 := FIP->(GetArea())
Local lRet		 := .T.
Local cPadrao	 := ""
Local lPadrao	 := .F.
Local cPadEfet   := "5B1"
Local cPadEsto   := "5B2"
Local lPadEfet   := VerPadrao(cPadEfet)
Local lPadEsto   := VerPadrao(cPadEsto)
Local cLoteFin	 := LoteCont("FIN")
Local lPrim		 := .T.
Local cProcesso  := ""
Local aFlagCTB   := {}
Local lUsaFlag   := GetNewPar( "MV_CTBFLAG" , .F.) // controle de flags do CTB
Local cCpoFlag	 := ""

Private cArquivo := ""
Private nHdlPrv	 := 0
Private nTotal	 := 0

SE1->(dbSetOrder(1)) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
SED->(dbSetOrder(1)) // ED_FILIAL+ED_CODIGO
FIN->(dbSetOrder(1)) // FIN_FILIAL+FIN_PREFIX+FIN_NUM+FIN_PARCEL+FIN_TIPO+FIN_CLIENT+FIN_LOJA+FIN_SEQ

(cTabCtb)->(dbGoTop())
If (cTabCtb)->(!EOF())

	cProcesso := (cTabCtb)->FIP_PROC

	While (cTabCtb)->(!EOF())
		//Posiciona no Movimento
		FIP->(dbGoTo( (cTabCtb)->FIPRECNO ) )
		//Posiciona no Titulo
		SE1->( MsSeek( xFilial("SE1") + FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO) ) )
		//Posiciona no Cliente
		SA1->( MsSeek( xFilial("SA1") + FIP->(FIP_CLIENT+FIP_LOJA) ) )
		//Posicina na Natureza
		SED->( MsSeek( xFilial("SED") + SE1->E1_NATUREZ ) )
		//Posiciona no AVP
		FIN->( MsSeek( xFilial("FIN") + FIP->(FIP_PREFIX+FIP_NUM+FIP_PARCEL+FIP_TIPO+FIP_CLIENT+FIP_LOJA+FIP_SEQ) ) )

		If FIP->FIP_STATUS == 'E' // Efetivado
			cPadrao 	:= cPadEfet
			lPadrao	:= lPadEfet
			cCpoFlag	:= "FIP_LA"
		ElseIf FIP->FIP_STATUS == 'X' // Estorno
			cPadrao  := cPadEsto
			lPadrao	:= lPadEsto
			cCpoFlag	:= "FIP_LE"
		EndIf
		If (FIP->FIP_STATUS == 'X' .AND. ALLTRIM(FIP->FIP_LA) == "S") .OR. (FIP->FIP_STATUS == 'E' .AND. ALLTRIM(FIP->FIP_LA) # "S")
			If lPadrao   // Se existe o Lacto padrao
				If lPrim
					nHdlPrv := HeadProva(cLoteFin,"FINA940",Substr(cUsuario,7,6),@cArquivo)
					lPrim := .F.
				Endif
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Tratamento utiliza็ใo do controle de flags do ctb                      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If lUsaFlag
					aAdd(aFlagCTB,{cCpoFlag,"S","FIP",FIP->(Recno()),0,0,0})
				Else
					RecLock("FIP",.F.)
					FIP->&(cCpoFlag) := "S"
					MsUnlock()
				EndiF

				nTotal += DetProva(nHdlPrv,cPadrao,"FINA940",cLoteFin)

			Endif
		EndIf
		(cTabCtb)->(dbSkip())
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica a quebra de processo        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (cTabCtb)->(EOF()) .Or. cProcesso != (cTabCtb)->FIP_PROC
			If nTotal > 0
				RodaProva(nHdlPrv,nTotal)
				cA100Incl( cArquivo, nHdlPrv , 3 , cLoteFin, lMostra, lAglutina,,,, @aFlagCTB )
			EndIf
			lPrim    := .T.
			cArquivo := ""
			nHdlPrv	 := 0
			nTotal	 := 0
			cProcesso := (cTabCtb)->FIP_PROC
		EndIf
	End
EndIf

RestArea(aAreaFIP)
RestArea(aAreaFIN)
RestArea(aAreaSED)
RestArea(aAreaSA1)
RestArea(aAreaSE1)
RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940CtbArqบAutor  ณAlvaro Camillo Neto บ Data ณ  30/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrepara o arquivo para a efetivacao da constituicao do AVP  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940CtbArq(cProcDe,cProcAte)
Local aStruSQL		:= {}
Local aArea 		:= GetArea()
Local cTab			:= FAVPNextAlias()
Local cQuery		:= ""

//Estrutura do arquivo de trabalho
AADD(aStruSQL,{"FIP_PROC" 		,"C",TamSx3("FIP_PROC")[1],00})
AADD(aStruSQL,{"FIPRECNO" 		,"N",08,00})
AADD(aStruSQL,{"FIPFLAG" 		,"C",02,00})

MsErase(cTab)
MsCreate(cTab, aStruSQL, 'TOPCONN' )
dbUseArea( .T., 'TOPCONN', cTab, cTab, .T., .F. )

cQuery += " SELECT "
cQuery += " 	FIP_PROC,  "
cQuery += " 	FIP.R_E_C_N_O_ FIPRECNO ,  "
cQuery += " 	'  ' FIPFLAG  "
cQuery += " FROM "  +RetSQLTab("FIP")
cQuery += " WHERE "
cQuery += " 	FIP_PROC   >= '" + cProcDe + "' AND "
cQuery += " 	FIP_PROC   <= '" + cProcAte + "' AND "
cQuery += " 	FIP_STATUS <> 'S' AND  "
cQuery += " 	FIP_VLRAVP <> 0 AND  "
cQuery += " 	( (FIP_LA <> 'S' AND FIP_STATUS <> 'X') OR (FIP_LE <> 'S' AND FIP_STATUS = 'X' AND FIP_LA = 'S') ) AND "
cQuery += RetSQLCond("FIP")
cQuery += " ORDER BY FIP_PROC "

SqlToTrb(cQuery, aStruSQL, cTab)

RestArea(aArea)
Return cTab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940VAgl	บAutor  ณAlvaro Camillo Neto บ Data ณ  14/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o usuario concorda que o lan็amento aglutinado  นฑฑ
ฑฑบ          ณquebre em n documentos por causa do processamento			  นฑฑ
ฑฑบ          ณmultithread                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F940VAgl(cPerg)
Local lRet := .T.
Local nNumProc		:= GetMv("MV_AVPCTB", .F., 1 )

Pergunte(cPerg,.F.)

If lRet .And. nNumProc > 1
	lRet := CTBINTRAN(1,.F.)
EndIf

If lRet .And. nNumProc > 1 .And. MV_PAR04 == 1
	lRet := MsgYesNo( STR0067 + cValtoChar(nNumProc) + STR0068 +CRLF+ STR0069 +cValtoChar(nNumProc)+ STR0070+CRLF+ STR0071 )//"A rotina estแ configurada para executar em "##" processos, sendo "##" assim irแ gerar "##" lan็amentos aglutinados. "##" Concorda com a opera็ใo? "
EndIf

If lRet .And. nNumProc > 1 .And. MV_PAR03 == 1
	lRet := MsgYesNo( STR0067 + cValtoChar(nNumProc) + STR0072 +CRLF+ STR0071 )//"A rotina estแ configurada para executar em "##" processos, por isso nใo serแ mostrada a tela de contabiliza็ใo"##" Concorda com a opera็ใo? "
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF940JOBCTBบAutor  ณAlvaro Camillo Neto บ Data ณ 28/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJob respnsavel por subir o ambiente e processar a contabilizaบฑฑ
ฑฑบ          ณ็ใo do avp                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA940                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F940JOBCTB(cEmpX,cFilX,cMarca,cFileLck,cCpoFlag,cTabMaster,aStructTab,lAglutina,cId)
Local nHandle	 := 0
Local cTabJob	 := ""
Local lRet		 := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre o arquivo de Lock parao controle externo das threadsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHandle := FAVPLock(cFileLck)

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX, cFilX,,,'FIN')

Conout(STR0073+ cId + STR0046 + TIME() + STR0047) //"Processando a contabiliza็ใo Calculo do AVP do Contas a Receber Thread: "##" as "## " horas"
cTabJob	 := FAVPSelJob(cTabMaster,aStructTab,cCpoFlag,cMarca)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza o processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Begin Transaction
	lRet := F940CtbProc(cTabJob,.F.,lAglutina)
End Transaction

FAVPUnLock(nHandle,lRet)
Conout(STR0074+cId + STR0046 + TIME() + STR0047)//"Fim do processo a contabiliza็ใo Calculo do AVP do Contas a Receber Thread: "##" as "## " horas"

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFin940LegณAutor  ณ Alvaro Camillo Neto   ณ Data ณ21.12.2009 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณDemonstra a legenda das cores da mbrowse                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณEsta rotina monta uma dialog com a descricao das cores da    ณฑฑ
ฑฑณ          ณMbrowse.                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Fin940Leg(lRetCor)
Local aRet		:= {}
Local aCores := {	{"ENABLE"		,	"FIO_STATUS = 'E'", STR0075},;//"Efetivado"
					{"BR_AMARELO"		,	"FIO_STATUS = 'S'", STR0076},;//"Simulado"
					{"DISABLE"			,	"FIO_STATUS = 'X'", STR0077} }//"Estornado"

DEFAULT lRetCor := .F.
If ValType(lRetCor) <> 'L'
	lRetCor := .F.
EndIf

If lRetCor
	aEval( aCores, {|x|  Aadd( aRet, {x[2],x[1]} ) } )
Else
	aEval( aCores, {|x|  Aadd( aRet, {x[1],x[3]} ) } )
	BrwLegenda(cCadastro,STR0078,aRet)//"Legenda"
	aRet := Nil
EndIf

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ FGRV940CAB ณ Autor ณ Alvaro Camillo Neto ณ Data ณ 16/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Grava as tabelas Cabecalho Processo AVP			           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FGRV940CAB(cProcesso,cTipoProc,aRetPer)
Local aArea 	:= GetArea()

Default cTipoProc 	:= "S"
Default aRetPer		:= {}

FIO->(dbSetOrder(1))
If FIO->(MsSeek(xFilial("FIO")+cProcesso))
	RecLock("FIO",.F.)
	FIO_STATUS	:= cTipoProc
	MsUnlock()
ElseIf !Empty(aRetPer)
	RecLock("FIO",.T.)
		FIO->FIO_FILIAL	:= xFilial("FIO")
		FIO->FIO_PROC	  	:= aRetPer[PROCESSO]
		FIO->FIO_DTAVP	  	:= aRetPer[DATA_PROC]
		FIO->FIO_STATUS		:= cTipoProc
		FIO->FIO_VLRDE		:= aRetPer[VALOR_DE]
		FIO->FIO_VLRATE		:= aRetPer[VALOR_ATE]
		FIO->FIO_VENDE		:= aRetPer[VENCTO_DE]
		FIO->FIO_VENATE		:= aRetPer[VENCTO_ATE]
		FIO->FIO_NATDE		:= aRetPer[NATUREZA_DE]
		FIO->FIO_NATATE		:= aRetPer[NATUREZA_ATE]
		FIO->FIO_PORDE		:= aRetPer[PORTADOR_DE]
		FIO->FIO_PORATE		:= aRetPer[PORTADOR_ATE]
		FIO->FIO_CLIDE	  	:= aRetPer[CLIENTE_DE]
		FIO->FIO_CLIATE		:= aRetPer[CLIENTE_ATE]
		FIO->FIO_LOJDE		:= aRetPer[LOJA_DE]
		FIO->FIO_LOJATE		:= aRetPer[LOJA_ATE]
		FIO->FIO_METODO		:= cValToChar(aRetPer[METODO])
		FIO->FIO_EMSDE 		:= aRetPer[EMISSAO_DE]
		FIO->FIO_EMSATE		:= aRetPer[EMISSAO_ATE]
	MsUnlock()
Endif

RestArea(aArea)
Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Alvaro Camillo Neto   ณ Data ณ21/12/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ	  1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef()

Private aRotina :=  { {'Pesquisar',"AxPesqui", 	1, 1},;
						{ STR0079,"FIN940Sim", 	3, 3},;//'Simular'
						{ STR0080,"FIN940Efe", 	4, 4},;//'Efetivar'
						{ STR0081,"FIN940Proc", 3, 3},;//'Processar'
						{ STR0082 ,"FIN940Est",	4, 5},;//'Estornar'
						{ STR0083 ,"FIN940Ctb",	4, 2},;//"Contabilizar"
						{ STR0078,"FIN940Leg", 	2, 2} }//"Legenda"

Return(aRotina)
