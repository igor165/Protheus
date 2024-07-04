#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"


//------------------------------------------------------------------
/*/{Protheus.doc} FISA153

Rotina da apuração da EFD Contribuições.
@author Erick G. Dias
@since 07/03/2018
@version 12.1.17
@description teste descrição
/*/
//------------------------------------------------------------------
Function FISA153()

	Local lVerpesssen 	:= Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Private oBrowse
	Private oPanelBrw
	Private cFsa200ALS  := ""
	Private cFsa200DESC := ""
	Private lPosPerRed 	:= .F.
	Private lPosPredRed := .F.
	Private lAutomato 	:= isBlind()

	If lVerpesssen
		If AliasIndic("F1A")

			DbSelectArea ("F10")
			DbSelectArea ("F11")
			DbSelectArea ("F12")
			DbSelectArea ("F13")
			DbSelectArea ("F14")
			DbSelectArea ("F15")
			DbSelectArea ("F16")
			DbSelectArea ("F17")
			DbSelectArea ("F18")
			DbSelectArea ("F19")
			DbSelectArea ("F1A")
			DbSelectArea ("F1B")
			DbSelectArea ("F1C")
			DbSelectArea ("F1D")
			DbSelectArea ("F1E")
			DbSelectArea ("SF2")
			DbSelectArea ("SD2")

			lPosPerRed := F1B->(FieldPos("F1B_PERRED")) > 0
			lPosPredRed := F1B->(FieldPos("F1B_PREDBC")) > 0
			
			If !lAutomato
				//Faz Chamada para verificação da carga inicial dos cadastros
				FwMsgRun(,{|oSay| CargaIni( oSay ) },"Processando carga inicial dos cadastros","")

				FWExecView("Apuração Simples Nacional",'FISA153', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  )//'Rotina de Apuração EFD Contribuições'
			Else

				CargaIni()
			
			EndIf
		Else
			Alert("Tabela F1A não existe no ambiente, favor verifique atualização da apuração do Simples Nacional")
		EndIf
	EndIf 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar" 							  	ACTION 'FSA200VISUALIZAR("1")' 	     OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE "Excluir"    							 	ACTION 'FSA200EXCLUIR'    			 OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE "Sobre"      							  	ACTION 'FSA153DATA()'    			 OPERATION 5 ACCESS 0 //'Editar'
ADD OPTION aRotina TITLE 'Gerar Movimentação Financeira' 		 	ACTION 'FSA200VISUALIZAR("2")' 		 OPERATION 5 ACCESS 0 //'Editar'
ADD OPTION aRotina TITLE 'Gerar Movimentação Financeira e Contábil' ACTION 'FSA200VISUALIZAR("3")' 	     OPERATION 5 ACCESS 0 //'Editar'

Return ( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStructABA := FWFormStruct( 1, 'F1A')

oModel	:=	MPFormModel():New('MODEL_ABA',,{|oModel| .T. },{|oModel| .T. })
oModel:AddFields( 'MODEL_ABA' ,, oStructABA )
oModel:SetPrimaryKey( { 'ABA_CMP1'} )
oModel:SetDescription( 'TOTVS')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel( 'FISA153' )
Local oView     := FWFormView():New()
Local oStruABA   := FWFormStruct( 2, 'F1A' )

oView:SetModel( oModel )

oView:AddField( 'VIEW_ABA', oStruABA, 'MODEL_ABA' )

oView:AddOtherObject( 'PANEL_TREE',  { |oPanel| MONTATREE( oPanel ) } )
oView:AddOtherObject( 'PANEL_EMPTY', { |oPanel| } )
oView:AddOtherObject( 'PANEL_BROWSE',{ |oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel ) } )

oView:EnableTitleView('PANEL_TREE',"Rotinas Disponíveis")//'Rotinas Disponíveis'

oView:CreateHorizontalBox( 'INFO_FUNC'	  	,00 )
oView:CreateHorizontalBox( 'EVENTO_FUNC'	,98 )
oView:CreateHorizontalBox( 'FIM_TELA'   	,02 )

oView:CreateVerticalBox( 'INFO_FUNC_ESQ'		, 100	,'INFO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_ESQ'		, 27	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_CENTER'	, 01	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_DIR'		, 72	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'FIM_TELA_EMPTY'		, 100	, 'FIM_TELA' )

oView:SetOwnerView( 'VIEW_ABA'		, 'INFO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_TREE'	, 'EVENTO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'EVENTO_FUNC_CENTER' )
oView:SetOwnerView( 'PANEL_BROWSE'	, 'EVENTO_FUNC_DIR' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'FIM_TELA_EMPTY' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
Função que cria tree com as rotinas disponíveis

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

STATIC FUNCTION MontaTree(oPanel)

Local oTree
Local aCoors := FWGetDialogSize( oPanel )
//Local bChange := { || Processa( { || FChgTree( oTree,oPanel )  }, "Processando", "" ) }
Local bChange := { || FChgTree( oTree,oPanel )  }

oTree := DbTree():New( aCoors[1] + 20 ,aCoors[2] +5,aCoors[3]-10,aCoors[4]-10, oPanel,bChange , , .T. )

oTree:AddTree( Padr("Rotinas do Simples Nacional",40), .T., "FOLDER5" ,"FOLDER6",,,"000" )
oTree:TreeSeek( "001" )
oTree:AddItem("Processar Apuração do Simples Nacional","001","PMSEDT3","",,,2)
oTree:AddItem("Cadastro de Anexos"                    ,"002","PMSEDT3","",,,2)
oTree:AddItem("Cadastro de Atividades"                ,"003","PMSEDT3","",,,2)
oTree:AddItem("Receitas Mensais"                      ,"004","PMSEDT3","",,,2)
oTree:AddItem("Encargos da Folha Mensais"             ,"005","PMSEDT3","",,,2)
oTree:AddItem("Limites e Sublimites"                  ,"006","PMSEDT3","",,,2)
oTree:AddItem("Alíquotas Efetivas"                    ,"007","PMSEDT3","",,,2)
oTree:AddItem("Saldos de Devoluções"                  ,"008","PMSEDT3","",,,2)
oTree:AddItem("Relatório Regime de Caixa"		      ,"009","PMSEDT3","",,,2)
oTree:AddItem("Relatório Sintético de Apuração"       ,"010","PMSEDT3","",,,2)
oTree:AddItem("Relatório Analítico de Apuração"       ,"011","PMSEDT3","",,,2)

return ()

//-------------------------------------------------------------------
/*/{Protheus.doc} FChgTree

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function FChgTree( oTree )

Local cIdTreePos := ""

Local aInfTree := {}

//Busco a identificação de qual item da Tree estamos posicionadoss
cIdTreePos := oTree:GetCargo()
oPanelBrw:FreeChildren()
oBrowse:DeActivate()
aInfTree := FSA200FUNC( cIdTreePos ,oTree)
FBrowseMon( oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4] )
oBrowse:Refresh()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function FBrowseMon( oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw )

Local aFields := {}
Local cFunc := "MethIsMemberOf"

Default cFonteTree := ""
Default cAliasTree := ""
Default cFiltroBrw := ""
Default cDescBrw   := ""

oBrowse := FWmBrowse():New()

If &cFunc.(oBrowse,"SetMainProc")
	oBrowse:SetMainProc("FISA153")
EndIf

If Empty( cFonteTree ) .And. Empty( cAliasTree )
	aInf := FSA200FUNC()

	cFonteTree := aInf[1]
	cAliasTree := aInf[2]
	cFiltroBrw := aInf[3]
	cDescBrw   := aInf[4]

	oBrowse:AddLegend( "F1A_STATUS == '1' " , "RED", "Apuração não gerou movimentações Financeiras e Contábeis" ) 
	oBrowse:AddLegend( "F1A_STATUS == '2' " , "BLUE", "Apuração gerou somente movimentação Financeira" ) 
	oBrowse:AddLegend( "F1A_STATUS == '3' " , "GREEN", "Apuração gerou movimentações Financeira e Contábil" )	

ElseIF  cAliasTree  == "F10"

	oBrowse:AddLegend( "Empty(F10_FIMVIG) .OR. F10_FIMVIG >= dDatabase" , "GREEN", "Vigente" ) // Vigente
	oBrowse:AddLegend( "!Empty(F10_FIMVIG) .OR. F10_FIMVIG < dDatabase ", "RED",   "Não Vigente" ) // Não vigente

ElseIF  cAliasTree  == "F1E"

	oBrowse:AddLegend( "F1E_APROV == '1'" , "GREEN", "Alíquotas Efetivas Aprovadas" ) // 
	oBrowse:AddLegend( "F1E_APROV <> '1'" , "RED", "Alíquotas Efetivas Não Aprovadas" ) // 
EndIf

oBrowse:SetOwner( oPanel )
oBrowse:SetDescription( cDescBrw )
oBrowse:SetAlias( cAliasTree )

oBrowse:SetMenuDef( cFonteTree )
oBrowse:DisableDetails()
oBrowse:SetFilterDefault( cFiltroBrw )

oBrowse:Activate()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA200FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA200FUNC( cIdTreePos ,oTree, aReprocess)

Local aRet   			:= Array( 04 )
Local aFil				:= {}
cFsa200DESC	:= ""
Do Case

	Case EmptY(cIdTreePos)
		aRet[1] := 'FISA153'
		aRet[2] := 'F1A'
		aRet[3] := ""
		aRet[4] := "Apuração do Simples Nacional"

	Case cIdTreePos == "001"
        IniciaApur()
		oTree:TreeSeek('000')

	Case cIdTreePos == "002" //Cadastro de Anexos
		cFsa200ALS   := ""
        aRet[1] 	:= 'FISA150'
		aRet[2] 	:= 'F10'
		aRet[3] 	:= ""
		aRet[4] 	:= "Cadastro de Anexos"

    Case cIdTreePos == "003" //Cadastro de Atividades
		cFsa200ALS   := ""
        aRet[1] 	:= 'FISA151'
		aRet[2] 	:= 'F12'
		aRet[3] 	:= "F12_FILIAL == '"  +   xFilial("F12") + "'"
		aRet[4] 	:= "Cadastro de Atividades"

    Case cIdTreePos == "004" // Receitas Anuais
		cFsa200ALS   := "F15"
		cFsa200DESC	:= "Receitas Mensais"
        aRet[1] 	:= 'FISA152'
		aRet[2] 	:= 'F15'
		aRet[3] 	:= "F15_FILIAL == '"  +   xFilial("F15") + "'"
		aRet[4] 	:= "Receitas Mensais"

	Case cIdTreePos == "005" //Encargos da Folha de Pagamento
		cFsa200ALS   := "F1C"
		cFsa200DESC	:= "Encargos da Folha de Pagamento"
        aRet[1] 	:= 'FISA152'
		aRet[2] 	:= 'F1C'
		aRet[3] 	:= "F1C_FILIAL == '"  +   xFilial("F1C") + "'"
		aRet[4] 	:= "Encargos da Folha de Pagamento"

	Case cIdTreePos == "006" //Limites Simples Nacional
		cFsa200ALS   := "F14"
        cFsa200DESC	:= "Limites do Simples Nacional"
		aRet[1] 	:= 'FISA152'
		aRet[2] 	:= 'F14'
		aRet[3] 	:= ""
		aRet[4] 	:= "Limites do Simples Nacional"

	Case cIdTreePos == "007" //Alíquotas Efetivas
        cFsa200ALS  := ""
		aRet[1] 	:= 'FISA155'
		aRet[2] 	:= 'F1E'
		aRet[3] 	:= ""
		aRet[4] 	= "Alíquotas Efetivas"

	Case cIdTreePos == "008" // Saldos de Devoluções
		cFsa200ALS  := "F1D"
		cFsa200DESC	:= "Saldos de Devoluções"
        aRet[1] 	:= 'FISA152'
		aRet[2] 	:= 'F1D'
		aRet[3] 	:= "F1D_FILIAL == '"  +   xFilial("F1D") + "'"
		aRet[4] 	= "Saldos de Devoluções"

	Case cIdTreePos == "009" // Relatório
		FISR153B()
		oTree:TreeSeek('000')
	Case cIdTreePos == "010" // Relatório
		FISR153()
		oTree:TreeSeek('000')
	Case cIdTreePos == "011" // Relatório
		FISR153A()
		oTree:TreeSeek('000')
	OtherWise
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	= ""
EndCase

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA200ALIAS
Função utilizada para retornar alias do modelo genériuco FISA152.

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA200ALIAS()
Return Iif (type("cFsa200ALS") == 'C', cFsa200ALS, "")

Function FSA200DESC()
Return Iif (type("cFsa200DESC") == 'C', cFsa200DESC, "")

Static Function IniciaApur()

Local aFil		:= {}
Local lProc		:= .T.
Local cIdApur	:= ""
Local lOK 		:= .F.
Local cIdAnt    := ""
Local cLimI     := ""
Local cLimE     := ""
Local cSubLimI  := ""
Local cSubLimE  := ""
Local nX        := 0
Local nFilImped := 0
Local aAreaSM0 	:= SM0->(GetArea())

//Verifica o compartilhamento das tabelas e exibe mensagem alertadndo usuário
ChkCompTab()

F18->( DbSetOrder ( 3 ) )

IF Pergunte("FSA153", !lAutomato)
	
	//trecho que verifica se já existe apuração realizada no período
	IF !Empty( GetIdApurMatriz(  FSA200DataApur ( mv_par01 )  ) ) //Se não houver ID então apuração não foi processada ainda para esta filial e período.
		lProc:= .F.
		If !lAutomato .AND. ( ApMsgYesNo("Apuração já foi realizada neste período." + CHR(10)+CHR(13) + "Deseja fazer o reprocessamento?" ) )

			lProc	:= ChkTit()

			cIdApur	:= F1A->F1A_ID //Utilizará este ID para excluir as informações das tabelas de apuração e iniciar nova apuração.
		EndIF
	EndIF

	//------------------------------------------------------
	//Pergunta para o usuário quais filiais deverão ser consideradas no processamento
	//------------------------------------------------------
	IF lProc 
		aFil := IIF(!lAutomato, GetFilial( .T. ), {{cEmpAnt, cFilAnt}})
	EndIF

	// Verifico se as filiais selecionadas para processamento estão ou não
	// impedidas de recolher os tributos pelo SIMPLES. Se estiverem impeço
	// o usuário de continuar a apuração.

	//Somente irá seguir se houver ao menos 1 filial no selecionada
	If Len(aFil) > 0

		//Retornar id da apuração anterior
		cIdAnt	:= IdApurAnt(  MonthSub( FSA200DataApur ( mv_par01 ) , 1 ) )

		// Se encontrou apuração no mês anterior...
		If cIdAnt <> ""

			For nX := 1 to Len(aFil)
				SM0->(DbGoTop ())
				SM0->(MsSeek (aFil[nX][1]+aFil[nX][2], .T.))
				cFilAnt := FWGETCODFILIAL
				// Chama função para buscar status da apuração do período anterior.
				BuscaStatus( cIdAnt, FirstDay( MonthSub( FSA200DataApur ( mv_par01 ), 1 ) ) , @cLimI, @cLimE, @cSubLimI, @cSubLimE )
				// Se os status do sublimite e limite (interno ou exportação) foram excedidos em mais de 20%...
				If ((cLimI == "3" .And. cSubLimI == "3") .Or. (cLimE == "3" .And. cSubLimE == "3"))
					nFilImped++
				EndIf
			Next nX

			RestArea (aAreaSM0)
			cFilAnt := FWGETCODFILIAL

		EndIf

		// Se todas as filiais selecionadas estão impedidas de apurar pelo SIMPLES interrompo o processamento.
		If lProc .AND.  nFilImped > 0 .And. nFilImped == Len(aFil)

			MsgStop("Atenção! As filiais selecionadas para processamento ultrapassaram os limites para recolhimento dos tributos pelo SIMPLES NACIONAL em mais de 20% no último mês de apuração." + Chr(13) + Chr(10) + ;
					"Os tributos deverão ser apurados através das rotinas específicas de apuração.")

		ElseIF lProc
			
			If !lAutomato
				
				FwMsgRun(,{|oSay| ApurSimNac( oSay, aFil, cIdApur, @lOk ) },"Processando Apuração do Simples Nacional","")
			
			Else
				
				ApurSimNac( Nil, aFil, cIdApur, @lOk )

			EndIf

			If lOk .AND. !lAutomato
				//-----------------------------------------
				//Chama a tela para visualizar a apuração.
				//-----------------------------------------
				FISA154( alltrim(str(mv_par03)), .F. , "1" )
			EndIF
		EndIf

	EndIF

EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcApur
Função principal de apuração

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function ApurSimNac( oSay, aFil, cIdApur, lOk )

Local cVldSx1	:= ""
Local INTERNO 	:= "1"
Local EXTERNO 	:= "2"
Local FOLHA 	:= "5"
Local cRegime	:= ""

Local nX 		:= 0
Local aAreaSM0 	:= SM0->(GetArea())
Local nRBT12I	:= 0 //Mercado interno
Local nRBT12E	:= 0//mercado externo
Local nRBAI		:= 0//RBA interno
Local nRBAE		:= 0//RBA externo
Local nFsp12	:= 0
Local nFsp  	:= 0
Local nTotRPA	:= 0
Local cLimI		:= "1"
Local cLimE		:= "1"
Local cSubLimI	:= "1"
Local cSubLimE	:= "1"
Local aReceita 	:= {}
Local cIdAnt		:= ""
Local cMes		:= ""
Local cAno		:= ""
Local aDevol    := {}
Local aSldDev   := {}
Local nRpaI 	:= 0
Local nRpaE 	:= 0
Local nTotRpaI 	:= 0
Local nTotRpaE 	:= 0
Local nRpaApurI	:= 0
Local nRpaApurE	:= 0
Local nTotalTrib := 0
Local aDevSaldo := {}
local aAlqEfet 	:= {}

Begin Transaction

AtualizaMsg( oSay, "Iniciando processamento da Apuração")

//Obtem o ID da Apuração. Este ID será utilizado para referenciar todas as tabelas de apuração.
cIdApurMatriz	:= FWUUID("F1A")

cRegime	:= alltrim(str(mv_par03))

//Retornar id da apuração anterior
cIdAnt	:= IdApurAnt(  monthsub( FSA200DataApur ( mv_par01 ) ,1 ) )

cMes	:= Month2Str( FSA200DataApur ( mv_par01 ) )
cAno	:= Year2Str( FSA200DataApur ( mv_par01 ) )

IF len(aFil) > 0

	//Limpa as tabelas axuliares de apuração do período
	If !Empty(cIdApur)
		AtualizaMsg( oSay, "Limpando tabelas de Apuração")
		ClearApu(cIdApur, FSA200DataApur ( mv_par01 ))
	EndIF

	ExcluiTab("F15", , FSA200DataApur ( mv_par01 ))
	//------------------------------------------------------
	//Inclui nova tabela principal de apuração com novo ID
	//------------------------------------------------------
	GravaF1A( FSA200DataApur ( mv_par01 ) , cIdApurMatriz, cRegime, 0, 0, 0, 0, 0,0,0,0 )

	AtualizaMsg( oSay, "Buscando Receitas da Filial dos últimos 12 meses...")
	//----------------------------------------------------------------------
	//Obtem o valor da RBT12 do mercado interno e do mercado Externo
	//----------------------------------------------------------------------
	nRBT12I		+= FSA154SREC( FSA154RBT( FSA200DataApur ( mv_par01 ), INTERNO, , .F. ) )
	nRBT12E		+= FSA154SREC( FSA154RBT( FSA200DataApur ( mv_par01 ), EXTERNO, , .F. ) )

	//--------------------------------------------------------------
	//Obtem o valor da RBA do mercado interno e do mercado Externo
	//--------------------------------------------------------------
	nRBAI		+= FSA154SREC( FSA154RBT( STOD( Str( year( FSA200DataApur(MV_PAR01) ) + 1 ,4 ) + "0101" ), INTERNO, , .F.,Month(FSA200DataApur(MV_PAR01)) ) )
	nRBAE		+= FSA154SREC( FSA154RBT( STOD( Str( year( FSA200DataApur(MV_PAR01) ) + 1 ,4 ) + "0101" ), EXTERNO, , .F.,Month(FSA200DataApur(MV_PAR01)) ) )

	//--------------------------------------------------------------
	//Obtem o valor da da folha de salários dos últimos 12 meses
	//--------------------------------------------------------------
	nFsp12	+= FSA154SREC( FSA154FSP12( FSA200DataApur(MV_PAR01), .F.  ) )
	nFsp    += FSA154SREC( FSA154FSP12( FSA200DataApur(MV_PAR01), .T.  ) )

EndIF
//-----------------------------------------------------------------
//Primeiro Laço das filiais para obter o RBT12 de todas as filiais
//-----------------------------------------------------------------

For nX := 1 to Len(aFil)

	//Posiciona na filial
	SM0->(DbGoTop ())
	SM0->(MsSeek (aFil[nX][1]+aFil[nX][2], .T.))
	cFilAnt := FWGETCODFILIAL

	//-----------------------------------
	//Processamento das receitas internas
	//-----------------------------------
	AtualizaMsg( oSay, "Processando Receitas da Filial: " + cFilAnt)

	nTotRpaI	:= ProcApur( INTERNO, @aReceita, @aDevol, cRegime )
	nRpaI		+= nTotRpaI  //Aqui tem somente o RPA do período
	nRBAI		+= nTotRpaI //Aqui tem o RPA dos meses anteriores e do período

	//-----------------------------------
	//Processamento das receitas externas
	//-----------------------------------
	nTotRpaE	:= ProcApur( EXTERNO, @aReceita, @aDevol, cRegime )
	nRpaE		+= nTotRpaE //Aqui tem somente o RPA do período
	nRBAE 		+= nTotRpaE //Aqui tem o RPA dos meses anteriores e do período

Next nX

//SALDO_DEVOLUCOES
// Abato o valor das devoluções das respectivas receitas
If AliasIndic("F1D")

	// Inicializando o array de saldos de devolução com os valores para utilização no mês de apuração
	SaldoDev(@aSldDev, Month2Str(FSA200DataApur(mv_par01)), Year2Str(FSA200DataApur(mv_par01)), "INICIALIZAR")

	// Primeiro vou atualizar as receitas utilizando os saldos dos períodos anteriores.
	AtuRecDev(@aReceita, @aSldDev)

	// Depois vou atualizar as receitas utilizando as devoluções do período.
	AtuRecDev(@aReceita, @aDevol)

	// Por fim atualizo novamente os saldos para posterior gravação
	SaldoDev(@aSldDev, Month2Str(FSA200DataApur(mv_par01)), Year2Str(FSA200DataApur(mv_par01)), "ATUALIZAR", aDevol)

EndiF

//Aqui totaliza o valor da RPA de todas as filiais processadas
nTotRPA	:= GetTotRPA( aReceita )

//Ordena o Array de recitas antes de iniciar apuração
//aSort(aReceita,,,{|x,y| x[1]+x[5] < y[1]+y[5] }) 

//----------------------------------------------------------------------------------------
//Segundo laço das filiais passando os valores de receitas para a classe de apuração.
//----------------------------------------------------------------------------------------
For nX := 1 to Len(aFil)

	SM0->(DbGoTop ())
	SM0->(MsSeek (aFil[nX][1]+aFil[nX][2], .T.))
	cFilAnt := FWGETCODFILIAL

	//Receitas Mercado Interno
	GrvAlqAnexo(cAno, cMes, nRBT12I, nRBAI, (nRBT12I + nRBT12E), nFsp, nFsp12, cLimI, cSubLimI, nTotRPA  )

	AtualizaMsg( oSay, "Apurando Receitas da Filial: " + cFilAnt)

	//Chama função para buscar status da apuração do período anterior.
	BuscaStatus( cIdAnt, FirstDay( MonthSub( FSA200DataApur ( mv_par01 ), 1 ) ) , @cLimI, @cLimE, @cSubLimI, @cSubLimE )

	//Realiza apuração das receitas do mercado interno
	Apurar( INTERNO , aReceita, nRBT12I, nRBAI, cIdApurMatriz, (nRBT12I + nRBT12E), nFsp12, nFsp, cLimI, cSubLimI, nTotRPA, nRpaI, cRegime, @nRpaApurI, @nTotalTrib  )

	//Realiza apuração das receitas do mercado interno
	Apurar( EXTERNO , aReceita, nRBT12E, nRBAE, cIdApurMatriz, (nRBT12I + nRBT12E), nFsp12, nFsp, cLimE, cSubLimE, nTotRPA, nRpaE, cRegime, @nRpaApurE, @nTotalTrib  )

	//---------------------------------------------------------------
	//Query para trazer as alíquotas efetivas calculadas no período
	//---------------------------------------------------------------
	aAlqEfet 	:= PreparaAlqEfet( cIdApurMatriz )

	//-----------------------------------------------------------------------
	//Laço para gravar as alíquotas efetivas em todas as filiais processadas
	//-----------------------------------------------------------------------
	GravaF16( cAno, cMes , aAlqEfet )	

Next nX

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

//Grava F15 para mercado Interno
GravaF15( FSA200DataApur ( mv_par01 ), INTERNO, Iif( cRegime =="1" ,  nRpaApurI , nRpaI )   )

//Grava F15 para mercado Externo
GravaF15( FSA200DataApur ( mv_par01 ), EXTERNO, Iif( cRegime =="1" ,  nRpaApurE , nRpaE )   )

//Atualiza a F1A com os valores processados
GravaF1A( FSA200DataApur ( mv_par01 ) , cIdApurMatriz, cRegime, nRBT12I, nRBT12E, nRpaApurI, nRpaApurE, nFsp12, nRBAI, nRBAE, nTotalTrib )

//Grava F1D - Saldos de devolução
If Len(aSldDev) > 0
	GravaF1D(cIdApurMatriz, aSldDev)
EndIf

AtualizaMsg( oSay, "Encerrando Transação de Banco")
End Transaction
AtualizaMsg( oSay, "Transação Encerrada com Sucesso")

lOk	:= .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcReceita
Função que irá processa as receitas do período e adicionar na apuração

@author Erick G Dias
@since 06/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ProcReceita( cAliasQry, oApuracao, aReceita, cOpRec, oBjRecNf, cFiltro, lDevol )

Local cCodSubAtv    := ''
Local oReceita      := Nil
Local nRbtm 		:= 0
Local nX			:= 0
Local cRegime		:= alltrim(str(mv_par03))
Local nValBrut      := 0

DEFAULT lDevol := .F.

Do While !(cAliasQry)->(Eof ())

	IF cFiltro  == "RECEITA_CAIXA"

		//Popula Objeto receitanf com informações da nota fiscal no regime de competência
		RecNfCaixa( cAliasQry, oBjRecNf, @aReceita, cOpRec )
		nRbtm += oBjRecNf:getValBrut()
	Else
        //--------------------------------------------------
        //Classifica receita e obte código de sub atividade
        //--------------------------------------------------
        oBjRecNf:Clear()
		oBjRecNf:setCodAtv( (cAliasQry)->F12_CODATV 	)

		// Tratamento diferenciado para devoluções pois não há nenhum campo na tabela SD1 que corresponda
		// ao D2_VALBRUT. Desta forma sempre é necessário "compor" o que seria o D2_VALBRUT para poder fazer
		// a dedução da devolução corretamente. O ideal era ter um campo correspondente na SD1...
		If lDevol
			// (Total do item + frete + seguro + despesas + IPI + ICMS-ST) - Desconto
			nValBrut := ((cAliasQry)->D1_TOTAL + (cAliasQry)->D1_VALFRE + (cAliasQry)->D1_SEGURO + (cAliasQry)->D1_DESPESA + (cAliasQry)->D1_VALIPI + (cAliasQry)->NICMSRET) - (cAliasQry)->D1_VALDESC
		Else
			nValBrut := (cAliasQry)->VALBRUT	
		EndIf
		
		If !(cAliasQry)->F4_INCSOL $"A,N,D" 
			oBjRecNf:setVALBRUT( nValBrut - (cAliasQry)->NICMSRET - (cAliasQry)->VALIPI )
		Else
			oBjRecNf:setVALBRUT( nValBrut - (cAliasQry)->VALIPI )
		EndIF

		oBjRecNf:setAnexo( (cAliasQry)->F13_ANEXO 		)
		oBjRecNf:setICMSRET( (cAliasQry)->NICMSRET 		)
		oBjRecNf:setTpServ( (cAliasQry)->F13_TPSERV 	)
		oBjRecNf:setFatorR( (cAliasQry)->F13_FATORR 	)
		oBjRecNf:setCfop( (cAliasQry)->F13_CFOP     	)		
		oBjRecNf:setCCodMun(  xFisCodIBGE( (cAliasQry)->A1_EST ) + (cAliasQry)->A1_COD_MUN 	)		
		oBjRecNf:setMunPres( xFisCodIBGE( (cAliasQry)->C5_ESTPRES ) + (cAliasQry)->C5_MUNPRES 	)
		oBjRecNf:setRecIss( (cAliasQry)->F2_RECISS 		)
		oBjRecNf:setCsosn( (cAliasQry)->F4_CSOSN 		)		
		oBjRecNf:setAnexoSub( (cAliasQry)->F13_ASUB 	)		
		oBjRecNf:setMepLes( (cAliasQry)->B1_MEPLES 		)		

        Atv2SubAtv ( oBjRecNf )

        IF !Empty( oBjRecNf:getSubAtv() )

            AgrupaReceita( @aReceita, oBjRecNf, cOpRec,cRegime)

        EndIF

    EndIF
	
	IF cFiltro  <> "RECEITA_CAIXA" 
		nRbtm += oBjRecNf:getValBrut()
	EndIF

	(cAliasQry)->(DbSkip ())

EndDo

//Fecha a query
DbSelectArea (cAliasQry)
(cAliasQry)->(DbCloseArea())

Return nRbtm

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaApur
Função responsável por gravar apuração do Simples Nacional

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravaApur( oApuracao, nRBTM, cTpRec, cIdApurMatriz, nRPAMes, cRegime, nTotalTrib )

Local cIdApur		:= ""
Local cCodtrib		:= ""
Local cCodSubAtv	:= ""
Local cCodAtv 		:= ""
Local cTpReceita	:= ""
Local cLim			:= 	oapuracao:getStatusLimite()
Local cSubLim		:= 	oapuracao:getStatusSublimite()
Local cAnexo		:= ""
Local cRegime		:= alltrim(str(mv_par03))
Local cRegraISS		:= ""
Local aAtributos	:= oapuracao:getTributos()
Local aAtividades	:= oapuracao:getAtividades()
Local aSubAtividades:= {}
Local nFatorR		:= oapuracao:getFatorR()
Local nIrpj			:= 0
Local nCSLL			:= 0
Local nCOFINS		:= 0
Local nPis			:= 0
Local nCPP			:= 0
Local nIPI			:= 0
Local nICMS			:= 0
Local nISS			:= 0
Local nTributo		:= 0
Local nTotRec		:= 0
Local nTotTrib		:= 0
Local nX 			:= 0
Local nY 			:= 0

cIdApur		:= GetIdApur( cIdApurMatriz ) //Busca ID da F18

//---------------------------------------
//Faz laço nas Atividades processadas
//---------------------------------------
For nX:=1 to Len( aAtividades )

	nTotRec		 	+=	aatividades[nx]:getReceita() 			//Total da receita da atividade
	cCodAtv 		:=  aatividades[nx]:getCodigo()	 			//Código da atividade
	aSubAtividades	:=  aatividades[nX]:getSubAtividades() 		//Lista das sub atividades

	//--------------------------------------------------------
	//Faz laço nas Sub Atividades da Atividade posicionada
	//--------------------------------------------------------
	For nY:= 1 to Len( aSubAtividades )

		aAtributos	:= aSubAtividades[nY]:getTributos()	//Lista de tributos da sub atividade posicionada
		cCodSubAtv	:= aSubAtividades[nY]:getCodigo()	//Código da Sub Atividade
		cAnexo		:= aSubAtividades[nY]:getAnexo()	//Anexo da Sub Atividade
		cRegraISS	:= aSubAtividades[nY]:getRegraISS() // Código da regra utilizado para o ISS (F17_ISS)

		//--------------------------
		//Processa Sub Atividade
		//--------------------------
		ProcSubAtv( cIdApurMatriz, oapuracao:getDataIni(), cCodAtv, cCodSubAtv, aAtributos, aSubAtividades[nY]:getreceita(), cAnexo , aSubAtividades[nY]:getRecBruta(), aSubAtividades[nY]:getValorDevolucoes(), cTpRec, oApuracao:getStatusSublimite(), oapuracao:getStatusLimite(), cRegraISS, oApuracao )

	Next nY

Next nX

//---------------------------------------------------------------------------------------
//Obtem o valor total dos tributos  calculados de todas as atividade e sub atividades
//---------------------------------------------------------------------------------------
ValTributo ( oApuracao:getTributos(), @nIrpj, @nCSLL, @nCOFINS, @nPis, @nCPP, @nIPI, @nICMS, @nISS, , .F. )

//-----------------------------------
//Grava informações na tabela F18
//-----------------------------------
GravaF18( cIdApur,  oapuracao:getDataIni(), nTotRec, nIrpj, nCSLL, nCOFINS, nPis, nCPP, nICMS, nIPI, nISS, cLim, cSubLim, nFatorR, cTpRec, cIdApurMatriz, oapuracao:getLimite(), oapuracao:getSubLimite(), @nTotalTrib  )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF19
Função responsálve por gravar as informações da F19

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravaF19( cIdApurMatriz, dPer, cCodAtv,  cCodSubAtv, nIrpj, nCSLL, nCOFINS, nPis,  nCPP , nIPI, nICMS, nISS, nTotal, nReceita, cAnexo, nTotDev, nRecBru, cTpRec )

RecLock('F19',.T.)

F19->F19_FILIAL  := xFilial("F19")
F19->F19_ID    	 := FwUUID("F19")
F19->F19_IDAPUR  := cIdApurMatriz
F19->F19_PER     := dPer
F19->F19_CODATV  := cCodAtv
F19->F19_SUBATV  := cCodSubAtv
F19->F19_IRPJ    := nIrpj
F19->F19_CSLL    := nCSLL
F19->F19_COFINS  := nCOFINS
F19->F19_PIS     := nPis
F19->F19_CPP     := nCPP
F19->F19_IPI     := nIPI
F19->F19_ICMS    := nICMS
F19->F19_ISS     := nISS
F19->F19_TOTAL   := nTotal
F19->F19_TOTREC	 := nReceita
F19->F19_ANEXO	 := cAnexo
F19->F19_TOTDEV	 := nTotDev
F19->F19_RECBRU	 := nRecBru
F19->F19_TPREC	 := cTpRec

F19->(msUnlock())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSubAtv
Função responsável por processar a Sub Atividade

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ProcSubAtv( cIdApurMatriz, dPer, cCodAtv,  cCodSubAtv, aAtributos, nReceita, cAnexo, nRecBru, nTotDev, cTpRec, cStatusSub, cStatusLim, cRegraISS, oApuracao )

Local nIrpj			:= 0
Local nCSLL			:= 0
Local nCOFINS		:= 0
Local nPis			:= 0
Local nCPP			:= 0
Local nIPI			:= 0
Local nICMS			:= 0
Local nISS			:= 0
Local cCodtrib		:= ''
Local nTributo		:= 0
Local nTotTrib		:= 0

Default cRegraISS	:= ''

//--------------------------------------------------
//Obtem o valor total dos tributos da Sub Atividade
//--------------------------------------------------
ValTributo ( aAtributos, @nIrpj, @nCSLL, @nCOFINS, @nPis, @nCPP, @nIPI, @nICMS, @nISS, @nTotTrib, .T., cAnexo, cIdApurMatriz, dPer, cCodSubAtv, cRegraISS, oApuracao )

//--------------------------------------------------
//Aqui tenho todas as informações para gravar F19
//--------------------------------------------------
GravaF19( cIdApurMatriz, dPer, cCodAtv,  cCodSubAtv, nIrpj, nCSLL, nCOFINS, nPis, nCPP, nIPI, nICMS, nISS, nTotTrib, nReceita, cAnexo, nTotDev, nRecBru, cTpRec )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ClearApu
Função que limpará as tabelas de apuração antes de iniciar uma nova apuração

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ClearApu( cIdApur, dPer )

ExcluiTab("F1E", cIdApur, dPer)
ExcluiTab("F15", cIdApur, dPer)
ExcluiTab("F16", cIdApur, dPer)
ExcluiTab("F18", cIdApur, dPer)
ExcluiTab("F19", cIdApur, dPer)
ExcluiTab("F1A", cIdApur, dPer)
ExcluiTab("F1B", cIdApur, dPer)
ExcluiTab("F1D", cIdApur, MonthSum(dPer,1))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DeletaTab
Função que faz delete nas tabelas de apuração.

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function DeletaTab( cAlias, cIdApur, nOrd, dPer )

Local cCampoId	:= Iif(cAlias == "F1A"  , '_ID' ,  '_IDAPUR')

DbSelectArea ( cAlias )
( cAlias )->( DbSetOrder ( nOrd ) )

If cAlias == "F15"

	//Limpa tabela de apuração
	If ( cAlias )->( DbSeek(xFilial(cAlias) + dTos( dPer ) ) )
		Do While ( cAlias )->( !Eof() .And.  (calias)->&((cAlias+'_FILIAL')) == xFilial( cAlias ) .And. (calias)->&((cAlias+'_PER')) ==  dPer  )

			RecLock( cAlias,.F. )
			( cAlias )->(dbDelete())
			MsUnLock()
			( cAlias )->(FKCommit())

			( cAlias )->(DbSkip ())
		EndDo
	EndIf
Else

	//Limpa tabela de apuração
	If ( cAlias )->( DbSeek(xFilial(cAlias) + cIdApur ) )
		Do While ( cAlias )->( !Eof() .And.  (calias)->&((cAlias+'_FILIAL')) == xFilial( cAlias ) .And. (calias)->&((cAlias+cCampoId)) == cIdApur )

			RecLock( cAlias,.F. )
			( cAlias )->(dbDelete())
			MsUnLock()
			( cAlias )->(FKCommit())

			( cAlias )->(DbSkip ())
		EndDo
	EndIf

EndIF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA200VISUALIZAR
Função para visualização de apuração selecionada

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Function FSA200VISUALIZAR ( cOp )

mv_par01:=  F1A->F1A_MES  + F1A->F1A_ANO

If cOp $"2/3" .AND. F1A->F1A_STATUS $ "2/3"	
	Alert("Apuração já gerou título, não será possível realizar esta operação.")

Else
	FISA154( F1A->F1A_REGIME, .T., cOp )

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA200EXCLUIR
Função que irá deletar apuração

@author Erick G Dias
@since 09/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Function FSA200EXCLUIR ()

Local cIdApur	:= F1A->F1A_ID
Local dPerApur	:= FSA200DataApur ( F1A->F1A_MES + F1A->F1A_ANO )

If  ApMsgYesNo( "Deseja realmente excluir apuração?" )

	If ChkTit()

		//Deleta tabela principal
		DeletaTab( "F1A", cIdApur, 2, dPerApur )

		//Deleta as demais tabelas da apuração.
		ClearApu( cIdApur, dPerApur )

		MsgInfo( "Apuração excluída com sucesso!" )

	EndIF
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaObjApur
Função que inicia a classe de Apuração

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function CriaObjApur(cFil, cUf, dDtIni, dDtFim)

Local oApuracao	:= nil
oApuracao := FISA153APURACAO():new()
//Popula objeto
oApuracao:setUF( cUf )
oApuracao:setDataIni( dDtIni )
oApuracao:setDataFim( dDtFim )

Return oApuracao

//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaObjApur
Função que destroi a classe de Apuração

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function LimpaObjApur( oApuracao )

oApuracao:clear()
FSA153DOBJ(oApuracao)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaReceita
Função responsável por fazer query das notas fiscais conforme o filtro desejado

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function BuscaReceita( oApuracao , cOpRec, cFiltro, aReceita, oBjRecNf, lDevol )

Local cAliasQry  	:= ""
Local nReceita		:= 0

DEFAULT lDevol := .F.

//Realiza query para trazer as notas fiscais com receita conforme definição com os cadastros das atividades e sub atividades
cAliasQry   := oApuracao:execQuery( cFiltro, { cOpRec , FSA200DataApur ( mv_par01 ) } )

//Classifica as receitas nas sub atividades correspondentes
nReceita	:= ProcReceita( cAliasQry, oApuracao, @aReceita, cOpRec, oBjRecNf, cFiltro, lDevol )

Return nReceita


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcApur
Função responsável por chamar funções das receitas de CFOP, Código ISS e grupo de produtos,
composição da RBT12 e apuração, conforme indicador da opção de receita.

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ProcApur( cOpRec, aReceita, aDevol, cRegime )

Local nRbtm 	:= 0
Local oApuracao	:= CriaObjApur( cFilAnt , SuperGetMv("MV_ESTADO" ,.F., "" )  , FSA200DataApur ( mv_par01 ) , LastDay(FSA200DataApur ( mv_par01 ) ) ) //Cria novo objeto da apuração
Local nValDev 	:= 0
Local oBjRecNf  := FISA153RECEITANF():new()
 
If cRegime == "2"
	//------------------------------------------------------------------
	//Executa query para compor o RPA considerando as baixas do período
	//------------------------------------------------------------------
	 BuscaReceita( oApuracao , cOpRec, "RECEITA_CAIXA", @aReceita, oBjRecNf )

EndIF

//-------------------------------------------------
//Processa as receitas com origem de CFOP
//-------------------------------------------------
nRbtm   +=  BuscaReceita( oApuracao , cOpRec, "RECEITA_CFOP", @aReceita, oBjRecNf  )

//-------------------------------------------------
//Processa as receitas com origem de código de ISS
//-------------------------------------------------
nRbtm  +=  BuscaReceita( oApuracao , cOpRec, "RECEITA_GRUPO", @aReceita, oBjRecNf  )

//-------------------------------------------------
//Processa as receitas com origem de grupo de produtos
//-------------------------------------------------
nRbtm  +=  BuscaReceita( oApuracao , cOpRec, "RECEITA_ISS", @aReceita, oBjRecNf  )

//-------------------------------------------------
//Processa as devoluções - Apenas para CFOP (mercadoria)
//-------------------------------------------------
If cRegime == "1" // Somente chama devoluçõe no regime de competência
	nValDev += BuscaReceita( oApuracao , cOpRec, "DEVOLUCOES_CFOP", @aDevol, oBjRecNf, .T. )
EndIF

// Abato o valor das devoluções da receita
If nRbtm >= nValDev
	nRbtm -= nValDev
Else
	nRbtm := 0
EndIf

//-------------------------------------------------
//Destroi objeto de apuração
//-------------------------------------------------
LimpaObjApur( oApuracao )

FSA153DOBJ(oBjRecNf)

Return nRbtm

//-------------------------------------------------------------------
/*/{Protheus.doc} Atv2SubAtv
Função que classifica a atividade em código de sub atividade

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function Atv2SubAtv ( oObjRecNf )

Local cCodSubAtv	:= ""
Local cCodMunEmp	:= Alltrim(SM0->M0_CODMUN)//Código de município do contribuinte
Local cCodMunNF		:= ""
Local cRetIss		:= ""
Local cCodTransp	:= "5351/5352/5353/5354/5355/5356/5357/5359/5360/6351/6352/6353/6354/6355/6356/6357/6359/6360"
Local cCodCOmu		:= "5301/5302/5303/5304/5305/5306/5307/6301/6302/6303/6304/6305/6306/6307"
Local cCfop 		:= ""
Local lIcmsSt		:= .F.

If oObjRecNf:getCodAtv() == "01"
	//--------------------------------------------------------------
	//Para esta atividade deve classificar se possui ou não ICMS ST
	//--------------------------------------------------------------
	IF oObjRecNf:getICMSRET() > 0
		//Se tem ICMS ST o contribuinte é Substituto
		cCodSubAtv	:= "0101"
	ElseIf oObjRecNf:getCsosn() == "500" //Se não tem ICMS ST, pode ser Substituído ou não ter ICMS ST, por este motivo irei verificar o CSON
		//ICMS Pago anteriormente, condição de Substituído
		cCodSubAtv	:= "0102"
	Else
		//Se não tem ICMS ST na nota e não foi recolhido anteriormente, então não existe ICMS ST na cadeia
		cCodSubAtv	:= "0101"
	EndIF

ElseIf oObjRecNf:getCodAtv()== "02"
	//--------------------------------------------------------------
	//Esta AStividade possui somente 1 sub atividade
	//--------------------------------------------------------------
	cCodSubAtv  := "0201"

ElseIf oObjRecNf:getCodAtv() == "03"
	//--------------------------------------------------------------
	//Para esta atividade deve classificar se possui ou não ICMS ST
	//--------------------------------------------------------------
	IF oObjRecNf:getICMSRET() > 0
		//Se tem ICMS ST o contribuinte é Substituto
		cCodSubAtv	:= "0301"
	ElseIf oObjRecNf:getCsosn() == "500" //Se não tem ICMS ST, pode ser Substituído ou não ter ICMS ST, por este motivo irei verificar o CSON
		//ICMS Pago anteriormente, condição de Substituído
		cCodSubAtv	:= "0302"
	Else
		//Se não tem ICMS ST na nota e não foi recolhido anteriormente, então não existe ICMS ST na cadeia
		cCodSubAtv	:= "0301"
	EndIF

ElseIf oObjRecNf:getCodAtv() == "04"
	//--------------------------------------------------------------
	//Esta AStividade possui somente 1 sub atividade
	//--------------------------------------------------------------
	cCodSubAtv  := "0401"

ElseIf oObjRecNf:getCodAtv() == "05"
	//--------------------------------------------------------------
	//Esta AStividade possui somente 1 sub atividade
	//--------------------------------------------------------------
	cCodSubAtv  := "0501"

ElseIf oObjRecNf:getCodAtv() == "06"
	//--------------------------------------------------------------
	//Esta AStividade possui somente 1 sub atividade
	//--------------------------------------------------------------
	cCodSubAtv  := "0601"

ElseIf oObjRecNf:getCodAtv() == "07"	

	//Verifica se o serviço possui Iss retido e/ou Iss é devido no município do contribuinte
	cRetIss	:= IssRetMun( cCodMunEmp, oObjRecNf )

	//Primeiro verifica se é sujeito ao anexo 04
	If  oObjRecNf:getTpServ() == "1"
		//Escritprios contábeis autorizados pela legislação.
		cCodSubAtv	:= "0701"

	ElseIf oObjRecNf:getAnexo() == "04"
		//Sujeito ao anexo IV

		IF cRetIss == "1" //Sujeiro anexo IV com retenção
			cCodSubAtv	:= "0710"
		ElseIF cRetIss == "2" //Anexo IV sem retenção e devido no mesmo município
			cCodSubAtv	:= "0709"
		ElseIF cRetIss == "3" //Anexo IV sem retenção e devido em outroo município
			cCodSubAtv	:= "0708"
		EndIF

	ElseIF oObjRecNf:getAnexo() == "03" .AND. oObjRecNf:getFatorR() <> "1"
		//Sujeiro anexo III e não sujeito ao fator R

		IF cRetIss == "1" //anexo III sem fator R e com retenção
			cCodSubAtv	:= "0707"
		ElseIF cRetIss == "2" //Anexo III sem fator R sem retenção iss no mesmo município
			cCodSubAtv	:= "0706"
		ElseIF cRetIss == "3" //Anexo III sem fator R sem retenção iss outro município
			cCodSubAtv	:= "0705"
		EndIF

	Elseif oObjRecNf:getFatorR() == "1"

		IF cRetIss == "1" //anexo III com fator R e com retenção
			cCodSubAtv	:= "0704"
		ElseIF cRetIss == "2"//Anexo III com fator R sem retenção iss no mesmo município
			cCodSubAtv	:= "0703"
		ElseIF cRetIss == "3" //Anexo III com fator R sem retenção iss outro município
			cCodSubAtv	:= "0702"
		EndIF

	EndIF

ElseIf oObjRecNf:getCodAtv() == "08"

	//Verifica se o serviço possui Iss retido e/ou Iss é devido no município do contribuinte
	cRetIss	:= IssRetMun( cCodMunEmp, oObjRecNf )

	//Primeiro verifica se é sujeito ao anexo 03
	IF oObjRecNf:getAnexo() == "03" .AND. oObjRecNf:getTpServ() == "2"

		IF cRetIss == "1" //anexo III e com retenção é código 03
			cCodSubAtv	:= "0803"
		ElseIF cRetIss == "2"//Anexo III  sem retenção iss no mesmo município código 02
			cCodSubAtv	:= "0802"
		ElseIF cRetIss == "3" //Anexo III sem retenção iss outro município 01
			cCodSubAtv	:= "0801"
		EndIF

	ElseIf oObjRecNf:getAnexo() == "04"  .AND. oObjRecNf:getTpServ() == "2"

		IF cRetIss == "1" //anexo IV  com retenção é código 06
			cCodSubAtv	:= "0806"
		ElseIF cRetIss == "2"//Anexo IV sem retenção iss no mesmo município código 05
			cCodSubAtv	:= "0805"
		ElseIF cRetIss == "3" //Anexo IV sem retenção iss outro município 04
			cCodSubAtv	:= "0804"
		EndIF

	ElseIF  oObjRecNf:getTpServ() == "3" //serviços dos sub itens 16.1

		IF cRetIss == "1" //anexo IV  com retenção é código 06
			cCodSubAtv	:= "0809"
		ElseIF cRetIss == "2"//Anexo IV sem retenção iss no mesmo município código 05
			cCodSubAtv	:= "0808"
		ElseIF cRetIss == "3" //Anexo IV sem retenção iss outro município 04
			cCodSubAtv	:= "0807"
		EndIF

	EndIF

ElseIf oObjRecNf:getCodAtv() == "09"

	IF oObjRecNf:getTpServ() == "1"
		//Serviço contábil autorizados pela legislação a pagar o ISS em valor fixo.
		cCodSubAtv	:= "0901"
	ElseIf oObjRecNf:getAnexo() == "04"
		//Anexo IV é código 03
		cCodSubAtv	:= "0904"
	ElseIf oObjRecNf:getAnexo() == "03" .AND. oObjRecNf:getFatorR() <> "1"
		//Anexo III não sujeito ao fator R é código 02
		cCodSubAtv	:= "0903"
	ElseIF oObjRecNf:getFatorR() == "1"
		//Sujeito ao fator R é código 01
		cCodSubAtv	:= "0902"	
	EndIF

ElseIf oObjRecNf:getCodAtv() == "10"

	If oObjRecNf:getAnexo() == "03" .AND. oObjRecNf:getTpServ() == "2"
		//Anexo III é código 01
		cCodSubAtv	:= "1001"
	ElseIf oObjRecNf:getAnexo() == "04" .AND. oObjRecNf:getTpServ() == "2"
		//Anexo IV é código 02
		cCodSubAtv	:= "1002"
	EndIF

ElseIf oObjRecNf:getCodAtv() == "11"

	cCfop	:=	AllTrim(oObjRecNf:getCfop())

	lIcmsSt	:= .F.
	IF oObjRecNf:getICMSRET() > 0
		//Possui valor de ICMS ST
		lIcmsSt	:= .T.
	EndIF

	IF cCfop $ cCodTransp
		//Cfop de Transporte
		If lIcmsSt
			//Se tem ICMS ST o contribuinte é Substituto, logo é o código 01
			cCodSubAtv	:= "1101"
		ElseIf oObjRecNf:getCsosn()	== "500" //Se não tem ICMS ST, pode ser Substituído ou não ter ICMS ST, por este motivo irei verificar o CSON
			//ICMS Pago anteriormente, condição de Substituído
			cCodSubAtv	:= "1102"

		Else
			//Se não tem ICMS ST na nota e não foi recolhido anteriormente, então não existe ICMS ST na cadeia, então é código 01
			cCodSubAtv	:= "1101"
		EndIF

	ElseIF cCfop $ cCodComu
		//Cfop de Comunicação
		If lIcmsSt
			//Se tem ICMS ST o contribuinte é Substituto, logo é o código 03
			cCodSubAtv	:= "1103"
		ElseIf oObjRecNf:getCsosn()	== "500" //Se não tem ICMS ST, pode ser Substituído ou não ter ICMS ST, por este motivo irei verificar o CSON
			//ICMS Pago anteriormente, condição de Substituído
			cCodSubAtv	:= "1104"

		Else
			//Se não tem ICMS ST na nota e não foi recolhido anteriormente, então não existe ICMS ST na cadeia, então é código 01
			cCodSubAtv	:= "1103"
		EndIF

	EndIF

ElseIf oObjRecNf:getCodAtv() == "12"

	cCfop	:=	AllTrim(oObjRecNf:getCfop())

	IF cCfop $ cCodTransp
		//Cfop de Transporte
		cCodSubAtv	:= "1201"

	ElseIF cCfop $ cCodComu
		//Cfop de Comunicação
		cCodSubAtv	:= "1202"
	EndIF

Else

	//Atividade cadastrada manualmente pelo cliente, terá somente 1 sub atividade
	//deverá posicionar na tabela F13 para obter o código da Sub Atividade
	F17->( DbSetOrder ( 2 ) )
	//Verifica se já existe F18 gravada no período
	If F17->( DbSeek ( xFilial('F17') + oObjRecNf:getCodAtv() ) )
		cCodSubAtv	:= F17->F17_SUBATV
	EndIF
	F17->( DbSetOrder ( 1 ) )

EndIF

oObjRecNf:setSubAtv( cCodSubAtv )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ValTributo
Função que percorre a lista de tributos e retorna o valor de
cada um os tributos da lista

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ValTributo ( aAtributos, nIrpj, nCSLL, nCOFINS, nPis, nCPP, nIPI, nICMS, nISS, nTotTrib, lGravaF1B, cAnexo, cIdApurMatriz, dPer, cCodSubAtv, cRegraISS, oApuracao )

Local nX				:= 0
Local cCodtrib			:= ""
Local nTributo			:= 0
Local nAlqTrib			:= 0
Local nISSExced			:= 0
Local nPerc				:= 0
Local nBase				:= 0
Local nTribTotal        := 0
Local nTribDif          := 0

Default nTotTrib		:= 0
Default cAnexo			:= ""
Default cIdApurMatriz	:= ""
Default dPer			:= cTod("  /  /    ")
Default cCodSubAtv		:= ""
Default cRegraISS		:= ""

For nX	:= 1 to Len(aAtributos)

	nAlqTrib	:= aAtributos[nX]:getAliquota()
	cCodtrib	:= aAtributos[nX]:getCodigo()
	nTributo	:= aAtributos[nX]:getValor()

	If cRegraISS == "3"
		nISSExced := aAtributos[nX]:getISSExced()
		nPerc     := aAtributos[nX]:getPerc()
		nBase     := aAtributos[nX]:getBase()

		//Quando há diferença de valores, recalculo os valores já gravados no objeto oApuracao
		nAlqTrib  :=  nAlqTrib - ( nISSExced * ( nPerc / 100 ) ) 
		nTribDif  := nTributo - (nBase * nAlqTrib)
		nTributo  := nBase * nAlqTrib

		aAtributos[nX]:SetAliquota( nAlqTrib )
		aAtributos[nX]:SetValor( nTributo )

		nTribTotal := oApuracao:getTributos(cCodtrib):GetValor() - nTribDif

		oApuracao:setTributos(oApuracao:getTributos(), cCodtrib, nTribTotal)
	EndIf

	nTotTrib 	+= nTributo

	If cCodtrib == "IRPJ"
		nIrpj	+=  nTributo
	ElseIf cCodtrib == "CSLL"
		nCSLL	+= nTributo
	ElseIf cCodtrib == "COFINS"
		nCOFINS	+= nTributo
	ElseIf cCodtrib == "PIS"
		nPis	+= nTributo
	ElseIf cCodtrib == "CPP"
		nCPP	+= nTributo
	ElseIf cCodtrib == "IPI"
		nIPI	+= nTributo
	ElseIf cCodtrib == "ICMS"
		nICMS	+= nTributo
	ElseIf cCodtrib == "ISS"
		nISS	+= nTributo
	EndIF

	If lGravaF1B
		//Grava tabela F1B
		GravaF1B( cIdApurMatriz, month2str(dPer), Year2str(dPer), cCodSubAtv, aAtributos[nX], aAtributos[nX]:getMemoria(), nTributo )
	EndIF

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF18
Função responsável por gravar a tabela F18

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravaF18( cIdApur, dPer, nTotRec, nIrpj, nCSLL, nCOFINS, nPis, nCPP, nICMS, nIPI, nISS, cLim, cSubLim, nFatorR, cTpRec, cIdApurMatriz, nLimite, nSubLimite, nTotalTrib )

F18->( DbSetOrder ( 3 ) )
//Verifica se já existe F18 gravada no período
If F18->( DbSeek ( xFilial('F18') + cIdApurMatriz ) )
	RecLock('F18',.F.)
Else
	RecLock('F18',.T.)
	F18->F18_FILIAL     := xFilial("F18")
	F18->F18_ID     	:= cIdApur
	F18->F18_PER	    := dPer
	F18->F18_FATORR		:= nFatorR
	F18->F18_IDAPUR		:= cIdApurMatriz
	F18->F18_ESTABE		:= cFilAnt
	F18->F18_VALLIM		:= nLimite
	F18->F18_VALSUB		:= nSubLimite

EndIf

F18->F18_VALREC     += nTotRec
F18->F18_IRPJ 	    += nIrpj
F18->F18_CSLL 	    += nCSLL
F18->F18_COFINS	    += nCOFINS
F18->F18_PIS 	    += nPis
F18->F18_CPP 	    += nCPP
F18->F18_ICMS 	    += nICMS
F18->F18_IPI 	    += nIPI
F18->F18_ISS 	    += nISS

nTotalTrib += nIrpj + nCSLL + nCOFINS + nPis + nCPP + nIPI + nICMS + nISS

//Status dos limites
IF cTpRec == "1"
	//Mercado Interno
	F18->F18_LIMITE     := cLim
	F18->F18_SUBLIM     := cSubLim
ElseIF cTpRec == "2"
	//Mercado Externo
	F18->F18_LEXT  	    := cLim
	F18->F18_SUBEXT     := cSubLim
EndIF

F18->(msUnlock())

Return

//------------------------------------------------------------------
/*/{Protheus.doc} GravaF1A

Função responsável por gravar a tabela de apuração F1A

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function GravaF1A( dPer, cIdMatriz, cRegime, nRBT12I, nRBT12E, nRpaI, nRpaE, nFS12, nRBAI, nRBAE, nTotalTrib )
F1A->(DbSetOrder (2))

//Verifica se já existe F19 gravada no período
If F1A->( DbSeek(xFilial("F1A")+  cIdMatriz ) )
	RecLock('F1A',.F.)

	F1A->F1A_RBT12I		+= nRBT12I
	F1A->F1A_RBT12E		+= nRBT12E
	F1A->F1A_RPAI		+= nRpaI
	F1A->F1A_RPAE		+= nRpaE
	F1A->F1A_FS12		+= nFS12
	F1A->F1A_RBAI		+= nRBAI
	F1A->F1A_RBAE		+= nRBAE	
	F1A->F1A_TRIB  		+= nTotalTrib	

	F1A->(msUnlock())
Else
	RecLock('F1A',.T.)

	F1A->F1A_FILIAL     := xFilial("F1A")
	F1A->F1A_ID     	:= cIdMatriz
	F1A->F1A_MES		:= month2str(dPer)
	F1A->F1A_ANO		:= Year2str(dPer)
	F1A->F1A_REGIME		:= cRegime
	F1A->F1A_RBT12I		:= nRBT12I
	F1A->F1A_RBT12E		:= nRBT12E
	F1A->F1A_RPAI		:= nRpaI
	F1A->F1A_RPAE		:= nRpaE
	F1A->F1A_FS12		:= nFS12
	F1A->F1A_RBAI		:= nRBAI
	F1A->F1A_RBAE		:= nRBAE
	F1A->F1A_STATUS		:= "1" //Não gerou título e contabilizações

	F1A->(msUnlock())

EndIf

F1A->(DbSetOrder (1))

Return

//------------------------------------------------------------------
/*/{Protheus.doc} IdApurAnt

Função que buscará ID da apuração anterior

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function IdApurAnt( dPer )

Local cId		:= ""

F1A->( DbSetOrder ( 1 ) )

If F1A->( DbSeek(xFilial("F1A") + Year2str(dPer) + Month2Str(dPer)  ) )
	cId	:= F1A->F1A_ID
EndIF

Return cId

//------------------------------------------------------------------
/*/{Protheus.doc} BuscaStatus

Função buscará o status da apuração do período anterior, para que possa
enviar para a classe o status do siblimite e limite anterior.
Caso o status seja que ultrapassou limite em até 20%, não será mais 
permitido continuar com apuração.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function BuscaStatus( cIdAnt, dPer, cLimI, cLimE, cSubLimI, cSubLimE )

If !Empty( cIdAnt ) .AND. F18->( DbSeek(xFilial("F18")+  cIdAnt ) )

	cLimI		:= F18->F18_LIMITE
	cSubLimI	:= F18->F18_SUBLIM
	cLimE		:= F18->F18_LEXT
	cSubLimE	:= F18->F18_SUBEXT

Else
	//Caso não exista apuração anterior adotará status 1
	cLimI := cLimE	:= cSubLimI	:= cSubLimE	:= "1"

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetIdApur
Função responsável por obter o ID da F18

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GetIdApur( cIdApurMatriz )

Local cId := FWUUID("F18")

//Verifica se já existe F18 gravada no período
If F18->( DbSeek ( xFilial('F18') + cIdApurMatriz ) )
	cId	:= F18->F18_ID
EndIF

Return cId

Static Function GetIdApurMatriz( dPer )

Local cId := ""

If F1A->( DbSeek(xFilial("F1A")+  Year2str(dPer) + month2str(dPer) ) )
	cId	:= F1A->F1A_ID
EndIF

Return cId

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF15
Função responsável por gravar a receita na tabela F15

@author Erick G Dias
@since 08/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravaF15( dPer, cTpRec, nRBTM )

RecLock('F15',.T.)
F15->F15_FILIAL     := xFilial("F15")
F15->F15_ID     	:= FWUUID("F15")
F15->F15_MES	    := month2str( dPer)
F15->F15_ANO	    := Year2str( dPer )
F15->F15_TPREC      := cTpRec
F15->F15_VALOR 	    := nRBTM
F15->(msUnlock())


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IssRetMun
Identifica se o serviço possui ISS retido, e se o ISS é devido no ´município
do contribuinte.

@author Erick G Dias
@since 09/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function IssRetMun( cCodMunEmp,  oObjRecNf )

Local cRet	:= "" //1=Iss retido, 2=Iss devido mesmo município; 3=Iss devido outro município
Local cMumServ	:= ""

If oObjRecNf:getRecIss() == "1"
	//Possui retenção de ISS
	cRet	:= "1"
Else
	
	//Precisa definir se o ISS é devido no muniícipo do prestador ou não
	IF !EmptY( oObjRecNf:getMunPres() )
		//O município do pedido de venda terá maior prioridade
		cMumServ	:= oObjRecNf:getMunPres()

	ElseIf oObjRecNf:getMepLes() == "1" //EP
		//Iss devido no estabelecimento do Prestador, considera mesmo município
		cMumServ	:= cCodMunEmp

	ElseIF oObjRecNf:getMepLes() == "2" //LES
		//Iss devido no local da execção do serviço, considera município do cliente
		cMumServ	:= oObjRecNf:getCCodMun() 

	Else	
		//Se nada anteriormente estiver preenchido, adotarei o código de município do estabelecimento do prestador
		cMumServ	:= cCodMunEmp
	EndIf	

	If AllTrim(cCodMunEmp) == AllTrim(cMumServ)
		//Iss é devido no município do estabelecimento do prestador
		cRet	:= "2"
	Else
		//Iss é devido em outro município
		cRet	:= "3"
	EndIF

EndIF

Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} GravaF1B

Função responsável por gravar tabela F1B de memória de cálculo

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function GravaF1B( cIdApur, cMes, cAno, cCodSubAtv, oTributo, aMemoria, nValor )

Local cTrib    := oTributo:getCodigo()
Local nValParc := oTributo:getBase()
Local nEfetTb  := oTributo:getAliquota()
Local cTpParc  := oTributo:getTipoTributo()

Local nRecEnq  := 0
Local cAnexo   := ""
Local cFaixa   := ""
Local nAlqNom  := 0
Local nValDed  := 0
Local nEfet    := 0
Local nParttb  := 0

Default nValor   := oTributo:getValor()

If Len(aMemoria) > 0
	nRecEnq  := aMemoria[2]
	cAnexo   := aMemoria[3]
	cFaixa   := aMemoria[4]
	nAlqNom  := aMemoria[5]
	nValDed  := aMemoria[6]
	nEfet    := aMemoria[7]
	nParttb  := aMemoria[8]
	nPerRedBC:= aMemoria[9]
	nPerRedIC:= aMemoria[10]

	RecLock('F1B',.T.)

	F1B->F1B_FILIAL  	 := xFilial("F1B")
	F1B->F1B_ID    	 	 := FwUUID("F1B")
	F1B->F1B_IDAPUR  	 := cIdApur				//Id da apuração.
	F1B->F1B_SUBATV      := cCodSubAtv			//Código da Sub Atividade
	F1B->F1B_MES     	 := cMes				//Mês de processamento
	F1B->F1B_ANO   	 	 := cAno				//Ano de processamento
	F1B->F1B_TPPARC   	 := cTpParc 			//Tipo da parcela: Não excedeu sublimite, excedeu sublimite e excedeu limite
	F1B->F1B_VLPARC   	 := nValParc 			//VAlor da parcela de cálculo
	F1B->F1B_TRIB   	 := CodTrib( ctrib )	//tributo
	F1B->F1B_RECENQ   	 := nRecEnq				//receita utilizada para enquadrar a faixa do anexo
	F1B->F1B_ANEXO   	 := cAnexo				//anexo
	F1B->F1B_FAIXA   	 := cFaixa				//número da faixa enquadrada
	F1B->F1B_ALQNOM   	 := nAlqNom * 100		//Alíquota nominal geral
	F1B->F1B_VALDED   	 := nValDed				//valor da dedução
	F1B->F1B_EFET   	 := nEfet   * 100		//alíquota efetiva geral
	F1B->F1B_PARTTB   	 := nParttb * 100		//valor da partilha do tributo
	F1B->F1B_EFETTB   	 := nEfetTb * 100		//alíquota efetiva do tributo
	F1B->F1B_VALOR   	 := nValor				//valor do tributo
	If lPosPredRed
		F1B->F1B_PREDBC      := nPerRedBC			// Redução de Base de Cálculo
	EndIf
	If lPosPerRed
		F1B->F1B_PERRED      := nPerRedIC			// Percentual de Redução de Base de Cálculo da CIA
	EndIf

	F1B->(msUnlock())

EndIF

Return

//------------------------------------------------------------------
/*/{Protheus.doc} GetFilial

Função que fará tratamento das filiais selecionadas pelo usuário, e que 
serão consideradas na apuração

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function GetFilial( lPergunta )

Local aFil	:= {}
Local aSM0	:= {}
Local aAreaSM0	:= {}
Local nFil	:= 0


//lpergunrta indica se deverá ser exibda a tela para o usuário selecionar quais filiais deverão ser processadas
//Se lPergunta estiver .F., a função retornará todas as filiais da empresa sem exibir a tela para usuário.
If lPergunta

	If mv_par02 == 1
		//chama função para usuário escolher filial
		aFil:= MatFilCalc( .T. )
		If len(aFil) ==0
			MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
		EndiF
	EndIF

Else
	
	aFil:= MatFilCalc( .F. )

EndIF

IF lPergunta .AND. mv_par02 <> 1
	//Adiciona filial logada para realizar o processamento
	AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
EndIF

IF  Len(aFil) > 0

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")
	//--------------------------------------------------------
	//Irá preencher aSM0 somente com as filiais selecionadas
	//pelo cliente
	//--------------------------------------------------------

	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof())
			nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. (aFil[nFil][1] .OR. !lPergunta) .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf

	SM0->(RestArea(aAreaSM0))
EndIF

Return  aSM0

//------------------------------------------------------------------
/*/{Protheus.doc} FSA200DataApur

Função que converte a data em MM/AAAA em campo tipo de data

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function FSA200DataApur( cData )
Return cToD("01/" + SubStr(cData, 1, 2) + "/" + SubStr(cData, 3, 4))

//------------------------------------------------------------------
/*/{Protheus.doc} Apurar

Esta função é quem chamará o método de apurar da classe de apuração. 
Passará todas as informações necessárias para que a classe possa
realizar os cálculo, e consumirá o retorno das infromações, disparando
as funções de gravação.
Esta função será chamada duas vezes, uma vez para tratar as receitas
do mercado interno, e a segunda vez para tratar as receitas do mercado
externo.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function Apurar( cTpRec , aReceita, nRBT12, nRBA, cIdApurMatriz, nRbt12R, nFsp12, nFsp, cLim, cSubLim, nTotRPA, nRPAMes, cRegime, nRpaApur, nTotalTrib  )

Local oApuracao	:= CriaObjApur( cFilAnt , SuperGetMv("MV_ESTADO",.F.,"") , FSA200DataApur ( mv_par01 ) , LastDay(FSA200DataApur ( mv_par01 ) ) ) //Cria novo objeto da apuração
Local oReceita	:= nil
Local nCont		:= 0
Local nX		:= 0

//Passa o valor total do RBT12 de todas as filiais
oApuracao:setRBT12( nRBT12 )

//Passa o RBA somado de todas as filiais
oApuracao:setRBA(  nRBA   )

//RBTA interno e externo somados para cálculo do fator R
oApuracao:setrbt12r(  nRbt12R   )

//Valor da folha de pagamento do período
oApuracao:setFSPA(  nFsp   )

//VAlor da folha de pagamento dos últimos 12 meses
oApuracao:setFS12(  nFsp12   )

//Início de atividades da filial
oApuracao:setDtInicioAtiv( cTod( SuperGetmv( "MV_DTINISI" , .F., "  /  /    " ) ) )

//Status do limite da apuração do período anterior
oApuracao:setStatusLimite(cLim)

//Status do Sublimite da apuração do período anterior
oApuracao:setStatusSublimite(cSubLim)

//Envia o RPA somado de todas as filiais
oApuracao:setRPATot(nTotRPA)

//Processa a carga dos Anexos
oApuracao:loadAnexos()

//Realiza a caraga dos limites
oApuracao:loadLimites()

//--------------------------------------------------------------------------------
//Envia para classe de apuração as receitas totalizadas por código de atividade
//sub atividade e anexo.
//--------------------------------------------------------------------------------
nCont := ASCAN(aReceita, {|aX| aX[1] == cFilAnt .AND. ax[5] == cTpRec  })
If nCont > 0

	For nX 	:= nCont to Len( aReceita )

		If aReceita[nX][1] == cFilAnt .AND. aReceita[nX][5] == cTpRec			
			oReceita := FISA153RECEITA():new()
			oReceita:setCodAtiv( aReceita[nX][2] 			)
			oReceita:setAnexo( aReceita[nX][3] 				)
			oReceita:setCodSubAtiv( aReceita[nX][4] 		)
			oReceita:setValor( aReceita[nX][6] 				)
			oReceita:setValorBruto( aReceita[nX][7] 		)
			oReceita:setValorDevolucoes( aReceita[nX][8] 	)			
			oReceita:setFatorR( aReceita[nX][9] 			)
			oReceita:setAnexoSub( aReceita[nX][10] 			)			

			//Adiciona receita para classe de apuração
			oApuracao:addReceita( oReceita )
		Else
			Exit
		EndIF

	Next nX

EndIF

//-----------------------------------------------------------
//Chama método para classe de apuração realizar os cálculos
//-----------------------------------------------------------
oApuracao:apurar()

//-------------------------------------------------
//Realiza a gravação das tabelas de apuração
//-------------------------------------------------
nRpaApur	+= oapuracao:getRPA()

GravaApur( oApuracao, nRBA, cTpRec, cIdApurMatriz, nRPAMes, cRegime, @nTotalTrib )

//-------------------------------------------------
//Destroi objeto de apuração
//-------------------------------------------------
LimpaObjApur( oApuracao )

Return

//------------------------------------------------------------------
/*/{Protheus.doc} ExcluiTab

Função que fará instrução de delete das tabelas, quando apuração for 
reprocessada ou então excluída.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function ExcluiTab(cTab, cId, dPer)

Local cQuery	:= ''
Local cCampoId	:= Iif(cTab == "F1A"  , '_ID' ,  '_IDAPUR')

cQuery := "DELETE FROM " +  RetSqlName(cTab)  + " " 

If cTab $ 'F15/F16/F1E'
	cQuery += "WHERE  " + cTab + "_FILIAL = " + valtosql( xFilial( cTab ) ) + " AND " + cTAb + "_MES = " + ValToSQL( month2str( dPer ) ) + " AND " + cTAb + "_ANO = " + ValToSQL( Year2str( dPer ) ) + " "
ElseIf cTab == 'F1D'
	cQuery += "WHERE " + cTab + "_FILIAL = " + valtosql( xFilial( cTab ) ) + " AND F1D_MESUTI = " + ValToSQL( month2str( dPer ) ) + " AND F1D_ANOUTI = " + ValToSQL( Year2str( dPer ) ) + " "
Else
	cQuery += "WHERE " + cTab + cCampoId + " = " + ValToSQL( cId ) + " "
EndIF

IF !EmpTy(Alltrim(cQuery))
	TcSqlExec(cQuery)
EndIF

Return

//------------------------------------------------------------------
/*/{Protheus.doc} GetTotRPA

Função que apenas realiza soma do RPA de todos os valores do array aReceita

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function GetTotRPA( aReceita )

Local nTotRPA	:= 0
Local nx		:= 0

For nX := 1 to len( aReceita)

	nTotRPA +=	aReceita[nX][6]

NExt nX

Return nTotRPA


//------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function AtualizaMsg( oSay, cMsg )

	If ValType("lAutomato") != "U" .AND. !lAutomato
		
		oSay:cCaption := (cMsg)
		ProcessMessages()

	EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} CargaIni

Função que fará a chamada da caraga inicial das tabelas F10, F11, F12, F13, F14 e F17.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function CargaIni( oSay )

	Begin Transaction

		//Faz Carga inicial do cadastros do Anexos
		AtualizaMsg( oSay, "Processando carga inicial dos Anexos" )
		FSA150ANEX()

		//Faz a CArga inicial das atividades
		AtualizaMsg( oSay, "Processando carga inicial das Atividades" )
		FSA151ATIV()

		//Da carga das limites do simples Nacional
		AtualizaMsg( oSay, "Processando carga inicial dos Limites" )
		FSA151LIMITE()

		AtualizaMsg( oSay, "Concluído" )

	End Transaction

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuRecDev()

Função responsável por atualizar os valores das receitas fazendo
a dedução dos valores devolvidos.

@author joao.pellegrini
@since 16/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AtuRecDev(aReceita, aDevol, cOrigem, aSldDev)

Local nX      := 0
Local nPosRec := 0
Local nPosSld := 0
Local nY      := 0
Local cMes    := Month2Str(FSA200DataApur(mv_par01))
Local cAno    := Year2Str(FSA200DataApur(mv_par01))

Local POS_FILIAL       := 1
Local POS_ATIVIDADE    := 2
Local POS_ANEXO        := 3
Local POS_SUBATIVIDADE := 4
Local POS_TIPO         := 5
Local POS_VALOR        := 6
Local POS_RECBRU       := 7
Local POS_VALDEV       := 8

For nX := 1 to Len(aDevol)

	// Se a origem não for NF não tenho a filial, já que a tabela de saldos é compartilhada.
	// Assim, nem tento localizar receitas considerando a filial pois não encontraria nunca.
	If cOrigem == "NF"

		// Verifico se consigo deduzir a devolução da receita da mesma filial e subatividade que a gerou
		For nY := 1 to Len(aReceita)

			If aReceita[nY, POS_FILIAL]       == aDevol[nX, POS_FILIAL]       .And.;
			   aReceita[nY, POS_ATIVIDADE]    == aDevol[nX, POS_ATIVIDADE]    .And.;
			   aReceita[nY, POS_ANEXO]        == aDevol[nX, POS_ANEXO]        .And.;
			   aReceita[nY, POS_SUBATIVIDADE] == aDevol[nX, POS_SUBATIVIDADE] .And.;
			   aReceita[nY, POS_TIPO]         == aDevol[nX, POS_TIPO]

				// Se a receita tem saldo suficiente para abater toda a devolução...
				If aReceita[nY, POS_VALOR] >= aDevol[nX, POS_VALOR]
					aReceita[nY, POS_VALDEV] += aDevol[nX, POS_VALOR]
					aReceita[nY, POS_VALOR] -= aDevol[nX, POS_VALOR]
					aDevol[nX, POS_VALOR] := 0
				Else
					aReceita[nY, POS_VALDEV] += aReceita[nY, POS_VALOR]
					aDevol[nX, POS_VALOR] -= aReceita[nY, POS_VALOR]
					aReceita[nY, POS_VALOR] := 0
				EndIf
			EndIf

		Next nY

		// Se restou algum saldo verifico se existem outras subatividades (do mesmo anexo) para
		// deduzir o restante do saldo.
		If aDevol[nX, POS_VALOR] > 0

			For nY := 1 to Len(aReceita)

				If aReceita[nY, POS_FILIAL] == aDevol[nX, POS_FILIAL] .And.;
				   aReceita[nY, POS_ANEXO]  == aDevol[nX, POS_ANEXO]  .And.;
				   aReceita[nY, POS_TIPO]   == aDevol[nX, POS_TIPO]

					If aReceita[nY, POS_VALOR] >= aDevol[nX, POS_VALOR]
						aReceita[nY, POS_VALDEV] += aDevol[nX, POS_VALOR]
						aReceita[nY, POS_VALOR]  -= aDevol[nX, POS_VALOR]
						aDevol[nX, POS_VALOR] := 0
					Else
						aReceita[nY, POS_VALDEV] += aReceita[nY, POS_VALOR]
						aDevol[nX, POS_VALOR]    -= aReceita[nY, POS_VALOR]
						aReceita[nY, POS_VALOR]  := 0
					EndIf

				EndIf

			Next nY

		EndIf

	EndIf

	// Tento encontrar a mesma atividade/subatividade/anexo nas outras filiais...
	If aDevol[nX, POS_VALOR] > 0

		For nY := 1 to Len(aReceita)

			If aReceita[nY, POS_ATIVIDADE]    == aDevol[nX, POS_ATIVIDADE]    .And.;
			   aReceita[nY, POS_ANEXO]        == aDevol[nX, POS_ANEXO]        .And.;
			   aReceita[nY, POS_SUBATIVIDADE] == aDevol[nX, POS_SUBATIVIDADE] .And.;
			   aReceita[nY, POS_TIPO]         == aDevol[nX, POS_TIPO]

				// Se a receita tem saldo suficiente para abater toda a devolução...
				If aReceita[nY, POS_VALOR] >= aDevol[nX, POS_VALOR]
					aReceita[nY, POS_VALDEV] += aDevol[nX, POS_VALOR]
					aReceita[nY, POS_VALOR]  -= aDevol[nX, POS_VALOR]
					aDevol[nX, POS_VALOR] := 0
				Else
					aReceita[nY, POS_VALDEV] += aReceita[nY, POS_VALOR]
					aDevol[nX, POS_VALOR] -= aReceita[nY, POS_VALOR]
					aReceita[nY, POS_VALOR] := 0
				EndIf

			EndIf

		Next nY

	EndIf

	// Se ainda restar saldo, verifico na receita de todas as demais filiais
	// se consigo deduzir o restante...
	If aDevol[nX, POS_VALOR] > 0

		For nY := 1 to Len(aReceita)

			If aReceita[nY, POS_ANEXO] == aDevol[nX, POS_ANEXO] .And.;
			   aReceita[nY, POS_TIPO]  == aDevol[nX, POS_TIPO]

				// Se a receita tem saldo suficiente para abater toda a devolução...
				If aReceita[nY, POS_VALOR] >= aDevol[nX, POS_VALOR]
					aReceita[nY, POS_VALDEV] += aDevol[nX, POS_VALOR]
					aReceita[nY, POS_VALOR] -= aDevol[nX, POS_VALOR]
					aDevol[nX, POS_VALOR] := 0
				Else
					aReceita[nY, POS_VALDEV] += aReceita[nY, POS_VALOR]
					aDevol[nX, POS_VALOR] -= aReceita[nY, POS_VALOR]
					aReceita[nY, POS_VALOR] := 0
				EndIf

			EndIf

		Next nY

	EndIf

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF1D()

Função responsável por efetuar a gravação dos saldos na tabela F1D.

@author joao.pellegrini
@since 16/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravaF1D(cIDApur, aSldDev)

Local cMes    := Month2Str(FSA200DataApur(mv_par01))
Local cAno    := Year2Str(FSA200DataApur(mv_par01))
Local cMesUti := Month2Str(MonthSum(FSA200DataApur(mv_par01), 1))
Local cAnoUti := Year2Str(MonthSum(FSA200DataApur(mv_par01), 1))
Local nX := 0

// Esta função irá gravar os novos saldos e regravar os saldos
// que foram ou poderiam ter sido utilizados no período da apuração,
// setando como mês e ano de utilização o mês seguinte.

For nX := 1 to Len(aSldDev)

	// Só grava se houver saldo remanescente.
	If aSldDev[nX, 6] > 0

		RecLock("F1D", .T.)

		F1D->F1D_FILIAL := xFilial("F1D")
		F1D->F1D_ID     := FWUUID("F1D")
		F1D->F1D_MES    := cMes
		F1D->F1D_ANO    := cAno
		F1D->F1D_MESUTI := cMesUti
		F1D->F1D_ANOUTI := cAnoUti
		F1D->F1D_CODATV := aSldDev[nX, 2]
		F1D->F1D_ANEXO  := aSldDev[nX, 3]
		F1D->F1D_SUBATV := aSldDev[nX, 4]
		F1D->F1D_TPREC  := aSldDev[nX, 5]
		F1D->F1D_SALDO  := aSldDev[nX, 6]

		F1D->(MsUnLock())

	EndIf

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IniSaldoDev()

Função responsável por inicializar o array de saldos com os saldos
disponíveis para utilização no período de apuração.

@author joao.pellegrini
@since 16/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SaldoDev(aSldDev, cMes, cAno, cOperacao, aSaldo)

Local cAliasF1D := ""
Local cSelect 	:= ""
Local cFrom 	:= ""
Local cWhere 	:= ""
Local cOrder 	:= ""
Local cGroupBy	:= ""
Local nX := 0
Local nPosSld := 0

Local POS_FILIAL       := 1
Local POS_ATIVIDADE    := 2
Local POS_ANEXO        := 3
Local POS_SUBATIVIDADE := 4
Local POS_TIPO         := 5
Local POS_VALOR        := 6
Local POS_RECBRU       := 7
Local POS_VALDEV       := 8

Local aRet := {}

If cOperacao == "INICIALIZAR"

	cSelect += "F1D.F1D_FILIAL, F1D.F1D_ID, F1D.F1D_MES, F1D.F1D_ANO, F1D.F1D_MESUTI, F1D.F1D_ANOUTI, F1D.F1D_CODATV, F1D.F1D_SUBATV, F1D.F1D_ANEXO, "
	cSelect += "F1D.F1D_TPREC, F1D.F1D_SALDO "

	cFrom += RetSqlName("F1D") + " F1D "

	cWhere += "F1D.F1D_FILIAL = " + ValToSQL(xFilial("F1D")) + " AND "
	cWhere += "F1D.F1D_MESUTI = " + ValToSQL(cMes) + " AND "
	cWhere += "F1D.F1D_ANOUTI = " + ValToSQL(cAno) + " AND "
	cWhere += "F1D.D_E_L_E_T_ = ' ' "

	cOrder += "ORDER BY F1D.F1D_ANO, F1D.F1D_MES"

	// Formatando query p/ execução

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom + "%"
	cWhere  := "%" + cWhere + cOrder + cGroupBy + "%"

	cAliasF1D := GetNextAlias()

	BeginSQL Alias cAliasF1D

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

	EndSQL


	(cAliasF1D)->(dbGoTop())

	While !(cAliasF1D)->(Eof())

		aAdd(aSldDev, {})
		nPosSld := Len(aSldDev)

		// Não alterar a ordem das 6 primeiras posições!!!

		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_FILIAL) //01
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_CODATV) //02
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_ANEXO)  //03
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_SUBATV) //04
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_TPREC)  //05
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_SALDO)  //06
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_ID)     //07
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_MES)    //08
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_ANO)    //08
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_MESUTI) //09
		aAdd(aSldDev[nPosSld], (cAliasF1D)->F1D_ANOUTI) //10

		(cAliasF1D)->(dbSkip())

	EndDo

ElseIf cOperacao == "ATUALIZAR"

	For nX := 1 to Len(aSaldo)

		If aSaldo[nX, POS_VALOR] > 0

			If (nPosSld := aScan(aSldDev, {|x| 	x[8]                == cMes                         .And.;
												x[9]                == cAno                         .And.;
												x[POS_ATIVIDADE]    == aSaldo[nX, POS_ATIVIDADE]    .And.;
												x[POS_SUBATIVIDADE] == aSaldo[nX, POS_SUBATIVIDADE] .And.;
												x[POS_ANEXO]        == aSaldo[nX, POS_ANEXO]        .And.;
												x[POS_TIPO]         == aSaldo[nX, POS_TIPO]})) == 0

				aAdd(aSldDev, {})
				nPosSld := Len(aSldDev)

				aAdd(aSldDev[nPosSld], "")   // Filial: Será gravada na função GravaF1D.
				aAdd(aSldDev[nPosSld], aSaldo[nX, POS_ATIVIDADE])
				aAdd(aSldDev[nPosSld], aSaldo[nX, POS_ANEXO])
				aAdd(aSldDev[nPosSld], aSaldo[nX, POS_SUBATIVIDADE])
				aAdd(aSldDev[nPosSld], aSaldo[nX, POS_TIPO])
				aAdd(aSldDev[nPosSld], aSaldo[nX, POS_VALOR])
				aAdd(aSldDev[nPosSld], "")   // ID: Será gerado na função GravaF1D.
				aAdd(aSldDev[nPosSld], cMes)
				aAdd(aSldDev[nPosSld], cAno)
				aAdd(aSldDev[nPosSld], "")   // Mês de Utilização: Será gerado na função GravaF1D.
				aAdd(aSldDev[nPosSld], "")   // Ano de Utilização: Será gerado na função GravaF1D.

			Else

				aSldDev[nPosSld, 6] += aSaldo[nX, POS_VALOR]

			EndIf

		EndIf

	Next nX

EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} RecNfCaixa

Função que fará todo tratamento do regime de caixa.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function RecNfCaixa( cAliasQry, oObjRecNf, aReceita, cOpRec )

Local cChaveD2	:= ""
Local cIdAtv	:= ""
Local lServ		:= .F.
Local lMerc		:= .F.
Local lGrupo	:= .F.
Local nPercBaix	:= 0
Local nValBaixa	:= 0
Local cCliLoja 	:= (cAliasQry)->E5_CLIFOR+(cAliasQry)->E5_LOJA 
Local lLoja    	:=  "LOJA" $ (cAliasQry)->E1_ORIGEM
Local cAnoMes	:=  substr(MV_PAR01,3,6)+substr(MV_PAR01,1,2)
SF2->( DbSetOrder ( 1 ) )
SD2->( DbSetOrder ( 3 ) )


IF lLoja 
	DbselectArea("SL1")
	SL1->(DbSetOrder(2))
		If SL1->(Dbseek(xFilial("SL1")+(cAliasQry)->E1_SERIE+(cAliasQry)->E5_NUMERO)) .and. Alltrim((cAliasQry)->E5_TIPO) <> 'NF'
			cCliLoja := SL1->L1_CLIENTE+SL1->L1_LOJA
		EndIF
EndIF
//Verifica se existe SF2 para esta baixa
If SF2->(MsSeek(   xFilial("SF2")+(cAliasQry)->E5_NUMERO+(cAliasQry)->E1_SERIE+cCliLoja ))

	cChaveD2	:=  xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA

	//Verifica se existe item para esta nota
	IF SD2->(MsSeek( cChaveD2 ))

		While SD2->(!Eof()) .AND. SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA  == cChaveD2

			cIdAtv	 	:= ""
			lServ		:= .F.
			lMerc		:= .F.
			lGrupo		:= .F.

			//Limpa os objetos da classe
			oObjRecNf:Clear()
			If !Empty(SD2->D2_CODISS)

				//Nota Fiscal de serviço
				//Irá posicionar a F13 com código de ISS
				F13->( DbSetOrder ( 5 ) )
				If F13->(MsSeek(xFilial("F13") + SD2->D2_CODISS ))
					//Precisa verificar se a vigência da F13 está de acordo
					While !F13->(Eof())	 .AND. F13->F13_FILIAL == xFilial("F13") .AND. Alltrim(F13->F13_CODISS) == Alltrim(SD2->D2_CODISS)

						If F13->F13_INIVIG <= FSA200DataApur ( mv_par01 ) .AND. ( F13->F13_FIMVIG >= LastDay(FSA200DataApur ( mv_par01 ) ) .Or. Empty(F13->F13_FIMVIG)  )
							cIdAtv	:= F13->F13_IDATV
							lServ	:= .T.
							Exit
						EndIF
						F13->(DbSkip())
					EndDo
					
				EndIF

			EndIF

				IF !Empty( SD2->D2_CF ) .and. Empty(cIdAtv)

					//Tentará posicionar a F13 com o CFOP
					F13->( DbSetOrder ( 3 ) )
					If F13->(MsSeek(xFilial("F13") + SD2->D2_CF ))
						
						//Precisa verificar se a vigência da F13 está de acordo
						While !F13->(Eof())	 .AND. F13->F13_FILIAL == xFilial("F13") .AND. alltrim(F13->F13_CFOP) == Alltrim(SD2->D2_CF)

							If F13->F13_INIVIG <= FSA200DataApur ( mv_par01 ) .AND. ( F13->F13_FIMVIG >= LastDay(FSA200DataApur ( mv_par01 ) ) .Or. Empty(F13->F13_FIMVIG)  )
								cIdAtv	:= F13->F13_IDATV
								lMerc	:= .T.
								Exit
							EndIF
							F13->(DbSkip())
						EndDo						
					
					EndIF

				EndIF

				IF Empty(cIdAtv) .AND. !Empty( SD2->D2_GRUPO )

					F13->( DbSetOrder ( 4 ) )
					If F13->(MsSeek(xFilial("F13") + SD2->D2_GRUPO ))

						//Precisa verificar se a vigência da F13 está de acordo
						While !F13->(Eof())	 .AND. F13->F13_FILIAL == xFilial("F13") .AND. Alltrim(F13->F13_GRUPO) == Alltrim(SD2->D2_GRUPO)

							If F13->F13_INIVIG <= FSA200DataApur ( mv_par01 ) .AND. ( F13->F13_FIMVIG >= LastDay(FSA200DataApur ( mv_par01 ) ) .Or. Empty(F13->F13_FIMVIG)  )
								cIdAtv	:= F13->F13_IDATV
								lGrupo	:= .T.
								Exit
							EndIF
							F13->(DbSkip())
						EndDo						

					EndIF

				EndIF

			//Se encontrou código de Atividade prosegue
			If !Empty( cIdAtv )

				//Buscará o código da atividade
				F12->( DbSetOrder ( 2 ) )
				If F12->(MsSeek(xFilial("F12") + cIdAtv ))

					//Somente processa receitas do mesmo tipo da atividade (interno/exportação)
					IF F12->F12_TPREC == cOpRec
						/*
							RESOLUÇÃO CGSN Nº 140, DE 22 DE MAIO DE 2018
							"§ 5º Não compõem a receita bruta de que trata este artigo: (Lei Complementar nº 123, de 2006, art. 2º, inciso I e § 6º, e art. 3º, § 1º)
							II - os juros moratórios, as multas e quaisquer outros encargos auferidos em decorrência do atraso no pagamento de operações ou prestações"
							
							Obs: O financeiro irá criar um compoenente para não termos que efetuar os cálculos pelo fiscal.
						*/
						
						// Define perncutal da baixa ( sem encargos financeiros e com impostos ).
						nValBaixa	:=  (cAliasQry)->E5_VALOR -   (cAliasQry)->E5_VLMULTA -  (cAliasQry)->E5_VLJUROS +  (cAliasQry)->E5_VLDESCO
						nPercBaix	:= ( ( nValBaixa * 100 )/ SF2->F2_VALFAT ) / 100

						//Posiciona o TES
						If F14->(MsSeek(xFilial("F14") + SD2->D2_TES ))
							oObjRecNf:setCsosn( SF4->F4_CSOSN )
						EndIF

						//Define a receita do simples nacional.
						
						oObjRecNf:SetValorRc( SD2->( D2_VALBRUT - D2_ICMSRET - D2_VALIPI) * nPercBaix  )
					
						oObjRecNf:setRecIss( SF2->F2_RECISS )
						oObjRecNf:setCodAtv( F12->F12_CODATV 				)
						oObjRecNf:setAnexo( F13->F13_ANEXO 					)
						oObjRecNf:setICMSRET( SD2->D2_ICMSRET 				)
						oObjRecNf:setTpServ( F13->F13_TPSERV 				)
						oObjRecNf:setFatorR( F13->F13_FATORR 				)
						oObjRecNf:setAnexoSub( F13->F13_ASUB 				)
						oObjRecNf:setCfop( SD2->D2_CF					    )

						// Posicionar na SA1
						If SA1->(MsSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOCAL ))
							oObjRecNf:setCCodMun( xFisCodIBGE( SA1->A1_EST ) + SA1->A1_COD_MUN 	 )
						EndIF

						//Posiciona o pedido de venda
						If SC5->(MsSeek(xFilial("SC5") + SD2->D2_PEDIDO ))
							oObjRecNf:setMunPres( xFisCodIBGE( SC5->C5_ESTPRES ) + SC5->C5_MUNPRES ) // posicionar na SC5
						EndIF
						
						//Posiciona a SB1
						If SB1->(MsSeek(xFilial("SB1") + SD2->D2_COD ))
							oObjRecNf:setMepLes( SB1->B1_MEPLES 	)		
						EndIF

						//--------------------------------------------------------
						//Processa função para obter um código de subatividade
						//--------------------------------------------------------
						Atv2SubAtv ( oObjRecNf )

						IF (lMerc .OR. lServ .Or. lGrupo) .AND. !Empty( oObjRecNf:getSubAtv() )

							AgrupaReceita( @aReceita, oObjRecNf,  F12->F12_TPREC , '2' )

						EndIF

					EndIF

				EndIF

			EndIF

			SD2->(dbSkip())
		EndDo

	EndIF
EndIF

Return

//------------------------------------------------------------------
/*/{Protheus.doc} AgrupaReceita

Função agrupa as receitas, por código de atividade, subatividade, anexo, filial e tipo de receita
(interna/exportação), que posteriormente será enviado para classe de apuração.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function AgrupaReceita( aReceita, oObjRecNf, cOpRec, cRegime )

Default  cRegime := '1'
nPos := ASCAN(aReceita, {|aX| aX[1] == cFilAnt .AND. ax[2] ==  oObjRecNf:getCodAtv()  .AND. ax[3] == oObjRecNf:getAnexo() .AND. ax[4] == oObjRecNf:getSubAtv() .AND. ax[5] == cOpRec .AND. ax[9] == oObjRecNf:getFatorR() .AND. ax[10] == oObjRecNf:getAnexoSub()  })

IF nPos == 0
	//Ainda não existe para esta filial valor deste código de atividade e sub atividade e anexo
	aAdd(aReceita, {})
	nPos := Len(aReceita)
	aAdd (aReceita[nPos],  cFilAnt 					)	//01 Filial
	aAdd (aReceita[nPos],  oObjRecNf:getCodAtv() 	)	//02 Código da Atividade
	aAdd (aReceita[nPos],  oObjRecNf:getAnexo()		)	//03 Anexo
	aAdd (aReceita[nPos],  oObjRecNf:getSubAtv() 	)	//04 Código da SubAtividade
	aAdd (aReceita[nPos],  cOpRec			     	)	//05 Tipo da receita (Interna/Exportação)
	aAdd (aReceita[nPos],  IIf(cRegime == '2', oObjRecNf:getValorRc(), oObjRecNf:getVALBRUT() )		)	//06 Base de cálculo
	aAdd (aReceita[nPos],  oObjRecNf:getVALBRUT() 	)	//07 Receita bruta sem redução das devoluções
	aAdd (aReceita[nPos],  0 						)	//08 Valor das devoluções
	aAdd (aReceita[nPos],  oObjRecNf:getFatorR()	)	//09 Sujeio ao fator R
	aAdd (aReceita[nPos],  oObjRecNf:getAnexoSub()  )	//10 Anexo Substituto		

Else
	//Já existe para esta filial valor deste código de atividade e sub atividade e anexo
	aReceita[nPos][6] += IIf(cRegime == '2', oObjRecNf:getValorRc(), oObjRecNf:getVALBRUT() )	
	aReceita[nPos][7] += oObjRecNf:getVALBRUT()

EndIF

Return

//------------------------------------------------------------------
/*/{Protheus.doc} ChkTit

Função responsável por verificar se no momento de reprocessar ou excluir apuração,
se existe título gerado ou contabilização realizada.
Se houver título será excluído, se houver contabilização, esta será estornada.
Caso o título tenha baixa realizada, não será excluído e o processamento será barrado.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function ChkTit()

Local lRet		:= .T.
Local cLPadSim	:= AllTrim( GetNewPar( "MV_LPADSN" , "" ) )
Local cLcPadExt	:= Substr( cLPadSim, 4, 3 )
Local cAlqAprov	:= ChkAprovAliq()

//---------------------------------------------
//Verificação do cmopartilhamento das tabelas
//---------------------------------------------
If !Empty( cAlqAprov )
	//Significa que existe alíquotas aprovadas para esta apuração
	MsgStop("Existem alíquotas aprovadas para a(s) seguinte(s) filial(ais):" + chr(13) + chr(10) + chr(13) + chr(10) + cAlqAprov + chr(13) + chr(10) + chr(13) + chr(10)  + "Para prosseguir com a operação as aprovações deverão ser estornadas." )
	lRet	:= .F.
EndIF

If lRet
	//------------------------------------------------------------------------
	//Verifica se existe algum título no contas a pagar gerado pela apuração
	//-----------------------------------------------------------------------
	DBSelectArea("SE2")
	SE2->(dbSetOrder(1))
	If !Empty(F1A->F1A_NUMTIT) .AND.  SE2->(MsSeek(xFilial("SE2") + F1A->F1A_PRETIT + PadR( F1A->F1A_NUMTIT ,TamSx3("E2_NUM")[1])+  F1A->F1A_PARTIT + F1A->F1A_TPTIT + F1A->F1A_FORTIT + F1A->F1A_LOJTIT ))

		//Verifica se o título já possui baixa
		If !FaCanDelCP("SE2", 'FISA153',.F.)
			MsgStop("O título financeiro de número:" +  F1A->F1A_NUMTIT  +', Prefixo: ' + F1A->F1A_PRETIT + ' e Tipo: ' + F1A->F1A_TPTIT + " possui baixas e não poderá ser deletado, o processo será interrompido.")
			lRet := .F.
		Else

			//Estorna lançamento contábil
			If !Empty( cLcPadExt ) .AND. F1A->F1A_STATUS == "3"
				LancCont(cLcPadExt,"FISA153")
			EndIF

			//Deleta o título pois não possui baixas
			RecLock('SE2')
			FaAvalSE2(2,"FISA153")
			FaAvalSE2(3,"FISA153")
			SE2->(dbDelete())
			MsUnLock()

			lRet := .T.
		EndIf

	Else
		//Estorna lançamento contábil
		If !Empty( cLcPadExt ) .AND. F1A->F1A_STATUS == "3"
			LancCont(cLcPadExt,"FISA153")
		EndIF
	
	EndIF

EndIF

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} GravaF1E

Função responsável por gravar F1E, cabeçalho das alíquotas efetivas

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function GravaF1E( cAno, cMes )

If ! F1E->( DbSeek ( xFilial('F1E') + cAno + cMes  ) )

	RecLock('F1E',.T.)
	F1E->F1E_FILIAL  	:= xFilial("F1E")
	F1E->F1E_ID    	 	:= FwUUID("F1E")
	F1E->F1E_MES    	:= cMes
	F1E->F1E_ANO    	:= cAno
	F1E->F1E_APROV    	:= "2" //Sempre grava iniciando com status de não aprovado.
	F1E->(msUnlock())

EndIF

Return

//------------------------------------------------------------------
/*/{Protheus.doc} GravaF16

Função responsável para gravar as alíquotas efetivas por anexo na tabela F16.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function GravaF16( cAno, cMes, aAlqEfet )

Local nX	:= 0

For nX:= 1 to Len( aAlqEfet )

	If F16->( DbSeek ( xFilial('F16') + cAno + cMes  +  aAlqEfet[nX][1]  ) )
		
		RecLock('F16',.F.)		
		//Sobreescreve todas as alíquotas
		F16->F16_IRPJ	:= aAlqEfet[nX][2]
		F16->F16_CSLL	:= aAlqEfet[nX][3]
		F16->F16_COFINS	:= aAlqEfet[nX][4]
		F16->F16_PIS	:= aAlqEfet[nX][5]
		F16->F16_CPP	:= aAlqEfet[nX][6]
		F16->F16_IPI	:= aAlqEfet[nX][7]
		F16->F16_ICMS	:= aAlqEfet[nX][8]
		F16->F16_ISS	:= aAlqEfet[nX][9]
		
	Else

		RecLock('F16',.T.)
		F16->F16_FILIAL  := xFilial("F16")
		F16->F16_ID    	 := FwUUID("F16")
		F16->F16_ANO    := cAno
		F16->F16_MES    := cMes
		F16->F16_ANEXO	:= aAlqEfet[nX][1]
		F16->F16_IRPJ	:= aAlqEfet[nX][2]
		F16->F16_CSLL	:= aAlqEfet[nX][3]
		F16->F16_COFINS	:= aAlqEfet[nX][4]
		F16->F16_PIS	:= aAlqEfet[nX][5]
		F16->F16_CPP	:= aAlqEfet[nX][6]
		F16->F16_IPI	:= aAlqEfet[nX][7]
		F16->F16_ICMS	:= aAlqEfet[nX][8]
		F16->F16_ISS	:= aAlqEfet[nX][9]
		F16->F16_APROV	:= "2" //Adiciona alíquota com status de Não Aprovado

	EndIF

	F16->(msUnlock())

Next nX

Return

//------------------------------------------------------------------
/*/{Protheus.doc} CodTrib

Esta função faz o DE-PARA, do tributo para o código do combo.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function CodTrib( ctrib )

Local cRet	:= ""

If ctrib == "IRPJ"
	cRet	+=  "1"
ElseIf ctrib == "CSLL"
	cRet	+= "2"
ElseIf ctrib == "COFINS"
	cRet	+= "3"
ElseIf ctrib == "PIS"
	cRet	+= "4"
ElseIf ctrib == "CPP"
	cRet	+= "5"
ElseIf ctrib == "IPI"
	cRet	+= "6"
ElseIf ctrib == "ICMS"
	cRet	+= "7
ElseIf ctrib == "ISS"
	cRet	+= "8"
EndIF

Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} BuscaAlqEfet

Função que realiza query na tabela F1B para buscar alíquotas efetivas
considerando o Id da apuração (F1A)

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function BuscaAlqEfet ( cIdApur )

Local cAliasAlqE	:= ''
Local cSelect		:= ''
Local cFrom			:= ''
Local cWhere		:= ''
Local cOrder		:= ''

cSelect 	+= "DISTINCT F1B_ANEXO, F1B_TPPARC"
cFrom 		+= RetSqlName("F1B") + " F1B "
cFrom 		+= "JOIN " + RetSQLName("F17") + " F17 " + " ON (F17.F17_FILIAL = " + ValToSQL(xFilial("F17")) + " AND F17.F17_SUBATV = F1B.F1B_SUBATV AND F17.D_E_L_E_T_ = ' ') "
cFrom 		+= "JOIN " + RetSQLName("F12") + " F12 " + " ON (F12.F12_FILIAL = " + ValToSQL(xFilial("F12")) + " AND F12.F12_CODATV = F17.F17_CODATV AND F12.D_E_L_E_T_ = ' ') "
cWhere 		+= "F1B.F1B_IDAPUR  = " + ValToSQL( cIdApur ) + " AND "
cWhere 		+= "F12.F12_TPREC = '1' AND "
cWhere 		+= "F1B.D_E_L_E_T_ = ' ' "
cOrder 		+= "ORDER BY F1B_ANEXO, F1B_TPPARC DESC"

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom + "%"
cWhere  := "%" + cWhere + cOrder + "%"

cAliasAlqEfet := GetNextAlias()

BeginSQL Alias cAliasAlqEfet

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSQL

Return cAliasAlqEfet


//------------------------------------------------------------------
/*/{Protheus.doc} PreparaAlqEfet

Função que retorna as datas das rotinas auxiliares e exibe para o usuário

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function PreparaAlqEfet( cIdApurMatriz )

Local aRet		:= {}
Local aAnexo	:= {}
Local cAliasF1B	:= ''
Local nPos		:= 0

//Para gravação das alíquotas efetivas, serão consideradas as alíquotas gravadas na memória de cálculo da tabela F1B.
//Lembrando que se houver mais de uma alíquota no mês, por conta de ultrapassar o sublimite/limite, a alíquota considerada
//será do status atual do cliente.
cAliasF1B	:= BuscaAlqEfet( cIdApurMatriz )

(cAliasF1B)->(dbGoTop())

//Processa todas as F18 de todas as filiais
While !(cAliasF1B)->(Eof())	
	
	nPos := ASCAN(aAnexo, {|aX| aX[1] == (cAliasF1B)->F1B_ANEXO  })

	If nPos == 0
		aAdd( aAnexo, { (cAliasF1B)->F1B_ANEXO, (cAliasF1B)->F1B_TPPARC }) //Adiciona no array o anexo e o tipo da parcela
	EndIF		

	(cAliasF1B)->(dbSkip())

EndDo

F1B->( DbSetOrder ( 3 ) )
F1B->(dbGoTop())
//Roda os anexos buscando da F1B os valores dos tributos
For nPos:= 1 to len( aAnexo )
	//Zero as variáveis para novo anexo
	nIrpj	:= 0 
	nCSLL	:= 0 
	nCOFINS	:= 0 
	nPis	:= 0 
	nCPP	:= 0 
	nIPI	:= 0 
	nICMS	:= 0 
	nISS	:= 0

	If F1B->( DbSeek ( xFilial('F1B') + cIdApurMatriz +  aAnexo[nPos][1] + aAnexo[nPos][2] ) )

		While !F1B->(Eof()) .AND. F1B->F1B_IDAPUR == cIdApurMatriz .AND. F1B->F1B_ANEXO == aAnexo[nPos][1] .AND. F1B->F1B_TPPARC == aAnexo[nPos][2] 

			//Irá percorrer todos os tributos da F1B do mesmo id de apuração, mesmo anexo e mesmo tipo de parcela
			IF F1B->F1B_TRIB == '1'
				//IRPJ
				nIrpj	:= NoRound( F1B->F1B_EFETTB )
			ElseIF F1B->F1B_TRIB == '2'
				//CSLL
				nCSLL	:= NoRound( F1B->F1B_EFETTB )
			ElseIF F1B->F1B_TRIB == '3'
				//COFINS
				nCOFINS	:= NoRound( F1B->F1B_EFETTB )
			ElseIF F1B->F1B_TRIB == '4'
				//PIS
				nPis	:= NoRound( F1B->F1B_EFETTB )				
			ElseIF F1B->F1B_TRIB == '5'
				//CPP
				nCPP	:= NoRound( F1B->F1B_EFETTB )
			ElseIF F1B->F1B_TRIB == '6'
				//IPI
				nIPI	:= NoRound( F1B->F1B_EFETTB )				
			ElseIF F1B->F1B_TRIB == '7'
				//ICMS
				nICMS	:= NoRound( F1B->F1B_EFETTB )
			ElseIF F1B->F1B_TRIB == '8'				
				//ISS
				nISS	:= NoRound( F1B->F1B_EFETTB )
			EndIF
		
			F1B->(dbSkip())

		EndDo

		//Adiciona anexo e alíquotas no array
		aAdd( aRet, { aAnexo[nPos][1], nIrpj , nCSLL , nCOFINS, nPis , nCPP , nIPI , nICMS , nISS  }) 

	EndIF
	
Next nPos

//Fecha a query
DbSelectArea (cAliasF1B)
(cAliasF1B)->(DbCloseArea())

Return aRet	

//------------------------------------------------------------------
/*/{Protheus.doc} FSA153DATA

Função que retorna as datas das rotinas auxiliares e exibe para o usuário

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function FSA153DATA() 

Local cMsg	:= ''

cMsg    += "Rotinas Envolvidas na Apuração: "  + Chr(13) + Chr(10) + Chr(13) + Chr(10)
cMsg	+= "FISA150  -  " + dtoc(GetAPOInfo("FISA150.PRW")[4])  + ' - ' +  GetAPOInfo("FISA150.PRW")[5] + Chr(13) + Chr(10)
cMsg	+= "FISA151  -  " + dtoc(GetAPOInfo("FISA151.PRW")[4])  + ' - ' +  GetAPOInfo("FISA151.PRW")[5] + Chr(13) + Chr(10)
cMsg	+= "FISA152  -  " + dtoc(GetAPOInfo("FISA152.PRW")[4])  + ' - ' +  GetAPOInfo("FISA152.PRW")[5] + Chr(13) + Chr(10)
cMsg	+= "FISA153  -  " + dtoc(GetAPOInfo("FISA153.PRW")[4])  + ' - ' +  GetAPOInfo("FISA153.PRW")[5] + Chr(13) + Chr(10)
cMsg	+= "FISA153A -  " + dtoc(GetAPOInfo("FISA153A.PRW")[4]) + ' - ' +  GetAPOInfo("FISA153A.PRW")[5] + Chr(13) + Chr(10)
cMsg	+= "FISA154  -  " + dtoc(GetAPOInfo("FISA154.PRW")[4])  + ' - ' +  GetAPOInfo("FISA154.PRW")[5] + Chr(13) + Chr(10)
cMsg	+= "FISA155  -  " + dtoc(GetAPOInfo("FISA155.PRW")[4])  + ' - ' +  GetAPOInfo("FISA155.PRW")[5] + Chr(13) + Chr(10)
cMsg	+= "FISR153  -  " + dtoc(GetAPOInfo("FISR153.PRW")[4])  + ' - ' +  GetAPOInfo("FISR153.PRW")[5] + Chr(13) + Chr(10)
cMsg	+= "FISR153A -  " + dtoc(GetAPOInfo("FISR153A.PRW")[4]) + ' - ' +  GetAPOInfo("FISR153A.PRW")[5] + Chr(13) + Chr(10)

MsgInfo(cMsg)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} GrvAlqAnexo

Função que processa as alíquotas efetivas iniciais de processamento.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function GrvAlqAnexo(cAno, cMes, nRBT12, nRBA, nRbt12R, nFsp, nFsp12, cLim, cSubLim, nTotRPA  )

Local oApuracao		:= CriaObjApur( cFilAnt , SuperGetMv("MV_ESTADO" ,.F., "" )  , FSA200DataApur ( mv_par01 ) , LastDay(FSA200DataApur ( mv_par01 ) ) ) //Cria novo objeto da apuração
Local nX			:= 0
Local aAnexos		:= {}
Local aAlq 			:= {}

//Passa o valor total do RBT12 de todas as filiais
oApuracao:setRBT12( nRBT12 )

//Passa o RBA somado de todas as filiais
oApuracao:setRBA(  nRBA   )

//RBTA interno e externo somados para cálculo do fator R
oApuracao:setrbt12r(  nRbt12R   )

//Valor da folha de pagamento do período
oApuracao:setFSPA(  nFsp   )

//VAlor da folha de pagamento dos últimos 12 meses
oApuracao:setFS12(  nFsp12   )

//Início de atividades da filial
oApuracao:setDtInicioAtiv( cTod( SuperGetmv( "MV_DTINISI" , .F., "  /  /    " ) ) )

//Status do limite da apuração do período anterior
oApuracao:setStatusLimite(cLim)

//Status do Sublimite da apuração do período anterior
oApuracao:setStatusSublimite(cSubLim)

//Envia o RPA somado de todas as filiais
oApuracao:setRPATot( 0 )

//Processa a carga dos Anexos
oApuracao:loadAnexos()

//Realiza a caraga dos limites
oApuracao:loadLimites()

//Chama método de apurar
oApuracao:apurar()

aAnexos	:= oapuracao:getAnexos()

//Buscará as alíquotas efetivas iniciais dos anexos
For nX:=1 to Len( aAnexos )
	If aAnexos[nX] <> NIL
		AlqEfetIni( cAno, cMes, aAnexos[nX] ) 
	EndIf
Next nX

FSA153DOBJ(oApuracao)

FSA153DOBJ(aAnexos)

//-------------------------------------------
//Gravação do cabeçalho da alíquota efetiva
//-------------------------------------------
GravaF1E( cAno, cMes )

Return

//------------------------------------------------------------------
/*/{Protheus.doc} AlqEfetIni

Função que processa as alíquotas efetivas iniciais de processamento.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function AlqEfetIni( cAno, cMes, oAnexo )

Local aAlq		:= {}
Local nIrpj		:= 0
Local nCSLL		:= 0
Local nCOFINS	:= 0
Local nPis		:= 0
Local nCPP		:= 0
Local nIPI		:= 0
Local nICMS		:= 0
Local nISS		:= 0

nIrpj	:= NoRound( oAnexo:getAliqIRPJ() * 100 )
nCSLL	:= NoRound( oAnexo:getAliqCSLL() * 100 )
nCOFINS	:= NoRound( oAnexo:getAliqCOF()  * 100 )
nPis	:= NoRound( oAnexo:getAliqPIS()  * 100 )
nCPP	:= NoRound( oAnexo:getAliqCPP()  * 100 )
nIPI	:= NoRound( oAnexo:getAliqIPI()  * 100 )
nICMS	:= NoRound( oAnexo:getAliqICMS() * 100 )
nISS	:= NoRound( oAnexo:getAliqISS()  * 100 )

aAdd( aAlq, { oAnexo:getNumero(), nIrpj , nCSLL , nCOFINS , nPis ,nCPP , nIPI , nICMS , nISS })

//----------------------------------------
//Grava na tabela F16 as alíquotas obtidas.
//----------------------------------------
GravaF16( cAno, cMes, aAlq )

Return

//------------------------------------------------------------------
/*/{Protheus.doc} ChkAprovAliq

Função que verifica se existe alguma alíquota efetiva aprovada para a filial
que está sendo reprocessada. Se existir não permitirá reprocessamento ou exclusão
da apuração.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function ChkAprovAliq()

local cIdApur	:= F1A->F1A_ID
Local cRet		:= ""
Local nX		:= 0
Local aFil		:= GetFilial( .F. )
Local aAreaSM0 	:= SM0->(GetArea())

F18->( DbSetOrder ( 3 ) )
For nX	:= 1 to Len( aFil )

	SM0->(DbGoTop ())
	SM0->(MsSeek (aFil[nX][1]+aFil[nX][2], .T.))
	cFilAnt := FWGETCODFILIAL

	//Verifica se já existe F18 gravada no período
	If F18->( DbSeek ( xFilial('F18') + cIdApur ) )

		//Verifica se existe alíquotas aprovadas em todas as filiais para o período selecionado.
		If F1E->( DbSeek ( xFilial('F1E') + Year2Str(F18->F18_PER) + Month2Str(F18->F18_PER)  ) ) .AND. F1E->F1E_APROV == '1'
			cRet += "Filial : " + cFilAnt + CHR(10)+CHR(13)
		EndIF
	
	EndIF	

Next nX

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} ChkCompTab

Função que faz verificação inicial com o compartilhamento das tabelas,
se houver compartilhamento divergente exibirá mensagem para usuário, 
alertando que poderá ocorrer erro, porém não impedirá o processo.

@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function ChkCompTab ( )

Local lErro			:= .F.
Local aAlias		:= {}
Local nCont			:= 0
Local cTit			:= 'Atenção, o compartilhamento das tabelas abaixo não está de acordo com o recomendado:'
Local cMsg			:= ''

AADD(aAlias,{'F10',3,'C'}) //Compartilhado empresa
AADD(aAlias,{'F11',3,'E'}) //Exclusívo filial
AADD(aAlias,{'F12',3,'C'}) //Compartilhado empresa
AADD(aAlias,{'F13',3,'C'}) //Compartilhado empresa
AADD(aAlias,{'F17',3,'C'}) //Compartilhado empresa
AADD(aAlias,{'F14',3,'C'}) //Compartilhado empresa
AADD(aAlias,{'F15',3,'C'}) //Compartilhado empresa
AADD(aAlias,{'F16',3,'E'}) //Exclusívo filial
AADD(aAlias,{'F18',3,'E'}) //Exclusívo filial 
AADD(aAlias,{'F19',3,'E'}) //Exclusívo filial
AADD(aAlias,{'F1A',3,'E'}) //Exclusívo filial
AADD(aAlias,{'F1B',3,'E'}) //Exclusívo filial
AADD(aAlias,{'F1C',3,'C'}) //Compartilhado empresa
AADD(aAlias,{'F1D',3,'C'}) //Compartilhado empresa
AADD(aAlias,{'F1E',3,'E'}) //Exclusívo filial

//Verifica compatibilidade das tabelas de acordo com opção de apuração consolidada ou individualizada.	
For nCont	:= 1 to Len(aAlias)
	
	cModo	:= FWModeAccess( aAlias[nCont][1] , aAlias[nCont][2] ) 
	//Se o modo retornado for diferente do modo esperado, exibirá mensagem para usuário
	If cModo <> aAlias[nCont][3]	
		cMsg +=aAlias[nCont][1] + Iif( nCont == Len(aAlias),'' ,',' )
		lErro	:= .T. 
	EndIF	
	
Next nCont

If lErro
	MsgInfo( cTit  + CHR(10)+CHR(13) + cMsg + CHR(10)+CHR(13) + 'Isso poderá ocasionar incosistências na apuração.' )
EndIF

Return 


//------------------------------------------------------------------
/*/{Protheus.doc} FSA153DOBJ

Função que destroi objeto. Verifico a versão pois na versão 11 não consigo
executar o FreeObj após atribuir Nil no objeto.
@author Erick G. Dias
@since 27/03/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function FSA153DOBJ(oObj)

Local cVersao := GetVersao(.F.)

If cVersao <> "12"
	oObj := NIL
Else
	oObj := NIL
	FreeObj(oObj)
EndIf

Return

