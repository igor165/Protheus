#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'ORGM050.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa     ³ ORGM050  ³ Autor ³ Equipe IP-RH          ³ Data ³ 02/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Geracao de Vagas no RSP                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ SigaOrg - Arquitetura Organizacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS     ³  Motivo da Alteracao                   ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Cecilia Carc.³01/08/14³TQEIB9    ³Incluido o fonte da 11 para a 12 e efetu³±±
±±³             ³        ³          ³ada a limpeza.                          ³±±
±±³EstherViveiro³13/07/15³TSUTGD    ³Corrigidos problemas da geração de vagas³±±
±±³Oswaldo L    ³04/04/17³DRHPONTP-5 ³Projeto Ctree                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGM050()
	
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oFWLayer, oPanelUp, oPanelDown, oRelac

Local lGrava 	:= .F.
Local bSet15	:= {|| lGrava := .T., oDlgPrinc:End()}
Local bSet24	:= {|| oDlgPrinc:End()}

Local aColumns	:= {}
Local aRotAuto	:= {}

Local lIntRSP		:= GetMv("MV_IORGRSP", NIL, "0") == "1"

Private oDlgPrinc
Private oBrowseUp
Private oBrowseDown
Private cArqTmp1
Private cArqTmp2

Private aLogDet		:= {}
Private aLogTitle	:= {}

Private oRCLVAGTmp
Private oRCLDEPTmp

 
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Verifica se a integracao esta ativada			        	  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/

If !lIntRSP
	MsgAlert( STR0001,STR0002 )	// "Esta rotina será habilitada apenas se a Integração com o módulo Recrutamento estiver ativada." ### "Atenção"
	Return
Endif

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Cria as tabelas que serao utilizadas nos browsers        	  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If !ORGM050QRY()
	MsgAlert( STR0003,STR0002 ) 	// "Nao existem vagas pendentes a serem criadas!" ### "Atenção"
	Return
Endif

Define MsDialog oDlgPrinc Title STR0004 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel // 'Geração de Vagas'

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Cria o container onde serão colocados os browses        	  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )

//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 50, .F. )                       // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )            // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )         // Pego o objeto desse pedaço do container

//
// Painel Inferior
//
oFWLayer:AddLine( 'DOWN', 50, .F. )                     // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'DOWN' )        // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelDown  := oFWLayer:GetColPanel( 'ALL' , 'DOWN' )  // Pego o objeto desse pedaço do container

//
// FWMarkBrowse Superior Departamentos
//
//-- Define as colunas do Brwose
aColumns := {}
Aadd( aColumns, { TitSX3("RCL_FILIAL")[1]	,"RCL_FILIAL"	,"C",TAMSX3("RCL_FILIAL")[1],TAMSX3("RCL_FILIAL")[2]	,GetSx3Cache( "RCL_FILIAL" , "X3_PICTURE" ) })
Aadd( aColumns, { TitSX3("RCL_DEPTO")[1]	,"RCL_DEPTO"	,"C",TAMSX3("RCL_DEPTO")[1],TAMSX3("RCL_DEPTO")[2]		,GetSx3Cache( "RCL_DEPTO" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_DDEPTO")[1]	,"RCL_DDEPTO"	,"C",TAMSX3("QB_DESCRIC")[1],TAMSX3("QB_DESCRIC")[2]	,GetSx3Cache( "QB_DESCRIC" , "X3_PICTURE" )})

oBrowseUp:= FWMarkBrowse():New()
oBrowseUp:SetOwner( oPanelUp )                          // Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( STR0005 ) // "Departamentos"
oBrowseUp:SetAlias( 'RCLDEP' )
oBrowseUp:SetTemporary(.T.)
oBrowseUp:SetProfileID( '1' )
oBrowseUp:SetSemaphore(.T.)
oBrowseUp:SetFieldMark( 'RCL_FLAG' )
oBrowseUp:SetAllMark( { || } )
oBrowseUp:SetAfterMark( { || ORGM50MUP(),oBrowseDown:GoTop(),oBrowseDown:Refresh() } )
oBrowseUp:SetFields(aColumns)
oBrowseUp:DisableReport()
oBrowseUp:DisableSaveConfig()
oBrowseUp:DisableConfig()
oBrowseUp:SetMenuDef( 'ORGM050' )
oBrowseUp:Activate()

//
// FWMarkBrowse Superior Vagas
//
//-- Define as colunas do Brwose
aColumns := {}
Aadd( aColumns, { TitSX3("RCL_FILIAL")[1]	,"RCL_FILIAL"	,"C",TAMSX3("RCL_FILIAL")[1],TAMSX3("RCL_FILIAL")[2]	,GetSx3Cache( "RCL_FILIAL" , "X3_PICTURE" ) })
Aadd( aColumns, { TitSX3("RCL_POSTO")[1]	,"RCL_POSTO"	,"C",TAMSX3("RCL_POSTO")[1],TAMSX3("RCL_POSTO")[2]		,GetSx3Cache( "RCL_POSTO" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_TPCONT")[1]	,"RCL_TPCONT"	,"C",TAMSX3("RCL_TPCONT")[1],TAMSX3("RCL_TPCONT")[2]	,"" })
Aadd( aColumns, { TitSX3("RCL_TPOSTO")[1]	,"RCL_TPOSTO"	,"C",TAMSX3("RCL_TPOSTO")[1],TAMSX3("RCL_TPOSTO")[2]	,"" })
Aadd( aColumns, { TitSX3("RCL_PROCES")[1]	,"RCL_PROCES"	,"C",TAMSX3("RCL_PROCES")[1],TAMSX3("RCL_PROCES")[2]	,GetSx3Cache( "RCL_PROCES" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_DPROC")[1]	,"RCL_DPROC"	,"C",TAMSX3("RCL_DPROC")[1],TAMSX3("RCL_DPROC")[2]		,GetSx3Cache( "RCL_DPROC" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_CARGO")[1]	,"RCL_CARGO"	,"C",TAMSX3("RCL_CARGO")[1],TAMSX3("RCL_CARGO")[2]		,GetSx3Cache( "RCL_CARGO" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_DCARGO")[1]	,"RCL_DCARGO"	,"C",TAMSX3("RCL_DCARGO")[1],TAMSX3("RCL_DCARGO")[2]	,GetSx3Cache( "RCL_DCARGO" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_FUNCAO")[1]	,"RCL_FUNCAO"	,"C",TAMSX3("RCL_FUNCAO")[1],TAMSX3("RCL_FUNCAO")[2]	,GetSx3Cache( "RCL_FUNCAO" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_DFUNC")[1]	,"RCL_DFUNC"	,"C",TAMSX3("RCL_DFUNC")[1],TAMSX3("RCL_DFUNC")[2]		,GetSx3Cache( "RCL_DFUNC" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_CC")[1]		,"RCL_CC"		,"C",TAMSX3("RCL_CC")[1],TAMSX3("RCL_CC")[2]			,GetSx3Cache( "RCL_CC" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_DESCCC")[1]	,"RCL_DESCCC"	,"C",TAMSX3("RCL_DESCCC")[1],TAMSX3("RCL_DESCCC")[2]	,GetSx3Cache( "RCL_DESCCC" , "X3_PICTURE" )})
Aadd( aColumns, { TitSX3("RCL_SALAR")[1]	,"RCL_SALAR"	,"N",TAMSX3("RCL_SALAR")[1],TAMSX3("RCL_SALAR")[2]		,GetSx3Cache( "RCL_SALAR" , "X3_PICTURE" ) })

oBrowseDown:= FWMarkBrowse():New()
oBrowseDown:SetOwner( oPanelDown )                          // Aqui se associa o browse ao componente de tela
oBrowseDown:SetDescription( STR0006 )	// "Vagas"
oBrowseDown:SetAlias( 'RCLVAG' )
oBrowseDown:SetTemporary(.T.)
oBrowseDown:SetProfileID( '2' )
oBrowseDown:SetSemaphore(.T.)
oBrowseDown:SetFieldMark( 'RCL_FLAG' )
oBrowseDown:SetAllMark( { || } )
oBrowseDown:SetFields(aColumns)
oBrowseDown:DisableReport()
oBrowseDown:DisableConfig()
oBrowseDown:DisableSaveConfig()
oBrowseDown:SetMenuDef( '' )
oBrowseDown:Activate()

//
// Relacionamento entre os Paineis
//
oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrowseUp  , oBrowseDown , { { 'RCL_FILIAL', 'RCL_FILIAL' }, { 'RCL_DEPTO' , 'RCL_DEPTO'  } } )
oRelac:Activate()

ACTIVATE MSDIALOG oDlgPrinc Center ON INIT EnchoiceBar( oDlgPrinc , bSet15 , bSet24 )

// Efetua a gravacao das vagas no Recrutamento e Selecao
If lGrava
	MsAguarde( {|| ORGM50Grv()}, , OemToAnsi( STR0007 ) ) // "Gerando Vagas no módulo SIGARSP..."
Endif

If Select("RCLDEP") > 0
	RCLDEP->(dbCloseArea())
Endif

If Select("RCLVAG") > 0
	RCLVAG->(dbCloseArea())
Endif
						
If oRCLDEPTmp <> Nil
	oRCLDEPTmp:Delete()
	Freeobj(oRCLDEPTmp)
EndIf				
If oRCLVAGTmp <> Nil
	oRCLVAGTmp:Delete()
	Freeobj(oRCLVAGTmp)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORGM50Grv     ºAutor  ³IP-RH Inovacao  º Data ³  02/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava as informacoes do ORG para o RSP                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAORG                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ORGM50Grv()

aAdd( aLogTiTle , Padr(STR0010,TAMSX3("RCL_POSTO")[1]+TAMSX3("RCL_FILIAL")[1]+1) + " " + STR0006 )	// "Posto" ### "Vaga" 
aAdd( aLogTitle , Replicate("-", TAMSX3("QS_POSTO")[1] + TAMSX3("RCL_FILIAL")[1] + 2 + TAMSX3("QS_VAGA")[1] + 3 + TAMSX3("QS_DESCRIC")[1] ) )

Begin Transaction

	RCLVAG->(dbGoTop())
	While RCLVAG->(!Eof())
	
		If !Empty(RCLVAG->RCL_FLAG)
	
			// Rotina automatica de inclusao de Vagas
			ORGXRSPINT( 3, "RCLVAG")
			aAdd( aLogDet , SQS->QS_FILPOST + "/" + PADR(SQS->QS_POSTO,TAMSX3("QS_POSTO")[1]) + " " + Padr(SQS->QS_VAGA,TAMSX3("QS_VAGA")[1]) + " - " + SQS->QS_DESCRIC )
	
		Endif
	
		RCLVAG->(dbSkip())
	
	Enddo

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Gera o Log de Inconsistencias                                ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF Len( aLogDet ) > 0
		fMakeLog( { aLogDet } , aLogTitle , /*"ORGM50"*/, NIL , NIL , STR0008 ) // "Log de Integração Módulo SIGAORG X Módulo SIGARSP - Geração Automatica de Vagas" 
	EndIF

End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORGM050QRY    ºAutor  ³IP-RH Inovacao  º Data ³  02/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega as tabelas para utilizacao nos browsers            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAORG                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ORGM050QRY()
Local lRet			:= .F.
Local cAliasQry		:= GetNextAlias()
Local cWhere		:= ""
Local cFilRCLSQB:= "%" + FWJoinFilial("RCL", "SQB") + "%"
Local cFilRCLSQ3:= "%" + FWJoinFilial("RCL", "SQ3") + "%"
Local cFilRCLCTT:= "%" + FWJoinFilial("RCL", "CTT") + "%"
Local cFilRCLSRJ:= "%" + FWJoinFilial("RCL", "SRJ") + "%"
Local cFilRCLRCJ:= "%" + FWJoinFilial("RCL", "RCJ") + "%"
Local aLstIndices := {}

cWhere := "% RCL.D_E_L_E_T_ = ' ' AND "
cWhere += " RCL.RCL_FUNCAO <> '' AND " //nao pode criar vagas no rsp com função em branco
cWhere += "( RCL.RCL_STATUS = '1' OR ( RCL.RCL_STATUS = '2' AND RCL.RCL_TPOSTO = '2' AND RCL.RCL_OPOSTO < RCL_NPOSTO )) %"

BeginSql alias cAliasQry
	SELECT DISTINCT RCL.R_E_C_N_O_, RCJ.RCJ_DESCRI, RCL.*, SRJ.*, SQB.QB_DESCRIC, SQ3.Q3_DESCSUM
	FROM %table:RCL% RCL 
	INNER JOIN %table:SQB% SQB ON RCL.RCL_DEPTO  = SQB.QB_DEPTO AND SQB.%NotDel% AND %exp:cFilRCLSQB%
	INNER JOIN %table:SQ3% SQ3 ON RCL.RCL_CARGO  = SQ3.Q3_CARGO AND SQ3.%NotDel% AND %exp:cFilRCLSQ3%
	LEFT  JOIN %table:CTT% CTT ON RCL.RCL_CC     = CTT.CTT_CUSTO AND CTT.%NotDel% AND %exp:cFilRCLCTT%
	LEFT  JOIN %table:SRJ% SRJ ON RCL.RCL_FUNCAO = SRJ.RJ_FUNCAO AND SRJ.%NotDel% AND %exp:cFilRCLSRJ%
	LEFT  JOIN %table:RCJ% RCJ ON RCL.RCL_PROCES = RCJ.RCJ_CODIGO AND RCJ.%NotDel% AND %exp:cFilRCLRCJ%
	WHERE %exp:cWhere% AND 
	( NOT EXISTS ( SELECT QS_FILIAL,QS_POSTO 
					FROM %Table:SQS% SQS 
					WHERE QS_FILPOST = RCL.RCL_FILIAL AND QS_POSTO = RCL.RCL_POSTO AND SQS.%NotDel% ) OR
		(	EXISTS ( SELECT QS_FILIAL,QS_POSTO 
					FROM %Table:SQS% SQS 
					WHERE QS_FILPOST = RCL.RCL_FILIAL AND QS_POSTO = RCL.RCL_POSTO AND (SQS.QS_NRVAGA-SQS.QS_VAGAFEC)=0 AND SQS.%NotDel% ) AND
			( SELECT SUM(QS_NRVAGA)  
					FROM %Table:SQS% SQS 
					WHERE QS_FILPOST = RCL.RCL_FILIAL AND QS_POSTO = RCL.RCL_POSTO AND SQS.%NotDel% ) < RCL.RCL_NPOSTO
		)			
	)
	ORDER BY RCL_FILIAL,RCL_DEPTO,RCL_POSTO
EndSql

If (cAliasQry)->( !Eof() )
	lRet := .T.
	aCampos:={}
	AADD(aCampos,{"RCL_FLAG"	,"C",02,00 }) 
	AADD(aCampos,{"RCL_FILIAL"	,"C",TAMSX3("RCL_FILIAL")[1]	,TAMSX3("RCL_FILIAL")[2]} ) 
	AADD(aCampos,{"RCL_POSTO"	,"C",TAMSX3("RCL_POSTO")[1]		,TAMSX3("RCL_POSTO")[2]} ) 
	AADD(aCampos,{"RCL_DEPTO"	,"C",TAMSX3("RCL_DEPTO")[1]		,TAMSX3("RCL_DEPTO")[2]} ) 
	AADD(aCampos,{"RCL_TPCONT"	,"C",30                        	,0                      } ) 
	AADD(aCampos,{"RCL_TPOSTO"	,"C",30                     	,0                      } ) 
	AADD(aCampos,{"RCL_PROCES"	,"C",TAMSX3("RCL_PROCES")[1]	,TAMSX3("RCL_PROCES")[2]} ) 
	AADD(aCampos,{"RCL_DPROC"	,"C",TAMSX3("RCL_DPROC")[1]		,TAMSX3("RCL_DPROC")[2]} ) 
	AADD(aCampos,{"RCL_CARGO"	,"C",TAMSX3("RCL_CARGO")[1]		,TAMSX3("RCL_CARGO")[2]} ) 
	AADD(aCampos,{"RCL_DCARGO"	,"C",TAMSX3("RCL_DCARGO")[1]	,TAMSX3("RCL_DCARGO")[2]} ) 
	AADD(aCampos,{"RCL_FUNCAO"	,"C",TAMSX3("RCL_FUNCAO")[1]	,TAMSX3("RCL_FUNCAO")[2]} ) 
	AADD(aCampos,{"RCL_DFUNC"	,"C",TAMSX3("RCL_DFUNC")[1]		,TAMSX3("RCL_DFUNC")[2]} ) 	
	AADD(aCampos,{"RCL_CC"		,"C",TAMSX3("RCL_CC")[1]		,TAMSX3("RCL_CC")[2]} ) 	
	AADD(aCampos,{"RCL_DESCCC"	,"C",TAMSX3("RCL_DESCCC")[1]	,TAMSX3("RCL_DESCCC")[2]} ) 	
	AADD(aCampos,{"RCL_SALAR"	,"N",TAMSX3("RCL_SALAR")[1]		,TAMSX3("RCL_SALAR")[2]} ) 	
	AADD(aCampos,{"RCL_NPOSTO"	,"N",TAMSX3("RCL_NPOSTO")[1]	,TAMSX3("RCL_NPOSTO")[2]} )
	AADD(aCampos,{"RCL_OPOSTO"	,"N",TAMSX3("RCL_OPOSTO")[1]	,TAMSX3("RCL_OPOSTO")[2]} )
		
	AAdd( aLstIndices, {"RCL_FILIAL","RCL_DEPTO","RCL_POSTO"})
	oRCLVAGTmp := RhCriaTrab('RCLVAG', aCampos, aLstIndices)
		
	

	aCampos:={}
	AADD(aCampos,{"RCL_FLAG"	,"C",02,00 }) 
	AADD(aCampos,{"RCL_FILIAL"	,"C",TAMSX3("RCL_FILIAL")[1],TAMSX3("RCL_FILIAL")[2]} ) 
	AADD(aCampos,{"RCL_POSTO"	,"C",TAMSX3("RCL_POSTO")[1],TAMSX3("RCL_POSTO")[2]} ) 
	AADD(aCampos,{"RCL_DEPTO"	,"C",TAMSX3("RCL_DEPTO")[1],TAMSX3("RCL_DEPTO")[2]} ) 
	AADD(aCampos,{"RCL_DDEPTO"	,"C",TAMSX3("QB_DESCRIC")[1],TAMSX3("QB_DESCRIC")[2]} ) 

	aLstIndices := {}
	AAdd( aLstIndices, {"RCL_FILIAL","RCL_DEPTO","RCL_POSTO"})
	oRCLDEPTmp := RhCriaTrab('RCLDEP', aCampos, aLstIndices)
	
	While (cAliasQry)->( !Eof() )

		RecLock("RCLDEP" , .T. )
		("RCLDEP")->RCL_FILIAL	:=  (cAliasQry)->RCL_FILIAL
		("RCLDEP")->RCL_POSTO	:=  (cAliasQry)->RCL_POSTO
		("RCLDEP")->RCL_DEPTO	:=  (cAliasQry)->RCL_DEPTO
		("RCLDEP")->RCL_DDEPTO	:=  (cAliasQry)->QB_DESCRIC
		
		("RCLDEP")->(MsUnLock())

		While (cAliasQry)->( !Eof() ) .And. (cAliasQry)->RCL_FILIAL + (cAliasQry)->RCL_DEPTO == RCLDEP->RCL_FILIAL + RCLDEP->RCL_DEPTO
	
			RecLock("RCLVAG" , .T. )
			("RCLVAG")->RCL_FILIAL	:=  (cAliasQry)->RCL_FILIAL
			("RCLVAG")->RCL_POSTO	:=  (cAliasQry)->RCL_POSTO
			("RCLVAG")->RCL_DEPTO	:=  (cAliasQry)->RCL_DEPTO
			("RCLVAG")->RCL_TPCONT	:=  If(Empty((cAliasQry)->RCL_TPCONT) , "", ORGCombo("RCL_TPCONT")[Val((cAliasQry)->RCL_TPCONT),1] )
			("RCLVAG")->RCL_TPOSTO	:=  If(Empty((cAliasQry)->RCL_TPOSTO) , "", ORGCombo("RCL_TPOSTO")[Val((cAliasQry)->RCL_TPOSTO),1] )
			("RCLVAG")->RCL_PROCES	:=  (cAliasQry)->RCL_PROCES
			("RCLVAG")->RCL_DPROC	:=  (cAliasQry)->RCJ_DESCRI
			("RCLVAG")->RCL_CARGO	:=  (cAliasQry)->RCL_CARGO
			("RCLVAG")->RCL_DCARGO	:=  (cAliasQry)->Q3_DESCSUM
			("RCLVAG")->RCL_FUNCAO	:=  (cAliasQry)->RCL_FUNCAO
			("RCLVAG")->RCL_DFUNC	:=  (cAliasQry)->RJ_DESC
			("RCLVAG")->RCL_CC		:=  (cAliasQry)->RCL_CC
			("RCLVAG")->RCL_DESCCC	:=  (cAliasQry)->QB_DESCRIC
			("RCLVAG")->RCL_SALAR	:=  (cAliasQry)->RCL_SALAR
			("RCLVAG")->RCL_NPOSTO	:=  (cAliasQry)->RCL_NPOSTO
			("RCLVAG")->RCL_OPOSTO	:=  (cAliasQry)->RCL_OPOSTO
			
			("RCLVAG")->(MsUnLock())

			(cAliasQry)->( dbSkip() )
		Enddo
	Enddo
Endif

dbSelectArea(cAliasQry)
dbCloseArea()

If Select("RCLDEP") > 0
	dbSelectArea("RCLDEP")
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ORGM50MUP ³ Autor ³ IP - RH Inovacao  	³ Data ³ 03.02.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Marca todas as vagas correspondente ao departamento marcado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ORGM50MUP()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	 	 ³ ORGM050  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± */
Static Function ORGM50MUP()
Local cMarc := If(oBrowseUp:IsMark(),oBrowseDown:mark(),Space(2))

RCLVAG->(dbGoTop())
While RCLVAG->(!Eof())

	If (RCLVAG->RCL_FILIAL + RCLVAG->RCL_DEPTO == RCLDEP->RCL_FILIAL + RCLDEP->RCL_DEPTO )
		RecLock("RCLVAG" , .F.)
		RCL_FLAG := cMarc
		MsUnLock()
	Endif
	RCLVAG->(dbSkip())

Enddo

Return