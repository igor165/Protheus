#INCLUDE "JURA201.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

//Para desativar a emissão de pré-fatura por thread, mudar a variável "Static THREAD" para .F.
//ATENÇÃO: ao fazer o commit certifique-se para que essas alterações não subam!!!

Static LOG         := .F.
Static THREAD      := .T.
Static lTSZR       := .T.
Static lIntegracao
Static lIntRevis

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA201
Emissão da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA201(lAutomato, cTestCase)
Local aCbxResult     := { STR0001, STR0002, STR0058, STR0059 } //"Impressora", "Tela", "Word", "Nenhum"
Local aCbxSituac     := {}
Local aSituSoc       := { STR0114, STR0115, STR0116 } //"Todos", "Ativos", "Inativos"
Local lIsTop         := .T.
Local lOk            := .F.
Local lForceDate     := .F.
Local cRet           := '0'  // 0 - problemas na emissão; 1 - não encontrou dados para emissão; 2 - emitida com exito
Local oChkPenden     := Nil
Local oChkFech       := Nil
Local oChkAdi        := Nil
Local oChkFxNc       := Nil
Local oSocio         := Nil
Local oMoeda         := Nil
Local oEscrit        := Nil
Local oTipoTS        := Nil
Local oTipoRF        := Nil
Local oExcSoc        := Nil
Local oSitSoc        := Nil
Local oChkApagar     := Nil
Local oChkApaMP      := Nil
Local oChkCorrigir   := Nil
Local oChkDes        := Nil
Local oChkTS         := Nil
Local oChkNaoImp     := Nil
Local oChkTab        := Nil
Local oGetGrup       := Nil
Local oTipoDes       := Nil
Local oTipoFech      := Nil
Local oDlg           := Nil
Local oPnl           := Nil
Local oGrid          := Nil
Local oCbxSituac     := Nil
Local oLkUpSA1       := __FWLookUp('SA1NUH')
Local lTudPend       := SuperGetMV( 'MV_JTDPEND',, .T. )  // Habilita o campo "Emitir tudo pendente"
Local aRetAuto       := {}
Local bConfir        := {||}
Local oLayer         := FWLayer():New()
Local oMainColl      := Nil
Local cLojaAuto      := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oFilaExe       := JurFilaExe():New("JURA201")
Local lVldUser       := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.) // Valida o participante relacionado ao usuário logado
Local lPDUserAc      := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
Local nLinTdPen      := 140
Local lCpoTpFech     := NX0->(ColumnPos('NX0_TPFECH')) > 0 // Proteção para o campo de Tipo de Fechamento para o release 12.1.30 
Local lCpoFxNc       := NX0->(ColumnPos('NX0_FXNC')) > 0 // Proteção para campo de contratos fixos ou não cobráveis

Private cGetCaso     := Space( 240 )
Private cCbxResult   := Space( 25 )
Private cCbxSituac   := '2'
Private cGetClie     := Criavar( 'A1_COD'    , .F. )
Private cContratos   := Space( 250 )
Private cEscrit      := Criavar( 'NS7_COD'   , .F. )
Private cExceto      := Space( 230 )
Private cGetGrup     := Criavar( 'ACY_GRPVEN', .F. )
Private cGetLoja     := Criavar( 'A1_LOJA'   , .F. )
Private cMoeda       := Criavar( 'CTO_MOEDA' , .F. )
Private cSocio       := Criavar( 'RD0_SIGLA' , .F. )
Private cTipoRF      := Criavar( 'NRJ_COD'   , .F. )
Private cTipoDes     := Space( 250 )
Private cTipoTS      := Criavar( 'NRD_COD'   , .F. )
Private cSituSoc     := STR0114 //"Todos"
Private cExcSoc      := Space( 230 )
Private cTipoFech    := IIf(ChkFile("OHU"), Criavar( 'OHU_CODIGO', .F. ), "") //Proteção para o campo de Tipo de Fechamento para o release 12.1.30
Private dDtIniHon    := CToD( '01/01/1900' )
Private dDtFinHon    := dDataBase
Private dDtIniDes    := CToD( '01/01/1900' )
Private dDtFinDes    := dDataBase
Private dDtIniTab    := CToD( '01/01/1900' )
Private dDtFinTab    := dDataBase
Private dDtFinAdi    := CToD( '  /  /  ' )
Private dDtIniAdi    := CToD( '  /  /  ' )
Private dDtIniFxNc   := CToD( '  /  /  ' )
Private dDtFinFxNc   := CToD( '  /  /  ' )

Private lChkTS       := .T.
Private lChkDes      := .T.
Private lChkTab      := .T.
Private lChkHon      := .F.
Private lChkDesF     := .T.
Private lChkTabF     := .T.
Private lChkAdi      := .F.
Private lChkApagar   := .T.
Private lChkApaMP    := .F.
Private lChkCorrigir := .F.
Private lChkNaoImp   := .F.
Private lChkPenden   := .F.
Private lChkFech     := .F.
Private lChkTdCont   := .F.
Private lChkTdCaso   := .F.
Private lChkFxNc     := .F.

Private oGetCaso     := Nil
Private oGetClie     := Nil
Private oContratos   := Nil
Private oGetLoja     := Nil
Private oDtFinAdi    := Nil
Private oDtFinDes    := Nil
Private oChkTdCont   := Nil
Private oChkTdCaso   := Nil
Private oChkHon      := Nil
Private oChkTabF     := Nil
Private oChkDesF     := Nil
Private oDtFinTab    := Nil
Private oDtInAdi     := Nil
Private oDtIniDes    := Nil
Private oDtIniHon    := Nil
Private oDtIniTab    := Nil
Private oDtFinHon    := Nil
Private oExceto      := Nil
Private oDtIniFxNc   := Nil
Private oDtFinFxNc   := Nil
Private cSocAtivo    := "3"  //Variavel private para controle da consulta padarao 'RD0JUR' "3-Todos", "2-Ativos", "1-Inativos"

Default lAutomato    := .F.
Default cTestCase    := "JURA201TestCase"

If lVldUser .And. oFilaExe:OpenWindow(.T.) //Indica que a tela está em execução para Thread de relatório
	
	oLkUpSA1:SetRetFunc( { |x,y| LKRetSA1(x, y, @cGetClie, @cGetLoja ) } )

	lIntegracao  := (SuperGetMV("MV_JFSINC", .F., '2') == '1') //Adicionado para não afetar a performance da tela quando o parâmetro de fila de integração está desativado
	lIntRevis    := lIntegracao .And. (SuperGetMV("MV_JREVILD", .F., '2') == '1') //Controla a integracao da revisão de pré-fatura com o Legal Desk

	If lIntRevis // Utiliza LD e Revisão via LD
		aCbxSituac := { JurSitGet("1"), JurSitGet("2"), JurSitGet("4"), JurSitGet("5"), JurSitGet("C") } //"Conferência"###"Análise"###"Emitir Fatura"###"Emitir Minuta"###"Em Revisão"
	Else // Não utiliza LD e não revisão via LD
		aCbxSituac := { JurSitGet("1"), JurSitGet("2"), JurSitGet("4"), JurSitGet("5"), JurSitGet("9") } //"Conferência"###"Análise"###"Emitir Fatura"###"Emitir Minuta"###"Minuta Sócio"
	EndIf

	SetCloseThread(.F.)

	#IFDEF TOP
		lIsTop := .T.
	#ELSE
		lIsTop := .F.
	#ENDIF

	SetKEY(VK_F8 , {|| J201F8()})
	SetKEY(VK_F9 , {|| J201F9()})
	SetKEY(VK_F11, {|| J201SaveLOG(LOG := !LOG), MsgInfo(STR0076 + IIF(LOG, STR0079, STR0080)) }) // "O log de emissão esta: " e "ligado" "desligado"

	oGrid := JURTHREAD():New()
	oGrid:SetFunction("JA201AEmi")
	oGrid:SetLog({|| J201ReadLOG() })
	oGrid:SetLAutomato(lAutomato)

	oGrid:StartThread()

	If !lAutomato

		oFilaExe:StartReport(lAutomato) //Inicia a thread emissão do relatório

		J201NewLOG()

		If !lPDUserAc
			cCbxResult := aCbxResult[4] // Nenhum
		EndIf

		Define MsDialog oDlg Title STR0009 FROM 176, 188 To IIF(lCpoFxNc, 740, 660), 980 Pixel //"Emissão de Pré Fatura"

		oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
		oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
		oMainColl := oLayer:GetColPanel( 'MainColl' )

		oPnl := tPanel():New(0, 0, '', oMainColl,,,,,, 0, 0)
		oPnl:Align := CONTROL_ALIGN_ALLCLIENT

		/*****************************************************************************************/
		//Hora
		@ 002, 002 To 122, 45 Label STR0033 Pixel Of oPnl //" Hora "
		/*****************************************************************************************/

		@ 010, 005 Say STR0010 Size 040, 008 Pixel Of oPnl //( Time-Sheet )

		//Honorários
		@ 030, 011 CheckBox oChkTS Var lChkTS Prompt STR0011 Size 040, 008 Pixel Of oPnl; //"Ativar"
		On Change LmpDatas( oDtIniHon, oDtFinHon, @dDtIniHon, @dDtFinHon, lChkTS, lChkHon, 0, oChkAdi, oChkTS, oChkDes, oChkTab, oChkHon, oChkDesF, oChkTabF, oChkFxNc, lCpoFxNc )
		//Despesas
		@ 066, 011 CheckBox oChkDes Var lChkDes Prompt STR0011 Size 040, 008 Pixel Of oPnl; //"Ativar"
		On Change LmpDatas( oDtIniDes, oDtFinDes, @dDtIniDes, @dDtFinDes, lChkDes, lChkDesF, 0, oChkAdi, oChkTS, oChkDes, oChkTab, oChkHon, oChkDesF, oChkTabF, oChkFxNc, lCpoFxNc )
		//Tabelado
		@ 102, 011 CheckBox oChkTab Var lChkTab Prompt STR0011 Size 040, 008 Pixel Of oPnl; //"Ativar"
		On Change LmpDatas( oDtIniTab, oDtFinTab, @dDtIniTab, @dDtFinTab, lChkTab, lChkTabF, 0, oChkAdi, oChkTS, oChkDes, oChkTab, oChkHon, oChkDesF, oChkTabF, oChkFxNc, lCpoFxNc )

		/*****************************************************************************************/
		// Demais Casos
		@ 002, 47  To  122, 90 Label STR0018 Pixel Of oPnl //" Demais Casos "
		/*****************************************************************************************/
		@ 010, 054 Say STR0071 Size 040, 008 Pixel Of oPnl //( Parcelas )

		//Honorários
		@ 030, 058 CheckBox oChkHon Var lChkHon Prompt STR0011 Size 040, 008 Pixel Of oPnl; //"Ativar"
		On Change LmpDatas( oDtIniHon, oDtFinHon, @dDtIniHon, @dDtFinHon, lChkTS, lChkHon, 0, oChkAdi, oChkTS, oChkDes, oChkTab, oChkHon, oChkDesF, oChkTabF, oChkFxNc, lCpoFxNc )
		//Despesas
		@ 066, 058 CheckBox oChkDesF Var lChkDesF Prompt STR0011 Size 040, 008 Pixel Of oPnl; //"Ativar"
		On Change LmpDatas( oDtIniDes, oDtFinDes, @dDtIniDes, @dDtFinDes, lChkDes, lChkDesF, 0, oChkAdi, oChkTS, oChkDes, oChkTab, oChkHon, oChkDesF, oChkTabF, oChkFxNc, lCpoFxNc )
		//Tabelado
		@ 102, 058 CheckBox oChkTabF Var lChkTabF Prompt STR0011 Size 040, 008 Pixel Of oPnl; //"Ativar"
		On Change LmpDatas( oDtIniTab, oDtFinTab, @dDtIniTab, @dDtFinTab, lChkTab, lChkTabF, 0, oChkAdi, oChkTS, oChkDes, oChkTab, oChkHon, oChkDesF, oChkTabF, oChkFxNc, lCpoFxNc )

		/*****************************************************************************************/
		// Datas dos lançamentos
		@ 006, 92  To  122, 225 Pixel Of oPnl

		/*****************************************************************************************/
		//Honorários
		/*****************************************************************************************/
		@ 010, 096 Say STR0067 Size 040, 008 Pixel Of oPnl //( Honorários )

		@ 020, 096 Say STR0012 Size 050, 008 Pixel Of oPnl //"Data Inicial"
		@ 030, 096 MsGet oDtIniHon Var dDtIniHon Size 060, 009 Pixel Of oPnl;
		Valid IIf( !Empty(dDtFinHon) .And. dDtIniHon > dDtFinHon, J201MsgDt( STR0013 ), .T.) HasButton // "A data inicial não pode ser maior que a data final."

		@ 020, 160 Say STR0014 Size 050, 008 Pixel Of oPnl //"Data Final"
		@ 030, 160 MsGet oDtFinHon Var dDtFinHon Size 060, 009 Pixel Of oPnl;
		Valid IIf( !Empty(dDtFinHon) .And. dDtIniHon > dDtFinHon, J201MsgDt( STR0015 ), .T.) HasButton // "A data final não pode ser menor que a data inicial."

		/*****************************************************************************************/
		//Despesas
		/*****************************************************************************************/
		@ 045, 095 Say STR0016 Size 040, 008 Pixel Of oPnl //" Despesas "

		@ 056, 096 Say STR0012 Size 060, 008 Pixel Of oPnl //"Data Inicial"
		@ 066, 096 MsGet oDtIniDes Var dDtIniDes Size 060, 009 Pixel Of oPnl;
		Valid IIf( !Empty(dDtFinDes) .And. dDtIniDes > dDtFinDes, J201MsgDt( STR0013 ), .T.) HasButton // "A data inicial não pode ser maior que a data final."

		@ 056, 160 Say STR0014 Size 060, 008 Pixel Of oPnl //"Data Final"
		@ 066, 160 MsGet oDtFinDes Var dDtFinDes Size 060, 009 Pixel Of oPnl;
		Valid IIf( !Empty(dDtFinDes) .And. dDtIniDes > dDtFinDes, J201MsgDt( STR0015 ), .T.) HasButton // "A data final não pode ser menor que a data inicial."

		/*****************************************************************************************/
		// Tabelado
		/*****************************************************************************************/
		@ 083, 095 Say STR0017 Size 040, 008 Pixel Of oPnl //" Lanc. Tabelado "

		@ 092, 096 Say STR0012 Size 060, 008 Pixel Of oPnl //"Data Inicial"
		@ 102, 096 MsGet oDtIniTab Var dDtIniTab Size 060, 009 Pixel Of oPnl;
		Valid IIf( !Empty(dDtFinTab) .And. dDtIniTab > dDtFinTab, J201MsgDt( STR0013 ), .T.) HasButton // "A data inicial não pode ser maior que a data final."

		@ 092, 160 Say STR0014 Size 060, 008 Pixel Of oPnl //"Data Final"
		@ 102, 160 MsGet oDtFinTab Var dDtFinTab Size 060, 009 Pixel Of oPnl;
		Valid IIf( !Empty(dDtFinTab) .And. dDtIniTab > dDtFinTab, J201MsgDt( STR0015 ), .T.) HasButton // "A data final não pode ser menor que a data inicial."

		/*****************/
		// Filtros
		@ 002, 227  To  160, 394 Label STR0021 Pixel Of oPnl //" Filtro "

		@ 010, 232 Say STR0022 Size 070, 008 Pixel Of oPnl //"Sócio"
		@ 017, 232 MsGet oSocio Var cSocio   Size 075, 009 When !lChkPenden Pixel Of oPnl F3 'RD0REV';
		Valid ( Empty( cSocio ) .Or. ( ExistCpo( 'RD0', cSocio, 9) .And. JA201VGCLC('Socio', @cGetGrup, @cGetClie, @cGetLoja, @cGetCaso, @cSocio, @cSituSoc, @cExcSoc) ) ) HasButton
		oSocio:bF3 := {|| JbF3LookUp('RD0REV', oSocio, @cSocio)}

		@ 010, 315 Say STR0023 Size 070, 008 Pixel Of oPnl //"Moeda"
		@ 017, 315 MsGet oMoeda Var cMoeda   Size 075, 009 Pixel Of oPnl F3 'CTO';
		Valid ( Empty( cMoeda ) .Or. ExistCpo( 'CTO', cMoeda ) ) HasButton
		oMoeda:bF3 := {|| JbF3LookUp('CTO', oMoeda, @cMoeda)}

		@ 030, 232 Say STR0027 Size 021, 008 Pixel Of oPnl //"Contrato"
		@ 029, 270 CheckBox oChkTdCont Var lChkTdCont Prompt STR0068 Size 040, 008 Pixel Of oPnl When (!Empty(cContratos) .And. !lChkPenden) // Todos On Change
		@ 037, 232 MsGet oContratos Var cContratos Size 075, 009 Pixel Of oPnl F3 'J96NT0';
		Valid ((Empty( cContratos ) .Or. J201VldCpo(cContratos, "NT0", 1, 'NT0_COD', STR0027)) .And. JA201VLC()) HasButton
		oContratos:bF3 := {|| JbF3LUpMul('NT0', oContratos, @cContratos)}
		oContratos:bSetGet := {|u| If(Pcount() > 0, cContratos := PADR(u, 250, " "), PADR(cContratos, 250, " ")) }

		@ 030, 315 Say STR0026 Size 060, 008 Pixel Of oPnl //"Grupo de Clientes"
		@ 037, 315 MsGet oGetGrup Var cGetGrup Size 075, 009 Pixel Of oPnl  F3 'ACY';
		Valid ( Empty( cGetGrup ) .Or. JA201VGCLC('Grupo', @cGetGrup,  @cGetClie, @cGetLoja, @cGetCaso) ) HasButton;
		When (Empty(cGetCaso) .And. !lChkPenden)
		oGetGrup:bF3 := {|| JbF3LookUp('ACY', oGetGrup, @cGetGrup)}

		@ 050, 232 Say STR0024 Size 060, 008 Pixel Of oPnl          //"Cliente"
		@ 057, 232 MsGet oGetClie Var cGetClie Size 055, 009 Pixel Of oPnl F3 'SA1NUH';
		Valid {|| ( JA201VGCLC('Cliente', @cGetGrup,  @cGetClie, @cGetLoja, @cGetCaso) ) .And. JA201VLC() .And. ;
		J201VldFaCs(lChkAdi,@oChkTdCaso, @lChkTdCaso, cGetClie, cGetLoja, cGetCaso) } HasButton;
		When (Empty(cGetCaso) .And. !lChkPenden)
		oGetClie:bF3 := {|a,b,c| Iif(oLkUpSA1:Activate(cGetClie+cGetLoja),;
		(oLkUpSA1:ExecuteReturn(oGetClie), oGetClie:lModified := .T., oGetLoja:lModified := .T., oGetLoja:Refresh());
		, Nil), oLkUpSA1:DeActivate()}

		//Loja
		@ 057, 287 MsGet oGetLoja     Var cGetLoja    Size 020, 009 Pixel Of oPnl;
		Valid {|| ( JA201VGCLC('Loja', @cGetGrup,  @cGetClie, @cGetLoja, @cGetCaso) ) .And.  JA201VLC() .And. ;
		J201VldFaCs(lChkAdi, @oChkTdCaso, @lChkTdCaso, cGetClie, cGetLoja, cGetCaso)} HasButton;
		When (Empty(cGetCaso) .And. !lChkPenden)
		Iif (cLojaAuto == "1", oGetLoja:Hide(), )

		@ 050, 315 Say STR0025 Size 060, 008 Pixel Of oPnl //"Caso"
		@ 049, 353 CheckBox oChkTdCaso Var lChkTdCaso Prompt STR0068 Size 040, 008 Pixel Of oPnl When (!Empty(cGetCaso) .And. !lChkPenden) // Todos On Change
		@ 057, 315 MsGet oGetCaso Var cGetCaso Size 075, 009 Pixel Of oPnl F3 'NVELOJ';
		Valid {|| (JA201VGCLC('Caso', @cGetGrup, @cGetClie, @cGetLoja, @cGetCaso)) .And. JA201VLC() .And. ;
		J201VldFaCs(lChkAdi, @oChkTdCaso, @lChkTdCaso, cGetClie, cGetLoja, cGetCaso) } When JA202WC(cGetClie, cGetLoja, @cGetCaso, cContratos) HasButton
		oGetCaso:bF3  := {|| JbF3LUpMul('NVELOJ', oGetCaso, @cGetCaso)}
		oGetCaso:bSetGet := {|u| if(Pcount()>0, cGetCaso := PADR(u, 250, " "), PADR(cGetCaso, 250, " ")) }

		@ 070, 232 Say STR0028 Size 060, 008 Pixel Of oPnl //"Exceto Clientes"
		@ 077, 232 MsGet oExceto Var cExceto Size 075, 009 Pixel Of oPnl F3 'SA1PR2' ;
		Valid (Empty( cExceto ) .Or. J201VldCpo(cExceto, "SA1", 1, 'A1_COD', STR0028) ) HasButton
		oExceto:bF3 := {|| JbF3LUpMul('SA1PR2', oExceto, @cExceto)}

		@ 070, 315 Say STR0029 Size 060, 008 Pixel Of oPnl //"Escritório"
		@ 077, 315 MsGet oEscrit Var cEscrit Size 075, 009 Pixel Of oPnl F3 'NS7';
		Valid ( Empty( cEscrit ) .Or. ExistCpo( 'NS7', cEscrit ) ) HasButton
		oEscrit:bF3 := {|| JbF3LookUp('NS7', oEscrit, @cEscrit)}

		@ 090, 232 Say STR0030 Size 060, 008 Pixel Of oPnl //"Tipo de Despesas"
		@ 097, 232 MsGet oTipoDes Var cTipoDes Size 075, 009 Pixel Of oPnl F3 'NRH' ;
		Valid (Empty( cTipoDes ) .Or. J201VldCpo(cTipoDes, "NRH", 1, 'NRH_COD',STR0030)) HasButton
		oTipoDes:bF3 := {|| JbF3LUpMul('NRH', oTipoDes, @cTipoDes)}
		oTipoDes:bSetGet := {|u| if(Pcount() > 0, cTipoDes := PADR(u, 250, " "), PADR(cTipoDes, 250, " ")) }

		@ 090, 315 Say STR0036 Size 100, 008 Pixel Of oPnl //"Tipo de Honorários"
		@ 097, 315 MsGet oTipoTS Var cTipoTS Size 075, 009 Pixel Of oPnl F3 'NRA' ;
		Valid (Empty( cTipoTS ) .Or. ExistCpo( 'NRA', cTipoTS )) HasButton
		oTipoTS:bF3 := {|| JbF3LUpMul('NRA', oTipoTS, @cTipoTS)}

		@ 110, 232 Say STR0110 Size 060, 008 Pixel Of oPnl //"Situação dos Sócios"
		@ 117, 232 ComboBox oSitSoc Var cSituSoc Items aSituSoc Size 076, 012 Pixel Of oPnl ;
		When (Empty(cSocio) .And. !lChkPenden);
		On Change (Iif(oSitSoc:nAt == 1, cSocAtivo := "3", (Iif(oSitSoc:nAt == 2, cSocAtivo := "2", cSocAtivo := "1"), cExcSoc := Space(230))))

		@ 110, 315 Say STR0111 Size 100, 008 Pixel Of oPnl //"Exceto Sócios"
		@ 117, 315 MsGet oExcSoc Var cExcSoc Size 075, 009 Pixel Of oPnl F3 'RD0JUR' ;
		Valid (Empty( cExcSoc ) .Or. J201VldCpo(cExcSoc, "RD0", 9, 'RD0_SIGLA', STR0111, cSocAtivo, "RD0_MSBLQL") ) HasButton ;
		When (Empty(cSocio) .And. !lChkPenden)
		oExcSoc:bF3  := {|| JbF3LUpMul('RD0JUR', oExcSoc, @cExcSoc)}
		oExcSoc:bSetGet := {|u| If(Pcount() > 0, cExcSoc := PADR(u, 230, " "), PADR(cExcSoc, 230, " ")) }

		If lCpoTpFech //Proteção para o campo de Tipo de Fechamento para o release 12.1.30 
			@ 130, 232 Say STR0138 Size 060, 008 Pixel Of oPnl //Tipo de Fechamento
			@ 129, 287 CheckBox oChkFech Var lChkFech Prompt "" Size 040, 008 Pixel Of oPnl;
			On Change (IIf(lChkFech, oTipoFech:Enable(), oTipoFech:Disable()), oTipoFech:SetFocus())
			@ 137, 232 MsGet oTipoFech Var cTipoFech Size 075, 009 Pixel Of oPnl F3 'OHU';
			Valid ((Empty( cTipoFech ) .Or. J201VldCpo(cTipoFech, "OHU", 1, 'OHU_CODIGO', STR0138))) HasButton ;
			When (lChkFech .And. !lChkPenden)
			oTipoFech:bF3 := {|| JbF3LUpMul('OHU', oTipoFech, @cTipoFech)}
			oTipoFech:bSetGet := {|u| If(Pcount() > 0, cTipoFech := PADR(u, 250, " "), PADR(cTipoFech, 250, " ")) }

			nLinTdPen := nLinTdPen + 10
		EndIf

		//"Situação da Pré Fatura"
		@ 130, 315 Say STR0038 Size 060, 008 Pixel Of oPnl
		oCbxSituac := TComboBox():New(137,315,{|u|if(PCount()>0,cCbxSituac:=u,cCbxSituac)},aCbxSituac,76,12,oPnl,,{||},,,,.T.,,,,,,,,,'cCbxSituac') //"Situação da Pré Fatura"
		cCbxSituac := aCbxSituac[2]  //"Situação da Pré Fatura"

		@ nLinTdPen, 232 CheckBox oChkPenden Var lChkPenden Prompt STR0031 Size 060, 008 Pixel Of oPnl; //"Emitir tudo pendente"
		On Change ( IIf( lChkPenden,   (;
											cSocio   := Criavar('RD0_SIGLA', .F.), cMoeda := Criavar( 'CTO_MOEDA', .F. ),;
											cGetClie := Criavar('A1_COD' , .F.), cGetLoja := Criavar( 'A1_LOJA'  , .F. ),;
											cGetCaso := Space( 250 ), cContratos := Space( 250 ),;
											cGetGrup := Criavar('ACY_GRPVEN', .F.), cExceto := Space( 250 ), cExcSoc := Space( 250 ),;
											cEscrit  := Criavar('NS7_COD', .F.), cTipoDes := Space( 250 ), cSituSoc := STR0114 /*"Todos"*/,;
											cTipoTS  := Criavar('NRD_COD', .F.), lChkFech := .F.,;
											lChkTdCont := .F., lChkTdCaso := .F., oChkTdCont:Disable(), oChkTdCaso:Disable(),;
											oChkTdCont:Refresh(), oChkTdCaso:Refresh(),;
											oSocio:Disable(), oMoeda:Disable(), oMoeda:Refresh(), oGetClie:Disable(),;
											oGetLoja:Disable(), oGetCaso:Disable(), oContratos:Disable(),;
											oGetClie:Refresh(), oGetLoja:Refresh(), oGetCaso:Refresh(), oContratos:Refresh(),;
											oExceto:Disable(), oEscrit:Disable(), oTipoDes:Disable(),;
											oGetGrup:Disable(), oTipoTS:Disable(), oExcSoc:Disable(),;
											oSitSoc:Disable(), oTipoFech:Disable(),;
											IIf(lCpoTpFech, oChkFech:Disable(), Nil),;
											IIf(lCpoTpFech, oChkFech:Refresh(), Nil),; 
											oDlg:Refresh();
										),;
										( oSocio:Enable(), oMoeda:Enable(), oGetClie:Enable(),;
											oGetLoja:Enable(), oGetCaso:Enable(), oContratos:Enable(),;
											oExceto:Enable(), oEscrit:Enable(), oTipoDes:Enable(),;
											oGetGrup:Enable(), oTipoTS:Enable(), oEscrit:Enable(),;
											oExcSoc:Enable(), oSitSoc:Enable(),; 
											IIf(lCpoTpFech, oChkFech:Enable(), Nil),;
											oDlg:Refresh() );
						);
					)

		If lTudPend
			oChkPenden:Enable()
		Else
			oChkPenden:Disable()
		EndIf

		//Outros

		//" Faturamento Adicional "
		@ 124, 002 To 160, 225 Label STR0019 Pixel Of oPnl

		@ 141, 011 CheckBox oChkAdi Var lChkAdi Prompt STR0011 Size 040, 008 Pixel Of oPnl; //"Ativar"
		On Change (LmpDatas( oDtInAdi, oDtFinAdi, @dDtIniAdi, @dDtFinAdi, lChkAdi, lChkAdi ,1 ,oChkAdi,oChkTS,oChkDes,oChkTab,oChkHon,oChkDesF,oChkTabF,oChkFxNc,lCpoFxNc),;
		J201VldFaCs(lChkAdi, @oChkTdCaso, @lChkTdCaso, cGetClie, cGetLoja, cGetCaso, "1"))

		@ 132, 096 Say STR0012 Size 060, 008 Pixel Of oPnl //"Data Inicial"
		@ 141, 096 MsGet oDtInAdi Var dDtIniAdi Size 060, 009 Pixel Of oPnl;
		Valid IIf( !Empty(dDtFinAdi) .And. dDtIniAdi > dDtFinAdi, J201MsgDt( STR0013 ), .T.) HasButton // "A data inicial não pode ser maior que a data final."

		@ 132, 160 Say STR0014 Size 060, 008 Pixel Of oPnl //"Data Final"
		@ 141, 160 MsGet oDtFinAdi Var dDtFinAdi Size 060, 009 Pixel Of oPnl ;
		Valid IIf( !Empty(dDtFinAdi) .And. dDtIniAdi > dDtFinAdi, J201MsgDt( STR0015 ), .T.) HasButton // "A data final não pode ser menor que a data inicial."

		// Contratos Fixos ou Não Cobráveis
		If lCpoFxNc
			@ 162, 002 To 207, 225 Label STR0141 Pixel Of oPnl // "Time Sheets de Contratos Fixos/Não Cobráveis"
			@ 182, 011 CheckBox oChkFxNc Var lChkFxNc Prompt STR0011 Size 040, 008 Pixel Of oPnl; //"Ativar"
			On Change (LmpDatas( oDtIniFxNc, oDtFinFxNc, @dDtIniFxNc, @dDtFinFxNc, lChkFxNc, lChkFxNc ,2 ,oChkAdi,oChkTS,oChkDes,oChkTab,oChkHon,oChkDesF,oChkTabF,oChkFxNc,lCpoFxNc),;
			J201VldFaCs(lChkFxNc, @oChkTdCaso, @lChkTdCaso, cGetClie, cGetLoja, cGetCaso, "1"))

			@ 173, 096 Say STR0012 Size 060, 008 Pixel Of oPnl //"Data Inicial"
			@ 182, 096 MsGet oDtIniFxNc Var dDtIniFxNc Size 060, 009 Pixel Of oPnl;
			Valid IIf( !Empty(dDtFinFxNc) .And. dDtIniFxNc > dDtFinFxNc, J201MsgDt( STR0013 ), .T.) HasButton // "A data inicial não pode ser maior que a data final."

			@ 173, 160 Say STR0014 Size 060, 008 Pixel Of oPnl //"Data Final"
			@ 182, 160 MsGet oDtFinFxNc Var dDtFinFxNc Size 060, 009 Pixel Of oPnl ;
			Valid IIf( !Empty(dDtFinFxNc) .And. dDtIniFxNc > dDtFinFxNc, J201MsgDt( STR0015 ), .T.) HasButton // "A data final não pode ser menor que a data inicial."
		EndIf

		//"(diversos)"
		If lCpoFxNc // Possui campo de Time Sheets de Contratos Fixos ou Não Cobráveis
			@ 209, 002  To  250, 394 Pixel Of oPnl
			@ 215, 011 CheckBox oChkApagar    Var lChkApagar    Prompt STR0041 Size 150, 008 Pixel Of oPnl //"Apagar/Substituir pré-faturas existentes neste(s) caso(s) "
			@ 226, 011 CheckBox oChkApaMP     Var lChkApaMP     Prompt STR0112 Size 150, 008 Pixel Of oPnl //"Apagar/Substituir minutas existentes neste(s) caso(s) "
			@ 238, 011 CheckBox oChkCorrigir  Var lChkCorrigir  Prompt STR0113 Size 150, 008 Pixel Of oPnl //"Corrigir valor base do(s) contrato(s) Fixo(s) "
		Else
			@ 165, 002  To  207, 225  Pixel Of oPnl
			@ 170, 011 CheckBox oChkApagar    Var lChkApagar    Prompt STR0041 Size 150, 008 Pixel Of oPnl //"Apagar/Substituir pré-faturas existentes neste(s) caso(s) "
			@ 181, 011 CheckBox oChkApaMP     Var lChkApaMP     Prompt STR0112 Size 150, 008 Pixel Of oPnl //"Apagar/Substituir minutas existentes neste(s) caso(s) "
			@ 193, 011 CheckBox oChkCorrigir  Var lChkCorrigir  Prompt STR0113 Size 150, 008 Pixel Of oPnl //"Corrigir valor base do(s) contrato(s) Fixo(s) "
		EndIf

		//"Impressão"
		@ 162, 227  To  207, 394 Label STR0123 Pixel Of oPnl
		@ 170, 232 Say STR0037 Size 060, 008 Pixel Of oPnl //"Resultado"
		@ 179, 232 ComboBox cCbxResult Items aCbxResult When lPDUserAc Size 076, 012 Pixel Of oPnl
		@ 193, 232 CheckBox oChkNaoImp Var lChkNaoImp Prompt STR0040 Size 150, 008 Pixel Of oPnl //"Não imprimir observação dos casos no relatório"

		@ 170, 315 Say STR0039 Size 070, 008 Pixel Of oPnl //"Tipo de Relatório de Fatura"
		@ 179, 315 MsGet oTipoRF Var cTipoRF Size 075, 009 Pixel Of oPnl F3 'NRJ' ;
		Valid (Empty( cTipoRF ) .Or. J201VldTrf( cTipoRF ) ) HasButton

		oDlg:lEscClose := .F.

		oDtInAdi:Disable()
		oDtFinAdi:Disable()

		If lCpoFxNc
			oDtIniFxNc:Disable()
			oDtFinFxNc:Disable()
		EndIf

		bConfir := {|| IIf( lOk := TudoOk( lChkAdi, lChkDes, lChkTS, lChkTab, lChkDesF, lChkHon, lChkTabF,;
												cExceto, cGetClie, cGetLoja, cGetCaso, cSocio, cMoeda, cContratos,;
												cGetGrup, cEscrit, cTipoDes, cTipoTS, lChkPenden, cExcSoc, lChkFech, cTipoFech, lChkFxNc, cCbxSituac ), ;
												JA201end(lOk, lIsTop, aCbxResult, aCbxSituac, cRet, oGrid), ) }

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bConfir, {||(lOk := .F., oDlg:End())}, , /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

		oFilaExe:CloseWindow() // Indica que tela fechada para o client de impressão ser fechado também.

	Else // Via Automação
		If FindFunction("GetParAuto")
			aRetAuto := GetParAuto(cTestCase)
		EndIf

		// Força as datas enviadas no aRetAuto, mesmo que vazias
		lForceDate   := FWIsInCallStack("JUR201_056") .Or. FWIsInCallStack("JUR201_057") .Or. FWIsInCallStack("JUR201_058")

		cCbxSituac   := aRetAuto[1][1]
		cCbxResult   := aRetAuto[1][2]
		lChkAdi      := aRetAuto[1][3]
		lChkDes      := aRetAuto[1][4]
		lChkTS       := aRetAuto[1][5]
		lChkTab      := aRetAuto[1][6]
		lChkDesF     := aRetAuto[1][7]
		lChkHon      := aRetAuto[1][8]
		lChkTabF     := aRetAuto[1][9]
		cExceto      := aRetAuto[1][10]
		cGetClie     := aRetAuto[1][11]
		cGetLoja     := aRetAuto[1][12]
		cGetCaso     := aRetAuto[1][13]
		cSocio       := aRetAuto[1][14]
		cMoeda       := aRetAuto[1][15]
		cContratos   := aRetAuto[1][16]
		cGetGrup     := aRetAuto[1][17]
		cEscrit      := aRetAuto[1][18]
		cTipoDes     := aRetAuto[1][19]
		cTipoTS      := aRetAuto[1][20]
		lChkPenden   := aRetAuto[1][21]
		dDtIniHon    := Iif( Len(aRetAuto[1]) >= 22 .And. (lForceDate .Or. !Empty(aRetAuto[1][22])), aRetAuto[1][22], dDtIniHon )
		dDtFinHon    := Iif( Len(aRetAuto[1]) >= 23 .And. (lForceDate .Or. !Empty(aRetAuto[1][23])), aRetAuto[1][23], dDtFinHon )
		dDtIniDes    := Iif( Len(aRetAuto[1]) >= 24 .And. (lForceDate .Or. !Empty(aRetAuto[1][24])), aRetAuto[1][24], dDtIniDes )
		dDtFinDes    := Iif( Len(aRetAuto[1]) >= 25 .And. (lForceDate .Or. !Empty(aRetAuto[1][25])), aRetAuto[1][25], dDtFinDes )
		dDtIniTab    := Iif( Len(aRetAuto[1]) >= 26 .And. (lForceDate .Or. !Empty(aRetAuto[1][26])), aRetAuto[1][26], dDtIniTab )
		dDtFinTab    := Iif( Len(aRetAuto[1]) >= 27 .And. (lForceDate .Or. !Empty(aRetAuto[1][27])), aRetAuto[1][27], dDtFinTab )
		dDtIniAdi    := Iif( Len(aRetAuto[1]) >= 28 .And. !Empty(aRetAuto[1][28])                  , aRetAuto[1][28], dDtIniAdi )
		dDtFinAdi    := Iif( Len(aRetAuto[1]) >= 29 .And. !Empty(aRetAuto[1][29])                  , aRetAuto[1][29], dDtFinAdi )
		lChkApagar   := Iif( Len(aRetAuto[1]) >= 30 .And. !Empty(aRetAuto[1][30])                  , aRetAuto[1][30], lChkApagar )
		lChkTdCont   := Iif( Len(aRetAuto[1]) >= 31 .And. !Empty(aRetAuto[1][31])                  , aRetAuto[1][31], lChkTdCont )
		lChkCorrigir := Iif( Len(aRetAuto[1]) >= 32 .And. !Empty(aRetAuto[1][32])                  , aRetAuto[1][32], lChkCorrigir )
		lChkApaMP    := Iif( Len(aRetAuto[1]) >= 33 .And. !Empty(aRetAuto[1][33])                  , aRetAuto[1][33], lChkApaMP )
		lChkTdCaso   := Iif( Len(aRetAuto[1]) >= 34 .And. !Empty(aRetAuto[1][34])                  , aRetAuto[1][34], lChkTdCaso )
		cExcSoc      := Iif( Len(aRetAuto[1]) >= 35 .And. !Empty(aRetAuto[1][35])                  , aRetAuto[1][35], cExcSoc )
		lChkFech     := Iif( Len(aRetAuto[1]) >= 36 .And. !Empty(aRetAuto[1][36])                  , aRetAuto[1][36], lChkFech )
		cTipoFech    := Iif( Len(aRetAuto[1]) >= 37 .And. !Empty(aRetAuto[1][37])                  , aRetAuto[1][37], cTipoFech )
		lChkFxNc     := Iif( Len(aRetAuto[1]) >= 38 .And. !Empty(aRetAuto[1][38])                  , aRetAuto[1][38], lChkFxNc )
		dDtIniFxNc   := Iif( Len(aRetAuto[1]) >= 39 .And. (lForceDate .Or. !Empty(aRetAuto[1][39])), aRetAuto[1][39], dDtIniFxNc )
		dDtFinFxNc   := Iif( Len(aRetAuto[1]) >= 40 .And. (lForceDate .Or. !Empty(aRetAuto[1][40])), aRetAuto[1][40], dDtFinFxNc )

		lOk := TudoOk( lChkAdi, lChkDes, lChkTS, lChkTab, lChkDesF, lChkHon, lChkTabF, cExceto, cGetClie, cGetLoja,;
		               cGetCaso, cSocio, cMoeda, cContratos, cGetGrup, cEscrit, cTipoDes, cTipoTS, lChkPenden, cExcSoc,;
		               lChkFech, cTipoFech, lChkFxNc, cCbxSituac )

		JA201end(lOk, lIsTop, aCbxResult, aCbxSituac, cRet, oGrid, lAutomato)

		//Aguarda o retorno da Thread
		Iif(THREAD, IPCWaitEx("JTESTCASE", 360000),)

	EndIf

EndIf

J201DelLOG()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J201MsgDt
Função para exibir a mensagem de erro da validação dos campos de data

@Param  cMsg - Mensagem de aviso de falha

@Return  .F.

@author  Jonatas Martins / Jorge Martins
@since   09/05/2019
@Obs     Só entra nessa função quando falha a validação de data
/*/
//-------------------------------------------------------------------
Static Function J201MsgDt(cMsg)
	ApMsgStop( cMsg )
Return (.F.)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201VldFaCs
Validação para emissão dos casos da fatura adicional.

@Param  lChkAdi      - variável lógica do checkbox da FA
@Param  oChkTdCaso   - Objeto do checkbox de Casos (por referência)
@Param  lChkTdCaso   - variável lógica do checkbox de Casos (por referência)
@Param  cGetClie     - Cliente
@Param  cGetLoja     - Loja
@Param  cGetCaso     - Caso
@Param  cOrigem      - Campo de origem: 1 = FA;
                                        2 = Outros;

@Return  .T.

@author Luciano Pereira dos Santos
@since 15/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201VldFaCs(lChkAdi, oChkTdCaso, lChkTdCaso, cGetClie, cGetLoja, cGetCaso, cOrigem)
Local lRet      := .T.
Default cOrigem := '2'

If lChkAdi .And. (!Empty(cGetClie) .Or. !Empty(cGetLoja) .Or. !Empty(cGetCaso))
	oChkTdCaso:Disable()
	lChkTdCaso := .T.
ElseIf (!lChkAdi .And. cOrigem = '1') .Or. (Empty(cGetClie) .And. Empty(cGetLoja) .And. Empty(cGetCaso))
	oChkTdCaso:Enable()
	lChkTdCaso := .F.
EndIf

oChkTdCaso:Refresh()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202WC()
Modo de edição do campo Caso de emissão de pré-fatura

@author Luciano Pereira dos Santos
@since 13/06/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202WC(cGetClie, cGetLoja, cGetCaso, cContratos)
Local lRet     := .T.
Local cMVJcaso := GetMV('MV_JCASO1',, '1')

If cMVJcaso == '1'
	lRet := !(Empty(cGetClie) .Or. Empty(cGetLoja))
	If !lRet
		cGetCaso := Space( 250 )
	EndIf
ElseIf cMVJcaso == '2' .And. !Empty(cContratos)
	cGetCaso := Space( 250 )
	lRet     := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201VGCLC
Valida Grupo / Cliente / Loja e Caso

@author David Fernandes
@since 13/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201VGCLC(cCampo, cGetGrup, cGetClie, cGetLoja, cGetCaso, cSocio, cSituSoc, cExcSoc)
Local lRet       := .T.
Local nCont      := 0
Local cCopyCaso  := ""
Local cMVJcaso   := SuperGetMV('MV_JCASO1',, '1') //Defina a sequência da numeração do Caso. (1- Por cliente;2- Independente do cliente.)
Local aArea      := GetArea()
Local cLojaAuto  := SuperGetMV('MV_JLOJAUT', .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cCVarCli   := Criavar('A1_COD', .F. )
Local cCVarLoj   := Criavar('A1_LOJA', .F. )
Local cCVarCas   := Criavar('NVE_NUMCAS', .F. )
Local aCasos     := {}
Local aCliLoj    := {}

	If cCampo == "Grupo"
		lRet := JurVldCli(cGetGrup, cGetClie, cGetLoja,,, "GRP")

		If (lRet .And. !JurClxGr(cGetClie, cGetLoja, cGetGrup)) //Se grupo NÃO pertence ao cliente
			cGetClie := cCVarCli
			cGetLoja := cCVarLoj
			cGetCaso := Space( 240 )
		EndIf

	ElseIf cCampo == "Cliente"
		If (cLojaAuto == "1")
			Iif (Empty(cGetClie), cGetLoja := "", cGetLoja := JurGetLjAt())
		EndIf
		lRet := JurVldCli(cGetGrup, cGetClie, cGetLoja,,, "CLI")

		Iif(lRet, cGetCaso := cCVarCas,)
		If (lRet .And. !Empty(cGetClie) .And. !Empty(cGetLoja)) //Gatilho
			cGetGrup := JurGetDados('SA1', 1, xFilial('SA1') + cGetClie + cGetLoja, 'A1_GRPVEN')

			If Len(aCasos := StrTokArr(Alltrim(cGetCaso), ";")) > 0
				//Verificar se o primeiro caso selecionado pertence ao cliente selecionado, senão pertencer ele é apagado.
				Iif(JurClxCa(cGetClie, cGetLoja, aCasos[1]), , cGetCaso := "")
			EndIf

		EndIf

	ElseIf cCampo == "Loja" .And. !Empty(cGetLoja)
		lRet := JurVldCli(cGetGrup, cGetClie, cGetLoja,,, "LOJ")

		Iif(lRet, cGetCaso := cCVarCas,)
		If(lRet .And. !Empty(cGetClie)) //Gatilho
			cGetGrup := JurGetDados('SA1', 1, xFilial('SA1') + cGetClie + cGetLoja, 'A1_GRPVEN')
			If Len(aCasos := StrTokArr(Alltrim(cGetCaso), ";")) > 0
				//Verificar se o primeiro caso selecionado pertence ao cliente selecionado, senão pertencer ele é apagado.
				Iif(JurClxCa(cGetClie, cGetLoja, aCasos[1]), , cGetCaso := "")
			EndIf
		EndIf

	ElseIf cCampo == 'Caso' .And. !Empty(cGetCaso)

		aCasos := StrTokArr(Alltrim(cGetCaso), ";")

		For nCont := 1 To Len(aCasos)
			cCopyCaso := aCasos[nCont]

			If cMVJcaso == "2" .And. !Empty(cCopyCaso)
				aCliLoj := JCasoAtual(cCopyCaso)
				If !Empty(aCliLoj)
					cGetClie := aCliLoj[1][1]
					cGetLoja := aCliLoj[1][2]
					cGetGrup := JurGetDados('SA1', 1, xFilial('SA1') + cGetClie + cGetLoja, 'A1_GRPVEN')
				EndIf
			EndIf

			lRet := JurVldCli(cGetGrup, cGetClie, cGetLoja, cCopyCaso,, "CAS")

		Next nCont

		// Quando houver mais de um caso, os campos de cliente devem ser limpos.
		If lRet .And. cMVJcaso == "2" .And. Len(aCasos) > 1
			cGetClie := cCVarCli
			cGetLoja := cCVarLoj
			cGetGrup := cCVarCas
		EndIf

	ElseIf cCampo == "Socio" .And. !Empty(cSocio)
		cSituSoc := STR0114
		cExcSoc  := ""
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201end()

@author
@since 25/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201end(lOk, lIsTop, aCbxResult, aCbxSituac, cRet, oGrid, lAutomato)
Local cSvSet4     := Set(4, "dd/mm/yyyy")
Local lRet        := .T.
Local aRet        := {}

Default lAutomato := .F.

Set(4, cSvSet4) // retorna o padrão de data

If !lOk
	Return NIL
EndIf

// Conversao de alguns campos
If ValType(cCbxResult) <> "N" .And. Len(cCbxResult) > 1
	cCbxResult := AllTrim( Str( aScan( aCbxResult, cCbxResult ) ) )
EndIf
If ValType(cCbxSituac) <> "N" .And. Len(cCbxSituac) > 1
	cCbxSituac := AllTrim( Str( aScan( aCbxSituac, cCbxSituac ) ) )
	// Integração e Revisão com LD habilitada
	If lIntRevis .And. cCbxSituac == "5"
		cCbxSituac := "6"
	EndIf
EndIf

// Verifica se existem Time-Sheets com particiapante sem categoria, em positivo retorna o numero do TS para gerar o Relatório
If lChkTS .And. lTSZR
	Processa( { || aRet := JA201TsZr() }, STR0043, STR0044, .F. ) //"Aguarde"###"Emitindo pré-faturas ..."
Else
	aRet := {.T., ''}
EndIf

If aRet[1]
	Processa( { || cRet := Runproc(lAutomato) }, STR0043, STR0044, .T. ) //"Aguarde"###"Emitindo pré-faturas ..."
Else
	If !Empty(aRet[2])
		ApMsgStop(aRet[2])
	EndIf
	cRet := '4'
EndIf

Do Case
	Case cRet == '0'
		ApMsgStop( STR0046 ) //"Emissão terminada com problemas."
	Case cRet == '1'
		ApMsgInfo( STR0065 ) //"Não foram encontrados dados para emissão da Pré-Fatura."
	Case cRet == '2'
		ApMsgInfo( STR0045 ) //"Emissão terminada."
	Case cRet == '3'
		Alert( STR0094 )  //"O contrato " / "está sendo processado por outra rotina, tente novamente em alguns instantes."
	Case cRet == '4'
		// Sem msg, enviado para thread ou mensagem já exibida.
EndCase

If cRet <> '1' .And. FindFunction("JPDLogUser")
	JPDLogUser("JA201end") // Log LGPD Relatório de emissão da Pré-Fatura
EndIf

FreeUsedCode()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TudoOk()
Função do botão Confirmar da tela de Emissão de Pré-fatura.

@author
@since 25/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TudoOk( lChkAdi, lChkDes, lChkTS, lChkTab, lChkDesF, lChkHon, lChkTabF, cExceto, cGetClie, cGetLoja, cGetCaso, cSocio, cMoeda, cContratos, cGetGrup, cEscrit, cTipoDes, cTipoTS, lChkPenden, cExcSoc, lChkFech, cTipoFech, lChkFxNc, cCbxSituac)
Local lRet        := .T.

If (Empty(cGetClie) .Or. Empty(cGetLoja)) .And. !Empty(cGetCaso) .And. SuperGetMV( 'MV_JCASO1',, '1' ) == "1"
	ApMsgStop(STR0063) //"Como a sequência dos códigos dos casos é por cliente, é necessário informar o cliente."
	lRet := .F.
EndIf

If lRet .And. lChkAdi .And. (lChkFxNc .Or. lChkTS  .Or. lChkDes .Or. lChkTab .Or. lChkDesF .Or. lChkHon .Or. lChkTabF)
	ApMsgStop(STR0060) //Para emitir pré-fatura de fatura adicional é necessário desmarcar os outros tipos
	lRet := .F.
EndIf

If lRet .And. lChkFxNc .And. (lChkAdi .Or. lChkTS  .Or. lChkDes .Or. lChkTab .Or. lChkDesF .Or. lChkHon .Or. lChkTabF)
	ApMsgStop(STR0142) //"Para emitir pré-fatura de time sheets de contratos fixos ou não cobráveis é necessário desmarcar os outros tipos"
	lRet := .F.
EndIf

If lRet .And. !Empty( cExceto ) .And. !Empty( cGetClie )
	ApMsgStop( STR0047 ) //"Para emissão de um cliente especifico não é permitido informar exceções"
	lRet := .F.
EndIf

If lRet .And. !Empty( cExcSoc ) .And. !Empty( cSocio )
	ApMsgStop( STR0118 ) //"Para emissão de um sócio especifico não é permitido informar exceções"
	lRet := .F.
EndIf

If lRet .And. !( lChkAdi .Or. lChkDes .Or. lChkTS .Or. lChkTab .Or. lChkDesF .Or. lChkHon .Or. lChkTabF .Or. lChkFxNc )
	ApMsgStop( STR0048 ) //"Deve haver pelo menos um filtro selecionado."
	lRet := .F.
EndIf

If lRet .And. lChkAdi .And. (Empty(DtoS(dDtIniAdi)) .Or. Empty(DtoS(dDtFinAdi)))
	ApMsgStop( STR0124 ) //"Data inicial e/ou final da Fatura Adicional não foi preenchida!"
	lRet := .F.
EndIf

If lRet .And. lChkFxNc .And. (Empty(DtoS(dDtIniFxNc)) .Or. Empty(DtoS(dDtFinFxNc)))
	ApMsgStop(STR0143) // "Data inicial e/ou final de time sheets de contratos fixos ou não cobráveis não foi preenchida!"
	lRet := .F.
EndIf

If lRet .And. (lChkDes .Or. lChkDesF) .And. (Empty(DtoS(dDtIniDes)) .Or. Empty(DtoS(dDtFinDes)))
	ApMsgStop( STR0125 ) //"Data inicial e/ou final de Despesas não foi preenchida!"
	lRet := .F.
EndIf

If lRet .And. (lChkTS .Or. lChkHon) .And. (Empty(DtoS(dDtIniHon)) .Or. Empty(DtoS(dDtFinHon)))
	ApMsgStop( STR0126 ) //"Data inicial e/ou final de Honorários não foi preenchida!"
	lRet := .F.
EndIf

If lRet .And. (lChkTab .Or. lChkTabF) .And. (Empty(DtoS(dDtIniTab)) .Or. Empty(DtoS(dDtFinTab)))
	ApMsgStop( STR0127 ) //"Data inicial e/ou final de Lançamento Tabelado não foi preenchida!"
	lRet := .F.
EndIf

If lRet .And. lChkFxNc .And. cCbxSituac != JurSitGet("1") .And. cCbxSituac != JurSitGet("2") .And. cCbxSituac != JurSitGet("C") .And. !(cCbxSituac $ "1|2|C")
	lRet := .F.
	ApMsgStop(STR0145) // "Situaçáo da pré-fatura inválida. Para emissão de pré-fatura de Time sheets de contratos fixos ou não cobráveis a situação selecionada pode ser somente: Conferência, Análise ou Em Revisão. Verifique!"
EndIf

If lRet
	If !lChkPenden
		If Empty(cExceto) .And. Empty(cGetClie) .And. Empty(cGetLoja) .And. Empty(cGetCaso) .And. Empty(cSocio) .And. ;
		   Empty(cMoeda) .And. Empty(cContratos) .And. Empty(cGetGrup) .And. Empty(cEscrit) .And. Empty(cTipoDes) .And. ;
		   Empty(cTipoTS) .And. Empty(cExcSoc) .And. !lChkFech
			lRet := .F.
			ApMsgStop(STR0091) //"Deve haver pelo menos um campo preenchido, Verifique!"
		EndIf
	ElseIf !IsBlind()
		lRet := ApMsgYesNo( STR0092 ) //"Confirma a emissão das pré-faturas de TUDO PENDENTE?"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LKRetSA1()
Funcao para validar o  botao do tipo de faturamento escolhido para faturamento

@Param oLookUp  obj da consulta
@Param oObj     obj da tela
@Param cCli     codigo do cliente
@Param cLoja    codigo da loja

@author
@since 25/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function LKRetSA1( oLookUp, oObj, cCli, CLoja )
Local oSXB     := oLookUp:GetCargo()
Local aReturns := oSXB:GetReturnFields()

cCli  := PadR(Eval(& ('{||' + aReturns[1] + '}')), Len(cCli))
cLoja := PadR(Eval(& ('{||' + aReturns[2] + '}')), Len(cLoja))

oObj:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} LmpDatas
Funcao para validar o  botao do tipo de faturamento escolhido para faturamento

@Param oDtIni  , obj data inicial
@Param oDtFin  , obj data final
@Param dDtIni  , data inicial
@Param dDtFin  , data final
@Param lTravar , botao clicado
@Param nFAFxNc , variável de controle para identificar o botao 1 - Faturamento Adicional ou 2 - TSs de Contratos Fixos/Não Cobráveis
@Param oChkAdi , oChkTS,oChkDes,oChkTab,oChkHon,oChkDesF,oChkTabF,oChkFxNc (objetos dos botoes)
@param lCpoFxNc, Indica se o campo NX0_FXNC existe

@author
@since 25/03/10
/*/
//-------------------------------------------------------------------
Static Function LmpDatas( oDtIni, oDtFin, dDtIni, dDtFin, lHon, lOut, nFAFxNc, oChkAdi, oChkTS, oChkDes, oChkTab, oChkHon, oChkDesF, oChkTabF, oChkFxNc, lCpoFxNc )
Local dBranco  := CToD( '  /  /  ' )
Default nFAFxNc := 0

If (!lHon .And. !lOut)
	dDtIni := CToD( '  /  /  ' )
	dDtFin := CToD( '  /  /  ' )
	oDtIni:Refresh()
	oDtFin:Refresh()
	oDtIni:Disable()
	oDtFin:Disable()
Else
	If (lHon .Or. lOut) .And. Empty(dDtIni)
		dDtIni := CToD( '01/01/1900' )
		dDtFin := dDataBase
		oDtIni:Refresh()
		oDtFin:Refresh()
		oDtIni:Enable()
		oDtFin:Enable()
	EndIf
EndIf

If nFAFxNc == 1 .Or. nFAFxNc == 2 // Se ( 1 - Faturamento Adicional) ou (2 - TSs de Contratos Fixos/Não cobráveis) desabilita os outros itens

	If lChkAdi .Or. lChkFxNc

		lChkTS    := .F.
		lChkDes   := .F.
		lChkTab   := .F.
		lChkHon   := .F.
		lChkTabF  := .F.
		lChkDesF  := .F.

		oDtIniHon:Disable()
		oDtFinHon:Disable()
		oDtIniDes:Disable()
		oDtFinDes:Disable()
		oDtIniTab:Disable()
		oDtFinTab:Disable()

		dDtFinDes  := dBranco
		dDtFinHon  := dBranco
		dDtFinTab  := dBranco

		dDtIniDes  := dBranco
		dDtIniHon  := dBranco
		dDtIniTab  := dBranco

		If nFAFxNc == 2 .And. lChkFxNc // Quando ativar a opção de TSs de contratos fixos ou não cobráveis desabilita as opções de fatura adicional
			lChkAdi  := .F.
			oDtInAdi:Disable()
			oDtFinAdi:Disable()
			dDtIniAdi := dBranco
			dDtFinAdi := dBranco
		ElseIf lCpoFxNc .And. nFAFxNc == 1 .And. lChkAdi // Quando ativar a opção de fatura adicional desabilita as opções de contratos fixos ou não cobráveis
			lChkFxNc  := .F.
			oDtIniFxNc:Disable()
			oDtFinFxNc:Disable()
			dDtIniFxNc := dBranco
			dDtFinFxNc := dBranco
		EndIf

	EndIf

Else  //Se for outros faturamento desmarca o fat adicional e TSs de contratos fixos ou não cobráveis

	If lChkTS .Or. lChkDes .Or. lChkTab .Or. lChkHon .Or. lChkDesF .Or. lChkTabF
		lChkAdi  := .F.
		lChkFxNc := .F.
		oDtInAdi:Disable()
		oDtFinAdi:Disable()
		If lCpoFxNc
			oDtIniFxNc:Disable()
			oDtFinFxNc:Disable()
		EndIf
		dDtFinAdi  := dBranco
		dDtIniAdi  := dBranco
		dDtIniFxNc := dBranco
		dDtFinFxNc := dBranco
	EndIf

EndIf

oChkTS:Refresh()
oChkDes:Refresh()
oChkTab:Refresh()
oChkAdi:Refresh()
oChkHon:Refresh()
oChkDesF:Refresh()
oChkTabF:Refresh()

oDtFinDes:Refresh()
oDtFinTab:Refresh()
oDtFinAdi:Refresh()
oDtFinHon:Refresh()

oDtIniDes:Refresh()
oDtIniTab:Refresh()
oDtInAdi:Refresh()
oDtIniHon:Refresh()

If lCpoFxNc
	oChkFxNc:Refresh()
	oDtIniFxNc:Refresh()
	oDtFinFxNc:Refresh()
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} Runproc()
Rotina de processamento de emissão de pré-fatura

@param lAutomato, Indica se a chamada foi feita via automação

@return cRet    , Retorno da emissão
                  0 - Problemas na emissão
                  1 - Não encontrou dados para emissão
                  2 - Emitida com exito
                  3 - Thread

@author
@since 25/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Runproc(lAutomato)
Local cRet       := "0" //0 - problemas na emissão; 1 - não encontrou dados para emissão; 2 - emitida com exito; 3 - Thread
Local aResult    := {.T., ""}
Local cTipo      := "1"
Local aArea      := GetArea()
Local cCPreFt    := "0"
Local aContr     := {}
Local lIsTop     := .T.
Local cCodPart   := IIf( !Empty(cSocio) .And. ExistCPO('RD0', cSocio, 9), AllTrim(JurGetDados('RD0', 9, xFilial('RD0') + cSocio, 'RD0_CODIGO')), '')
Local dDtEmit    := CToD('  /  /  ')
Local aRet       := {}
Local lRet       := .T.
Local oFilaExe   := JurFilaExe():New( "JURA201", "1" )
Local nRecno     := 0
Local lCpoFxNc   := NX0->(ColumnPos('NX0_FXNC')) > 0 // Proteção para campo de TSs de contratos fixos ou não cobráveis 

Default lAutomato := .F.

aRet := JURA203G( 'FT', Date(), 'FATEMI'  )

If aRet[2] == .T.
	dDtEmit := aRet[1]
Else
	lRet := aRet[2]
	cRet := "0"
EndIf

If lRet

	#IFDEF TOP
		lIsTop := .T.
	#ELSE
		lIsTop := .F.
	#ENDIF

	ProcRegua( 0 )
	IncProc()
	IncProc()
	IncProc()
	IncProc()
	IncProc()

	oParams := TJPREFATPARAM():New()
	oParams:SetCodUser(__CUSERID)

	oParams:SetFltrHH( lChkTS   ) // Honorários Por Hora
	oParams:SetFltrHO( lChkHon  ) // Honorários Outros Tipos
	oParams:SetDIniH( dDtIniHon ) // Referência Inicial de Honorários
	oParams:SetDFinH( dDtFinHon ) // Referência Final   de Honorários

	oParams:SetFltrDH( lChkDes  ) // Despesas de Faturamento Por hora
	oParams:SetFltrDO( lChkDesF ) // Despesas de Outros Tipos
	oParams:SetDIniD( dDtIniDes ) // Referência Inicial de Despesas
	oParams:SetDFinD( dDtFinDes ) // Referência Final   de Despesas

	oParams:SetFltrTH( lChkTab  ) // Serviços Tabelados de Faturamento Por hora
	oParams:SetFltrTO( lChkTabF ) // Serviços Tabelados de Outros Tipos
	oParams:SetDIniT( dDtIniTab ) // Referência Inicial de Serviços Tabelados
	oParams:SetDFinT( dDtFinTab ) // Referência Final   de Serviços Tabelados

	oParams:SetFltrFA( lChkAdi   ) // Fatura Adicional
	oParams:SetDInIFA( dDtIniAdi ) // Referência Inicial de Fatura Adicional
	oParams:SetDFinFA( dDtFinAdi ) // Referência Final   de Fatura Adicional

	oParams:SetFltrFxNC( lChkFxNc   ) // Time Sheets de Contratos Fixos ou Não Cobráveis
	oParams:SetDInIFxNC( dDtIniFxNc ) // Referência Inicial de Fatura Adicional
	oParams:SetDFinFxNC( dDtFinFxNc ) // Referência Final   de Fatura Adicional

	oParams:SetSocio( cCodPart  )
	oParams:SetMoeda( cMoeda   )
	oParams:SetContrato( cContratos )
	oParams:SetTDContr( lChkTdCont )
	oParams:SetGrpCli( cGetGrup )
	oParams:SetCliente( cGetClie )
	oParams:SetLoja( cGetLoja )
	oParams:SetCasos( cGetCaso )
	oParams:SetTDCasos( lChkTdCaso )
	oParams:SetExceto( cExceto )
	oParams:SetExcSoc( cExcSoc )
	oParams:SetSitSoc( Iif(cSituSoc == STR0114, '', Iif(cSituSoc == STR0115, '2', '1') ) )
	oParams:SetEScrit( cEscrit )
	oParams:SetTipoDP( cTipoDes )
	oParams:SetTipoHon( cTipoTS )
	oParams:SetChkPend( lChkPenden )
	oParams:SetTipRel( cTipoRF )
	oParams:SetChkApaga( lChkApagar )
	oParams:SetChkApaMP( lChkApaMP )
	oParams:SetChkCorr( lChkCorrigir )
	oParams:SetSituac( cCbxSituac )

	oParams:SetTpExec( cTipo )
	oParams:SetDEmi( dDtEmit )
	oParams:SetPreFat( cCPreFt )

	oParams:SetCodFatur( Criavar('NXA_COD', .F.))
	oParams:SetCodEscr( Criavar('NXA_CESCR', .F.))

	oParams:SetNameFunction("JA201AEmi")

	If MethIsMemberOf( oParams, "SetChkFech" ) // Proteção para os métodos criados na TJurPreFat para o release 12.1.30
		oParams:SetChkFech( lChkFech )
		oParams:SetTipoFech( cTipoFech )
	EndIf

	aContr := oParams:LockContratos()

	If Empty(aContr[2])
		cRet := "1" // "Não foram encontrados dados para emissão da Pré-Fatura."
	Else

		If aContr[1]

			oParams:UnLockContratos() // Libero novamente pois a JA201AEmi irá "lockar".
			// (Isto é necessário para saber se o lock já foi feito e ser liberado ao termino da emissão da 201A).

			oParams:SetIsThread(THREAD)

			// Grava o registro desta pré
			oFilaExe:AddParams(STR0037, cCbxResult) //#Resultado
			oFilaExe:AddParams(STR0040, lChkNaoImp) //#Não imprimir observação dos casos no relátorio
			oFilaExe:AddParams(STR0120, .F., .F.) //"Time Sheet zero"
			//É Códificado para garantir a integridade da função, pois o Serialize transforma o objeto em um xml e gera conflito.
			cParams := Encode64(oParams:JSerialize())
			oFilaExe:AddParams("oParams", cParams, .F.)

			If !lAutomato
				oFilaExe:StartReport(lAutomato) //Verifica e abre a Thread de relatório se não estiver aberta
			EndIf

			//Parâmetros apenas para registro
			oFilaExe:AddParams(STR0067+" - "+STR0010, lChkTS)    //#Honorários ##( Time-Sheet )
			oFilaExe:AddParams(STR0067+" - "+STR0071, lChkHon)   //#Honorários ##( Parcelas )
			oFilaExe:AddParams(STR0067+" - "+STR0012, dDtIniHon) //#Honorários ##Data Inicial
			oFilaExe:AddParams(STR0067+" - "+STR0014, dDtFinHon) //#Honorários ##Data Final

			oFilaExe:AddParams(STR0016+" - "+STR0010, lChkDes)   //#Despesas ##( Time-Sheet )
			oFilaExe:AddParams(STR0016+" - "+STR0071, lChkDesF)  //#Despesas ##( Parcelas )
			oFilaExe:AddParams(STR0016+" - "+STR0012, dDtIniDes) //#Despesas ##Data Inicial
			oFilaExe:AddParams(STR0016+" - "+STR0014, dDtFinDes) //#Despesas ##Data Final

			oFilaExe:AddParams(STR0017+" - "+STR0010, lChkTab)   //#Lanc. Tabelado ##( Time-Sheet )
			oFilaExe:AddParams(STR0017+" - "+STR0071, lChkTabF)  //#Lanc. Tabelado ##( Parcelas )
			oFilaExe:AddParams(STR0017+" - "+STR0012, dDtIniTab) //#Lanc. Tabelado ##Data Inicial
			oFilaExe:AddParams(STR0017+" - "+STR0014, dDtFinTab) //#Lanc. Tabelado ##Data Final

			oFilaExe:AddParams(STR0019, lChkAdi)                 //#Faturamento Adicional
			oFilaExe:AddParams(STR0019+" - "+STR0012, dDtIniAdi) //#Faturamento Adicional ##Data Inicial
			oFilaExe:AddParams(STR0019+" - "+STR0014, dDtFinAdi) //#Faturamento Adicional ##Data Final

			If lCpoFxNc
				oFilaExe:AddParams(STR0144, lChkFxNc)                   // "Time Sheets de Contrato Fixo/Não Cobrável"
				oFilaExe:AddParams(STR0144 +" - " + STR0012, dDtIniAdi) // "Time Sheets de Contrato Fixo/Não Cobrável" / "Data Inicial"
				oFilaExe:AddParams(STR0144 +" - " + STR0014, dDtFinAdi) // "Time Sheets de Contrato Fixo/Não Cobrável" / "Data Final"
			EndIf

			oFilaExe:AddParams(STR0022, cCodPart) //#Sócio
			oFilaExe:AddParams(STR0023, cMoeda)   //#Moeda
			oFilaExe:AddParams(STR0027, cContratos) //#Contrato
			oFilaExe:AddParams(STR0068+ " - "+STR0027, lChkTdCont) //#Todos ##Contrato
			oFilaExe:AddParams(STR0026, cGetGrup) //#Grupo de Clientes
			oFilaExe:AddParams(STR0024, cGetClie) //#Cliente
			oFilaExe:AddParams(STR0024+" - "+STR0121, cGetLoja) //#Cliente ##Loja
			oFilaExe:AddParams(STR0025, cGetCaso) //#Caso
			oFilaExe:AddParams(STR0068+ " - "+STR0025, lChkTdCaso) //#Todos ##Caso
			oFilaExe:AddParams(STR0028, cExceto) //#Exceto Clientes
			oFilaExe:AddParams(STR0111, cExcSoc) //# "Exceto Sócios"
			oFilaExe:AddParams(STR0110, Iif(cSituSoc == STR0114, '', Iif(cSituSoc == STR0115, '2', '1') )  ) //#"Situação dos Sócios" ## "Todos" ## "Ativos" ## "Inativos"
			oFilaExe:AddParams(STR0029, cEscrit) //#Escritório
			oFilaExe:AddParams(STR0030, cTipoDes) //#Tipo de Despesas
			oFilaExe:AddParams(STR0036, cTipoTS) //#Tipo de Honorarios
			oFilaExe:AddParams(STR0031, lChkPenden) //#Emitir tudo pendente
			oFilaExe:AddParams(STR0039, cTipoRF) //#Tipo de Relatório
			oFilaExe:AddParams(STR0041, lChkApagar) //#Apagar/Substituir pré-faturas existentes neste(s) caso(s)
			oFilaExe:AddParams(STR0112, lChkApaMP) //# "Apagar/Substituir minutas existentes neste(s) caso(s)"
			oFilaExe:AddParams(STR0113, lChkCorrigir) //# "Corrigir valor base do(s) contrato(s) Fixo(s)"
			oFilaExe:AddParams(STR0038, cCbxSituac) //#Situação da Pré Fatura
			Iif(lAutomato, oFilaExe:AddParams(STR0119, 10, .F.), ) //"Teste parametro numerico"
			oFilaExe:AddParams(STR0139, lChkFech) //#Flag do Tipo de Fechamento 
			oFilaExe:AddParams(STR0138, cTipoFech) //#Tipo de Fechamento 

			nRecno := oFilaExe:Insert(THREAD)
			If !THREAD .And. nRecno > 0
				aResult := JA201AEmi({oFilaExe:GetParams(), nRecno}, lAutomato)
				If !aResult[1]
					If Empty(aResult[2])
						cRet := "1"  //0 - problemas na emissão; 1 - não encontrou dados para emissão; 2 - emitida com exito; 3 - Contrato já emitindo
					Else
						JurErrLog(aResult[2], "Problemas na emissão")
						cRet := "4"  // Mensagem já exibida
					EndIf

				Else
					cRet := "2"  //0 - problemas na emissão; 1 - não encontrou dados para emissão; 2 - emitida com exito; 3 - Contrato já emitindo
					While __lSX8
						ConfirmSX8()
					EndDo
				EndIf
			Else
				Iif (nRecno > 0, cRet := "4",) //0 - problemas na emissão; 1 - não encontrou dados para emissão; 2 - emitida com exito; 3 - Contrato já emitindo
			EndIf
		Else
			cRet := "3" // "Contrato selecionado já esta sendo emitido! Verifique."
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201F3
Rotina genérica para pesquisa de Cliente/Loja e Caso

@Param   cTipo      Indica qual o tipo de pesquisa: 1 = Cliente e Loja / 2 = Caso

@author Jacques Alves Xavier
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201F3(cTipo)
Local cRet := "@#@#"

If cTipo == '1'
	cRet := IIF(Type("cGetGrup") == "U" .Or. Empty(cGetGrup), "@#@#", "@#SA1->A1_GRPVEN == '" + cGetGrup + "'@#")
Else
	If Type("cGetClie") != "U" .And. !Empty(cGetClie) .And. !Empty(cGetLoja)
		cRet := "@#NVE->NVE_CCLIEN == '" + cGetClie + "' .And. NVE->NVE_LCLIEN == '" + cGetLoja + "' @#"
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201VLC()
Função utilizada validação do preenchimento dos campos contrato, caso,
cliente e loja na tela de emissão de pré-fatura.

@author Luciano Pereira dos Santos
@since 16/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201VLC()
Local lRet := .T.

If (!Empty( cGetClie ) .Or. !Empty( cGetLoja ) .Or. !Empty( cGetCaso ))
	cContratos := Space( 250 )
	lChkTdCont := .F.
	oContratos:Disable()
	oChkTdCont:Disable()
Else
	oContratos:Enable()
	oChkTdCont:Enable()
	oContratos:Refresh()
	oChkTdCont:Refresh()
EndIf

If Empty( cGetClie )
	cGetLoja := Criavar( 'A1_LOJA', .F. )
	oGetLoja:Refresh()
EndIf

If Empty( cContratos )
	lChkTdCont := .F.
	oChkTdCont:Disable()
EndIf

If Empty( cGetCaso )
	lChkTdCaso := .F.
	oChkTdCaso:Disable()
EndIf

If (!Empty(cContratos))
	cGetCaso   := Space( 240 )
	cGetClie   := Criavar( 'A1_COD', .F. )
	cGetLoja   := Criavar( 'A1_LOJA', .F. )
	oGetCaso:Disable()
	oGetClie:Disable()
	oGetLoja:Disable()
Else
	oGetCaso:Enable()
	oGetClie:Enable()
	oGetLoja:Enable()
	oGetCaso:Refresh()
	oGetClie:Refresh()
	oGetLoja:Refresh()
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201TsZr()
Função utilizada para verificar se existem Time Sheets com participante sem valor de honorário
e emitir relatório desse participantes.

@author Luciano Pereira dos Santos
@since 28/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201TsZr()
Local aRet       := {.T., ''}
Local lRet       := .T.
Local cTipo      := "1"
Local aArea      := GetArea()
Local cQryRes    := GetNextAlias()
Local cQuery     := ""
Local lIsTop     := .T.
Local cCodPart   := IIf(!Empty(cSocio) .And. ExistCPO('RD0', cSocio, 9), AllTrim(JurGetDados('RD0', 9, xFilial('RD0') + cSocio, 'RD0_CODIGO')), '')
Local aDtEmit    := JURA203G( 'FT', Date(), 'FATEMI' )
Local dDtEmit    := CToD( '  /  /  ' )
Local cCodPre    := ""
Local cNVVCOD    := ""
Local cNW2COD    := ""
Local cNT0COD    := ""
Local cNT0CRELAT := ""
Local cNVECCLIEN := ""
Local cNVELCLIEN := ""
Local cNVENUMCAS := ""
Local cTEMTS     := ""
Local cTEMLT     := ""
Local cTEMDP     := ""
Local cTEMFX     := ""
Local cTEMFA     := ""
Local nCount     := 0
Local lFirstApag := .T.
Local cCodFixo   := ""
Local oFilaExe   := JurFilaExe():New( "JURA201", "2" ) // 2= Impressão

If (lRet := aDtEmit[2])
	dDtEmit := aDtEmit[1]
EndIf

If lRet
	#IFDEF TOP
		lIsTop := .T.
	#ELSE
		lIsTop := .F.
	#ENDIF

	ProcRegua( 0 )
	IncProc()

	oParams := TJPREFATPARAM():New()
	oParams:SetCodUser(__CUSERID)

	oParams:SetFltrHH( lChkTS  ) // Honorários Por Hora
	oParams:SetFltrHO(.F.)       // Honorários Outros Tipos
	oParams:SetDIniH( dDtIniHon ) // Referência Inicial de Honorários
	oParams:SetDFinH( dDtFinHon ) // Referêncis Final   de Honorários

	oParams:SetFltrDH(.F.) // Despesas de Faturamento Por hora
	oParams:SetFltrDO(.F.) // Despesas de Outros Tipos
	oParams:SetDIniD( dDtIniDes ) // Referência Inicial de Despesas
	oParams:SetDFinD( dDtFinDes ) // Referêncis Final   de Despesas

	oParams:SetFltrTH(.F.) // Serviços Tabelados de Faturamento Por hora
	oParams:SetFltrTO(.F.) // Serviços Tabelados de Outros Tipos
	oParams:SetDIniT( dDtIniTab ) // Referência Inicial de Serviços Tabelados
	oParams:SetDFinT( dDtFinTab ) // Referêncis Final   de Serviços Tabelados

	oParams:SetFltrFA(.F.)
	oParams:SetDInIFA( dDtIniAdi )
	oParams:SetDFinFA( dDtFinAdi )

	oParams:SetSocio( cCodPart)
	oParams:SetMoeda( cMoeda)
	oParams:SetContrato( cContratos )
	oParams:SetTDContr( lChkTdCont )
	oParams:SetGrpCli( cGetGrup )
	oParams:SetCliente( cGetClie )
	oParams:SetLoja( cGetLoja )
	oParams:SetCasos( cGetCaso )
	oParams:SetTDCasos( lChkTdCaso )
	oParams:SetExceto( cExceto )
	oParams:SetExcSoc( cExcSoc )
	oParams:SetSitSoc( Iif(cSituSoc == STR0114, '', Iif(cSituSoc == STR0115, '2', '1') ) )
	oParams:SetEScrit( cEscrit )
	oParams:SetTipoDP( cTipoDes )
	oParams:SetTipoHon( cTipoTS )
	oParams:SetChkPend( lChkPenden )
	oParams:SetTipRel( cTipoRF )
	oParams:SetChkApaga( lChkApagar )
	oParams:SetChkApaMP( lChkApaMP )
	oParams:SetChkCorr(lChkCorrigir)
	oParams:SetSituac( "1" ) //conferencia

	oParams:SetTpExec( cTipo )
	oParams:SetDEmi( dDtEmit )

	oParams:SetTsZero(.T.)
	oParams:SetNameFunction("JA201AEmi")

	If MethIsMemberOf( oParams, "SetChkFech" ) // Proteção para os métodos criados na TJurPreFat para o release 12.1.30
		oParams:SetChkFech( lChkFech )
		oParams:SetTipoFech( cTipoFech )
	EndIf

	aRet := oParams:LockContratos()

	If aRet[1]
		cQuery := " SELECT A.NVV_COD,"
		cQuery +=        " A.NW2_COD,"
		cQuery +=        " A.NT0_COD,"
		cQuery +=        " A.NT0_CRELAT,"
		cQuery +=        " A.NVE_CCLIEN,"
		cQuery +=        " A.NVE_LCLIEN,"
		cQuery +=        " A.NVE_NUMCAS,"
		cQuery +=        " MIN(A.TEMTS) TEMTS,"
		cQuery +=        " MIN(A.TEMLT) TEMLT,"
		cQuery +=        " MIN(A.TEMDP) TEMDP,"
		cQuery +=        " MIN(A.TEMFX) TEMFX,"
		cQuery +=        " MIN(A.TEMFA) TEMFA,"
		cQuery +=        " A.SEPARA "
		cQuery +=  " FROM ( " + oParams:GetQueryPre() + " ) A"
		cQuery +=  " GROUP BY A.NVV_COD,"
		cQuery +=           " A.NW2_COD,"
		cQuery +=           " A.NT0_COD,"
		cQuery +=           " A.NT0_CRELAT,"
		cQuery +=           " A.NVE_CCLIEN,"
		cQuery +=           " A.NVE_LCLIEN,"
		cQuery +=           " A.NVE_NUMCAS,"
		cQuery +=           " A.SEPARA "
		cQuery += " ORDER BY A.NVV_COD,"
		cQuery +=           " A.NW2_COD,"
		cQuery +=           " A.SEPARA DESC,"
		cQuery +=           " A.NT0_COD,"
		cQuery +=           " A.NT0_CRELAT,"
		cQuery +=           " A.NVE_CCLIEN,"
		cQuery +=           " A.NVE_LCLIEN,"
		cQuery +=           " A.NVE_NUMCAS"

		cQuery := ChangeQuery(cQuery, .F.)

		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

		If !(cQryRes)->(EOF()) .And. Alltrim((cQryRes)->TEMTS) == "1" .And. !ApMsgYesNo( STR0072 ) //"Existem participantes sem valor na tabela de honorário, deseja continuar a emitir a(s) pré-fatura(s)?"
			IncProc(STR0104) //"Gerando o relatório..."

			While aRet[1] .And. !(cQryRes)->(EOF())

				oParams:PtInternal(STR0027 + " " + (cQryRes)->NT0_COD)

				lAguarda := .T.
				nVezes   := 0

				While lAguarda .And. nVezes <= 2000

					lAguarda := J201AWaitDel("JA201AEmi: Erasing")
					If !lAguarda

						oParams:PtInternal("Erasing")
						aRet := JA201JApag( oParams, ;
							(cQryRes)->NVV_COD, ;
							(cQryRes)->NW2_COD, ;
							(cQryRes)->NT0_COD, ;
							(cQryRes)->NVE_CCLIEN, ;
							(cQryRes)->NVE_LCLIEN, ;
							(cQryRes)->NVE_NUMCAS,  ;
							Alltrim((cQryRes)->TEMTS),; //Tratamento para banco POSTGRES
							Alltrim((cQryRes)->TEMLT),;
							Alltrim((cQryRes)->TEMDP),;
							Alltrim((cQryRes)->TEMFX),;
							Alltrim((cQryRes)->TEMFA),;
							'2',;
							cCodPre,;
							STR0034 ) // #Cancelamento por emissão de pré-fatura
							oParams:PtInternal("Working")

					Else
						If nVezes == 0 .And. lFirstApag
							oParams:EventInsert(1, STR0100) // "Aguardando outras emissões de pré-faturas terminarem de substituir prés antigas."
							lFirstApag := .F.
						EndIf
						oParams:PtInternal("Waiting erase (" + Str(nVezes) + ")")
						Sleep(10)
						nVezes++
					EndIf
				EndDo

				If nVezes == 2000
					aRet := {.F., "JA201AEmi: JA201JApag - " + STR0101 + "."}
					oParams:EventInsert(1, STR0101, 2) // "Tempo de espera por outras emissões de pré-faturas foi esgotado! Favor Gerar novamente"
				EndIf

				If aRet[1]

					BEGIN TRANSACTION // MUDANÇA NO CONTROLE DE TRANSAÇÕES
						If nCount == 0
							cCodPre := JurGetNum("NX0", "NX0_COD") //Pega o primeiro numero de Pre Fatura
						EndIf

						// Se não forem:
						//		Casos do mesmo Contrato
						//		ou
						//		Contratos da mesma Junção
						//		ou
						//		Casos da mesma Fatura Adicional
						If nCount > 0
							If aRet[1] .And. ;
									!(;
									(Empty(cNVVCOD) .And. Empty(cNW2COD)  .And. ;
									(cNVVCOD    == (cQryRes)->NVV_COD)    .And. ;
									(cNW2COD    == (cQryRes)->NW2_COD)    .And. ;
									(cNT0COD    == (cQryRes)->NT0_COD)    .And. ;
									(cNT0CRELAT == (cQryRes)->NT0_CRELAT) .And. ;
									(cNVECCLIEN == (cQryRes)->NVE_CCLIEN) .And. ;
									(cNVELCLIEN == (cQryRes)->NVE_LCLIEN) ;
									) ;
									.Or.;
									(Empty(cNVVCOD) .And. !Empty(cNW2COD) .And.;
									(cNW2COD == (cQryRes)->NW2_COD) ;
									) ;
									.Or.;
									(;
									(cNT0COD    == (cQryRes)->NT0_COD)    .And. ;
									(Empty(cNVVCOD) .Or.;
									(cNVVCOD = (cQryRes)->NVV_COD) ;
									);
									);
									) .Or.;
									((cQryRes)->SEPARA == '1')

								If !Empty(cNW2COD)
									cNT0COD := ""
								EndIf

								If aRet[1]
									oParams:PtInternal(STR0044) //"Emitindo pré-faturas ..."
									aRet := JA201CEmi(oParams, cCodPre, cNVVCOD, cNW2COD, cNT0COD)
								EndIf

								If !aRet[1]
									DisarmTransaction()
									While __lSX8  //Libera os registros usados na transação
										RollBackSX8()
									EndDo
								Else
									While __lSX8
										ConfirmSX8()
									EndDo

									If NX0->(DbSeek( xFilial("NX0") + cCodPre ) )
										oFilaExe:AddParams(STR0082, cCodPre) //#"Impressão de Pré-Fatura"
										oFilaExe:AddParams(STR0037, '2') //#"Resultado"  (1="Impressora"; 2="Tela"; 3="Nenhum")
										oFilaExe:AddParams(STR0040, .F.) //#"Não imprimir observação dos casos no relátorio"
										oFilaExe:AddParams(STR0120, .T.) //#"Time Sheet zero"
										oFilaExe:Insert()
									EndIf

								EndIf

								oParams:PtInternal() // "Working"
								lEmitiu := .T.

								cCodPre := JurGetNum("NX0", "NX0_COD")

							EndIf
						EndIf

						If aRet[1]
							cNVVCOD    := (cQryRes)->NVV_COD
							cNW2COD    := (cQryRes)->NW2_COD
							cNT0COD    := (cQryRes)->NT0_COD
							cNT0CRELAT := (cQryRes)->NT0_CRELAT
							cNVECCLIEN := (cQryRes)->NVE_CCLIEN
							cNVELCLIEN := (cQryRes)->NVE_LCLIEN
							cNVENUMCAS := (cQryRes)->NVE_NUMCAS
							cTEMTS     := Alltrim((cQryRes)->TEMTS) //Tratamento para banco POSTGRES
							cTEMLT     := Alltrim((cQryRes)->TEMLT)
							cTEMDP     := Alltrim((cQryRes)->TEMDP)
							cTEMFX     := Alltrim((cQryRes)->TEMFX)
							cTEMFA     := Alltrim((cQryRes)->TEMFA)

							//Vincula lanctos do caso atual
							oParams:PtInternal(STR0103) //"Vinculando lançamentos na pré-fatura"
							aRet       := JA201BVinc(oParams, cCodFixo, cCodPre, cNVVCOD, cNW2COD, cNT0COD, cNVECCLIEN, cNVELCLIEN, cNVENUMCAS, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA)
							oParams:PtInternal() // "Working"
							lEmitiu    := .F.
						EndIf

						(cQryRes)->(DbSkip())
						nCount := nCount + 1

						If aRet[1] .And. (cQryRes)->(Eof()) .And. !lEmitiu
							// verifica se há categorias não cadastradas na Tab hon.
							oParams:PtInternal(STR0044) //"Emitindo pré-faturas ..."
							aRet := JA201CEmi(oParams, cCodPre, cNVVCOD, cNW2COD, cNT0COD)

							If !aRet[1]
								DisarmTransaction()
								While __lSX8  //Libera os registros usados na transação
									RollBackSX8()
								EndDo
							Else
								While __lSX8
									ConfirmSX8()
								EndDo
								aRet := {.F., ''} //Emite o relatorio no lugar da pré-fatura

								If NX0->(DbSeek( xFilial("NX0") + cCodPre ) )
									oFilaExe:AddParams(STR0082, cCodPre) //#"Impressão de Pré-Fatura"
									oFilaExe:AddParams(STR0037, '2') //#"Resultado"  (1="Impressora"; 2="Tela"; 3="Nenhum")
									oFilaExe:AddParams(STR0040, .F.) //#"Não imprimir observação dos casos no relátorio"
									oFilaExe:AddParams(STR0120, .T.) //#"Time Sheet zero"
									oFilaExe:Insert()
								EndIf

								oParams:PtInternal() // "Working"
								lEmitiu := .T.

							EndIf
						Else
							nCount := -1 // tratamento para não exibir mensagem de "sem dados para emissão" erronemente
						EndIf

					END TRANSACTION
				EndIf

			EndDo
			(cQryRes)->(DbCloseArea())
		Else
			aRet := {.T., ''} //Emite direto a pré-fatura
		EndIf

		oParams:UnLockContratos()

	ElseIf Empty(aRet[2])
		aRet := {.T., ''} //Não existem inconsistências na tabela de honorários e emite direto a pré-fatura
	Else
		aRet := {.F., STR0102} //"Pelo menos um contrato do filtro selecionado já esta sendo emitido por outro usuário."
	EndIf

	RestArea(aArea)

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201GeraRpt
Emissão de relatórios por SmartClient secundário.

@author Felipe Bonvicini Conti
@since 25/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Main Function J201GeraRpt(cParams)
Local lRet        := .F.
Local lExit       := .F.
Local nVezes      := 0
Local cUser       := ""
Local aParam      := {}
Local nNext       := 1
Local cEmpAux     := ""
Local cFilAux     := ""
Local cMessage    := ""
Local cPtInternal := "J201GeraRpt: "
Local cCrysPath   := ''
Local oFilaExe    := Nil
Local aRetFila    := {}
Local cPRE        := ""
Local cTIPO       := ""
Local lNAOIMP     := .F.
Local lTSZERO     := .F.
Local lPDUserAc   := .T.

PtInternal(1, cPtInternal + "Start " )

cParams := StrTran(cParams, Chr(135), " ")
aParam  := StrTokArr(cParams, "||")

If (lRet := Len(aParam) >= 4)
	cUser      := aParam[1]
	cEmpAux    := aParam[2]
	cFilAux    := aParam[3]
	cCrysPath  := aParam[4] // Ver rotina JurCrysPath()
	If Len(aParam) >= 6
		lPDUserAc := aParam[6] == ".T."
	EndIf
EndIf

If lRet
	RpcSetType(3)
	RpcSetEnv(cEmpAux, cFilAux, , ,"PFS")

	__cUserId   := cUser

	cPtInternal := "J201GeraRpt: " + JurUsrName(cUser) + " "

	oFilaExe := JurFilaExe():New("JURA201", "2") // 2 = Impressão
	If oFilaExe:OpenReport()

		While !KillApp()

			PtInternal(1, cPtInternal + " GetNext Table OH1" )
			aRetFila := oFilaExe:GetNext()
			If( Len(aRetFila) > 1 .And. aRetFila[2] > 0)
				cPRE       := aRetFila[1][1][2] // Lista de Pré-Fatura
				cTIPO      := aRetFila[1][2][2] // 1="Impressora"; 2="Tela"; 3="Nenhum"
				lNAOIMP    := aRetFila[1][3][2] // Não imprime a observação do caso no relatório
				lTSZERO    := aRetFila[1][4][2] // Emite relatório de timeSheets com categoria sem valor
				nNext      := aRetFila[2]
			Else
				nNext := 0
			EndIf

			IIF(J201ReadLOG(), JurLogMsg(cPtInternal+" On KillApp() / TIME() == " + TIME() + " / cNext == " + AllTrim(Str(nNext)), , , {}, 2), )

			If nNext > 0
				OH1->(dbGoto(nNext))

				IIF(J201ReadLOG(), JurLogMsg(cPtInternal + " On KillApp() / cPRE == " + cPRE), )

				PtInternal(1, cPtInternal + " Print pre invoice " + cPRE )
				If J201Imprimi(cPRE, cTIPO, cUser, lNAOIMP, cCrysPath, lTSZERO, lPDUserAc )
					// Imprimiu
				Else
					cMessage := STR0081 // "O relatório não foi impresso pois a pré-fatura foi substituida, Verifique!"
					EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "054", FW_EV_LEVEL_ERROR, ""/*cCargo*/, STR0082, cMessage, .F. ) // "Impressão de Pré-Fatura"
				EndIf

				oFilaExe:SetConcl(nNext)
				Sleep(500)

			Else
				PtInternal(1, cPtInternal + " Idle ")
				lExit := !oFilaExe:IsOpenWindow() //Fim da emissão
				Iif(lExit, , Sleep(1000))
			EndIf

			If lExit
				PtInternal(1, cPtInternal + " Out ")
				Exit
			EndIf

			nVezes += 1
			IIF(J201ReadLOG(), JurLogMsg(cPtInternal + " On KillApp() / nVezes == " + Str(nVezes)), )
		EndDo

		OH1->(dbCloseArea())

		PtInternal(1, cPtInternal + " Finish " )

		oFilaExe:CloseReport()
	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J201Imprimi
Emissão de relatórios por SmartClient secundário.

@author Felipe Bonvicini Conti
@since 25/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201Imprimi(cPre, cTipoImp, cUser, lChkNaoImp, cCrysPath, lTsZero, lPDUserAc)
Local cArquivo  := ""
Local cParams   := ""
Local cOptions  := ""
Local lRet      := .T.
Local aPres     := {}
Local nI        := 0
Local lExpFSrv  := .T.  //Se for server exporta o arquivo
Local cDestPath := ''
Local cMsgLog   := ''
Local cMsgRet   := ''
Local cArqRel   := ''   // Relatorio de pre-fatura que sera usado na impressao
Local cTipRel   := ''   // Tipo de relatorio que sera usado na impressao
Local cMoeNac   := SuperGetMv('MV_JMOENAC',, '01' )
Local cVincTS   := IF(SuperGetMv('MV_JVINCTS',, .T.), '1', '2')
Local cJurTS8   := IF(SuperGetMv('MV_JURTS8',, .T.), '1', '2')
Local cModRel   := SuperGetMV('MV_JMODREL',, '1')  // TIPO DE RELATORIO 1 CRYSTAL, 2 FWMSPRINT
Local lJURR201A := ExistBlock('JURR201A')

aPres := STRToArray(cPre, ',')

For nI := 1 To Len(aPres)

	If  !lTsZero
		cArquivo  := "prefatura_" + aPres[nI]
		cDestPath := JurImgPre(aPres[nI], .T., .F., @cMsgLog)

		If !J201IsDelPre(aPres[nI]) .And. !JurIN( JurGetDados("NX0", 1, xFilial("NX0") + aPres[nI], "NX0_SITUAC"), {"8", " "} ) // Diferente de substituida ou em branco

			PtInternal(1, "J201GeraRpt: Print pre invoice " + aPres[nI] )

			/*
			CALLCRYS (rpt , params, options), onde:
			rpt = Nome do relatório, sem o caminho.
			params = Parâmetros do relatório, separados por vírgula ou ponto e vírgula. Caso seja marcado este parâmetro, serão desconsiderados os parâmetros marcados no SX1.
			options = Opções para não se mostrar a tela de configuração de impressão , no formato x;y;z;w ,onde:
			x = Impressão em Vídeo(1), Impressora(2), Impressora(3), Excel (4), Excel Tabular(5), PDF(6) e Texto(7)?.
			y = Atualiza Dados  ou não(1)
			z = Número de Cópias, para exportação este valor sempre será 1.
			w = Título do Report, para exportação este será o nome do arquivo sem extensão.
			*/

			//1 - "Impressora", 2 - "Tela", 3 - Word, 4 - "Nenhum"
			Do Case
			Case cTipoImp == '1'  //Impressora
				cOptions := '2'

			Case cTipoImp == '2'  //Tela
				cOptions := '1'

			Case cTipoImp == '3'  //Word
				cOptions := '8'

			Otherwise            //Tela
				cOptions := '1'
			EndCase

			cOptions := cOptions + ';0;1;'

			cParams  := aPres[nI] + ';' + IIf( lChkNaoImp, 'N', 'S' ) + ';' + cUser + ';' + cMoeNac +;
						';' + cVincTS +';' + cJurTS8 +';'

			cArqRel := J201TipRel(aPres[nI], @cTipRel) // Busca o tipo de relatorio de pre-fatura

			// Grava o campo NX0_RELPRE com o tipo de relatorio customizado
			If !Empty(cTipRel)
				NX0->(DbSetOrder(1))

				If NX0->(DbSeek(xFilial('NX0') + aPres[nI]))   // posiciona pre-fatura
					RecLock('NX0', .F.)
					NX0->NX0_RELPRE := cTipRel
					NX0->(MsUnlock())
				EndIf
			EndIf

			If cTipoImp == '3' // Gera relatório de faturamento em Word"
				JCallCrys( cArqRel, cParams, cOptions + cArquivo, .T., .F., lExpFSrv) //"Relatorio de Faturamento"
				cMsgRet := ''
				lRet := JurMvRelat(cArquivo + ".doc", cCrysPath, cDestPath, '3', @cMsgRet) //Copia
				If !lRet
					cMsgLog += CRLF + "J201Imprimi -> "+ cMsgRet + CRLF
				EndIf
			EndIf

			JCallCrys( cArqRel, cParams, '6;0;1;' + cArquivo, .T., .F., lExpFSrv) //Sempre gera em PDF
			cMsgRet := ''

			Do Case
			Case cTipoImp == '1'  //Imprime
				lRet := JurMvRelat(cArquivo + ".pdf", cCrysPath, cDestPath, '1', @cMsgRet) //Imprime
			Case cTipoImp == '2'  //Tela
				lRet := JurMvRelat(cArquivo + ".pdf", cCrysPath, cDestPath, '2', @cMsgRet) //Tela
			Case cTipoImp $ '3|4'  //Nenhum
				lRet := JurMvRelat(cArquivo + ".pdf", cCrysPath, cDestPath, '3', @cMsgRet) //Copia
			EndCase

			If !lRet
				cMsgLog += CRLF + "J201Imprimi -> " + cMsgRet
			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		If cModRel == '2' .And. FindFunction('JURR201A') // FWMSPRINT
			// Relatorio FWMSPrinter
			If lJURR201A  // Chamada de função de usuário
				ExecBlock('JURR201A', .F., .F., {aPres[nI], lPDUserAc} )
			Else
				JURR201A(aPres[nI], lPDUserAc)
			EndIf
		Else
			JCallCrys( 'JU201A', aPres[nI], '1;0;1;' + "RelCatVal_(USR_" + __CUSERID + ")", .T., .F., .F. ) //"Relatorio de Categoria sem valor"
		EndIf
	EndIf

Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201NewLOG()
Função para criar o arquivo de log da thread de emissão de pré-fatura

@Return lRet

@author
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201NewLOG()
Local lRet    := .F.
Local nHdlLog := FCREATE("\" + CurDir() + "J201LOG" + __cUserId + ".txt")

lRet := nHdlLog <> -1
If lRet
	FWrite(nHdlLog, LtoC(LOG))
	FClose(nHdlLog)
Else
	JurLogMsg("J201: Erro ao criar arquivo \" + CurDir() + "J201LOG" + __cUserId + ".txt - FError " + Str(Ferror()))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201SaveLOG()
Função para salvar o arquivo de log da thread de emissão de pré-fatura

@Return lRet

@author
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201SaveLOG(lLog)
Local lRet    := .T.
Local nHdlLog := fopen("\" + CurDir() + "J201LOG" + __cUserId + ".txt", FO_READWRITE + FO_SHARED )

lRet := nHdlLog <> -1
If lRet
	FWrite(nHdlLog, LtoC(lLog))
	fclose(nHdlLog)
Else
	JurLogMsg("J201: Erro de abertura (Salvar) \" + CurDir() + "J201LOG" + __cUserId + ".txt - FError " + str(ferror(),4))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201ReadLOG()
Função para ler o arquivo de log da thread de emissão de pré-fatura

@Return lRet

@author
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201ReadLOG()
Local cRet     := ".F."
Local cArq     := "\" + CurDir() + "J201LOG" + __cUserId + ".txt"
Local nHdlLog

If File(cArq)
	nHdlLog := fopen("\" + CurDir() + "J201LOG" + __cUserId + ".txt", FO_READWRITE + FO_SHARED )

	If nHdlLog <> -1
		FRead(nHdlLog, cRet, 3)
		fclose(nHdlLog)
	Else
		JurLogMsg("J201: Erro de abertura (Ler)\" + CurDir() + "J201LOG" + __cUserId + ".txt - FError " + str(ferror(), 4))
	EndIf
EndIf

Return cRet == ".T."

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DelLOG()
Função para apagar o arquivo de log da thread de emissão de pré-fatura

@Return lRet

@author
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201DelLOG()
Local lRet := .F.
Local cArq := "\" + CurDir() + "J201LOG" + __cUserId + ".txt"
Local lLog := J201ReadLOG()
Local nI

For nI := 1 To 10000
	If File(cArq)

		If FCLOSE(FOpen(cArq, 264))
			If FErase(cArq) == -1
				JurLogMsg("J201: Falha na deleção do Arquivo. \" + CurDir() + "J201LOG" + __cUserId + ".txt")
			Else
				IIF(lLog, JurLogMsg("J201: Arquivo deletado com sucesso. \" + CurDir() + "J201LOG" + __cUserId + ".txt"), )
				lRet := .T.
				Exit
			EndIf
		EndIf

	Else
		Exit
	EndIf
	Sleep(10000)
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201IsDelPre()
Função para verificar se pré-fatura esta deletada

@Return lRet .T.

@author
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201IsDelPre(cPre)
Local lRet      := .F.
Local cRecnoNX0 := NX0->(Recno())

	NX0->(dbSetOrder(1))
	lRet := NX0->(dbSeek(xFilial("NX0") + cPre)) .And. NX0->(Deleted())
	NX0->(dbGoTo(cRecnoNX0))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201F8
Função para habilitar/desabilitar a execução do TSZERO

@param  lTSZERO  , Variável de controle para habilitar/desabilitar a execução do TSZERO
@param  lAutomato, Variável que informa se a execução é via automação

@Return lRet .T.

@author Jonatas Martins / Jorge Martins
@since  02/08/2012
/*/
//-------------------------------------------------------------------
Function J201F8(lTSZERO, lAutomato)
Local lRet := .T.

Default lTSZERO   := .T.
Default lAutomato := .F.

	If !lAutomato
		If MsgYesNo(I18N(STR0140, {Iif(lTSZR, STR0099, STR0098)}) ) //#"Deseja #1 a análise de categorias não cadastradas na tabela de honorários?" ## "desabilitar" ### "habilitar"
			lTSZR := !lTSZR
		EndIf
	Else
		lTSZR := lTSZERO
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201F9()
Função para habilitar/desabilitar a emissão de pré-fatura em Thread

@Return lRet .T.

@author Luciano Pereira dos Santos
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201F9(lTHREAD, lAutomato)
Local lRet        := .T.

Default lTHREAD   := .T.
Default lAutomato := .F.

If !lAutomato
	If MsgYesNo(I18N(STR0097, {Iif(THREAD, STR0099, STR0098)}) ) //#"Deseja #1 a emissão de pré-fatura em segundo plano?" ## "desabilitar" ### "habilitar"
		THREAD := !THREAD
	EndIf
Else
	THREAD := lTHREAD
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201GetPFat()
Função para retornar o caminho da pasta dos relatórios da pré-fatura,
e criar a estrutura caso ela não exista.

@Param  cPreft      Código da pré-fatura
@Param  cMsgLog     Log da rotina, passada por referência

@author Felipe Bonvicini Conti
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201GetPFat(cPreft, cMsgLog)
Local aArea      := GetArea()
Local cPastaDest := JurFixPath((SuperGetMV("MV_JPASPRE",, "")), 2, 1)
Local cPastaGrp  := ""
Local cPastPF    := Alltrim(SuperGetMV("MV_JPASGRP",, "")) //NX0_CCLIEN + NX0_CLOJA"
Local cPathImg   := ""
Local aCampos    := StrTokArr(cPastPF, "+")
Local ni         := 0
Local aStrcNX0   := {}
Local cMsgRet    := ''
Local cCpoValor  := ''

Default cMsgLog  := ''

If !Empty(cPastaDest)
	cPathImg := JurImgPre(cPreft, .F., .F., @cMsgRet)
	If !Empty(cMsgRet)
		cMsgLog += CRLF + "J201GetPFat-> " + cMsgRet
	EndIf

	If !ExistDir(cPathImg + cPastaDest) // Se não existir o diretorio do MV_JPASPRE, cria o diretório antes de adicionar a estrutura do MV_JPASGRP
		If (MakeDir(cPathImg + cPastaDest) != 0)
			cMsgLog += CRLF + "J201GetPFat.: " + I18N(STR0105, {cPathImg + cPastaDest} ) //# "Não foi possível criar o diretório '#1'."
		EndIf
	EndIf

	If !Empty(cPastPF) .And. !Empty(cPreFt)
		NX0->( DbSetOrder(1) )
		If (NX0->( DbSeek( xFilial("NX0") + cPreFt ) ))
			nMax     := Len(aCampos)
			aStrcNX0 := NX0->(DbStruct())
			For nI := 1 To nMax
				If aScan(aStrcNX0, {|x| x[1] == aCampos[nI]}) > 0
					cCpoValor := NX0->(FieldGet(FieldPos(aCampos[nI])))
					cPastaGrp := cPastaGrp + IIf(Empty(cCpoValor),'', cCpoValor)
					If nI < nMax
						cPastaGrp := cPastaGrp + "_"
					EndIf
				Else
					cMsgLog += CRLF + "J201GetPFat.: " + I18N(STR0106, {aCampos[nI], 'NX0'} ) //# "Não foi possível localizar o campo '#1' na estrutura da tabela '#2'."
				EndIf
			Next nI
			cPastaGrp := JurFixPath(cPastaGrp, 2, 1)
			cPastaDest:= cPastaDest + cPastaGrp

			If !ExistDir(cPathImg+cPastaDest) //Se não existir, cria o diretório  do MV_JPASGRP
				If (MakeDir(cPathImg + cPastaDest)!= 0)
					cMsgLog += CRLF + "J201GetPFat.: " + I18N(STR0105, {cPathImg + cPastaDest} ) //# "Não foi possível criar o diretório '#1'."
				EndIf
			EndIf

		Else
			cMsgLog += CRLF + "J201GetPFat.: " + I18N(STR0107, {cPreFt} ) //# "Não foi possível localizar a pré-fatura '#1'."
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return cPastaDest

//-------------------------------------------------------------------
/*/{Protheus.doc} J201VldCnt(cCodigos, cTab, nOrdem, cCampo)
Função utilizada para validar os codigos separados por ; da tela de emissão.

@Param  cCodigos  string de codigos concatenados por ';' Ex: "000001;000002"
@Param  cTab      Tabela do referente os códigos. Ex: "SA1"
@Param  nOrdem    número do indice para validação Ex: 1
@Param  cCampo    Nome do campo de validação. Ex: 'A1_COD'
@Param  cTittle   Titulo do campo validado para mensagem de erro: 'Cliente'
@Param  cVldAtiv  Valida o registro conforme o tipo: 1 - Inativo; 2- ativos; 3-Todos
@Param  cCpoInat  Campo para teste de registro inativo Ex: "RD0_MSBLQL"

@author Luciano Pereira dos Santos
@since 15/12/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201VldCpo(cCodigos, cTab, nOrdem, cCampo, cTittle, cVldAtiv, cCpoInat)
Local lRet       := .T.
Local aCodigos   := {}
Local cCodigo    := ""
Local aArea      := GetArea()
Local nI         := 0
Local nTamCod    := TamSX3(cCampo)[1]

Default cCodigos := ""
Default cTab     := ""
Default nOrdem   := 0
Default cVldAtiv := "2"
Default cCpoInat := ""

If !Empty(cCodigos)
	aCodigos := StrTokArr(Alltrim(cCodigos), ";")

	For nI := 1 To Len(aCodigos)
		cCodigo := aCodigos[nI]

		If (Len(cCodigo) <= nTamCod)
			cCodigo := PadR(cCodigo, nTamCod, " ")
			If cVldAtiv == "2" //Validação para registro somente ativo
				lRet := ExistCpo(cTab, cCodigo, nOrdem, , .F., .T.)
			Else
				lRet := JurGetDados(cTab, nOrdem, xFilial(cTab) + cCodigo, cCpoInat) $ Iif(cVldAtiv == "3", "1|2", "1")
			EndIf
		Else
			lRet := .F.
		EndIf

		If !lRet
			Exit
		EndIf
	Next nI

	Iif(!lRet, ApMsgStop(I18N(STR0122, {Alltrim(cCodigo), cTittle})), Nil) //O código '#1' não é um registro válido para o campo '#2'."

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201TipRel
Função para retornar o tipo de relatorio de pre-fatura
Verifica o contrato, a juncao de contrato e busca se existe rel. especifico
se nao, usa o default JU201

@param  cPreFat  Codigo da pre-fatura

@return cRet     RPT de impressao

@author Mauricio Canalle
@since 01/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201TipRel(cPreFat, cTipRel)
Local aArea := GetArea()
Local cRet  := 'JU201'

NX0->(DbSetOrder(1))
If NX0->(DbSeek(xFilial('NX0') + cPreFat))
	If !Empty(NX0->NX0_CJCONT)  // Tem juncao de contrato
		NW2->(DbSetOrder(1))
		If NW2->(DbSeek(xFilial('NW2') + NX0->NX0_CJCONT))  // posiciona a juncao
			If NW2->(FieldPos('NW2_RELPRE')) > 0 .And. !Empty(NW2->NW2_RELPRE)  // rpt especifico
				cRet    := J201RetRel(NW2->NW2_RELPRE)
				cTipRel := NW2->NW2_RELPRE
			EndIf
		EndIf
	Else // Nao Tem Juncao de Contrato
		If !Empty(NX0->NX0_CCONTR)  // Tem Contrato
			NT0->(DbSetOrder(1))
			If NT0->(DbSeek(xFilial('NT0') + NX0->NX0_CCONTR))  // posiciona no contrato
				If NT0->(FieldPos('NT0_RELPRE')) > 0 .And. !Empty(NT0->NT0_RELPRE)  // rpt especifico
					cRet    := J201RetRel(NT0->NT0_RELPRE)
					cTipRel := NT0->NT0_RELPRE
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201RetRel(cTpRel)
Função para retornar o tipo de relatorio de pre-fatura
Busca na NZO pelo tipo de relatorio e retorna o RPT especifico
e caso nao tenha o default JU201

@param  cTpRel   Codigo do tipo de relatorio

@return cRet     RPT especifico

@author Mauricio Canalle
@since 01/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201RetRel(cTpRel)
Local aArea       := GetArea()
Local cRet        := 'JU201' // Relat Padrao
Local cDirCrystal := GetMV('MV_CRYSTAL')

NZO->(DbSetOrder(1))
If NZO->(Dbseek(xFilial('NZO') + cTpRel))
	If !Empty(NZO->NZO_ARQ)
		cRet := Upper(Alltrim(NZO->NZO_ARQ))
		cRet := StrTran(cRet, '.RPT', '')  // tira o .rpt do nome caso tenha sido cadastrado
		If !File(cDirCrystal + cRet + '.RPT')  // verifica se encontra o arquivo especifico na pasta dos relatorios
			cRet := 'JU201'  // se nao encontra imprime o padrao
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201VldTrf()
Valida se o tipo de relatorio de fatura (NRJ) esta ativo

@param  cTpRel  Codigo do tipo de relatorio

@return cRet    .T./.F.

@author Mauricio Canalle
@since 03/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201VldTrf(cTpRel)
Local lRet   := .T.
Local aArea  := GetArea()

NRJ->( dbSetOrder( 1 ) ) //NRJ_FILIAL+NRJ_COD
If NRJ->( dbSeek( xFilial('NRJ') + cTipoRF, .F. ) )
	If !NRJ->NRJ_ATIVO == '1'
		ApMsgStop( STR0108 ) //'Este tipo de relatório não pode ser utilizado pois está inativo'
		lRet := .F.
	EndIf
Else
	ApMsgStop( STR0109 ) //'Tipo de Relatório Não Cadastrado...'
	lRet := .F.
EndIf

RestArea(aArea)

Return( lRet )
