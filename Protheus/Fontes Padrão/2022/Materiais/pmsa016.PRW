#include "pmsa016.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ PMSA016    บAutorณJoใo Gon็alves de Oliveira บ Data ณ 10/10/2008    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina de Cadastro de Insumos para Gestใo de Projetos               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PMSA016()                                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Nenhum                                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMS - Gestใo de Projetos / Template Constru็ใo Civil                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PMSA016()

Private lCopia    	:= .F.
Private lDuplic		:= .F.
PRIVATE cCadastro	:= STR0001 //"Insumos"
PRIVATE aRotina 	:= MenuDef()
PRIVATE aCores		:= PmsAF8Color()

// so executa se houver o template aplicadoc com licen็a, caso 
// contrario mostra uma mensagem de alerta e aborta
ChkTemplate("CCT")

If AMIIn(44) 
	mBrowse(6,1,22,75,"AJZ")
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ PMSA016Man บAutorณJoใo Gon็alves de Oliveira บ Data ณ 10/10/2008    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina para Inclusใo, Altera็ใo, Exclusใo ou C๓pia de Insumos       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PMSA016Man(cAlias,nReg,nOpc)                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ ExpC1 - Apelido do Arquivo                                          บฑฑ
ฑฑบ          ณ ExpN2 - N๚mero do registro a sofrer manuten็ใo                      บฑฑ
ฑฑบ          ณ ExpN3 - Op็ใo atualiza็ใo(3 - Inclusใo, 4- Altera็ใo, 5- Exclusใo)  บฑฑ
ฑฑบ          ณ       - conforme aRotina                                            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMS - Gestใo de Projetos / Template Constru็ใo Civil                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSA016Man(cAlias,nReg,nOpc,lImporta,lExporta)
Local aArea   	:= { Alias(), IndexOrd(), Recno() }
Local aButtons := {}
Local nContItem := 1
Local nContHead := 1
Local cCodiInsu := AJZ->AJZ_INSUMO
Local aRots 	:= AClone(aRotina)
Local lContinua	:= .T.
Local aBloco := {{||PMA016INS(AJZ->(Recno()))},{||.T.},{||.F.},{||.F.}}

Private aHeader := GetaHeader("AJY",,{"AJY_INSUMO"})
Private aColsAJY  := {}
Private aOpcoes  := {1,"",""}
Private nVariavel := 1             
Private cDesc := ""

Default lImporta := .F.
Default lExporta := .F.

AAdd(aButtons,{'PRODUTO',{|| aColsAJY := PMS16PrjIns(M->AJZ_INSUMO,M->AJZ_DESC,nOpc) },STR0008 }) //"Vincular"

Do Case
	Case nOpc == 2 //Visualizacao
		PMA016Inc("AJZ",nReg,nOpc,)

	Case nOpc == 3 //Inclusao
		PMA016Inc("AJZ",,nOpc,)

	Case nOpc == 4 //Alteracao 
		PMA016Inc("AJZ",nReg,nOpc,)

	Case nOpc == 5 //Exclusao
		// Verifica se o insumo podera ser excluido
		If Pma016VldExc( nReg )
			PMA016Inc("AJZ",nReg,nOpc,)
		EndIf

	Case nOpc == 6    // C๓pia
		INCLUI := .T.
		nOpca := 3
		cDesc := RTrim(AJZ_DESC)
			
		If !lImporta .And. !lExporta .And.; 
			ParamBox({;         
						{9,STR0028,Len(STR0028)*4,,},;			//Confirmar o codigo do insumo que sera duplicado:
						{1,STR0029,AJZ_INSUMO,PesqPict("AJZ","AJZ_INSUMO",),"PMA016Desc(AJZ_DESC) .And. ExistCpo('AJZ',MV_PAR02,1)","AJZ",/*When*/,80,.T.},;	//AJZ->AJZ_INSUMO - Codigo do Insumo
						{1,STR0030,AJZ_DESC,PesqPict("AJZ","AJZ_DESC",),/*VALID*/,/*F3*/,'.F.',80,.F.};
						},STR0023,,,,.T.,,,,,.F.,.F.)			
			
			If xFilial("AJZ") # AJZ->AJZ_FILIAL .Or. (AJZ->(EOF()) .and. AJZ->(BOF()))
				HELP(" ",1,"ARQVAZIO")
				lContinua := .F.
			Endif
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณEfetua c๓pia do insumo posicionado             ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lDuplic := .T.
			PMA016Inc("AJZ",AJZ->(Recno()),nOpcA,.T.)
			lDuplic := .F.
			
		ElseIf lImporta
			PMA016Iexp(lImporta,lExporta)
		ElseIf lExporta
			PMA016Iexp(lImporta,lExporta)
		EndIf			
EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ PMS16TudOk บAutorณJoใo Gon็alves de Oliveira บ Data ณ 10/10/2008    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Valida tela de grava็ใo de insumos                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PMS16TudOk()                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Nenhum                                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ ExpL1 - Valida se os dados estใo corretamente cadastrados           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMS - Gestใo de Projetos / Template Constru็ใo Civil                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS16TudOk()
Local lValiInsu := .T.

Return(lValiInsu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ PMSGerInsu บAutorณJoใo Gon็alves de Oliveira บ Data ณ 24/10/2008    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑณDescri็ใo ณ Executa regua de processamento para c๓pia de insumos entre projetos ณฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PMSGerInsu(cProjOrig,cProjDest)                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Nenhum                                                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMS - Gestใo de Projetos / Template Constru็ใo Civil                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Function PMSGerInsu(cProjOrig,cProjDest)
Private oProcess
// Executa o processamento dos arquivos
oProcess:=	MsNewProcess():New( {|lEnd| PMSProcIns(oProcess,cProjOrig,cProjDest) } )
oProcess:Activate()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ PMSProcIns บAutorณJoใo Gon็alves de Oliveira บ Data ณ 24/10/2008    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑณDescri็ใo ณ Replica insumos do projeto origem para o projeto destino            ณฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PMSProcIns(oProcess,cProjOrig,cProjDest)                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ ExpO1 - Objeto da R้gua de Processamento                            บฑฑ
ฑฑบ          ณ ExpC2 - Projeto Origem para r้plica                                 บฑฑ
ฑฑบ          ณ ExpC3 - Projeto Destino para r้plica                                บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMS - Gestใo de Projetos / Template Constru็ใo Civil                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PMSProcIns(oProcess,cProjOrig,cProjDest)

Local cQuery := ""
Local nContItem := 1
Local nTotaRegs := 0
Local nContLoop := 1

#IFDEF TOP
	
	cAliasQry := GetNextAlias()
	
	cQuery := " SELECT * FROM " + RetSqlName("AJY") + " AJY"
	cQuery += "	WHERE AJY_PROJET = '" + cProjOrig + "'"
	cQuery += " AND D_E_L_E_T_ = ' '
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )
	
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	dbeval({|| nTotaRegs ++})
	
	oProcess:SetRegua2(nTotaRegs)
	
	(cAliasQry)->(dbGoTop())
	While ! (cAliasQry)->(Eof())
		
		AJY->(dbSetOrder(1))
		If ! AJY->(dbSeek(xfilial("AJY") + cProjDest + PmsRevAtu(cProjDest) + (cAliasQry)->AJY_INSUMO) )
			
			Reclock("AJY",.T.)
			oProcess:SetRegua1(AJY->(FCount()))
			For nContItem := 1 to AJY->(FCount())
				Do Case
					Case Field(nContItem) == "AJY_PROJET"
						xContGrav := cProjDest
					OtherWise
						xContGrav := (cAliasQry)->&(Field(nContItem))
				EndCase
				FieldPut(nContItem, xContGrav)
				oProcess:IncRegua1(STR0015 + Field(nContItem))
			Next
			MsUnlock()
			
		EndIf
		(cAliasQry)->(dbSkip())
		oProcess:IncRegua2(STR0016 + Str((cAliasQry)->(Recno())))
		
	End
	
#ELSE
	
	ChkFile("AJY",.F.,"TRBAJY")
	
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	dbeval({||nTotaRegs ++})
	
	
	TRBAJY->(dbSetorder(2))
	TRBAJY->(dbSeek(xfilial("AJY") + cProjOrig, .T. ) )
	
	While ! TRBAJY->( Eof() ) .And. TRBAJY->AJY_PROJET == cProjOrig
		If ! AJY->(dbSeek(xfilial("AJY") + cProjDest + TRBAJY->AJY_INSUMO ))
			Reclock("AJY",.T.)
			For nContItem := 1 to FCount
				Do Case
					Case Field(nContItem) == "AJY_PROJET"
						xContGrav := cProjDest
					OtherWise
						xContGrav := (cAliasQry)->&(Field(nContItem))
				EndCase
				FieldPut(nContItem, xContGrav)
			Next
			MsUnlock()
		EndIf
		TRBAJY->(dbSkip())
		oProcess:IncRegua2(STR0016 + Str((cAliasQry)->(Recno())))
	End
	
#ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณPMS16PrjIns บAutorณJoใo Gon็alves de Oliveira บ Data ณ  21/10/2008   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑณDescri็ใo ณ Grava dados de vํnculo entre projetos e insumos entre projetos      ณฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PMS16PrjIns(cInsuProj,cDescInsu,nOPc)                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ ExpC1 - C๓digo do Insumo a ser atualizado                           บฑฑ
ฑฑบ          ณ ExpC2 - Descri็ใo do Insumo a ser atualizado                        บฑฑ
ฑฑบ          ณ ExpN3 - Op็ใo de atualiza็ใo utilizada (aRotina)                    บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ ExpA1 - aCols (Vetor com os projetos a vincular                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMS - Gestใo de Projetos / Template Constru็ใo Civil                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PMS16PrjIns(cInsuProj,cDescInsu,nOPc,nProjRec)

Local aPosObj      := {}
Local aObjects     := {}
Local aSize        := MsAdvSize( .F. )
Local nContItem    := 0
Local lCompUnic    := .F.
Local aColsX       := {}
Local nOpcX        := 0
Local oDlg
Local oGet,oGet2
Local nProj        := aScan(aHeader,{ |x| x[2] == "AJY_PROJET"})

nLinAJY := 0

aColsX := aClone(aColsAJY)

//If Len(aColsAJY) == 0
AF8->(dbGoTo(nProjRec))	
dbSelectArea("AJY")
AJY->(dbSetOrder(1))
If AJY->(dbSeek(xfilial("AJY") + cInsuProj))
	
	While AJY->(AJY_FILIAL + AJY_INSUMO) == xfilial("AJZ") + cInsuProj
		
		aAdd(aColsAJY,Array(Len(aHeader) + 1))
		nLinAJY ++
		AEval(aHeader, {|x,y| aColsAJY[nLinAJY][y] := If(Alltrim(x[2])$"AJY_ALI_WT|AJY_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
		aColsAJY[nLinAJY][Len(aHeader) + 1] := .F.
		
		AJY->(dbSkip())
		
	End
	
Else
	
	aAdd(aColsAJY,Array(Len(aHeader) + 1))
	nLinAJY ++
	aEval(aHeader, {|x,y| aColsAJY[nLinAJY][y] := If(Alltrim(x[2])$"AJY_ALI_WT|AJY_REC_WT",NIL,PM16RetIns(x[2],AF8->AF8_PROJET)) })
	aColsAJY[nLinAJY][Len(aHeader) + 1] := .F.
	
EndIf
	
//EndIf

AAdd( aObjects, { 100,  44, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
aPosObj := MsObjSize( aInfo, aObjects )

AF8->(dbGoTo(nProjRec))
aColsAJY[1][nProj] := AF8->AF8_PROJET

/*
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

@ 019,005 SAY OemToAnsi(STR0017) SIZE 040,009 OF oDlg PIXEL // "Insumo"
@ 018,050 GET oGet  VAR cInsuProj SIZE 120,009 OF oDlg PIXEL WHEN .F.

@ 032,005 SAY OemToAnsi(STR0018) SIZE 040,009 OF oDlg PIXEL // "Descri็ใo"
@ 031,050 GET oGet2 VAR cDescInsu SIZE 120,009 OF oDlg PIXEL WHEN .F.

oGetD := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIf(nOpc == 2 .Or. nOpc == 5,Nil,GD_INSERT+GD_UPDATE+GD_DELETE),,,,,,,,,,,aHeader,aColsAJY)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGetd:TudoOk() .And.;
 																						PMSA016Rel(oGetd:aCols,oGetd:aHeader,M->AJZ_INSUMO,),;
 																						oDlg:End(),nOpcA := 0),nOpcX := 1},{||oDlg:End(),nOpcX := 2})
*/

//PMSA016Rel(aColsAJY,aHeader,cInsuProj,)
                           
If (nOpcX == 2)
	aColsAJY := aClone(aColsX)
EndIf	

Return(aColsAJY)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ PM16GrvVin บAutorณJoใo Gon็alves de Oliveira บ Data ณ 23/10/2008    บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑณDescri…o ณ Gera/Atualiza Vํnculo entre Insumo e Projeto(s)                     ณฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PM16GrvVin(aHeader,aColsAJY,nOpc,cCodiInsu)                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ ExpA1 - Cabe็alho da GetDados (aHeader)                             บฑฑ
ฑฑบ          ณ ExpA2 - อtens da GetDados (aCols)                                   บฑฑ
ฑฑบ          ณ ExpN3 - Op็ใo de atualiza็ใo utilizada (nOpc)                       บฑฑ
ฑฑบ          ณ ExpC4 - C๓digo do Insumo Atualizado                                 บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMS - Gestใo de Projetos / Template Constru็ใo Civil                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PM16GrvVin(aHeader,aColsAJY,nOpc,cCodiInsu,lRegiNovo)
Local nContItem := 1
Local aRegiDele := {}
Local cRevAtu   := ""
Local nCount    := 0                

Private nPosiProj := aScan(aHeader,{ |x| x[2] == "AJY_PROJET"})

DEFAULT lRegiNovo := .T.

If nOpc <> 5
	If PmsVldFase("AF8",aColsAJY[1,nPosiProj],"11",.F.,/*cMensagem*/,/*dDataChk*/)

		For nContItem := Len(aColsAJY) To 1 Step -1
			If aColsAJY[nContItem,1] == Nil
				aDel(aColsAJY,nContItem)
				nCount++
			EndIf
		Next nContItem
		
		aSize(aColsAJY,Len(aColsAJY)-nCount)	
		
		For nContItem := 1 to Len(aColsAJY)
			AJY->(dbSetOrder(1))
			cRevAtu := PmsRevAtu(aColsAJY[1,nPosiProj])
			lRegiNovo := ! AJY->(dbSeek(xfilial("AJY") + aColsAJY[1,nPosiProj] + cRevAtu + AJZ->AJZ_INSUMO))

			Reclock("AJY",lRegiNovo)
			If ! aColsAJY[nContItem,Len(aColsAJY[nContItem])]
				If lRegiNovo
					AJY_FILIAL := xfilial("AJY")
					AJY_INSUMO := AJZ->AJZ_INSUMO
				EndIf
				AEval(aHeader,{|x,y| If( FieldPos(x[2])> 0 ,FieldPut(FieldPos(x[2]),aColsAJY[nContItem][y]),) })
			Else
				Delete
			EndIf
			MsUnlock()
		Next


	EndIf
Else
	AJY->(dbSetOrder(1))
	AJY->(dbSeek(xfilial("AJY") + cCodiInsu))
	While cCodiInsu == AJY->AJY_INSUMO .And. ! AJY->(Eof())
		aAdd(aRegiDele,AJY->(Recno()))
		AJY->(dbSkip())
	End
	
	For nContItem := 1 to Len(aRegiDele)
		AJY->(dbGoTo(aRegiDele[nContItem]))
		Reclock("AJY",.F.)
		Delete
		MsUnlock()
	Next
	
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณPM16RetIns  บAutorณJoใo Gon็alves de Oliveira บ Data ณ  27/10/2008   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑณDescri…o ณ Retorno conte๚do de mem๓ria da tabela principal de insumo para      ณฑฑ
ฑฑณ          ณ preenchimento da GetDados de vํnculo projeto x insumo               ณฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PM16RetIns(cCampo)                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ ExpC1 - Nome do Campo                                               บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Conte๚do equivalente do campo informado (variแvel de mem๓ria)       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMS - Gestใo de Projetos / Template Constru็ใo Civil                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PM16RetIns(cCampo)

Default cCampo := SX3->X3_CAMPO

If AllTrim(cCampo) == "AJY_PROJET"
	xVariMemo := CriaVar(AllTrim(cCampo))
Else
	If AllTrim(cCampo) == "AJY_REVISA"
		xVariMemo := PmsRevAtu(AF8->AF8_PROJET)
	Else
		xVariMemo := AJZ->&(Substr(AllTrim(cCampo),1,2) + "Z" + Substr(AllTrim(cCampo),4))
   EndIf
EndIf

If xVariMemo == NIL
	xVariMemo := &(AJZ->(Substr(AllTrim(cCampo),1,2) + "Z" + Substr(AllTrim(cCampo),4)))
EndIf

Return(xVariMemo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ PMSInsuPad  บAutorณJoใo Gon็alves de Oliveira บ Data ณ 05/11/2008   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑณDescri…o ณ Consulta padrใo para buscar insumos por projeto ou pelo cadastro    ณฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PMSInsuPad()                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ                                                                     บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMS - Gestใo de Projetos / Template Constru็ใo Civil                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PMSInsuPad()
Local xRet

// Executa a Consulta Padrao do parametro conforme a existencia de projeto
xRet := ConPad1( ,,, IIf(Posicione("AJY",1,xfilial("AJY") + AF8->AF8_PROJET,"AJY_PROJET") == AF8->AF8_PROJET .And. !Empty(AF8->AF8_PROJET),"AJY","AJZ"),,, .F. )

Return( xRet )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSA016DelบAutor  ณPedro Pereira Lima  บ Data ณ  09/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se todos os vinculos de insumo/projeto foram dele- บฑฑ
ฑฑบ          ณtados. Se sim, emite alerta sobre a necessidade do vinculo. บฑฑ 
ฑฑบ          ณ                                                            บฑฑ 
ฑฑบ          ณ                                                            บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA016 - Cadastro de Insumos                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSA016Del(aColsGet,aHeadGet)
Local aColsX := Iif(ValType(aColsGet) == 'A', aClone(aColsGet), {})
Local aHeadX := Iif(ValType(aHeadGet) == 'A', aClone(aHeadGet), {})
Local nX     := 0
Local lAlerta:= .F.

If Len(aColsGet) >= 1
	For nX := 1 To Len(oGetD:aCols)
		If !aColsX[nX][Len(aHeadX)+1]	
			lAlerta := .T.
		EndIf
	Next nX
EndIf
        
If !lAlerta
	Alert(STR0019)
EndIf

Return lAlerta   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSA016RelบAutor  ณPedro Pereira Lima  บ Data ณ  10/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a validacao dos insumos marcados para delecao, verifi-  บฑฑ
ฑฑบ          ณcando se existe amarracao entre o insumo e alguma composicaoบฑฑ
ฑฑบ          ณaux cadastrada. Se existir esse vinculo, nao permite a de-บฑฑ
ฑฑบ          ณlecao do insumo, alertando sobre o vinculo com a composicao บฑฑ
ฑฑบ          ณaux.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA016 - Cadastro de Insumos                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Function PMSA016Rel(aColsGet,aHeadGet,cCodInsumo,lGetDados)
Local aColsX     := Iif(ValType(aColsGet) == 'A', aClone(aColsGet), {})
Local aHeadX     := Iif(ValType(aHeadGet) == 'A', aClone(aHeadGet), {})
Local nX         := 0
Local lAlerta    := .T.
Local aArea      := GetArea()
Local aAreaAJU   := AJU->(GetArea())
Local cAliasX    := GetNextAlias()
Local nConta     := 0

Default lGetDados := .F.

If !lGetDados
	If Len(aColsGet) >= 1
		For nX := 1 To Len(oGetD:aCols) //Verifico se existe linha marcada para delecao
			If aColsX[nX][Len(aHeadX)+1]	//Caso alguma linha esteja marcada para delecao, altero o valor de lAlerta (flag) para .F.
				lAlerta := .F.
			EndIf
		Next nX
	EndIf
EndIf
      
If !lAlerta .Or. lGetDados
	#IFDEF TOP
		BeginSQL ALIAS cAliasX
			SELECT COUNT(AJU_COMPUN) CONTA FROM %Table:AJU% As AJU
				WHERE AJU_FILIAL = %EXP:xFilial("AJU")%
				AND AJU_PRODUT = %EXP:cCodInsumo%
				AND AJU.%NotDel%
		EndSQL			
	   
		nConta := (cAliasX)->CONTA
	
	#ELSE 
   	cFiltroAJU := "AJU_PRODUT = '" + cCodInsumo + "'"
	
		dbSelectArea("AJU")
		dbSetFilter({||&cFiltroAJU},cFiltroAJU)
		dbGoTop()
		
		While !Eof()
			If AJU->AJU_PRODUT == cCodInsumo
				nConta++
			EndIf
			dbSkip()
		EndDo
	#ENDIF
	
	If !(nConta == 0)
		Alert(STR0020)
		lAlerta := .F.
	Else
		lAlerta := .T.
	EndIf
			
EndIf

RestArea(aAreaAJU)
RestArea(aArea)

Return lAlerta   
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ MenuDef  ณ Autor ณ Pedro Pereira Lima    ณ Data ณ31/03/09  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional adequado a composicao aux   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Array com opcoes da rotina de cadastro de insumos.         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina 	

aRotina 	  := {	{ STR0002,"AxPesqui"  	,0,1},; //"Pesquisar"
						{ STR0003,"PMSA016Man"	,0,2},; //"Visualizar"
						{ STR0004,"PMSA016Man"	,0,3},; //"Incluir"
						{ STR0005,"PMSA016Man"	,0,4},; //"Alterar"
						{ STR0006,"PMSA016Man"	,0,5},; //"Excluir"
						{ STR0021, "MenuAux(1)", 0 , 6 },; //"Importar" 
						{ STR0022, "MenuAux(2)", 0 , 7 },; //"Exportar"
						{ STR0023, "MenuAux(3)", 0 , 8 }}  //"Copiar"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuAux   บAutor  ณPedro Pereira Lima  บ Data ณ  31/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamada auxiliar para o menu dinamico da composicao aux    บฑฑ
ฑฑบ          ณ cadastro de insumos                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA016 - MenuDef()                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MenuAux(nOpcAux)

Do Case
	Case nOpcAux == 1
		PMSA016Man(,,6,.T.,.F.)
	Case nOpcAux == 2
		PMSA016Man(,,6,.F.,.T.)
	Case nOpcAux == 3
		PMSA016Man(,,6,.F.,.F.)
EndCase                                                                        

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMA016INS บAutor  ณPedro Pereira Lima  บ Data ณ  31/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os valores do insumo original na tela gerada para a บฑฑ
ฑฑบ          ณduplicata deste insumo.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA016 - PMSA016Man                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMA016INS(nRegIns)
Local aArea    := GetArea()
Local aAreaAJZ := AJZ->(GetArea())
Local aAreaSX3 := SX3->(GetArea())
Local nCampos  := 0

dbSelectArea("AJZ")
AJZ->(dbGoTo(nRegIns))
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("AJZ"))
While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "AJZ"
	If AllTrim(SX3->X3_CAMPO) <> "AJZ_INSUMO" .And. SX3->X3_CONTEXT <> "V"
		M->&(AllTrim(SX3->X3_CAMPO)) := AJZ->&(AllTrim(SX3->X3_CAMPO))
	EndIf                                                           
	SX3->(dbSkip())
EndDo

RestArea(aAreaSX3)
RestArea(aAreaAJZ)
RestArea(aArea)
Return Nil

Function PMA016Desc(cDesc)

MV_PAR03 := RTrim(cDesc)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMA016Iexp  บAutor  ณPedro Pereira Lima  บ Data ณ  03/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de importacao/exportacao de insumos:                   บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑบ          ณImporta insumo dos projetos selecionados para o cadastro de   บฑฑ
ฑฑบ          ณinsumos.                                                      บฑฑ
ฑฑบ          ณExporta insumos selecionados para o cadastro de insumos de    บฑฑ
ฑฑบ          ณprojetos.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMA016Iexp(lImp,lExp) 
Local bOk1
Local aSize := {}
Local aCampos := {}                        
Local aStru := {}
Local cNomeArq := ""                    
Local cIndex   := ""                    
Local lInverte := .F.             
Local lImporta := .F.
Local nZ            
Local nX
Local nY
Local nInc
Local cAliasAJ := ""
Local cRevAtu  := ""
Local cFiltro  := ""
Local aArea    := GetArea()
Local aAreaAJY := AJY->(GetArea())
Local aAreaAJZ := AJZ->(GetArea())
Local aAreaAF8 := AF8->(GetArea())
Local aRecAux  := {}
Local aRecSel  := {}
Local aRecProj := {}
Local aRecChk  := {}
Local aInsTMP  := {}
Local aRecExis := {}
Local aAreaAJZE := {}
Local lNew		:= .T.
Local cTrab
Local cIndTmp1
Local oDlg
Local lOk
Local cMarca2	:= "X"				// Caractere de marca
Local oPanel
Local oGet
Local cProcura
Local oButton
Local oPMS0161	:= Nil
Local oPMS0162	:= Nil
Local oPMS0163	:= Nil


Private cMarca := GetMark()
Private oMark

aSize := MSADVSIZE()
 
If lImp .And. !lExp
	cAliasAJ := "AJYTMP"
	If !ParamBox({;         
			{9,STR0038,Len(STR0038)*3,,},;      	//Selecionar o projeto cujos insumos serใo importados:
			{1,STR0031,AF8->AF8_PROJET,PesqPict("AF8","AF8_PROJET",),"PMA016Desc(AF8->AF8_DESCRI) .And. ExistCpo('AF8',MV_PAR02,1)","AF8",/*When*/,80,.T.},;	//AF8_PROJET - Codigo do Projeto
			{1,STR0030,AF8->AF8_DESCRI,PesqPict("AF8","AF8_DESCRI",),/*VALID*/,/*F3*/,'.F.',80,.F.};
			},STR0021,,,,.T.,,,,,.F.,.F.)                                             
		Return
	EndIf		     
	cFiltro := "AJY_PROJET = '" + MV_PAR02 + "'"
Else
	cAliasAJ := "AJZTMP"	 
EndIf

aCampos := 	{;	
					{ "AJ_OK"			                  ,,			 },;	
					{ Substr(cAliasAJ,1,3) + "_INSUMO"  	,, "INSUMO"},;
					{ Substr(cAliasAJ,1,3) + "_DESC"    	,, STR0018};
				}  

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek(Substr(cAliasAJ,1,3) + "_INSUMO")
aAdd(aStru ,{"AJ_OK"		  ,"C"			,2					 ,0				  })//"Campo 'Check'
aAdd(aStru ,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})//"Codigo"

dbSeek(Substr(cAliasAJ,1,3) + "_DESC")                                                                          
aAdd(aStru ,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})//"Descricao"
aAdd(aStru ,{"AJ_RECNO"  ,"N"			,12				 ,0              })//"Recno"        

If lImp
	dbSeek(Substr(cAliasAJ,1,3) + "_PROJET")
	aAdd(aStru ,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})//"Projeto" (Para uso do filtro)
EndIf

oPMS0161 := FWTemporaryTable():New( cAliasAJ )  
oPMS0161:SetFields(aStru) 
oPMS0161:AddIndex("1", {Substr(cAliasAJ,1,3) + "_INSUMO"})

//------------------
//Cria็ใo da tabela temporaria
//------------------
oPMS0161:Create()

dbSelectArea(cAliasAJ)
dbGotop()
      	
dbselectarea(Substr(cAliasAJ,1,3))
dbgotop()
	
While (Substr(cAliasAJ,1,3))->(!Eof())
	RecLock(cAliasAJ, .T.)
	For nZ := 1 to (Substr(cAliasAJ,1,3))->( fCount() )
		If !Empty((Substr(cAliasAJ,1,3))->(FieldName(nZ))).AND. (cAliasAJ)->(FieldPos((Substr(cAliasAJ,1,3))->(FieldName(nZ)))) > 0
			If (Substr(cAliasAJ,1,3))->(ValType(FieldName(nZ))) # "M"
				(cAliasAJ)->(FieldPut((cAliasAJ)->(FieldPos((Substr(cAliasAJ,1,3))->(FieldName(nZ)))), (Substr(cAliasAJ,1,3))->(FieldGet(nZ)) ) )
			EndIf
		EndIf	
	Next nZ
	(cAliasAJ)->AJ_RECNO := ((Substr(cAliasAJ,1,3)))->(Recno())
	
	MsUnlock()

	(Substr(cAliasAJ,1,3))->(DbSkip())
EndDo

(cAliasAJ)->(dbGoTop())

DEFINE MSDIALOG oDlg1 TITLE STR0026 From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Copia de Insumos"
oDlg1:lMaximized := .T.
	
////////
// Panel
	oPanel := TPanel():New(0,0,'',oDlg1,, .T., .T.,, ,315,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           
	@ 003 , 005 SAY STR0027 FONT oDlg1:oFont PIXEL Of oPanel // "Selecione os insumos para exporta็ใo"

	cProcura := space(TamSX3( "AJY_INSUMO")[1])
	@ 010,010 MSGET oGet VAR cProcura	SIZE 045,010 OF oPanel PIXEL
	oButton := TButton():New(010,060,"Procura",oPanel,{|| (cAliasAJ)->(dbSeek(cProcura)) },40,10,NIL,NIL,.F.,.T.,.T.,NIL,.F.,NIL,NIL,.F.)
// Panel
////////     

/////////////
// MarkBrowse
	oMark := MsSelect():New(cAliasAJ,"AJ_OK","",aCampos,@lInverte,@cMarca,{50,oDlg1:nLeft,oDlg1:nBottom,oDlg1:nRight},,)
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // Somente Interface MDI
	oMark:bAval	:= {|| PMA016Mark(cMarca,cAliasAJ)}
	oMark:oBrowse:lhasMark = .T.
	oMark:oBrowse:lCanAllmark := .T.
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
// MarkBrowse
/////////////

bOk1 := {|| nOpca := 1,oDlg1:End()}
                 
ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1,	{|| Eval(bOk1) },{|| nOpca := 2,oDlg1:End()},,)) CENTER

(cAliasAJ)->(dbGoTop())
While (cAliasAJ)->(!Eof())
	If (cAliasAJ)->AJ_OK == cMarca 
		If lExp
			aAdd(aRecAux,(cAliasAJ)->AJ_RECNO)
			aAreaAJZE := AJZ->( GetArea() )
			AJZ->( DbGoTo( (cAliasAJ)->AJ_RECNO ) )
			PA016IncSub( AJZ->AJZ_INSUMO, @aRecAux )
			AJZ->( RestArea( aAreaAJZE ) )
		ElseIf lImp
			DbSelectArea( "AJZ" )
			AJZ->( DbSetOrder( 1 ) )
			If AJZ->( DbSeek( xFilial( "AJZ" ) + (cAliasAJ)->AJY_INSUMO ) )
				aAdd(aRecChk,(cAliasAJ)->AJ_RECNO)
			Else
				aAdd(aRecSel,(cAliasAJ)->AJ_RECNO)
			EndIf
		EndIf
	EndIf

	(cAliasAJ)->(dbSkip())
EndDo

If oPMS0161 <> Nil
	oPMS0161:Delete()
	oPMS0161 := Nil
Endif              

If lExp
	aRecProj := PMA016BPrj()

	For nX := 1 To Len(aRecProj)
		aRecSel := {}
		aRecChk := {}
		DbSelectArea( "AJY" )
		AJY->( DbSetOrder( 1 ) )
		aInsTMP:={{""}}
		For nY := 1 To Len(aRecAux)
			dbSelectArea("AJZ")
			AJZ->(dbGoTo(aRecAux[nY]))
			aInsTMP := PMS16PrjIns(AJZ->AJZ_INSUMO,AJZ->AJZ_DESC,1,aRecProj[nX])
			AJY->( dbSetOrder( 1 ) )
			cRevAtu := PmsRevAtu(aInsTMP[1,1])

			If AJY->( dbSeek( xfilial( "AJY" ) + aInsTMP[1,1] + cRevAtu + AJZ->AJZ_INSUMO))
				aAdd(aRecChk, aRecAux[nY])
			Else
				aAdd(aRecSel, aRecAux[nY])
			EndIf
		Next nY

		If !Empty(aRecChk)
			Alert( STR0050 + ' ' + aInsTMP[1,1] + chr(13) + chr(10) + STR0049 ) //"Foi encontrado algum insumo jแ definido para o projeto" ## "Selecione os insumos que devem ser substituidos."
	
			aTrab		:= {	{ "OK"    , "C", 1							,	0 },;
								{ "CODIGO", "C", TamSX3( "AJZ_INSUMO"	)[1],	0 },;
								{ "DESCR" , "C", TamSX3( "AJZ_DESC"	)[1],	0 },;
								{ "REC"   , "N", 12							,	0 } }
					
			oPMS0162 := FWTemporaryTable():New( "TRB" )  
			oPMS0162:SetFields(aTrab) 
			oPMS0162:AddIndex("1", {"CODIGO"})
			
			//------------------
			//Cria็ใo da tabela temporaria
			//------------------
			oPMS0162:Create()
		
			For nInc := 1 To Len( aRecChk )
				AJZ->( DbGoTo( aRecChk[nInc] ) )
				RecLock( "TRB", .T. ) 
				TRB->CODIGO	:= AJZ->AJZ_INSUMO
				TRB->DESCR	:= AJZ->AJZ_DESC
				TRB->REC	:= aRecChk[nInc]
				MsUnLock()
			Next

			DbSelectArea( "TRB" )
			TRB->( DbGoTop() )

			DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL
		
			aCpos := {	{ "OK"    	, "", "", ""}, ;
						{ "CODIGO"	, "", A093RetDescr( "AJZ_INSUMO"	), "" },;
						{ "DESCR"	, "", A093RetDescr( "AJZ_DESC"		), "" } }
		
			oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca2, {35,oDlg:nLeft,oDlg:nBottom,oDlg:nRight} )
			oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
			oMark:oBrowse:lCanAllMark	:= .T.
			oMark:oBrowse:bAllMark		:= { || PMA016Inv( cMarca2, .T., oMark ) }
		
			ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End(), .F. }, { || oDlg:End() },,/*aButtons*/ ) ) CENTERED

			If lOk
				TRB->( DbGoTop() )
				While TRB->( !Eof() )
					If TRB->OK == "X"
						aAdd( aRecSel, TRB->REC )
					EndIf
				
					TRB->( DbSkip() )
				End
			EndIf
			
			If oPMS0162 <> Nil
				oPMS0162:Delete()
				oPMS0162 := Nil
			Endif
	
		EndIf

		For nY := 1 To Len(aRecSel)
			Begin Transaction

			dbSelectArea("AJZ")
			AJZ->(dbGoTo(aRecSel[nY]))
			aInsTMP := PMS16PrjIns(AJZ->AJZ_INSUMO,AJZ->AJZ_DESC,1,aRecProj[nX])
			AJY->(dbSetOrder(1))
			cRevAtu := PmsRevAtu(aInsTMP[1,1])

			lNew := !AJY->(dbSeek(xfilial("AJY") + aInsTMP[1,1] + cRevAtu + AJZ->AJZ_INSUMO))

			PM16GrvVin(aHeader,aInsTMP,1,AJZ->AJZ_INSUMO,lNew)
				
			DbSelectArea( "AEM" )
			AEM->( DbSetOrder( 2 ) )
			AEM->( DbSeek( xFilial( "AEM" ) + aInsTMP[1,1] + cRevAtu + AJZ->AJZ_INSUMO ) )
			Do While !AEM->(Eof()) .And. AEM->( AEM_FILIAL+AEM_PROJET+AEM_REVISA+AEM_INSUMO ) == xFilial( "AEM" ) + aInsTMP[1,1] + cRevAtu + AJZ->AJZ_INSUMO
				RecLock("AEM",.F.,.T.)
				dbDelete()
				MsUnlock()
				AEM->(dbSkip())
			EndDo
				
			// Copia os sub-insumos
			aFields := AEK->( DbStruct() )

			DbSelectArea( "AEK" )
			AEK->( DbSetOrder( 1 ) )
			AEK->( DbSeek( xFilial( "AEK" ) + AJZ->AJZ_INSUMO ) )
			While AEK->( !Eof() ) .AND. AEK->( AEK_FILIAL + AEK_INSUMO ) == xFilial( "AEK" ) + AJZ->AJZ_INSUMO

				RecLock( "AEM", .T. )
				For nInc := 1 To Len( aFields )
					cCampo := "AEM_" + AllTrim( substr( aFields[nInc][1], 5 ) )
					If AEM->( FieldPos( cCampo ) ) > 0
						AEM->( &(cCampo) ) := AEK->( &(aFields[nInc][1]) )
					EndIf
				Next
			
				AEM->AEM_FILIAL := xFilial( "AEM" )
				AEM->AEM_SUBINS := AEK->AEK_SUBCOD
				AEM->AEM_PROJET := aInsTMP[1,1]
				AEM->AEM_REVISA := cRevAtu
				AEM->( MsUnLock() )

				AEK->( DbSkip() )
			End

			End Transaction
		Next nY
	Next nX
ElseIf lImp
	If !Empty(aRecChk)
		Alert( STR0048 + chr(13) + chr(10) + STR0049 ) //"Foram encontrados insumos jแ definidos no cadastro." ## "Selecione os insumos que devem ser substituidos."
	
		aTrab		:= {	{ "OK"    , "C", 1							,	0 },;
							{ "PROJET", "C", TamSX3( "AJY_PROJET"	)[1],	0 },;
							{ "REVISA", "C", TamSX3( "AJY_REVISA"	)[1],	0 },;
							{ "CODIGO", "C", TamSX3( "AJY_INSUMO"	)[1],	0 },;
							{ "DESCR"  ,	"C", TamSX3( "AJY_DESC"	)[1],	0 },;
							{ "REC"   ,	"N", 12							,	0 } }
				
		oPMS0163 := FWTemporaryTable():New( "TRB" )  
		oPMS0163:SetFields(aTrab) 
		oPMS0163:AddIndex("1", {"CODIGO"})
		
		//------------------
		//Cria็ใo da tabela temporaria
		//------------------
		oPMS0163:Create()
		
		For nInc := 1 To Len( aRecChk )
			AJY->( DbGoTo( aRecChk[nInc] ) )
			RecLock( "TRB", .T. ) 
			TRB->CODIGO	:= AJY->AJY_INSUMO
			TRB->DESCR	:= AJY->AJY_DESC
			TRB->PROJET	:= AJY->AJY_PROJET
			TRB->REVISA	:= AJY->AJY_REVISA
			TRB->REC	:= aRecChk[nInc]
			MsUnLock()
		Next

		DbSelectArea( "TRB" )
		TRB->( DbGoTop() )

		DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 TO aSize[6]-100,aSize[5]-100 OF oMainWnd PIXEL
		
		aCpos := {	{ "OK"    	, "", "", ""}, ;
					{ "PROJET"	, "", A093RetDescr( "AJY_PROJET"	), "" },;
					{ "REVISA"	, "", A093RetDescr( "AJY_REVISA"	), "" },;
					{ "CODIGO"	, "", A093RetDescr( "AJY_INSUMO"	), "" },;
					{ "DESCR"	, "", A093RetDescr( "AJY_DESC"		), "" } }
		
		oMark 						:= MsSelect():New( "TRB", "OK",, aCpos, @lInverte, @cMarca2, {35,oDlg:nLeft,oDlg:nBottom,oDlg:nRight} )
		oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:lCanAllMark	:= .T.
		oMark:oBrowse:bAllMark		:= { || PMA016Inv( cMarca2, .T., oMark ) }
		
		ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, { || lOk := .T., oDlg:End(), .F. }, { || oDlg:End() },,/*aButtons*/ ) ) CENTERED

		If lOk
			TRB->( DbGoTop() )
			While TRB->( !Eof() )
				If TRB->OK == "X"
					aAdd( aRecSel, TRB->REC )
				EndIf
				
				TRB->( DbSkip() )
			End
		EndIf
		
		If oPMS0163 <> Nil
			oPMS0163:Delete()
			oPMS0163 := Nil
		Endif
	
	EndIf
	
	For nX := 1 To Len( aRecSel )
		Begin Transaction

		DbSelectArea( "AJY" )
		AJY->( DbGoTo( aRecSel[nX] ) )
		
		// Copia os sub-insumos
		aFields := AJY->( DbStruct() )
		cRevAtu := PmsRevAtu( MV_PAR02 )

		lNew := AJZ->( !DbSeek( xFilial( "AJZ" ) + AJY->AJY_INSUMO ) )

		RecLock( "AJZ", lNew )
		For nInc := 1 To Len( aFields )
			cCampo := "AJZ_" + AllTrim( substr( aFields[nInc][1], 5 ) )
			If AJZ->( FieldPos( cCampo ) ) > 0
				AJZ->( &(cCampo) ) := AJY->( &(aFields[nInc][1]) )
			EndIf
		Next

		AJZ->AJZ_FILIAL := xFilial( "AJZ" )
		AJZ->( MsUnLock() )

		// Copia os sub-insumos
		aFields := AEM->( DbStruct() )
		cRevAtu := PmsRevAtu( MV_PAR02 )

		DbSelectArea( "AEM" )
		AEM->( DbSetOrder( 1 ) )
		AEM->( DbSeek( xFilial( "AEK" ) + MV_PAR02 + cRevAtu + AJY->AJY_INSUMO ) )
		While AEM->( !Eof() ) .AND. AEM->( AEM_FILIAL + AEM_PROJET + AEM_REVISA + AEM_INSUMO ) == xFilial( "AEM" ) + MV_PAR02 + cRevAtu + AJY->AJY_INSUMO

			AEK->( DbSetOrder( 2 ) )
			lNew := AEK->( !DbSeek( xFilial( "AEK" ) + AEM->( AEM_SUBINS + AEM_INSUMO ) ) )

			RecLock( "AEK", lNew )
			For nInc := 1 To Len( aFields )
				cCampo := "AEK_" + AllTrim( substr( aFields[nInc][1], 5 ) )
				If AEK->( FieldPos( cCampo ) ) > 0
					AEK->( &(cCampo) ) := AEM->( &(aFields[nInc][1]) )
				EndIf
			Next
	
			AEK->AEK_FILIAL := xFilial( "AEM" )
			AEK->AEK_SUBCOD := AEM->AEM_SUBINS
			AEK->( MsUnLock() )

			AEM->( DbSkip() )
		End

		End Transaction
	Next
EndIf


RestArea(aAreaAF8)
RestArea(aAreaAJZ)
RestArea(aAreaAJY)
RestArea(aArea)
Return													

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMA016MarkบAutor  ณPedro Pereira Lima  บ Data ณ  08/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermite a marcacao dos resgistros na MBrowse sem desordenar บฑฑ
ฑฑบ          ณa exibicao dos mesmos.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA016 - PMA016Iexp()                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMA016Mark(cMarca,cAliasTMP)
Local lRet := .T.
Local nReg := (cAliasTMP)->(Recno())

If (cAliasTMP)->(MsRLock())
	If (cAliasTMP)->&(Substr(cAliasTMP,1,2) + "_OK") == cMarca
		(cAliasTMP)->&(Substr(cAliasTMP,1,2) + "_OK") := " "
		(cAliasTMP)->(MsUnlock())
	Else
		(cAliasTMP)->&(Substr(cAliasTMP,1,2) + "_OK") := cMarca		
		(cAliasTMP)->(MsUnlock())
	EndIf
EndIf

(cAliasTMP)->(dbGoTo(nReg))
oMark:oBrowse:Refresh(.T.)

Return lRet                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMA016BPrjบAutor  ณPedro Pereira Lima  บ Data ณ  08/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA016 - PMA016Iexp()                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMA016BPrj()
Local bOk1
Local aSize := {}
Local aCampos := {}                        
Local aStru := {}
Local cNomeArq := ""                    
Local cIndex   := ""                    
Local lInverte := .F.             
Local nZ
Local cAliasAF   := ""
Local aArea    := GetArea()
Local aAreaAF8 := AF8->(GetArea())
Local aRecSel  := {}
Local aRecProj := {}
Local aColors   := PmsAF8Color()
Local oPMS0164	:= Nil

aSize := MSADVSIZE()
 
cAliasAF := "AF8TMP"

For nZ := 1 To Len(aColors)
	aColors[nZ][1] := SubStr(aColors[nZ][1],6)
	aDel(aColors[nZ],3)
	aSize(aColors[nZ],Len(aColors[nZ])-1)	
Next nZ

aCampos := 	{;	
					{ "AF_OK"			                     ,,			 },;	
					{ Substr(cAliasAF,1,3) + "_PROJET"   ,, STR0031},;
					{ Substr(cAliasAF,1,3) + "_REVISA"   ,, STR0032},;										
					{ Substr(cAliasAF,1,3) + "_DESCRI"   ,, STR0030};
				}  


dbSelectArea("SX3")
SX3->(dbSetOrder(2))
SX3->(dbSeek("AF8"))
SX3->(dbSeek(Substr(cAliasAF,1,3) + "_FASE"))
aAdd(aStru ,{"AF_OK"		  ,"C"			,2					 ,0				  })//"CAMPO 'CHECK'
aAdd(aStru ,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})//"FASE"
SX3->(dbSeek(Substr(cAliasAF,1,3) + "_PROJET"))                                  
aAdd(aStru ,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})//"COD. PROJETO"
SX3->(dbSeek(Substr(cAliasAF,1,3) + "_DESCRI"))
aAdd(aStru ,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})//"DESCRICAO"
SX3->(dbSeek(Substr(cAliasAF,1,3) + "_REVISA"))
aAdd(aStru ,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})//"REVISAO"
aAdd(aStru ,{"AF_RECNO"  ,"N"			,12				 ,0              })//"RECNO"
		
oPMS0164 := FWTemporaryTable():New( cAliasAF )  
oPMS0164:SetFields(aStru) 
oPMS0164:AddIndex("1", {Substr(cAliasAF,1,3) + "_PROJET"})

//------------------
//Cria็ใo da tabela temporaria
//------------------
oPMS0164:Create()

dbSelectArea(cAliasAF)
dbGotop()
      	
dbselectarea(Substr(cAliasAF,1,3))
dbgotop()
	
While (Substr(cAliasAF,1,3))->(!Eof())
	RecLock(cAliasAF, .T.)
	For nZ := 1 to (Substr(cAliasAF,1,3))->(fCount())
		If !Empty((Substr(cAliasAF,1,3))->(FieldName(nZ))).AND. (cAliasAF)->(FieldPos((Substr(cAliasAF,1,3))->(FieldName(nZ)))) > 0
			If (Substr(cAliasAF,1,3))->(ValType(FieldName(nZ))) # "M"
				(cAliasAF)->(FieldPut((cAliasAF)->(FieldPos((Substr(cAliasAF,1,3))->(FieldName(nZ)))), (Substr(cAliasAF,1,3))->(FieldGet(nZ)) ) )
			EndIf	
		EndIf	
	Next nZ
	(cAliasAF)->AF_RECNO := ((Substr(cAliasAF,1,3)))->(Recno())
	
	MsUnlock()

	(Substr(cAliasAF,1,3))->(DbSkip())
EndDo

(cAliasAF)->(dbGoTop())

DEFINE MSDIALOG oDlg1 TITLE STR0033 From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Copia de Insumos"
oDlg1:lMaximized := .T.
	
////////
// Panel
	oPanel := TPanel():New(0,0,'',oDlg1,, .T., .T.,, ,315,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP // Somente Interface MDI		                           
	@ 003 , 005 SAY STR0034 FONT oDlg1:oFont PIXEL Of oPanel // "Selecione os insumos para exporta็ใo"
	@ 025 , 005 BUTTON STR0035 SIZE 035 ,010  FONT oDlg1:oFont ACTION (PMS200Leg()) OF oDlg1 PIXEL
// Panel
////////     

/////////////
// MarkBrowse
	oMark := MsSelect():New(cAliasAF,"AF_OK","",aCampos,@lInverte,@cMarca,{50,oDlg1:nLeft,oDlg1:nBottom,oDlg1:nRight},,,,,aColors)
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // Somente Interface MDI
	oMark:bAval	:= {|| PMA016Mark(cMarca,cAliasAF)}
	oMark:oBrowse:lhasMark = .T.
	oMark:oBrowse:lCanAllmark := .T.
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
// MarkBrowse
/////////////

bOk1 := {|| nOpca := 1,oDlg1:End()}
                 
ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1,	{|| Eval(bOk1) },{|| nOpca := 2,oDlg1:End()},,)) CENTER

(cAliasAF)->(dbGoTop())
While (cAliasAF)->(!Eof())
	If (cAliasAF)->AF_OK == cMarca 
		aAdd(aRecSel,(cAliasAF)->AF_RECNO)
	EndIf
	(cAliasAF)->(dbSkip())
EndDo

If oPMS0164 <> Nil
	oPMS0164:Delete()
	oPMS0164 := Nil
Endif                 

aRetPrj := aRecSel

RestArea(aAreaAF8)
RestArea(aArea)
Return aRetPrj

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMA016Inc บAutor  ณPedro Pereira Lima  บ Data ณ  23/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para efetuar inclusใo/altera็ใo/exclusใo/visualiza็ใoบฑฑ
ฑฑบ          ณde insumos padrใo.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA016                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMA016Inc(cAlias,nReg,nOpcx,lCopia)
                                    	
Local cAliasE := "AJZ"
Local aAlterEnch := {}
Local nModelo := 3
Local lF3 := .F.
Local lMemoria := .T.
Local lColumn := .F.
Local caTela := ""
Local lNoFolder := .F.
Local lProperty := .T.
Local nI
Local nUsado 	:= 0
Local aTitles 	:= {STR0036,STR0037}
Local aButtons	:= {}  
Local aCpoGet 	:= {}             
Local nMaxLin	:= 99 //Numero maximo de linhas da GetDados
Local lOk
Local nOpcG := GD_UPDATE+GD_INSERT+GD_DELETE
Local nPosCod	:= 0
Local nPosQuant	:= 0
Local nPosUnit	:= 0
Local nPosCusto	:= 0
Local nPosTpParc:= 0
Local nMDO 		:= 0
Local nMateri	:= 0
Local nManut	:= 0
Local aAreaAJZ

Private oDlg
Private oGetD
Private oEnch1
Private oEnch2
Private oPanel1
Private oPanel2
Private aTELA[0][0]
Private aGETS[0]
Private lRefresh		:= .T.
Private aHeaderCM 		:= {}
Private aColsCM 		:= {}
Private aSize	   		:= {}
Private aInfo	 	    := {} // Coluna Inicial, Linha Inicial
Private aObjects		:= {}
Private aPosObj			:= {}
Private aCpo1Ench		:= {}
Private aCpo2Ench		:= {}

Default lCopia := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calculo do tamanho dos objetos                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize		:= MsAdvSize()
aObjects	:= {}
AAdd( aObjects, { 100, 100, .T., .T. } ) // 100, 100
AAdd( aObjects, { 100, 100, .T., .F. } ) // 100, 060
aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }                                        
aPosObj		:= MsObjSize( aInfo, aObjects )

If nOpcX <> 2 .Or. nOpcX <> 5 //Se for visualizacao ou exclusao, restringo a alteracao dos campos da getdados
	aCpoGet := {"AEK_SUBCOD","AEK_TPPARC","AEK_QUANT"}
EndIf

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("AEK")

While !Eof() .And. SX3->X3_ARQUIVO == "AEK"
	If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .And. X3_CAMPO <> "AEK_INSUMO"
		nUsado++
		AADD(aHeaderCM,{Trim(X3Titulo()),;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID,;
		"",;
		SX3->X3_TIPO,;
		"",;
		SX3->X3_CONTEXT })
	EndIf
	DbSkip()
EndDo

If lCopia .Or. nOpcX <> 3
	dbSelectArea("AEK")
	AEK->(dbSetOrder(1))
	AEK->(dbSeek(xFilial(cAlias)+AJZ->AJZ_INSUMO))
	While !Eof() .And. AEK->(AEK_FILIAL+AEK_INSUMO) == AJZ->(AJZ_FILIAL+AJZ_INSUMO)
		aADD(aColsCM,Array(Len(aHeaderCM)+1))
		For nI := 1 To Len(aHeaderCM)
			// Campo nใo ้ virtual, isto ้, existe o campo fisicamente na tabela
			If ( aHeaderCM[nI][10] != "V")
				aColsCM[Len(aColsCM)][aScan(aHeaderCM,{ |x| x[2] == aHeaderCM[nI][2]})] := AEK->&(aHeaderCM[nI][2])
			EndIf
		Next nI
		aColsCM[Len(aColsCM)][Len(aHeaderCM)+1] := .F.

		// Realiza o calculo do custo
		nPosCod		:= aScan( aHeaderCM, { |x| "AEK_SUBCOD" == x[2] } )
		nPosQuant	:= aScan( aHeaderCM, { |x| "AEK_QUANT " == x[2] } )
		nPosUnit	:= aScan( aHeaderCM, { |x| "AEK_UNITAR" == x[2] } )
		nPosCusto	:= aScan( aHeaderCM, { |x| "AEK_CSTITE" == x[2] } )
		nPosTpParc	:= aScan( aHeaderCM, { |x| "AEK_TPPARC" == x[2] } )

		If nPosCod > 0
			aAreaAJZ	 := AJZ->( GetArea() )

			DbSelectArea( "AJZ" )
			AJZ->( DbSetOrder( 1 ) )
			If AJZ->( DbSeek( xFilial( "AJZ" ) + aColsCM[ Len( aColsCM ) ][ nPosCod ]  ) )
				aColsCM[ Len( aColsCM ) ][ nPosUnit  ] := AJZ->AJZ_CUSTD
				aColsCM[ Len( aColsCM ) ][ nPosCusto ] := aColsCM[ Len( aColsCM ) ][ nPosQuant ] * aColsCM[ Len( aColsCM ) ][ nPosUnit ] 

				If aColsCM[ Len( aColsCM ) ][ nPosTpParc ] == "H" // Mao de Obra
					nMDO			+= aColsCM[ Len( aColsCM ) ][ nPosCusto ]

				ElseIf aColsCM[ Len( aColsCM ) ][ nPosTpParc ] == "M" // Material
					nMateri			+= aColsCM[ Len( aColsCM ) ][ nPosCusto ]

				ElseIf aColsCM[ Len( aColsCM ) ][ nPosTpParc ] == "N" // Manutencao
//					nManut			+= aColsCM[ Len( aColsCM ) ][ nPosCusto ]
				EndIf
			EndIf

			RestArea( aAreaAJZ )
		EndIf

		AEK->(dbSkip())
	EndDo  
EndIf

// se aCols estiver vazio. Cria a 1a linha vazia
If Empty(aColsCM)
	AADD(aColsCM,Array(nUsado+1))
	For nI := 1 To nUsado
		aColsCM[1][nI] := CriaVar(aHeaderCM[nI][2])
	Next nI
	aColsCM[1][nUsado+1] := .F.
	aColsCM[1][aScan(aHeaderCM,{ |x| AllTrim(x[2]) == "AEK_ITEM"})] := "01"
EndIf

aCpo1Ench := {	"AJZ_INSUMO",;
					"AJZ_DESC",;
					"AJZ_TIPO",;
					"AJZ_UM",;
					"AJZ_SEGUM",;
					"AJZ_CONV",;
					"AJZ_TIPCON",;
					"AJZ_PRODUT",;
					"AJZ_RECURS",;
					"AJZ_GRUPO",;
					"AJZ_BCOMPO",;
					"AJZ_DATREF",;
					"AJZ_CUSTD",;
					"AJZ_CUSTIM" }

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAliasE)

While !Eof() .And. SX3->X3_ARQUIVO == cAliasE
	If	!(SX3->X3_CAMPO $ "AJZ_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO) .And.;
	 	aScan(aCpo1Ench,{ |x| x == AllTrim(SX3->X3_CAMPO)}) == 0
		AADD(aCpo2Ench,SX3->X3_CAMPO)
	EndIf
	DbSkip()
EndDo

aAlter1Ench := aClone(aCpo1Ench)
aAlter2Ench := aClone(aCpo2Ench)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],aSize[2] TO aSize[6],aSize[5] PIXEL 

	oDlg:lCentered	:= .T.
	oDlg:lMaximized	:= .T.
	oDlg:CoorsUpdate()

	oFolder := TFolder():New(,,aTitles,{'',''},oDlg,,,,.T.,.F.,,)
   
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel1 := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oFolder:aDialogs[1],NIL,.T.,.F.,NIL,NIL,aPosObj[1,3],aPosObj[1,4],.T.,.F. )
	
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT                        

	RegToMemory("AJZ", Iif(nOpcX == 3,.T.,.F.))

	oEnch1 := MsMGet():New(cAliasE,,nOpcX,/*aCRA*/,/*cLetra*/,;
								 /*cTexto*/,aCpo1Ench,aPosObj[1],aAlter1Ench,nModelo,/*nColMens*/,;
								 /*cMensagem*/,/*cTudoOk*/,oPanel1,lF3,lMemoria,lColumn,caTela,;
								 lNoFolder,lProperty)

	oPanel2 := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oFolder:aDialogs[2],NIL,.T.,.F.,NIL,NIL,aPosObj[1,3],aPosObj[1,4],.T.,.F. )
	
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	RegToMemory("AJZ", Iif(nOpcX == 3,.T.,.F.))

	oEnch2 := MsMGet():New(cAliasE,,nOpcX,/*aCRA*/,/*cLetra*/,;
								 /*cTexto*/,aCpo2Ench,aPosObj[1],aAlter2Ench,nModelo,/*nColMens*/,;
								 /*cMensagem*/,/*cTudoOk*/,oPanel2,lF3,lMemoria,lColumn,caTela,;
								 lNoFolder,lProperty) 
								 	
	oGetDados := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcG, "a016GD1LinOk()","AlwaysTrue","+AEK_ITEM",aCpoGet,,,"AlwaysTrue","AlwaysTrue","PMS016Del()",oPanel2,aHeaderCM,aColsCM)

	If lCopia
		PMA016Mem(aCpo1Ench,aCpo2Ench)  
		oGetDados:lChgField := .T.
	EndIf

	PA016Brw()
	PA016Gatilho( .T. )
	
	If M->AJZ_TPPARC == "1"
		nMDO	:= IIf( nMDO    == 0, M->AJZ_MDO, 		nMDO 	)
		nMATERI	:= IIf( nMATERI == 0, M->AJZ_MATERI, 	nMATERI )
		nMANUT	:= IIf( nMANUT  == 0, M->AJZ_MANUT, 	nMANUT 	)
	EndIf
	
	PMA016Recalc( nMDO, nMateri, nManut )

ACTIVATE MSDIALOG oDlg ; 
ON INIT ( EnchoiceBar( oDlg,{ ||lOk := PMS016Ok(nOpcX),Iif(lOk,oDlg:End(),.F.)},{||lOk:=.F., oDlg:End()},,/*@aButtons*/) )

If lOk .And. nOpcX<>2
	PMA016Grv("AJZ",Iif(nOpcX == 5,.T.,.F.),Iif(nOpcX == 4,.T.,.F.),nReg,oGetDados:aHeader,oGetDados:aCols,lCopia)//AJZ - Enchoice
	PMA016Grv("AEK",Iif(nOpcX == 5,.T.,.F.),Iif(nOpcX == 4,.T.,.F.),,oGetDados:aHeader,oGetDados:aCols,lCopia)//AEK - GetDados	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMA016Grv บAutor  ณPedro Pereira Lima  บ Data ณ  29/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMA016Grv(cAlias,lDeleta,lAltera,nRecAtu,aHeaderCM,aColsCM,lCopia)
Local nX    
Local nY
Local bCampo 	:= {|n| FieldName(n) }
Local aArea		:= GetArea()
Local nItemA	:= aScan(aHeaderCM,{ |x| AllTrim(x[2]) == "AEK_ITEM"})
Local nItemCod	:= aScan(aHeaderCM,{ |x| AllTrim(x[2]) == "AEK_SUBCOD"})

Default lCopia := .F.

If cAlias == "AJZ"
	If !lDeleta
		If lAltera
			(cAlias)->(dbGoto(nRecAtu))
			RecLock(cAlias)
		Else
			RecLock(cAlias,.T.)
		EndIf
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
		FieldPut(FieldPos(cAlias+"_FILIAL"),xFilial(cAlias))
		MsUnlock()
		PA016AtuPai( M->AJZ_INSUMO )
	Else
		(cAlias)->(dbGoto(nRecAtu))
		RecLock(cAlias,.F.,.T.)
		dbDelete()
		MsUnlock()
	EndIf
Else
	If !lDeleta
		For nY := 1 To Len(aColsCM)
			If Empty( aColsCM[nY][nItemCod] )
				Loop
			EndIf
		
			If lAltera
				If aColsCM[nY][Len(aHeaderCM)+1]
					If (cAlias)->(dbSeek(xFilial(cAlias)+M->AJZ_INSUMO+aColsCM[nY][nItemA]))
						RecLock(cAlias,.F.,.T.)
						dbDelete()
						MsUnlock()
					EndIf
					Loop
				EndIf
				If (cAlias)->(dbSeek(xFilial(cAlias)+M->AJZ_INSUMO+aColsCM[nY][nItemA]))
					RecLock(cAlias,.F.)
				Else 
					RecLock(cAlias,.T.)
				EndIf
			Else
				If aColsCM[nY][Len(aHeaderCM)+1] == .F.
					RecLock(cAlias,.T.)
				Else
					Loop
				EndIf
			EndIf

			For nX := 1 To Len(aHeaderCM)
		      If aHeaderCM[nX][10] != "V"
					(cAlias)->(FieldPut(FieldPos(aHeaderCM[nX][2]),aColsCM[nY][nX]))
				EndIf
			Next nX
			AEK->AEK_FILIAL	:= xFilial(cAlias)
			AEK->AEK_INSUMO 	:= M->AJZ_INSUMO
			AEK->(MsUnlock())
		Next nY
	Else
		dbSelectArea(cAlias)
		(cAlias)->(dbSetOrder(1))
		If (cAlias)->(dbSeek(xFilial(cAlias)+M->AJZ_INSUMO))
			While !Eof() .And. AEK->AEK_INSUMO == M->AJZ_INSUMO
				RecLock(cAlias,.F.,.T.)
				dbDelete()
				MsUnlock()
				(cAlias)->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMA016Mem บAutor  ณPedro Pereira Lima  บ Data ณ  03/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCopia o conteudo do registro posicionado na tabela AJZ para บฑฑ
ฑฑบ          ณas variaveis de memoria da enchoice para que possa ser feitaบฑฑ
ฑฑบ          ณa copia do insumo selecionado.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMA016Mem(aCpo1Ench,aCpo2Ench)
Local nX

For nX := 1 To Len(aCpo1Ench)
	If AllTrim(aCpo1Ench[nX]) == "AJZ_INSUMO"
		Loop
	Else
		M->&(aCpo1Ench[nX]) := AJZ->&(aCpo1Ench[nX])
	EndIf
Next nX

For nX := 1 To Len(aCpo2Ench)
	M->&(aCpo2Ench[nX]) := AJZ->&(aCpo2Ench[nX])
Next nX

Return Nil

Function LINHAOK()
Local lRet := .T.

If Empty(oGetDados:aCols[Len(oGetDados:aCols)][aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "AEK_TPPARC"})]) .Or.;
	Empty(oGetDados:aCols[Len(oGetDados:aCols)][aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "AEK_SUBCOD"})]) .Or.;
	oGetDados:aCols[Len(oGetDados:aCols)][aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "AEK_QUANT"})] == 0
	lRet := .F.
EndIf

Return lRet

Function DELOK()
Return .T.

Function SUPERDEL()
Return .T.

Function FIELDOK()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPMS016Okณ Autor ณ Pedro Pereira Lima      ณ Data ณ 14/06/2009 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณValidacao TudoOk do cadastro de Insumos.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณPMSA016,SIGAPMS                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS016Ok(nOpc)
Local lRet		:= .T.
Local aArea 	:= GetArea()
Local aAreaAEH := AEH->(GetArea())
Local aAreaAJZ := AJZ->(GetArea())
Local nX

If nOpc <> 5
	For nX := 1 to len(aCpo1Ench)
		If X3Obrigat(aCpo1Ench[nX]) .And. Empty(M->&(aCpo1Ench[nX]))
			lRet:=.F.
		EndIf
	Next nX
	
	For nX := 1 to len(aCpo2Ench)
		If X3Obrigat(aCpo2Ench[nX]) .And. Empty(M->&(aCpo2Ench[nX]))
			lRet:=.F.
		EndIf
	Next nX

	If !lRet
		MsgAlert(STR0039)
	EndIf
EndIf

// valida o browse
If lRet
	lRet := A016GD1TudOk()
EndIf

RestArea(aAreaAJZ)
RestArea(aAreaAEH)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS016Col บAutor  ณPedro Pereira Lima  บ Data ณ  14/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche os valores de custo total do insumo do insumo no   บฑฑ
ฑฑบ          ณaCols da tela de cadastro de insumo.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSA016 - Cadastro de Insumos                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS016Col()
Local nQuant   := M->AEK_QUANT//oGetDados:aCols[n][aScan(oGetDados:aHeader,{ |x| x[2] == "AEK_QUANT"})]
Local nValUn   := oGetDados:aCols[n][aScan(oGetDados:aHeader,{ |x| x[2] == "AEK_UNITAR"})]
Local lAtualiza:= Iif(oGetDados:aCols[n][aScan(oGetDados:aHeader,{ |x| x[2] == "AEK_CSTITE"})] <> 0,.T.,.F.)
Local nValRet  := nQuant * nValUn 
Local nPConsum := 0
Local nPCusto  := 0
Local nPDMT    := 0
Local nPValor  := 0
                 
nParcela:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "AEK_TPPARC"})
nCstItem:= aScan(aHeader,{|x| AllTrim(x[2]) == "AEK_CSTITE"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula o valor do transporte.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If oGetDados:aCols[n][nParcela] == "M"
	If lAtualiza
		M->AJZ_MATERI -= oGetDados:aCols[n][nCstItem]	
		M->AJZ_MATERI += nValRet
	Else
		M->AJZ_MATERI += nValRet
	EndIf
ElseIf oGetDados:aCols[n][nParcela] == "N"
	If lAtualiza
		M->AJZ_MANUT -= oGetDados:aCols[n][nCstItem]
		M->AJZ_MANUT += nValRet			
	Else 
		M->AJZ_MANUT += nValRet	
	EndIf
ElseIf oGetDados:aCols[n][nParcela] == "H"
	If lAtualiza
		M->AJZ_MDO -= oGetDados:aCols[n][nCstItem]
		M->AJZ_MDO += nValRet		
	Else 
		M->AJZ_MDO += nValRet	
	EndIf
EndIf

oEnch2:Refresh()

Return .T. //nValRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS016Del บAutor  ณPedro Pereira Lima  บ Data ณ  06/15/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica as linhas deletadas do aCols e atualiza os campos  บฑฑ
ฑฑบ          ณcorrespondentes aos tipos de parcela na oEnch2.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPMSA016 - PMA016Inc()                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS016Del()
Local cTipoPcl := ""
Local cSinal := Iif(oGetDados:aCols[n][Len(oGetDados:aHeader)+1],"-","+")
cTipoPcl := oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEK_TPPARC"})]

Do case
	case cTipoPcl == "M"   
		If cSinal == "+"
			M->AJZ_MATERI -= oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEK_CSTITE"})]
		Else
			M->AJZ_MATERI += oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEK_CSTITE"})]
		EndIf		
	case cTipoPcl == "N"
		If cSinal == "+"
			M->AJZ_MANUT -= oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEK_CSTITE"})]
		Else
			M->AJZ_MANUT += oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEK_CSTITE"})]					
		EndIf
	case cTipoPcl == "H"		         
		If cSinal == "+"
			M->AJZ_MDO -= oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEK_CSTITE"})]
		Else
			M->AJZ_MDO += oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| x[2] == "AEK_CSTITE"})]
		EndIf					
EndCase           

oEnch2:Refresh()

ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJZ_MDO', 'AJZ_CUSTD' } )
ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJZ_MDO', 'AJZ_CUSTIM' } )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPA016Vld  บAutor  ณ Totvs              บ Data ณ  16/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o campo podera ser editado                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PA016Vld( cField )
	Local cGrpOrg	:= M->AJZ_GRORGA
	Local cTpParc	:= M->AJZ_TPPARC
	Local lRecurs	:= !Empty( M->AJZ_RECURS )
	Local lRet		:= .F.

	If lRecurs
		//lRet := cGrpOrg $ "A*B" .OR. cTpParc $ "1*2"
		If cGrpOrg == "A" .AND. cTpParc == "3" .AND. cField $ "AJZ_CUSTD|AJZ_CUSTIM|AJZ_MCUSTD|AJZ_GRORGA"
			lRet := .T.
		ElseIf cGrpOrg == "A" .AND. cTpParc == "1" .And. !(cField $ "AJZ_CUSTD|AJZ_CUSTIM")
			lRet := .T.
		EndIf

		If cGrpOrg == "B" .AND. cField $ "AJZ_CUSTD|AJZ_GRORGA"
			lRet := .T.
		EndIf

		If cGrpOrg == "A" .And. cTpParc == "2" .And. !(cField $ "AJZ_CUSTD|AJZ_CUSTIM")
			lRet := .T.
		EndIf
	Else
		lRet := cField == "AJZ_CUSTD"
	EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPma016VldExcบAutor  ณ Totvs            บ Data ณ  02/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o insumo podera ser excluido                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pma016VldExc( nReg )
	Local cInsumo	:= ""
	Local lRet		:= .T.
	
	// Verifica se o insumo eh subinsumo de outro
	DbSelectArea( "AJZ" )
	AJZ->( DbGoTo( nReg ) )
	cInsumo := AJZ->AJZ_INSUMO
	If !Empty( cInsumo ) .AND. AJZ->( !Eof() )
		DbSelectArea( "AEK" )
		AEK->( DbSetOrder( 2 ) )
		If AEK->( DbSeek( xFilial( "AEK" ) + cInsumo ) )
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		MsgAlert( STR0040 ) //"O insumo nใo pode ser excluido pois esta sendo usado em outro insumo!"
	EndIf

	// Verifica se o insumo esta sendo usado em alguma composicao auxiliar
	If lRet .AND. !Empty( Posicione( "AEH", 2, xFilial("AEH") + AJZ->AJZ_INSUMO, "AEH_INSUMO") )
		MsgAlert(STR0045) //"Nใo ้ possํvel excluir um insumo associado a uma composi็ใo!"
		lRet := .F.     
	EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณa205GD1LinOkณ Autor ณ Edson Maricate      ณ Data ณ 09-02-2001 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de validacao das Linhas da GetDados.                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณLinOk da GetDados 1.                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a016GD1LinOk()

Local nPosTipo		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEK_TPPARC" } )
Local nPosSubCod	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEK_SUBCOD"  } )
Local nPosQT		:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEK_QUANT"  } )
Local nContItem 	:= 1
Local lRet 			:= .T.

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosTipo])
		Aviso( STR0013, STR0042, { "Ok" } ) // "ษ necessแrio selecionar uma parcela!"
		lRet := .F.
	EndIf

	If Empty(aCols[n][nPosSubCod])
		Aviso( STR0013, STR0043, { "Ok" } ) // "ษ necessแrio informar um insumo!"
		lRet := .F.
	EndIf

	If lRet .AND. ( Empty(aCols[n][nPosQT]) .OR. aCols[n][nPosQT] == 0 )
		Aviso( STR0013, STR0044, { "Ok" } ) // "ษ necessแrio informar uma quantidade!"
		lRet := .F.
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณverifica duplicidade de insumos na composicao Aux.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lRet .AND. Len( aCols ) > 0 .AND. nPosSubCod > 0 .AND. !Empty( aCols[ n ][ nPosSubCod ] )
		For nContItem := 1 To Len( aCols )
			If !aCols[nContItem][Len(aHeader)+1]
				If n <> nContItem .AND. aCols[ n ][ nPosTipo ] + aCols[ n ][ nPosSubCod ]  == aCols[ nContItem ][ nPosTipo ] + aCols[ nContItem ][ nPosSubCod ]
					Aviso( STR0013, STR0041, { "Ok" } ) // "Nใo ้ permitido duplicidade de insumos no browse!"
					lRet := .F.
	
					Exit
				EndIf
			EndIf
		Next
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณpma016Recalcณ Autor ณ Totvs               ณ Data ณ 23-07-2009 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRecalcula os campos com base no custos atuais dos insumos     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณLinOk da GetDados 1.                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function pma016Recalc( nMDO, nMateri, nManut )
	// Se for um recurso do grupo A ou B e tipo de parcela 3, obtem o custo standard do recurso.
	If !Empty( M->AJZ_RECURS ) .AND. M->AJZ_GRORGA == "A" .AND. ( Empty( M->AJZ_TPPARC ) .OR. M->AJZ_TPPARC == "3" )
		If !Empty( M->AJZ_TPPARC ) .AND. M->AJZ_TPPARC <> "3"
			ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJZ_MDO', 'AJZ_CUSTD' } )
			ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJZ_MDO', 'AJZ_CUSTIM' } )
		EndIf
	Else
		M->AJZ_MDO		:= nMDO + ExecTemplate('CCTTrigg',.F.,.F.,{'','AJZ_HORANO','AJZ_MDO'})
		M->AJZ_MATERI	:= ExecTemplate('CCTTrigg',.F.,.F.,{'','AJZ_HORANO','AJZ_MATERI'})
		M->AJZ_MANUT 	:= ExecTemplate('CCTTrigg',.F.,.F.,{'M','AJZ_HORANO','AJZ_MANUT'})
		
		If !Empty( M->AJZ_TPPARC ) .AND. M->AJZ_TPPARC <> "3"
			ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJZ_MDO', 'AJZ_CUSTD' } )
			ExecTemplate( 'CCTTrigg',.F.,.F.,{ '', 'AJZ_MDO', 'AJZ_CUSTIM' } )
		EndIf
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ PA016Brw     ณ Autor ณ Totvs             ณ Data ณ 12/09/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Habilita/Desabilita o browse conforme o campo AJY_GRORGA   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PA016Brw()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณO browser deve estar habilitado somente se o conteudo do campoณ
	//ณAJY_GRORGA for A e tipo de parcela calculada (1)              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oGetDados:oBrowse:bGotFocus := { || oGetDados:lActive := ( Upper( M->AJZ_GRORGA ) == "A" .AND. M->AJZ_TPPARC == "1" ) }
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno   ณPA016IncSub  ณ Autor ณ Totvs                 ณ Data ณ 29.07.09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrioณ Inclui no array para exportar as sub-insumos                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PA016IncSub( cInsumo, aRecSel )
	Local aAreaAJZ		:= AJZ->( GetArea() )
	Local aAreaAEK		:= AEK->( GetArea() )

	DbSelectArea( "AEK" )
	AEK->( DbSetOrder( 1 ) )
	AEK->( DbSeek( xFilial( "AEK" ) + cInsumo ) )
	While AEK->( !Eof() ) .AND. AEK->( AEK_FILIAL + AEK_INSUMO ) == xFilial( "AEK" ) + cInsumo
		aAreaAEK	:= AEK->( GetArea() )
		If !Empty( AEK->AEK_SUBCOD ) // Protecao
			DbSelectArea( "AJZ" )
			AJZ->( DbSetOrder( 1 ) )
			If AJZ->( DbSeek( xFilial( "AJZ" ) + AEK->AEK_SUBCOD ) )
				aAdd( aRecSel, AJZ->( RecNo() ) )

				PA016IncSub( AEK->AEK_SUBCOD, @aRecSel )
			EndIf
		EndIf
		AEK->( RestArea( aAreaAEK ) )

		AEK->( DbSkip() )
	End

	AJZ->( RestArea( aAreaAJZ ) )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPA016Gatilhoบ Autor ณ Totvs               บ Data ณ 13/08/2009บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para gatilhar os campos do cadastro de insumo com os บฑฑ
ฑฑบ          ณ campos identicos ao cadastro de produtos/recursos.          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template CCT                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PA016Gatilho( lCarrega )
	Local aStruct	:= {}	
	Local cCodigo	:= ""
	Local cCampo	:= ""
	Local lReturn 	:= .T.
	Local lMsg		:= .T.
	Local nInc		:= 0
	
	Default lCarrega	:= .F.
	
	If Type("lDuplic") <> 'L'
		lDuplic := .F.
	EndIf

	If Empty( M->AJZ_PRODUT ) .AND. Empty( M->AJZ_RECURS )
		Return lReturn
	EndIf

	If INCLUI .And. !lCarrega
		lMsg	:= MsgYesNo( STR0046 )
	EndIf

	If lMsg
		If !Empty( M->AJZ_PRODUT )
			cCodigo := M->AJZ_PRODUT
			aStruct	:= SB1->( DbStruct() )	

			If INCLUI .AND. !lDuplic
				DbSelectArea( "SB1" )
				SB1->( DbSetOrder( 1 ) )
				If SB1->( DbSeek( xFilial( "SB1" ) + cCodigo ) )
					For nInc := 1 To Len( aStruct )
						cCampo := substr( aStruct[nInc][1], 4, 6 )
						If AJZ->( FieldPos( "AJZ_" + cCampo ) ) > 0
							M->&( "AJZ_" + cCampo ) := SB1->&(aStruct[nInc][1])
						EndIf
					Next
				EndIf
			EndIf
		ElseIf !Empty( M->AJZ_RECURS )
			cCodigo := M->AJZ_RECURS
			aStruct	:= AE8->( DbStruct() )	

			If INCLUI .AND. ( M->AJZ_TPPARC == "3" .OR. Empty( M->AJZ_TPPARC ) ) .AND. !lDuplic
				DbSelectArea( "AE8" )
				AE8->( DbSetOrder( 1 ) )
				If AE8->( DbSeek( xFilial( "AE8" ) + cCodigo ) )
					For nInc := 1 To Len( aStruct )
						cCampo := substr( aStruct[nInc][1], 5, 6 )
						If !( cCampo $ "TIPO*PRODUT" ) .AND. AJZ->( FieldPos( "AJZ_" + cCampo ) ) > 0
							M->&( "AJZ_" + cCampo ) := AE8->&(aStruct[nInc][1])
						EndIf
					Next
	
					M->AJZ_DESC		:= AE8->AE8_DESCRI
					M->AJZ_CUSTD	:= AE8->AE8_VALOR
					M->AJZ_TPCUSD	:= AE8->AE8_TPCUDI
					M->AJZ_TPCUSI	:= AE8->AE8_TPCUIN
				EndIf
			EndIf
		EndIf
	EndIf
	If M->AJZ_GRORGA <> 'A'
		M->AJZ_TPPARC := ''
	EndIf
Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPA016VldCod บ Autor ณ Totvs               บ Data ณ 31/08/2009บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para validar o codigo do sub-insumo.                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template CCT                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PA016VldCod()
	Local aAreaAJZ	:= AJZ->( GetArea() )
	Local aAreaAEK	:= AEK->( GetArea() )
	Local cCodAEK	:= M->AEK_SUBCOD
	Local lRet		:= M->AEK_SUBCOD <> M->AJZ_INSUMO
	
	DbSelectArea( "AEK" )
	AEK->( DbSetOrder( 1 ) )
	If AEK->( DbSeek( xFilial( "AEK" ) + cCodAEK ) )
		lRet := .F.
		MsgAlert( STR0047 )	// "Este insumo cont้m sub-insumos e nใo poderแ ser incluido na estrutura!"
	EndIf
	
	RestArea( aAreaAJZ )
	RestArea( aAreaAEK )
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA016GD1TudOkณ Autor ณ Totvs               ณ Data ณ 31-08-2009 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณTudOk da GetDados 1.                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A016GD1TudOk()
	Local lRet		:= .T.
	Local nx 		:= 0
	Local nPosSubCod:= 0
	
	Private aHeader	:= oGetDados:aHeader
	Private aCols	:= oGetDados:aCols

	nPosSubCod	:= aScan( aHeader, { |x| AllTrim( x[ 2 ] ) == "AEK_SUBCOD"  } )
	If nPosSubCod > 0
		For nx := 1 To Len( aCols )
			n := nx

			If !Empty( aCols[nx][nPosSubCod] )
				If !A016GD1LinOk()
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf
	
Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ PMA016Inv  ณ Autor ณ Marcelo Akama         ณ Data ณ 22/09/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Marca / Desmarca							  	         		ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PMA016Inv( cMarca, lTodos, oMark )
Local nReg := TRB->(Recno())

DEFAULT lTodos  := .T.

DbSelectArea( "TRB" )
If lTodos
	DbGoTop()
EndIf

While !lTodos .Or. !Eof()
	If TRB->OK == cMarca
		RecLock("TRB")
		Replace OK With Space(02)
		TRB->(MsUnlock())
	Else
		RecLock("TRB")
		Replace OK With cMarca
		TRB->(MsUnlock())
	EndIf

	If lTodos
		TRB->(dbSkip())
	Else
		Exit
	Endif
End

DbGoTo( nReg )

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ PA016AtuPai  ณ Autor ณ Marcelo Akama     ณ Data ณ 12/10/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Atualiza indices e custos dos insumos pais                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PA016AtuPai( cCodIns )
	Local aArea		:= GetArea()
	Local aAreaAEK	:= AEK->( GetArea() )
	Local aAreaAJZ	:= AJZ->( GetArea() )
	Local aAreaAJW	:= AJW->( GetArea() )
	Local aAreaAux
	Local aAreaAux2
	Local lMDO
	Local lMateri
	Local lManut
	Local nMDO
	Local nMateri
	Local nManut
	Local nCusto
	Local cInsumo
	
	DbSelectArea( "AJZ" )
	AJZ->( DbSetOrder( 1 ) )
	DbSelectArea( "AEK" )
	AEK->( DbSetOrder( 2 ) )
	AEK->( DbSeek( xFilial( "AEK" ) + cCodIns ) )
	Do While !AEK->(Eof()) .And. AEK->(AEK_FILIAL+AEK_SUBCOD)==xFilial( "AEK" ) + cCodIns
		If AJZ->( DbSeek(xFilial( "AJZ" ) + AEK->AEK_INSUMO) )
			aAreaAux := AEK->( GetArea() )
			aAreaAux2:= AJZ->( GetArea() )
			lMDO     := .F.
			lMateri  := .F.
			lManut   := .F.
			nMDO     := 0
			nMateri  := AJZ->AJZ_POTENC*AJZ->AJZ_VALCOM*AJZ->AJZ_COMBUS
			nManut   := ((AJZ->AJZ_AQUISI - AJZ->AJZ_RESIDU) * AJZ->AJZ_COEFMA) / (AJZ->AJZ_VIDAUT * AJZ->AJZ_HORANO)
			cInsumo  := AJZ->AJZ_INSUMO
			AEK->( DbSetOrder( 1 ) )
			AEK->( DbSeek( xFilial( "AEK" ) + cInsumo ) )
			Do While !AEK->(Eof()) .And. AEK->(AEK_FILIAL+AEK_INSUMO)==xFilial( "AEK" ) + cInsumo
				If AJZ->( DbSeek(xFilial( "AJZ" ) + AEK->AEK_SUBCOD) )
					nCusto := AJZ->AJZ_CUSTD * AEK->AEK_QUANT
					Do Case
						Case AEK->AEK_TPPARC='H'
							nMDO    += nCusto
							lMDO    := .T.
						Case AEK->AEK_TPPARC='M'
							nMateri += nCusto
							lMateri := .T.
						Case AEK->AEK_TPPARC='N'
							nManut  += nCusto
							lManut  := .T.
					EndCase
					RecLock("AEK", .F.)
					AEK->AEK_UNITAR := AJZ->AJZ_CUSTD
					AEK->AEK_CSTITE := nCusto
					MsUnlock()
				EndIf
				AEK->(dbSkip())
			EndDo
			RestArea( aAreaAux2 )

			RecLock("AJZ", .F.)
			If lMDO
				AJZ->AJZ_MDO    := nMDO
			EndIf
			If lMateri
				AJZ->AJZ_MATERI := nMateri
			EndIf
			If lManut
				AJZ->AJZ_MANUT  := nManut
			EndIf
			If AJZ->AJZ_GRORGA=='A' .And. AJZ->AJZ_TPPARC $ '1;2'
				dbSelectArea("AJW")
				AJW->(dbSeek(xFilial("AJW")+AJZ->AJZ_BCOMPO))
				AJZ->AJZ_CUSTD  :=	IIf(AJW->AJW_DEPREC $ "13", AJZ->AJZ_DEPREC, 0) +;
									IIf(AJW->AJW_JUROS  $ "13", AJZ->AJZ_VLJURO, 0) +;
									IIf(AJW->AJW_MDO    $ "13", AJZ->AJZ_MDO   , 0) +;
									IIf(AJW->AJW_MATERI $ "13", AJZ->AJZ_MATERI, 0) +;
									IIf(AJW->AJW_MANUT  $ "13", AJZ->AJZ_MANUT , 0)
				AJZ->AJZ_CUSTIM :=	IIf(AJW->AJW_DEPREC $ "23", AJZ->AJZ_DEPREC, 0) +;
									IIf(AJW->AJW_JUROS  $ "23", AJZ->AJZ_VLJURO, 0) +;
									IIf(AJW->AJW_MDO    $ "23", AJZ->AJZ_MDO   , 0)
			EndIf
			MsUnlock()
			
			RestArea( aAreaAux )
		EndIf
		AEK->(dbSkip())
	EndDo
	
	RestArea( aAreaAJW )
	RestArea( aAreaAJZ )
	RestArea( aAreaAEK )
	RestArea( aArea )
Return .T.
