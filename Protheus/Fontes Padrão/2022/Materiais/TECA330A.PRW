#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PONCALEN.CH"
#INCLUDE "TECA330A.CH"

#DEFINE _ZZXGRUPO		1
#DEFINE _ZZXDATA		2
#DEFINE _ZZXSEMANA	3
#DEFINE _ZZXENTRADA	4
#DEFINE _ZZXSAIDA		5
#DEFINE _ZZXATEND 	6
#DEFINE _ZZXNOME  	7
#DEFINE _ZZXSITALO  	8
#DEFINE _ZZXTIPO		9
#DEFINE _ZZXCODABB	10
#DEFINE _ZZXATEAGE	11
#DEFINE _ZZXTURNO 	12
#DEFINE _ZZXSEQ   	13

#DEFINE _ULTALOC_KEYTGY		1
#DEFINE _ULTALOC_DATA		2
#DEFINE _ULTALOC_SEQ		3
#DEFINE _ULTALOC_ITEMTGY	4
#DEFINE _ULTALOC_GRUPO		5
#DEFINE _ULTALOC_LINHA		6
#DEFINE _ULTALOC_DTF		7
#DEFINE _ULTALOC_SIZE		7

#DEFINE _ULTALOC_PREV		6

#DEFINE _TDV_DTREF		1
#DEFINE _TDV_TURNO		2
#DEFINE _TDV_TPEXT		3
#DEFINE _TDV_TPEXTN		4
#DEFINE _TDV_NONHOR		5
#DEFINE _TDV_CODREF		6
#DEFINE _TDV_INSREP		7
#DEFINE _TDV_HRMEN		8
#DEFINE _TDV_HRMAI		9
#DEFINE _TDV_FERIAD		10
#DEFINE _TDV_FTPEXT		11
#DEFINE _TDV_FEXTN		12
#DEFINE _TDV_FEXTN		13
#DEFINE _TDV_FERSAI		14
#DEFINE _TDV_FSTPEX		15
#DEFINE _TDV_FSEXTN		16
#DEFINE _TDV_INTVL1		17
#DEFINE _TDV_INTVL2		18
#DEFINE _TDV_INTVL3		19
#DEFINE _TDV_PREV			19
#DEFINE _NPOSCFG		3
#DEFINE _NPOSTIPCFG		1
#DEFINE _NPOSDIASEM		2
#DEFINE _NPOSHRINI		3
#DEFINE _NPOSHRFIM		4

STATIC aFilGrp := { STR0009 } // "Todos"
STATIC aFilAte := { STR0009 } // "Todos"
STATIC aAtend  := {}

STATIC lLegend := .T.
STATIC nGrpFil := 0
STATIC cAteFil  := ""
STATIC nTamCdAte := TAMSX3("AA1_CODTEC")[1]


STATIC aCfltHead	:= {'AA1_FILIAL','AA1_CODTEC','AA1_NOMTEC','ABB_DTINI','ABB_HRINI','ABB_DTFIM',;
						'ABB_HRFIM','RA_SITFOLH','RA_ADMISSA','RA_DEMISSA','RF_DATAINI','RF_DFEPRO1','RF_DATINI2',;
						'RF_DFEPRO2','RF_DATINI3','RF_DFEPRO3','R8_DATAINI','R8_DATAFIM',;
						"DTINI", "DTFIM", 'HRINI' ,"HRFIM", "ATIVO", "DTREF"}
STATIC aCfltAtnd	:= {}
Static aAteAgeSt := {}
STATIC aDiasFer 	:= {}
STATIC aDiasFer2 	:= {}
STATIC aDiasFer3 	:= {}
STATIC aDiasAfast 	:= {}
STATIC aDiasDem 	:= {}
STATIC aDiasAdi		:= {}

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Alocação por escala

@Return 	nil
@author	Serviços
@since 		03/07/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruTFF := FWFormStruct(1,"TFF")
Local oStruTGY := FWFormStruct(1,"TGY")
Local oStruZZX := FWFormModelStruct():New()
Local bLoad    := {|oModel| At330LdZZX(oModel )} 
Local bCommit  := { |oModel| At330ACmt(oModel) }
Local bLinePre := { |oMdlG,nLine,cAcao,cCampo| PreLinZZX(oMdlG, nLine, cAcao, cCampo) }
Local bLinePos := { |oMdlG,nLine,cAcao,cCampo| PosLinZZX(oMdlG, nLine, cAcao, cCampo) }
Local bPos330Val:={ |oModel| At330AVal(oModel) }
Local aAux     := {}	

aDiasFer 	:= {}
aDiasAfast 	:= {}
aDiasAAbb 	:= {}
aDiasDem 	:= {}
aDiasAdi	:= {}
aFilGrp := { STR0009 } // "Todos"
aFilAte := { STR0009 } // "Todos"
aAtend  := {}
nGrpFil := 0
cAteFil := ""
aCfltAtnd := {}
aAteAgeSt := {}

oStruZZX:AddTable("   ",{},STR0001) // "Efetivos"

// Altera as estruturas da tabela para montar a tela
At330AStru( .F., oStruTFF, "TFF", .T. )
At330AStru( .F., oStruTGY, "TGY", .T. )                    		
At330AStru( .F., oStruZZX, "ZZX", .T. )

aAux := FwStruTrigger("ZZX_ATEND","ZZX_NOME","AA1->AA1_NOMTEC",.T.,"AA1",1,'xFilial("AA1")+FwFldGet("ZZX_ATEND")')
oStruZZX:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oStruZZX:SetProperty( "ZZX_ENTRADA", MODEL_FIELD_VALID, { |oModel| At330AVldInf(oModel,"ZZX_ENTRADA") } )
oStruZZX:SetProperty( "ZZX_SAIDA"  , MODEL_FIELD_VALID, { |oModel| At330AVldInf(oModel,"ZZX_SAIDA")   } )
oStruZZX:SetProperty( "ZZX_ATEND"  , MODEL_FIELD_VALID, { |oModel| At330AVldInf(oModel,"ZZX_ATEND")   } )
oStruZZX:SetProperty( "ZZX_TIPO"   , MODEL_FIELD_VALID, { |oModel| At330AVldInf(oModel,"ZZX_TIPO")    } )

oStruTGY:SetProperty( "TGY_CODTFF", MODEL_FIELD_OBRIGAT, .F. )
oStruTFF:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

oModel := MPFormModel():New("TECA330A", /*bPreValidacao*/,bPos330Val, bCommit, /*bCancel*/ )

oModel:AddFields("TFFMASTER",/*cOwner*/,oStruTFF, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid( "TGYDETAIL", "TFFMASTER", oStruTGY, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, {|oModel|a330LdTGY(oModel)}   )
oModel:AddGrid( "ZZXDETAIL", "TFFMASTER", oStruZZX, bLinePre, bLinePos, /*bPreVal*/, /*bPosVal*/, bLoad )

oModel:SetDescription(STR0002) // "Alocacao por escala"

oModel:SetVldActivate( {|oModel| At330AVld(oModel)} ) 
oModel:SetActivate( {|oModel| InitDados( oModel ) } )

oModel:GetModel("ZZXDETAIL"):SetOptional(.T.)

oModel:GetModel("ZZXDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("TGYDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("TGYDETAIL"):SetNoDeleteLine(.T.)


Return(oModel)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Alocação por escala

@Return 	view
@author 	Serviços
@since 		04/07/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel := FWLoadModel("TECA330A")

Local oStruTFF := FwFormStruct( 2, "TFF", {|cCpo| AllTrim(cCpo)$"TFF_COD+TFF_CONTRT+TFF_PRODUT+TFF_DESCRI+TFF_LOCAL+TFF_ESCALA+TFF_NOMESC" } )
Local oStruTGY := FwFormStruct( 2, "TGY", {|cCpo| AllTrim(cCpo)$"TGY_TURNO+TGY_DESC+TGY_SEQ+TGY_ATEND+TGY_NOME+TGY_DTINI+TGY_DTFIM+TGY_GRUPO+TGY_ULTALO+TGY_TIPALO" } )
Local oStruZZX := FWFormViewStruct():New()

At330AStru( .F., oStruTFF, "TFF", .F. )
At330AStru( .F., oStruTGY, "TGY", .F. )
At330AStru( .F., oStruZZX, "ZZX", .F. )     		
					
oStruTFF:SetProperty( "*", MVC_VIEW_CANCHANGE, .F. )
oStruTGY:SetProperty( "*", MVC_VIEW_CANCHANGE, .F. )
oStruTGY:SetProperty( "TGYSTATUS", MVC_VIEW_CANCHANGE, .T. )	//Legenda: Conflito Atendente

oStruZZX:SetProperty( "ZZX_ENTRADA", MVC_VIEW_CANCHANGE, .T. )
oStruZZX:SetProperty( "ZZX_SAIDA"  , MVC_VIEW_CANCHANGE, .T. )
oStruZZX:SetProperty( "ZZX_ATEND"  , MVC_VIEW_CANCHANGE, .T. )
oStruZZX:SetProperty( "ZZX_TIPO"   , MVC_VIEW_CANCHANGE, .T. )

// Legenda Alocacao por Escala														
oStruZZX:SetProperty( "ZZX_SITABB" , MVC_VIEW_CANCHANGE, .T. )
oStruZZX:SetProperty( "ZZX_SITALO" , MVC_VIEW_CANCHANGE, .T. )														
														
oView := FWFormView():New()
oView:SetModel( oModel )

oView:SetDescription( STR0002 ) // "Alocacao por escala"
oView:SetCloseOnOk({|| .T. } )

oView:AddField("TFF_CABEC", oStruTFF, "TFFMASTER" )
oView:AddGrid( "TGY_GRID" , oStruTGY, "TGYDETAIL" )
oView:AddGrid( "ZZX_GRID" , oStruZZX, "ZZXDETAIL" )

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "TOP"   , 22 )  
oView:CreateHorizontalBox( "MIDDLE", 25 )  
oView:CreateHorizontalBox( "FILDWN", 15 )
oView:CreateHorizontalBox( "DOWN"	, 38 )

oView:AddOtherObject("FIL_MESC", {|oPanel,oView| At330AFil(oPanel,oView) })  

oView:AddUserButton( STR0003, "", {|oView| At330AEsc(oView)}, Nil, Nil, Nil ) // "Visualizar Escala"
oView:AddUserButton( STR0004, "", {|oView| At330ATotHor(oView)}, Nil, Nil, Nil ) // "Horas de Alocação"
oView:AddUserButton( STR0069, "", {|oView| At330Desaloc(oView)}, Nil, Nil, Nil ) // "Remoção de Agenda"
oView:AddUserButton( STR0078, "", {|oView| At330ADtCfl(oView)}, Nil, Nil, Nil ) // "Detalhar Conflito"
oView:AddUserButton( STR0090, "", {|oView| At330MntAge(oView)}, Nil, Nil, Nil ) // "Manut. Agenda"
//--------------------------------------
//		Associa os componentes ao Box
//--------------------------------------
oView:SetOwnerView( "TFF_CABEC", "TOP"   ) 
oView:SetOwnerView( "TGY_GRID", "MIDDLE" )
oView:SetOwnerView( "FIL_MESC", "FILDWN" )
oView:SetOwnerView( "ZZX_GRID", "DOWN" )

oView:EnableTitleView( "TGY_GRID", STR0005 ) 			// "Atendentes da escala"
oView:EnableTitleView( "FIL_MESC", STR0006 ) 			// "Agenda"

 	Return(oView)


/*/{Protheus.doc} At330AVld
Pre validação para a ativação do model

@since 06/03/2015
@version 1.0
@param oModel, objeto, Model
@return lRet

/*/
Static Function At330AVld(oModel)
Local lRet := .T.
If MV_PAR01 >= TFF->TFF_PERINI .AND. (MV_PAR02 <= TFF->TFF_PERFIM .OR. Empty(TFF->TFF_PERFIM))
	lRet := .T.
Else
	Help(,,"At330AVld",,STR0074 + " ("+DTOC(TFF->TFF_PERINI)+" - "+DTOC(TFF->TFF_PERFIM)+")",1,0) // "Periodo de alocação inicial e/ou final fora do periodo do contrato!"
	lRet := .F.
EndIf

//verificar se o local / posto esta encerrado
If empty(TFF->TFF_ENCE) .OR. TFF->TFF_ENCE <> '1' 
	lRet := .T.
Else
	Help(,,"At330AVld",,STR0088,1,0) // "Posto Encerrado, não poderá gerar novas agendas" 
	lRet := .F.
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados()
Inicializa as informações da visualização da escala

@sample 	InitDados()

@param  	oModel, Objeto, objeto geral do model que será alterado

@author 	Serviços
@since 		09/06/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlTFF  	:= oModel:GetModel("TFFMASTER")
Local lView		:= oModel:GetOperation() == MODEL_OPERATION_VIEW
   
// Cabecalho da alocacao 

If lView
	oMdlTFF:LoadValue( "TFF_DATINI", MV_PAR01 )
	oMdlTFF:LoadValue( "TFF_DATFIM", MV_PAR02 )
	oMdlTFF:LoadValue( "TFF_DSCABS", Posicione( "ABS", 1, xFilial("ABS")+oMdlTFF:GetValue("TFF_LOCAL"), "ABS_DESCRI" ) )
	oMdlTFF:LoadValue( "TFF_DESCRI", Left( Posicione( "SB1", 1, xFilial("SB1")+oMdlTFF:GetValue("TFF_PRODUT"), "B1_DESC" ), 30 ) )
	oMdlTFF:LoadValue( "TFF_NOMESC", Posicione( "TDW", 1, xFilial("TDW")+oMdlTFF:GetValue("TFF_ESCALA"), "TDW_DESC" ) )
Else
	oMdlTFF:SetValue( "TFF_DATINI", MV_PAR01 )
	oMdlTFF:SetValue( "TFF_DATFIM", MV_PAR02 )
	oMdlTFF:SetValue( "TFF_DSCABS", Posicione( "ABS", 1, xFilial("ABS")+oMdlTFF:GetValue("TFF_LOCAL"), "ABS_DESCRI" ) )
	oMdlTFF:SetValue( "TFF_DESCRI", Left( Posicione( "SB1", 1, xFilial("SB1")+oMdlTFF:GetValue("TFF_PRODUT"), "B1_DESC" ), 30 ) )
	oMdlTFF:SetValue( "TFF_NOMESC", Posicione( "TDW", 1, xFilial("TDW")+oMdlTFF:GetValue("TFF_ESCALA"), "TDW_DESC" ) )
EndIf
Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330ABtn
Criação do botão para as acoes da alocacao

@sample 	At330ABtn(oPanel)

@param		oPanel - Painel onde deverá ser criado e exibido o botão
	
@return	Nil 
@author	Serviços
@since		04/07/2014       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function At330ABtn( oPanel, cTipo )

Local oButton

Local oModel  := FwModelActive()
Local cEscala := oModel:GetModel("TFFMASTER"):GetValue("TFF_ESCALA")
Local cTitulo := If( cTipo == "1", STR0003, STR0014 ) // "Vis. Escala" # "Montar Escala"

@ 000, 000 Button oButton Prompt cTitulo Of oPanel Size 060, 012 Pixel 
oButton:Align := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
oButton:bAction := { || At330AEsc( oModel) }

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AEsc
Criação do botão para as acoes da alocacao

@sample 	At330AEsc( cEscala, cTipo )

@param		oModel - Model que contem a informação da escala
@param		cTipo - Tipo do processo 1 = Visualizar / 2 = Montar
	
@return	Nil 
@author	Serviços
@since		07/07/2014       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function At330AEsc( oModel )

Local lConfirm

Local aArea   := GetArea()
Local cEscala := oModel:GetModel("TFFMASTER"):GetValue("TFF_ESCALA") 

dbSelectArea("TDW")
TDW->(dbSetOrder(1)) //TDW_FILIAL+TDW_COD

If TDW->(dbSeek(xFilial("TDW")+cEscala))	
	lConfirm := ( FWExecView( STR0015,"VIEWDEF.TECA580", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  // "Visualização da Escala" 
								{||.T.}/*bOk*/,/*nReducao*/, /*aButtons*/, {||.T.}/*bCancel*/ ) == 0 )
EndIf

RestArea( aArea )

Return(.T.)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AAtend
Retorna a lista de atendentes configurados na escala

@sample 	At330AAtend( cEscala, dDatIni, dDAtFim )

@param		cCodTFF - Código do recurso humano para a escala
@param		cEscala - Código da escala para gerar a lista
@param		dDatIni - Data Inicial para verificacao dos atendentes
@param		dDatFim - Data Final para verificacao dos atendentes
@param		nQtdVen - Quantidade vendida no orcamento de servicos
	
@return	aRet - Array com as informacoes dos atendentes da escala
 
@author	Serviços
@since		08/07/2014       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function At330AAtend( cCodTFF, cEscala, dDatIni, dDAtFim, cCodAtend, cContra, lRtFolg )
Local oModel
Local cContraDe
Local cContraAt
Local aRet 	  		:= {}
Local aAtendEsc 	:= {}
Local cAliasEfe 	:= GetNextAlias()
Local cAliasCob 	:= GetNextAlias()
Local cAliasSub		:= GetNextAlias()
Local cTGY_ATEND	:= Space(TamSx3("TGY_ATEND")[1])
Local lAlocAut		:= IsInCallStack("At330AloAut") //Alocação Automática
Local lGesHr		:= SuperGetMV('MV_GSGEHOR',,.F.) .And. at330ColHR()
Local cChvTGY    	:= ""
Local cChvTGZ    	:= ""
Local lTrocaEfet	:= IsInCallStack("At190TrEft")

Default cCodAtend 	:= ""
Default cContra := ""
Default lRtFolg := .F.

If EMPTY(cContra)
	If !lAlocAut
		oModel 	:= FwModelActive()
		cContra := oModel:GetModel("TFFMASTER"):GetValue("TFF_CONTRT")
	Else
		cContraDe := MV_PAR03
		cContraAt := MV_PAR04
	EndIf
EndIf

If !Empty(cCodAtend)
	cChvTGY := "%AND TGY.TGY_ATEND = '"+cCodAtend+"'%"
Else
	cChvTGY := "%%"
EndIf

// Efetivos
If !lGesHr
	BeginSql Alias cAliasEfe
		COLUMN TGY_DTINI AS DATE
		COLUMN TGY_DTFIM AS DATE
		SELECT 
			TDX.TDX_COD,TGY.TGY_ITEM, TDX.TDX_TURNO, SR6.R6_DESC, TGY.TGY_SEQ, TGY.TGY_ULTALO, 
			TDX.TDX_TIPO, TGY.TGY_GRUPO, TGY.TGY_ATEND, 
			AA1.AA1_NOMTEC, TGY.TGY_DTINI, TGY.TGY_DTFIM, TGY.TGY_TIPALO 		
		FROM 
			%table:TDW% TDW 
		JOIN %table:TDX% TDX ON
			TDX.TDX_FILIAL = %xFilial:TDX% AND 
			TDX.TDX_CODTDW = TDW.TDW_COD AND 
			TDX.%NotDel%
		JOIN %table:TGY% TGY ON
			TGY.TGY_FILIAL = %xFilial:TGY% AND 
			TGY.TGY_CODTDX = TDX.TDX_COD AND
			TGY.%NotDel%
			%Exp:cChvTGY%
		LEFT JOIN %table:SR6% SR6 ON 
			SR6.R6_FILIAL = %xFilial:SR6% AND 
			SR6.R6_TURNO = TDX.TDX_TURNO AND
			SR6.%NotDel%
		LEFT JOIN %table:AA1% AA1 ON
			AA1.AA1_FILIAL = %xFilial:AA1% AND 
			AA1.AA1_CODTEC = TGY.TGY_ATEND AND
			AA1.%NotDel%
		WHERE 
			TDW.TDW_FILIAL = %xFilial:TDW% AND 
			TDW.TDW_COD = %Exp:cEscala% AND
			TGY.TGY_CODTFF = %Exp:cCodTFF% AND
			TGY.TGY_ATEND <> %exp:cTGY_ATEND% AND
			((TGY.TGY_DTINI BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR
			(TGY.TGY_DTFIM <> %exp:Space(8)% AND 
			TGY.TGY_DTFIM BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR
			(TGY.TGY_DTINI < %Exp:dDatIni% AND 
			(TGY.TGY_DTFIM=%exp:Space(8)% OR TGY.TGY_DTFIM > %Exp:dDatFim%))) AND 
			TDW.%NotDel%
		GROUP BY 
			TDX.TDX_COD, TDX.TDX_TURNO, SR6.R6_DESC, TGY.TGY_SEQ, TGY.TGY_ULTALO,
			TDX.TDX_TIPO, TGY.TGY_ITEM, TGY.TGY_GRUPO, TGY.TGY_ATEND, 
			AA1.AA1_NOMTEC, TGY.TGY_DTINI, TGY.TGY_DTFIM, TGY.TGY_TIPALO 		
	 
	EndSql
	

Else
	BeginSql Alias cAliasEfe
		COLUMN TGY_DTINI AS DATE
		COLUMN TGY_DTFIM AS DATE
		SELECT 
			TDX.TDX_COD,TGY.TGY_ITEM, TDX.TDX_TURNO, SR6.R6_DESC, TGY.TGY_SEQ, TGY.TGY_ULTALO, 
			TDX.TDX_TIPO, TGY.TGY_GRUPO, TGY.TGY_ATEND, 
			AA1.AA1_NOMTEC, TGY.TGY_DTINI, TGY.TGY_DTFIM, TGY.TGY_TIPALO, TGY.TGY_ENTRA1, TGY.TGY_SAIDA1, TGY.TGY_ENTRA2, TGY.TGY_SAIDA2,
			TGY.TGY_ENTRA3, TGY.TGY_SAIDA3, TGY.TGY_ENTRA4, TGY.TGY_SAIDA4 		
		FROM 
			%table:TDW% TDW 
		JOIN %table:TDX% TDX ON
			TDX.TDX_FILIAL = %xFilial:TDX% AND 
			TDX.TDX_CODTDW = TDW.TDW_COD AND 
			TDX.%NotDel%
		JOIN %table:TGY% TGY ON
			TGY.TGY_FILIAL = %xFilial:TGY% AND 
			TGY.TGY_CODTDX = TDX.TDX_COD AND
			TGY.%NotDel%
			%Exp:cChvTGY%
		LEFT JOIN %table:SR6% SR6 ON 
			SR6.R6_FILIAL = %xFilial:SR6% AND 
			SR6.R6_TURNO = TDX.TDX_TURNO AND
			SR6.%NotDel%
		LEFT JOIN %table:AA1% AA1 ON
			AA1.AA1_FILIAL = %xFilial:AA1% AND 
			AA1.AA1_CODTEC = TGY.TGY_ATEND AND
			AA1.%NotDel%
		WHERE 
			TDW.TDW_FILIAL = %xFilial:TDW% AND 
			TDW.TDW_COD = %Exp:cEscala% AND
			TGY.TGY_CODTFF = %Exp:cCodTFF% AND
			TGY.TGY_ATEND <> %exp:cTGY_ATEND% AND
			((TGY.TGY_DTINI BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR
			(TGY.TGY_DTFIM <> %exp:Space(8)% AND 
			TGY.TGY_DTFIM BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR
			(TGY.TGY_DTINI < %Exp:dDatIni% AND 
			(TGY.TGY_DTFIM=%exp:Space(8)% OR TGY.TGY_DTFIM > %Exp:dDatFim%))) AND 
			TDW.%NotDel%
		GROUP BY 
			TDX.TDX_COD, TDX.TDX_TURNO, SR6.R6_DESC, TGY.TGY_SEQ, TGY.TGY_ULTALO,
			TDX.TDX_TIPO, TGY.TGY_ITEM, TGY.TGY_GRUPO, TGY.TGY_ATEND, 
			AA1.AA1_NOMTEC, TGY.TGY_DTINI, TGY.TGY_DTFIM, TGY.TGY_TIPALO, TGY.TGY_ENTRA1, TGY.TGY_SAIDA1, TGY.TGY_ENTRA2, TGY.TGY_SAIDA2,
			TGY.TGY_ENTRA3, TGY.TGY_SAIDA3, TGY.TGY_ENTRA4, TGY.TGY_SAIDA4 		
	 
	EndSql
	
	
EndIf
While (cAliasEfe)->(!Eof())

	If !lGesHr
		aAdd( aAtendEsc, { (cAliasEfe)->TGY_GRUPO,;
							 X3Combo("TDX_TIPO",(cAliasEfe)->TDX_TIPO),;
							 (cAliasEfe)->TDX_TURNO,;
							 (cAliasEfe)->R6_DESC,;
							 (cAliasEfe)->TGY_SEQ,;
							 (cAliasEfe)->TGY_ATEND,;
							 (cAliasEfe)->AA1_NOMTEC,;
							 (cAliasEfe)->TGY_DTINI,;
							 (cAliasEfe)->TGY_DTFIM,;
							 (cAliasEfe)->TDX_TIPO,;
							 (cAliasEfe)->TGY_ITEM,;
							 (cAliasEfe)->TDX_COD,;
							  .T.,;
							  STOD((cAliasEfe)->TGY_ULTALO),;
							 (cAliasEfe)->TGY_TIPALO} )			
	Else
		aAdd( aAtendEsc, { (cAliasEfe)->TGY_GRUPO,;
							 X3Combo("TDX_TIPO",(cAliasEfe)->TDX_TIPO),;
							 (cAliasEfe)->TDX_TURNO,;
							 (cAliasEfe)->R6_DESC,;
							 (cAliasEfe)->TGY_SEQ,;
							 (cAliasEfe)->TGY_ATEND,;
							 (cAliasEfe)->AA1_NOMTEC,;
							 (cAliasEfe)->TGY_DTINI,;
							 (cAliasEfe)->TGY_DTFIM,;
							 (cAliasEfe)->TDX_TIPO,;
							 (cAliasEfe)->TGY_ITEM,;
							 (cAliasEfe)->TDX_COD,;
							  .T.,;
							  STOD((cAliasEfe)->TGY_ULTALO),;
							 (cAliasEfe)->TGY_TIPALO,;
							 {{(cAliasEfe)->TGY_ENTRA1,;
							 (cAliasEfe)->TGY_SAIDA1},;
							 {(cAliasEfe)->TGY_ENTRA2,;
							 (cAliasEfe)->TGY_SAIDA2},;
							 {(cAliasEfe)->TGY_ENTRA3,;
							 (cAliasEfe)->TGY_SAIDA3},;
							 {(cAliasEfe)->TGY_ENTRA4,;
							 (cAliasEfe)->TGY_SAIDA4}}} )
		
		
	EndIf							 

	If aScan(aFilGrp,Str((cAliasEfe)->TGY_GRUPO,3)) == 0
		aAdd( aFilGrp, Str((cAliasEfe)->TGY_GRUPO,3) )
	EndIf	
	
	If aScan(aFilAte,	(cAliasEfe)->TGY_ATEND+" - "+(cAliasEfe)->AA1_NOMTEC ) == 0
		aAdd( aFilAte,(cAliasEfe)->TGY_ATEND+" - "+(cAliasEfe)->AA1_NOMTEC )	
	EndIf	

	(cAliasEfe)->(dbSkip())
	If lRtFolg
		Exit
	Endif
EndDo

(cAliasEfe)->(dbCloseArea())
If !lTrocaEfet .AND. !isInCallStack("ProjAloc2")
	
	If !Empty(cCodAtend)  .AND. isInCallStack("ProjALoc2")
		cChvTGZ := "%AND TGZ.TGZ_ATEND = '"+cCodAtend+"'%"
	Else
		cChvTGZ := "%%"
	EndIf
	
	// Cobertura
	BeginSql Alias cAliasCob
		COLUMN TGZ_DTINI AS DATE
		COLUMN TGZ_DTFIM AS DATE
		SELECT 
			TGX.TGX_TIPO, TGX.TGX_ITEM, TGZ.TGZ_GRUPO, TGZ.TGZ_ATEND, 
			AA1.AA1_NOMTEC, TGZ.TGZ_DTINI, TGZ.TGZ_DTFIM
		FROM 
			%table:TDW% TDW 
		JOIN %table:TGX% TGX ON
			TGX.TGX_FILIAL = %xFilial:TGX% AND 
			TGX.TGX_CODTDW = TDW.TDW_COD AND 
			TGX.%NotDel%
		JOIN %table:TGZ% TGZ ON
			TGZ.TGZ_FILIAL = %xFilial:TGZ% AND 
			TGZ.TGZ_CODTDX = TGX.TGX_COD AND 
			TGZ.%NotDel%
			%Exp:cChvTGZ%
		LEFT JOIN %table:AA1% AA1 ON
			AA1.AA1_FILIAL = %xFilial:AA1% AND 
			AA1.AA1_CODTEC = TGZ.TGZ_ATEND AND
			AA1.%NotDel%
		WHERE 
			TDW.TDW_FILIAL = %xFilial:TDW% AND 
			TDW.TDW_COD = %Exp:cEscala% AND
			TGZ.TGZ_CODTFF = %Exp:cCodTFF% AND
			((TGZ.TGZ_DTINI BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR
			(TGZ.TGZ_DTFIM <> %exp:Space(8)% AND 
			TGZ.TGZ_DTFIM BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR
			(TGZ.TGZ_DTINI < %Exp:dDatIni% AND 
			(TGZ.TGZ_DTFIM=%exp:Space(8)% OR TGZ.TGZ_DTFIM > %Exp:dDatFim%))) AND				 
			TDW.%NotDel%	
		GROUP BY 
			TGX.TGX_TIPO, TGX.TGX_ITEM, TGZ.TGZ_GRUPO, TGZ.TGZ_ATEND, 
			AA1.AA1_NOMTEC, TGZ.TGZ_DTINI, TGZ.TGZ_DTFIM
	EndSql
	
	While (cAliasCob)->(!Eof())
	
		aAdd( aAtendEsc, { (cAliasCob)->TGZ_GRUPO,;
							 X3Combo("TGX_TIPO",(cAliasCob)->TGX_TIPO),;
							 "",;
							 "",;
							 "",;
							 (cAliasCob)->TGZ_ATEND,;
							 (cAliasCob)->AA1_NOMTEC,;
							 (cAliasCob)->TGZ_DTINI,;
							 (cAliasCob)->TGZ_DTFIM,;
							 (cAliasCob)->TGX_TIPO,;
							 (cAliasCob)->TGX_ITEM,;
							 "",;
							  .T.,;
							  STOD(""),;
							  "" } )
								 
		If aScan(aFilGrp,Str((cAliasCob)->TGZ_GRUPO,3)) == 0
			aAdd( aFilGrp, Str((cAliasCob)->TGZ_GRUPO,3) )
		EndIf	
			
		If aScan(aFilAte,	(cAliasCob)->TGZ_ATEND + " - " + (cAliasCob)->AA1_NOMTEC ) == 0
			aAdd( aFilAte,(cAliasCob)->TGZ_ATEND + " - " + (cAliasCob)->AA1_NOMTEC )	
		EndIf		
		
		(cAliasCob)->(dbSkip())
		
	EndDo

	(cAliasCob)->(dbCloseArea())
EndIf

If lAlocAut .And. !lTrocaEfet
	// Substituto - Alocação Automática
	BeginSql Alias cAliasSub
		COLUMN ABR_DTINI AS DATE
		COLUMN ABR_DTFIM AS DATE
		SELECT 
			Distinct(ABR_CODSUB), AA1.AA1_NOMTEC, TDV.TDV_GRUPO
		FROM 
			%table:TFF% TFF, %table:ABR% ABR
		INNER JOIN %table:ABB% ABB ON 
			ABB.ABB_FILIAL = %xFilial:ABB% AND ABB.ABB_CODTEC = ABR.ABR_CODSUB AND ABB.%NotDel%
		INNER JOIN %table:TDV% TDV ON 
			TDV.TDV_FILIAL = %xFilial:TDV% AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.%NotDel%
		LEFT JOIN %table:AA1% AA1 ON
			AA1.AA1_FILIAL = %xFilial:AA1% AND 
			AA1.AA1_CODTEC = ABR.ABR_CODSUB AND
			AA1.%NotDel%
		WHERE 
			((ABR.ABR_DTINI BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR 
			(ABR.ABR_DTFIM <> %Exp:Space(8)% AND 
			ABR.ABR_DTFIM BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR 
			(ABR.ABR_DTINI < %Exp:dDatIni% AND 
			(ABR.ABR_DTFIM = %Exp:Space(8)% OR ABR.ABR_DTFIM > %Exp:dDatFim%))) AND
			ABR.ABR_FILIAL = %xFilial:ABR% AND
			ABR.%NotDel% AND
			TFF.TFF_FILIAL = %xFilial:TFF% AND
			TFF.TFF_CONTRT BETWEEN %Exp:cContraDe% AND %Exp:cContraAt% AND
			TFF.%NotDel%
	EndSql
Else
	// Substituto
	BeginSql Alias cAliasSub
		COLUMN ABR_DTINI AS DATE
		COLUMN ABR_DTFIM AS DATE
		SELECT 
			Distinct(ABR_CODSUB), AA1.AA1_NOMTEC, TDV.TDV_GRUPO
		FROM 
			%table:TFF% TFF, %table:ABR% ABR
		INNER JOIN %table:ABB% ABB ON 
			ABB.ABB_FILIAL = %xFilial:ABB% AND ABB.ABB_CODTEC = ABR.ABR_CODSUB AND ABB.%NotDel%
		INNER JOIN %table:ABQ% ABQ ON
			ABQ.ABQ_FILIAL = %xFilial:ABQ% AND 
			ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND 
			ABQ.%NotDel% AND
			ABQ.ABQ_CONTRT = %Exp:cContra% AND 
			ABQ.ABQ_CODTFF = %Exp:cCodTFF% AND
			ABQ.ABQ_FILTFF = %xFilial:TFF% 
		INNER JOIN %table:TDV% TDV ON 
			TDV.TDV_FILIAL = %xFilial:TDV% AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.%NotDel%
		LEFT JOIN %table:AA1% AA1 ON
			AA1.AA1_FILIAL = %xFilial:AA1% AND 
			AA1.AA1_CODTEC = ABR.ABR_CODSUB AND
			AA1.%NotDel%
		WHERE 
			((ABR.ABR_DTINI BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR 
			(ABR.ABR_DTFIM <> %Exp:Space(8)% AND 
			ABR.ABR_DTFIM BETWEEN %Exp:dDatIni% AND %Exp:dDatFim%) OR 
			(ABR.ABR_DTINI < %Exp:dDatIni% AND 
			(ABR.ABR_DTFIM = %Exp:Space(8)% OR ABR.ABR_DTFIM > %Exp:dDatFim%))) AND
			ABR.ABR_FILIAL = %xFilial:ABR% AND
			ABR.%NotDel% AND
			TFF.TFF_COD = %Exp:cCodTFF%  AND
			TFF.TFF_FILIAL = %xFilial:TFF% AND
			TFF.TFF_CONTRT = %Exp:cContra% AND
			TFF.%NotDel%
	EndSql
EndIf

While (cAliasSub)->(!Eof())
	
	//Colocar os substitutos para fazer o filtro
	If aScan(aFilGrp,Str((cAliasSub)->TDV_GRUPO,3)) == 0
		aAdd( aFilGrp, Str((cAliasSub)->TDV_GRUPO,3) )
	EndIf
		
	If aScan(aFilAte,	(cAliasSub)->ABR_CODSUB + " - " + (cAliasSub)->AA1_NOMTEC ) == 0
		aAdd( aFilAte,(cAliasSub)->ABR_CODSUB + " - " + (cAliasSub)->AA1_NOMTEC )	
	EndIf		
	
	(cAliasSub)->(dbSkip())
EndDo

(cAliasSub)->(dbCloseArea())
aSort( aFilAte  , 2, Nil, { |x,y| x < y } )
aSort( aAtendEsc, Nil, Nil, { |x,y| x[1]<y[1] .And. x[3]+x[5]<y[3]+y[5] .And. DtoS(x[8])<DtoS(y[8]) } )

aRet := aAtendEsc

Return(aRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AAtEsp
Retorna a lista de atendentes alocados fora da escala

@sample 	At330AAtEsp( aAteEfe, cCodTFF, cContrato )

@param		aAteEfe   - Array com os atendentes da escala
@param		cCodTFF   - Código do recurso humano para o filtro das alocações
@param		cContrato - Código do contrato para o filtro das alocações
 
@author	Serviços
@since		05/08/2014       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function At330AAtEsp( aAteEfe, cCodTFF, cContrato, dLimIni, dLimFim, cFilTFF )

Local cDscTip   := ""
Local nLenAte   := 0
Local cAliasABB := GetNextAlias()
Local lSum444 := TDV->(FieldPos("TDV_FERSAI")) > 0 .AND. TDV->(FieldPos("TDV_FSTPEX")) > 0 .AND. TDV->(FieldPos("TDV_FSEXTN")) > 0 // Verificação de campos para sumula 444
Local cCampos := If(lSum444,"%, TDV_FERSAI, TDV_FSTPEX, TDV_FSEXTN%", "%%")

Default cFilTFF := xFilial("TFF", cFilAnt )

BeginSql Alias cAliasABB	
	SELECT 
		ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_HRINI, 	ABB.ABB_HRFIM, 
		ABB.ABB_CODTEC, AA1.AA1_NOMTEC, ABB.ABB_CODIGO, ABB.ABB_ATENDE, ABB.ABB_MANUT,
		TDV.TDV_CODABB, TDV.TDV_DTREF, TDV.TDV_TURNO, TDV.TDV_SEQTRN, 
		TDV.TDV_TPEXT, TDV.TDV_TPEXTN,	TDV.TDV_NONHOR, TDV.TDV_CODREF, 
		TDV.TDV_INSREP, TDV.TDV_TPDIA, TDV.TDV_HRMEN, TDV.TDV_HRMAI,
		TDV.TDV_INTVL1, TDV.TDV_INTVL2, TDV.TDV_INTVL3, TDV.TDV_FERIAD, 
		TDV.TDV_FTPEXT, TDV.TDV_FEXTN, TDV.TDV_GRUPO %Exp:cCampos%
	FROM 
		%table:ABQ% ABQ
	JOIN %table:ABB% ABB ON
		ABB.ABB_FILIAL = %xFilial:ABB% AND 
		ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND 
		ABB.%NotDel%
	JOIN %table:TDV% TDV ON 
		TDV.TDV_FILIAL = %xFilial:TDV% AND 
		TDV.TDV_CODABB = ABB.ABB_CODIGO AND 
		TDV.%NotDel% 
	LEFT JOIN %table:AA1% AA1 ON
		AA1.AA1_FILIAL = %xFilial:AA1% AND 
		AA1.AA1_CODTEC = ABB.ABB_CODTEC AND
		AA1.%NotDel%
	WHERE 
		ABQ.%NotDel% AND
		ABQ.ABQ_FILIAL = %xFilial:ABQ% AND
		ABQ.ABQ_FILTFF = %Exp:cFilTFF% AND 
		ABQ.ABQ_CODTFF = %Exp:cCodTFF% AND  
		ABQ.ABQ_CONTRT = %Exp:cContrato% AND
		TDV.TDV_DTREF BETWEEN %Exp:DTOS(dLimIni)% AND %Exp:DTOS(dLimFim)% AND
		( SELECT 
			Count(1) 
		FROM 
			%table:TGZ% TGZ 
		WHERE 
			TGZ.TGZ_FILIAL = %xFilial:TGZ% AND 
			TGZ.TGZ_ATEND = ABB.ABB_CODTEC AND
			TGZ.TGZ_CODTFF = %Exp:cCodTFF% AND 
			TGZ.%NotDel% ) = 0 AND 
		( SELECT 
			Count(1) 
		FROM 
			%table:TGY% TGY 
		WHERE 
			TGY.TGY_FILIAL = %xFilial:TGY% AND 
			TGY.TGY_ATEND = ABB.ABB_CODTEC AND
			TGY.TGY_CODTFF = %Exp:cCodTFF% AND 
			TGY.%NotDel% ) = 0
EndSql

While (cAliasABB)->(!Eof())
	
	Do Case
		Case (cAliasABB)->TDV_TPDIA == "S" ; cDscTip := STR0016		// "Trabalhado"
		Case (cAliasABB)->TDV_TPDIA == "C" ; cDscTip := STR0017		// "Compensado"
		Case (cAliasABB)->TDV_TPDIA == "D" ; cDscTip := STR0018		// "D.S.R."
		Case (cAliasABB)->TDV_TPDIA == "N" ; cDscTip := STR0019		// "Nao Trabalhado"
		Case (cAliasABB)->TDV_TPDIA == "E" ; cDscTip := STR0020		// "Hora Extra"
		OtherWise 								; cDscTip := ""
	EndCase	
		
	aAdd( aAtend, { (cAliasABB)->TDV_GRUPO,;							// Grupo 
					  StoD((cAliasABB)->ABB_DTINI),;					// Data
					  DiaSemana(StoD((cAliasABB)->ABB_DTINI)),; 		// Dia da Semana
					  (cAliasABB)->ABB_HRINI,; 							// Horario Inicial
					  (cAliasABB)->ABB_HRFIM,;							// Horario Final
					  (cAliasABB)->ABB_CODTEC,;							// Código do atendente
					  (cAliasABB)->AA1_NOMTEC,; 						// Nome do Atendente
					  (cAliasABB)->TDV_TPDIA,;							// Tipo do dia trabalhado
					  cDscTip,; 											// Descrição do dia trabalhado
					  (cAliasABB)->ABB_CODIGO,;							// Código da Agenda do atendente
					  (cAliasABB)->ABB_ATENDE,;							// Se agenda foi atendida
					  (cAliasABB)->TDV_TURNO,;							// Turno do atendente
					  (cAliasABB)->TDV_SEQTRN,;							// Sequencia do turno do atendente
					  {}, Len(aAtend)+1,;								// Dados para a tabela TDV
					  StoD((cAliasABB)->TDV_DTREF),;					// Data de referencia
					  "",;													//chave para posicionamento TGY	(TGY_ESCALA + TGY_CODTDX + TGY_CODTFF)
					  "",;													//Item TGY
					  (cAliasABB)->ABB_MANUT } )						//Agenda com manutenção				


					  					  
	nLenAte := Len(aAtend) 					  					  
			
	aAdd( aAtend[nLenAte,14], { (cAliasABB)->TDV_CODABB,;
									StoD((cAliasABB)->TDV_DTREF),;
									(cAliasABB)->TDV_TURNO,;
									(cAliasABB)->TDV_SEQTRN,;
									(cAliasABB)->TDV_TPEXT,;
									(cAliasABB)->TDV_TPEXTN,;
									(cAliasABB)->TDV_NONHOR,;
									(cAliasABB)->TDV_CODREF,;
									(cAliasABB)->TDV_INSREP,;
									(cAliasABB)->TDV_TPDIA,;
									Nil,;											
									(cAliasABB)->TDV_INTVL1,;
									(cAliasABB)->TDV_INTVL2,; 
									(cAliasABB)->TDV_INTVL3,;
									(cAliasABB)->TDV_FERIAD,;
									(cAliasABB)->TDV_FTPEXT,;
									(cAliasABB)->TDV_FEXTN,;
									(cAliasABB)->TDV_HRMEN,;
									(cAliasABB)->TDV_HRMAI,;
									(cAliasABB)->TDV_GRUPO,;
									If(lSum444, (cAliasABB)->TDV_FERSAI, ""),;
									If(lSum444, (cAliasABB)->TDV_FSTPEX, ""),;
									If(lSum444, (cAliasABB)->TDV_FSEXTN, "");
									 } )			  										

	(cAliasABB)->(dbSkip())
 
EndDo

aSort( aAtend, Nil, Nil, { |x,y| DtoS(x[02])+x[4] < DtoS(y[02])+y[4] } )

aAteEfe := aAtend

(cAliasABB)->(dbCloseArea())

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AFil
Filtro para o grid da agenda dos atendentes

@sample 	At330AFil( oPanel, oView )

@param		oPanel - Painel onde deverá ser criado e exibido o botão
	
@return	Nil 
@author	Serviços
@since		10/07/2014       
@version	P12 
/*/
//------------------------------------------------------------------------------
Function At330AFil( oPanel, oView )

Local oMdlFull := oView:GetModel()

Local oFonte
Local oCombo, cCombo

If (FindFunction("At580bAt") .And. TecHasPerg("MV_PAR05","TEC580BE")) .And. !Empty(MV_PAR05)
	aFilAte := At580bEsc(aFilAte,"1")
EndIf

DEFINE FONT oFonte NAME "Arial" BOLD 

@ 014,005 SAY STR0021 SIZE 50, 08 OF oPanel Pixel FONT oFonte	//"Filtro por Grupo"

oCombo := TComboBox():New(022,005,{|u|if(PCount()>0,cCombo:=u,cCombo)},;
                         aFilGrp,55,10,oPanel,,{||At330AMFil(1,oMdlFull,cCombo)};
                         ,,,,.T.,,,,,,,,,"cCombo")
                         
@ 014,075 SAY STR0022 SIZE 80, 08 OF oPanel Pixel FONT oFonte	//"Filtro por Atendente" 

oCombo := TComboBox():New(022,075,{|u|if(PCount()>0,cCombo:=u,cCombo)},;
                         aFilAte,145,10,oPanel,,{||At330AMFil(2,oMdlFull,cCombo)};
                         ,,,,.T.,,,,,,,,,"cCombo")                         
                         
Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AStru
Carrega as estruturas para os grids da alocação

@sample 	At330AStru( oStruct, cTipo, lView )

@param		oStruct - Estrutura a ser alterada com os novos campos
@param		oPanel - Painel onde deverá ser criado e exibido o botão
@param		oPanel - Painel onde deverá ser criado e exibido o botão
	
@return	Nil 
@author	Serviços
@since		10/07/2014       
@version	P12   admin	
/*/
//------------------------------------------------------------------------------
Function At330AStru( lEstr, oStruct, cTipo, lModel,oModel )
Local aCols := {}
Local xRet
Local nTamKeyTGY := 0
Local nTamItTGY := 0
Local aAux := {}
Local nI := 1
Local nLenAteAge := 0 
Local cApeAge := MV_PAR03
Local cApeFol := MV_PAR04
Local aPosFlds := {} 
Local lRestrRH := .F.
Local nPosdIni := AScan(aCfltHead,{|e| e == 'DTINI'})
Local nPosdFim := AScan(aCfltHead,{|e| e == 'DTFIM'})
Local nPosHrIni := AScan(aCfltHead,{|e| e == 'HRINI'})
Local nPosHrFim := AScan(aCfltHead,{|e| e == 'HRFIM'})
Local nPos := 0
Local nHrIni := 0
Local nHrFim := 0
Local nHrIniAge := 0
Local nHrFimAge := 0
Local lGSVERHR := SuperGetMV("MV_GSVERHR",,.F.)
Local nAddZZX := 0
Local nAddABB := 0 
Local nLastPos := 0 //Ultima posicao da agenda localizada
Local lProcessa := .T.
Local lResRHTXB	:= TableInDic("TXB") //Restrições de RH
Local nTXBDtIni := 0
Local nTXBDtFim := 0
Default oStruct := Nil
Default cTipo   := "TFF"
Default lModel  := .T.
Default oModel := Nil

If lEstr
	nLenAteAge := Len(aAteAgeSt)

	xRet := {}				
	If nLenAteAge > oModel:GetMaxLines()
		oModel:SetMaxLines(nLenAteAge)
	EndIf

	If lResRHTXB
		nTXBDtIni := AScan(aCfltHead,{|e| e == 'TXB_DTINI'})
		nTXBDtFim := AScan(aCfltHead,{|e| e == 'TXB_DTFIM'})
	Endif

	aPosFlds := oModel:GetStruct():GetArrayPos({'ZZX_SITABB',; //[1]
							   'ZZX_SITALO',; 	  //[2]
							   'ZZX_GRUPO',; 	  //[3]
							   'ZZX_DATREF',;     //[4]
							   'ZZX_DATA',;       //[5]
							   'ZZX_SEMANA',;     //[6]
							   'ZZX_ENTRADA',;    //[7]
							   'ZZX_SAIDA',;      //[8]
							   'ZZX_ATEND',;      //[9]
							   'ZZX_NOME',;       //[10]
							   'ZZX_TIPO',;       //[11]
							   'ZZX_ATEAGE',;     //[12]
							   'ZZX_CODABB',;     //[13]
							   'ZZX_TURNO',;      //[14]
							   'ZZX_SEQ',;        //[15]
							   'ZZX_ITEM',;       //[16]
							   'ZZX_KEYTGY',;     //[17]
							   'ZZX_ITTGY',;	  //[18]
							   'ZZX_EXSABB'})  	  //[19]	
							
    nLenFlds := Len(aPosFlds)			

	For nI:=1 To nLenAteAge
		lRestrRH := .F.
		// Verifica o parametro para exibição da agenda
		If cApeAge <> 3 // Todas	
			If (cApeAge == 1 .And.  Empty(aAteAgeSt[nI,10])) .Or. ; // Geradas 
			   (cApeAge == 2 .And. !Empty(aAteAgeSt[nI,10])) // Não Geradas
				Loop
			EndIf				
		EndIf
		
		// Verifica o parametro para exibicao da folga
		If cApeAge <> 1 .And. cApeFol == 2 // Geradas # Apresenta folgas = Nao
			If Upper(AllTrim(aAteAgeSt[nI,04])) == "FOLGA" .Or. ;
			   Upper(AllTrim(aAteAgeSt[nI,05])) == "FOLGA"
				Loop
			EndIf		   
		EndIf
		
		aAux := Array(nLenFlds)
		
		If nGrpFil > 0 .And. nGrpFil <> aAteAgeSt[nI,01] // Filtros VERIFICAR
			Loop
		EndIf
		
		If !Empty(cAteFil) .And. cAteFil <> aAteAgeSt[nI,06]
			Loop
		EndIf	
		
		If Len(xRet) > 0
			If Ascan(xRet, {|x| x[2,9] == aAteAgeSt[nI,06] .And. x[2,5] == aAteAgeSt[nI,02] .And. x[2,7] == aAteAgeSt[nI,04] .And.  x[2,8] == aAteAgeSt[nI,05] .And. x[2,11] == aAteAgeSt[nI,08] }) > 0
				Loop
			EndIf
		EndIf
		
		If !lRestrRH .And. Len(aDiasFer) > 0  
			nPos := Ascan(aDiasFer,{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND. aAteAgeSt[nI,2] >= x[2] .And. aAteAgeSt[nI,2] <= x[3] } )
			
			lRestrRH :=  nPos > 0
		EndIf
		
		If !lRestrRH .And. Len(aDiasFer2) > 0  
			nPos := Ascan(aDiasFer2,{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND. aAteAgeSt[nI,2] >= x[2] .And. aAteAgeSt[nI,2] <= x[3] } )
			lRestrRH :=  nPos > 0
		EndIf  
		
		If !lRestrRH .And. Len(aDiasFer3) > 0  
			nPos := Ascan(aDiasFer3,{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND. aAteAgeSt[nI,2] >= x[2] .And. aAteAgeSt[nI,2] <= x[3] } )
			
			lRestrRH := nPos > 0
		EndIf  
		
		
		If !lRestrRH .And. Len(aDiasDem) > 0  
			nPos := Ascan(aDiasDem,{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND.  aAteAgeSt[nI,2] >= x[2] } )
			lRestrRH := nPos > 0
		EndIf
		
		If !lRestrRH .And. Len(aDiasAfast) > 0  
			nPos := Ascan(aDiasAfast,{|x| Alltrim(x[1]) == Alltrim(aAteAgeSt[nI,06]) .AND. aAteAgeSt[nI,2] >= x[2] .And. (aAteAgeSt[nI,2] <= x[3] .Or. Empty(x[3]) )  } )
			lRestrRH := nPos > 0
		EndIf

		If !lRestrRH .And. Len(ACFLTATND) > 0 .And. lResRHTXB
			nPos := Ascan(ACFLTATND,{|x| Alltrim(x[2]) == Alltrim(aAteAgeSt[nI,06]) .AND. !Empty(x[nTXBDtIni]) .AND. aAteAgeSt[nI,2] >= sTod(x[nTXBDtIni]) .And. ( Empty(x[nTXBDtFim]) .Or. aAteAgeSt[nI,2] <= sTod(x[nTXBDtFim]) ) } )
			lRestrRH := nPos > 0
		ENdif

		If !lRestrRH .And. Len(ACFLTATND) > 0  
			nLastPos := 0
			nHrIniAge := VAL(AtJustNum(aAteAgeSt[nI,04]))
			nHrFimAge := VAL(AtJustNum(aAteAgeSt[nI,05]))	
			nAddZZX := IIF(nHrIniAge >= nHrFimAge, 2400,0)	
			lProcessa := .T.
					
			Do While lProcessa
				nLastPos++
				nPos := Ascan(ACFLTATND,{|x| Alltrim(x[2]) == Alltrim(aAteAgeSt[nI,06]) .And. (aAteAgeSt[nI,2] == x[nPosdIni] .Or.  aAteAgeSt[nI,2] == x[nPosdFim] )}, nLastPos )
				nLastPos := nPos
				If nPos > 0				
					lRestrRH := .T.				
					aAux[aPosFlds[19]] := "1"		
					
						//Agenda não atendida
					If ( Empty(aAteAgeSt[nI,10]) .OR. aAteAgeSt[nI,11] <> '1') .AND.  ;
						lRestrRH .And. lGSVERHR .And. (Upper(AllTrim(aAteAgeSt[nI,04])) <> "FOLGA" .And. Upper(AllTrim(aAteAgeSt[nI,05])) <> "FOLGA") 					
						nHrIni := VAL(AtJustNum(ACFLTATND[nPos,nPosHrIni]))
						nHrFim := VAL(AtJustNum(ACFLTATND[nPos,nPosHrFim]))
																
						If nHrFim <= nHrIni  
							nAddABB := 2400
						Else
							nAddABB := 0
						EndIf 
						
						If 	( nHrIniAge >= nHrIni .AND.;
								nHrIniAge <= ( nHrFim + nAddABB ) ) ;
									.OR.;
							( ( nHrFimAge  + nAddZZX ) >= nHrIni .AND.;
								( nHrFimAge  + nAddZZX ) <= (nHrFim + nAddABB ));
									.OR.;
							( nHrIniAge <= nHrIni .AND.;
								( nHrFimAge + nAddZZX ) >= ( nHrFim + nAddABB ) )
							lRestrRH := .T.
							aAux[aPosFlds[19]] := "1"	
							lProcessa := .F.					
						Else
							lRestrRH := .F.
							aAux[aPosFlds[19]] := "2"
							//Procura o próximo horário do dia
						EndIf
					Else
						If (Upper(AllTrim(aAteAgeSt[nI,04])) == "FOLGA" .And. Upper(AllTrim(aAteAgeSt[nI,05])) == "FOLGA")
							lRestrRH := .F.
							aAux[aPosFlds[19]] := "2"
						EndIf
						lProcessa := .F.					
					EndIf				
				Else		
					aAux[aPosFlds[19]] := "2"
					lProcessa := .F.
				EndIf
			End 
		Else			
			aAux[aPosFlds[19]] := "2"
		EndIf
		
		aAux[aPosFlds[1]] := At330ACLgA( !Empty(aAteAgeSt[nI,10]), aAteAgeSt[nI,11], (aAteAgeSt[nI,19]=="1"), lRestrRH  ) //ZZX_SITABB				
		aAux[aPosFlds[2]] := At330ACLgS(aAteAgeSt[nI,8]) //ZZX_SITALO
		aAux[aPosFlds[3]] := aAteAgeSt[nI,01] 			 //ZZX_GRUPO
		aAux[aPosFlds[4]] := aAteAgeSt[nI,16]		  	 //ZZX_DATREF
		aAux[aPosFlds[5]] := aAteAgeSt[nI,02]            //ZZX_DATA
		aAux[aPosFlds[6]] := aAteAgeSt[nI,03]            //ZZX_SEMANA
		aAux[aPosFlds[7]] := aAteAgeSt[nI,04]            //ZZX_ENTRADA
		aAux[aPosFlds[8]] := aAteAgeSt[nI,05]            //ZZX_SAIDA
		aAux[aPosFlds[9]] := aAteAgeSt[nI,06]            //ZZX_ATEND
		aAux[aPosFlds[10]] := aAteAgeSt[nI,07]           //ZZX_NOME
		aAux[aPosFlds[11]] := aAteAgeSt[nI,08]           //ZZX_TIPO
		aAux[aPosFlds[12]] := aAteAgeSt[nI,11]			 //ZZX_ATEAGE
		aAux[aPosFlds[13]] := aAteAgeSt[nI,10]           //ZZX_CODABB
		aAux[aPosFlds[14]] := aAteAgeSt[nI,12]           //ZZX_TURNO
		aAux[aPosFlds[15]] := aAteAgeSt[nI,13]           //ZZX_SEQ
		aAux[aPosFlds[16]] := aAteAgeSt[nI,15]           //ZZX_ITEM
		aAux[aPosFlds[17]] := aAteAgeSt[nI,17]           //ZZX_KEYTGY
		aAux[aPosFlds[18]] := aAteAgeSt[nI,18]           //ZZX_ITTGY
		Aadd(xRet, {nI,aAux})
	Next nI
	If Len(xRet) == 0
		aAux := Array(nLenFlds)
		aAux[aPosFlds[1]] := "BR_VERDE"
		aAux[aPosFlds[2]] := "BR_VERDE"
		aAux[aPosFlds[3]] := 0
		aAux[aPosFlds[4]] := CTod('')
		aAux[aPosFlds[5]] := CTod('')
		aAux[aPosFlds[6]] := ""
		aAux[aPosFlds[7]] := ""
		aAux[aPosFlds[8]] := ""
		aAux[aPosFlds[9]] := ""
		aAux[aPosFlds[10]] := ""
		aAux[aPosFlds[11]] := ""
		aAux[aPosFlds[12]] := ""
		aAux[aPosFlds[13]] := ""
		aAux[aPosFlds[14]] := ""
		aAux[aPosFlds[15]] := ""
		aAux[aPosFlds[16]] := ""
		aAux[aPosFlds[17]] := ""
		aAux[aPosFlds[18]] := ""
		aAux[aPosFlds[19]] := "2"
		Aadd(xRet, {1,aAux})
	EndIf
	
					 
Else 

	If lModel
		
		/* Estutura para a criação de campos no model
	
			[01] C Titulo do campo
			[02] C ToolTip do campo
			[03] C identificador (ID) do Field
			[04] C Tipo do campo
			[05] N Tamanho do campo
			[06] N Decimal do campo
			[07] B Code-block de validação do campo
			[08] B Code-block de validação When do campo
			[09] A Lista de valores permitido do campo
			[10] L Indica se o campo tem preenchimento obrigatório
			[11] B Code-block de inicializacao do campo
			[12] L Indica se trata de um campo chave
			[13] L Indica se o campo pode receber valor em uma operação de update.
			[14] L Indica se o campo é virtual
	                    	
		*/  
	
		If cTipo == "TFF"
		
			oStruct:AddField( STR0023, STR0023, "TFF_DATINI", "D", 8, 0, Nil, Nil, Nil, Nil,;  // "Alocação de"
								Nil, Nil, .F., .T. )
			
			oStruct:AddField( STR0024, STR0024, "TFF_DATFIM", "D", 8, 0, Nil, Nil, Nil, Nil,; // "Alocação Ate"
			                    		Nil, Nil, .F., .T. )
			
			oStruct:AddField( STR0025, STR0025, "TFF_DSCABS", "C", 50, 0, Nil, Nil, Nil, Nil,; // "Descrição"
			                    		Nil, Nil, .F., .T. )
		
		ElseIf cTipo == "TGY"
		
			// Legenda do Status de Alocação
			oStruct:AddField( STR0079, STR0079, "TGYSTATUS", "BT", 1, 0, {||At330ALgSt()}, Nil, Nil,.F.,;
								{||At330ALgGS()}, Nil, Nil, .T., Nil ) //"Alocação"

			oStruct:AddField( STR0026, STR0026, "TGY_TIPO", "C", 12, 0, Nil, Nil, Nil, Nil,; // "Tipo" # "Efetivo" # "Cobertura"
			                    		Nil, Nil, .F., .T. )
		
		ElseIf cTipo == "ZZX"
		
			nTamKeyTGY := TamSX3("TGY_ESCALA")[1] + TamSX3("TGY_CODTDX")[1] + TamSX3("TGY_CODTFF")[1]
			nTamItTGY := TamSX3("TGY_ITEM")[1]
			
			// Legenda de agenda gerada
			oStruct:AddField( STR0027, STR0027, "ZZX_SITABB", "BT", 1, 0, {||At330AGtLA()}, Nil, Nil,.F.,;
								{||At330ACLgA()}, Nil, Nil, .T., Nil ) //"Agenda"
			
			// Legenda do tipo da alocação
			oStruct:AddField( STR0028, STR0028, "ZZX_SITALO", "BT", 1, 0, {||At330AGtLS()}, Nil, Nil,.F.,;
								{||At330ACLgS()}, Nil, Nil, .T., Nil ) //"Status"
		
			oStruct:AddField( STR0029, STR0029, "ZZX_GRUPO", "N", 3, 0, Nil, Nil, Nil, Nil,;  // "Grupo"
								Nil, Nil, .F., .T. )

			oStruct:AddField( STR0030, STR0030, "ZZX_DATREF", "D", 8, 0, Nil, Nil, Nil, Nil,;  // "Dt.Referência"
								Nil, Nil, .F., .T. )
		
			oStruct:AddField( STR0031, STR0031, "ZZX_DATA", "D", 8, 0, Nil, Nil, Nil, Nil,;  // "Data"
								Nil, Nil, .F., .T. )

			oStruct:AddField(	STR0032, STR0032, "ZZX_SEMANA", "C", 14, 0, Nil, Nil,;	// "Semana" 
								Nil, Nil, Nil, Nil, Nil, .T. )
								
			oStruct:AddField(	STR0033, STR0033, "ZZX_ENTRADA", "C", 8, 0, Nil, Nil, Nil, Nil,; // "Entrada"
								Nil, Nil, Nil, .F. )			
								
			oStruct:AddField(	STR0034, STR0034, "ZZX_SAIDA", "C", 8, 0, Nil, Nil, Nil, Nil,; // "Saida"
								Nil, Nil, Nil, .F. )
	
			oStruct:AddField(	STR0035, STR0035, "ZZX_ATEND", "C", nTamCdAte, 0, Nil, Nil, Nil, Nil,; // "Cod. Atend"
								{||At330ACLgA()}, Nil, Nil, .F. )
								
			oStruct:AddField(	STR0036, STR0036, "ZZX_NOME", "C", 30, 0, Nil, Nil, Nil, Nil,; // "Nome Atend."
								Nil, Nil, Nil, .T. )
			
			//"S=Trabalhado", "C=Compensado", "D=D.S.R.", "E=Hora Extra", "I=Intervalo", "N=Nao Trabalhado"
			oStruct:AddField(	STR0037, STR0037, "ZZX_TIPO", "C", 1, 0, Nil, Nil, { "S="+STR0016, "C="+STR0017, "D="+STR0018,; 
								"E="+STR0020, "I="+STR0046, "N="+STR0019 }, Nil,; // "Tipo"
								Nil, Nil, Nil, .F. )
																			
			oStruct:AddField(	STR0038, STR0038, "ZZX_ATEAGE", "C", 1, 0, Nil, Nil, Nil, Nil,; // "Atendeu"
								Nil, Nil, Nil, .T. )
								
			oStruct:AddField(	STR0039, STR0039, "ZZX_CODABB", "C", 12, 0, Nil, Nil, Nil, Nil,; // "Cod. Agenda"
								Nil, Nil, Nil, .T. )
								
			oStruct:AddField(	STR0040, STR0040, "ZZX_TURNO", "C", 3, 0, Nil, Nil, Nil, Nil,; // "Turno"
								Nil, Nil, Nil, .T. )
								
			oStruct:AddField(	STR0041, STR0041, "ZZX_SEQ", "C", 2, 0, Nil, Nil, Nil, Nil,; // "Sequencia"
								Nil, Nil, Nil, .T. )
								
			oStruct:AddField(	STR0042, STR0042, "ZZX_ITEM", "N", 6, 0, Nil, Nil, Nil, Nil,; // "Item"
								Nil, Nil, Nil, .T. )	
									
			oStruct:AddField(	"", "", "ZZX_KEYTGY", "C", nTamKeyTGY, 0, Nil, Nil, Nil, Nil,; // "KeyTGY"
								Nil, Nil, Nil, .T. )
								
			oStruct:AddField(	"", "", "ZZX_ITTGY", "C", nTamItTGY, 0, Nil, Nil, Nil, Nil,; // "KeyTGY"
								Nil, Nil, Nil, .T. )					
								
			oStruct:AddField(	"", "", "ZZX_EXSABB", "C", 1, 0, Nil, Nil, Nil, Nil,; 
								Nil, Nil, Nil, .T. )										
								
																																																																																
		
		EndIf	                    		
			
	Else
	
	
		/* Estutura para a criação de campos na view	
		
			[01] C Nome do Campo
			[02] C Ordem
			[03] C Titulo do campo  
			[04] C Descrição do campo  
			[05] A Array com Help
			[06] C Tipo do campo
			[07] C Picture
			[08] B Bloco de Picture Var
			[09] C Consulta F3
			[10] L Indica se o campo é editável
			[11] C Pasta do campo
			[12] C Agrupamento do campo
			[13] A Lista de valores permitido do campo (Combo)
			[14] N Tamanho Maximo da maior opção do combo
			[15] C Inicializador de Browse
			[16] L Indica se o campo é virtual
			[17] C Picture Variável
	
		*/
	
		If cTipo == "TFF"
		
			oStruct:AddField( "TFF_DATINI", "01", STR0023, STR0023, Nil, "D", "@!", NIL, "", .F.,; // "Alocação de" 
								NIL	, NIL, NIL, NIL, NIL, .T., NIL )
								
			oStruct:AddField( "TFF_DATFIM", "02", STR0024, STR0024, Nil, "D", "@!", NIL, "", .F.,; // "Alocação Ate" 
								NIL	, NIL, NIL, NIL, NIL, .T., NIL )
								
			oStruct:AddField( "TFF_DSCABS", "04", STR0025, STR0025, Nil, "C", "@!", NIL, "", .F.,;		// "Descrição" 
								NIL	, NIL, NIL, NIL, NIL, .T., NIL )
								
			// Ordena a visualização correta do cabecalho da alocacao
			oStruct:SetProperty( "TFF_LOCAL"	, MVC_VIEW_ORDEM, "03" )
			oStruct:SetProperty( "TFF_CONTRT"	, MVC_VIEW_ORDEM, "05" )
			oStruct:SetProperty( "TFF_PRODUT"	, MVC_VIEW_ORDEM, "06" )
			oStruct:SetProperty( "TFF_DESCRI"	, MVC_VIEW_ORDEM, "07" )
			oStruct:SetProperty( "TFF_ESCALA"	, MVC_VIEW_ORDEM, "08" )
			oStruct:SetProperty( "TFF_NOMESC"	, MVC_VIEW_ORDEM, "09" )									
	
		ElseIf cTipo == "TGY"
	
			oStruct:AddField( "TGYSTATUS", "01", STR0079, STR0079, {}, "BT", "", Nil, Nil, .T.,;
								 "", Nil, Nil, Nil, Nil, .T., Nil ) // "Alocação"


			oStruct:AddField( "TGY_TIPO", "02", STR0026, STR0026, Nil, "C", "", NIL, "", .F.,;		// "Tipo" 
								NIL	, NIL, Nil, NIL, NIL, .T., NIL )
	
			// Ordena a visualização correta do grid de atendentes da escala
			oStruct:SetProperty( "TGY_GRUPO"	, MVC_VIEW_ORDEM, "01" )
			oStruct:SetProperty( "TGY_TURNO"	, MVC_VIEW_ORDEM, "03" )
			oStruct:SetProperty( "TGY_DESC"		, MVC_VIEW_ORDEM, "04" )
			oStruct:SetProperty( "TGY_SEQ"		, MVC_VIEW_ORDEM, "05" )
			oStruct:SetProperty( "TGY_ATEND"	, MVC_VIEW_ORDEM, "06" )
			oStruct:SetProperty( "TGY_NOME"		, MVC_VIEW_ORDEM, "07" )
			oStruct:SetProperty( "TGY_DTINI"	, MVC_VIEW_ORDEM, "08" )
			oStruct:SetProperty( "TGY_DTFIM"	, MVC_VIEW_ORDEM, "09" )
			oStruct:SetProperty( "TGY_ULTALO"	, MVC_VIEW_ORDEM, "10" )										
						
		ElseIf cTipo == "ZZX"
		
			oStruct:AddField( "ZZX_SITABB", "01", STR0027, STR0027, {}, "BT", "", Nil, Nil, .T.,;
								 "", Nil, Nil, Nil, Nil, .T., Nil ) // "Agenda"
			
			oStruct:AddField( "ZZX_SITALO", "02", STR0028, STR0028, {}, "BT", "", Nil, Nil, .F.,;
								 "", Nil, Nil, Nil, Nil, .T., Nil ) // "Status"
			
			oStruct:AddField( "ZZX_GRUPO", "03", STR0029, STR0029, Nil, "N", "@E 999", NIL, "", .F.,;		// "Grupo" 
								NIL	, NIL, NIL, NIL, NIL, .T., NIL )	
		
			oStruct:AddField( "ZZX_DATREF", "04", STR0030, STR0030, Nil, "D", "@!", NIL, "", .F.,; // "Dt.Referência" 
								NIL	, NIL, NIL, NIL, NIL, .T., NIL )
		
			oStruct:AddField( "ZZX_DATA", "05", STR0031, STR0031, Nil, "D", "@!", NIL, "", .F.,; // "Data" 
								NIL	, NIL, NIL, NIL, NIL, .T., NIL )	
	
			oStruct:AddField( "ZZX_SEMANA", "06", STR0032, STR0032, Nil, "C", "", NIL, "", .F.,;		// "Semana" 
								NIL	, NIL, Nil, NIL, NIL, .T., NIL )									
								
			oStruct:AddField( "ZZX_ENTRADA", "07", STR0033, STR0033, Nil, "C", "@!", NIL, "", .F.,;		// "Entrada" 
								NIL	, NIL, NIL, NIL, NIL, .F., NIL )
								
			oStruct:AddField( "ZZX_SAIDA", "08", STR0034, STR0034, Nil, "C", "@!", NIL, "", .F.,;		// "Saida" 
								NIL	, NIL, NIL, NIL, NIL, .F., NIL )
								
			oStruct:AddField( "ZZX_ATEND", "09", STR0035, STR0035, Nil, "C", "@!", NIL, "AA1ABB", .F.,;		// "Cod. Atend" 
								NIL	, NIL, Nil, NIL, NIL, .F., NIL )
								
			oStruct:AddField( "ZZX_NOME", "10", STR0036, STR0036, Nil, "C", "@!", NIL, "", .F.,;		// "Nome Atend." 
								NIL	, NIL, Nil, NIL, NIL, .T., NIL )

			//"S=Trabalhado", "C=Compensado", "D=D.S.R.", "E=Hora Extra", "I=Intervalo", "N=Nao Trabalhado"
			oStruct:AddField( "ZZX_TIPO", "11", STR0037, STR0037, Nil, "C", "", NIL, "", .F.,;		// "Tipo" 
								NIL	, NIL, { "S="+STR0016, "C="+STR0017, "D="+STR0018,; 
								"E="+STR0020, "I="+STR0046, "N="+STR0019 }, NIL, NIL, .F., NIL )																	
		
		EndIf
		
	EndIf	
		
EndIf	

Return(xRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At330AGtLA			   
Cria as informações referentes a legenda da agenda gerada pela ABB.

@sample 	At330AGtLA()

@author  	Serviços
@since 	  	16/07/2014
@version 	P12

@return 	lRet: Retorna .T. quando a criação foi bem sucedida.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330AGtLA()	
		  
Local	oLegABB := FwLegend():New() 

If	lLegend
	oLegABB:Add( "", "BR_VERMELHO", STR0043 )		//"Agenda Gerada"
	oLegABB:Add( "", "BR_AMARELO" , STR0044 )		//"Agenda Atendida"
	oLegABB:Add( "", "BR_VERDE"	  , STR0045 )		//"Agenda Não Gerada"
	oLegABB:Add( "", "BR_LARANJA" , STR0075 )		//"Agenda com Manutenção"
	oLegABB:Add( "", "BR_PRETO"	  , STR0077 )		//"Conflito de Alocação"
	oLegABB:Add( "", "BR_PINK"	  , STR0109 )       //"Agenda Reserva Técnica"
	oLegABB:Add( "", "BR_AZUL"	  , STR0110 )       //"Sem convocação"
	oLegABB:View()
	DelClassIntf()		
EndIf
                                                                                                                                          
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At330ALgSt
Cria as informações referentes a legenda de conflitos de alocação do Atendente (RH).

@sample 	At330ALgSt()

@author  	Serviços
@since 	  	18/05/2015
@version 	P12

@return 	lRet: Retorna .T. quando a criação foi bem sucedida.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330ALgSt()
		  
Local	oLegTDY := FwLegend():New()

If	lLegend
	oLegTDY:Add( "", "BR_VERDE"		, STR0080 )	//"Atendente Sem conflito de Alocação"
	oLegTDY:Add( "", "BR_VERMELHO"	, STR0081 )	//"Atendente Com Demissão no Período"
	oLegTDY:Add( "", "BR_AZUL"		, STR0082 )	//"Atendente Com Férias no Período"
	oLegTDY:Add( "", "BR_AMARELO"	, STR0083 )	//"Atendente Com Afastamento no Período"
	oLegTDY:Add( "", "BR_CINZA"		, STR0089 )	//"Atendente Com Curso Vencido"
	oLegTDY:Add( "", "BR_LARANJA"	, STR0098 )	//"Atendente com restrição operacional de aviso."
	oLegTDY:Add( "", "BR_PRETO"		, STR0099 )	//"Atendente com restrição operacional para o local/cliente"
	oLegTDY:View()
	DelClassIntf()		
EndIf
                                                                                                                                          
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At330AGtLS			   
Cria as informações referentes a legenda do status do dia trabalhado no grid.

@sample 	At330AGtLS()

@author  	Serviços
@since 	  	16/07/2014
@version 	P12

@return 	lRet: Retorna .T. quando a criação foi bem sucedida.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330AGtLS()

Local oLegSTA := FwLegend():New()

If	lLegend
	oLegSTA:Add( "", "BR_VERDE"   , STR0016 )		//"Trabalhado"
	oLegSTA:Add( "", "BR_AMARELO" , STR0017 )		//"Compensado"
	oLegSTA:Add( "", "BR_AZUL"	  , STR0018 )		//"D.S.R."
	oLegSTA:Add( "", "BR_LARANJA" , STR0020 )		//"Hora Extra"
	oLegSTA:Add( "", "BR_PRETO"   , STR0046 )		//"Hora Extra"
	oLegSTA:Add( "", "BR_VERMELHO", STR0019 )		//"Não Trabalhado"
			
	oLegSTA:View()
	DelClassIntf()	
EndIf
                                                                                                                                          
Return(.T.)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At330ALgGS
Atribui a cor nas legendas do grid de Rel. Escala x Func. Efetivo.

@sample 	At330ALgGS()

@author  	Serviços
@since 	  	18/05/2015
@version	P12

@return 	cRet: Cor da legenda conforme a configuração do efetivo
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330ALgGS( lDemis, lAfast, lFerias,lCursoVenc,cTipoRest )		  
Local cRet := ""

Default lDemis := .F.
Default lAfast := .F.
Default lFerias := .F.
Default lCursoVenc:= .F. 

If lDemis
	cRet := "BR_VERMELHO"
ElseIf lAfast
	cRet := "BR_AMARELO"
ElseIf lFerias
	cRet := "BR_AZUL"
ElseIf lCursoVenc
	cRet := "BR_CINZA"	
ElseIf cTipoRest == '1' // aviso de restricao
	cRet := "BR_LARANJA"
ElseIf cTipoRest == '2' // bloqueio de restricao
	cRet := "BR_PRETO"
Else
	cRet := "BR_VERDE"	
EndIf
	
Return(cRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At330ACLgA 
Atribui a cor nas legendas do grid de atendentes.

@sample 	At330ACLgA()

@author  	Serviços
@since 	  	16/07/2014
@version	P12

@return 	cRet: Cor da legenda conforme a configuração do efetivo
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330ACLgA( lAgenda, cAtend, lManut, lConflAloc, lResTec  )		  

Local cRet

Default lAgenda 	:= .F.
Default cAtend  	:= ""
Default lManut 		:= .F.
Default lConflAloc 	:= .F.
Default lResTec		:= .F.

If lAgenda
	If cAtend == "1"
		cRet := "BR_AMARELO"
	ElseIf lManut
		cRet := "BR_LARANJA"	
	Else
		cRet := "BR_VERMELHO"
	EndIf
ElseIf lConflAloc
	If lResTec
		cRet := "BR_PINK" // Atendente em reserva técnica
	Else
		cRet := "BR_PRETO"
	EndIf
Else
	cRet := "BR_VERDE"
EndIf
	
Return(cRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At330ACLgS
Atribui a cor nas legendas do grid de atendentes.

@sample 	At330ACLgS()

@author  	Serviços
@since 	  	16/07/2014
@version	P12

@return 	cRet: Cor da legenda conforme a configuração do efetivo
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330ACLgS( cStatus )

Local cRet

Default cStatus := ""
	
If cStatus == "S" 		// Trabalhado
	cRet := "BR_VERDE"
ElseIf cStatus == "C" 	// Compensado
	cRet := "BR_AMARELO"	
ElseIf cStatus == "D" 	// D.S.R.
	cRet := "BR_AZUL"
ElseIf cStatus == "E" 	// Hora Extra
	cRet := "BR_LARANJA"
ElseIf cStatus == "I" 	// Intervalo
	cRet := "BR_PRETO"			
Else 						// Nao Trabalhado
	cRet := "BR_VERMELHO"		 	
EndIf

Return(cRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At330AAgAt				   
Carrega todos atendentes do posto para o periodo de agenda selecionado

@sample 	At330AAgAt( aAteEfe, aAteCob, dDatIni, dDatFim, cEscala, cCalend )

@param		aAteEfe - Lista com as informações dos efetivos
@param		aAteCob - Lista com as informações das coberturas
@param		dDatIni - Data Inicial para a consistencia das agendas
@param		dDatFim - Data Final para a consistencias das agendas
@param		cEscala - Escala a ser utilizada na agenda
@param		cCalend - Calendario de feriados a ser utilizado na agenda
@param		cCodTFF - Codigo da TFF que será gerado a agenda
@param		cFilTFF - Filial da TFF para busca das agendas geradas
@param		lGerConf - Verifica se tem conflito a ser analisado(Via Job)

@author  	Serviços
@since 	  	17/07/2014
@version	P12

@return 	aRet: Lista com os atendentes efetivos e de cobertura para o periodo da agenda 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330AAgAt( aAteEfe, aAteCob, dDatIni, dDatFim, cEscala, cCalend, cCodTFF, cFilTFF,;
					 lGerConf, cCodTec, cCodRota, cSeq, cAtendFlex, lSemEftTrn, cCodRtItem )

Local aTabPadrao 	:= {}
Local aTabCalend 	:= {}
Local aBKPAteEfe	:= {}
Local cFilSR6  		:= xFilial("SR6")
Local aRet 			:= {}
Local aCfgCob   	:= {}
Local aAteABB   	:= {}
Local nPos			:= 0
Local nPosCob		:= 0
Local nPosABB		:= 0
Local nPosAte		:= 0
Local nIntHor		:= 0
Local nHorIni    	:= 0
Local nHorFim    	:= 0
Local nItem			:= 0
Local cTipo      	:= ""
Local cDscTip    	:= ""
Local cHorIni    	:= ""
Local cHorFim    	:= ""
Local cOrdem    	:= ""
Local cIntVl1    	:= ""
Local cIntVl2    	:= ""
Local cIntVl3    	:= ""
Local aArea 		:= GetArea()
Local dUltAloc		:= STOD("")
Local cSeqTrn		:= ""
Local nHorMen		:= 0
Local nHorMai		:= 0

Local nI, nJ, nX, nY, nW, nZ, nLenAte
Local lRetCalend, cTurno, dDatCob, dAteCob, dDataAux
Local dDtCobIni, dDtCobFim

Local nLenAteEfe := Len(aAteEfe)
Local nLenConfl		:= Len(ACFLTATND)
Local nLenTbCalend
Local nLenAteEf2
Local nLenCfgCob
Local aAbbAtend := {}
Local aNewAtend := {}
Local aCalend   := {}
Local aAux := {}
Local nFerPos 	:= 0
Local lSemTela	:= IsBlind()
Local nDeslig	:= 0
Local nAdmiss	:= 0
Local lGerAgenda := .T. //Gera a agenda para a data?
Local lCobFerias := .T. //Gera agenda de cobertura?
Local lTeca190d := isInCallStack("gravaaloc2") .OR. isInCallStack("ProjAloc2") 
Local lGConfJob := SuperGetMV("MV_GSAGCFL", .f., .f.)//Gera agenda de conflito?
Local lAterouSeq := .F.
Local lResRHTXB	:= TableInDic("TXB") //Restrições de RH
Local nTXBDtIni := 0
Local nTXBDtFim := 0
Local lTrfEfet	:= isInCallStack("At190TrEft") //Verifica se a chamada foi feita pela Troca de Efetivo
Local lRealoca	:= isInCallStack("AT190dIMn2") //Verifica se a chamada foi feita pela Realocação
Local cChaveTDW	:= "" //Armazena a chave para verificar a cobertura do efetivo
Local lCob		:= .F. //Verifica se a TFF tem cobertura para realizar as agendas
Local aChaveTDW	:= {} //Array para armazenar as chaves da TDW
Local nPosChave	:= 0 //Utilizada para verificar a posição do array aCfgCob para recuperação
Local cSeqFolga	:= "" //Sequencia a ser considerado quando o atendente estiver de folga
Local lPNMTABC	:= FindFunction("U_PNMSESC") .AND. FindFunction("U_PNMSCAL")
Local lTecPnm	:= FindFunction( "TecExecPNM" ) .AND. TecExecPNM()
Local aExcecoes	:= {}
Local lTecExeFer := lTecPnm .AND.  ExistFunc("TecRwExec")
Local cKeyTGY 	:= "" //Chave da TGY
Local cTurnoAtd := "" //Turno do Atendente
Local lPNMRwExc := FindFunction("U_PNMRwExc")
Local lExceFer  := .F.
Local lExcecao	:= .F.
Local lRplFer   := TDW->( ColumnPos('TDW_RPLFER')) > 0 .And. (Posicione("TDW",1,xFilial("TDW") + cEscala , "TDW_RPLFER") == "1")
Local lRtFolg	:= (isInCallStack("At581Efet") .And. TW0->(ColumnPos("TW0_TIPO")) > 0 .And. (Posicione("TW0",1,xFilial("TW0") + cCodRota , "TW0_TIPO") == "1"))
Local lLdTGY 	:= isInCallStack("a330LdTGY")

Default lGerConf := .F.
Default cFilTFF := xFilial( "TFF", cFilAnt )
Default cCodTec := ""
Default cCodRota:= ""
Default cSeq	:= ""
Default aAtendFlex := ""
Default lSemEftTrn := .F.

If FindFunction("U_PNMLdExc")
	aExcecoes := U_PNMLdExc(cEscala)
ElseIf lTecPnm .AND. ExistFunc("TecLdExce")
	aExcecoes := TecLdExce(cEscala)
EndIf
If lResRHTXB
	nTXBDtIni := AScan(aCfltHead,{|e| e == 'TXB_DTINI'})
	nTXBDtFim := AScan(aCfltHead,{|e| e == 'TXB_DTFIM'})
Endif
	
If !lRtFolg
	aAteABB := At330AVerABB( dDatIni, dDatFim, cCodTFF, cFilTFF, cCodTec )//Informações da Agenda (ABB) Ordenada por Data de Referencia (TDV_DTREF)	
Endif

If !lTrfEfet .And. !lRealoca .AND. !isInCallStack("ProjAloc2")
	//Verifica se a TFF tem cobertura
	lCob := ExistTGZ( cCodTFF, dDatIni )
EndIf

If lSemEftTrn
	aBKPAteEfe	:= ACLONE(aAteEfe)
	GeraAtt(@aAteEfe, cCodRota, cAtendFlex, dDatIni, dDatFim, cEscala, cCodRtItem)
	nLenAteEfe := Len(aAteEfe)
EndIf
	
dbSelectArea("ABB")
ABB->(dbSetOrder(1))

For nI:=1 To nLenAteEfe

	// Ordena as datas a serem consistidas para gerar as informações
	aSort( aAteEfe[nI,4],,, { |x,y| x[1]<y[1] } )
	
	cTurno := aAteEfe[nI,1] 
	//Quando for rota considera a sequencia inicial configurada na rota
	If Empty(cSeq)
		If !Empty(cCodRota)
			cSeq := GetSeqTGZ(cCodRota,cCodTFF)
		Else
			cSeq := aAteEfe[nI,2]
		EndIf
	Else
		If lLdTGY
			cSeq := aAteEfe[nI,2]
		Endif
	EndIf
	If lTeca190d .AND. !EMPTY(aAteABB)
		aAux := ACLONE(aAteABB)
		ASORT(aAux,,, { |x, y| x[1] < y[1] } )
		If dDatIni <= aAux[1][1] .AND. dDatFim > aAux[LEN(aAux)][1]
			cSeq := aAux[1][8]
			lAterouSeq := .T.
		EndIf
	EndIf
	If lPNMTABC
		U_PNMSEsc(cEscala) // informar escala
		U_PNMSCal(cCalend) // informar calendario     
	ElseIf lTecPnm
		TecPNMSEsc( cEscala )
		TecPNMSCal( cCalend )
	EndIf
	lRetCalend := CriaCalend( 	dDatIni    ,;    //01 -> Data Inicial do Periodo
								dDatFim    ,;    //02 -> Data Final do Periodo
								cTurno     ,;    //03 -> Turno Para a Montagem do Calendario
								cSeq       ,;    //04 -> Sequencia Inicial para a Montagem Calendario
								@aTabPadrao,;    //05 -> Array Tabela de Horario Padrao
								@aTabCalend,;    //06 -> Array com o Calendario de Marcacoes  
								cFilSR6    ,;    //07 -> Filial para a Montagem da Tabela de Horario
								Nil, Nil )
                          	
	
                            	
	If lPNMTABC
		U_PNMSEsc(Nil) // Limpar as variaveis estaticas
		U_PNMSCal(Nil) 
	ElseIf lTecPnm
		TecPNMSEsc(Nil)
		TecPNMSCal(Nil)
	EndIf
	If lAterouSeq
		cSeq   := aAteEfe[nI,2]
	EndIf
	
	cOrdem  := Nil
	nIntHor := 0
	nLenTbCalend := Len(aTabCalend)
	
	For nJ:=1 To nLenTbCalend Step 2
	
		nLenAteEf2 := Len(aAteEfe[nI,4])//Quantidade de atendentes dentro da configuração da escala		
		
		// Efetivos
		For nX:=1 To nLenAteEf2 
			
			lGerAgenda := .T.
			nPosAte := 0
			If lSemTela .And. nLenConfl > 0 .AND. (!lGerConf .AND. !lGConfJob)
				//busca o atendente no array de conflitos
				nPosAte := Ascan(ACFLTATND,{|x| x[2] ==  aAteEfe[nI][4][nX][2] })
			EndIf
			
			// Verifica se o atendente esta dentro do periodo			
			If !Empty(aAteEfe[nI,4,nX,3]) .And. !Empty(aAteEfe[nI,4,nX,4])
				If	!( aTabCalend[nJ,CALEND_POS_DATA_APO] >= aAteEfe[nI,4,nX,3] .And. aTabCalend[nJ+1,CALEND_POS_DATA_APO] <= aAteEfe[nI,4,nX,4] ) 				 
					 Loop				 
				Else
					//Validação feita somente para chamadas via Job
					If  nPosAte > 0
						//Se existir data de desligamento, ignora a agenda a partir da data
						nDeslig := 0
						If len(aDiasDem) > 0
							// Verificação para ignorar agenda a partir da data de desligamento
							nDeslig := aScan( aDiasDem, { |x| x[1] == aAteEfe[nI,4,nX,2] .and.  aTabCalend[nJ,CALEND_POS_DATA] >= x[2] } ) 
							If nDeslig > 0
								lGerAgenda := .F.
							EndIf
						EndIf							


						//Se existir conflito de afastamento, gerar apenas para os dias válidos, se o usuário não tiver permissão para gerar agenda com conflito
						If lGerAgenda .AND. Len(aDiasAfast) > 0 
							If aScan( aDiasAfast, { |x| x[1] == aAteEfe[nI,4,nX,2] .AND. aTabCalend[nJ,CALEND_POS_DATA] >=  x[2] .and. aTabCalend[nJ+1,CALEND_POS_DATA] <= x[3] } ) > 0
								lGerAgenda := .F.
							End
						
						EndIf
						
						 //Se existir conflito de férias, gerar apenas para os dias válidos
						 nFerPos := 0
						If lGerAgenda .AND. len(aDiasFer) > 0
							nFerPos := aScan( aDiasFer, { |x| x[1] == aAteEfe[nI,4,nX,2] .AND. aTabCalend[nJ,CALEND_POS_DATA] >= x[2] .And. aTabCalend[nJ+1,CALEND_POS_DATA] <= x[3] } ) 
							If nFerPos > 0	
								lGerAgenda := .F.
							EndIf
						EndIf
						
						nFerPos := 0
						If lGerAgenda .AND. len(aDiasFer2) > 0
							nFerPos := aScan( aDiasFer2, { |x| x[1] == aAteEfe[nI,4,nX,2] .AND. aTabCalend[nJ,CALEND_POS_DATA] >= x[2] .And. aTabCalend[nJ+1,CALEND_POS_DATA] <= x[3] } )
							If nFerPos > 0
								lGerAgenda := .F.
							EndIf
						EndIf
						
						nFerPos := 0
						If lGerAgenda .AND. len(aDiasFer3) > 0
							nFerPos := aScan( aDiasFer3, { |x| x[1] == aAteEfe[nI,4,nX,2] .AND. aTabCalend[nJ,CALEND_POS_DATA] >= x[2] .And. aTabCalend[nJ+1,CALEND_POS_DATA] <= x[3] } )
							If nFerPos > 0
								lGerAgenda := .F.
							EndIf
						EndIf
						
						If lResRHTXB
							If lGerAgenda .AND. len(aCfltAtnd) > 0
								If aScan( aCfltAtnd, { |x| x[1] == aAteEfe[nI,4,nX,2] .AND. aTabCalend[nJ,CALEND_POS_DATA] >= sTod(x[nTXBDtIni]) .And. ( Empty(x[nTXBDtFim]) .Or. aTabCalend[nJ+1,CALEND_POS_DATA] <= sTod(x[nTXBDtFim])) } ) > 0
									lGerAgenda := .F.
								EndIf
							EndIf
						Endif

					EndIf	
				EndIf
			
			ElseIf Empty(aAteEfe[nI,4,nX,4]) // Verifica os atendentes sem data final de atendimento
				If ! aTabCalend[nJ,CALEND_POS_DATA] >= aAteEfe[nI,4,nX,3]
					Loop
				EndIf	
			EndIf
			If lRtFolg
				aCfgCob := {}
			EndIf	
			If (!lSemTela .OR. (lSemTela .AND. lGerAgenda)  ) .AND. aTabCalend[nJ, CALEND_POS_TIPO_MARC] == "1E" .And. (!lRtFolg .Or. (lRtFolg .And. aTabCalend[nJ, CALEND_POS_TIPO_DIA] != 'S')) 	//Incluído trecho para gerar agenda de cobertura	
					
				//Recupera todas agendas já geradas com base na data de referencia
  				aAbbAtend := At330AAbb(aTabCalend[nJ,CALEND_POS_DATA_APO], aAteABB, aAteEfe[nI,4,nX,2])
				//Recupera conjunto de marcações do aTabCalend para o data de referencia				
				aCalend := At330ACal(aTabCalend, nJ)
				If lPNMRwExc
					lExcecao := Len(U_PNMRwExc(aTabCalend[nJ], aExcecoes, ,lRplFer)) >  0
				ElseIf lTecExeFer  
					lExcecao := Len(TecRwExec(aTabCalend[nJ], aExcecoes, ,lRplFer)) >  0
				EndIf
				//Recupera estrutura do atendente  a ser apresentada na alocação
				aNewAtend := getInfoAtend(aAbbAtend, aCalend, aAteEfe[nI,4,nX], cTurno, cSeq, cEscala+aAteEfe[nI][3]+cCodTFF,,,,,,lExcecao,dDatIni,dDatFim)
				//Adiciona itens na estrutura do aAtend					
				For nZ := 1 To Len(aNewAtend)
					nItem++
					aAdd(aAtend, aNewAtend[nZ])	
					aAtend[Len(aAtend)][15] := nItem//Ajusta Item										
				Next nZ

				If (!lTrfEfet .And. !lRealoca) .And. lCob 
					If aAtend[nItem][4] == "FOLGA" .And. aAtend[nItem][5] = "FOLGA"
						cSeqFolga := aTabCalend[nJ,CALEND_POS_SEQ_TURNO]
					Else
						cSeqFolga := aAtend[nItem][13]
					EndIf

					cTurnoAtd := aAtend[nItem][12]
					cSeqTrnAtd := cSeqFolga
					cKeyTGY := aAtend[nItem][17]
				EndIf
				
			ElseIf !lGerAgenda .AND. (!lTrfEfet .And. !lRealoca) .And. lCob  .and. Empty(cCodRota)  .AND. aTabCalend[nJ, CALEND_POS_TIPO_MARC] == "1E"  
				
				cTurnoAtd := cTurno
				cSeqFolga := aTabCalend[nJ,CALEND_POS_SEQ_TURNO]
				cKeyTGY := cEscala+aAteEfe[nI][3]+cCodTFF				
			ElseIf lRtFolg .And. aTabCalend[nJ, CALEND_POS_TIPO_DIA] == 'S'
				cTurnoAtd 	:= ""
				cSeqFolga 	:= ""
				cKeyTGY 	:= ""
			EndIf
			
			If !Empty(cKeyTGY) .AND. !Empty(cTurnoAtd) .AND. !Empty(cSeqFolga)
				If cChaveTDW <> cTurnoAtd+cSeqFolga+cKeyTGY .Or. lRtFolg
					If lRtFolg
						If aTabCalend[nJ, CALEND_POS_TIPO_MARC] == "1E"
							aCfgCob := {}
							aCfgCob := At330ACob(cCodTFF, ACLONE(aTabCalend[nJ]), cEscala, cCodRota, cTurnoAtd, cSeqFolga, cAtendFlex, aExcecoes, lSemEftTrn, @aTabCalend)
							dDatCob := Nil
						Endif
					Else
						cChaveTDW := cTurno+cSeqFolga+cKeyTGY
						If Empty(aChaveTDW)
							// Lista com as coberturas do efetivo
							aCfgCob := {}
							aCfgCob := At330ACob(cCodTFF, ACLONE(aTabCalend[nJ]), cEscala, cCodRota, cTurnoAtd, cSeqFolga, cAtendFlex, aExcecoes, lSemEftTrn, @aTabCalend)
							Aadd(aChaveTDW,{cChaveTDW,aClone(aCfgCob)})
							dDatCob := Nil
						Else
							nPosChave := aScan(	aChaveTDW, { |x| x[1] ==  cChaveTDW } )
							If nPosChave > 0
								aCfgCob := {}
								dDatCob := Nil
								aCfgCob := aClone(aChaveTDW[nPosChave][2])
							Else
								aCfgCob := {}
								aCfgCob := At330ACob(cCodTFF, ACLONE(aTabCalend[nJ]), cEscala, cCodRota, cTurnoAtd, cSeqFolga, cAtendFlex, aExcecoes, lSemEftTrn, @aTabCalend)
								Aadd(aChaveTDW,{cChaveTDW,aClone(aCfgCob)})
								dDatCob := Nil			
							EndIf
						Endif
					EndIf
				EndIf
			EndIf
			
			//Cobertura			
			If (!lRtFolg .And. dDatCob <> aTabCalend[nJ,CALEND_POS_DATA_APO]) .Or. (lRtFolg .And. dDatCob <> aTabCalend[nJ,CALEND_POS_DATA_APO] .And. aTabCalend[nJ, CALEND_POS_TIPO_MARC] == "1E")
			
				dDatCob := aTabCalend[nJ,CALEND_POS_DATA_APO]	

				nPosCob := aScan(	aCfgCob, { |x| x[1] == Str(Dow(aTabCalend[nJ,CALEND_POS_DATA_APO]),1)} )	
				
				If nPosCob > 0
					If lRtFolg
						dDtCobFim := Nil
					Endif
					For nY:=1 To Len(aCfgCob[nPosCob,2])
						

						If  lCob .and. aTabCalend[nJ,CALEND_POS_FERIADO]
							lExceFer := .F. 

							If lPNMRwExc
								lExceFer := Len(U_PNMRwExc(aTabCalend[nJ], aExcecoes, .T.)) >  0
							ElseIf lTecExeFer  
								lExceFer := Len(TecRwExec(aTabCalend[nJ], aExcecoes, .T.)) >  0
							EndIf

							If !lExceFer
								Loop
							EndIf
						EndIf

						If aCfgCob[nPosCob,2,nY,5] == "1"	// Trabalha
							cTipo := "S"
						ElseIf aCfgCob[nPosCob,2,nY,5] == "3" // Intervalo
							cTipo := "I"
						Else 
							If (HoraToInt(aCfgCob[nPosCob,2,nY,4])+HoraToInt(aCfgCob[nPosCob,2,nY,3])) > 0
								cTipo := "S"
							Else
								cTipo := "N"
							EndIf
						EndIf
						
						cDscTip := At330ADTip(cTipo)//Descricação do tipo
						cHorIni := aCfgCob[nPosCob,2,nY,3]
						cHorFim := aCfgCob[nPosCob,2,nY,4]
						// Ordena as datas a serem consistidas para gerar as informações da cobertura
						aSort( aCfgCob[nPosCob,2,nY,6],,, { |x,y| x[1]<y[1] } )
						nLenCfgCob := Len(aCfgCob[nPosCob,2,nY,6])
						
						For nW:=1 To nLenCfgCob 
						
							lCobFerias := .T. //Gera agenda de cobertura de férias
							If !Empty(aCfgCob[nPosCob,2,nY,6,nW,2]) .And. !Empty(aCfgCob[nPosCob,2,nY,6,nW,3])	
								// Verifica se a cobertura é do tipo "Ferista"
								If aCfgCob[nPosCob,2,nY,2] == '4' 
									// Verifica quais períodos de Férias o atendente tem agendamento
									lCobFerias := .T.
									If len(aDiasFer) > 0
										nFerPos := aScan( aDiasFer, { |x| x[1] == aAteEfe[nI,4,nX,2] .AND.  aTabCalend[nJ,CALEND_POS_DATA] >= x[2] .And.  aTabCalend[nJ+1,CALEND_POS_DATA] <= x[3]  } ) 
										If nFerPos <= 0
											lCobFerias := .F.
											//Não é cobertura de férias verifique o segundo agendamento
										EndIf
									EndIf
									
									nFerPos := 0
									If !lCobFerias .AND. len(aDiasFer2) > 0
										lCobFerias := .T.
										nFerPos := aScan( aDiasFer2, { |x| x[1] == aAteEfe[nI,4,nX,2] .AND.  aTabCalend[nJ,CALEND_POS_DATA] >= x[2] .And.  aTabCalend[nJ+1,CALEND_POS_DATA] <= x[3]  } )
										If nFerPos <= 0
											lCobFerias := .F.
											//Não é cobertura de férias verifique o terceiro agendamento
										EndIf
									EndIf
									
									nFerPos := 0
									If !lCobFerias .AND. len(aDiasFer3) > 0
										lCobFerias := .T.
										nFerPos := aScan( aDiasFer3, { |x| x[1] == aAteEfe[nI,4,nX,2] .AND.  aTabCalend[nJ,CALEND_POS_DATA] >= x[2] .And.  aTabCalend[nJ+1,CALEND_POS_DATA] <= x[3] } )
										If nFerPos <= 0
											lCobFerias := .F.
											//Não é cobertura de férias não gere agenda de cobertura para a data
										EndIf
									EndIf
									
								Else
									// Verifica se o atendente esta dentro do periodo, em caso de cobertura diferente de 4 (Ferista)
									If	!( aTabCalend[nJ,CALEND_POS_DATA] >= aCfgCob[nPosCob,2,nY,6,nW,2] .And. ; 
										 aTabCalend[nJ+1,CALEND_POS_DATA] <= aCfgCob[nPosCob,2,nY,6,nW,3] ) 										 				
										lCobFerias := .F.
									EndIf
								EndIf
							ElseIf Empty(aCfgCob[nPosCob,2,nY,6,nW,3]) // Verifica os atendentes sem data final de atendimento
								If ! aTabCalend[nJ,CALEND_POS_DATA] >= aCfgCob[nPosCob,2,nY,6,nW,2] 
									lCobFerias := .F.
								EndIf								
							EndIf
							
							If !lCobFerias
								Loop
							EndIf
							
							
							nItem++							
							
							nPosABB := aScan( aAteABB, { |x| x[1] 	== aTabCalend[nJ,CALEND_POS_DATA] .And.;
																	x[5] == aCfgCob[nPosCob,2,nY,6,nW,1] .And. x[7] == .T. .And. ;
																	(x[3] == cHorIni .Or. x[4] == cHorFim) } )
				
							If nPosABB == 0
								nPosABB := aScan( aAteABB, { |x| x[1] 	== aTabCalend[nJ,CALEND_POS_DATA] .And.;
																x[5] == aCfgCob[nPosCob,2,nY,6,nW,1] .And. x[7] == .T. } )							 
							EndIf
																  												  
							If nPosABB > 0
								
								cHorIni := aAteABB[ nPosABB, 3 ]				
								cHorFim := aAteABB[ nPosABB, 4 ]
				
								If cTipo == "N" .And. ( HoraToInt( cHorIni ) + HoraToInt( cHorFim ) ) > 0
									cTipo := "E"									
								EndIf		
																								
								aAteABB[ nPosABB, 7 ] := .F.				
								
							EndIf		
														
							dAteCob := aTabCalend[nJ,CALEND_POS_DATA]
							
							If !lRtFolg
								// Verifica quando a cobertura entra no meio do turno no dia seguinte
								If aTabCalend[nJ,CALEND_POS_DATA] <> aTabCalend[nJ+1,CALEND_POS_DATA]
									If HoraToInt(cHorIni) >= 0
										dAteCob := aTabCalend[nJ+1,CALEND_POS_DATA]		
									EndIf
								EndIf	
							Endif							
							
							dDtCobIni := dAteCob
							If lRtFolg .And. ValType(dDtCobFim) <> "U" .And. dAteCob <= dDtCobFim
								dAteCob	  := dDtCobFim
								dDtCobIni := dDtCobFim
							Endif
							dDtCobFim := Iif( HoraToInt(cHorFim) < HoraToInt(cHorIni), dAteCob + 1, dAteCob ) 				
							
							aAdd( aAtend, { 	aAteEfe[nI,4,nX,1],;								// Grupo 
								  				dAteCob,;					// Data
								  				DiaSemana(dAteCob),; 								// Dia da Semana
								  				cHorIni,; 								 			// Horario Inicial
								  				cHorFim,;											// Horario Final
								  				aCfgCob[nPosCob,2,nY,6,nW,1],;					// Código do atendente
								  				Posicione("AA1",1,xFilial("AA1")+aCfgCob[nPosCob,2,nY,6,nW,1],"AA1_NOMTEC"),; // Nome do Atendente
								  				cTipo,;												// Tipo do dia trabalhado
								  				cDscTip,; 											// Descrição do dia trabalhado
								  				If(nPosABB>0,aAteABB[nPosABB][9], ""),; 			// Código da Agenda do atendente
								  				If(nPosABB>0,aAteABB[nPosABB][10],""),; 			// Se agenda foi atendida
								  				"",;												// Turno do atendente
								  				cSeqFolga,; 												// Sequencia do turno do atendente
								  				{},;
								  				nItem,;										// Dados para a tabela TDV
								  				aTabCalend[nJ,CALEND_POS_DATA_APO],;			// Data de referencia
								  				"",;	//chave para posicionamento TGY	(TGY_ESCALA + TGY_CODTDX + TGY_CODTFF)
								  				"",;//Item TGY
								  				If(nPosABB>0,aAteABB[nPosABB][12],"2")} )//Agenda Ativa					

							nLenAte := Len(aAtend)	
							
							
							// Calculo para os limites de entrada
							If Len(aTabCalend[nJ,CALEND_POS_LIM_MARCACAO]) > 0
								If !Empty(DTOS(aTabCalend[nJ,CALEND_POS_LIM_MARCACAO][1]))
									nHorMen := SubtHoras(aTabCalend[nJ,CALEND_POS_LIM_MARCACAO][1],AtConvHora(aTabCalend[nJ,CALEND_POS_LIM_MARCACAO][2]),aTabCalend[nJ,CALEND_POS_DATA],If(cHorIni=="FOLGA", "00:00",cHorIni ),.T.)
								EndIf
							EndIf
					
							// Calculo para os limites de saida
							If Len(aTabCalend[nJ+1,CALEND_POS_LIM_MARCACAO]) > 0
								If !Empty(DTOS(aTabCalend[nJ+1,CALEND_POS_LIM_MARCACAO][1]))
									nHorMai := SubtHoras(aTabCalend[nJ+1,CALEND_POS_DATA],If(cHorFim=="FOLGA", "00:00",cHorIni ), aTabCalend[nJ+1,CALEND_POS_LIM_MARCACAO][1],AtConvHora(aTabCalend[nJ+1,CALEND_POS_LIM_MARCACAO][2]),.T.)
								EndIf
							EndIf
							
							aAdd( aAtend[nLenAte,14], { Nil,;
															aTabCalend[nJ,CALEND_POS_DATA_APO],;
															aTabCalend[nJ,CALEND_POS_TURNO],;
															cSeqTrn,;
															aTabCalend[nJ,CALEND_POS_TIPO_HE_NOR],;
															aTabCalend[nJ,CALEND_POS_TIPO_HE_NOT],;
															aTabCalend[nJ,CALEND_POS_PG_NONA_HORA],;
															aTabCalend[nJ,CALEND_POS_COD_REFEICAO],;
															aTabCalend[nJ,CALEND_POS_INTSREP],;
															aTabCalend[nJ,CALEND_POS_TIPO_DIA],;
															aTabCalend[nJ,CALEND_POS_LIM_MARCACAO],;
															"N", "N", "N",;
															aTabCalend[nJ,CALEND_POS_DESC_FERIADO],;
															aTabCalend[nJ,CALEND_POS_TP_HE_FER_NR],;
															aTabCalend[nJ,CALEND_POS_TP_HE_FER_NT],;
															nHorMen,;
															nHorMai,;
															aAteEfe[nI,4,nX,1],;
															aTabCalend[nJ+1,CALEND_POS_DESC_FERIADO],;//Feriado Saída
															aTabCalend[nJ+1,CALEND_POS_TP_HE_FER_NR],;//Tipo Hora extra saida
															aTabCalend[nJ+1,CALEND_POS_TP_HE_FER_NT];//Tipo Hora extra saida 
														} )
															
							If ABB->(MsSeek( xFilial("ABB") + ; 
								 				aCfgCob[nPosCob,2,nY,6,nW,1] + ;
								 				DtoS(dDtCobIni) + ;
								 				cHorIni + ;
								 				DtoS(dDtCobFim) + ;
								 				cHorFim ) )
								
								nPosABB := aScan( aAtend, { |x| x[10] == ABB->ABB_CODIGO .And.;
								   							    x[11] == ABB->ABB_ATENDE } )
			
								If nPosABB == 0
									aAtend[nLenAte,10]     := ABB->ABB_CODIGO
									aAtend[nLenAte,11]     := ABB->ABB_ATENDE		
									aAtend[nLenAte,14,1,1] := ABB->ABB_CODIGO
								EndIf
														
							EndIf
																						  								
						
						Next nW				
					
					Next nY 
				
				EndIf
				
			EndIf			
							  
		Next nX		
		 
	Next nJ

Next nI

aSort( aAtend, Nil, Nil, { |x,y| DtoS(x[2])+DtoS(x[14][1][2])+x[4]+x[5]<DtoS(y[2])+DtoS(y[14][1][2])+y[4]+y[5] } )//Ordena atendentes pela data

RestArea(aArea)

aRet := aAtend

If lSemEftTrn
	aAteEfe	:= ACLONE(aBKPAteEfe)
EndIf
Return(aRet)

/*/{Protheus.doc} At330AAbb
Recupera agendas existentes em aAteAbb considerando a data de referencia e o codigo do tecnico
@since 17/03/2015
@version 1.0
@param dDataRef, Date, Data de referencia
@param aAteAbb, Array, Array com Agendas a serem filtradas
@param cCodtec, String, Código do tecnico
/*/
Function At330AAbb(dDataRef, aAteAbb, cCodtec)
Local nPos := 1
Local aAbb := {}
Local nI := 1

//Busca agenda que ainda não foi apresentada pela data de referencia e codigo do atendente
nPos := aScan(aAteAbb, {|x| STOD(x[11][_TDV_DTREF]) == dDataRef .AND. x[7] .AND. x[5]==cCodTec })	

If nPos > 0
	For nI := nPos To Len(aAteAbb)
					
		If STOD(aAteAbb[nI][11][_TDV_DTREF])  == dDataref .AND. aAteAbb[nI][5] == cCodTec
			If aAteAbb[nI][7]//Agenda ainda não apresentada
				aAdd(aAbb, aAteAbb[nI])
				aAteAbb[nI][7] := .F.//Indicação de agenda já utilizada
			EndIf
		Else
			Exit//Interrompe a repetição						
		EndIf
	Next nI
EndIf
Return aAbb

Function At330ACal(aTabCalend, nIndCalend)
Local aCalend := {}
Local nOrdem := 0
Local nI := 1

If Len(aTabCalend) >= nIndCalend
	nOrdem := aTabCalend[nIndCalend][CALEND_POS_ORDEM]
	
	For nI:= 1 To Len(aTabCalend)
		If nOrdem == aTabCalend[nI][CALEND_POS_ORDEM]	
			aAdd(aCalend, aTabCalend[nI])				
		EndIf
	Next nI
EndIf

Return aCalend

Static Function getInfoAtend(aAbb, aCalend, aAteEfe, cTurno, cSeq, cKeyTGY, aHorFlex, nGrupo,;
								cCodTec, cItem, dUltAloc, lExcecao, dDatIni, dDatFim, aCfgRtCb, cAtendFlx, cTpRota )
	Local nI := 1
	Local cTipo := ""
	Local aNewAtend:= {}
	Local cIntVl1 := "N"
	Local cIntVl2 := "N"
	Local cIntVl3 := "N"
	Local cSeqTrn	:= ""
	Local nIntHor := 0
	Local nPosHora	:= 0
	Local lHrs :=  .F.
	Local lGesHr	:= SuperGetMV('MV_GSGEHOR',,.F.) .And. at330ColHR()
	Local lEditHor := ExistBlock("At330HR")
	Local lEditHorRt := ExistBlock("At330HRRT")
	Local aHoras   := {}
	Local aDados   := {}
	Local cCodTGY  := ""
	Local aHorRota	:= {}
	Local cHorIni	:= ""
	Local cHorFim	:= ""

	Default aHorFlex := IIF(LEN(aAteEfe) >= 8 , aAteEfe[8], ARRAY(1))
	Default nGrupo := aAteEfe[1]
	Default cCodTec := aAteEfe[2]
	Default cItem := aAteEfe[5]
	Default dUltAloc := aAteEfe[6]
	Default lExcecao := .F.
	Default aCfgRtCb := {}
	Default cAtendFlx := ""	
	Default cTpRota := ""	
	
	If lGesHr
		lHrs :=  Len(aHorFlex) > 0
	EndIf
	
	If Len(aAbb) > 0
		For nI := 1 To Len(aAbb)

			cTipo := At330ATip(aAbb[nI][6], HoraToInt(aAbb[nI][3]), HoraToInt(aAbb[nI][4]))

			aAdd( aNewAtend, { nGrupo,;						// Grupo 
							  aAbb[nI][1],;						// Data
							  DiaSemana(aAbb[nI][1]),;			// Dia da Semana
							  aAbb[nI][3],; 						// Horario Inicial
							  aAbb[nI][4],;						// Horario Final
							  cCodTec,;						// Código do atendente
							  Posicione("AA1",1,xFilial("AA1")+cCodTec,"AA1_NOMTEC"),; // Nome do Atendente
							  cTipo,;								// Tipo do dia trabalhado
							  At330ADTip(cTipo),; 				// Descrição do dia trabalhado
							  aAbb[nI][9],;						// Código da Agenda do atendente
							  aAbb[nI][10],;						// Se agenda foi atendida
							  aAbb[nI][11][_TDV_TURNO],;					// Turno do atendente
							  aAbb[nI][8],;						// Sequenci do turno do atendente
							  {},;									// Dados para a tabela TDV
							  0,;								//Item
							  STOD(aAbb[nI][11][_TDV_DTREF]),;	// Data de referencia
							  cKeyTGY,;							//chave para posicionamento TGY	(TGY_ESCALA + TGY_CODTDX + TGY_CODTFF)
							  cItem,;						//Item TGY
							  aAbb[nI][12]} )						//Agenda com manutenção												  

			
			cIntVl1 := aAbb[nI][11][_TDV_INTVL1]
			cIntVl2 := aAbb[nI][11][_TDV_INTVL2]
			cIntVl3 := aAbb[nI][11][_TDV_INTVL3]
			
			//Adiciona informações da TDV na estrutura do atendente
			aAdd( aNewAtend[Len(aNewAtend),14], getInfoTDV(NIl, NIl, aAbb[nI],aAbb[nI][3], aAbb[nI][4], cTipo, cIntVl1, cIntVl2, cIntVl3, nGrupo ))					  	
		Next nI
	Else
		//Percorre aCalend, considerando a estrutura do aTabCalend.
		//Obrigatoriamente deve existir linha para horário de entrada e linha para horário de saída
		For nI:=1 To Len(aCalend) Step 2			
			cHorIni := ""
			cHorFim := ""
			// Verifica se existe intervalo entre as marcações
			nIntHor++			
			cIntVl1 := "N"
			cIntVl2 := "N"
			cIntVl3 := "N"		
			If aCalend[nI+1,CALEND_POS_HRS_INTER] > 0
				Do Case
					Case nIntHor == 1	; cIntVl1 := "S"
					Case nIntHor == 2	; cIntVl2 := "S"
					OtherWise			; cIntVl3 := "S"
				EndCase  
			EndIf

			nPosHora += 1							
			//Não gera nova agenda para dias anteriores a data da ultima alocação.
			//para realizar este procedimento é necessário excluir as alocações				
			If aCalend[nI][CALEND_POS_DATA_APO] > dUltAloc
				cTipo := At330ATip(aCalend[nI][CALEND_POS_TIPO_DIA], aCalend[nI][CALEND_POS_HORA], aCalend[nI+1][CALEND_POS_HORA])			
				//Projeção de rota de cobertura de folguista
				If cTpRota == "1"
					If (cTipo $ "C|D|N" .Or. lExcecao) .And. Len(aCfgRtCb) > 0
						aHorRota := AtHrRota(aCfgRtCb, cTurno, aCalend[nI,CALEND_POS_SEQ_TURNO], aCalend[nI,CALEND_POS_DATA_APO], cTpRota )
						If Len(aHorRota) > 0
							If lHrs .And. !Empty(StrTran(aHorFlex[nPosHora,1], ':','')) .And. !Empty(StrTran(aHorFlex[nPosHora,2], ':', '')) .And. !lExcecao
								cHorIni := aHorFlex[nPosHora,1]
								cHorFim := aHorFlex[nPosHora,2]
							Else
								If lExcecao
									cHorIni := AtConvHora(aCalend[ nI ,CALEND_POS_HORA])
									cHorFim := AtConvHora(aCalend[ nI+1 ,CALEND_POS_HORA])
								Else
									cHorIni := aHorRota[nPosHora,1]
									cHorFim := aHorRota[nPosHora,2]
								Endif
							Endif
							If lEditHorRt .And. ValType(aCalend) == "A"
								cCodTGY := xFilial("TGY")+cKeyTGY+cItem
								aDados := {cCodTGY, cAtendFlx,dDatIni,dDatFim,aCalend[nI,CALEND_POS_DATA_APO] ,cTurno,cSeq, {}, aCalend }
								aHoras := Execblock("At330HRRT",.F.,.F., aDados)
								If ValType(aHoras) == "A" .And. !Empty(aHoras)
									If Len(aHoras[2]) >= 2
										aCalend := aHoras[2]
										cHorIni := aHoras[1][nPosHora][1]
										cHorFim := aHoras[1][nPosHora][2]
									EndIf
								Endif
							Endif
						Else
							cHorIni := "FOLGA"	// "FOLGA"
							cHorFim := "FOLGA"
						EndIf
					Else
						cHorIni := "FOLGA"	// "FOLGA"
						cHorFim := "FOLGA"
					Endif
				Elseif cTpRota $ "2|3" //Rota de cobertura de almocista/jantista
					If aCalend[nI+1,CALEND_POS_HRS_INTER] > 0
						aHorRota := AtHrRota(aCfgRtCb, cTurno, aCalend[nI,CALEND_POS_SEQ_TURNO], aCalend[nI,CALEND_POS_DATA_APO], cTpRota )
						If Len(aHorRota) > 0
							If lHrs .And. !Empty(StrTran(aHorFlex[nIntHor,1], ':','')) .And. !Empty(StrTran(aHorFlex[nPosHora,2], ':', '')) .And. !lExcecao
								cHorIni := aHorFlex[nIntHor,1]
								cHorFim := aHorFlex[nIntHor,2]
							Else
								If lExcecao
									If Len(aCalend) >= nIntHor+2 //Quando exceção não tem intervalo é gerado folga
										cHorIni := AtConvHora(aCalend[ nIntHor+1 ,CALEND_POS_HORA])
										cHorFim := AtConvHora(aCalend[ nIntHor+2 ,CALEND_POS_HORA])
									Else
										cHorIni := "FOLGA"	// "FOLGA"
										cHorFim := "FOLGA"									
									Endif
								Else
									cHorIni := aHorRota[nIntHor,1]
									cHorFim := aHorRota[nIntHor,2]
								Endif
							Endif
						Else
							cHorIni := "FOLGA"	// "FOLGA"
							cHorFim := "FOLGA"
						EndIf
					Else
						cHorIni := "FOLGA"	// "FOLGA"
						cHorFim := "FOLGA"
					Endif
				Else
				//Efetivo
					If cTipo == "S" .Or. cTipo == "E"
						If lHrs .And. !Empty(StrTran(aHorFlex[nPosHora,1], ':','')) .And. !Empty(StrTran(aHorFlex[nPosHora,2], ':', '')) .And. !lExcecao
							cHorIni := aHorFlex[nPosHora,1]
							cHorFim := aHorFlex[nPosHora,2]
						Else
							cHorIni := AtConvHora(aCalend[ nI ,CALEND_POS_HORA])
							cHorFim := AtConvHora(aCalend[ nI+1 ,CALEND_POS_HORA])
						EndIf
						If lEditHor .And. ValType(aCalend) == "A"
							cCodTGY := xFilial("TGY")+cKeyTGY+cItem
							aDados := {cCodTGY, cCodTec,dDatIni,dDatFim,aCalend[nI,CALEND_POS_DATA_APO] ,cTurno,cSeq, aCalend[nI], aCalend }
							aHoras := Execblock("At330HR",.F.,.F., aDados)
							If ValType(aHoras) == "A" .And. !Empty(aHoras)
								If Len(aHoras[2]) >= 2
									aCalend := aHoras[2]
									cHorIni := aHoras[1][nPosHora][1]
									cHorFim := aHoras[1][nPosHora][2]
								EndIf
							Endif
						EndIf
					Else
						cHorIni := "FOLGA"	// "FOLGA"
						cHorFim := "FOLGA"
					EndIf
				Endif
				cSeqTrn := 	aCalend[nI,CALEND_POS_SEQ_TURNO]
			Else //Não existe agenda (ABB) e data inferior a ultima alocação realizada				
				cTipo := "N"
				cHorIni := "FOLGA"
				cHorFim := "FOLGA"
				cSeqTrn := ""//Deixa sequencia do turno vazia para recuperar quand	o salvar a alocação
			EndIf

			aAdd( aNewAtend, { nGrupo,;								// Grupo 
							aCalend[nI,CALEND_POS_DATA],;					// Data
							DiaSemana(aCalend[nI,CALEND_POS_DATA]),; 	// Dia da Semana
							cHorIni,; 								 			// Horario Inicial
							cHorFim,;											// Horario Final
							cCodTec,;								// Código do atendente
							Posicione("AA1",1,xFilial("AA1")+cCodTec,"AA1_NOMTEC"),; // Nome do Atendente
							cTipo,;												// Tipo do dia trabalhado
							At330ADTip(cTipo),; 											// Descrição do dia trabalhado
							"",;				// Código da Agenda do atendente
							"",;				// Se agenda foi atendida
							aCalend[nI][CALEND_POS_TURNO],;												// Turno do atendente
							cSeqTrn,;												// Sequencia do turno do atendente
							{},;											// Dados para a tabela TDV
							0,;										//Item
							aCalend[nI,CALEND_POS_DATA_APO],;// Data de referencia
							cKeyTGY,;	//chave para posicionamento TGY	(TGY_ESCALA + TGY_CODTDX + TGY_CODTFF)
							cItem,;//Item TGY
							"2"} )//Agenda com Manutenção	

			If Len(aNewAtend) > 0
				//Adiciona informações da TDV na estrutura do atendente
				aAdd( aNewAtend[Len(aNewAtend),14], getInfoTDV(aCalend, nI,  Nil,cHorIni, cHorFim, cTipo,cIntVl1, cIntVl2, cIntVl3, nGrupo ))				
			Endif
		Next nI
	EndIf

Return aNewAtend

Static Function At330ATip(cTipo, nHorIni, nHorFim)

If cTipo <> "N" .And. (nHorIni + nHorFim) == 0
	If cTipo != "C"
		cTipo := "D"
	EndIf		 				
EndIf

Return cTipo

Static Function At330ADTip(cTipo)
	Local cDscTip := ""
	Do Case
		Case cTipo == "S" ; cDscTip := STR0016	 	//"Trabalhado"
		Case cTipo == "C" ; cDscTip := STR0017	 	//"Compensado"
		Case cTipo == "D" ; cDscTip := STR0018 		//"D.S.R."
		Case cTipo == "N" ; cDscTip := STR0019 		//"Nao Trabalhado"
		Case cTipo == "E" ; cDscTip := STR0020		//"Hora Extra"
		Case cTipo == "I" ; cDscTip := STR0046		// "Intervalo"
		OtherWise 			; cDscTip := ""
	EndCase
	
Return cDscTip

/*/{Protheus.doc} getInfoTDV
Recupera informações relativas a TDV, seja pelo aTabCalend (Nova alocação) ou através da ABB/TDV (Alocação já realizada) 
@since 04/03/2015
@version 11.8
@param aTabCalend, Array, aTabCalend do ponto
@param nIndCalend, Integer, indice do aTabCalend a ser considerado
@param aInfoABB, Array, INformações da agenda (ABB)
@param cHorIni, String, Horario inicial
@param cHorFim, String, Horario Final
@param cIntVl1, String, Indicação de primeiro intervalo
@param cIntVl2, String, Indicação de segundo intervalo
@param cIntVl3, String, Indicação de terceiro intervalo
@param nGrupo, Integer, Grupo de alocação do atendente

@return aInfoTDV, Estrutura com informações da TDV da agenda baseada no aTAbCalend ou então na alocação já realizada (ABB/TDV)

/*/
Static Function getInfoTDV(aTabCalend, nIndCalend, aInfoABB, cHorIni, cHorFim, cTipo,cIntVl1, cIntVl2, cIntVl3, nGrupo)

	Local aInfoTDV := {}
	Local nHorMen	:= 0
	Local nHorMai := 0		
	Local aTDV := {}
	
	
	If aInfoABB == Nil .OR. Len(aInfoABB[11]) == 0//considera informações provenientes do aTabCalend
	
		// Calculo para os limites de entrada
		If Len(aTabCalend[nIndCalend,CALEND_POS_LIM_MARCACAO]) > 0
			If !Empty(DTOS(aTabCalend[nIndCalend,CALEND_POS_LIM_MARCACAO][1]))
				nHorMen := SubtHoras(aTabCalend[nIndCalend,CALEND_POS_LIM_MARCACAO][1],AtConvHora(aTabCalend[nIndCalend,CALEND_POS_LIM_MARCACAO][2]),aTabCalend[nIndCalend,CALEND_POS_DATA],If(cHorIni=="FOLGA", "00:00",cHorIni ),.T.)
			EndIf
		EndIf			
		
		// Calculo para os limites de saida
		If Len(aTabCalend[nIndCalend+1,CALEND_POS_LIM_MARCACAO]) > 0
			If !Empty(DTOS(aTabCalend[nIndCalend+1,CALEND_POS_LIM_MARCACAO][1]))
				nHorMai := SubtHoras(aTabCalend[nIndCalend+1,CALEND_POS_DATA],If(cHorFim=="FOLGA", "00:00",cHorFim ), aTabCalend[nIndCalend+1,CALEND_POS_LIM_MARCACAO][1],AtConvHora(aTabCalend[nIndCalend+1,CALEND_POS_LIM_MARCACAO][2]),.T.)
			EndIf
		EndIf	
							
		aInfoTDV := { If(aInfoABB == Nil,"", aInfoABB[9]),;
											aTabCalend[nIndCalend,CALEND_POS_DATA_APO],;
											aTabCalend[nIndCalend,CALEND_POS_TURNO],;
											aTabCalend[nIndCalend,CALEND_POS_SEQ_TURNO],;
											aTabCalend[nIndCalend,CALEND_POS_TIPO_HE_NOR],;
											aTabCalend[nIndCalend,CALEND_POS_TIPO_HE_NOT],;
											aTabCalend[nIndCalend,CALEND_POS_PG_NONA_HORA],;
											aTabCalend[nIndCalend,CALEND_POS_COD_REFEICAO],;
											aTabCalend[nIndCalend,CALEND_POS_INTSREP],;
											cTipo,;
											aTabCalend[nIndCalend,CALEND_POS_LIM_MARCACAO],;											
											cIntVl1, cIntVl2, cIntVl3,;
											aTabCalend[nIndCalend,CALEND_POS_DESC_FERIADO],;//Feriado Entrada
											aTabCalend[nIndCalend,CALEND_POS_TP_HE_FER_NR],;//Tipo Hora extra entrada
											aTabCalend[nIndCalend,CALEND_POS_TP_HE_FER_NT],;//Tipo Hora extra entrada
											nHorMen,;//Limite Inferior
											nHorMai,;//Limite Superior
											nGrupo,;
											aTabCalend[nIndCalend+1,CALEND_POS_DESC_FERIADO],;//Feriado Saída
											aTabCalend[nIndCalend+1,CALEND_POS_TP_HE_FER_NR],;//Tipo Hora extra saida
											aTabCalend[nIndCalend+1,CALEND_POS_TP_HE_FER_NT];//Tipo Hora extra saida
											 } 	
											 
	Else//Considera Informações provenientes da TDV
		
		aTDV := aInfoABB[11]
		
		// Calculo para os limites de entrada
		nHorMen := aTdv[_TDV_HRMEN]
		nHorMai := aTdv[_TDV_HRMAI]
					
					
					
		aInfoTDV := { aInfoABB[9],;
						Stod(aTdv[_TDV_DTREF]),;//Data referencia
						aTdv[_TDV_TURNO],;//Turno
						aInfoABB[8],;//Sequencia do turno
						aTdv[_TDV_TPEXT],;//Tipo hora extra normal
						aTdv[_TDV_TPEXTN],;//tipo hora extra noturna
						aTdv[_TDV_NONHOR],;//paga nona hora
						aTdv[_TDV_CODREF],;//codigo v. refeição
						aTdv[_TDV_INSREP],;//
						cTipo,;//Tipo
						{},;//Limite marcação											
						cIntVl1, cIntVl2, cIntVl3,;//intervalos
						aTdv[_TDV_FERIAD],;//Feriado Entrada
						aTdv[_TDV_FTPEXT],;//Tipo Hora extra entrada
						aTdv[_TDV_FSEXTN],;//Tipo Hora extra entrada
						nHorMen,;//Limite Inferior
						nHorMai,;//Limite Superior
						nGrupo,;//Grupo
						aTdv[_TDV_FERSAI],;//Feriado Saída
						aTdv[_TDV_FSTPEX],;//Tipo Hora extra saida
						aTdv[_TDV_FSEXTN];//Tipo Hora extra saida
					} 
	EndIf

Return aInfoTDV

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At330ACob				   
Retorna as coberturas do efetivo

@sample 	At330ACob( cCodEfe, cEscala )

@param		cCodTFF - Codigo do recurso humano para filtro
@param		cCodEfe - Codigo do efetivo para listar as coberturas
@param		cEscala - Codigo da Escala para a listagem das coberturas

@author  	Serviços
@since 	  	17/07/2014
@version	P12

@return 	aRet: Lista com as coberturas do efetivo 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330ACob( cCodTFF, aAteEf, cEscala, cCodRota,cTurno,cSeq, cAtend, aExcecoes, lSemEftTrn, aCalend )

Local aRet 	  	:= {}
Local cAliasTGW := GetNextAlias()
Local aCobEfe   := {}
Local nPos      := 0
Local nPosAte   := 0
Local cChvTGZ   := ""
Local cJoinTW0	:= "%%"
Local cSelTW0	:= "%%"
Local cAliasTGY	:= ""
Local lHrFlex	:= TecXHasEdH()
Local nC		:= 0
Local aExceRt	:= {}
Local aDados	:= {}
Local aCopyteEF1 := {}
Local aCopyteEF2 := {}
Local nK		:= 0
Local lRplFer   := TDW->( ColumnPos('TDW_RPLFER')) > 0 .And. (Posicione("TDW",1,xFilial("TDW") + cEscala , "TDW_RPLFER") == "1")
Local lPNMRwExc := FindFunction("U_PNMRwExc")
Local lTecExce  := FindFunction( "TecExecPNM" ) .AND. TecExecPNM() .AND. ExistFunc("TecRwExec")
Local lEditHor  := ExistBlock("At330HRRT")
Local aHoras	:= {}
Local cCodTGY	:= ""
Local lRotTipo	:= TW0->(ColumnPos("TW0_TIPO")) > 0

Default cCodRota:= ""
Default cAtend	:= ""

If !Empty(cCodRota) .And. lRotTipo
	cChvTGZ := "%AND TGZ.TGZ_CODTW0 = '"+cCodRota+"'%"
	If lHrFlex
		cSelTW0	:= "% , TW0.TW0_TIPO, TGZ.TGZ_GRUPO %"
		cJoinTW0 := "% JOIN " + RetSqlName("TW0") + " TW0 "
		cJoinTW0 += " ON TW0.TW0_COD = TGZ.TGZ_CODTW0 "
		cJoinTW0 += " AND TW0.TW0_FILIAL = '" + xFilial("TW0") + "' "
		cJoinTW0 += " AND TW0.D_E_L_E_T_ = '' %"
	EndIf
Else
	cChvTGZ := '%%'
EndIf

BeginSql Alias cAliasTGW
	SELECT 
		TGW.TGW_DIASEM, TGW.TGW_HORINI, TGW.TGW_HORFIM, 
		TGW.TGW_STATUS, TGW.TGW_COBTDX, TGW.TGW_COBTIP,
		TGZ.TGZ_ATEND, TGZ.TGZ_DTINI, TGZ.TGZ_DTFIM, TGZ.TGZ_HORINI, TGZ.TGZ_HORFIM, TGZ.TGZ_ITEM, TDX.TDX_COD %Exp:cSelTW0%
	FROM 
		%table:TGW% TGW
	JOIN %table:TDX% TDX ON 
		TDX.TDX_FILIAL = %xFilial:TDX% AND
		TDX.TDX_CODTDW = %Exp:cEscala% AND
		TDX.TDX_TURNO  = %Exp:cTurno%  AND
		TDX.TDX_SEQTUR = %Exp:cSeq%  AND
		TDX.%NotDel%	
	JOIN %table:TGX% TGX ON
		TGX.TGX_FILIAL = %xFilial:TGX% AND
		TGX.TGX_CODTDW = %Exp:cEscala% AND 
		TGX.TGX_ITEM = TGW.TGW_COBTDX AND
		TGX.%NotDel%
	JOIN %table:TGZ% TGZ ON 
		TGZ.TGZ_FILIAL = %xFilial:TGZ% AND
		TGZ.TGZ_CODTDX = TGX.TGX_COD AND 
		TGZ.TGZ_ESCALA = %Exp:cEscala% AND
		TGZ.TGZ_CODTFF = %Exp:cCodTFF% AND
		TGZ.%NotDel%
	%Exp:cJoinTW0%
	WHERE 
		TGW.TGW_FILIAL = %xFilial:TGW% AND 
		TGW.TGW_EFETDX = TDX.TDX_COD  AND 
		TGW.TGW_COBTDX <> ' ' AND
		TGW.%NotDel%
		%Exp:cChvTGZ%
	ORDER BY TGZ.TGZ_ITEM,  TGW.TGW_DIASEM
		
EndSql

While (cAliasTGW)->(!Eof())
	
	nPos := aScan( aCobEfe, { |x| x[1] == (cAliasTGW)->TGW_DIASEM } )
		
	If nPos == 0
		aAdd( aCobEfe, { 	(cAliasTGW)->TGW_DIASEM, {} } )		
		nPos := Len(aCobEfe)
		nC := 0
		nK := 0
		If lPNMRwExc
			aExceRt := U_PNMRwExc(aAteEf, aExcecoes, ,lRplFer)
		ElseIf lTecExce
			aExceRt := TecRwExec(aAteEf, aExcecoes, ,lRplFer)
		EndIf
	EndIf

	If !Empty(aExceRt)
		While nK < 8
			If lEditHor .And. nC == 0
				cCodTGY := xFilial("TGY")+cEscala+(cAliasTGW)->TDX_COD+cCodTFF
				aCopyteEF1 := ACLONE(aAteEf)
				aDados := {cCodTGY, cAtend, (cAliasTGW)->TGZ_DTINI, (cAliasTGW)->TGZ_DTFIM, aCopyteEF1, cTurno, cSeq, {}, aCalend}
				aHoras := Execblock("At330HRRT",.F.,.F., aDados)
				If ValType(aHoras) == 'A' .And. Len(aHoras) == 2 .And. Len(aHoras[1]) > 0 .And. Len(aHoras[2]) > 0
					aCalend := aHoras[2]
					aHoras  := aHoras[1]
				EndIf
				If ValType(aHoras) == "A" .And. !Empty(aHoras)
					For nC := 1 to Len(aHoras)
						aAdd( aCobEfe[nPos,2], {	(cAliasTGW)->TGW_COBTDX,;
													(cAliasTGW)->TGW_COBTIP,;
													aHoras[nC,1],;
													aHoras[nC,2],;
													(cAliasTGW)->TGW_STATUS, {}} )
						nPosAte := Len(aCobEfe[nPos,2])
						aAdd( aCobEfe[nPos,2,nPosAte,6], { (cAliasTGW)->TGZ_ATEND,;
												StoD((cAliasTGW)->TGZ_DTINI),;
												StoD((cAliasTGW)->TGZ_DTFIM) } )
					Next nC
					If nC <> 0
						Exit
					Endif
				Endif
			Endif

			If aExceRt[4+nK] <> 0 .And. aExceRt[5+nK] <> 0 .And. nC == 0
				aAdd( aCobEfe[nPos,2], {	(cAliasTGW)->TGW_COBTDX,; 
											(cAliasTGW)->TGW_COBTIP,; 
											TecConvHr(aExceRt[4+nK]),; 
											TecConvHr(aExceRt[5+nK]),;
											(cAliasTGW)->TGW_STATUS, {}} )
				nPosAte := Len(aCobEfe[nPos,2])
				aAdd( aCobEfe[nPos,2,nPosAte,6], { (cAliasTGW)->TGZ_ATEND,;
											StoD((cAliasTGW)->TGZ_DTINI),;
											StoD((cAliasTGW)->TGZ_DTFIM) } )
			Endif

			nK += 2
		EndDo
	Else
		If !Empty((cAliasTGW)->TGZ_HORINI) .OR. !Empty((cAliasTGW)->TGZ_HORFIM) //busca horario da cobertura 
			
			nPosAte := aScan( aCobEfe[nPos,2], { |x| 	x[1] == (cAliasTGW)->TGW_COBTDX .And. ; 
														x[2] == (cAliasTGW)->TGW_COBTIP .And. ;
														x[3] == AtConvHora((cAliasTGW)->TGZ_HORINI) .And. ; 
														x[4] == AtConvHora((cAliasTGW)->TGZ_HORFIM) } )
			
			If nPosAte == 0	
				aAdd( aCobEfe[nPos,2], {	(cAliasTGW)->TGW_COBTDX,; 
											(cAliasTGW)->TGW_COBTIP,; 
											AtConvHora((cAliasTGW)->TGZ_HORINI),; 
											AtConvHora((cAliasTGW)->TGZ_HORFIM),; 
											(cAliasTGW)->TGW_STATUS, {} } )						
				nPosAte := Len(aCobEfe[nPos,2])		
			EndIf									
		Else //busca horario da escala
			If lHrFlex .AND. lRotTipo .AND. !Empty(cCodRota) .AND. ((cAliasTGW)->TW0_TIPO == '1')
				If nC == 0 .And. !lSemEftTrn
					cQuery := ""
					cQuery += " SELECT TGY.TGY_ENTRA1, TGY.TGY_ENTRA2, TGY.TGY_ENTRA3, TGY.TGY_ENTRA4, "
					cQuery += " TGY.TGY_SAIDA1, TGY.TGY_SAIDA2, TGY.TGY_SAIDA3, TGY.TGY_SAIDA4, TGY.TGY_ITEM "
					cQuery += " FROM " + RetSqlName("TGY") + " TGY "
					cQuery += " WHERE TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
					cQuery += " AND TGY.TGY_CODTFF = '" + cCodTFF + "' "
					cQuery += " AND TGY.TGY_GRUPO = '" + cValToChar((cAliasTGW)->TGZ_GRUPO) + "' "
					cQuery += " AND TGY.D_E_L_E_T_ = '' "
					If TW1->(ColumnPos("TW1_ATDTGY") > 0) .AND. !Empty(cAtend)
						cQuery += " AND TGY.TGY_ATEND = '" + cAtend + "' "
					EndIf

					cAliasTGY := GetNextAlias()

					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTGY, .F., .T.)

					If (cAliasTGY)->(!Eof())
						If lEditHor
							cCodTGY := xFilial("TGY")+cEscala+(cAliasTGW)->TDX_COD+cCodTFF
							aCopyteEF2 := ACLONE(aAteEf)
							aDados := {cCodTGY, cAtend, (cAliasTGW)->TGZ_DTINI, (cAliasTGW)->TGZ_DTFIM, aCopyteEF2, cTurno, cSeq, {}, aCalend} 
							aHoras := Execblock("At330HRRT",.F.,.F., aDados)
							If ValType(aHoras) == 'A' .And. Len(aHoras) == 2 .And. Len(aHoras[1]) > 0 .And. Len(aHoras[2]) > 0
								aCalend := aHoras[2]
								aHoras  := aHoras[1]
							EndIf
							If ValType(aHoras) == "A" .And. !Empty(aHoras)
								For nC := 1 to Len(aHoras)
									aAdd( aCobEfe[nPos,2], {	(cAliasTGW)->TGW_COBTDX,;
																(cAliasTGW)->TGW_COBTIP,;
																aHoras[nC,1],;
																aHoras[nC,2],;
																(cAliasTGW)->TGW_STATUS, {}} )
									nPosAte := Len(aCobEfe[nPos,2])
									aAdd( aCobEfe[nPos,2,nPosAte,6], { (cAliasTGW)->TGZ_ATEND,;
															StoD((cAliasTGW)->TGZ_DTINI),;
															StoD((cAliasTGW)->TGZ_DTFIM) } )
								Next nC
							Endif
						Endif
						If nC == 0 .And. (!Empty((cAliasTGY)->TGY_ENTRA1) .AND. !Empty((cAliasTGY)->TGY_SAIDA1)) 							
							For nC := 1 to 4
								If !Empty(&("(cAliasTGY)->TGY_ENTRA"+ Str(nC, 1)))
									aAdd( aCobEfe[nPos,2], {	(cAliasTGW)->TGW_COBTDX,; 
																(cAliasTGW)->TGW_COBTIP,; 
																&("(cAliasTGY)->TGY_ENTRA"+ Str(nC, 1)),; 
																&("(cAliasTGY)->TGY_SAIDA"+ Str(nC, 1)),; 
																(cAliasTGW)->TGW_STATUS, {}} )		
									nPosAte := Len(aCobEfe[nPos,2])	
									aAdd( aCobEfe[nPos,2,nPosAte,6], { (cAliasTGW)->TGZ_ATEND,;
															StoD((cAliasTGW)->TGZ_DTINI),;
															StoD((cAliasTGW)->TGZ_DTFIM) } )
								EndIf
							Next nC
						Endif
					Else
						nPosAte := aScan( aCobEfe[nPos,2], { |x| 	x[1] == (cAliasTGW)->TGW_COBTDX .And. ; 
																		x[2] == (cAliasTGW)->TGW_COBTIP .And. ;
																		x[3] == AtConvHora((cAliasTGW)->TGW_HORINI) .And. ; 
																		x[4] == AtConvHora((cAliasTGW)->TGW_HORFIM) } )
							
						If nPosAte == 0	
							aAdd( aCobEfe[nPos,2], {	(cAliasTGW)->TGW_COBTDX,; 
														(cAliasTGW)->TGW_COBTIP,; 
														AtConvHora((cAliasTGW)->TGW_HORINI),; 
														AtConvHora((cAliasTGW)->TGW_HORFIM),; 
														(cAliasTGW)->TGW_STATUS, {} } )						
							nPosAte := Len(aCobEfe[nPos,2])		
						EndIf
					EndIf
					(cAliasTGY)->(dbCloseArea())
				Endif
			Else
				nPosAte := aScan( aCobEfe[nPos,2], { |x| 	x[1] == (cAliasTGW)->TGW_COBTDX .And. ; 
																	x[2] == (cAliasTGW)->TGW_COBTIP .And. ;
																	x[3] == AtConvHora((cAliasTGW)->TGW_HORINI) .And. ; 
																	x[4] == AtConvHora((cAliasTGW)->TGW_HORFIM) } )
						
				If nPosAte == 0	
					aAdd( aCobEfe[nPos,2], {	(cAliasTGW)->TGW_COBTDX,; 
												(cAliasTGW)->TGW_COBTIP,; 
												AtConvHora((cAliasTGW)->TGW_HORINI),; 
												AtConvHora((cAliasTGW)->TGW_HORFIM),; 
												(cAliasTGW)->TGW_STATUS, {}} )									
					nPosAte := Len(aCobEfe[nPos,2])		
				EndIf
			EndIf
		Endif
		If nC == 0 .And. nK == 0 .And. nPosAte <> 0
			aAdd( aCobEfe[nPos,2,nPosAte,6], { (cAliasTGW)->TGZ_ATEND,;
										StoD((cAliasTGW)->TGZ_DTINI),;
										StoD((cAliasTGW)->TGZ_DTFIM) } )		 
		EndIF
	Endif
	(cAliasTGW)->(dbSkip())
EndDo

(cAliasTGW)->(dbCloseArea())

aRet := aCobEfe

Return(aRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At330ACmt				   
Efetiva a alocação dos atendentes

@sample 	At330ACmt( oModel )

@param		oModel - Model para a gravação da alocação dos atendentes

@author  	Serviços
@since 	  	21/07/2014
@version	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330ACmt( oModel )

Local oMdlTFF 	:= oModel:GetModel("TFFMASTER")
Local oMdlZZX 	:= oModel:GetModel("ZZXDETAIL")
Local nAux
Local aDesalocar 	:= {}
Local aCalAtd 	:= {}
Local aAgenda    	:= {}
Local aSaldoCfg	:= {}
Local aAloTDV		:= {}
Local aDesTDV		:= {}
Local aAlocTipMov   := {}
Local nPosTipMov    := 0
Local nPosAtend  	:= 0
Local nTotHor  	:= 0
Local cIdCFal    	:= ""
Local cHorIni    	:= ""
Local cHorFim    	:= ""
Local aIteABQ    	:= {}
Local lChange    	:= .F.
Local aUltAloc		:= {} //Array com ultima alocação válida
Local nPosUltAlo	:= 0//nPos do array de ultima alocação
Local aPriDes		:= {} //Array com primeira desalocação
Local nPosPriDes	:= 0//nPos do array de primeira desalocação
Local nI
Local dAloFim
Local dAloFimOri := STOD("")//Data fim da agenda original
Local cAliasABB		:= ""
Local lResTec := .F.
Local aInserted := {}
Local cEscala := oMdlTFF:GetValue("TFF_ESCALA")
Local cCodTFF := oMdlTFF:GetValue("TFF_COD")

dbSelectArea("ABQ")
ABQ->(dbSetOrder(3))

For nI:=1 To oMdlZZX:Length()

	oMdlZZX:GoLine(nI)
	
	If nI == 1
		dbSelectArea("ABS")
		ABS->(dbSetOrder(1))
		If ABS->(dbSeek(xFilial("ABS")+oMdlTFF:GetValue("TFF_LOCAL") )) .And. ABS->ABS_RESTEC == "1"
			lResTec := .T.
		EndIf
	EndIf
	
	nPosAtend := 0
	// Posiciona no array estatico de atendentes
	If ( (Empty(nGrpFil) .OR. nGrpFil == oMdlZZX:GetValue("ZZX_GRUPO") ) .AND.;
	     (Empty(cAteFil) .OR. cAteFil == oMdlZZX:GetValue("ZZX_ATEND")) )
	     nPosAtend := aScan( aAtend, { |x| x[15] == oMdlZZX:GetValue("ZZX_ITEM") } )
	EndIf
	
	If nPosAtend > 0
		lChange := .F.
		
		If oMdlZZX:IsUpdated()
			If oMdlZZX:IsFieldUpdated("ZZX_ENTRADA") .Or. oMdlZZX:IsFieldUpdated("ZZX_SAIDA") .Or. oMdlZZX:IsFieldUpdated("ZZX_ATEND") .Or. oMdlZZX:IsFieldUpdated("ZZX_TIPO") 
				lChange := .T.
			EndIf
		EndIf
	
		
		cHorIni := StrHora(oMdlZZX:GetValue("ZZX_ENTRADA"))
		cHorFim := StrHora(oMdlZZX:GetValue("ZZX_SAIDA"))
		
		oMdlZZX:LoadValue( "ZZX_ENTRADA", cHorIni )
		oMdlZZX:LoadValue( "ZZX_SAIDA", cHorFim )
		
		dAloFim := If( HoraToInt(oMdlZZX:GetValue("ZZX_SAIDA")) < HoraToInt(oMdlZZX:GetValue("ZZX_ENTRADA")),; 
						oMdlZZX:GetValue("ZZX_DATA")+1, oMdlZZX:GetValue("ZZX_DATA"))
						
		If oMdlZZX:IsDeleted()	
					
			// Verifica se existe alocação para o atendente
			If At330ExABB(oMdlZZX)  				
				
				nTotHrsTrb := SubtHoras(	oMdlZZX:GetValue("ZZX_DATA"), oMdlZZX:GetValue("ZZX_ENTRADA"),;
											dAloFim, oMdlZZX:GetValue("ZZX_SAIDA") )
				
				aCalAtd := {}			 
				
				aAdd( aCalAtd, { 	.T., oMdlZZX:GetValue("ZZX_DATA"),;									
									AllTrim(oMdlZZX:GetValue("ZZX_ENTRADA")),;
									dAloFim,;
									AllTrim(oMdlZZX:GetValue("ZZX_SAIDA")),;
									AtConvHora(nTotHrsTrb) } ) 
			
				aAgenda := { aCalAtd, nTotHrsTrb, 1 } 
													
				If Len(aAgenda) > 0
				
					aAdd( aDesalocar, { 	oMdlZZX:GetValue("ZZX_ATEND"),;
											oMdlZZX:GetValue("ZZX_NOME"),;
											Posicione("AA1",1,xFilial("AA1")+oMdlZZX:GetValue("ZZX_ATEND"), "AA1_CDFUNC"),;
											oMdlZZX:GetValue("ZZX_TURNO"),;
											oMdlTFF:GetValue("TFF_FUNCAO"),;
											oMdlTFF:GetValue("TFF_CARGO"),;
											aAgenda[1]                   ,;
											aAgenda[2]                   ,;
											aAgenda[3] } )
	
					aAdd( aDesTDV, {	oMdlZZX:GetValue("ZZX_ATEND"),;
			  		 					oMdlZZX:GetValue("ZZX_DATA"),;
			  	    					AllTrim(oMdlZZX:GetValue("ZZX_ENTRADA")),;
			        					dAloFim,;
			       					AllTrim(oMdlZZX:GetValue("ZZX_SAIDA")), {} } )						       	

					aAdd( aDesTDV[Len(aDesTDV),6], aAtend[nPosAtend,14,1] )
				EndIf
							  
			EndIf
			
			//Controle de primeira alocação
			nPosPriDes := aScan(aPriDes, {|x| x[_ULTALOC_KEYTGY] == oMdlZZX:GetValue("ZZX_KEYTGY") .AND. x[_ULTALOC_ITEMTGY] == oMdlZZX:GetValue("ZZX_ITTGY")})
			If nPosPriDes > 0
				//Inclui primeira data e sequencia
				If (oMdlZZX:GetValue("ZZX_DATREF") < aPriDes[nPosPriDes][_ULTALOC_DATA])
					aPriDes[nPosPriDes][_ULTALOC_DATA]  := oMdlZZX:GetValue("ZZX_DATREF")
					aPriDes[nPosPriDes][_ULTALOC_SEQ] 	:= oMdlZZX:GetValue("ZZX_SEQ")
					aPriDes[nPosPriDes][_ULTALOC_LINHA]	:= oMdlZZX:GetLine()
				Else
					aPriDes[nPosPriDes][_ULTALOC_DTF] 	:= oMdlZZX:GetValue("ZZX_DATREF")
				EndIf
			Else
				//Inicia data e sequencia
				aAdd(aPriDes, Array(_ULTALOC_SIZE))
				nPosPriDes := Len(aPriDes)
				aPriDes[nPosPriDes][_ULTALOC_KEYTGY]:= oMdlZZX:GetValue("ZZX_KEYTGY")
				aPriDes[nPosPriDes][_ULTALOC_DATA]	:= oMdlZZX:GetValue("ZZX_DATREF")
				aPriDes[nPosPriDes][_ULTALOC_SEQ]	:= oMdlZZX:GetValue("ZZX_SEQ")
				aPriDes[nPosPriDes][_ULTALOC_ITEMTGY]:= oMdlZZX:GetValue("ZZX_ITTGY")
				aPriDes[nPosPriDes][_ULTALOC_GRUPO]	:= oMdlZZX:GetValue("ZZX_GRUPO")
				aPriDes[nPosPriDes][_ULTALOC_LINHA]	:= oMdlZZX:GetLine()
				aPriDes[nPosPriDes][_ULTALOC_DTF] 	:= oMdlZZX:GetValue("ZZX_DATREF")
			EndIf						  	
			
		Else
			// Verifica se a agenda foi editada, avaliando a necessidade de cancelar a agenda antiga
			If 	lChange
				
				dAloFimOri := If( HoraToInt(aAtend[nPosAtend,_ZZXSAIDA]) < HoraToInt(aAtend[nPosAtend,_ZZXENTRADA]),; 
								aAtend[nPosAtend,_ZZXDATA]+1, aAtend[nPosAtend,_ZZXDATA])						  				
				If !lResTec .And. At330ExABB(oMdlZZX)						  							
					nTotHrsTrb := SubtHoras(	aAtend[nPosAtend,_ZZXDATA], aAtend[nPosAtend,_ZZXENTRADA],;
												dAloFimOri, aAtend[nPosAtend,_ZZXSAIDA] )
					
					aCalAtd := {}
				
					aAdd( aCalAtd, { 	.T., aAtend[nPosAtend,_ZZXDATA],;									
										AllTrim(aAtend[nPosAtend,_ZZXENTRADA]),;
										dAloFimOri,;
										AllTrim(aAtend[nPosAtend,_ZZXSAIDA]),;
										AtConvHora(nTotHrsTrb) } ) 
				
					aAgenda := { aCalAtd, nTotHrsTrb, 1 } 
														
					If Len(aAgenda) > 0
					
						aAdd( aDesalocar, { 	aAtend[nPosAtend,_ZZXATEND],;
												aAtend[nPosAtend,_ZZXNOME],;
												Posicione("AA1",1,xFilial("AA1")+aAtend[nPosAtend,_ZZXATEND], "AA1_CDFUNC"),;
												aAtend[nPosAtend,_ZZXTURNO],;
												oMdlTFF:GetValue("TFF_FUNCAO"),;
												oMdlTFF:GetValue("TFF_CARGO"),;
												aAgenda[1]                   ,;
												aAgenda[2]                   ,;
												aAgenda[3] } )
		
						aAdd( aDesTDV, {	aAtend[nPosAtend,_ZZXATEND],;
				  		 					aAtend[nPosAtend,_ZZXDATA],;
				  	    					AllTrim(aAtend[nPosAtend,_ZZXENTRADA]),;
				        					dAloFimOri,;
				       					AllTrim(aAtend[nPosAtend,_ZZXSAIDA]), {} } )						       	
										
						aAdd( aDesTDV[Len(aDesTDV),6], aAtend[nPosAtend,14,1] )
						
					EndIf							  				
					  				
				EndIf	
				
			EndIf				
		
			If !AllTrim(oMdlZZX:GetValue("ZZX_ENTRADA")) == "FOLGA" .AND. ;
				!AllTrim(oMdlZZX:GetValue("ZZX_SAIDA")) == "FOLGA"
					  					
				// Verifica se não existe alocação para o atendente
				If lChange .Or. !(!lResTec .And. At330ExABB(oMdlZZX)) 
					aIteABQ := At330AABQ( oMdlTFF:GetValue("TFF_CONTRT"),;			 						
												oMdlTFF:GetValue("TFF_PRODUT"),;
												oMdlTFF:GetValue("TFF_LOCAL"),;
												oMdlTFF:GetValue("TFF_FUNCAO"),;  
												oMdlTFF:GetValue("TFF_TURNO"),;
												oMdlTFF:GetValue("TFF_COD"),;
												oMdlTFF:GetValue("TFF_FILIAL") )
					If Len(aIteABQ) > 0
							
						cIdCFal := aIteABQ[1][1]+aIteABQ[1][2]+aIteABQ[1][3]
						
						nTotHrsTrb := SubtHoras(	oMdlZZX:GetValue("ZZX_DATA"), oMdlZZX:GetValue("ZZX_ENTRADA"),;
													dAloFim, oMdlZZX:GetValue("ZZX_SAIDA") )
						
						nTotHor += nTotHrsTrb
						aCalAtd := {}
						
						aAdd( aCalAtd, { 	oMdlZZX:GetValue("ZZX_DATA"),;
											TxRtDiaSem(oMdlZZX:GetValue("ZZX_DATA")),;
											AllTrim(oMdlZZX:GetValue("ZZX_ENTRADA")),;
											AllTrim(oMdlZZX:GetValue("ZZX_SAIDA")),;
											AtConvHora(nTotHrsTrb),;
											oMdlZZX:GetValue("ZZX_SEQ") } ) 
								
						dbSelectArea("TGY")
						TGY->(dbSetOrder(1))
						TGY->(dbSeek(xFilial("TGY")+oMdlZZX:GetValue("ZZX_KEYTGY") ))
						nPosTipMov := AScan(aAlocTipMov,{|x| x[1] == TGY->TGY_TIPALO })
						If nPosTipMov <= 0
							AAdd(aAlocTipMov,{TGY->TGY_TIPALO,{}})
							nPosTipMov := Len(aAlocTipMov)
						EndIf
						
						AAdd(aAlocTipMov[nPosTipMov,2],{ 	oMdlZZX:GetValue("ZZX_ATEND")	,;
															oMdlZZX:GetValue("ZZX_NOME")	,;
															Posicione("AA1",1,xFilial("AA1")+oMdlZZX:GetValue("ZZX_ATEND"), "AA1_CDFUNC"),;
															oMdlZZX:GetValue("ZZX_TURNO")	,;
															oMdlTFF:GetValue("TFF_FUNCAO")	,;
															oMdlTFF:GetValue("TFF_CARGO")	,;
															cIdCFal,;
															""		,;
															""		,;
															aCalAtd							,;
															{} 						,;
															oMdlTFF:GetValue("TFF_LOCAL") })


						aAdd( aAloTDV, {	oMdlZZX:GetValue("ZZX_ATEND"),;
								  		 	oMdlZZX:GetValue("ZZX_DATA"),;
								  	    	AllTrim(oMdlZZX:GetValue("ZZX_ENTRADA")),;
								        	dAloFim,;
								       	AllTrim(oMdlZZX:GetValue("ZZX_SAIDA")), {} } )
								       	
						If Empty(aAtend[nPosAtend,14,1,2])
							aAtend[nPosAtend,14,1,2] := oMdlZZX:GetValue("ZZX_DATREF")
						EndIf										       	
								       	
						aAdd( aAloTDV[Len(aAloTDV),6], aAtend[nPosAtend,14,1] )		
														
						If oMdlZZX:GetValue("ZZX_TIPO") == "E"
							aAloTDV[Len(aAloTDV),6,1,10] := "N"
						ElseIf oMdlZZX:GetValue("ZZX_TIPO") == "I"
							aAloTDV[Len(aAloTDV),6,1,10] := "S"
						ElseIf oMdlZZX:GetValue("ZZX_TIPO") <> aAtend[nPosAtend,_ZZXSITALO]
							aAloTDV[Len(aAloTDV),6,1,10] := oMdlZZX:GetValue("ZZX_TIPO") 
						Endif
											
					EndIf								
								
				EndIf	
			EndIf
			
			//Controle de ultima alocação
			nPosUltAlo := aScan(aUltAloc, {|x| x[_ULTALOC_KEYTGY] == oMdlZZX:GetValue("ZZX_KEYTGY") .AND. x[_ULTALOC_ITEMTGY] == oMdlZZX:GetValue("ZZX_ITTGY")})
			If nPosUltAlo > 0
				//Inclui ultima data e sequencia
				If (oMdlZZX:GetValue("ZZX_DATREF") > aUltALoc[nPosUltAlo][_ULTALOC_DATA])
					aUltALoc[nPosUltAlo][_ULTALOC_DATA] 	:= oMdlZZX:GetValue("ZZX_DATREF")
					If !Empty(oMdlZZX:GetValue("ZZX_SEQ"))
						aUltALoc[nPosUltAlo][_ULTALOC_SEQ]	 	:= oMdlZZX:GetValue("ZZX_SEQ")
					EndIf
					aUltALoc[nPosUltAlo][_ULTALOC_LINHA]	:= oMdlZZX:GetLine()
				EndIf
			Else
				//Inicia data e sequencia
				If oMdlZZX:GetValue("ZZX_SITABB") == "BR_VERDE" .AND. oMdlZZX:GetValue("ZZX_TIPO") $"S|E" 
					aAdd(aUltAloc, Array(_ULTALOC_PREV))
					nPosUltAlo := Len(aUltAloc)
					aUltAloc[nPosUltAlo][_ULTALOC_KEYTGY]	:= oMdlZZX:GetValue("ZZX_KEYTGY")
					aUltAloc[nPosUltAlo][_ULTALOC_DATA]		:= oMdlZZX:GetValue("ZZX_DATREF")
					aUltAloc[nPosUltAlo][_ULTALOC_SEQ]		:= oMdlZZX:GetValue("ZZX_SEQ")			
					aUltAloc[nPosUltAlo][_ULTALOC_ITEMTGY]	:= oMdlZZX:GetValue("ZZX_ITTGY")
					aUltAloc[nPosUltAlo][_ULTALOC_GRUPO]	:= oMdlZZX:GetValue("ZZX_GRUPO")
					aUltALoc[nPosUltAlo][_ULTALOC_LINHA]	:= oMdlZZX:GetLine()
				EndIf
			EndIf
		
		EndIf 	
	EndIf
Next nI

At330UpTGY(aUltAloc, aPriDes, oMdlZZX, Nil)//Atualiza informações do Efetivo(TGY) com base nas alocações e desalocações realizadas

If Len(aDesalocar) > 0
	Begin Transaction
		If isBlind()
			aSaldoCfg := At330GvDes(aDesalocar)
			At330AUpTDV( .T., aDesTDV )
		Else
			MsgRun(STR0048, STR0008,; 	//"Desalocando os atendentes..."###"Processando"
					{ || aSaldoCfg := At330GvDes(aDesalocar) } ) 
					
			MsgRun( STR0049, STR0008,; 	//"Removendo informações da escala..."###"Processando"
					{ || At330AUpTDV( .T., aDesTDV ) } ) 
		EndIf
	End Transaction				
EndIf

If Len(aAlocTipMov) > 0
	Begin Transaction		
		For nI := 1 To Len(aAlocTipMov)
			If isBlind()
				At330GvAlo(aAlocTipMov[nI,2],"CN9",aAlocTipMov[nI,1])
			Else
				MsgRun(STR0050, STR0008,; 	//"Gerando agenda dos atendentes..."###"Processando"
						{ || At330GvAlo(aAlocTipMov[nI][2],"CN9",aAlocTipMov[nI][1],,@aInserted) } )
			EndIf 
		Next nI
				
		dbSelectArea("ABB")
		ABB->(dbSetOrder(1))

		For nI:=1 To Len(aAloTDV)
			If EMPTY(aInserted) .OR. (nAux := ASCAN(aInserted,;
											{|a| a[3] == aAloTDV[nI][1] .AND.;
											a[7] == aAloTDV[nI][2] .AND.;
											a[4] == aAloTDV[nI][3] .AND.;
											a[8] == aAloTDV[nI][4] .AND.;
											a[5] == aAloTDV[nI][5]})) == 0
				cAliasABB 	:= GetNextAlias()
				BeginSql Alias cAliasABB
					SELECT COUNT(ABB_CODIGO) AS CNT,  ABB_CODIGO
					FROM 
					%table:ABB% ABB
					WHERE ABB.ABB_FILIAL = %xFilial:ABB%
						AND ABB.ABB_CODTEC	= %Exp:aAloTDV[nI][1]%
						AND	ABB.ABB_DTINI 	= %Exp:DtoS(aAloTDV[nI][2])% 
						AND	ABB.ABB_HRINI 	= %Exp:aAloTDV[nI][3]% 
						AND	ABB.ABB_DTFIM 	= %Exp:DtoS(aAloTDV[nI][4])% 
						AND	ABB.ABB_HRFIM 	= %Exp:aAloTDV[nI][5]% 
						AND	ABB.ABB_ATIVO 	= '1'
						AND ABB.%notDel%
						GROUP BY ABB_CODIGO  
						ORDER BY ABB_CODIGO
				EndSql
				If valType((cAliasABB)->CNT) == "N"
					If (cAliasABB)->CNT == 1
						aAloTDV[nI,6,1,1] := (cAliasABB)->ABB_CODIGO
					EndIf
				EndIf
				(cAliasABB)->( DbCloseArea() )
			Else
				aAloTDV[nI,6,1,1] := aInserted[nAux][2]
			EndIf
		Next nI
		// Atualiza o saldo de horas do configurador de alocação	
		TxSaldoCfg( cIdCFal, nTotHor, .F. )
		If isBlind()
			At330AUpTDV( .F., aAloTDV )
		Else
			MsgRun( STR0051, STR0008,; 	//"Gerando informações sobre a escala..."###"Processando"
					{ || At330AUpTDV( .F., aAloTDV, @aInserted ) } )
		EndIf
		If TableInDic("TXH")
			At58gGera(aInserted,cEscala,cCodTFF)
		EndIf
	End Transaction			
EndIf

aFilGrp := {}
aFilAte := {}
aAtend  := {}
nGrpFil := 0
cAteFil := ""
ACFLTATND := {}

Return( .T. )

/*/{Protheus.doc} At330UpTGY
Realiza a atualização da sequencia e data de alocação dos efetivos (TGY)


@since 08/01/2015
@version 11.8
@param aUltAloc - Array com as informações de ultima alocação do grupo de funcionários
@param aPriDes - Array com as informações de primeira desalocação do grupo de funcionários
@param oMdlZZX - Model com as informações da alocação por escala
@param aAteAge - Array com as informações da alocação automatica

/*/
Static Function At330UpTGY(aUltAloc, aPriDes, oMdlZZX, aAteAge)
	Local nI := 1
	Local nY := 1
	Local aArea := GetArea()
	Local aAreaTGY := TGY->(GetArea())
	Local aTN5	:= {}
	Local aTN6	:= {}
	Local aInfo := {}
	Local nPos := 0
	Local nPosDes := 0 //nPos para identifição de desalocar
	Local nPosAloc := 0//nPos para identifição de desalocar
	Local cTurno := ""
	Local aSeqs	:= {}
	Local cSeq := ""
	Local cFilSRA		:= ""
	Local dUltDatRef := STOD("")//COntrole da ultima data de referencia verificada	
	Local aLinhaAg := {}//Linha da agenda
	Local nT		:= 1 
	Local aAloc		:= aClone(aUltAloc)
	Local aRDesAloc	:= {} 
	Local lHasAbbR	:= .F.
	Local lAtDfTGY	:= SuperGetMv("MV_ATDFTGY",,.F.)
	Local lTrfEfet	:= IsInCallStack("At190TrEft") 
	Local lMdtGS 	:= SuperGetMv("MV_NG2GS",.F.,.F.) .And. TableInDic("TN5") .And. TableInDic("TN6")//Parâmetro de integração entre o SIGAMDT x SIGATEC 
	Local cQueryTN5	:= ""
	Local nRecTar	:= 0
	Local dDtIniMdt	:= sTod("")
	Local lNewMdt	:= .F.
	Local lAlocMtFil:= .F.
	Local lGsMDTFil := ExistBlock("GsMDTFil")
	Local cCDFUNC 	:= ""
	
	If aPriDes != Nil 
		aRDesAloc := aClone(aPriDes)
	EndIf
	
	//Verifica sequencia por Escala e Grupo para atualizar controle de ultima alocação
	For nI := 1 To Len(aUltAloc)
		nPos := aScan(aInfo, {|x| x[_ULTALOC_KEYTGY] == aUltAloc[nI][_ULTALOC_KEYTGY] .AND.  x[_ULTALOC_GRUPO] == aUltAloc[nI][_ULTALOC_GRUPO]})
		
		If nPos > 0
			//considera maior data
			If aInfo[nPos][_ULTALOC_DATA] < aUltAloc[nI][_ULTALOC_DATA]
				aInfo[nPos] := aUltAloc[nI]
			EndIf
		Else
			aAdd(aInfo, aUltAloc[nI])
		EndIf
	Next nI
	
	If aPriDes != Nil .Or. Len(aRDesAloc) > 0
		//verifica sequencia dos itens desalocados para atualizar controle de ultima alocação
		For nI := 1 To Len(aPriDes)
			
			//Caso não encontra alocação verifica a sequencia da primeira desalocação		
			If 0 == aScan(aUltAloc, {|x| x[_ULTALOC_KEYTGY] == aPriDes[nI][_ULTALOC_KEYTGY] .AND. x[_ULTALOC_ITEMTGY] == aPriDes[nI][_ULTALOC_ITEMTGY]})
				
				nPos := aScan(aInfo, {|x| x[_ULTALOC_KEYTGY] == aPriDes[nI][_ULTALOC_KEYTGY] .AND. x[_ULTALOC_GRUPO] == aPriDes[nI][_ULTALOC_GRUPO] })
				
				If nPos > 0
					//considera menor data
					If aInfo[nPos][_ULTALOC_DATA] > aPriDes[nI][_ULTALOC_DATA]
						aInfo[nPos] := aPriDes[nI]					
					EndIf
				Else
					aAdd(aInfo, aPriDes[nI])
				EndIf
			EndIf
			
		Next nI	
	EndIf	
	
	//Processamento das informações de efetivos
	For nI:=1 To Len(aInfo)
		nPosDes := aScan(aPriDes, {|x| x[_ULTALOC_KEYTGY] == aInfo[nI][_ULTALOC_KEYTGY] .AND. x[_ULTALOC_GRUPO] == aInfo[nI][_ULTALOC_GRUPO]  .AND. x[_ULTALOC_DATA] == aInfo[nI][_ULTALOC_DATA]})
		nPosAloc := aScan(aUltAloc, {|x| x[_ULTALOC_KEYTGY] == aInfo[nI][_ULTALOC_KEYTGY] .AND. x[_ULTALOC_GRUPO] == aInfo[nI][_ULTALOC_GRUPO]  .AND. x[_ULTALOC_DATA] == aInfo[nI][_ULTALOC_DATA]})
			
		nSeq := 0
		dUltDatRef := STOD("")
		
		//Tratamento para alocação realizada por tela
		If oMdlZZX != Nil 
			//tratamento para inicio da desalocação em dia de folga
			If nPosDes > 0 .AND. Empty(aInfo[nI][_ULTALOC_SEQ]) 
				
				oMdlZZX:GoLine(aInfo[nI][_ULTALOC_LINHA])
				cTurno := oMdlZZX:GetValue("ZZX_TURNO")
				cSeq := oMdlZZX:GetValue("ZZX_SEQ")
							
				//posiciona na primeira data de folga e percorre model contando a continuação da sequencia até encontrar primeiro dia trabalhado
				For nY:=aInfo[nI][_ULTALOC_LINHA] To  oMdlZZX:Length()
					oMdlZZX:GoLine(nY)
					
					If oMdlZZx:GetValue("ZZX_KEYTGY") == aInfo[nI][_ULTALOC_KEYTGY]
						If dUltDatRef != oMdlZZX:GetValue("ZZX_DATREF") .AND. Dow(oMdlZZX:GetValue("ZZX_DATREF")) == 2//considera nova sequencia toda segunda-feira
							nSeq++
						EndIf
							
						If oMdlZZX:GetValue("ZZX_ENTRADA") != "FOLGA" .AND.  oMdlZZX:GetValue("ZZX_SAIDA") != "FOLGA"	
							cSeq := oMdlZZX:GetValue("ZZX_SEQ")
							Exit
						EndIf
						
						dUltDatRef := oMdlZZX:GetValue("ZZX_DATREF")
							
					EndIf			
				Next nY
	
				//Busca sequencia anterior conforme nSeq
				If nSeq > 0				
					nPosSeq := LoadSeqs(aSeqs, cTurno)	//Recupera aSeq							
					aInfo[nI][_ULTALOC_SEQ] := At330aGtSq(aSeqs[nPosSeq][2],cSeq,nSeq, .F.)//Busca sequencia	
				Else
					aInfo[nI][_ULTALOC_SEQ] := cSeq
				EndIf
				
			ElseIf nPosAloc > 0 .AND.  Empty(aInfo[nI][_ULTALOC_SEQ])//Tratamento para final da alocação com folga 
	
				oMdlZZX:GoLine(aInfo[nI][_ULTALOC_LINHA])
				cTurno := oMdlZZX:GetValue("ZZX_TURNO")
				cSeq := oMdlZZX:GetValue("ZZX_SEQ")
						
				//posiciona na ultima data de folga e percorre o model contando a sequencia até a ultima alocação
				For nY:=aInfo[nI][_ULTALOC_LINHA] To 1 Step -1
					oMdlZZX:GoLine(nY)
					
					If oMdlZZx:GetValue("ZZX_KEYTGY") == aInfo[nI][_ULTALOC_KEYTGY]
						If dUltDatRef != oMdlZZX:GetValue("ZZX_DATREF") .AND. Dow(oMdlZZX:GetValue("ZZX_DATREF")) == 2//considera nova sequencia toda segunda-feira
							nSeq++
						EndIf
							
						If oMdlZZX:GetValue("ZZX_ENTRADA") != "FOLGA" .AND.  oMdlZZX:GetValue("ZZX_SAIDA") != "FOLGA"	
							cSeq := oMdlZZX:GetValue("ZZX_SEQ")
							Exit
						EndIf
						
						dUltDatRef := oMdlZZX:GetValue("ZZX_DATREF")
							
					EndIf			
				Next nY
				
				//Busca sequencia posterior conforme nSeq
				If nSeq > 0				
					nPosSeq := LoadSeqs(aSeqs, cTurno)//Recupera aSeq				
					aInfo[nI][_ULTALOC_SEQ] := At330aGtSq(aSeqs[nPosSeq][2],cSeq,nSeq, .T.)	
				Else
					aInfo[nI][_ULTALOC_SEQ] := cSeq			
				EndIf
				
			EndIf
	
			//Aplica regras para troca de sequencia para o dia posterior ou anterior
			If nPosAloc > 0
				If Dow(aInfo[nI][_ULTALOC_DATA]) == 1//Ultima Alocação no domingo
					oMdlZZX:GoLine(aInfo[nI][_ULTALOC_LINHA])
					nPosSeq := LoadSeqs(aSeqs, oMdlZZX:GetValue("ZZX_TURNO"))
					aInfo[nI][_ULTALOC_SEQ] := At330aGtSq(aSeqs[nPosSeq][2],aInfo[nI][_ULTALOC_SEQ], 1, .T. )//Recupera proxima Sequencia
				EndIf
			EndIf
			
		//Tratamento para alocação automatica	
		ElseIf aAteAge != Nil 
						
			If nPosAloc > 0 .AND.  Empty(aInfo[nI][_ULTALOC_SEQ])//Tratamento para final da alocação com folga 
				
				aLinhaAg := aAteAge[aInfo[nI][_ULTALOC_LINHA]]
				cTurno := aLinhaAg[12]
				cSeq := aLinhaAg[13]
						
				//posiciona na ultima data de folga e percorre o model contando a sequencia até a ultima alocação
				For nY:=aInfo[nI][_ULTALOC_LINHA] To  1 Step -1
					aLinhaAg := aAteAge[nY]				
					
					If aLinhaAg[17] == aInfo[nI][_ULTALOC_KEYTGY]
						If dUltDatRef != aLinhaAg[16] .AND. Dow(aLinhaAg[16]) == 2//considera nova sequencia toda segunda-feira
							nSeq++
						EndIf
							
						If aLinhaAg[4] != "FOLGA" .AND.  aLinhaAg[5] != "FOLGA"	
							cSeq := aLinhaAg[13]
							Exit
						EndIf
						
						dUltDatRef := aLinhaAg[16]
							
					EndIf			
				Next nY
				
				//Busca sequencia posterior conforme nSeq
				If nSeq > 0				
					nPosSeq := LoadSeqs(aSeqs, cTurno)//Recupera aSeq				
					aInfo[nI][_ULTALOC_SEQ] := At330aGtSq(aSeqs[nPosSeq][2],cSeq,nSeq, .T.)	
				Else
					aInfo[nI][_ULTALOC_SEQ] := cSeq			
				EndIf
				
			EndIf
	
			//Aplica regras para troca de sequencia para o dia posterior ou anterior
			If nPosAloc > 0
				If Dow(aInfo[nI][_ULTALOC_DATA]) == 1//Ultima Alocação no domingo
					nPosSeq := LoadSeqs(aSeqs, aAteAge[aInfo[nI][_ULTALOC_LINHA]][12]/*Turno*/ )
					aInfo[nI][_ULTALOC_SEQ] := At330aGtSq(aSeqs[nPosSeq][2],aInfo[nI][_ULTALOC_SEQ], 1, .T. )//Recupera proxima Sequencia
				EndIf
			EndIf
			
		EndIf

		
		//Atualiza informações do efetivo		
		TGY->(DbSetOrder(1))//TGY_FILIAL + TGY_ESCALA + TGY_CODTDX + TGY_CODTFF + TGY_ITEM
		
		If !( IsInCallStack('At580BAloc') )
		
			TGY->( DbSeek(xFilial("TGY")+aInfo[nI][_ULTALOC_KEYTGY]) )
					
			While (TGY->(!EOF()) .AND. xFilial("TGY")+aInfo[nI][_ULTALOC_KEYTGY] == TGY->TGY_FILIAL + TGY->TGY_ESCALA + TGY->TGY_CODTDX+ TGY->TGY_CODTFF)
				
				If !lTrfEfet .And. TGY->TGY_GRUPO == aInfo[nI][_ULTALOC_GRUPO]
					RecLock("TGY", .F.)									
						TGY->TGY_SEQ	:= aInfo[nI][_ULTALOC_SEQ]
						
						If nPosDes > 0//ao desalocar considera ultima data valida como a anterior a desalocação
							TGY->TGY_ULTALO	:= aInfo[nI][_ULTALOC_DATA]-1
						Else
							TGY->TGY_ULTALO	:= aInfo[nI][_ULTALOC_DATA]
						EndIf
					MsUnlock()
				ElseIf lTrfEfet .And. TGY->TGY_GRUPO == aInfo[nI][_ULTALOC_GRUPO] .And. TGY->TGY_ITEM == aInfo[nI][_ULTALOC_ITEMTGY]
					RecLock("TGY", .F.)									
						TGY->TGY_SEQ	:= aInfo[nI][_ULTALOC_SEQ]
						
						If nPosDes > 0//ao desalocar considera ultima data valida como a anterior a desalocação
							TGY->TGY_ULTALO	:= aInfo[nI][_ULTALOC_DATA]-1
						Else
							TGY->TGY_ULTALO	:= aInfo[nI][_ULTALOC_DATA]
						EndIf
					MsUnlock()
					If lMdtGS //Integração entre o SIGAMDT x SIGATEC
						// posicina TFF
						DbSelectArea("TFF")
						TFF->( DbSetOrder(1)) //TFF_FILIAL+TFF_COD
					
						//posicina TN5
						dbSelectArea("TN5")
						TN5->(dbSetOrder(1)) //TN5_FILIAL+TN5_CODTAR
						
						If (lMdtGS := (TFF->( ColumnPos("TFF_RISCO")) > 0 .And. TN5->(ColumnPos("TN5_LOCAL")) > 0 .And. TN5->(ColumnPos("TN5_POSTO")) > 0))
					
							//posicina TN6
							dbSelectArea("TN6")
							TN6->(dbSetOrder(1)) //TN6_FILIAL+TN6_CODTAR+TN6_MAT+DTOS(TN6_DTINIC)
							
							cCDFUNC := Posicione("AA1",1,xFilial("AA1")+TGY->TGY_ATEND, "AA1_CDFUNC")
							cFilSRA := Posicione("AA1",1,xFilial("AA1")+TGY->TGY_ATEND, "AA1_FUNFIL") 
							If cFilSRA != cFilAnt
								lAlocMtFil := .T.
							EndIf
							
							If TFF->(DbSeek(xFilial("TFF")+TGY->TGY_CODTFF)) .And.;
							   TFF->TFF_RISCO == "1" .And. !Empty(cCDFUNC)
							   
							   cQueryTN5	:= GetNextAlias()
						
								BeginSql Alias cQueryTN5
								
									SELECT TN5.R_E_C_N_O_ TN5RECNO
									FROM %Table:TN5% TN5
									WHERE TN5.TN5_FILIAL	= %exp:xFilial('TN5')%
										AND TN5.TN5_LOCAL	= %exp:TFF->TFF_LOCAL%
										AND TN5.TN5_POSTO	= %exp:TFF->TFF_FUNCAO% 
										AND TN5.%NotDel%
								EndSql
						
								If (cQueryTN5)->(!EOF())
									nRecTar := (cQueryTN5)->TN5RECNO
								Endif
				
								(cQueryTN5)->(DbCloseArea())
				
								If nRecTar > 0 //Integração entre o SIGAMDT x SIGATEC
									TN5->(DbGoTo(nRecTar)) 
									If !TN6->(dbSeek(xFilial("TN6")+TN5->TN5_CODTAR+cCDFUNC))
										lNewMdt := .T.		
									Else 
										dDtIniMdt := TN6->TN6_DTINIC
									Endif								
								Endif
							Endif	
						Endif
					Endif
					
					If (nRecTar > 0 .And. !Empty(dDtIniMdt)) .Or. (nRecTar > 0 .And. lNewMdt)//Integração entre o SIGAMDT x SIGATEC
						TN5->(DbGoTo(nRecTar))
						If lAlocMtFil .And. lGsMDTFil
							aAdd(aTN5,{"TN5_FILIAL",cFilSRA})
							aAdd(aTN5,{"TN5_NOMTAR",TFF->TFF_LOCAL + " - " + TFF->TFF_FUNCAO})
							aAdd(aTN5,{"TN5_LOCAL",TFF->TFF_LOCAL})
							aAdd(aTN5,{"TN5_POSTO",TFF->TFF_FUNCAO})	

							aAdd(aTN6,{"TN6_FILIAL",cFilSRA})
							aAdd(aTN6,{"TN6_MAT",cCDFUNC})
							aAdd(aTN6,{"TN6_DTINIC",TGY->TGY_DTINI})
							aAdd(aTN6,{"TN6_DTTERM",TGY->TGY_ULTALO})

							ExecBlock("GsMDTFil",.F.,.F.,{aTN5, aTN6} )
						ElseIf !lAlocMtFil
							If !lNewMdt
								If !TN6->(dbSeek(xFilial("TN6")+TN5->TN5_CODTAR+cCDFUNC+Dtos(dDtIniMdt)))
									RecLock("TN6",.T.)
										TN6->TN6_FILIAL	:= xFilial("TN6")
										TN6->TN6_CODTAR	:= TN5->TN5_CODTAR
										TN6->TN6_MAT	:= cCDFUNC
										TN6->TN6_DTINIC	:= TGY->TGY_DTINI
										TN6->TN6_DTTERM	:= TGY->TGY_ULTALO
									TN6->(MsUnLock())
								Else
									RecLock("TN6",.F.)
										TN6->TN6_DTINIC	:= TGY->TGY_DTINI
										TN6->TN6_DTTERM	:= TGY->TGY_ULTALO
									TN6->(MsUnLock())		
								Endif
							Else
								RecLock("TN6",.T.)
									TN6->TN6_FILIAL	:= xFilial("TN6")
									TN6->TN6_CODTAR	:= TN5->TN5_CODTAR
									TN6->TN6_MAT	:= cCDFUNC
									TN6->TN6_DTINIC	:= TGY->TGY_DTINI
									TN6->TN6_DTTERM	:= TGY->TGY_ULTALO
								TN6->(MsUnLock())
							EndIf	
						EndIf	
					Endif
				EndIf			
				
				TGY->(DbSkip())
			End
		Else
			//--Atualiza na geração da agenda	
			If Len(aAloc) > 0 .AND. (nPosAloc > 0)			
				For nT := 1 To Len(aAloc)
					If TGY->(DbSeek(xFilial("TGY") + aAloc[nT][_ULTALOC_KEYTGY] + aAloc[nT][4] ) );
						.AND.( xFilial("TGY") + aAloc[nT][_ULTALOC_KEYTGY] + aAloc[nT][4]  == TGY->TGY_FILIAL + TGY->TGY_ESCALA + TGY->TGY_CODTDX+ TGY->TGY_CODTFF + TGY->TGY_ITEM );
						.AND. ( TGY->TGY_GRUPO == aAloc[nT][_ULTALOC_GRUPO] )
		
						TGY->(RecLock("TGY", .F.))
						TGY->TGY_SEQ := aAloc[nT][_ULTALOC_SEQ]		//-- Sequencia				
						TGY->TGY_ULTALO	:= aAloc[nT][_ULTALOC_DATA]		//-- Dt da Ultima Alocação		
						TGY->( MsUnlock() )
					EndIf
				Next nT
			//--Atualiza na exclusão da agenda (desalocação)	
			ElseIf Len(aRDesAloc) > 0  .AND. (nPosDes > 0)	
				For nT := 1 To Len(aRDesAloc)
					If TGY->(DbSeek(xFilial("TGY") + aRDesAloc[nT][_ULTALOC_KEYTGY] + aRDesAloc[nT][4] ) );
						.AND.( xFilial("TGY") + aRDesAloc[nT][_ULTALOC_KEYTGY] + aRDesAloc[nT][4]  == TGY->TGY_FILIAL + TGY->TGY_ESCALA + TGY->TGY_CODTDX+ TGY->TGY_CODTFF + TGY->TGY_ITEM );
						.AND. ( TGY->TGY_GRUPO == aRDesAloc[nT][_ULTALOC_GRUPO] )
						
						lHasAbbR := hasABBRig(aRDesAloc[nT][_ULTALOC_DTF], TGY->TGY_CODTFF, TGY->TGY_ATEND)
						TGY->(RecLock("TGY", .F.))
						If aRDesAloc[nT][_ULTALOC_DATA] <> TGY->TGY_DTINI .AND. lHasAbbR 
							TGY->TGY_ULTALO	:= aRDesAloc[nT][_ULTALOC_DATA]-1	//-- ao desalocar considera ultima data valida como a anterior a desalocação
						Else
							If !lHasAbbR
								If aRDesAloc[nT][_ULTALOC_DATA] == TGY->TGY_DTINI 
									TGY->TGY_ULTALO	:= CtoD(Space(08))
								Else
									TGY->TGY_ULTALO	:= aRDesAloc[nT][_ULTALOC_DATA]-1
								EndIf
								// Atualiza o campo TGY_DTFIM caso o parâmetro MV_DFDTFIM == .T. e caso não existam agendas futuras para o atendente
								If lAtDfTGY
									TGY->TGY_DTFIM := aRDesAloc[nT][_ULTALOC_DATA]-1
								EndIf
							EndIf
						EndIf
	
						TGY->( MsUnlock() )
					EndIf
				Next nT
			EndIf
		EndIf
	Next nI	
	
	RestArea(aAreaTGY)
	RestArea(aArea)
Return

/*/{Protheus.doc} LoadSeqs
Carrega sequencias do turno por demanda e retorna posição do turno das seqeuncias do turno

@since 14/01/2015

@param aSeqs Array com sequencias dos turnos
@param cTurno Turno a ser consultado no aSeqs

/*/
Static Function LoadSeqs(aSeqs, cTurno)
	Local nPosSeq := 0

	//Carrega aSeqs por demanda
	nPosSeq := aScan(aSeqs, {|x| x[1] == cTurno})
	If nPosSeq == 0
		aAdd(aSeqs, {cTurno, At580GtSeq(cTurno)})
		nPosSeq := Len(aSeqs)
	EndIf
	
Return nPosSeq


/*/{Protheus.doc} At330aGtSq
Retorna numero da sequencia conforme parametros

@since 13/01/2015
@version 11.8
@param aSeqs
@param cSeqAtu Sequencia atual
@param nNumSeq - Quantidade de sequencias a ser recuperada
@param lNext - Indica se deverá ser recuperada proximas sequencias, ou sequencias anteriores
@return String numero da sequencia
/*/
Function At330aGtSq(aSeqs, cSeqAtu, nNumSeq, lNext)
	Local cSeq := cSeqAtu
	Local nPos := 0
	Local nCount := 0
	
	If Len(aSeqs) > 0
		nPos := aScan(aSeqs, {|x| x[2]==cSeqAtu})
		If nPos > 0
		
			//Raliza calculo para percorrer a sequencia até achar a correspondente
			If lNext
				nCount := nNumSeq + nPos
				While (nCount>Len(aSeqs))
					nCount -= Len(aSeqs)			
				End
			Else
				nCount := nPos - nNumSeq						
				While (nCount<=0)
					nCount += Len(aSeqs)			
				End
			EndIf
			
			cSeq := aSeqs[nCount][2]
			
		EndIf
	EndIf
	
	
Return cSeq


//-------------------------------------------------------------------
/*/{Protheus.doc} At330AUpTDV				  
Efetua a manuntenção da tabela com as informações da escala

@sample 	At330AUpTDV(lDeleta,aEscAte)

@param		lDeleta, Boolean, Verifica se a operação é exclusao 
@param		aEscAte, Array, Lista com as informações dos atendentes para
							  gravação

@since		22/07/2014
@version	P11.9
/*/
//-------------------------------------------------------------------
Function At330AUpTDV( lDeleta, aEscAte, aInserted, lAlwaysInsert )

Local lNoFound := .T.
Local aSave    := GetArea()
Local aSaveTDV := TDV->(GetArea())
Local nHorMEN  := 0
Local nHorMAI  := 0
Local nPosArr	:= 0
Local nI
Local lSum444 := TDV->(FieldPos("TDV_FERSAI")) > 0 .AND. TDV->(FieldPos("TDV_FSTPEX")) > 0 .AND. TDV->(FieldPos("TDV_FSEXTN")) > 0 // Verificação de campos para sumula 444
Local lRota := isInCallStack("At581EFET")

DEFAULT lDeleta := .F.
Default aInserted := {}
Default lAlwaysInsert := .F.

DbSelectArea('TDV')
TDV->(DbSetOrder(1)) //TDV_FILIAL+TDV_CODABB

For nI:=1 To Len(aEscAte)
	If lRota
		aEscAte[nI,6,1,10] := 'S'
	EndIf
	nHorMen := 0
	nHorMai := 0

	If Empty(aEscAte[nI][6][1][01])
		Loop
	EndIf
	If !lAlwaysInsert
		lNoFound := !TDV->(DbSeek(xFilial('TDV')+aEscAte[nI][6][1][01]))
	EndIf
	If ! lDeleta
	
		Reclock( "TDV", lNoFound )
			
		TDV_FILIAL	:= xFilial("TDV")
		TDV_CODABB	:= aEscAte[nI][6][1][01] 
		
		If !Empty(aEscAte[nI][6][1][02])
			TDV_DTREF	:= aEscAte[nI][6][1][02]
		EndIf
		
		TDV_TURNO	:= aEscAte[nI,6,1,03]
		TDV_SEQTRN	:= aEscAte[nI,6,1,04]
		TDV_TPEXT	:= aEscAte[nI,6,1,05]
		TDV_TPEXTN	:= aEscAte[nI,6,1,06]
		TDV_NONHOR	:= aEscAte[nI,6,1,07]
		TDV_CODREF	:= aEscAte[nI,6,1,08]
		TDV_INSREP	:= aEscAte[nI,6,1,09]
		TDV_TPDIA	:= aEscAte[nI,6,1,10]
		TDV_HRMEN	:= aEscAte[nI,6,1,18]
		TDV_HRMAI	:= aEscAte[nI,6,1,19]
		TDV_INTVL1	:= aEscAte[nI,6,1,12]
		TDV_INTVL2	:= aEscAte[nI,6,1,13]
		TDV_INTVL3	:= aEscAte[nI,6,1,14]
		TDV_FERIAD	:= aEscAte[nI,6,1,15]
		TDV_FTPEXT	:= aEscAte[nI,6,1,16]
		TDV_FEXTN	:= aEscAte[nI,6,1,17]		
		TDV_GRUPO	:= aEscAte[nI,6,1,20]
		If lSum444
			TDV_FERSAI	:= aEscAte[nI,6,1,21]
			TDV_FSTPEX	:= aEscAte[nI,6,1,22]
			TDV_FSEXTN	:= aEscAte[nI,6,1,23]
		EndIf		
		
		TDV->(MsUnlock())
		If (nPosArr := ASCAN(aInserted, {|a| a[2] == aEscAte[nI][6][1][01] .AND. !EMPTY(a[2]) })) > 0
			aInserted[nPosArr][10] := aEscAte[nI][6][1][02]
		EndIf
	Else 

		If !lNoFound
			Reclock('TDV',.F.)
			TDV->(DbDelete())
			TDV->(MsUnlock())
		EndIf	
		
	EndIf		

Next nI

RestArea(aSaveTDV)
RestArea(aSave)

Return(Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} At330AloAut
Efetua a alocação automatica dos atendentes

@sample 	At330AloAut( cEscIni, cEscFim, cCntIni, cCntFim, cLocIni, cLocFim, dDataIni, dDataFim, cClienteDe, cLojaDe, cClienteAt, cLojaAte, cSupDe, cSupAte, cCodAtend, cCodigoTFF )


@param		cEscIni - Escala Inicial para a alocação
@param		cEscFim - Escala Final para a alocação
@param		cCntIni - Contrato Inicial para a alocação
@param		cCntFim - Contrato Final para a alocação
@param		cLocIni - Local Inicial para alocação
@param		cLocFim - Local Final para alocação
@param		dDataIni - Data inicial para a alocação
@param		dDataFim - Data final para a alocação
@param		cClienteDe - Contrato Inicial para a alocação
@param		cLojaDe - Contrato Final para a alocação
@param		cClienteAt - Local Inicial para alocação
@param		cLojaAte - Local Final para alocação
@param		cSupDe - Supervisor de
@param		cSupAte - Supervisor ate
@param		cCodAtend - Codigo do Atendente
@param		cCodigoTFF - Codigo da TFF
@param		cAtendRt   - Atendente da Rota de cobertura
@param 		lExibe	- Indica se vai exibir as perguntas e avisos na tela

@since		22/07/2014
@version	P11.9
/*/
//-------------------------------------------------------------------
Function At330AloAut( cEscIni, cEscFim, cCntIni, cCntFim, cLocIni, cLocFim,;
					 dDataIni, dDataFim, cClienteDe, cLojaDe, cClienteAt, cLojaAte,;
					 cSupDe, cSupAte, cCodAtend, cCodigoTFF, cAtendRt,lExibe, cCodRota,;
					 lMVLote, aAgendas, cSeq, cAtendFlex, lSemEftTrn, cCodRtItem )

Local aArea     := GetArea()
Local lRet 	  := .F.
Local cAliasTFF := GetNextAlias()
Local aAteEsc   := {}
Local aAteAge   := {}
Local aAteCob   := {}
Local aAteEfe   := {}
Local aCalAtd   := {}
Local aAloTDV   := {}
Local aMotAlocar:= {}
Local aIteABQ   := {}
Local cIdCFal   := ""
Local nTotHor  	:= 0
Local nPosMot   := 0
Local nPosUltAlo := 0
Local aUltAloc := {}
Local dDtIniAlo := STOD("")
Local dDtFimAlo := STOD("")
Local lHasCnflt	:= .F.
Local aLstCnflt 	:= {}
Local aCnflt		:= nil
Local aRestrOp 	:= {}
Local nPosRest  := 0
Local lGerConf	:= .F.
Local lTrfEfet	:= isInCallStack("At190TrEft")  //Troca de Efetivo
Local lVerPerm := .F.
Local nPos, nTotHrsTrb, cEscala, cCalend, nI, dAloFim, cCodTFF, cFilTFF
Local lGesHr	:= SuperGetMV('MV_GSGEHOR',,.F.) .And. at330ColHR() 
Local cAliasABB 	:= ""
Local aInserted := {}
Local cMsg		:= ""
Local lRtFolg	:= (isInCallStack("At581Efet") .And. TW0->(ColumnPos("TW0_TIPO")) > 0 .And. (Posicione("TW0",1,xFilial("TW0") + cCodRota , "TW0_TIPO") == "1"))
Local nX		
Local aFeriados := {}

Default cEscIni 	:= " "
Default cEscFim 	:= " "
Default cCntIni 	:= " "
Default cCntFim 	:= " "
Default cLocIni 	:= " "
Default cLocFim 	:= " "
Default dDataIni	:= CtoD("  /  /    ")
Default dDataFim 	:= CtoD("  /  /    ")
Default cClienteDe	:= " "
Default cLojaDe 	:= " "
Default cClienteAt	:= " "
Default cLojaAte 	:= " "
Default cSupDe		:= " "
Default cSupAte 	:= " "
Default cCodAtend   := ""
Default cCodigoTFF  := ""
Default cAtendRt	:= ""
Default lExibe		:= .T.
Default cCodRota	:= ""
Default lMVLote		:= .F. //Indica se foi chamado pela movimentação em lote da Rota
Default aAgendas	:= {}
Default cSeq		:= ""
Default cAtendFlex	:= ""
Default lSemEftTrn	:= .F.
Default cCodRtItem	:= ""


If !Empty(cCodigoTFF)
	BeginSql Alias cAliasTFF
		
		SELECT 
			TFF.TFF_FILIAL, TFF.TFF_COD, TFF.TFF_ESCALA, 
			TFF.TFF_CALEND, TFF.TFF_CONTRT, TFF.TFF_LOCAL, 
			TFF.TFF_PRODUT, TFF.TFF_PERINI,	TFF.TFF_PERFIM, 
			TFF.TFF_FUNCAO, TFF.TFF_CARGO,  TFF.TFF_TURNO, 
			TFJ.TFJ_CODENT, TFJ.TFJ_LOJA ,  TFJ.TFJ_CODIGO,
			ABS.ABS_DESCRI
		FROM 
			%table:TFF% TFF
		JOIN %table:ABS% ABS 
			   ON ABS.ABS_FILIAL = %xFilial:ABS%
			   AND ABS.ABS_LOCAL  = TFF.TFF_LOCAL	      
			   AND ABS.D_E_L_E_T_ = ' '
		JOIN %table:TFL% TFL ON 
			TFL.TFL_FILIAL = %xFilial:TFL%    AND 
			TFL.TFL_CODIGO = TFF.TFF_CODPAI   AND 
			TFL.%NotDel%
		JOIN %table:TFJ% TFJ ON 
			TFJ.TFJ_FILIAL = %xFilial:TFJ%    AND 
			TFJ.TFJ_CODIGO = TFL.TFL_CODPAI   AND 
			TFJ.%NotDel%		
		WHERE 
			TFF.TFF_FILIAL = %xFilial:TFF%    AND 
			TFF.TFF_COD    = %Exp:cCodigoTFF% AND
			TFF.%NotDel%
	EndSql

Else

	BeginSql Alias cAliasTFF
		
		SELECT 
			TFF.TFF_FILIAL, TFF.TFF_COD, TFF.TFF_ESCALA, 
			TFF.TFF_CALEND, TFF.TFF_CONTRT, TFF.TFF_LOCAL, 
			TFF.TFF_PRODUT, TFF.TFF_PERINI,	TFF.TFF_PERFIM, 
			TFF.TFF_FUNCAO, TFF.TFF_CARGO, TFF.TFF_TURNO, 
			TFJ.TFJ_CODENT, TFJ.TFJ_LOJA, ABS.ABS_DESCRI
		FROM 
			%table:TFF% TFF
		JOIN %table:ABS% ABS 
			   ON ABS.ABS_FILIAL = %xFilial:ABS%
			   AND ABS.ABS_LOCAL  = TFF.TFF_LOCAL	      
			   AND ABS.D_E_L_E_T_ = ' '
		JOIN %table:TFL% TFL ON 
			TFL.TFL_FILIAL = %xFilial:TFL% AND 
			TFL.TFL_CODIGO = TFF.TFF_CODPAI AND 
			TFL.%NotDel%
		JOIN %table:TFJ% TFJ ON 
			TFJ.TFJ_FILIAL = %xFilial:TFJ% AND 
			TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND 
			TFJ.%NotDel%
		LEFT JOIN %table:TGS% TGS ON 
			TGS.TGS_FILIAL = %xFilial:TGS% AND 
			TGS.TGS_REGIAO = ABS.ABS_REGIAO AND
			TGS.%NotDel%		
		WHERE 
			TFF.TFF_FILIAL = %xFilial:TFF%  AND 
			TFF.TFF_CODSUB = '      '		AND
			TFF.TFF_ENCE <> '1' AND
			TFF.TFF_ESCALA >= %Exp:cEscIni% AND 
			TFF.TFF_ESCALA <= %Exp:cEscFim% AND 
			TFF.TFF_CONTRT >= %Exp:cCntIni% AND 
			TFF.TFF_CONTRT <= %Exp:cCntFim% AND
			LTRIM(RTRIM(TFF.TFF_CONTRT)) <> ' ' AND  
			TFF.TFF_LOCAL >= %Exp:cLocIni% AND 
			TFF.TFF_LOCAL <= %Exp:cLocFim% AND 
			((TFF.TFF_PERINI BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%) OR
			(LTRIM(RTRIM(TFF.TFF_PERFIM)) <> ' ' AND 
			TFF.TFF_PERFIM BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%) OR
			(TFF.TFF_PERINI < %Exp:dDataIni% AND 
			(LTRIM(RTRIM(TFF.TFF_PERFIM))=' ' OR TFF.TFF_PERFIM > %Exp:dDataFim%))) AND
			(TFJ.TFJ_CODENT >= %Exp:cClienteDe% AND TFJ.TFJ_CODENT <= %Exp:cClienteAt%) AND
			(TFJ.TFJ_LOJA >= %Exp:cLojaDe% AND TFJ.TFJ_LOJA <= %Exp:cLojaAte%) AND		
			TFF.%NotDel% AND
			(ABS.ABS_REGIAO = ' ' OR (
			TGS.TGS_SUPERV >= %Exp:cSupDe% AND 
			TGS.TGS_SUPERV <= %Exp:cSupAte%)) AND
			TFJ.TFJ_STATUS = '1'
			
	EndSql

EndIf

If (cAliasTFF)->(Eof()) .And. (cAliasTFF)->(Bof()) 
	
	If !IsBlind()
		Help(,,"At330ALOAUT",,STR0052,1,0) // "Não existem agendas disponiveis com essas informações!"
	EndIf
Else
	If (IsBlind() .Or. lTrfEfet .Or. !Empty(cAtendRt) .Or. !lExibe) .Or. MsgYesNo(STR0053, STR0054) //"Deseja realmente gerar todas as alocações ?"#"Atenção"
		 
		dbSelectArea("ABQ")
		ABQ->(dbSetOrder(3))
		
		While (cAliasTFF)->(!Eof())
		
			aAtend  := {}	
			aAteCob := {}
			aAteEfe := {}
			aAloTDV := {}
			aMotAlocar := {}
			nPosMot    := 0
			nTotHor := 0
			aUltAloc := {}
			//recupera data real de alocação dentro do periodo informado considerando inicio e fim de alocação
			dDtIniAlo := If(dDataIni > STOD((cAliasTFF)->TFF_PERINI), dDataIni, STOD((cAliasTFF)->TFF_PERINI))
			dDtFimAlo := If(dDataFim < STOD((cAliasTFF)->TFF_PERFIM), dDataFim, STOD((cAliasTFF)->TFF_PERFIM))
			
			If isBlind() .Or. lMVLote
				If lRtFolg
					aAteEsc := At330AAtend( (cAliasTFF)->TFF_COD, (cAliasTFF)->TFF_ESCALA, dDtIniAlo, dDtFimAlo, cAtendFlex, ,lRtFolg )				
				Else
					aAteEsc := At330AAtend( (cAliasTFF)->TFF_COD, (cAliasTFF)->TFF_ESCALA, dDtIniAlo, dDtFimAlo, cCodAtend )
				Endif
			Else
				If lTrfEfet
					MsgRun( STR0007, STR0008,; 	// "Gerando lista dos atendentes da escala..."#"Processando" 
					{ || aAteEsc := At330AAtend( (cAliasTFF)->TFF_COD, (cAliasTFF)->TFF_ESCALA, dDtIniAlo, dDtFimAlo, cCodAtend,(cAliasTFF)->TFF_CONTRT  ) } )
				Else
					If lRtFolg
						MsgRun( STR0007, STR0008,; 	// "Gerando lista dos atendentes da escala..."#"Processando" 
						{ || aAteEsc := At330AAtend( (cAliasTFF)->TFF_COD, (cAliasTFF)->TFF_ESCALA, dDtIniAlo, dDtFimAlo, cAtendFlex, ,lRtFolg ) } )				
					Else
						MsgRun( STR0007, STR0008,; 	// "Gerando lista dos atendentes da escala..."#"Processando" 
						{ || aAteEsc := At330AAtend( (cAliasTFF)->TFF_COD, (cAliasTFF)->TFF_ESCALA, dDtIniAlo, dDtFimAlo, cCodAtend ) } )				
					Endif
				EndIf	  
			EndIf
			// Verifica se existe restrição operacional para os atendentes
			aRestrOp := TxRestri((cAliasTFF)->TFF_LOCAL)
			
			For nI:=1 To Len(aAteEsc)

				// Verifica se a restrição é de bloqueio no periodo de alocação.
				nPosRest:= aScan(aRestrOp,{|x| x[1] == aAteEsc[nI][_ZZXATEND] .And. ((sTod(x[6]) >= dDtIniAlo .And. sTod(x[6]) <= dDtFimAlo ) .Or. ;
													  	 							( sTod(x[7]) >= dDtIniAlo .And. sTod(x[7]) <= dDtFimAlo ))})
				If nPosRest > 0
					If aRestrOp[nPosRest][8] == '2'
						If AScan(aLstCnflt,{|e| e[1] == (cAliasTFF)->TFF_LOCAL}) > 0
							Loop
						EndIf
						
						// Adiciona no log de conflito
						lHasCnflt := .T.
						
						AAdd(aLstCnflt,;
							{(cAliasTFF)->TFF_LOCAL,;
							(cAliasTFF)->ABS_DESCRI,;
							(cAliasTFF)->TFF_CONTRT,;
							(cAliasTFF)->TFF_ESCALA,;
							aAteEsc[Ni,_ZZXATEND],;
							aAteEsc[Ni,_ZZXNOME],;
							STR0102}) // "BLOQUEIO"

						Loop
					EndIf 
				EndIf
			
				// Consulta e Atualiza o Status: Conflito Atendente
				aCnflt := ChkCfltAlc(dDataIni, dDataFim, aAteEsc[nI,_ZZXATEND])
				
				If aCnflt[1] .or. aCnflt[2] .or. aCnflt[3] .or.  aCnflt[5] 
					
					If !lVerPerm				
						lVerPerm := .T.
						If AT680Perm(NIL, __cUserID, "017")
							If !IsBlind() .And. !isInCallStack("At581Efet")
								lGerConf := MsgYesNo(STR0106)											 																					
							Else
								lGerConf := .T.
							EndIf	
						Else
							lGerConf := .F.						
						EndIf
					EndiF	
					
					lHasCnflt := .T.
					
					AAdd(aLstCnflt,;
						{(cAliasTFF)->TFF_LOCAL,;
							(cAliasTFF)->ABS_DESCRI,;
							(cAliasTFF)->TFF_CONTRT,;
							(cAliasTFF)->TFF_ESCALA,;
							aAteEsc[Ni,_ZZXATEND],;
							aAteEsc[Ni,_ZZXNOME],;
							STR0103}) // "CONFLITO"
				EndIf
				
				If !lGerConf .AND. !isBlind()
					If AScan(aLstCnflt,{|e| e[1] == (cAliasTFF)->TFF_LOCAL}) > 0
						Loop
					EndIf
				EndIf	
				
				If aAteEsc[nI][2] == "Efetivo" 
					nPos := aScan( aAteEfe, { |x|	x[1] == aAteEsc[nI][3] .And. ; //TDX_TURNO
												      	x[2] == aAteEsc[nI][5] .And. ;//TGY_SEQ
												      	x[3] == aAteEsc[nI][12] } )//TDX_COD
					If nPos == 0
						aAdd( aAteEfe, { aAteEsc[nI][3], aAteEsc[nI][5], aAteEsc[nI][12], {} } )
						nPos := Len(aAteEfe)
					EndIf
					
					If !lGesHr 
						aAdd( aAteEfe[nPos,4], {	aAteEsc[nI,1],;  //TGY_GRUPO
					 								aAteEsc[nI,6],;  //TGY_ATEND
													aAteEsc[nI,8],;  //TGY_DTINI
													aAteEsc[nI,9],;  //TGY_DTFIM
													aAteEsc[nI,11],; //TGY_ITEM
													aAteEsc[nI,14],; //TGY_ULTALO
													aAteEsc[nI,15]}) //TGY_TIPALO
					Else
						aAdd( aAteEfe[nPos,4], {	aAteEsc[nI,1],;  //TGY_GRUPO
					 								aAteEsc[nI,6],;  //TGY_ATEND
													aAteEsc[nI,8],;  //TGY_DTINI
													aAteEsc[nI,9],;  //TGY_DTFIM
													aAteEsc[nI,11],; //TGY_ITEM
													aAteEsc[nI,14],; //TGY_ULTALO
													aAteEsc[nI,15],; //TGY_TIPALO													
													aAteEsc[nI,16]}) //Array com a gestão dos horarios
					
					EndIf												
									
				Else // Cobertura
					nPos := aScan( aAteCob, { |x| x[1] == aAteEsc[nI,10] .And. x[2] == aAteEsc[nI,11] } )
					If nPos == 0
						aAdd( aAteCob, { aAteEsc[nI,10], aAteEsc[nI,11], {} } )
						nPos := Len(aAteCob)
					EndIf
					aAdd( aAteCob[nPos,3], {	aAteEsc[nI,1], aAteEsc[nI,6],; 
												aAteEsc[nI,8], aAteEsc[nI,9] } )			
				EndIf		
			
			Next nI
			
			If lHasCnflt 
				lHasCnflt := .F.
				If !IsBlind()
					If !lGerConf
						(cAliasTFF)->(dbSkip())			
						Loop
					EndIf
				EndIf	
			EndIf
			
			cEscala := (cAliasTFF)->TFF_ESCALA
			cCalend := (cAliasTFF)->TFF_CALEND
			cCodTFF := (cAliasTFF)->TFF_COD
			cFilTFF := (cAliasTFF)->TFF_FILIAL
			
			If IsBlind()
				aAteAge := At330AAgAt( aAteEfe, aAteCob, dDtIniAlo, dDtFimAlo, cEscala, cCalend, cCodTFF, cFilTFF, lGerConf, , cCodRota, cSeq, cAtendFlex, lSemEftTrn, cCodRtItem )
			Else
				If !lMVLote
					MsgRun(STR0011, STR0008,;	 // "Gerando agenda dos atendentes da escala selecionados..."#"Processando"
					{ || aAteAge := At330AAgAt( aAteEfe, aAteCob, dDtIniAlo, dDtFimAlo, cEscala, cCalend, cCodTFF, cFilTFF , , , cCodRota, cSeq, cAtendFlex, lSemEftTrn, cCodRtItem ) } )
				Else
					aAteAge := At330AAgAt( aAteEfe, aAteCob, dDtIniAlo, dDtFimAlo, cEscala, cCalend, cCodTFF, cFilTFF , , , cCodRota, cSeq, cAtendFlex, lSemEftTrn, cCodRtItem )
				EndIf 
			EndIf
			
			For nI:=1 To Len(aAteAge)
			
				If !AllTrim(aAteAge[nI,_ZZXENTRADA]) == "FOLGA" .AND. ;
					!AllTrim(aAteAge[nI,_ZZXSAIDA]) == "FOLGA"					
				
					// Verifica se não existe alocação para o atendente
					If ! TxExistAloc( AllTrim(aAteAge[nI,_ZZXATEND]),;
									  aAteAge[nI,_ZZXDATA],;
									  aAteAge[nI,_ZZXENTRADA],;
									  aAteAge[nI,_ZZXDATA],;
									  aAteAge[nI,_ZZXSAIDA],0,,,(cAliasTFF)->TFF_LOCAL)	

						//Verificar se é alocação de rota de cobertura, não deixar realizar alocação dos efetivos dos postos.
						If Empty(cAtendRt) .Or. (!Empty(cAtendRt) .And. cAtendRt == AllTrim(aAteAge[nI,_ZZXATEND]))
							aIteABQ := At330AABQ( (cAliasTFF)->TFF_CONTRT,;												
													(cAliasTFF)->TFF_PRODUT,;
													(cAliasTFF)->TFF_LOCAL,;
													(cAliasTFF)->TFF_FUNCAO,;  
													(cAliasTFF)->TFF_TURNO,;
													(cAliasTFF)->TFF_COD,;
													(cAliasTFF)->TFF_FILIAL)					
							If Len(aIteABQ) > 0
							//If ABQ->( dbSeek( xFilial("ABQ")+(cAliasTFF)->TFF_COD ) )
							
								cIdCFal := ABQ->ABQ_CONTRT+ABQ->ABQ_ITEM+ABQ->ABQ_ORIGEM 
							
								nTotHrsTrb := SubtHoras(	aAteAge[nI,_ZZXDATA], aAteAge[nI,_ZZXENTRADA],;
															aAteAge[nI,_ZZXDATA], aAteAge[nI,_ZZXSAIDA] )
																												
								nTotHor += nTotHrsTrb
								aCalAtd := {}
								
								aAdd( aCalAtd, { 	aAteAge[nI,_ZZXDATA],;
													TxRtDiaSem(aAteAge[nI,_ZZXDATA]),;
													AllTrim(aAteAge[nI,_ZZXENTRADA]),;
													AllTrim(aAteAge[nI,_ZZXSAIDA]),;
													AtConvHora(nTotHrsTrb),;
													aAteAge[nI,_ZZXSEQ] } ) 
													
								nPosMot := AScan(aMotAlocar,{|x| x[1] == aAteAge[nI,17] })	
								If nPosMot <= 0
									AAdd(aMotAlocar,{aAteAge[nI,17],{}})
									nPosMot := Len(aMotAlocar)
								EndIf
								
								AAdd(aMotAlocar[nPosMot,2],{ 	aAteAge[nI,_ZZXATEND]	,;
																aAteAge[nI,_ZZXNOME]		,;
																Posicione("AA1",1,xFilial("AA1")+aAteAge[nI,_ZZXATEND], "AA1_CDFUNC"),;
																aAteAge[nI,_ZZXTURNO]	,;
																(cAliasTFF)->TFF_FUNCAO	,;
																(cAliasTFF)->TFF_CARGO	,;
																ABQ->ABQ_CONTRT+ABQ->ABQ_ITEM+ABQ->ABQ_ORIGEM,;
																""		,;
																""		,;
																aCalAtd							,;
																{} 						,;
																(cAliasTFF)->TFF_LOCAL } )
													
								dAloFim := If( HoraToInt(aAteAge[nI,_ZZXSAIDA]) < HoraToInt(aAteAge[nI,_ZZXENTRADA]),; 
												aAteAge[nI,_ZZXDATA]+1, aAteAge[nI,_ZZXDATA])
								
								aAdd( aAloTDV, {	aAteAge[nI,_ZZXATEND],;
										  		 	aAteAge[nI,_ZZXDATA],;
										  	    	AllTrim(aAteAge[nI,_ZZXENTRADA]),;
										        	dAloFim,;
										       	AllTrim(aAteAge[nI,_ZZXSAIDA]), {} } )
										       	
								aAdd( aAloTDV[Len(aAloTDV),6], aAteAge[nI,14,1] )
							Endif
						EndIf
					EndIf
				EndIf
							
				//Controle de ultima alocação
				nPosUltAlo := aScan(aUltAloc, {|x| x[_ULTALOC_KEYTGY] == aAteAge[nI,17] .AND. x[_ULTALOC_ITEMTGY] == aAteAge[nI][18]})
				If nPosUltAlo > 0
					//Inclui ultima data e sequencia
					If (aAteAge[nI,16] > aUltALoc[nPosUltAlo][_ULTALOC_DATA])
						
						aUltALoc[nPosUltAlo][_ULTALOC_DATA] := aAteAge[nI][16]
						aUltALoc[nPosUltAlo][_ULTALOC_SEQ]	:= aAteAge[nI][14][01][04]
						aUltALoc[nPosUltAlo][_ULTALOC_LINHA]	:= nI///AJUSTAR
					EndIf
				Else
					//Inicia data e sequencia
					aAdd(aUltAloc, Array(_ULTALOC_PREV))
					nPosUltAlo := Len(aUltAloc)
					aUltAloc[nPosUltAlo][_ULTALOC_KEYTGY]	:= aAteAge[nI][17]
					aUltAloc[nPosUltAlo][_ULTALOC_DATA]		:= aAteAge[nI][16]
					aUltALoc[nPosUltAlo][_ULTALOC_SEQ]		:= aAteAge[nI][14][01][04]
					aUltAloc[nPosUltAlo][_ULTALOC_ITEMTGY]	:= aAteAge[nI][18]
					aUltAloc[nPosUltAlo][_ULTALOC_GRUPO]	:= aAteAge[nI][01]
					aUltALoc[nPosUltAlo][_ULTALOC_LINHA]	:= nI//aJUSTAR
				EndIf
			Next nI

			//Se não for rota de cobertura realiza a atualização da TGY
			If Empty(cAtendRt)
				At330UpTGY(aUltAloc, Nil, Nil, aAteAge)//Atualiza informações do Efetivo(TGY) com base nas alocações e desalocações realizadas
			Endif
			
			If Len(aMotAlocar) > 0
				Begin Transaction
					For nPosMot := 1 To Len(aMotAlocar)
						dbSelectArea("TGY")
						TGY->(dbSetOrder(1)) //TGY_FILIAL + TGY_ESCALA + TGY_CODTDX + TGY_CODTFF + TGY_ITEM
						If (isInCallStack("TrocaAten") .AND. !EMPTY(At190eGSRc())) .OR. TGY->(dbSeek(xFilial("TGY")+aMotAlocar[nPosMot,1] ))
							If isInCallStack("TrocaAten") .AND. !EMPTY(At190eGSRc())
								TGY->(dbGoTo(At190eGSRc()))
							EndIf
							If isBlind()
								If isInCallStack("TrocaAten")
									lRet := At330GvAlo(aMotAlocar[nPosMot,2],"CN9",TGY->TGY_TIPALO, , @aInserted, , , , , cCodRtItem)
								Else
									lRet := At330GvAlo(aMotAlocar[nPosMot,2],"CN9",TGY->TGY_TIPALO, , , , , , , cCodRtItem)
								EndIf
							Else
								If isInCallStack("TrocaAten")
									MsgRun( STR0050, STR0008,; 	//"Gerando agenda dos atendentes..."###"Processando"
											{ || lRet := At330GvAlo(aMotAlocar[nPosMot,2],"CN9",TGY->TGY_TIPALO,lExibe,@aInserted, , , ,@cMsg, cCodRtItem) } )
								Else
									If !lMVLote
										If lRtFolg
											MsgRun( STR0050, STR0008,; 	//"Gerando agenda dos atendentes..."###"Processando"
													{ || lRet := At330GvAlo(aMotAlocar[nPosMot,2],"CN9","001",lExibe, @aInserted, , , , , cCodRtItem) } )
										Else
											MsgRun( STR0050, STR0008,; 	//"Gerando agenda dos atendentes..."###"Processando"
													{ || lRet := At330GvAlo(aMotAlocar[nPosMot,2],"CN9",TGY->TGY_TIPALO,lExibe, , , , , , cCodRtItem) } )
										Endif
									Else
										If lRtFolg
											lRet := At330GvAlo(aMotAlocar[nPosMot,2],"CN9","001",lExibe, @aInserted, , , , , cCodRtItem)
										Else
											lRet := At330GvAlo(aMotAlocar[nPosMot,2],"CN9",TGY->TGY_TIPALO,lExibe, , , , , , cCodRtItem)
										Endif
										AADD(aAgendas, ACLONE(aMotAlocar[nPosMot,2]))
									EndIf 
								EndIf
							EndIf
						Else
							If isBlind()
								lRet := At330GvAlo(aMotAlocar[nPosMot,2],"CN9", , , , , , , , cCodRtItem)
							Else
								MsgRun( STR0050, STR0008,; 	//"Gerando agenda dos atendentes..."###"Processando"
										{ || lRet := At330GvAlo(aMotAlocar[PosMot][2],"CN9", , , , , , , , cCodRtItem) } )
							EndIf
						EndIf
					Next nPosMot 
					
					dbSelectArea("ABB")
					ABB->(dbSetOrder(1))  // ABB_FILIAL+ABB_CODTEC+ABB_DTINI+ABB_HRINI+ABB_DTFIM+ABB_HRFIM
						
					For nI:=1 To Len(aAloTDV)
						cAliasABB 	:= GetNextAlias()
						BeginSql Alias cAliasABB
							SELECT COUNT(ABB_CODIGO) AS CNT,  ABB_CODIGO
							FROM 
							%table:ABB% ABB
							WHERE ABB.ABB_FILIAL = %xFilial:ABB%
								AND ABB.ABB_CODTEC	= %Exp:aAloTDV[nI][1]%
								AND	ABB.ABB_DTINI 	= %Exp:DtoS(aAloTDV[nI][2])% 
								AND	ABB.ABB_HRINI 	= %Exp:aAloTDV[nI][3]% 
								AND	ABB.ABB_DTFIM 	= %Exp:DtoS(aAloTDV[nI][4])% 
								AND	ABB.ABB_HRFIM 	= %Exp:aAloTDV[nI][5]% 
								AND	ABB.ABB_ATIVO 	= '1'
								AND ABB.%notDel%
							GROUP BY ABB_CODIGO  
							ORDER BY ABB_CODIGO
						EndSql
						If valType((cAliasABB)->CNT) == "N"
							If (cAliasABB)->CNT == 1
								aAloTDV[nI,6,1,1] := (cAliasABB)->ABB_CODIGO
							EndIf
						EndIf
						(cAliasABB)->( DbCloseArea() )
							
						If aAloTDV[nI][6][1][10] == "E"
							aAloTDV[nI][6][1][10] := "N"
						ElseIf aAloTDV[nI][6][1][10] == "I"
							aAloTDV[nI][6][1][10] := "S"
						EndIf					
					Next nI				
							
					// Atualiza o saldo de horas do configurador de alocação	
					TxSaldoCfg( cIdCFal, nTotHor, .F. )
						
					If isBlind() .Or. lMVLote
						If isInCallStack("TrocaAten") .OR. lRtFolg 
							At330AUpTDV( .F., aAloTDV,@aInserted )
						Else
							At330AUpTDV( .F., aAloTDV )
						Endif
					Else
						If isInCallStack("TrocaAten") .OR. lRtFolg
							MsgRun( STR0051, STR0008,; 	//"Gerando informações sobre a escala..."###"Processando"
									{ || At330AUpTDV( .F., aAloTDV,@aInserted ) } )
						Else
							MsgRun( STR0051, STR0008,; 	//"Gerando informações sobre a escala..."###"Processando"
									{ || At330AUpTDV( .F., aAloTDV ) } )
						Endif
					EndIf
					If TableInDic("TXH") .AND. (isInCallStack("TrocaAten") .OR. lRtFolg)
						For nX := 1 To LEN(aAloTDV)
                            If LEN(aAloTDV[nX]) >= 6 .AND. VALTYPE(aAloTDV[nX][6]) == 'A'
                                If VALTYPE(aAloTDV[nX][6]) == 'A' .AND. !EMPTY(aAloTDV[nX][6])
                                    If VALTYPE(aAloTDV[nX][6][1]) == 'A' .AND. LEN(aAloTDV[nX][6][1]) >= 23
                                        If !EMPTY(aAloTDV[nX][6][1][15])
                                            AADD(aFeriados, ACLONE(aAloTDV[nX]))
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf
                        Next nX
						At58gGera(aInserted,cEscala,cCodTFF,aFeriados,cAtendFlex)
					EndIf
				End Transaction
			EndIf
		
			(cAliasTFF)->(dbSkip())
		
		EndDo

		If !lGerConf .And. !Empty(aLstCnflt) .And. !IsBlind()
			aSort(aLstCnflt,,,{|x,y| x[7]+x[1] < y[7]+y[1]})
			At330AGvLg({'TFF_LOCAL','ABS_DESCRI','TFF_CONTR','TFF_ESCALA','AA1_CODTEC','AA1_NOMTEC','TW2_RESTRI'},aLstCnflt)
		EndIf
		
		If !lRet .And. !Empty(cMsg) .And. isInCallStack("TrocaAten") .And. !IsBlind()
			Help(,,"At330ALOAUT_TrocaEfet",,cMsg,1,0)
		EndIf

	EndIf		
	(cAliasTFF)->(dbCloseArea())
EndIf
	
RestArea(aArea)

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330ATotHor				  	
Tela das informações de horarios de alocação por atendente

@sample 	At330ATotHor(oModel)

@return	Nil 
@author 	Serviços
@since		06/11/2013
@version	P11.90

/*/
//------------------------------------------------------------------------------
Static Function At330ATotHor(oModel)

Local aArea     := GetArea()
Local oMdlTFF   := oModel:GetModel("TFFMASTER")
Local oMdlTGY   := oModel:GetModel("TGYDETAIL")
Local oMdlZZX   := oModel:GetModel("ZZXDETAIL")
Local aCmpDet	  := {}
Local nTotal    := 0
Local nLinTGY   := oMdlTGY:GetLine()  
Local nLinZZX   := oMdlZZX:GetLine()

Local nTotHor, nPosAte, nI, oViewZZX, dDatFim

Local oListBox			//Grid campos
Local oOk					//Objeto Confirma
Local oTop 				//Objeto Panel
Local oMiddle
Local oBottom
Local oDlgCmp

For nI:=1 To oMdlZZX:Length()

	oMdlZZX:GoLine(nI)
	
	If AllTrim(oMdlZZX:GetValue("ZZX_ENTRADA")) == "FOLGA" .And. ;
	   AllTrim(oMdlZZX:GetValue("ZZX_ENTRADA")) == "FOLGA"
	   Loop
	EndIf		 		
	
	If Empty(oMdlZZX:GetValue("ZZX_SAIDA")) .Or. Empty(oMdlZZX:GetValue("ZZX_SAIDA"))
		Loop
	EndIf 
	
	dDatFim := If( HoraToInt(oMdlZZX:GetValue("ZZX_SAIDA")) < HoraToInt(oMdlZZX:GetValue("ZZX_ENTRADA")),;
					oMdlZZX:GetValue("ZZX_DATA")+1, oMdlZZX:GetValue("ZZX_DATA"))
	
	nTotHor := SubtHoras(oMdlZZX:GetValue("ZZX_DATA"), oMdlZZX:GetValue("ZZX_ENTRADA"),;
							dDatFim, oMdlZZX:GetValue("ZZX_SAIDA") )	 
				
	nPosAte := aScan( aCmpDet, { |x| x[1] == oMdlZZX:GetValue("ZZX_ATEND") } )
	
	If nPosAte == 0				
		aAdd( aCmpDet, { 	oMdlZZX:GetValue("ZZX_ATEND")	,;
							oMdlZZX:GetValue("ZZX_NOME")	,;
							nTotHor, AtConvHora(nTotHor) } )
	Else
		aCmpDet[nPosAte,3] := aCmpDet[nPosAte,3] + nTotHor
		aCmpDet[nPosAte,4] := AtConvHora(aCmpDet[nPosAte,3]) 				
	EndIf							
						
	nTotal += nTotHor
								
Next nI

If Len(aCmpDet) > 0

	Define MsDialog oDlgCmp TITLE STR0055 FROM 000, 000 To 450, 540 Pixel // "Total de Horas de Alocação"		
	
	@ 000, 000 MsPanel oTop Of oDlgCmp Size 000, 070 // Coordenada para o panel
	oTop:Align := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
	
	@ 005,005 SAY STR0023 OF oTop PIXEL SIZE 60,9 // "Alocação de"
	@ 015,005 MsGet oMdlTFF:GetValue("TFF_DATINI") OF oTop SIZE 45,10 PIXEL WHEN .F.
	@ 005,060 SAY STR0024 OF oTop PIXEL SIZE 60,9 // "Alocação Ate"
	@ 015,060 MsGet oMdlTFF:GetValue("TFF_DATFIM") OF oTop SIZE 45,10 PIXEL WHEN .F.
	@ 005,115 SAY STR0056 OF oTop PIXEL SIZE 60,9 // "Local"
	@ 015,115 MsGet oMdlTFF:GetValue("TFF_LOCAL") OF oTop SIZE 50,10 PIXEL WHEN .F.
	@ 035,005 SAY STR0025 OF oTop PIXEL SIZE 120,9 // "Descrição"
	@ 045,005 MsGet oMdlTFF:GetValue("TFF_DSCABS") OF oTop SIZE 190,10 PIXEL WHEN .F.
	
	@ 035,205 SAY STR0057 OF oTop PIXEL SIZE 120,9 // "Total de Horas"
	@ 045,205 MsGet AtConvHora(nTotal) OF oTop SIZE 60,10 PIXEL WHEN .F.
				
	@ 000, 000 MsPanel oMiddle Of oDlgCmp Size 000, 150 // Coordenada para o panel
	oMiddle:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)	
		
	// Criação do grid para o panel	
	oListBox := TWBrowse():New(000,000,000,000,,{STR0035,STR0036,STR0058};
													,,oMiddle,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
												      //"Cod. Atend"#"Nome Atend."#"Horas Alocação"	
												       	  
	oListBox:SetArray(aCmpDet) // Atrela os dados do grid com a matriz
	oListBox:bLine := { ||{aCmpDet[oListBox:nAT][1],;
							  aCmpDet[oListBox:nAT][2],;
							  aCmpDet[oListBox:nAT][4]}} // Indica as linhas do grid	
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
	
	// Cria o panel para o botao OK	
	@ 000, 000 MsPanel oBottom Of oDlgCmp Size 000, 012 // Corrdenada para o panel dos botoes (size)
	oBottom:Align := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
	
	// Botao de acao OK	
	@ 000, 000 Button oOk Prompt STR0059  Of oBottom Size 030, 000 Pixel //"Fechar"
	oOk:bAction := { || oDlgCmp:End() }
	oOk:Align   := CONTROL_ALIGN_RIGHT
			
	// Ativa a tela exibindo conforme a coordenada
	Activate MsDialog oDlgCmp Centered
	
Else
	
	Help(,,"At330ATOTH",,STR0060,1,0) // "Não existem atendentes para essa escala!"

EndIf

RestArea(aArea)

//  Atualiza o grid da agenda dos atendentes
oViewZZX := FwViewActive()
oMdlTGY:GoLine(nLinTGY)
oMdlZZX:GoLine(nLinZZX)
oViewZZX:Refresh("ZZX_GRID")
		
Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinZZX				  	
Executa a verificação da edição da linha no grido dos atendentes

@sample 	PreLinZZX(oMdlG, nLine, cAcao, cCampo)

@param 		oMdlG, Objeto, objeto do grid em validação
@param 		nLine, Numerico, linha em ação
@param 		cAcao, Caracter, tipo da ação (DELETE, UNDELETE, etc)
@param 		cCampo, Caracter, campo da ação

@return	Nil 
@author 	Serviços
@since		23/07/2014
@version	P11.90

/*/
//------------------------------------------------------------------------------
Static Function PreLinZZX(oMdlG, nLine, cAcao, cCampo)

Local lOk      := .T.
Local lOkInat	:= .T.
Local lConteudo := .T.
Local cTipoCampo := ""
  
If cAcao == "DELETE"			 
	If oMdlG:GetValue("ZZX_ATEAGE") == "1"	 	
		lOk := .F.
	EndIf	
	
ElseIf cAcao == "UNDELETE"
	If oMdlG:GetValue("ZZX_ATEAGE") == "1"	 	
		lOk := .F.
	EndIf									
ElseIf cAcao == "SETVALUE"		 
	If !(cCampo == "ZZX_SITABB" .Or. cCampo == "ZZX_SITALO")
		If oMdlG:GetValue("ZZX_ATEAGE") == "1"				
			lOk := .F.
		EndIf	
		
		If 	oMdlG:GetValue("ZZX_SITABB") == "BR_LARANJA"//Valida alteração de agendas com manutenção
			lOkInat := .F.
		EndIf	
		
	EndIf
ElseIf cAcao == "CANSETVALUE"
	If nLine == 1 .And. Empty( oMdlG:GetValue("ZZX_DATA") )
		lConteudo := .F.
		If oMdlG:GetValue(cCampo) == Nil
			cTipoCampo := oMdlG:GetStruct():GetProperty(cCampo, MODEL_FIELD_TIPO)
			// atribui um valor padrão quando o conteúdo estiver nulo no campo
			If cTipoCampo $ "C#BT"
				oMdlG:LoadValue(cCampo,"")
			ElseIf cTipoCampo == "N"
				oMdlG:LoadValue(cCampo,0)
			ElseIf cTipoCampo == "D"
				oMdlG:LoadValue(cCampo,CTOD(""))
			ElseIf cTipoCampo == "L"
				oMdlG:LoadValue(cCampo,.F.)
			EndIf
		EndIf 
	EndIf
EndIf	

If !lOk
	Help(,,"AT330AOK",,STR0061,1,0) // "Não é possivel efetuar esta operação para uma agenda atendida!"
ElseIf !lOkInat
	Help(,,"AT330AOK",,STR0076,1,0) // "Não é possivel efetuar esta operação para uma agenda com manutenção!"
EndIf

Return(lOk .AND. lOkInat .AND. lConteudo)


//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinZZX				  	
Executa a verificação dos valores inclusos na linha

@sample 	PosLinZZX(oMdlG, nLine, cAcao, cCampo)

@param 		oMdlG, Objeto, objeto do grid em validação
@param 		nLine, Numerico, linha em ação
@param 		cAcao, Caracter, tipo da ação (DELETE, UNDELETE, etc)
@param 		cCampo, Caracter, campo da ação

@return	Nil 
@author 	Serviços
@since		01/08/2014
@version	P11.90

/*/
//------------------------------------------------------------------------------
Static Function PosLinZZX(oMdlG, nLine, cAcao, cCampo)

Local lOk      := .T.
  
If cAcao == "SETVALUE"
	If cCampo == "ZZX_TIPO" .And. !Empty(oMdlG:GetValue("ZZX_TIPO"))
		If oMdlG:GetValue("ZZX_TIPO") == "D"
			lOk := (oMdlG:GetValue("ZZX_ENTRADA") == "FOLGA" .And. oMdlG:GetValue("ZZX_ENTRADA") == "FOLGA") 
		EndIf
	EndIf		
EndIf	

If !lOk
	Help(,,"AT330APL",,STR0062,1,0) // "Horario de entrada e saida invalido para esse tipo de alocação!"
EndIf

Return(lOk)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AMFil				  	
Executa os filtros do grid da agenda dos atendentes

@sample 	At330AMFil( nTipo, oView, oMdlZZX, cOpcCmb )

@param 		nTipo, Numerico, 1 = Filtro por grupo ou 2 = Filtro por atendente
@param 		oMdlZZX, Objeto, Model utilizado para atualizar os dados
@param 		cOpcCmb, Caracter, Opção do combo para realizar o filtro

@return	Nil 
@author 	Serviços
@since		23/07/2014
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At330AMFil( nTipo, oModel, cOpcCmb )

Local oMdlTGY  := oModel:GetModel("TGYDETAIL")
Local oMdlZZX  := oModel:GetModel("ZZXDETAIL")
Local lIsBlind	:= IsBlind() 
Local oViewZZX 
Local aFilter := {}
Local lAnd := .F.
Local cFiltro := ""
Local cFiltroT := ""
Local lFilterGrd := .F.


If AllTrim(cOpcCmb) == STR0009	// "Todos"
	If nTipo == 1
		nGrpFil  := 0
	Else
		cAteFil  := ""
	EndIf
Else
	If nTipo == 1
		nGrpFil  := Val(cOpcCmb)	
	Else		
		cAteFil := Left(cOpcCmb,nTamCdAte)			
	EndIf
EndIf	
	

If !Empty(nGrpFil)
	lAnd := .T.
	cFiltroT := "ZZX_GRUPO == " + cValTochar(nGrpFil)
	cFiltro += cFiltroT
	
	aAdd( aFilter,  {"ZZX_GRUPO", "FIELD", STR0029+" = "+cValTochar(nGrpFil), cFiltroT , StrTran(cFiltroT, "==", "=")} )
	aAdd( aFilter,  {"==", "OPERATOR", "", "", ""} )
	aAdd( aFilter,  {nGrpFil,"EXPRESSION", "", "", "", "", .T.} )
EndIf

If !Empty(cAteFil)

	If lAnd
		aadd(aFilter, { " .AND. ", "", "", "", ""})
		cFiltro += " .AND. "
	End
	cFiltroT := "ZZX_ATEND == '" +cAteFil + "'"
	cFiltro += cFiltroT
	
	aAdd( aFilter,  {"ZZX_ATEND", "FIELD", STR0035+" = "+cAteFil+"'", cFiltroT , StrTran(cFiltroT, "==", "=")} )
	aAdd( aFilter,  {"==", "OPERATOR", "", "", ""} )
	aAdd( aFilter,  {cAteFil,"EXPRESSION", "", "", "", "", .T.}  )

EndIf


//  Atualiza o grid da agenda dos atendentes
If !lIsBlind
	oViewZZX := FwViewActive()
	
	If ValType(oViewZZX) == 'O'
		lFilterGrd := .T.
		oViewZZX:GetViewObj("ZZX_GRID")[3]:oBrowse:DeleteFilter("01")
		
		oViewZZX:GetViewObj("ZZX_GRID")[3]:oBrowse:AddFilter("ZZX_01", cFiltro,.f.,.t.,"   ",NIL,aFilter,'01') 		
		oViewZZX:GetViewObj("ZZX_GRID")[3]:oBrowse:oFwFilter:ExecuteFilter()
	EndIf
EndIf

If !lFilterGrd
	// Recria o model para o novo filtro	
	oModel:CancelData()
	oModel:DeActivate()
	oModel:Activate()

	oMdlTGY:GoLine(1)
	oMdlZZX:GoLine(1)

	If !lIsBlind .AND. ValType(oViewZZX) == 'O'
		oViewZZX:Refresh()
	EndIf
EndIf

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AVldInf				  	
Valida as informaçoes editadas no grid de alocações de atendentes

@sample 	At330AVldInf( oModel, cCampo )

@param 		oModel, Objeto, Model utilizado para verificar as informações
@param 		cCamp, Caracter, Campo para a consistencia das informações

@return	Nil 
@author 	Serviços
@since		23/07/2014
@version	P11.90

/*/
//------------------------------------------------------------------------------
Static Function At330AVldInf( oModel, cCampo )

Local aArea := GetArea()
Local cCor  := ""
Local lRet  := .T.

Local oViewZZX
Local aCnflt := nil

dbSelectArea("ABB")
ABB->(dbSetOrder(1))

If oModel <> Nil .And. oModel:GetId() == "ZZXDETAIL" .And. !IsInCallStack("InitDados")
	
	lLegend := .F.
			
	If cCampo == "ZZX_ENTRADA" .Or. cCampo == "ZZX_SAIDA"
			
		If oModel:GetValue(cCampo) <> "FOLGA"
			lRet := AtVldHora(AllTrim(oModel:GetValue(cCampo)))
		EndIf
				
	ElseIf cCampo == "ZZX_ATEND"
			
		lRet := ExistCpo( "AA1", oModel:GetValue(cCampo) )
			
	ElseIf cCampo == "ZZX_TIPO"
			
		Do Case
		Case oModel:GetValue(cCampo) == "S" 	; cCor := "BR_VERDE"
		Case oModel:GetValue(cCampo) == "C" 	; cCor := "BR_AMARELO"
		Case oModel:GetValue(cCampo) == "D" 	; cCor := "BR_AZUL"
		Case oModel:GetValue(cCampo) == "E" 	; cCor := "BR_LARANJA"
		Case oModel:GetValue(cCampo) == "I" 	; cCor := "BR_PRETO"
		OtherWise			   						; cCor := "BR_VERMELHO"
		EndCase
					 					 		
		oModel:SetValue( "ZZX_SITALO", cCor )
				
	EndIf
			
	If lRet .And. (!Empty(oModel:GetValue("ZZX_ATEND")) .And. ;
					!Empty(oModel:GetValue("ZZX_DATA")) .And. ;
					!Empty(oModel:GetValue("ZZX_ENTRADA")) .And.;
					!Empty(oModel:GetValue("ZZX_DATA")) .And. ;
					!Empty(oModel:GetValue("ZZX_SAIDA")))
			 
		If ABB->( dbSeek( xFilial("ABB") + ;
				oModel:GetValue("ZZX_ATEND") + ;
				DtoS(oModel:GetValue("ZZX_DATA")) + ;
				AllTrim(oModel:GetValue("ZZX_ENTRADA")) + ;
				DtoS(oModel:GetValue("ZZX_DATA")) + ;
				AllTrim(oModel:GetValue("ZZX_SAIDA")) ) )
			cCor := "BR_VERMELHO"
		Else
			cCor := "BR_VERDE"
		EndIf
				
				// Consulta e Atualiza o Status: Conflito Atendente
		aCnflt := ChkCfltAlc(oModel:GetValue("ZZX_DATA"), oModel:GetValue("ZZX_DATA"), oModel:GetValue("ZZX_ATEND"),;
		 					IIF( oModel:GetValue("ZZX_ENTRADA") <> "FOLGA",oModel:GetValue("ZZX_ENTRADA"),  ), ;
		 					IIF( oModel:GetValue("ZZX_SAIDA") <> "FOLGA",oModel:GetValue("ZZX_SAIDA"),  ), ) 
		If (aCnflt[1] .or. aCnflt[2] .or. aCnflt[3] ) .or. aCnflt[5] .or. aCnflt[4] 
			cCor := "BR_PRETO"
		EndIf
				
		oModel:SetValue( "ZZX_SITABB", cCor )
				
		//  Atualiza o grid da agenda dos atendentes
		If !isBlind()
			oViewZZX := FwViewActive()
			oViewZZX:Refresh("ZZX_GRID")
		EndIf
	Else
		lRet := .F.
		oModel:GetModel():SetErrorMessage(oModel:GetId(),cCampo,oModel:GetModel():GetId(),cCampo,'At330AVldInf',; 
														STR0104, STR0105 ) //"Não há dados na agenda para gravação"
	EndIf
				
	lLegend := .T.
EndIf

RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330APosZZX				  	
Verifica se as informações inclusas estão corretas

@sample 	At330APosZZX(oModel)

@param 		oModel, Objeto, Model utilizado para verificar as informações

@return	Nil 
@author 	Serviços
@since		01/08/2014
@version	P11.90

/*/
//------------------------------------------------------------------------------
Static Function At330APosZZX(oModel)

Local lRet 	 := .T.
Local cEntrada := ""
Local cSaida   := ""
Local lHasConfl := .F.
Local lPermConfl:= AT680Perm(NIL, __cUserID, "017")
Local nI        := 0

For	nI:=1 To oModel:Length()

	oModel:GoLine(nI)
	
	If !Empty(oModel:GetValue("ZZX_ATEND"))
	
		lHasConfl:= oModel:GetValue("ZZX_SITABB") == "BR_PRETO"
		
		// Se existe algum tipo de conflito para a alocação e 
		// caso o usuário atual não tenha permissão de alocação para estes casos
		// invalida a operação e encerra o processo. 
		If lHasConfl .and. !lPermConfl
			Help( ' ', 1, 'TECA330A', , STR0084, 1, 0 )	//"Usuário não tem permissão para realizar alocações com conflitos."
			lRet := .F.
			Exit
		EndIf  
		
		cEntrada := AllTrim(oModel:GetValue("ZZX_ENTRADA"))
		cSaida   := AllTrim(oModel:GetValue("ZZX_SAIDA"))
				
		If 	(cEntrada == "FOLGA" .And. cSaida <> "FOLGA") .Or. ; 
			(cEntrada <> "FOLGA" .And. cSaida == "FOLGA")
			Help(,,"At330APF",,STR0063 + DtoC(oModel:GetValue("ZZX_DATA")) + STR0064 + ;
									oModel:GetValue("ZZX_ATEND"),1,0) // "Tipo de intervalo incorreto para alocação! Dia:" ## " Atendente :"
			lRet := .F.			
		ElseIf (cEntrada == "FOLGA" .And. cSaida == "FOLGA") .And. ;
				oModel:GetValue("ZZX_TIPO") <> "D" .And. ;
				oModel:GetValue("ZZX_TIPO") <> "N" .And. ;
				oModel:GetValue("ZZX_TIPO") <> "C" 
			Help(,,"At330APFS",,STR0065 + DtoC(oModel:GetValue("ZZX_DATA")) + STR0064 + ;
									oModel:GetValue("ZZX_ATEND"),1,0) // "Tipo de trabalho invalido para o intervalo de horarios! Dia:" ## " Atendente :"

			lRet := .F.				
		ElseIf (cEntrada <> "FOLGA" .And. cSaida <> "FOLGA") .And. ;
				oModel:GetValue("ZZX_TIPO") == "D"
			Help(,,"At330APSF",,STR0066 + DtoC(oModel:GetValue("ZZX_DATA")) + STR0064 + ;
									oModel:GetValue("ZZX_ATEND"),1,0) // "Tipo de intervalo incorreto para esse tipo de trabalho! Dia:" ## " Atendente :"				
			lRet := .F.
		EndIf
	Else
		Help( ' ', 1, 'TECA330A', , STR0052, 1, 0 )	//"Não existem agendas disponiveis com essas informações!"
		lRet := .F.
	EndIf

Next nI

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330APosZZX				  	
Verifica se as informações inclusas estão corretas

@sample 	At330APosZZX(oModel)

@param 		oModel, Objeto, Model utilizado para verificar as informações

@return	Nil 
@author 	Serviços
@since		01/08/2014
@version	P11.90

/*/
//------------------------------------------------------------------------------
Function At330AABQ( cContrato, cProduto, cLocal, cFuncao, cTurno, cCodTFF, cFilTFF )

Local aRet  := {} 
Local aArea := GetArea()

Default cFilTFF := xFilial("TFF", cFilAnt )

dbSelectArea("ABQ")
ABQ->(dbSetOrder(1))

If ABQ->( dbSeek( xFilial("ABQ") + cContrato ) )

 	While ABQ->(!EoF()) .And. ;
 		  ABQ->ABQ_CONTRT == cContrato 
 	
 		If ABQ->ABQ_PRODUT <> cProduto
 			ABQ->(dbSkip())
 			Loop 			
 		EndIf
 		
 		If ABQ->ABQ_LOCAL <> cLocal
 			ABQ->(dbSkip())
 			Loop 			
 		EndIf
 		
 		If ABQ->ABQ_FUNCAO <> cFuncao
 			ABQ->(dbSkip())
 			Loop 			
 		EndIf
 		
 		If ABQ->ABQ_TURNO <> cTurno
 			ABQ->(dbSkip())
 			Loop 			
 		EndIf

		If (ABQ->ABQ_FILTFF <> cFilTFF)
			ABQ->(dbSkip())
			Loop
		EndIf	 		
		If (ABQ->ABQ_CODTFF <> cCodTFF)  
			ABQ->(dbSkip())
			Loop
		EndIf
 		
 		aAdd( aRet, { ABQ->ABQ_CONTRT, ABQ->ABQ_ITEM, ABQ->ABQ_ORIGEM } ) 		
 		Exit
 		 	
 	EndDo

EndIf

RestArea(aArea)

Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330ADtCfl				  	
	Realiza uma consulta detalhada dos conflitos de alocação, caso existam.

@sample 	At330ADtCfl(oView)
@param 		oView, Objeto, view sendo utilizada na alocação por escala

@return 	Nil 
@author 	Serviços
@since		20/05/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Static Function At330ADtCfl(oView)
Local uRet			:= Nil
Local oMdlGeral 	:= oView:GetModel()
Local oMdlTGY  	:= oMdlGeral:GetModel("TGYDETAIL")
Local cCodAte		:= oMdlTGY:GetValue("TGY_ATEND")
Local dDtIni		:= CToD('')
Local dDtFin		:= CToD('')

If Empty(oMdlTGY:GetValue("TGY_DTINI")) 
	dDtIni := MV_PAR01
Else
	dDtIni := Max(oMdlTGY:GetValue("TGY_DTINI"),MV_PAR01)
EndIf

If Empty(oMdlTGY:GetValue("TGY_DTFIM")) 
	dDtFin := MV_PAR02
Else
	dDtFin := Min(oMdlTGY:GetValue("TGY_DTFIM"),MV_PAR02)
EndIf

At570Detal(cCodAte,{{dDtIni,"",dDtFin,""}})

Return uRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330Desaloc				  	
	Realiza a remoção da alocação de todos os recursos dentro do período

@sample 	At330Desaloc(oView)
@param 		oView, Objeto, view sendo utilizada na alocação por escala

@return 	Nil 
@author 	Serviços
@since		01/09/2014
@version	P11.90

/*/
//------------------------------------------------------------------------------
Static Function At330Desaloc(oView, lAutomato, oMdlGeral)
Local oMdlAgd
Local cPergAnt  	:= "TEC580BE"
Local cPergDes    := "TEC330A1"

Local lOk      	:= .F.
Local cTxtStatus 	:= STR0067 // "As seguintes alocações não puderam ser desfeitas"
Local cLogStatus 	:= ""
Local nLinMdl  	:= 0
Local nOper 	:= 0 //Operaçao 

Default lAutomato := .F.
Default oMdlGeral := oView:GetModel()


If !lAutomato
	nOper := oView:GetOperation()	
Else
	nOper := oMdlGeral:getOperation()
EndIf


If nOper <> MODEL_OPERATION_VIEW
	oMdlAgd  	:= oMdlGeral:GetModel("ZZXDETAIL")
	
	If lAutomato .OR. ( Pergunte(cPergDes,.T.) .And. ;
		MsgNoYes(STR0068) ) // "Confirma a exclusão das agendas com a data de referência dentro do período?"
		
		// valida se o período informado pelo usuário está dentro do fornecido inicialmente na pesquisa
		If !(FwFldGet("TFF_DATINI") > MV_PAR02 .Or. FwFldGet("TFF_DATFIM") < MV_PAR01 ) 
		
			For nLinMdl := 1 To oMdlAgd:Length()
			
				oMdlAgd:GoLine(nLinMdl)
				
				If !oMdlAgd:IsDeleted() .And. ;
					oMdlAgd:GetValue("ZZX_DATREF") >= MV_PAR01 .And. ;
					oMdlAgd:GetValue("ZZX_DATREF") <= MV_PAR02 .AND.;
					( (Empty(nGrpFil) .OR. nGrpFil == oMdlAgd:GetValue("ZZX_GRUPO")) .AND. ;
					  (Empty(cAteFil) .OR. cAteFil ==  oMdlAgd:GetValue("ZZX_ATEND")) )

					
					
					lOk := oMdlAgd:DeleteLine()
					
					If !lOk
						cLogStatus += I18N( STR0070, ; // "Atendente: #1[codAtd]# - #2[cAtdNome]# Dia Inicial: #3[dInicial]# - Hora Inicial: #4[hInicial]#"
							{ oMdlAgd:GetValue("ZZX_ATEND"), oMdlAgd:GetValue("ZZX_NOME"), ;
								oMdlAgd:GetValue("ZZX_DATA"),oMdlAgd:GetValue("ZZX_ENTRADA") } ) + CRLF
					EndIf
					
				EndIf
				
			Next nLinMdl
		
			If !Empty(cLogStatus) .AND. !lAutomato
				Aviso(STR0069,cLogStatus,{STR0072},2,cTxtStatus,,,.T.) // "Remoção de Agenda" ### "OK"
			EndIf
		
		Else
			MsgAlert( STR0071,; // "Período inserido para o cancelamento não está dentro do período definido para geração das agendas"
						STR0069 ) // "Remoção de Agenda"
		EndIf
	EndIf
	
	//  elimina eventuais erros identificados durante o processamento
	// das exclusões para não bloquear o usuário na tela
	oMdlAgd:DiffuseVoid()  
	Pergunte(cPergAnt,.F.)
	If Valtype(oView) == 'O'
		oView:Refresh() // Atualiza as views
	EndIf
Else
	Help(,,"At330Desaloc",,STR0107,1,0)
EndIf
Return


/*/{Protheus.doc} AtConvHora
Realiza conversão de hora para formato utilizado pela rotina
@since 21/11/2014
@version 12
@param nHora, numérico, Hora no formato Inteiro
@return String, Hora em String no formato utilizado pela rotina
/*/
Static Function AtConvHora(nHoras)
	Local nHora := Int(nHoras)//recupera somente a hora
	Local nMinuto := (nHoras - nHora)*100//recupera somento os minutos	
Return(StrZero(nHora, 2) + ":" + StrZero(nMinuto, 2))


//------------------------------------------------------------------------------
/*/{Protheus.doc} StrHora
	Ajusta o horario para receber o formato correto

@sample 	StrHora(cHora)

@return	cRet - Horario com o formato correto  
@author	Serviços
@since		29/12/2014       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Static Function StrHora(cHora)

Local cRet    := ""
Local cHorRet := AllTrim( cHora )

If cHorRet <> "FOLGA"
	If Len( cHorRet ) < 4
		cHorRet := PadL( cHorRet, 4, "0" )
	EndIf
	
	If At( ":", cHorRet ) == 0
		cHorRet := Left( cHorRet, 2 ) + ":" + Right( cHorRet, 2 )
	EndIf
EndIf	

cRet := cHorRet

Return(cRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AVerABB				  
	Verifca todas as agendas gravadas na ABB para o item do contrato 

@sample 	At330AVerABB(dDatIni, dDatFim, cCodTFF)

@param		dDatIni - Data Inicial para a agenda dos atendentes
@param		dDatFim - Data Final para a agenda dos atendentes
@param		cCodTFF - Codigo do recurso humano para o contrato
@param		cFilTFF - Filial do recurso humano para o contrato

@return	aRet - Lista com todas as agendas geradas no contrato.  
@author	Serviços
@since		30/12/2014       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At330AVerABB( dDatIni, dDatFim, cCodTFF, cFilTFF, cCodTec, cNotIdcFal,lJoinTGY,cCodTDX, cCodItRota )

Local aRet 	  	:= {}
Local cAliasABB := GetNextAlias()
Local cCampos 	:= "%%"
Local lSum444 	:= TDV->(FieldPos("TDV_FERSAI")) > 0 .AND. TDV->(FieldPos("TDV_FSTPEX")) > 0 .AND. TDV->(FieldPos("TDV_FSEXTN")) > 0 // Verificação de campos para sumula 444
Local aTDV 		:= Array(_TDV_PREV)
Local cJoinTGY	:= "%%"
Local cWhereTec := ""

Default cFilTFF 	:= xFilial("TFF", cFilAnt)
Default cCodTec 	:= ""
Default cNotIdcFal 	:= ""
Default lJoinTGY	:= .F.
Default cCodTDX		:= ""
Default cCodItRota  := ""

If lSum444
	If !lJoinTGY
		cCampos := "%, TDV.TDV_FERSAI, TDV.TDV_FSTPEX, TDV.TDV_FSEXTN%"	
	Else
		cCampos := "%"
		cCampos += ", TDV.TDV_FERSAI, TDV.TDV_FSTPEX, TDV.TDV_FSEXTN"
		cCampos += ", TGY.TGY_CODTDX"
		cCampos += "%"
	EndIf
ElseIf lJoinTGY
	cCampos := "%, TGY.TGY_CODTDX%"
EndIf

If !EMPTY(cCodTec)
	cWhereTec += " AND ABB.ABB_CODTEC = '" + cCodTec + "' "
EndIf

If !Empty(cCodItRota)
	cWhereTec += " AND ABB.ABB_CODTW1 = '" + cCodItRota + "' "
Endif

cWhereTec := "%"+cWhereTec+"%"

If lJoinTGY
	cJoinTGY := "%"
	cJoinTGY += "LEFT JOIN " + RetSqlName( "TFF" ) + " TFF ON "
	cJoinTGY +=	"TFF.TFF_COD = ABQ.ABQ_CODTFF AND " 
	cJoinTGY +=	"TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND " 
	cJoinTGY +=	"TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND " 
	cJoinTGY +=	"TFF.D_E_L_E_T_ = ' '"  
	cJoinTGY += "LEFT JOIN " + RetSqlName( "TGY" ) + " TGY ON "
	cJoinTGY +=	"TGY.TGY_ATEND = ABB.ABB_CODTEC AND "
	cJoinTGY +=	"TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND " 
	cJoinTGY +=	"TGY.TGY_CODTFF = TFF.TFF_COD AND "
	cJoinTGY +=	"TGY.TGY_CODTDX = '" + cCodTDX + "' AND "
	cJoinTGY +=	"TGY.D_E_L_E_T_ = ' '"
	cJoinTGY += "%"
EndIf

BeginSql Alias cAliasABB
	
	COLUMN ABB_DTINI AS DATE
	COLUMN ABB_DTFIM AS DATE	
	
	SELECT 
		ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_HRINI, 
		ABB.ABB_HRFIM, ABB.ABB_CODTEC, TDV.TDV_TPDIA, 
		TDV_SEQTRN, ABB.ABB_CODIGO, ABB.ABB_ATENDE, ABB.ABB_MANUT,
		TDV.TDV_DTREF, TDV.TDV_TURNO, TDV.TDV_TPEXT, TDV.TDV_TPEXTN, 
		TDV.TDV_NONHOR, TDV.TDV_CODREF, TDV.TDV_INSREP, TDV.TDV_HRMEN, TDV.TDV_HRMAI,
		TDV.TDV_INTVL1, TDV.TDV_INTVL2, TDV.TDV_INTVL3, TDV.TDV_FERIAD, TDV.TDV_FTPEXT, 
		TDV.TDV_FEXTN, ABB.ABB_IDCFAL %Exp:cCampos%	
	FROM 
		%table:ABQ% ABQ		
	JOIN %table:ABB% ABB ON 
		ABB.ABB_FILIAL = %xFilial:ABB% AND 
		ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND 
		ABB.%NotDel% 			
	JOIN %table:TDV% TDV ON 
		TDV.TDV_FILIAL = %xFilial:TDV% AND
		TDV.TDV_CODABB = ABB.ABB_CODIGO AND 
		( 
			( 
		TDV.TDV_DTREF >= %Exp:dDatIni% AND 
		TDV.TDV_DTREF <= %Exp:dDatFim% 
			) 
		OR 
			( 
				(
			ABB.ABB_DTINI = %Exp:dDatIni% OR ABB.ABB_DTINI = %Exp:dDatIni% 
				) OR
				(
			ABB.ABB_DTFIM = %Exp:dDatFim% OR ABB.ABB_DTFIM = %Exp:dDatFim%
				)
			)
		) AND
		TDV.%NotDel% 
	%Exp:cJoinTGY%
	WHERE 
		ABQ.ABQ_CODTFF = %Exp:cCodTFF% AND 
		ABQ.ABQ_FILTFF = %Exp:cFilTFF% AND
		ABQ.ABQ_FILIAL = %xFilial:ABQ% AND
		ABQ.%NotDel%
		%Exp:cWhereTec%
	GROUP BY 
		ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_HRINI, 
		ABB.ABB_HRFIM, ABB.ABB_CODTEC, TDV.TDV_TPDIA, TDV_SEQTRN, ABB_CODIGO, ABB_ATENDE, ABB_MANUT,
		TDV.TDV_DTREF, TDV.TDV_TURNO, TDV.TDV_TPEXT, TDV.TDV_TPEXTN, TDV.TDV_NONHOR, TDV.TDV_CODREF, TDV.TDV_INSREP, TDV.TDV_HRMEN, TDV.TDV_HRMAI,
		TDV.TDV_INTVL1, TDV.TDV_INTVL2, TDV.TDV_INTVL3, TDV.TDV_FERIAD, TDV.TDV_FTPEXT, TDV.TDV_FEXTN,
		ABB.ABB_IDCFAL %Exp:cCampos%
	ORDER BY
		TDV.TDV_DTREF, ABB.ABB_CODTEC
EndSql

While (cAliasABB)->(!Eof())
	
	aTdv := Array(_TDV_PREV)
	aTdv[_TDV_DTREF] := (cAliasABB)->TDV_DTREF
	aTdv[_TDV_TURNO] := (cAliasABB)->TDV_TURNO
	aTdv[_TDV_TPEXT] := (cAliasABB)->TDV_TPEXT
	aTdv[_TDV_TPEXTN] := (cAliasABB)->TDV_TPEXTN
	aTdv[_TDV_NONHOR] := (cAliasABB)->TDV_NONHOR
	aTdv[_TDV_CODREF] := (cAliasABB)->TDV_CODREF
	aTdv[_TDV_INSREP] := (cAliasABB)->TDV_INSREP
	aTdv[_TDV_HRMEN] := (cAliasABB)->TDV_HRMEN
	aTdv[_TDV_HRMAI] := (cAliasABB)->TDV_HRMAI
	aTdv[_TDV_FERIAD] := (cAliasABB)->TDV_FERIAD
	aTdv[_TDV_FTPEXT] := (cAliasABB)->TDV_FTPEXT
	aTdv[_TDV_FEXTN] := (cAliasABB)->TDV_FEXTN
	aTdv[_TDV_INTVL1] := (cAliasABB)->TDV_INTVL1
	aTdv[_TDV_INTVL2] := (cAliasABB)->TDV_INTVL2
	aTdv[_TDV_INTVL3] := (cAliasABB)->TDV_INTVL3

	If lSum444
		aTdv[_TDV_FERSAI] := (cAliasABB)->TDV_FERSAI
		aTdv[_TDV_FSTPEX] := (cAliasABB)->TDV_FSTPEX
		aTdv[_TDV_FSEXTN] := (cAliasABB)->TDV_FSEXTN
	EndIf	

	aAdd( aRet, { (cAliasABB)->ABB_DTINI,;						 
					(cAliasABB)->ABB_DTFIM,;
					(cAliasABB)->ABB_HRINI,;
					(cAliasABB)->ABB_HRFIM,;
					(cAliasABB)->ABB_CODTEC,;
					(cAliasABB)->TDV_TPDIA,;
					.T.,;
					(cAliasABB)->TDV_SEQTRN,;
					(cAliasABB)->ABB_CODIGO,;
					(cAliasABB)->ABB_ATENDE,;
					aTdv,;
					(cAliasABB)->ABB_MANUT } )

	IF EMPTY(cNotIdcFal)
		cNotIdcFal := (cAliasABB)->ABB_IDCFAL
	EndIf			
	(cAliasABB)->(dbSkip())
EndDo

(cAliasABB)->(dbCloseArea())

Return(aRet) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ChkCfltAlc
	Pesquisa por conflitos de alocação

@sample 	ChkCfltAlc(oModel)

@return	aRet,array,
Estrutura do array:
	[1]-Se possui data de demissão no periodo
	[2]-Se possui data de afastamento no periodo
	[3]-Se possui programação de férias no periodo
	[4]-Se possui conflito de agenda
	[5]-Se possui restrição do RH TXB
	[6]-Se possui conflito de admissão 

@author	Serviços
@since		22/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Function ChkCfltAlc(dAlocDe, dAlocAte, cAtend, cHoraIni, cHoraFim, lUsaStatic, aFieldsQry,;
						aArrConfl, aArrDem, aArrAfast, aArrDFer, aArrDFer2, aArrDFer3, cNotIdcFal, lCheckRT, cFilABB, dDtRef, cIdcFal, aArrAdi)
Local oModel := FwModelActive()
// Ambiente
Local aRet			:= { .F. , .F. , .F. , .F. , .F. , .F. }	// Demissão ; Afastamento ; Ferias ; Conflito de Agenda; TXB - Restrições RH ; Admissão
Local aArea		:= nil
Local cAliasRA	:= ""
Local cQuerie		:= ""

// Ponteiros usados pela função
Local nPosCodTec
Local nPosDTINI
Local nPosDTFIM
Local nPosAtnd	:= 0
Local nRAADMISSA := 0
Local nRADEMISSA := 0
Local nR8DATAINI := 0
Local nR8DATAFIM := 0
Local nRFDATINI := 0
Local nRFDFEPRO1 := 0
Local nRFDFEPRO2 := 0
Local nRFDFEPRO3 := 0
Local nRFDATIN2 := 0
Local nRFDATIN3 := 0
Local nHRINI := 0
Local nHRFIM := 0
Local nDTINI := 0
Local nDTFIM := 0
Local nAtivo	:= 0
Local nLenArConf := 0
//Filtro usado em pesquisa no array aCfltAtnd
Local bFilter		:= {|e| e[nPosCodTec] == cAtend .and. dAlocDe >= e[nPosDTINI] .and. dAlocAte <= e[nPosDTFIM] }

// Regra para verificação de conflito, onde:
// dIA -> Data Inicial da Alocação; 
// dFA -> Data Final da Alocação;
// dIE -> Data Inicial do Evento: (Afastamento ou Férias);
// dFE -> Data Final do Evento: (Afastamento ou Férias);
Local bCnflt		:= {|dIA,dFA,dIE,dFE| (dIA >= dIE .and. dFA <= dFE) .or. ;
										  (dIE >= dIA .and. dIE <= dFA) .or. ;
										  (dFE >= dIA .and. dFE <= dFA) .or. ;
										  (dFE <= dIA .and. (dFE >= dFA .or. Empty(dFA) );
										  )}

// Contadores
Local nI			:= 0
Local nJ			:= 0
Local nX			:= 0

// Auxiliares da Função
Local aAux			:= {}
Local dAux			:= CToD('')
Local nAux			:= 0
Local aHoras := {}
Local nAddABB := 0
Local nAddZZX := 0

Local nHoraIni := 0
Local nHoraFim := 0
Local lGSVERHR := SuperGetMV("MV_GSVERHR",,.F.)
Local aVezes := {}
Local lResRH 	:= TableInDic("TXB") //Restrições de RH
Local lVerABB	:= .F.
Local lSubs550	:= isInCallStack("At550VaSub")
Local lContinua	:= .T.
Local nTXBDtIni	:= 0
Local nTXBDtFim	:= 0
Local nPosCpo	:= 0
Local aCpos := {}
Local lTecr020  := IsInCallStack("TECR020")

Default cHoraIni := ""
Default cHoraFim := ""
Default lUsaStatic := .T.
Default cNotIdcFal := ""
Default lCheckRT := .F.
Default cFilABB	:= xFilial("ABB")
Default dDtRef := StoD("")
Default cIdcFal	:= ""

IF lUsaStatic
	nPosCodTec	:= AScan(aCfltHead,{|e| e == 'AA1_CODTEC'}) 
	nPosDTINI	:= AScan(aCfltHead,{|e| e == 'ABB_DTINI'})
	nPosDTFIM	:= AScan(aCfltHead,{|e| e == 'ABB_DTFIM'})
Else
	nPosCodTec	:= AScan(aFieldsQry,{|e| e == 'AA1_CODTEC'}) 
	nPosDTINI	:= AScan(aFieldsQry,{|e| e == 'ABB_DTINI'})
	nPosDTFIM	:= AScan(aFieldsQry,{|e| e == 'ABB_DTFIM'})
EndIf

If !EMPTY(cHoraIni) .AND. !EMPTY(cHoraFim)
	nHoraIni := VAL(AtJustNum(cHoraIni))
	nHoraFim := VAL(AtJustNum(cHoraFim))
EndIf

IF lUsaStatic
	nPosAtnd := AScan(aCfltAtnd, bFilter)
Else
	nPosAtnd := AScan(aArrConfl, bFilter)
EndIf

If (nPosAtnd == 0)
	aArea		:= GetArea()
	cAliasRA	:= GetNextAlias() 
	If !Empty(cIdcFal) .AND. lSubs550
		cQuerie		:= AT570QryPC(dDtRef, dDtRef, cAtend, cAtend,,.T., cNotIdcFal, lCheckRT)
	Else
		cQuerie		:= AT570QryPC(dAlocDe, dAlocAte, cAtend, cAtend,,.T., cNotIdcFal, lCheckRT)
	EndIf
	
	
	// Recurso utilizado para executar no Embedded SQL
	// Retira-se apenas a primeira ocorrência do termo SELECT
	// E introduz o sinal de percent para a expansão da expressão.
	cQuerie	:= "% " + StrTran(cQuerie, "SELECT", "" , 1 , 1 ) + " %"
	
	// Envia consulta ao banco
	BeginSQL Alias cAliasRA
		
		column ABB_DTINI as Date
		column ABB_DTFIM as Date
		column RA_ADMISSA as Date
		column RA_DEMISSA as Date
		column RF_DATAINI as Date
		column RF_DATINI2 as Date
		column RF_DATINI3 as Date
		column R8_DATAINI as Date
		column R8_DATAFIM as Date
		column RF_DFEPRO1 as Numeric(5,0)
		column RF_DFEPRO2 as Numeric(5,0)
		column RF_DFEPRO3 as Numeric(5,0)
		column DTINI as Date
		column DTFIM as Date
		column DTREF as Date

		SELECT %exp:cQuerie%
		
	EndSQL

	If lResRH
		If lUsaStatic .AND. ASCAN(aCfltHead, "TXB_DTINI") == 0
			AAdd(aCfltHead,"TXB_DTINI")
			AAdd(aCfltHead,"TXB_DTFIM")
		ElseIf !lUsaStatic .AND. ASCAN(aFieldsQry, "TXB_DTINI") == 0
			AAdd(aFieldsQry,"TXB_DTINI")
			AAdd(aFieldsQry,"TXB_DTFIM")
			If lCheckRT .AND. ASCAN(aFieldsQry, "TCU_COD") == 0
				AAdd(aFieldsQry,"TCU_COD")
				AAdd(aFieldsQry,"TCU_RESTEC")
			EndIf
		EndIf
	Endif

	// Avalia o resultado da consulta  
	While !(cAliasRA)->(EOF())
		//Alimenta os array com a posição dos campos na primeira execução
		If Len(aCpos) = 0
			If lUsaStatic
				For nI := 1 To Len(aCfltHead)
					If (nPosCpo := FieldPos(aCfltHead[nI])) > 0
						AAdd(aCpos,nPosCpo)
					EndIf
				Next nI
			Else
				For nI := 1 To Len(aFieldsQry)
					If (nPosCpo := FieldPos(aFieldsQry[nI])) > 0
						AAdd(aCpos,nPosCpo)
					EndIf
				Next nI
			EndIf
		EndIf
		
		//Captura o valor dos campos basedo no array de posição
		For nI := 1 To Len(aCpos)
			AAdd(aAux,FieldGet(aCpos[nI]))
		Next nI
		
		If VALTYPE(oModel) == 'O' .AND. oModel:GetId() == "TECA190F"
			If ASCAN(At190DSMar(), {|a| !EMPTY(a[1]) .AND. a[4] == aAux[20] .AND. a[5] == aAux[21] .AND. a[2] == aAux[18] .AND. a[2] == aAux[19] .AND. a[7] != 'S'}) == 0
				AAdd(aCfltAtnd, aClone(aAux)) // Adiciona à variável estática
			EndIf
		Else
			If lUsaStatic
				AAdd(aCfltAtnd, aClone(aAux)) // Adiciona à variável estática
			Else
				AAdd(aArrConfl, aClone(aAux)) // Adiciona à variável estática
			EndIf
		EndIf
		
		aAux := {}	// Limpa a variável auxiliar 
		
		(cAliasRA)->(DbSkip())
	EndDo
	
	(cAliasRA)->(DbCloseArea())
	
	RestArea(aArea)
	
EndIf
If lUsaStatic
	nPosAtnd := AScan(aCfltAtnd, bFilter)
Else
	nPosAtnd := AScan(aArrConfl, bFilter)
EndIf
// Verifica se a data de alocação possúi algum conflito: Admissão, Demissão, Afastamento ou Férias
If nPosAtnd > 0
	If lUsaStatic
		nRAADMISSA 	:= AScan(aCfltHead,{|e| e == 'RA_ADMISSA'})
		nRADEMISSA 	:= AScan(aCfltHead,{|e| e == 'RA_DEMISSA'})
		nR8DATAINI 	:= AScan(aCfltHead,{|e| e == 'R8_DATAINI'})
		nR8DATAFIM	:= AScan(aCfltHead,{|e| e == 'R8_DATAFIM'})
		nRFDATINI	:= AScan(aCfltHead,{|e| e == 'RF_DATAINI'})
		nRFDFEPRO1	:= AScan(aCfltHead,{|e| e == 'RF_DFEPRO1'})
		nRFDFEPRO2	:= AScan(aCfltHead,{|e| e == 'RF_DFEPRO2'})
		nRFDFEPRO3	:= AScan(aCfltHead,{|e| e == 'RF_DFEPRO3'})
		nRFDATIN2	:= AScan(aCfltHead,{|e| e == 'RF_DATINI2'})
		nRFDATIN3	:= AScan(aCfltHead,{|e| e == 'RF_DATINI3'})
		nHRINI		:= AScan(aCfltHead,{|e| e == 'HRINI'})
		nHRFIM		:= AScan(aCfltHead,{|e| e == 'HRFIM'}) 
		nDTINI		:= AScan(aCfltHead,{|e| e == 'DTINI'})
		nDTFIM		:= AScan(aCfltHead,{|e| e == 'DTFIM'})
		nAtivo		:= AScan(aCfltHead,{|e| e == 'ATIVO'})
		
		If lResRH
			nTXBDtIni := AScan(aCfltHead,{|e| e == 'TXB_DTINI'})
			nTXBDtFim := AScan(aCfltHead,{|e| e == 'TXB_DTFIM'})
		Endif
		aAux := ACLONE(aCfltAtnd)
	Else
		nRAADMISSA 	:= AScan(aFieldsQry,{|e| e == 'RA_ADMISSA'})
		nRADEMISSA 	:= AScan(aFieldsQry,{|e| e == 'RA_DEMISSA'})
		nR8DATAINI 	:= AScan(aFieldsQry,{|e| e == 'R8_DATAINI'})
		nR8DATAFIM	:= AScan(aFieldsQry,{|e| e == 'R8_DATAFIM'})
		nRFDATINI	:= AScan(aFieldsQry,{|e| e == 'RF_DATAINI'})
		nRFDFEPRO1	:= AScan(aFieldsQry,{|e| e == 'RF_DFEPRO1'})
		nRFDFEPRO2	:= AScan(aFieldsQry,{|e| e == 'RF_DFEPRO2'})
		nRFDFEPRO3	:= AScan(aFieldsQry,{|e| e == 'RF_DFEPRO3'})
		nRFDATIN2	:= AScan(aFieldsQry,{|e| e == 'RF_DATINI2'})
		nRFDATIN3	:= AScan(aFieldsQry,{|e| e == 'RF_DATINI3'})
		nHRINI		:= AScan(aFieldsQry,{|e| e == 'HRINI'})
		nHRFIM		:= AScan(aFieldsQry,{|e| e == 'HRFIM'}) 
		nDTINI		:= AScan(aFieldsQry,{|e| e == 'DTINI'})
		nDTFIM		:= AScan(aFieldsQry,{|e| e == 'DTFIM'})
		nAtivo		:= AScan(aFieldsQry,{|e| e == 'ATIVO'})
		
		If lResRH
			nTXBDtIni := AScan(aFieldsQry,{|e| e == 'TXB_DTINI'})
			nTXBDtFim := AScan(aFieldsQry,{|e| e == 'TXB_DTFIM'})
		Endif
		aAux := ACLONE(aArrConfl)
	EndIf
	
	
	For nX := 1 to LEN(aAux)
		If ( nAux := AScan(aAux, bFilter) ) > 0
			AADD(aVezes, nAux)
			For nJ := 1 TO LEN(aAux[nAux])
				aAux[nAux][nJ] := nil
			Next
		EndIf
	Next
	
	// Admissão
	If lUsaStatic
		dAuxI := (ACFLTATND[nPosAtnd][nRAADMISSA] - 1)
		dAuxF := (ACFLTATND[nPosAtnd][nRAADMISSA] - 1)
		If !Empty(cIdcFal) .AND. lSubs550
			aRet[6] :=  !Empty(dAuxI) .AND. dAuxF >= dDtRef
		Else
			aRet[6] :=  !Empty(dAuxI) .AND. dAuxF >= dAlocDe
		EndIf
		If aRet[6]
			Aadd(aDiasAdi,{ACFLTATND[nPosAtnd,2],dAuxI,dAuxF})
		EndIf
	Else
		dAuxI := (aArrConfl[nPosAtnd][nRAADMISSA] - 1)
		dAuxF := (aArrConfl[nPosAtnd][nRAADMISSA] - 1)
		If !Empty(cIdcFal) .AND. lSubs550
			aRet[6] :=  !Empty(dAuxI) .AND. dAuxF >= dDtRef
		Else
			aRet[6] :=  !Empty(dAuxI) .AND. dAuxF >= dAlocDe
		EndIf
		If aRet[6]
			Aadd(aArrAdi,{aArrConfl[nPosAtnd,2],dAuxI,dAuxF})
		EndIf
	EndIf
	
	// Demissao
	If lUsaStatic
		dAuxI := ACFLTATND[nPosAtnd][nRADEMISSA]
		dAuxF := ACFLTATND[nPosAtnd][nRADEMISSA]
		If !Empty(cIdcFal) .AND. lSubs550
			aRet[1] :=  !Empty(dAuxF) .AND. dAuxF <= dDtRef
		Else
			aRet[1] :=  !Empty(dAuxF) .AND. dAuxF <= dAlocAte
		EndIf
		If aRet[1]
			Aadd(aDiasDem,{ACFLTATND[nPosAtnd,2],dAuxI,dAuxF})
		EndIf
	Else
		dAuxI := aArrConfl[nPosAtnd][nRADEMISSA]
		dAuxF := aArrConfl[nPosAtnd][nRADEMISSA]
		If !Empty(cIdcFal) .AND. lSubs550
			aRet[1] :=  !Empty(dAuxF) .AND. dAuxF <= dDtRef
		Else
			aRet[1] :=  !Empty(dAuxF) .AND. dAuxF <= dAlocAte
		EndIf
		If aRet[1]
			Aadd(aArrDem,{aArrConfl[nPosAtnd,2],dAuxI,dAuxF})
		EndIf
	EndIf

	For nJ := 1 To LEN(aVezes)

		// Afastamento
		If lUsaStatic
			dAuxI := ACFLTATND[aVezes[nJ]][nR8DATAINI]
			dAuxF := ACFLTATND[aVezes[nJ]][nR8DATAFIM]
		Else
			dAuxI := aArrConfl[aVezes[nJ]][nR8DATAINI]
			dAuxF := aArrConfl[aVezes[nJ]][nR8DATAFIM]
		EndIf

		If (lContinua := Eval(bCnflt,dAlocDe,dAlocAte,dAuxI,dAuxF)) .AND. !Empty(cIdcFal) .AND. lSubs550
			lContinua := Eval(bCnflt,dDtRef,dDtRef,dAuxI,dAuxF)
		EndIf

		If lContinua // Verificando regras de conflito (bCnflt)
		
			//Não inserir registros duplicados
			If lUsaStatic
				If aScan(aDiasAfast, {|b| b[1] == ACFLTATND[nPosAtnd,2] .and. b[2] == dAuxI .AND. b[3] == dAuxF} ) = 0
					Aadd(aDiasAfast,{ACFLTATND[nPosAtnd,2],dAuxI,dAuxF})
				EndIf
			Else
				If aScan(aArrAfast, {|b| b[1] == aArrConfl[nPosAtnd,2] .and. b[2] == dAuxI .AND. b[3] == dAuxF} ) = 0
					Aadd(aArrAfast,{aArrConfl[nPosAtnd,2],dAuxI,dAuxF})
				EndIf
			EndIf
			aRet[2] := .T.
		EndIf
		
		// Ferias - Verificação dos períodos de férias: 1º
		If lUsaStatic
			dAuxI :=  ACFLTATND[aVezes[nJ]][nRFDATINI]
			dAuxF := (ACFLTATND[aVezes[nJ]][nRFDFEPRO1]	 - 1) + dAuxI
		Else
			dAuxI :=  aArrConfl[aVezes[nJ]][nRFDATINI]
			dAuxF := (aArrConfl[aVezes[nJ]][nRFDFEPRO1]	 - 1) + dAuxI
		EndIf
		
		If (lContinua := Eval(bCnflt,dAlocDe,dAlocAte,dAuxI,dAuxF)) .AND. !Empty(cIdcFal) .AND. lSubs550
			lContinua := Eval(bCnflt,dDtRef,dDtRef,dAuxI,dAuxF)
		EndIf
		// Verificando regras de conflito (bCnflt)
		If lContinua
			If lUsaStatic
				If aScan(aDiasFer, {|b| b[1] == ACFLTATND[nPosAtnd,2] .and. b[2] == dAuxI .AND. b[3] == dAuxF} ) = 0
					Aadd(aDiasFer,{ACFLTATND[nPosAtnd,2],dAuxI,dAuxF})
				EndIf
			Else 
				If aScan(aArrDFer, {|b| b[1] == aArrConfl[nPosAtnd,2] .and. b[2] == dAuxI .AND. b[3] == dAuxF} ) = 0
					Aadd(aArrDFer,{aArrConfl[nPosAtnd,2],dAuxI,dAuxF})
				EndIf
			EndIf
			aRet[3] := .T.
		EndIf	

		// Ferias - Verificação dos períodos de férias: 2º
		If lUsaStatic
			dAuxI :=  ACFLTATND[aVezes[nJ]][nRFDATIN2]
			dAuxF := (ACFLTATND[aVezes[nJ]][nRFDFEPRO2]	 - 1) + dAuxI
		Else
			dAuxI :=  aArrConfl[aVezes[nJ]][nRFDATIN2]
			dAuxF := (aArrConfl[aVezes[nJ]][nRFDFEPRO2]	 - 1) + dAuxI
		EndIf
		// Verificando regras de conflito (bCnflt)
		If (lContinua := Eval(bCnflt,dAlocDe,dAlocAte,dAuxI,dAuxF)) .AND. !Empty(cIdcFal) .AND. lSubs550
			lContinua := Eval(bCnflt,dDtRef,dDtRef,dAuxI,dAuxF)
		EndIf

		If lContinua
			If lUsaStatic
				If aScan(aDiasFer2, {|b| b[1] == ACFLTATND[nPosAtnd,2] .and. b[2] == dAuxI .AND. b[3] == dAuxF} ) = 0
					Aadd(aDiasFer2,{ACFLTATND[nPosAtnd,2],dAuxI,dAuxF})
				EndIf
			Else
				If aScan(aArrDFer2, {|b| b[1] == aArrConfl[nPosAtnd,2] .and. b[2] == dAuxI .AND. b[3] == dAuxF} ) = 0
					Aadd(aArrDFer2,{aArrConfl[nPosAtnd,2],dAuxI,dAuxF})
				EndIf
			EndIf
			aRet[3] := .T.
		EndIf	
		
		// Ferias - Verificação dos períodos de férias: 3º
		If lUsaStatic
			dAuxI :=  ACFLTATND[aVezes[nJ]][nRFDATIN3]
			dAuxF := (ACFLTATND[aVezes[nJ]][nRFDFEPRO3]	 - 1) + dAuxI
		Else
			dAuxI :=  aArrConfl[aVezes[nJ]][nRFDATIN3]
			dAuxF := (aArrConfl[aVezes[nJ]][nRFDFEPRO3]	 - 1) + dAuxI
		EndIf
		// Verificando regras de conflito (bCnflt)
		If (lContinua := Eval(bCnflt,dAlocDe,dAlocAte,dAuxI,dAuxF)) .AND. !Empty(cIdcFal) .AND. lSubs550
			lContinua := Eval(bCnflt,dDtRef,dDtRef,dAuxI,dAuxF)
		EndIf

		If lContinua
			If lUsaStatic
				If aScan(aDiasFer3, {|b| b[1] == ACFLTATND[nPosAtnd,2] .and. b[2] == dAuxI .AND. b[3] == dAuxF} ) = 0
					Aadd(aDiasFer3,{ACFLTATND[nPosAtnd,2],dAuxI,dAuxF})
				EndIf
			Else
				If aScan(aArrDFer3, {|b| b[1] == aArrConfl[nPosAtnd,2] .and. b[2] == dAuxI .AND. b[3] == dAuxF} ) = 0
					Aadd(aArrDFer3,{aArrConfl[nPosAtnd,2],dAuxI,dAuxF})
				EndIf
			EndIf
			aRet[3] := .T.
		EndIf	

		If !lTecr020
			//Conflitos de Agendas
			If lUsaStatic
				dAuxI := ACFLTATND[aVezes[nJ]][nDTINI]
				dAuxF := ACFLTATND[aVezes[nJ]][nDTFIM]
			Else
				dAuxI := aArrConfl[aVezes[nJ]][nDTINI]
				dAuxF := aArrConfl[aVezes[nJ]][nDTFIM]
			EndIf

			lVerABB := .F.
			If Eval(bCnflt,dAlocDe,dAlocAte,dAuxI,dAuxF) .AND.;
				IIF(lUsaStatic,ACFLTATND[aVezes[nJ]][nAtivo],aArrConfl[aVezes[nJ]][nAtivo]) == "1" .AND. !lGSVERHR
				If !Empty(cIdcFal) .AND. lSubs550
					lVerABB := VerAbbRest(cIdcFal, cAtend, dDtRef, cFilABB)
				EndIf
				aRet[4] := .T.	// Verificando regras de conflito (bCnflt)	
			EndIf

			If (lGSVERHR .AND. !aRet[4] .AND. !EMPTY(cHoraIni) .And. !EMPTY(cHoraFim)) .OR. lVerABB
				nAddZZX := IIF(nHoraIni >= nHoraFim, 2400,0)
				If lUsaStatic
					nLenArConf := LEN(ACFLTATND)
				Else
					nLenArConf := LEN(aArrConfl)
				EndIf
				For nX := 1 to nLenArConf
					If lUsaStatic
						If ACFLTATND[nX][2] == cAtend .AND.;
							dAlocDe == ACFLTATND[nX][nDTINI] .AND.;
								dAlocAte == ACFLTATND[nX][nDTFIM]
						
							AADD(aHoras,;
								{;
									ACFLTATND[nX][nHRINI],; 					//[1] Hora de Inicio da Alocação já existente 
									ACFLTATND[nX][nHRFIM],; 					//[2] Hora de Partida da Alocação já existente
									VAL(AtJustNum(ACFLTATND[nX][nHRFIM]) ) <=;
									VAL(AtJustNum(ACFLTATND[nX][nHRINI]) ),;	//[3] .T. se a alocação vira o dia.
									ACFLTATND[nX][nAtivo];						//[4] Agenda ativa
								})
						EndIf
					Else
						If aArrConfl[nX][2] == cAtend .AND.;
							dAlocDe == aArrConfl[nX][nDTINI] .AND.;
								dAlocAte == aArrConfl[nX][nDTFIM]
						
							AADD(aHoras,;
								{;
									aArrConfl[nX][nHRINI],; 					//[1] Hora de Inicio da Alocação já existente 
									aArrConfl[nX][nHRFIM],; 					//[2] Hora de Partida da Alocação já existente
									VAL(AtJustNum(aArrConfl[nX][nHRFIM]) ) <=;
									VAL(AtJustNum(aArrConfl[nX][nHRINI]) ),;	//[3] .T. se a alocação vira o dia.
									aArrConfl[nX][nAtivo];						//[4] Agenda ativa
								})
						EndIf
					EndIf
				Next
				For nX := 1 to Len(aHoras)
				
					If aHoras[nX][3]
						nAddABB := 2400
					Else
						nAddABB := 0
					EndIf
					
					If 	(( nHoraIni > VAL(AtJustNum(aHoras[nX][1])) .AND.;
							nHoraIni < ( VAL(AtJustNum(aHoras[nX][2])) + nAddABB ) );
								.OR.;
						( ( nHoraFim + nAddZZX ) > VAL(AtJustNum(aHoras[nX][1])) .AND.;
							( nHoraFim + nAddZZX ) < ( VAL(AtJustNum(aHoras[nX][2])) + nAddABB ) );
								.OR.;
						( nHoraIni < VAL(AtJustNum(aHoras[nX][1])) .AND.;
							( nHoraFim + nAddZZX ) > ( VAL(AtJustNum(aHoras[nX][2])) + nAddABB ) ))
						If aHoras[nX][4] == "1"
							aRet[4] := .T.
							Exit
						Else
							aRet[4] := .F.
						EndIf
					Else
						aRet[4] := .F.
					EndIf
				Next
			EndIf
		Endif
		
		//Restrições RH
		If !aRet[5] .And. lResRH
			If lUsaStatic
				dAuxI := sTod(ACFLTATND[aVezes[nJ]][nTXBDtIni])
				dAuxF := sTod(ACFLTATND[aVezes[nJ]][nTXBDtFim])
			Else
				dAuxI := sTod(aArrConfl[aVezes[nJ]][nTXBDtIni])
				dAuxF := sTod(aArrConfl[aVezes[nJ]][nTXBDtFim])
			EndIf
			If !Empty(cIdcFal) .AND. lSubs550
				If Eval(bCnflt,dDtRef,dDtRef,dAuxI,dAuxF)
					aRet[5] := .T.	// Verificando regras de conflito (bCnflt)	
				EndIf
			Else
				If Eval(bCnflt,dAlocDe,dAlocAte ,dAuxI,dAuxF)
					aRet[5] := .T.	// Verificando regras de conflito (bCnflt)	
				EndIf
			EndIf
		Endif

	Next
EndIf

Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AGvLg
	Gera Log de operação e apresenta diálogo ao usuário com possibilidade de gravação.

@sample 	At330AGvLg(aHeader,aValues)

@param		aHeader,array,Nome dos campos relativos aos valores do array aValues
@param		aValues,array,Conjunto de dados contendo os valores relativos aos titulos de aHeaders
@return	nil  
@author	Serviços
@since		25/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At330AGvLg(aHeader,aValues)
Local cFileLog	:= ""
Local cPath		:= ""
Local aArea		:= GetArea()
Local nI			:= 0
Local nJ			:= 0
Local bPosSX3		:= {|cField| (POSICIONE('SX3', 2, cField, 'X3_TITULO'), X3TITULO()) }

dbSelectArea("SX3")
dbSetOrder(2)

AutoGrLog(STR0085)	//"LOG - Conflitos/Restrições Operacionais na Alocação Automática"
AutoGrLog(STR0086 + SM0->M0_CODIGO + "/" + SM0->M0_CODFIL)	//"EMPRESA / FILIAL: "
AutoGrLog("-------------------------------------------------------------------------------")

For nI := 1 To Len(aValues)
	For nJ := 1 To Len(aHeader)
		AutoGrLog(Eval(bPosSX3,aHeader[nJ]) + ": " + aValues[nI][nJ])
	Next nJ
	AutoGrLog("-------------------------------------------------------------------------------")
Next nI

AutoGrLog(STR0087 + ': ' + SubStr(cUsuario,7,15))	//"Usuario"

cFileLog := NomeAutoLog()

If cFileLog <> ""
   // A função MostraErro() apaga o arquivo que leu, por isso salve-o.
   MostraErro(cPath,cFileLog)
Endif

RestArea(aArea)
Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330MntAge
Prepara e executa a chamada da tela de manutenção da agenda do atendente.
@sample 	At330MntAge(oView)
@param 		oView, Objeto, view sendo utilizada na alocação por escala
@return	.T. = Processamento OK / .F. = Processamento com críticas  
@author 	Alexandre da Costa
@since		24/09/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At330MntAge(oView)	  
Local aArea		:=	GetArea()
Local aAreaABB	:=	ABB->(GetArea())
Local oMdlGeral 	:=	oView:GetModel()
Local oMdlTFF  	:=	oMdlGeral:GetModel("TFFMASTER")
Local oMdlZZX  	:=	oMdlGeral:GetModel("ZZXDETAIL")
Local cContrato	:=	oMdlTFF:GetValue("TFF_CONTRT")
Local cCodAtend	:=	oMdlZZX:GetValue("ZZX_ATEND")
Local dDt			:=	oMdlZZX:GetValue("ZZX_DATA")
Local nOldLinZZX	:=	oMdlZZX:GetLine()
Local nLinZZX		:=	0
Local nInd			:=	0
Local aMntAgenda	:=	{}	
Local lRet			:=	.T.
Local cMemoLOG	:=	""
Local cContrAnt	:=	""
Local dDataAnt	:=	CtoD(Space(08))
Local cSeparador	:=	" - "

//Valida se a agenda do atendente já foi gerada ou se sofreu manutenção
If	oMdlZZX:GetValue("ZZX_SITABB") == "BR_VERMELHO"	.or.;
	oMdlZZX:GetValue("ZZX_SITABB") == "BR_LARANJA"
	
	//Se houver agenda gerada ou com manutenção prévia, então será possível realizar novas manutenções na mesma...
	ABB->(dBSetOrder(1))	//ABB_FILIAL+ABB_CODTEC+DTOS(ABB_DTINI)+ABB_HRINI+DTOS(ABB_DTFIM)+ABB_HRFIM
	ABB->(dBSeek(xFilial("ABB")+cCodAtend+DtoS(dDt)))	//Posiciona no primeiro horário da data selecionada no GRID
	//
	At540SetAge("0")				//Força a inicialização do array da manutenção da agenda do atendente
	TECA540()						//Executa a rotina de manutenção da agenda, trazendo a agenda do atendente/data posicionados no GRID
	aMntAgenda := At540GetAge()	//Carrega o conteúdo do array da manutenção da agenda do atendente
	aSort( aMntAgenda, Nil, Nil, { |x,y| x[07]+DtoS(x[02])+x[03]+x[06] < y[07]+DtoS(y[02])+y[03]+y[06] } )
	//
	//=====================================================================================================
	//	Atualiza o status da agenda conforme a última posição da sua manutenção
	//	Atualiza o GRID da agenda dos atendentes
	//=====================================================================================================
	oViewZZX	:=	FwViewActive()
	For nInd := 1 to Len(aMntAgenda)
	 	//Certifica-se que a manutenção da agenda é referente ao contrato que está sendo trabalhado no momento
		If	Left(aMntAgenda[nInd,07],Len(cContrato)) == cContrato	//Contrato a qual a agenda que fora selecionada pertence
			If	(nLinZZX := aScan(aAtend,{|x|	x[02] == aMntAgenda[nInd,02] .and.;	//Data inicial
													x[04] == aMntAgenda[nInd,03] .and.;	//Hora inicial
													x[05] == aMntAgenda[nInd,05] .and.;	//Hora final
													x[06] == cCodAtend			 .and.;	//Código do atendente
													x[10] == aMntAgenda[nInd,06] }) ) > 0	//Código da agenda do atendente
				aAtend[nLinZZX,19]	:=	aMntAgenda[nInd,08]	//Agenda ativa?
				oMdlZZX:GoLine(nLinZZX)
				// Atualiza o sinalizador (legenda) da manutenção da agenda do atendente
				If	aAtend[nLinZZX,19] == "1"
					oMdlZZX:LoadValue("ZZX_SITABB","BR_LARANJA")	// Sinaliza que houve uma MANUTENÇÃO DA AGENDA
				Else
					oMdlZZX:LoadValue("ZZX_SITABB","BR_VERMELHO")	// Não há manutenção (Retorna o status p/AGENDA GERADA)
				EndIf			
			EndIf
		Else
			cMemoLOG	:=	If(	Empty(cMemoLOG),;
								STR0092+CRLF,;	//"Algumas agendas que foram selecionadas para manutenção pertencem a outros contratos. Verifique a atualização destas agendas."
								cMemoLOG)
			If	Empty(cContrAnt) .or. Left(aMntAgenda[nInd,07],Len(cContrato)) <> cContrAnt
				cMemoLOG	+=	CRLF+STR0093+Left(aMntAgenda[nInd,07],Len(cContrato))+":"+CRLF	//"Contrato "
				cContrAnt	:=	Left(aMntAgenda[nInd,07],Len(cContrato))
			EndIf
			If	Empty(dDataAnt) .or. aMntAgenda[nInd,02] <> dDataAnt
				cMemoLOG	+=	Space(03)+STR0094+DtoC(aMntAgenda[nInd,02])+CRLF	//"Data: "
				dDataAnt	:=	aMntAgenda[nInd,02]
			EndIf
			cMemoLOG	+=	Space(09)+	STR0095+aMntAgenda[nInd,03]+cSeparador+;	//"Hora inicial: "
										STR0096+aMntAgenda[nInd,05]+CRLF			//"Hora final: "
		EndIf												
	Next nInd
	oMdlZZX:GoLine(nOldLinZZX)
	oViewZZX:Refresh("ZZX_GRID")
	//
	If	!Empty(cMemoLOG)
		AtShowLog(cMemoLog,STR0097)	//"Alocação por escala x Manutenção da agenda do atendente"
	EndIf
	//
Else
	Help(,,"At330MntAge",,STR0091,1,0) // "Não foi possível a execução da manutenção da agenda, pois ela não foi gerada!"
	lRet	:=	.F.
EndIf
RestArea(aAreaABB)
RestArea(aArea)
Return	lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At330AVal				  	
Verifica se as informações inclusas estão corretas

@sample 	At330AVal(oModel)

@param 		oModel, Objeto, Model utilizado para verificar as informações

@return	Nil 
@author 	Serviços
@since		06/11/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Static Function At330AVal(oModel)

Local lRet		:= .T.
Local oMdlTGY	:=oModel:GetModel("TGYDETAIL")
Local xI		:= 0
Local lAviso	:= .F.
Local lBloq		:= .F.

//verifica status dos atendentes


lRet := At330APosZZX(oModel:GetModel('ZZXDETAIL'))

If lRet
	For	xI:=1 To oMdlTGY:Length()
	
		oMdlTGY:GoLine(xI)
		
		If !oMdlTGY:IsDeleted()
			//status do atendente
			
			If oMdlTGY:GetValue("TGYSTATUS") == "BR_LARANJA"
				lAviso := .T.
			Elseif oMdlTGY:GetValue("TGYSTATUS") == "BR_PRETO"	
				lBloq := .T.
				EXIT
			Endif
		Endif
	Next xI
	
	If lBloq
		lRet := .F.
		Help("",1,"At330AVal",,STR0099,2,0) //"Atendente com restrição operacional para o local/cliente"
	ElseIf lAviso
		lRet := msgYesNo(STR0098,STR0100) //"Atendente com restrição operacional de aviso."##"Deseja Continuar?"
		IF !lRet
			Help("",1,"At330AVal",,STR0101,2,0) //"Alocação Cancelada"
		ENDIF 
	EndIf
EndIf
Return(lRet)



//------------------------------------------------------------------------------
/*/{Protheus.doc} at330ColHR				  	
Verifica se existe a coluna TGY_ENTRA1

@sample 	at330ColHR(oModel)

@param 		

@return	Booleano 
@author 	Matheus Lando Raimundo
@since		24/08/201
@version	P12

/*/
//------------------------------------------------------------------------------
Function at330ColHR()
Local lRet := .F.

lRet := TGY->(ColumnPos("TGY_ENTRA1")) > 0

Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At330aDesl
@description Função utilizada nos scripts de automação para executar a Static Function At330aDesl
@author       Mateus Boiani
@since        10/10/2018
@return       At330Desaloc(oView, lAutomato, oModel) - A execução da função At330Desaloc
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330aDesl(oView, lAutomato, oModel)

Return At330Desaloc(oView, lAutomato, oModel)



//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at330aEnts
@description Função que retorna o numero de "movimentações" de um dia trabalhado de acordo com tabela 
				de horario padrão e sequencia
@author       Matheus Lando Raimundo
@since        22/11/2018
@return       nRet
/*/
//--------------------------------------------------------------------------------------------------------------------
Function at330aEnts(cTurno,cSeq)
Local nRet 	 := 0
Local cTempAlias := GetNextAlias() 

BeginSql Alias cTempAlias

	SELECT DISTINCT
	CASE 
		WHEN PJ_ENTRA4 > 0 AND PJ_SAIDA4 > 0 THEN 8 
		WHEN PJ_ENTRA3 > 0 AND PJ_SAIDA3 > 0 THEN 6
		WHEN PJ_ENTRA2 > 0 AND PJ_SAIDA2 > 0 THEN 4
		WHEN PJ_ENTRA1 > 0 AND PJ_SAIDA1 > 0 THEN 2
	END PJ_NUMENT FROM  %table:SPJ% SPJ
	WHERE SPJ.PJ_FILIAL = %xFilial:SPJ% 
		AND PJ_TURNO = %Exp:cTurno%
		AND PJ_SEMANA = %Exp:cSeq%
		AND PJ_TPDIA = 'S'
		AND PJ_ENTRA1 <> 0
		AND SPJ.%NotDel%
	GROUP BY PJ_ENTRA1, PJ_SAIDA1, PJ_ENTRA2, PJ_SAIDA2, PJ_ENTRA3, PJ_SAIDA3, PJ_ENTRA4, PJ_SAIDA4,PJ_TURNO, PJ_SEMANA
EndSQL	

nRet := (cTempAlias)->PJ_NUMENT
(cTempAlias)->(dbCloseArea())
	
Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} a330LdTGY
@description  
				Carga do modelo TGY
@author       Matheus Lando Raimundo
@since        31/01/2018
/*/
//--------------------------------------------------------------------------------------------------------------------
Function a330LdTGY(oModel)
Local dDataIni 	:= MV_PAR01
Local dDataFim 	:= MV_PAR02
Local cApeAge 	:= MV_PAR03
Local cApeFol 	:= MV_PAR04
Local aAteEsc   	:= {}
Local aAteEfe    	:= {}
Local aAteCob    	:= {}
Local aAteAge    	:= {}
Local nPos    	:= 0
Local lAgenda    	:= .F.
Local lDemis		:= .F.
Local lAfast		:= .F.
Local lFerias		:= .F.
Local lCursoVenc	:= .F.
Local aCnflt		:= nil
Local dDtIni		:= CToD('')
Local dDtFin		:= CToD('')
Local nI
Local nX
Local lRetCalend
Local cCalend
Local cEscala
Local cCodTFF
Local cContrato
Local cFilTFF
Local cTipoRest:=""
Local cTpResLoc:=""
Local cTpResCli:=""
Local lGesHr	:= at330ColHR()
Local lUseHr	:= lGesHr .And. SuperGetMV('MV_GSGEHOR',,.F.)
Local aRet := {}
Local aFldPos := {}
Local aAux := {}
Local oStru := oModel:GetStruct()
Local nLenFlds := 1
Local aFields := {}
Local lEfetivo := .T.
Local aAuxCob	:= {}

cEscala 	:= TFF->TFF_ESCALA
cCalend 	:= TFF->TFF_CALEND
cCodTFF 	:= TFF->TFF_COD
cContrato 	:= TFF->TFF_CONTRT

If isBlind()
	aAteEsc := At330AAtend( TFF->TFF_COD, TFF->TFF_ESCALA, MV_PAR01, MV_PAR02 )
Else
	MsgRun(STR0007, STR0008,; //"Gerando lista dos atendentes da escala..."#"Processando" 
	{ || aAteEsc := At330AAtend( TFF->TFF_COD, TFF->TFF_ESCALA, MV_PAR01, MV_PAR02 ) } )
	If (FindFunction("At580bAt") .And. TecHasPerg("MV_PAR05","TEC580BE")) .And. !Empty(MV_PAR05)
		aAteEsc := At580bEsc(aAteEsc)
	EndIf
	
EndIf

aSort( aAteEsc, Nil, Nil, { |x,y| AllTrim(Str(x[1]))+x[3]+x[5]+DtoS(x[8])<AllTrim(Str(y[1]))+y[3]+y[5]+DtoS(y[8]) } )


aFields := oStru:GetFields()
nLenFlds := Len(aFields) 
 
For nI := 1 To Len(aAteEsc)
	TGY->(DbSeek(xFilial('TGY') + TFF->TFF_ESCALA + aAteEsc[nI,12] + TFF->TFF_COD + aAteEsc[nI,11]  ))
	aAux := Array(nLenFlds)
	
	lEfetivo := aAteEsc[nI,2] == "Efetivo"
			
	For nX := 1 To nLenFlds
		cField := aFields[nX, MODEL_FIELD_IDFIELD]
		
		If cField == 'TGY_FILIAL'
			aAux[nX] := xFilial('TGY')
		ElseIf cField == 'TGY_ESCALA'
			aAux[nX] := TFF->TFF_ESCALA 
		ElseIf cField == 'TGY_CODTDX'
			aAux[nX] := aAteEsc[nI,12]
		ElseIf cField == 'TGY_ITEM'
			aAux[nX] := aAteEsc[nI,11]			
		ElseIf cField == 'TGY_ATEND'
			aAux[nX] := aAteEsc[nI,6]
		ElseIf cField == 'TGY_NOME'
			aAux[nX] := aAteEsc[nI,7]
		ElseIf cField == 'TGY_TURNO'
			aAux[nX] := aAteEsc[nI,3]	
		ElseIf cField == 'TGY_DESC'
			aAux[nX] := aAteEsc[nI,4]		
		ElseIf cField == 'TGY_SEQ'
			aAux[nX] := aAteEsc[nI,5]
		ElseIf cField == 'TGY_DTINI'
			aAux[nX] := aAteEsc[nI,8]	
		ElseIf cField == 'TGY_DTFIM'
			aAux[nX] := aAteEsc[nI,9]	
		ElseIf cField == 'TGY_GRUPO'
			aAux[nX] := aAteEsc[nI,1]
		ElseIf cField == 'TGY_CODTFF'
			aAux[nX] := TFF->TFF_COD
		ElseIf cField == 'TGY_ULTALO'
			aAux[nX] := aAteEsc[nI,14]
		ElseIf cField == 'TGY_TIPALO'
			aAux[nX] := aAteEsc[nI,15]
		ElseIf cField == 'TGY_DESMOV'
			aAux[nX] := ""							
		ElseIf cField == 'TGY_ENTRA1' .AND. lEfetivo
			If lUseHr
				aAux[nX] := aAteEsc[nI,16,1,1]
			Else
				aAux[nX] := ""
			EndIf	
		ElseIf cField == 'TGY_SAIDA1' .AND. lEfetivo
			If lUseHr
				aAux[nX] := aAteEsc[nI,16,1,2]
			Else
				aAux[nX] := ""
			EndIf	
		ElseIf cField == 'TGY_ENTRA2' .AND. lEfetivo
			If lUseHr
				aAux[nX] := aAteEsc[nI,16,2,1]
			Else
				aAux[nX] := ""
			EndIf	
		ElseIf cField == 'TGY_SAIDA2' .AND. lEfetivo
			If lUseHr
				aAux[nX] := aAteEsc[nI,16,2,2]
			Else
				aAux[nX] := ""
			EndIf	
		ElseIf cField == 'TGY_ENTRA3' .AND. lEfetivo
			If lUseHr
				aAux[nX] := aAteEsc[nI,16,3,1]
			Else
				aAux[nX] := ""
			EndIf					
		ElseIf cField == 'TGY_SAIDA3' .AND. lEfetivo
			If lUseHr
				aAux[nX] := aAteEsc[nI,16,3,2]
			Else
				aAux[nX] := ""
			EndIf		
		ElseIf cField == 'TGY_ENTRA4' .AND. lEfetivo
			If lUseHr
				aAux[nX] := aAteEsc[nI,16,4,1]
			Else
				aAux[nX] := ""
			EndIf					
		ElseIf cField == 'TGY_SAIDA4' .AND. lEfetivo
			If lUseHr
				aAux[nX] := aAteEsc[nI,16,4,2]
			Else
				aAux[nX] := ""
			EndIf
		ElseIf cField == 'TGY_TIPO'		
			aAux[nX] := aAteEsc[nI,2]		//TGY_TIPO
		ElseIf cField == 'TGY_TIPO'		
			aAux[nX] := aAteEsc[nI,2]		//TGY_TIPO
		ElseIf cField == 'TGYSTATUS'	
			
			If Empty(aAteEsc[nI,8] ) 
				dDtIni := MV_PAR01
			Else
				dDtIni := Max(aAteEsc[nI,8] ,MV_PAR01)
			EndIf
		
			If Empty(aAteEsc[nI,9]) 
				dDtFin := MV_PAR02
			Else
				dDtFin := Min(aAteEsc[nI,9],MV_PAR02)
			EndIf
						
			// Consulta e Atualiza o Status: Conflito Atendente
			aCnflt 	:= ChkCfltAlc(dDtIni, dDtFin, aAteEsc[nI,6])
			lDemis	:= aCnflt[1]
			lAfast	:= aCnflt[2]
			lFerias	:= aCnflt[3]

			lCursoVenc  := !At020VlDtC({aAteEsc[nI,6]},.F.)//Alerta para vencimento do curso do atendente
			cTpResLoc := at012ResLoc(aAteEsc[nI,6],dDtIni,dDtFin,TFF->TFF_LOCAL)
			If cTpResLoc == "0"
				cTpResCli := at012ResCli(aAteEsc[nI,6],dDtIni,dDtFin,TFF->TFF_LOCAL)
				cTipoRest := cTpResCli
			Else
				cTipoRest := cTpResLoc	
			Endif
						
			aAux[nX] := At330ALgGS(lDemis,lAfast,lFerias,lCursoVenc,cTipoRest) //TGYSTATUS
		ElseIf SX3->(DbSeek(cField))
			If !aFields[nI, MODEL_FIELD_VIRTUAL]
				aAux[nX] := TGY->&(cField)
			Else
				aAux[nX] := CriaVar(cField,.T.)
			EndIf  
		EndIf
	Next nX	
			
		
	Aadd(aRet, {nI, aAux})	

	If aAteEsc[nI,2] == "Efetivo" 
		nPos := aScan( aAteEfe, { |x|	x[1] == aAteEsc[nI,3] .And. x[2] == aAteEsc[nI,5] .And.	x[3] == aAteEsc[nI,12] } )//TDX_TURNO//TGY_SEQ//TDX_COD

		If nPos == 0
			aAdd( aAteEfe, { aAteEsc[nI,3], aAteEsc[nI,5], aAteEsc[nI,12], {} } )
			nPos := Len(aAteEfe)
		EndIf
		If !lUseHr
			aAdd( aAteEfe[nPos,4], {	aAteEsc[nI,1],;//TGY_GRUPO
			 							aAteEsc[nI,6],;//TGY_ATEND
										aAteEsc[nI,8],;//TGY_DTINI
										aAteEsc[nI,9],;//TGY_DTFIM
										aAteEsc[nI,11],;//TGY_ITEM
										aAteEsc[nI,14]} )//TGY_ULTALO				
		Else
			aAdd( aAteEfe[nPos,4], {	aAteEsc[nI,1],;//TGY_GRUPO
			 							aAteEsc[nI,6],;//TGY_ATEND
										aAteEsc[nI,8],;//TGY_DTINI
										aAteEsc[nI,9],;//TGY_DTFIM
										aAteEsc[nI,11],;//TGY_ITEM
										aAteEsc[nI,14],;//TGY_ULTALO										
										aAteEsc[nI,15],;
										aAteEsc[nI,16]}) //Array com a gestão dos horarios																													
		EndIf										
	Else // Cobertura
		nPos := aScan( aAteCob, { |x| x[1] == aAteEsc[nI,10] .And. x[2] == aAteEsc[nI,11] } )
		If nPos == 0
			aAdd( aAteCob, { aAteEsc[nI,10], aAteEsc[nI,11], {} } )
			nPos := Len(aAteCob)
		EndIf
		aAdd( aAteCob[nPos,3], {	aAteEsc[nI,1], aAteEsc[nI,6],; 
									aAteEsc[nI,8], aAteEsc[nI,9] } )			
	EndIf		

Next nI

If !IsBlind()
	MsgRun(STR0011, STR0008,;	// "Gerando agenda dos atendentes da escala selecionados..."#"Processando"
		{ || aAteAgeSt := At330AAgAt( aAteEfe, aAteCob, dDataIni, dDataFim, cEscala, cCalend, cCodTFF, cFilTFF ) } )
		
	MsgRun(STR0012, STR0008,;	// "Gerando agenda dos atendentes fora da escala selecionados..."#"Processando"
		{ || At330AAtEsp( @aAteAgeSt, cCodTFF, cContrato, dDataIni, dDataFim, cFilTFF ) } )
Else
	aAteAgeSt := At330AAgAt( aAteEfe, aAteCob, dDataIni, dDataFim, cEscala, cCalend, cCodTFF, cFilTFF )
	At330AAtEsp( @aAteAgeSt, cCodTFF, cContrato, dDataIni, dDataFim, cFilTFF )	
EndIf
 
Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At330LdZZX
@description  
				Carga do modelo ZZX
@author       Matheus Lando Raimundo
@since        31/01/2018
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330LdZZX(oModel)
Local aRet := {}

If !IsBlind()
	MsgRun(STR0011, STR0008, {||aRet := At330AStru( .T.,,,,oModel )})
Else
	aRet := At330AStru( .T.,,,,oModel )
EndIf	

Return aRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At330ExABB
@description  Retorna se ja existe ABB para determinada linha do grid
				
@author       Matheus Lando Raimundo
@since        22/03/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At330ExABB(oMdlZZX)
Local lRet := .F.

lRet := oMdlZZX:GetValue("ZZX_SITABB") == "BR_VERMELHO" .Or. oMdlZZX:GetValue("ZZX_EXSABB") == "1"

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} hasABBRig
@description  Retorna se Existe ABB depois de uma determinada data
@return lRet, Bool
@author Diego Bezerra
@since  2019-06-04
/*/
//--------------------------------------------------------------------------------------------------------------------
Function hasABBRig(dtFim, codTFF, codAtd, cEscala, lVldEsc)

Local cAliasLAg := getNextAlias()
Local lRet 		:= .F.
Local cAtend	:= "%%"
Local cEscAbb 	:= "%%"
Local cTDVRef	:= "%%"

Default codTFF 	:= ""
Default codAtd 	:= ""
Default cEscala := ""	
Default lVldEsc	:= .F.

If !Empty(codAtd)
	cAtend := "% AND TGY.TGY_ATEND = '"+ codAtd + "'%"
EndIf

If !Empty(cEscala)
	cEscAbb := "% AND TGY.TGY_ESCALA = '"+ cEscala + "'%"
EndIf

If lVldEsc
	cTDVRef := "% TDV.TDV_DTREF >= '"+ DtoS(dtFim) + "'%"
Else 
	cTDVRef := "% TDV.TDV_DTREF > '"+ DtoS(dtFim) + "'%"
EndIf 

BeginSql Alias cAliasLAg

	SELECT COUNT(1) AS CONTA	
	FROM 
		%table:TGY% TGY 
		INNER JOIN %table:ABQ% ABQ ON ( ABQ.ABQ_FILTFF = %xFilial:TFF% AND ABQ.ABQ_CODTFF = TGY.TGY_CODTFF AND ABQ.ABQ_FILIAL = %xFilial:ABQ% AND ABQ.%NotDel%)		
		INNER JOIN %table:ABB% ABB ON (  ABB.ABB_IDCFAL =  ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND ABB.ABB_CODTEC = TGY.TGY_ATEND AND ABB.%NotDel% AND ABB.ABB_FILIAL = %xFilial:ABB%  )	    
		INNER JOIN %table:TDV% TDV ON ( %Exp:cTDVRef%   AND ABB.ABB_CODIGO = TDV.TDV_CODABB  AND TDV.%NotDel% AND TDV.TDV_FILIAL = %xFilial:TDV%  )
		WHERE TGY.TGY_CODTFF = %Exp:codTFF% 
			AND TGY.TGY_FILIAL = %xFilial:TGY%
			%Exp:cAtend% 
			AND TGY.%NotDel%
			%Exp:cEscAbb%  
 
EndSql

lRet := (cAliasLAg)->CONTA > 0

(cAliasLAg)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT330ArsSt()

funcao utilizada para manipular os arrs static desse fonte

@author boiani
@since 03/06/2019
/*/
//------------------------------------------------------------------
Function AT330ArsSt(cArray,lLimpa)
Default lLimpa := .F.
Default cArray := ""
If lLimpa
	aCfltAtnd	:= {}
	aAteAgeSt   := {}
	aDiasFer 	:= {}
	aDiasFer2 	:= {}
	aDiasFer3 	:= {}
	aDiasAfast 	:= {}
	aDiasDem 	:= {}
	aDiasAdi 	:= {}
	aAtend  	:= {}
EndIf

If UPPER(cArray) == "ACFLTATND"
	Return aCfltAtnd
ElseIf UPPER(cArray) == "AATEAGEST"
	Return aAteAgeSt
ElseIf UPPER(cArray) == "ADIASFER"
	Return aDiasFer
ElseIf UPPER(cArray) == "ADIASFER2"
	Return aDiasFer2
ElseIf UPPER(cArray) == "ADIASFER3"
	Return aDiasFer3
ElseIf UPPER(cArray) == "ADIASAFAST"
	Return aDiasAfast
ElseIf UPPER(cArray) == "ADIASDEM"
	Return aDiasDem
ElseIf UPPER(cArray) == "ACFLTHEAD"
	Return aCfltHead
ElseIf UPPER(cArray) == "AATEND"
	Return aAtend
ElseIf UPPER(cArray) == "ADIASADI"
	Return aDiasAdi	
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistTGZ()

Funcao para verificar se a TFF a ser alocada tem cobertura

@param cCodTFF - Caracter - Codigo da TFF
@param cFilTFF - Caracter - Filial da TFF
@param dDatIni - Data - Data de Inicio da alocação
@param dDatFim - Data - Data de fim da alocação

@author Luiz Gabriel
@since 17/10/2019
/*/
//------------------------------------------------------------------
Static Function ExistTGZ( cCodTFF, dDatIni)
Local lRet		:= .F.
Local cAliasTGZ := GetNextAlias()
					
BeginSql Alias cAliasTGZ
	SELECT Count(TGZ_CODTFF) AS CNT
	FROM 
		%table:TGZ% TGZ 
	WHERE 
		TGZ.TGZ_FILIAL = %xFilial:TGZ% AND 
		TGZ.TGZ_CODTFF = %Exp:cCodTFF% AND
		(TGZ.TGZ_DTFIM >=  %exp:dDatIni% AND TGZ.TGZ_DTINI <= %exp:dDatIni% OR
			TGZ.TGZ_DTFIM >=  %exp:dDatIni% AND TGZ.TGZ_DTINI >= %exp:dDatIni%)  AND 
		TGZ.%NotDel%	 
EndSql

If (cAliasTGZ)->CNT > 0
	lRet := .T.
EndIf

(cAliasTGZ)->( DbCloseArea() )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSeqTGZ()

Funcao para recuperar a sequencia inicial a ser considerada para a rota

@param cCodRota - Caracter - Codigo da Rota de Cobertura
@param cCodTFF - Caracter - Codigo da TFF
@param cFilTFF - Caracter - Filial da TFF

@author Luiz Gabriel
@since 17/10/2019
/*/
//------------------------------------------------------------------
Static Function GetSeqTGZ(cCodRota,cCodTFF)
Local cRet	:= ""
Local cAliasTGZ := GetNextAlias()
					
BeginSql Alias cAliasTGZ
	SELECT TGZ.TGZ_SEQ
	FROM 
		%table:TGZ% TGZ 
	WHERE 
		TGZ.TGZ_FILIAL =%xFilial:TGZ% AND 
		TGZ.TGZ_CODTFF = %Exp:cCodTFF% AND
		TGZ.TGZ_CODTW0 = %Exp:cCodRota% AND
		TGZ.%NotDel%	 
EndSql

If!(cAliasTGZ)->(EOF())
	cRet := (cAliasTGZ)->TGZ_SEQ
EndIf

(cAliasTGZ)->( DbCloseArea() )

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At330aGtIA

@description Realiza a chamada da função 'getInfoAtend', que é Static

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At330aGtIA(aAbb, aCalend, aAteEfe, cTurno, cSeq, cKeyTGY, aHorFlex, nGrupo,;
								cCodTec, cItem, dUltAloc, lExcecao, dDatIni, dDatFim, aCfgRtCb, cAtendFlx, cTpRota )

Return (getInfoAtend(aAbb, aCalend, aAteEfe, cTurno, cSeq, cKeyTGY, aHorFlex, nGrupo,;
								cCodTec, cItem, dUltAloc, lExcecao, dDatIni, dDatFim, aCfgRtCb, cAtendFlx, cTpRota ))
//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraAtt

@description Inclui cópias de um atendente no array aAteEfe para movimentar rota sem efetivo

@author	boiani
@since	15/11/2020
/*/
//------------------------------------------------------------------------------
Static Function GeraAtt(aAteEfe, cCodRota, cAtendFlex, dDatIni, dDatFim, cEscala, cCodRtItem)
Local aHorarios := {}
Local lHrFlx := LEN(aAteEfe[1,4,1]) > 7
Local cQry := ""
Local cAls := ""
Local aTurnSeq 	:= GetSeqRt(cCodRota,cCodRtItem)
Local cTurno 	:= aTurnSeq[1]
Local cSeqTur 	:= aTurnSeq[2]
Local nAux 	:= 0
Local nX 	:= 0
Local aAux	:= {}

If lHrFlx
	If !EMPTY(cAtendFlex)
		For nX := 1 To LEN(aAteEfe)
			If (nAux := ASCAN(aAteEfe[nX][4] ,{|a| a[2] == cAtendFlex })) > 0
				aHorarios := ACLONE(aAteEfe[nX][4][nAux][8])
				Exit
			EndIf
		Next nX
	Else
		cQry := " SELECT SPJ.PJ_ENTRA1, SPJ.PJ_SAIDA1, "
		cQry += " SPJ.PJ_ENTRA2, SPJ.PJ_SAIDA2, SPJ.PJ_ENTRA3, SPJ.PJ_SAIDA3, "
		cQry += " SPJ.PJ_ENTRA4, SPJ.PJ_SAIDA4 "
		cQry += " FROM " + RetSqlName("SPJ") + " SPJ "
		cQry += " WHERE SPJ.D_E_L_E_T_ = ' ' "
		cQry += " AND SPJ.PJ_TURNO = '" + cTurno + "' "
		cQry += " AND SPJ.PJ_SEMANA = '" + cSeqTur + "' "
		cQry += " AND SPJ.PJ_FILIAL = '" + xFilial("SPJ") + "' "
		cQry += " AND SPJ.PJ_TPDIA = 'S' "
		cQry := ChangeQuery(cQry)
		cAls := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAls, .F., .F.)
		aHorarios := {{"     ","     "},{"     ","     "},{"     ","     "},{"     ","     "}}
		aHorarios[1][1] := TxValToHor((cAls)->PJ_ENTRA1)
		aHorarios[1][2] := TxValToHor((cAls)->PJ_SAIDA1)
		If (cAls)->PJ_ENTRA2 > 0 .OR. (cAls)->PJ_SAIDA2 > 0
			aHorarios[2][1] := TxValToHor((cAls)->PJ_ENTRA2)
			aHorarios[2][2] := TxValToHor((cAls)->PJ_SAIDA2)
		EndIf
		If (cAls)->PJ_ENTRA3 > 0 .OR. (cAls)->PJ_SAIDA3 > 0
			aHorarios[3][1] := TxValToHor((cAls)->PJ_ENTRA3)
			aHorarios[3][2] := TxValToHor((cAls)->PJ_SAIDA3)
		EndIf
		If (cAls)->PJ_ENTRA4 > 0 .OR. (cAls)->PJ_SAIDA4 > 0
			aHorarios[4][1] := TxValToHor((cAls)->PJ_ENTRA4)
			aHorarios[4][2] := TxValToHor((cAls)->PJ_SAIDA4)
		EndIf
		aHorarios[1][1] := TxValToHor((cAls)->PJ_ENTRA1)
		aHorarios[1][2] := TxValToHor((cAls)->PJ_SAIDA1)
		(cAls)->(DbCloseArea())
	EndIf
EndIf

If lHrFlx
	AADD(aAux, {cTurno,;
				cSeqTur,;
				cEscala,;
				{;
					{1,;
					SPACE(TamSx3("AA1_CODTEC")[1]),;
					dDatIni,;
					dDatFim,;
					"01",;
					dDatFim,;
					"001",;
					aHorarios};
				}})
Else
	AADD(aAux, {cTurno,;
				cSeqTur,;
				cEscala,;
				{;
					{1,;
					SPACE(TamSx3("AA1_CODTEC")[1]),;
					dDatIni,;
					dDatFim,;
					"01",;
					dDatFim,;
					"001";
					};
				}})
EndIf

If !Empty(aAux)
	aAteEfe := aAux
Endif

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetSeqRt

@description Seleciona a sequencia inicial para rotas sem efetivo na sequencia de cobertura.

@author	Kaique Schiller
@since	17/11/2020
/*/
//------------------------------------------------------------------------------
Static Function GetSeqRt(cCodRota,cCodRtItem)
Local aRetSeq := {"",""}
Local cAliasTW1 := GetNextAlias()

BeginSql Alias cAliasTW1
	SELECT TW1.TW1_TURNO,TW1.TW1_SEQ
	FROM 
		%table:TW1% TW1 
	WHERE 
		TW1.TW1_FILIAL =%xFilial:TW1% AND 
		TW1.TW1_CODTW0 = %Exp:cCodRota% AND
		TW1.TW1_COD = %Exp:cCodRtItem% AND
		TW1.%NotDel%	 
EndSql

If !(cAliasTW1)->(EOF())
	aRetSeq[1] := (cAliasTW1)->TW1_TURNO
	aRetSeq[2] := (cAliasTW1)->TW1_SEQ
EndIf

(cAliasTW1)->( DbCloseArea() )

Return aRetSeq

//------------------------------------------------------------------------------
/*/{Protheus.doc} VerAbbRest

@description Verifica se o atendente tem a primeira parte da agenda no posto 
com o parametro MV_GSVERHR desabilitado, para não ocorrer erro de alocação no mesmo dia.

@author	augusto.albuquerque
@since	24/02/2021
/*/
//------------------------------------------------------------------------------
Static Function VerAbbRest(cIdcFal, cAtend, dDtRef, cFilABB)
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAliasABB	:= GetNextAlias()
Local lRet		:= .T.

cQuery := ""
cQuery += " SELECT ABB.ABB_CODIGO, TDV.TDV_DTREF "
cQuery += " FROM " + RetSqlName("ABB") + " ABB "
cQuery += " INNER JOIN " + RetSqlName("TDV") + " TDV "
cQuery += " ON TDV.TDV_CODABB = ABB.ABB_CODIGO "
cQuery += " AND TDV.TDV_FILIAL = ABB.ABB_FILIAL "
cQuery += " AND TDV.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " ABB.ABB_IDCFAL = '" + cIdcFal + "' "
cQuery += " AND ABB.ABB_FILIAL = '" + cFilABB + "' "
cQuery += " AND ABB.ABB_CODTEC = '" + cAtend + "' "
cQuery += " AND ABB.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABB, .F., .T.)

While (cAliasABB)->(!Eof())
	If (cAliasABB)->TDV_DTREF == DToS(dDtRef)
		lRet := .T.
		Exit
	EndIf
	(cAliasABB)->(dbSkip())
EndDo

(cAliasABB)->(dbCloseArea())

RestArea( aArea )
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AtHrRota

@description Seleciona o horário da rota de cobertura
@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Static Function AtHrRota(aCfgRtCb,cTurno,cSeq,dDtRef,cTipRt)
Local nPos := aScan( aCfgRtCb, { |x| x[1] == cTurno .And. x[2] == cSeq } )
Local aRetHrRt := {}
Local nX := 0
Default cTipRt := ""

If nPos > 0 .And. !Empty(cTipRt)
	For nX := 1 to Len(aCfgRtCb[nPos,_NPOSCFG])
		If aCfgRtCb[nPos,_NPOSCFG,nX,_NPOSTIPCFG] $ cTipRt .And. aCfgRtCb[nPos,_NPOSCFG,nX,_NPOSDIASEM] == Alltrim(Str(Dow(dDtRef)))
			aAdd(aRetHrRt,{ AtConvHora(aCfgRtCb[nPos,_NPOSCFG,nX,_NPOSHRINI]),;
							AtConvHora(aCfgRtCb[nPos,_NPOSCFG,nX,_NPOSHRFIM]) })
		Endif
	Next nX
Endif

Return aRetHrRt
