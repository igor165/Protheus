#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'FINA010.ch'

#DEFINE SOURCEFATHER "FINA010"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010MEX
Cadastro de Natureza localizado para MÉXICO.

O fonte contém browse, menu, model e view propria, todos herdados do FINA010. 
Qualquer regra que se aplique somente para o MÉXICO deve ser definida aqui.

As validações e integrações realizadas após/durante a gravação estão definidas nos eventos do modelo, 
na classe FINA010EVMEX.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Function FINA010MEX()
Local oBrowse As Object
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Define o browse padrão para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse As Object 
	
	oBrowse := FwLoadBrw(SOURCEFATHER) 

Return oBrowse
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o model padrão para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel As Object
Local oEvent As Object
	
	oModel := FWLoadModel(SOURCEFATHER)
	oEvent := FINA010EVMEX():New()
	oModel:InstallEvent("MEXICO",,oEvent)
	
Return oModel
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view padrão para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView As Object

	oView := FWLoadView(SOURCEFATHER)

Return oView

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu padrão para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	As Array 
Local cStcFunc	As Character

	aRotina  := FWLoadMenuDef(SOURCEFATHER)
	cStcFunc := 'StaticCall(FINA010MEX, F010SldCTb)'
	aAdd(aRotina, { STR0011, cStcFunc, 0, 2  } ) //"Saldos Contábeis"
	
Return aRotina
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F010SldCtb
Cadastro de Natureza localizado para MÉXICO.

Botoes especificos da consulta de naturezas: Saldo da conta contabil relacionada a Natureza

@type function
 
@author Mauricio Pequim Jr
@since 23.11.2009
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function F010SldCtb()

LOCAL oDlg As Object

If !Empty (SED->ED_CONTA)
	
	//Saldo da conta contabil relacionada a Natureza
	//Saldo inicial ( ultimo dia do mes anterior )
	bSldCTBAnt	:= {||SaldoCT7(SED->ED_CONTA,FirstDay(dDatabase)-1,"01")}
	//Saldo atual ( database )
	bSldCTBAtu	:= {||SaldoCT7(SED->ED_CONTA,dDatabase,"01")}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorno SaldoCT7:                                    ³
	//³ [1] Saldo Atual (com sinal)                          ³
	//³ [2] Debito na Data                                   ³
	//³ [3] Credito na Data                                  ³
	//³ [4] Saldo Atual Devedor                              ³
	//³ [5] Saldo Atual Credor                               ³
	//³ [6] Saldo Anterior (com sinal)                       ³
	//³ [7] Saldo Anterior Devedor                           ³
	//³ [8] Saldo Anterior Credor                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario na EnchoiceBar                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "F010BUT" )
		bSldCTBAnt := ExecBlock( "F010BUT", .F., .F.,{1} )
		bSldCTBAtu := ExecBlock( "F010BUT", .F., .F.,{2} )
	EndIf
	
	aSaldosAnt := Eval(bSldCTBAnt)
	aSaldosAtu := Eval(bSldCTBAtu)
		
	cSalAnt :=  ValorCtb(aSaldosAnt[1],0,0,17,2,.T.,,,SED->ED_CONTA,,,,,.T.,.F.)
	cMovPer :=  ValorCtb(aSaldosAtu[1] - aSaldosAnt[1],0,0,17,2,.T.,,,SED->ED_CONTA,,,,,.T.,.F.)
	cSalAtu := 	ValorCtb(aSaldosAtu[1],0,0,17,2,.T.,,,SED->ED_CONTA,,,,,.T.,.F.)
	
	DEFINE MSDIALOG oDlg FROM 00,00 TO 120, 300 TITLE STR0012 PIXEL //"Saldo Contábil"
	@	003,003 	Say STR0013  OF oDlg PIXEL //"Saldo Anterior: "
	@	003,095	Say cSalAnt OF oDlg PIXEL
	@	015,003 	Say STR0014  OF oDlg PIXEL //"Movimento no periodo: "
	@	015,095	Say cMovPer OF oDlg PIXEL
	@	029,003 	Say STR0015  OF oDlg PIXEL //"Saldo Atual: "
	@	029,095	Say cSalAtu OF oDlg PIXEL
	
	@	001,001 TO 40,150 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 045,100	TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
Else

   Help("  ",1,"EMPTYCC",,STR0016,1,1) //"Conta contábil não preenchida para esta natureza"

Endif

Return nil