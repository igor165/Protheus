#include "PROTHEUS.CH"
#include "APWIZARD.CH"
#include "LJWIZNFCE.CH"

Static aSX3		:= {}
Static aSX6		:= {}
Static aSPED000	:= {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjWizNfCe บAutor  ณVendas Clientes       บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de ajuste manual de parโmetros para o funcionamento     บฑฑ
ฑฑบ          ณ  da NFC-e sobre tela Wizard                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjWizNFCe()
	
Local oWizard						//Objeto Wizard
Local oGD_ERP						//Objeto para painel dos parโmetros (SX6)
Local oGD_TSS						//Objeto para painel do TSS
Local lRetAux	:= .F.				//Auxiliar de Retorno
Local lSX3Ok	:= .F.				//Retorno da Tabela de Array SX3
Local lSX6Ok	:= .F.				//Retorno da Tabela de Array SX6

//inicia os arrays estaticos
LjSetArr('SX3')
LjSetArr('SX6')
LjSetArr('SPED000')
	
/*
	MONTAGEM DO WIZARD
		Explicacao sobre NEXT e BACK:
	Ao ser executado, NEXT soma 1 ao painel atual(oWizard:NPANEL), jแ BACK, subtrai 1
	Ex: Se estamos no PANEL 1 e queremos ir para o PANEL 4, usamos:
	NEXT {|| oWizard:NPANEL := 3 }, pois ao ser usado NEXT, ele vai somar 1, indo para o PANEL 4
*/	
DEFINE WIZARD oWizard;
	TITLE STR0001;									//"Wizard NFC-e"
	HEADER STR0002;									//"Wizard de Configura็ใo da NFC-e"
	MESSAGE STR0003;								//"Nota Fiscal de Consumidor Eletr๔nica"
	TEXT STR0004 PANEL;								//"A partir de agora, validaremos o Dicionแrio de Dados e revisaremos as configura็๕es do servidor TSS"		
	NEXT {|| lSX3Ok := LJLoad2Arr('SX3'), lSX6Ok := LJLoad2Arr('SX6'), nNextPanel := IIF(lSX3Ok .AND. lSX6Ok,1,3), oWizard:NPANEL := nNextPanel/*3+1=4*/, .T.};
	FINISH {|| .T.}

// PANEL 2 - PARAMETRO ERP	
CREATE PANEL oWizard;
	HEADER STR0005;									//"Parโmetros (SX6)"
	MESSAGE STR0006 + CRLF + STR0007 PANEL;			//"Para efetivar as altera็๕es, clique em Avan็ar."###"Somente um usuแrio do grupo ADMINISTRADORES pode efetuar altera็๕es"
	BACK { || .T.};
	EXEC { || oGD_ERP := LJArr2Grid('SX6',oWizard:GetPanel(2)) };
	NEXT { || IIf(oGD_ERP:TudoOk(), (IIF(FwIsAdmin(), LJUpdSX6(oGD_ERP), Nil), .T.), .F.) };		
	FINISH { || .T.}

// PANEL 3 - PARAMETRO TSS
CREATE PANEL oWizard;
	HEADER STR0008;									//"Parโmetros (SPED000)"
	MESSAGE STR0009 PANEL;							//"Para alterar os parโmetros, utilize a rotina NFC-e > Parโmetros"
	BACK {|| oWizard:NPANEL := 3/*3-1=2*/, .T.};
	EXEC {|| MsgRun( STR0010, STR0011, {||lRetAux := LJLoad2Arr('SPED000')} ), IIF( lRetAux, oGD_TSS := LJArr2Grid('SPED000',oWizard:GetPanel(3)), LjWizLog('SPED000', oWizard:GetPanel(3)) ) };	//"Consultando o servidor TSS"###"WIZARD NFC-e"
	NEXT {|| oWizard:NPANEL := 3/*3+1=4*/, .T.}

// PANEL 4 - LOG
CREATE PANEL oWizard;
	HEADER STR0012;									//"Conclusใo"
	MESSAGE STR0013 PANEL;							//"Verifique abaixo o log de conclusใo"
	BACK {|| MsgInfo(STR0014, STR0011),.F.};		//"Conclua o Assistente e execute-o novamente."###"WIZARD NFC-e"		
	NEXT {|| .T.};
	EXEC {|| LjWizLog('ALL', oWizard:GetPanel(4)), .T. };
	FINISH {|| .T. }

ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjPar2aHaC บAutor  ณVendas Clientes      บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que obtemos o aCols e aHeader que serใo utilizados      บฑฑ
ฑฑบ          ณ  na montagem do Grid do Wizard                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJPAR2aHaC(cInfo)

Local nI		:= 0		//Contador
Local nUsado	:= 0		//Retorna o tamanho do Header
Local aAux		:= {}		//Array auxiliar
Local aRet		:= {}		//Array de retorno
Local aHeader	:= {}		//Elemento do Grid
Local aCols	:= {}		//Elemento do Grid

Default cInfo	:= ""

// ------------------------------
// AHEADER - serve para ERP e TSS
// ------------------------------
Aadd( aHeader, {STR0015	, STR0016	, ''				,;			//'Parametro'###'PARAMETRO'
				10			, 0				, 'AllwaysTrue()'	,;
				Nil			, 'C'			, Nil				,;
				Nil} ) 

Aadd( aHeader, {STR0017	, STR0018	, ''				,;			//'Conteudo'###'CONTEUDO'
				250			, 0				, 'AllwaysTrue()'	,;
			 	Nil			, 'C'			, Nil				,;
			 	Nil} )

//tamanho do aHeader (quantidade de campos)
nUsado := Len( aHeader )

// -----
// ACOLS
// -----
If cInfo == "SX6"
	aAux := Aclone( LJGetArr('SX6') )
ElseIf cInfo == "SPED000"
	aAux := Aclone( LJGetArr('SPED000') )
EndIf	

//para cada tipo, obt้m os dados dos parโmetros
For nI := 1 to Len( aAux )
	
	//Se o parโmetro existir
	If aAux[nI][3]
		//cria uma nova linha no aCols
		Aadd(aCols, Array(nUsado + 1) )
		//e o alimenta com os valores do parโmetro
		aTail(aCols)[1] 		:= PadR(aAux[nI][1],250)		//Parโmetro
		aTail(aCols)[2]			:= PadR(aAux[nI][4],250)	//Conte๚do
		aTail(aCols)[nUsado+1]	:= .F.						//Marca como nใo deletado
	EndIf
Next

// retorna o aHeader e aCols
Aadd( aRet, aHeader	)
Aadd( aRet, aCols	) 

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjSetArr บAutor    ณVendas Clientes      บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria uma tabela de arrays a partir do conte๚do especํfico     บฑฑ
ฑฑบ          ณ   (SX3, SX6, SPED000)                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LjSetArr( cInfo, nOperacao, aAux ) 

Local cMvVerNFCe    := "" //Versao NFC-e
Local aGetMvTSS     := {}

Default cInfo		:= ""		//Tabela desejada
Default nOperacao	:= 0		//0=Cria Tabela de Array
Default aAux		:= {}		//Montagem da Tabela de Array

//Obtemos a versao da NFC-e do TSS
If ExistFunc("LjGetMVTSS")
    aGetMvTSS := LjGetMVTSS("MV_VERNFCE")
    
    If Len(aGetMvTSS) > 0 .And. aGetMvTSS[1]
        cMvVerNFCe := AllTrim(aGetMvTSS[2])
    EndIf
EndIf

DO CASE

	Case cInfo == 'SX3'
		/*		
		[][1] - nome do campo
		[][2] - 1-obrigatorio 2-recomendado 3-opcional
		[][3] - indica se o campo existe
		*/			
		If nOperacao == 0
			aAux := {}

							
			Aadd( aAux, {'L1_KEYNFCE'	, 1, .F.} )	
			Aadd( aAux, {'LQ_KEYNFCE'	, 1, .F.} )	
			Aadd( aAux, {'L2_ORIGEM'	, 1, .F.} )
			Aadd( aAux, {'LR_ORIGEM'	, 1, .F.} )			
			Aadd( aAux, {'L2_MODBC'		, 1, .F.} )
			Aadd( aAux, {'LR_MODBC'		, 1, .F.} )			
			Aadd( aAux, {'L2_POSIPI'	, 1, .F.} )
			Aadd( aAux, {'LR_POSIPI'	, 1, .F.} )
			Aadd( aAux, {'L2_CEST'		, 1, .F.} )
			Aadd( aAux, {'LR_CEST'		, 1, .F.} )
			Aadd( aAux, {'LG_NFCE'		, 1, .F.} )			
			
			//RECOMENDADO
			Aadd( aAux, {'L2_CODBAR'	, 2, .F.} )
			Aadd( aAux, {'LR_CODBAR'	, 2, .F.} )			
			Aadd( aAux, {'L2_DESCICM'	, 2, .F.} )
			Aadd( aAux, {'LR_DESCICM'	, 2, .F.} )	
			Aadd( aAux, {'L2_MOTDICM'	, 2, .F.} )
			Aadd( aAux, {'LR_MOTDICM'	, 2, .F.} )
			Aadd( aAux, {'L2_PREDIC'	, 2, .F.} )
			Aadd( aAux, {'LR_PREDIC'	, 2, .F.} )
			Aadd( aAux, {'L2_CODISS'	, 2, .F.} )
			Aadd( aAux, {'LR_CODISS'	, 2, .F.} )
			Aadd( aAux, {'L2_BASEISS'	, 2, .F.} )
			Aadd( aAux, {'LR_BASEISS'	, 2, .F.} )
			Aadd( aAux, {'L2_ALIQISS'	, 2, .F.} )
			Aadd( aAux, {'LR_ALIQISS'	, 2, .F.} )
			Aadd( aAux, {'L2_VALISS'	, 2, .F.} )
			Aadd( aAux, {'LR_VALISS'	, 2, .F.} )
			Aadd( aAux, {'LG_SERNFIS'	, 2, .F.} )
			Aadd( aAux, {'LX_MODDOC'	, 2, .F.} )
			Aadd( aAux, {'LQ_RETSFZ'	, 2, .F.} )
			Aadd( aAux, {'L1_RETSFZ'	, 2, .F.} )
			
			If cMvVerNFCe == "4.00"
                Aadd( aAux, {'L2_ALQFECP'   , 2, .F.} )
                Aadd( aAux, {'LR_ALQFECP'   , 2, .F.} )
                Aadd( aAux, {'L2_VALFECP'   , 2, .F.} )
                Aadd( aAux, {'LR_VALFECP'   , 2, .F.} )
                Aadd( aAux, {'L2_ALQFCST'   , 2, .F.} )
                Aadd( aAux, {'LR_ALQFCST'   , 2, .F.} )
                Aadd( aAux, {'L2_VFECPST'   , 2, .F.} )
                Aadd( aAux, {'LR_VFECPST'   , 2, .F.} )
            EndIf

			//OBRIGATORIO SOMENTE PARA FRONTLOJA
			Aadd( aAux, {'BI_ORIGEM'	, 2, .F.} )
			Aadd( aAux, {'BI_CEST'		, 2, .F.} )
		EndIf
		
		aSX3 := Aclone( aAux )
	
	Case cInfo == 'SX6'			
		/*		 
		[][1] - nome do parametro 
		[][2] - 1-obrigatorio 2-recomendado 3-opcional		
		[][3] - indica se o parametro existe
		[][4] - valor do parametro
		*/			
		If nOperacao == 0
			aAux := {}
			
			Aadd(aAux, {'MV_NFCEURL', 1, .F., Nil} )
			Aadd(aAux, {'MV_NFCETOK', 1, .F., Nil} )
			Aadd(aAux, {'MV_NFCEIDT', 1, .F., Nil} )
			Aadd(aAux, {'MV_NFCEUTC', 1, .F., Nil} )
			Aadd(aAux, {'MV_CODREG' , 1, .F., Nil} )						
			Aadd(aAux, {'MV_NFCEGC'	, 2, .F., Nil} )			
			Aadd(aAux, {'MV_SPEDEND', 2, .F., Nil} )
			Aadd(aAux, {'MV_LJGRVON', 2, .F., Nil} )
			Aadd(aAux, {'MV_NFCECNJ', 2, .F., Nil} )
			Aadd(aAux, {'MV_LJRECNR', 2, .F., Nil} )			
			Aadd(aAux, {'MV_LJSTPRT', 3, .F., Nil} )			
			Aadd(aAux, {'MV_LJCONDE', 3, .F., Nil} )			
			Aadd(aAux, {'MV_NFCEDES', 3, .F., Nil} )
			Aadd(aAux, {'MV_NFCEIMP', 3, .F., Nil} )
			Aadd(aAux, {"MV_INUTCLI", 3, .F., Nil} )
			Aadd(aAux, {"MV_INUTPRO", 3, .F., Nil} )
			Aadd(aAux, {"MV_INUTTES", 3, .F., Nil} )
			Aadd(aAux, {"MV_INUTLOJ", 3, .F., Nil} )
			
			If cMvVerNFCe == "4.00"
                Aadd(aAux, {'MV_LJTROCO' , 2, .F., Nil} )
            EndIf

		EndIf
		
		aSX6 := Aclone( aAux )
	
	Case cInfo == 'SPED000'
		/*
		[][1] - nome do parโmetro
		[][2] - 1-obrigat๓rio 2-recomendado 3-opcional 4-configura็ใo TSS		 
		[][3] - indica se o parโmetro existe (nใo usado para SPED000)
		[][4] - valor do parโmetro
		*/
		If nOperacao == 0
			aSPED000 := {}

			Aadd( aAux, {'VERSAO_TSS'	, 4, .T., Nil} )
			Aadd( aAux, {'ID_ENT'		, 4, .T., Nil} ) 
			Aadd( aAux, {'MV_AMBNFCE'	, 4, .T., Nil} )
			Aadd( aAux, {'MV_MODNFCE'	, 4, .T., Nil} )
			Aadd( aAux, {'MV_NFCEOFF'	, 4, .T., Nil} )		
			Aadd( aAux, {'MV_VERNFCE' 	, 4, .T., Nil} )
		EndIf

		aSPED000 := Aclone( aAux )

ENDCASE

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjGetArr บAutor    ณVendas Clientes      บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que retorna o conte๚do do array a partir de um         บฑฑ
ฑฑบ          ณ   elemento especํfico.                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJGetArr(cInfo)

Local aAux := {}		//Retorno do Conte๚do

Default cInfo := ""

DO CASE
	Case cInfo == 'SX3'
		aAux := aClone(aSX3)
		
	Case cInfo == 'SX6'
		aAux := aClone(aSX6)

	Case cInfo == 'SPED000'
		aAux := aClone(aSPED000)
ENDCASE

Return aAux


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjLoad2Arr บAutor    ณVendas Clientes    บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obt้m os dados do array estแtico (SX3,SX6,SPED000)            บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJLoad2Arr(cInfo)
	
Local nI		:= 0			//Contador
Local nPos		:= 0			//Posi็ใo do Array
Local cAliasName:= ""		//Nome do Alias
Local xGetMV	:= Nil			//Conte๚do GetMV
Local aAux		:= {}			//Dados do array estแtico (SX3 ou SX6 ou SPED000) 
/* uso TSS */
Local lRet		:= .T.			//Retorno
Local cError	:= ""			//Mensagem do Erro
Local cIDEnt	:= ""			//o ID da ENTIDADE que estแ configurado no TSS
Local cModelo	:= "65"		//Modelo de acordo com o SEFAZ

Default cInfo	:= ""

//obtem os dados do array estatico
aAux := aClone( LjGetArr(cInfo) )

DO CASE

	Case cInfo == "SX3"		
		
		For nI := 1 to Len(aAux)
				
			nPos := At( "_", aAux[nI][1] )
			
			//ZZ_FieldName
			If nPos == 3
				cAliasName := 'S' + SubStr(aAux[nI][1], 1, 2)  		
			//ZZZ_FieldName
			Else
				cAliasName := SubStr(aAux[nI][1], 1, 3)
			EndIf	
			
			If &(cAliasName)->( ColumnPos(aAux[nI][1]) ) > 0
				aAux[nI][3] := .T.
			Else	//se o campo for OBRIGATORIO
				If aAux[nI][2] == 1	
					lRet := .F.
				EndIf
			EndIf
			
		Next

	Case cInfo == "SX6"	

		For nI := 1 to Len( aAux )
			
			xGetMV := GetMV( aAux[nI][1], .F., "NOT_FOUND" )//SuperGetMV( aAux[nI][1], .F., "NOT_FOUND" )
		
			If ValType(xGetMV) == "C" .AND. xGetMV == "NOT_FOUND"
				If aAux[nI][2] == 1		//se o parametro for OBRIGATORIO
					lRet := .F.
				EndIf
			Else
				aAux[nI][3] := .T.		//indica que o parametro existe
				aAux[nI][4] := xGetMV	//armazena o valor do parametro
			EndIf

		Next

	Case cInfo == "SPED000"
		
		//usado para obter os parametros da NFC-e (tssconfig.prw) 
		SetFunName("LOJA701")

		/*		
			valida o TSS antes de obter os valores dos parametros
		*/
		//verifica se estแ conectado ao TSS
		lRet := isConnTSS(@cError)
		If ValType(lRet) <> 'L' .OR. !lRet .OR. !Empty(cError)			
			lRet := .F.
			ASize( aAux, 0 )
			Aadd( aAux, {'CONN_TSS', 4, .F., cError} )
			//Alert(cError)
		EndIf
	
		//recupera o ID da ENTIDADE que estแ configurado no TSS
		If lRet
			cIDEnt := getCfgEntidade(@cError)
			If !Empty(cError)			
				lRet := .F.
				Asize(aAux, 0)
				Aadd( aAux, {'CFG_ENTIDADE', 4, .F., cError} )
				//Alert(cError)
			EndIf
		EndIf
		/*
		//verifica se hแ certificado configurado
		If lRet
			lRet := isCFGReady(cIDEnt, @cError)
			If ValType(lRet) <> 'L' .OR. !lRet .OR. !Empty(cError)
				lRet := .F.
				Asize(aAux, 0)
				Aadd( aAux, {'CFG_READY', 4, .F., cError} )
				//Alert(cError)
			EndIf
		EndIf
		*/
		/*
			se o TSS estiver configurado, obtemos os valores dos parametros
		*/
		If lRet
			
			For nI := 1 to Len( aAux )
	
				Do Case
					Case aAux[nI][1] == 'VERSAO_TSS'									
						xGetMV := getVersaoTSS(@cError)

					Case aAux[nI][1] == 'ID_ENT'
						xGetMV := cIDEnt					
	
					Case aAux[nI][1] == 'MV_AMBNFCE'
						getCfgAmbiente(@cError, cIDEnt, cModelo, @xGetMV)				
							
					Case aAux[nI][1] == 'MV_MODNFCE'				
						getCfgModalidade(@cError, cIDEnt, cModelo, @xGetMV)

					Case aAux[nI][1] == 'MV_NFCEOFF'				
						getcfgContigencia(@cError, cIDEnt, cModelo, @xGetMV)

					Case aAux[nI][1] == 'MV_VERNFCE'	
						xGetMV := "0.00" // tem que ser "0.00" pois se passar vazio assume versใo padrao 3.10										
						getCfgVersao(@cError, cIDEnt, cModelo, @xGetMV )	
						//Case seja divergente o paramento da informa็ใo do TSS alteramos o parametro.
						If AllTrim(xGetMV) <> AllTrim(SuperGetMv("MV_VERNFCE",, "")) 
							PutMv("MV_VERNFCE" , xGetMV)
						EndIf						
				EndCase
				
				//Se houve erro, aborta a missao
				If !Empty(cError)
					aAux[nI][3] := .F.
					aAux[nI][4] := cError

					lRet := .F.
					//Alert( cError )
					Exit
				ElseIf Empty(xGetMV)
					aAux[nI][3] := .T.
					aAux[nI][4] := STR0019	//"NAO RETORNADO - Verifique se o parโmetro estแ configurado para essa Entidade na tabela SPED000"
				ElseIf xGetMV $ "0|0.00"	//valores padroes para MOD/AMB/NFCEOFF/VERNFCE
					aAux[nI][3] := .T.
					aAux[nI][4] := xGetMV + S	//" - VALOR INVALIDO"
					xGetMV		:= ""
				Else
					aAux[nI][4] := xGetMV
					xGetMV 		:= ""
				EndIf
			Next
		EndIf
ENDCASE

//atualiza o array estatico para geracao do Log
LjSetArr( cInfo, 1/*atualiza*/, aAux ) 

//limpa o array da mem๓ria
ASize( aAux, 0 )
aAux := Nil

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjWizLog บAutor    ณVendas Clientes      บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Log de Ocorr๊ncias ap๓s a altera็ใo dos parโmetros            บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LjWizLog( cInfo, oWindow )

Local cLog		:= ''			//Conte๚do do Log
Local nI		:= 0			//Contador I
Local nX		:= 0			//Contador X
Local aAux		:= {}			//Array auxiliar
Local aLog		:= { {/*OBRIG*/}, {/*RECOM*/}, {/*OPCIO*/}, {/*TSS*/} }	//Resultado do Log
Local oMultiGet	:= Nil		//Interface com o resultado do Log

Default cInfo	:= 'ALL'
Default oWindow := Nil

If cInfo == 'ALL'  
	Aadd( aAux, Aclone(LJGetArr('SX3')) )
	Aadd( aAux, Aclone(LJGetArr('SX6')) )
	Aadd( aAux, Aclone(LJGetArr('SPED000')) )
Else
	Aadd( aAux, Aclone(LJGetArr(cInfo)) )
EndIf
	
For nI := 1 to Len( aAux )
	For nX := 1 to Len( aAux[nI] )		
		//se o campo/parametro/configuracao nao existir
		If !aAux[nI][nX][3]
			Do Case 
				//itens obrigatorios
				Case aAux[nI][nX][2] = 1
					Aadd( aLog[1], aAux[nI][nX][1] )								
				//itens recomendados		  
				Case aAux[nI][nX][2] = 2
					Aadd( aLog[2], aAux[nI][nX][1] ) 
				//itens opcionais
				Case aAux[nI][nX][2] = 3
					Aadd( aLog[3], aAux[nI][nX][1] )				
				//configuracao TSS
				Case aAux[nI][nX][2] = 4
					Aadd( aLog[4], aAux[nI][nX][1] + " - " + aAux[nI][nX][4] )
			EndCase
		EndIf
	Next
Next

/*
	Formata็ao da string contendo o LOG	
*/
If cInfo == 'ALL'
	If Len(aLog[1]) > 0
		cLog += STR0021	//'NรO FOI POSSอVEL FINALIZAR A CONFIGURAวรO DA NFC-e. Verifique os itens OBRIGATำRIOS:'
		cLog += Replicate(CRLF,2)
	ElseIf (Len(aLog[2]) + Len(aLog[3]) + Len(aLog[4])) > 0
		cLog += STR0022	//'A configura็ใo da NFC-e foi finalizada, por้m hแ algumas advert๊ncias:'
		cLog += Replicate(CRLF,2)
	Else
		cLog += STR0023	//'A configura็ใo da NFC-e foi finalizada com SUCESSO!'
		cLog += Replicate(CRLF,2)
	EndIf
EndIf

If Len(aLog[1]) > 0 
	cLog += STR0024	//"- os itens OBRIGATำRIOS abaixo nใo existem nesse ambiente:"
	cLog += CRLF
	For nI := 1 to Len(aLog[1])
		cLog += (aLog[1][nI] + ';')
	Next
	cLog += Replicate(CRLF,2)
EndIf

If Len(aLog[2]) > 0
	cLog += STR0025	//"- os itens RECOMENDADOS abaixo nใo existem nesse ambiente:"
	cLog += CRLF
	For nI := 1 to Len(aLog[2])
		cLog += (aLog[2][nI] + ';')
	Next
	cLog += Replicate(CRLF,2)
EndIf

If Len(aLog[3]) > 0
	cLog += STR0026	//"- os itens OPCIONAIS abaixo nใo existem nesse ambiente:"
	cLog += CRLF
	For nI := 1 to Len(aLog[3])
		cLog += (aLog[3][nI] + ';')
	Next
	cLog += Replicate(CRLF,2)
EndIf

If Len(aLog[4]) > 0
	cLog += STR0027	//"- Nใo foi possํvel obter os dados do Servidor TSS devido ao erro: "
	cLog += CRLF
	For nI := 1 to Len(aLog[4])
		cLog += (aLog[4][nI] + ';')
	Next
	cLog += Replicate(CRLF,2)
EndIf	

If Len(aLog[1]) > 0 .OR. Len(aLog[2]) > 0 .OR. Len(aLog[3]) > 0
	cLog += STR0049	//"- Atualize o dicionแrio, consultando a documenta็ใo no TDN de acordo com o campo/parโmetro a ser configurado."
	cLog += Replicate(CRLF,2)
	cLog += STR0048	//"- Para maiores informa็๕es, por gentileza, leia o documento t้cnico http://tdn.totvs.com.br/pages/viewpage.action?pageId=210055818."
	cLog += Replicate(CRLF,2)
EndIf  

/*
	Montagem do MultiGet com o resultado do log
*/
oMultiGet := TMultiGet():Create(oWindow			, {|| cLog} 		, 5					, 5				,; 
								292				, 130				, /*oFont*/			, Nil			,;
								Nil				, Nil				, Nil				, .T. /*lPixel*/,;
								Nil				, Nil				, /*bWhen*/			, Nil			,; 
								Nil				, .T. /*lReadOnly*/	, /*bValid*/		, Nil			,;
								Nil				, .F. /*lBorder*/	, /*lVScroll*/		, /*cLabelText*/,;
								/*nLabelPos*/	, /*oLabelFont*/	, /*nLabelColor*/	)

Return oMultiGet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjUpdSX6 บAutor    ณVendas Clientes      บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Permite update na tabela SX6 com base na edi็ใo do grid       บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJUpdSX6(oGetData)

Local nI			:= 0		//Contador
Local nPos			:= 0		//Posi็ใo do Array
Local aColsAux	:= {}		//aCols do objeto MSNewGetDados
Local aSX6Aux		:= {}		//Conte๚do editado do array aSX6 	

Default oGetData := Nil

//obtemos o aCols do objeto MSNewGetDados com os dados editados
aColsAux := aClone(oGetData:aCols)

//verifica se hแ algum parโmetro pra ser atualizado (nao deletado no grid)
nPos := Ascan( aColsAux, {|x| Atail(x) == .F.} )

If nPos > 0

	If MsgYesNo(STR0029 + CRLF +;		//"Atualizar os valores dos parโmetros(SX6)?"
				STR0030)	//"Os parโmetros excluํdos no grid nใo serใo considerados."

		//obtemos o conteudo do array estatico aSX6
		aSX6Aux := Aclone( LJGetArr('SX6') )

		For nI := 1 to Len(aColsAux)
			//s๓ atualiza o SX6 e o array, se a linha do grid nao tiver deletada
			If !aTail( aColsAux[nI] )

				//atualizamos a tabela SX6 
				PutMV( AllTrim(aColsAux[nI][1]), AllTrim(aColsAux[nI][2]) )

				//atualizamos o array estแtico aSX6
				nPos := Ascan( aSX6Aux, {|x| x[1] == AllTrim(aColsAux[nI][1])} )
				If nPos > 0
					aSX6Aux[nPos][4] := aColsAux[nI][2]
					LjSetArr( "SX6", 1, aSX6Aux )		
				EndIf				
			EndIf
		Next

	EndIf
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjArr2Grid บAutor    ณVendas Clientes    บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ L๊ as informa็๕es do grid a partir de um array                บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJArr2Grid(cInfo, oWnd) 

Local aAlter	:= {}		//Array que mostrarแ a coluna "CONTEฺDO" se o login do usuแrio for administrador

Default cInfo	:= ""
Default oWnd	:= Nil

If cInfo == "SX6"
	//se pertencer ao grupo Administradores, permite editar a coluna CONTEUDO
	If FwIsAdmin()
		aAlter := {STR0018}		//'CONTEUDO'
	EndIf
EndIf	

//obtemos o aCols e aHeader que serao utilizados
aAuxHeader := Aclone( LJPAR2aHaC(cInfo)[1] )
aAuxCols := Aclone( LJPAR2aHaC(cInfo)[2] )

oGetDados := MsNewGetDados():New(	010						, 010			, 115 			, 280			,;
									GD_UPDATE+GD_DELETE		, 'AllwaysTrue' , "u_tudook"	, Nil			,;
									aAlter					, /*nFreeze*/0	, 999			, "AllwaysTrue"	,;
									""						, "AllwaysTrue"	, oWnd			, aAuxHeader	,;
									aAuxCols 				)

If nModulo == 23
	TButton():New( 120, 010, "Atualizar URLs da NFC-e", oWnd, {|| LjUpdUrls() }, 70, 15,,, .F., .T., .F.,, .F.,,, .F. )
EndIf

Return oGetDados

/*
MsNewGetDados(): New ( 	[ nTop]					, [ nLeft]		, [ nBottom]		, [ nRight ]	, 
						[ nStyle]				, [ cLinhaOk]	, [ cTudoOk]		, [ cIniCpos]	,
						[ aAlter]				, [ nFreeze]	, [ nMax]			, [ cFieldOk]	,
						[ cSuperDel]			, [ cDelOk]		, [ oWnd]			, [ aPartHeader], 
						[ aParCols]				, [ uChange]	, [ cTela] 			)
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TudoOk     บAutor    ณVendas Clientes    บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se todos os parโmetros OBRIGATำRIOS foram            บฑฑ
ฑฑบ          ณ   preenchidos.                                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TudoOk()

Local cAux			:= ""	//Variแvel auxiliar
Local cMsgErro	:= ""	//Mensagem de Erro
Local nI			:= 0	//Contador
Local nPos			:= 0	//Posi็ใo do Array
Local nOpcao		:= 1	//Op็ใo escolhida
Local lRet			:= .T.	//Variแvel de retorno
Local lMvSpedEnt	:= .F.	//Valor default do parโmetro MV_SPEDENT
Local aOpcao		:= {}	//Escolher op็ใo para aviso de fuso horแrio incorreto

AEval( aCols, {|x| x[1] := AllTrim(x[1])} )

For nI := 1 to Len(aCols)
	DO CASE
		Case aCols[nI][1] == "MV_NFCEURL"
			cAux := AllTrim(aCols[nI][2])
			
			If Empty(cAux)
				lRet := .F.
				cMsgErro += aCols[nI][1] + STR0031	//" - preencha com a URL do servidor TSS;"
				cMsgErro += CRLF
			EndIf

		Case aCols[nI][1] == "MV_NFCETOK"
			cAux := AllTrim(aCols[nI][2])
			
			If Empty(cAux)
				lRet := .F.
				cMsgErro += (aCols[nI][1] + STR0032)	//" - preencha com o CSC fornecido pelo SEFAZ (nใo altere nenhum caracter)"
				cMsgErro += CRLF
			EndIf

		Case aCols[nI][1] == "MV_NFCEIDT"
			cAux := AllTrim(aCols[nI][2])
			
			If Empty(cAux)
				lRet := .F.
				cMsgErro += aCols[nI][1] + STR0033	//" - preencha com o ID do CSC fornecido pelo SEFAZ;"
				cMsgErro += CRLF
			ElseIf Len(cAux) <> 6
				lRet := .F.
				cMsgErro += aCols[nI][1] + STR0034	//" - tamanho invแlido. Deve possuir 6 caracteres. Exemplo: 000001"
				cMsgErro += CRLF
			EndIf
			
		Case aCols[nI][1] == "MV_NFCEUTC"
			cAux := AllTrim(aCols[nI][2]) 
			
			If Empty(cAux)
				lRet := .F.
				cMsgErro += aCols[nI][1] + STR0035  //" - preencha com o FUSO HORมRIO de seu Estado. Exemplo: -03:00"
				cMsgErro += CRLF
			ElseIf Len(cAux) <> 6
				lRet := .F.
				cMsgErro += aCols[nI][1] + STR0036	//" - tamanho invแlido. Deve possuir 6 caracteres. Exemplo: -03:00
				cMsgErro += CRLF			
			//verifica se esta no formato correto "-00:00"
			ElseIf !( SubStr(cAux,1,1) == "-" .AND. IsDigit(SubStr(cAux,2,2)) .AND. SubStr(cAux,4,3) == ":00" )
				lRet := .F.
				cMsgErro += aCols[nI][1] + STR0037	//" - formato invแlido. O formato deve ser -99:99"
				cMsgErro += CRLF
			Else
				//MV_SPEDENT indica se usa o M0_ESTCOB (cobranca) ou M0_ESTENT (entrega)
				nPos := Ascan( aCols, {|x| x[1] == "MV_SPEDEND"} )
				If nPos > 0
					//macro executa o valor do parametro, pois ele vem no formato string
					lMvSpedEnt := &(aCols[nPos][2])
					If ValType( lMvSpedEnt ) <> "L"						
						lRet := .F.
						cMsgErro += aCols[nPos][1] + STR0038	//" - formato invแlido. Digite um valor LำGICO"
						cMsgErro += CRLF
					EndIf
				EndIf

				If ValType(lMvSpedEnt) == "L"
					If lMvSpedEnt
						cUF := AllTrim(SM0->M0_ESTENT)
					Else
						cUF := AllTrim(SM0->M0_ESTCOB)
					EndIf
					
					// retorno do RetUFUTC -> [1]UTC Normal / [2]UTC Horแrio de Verao
					aUFUTC := RetUFUTC(cUF)
					If !Empty(aUFUTC)

						If !( cAux $ (aUFUTC[1] + "|" + aUFUTC[2]) )
						
							//Se a UF nao possui Horario de Verao(ERR404), nao exibe essa opcao
							Aadd(aOpcao, cAux )			//[1]
							Aadd(aOpcao, aUFUTC[1] )	//[2]
							If aUFUTC[2] <> 'ERR404'
								Aadd(aOpcao, aUFUTC[2] )//[3]
							EndIf

							//o valor do MV_NFCEUTC nao condiz com nenhuma op็ใo retornada
							nOpcao := Aviso('MV_NFCEUTC',;
											STR0039 + cUF + CRLF +;	//'O fuso horแrio cadastrado nใo estแ de acordo com o fuso horแrio do Estado ' 
											STR0040 + CRLF + ;	//'Por favor, escolha qual fuso horแrio deseja utilizar:'
											STR0041 + IIf(Len(aOpcao)==3, STR0042, '' ),;	//'ATUAL | NORMAL '###' | VERรO' 											
											aOpcao, 2)

							//atualiza MV_NFCEUTC com horario NORMAL[2] ou de VERAO[3](se existir)
							If nOpcao == 2 .OR. nOpcao == 3 
								aCols[nI][2] := aUFUTC[nOpcao-1]
							EndIf
						EndIf					

					Else
						lRet := .F.
						cMsgErro += cUF + STR0043	//" -  fuso horแrio nใo cadastrado para esse Estado."
						cMsgErro += CRLF
					EndIf
				EndIf
			EndIf
		
		Case aCols[nI][1] == "MV_CODREG"
			cAux := AllTrim(aCols[nI][2]) 
			
			If Empty(cAux)
				lRet := .F.
				cMsgErro += aCols[nI][1] + STR0044	//" - preencha com o CRT - C๓digo de Regime Tributแrio. Exemplo: 3"
				cMsgErro += CRLF
			ElseIf Len(cAux) <> 1
				lRet := .F.
				cMsgErro += aCols[nI][1] + STR0045	//" - tamanho invแlido. Deve possuir 1 caracteres. Exemplo: 3"
				cMsgErro += CRLF
			ElseIf !(cAux $ "1|2|3")
				lRet := .F.
				cMsgErro += aCols[nI][1] + STR0046	//" - preencha com uma das op็๕es: 1=Simples Nacional, 2=SN Excesso de Sublimite de Receita Bruta ou 3=Regime Nacional."
				cMsgErro += CRLF

			EndIf		
			
	END CASE

Next

If !lRet
	Aviso("TUDOOK", STR0047 + CRLF + cMsgErro, {"OK"}, 2) //"Antes de prosseguir, corrija a(s) inconsist๊ncia(s) abaixo: "
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RetUfUtc   บAutor    ณVendas Clientes    บ Data ณ  29/09/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o UTC de cada UF, sem e com horแrio de verใo.         บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetUFUTC(cUF)

Local nPos		:= 0		//Posi็ใo do array
Local aUFxUTC	:= {}		//Montagem da tabela em array
Local aRetUTC	:= {}		//Array de retorno

Default cUF			:= ""

//Sul
Aadd(aUFxUTC, {'RS', '-03:00', '-02:00'} )
Aadd(aUFxUTC, {'SC', '-03:00', '-02:00'} )
Aadd(aUFxUTC, {'PR', '-03:00', '-02:00'} )
//Sudeste
Aadd(aUFxUTC, {'SP', '-03:00', '-02:00'} )
Aadd(aUFxUTC, {'RJ', '-03:00', '-02:00'} )
Aadd(aUFxUTC, {'MG', '-03:00', '-02:00'} )
Aadd(aUFxUTC, {'ES', '-03:00', '-02:00'} )
//Centro Oeste
Aadd(aUFxUTC, {'GO', '-03:00', '-02:00'} )
Aadd(aUFxUTC, {'MT', '-04:00', '-03:00'} )
Aadd(aUFxUTC, {'MS', '-04:00', '-03:00'} )
Aadd(aUFxUTC, {'DF', '-03:00', '-02:00'} )
//Norte
Aadd(aUFxUTC, {'AM', '-04:00', 'ERR404'} )
Aadd(aUFxUTC, {'AP', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'AC', '-05:00', 'ERR404'} )
Aadd(aUFxUTC, {'PA', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'RO', '-04:00', 'ERR404'} )
Aadd(aUFxUTC, {'RR', '-04:00', 'ERR404'} )
Aadd(aUFxUTC, {'TO', '-03:00', '-02:00'} )
//Nordeste
Aadd(aUFxUTC, {'AL', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'BA', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'CE', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'MA', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'PB', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'PE', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'PI', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'RN', '-03:00', 'ERR404'} )
Aadd(aUFxUTC, {'SE', '-03:00', 'ERR404'} )

nPos := Ascan( aUFxUTC, {|x| x[1] == cUF} )
If nPos > 0
	aRetUTC := {aUFxUTC[nPos][2], aUFxUTC[nPos][3]}
EndIf

Return aRetUTC

//-------------------------------------------------------------------
/*/{Protheus.doc} LjUpdUrls
Fun็ใo para atualizar o arquivo ljnfceurls no PDV

@author  Eduardo Sales
@since   19/02/2019
@version P12
@return  Nil
/*/
//-------------------------------------------------------------------
Function LjUpdUrls()

Local lContinua := .F.
Local lPOS		:= Iif(ExistFunc("STFIsPOS"), STFIsPOS(), .F.)	// Indica se eh TOTVS PDV
Local cBuffer	:= ""
Local nHandle	:= 1
Local cPath		:= "\autocom\nfce\"								// Diretorio do Arquivo xml ljnfceurls
Local cFile		:= "ljnfceurls.xml"								// Arquivo xml que cont้m todas as URLs referente a NFC-e
Local lRet		:= .T.
Local aRet		:= {}

If MsgYesNo(STR0051)	// "Deseja atualizar o arquivo de Urls da NFC-e?"
	//Chama rotina(RPC) para carregar o arquivo na Retaguarda
	If !lPOS
		LJMsgRun(STR0052, , {|| aRet := FR271CMyCall("LJURLSXML", Nil, 0)})	// "Importanto Urls da NFC-e..."
	Else 
		lContinua := STBRemoteExecute(	"LJURLSXML"	,;
										{ 0 }		,;
										Nil			,;
										.F. 		,;
										@aRet	)

		If lContinua
			ConOut("Execu็ใo com sucesso - LJURLSXML")
		Else
			ConOut("Erro na execu็ใo - LJURLSXML")
		EndIf  
	EndIf

	If Len(aRet) > 0 .And. ValType(aRet[1]) == "C" .And. aRet[1] <> "ERRO"
		cBuffer := aRet[1]
	Else
		lRet := .F.
	EndIf

	If lRet
		// Cria o diret๓rio para o arquivo de XML caso nใo exista
		If !ExistDir(cPath)
			MakeDir(cPath)
		EndIf

		nHandle := FCreate(cPath + cFile)
		If nHandle > 0
			FWrite(nHandle, cBuffer)
			FClose(nHandle)

			MsgAlert(STR0053)	// "Arquivo contendo as Urls da NFC-e foi carregado com sucesso!"
		EndIf
	EndIf
EndIf

Return