#INCLUDE "PCOXPGLA.ch"
#include "protheus.ch"
#include "msgraphi.ch"
//-----------------------------------------------------------------------------------------------------------//
//FUNCOES POPULA OS PAINEIS DE GESTAO
//-----------------------------------------------------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOPG010  บAutor  ณPaulo Carnelossi    บ Data ณ  01/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPainel de Gestao Saldo Cubo Gerencial 1a. Dimensao          บฑฑ
ฑฑบ          ณBaseado na Consulta Cubos-Saldos na Data (PCOC330)          บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PCOPG010()

Local aInfo  := {}
Local cDescri := ""
Local lRet := .F.
Local cPerg := "PCR900"
Local cChvPes
Local cOpPerg  := GetMv("MV_PCOP010")

Private cCubo, cConfig, dSaldo
Private aPerg := {}

If  cOpPerg == "1" //Carrega Parametros Pergunte

	Pergunte(cPerg, .F.)
	lRet := .T.

ElseIf cOpPerg == "2" //Verifica Cadastro Parametros Pre-Configurados - 1a. Config.
	dbSelectArea("ALF")
	dbSetOrder(1)
	cChvPes := xFilial("ALF")+PadR("PCOPG010",Len(ALF->ALF_PRGREL)) 
								
	If dbSeek(cChvPes)
		aPerg := R540CargaPerg()
		If Len(aPerg) >  0
			aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
			lRet := .T.
		EndIf
    EndIf
    
ElseIf cOpPerg == "3" //Verica Cadastro Parametros Pre-Configurados com restricao
						//acesso por entidade do modulo SIGAPCO
	dbSelectArea("ALF")
	dbSetOrder(1)
	cChvPes := xFilial("ALF")+PadR("PCOPG010",Len(ALF->ALF_PRGREL)) 
								
	If dbSeek(cChvPes)
		While ALF->(! Eof() .And. ALF_FILIAL+ALF_PRGREL == cChvPes )
			
			If PcoDirEnt_User("ALF",ALF->(ALF_PRGREL+ALF_CFGREL), __cUserID, .T.) >= 1 //1-VISUALIZA
				aPerg := R540CargaPerg()
				If Len(aPerg) >  0
					aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
					lRet := .T.
				EndIf
				Exit
		    EndIf
		
			ALF->(dbSkip())
			
		EndDo
	Else
		lRet := .F.
    EndIf

EndIf


If lRet

	cCubo 		:= MV_PAR01
	cConfig 	:= MV_PAR02
	dSaldo 		:= MV_PAR03
	
	dbSelectArea("AL3")
	dbSetOrder(3)
	lRet := dbSeek(xFilial("AL3")+PadR(cCubo, Len(AKW->AKW_COD))+PadR(cConfig, Len(AL3->AL3_CODIGO)))
	dbSetOrder(1)

	dbSelectArea("AL1")
	dbSetOrder(1)
	If lRet
		lRet := dbSeek(xFilial("AL1")+PadR(cCubo, Len(AL1->AL1_CONFIG)))
	EndIf

	dbSelectArea("AKW")
	dbSetOrder(1)
	If lRet .And. dbSeek(xFilial("AKW")+PadR(cCubo, Len(AKW->AKW_COD)))
		cDescri := Alltrim(AKW->AKW_DESCRI)
		Pco_PopSaldo(aInfo, cDescri, cCubo, cConfig)
	EndIf
EndIf	

Return aInfo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPco_PopSaldo บAutor  ณPaulo Carnelossi  บ Data ณ 02/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao utilizada na rotina de processamento do cubo         บฑฑ
ฑฑบ          ณgerencial do pco a fim de popular array ainfo               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pco_PopSaldo(aInfo, cDescri, cCubo, cConfig)
Local lZerado := .F.
Local aNiveis	 := {}
Local nX, aProcessa := {}

aProcessa := PcoRunCube(cCubo, 1, "PCOSld010",cConfig, 2/*nao edita cfg*/,lZerado,aNiveis,/*aFilIni*/,/*aFilFim*/,NIL /*lRetOriCod*/,/*aAuxCube*/,/*lProcessa*/,.T./*lVerAcesso*/)

If Len(aProcessa) > 0

	Aadd( aInfo, { STR0001+"[ "+cDescri+" ]", STR0002,CLR_HBLUE,  } ) //"Descricao[ "###"Valor"

	For nX := 1 TO Len(aProcessa)
    
		If aProcessa[nX, 8] == 1   //somente primeiro nivel
			Aadd( aInfo, { Alltrim(aProcessa[nX, 1])+"-"+Alltrim(aProcessa[nX, 6]), Transform(aProcessa[nX, 2, 1],"@E 999,999,999,999.99") , If(aProcessa[nX, 2, 1]<0, CLR_RED, CLR_BLUE)  ,  } )
	    EndIf
    
	Next
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOSld010	บAutor  ณPaulo Carnelossi    บ Data ณ  02/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao utilizada na rotina de processamento do cubo         บฑฑ
ฑฑบ          ณgerencial do pco                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOSld010(cConfig,cChave)
Local aRetFim
Local nCrdFim
Local nDebFim
Local aRet := {}

aRetFim := PcoRetSld(cConfig,cChave,dSaldo)
nCrdFim := aRetFim[1, 1]
nDebFim := aRetFim[2, 1]

nSldFim := nCrdFim-nDebFim

aAdd(aRet, nSldFim)
	
Return aRet

//----------------------------------------------------------------------------------//
// TERMINO DO PAINEL DE GESTAO PCOPG010-SALDO DE CUBOS 1a.DIMENSAO (SALDO NA DATA)
//----------------------------------------------------------------------------------//



//-----------------------------------------------------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOPG020  บAutor  ณPaulo Carnelossi    บ Data ณ  13/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPainel de Gestao Saldo Cubo Gerencial 1a. Dimensao          บฑฑ
ฑฑบ          ณpara 2 configuracoes de cubo.                               บฑฑ
ฑฑบ          ณBaseado na Consulta Cubos-Saldos na Data (PCOC330)          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOPG020()
Local aInfo  := {}
Local cDescri := ""
Local lRet := .T.
Local cPerg := "PCR910"
Local cChvPes

Local cOpPerg  := GetMv("MV_PCOP020")

Private cCubo, cCfg1, cConfig1 := "", cCfg2, cConfig2 := "", dSaldo
Private aPerg := {}

//PARAMETROS
//01      ฆCubo Gerencial ?
//02      ฆConfig. 1 do Cubo Gerencial ?
//03      ฆConfig. 2 do Cubo Gerencial ?
//04      ฆSaldo em ?

If  cOpPerg == "1" //Carrega Parametros Pergunte

	Pergunte(cPerg, .F.)
	lRet := .T.

ElseIf cOpPerg == "2" //Verifica Cadastro Parametros Pre-Configurados - 1a. Config.
	dbSelectArea("ALF")
	dbSetOrder(1)
	cChvPes := xFilial("ALF")+PadR("PCOPG020",Len(ALF->ALF_PRGREL)) 
								
	If dbSeek(cChvPes)
		aPerg := R540CargaPerg()
		If Len(aPerg) >  0
			aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
			lRet := .T.
		EndIf
    EndIf
    
ElseIf cOpPerg == "3" //Verica Cadastro Parametros Pre-Configurados com restricao
						//acesso por entidade do modulo SIGAPCO
	dbSelectArea("ALF")
	dbSetOrder(1)
	cChvPes := xFilial("ALF")+PadR("PCOPG020",Len(ALF->ALF_PRGREL)) 
								
	If dbSeek(cChvPes)
		While ALF->(! Eof() .And. ALF_FILIAL+ALF_PRGREL == cChvPes )
			
			If PcoDirEnt_User("ALF",ALF->(ALF_PRGREL+ALF_CFGREL), __cUserID, .T.) >= 1 //1-VISUALIZA
				aPerg := R540CargaPerg()
				If Len(aPerg) >  0
					aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
					lRet := .T.
				EndIf
				Exit  //qdo entrar na 1a. entidade sai do loop
		    EndIf
		
			ALF->(dbSkip())
			
		EndDo
	Else
		lRet := .F.
    EndIf

EndIf

If lRet

	cCubo		:= PadR(mv_par01, Len(AL1->AL1_CONFIG))
	cCfg1 		:= PadR(mv_par02, Len(AL3->AL3_CODIGO))
	cCfg2 		:= PadR(mv_par03, Len(AL3->AL3_CODIGO))
	dSaldo 		:= mv_par04

	dbSelectArea("AL3")
	dbSetOrder(3)
	lRet := dbSeek(xFilial("AL3")+cCubo+cCfg1)
	
	If lRet
	
		cConfig1 := PadR(AL3->AL3_DESCRI, 30)
		
		lRet := dbSeek(xFilial("AL3")+cCubo+cCfg2)
		If lRet
			cConfig2 := PadR(AL3->AL3_DESCRI, 30)
		EndIf	
		
	EndIf
	
	dbSetOrder(1)
	
	dbSelectArea("AL1")
	dbSetOrder(1)
	If lRet
		lRet := dbSeek(xFilial("AL1")+cCubo)
	EndIf
	
	dbSelectArea("AKW")
	dbSetOrder(1)
	If lRet .And. dbSeek(xFilial("AKW")+cCubo)
		cDescri := Alltrim(AKW->AKW_DESCRI)
		Pco_PopSld(aInfo, cDescri, cConfig1, cConfig2)
	EndIf

EndIf
		
Return aInfo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPco_PopSld   บAutor  ณPaulo Carnelossi  บ Data ณ 02/01/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao utilizada na rotina de processamento do cubo         บฑฑ
ฑฑบ          ณgerencial do pco a fim de popular array ainfo               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pco_PopSld(aInfo, cDescri, cConfig1, cConfig2)
Local lZerado 	:= .F.
Local aNiveis	:= {}
Local nX
Local aProcessa := {}
Local aProcComp := {}
Local aInfo_01 	:= {}
Local aInfo_02 	:= {}

aProcessa := PcoRunCube(cCubo, 1, "PCOSld020",cCfg1, 2/*nao edita cfg*/,lZerado,aNiveis,/*aFilIni*/,/*aFilFim*/,NIL /*lRetOriCod*/,/*aAuxCube*/,/*lProcessa*/,.T./*lVerAcesso*/)

aProcComp := PcoRunCube(cCubo, 1, "PCOSld020",cCfg2, 2/*nao edita cfg*/,lZerado,aNiveis,/*aFilIni*/,/*aFilFim*/,NIL /*lRetOriCod*/,/*aAuxCube*/,/*lProcessa*/,.T./*lVerAcesso*/)

If Len(aProcessa) > 0

	Aadd( aInfo_01, { STR0001+"[ "+cDescri+" ]", STR0002,CLR_HBLUE,  } )  //"Descricao[ "##"Valor"

	For nX := 1 TO Len(aProcessa)
    
		If aProcessa[nX, 8] == 1   //somente primeiro nivel
			Aadd( aInfo_01, { Alltrim(aProcessa[nX, 1])+"-"+Alltrim(aProcessa[nX, 6]), Transform(aProcessa[nX, 2, 1],"@E 999,999,999,999.99") , If(aProcessa[nX, 2, 1]<0, CLR_RED, CLR_BLUE)  ,  } )
	    EndIf
    
	Next
	
EndIf

If Len(aProcComp) > 0

	Aadd( aInfo_02, { STR0001+"[ "+cDescri+" ]", STR0002,CLR_HBLUE,  } ) //"Descricao[ "##"Valor"

	For nX := 1 TO Len(aProcComp)
    
		If aProcComp[nX, 8] == 1   //somente primeiro nivel
			Aadd( aInfo_02, { Alltrim(aProcComp[nX, 1])+"-"+Alltrim(aProcComp[nX, 6]), Transform(aProcComp[nX, 2, 1],"@E 999,999,999,999.99") , If(aProcComp[nX, 2, 1]<0, CLR_RED, CLR_BLUE)  ,  } )
	    EndIf
    
	Next

EndIf

If Len(aInfo_01) > 0
	aAdd(aInfo, { cConfig1, aClone(aInfo_01) })
EndIf	

If Len(aInfo_02) > 0
	aAdd(aInfo, { cConfig2, aClone(aInfo_02) })
EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOSld020	บAutor  ณPaulo Carnelossi    บ Data ณ  02/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao utilizada na rotina de processamento do cubo         บฑฑ
ฑฑบ          ณgerencial do pco                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOSld020(cConfig,cChave)
Local aRetFim
Local nCrdFim
Local nDebFim
Local aRet := {}

aRetFim := PcoRetSld(cConfig,cChave,dSaldo)
nCrdFim := aRetFim[1, 1]
nDebFim := aRetFim[2, 1]

nSldFim := nCrdFim-nDebFim

aAdd(aRet, nSldFim)
	
Return aRet

//----------------------------------------------------------------------------------//
// TERMINO PAINEL GESTAO PCOPG020-SALDO DE CUBOS 1a.DIMENSAO(SALDO NA DATA)P/ 2 SERIES
//----------------------------------------------------------------------------------//

//-----------------------------------------------------------------------------------------------------------//
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOPG030  บAutor  ณPaulo Carnelossi    บ Data ณ  01/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPainel de Gestao informando qtde de planilhas em revisao    บฑฑ
ฑฑบ          ณe informando quais sao                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOPG030()

Local aInfo  := {}
Local nQtdRev := 0
Local cAliasQry	:= GetNextAlias()
Local cAliasAK1	:= GetNextAlias()

BeginSql Alias cAliasQry

	SELECT
		COUNT(*) CONTADOR
	FROM 
		%table:AK1% AK1
	WHERE
		AK1.AK1_FILIAL = %xfilial:AK1%
		AND AK1.AK1_STATUS = '2'
		AND AK1.%notDel%

EndSql

nQtdRev := (cAliasQry)->CONTADOR

Aadd( aInfo, { STR0004, Str(nQtdRev, 3), CLR_HRED,  } )  //"Planilhas em Revisใo"

BeginSql Alias cAliasAK1

	SELECT
		AK1_DESCRI
	FROM 
		%table:AK1% AK1
	WHERE
		AK1.AK1_FILIAL = %xfilial:AK1%
		AND AK1.AK1_STATUS = '2'
		AND AK1.%notDel%

EndSql

dbSelectArea(cAliasAK1)

While ! Eof()
	Aadd( aInfo, { Alltrim(AK1->AK1_DESCRI), Str(1, 3), CLR_HBLUE,  } )
	(cAliasAK1)->(dbSkip())
EndDo

If Empty(aInfo)
	Aadd( aInfo, { STR0003, Str(0, 3), CLR_HRED,  } )  //"Nao Existem Planilhas em Revisใo"
EndIf

(cAliasQry)->(dbCloseArea())
(cAliasAK1)->(dbCloseArea())

Return(aInfo)

//----------------------------------------------------------------------------------//
// TERMINO DO PAINEL DE GESTAO PCOPG030-PLANILHAS EM REVISAO
//----------------------------------------------------------------------------------//


//-----------------------------------------------------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOPG040  บAutor  ณPaulo Carnelossi    บ Data ณ  14/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPainel de Gestao Qtde. Bloqueios por tipo de bloqueio       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOPG040()

Local aInfo  := {}
Local cAliasQry	:= GetNextAlias()

BeginSql Alias cAliasQry

	SELECT
		AKJ_COD, AKJ_DESCRI, AKJ_QTDBLQ
	FROM 
		%table:AKJ% AKJ
	WHERE
		AKJ.AKJ_FILIAL = %xfilial:AKJ%
		AND AKJ.%notDel%
	ORDER BY AKJ_COD

EndSql

While (cAliasQry)->(! Eof())

	Aadd( aInfo, { (cAliasQry)->AKJ_COD+"-"+Alltrim((cAliasQry)->AKJ_DESCRI), Str((cAliasQry)->AKJ_QTDBLQ, 4), CLR_HRED,  } )
	(cAliasQry)->(dbSkip())

EndDo  

(cAliasQry)->(dbCloseArea())

Return(aInfo)

//----------------------------------------------------------------------------------//
// TERMINO DO PAINEL DE GESTAO PCOPG040-QTDE BLOQUEIOS POR TIPO 
//----------------------------------------------------------------------------------//

//----------------------------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOPG050  บAutor  ณPaulo Carnelossi    บ Data ณ  22/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPainel de Gestao Saldo/Projecoes para Cubo Gerencial        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOPG050()
Local lRet := .T.
Local aRetPanel := {}

Local aProcessa, aProcComp
Local nX, nZ

Local aNiveis	:= {}

Local nTpPer	:= 3   // fixar mensal 
Local lZerado 	:= .F.
Local nTotal, nTotalCfg1, nTotalCfg2    
Local cPerg 	:= "PCR920"
Local cOpPerg  := GetMv("MV_PCOP050")

Private aPrcSldIni 	:= {}
Private nProcCubo 	:= 1
Private aPeriodo
Private nPeriodo 	:= Month(dDataBase)

Private dIni 		:= CTOD("01/01/"+Right(StrZero(Year(dDataBase),4),2))
Private dFim 		:= CTOD("31/12/"+Right(StrZero(Year(dDataBase),4),2))
Private dRef 		:= dDataBase
Private cCubo, cCfg1, cCfg2, nCenario, cConfig1, cConfig2
Private aView

Private aPerg := {}

If  cOpPerg == "1" //Carrega Parametros Pergunte

	Pergunte(cPerg, .F.)
	lRet := .T.

ElseIf cOpPerg == "2" //Verifica Cadastro Parametros Pre-Configurados - 1a. Config.
	dbSelectArea("ALF")
	dbSetOrder(1)
	cChvPes := xFilial("ALF")+PadR("PCOPG050",Len(ALF->ALF_PRGREL)) 
								
	If dbSeek(cChvPes)
		aPerg := R540CargaPerg()
		If Len(aPerg) >  0
			aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
			lRet := .T.
		EndIf
    EndIf
    
ElseIf cOpPerg == "3" //Verica Cadastro Parametros Pre-Configurados com restricao
						//acesso por entidade do modulo SIGAPCO
	dbSelectArea("ALF")
	dbSetOrder(1)
	cChvPes := xFilial("ALF")+PadR("PCOPG050",Len(ALF->ALF_PRGREL)) 
								
	If dbSeek(cChvPes)
		While ALF->(! Eof() .And. ALF_FILIAL+ALF_PRGREL == cChvPes )
			
			If PcoDirEnt_User("ALF",ALF->(ALF_PRGREL+ALF_CFGREL), __cUserID, .T.) >= 1 //1-VISUALIZA
				aPerg := R540CargaPerg()
				If Len(aPerg) >  0
					aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
					lRet := .T.
				EndIf
				Exit
		    EndIf
		
			ALF->(dbSkip())
			
		EndDo
	Else
		lRet := .F.
    EndIf

EndIf

cCubo 	:= mv_par01
dIni 	:= mv_par02
dFim 	:= mv_par03
dRef 	:= mv_par04
cCfg1 	:= mv_par05
cCfg2 	:= mv_par06
nCenario := mv_par07

If Empty(dIni)
	dIni 		:= CTOD("01/01/"+Right(StrZero(Year(dDataBase),4),2))
EndIf

If Empty(dFim)
	dFim 		:= CTOD("31/12/"+Right(StrZero(Year(dDataBase),4),2))
EndIf

If Empty(dRef)
	dRef 		:= dDataBase
EndIf

aPeriodo 	:= PcoRetPer(dIni/*dIniPer*/, dFim/*dFimPer*/, Str(nTpPer,1)/*cTipoPer*/, .F./*lAcumul*/)

lRet := PG050_Refer(aPeriodo, dRef, @nPeriodo)

If ! lRet  //se nao encontrou periodo de referencia
	Aviso(STR0005, STR0006, {"Ok"}) //"Atencao", "Data de referencia deve pertencer ao periodo informado. Verifique!"
EndIf

dbSelectArea("AL3")
dbSetOrder(3)
lRet := dbSeek(xFilial("AL3")+cCubo+cCfg1)

If lRet

	cConfig1 := PadR(AL3->AL3_DESCRI, 30)
	
	lRet := dbSeek(xFilial("AL3")+cCubo+cCfg2)
	If lRet
		cConfig2 := PadR(AL3->AL3_DESCRI, 30)
	EndIf	
	
EndIf

dbSetOrder(1)

dbSelectArea("AL1")
dbSetOrder(1)
If lRet
	lRet := dbSeek(xFilial("AL1")+cCubo)
EndIf

If lRet
	// sao sempre 2 series - vamos considerar sempre saldo do periodo
	aAdd(aPrcSldIni, 2)  //1=Saldo Acumulado 2=Saldo do Periodo
	aAdd(aPrcSldIni, 2)

	nTotal := 0
	nTotalCfg1 := 0
	nTotalCfg2 := 0
	
	//processa primeira configuracao do cubo sempre
	aProcessa := PcoRunCube(cCubo, Len(aPeriodo), "PCOSld050",cCfg1, 2/*nao edita cfg*/,lZerado,aNiveis,/*aFilIni*/,/*aFilFim*/,NIL /*lRetOriCod*/,/*aAuxCube*/,/*lProcessa*/,.T./*lVerAcesso*/)

   	If Len(aProcessa) > 0
 		For nX := 1 TO Len(aProcessa)
 			For nZ := 1 TO Len(aProcessa[nX, 2])
 				nTotalCfg1 += aProcessa[nX, 2, nZ]
 			Next
 		Next	
	   	//processa a  segunda configuracao
	   	nProcCubo := 2
		aProcComp := PcoRunCube(cCubo, Len(aPeriodo), "PCOSld050",cCfg2, 2/*nao edita cfg*/,lZerado,aNiveis,/*aFilIni*/,/*aFilFim*/,NIL /*lRetOriCod*/,/*aAuxCube*/,/*lProcessa*/,.T./*lVerAcesso*/)
 		For nX := 1 TO Len(aProcComp)
 			For nZ := 1 TO Len(aProcComp[nX, 2])
 				nTotalCfg2 += aProcComp[nX, 2, nZ]
 			Next
 		Next
 		nTotal := nTotalCfg1+nTotalCfg2
 		nTotalCfg1 := nTotalCfg1/nTotal*100
 		nTotalCfg2 := nTotalCfg2/nTotal*100
	Else
		Aviso(STR0005,STR0007,{"Ok"},2)  //	"Atencao"###"Nใo existem valores a serem visualizados na configura็ใo selecionada. Verifique as configura็๕es da consulta."
		lRet := .F.
	EndIf
	
	If lRet

		//chama a funcao que alimentara array para o painel
		aView := PG050_View(aProcessa, aProcComp)

		aHeader := {}
		aAdd(aHeader, STR0008) //"Codigo"
		aAdd(aHeader, STR0001)  //"Descricao"
		For nX := 1 TO Len(aPeriodo)
			aAdd(aHeader, aPeriodo[nX])
		Next	
		
        aTabela := {}
        aAdd(aTabela, { cConfig1, aClone(aHeader), aClone(aView[1]) } )
        aAdd(aTabela, { cConfig2, aClone(aHeader), aClone(aView[2]) } )
        
		aRetPanel := { GRP_PIE,;
						{ STR0009,{ || .T./*MsgStop("Mensagem Grafico")*/ },{cConfig1,cConfig2},{nTotalCfg1,nTotalCfg2}},;  //"Saldo/Projecoes por Periodo"
						 {STR0010,{ |x| .T./*MsgStop("Mensagem Tabela - " + x[1] )*/ }, aTabela }}  //"Saldos"
	EndIf
	
EndIf

Return(aRetPanel)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPG050_ViewบAutor  ณPaulo Carnelossi    บ Data ณ  22/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPainel de Gestao Saldo/Projecoes para Cubo Gerencial        บฑฑ
ฑฑบ          ณpopular array que serao exibidos                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PG050_View(aProcessa, aProcComp)
Local nx, nz, nPos
Local aView := {{},{}} 
Local aAuxView
Local nDivisor	:=	1
Local nTotCfg1, nTotCfg2, nCoefic
Local aGraf := {}
Local cPicture	:=	"@E 999,999,999,999.99"

For nx := 1 to Len(aProcessa)

	nPos := ASCAN(aProcComp, {|aVal| aVal[1] == aProcessa[nX][1]})
	
	aAuxView := {{},{}}
	aGraf := {}
	aAdd(aAuxView[1], aProcessa[nx][1] )   //codigo
	aAdd(aAuxView[1], aProcessa[nx][6] )   //descricao
    
	If nPos > 0
		aAdd(aAuxView[2], aProcComp[nPos][1] )   //codigo
		aAdd(aAuxView[2], aProcComp[nPos][6] )   //descricao
	Else
		aAdd(aAuxView[2], aProcessa[nx][1] )   //codigo
		aAdd(aAuxView[2], aProcessa[nx][6] )   //descricao
	EndIf
	
	If nCenario == 1  //Nenhum
		For nZ := 1 TO Len(aProcessa[nx][2])
			aAdd(aAuxView[1], TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView[2], TransForm(aProcComp[nPos][2][nZ]/nDivisor,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aProcComp[nPos][2][nZ]/nDivisor) 
			Else	
				aAdd(aAuxView[2], TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
		Next

	ElseIf nCenario == 2 //"2=Manter Tendencia"

		nTotCfg1 := 0
		nTotCfg2 := 0
		For nZ := 1 TO nPeriodo
			aAdd(aAuxView[1], TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView[2], TransForm(aProcComp[nPos][2][nZ]/nDivisor,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aProcComp[nPos][2][nZ]/nDivisor) 
			Else	
				aAdd(aAuxView[2], TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
	        nTotCfg1 += aGraf[Len(aGraf)-1]
	        nTotCfg2 += aGraf[Len(aGraf)]
		Next
		
		nCoefic := nTotCfg2 / nTotCfg1
		
		For nZ := nPeriodo+1 TO Len(aProcessa[nx][2])
			aAdd(aAuxView[1], TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView[2], TransForm(aGraf[Len(aGraf)]/nDivisor*nCoefic,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aGraf[Len(aGraf)]/nDivisor*nCoefic) 
			Else	
				aAdd(aAuxView[2], TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
		Next

	ElseIf nCenario == 3 //"3=Recuperar Orcamento ate o fim"
	
		nTotCfg1 := 0
		nTotCfg2 := 0
		For nZ := 1 TO nPeriodo
			aAdd(aAuxView[1], TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView[2], TransForm(aProcComp[nPos][2][nZ]/nDivisor,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aProcComp[nPos][2][nZ]/nDivisor) 
			Else	
				aAdd(aAuxView[2], TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
	        nTotCfg1 += aGraf[Len(aGraf)-1]
	        nTotCfg2 += aGraf[Len(aGraf)]
		Next
		
		nCoefic := nTotCfg2 - nTotCfg1
		//zera ntotcfg1 e acumula para saber total previsto restante
		nTotCfg1 := 0
		For nZ := nPeriodo+1 TO Len(aProcessa[nx][2])
   	        nTotCfg1 += aProcessa[nx][2][nZ]/nDivisor
		Next
		//agora projeta os periodos restantes recuperando o orcamento a partir dt.ref.
		For nZ := nPeriodo+1 TO Len(aProcessa[nx][2])
			//previsto 
			aAdd(aAuxView[1], TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			//projetado recupera orcto
			aAdd(aAuxView[2], TransForm(aProcessa[nx][2][nZ] - (nCoefic/nTotCfg1*aProcessa[nx][2][nZ])/nDivisor,cPicture))  
			aAdd(aGraf, aProcessa[nx][2][nZ] - (nCoefic/nTotCfg1*aProcessa[nx][2][nZ])/nDivisor) 
		Next

	ElseIf nCenario == 4 //"4=Ajustar ao Orcamento a Partir da Referencia"

		For nZ := 1 TO nPeriodo
			aAdd(aAuxView[1], TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
	        If nPos > 0 
				aAdd(aAuxView[2], TransForm(aProcComp[nPos][2][nZ]/nDivisor,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, aProcComp[nPos][2][nZ]/nDivisor) 
			Else	
				aAdd(aAuxView[2], TransForm(0,cPicture))  //Config.2 -  aProcComp
				aAdd(aGraf, 0) 
	        EndIf
		Next
		
		For nZ := nPeriodo+1 TO Len(aProcessa[nx][2])
		
			aAdd(aAuxView[1], TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
            //nesta projecao repete os valores previsto para se adequar ao orcamento 
			aAdd(aAuxView[2], TransForm(aProcessa[nx][2][nZ]/nDivisor,cPicture))  //Config.1 -  aProcessa
			aAdd(aGraf, aProcessa[nx][2][nZ]/nDivisor) 
			
		Next

	EndIf
	
	aAdd(aView[1], aAuxView[1])
	aAdd(aView[2], aAuxView[2])

Next

Return(aView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOSld050 บAutor  ณPaulo Carnelossi    บ Data ณ  22/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPainel de Gestao Saldo/Projecoes para Cubo Gerencial        บฑฑ
ฑฑบ          ณpopular array aprocessa  (PCORUNCUBE)                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOSld050(cConfig,cChave)
Local aRetorno := {}
Local aRetFim
Local nCrdFim
Local nDebFim
Local ny
Local lSaldoIni := .T.

For ny := 1 to Len(aPeriodo)

	nSldIni := 0
	
	If aPrcSldIni[nProcCubo] == 2

		If lSaldoIni
	
			nSldIni := 0
		    // PROCESSA CUBO SALDO INICIAL 
			dIni := CtoD(Subs(aPeriodo[ny], 1, 8))-1
	
			aRetIni := PcoRetSld(cConfig,cChave,dIni)
			nCrdIni := aRetIni[1, 1]
			nDebIni := aRetIni[2, 1]
	
			nSldIni := nCrdIni-nDebIni
			lSaldoIni := .F.
	
		Else
	
			nSldIni := nSldFim
	
		EndIf
		
    EndIf
    
    // PROCESSA CUBO SALDO FINAL
	dFim := CtoD(Subs(aPeriodo[ny],14))

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, 1]
	nDebFim := aRetFim[2, 1]

	nSldFim := nCrdFim-nDebFim

	//retorna saldo final - saldo inicial
	aAdd(aRetorno,nSldFim-nSldIni)
	
Next

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPG050_Refer บAutor  ณPaulo Carnelossi  บ Data ณ  22/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPainel de Gestao Saldo/Projecoes para Cubo Gerencial        บฑฑ
ฑฑบ          ณVerifica se data referencia esta dentro do periodo          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PG050_Refer(aPeriodo, dDatRef, nPeriodo)
Local nX, dDatIni, dDatFim, lRet := .F.

nPeriodo := 0

For nX := 1 TO Len(aPeriodo)

	dDatIni := CtoD(Subs(aPeriodo[nX], 1, 8))
	dDatFim := CtoD(Subs(aPeriodo[nX],14))
	
	If dDatRef >= dDatIni .And. dDatRef <= dDatFim
		lRet := .T.
	    nPeriodo := nX
	    Exit
	EndIf    

Next

Return(lRet)

//----------------------------------------------------------------------------------//
// TERMINO DO PAINEL DE GESTAO PCOPG050-SALDOS/PROJECOES POR PERIODO PARA CUBOS GER.
//----------------------------------------------------------------------------------//


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOPG060  บAutor  ณPaulo Carnelossi    บ Data ณ  27/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrucao Painel de Gestao Saldos Cubos Gerenciais         บฑฑ
ฑฑบ          ณMes ano atual x Mes Ano Anterior                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOPG060()

Local aInfo  := {}
Local cDescri := ""
Local lRet := .F.
Local cPerg := "PCR930"
Local cChvPes
Local cOpPerg  := GetMv("MV_PCOP060")
Local cAnoAnterior

Private cCubo, cConfig, dSaldo
Private aPerg := {}
Private aDtSaldo := {}, aDtAnterior := {}

If  cOpPerg == "1" //Carrega Parametros Pergunte

	Pergunte(cPerg, .F.)
	lRet := .T.

ElseIf cOpPerg == "2" //Verifica Cadastro Parametros Pre-Configurados - 1a. Config.
	dbSelectArea("ALF")
	dbSetOrder(1)
	cChvPes := xFilial("ALF")+PadR("PCOPG060",Len(ALF->ALF_PRGREL)) 
								
	If dbSeek(cChvPes)
		aPerg := R540CargaPerg()
		If Len(aPerg) >  0
			aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
			lRet := .T.
		EndIf
    EndIf
    
ElseIf cOpPerg == "3" //Verica Cadastro Parametros Pre-Configurados com restricao
						//acesso por entidade do modulo SIGAPCO
	dbSelectArea("ALF")
	dbSetOrder(1)
	cChvPes := xFilial("ALF")+PadR("PCOPG060",Len(ALF->ALF_PRGREL)) 
								
	If dbSeek(cChvPes)
		While ALF->(! Eof() .And. ALF_FILIAL+ALF_PRGREL == cChvPes )
			
			If PcoDirEnt_User("ALF",ALF->(ALF_PRGREL+ALF_CFGREL), __cUserID, .T.) >= 1 //1-VISUALIZA
				aPerg := R540CargaPerg()
				If Len(aPerg) >  0
					aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
					lRet := .T.
				EndIf
				Exit
		    EndIf
		
			ALF->(dbSkip())
			
		EndDo
	Else
		lRet := .F.
    EndIf

EndIf


If lRet

	cCubo 		:= MV_PAR01
	cConfig 	:= MV_PAR02
	dSaldo	 	:= LastDay(CTOD("01/"+Left(MV_PAR03,2)+"/"+Right(MV_PAR03,2)))

	If MV_PAR04 == 1
		aAdd(aDtSaldo, CTOD("01/01/"+Right(MV_PAR03,2)))
		aAdd(aDtSaldo, dSaldo)

		cAnoAnterior := Right(StrZero(Val(Right(MV_PAR03,4))-1,4),2)
		aAdd(aDtAnterior,CTOD("01/01/"+cAnoAnterior))
		aAdd(aDtAnterior,LastDay(CTOD("01/"+Left(MV_PAR03,2)+"/"+cAnoAnterior)))
	Else
		aAdd(aDtSaldo, FirstDay(dSaldo))
		aAdd(aDtSaldo, dSaldo)

		cAnoAnterior := Right(StrZero(Val(Right(MV_PAR03,4))-1,4),2)
		aAdd(aDtAnterior,FirstDay(CTOD("01/"+Left(MV_PAR03,2)+"/"+cAnoAnterior)))
		aAdd(aDtAnterior,LastDay(CTOD("01/"+Left(MV_PAR03,2)+"/"+cAnoAnterior)))
	EndIf	
	
	dbSelectArea("AL3")
	dbSetOrder(3)
	lRet := dbSeek(xFilial("AL3")+PadR(cCubo, Len(AKW->AKW_COD))+PadR(cConfig, Len(AL3->AL3_CODIGO)))
	dbSetOrder(1)

	dbSelectArea("AL1")
	dbSetOrder(1)
	If lRet
		lRet := dbSeek(xFilial("AL1")+PadR(cCubo, Len(AL1->AL1_CONFIG)))
	EndIf

	dbSelectArea("AKW")
	dbSetOrder(1)
	If lRet .And. dbSeek(xFilial("AKW")+PadR(cCubo, Len(AKW->AKW_COD)))
		cDescri := Alltrim(AKW->AKW_DESCRI)
		Pco_PopPG060(aInfo, cDescri, cCubo, cConfig)
	EndIf
EndIf	

Return aInfo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPco_PopPG060 บAutor  ณPaulo Carnelossi  บ Data ณ 26/02/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao utilizada na rotina de processamento do cubo         บฑฑ
ฑฑบ          ณgerencial do pco a fim de popular array apainel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pco_PopPG060(aPainel, cDescri, cCubo, cConfig)
Local lZerado := .F.
Local aNiveis	 := {}
Local nX, aProcessa := {}
Local aInfo

aInfo := {}
aProcessa := PcoRunCube(cCubo, 1, "PCOSld060",cConfig, 2/*nao edita cfg*/,lZerado,aNiveis,/*aFilIni*/,/*aFilFim*/,NIL /*lRetOriCod*/,/*aAuxCube*/,/*lProcessa*/,.T./*lVerAcesso*/)

If Len(aProcessa) > 0

	Aadd( aInfo, { STR0001+"[ "+cDescri+" ]", STR0002,CLR_HBLUE,  } ) //"Descricao[ "###"Valor"

	For nX := 1 TO Len(aProcessa)
    
		If aProcessa[nX, 8] == 1   //somente primeiro nivel
			Aadd( aInfo, { Alltrim(aProcessa[nX, 1])+"-"+Alltrim(aProcessa[nX, 6]), Transform(aProcessa[nX, 2, 1],"@E 999,999,999,999.99") , If(aProcessa[nX, 2, 1]<0, CLR_RED, CLR_BLUE)  ,  } )
	    EndIf
    
	Next
	
EndIf

If Len(aInfo) > 0
	aAdd(aPainel, { STR0011, aClone(aInfo) })  //"Saldo Ano Atual"
EndIf	

//ano anterior
aInfo := {}
aDtSaldo := aClone(aDtAnterior)

aProcessa := PcoRunCube(cCubo, 1, "PCOSld060",cConfig, 2/*nao edita cfg*/,lZerado,aNiveis,/*aFilIni*/,/*aFilFim*/,NIL /*lRetOriCod*/,/*aAuxCube*/,/*lProcessa*/,.T./*lVerAcesso*/)

If Len(aProcessa) > 0

	Aadd( aInfo, { STR0001+"[ "+cDescri+" ]", STR0002,CLR_HBLUE,  } ) //"Descricao[ "###"Valor"

	For nX := 1 TO Len(aProcessa)
    
		If aProcessa[nX, 8] == 1   //somente primeiro nivel
			Aadd( aInfo, { Alltrim(aProcessa[nX, 1])+"-"+Alltrim(aProcessa[nX, 6]), Transform(aProcessa[nX, 2, 1],"@E 999,999,999,999.99") , If(aProcessa[nX, 2, 1]<0, CLR_RED, CLR_BLUE)  ,  } )
	    EndIf
    
	Next
	
EndIf

If Len(aInfo) > 0
	aAdd(aPainel, { STR0012, aClone(aInfo) })  // "Saldo Ano Anterior"
EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOSld060	บAutor  ณPaulo Carnelossi    บ Data ณ  26/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao utilizada na rotina de processamento do cubo         บฑฑ
ฑฑบ          ณgerencial do pco                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOSld060(cConfig,cChave)
Local aRetFim, aRetIni, nSldIni, nSldFim
Local nCrdFim
Local nDebFim
Local aRet := {}

aRetIni := PcoRetSld(cConfig,cChave,aDtSaldo[1])
nCrdIni := aRetIni[1, 1]
nDebIni := aRetIni[2, 1]
nSldIni := nCrdIni-nDebIni

aRetFim := PcoRetSld(cConfig,cChave,aDtSaldo[2])
nCrdFim := aRetFim[1, 1]
nDebFim := aRetFim[2, 1]
nSldFim := nCrdFim-nDebFim

aAdd(aRet, nSldFim-nSldIni)
	
Return aRet

//----------------------------------------------------------------------------------//
// TERMINO DO PAINEL DE GESTAO PCOPG060-SALDO DE CUBOS 1a.DIMENSAO (SALDO NO MES ANO ATUAL/SALDO NO MES ANO ANTERIOR)
//----------------------------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPcoHelpPainelบAutor  ณPaulo Carnelossi   บ Data ณ 27/03/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณHelp resumido dos paineis de gestao do modulo PCO           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoHelpPainel(cProgPainel)
Local cRetHelp := ""

If 		cProgPainel == "PCOPG010"
	cRethelp += STR0013+CRLF //"Este painel exibe o saldo na data para o cubo gerencial"+CRLF
	cRethelp += STR0014+CRLF //"e configuracao do mesmo informado nos parametros."+CRLF
	cRethelp += STR0015+CRLF //"Observe que somente serao exibidos saldos para a "+CRLF
	cRethelp += STR0016+CRLF //"1a. dimensao do cubo gerencial."+CRLF

ElseIf 	cProgPainel == "PCOPG020"
	cRethelp += STR0017+CRLF //"Este painel exibe o saldo na data para o cubo gerencial"+CRLF
	cRethelp += STR0018+CRLF //"e 2 (duas) configuracoes que sao informados nos "+CRLF
	cRethelp += STR0019+CRLF //"parametros do painel, como por exemplo a configuracao"+CRLF
	cRethelp += STR0020+CRLF //"PR-PREVISTO e a configuracao RE-REAL."+CRLF
	cRethelp += STR0021+CRLF //"Observe que somente serao exibidos saldos para a "+CRLF
	cRethelp += STR0022+CRLF //"1a. dimensao do cubo gerencial."+CRLF

ElseIf 	cProgPainel == "PCOPG030"
	cRethelp += STR0023+CRLF //"Este painel informa a quantidade de planilhas orcamentarias"+CRLF
	cRethelp += STR0024+CRLF //"em processo de revisao e lista suas respectivas descricoes."+CRLF

ElseIf 	cProgPainel == "PCOPG040"
	cRethelp += STR0025+CRLF //"O painel exibe uma listagem com os tipos de bloqueios "+CRLF
	cRethelp += STR0026+CRLF //"existentes e a quantidade total de bloqueios efetuados."+CRLF

ElseIf 	cProgPainel == "PCOPG050"
	cRethelp += STR0027+CRLF //"Este painel fornece uma projecao dos saldos no periodo a"+CRLF
	cRethelp += STR0028+CRLF //"partir do mes seguinte a data referencia para o cubo "+CRLF
	cRethelp += STR0029+CRLF //"gerencial e 2 (duas) configuracoes conforme o cenario "+CRLF
	cRethelp += STR0030+CRLF //"informado nos parametros, conforme segue abaixo:"+CRLF
	cRethelp += STR0031+CRLF //"1=Nenhum : Neste caso somente lista o saldo das configuracoes"+CRLF
	cRethelp += STR0032+CRLF //"           (projecao inexistente)."+CRLF
	cRethelp += STR0033+CRLF //"2=Manter Tendencia : Nesta opcao a projecao para os meses seguintes"+CRLF
	cRethelp += STR0034+CRLF //"           a data de referencia para a 2a. (segunda) configuracao "+CRLF
	cRethelp += STR0035+CRLF //"           sera a aplicacao do indice de variacao ate a data de "+CRLF
	cRethelp += STR0036+CRLF //"           referencia ao valor obtido na 1a. (primeira) configuracao."+CRLF
	cRethelp += STR0037+CRLF //"3=Recuperar Orcamento Ate o Fim : Neste cenario a projecao para os "+CRLF
	cRethelp += STR0038+CRLF //"           meses seguintes a data de referencia para a 2a. (segunda)"+CRLF
	cRethelp += STR0039+CRLF //"           configuracao levara em conta as diferencas entre as duas "+CRLF
	cRethelp += STR0040+CRLF //"           configuracoes e proporcionalizara, subtraindo dos meses "+CRLF
	cRethelp += STR0041+CRLF //"           seguinte a referencia do valor obtido da 1a. (primeira) "+CRLF
	cRethelp += STR0042+CRLF //"           configuracao, o que resultara no final do exercicio o"+CRLF
	cRethelp += STR0043+CRLF //"           equilibrio entre a configuracao-1 e a configuracao-2."+CRLF
	cRethelp += STR0044+CRLF //"4=Ajustar ao Orcamento a partir da Referencia : Neste cenario os "+CRLF
	cRethelp += STR0045+CRLF //"           valores da 2a. (segunda) configuracao se igualarao aos "+CRLF
	cRethelp += STR0046+CRLF //"           da 1a.(primeira) configuracao a partir dos meses seguintes"+CRLF
	cRethelp += STR0047+CRLF //"           a data de referencia."+CRLF

ElseIf 	cProgPainel == "PCOPG060"
	cRethelp += STR0048+CRLF //"Este painel exibira o saldo na data para o cubo gerencial"+CRLF
	cRethelp += STR0049+CRLF //"e configuracao do cubo informado nos parametros, assim como"+CRLF
	cRethelp += STR0050+CRLF //"tambem o saldo do ano anterior fornecendo um comparativo entre"+CRLF
	cRethelp += STR0051+CRLF //"a data informada e do ano anterior."+CRLF

Else
	cRethelp += STR0052+CRLF //"Este painel exibe as informacoes conforme os parametros"+CRLF
	cRethelp += STR0053+CRLF //"informados."+CRLF

EndIf

Return(cRetHelp)
