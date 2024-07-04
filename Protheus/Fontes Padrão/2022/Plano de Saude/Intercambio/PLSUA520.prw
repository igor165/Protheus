#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "Plsmger.ch"
#INCLUDE "Colors.ch"
#INCLUDE "plsmfun.ch"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PLSUA520.CH"

#DEFINE CRLF chr( 13 ) + chr( 10 )
#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA520
Rotina de Aviso Lote Guias - Envio

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Function PLSUA520()

private oMBrwB2S 
private cFilter := ""
private __aRet	:= {}
private cCodInt	:= plsintpad()
static a520FIL := {}

//AJuste temporário
PlAjsTamCampo()
//

cFilter := PLSU520FIL(.f.)
setKey(VK_F2 ,{|| cFilter := PLSU520FIL(.t.) })

oMBrwB2S:= FWMarkBrowse():New()
oMBrwB2S:SetAlias('B2S')
oMBrwB2S:SetDescription(STR0001) //"Gestão de Avisos - Envio"
oMBrwB2S:SetMenuDef("PLSUA520")
oMBrwB2S:AddLegend( "B2S->B2S_STATUS=='1'", "GREEN", 	STR0002  ) //"Pend. Envio Aviso"
oMBrwB2S:AddLegend( "B2S->B2S_STATUS=='2'", "YELLOW", 	STR0003  ) //"Aviso Enviado"
oMBrwB2S:AddLegend( "B2S->B2S_STATUS=='3'", "ORANGE", 	STR0004  ) //"Aviso Recebido"

oMBrwB2S:SetFieldMark( 'B2S_OK' )	
oMBrwB2S:SetAllMark({ ||  PLSInvert(oMBrwB2S, "B2S") })
oMBrwB2S:SetWalkThru(.F.)
oMBrwB2S:SetFilterDefault(cFilter)
oMBrwB2S:SetAmbiente(.F.)
oMBrwB2S:ForceQuitButton()
oMBrwB2S:Activate()

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0005  	Action 'PesqBrw'          					OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0006 	Action 'ViewDef.PLSUA520'					OPERATION 2 ACCESS 0 //"Detalhar"
ADD OPTION aRotina Title STR0007 	Action 'PLSU520PRO(.f.)'						OPERATION 3 ACCESS 0 //"Processar" 
ADD OPTION aRotina Title STR0008	Action 'PLSU520EXP()'						OPERATION 2 ACCESS 0 //"Gerar Arquivo"
ADD OPTION aRotina Title STR0009	Action 'PLSP525()'							OPERATION 4 ACCESS 0 //"Importa Arq. Retorno"  
ADD OPTION aRotina Title STR0010	Action 'PLSUGLO520("1")'					OPERATION 2 ACCESS 0 //"Processa Glosa Total" 
ADD OPTION aRotina Title STR0011	Action 'PLSUGLO520("2")'					OPERATION 2 ACCESS 0 //"Exportar PTU A530" 
ADD OPTION aRotina Title STR0012	Action 'Processa({||PLSU520DEL()},"Lote de Aviso - Exclusao","Processando...",.T.)' 					OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina Title "<F2> - Filtrar" 		Action 'PLSU520FIL(.t.)'    OPERATION 2 ACCESS 0 //'Filtrar'
ADD OPTION aRotina Title "Relatório Criticados"	Action 'PLSR525()'    OPERATION 2 ACCESS 0 //'Relatório'
Return aRotina   

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function ViewDef()

Local oStruB2S := FWFormStruct( 2, 'B2S' ) 
Local oStruB5S := FWFormStruct( 2, 'B5S' )
Local oStruB6S := FWFormStruct( 2, 'B6S' )
Local oModel   := FWLoadModel( 'PLSUA520' )
Local oView      

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VIEW_B2S', oStruB2S, 	'B2SMASTER' )
oView:AddGrid( 'VIEW_B5S', 	oStruB5S, 	'B5SDETAIL' )
oView:AddGrid( 'VIEW_B6S', 	oStruB6S, 	'B6SDETAIL' )

oView:EnableTitleView('VIEW_B2S',STR0013) //"Lote" 
oView:EnableTitleView('VIEW_B5S',STR0014) //"Guias do Lote" 
oView:EnableTitleView('VIEW_B6S',STR0015) //"Eventos da Guia"

// Divide a tela em para conteúdo e rodapé
oView:CreateHorizontalBox( 'LOTE', 		15 )
oView:CreateHorizontalBox( 'PESQUISAR',	10 )
oView:CreateHorizontalBox( 'GUIAS', 	45 )
oView:CreateHorizontalBox( 'EVENTOS', 	30 )  

oView:SetOwnerView( 'VIEW_B2S', 'LOTE')   
oView:SetOwnerView( 'VIEW_B5S', 'GUIAS')
oView:SetOwnerView( 'VIEW_B6S', 'EVENTOS')

oView:AddOtherObject("OTHER_PANEL", {|oPanel| fPesquisa(oPanel)})

// Associa ao box que ira exibir os outros objetos
oView:SetOwnerView("OTHER_PANEL",'PESQUISAR')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define a model

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function ModelDef()
                                         
Local oStruB2S := FWFormStruct( 1, 'B2S')
Local oStruB5S := FWFormStruct( 1, 'B5S')
Local oStruB6S := FWFormStruct( 1, 'B6S')
Local oModel

oModel := MPFormModel():New( 'PLSUA520MODEL',/*bPreValidacao*/,{|| PLUA520Val(oModel)},/*bCommit*/, /*bCancel*/ )

// Monta a estrutura
oModel:AddFields( 'B2SMASTER', 				, oStruB2S)
oModel:AddGrid(   'B5SDETAIL', 	'B2SMASTER'	, oStruB5S)           
oModel:AddGrid(   'B6SDETAIL', 	'B5SDETAIL'	, oStruB6S) 

// Descrições
oModel:SetDescription( 'Aviso Lote Guia' )
oModel:GetModel( 'B2SMASTER' ):SetDescription( 'Lote' )   
oModel:GetModel( 'B5SDETAIL' ):SetDescription( 'Guias' )  
oModel:GetModel( 'B6SDETAIL' ):SetDescription( 'Eventos' ) 

// Relacionamentos
oModel:SetRelation( 'B5SDETAIL', { 	{ 	'B5S_FILIAL', 'xFilial( "B5S" )' 	},;
									{ 	'B5S_NUMLOT', 'B2S_NUMLOT'   		}},; 
										'B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO' )
										
oModel:SetRelation( 'B6SDETAIL', { 	{ 	'B6S_FILIAL', 'xFilial( "B6S" )' 	},;
									{ 	'B6S_NUMLOT', 'B5S_NUMLOT' 			},;
									{ 	'B6S_CODOPE', 'B5S_CODOPE' 			},;
									{ 	'B6S_CODLDP', 'B5S_CODLDP' 			},;
									{ 	'B6S_CODPEG', 'B5S_CODPEG' 			},;
									{ 	'B6S_NUMERO', 'B5S_NUMERO'   		}},;  
										'B6S_FILIAL+B6S_NUMLOT+B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO')	

oModel:SetPrimaryKey( { "B2S_FILIAL","B2S_NUMLOT","B2S_TIPGUI" } )																			

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} PLUA520Val
Valida a model

@author  Michel Montoro
@since   25/04/2018
@version P12
/*/
Function PLUA520Val(oModel)                       
Local aArea 		:= GetArea()
Local nOperation 	:= oModel:GetOperation()
Local lRet			:= .T.		
	                                     
If nOperation == MODEL_OPERATION_DELETE
    
	// Verifica a Fase para exclusao.

	If B2S->B2S_STATUS <> "1"
		Help( ,, 'HELP',,STR0020, 1, 0) //"Permitido apenas excluir registros com o Status [1] - Pend. Envio Aviso"
		lRet := .F.
	Endif 		

Endif
 
RestArea( aArea )

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procEnvio
Processa arquivo de envio

@author    Michel Montoro
@version   P12
@since     16/04/2018
/*/
//------------------------------------------------------------------------------------------
Function PLSU520PRO(lXml)

Local cTitulo	:= STR0021 //"Processa Arquivo de Envio"
Local cTexto	:= CRLF + CRLF +;
	STR0022 + CRLF +; 	//"Esta é a opção que irá efetuar a leitura das tabelas de contas médicas do PLS,"
	STR0023 + CRLF +; 	//"identIficar e processar atendimentos de intercâmbio eventual realizados para "
	STR0024 			//"beneficiários habituais."
Local aOpcoes	:= { STR0025,STR0026 } //"Processar" # "Cancelar"
Local nTaman	:= 3
Local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )
default lXml 	:= .f.
Private oProcess

If( nOpc == 1 )
	If( pergEnvio() )
		oProcess := msNewProcess():New( { | lEnd | PLUA520JOB( @lEnd,,lXml ) } , STR0027 , STR0028 , .F. ) //"Processando" # "Aguarde..."
		oProcess:Activate()
	EndIf
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} pergEnvio
Perguntas para composicao do arquivo de envio

@author    Michel Montoro
@version   P12
@since     16/04/2018
/*/
//------------------------------------------------------------------------------------------
Static Function pergEnvio()
Local lRet			:= .F.
Local aPergs		:= {}
Local cOperaDe		:= CriaVar("BD5_CODOPE",.F.)
Local cOperaAte		:= CriaVar("BD5_CODOPE",.F.)
Local cProtDe		:= CriaVar("BCI_CODPEG",.F.)
Local cProtAte		:= Replicate("Z",Len(cProtDe))
Local cMatrDe		:= CriaVar("BD5_CODOPE",.F.)+CriaVar("BD5_CODEMP",.F.)+CriaVar("BD5_MATRIC",.F.)+CriaVar("BD5_TIPREG",.F.)+CriaVar("BD5_DIGITO",.F.)
Local cMatrAte		:= Replicate("Z",Len(cMatrDe))
Local cDataDe		:= CriaVar("BD5_DTDIGI",.F.)
Local cDataAte		:= CriaVar("BD5_DTDIGI",.F.)
Local ni 			:= 1 


aadd(/*01*/ aPergs,{ 1,STR0029,	cOperaDe	,"@!",'.T.','B39PLS',/*'.T.'*/,40,.T. } ) //"Operadora De"
aadd(/*02*/ aPergs,{ 1,STR0030,	cOperaAte	,"@!",'.T.','B39PLS',/*'.T.'*/,40,.T. } ) //"Operadora Ate"
aadd(/*03*/ aPergs,{ 1,STR0031,	cProtDe		,"@!",'.T.','BC1PLS',/*'.T.'*/,40,.F. } ) //"Protocolo De"
aadd(/*04*/ aPergs,{ 1,STR0032,	cProtAte	,"@!",'.T.','BC1PLS',/*'.T.'*/,40,.T. } ) //"Protocolo Até"
aadd(/*05*/ aPergs,{ 1,STR0033,	cMatrDe		,"@!",'.T.',        ,/*'.T.'*/,40,.F. } ) //"Matricula De"
aadd(/*06*/ aPergs,{ 1,STR0034,	cMatrAte	,"@!",'.T.',        ,/*'.T.'*/,40,.T. } ) //"Matricula Até"
aadd(/*07*/ aPergs,{ 1,STR0035,	cDataDe		,"@!",'.T.',        ,/*'.T.'*/,50,.T. } ) //"Data De"
aadd(/*08*/ aPergs,{ 1,STR0036,	cDataAte	,"@!",'.T.',        ,/*'.T.'*/,50,.T. } ) //"Data Até"
aadd(/*09*/ aPergs,{ 2,"Status Guias:"		, space(1),{ "0=Digitação/Pronto","1=Pronto" },100,/*'.T.'*/,.t. } )

If( paramBox( aPergs,STR0037,__aRet,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSUA520',/*lCanSave*/.T.,/*lUserSave*/.T. ) ) //"Parâmetros - Processa Arquivo de Envio"
	If( validPergEnvio( __aRet ) )
		lRet := .T.
	Else
		lRet := pergEnvio()
	EndIf
EndIf
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} validPergEnvio
Validador de perguntas antes de processar o arquivo de envio

@author    Michel Montoro
@version   P12
@since     16/04/2018
/*/
//------------------------------------------------------------------------------------------
Static Function validPergEnvio( __aRet )
	Local nX
	Local lRet		:= .T.
	Local cMsgErro	:= STR0038 + CRLF + CRLF //"Corrija os itens abaixo antes de prosseguir:"
	
	For nX:=1 to len( __aRet )
		If		( nX == 1 .OR. nX == 2 )
			If Empty(__aRet[01] + __aRet[02])
				lRet		:= .F.
				cMsgErro += " - " + STR0039 + CRLF //"Parâmetros 'Operadoras De/Até' preenchidos incorretamente"
			EndIf
		ElseIf	( nX == 3 .OR. nX == 4 )
			If Empty(__aRet[03] + __aRet[04])
				lRet		:= .F.
				cMsgErro += " - " + STR0040 + CRLF //"Parâmetros 'Protocolos De/Até' preenchidos incorretamente"
			EndIf
		ElseIf	( nX == 5 .OR. nX == 6 )
			If Empty(__aRet[05] + __aRet[06])
				lRet		:= .F.
				cMsgErro += " - " + STR0041 + CRLF //"Parâmetros 'Matrículas De/Até' preenchidos incorretamente"
			EndIf
		ElseIf	( nX == 7 )
			If Empty(__aRet[07])
				lRet		:= .F.
				cMsgErro += " - " + STR0042 + CRLF //"Parâmetro 'Data De' preenchido incorretamente"
			EndIf
		ElseIf	( nX == 8 )
			If Empty(__aRet[08])
				lRet		:= .F.
				cMsgErro += " - " + STR0043 + CRLF //"Parâmetro 'Data Até' preenchido incorretamente"
			EndIf
		EndIf
	Next nx
	
	If( !lRet )
		Alert( cMsgErro )
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLUA520JOB
Faz o processamento das guias

@author  Michel Montoro
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------
Function PLUA520JOB(lEnd,lAuto,lXml)

Local nOpcao	:= 1
Local cini		:= ""
Local cfim		:= ""		

Local cAlias	:= ""
Local cNumLote	:= ""
Local cOpeAnt	:= ""
Local cChvAnt	:= ""
Local cAliBase	:= getNextAlias()
Local nVlrTaxa	:= 0
Local nVlrProc	:= 0
Local nTotTaxa	:= 0
Local nTotProc	:= 0
local ni 		:= 1

Local aDadUsr   := PLSGETUSR()
Local cGrpInt	:= ""
Local cPadInt	:= ""
Local cPadCon	:= ""
Local cRegAte	:= ""
Local aRdas		:= {}
Local cOpeRDA	:= ""
Local cTipPreFor:= ""
Local dDatProCir:= CToD("")
Local cHorCir	:= ""
Local cTipoGuia	:= ""
Local cProcGuia	:= ""
Local cModPag	:= ""
Local cParamDe	:= ""
Local cParamAte := ""
Local aVetPag	:= {}
Local aValor	:= {}
Local aDadUsr	:= {}
Local aZerados	:= {}
Local aCampos	:= {}
Local aCritica	:= {}
Local aResumo	:= {}
Local aDadRDA	:= {}
Local nGuias	:= 0 // Totalizador de controle para envio a cada 100 guias
Local nTotGuias	:= 0
Local nTotReg	:= 0
Local nCount	:= 0
Local nFor		:= 0
Local lRet		:= .T.
Local cMVPLSRDAG:= GetMV("MV_PLSRDAG")
Local oTmpBase	as object
local aTemLote  := {.T.}
Local aChvLote  := {}
local nPos 		:= 0
local nx 		:= 1
default lEnd 	:= .f.
default lAuto 	:= .f.
default lXml 	:= .f.

oProcess:SetRegua1( 4 ) //Alimenta a primeira barra de progresso
DbSelectArea("BQC")

fCriaBase(cAliBase,@oTmpBase)

cSql := " SELECT A.BD5_CODLDP, A.BD5_CODPEG, A.BD5_NUMERO FROM ( "
cSql += " SELECT BD5_CODEMP,BD5_DTDIGI, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO FROM " + RetSqlName("BD5") + " BD5 WHERE D_E_L_E_T_ = ' ' "
if ExistBlock("A520FIL")
	cSql += ExecBlock("A520FIL",.f.,.f., {"1", cSql})
endif
cSql += " ) A "
cSql += "    WHERE A.BD5_CODEMP = '" + GetNewPar("MV_PLSGEIN","0050")  + "' "
cSql += "    AND A.BD5_DTDIGI BETWEEN '" + dtos(__aRet[07])+"' AND '"+dtos(__aRet[08])+ "' "
if !empty(__aRet[03]) .and. !('ZZ' $ upper(__aRet[04]))
	cSql += "    AND A.BD5_CODPEG BETWEEN '" + __aRet[03] + "' AND '" + __aRet[04] + "' "
endif

if !empty(__aRet[05]) .and. !('ZZ' $ upper(__aRet[06]))
	cSql += " AND BD5.BD5_TIPGUI = '"+ cTipoGuia  +"' "// Resumo de Internação
	cParamDe	:= SUBSTR(__aRet[05],01,04)
	cParamAte	:= SUBSTR(__aRet[06],01,04)
	cSql += " AND BD5_CODOPE BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
	cParamDe	:= SUBSTR(__aRet[05],05,04)
	cParamAte	:= SUBSTR(__aRet[06],05,04)
	cSql += " AND BD5_CODEMP BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
	cParamDe	:= SUBSTR(__aRet[05],09,06)
	cParamAte	:= SUBSTR(__aRet[06],09,06)
	cSql += " AND BD5_MATRIC BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
	cParamDe	:= SUBSTR(__aRet[05],15,02)
	cParamAte	:= SUBSTR(__aRet[06],15,02)
	cSql += " AND BD5_TIPREG BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
	cParamDe	:= SUBSTR(__aRet[05],17,01)
	cParamAte	:= SUBSTR(__aRet[06],17,01)
	cSql += " AND BD5_DIGITO BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
endif
									
cSql := " Insert Into " +  oTmpBase:getrealName() + " (CODLDP, CODPEG, NUMERO) " + cSql
PLSCOMMIT(cSql) 

cSql := " SELECT A.BE4_CODLDP, A.BE4_CODPEG, A.BE4_NUMERO FROM ( "
cSql += " SELECT BE4_CODEMP,BE4_DTDIGI, BE4_CODLDP, BE4_CODPEG, BE4_NUMERO FROM " + RetSqlName("BE4") + " BE4 WHERE D_E_L_E_T_ = ' ' "
if ExistBlock("A520FIL")
	cSql += ExecBlock("A520FIL",.f.,.f., {"2", cSql})
endif
cSql += " ) A "
cSql += "    WHERE A.BE4_CODEMP = '" + GetNewPar("MV_PLSGEIN","0050")  + "' "
cSql += "    AND A.BE4_DTDIGI BETWEEN '" + dtos(__aRet[07])+"' AND '"+dtos(__aRet[08])+ "' "
if !empty(__aRet[03]) .and. !('ZZ' $ upper(__aRet[04]))
	cSql += "    AND A.BE4_CODPEG BETWEEN '" + __aRet[03] + "' AND '" + __aRet[04] + "' "
endif

if !empty(__aRet[05]) .and. !('ZZ' $ upper(__aRet[06]))
	cSql += " AND BE4.BE4_TIPGUI = '"+ cTipoGuia  +"' "// Resumo de Internação
	cParamDe	:= SUBSTR(__aRet[05],01,04)
	cParamAte	:= SUBSTR(__aRet[06],01,04)
	cSql += " AND BE4_CODOPE BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
	cParamDe	:= SUBSTR(__aRet[05],05,04)
	cParamAte	:= SUBSTR(__aRet[06],05,04)
	cSql += " AND BE4_CODEMP BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
	cParamDe	:= SUBSTR(__aRet[05],09,06)
	cParamAte	:= SUBSTR(__aRet[06],09,06)
	cSql += " AND BE4_MATRIC BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
	cParamDe	:= SUBSTR(__aRet[05],15,02)
	cParamAte	:= SUBSTR(__aRet[06],15,02)
	cSql += " AND BE4_TIPREG BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
	cParamDe	:= SUBSTR(__aRet[05],17,01)
	cParamAte	:= SUBSTR(__aRet[06],17,01)
	cSql += " AND BE4_DIGITO BETWEEN '"+ cParamDe +"' AND '"+ cParamAte +"' "
endif

cSql := " Insert Into " +  oTmpBase:getrealName() + " (CODLDP, CODPEG, NUMERO) " + cSql
PLSCOMMIT(cSql)

cini		:= time()
For nOpcao 	:= 1 To 4

	If nOpcao == 1
		cTipoGuia := G_CONSULTA
		cProcGuia := "CONSULTA"
	ElseIf nOpcao == 2
		cTipoGuia := G_SADT_ODON
		cProcGuia := "SADT"
	ElseIf nOpcao == 3
		cTipoGuia := G_HONORARIO
		cProcGuia := "HONORARIO"
	ElseIf nOpcao == 4
		cTipoGuia := G_RES_INTER
		cProcGuia := "RESUMO INTERNACAO"
	EndIf
	
	nTotReg	:= 0
	nCount	:= 0
	
	cAlias := PL520QUERY(cTipoGuia,oTmpBase:getrealName())
	oProcess:IncRegua1( STR0044 + cProcGuia ) //"Processando Lote: "
	
	nTotGuias	:= 0
		
	If !(cAlias)->(Eof())
	
		aZerados := {}
		nTotReg := Contar(cAlias,"!EoF()")
		oProcess:SetRegua2( nTotReg ) 	//Alimenta a segunda barra de progresso
		(cAlias)->(DbGoTop())
		
		While !(cAlias)->(Eof())
			nCount++
			oProcess:IncRegua2( STR0045 + "[" + cvaltochar(nCount) + "] - [" + cvaltochar(nTotReg) + "]" ) //"Processando De: "
			
			// Verifica se ja tem lote para mesma operadora origem
			if lXml
				nPos := aScan( aChvLote,{| x | allTrim( x[ 1 ] ) == allTrim( (cAlias)->(FILIAL+OPEORI) ) } )
				
				if nPos > 0 
					aTemLote := {.F.,aChvLote[nPos][2]}
				else 
					aTemLote := {.T.}
				endif  

			endif 

			If aTemLote[1] .and. (cOpeAnt <> (cAlias)->(FILIAL+OPEORI)) .OR. ( nGuias >= 9999 .AND. cChvAnt <> iif(lXml,"",(cAlias)->BD6_TIPGUI)+(cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ) ;
			 .or. (!lXml .and. (B2S->B2S_DATTRA <> stod((cAlias)->BD6_DTDIGI) .or. B2S->B2S_CODRDA <> (cAlias)->BD6_CODRDA))
				If nGuias >= 9999 .AND. cChvAnt <> (cAlias)->(BD6_TIPGUI+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
					cChvAnt := ""
				EndIf
				nGuias 	:= 0
				cOpeAnt := (cAlias)->(FILIAL+OPEORI)
				cNumLote := GetSx8Num("B2S","B2S_NUMLOT")
				
				 Aadd(aChvLote,{cOpeAnt,cNumLote})

				aCampos	:= {}
				aadd( aCampos,{ "B2S_FILIAL"	,xFilial( "B2S" ) 			} )	// Filial
				aadd( aCampos,{ "B2S_STATUS"	, "1"			 			} )	// 1=Pend. Envio Aviso;2=Aviso Enviado;3=Retorno Importado
				aadd( aCampos,{ "B2S_OPEORI"	,(cAlias)->OPEORI			} )	// Operadora Origem
				aadd( aCampos,{ "B2S_OPEHAB"	,(cAlias)->OPEUSR			} )	// Operadora Habitual
				aadd( aCampos,{ "B2S_NUMLOT"	,cNumLote					} )
				if !lXml
					aadd( aCampos,{ "B2S_TIPGUI"	,cTipoGuia					} )
				endif
				aadd( aCampos,{ "B2S_DATTRA"	,iif(lXml,dDatabase,stod((cAlias)->BD6_DTDIGI))	} )
				aadd( aCampos,{ "B2S_CODRDA"	,iif(lXml, "",(cAlias)->BD6_CODRDA)		} )				
				lRet := PLU520Grv( 3, aCampos, 'MODEL_B2S', 'PLSU520B2S' )
				
				If lRet
					B2S->( ConfirmSx8() )
				Else
					B2S->( RollBackSx8() )
				EndIf

			EndIf
			B5S->(dbsetorder(1)) // B5S_FILIAL, B5S_NUMLOT, B5S_CODOPE, B5S_CODLDP, B5S_CODPEG, B5S_NUMERO, B5S_STATUS, R_E_C_D_E_L_		
			
			if !aTemLote[1]  // Se falso pega o lote existente
				cNumLote =aTemLote[2]
			endif

			If !B5S->(msseek(xfilial("B5S") + cNumLote + (cAlias)->BD6_CODOPE + (cAlias)->BD6_CODLDP + (cAlias)->BD6_CODPEG + (cAlias)->BD6_NUMERO))
				nGuias++
				nTotGuias++
				if lXml
					cChvAnt := (cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
				else
					cChvAnt := (cAlias)->(BD6_TIPGUI+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
				endif
				nTotProc := nTotTaxa := 0
				
				aCampos	:= {}
				aadd( aCampos,{ "B5S_FILIAL"	,xFilial( "B5S" ) 			} )
				aadd( aCampos,{ "B5S_NUMLOT"	,cNumLote		 			} )
				aadd( aCampos,{ "B5S_OPEORI"	,(cAlias)->OPEORI			} )
				aadd( aCampos,{ "B5S_CODOPE"	,(cAlias)->BD6_CODOPE		} )
				aadd( aCampos,{ "B5S_CODLDP"	,(cAlias)->BD6_CODLDP		} )
				aadd( aCampos,{ "B5S_CODPEG"	,(cAlias)->BD6_CODPEG		} )
				aadd( aCampos,{ "B5S_NUMERO"	,(cAlias)->BD6_NUMERO		} )
				aadd( aCampos,{ "B5S_VLRTAX"	,nTotTaxa					} )
				aadd( aCampos,{ "B5S_VLRPRO"	,nTotProc					} )
				aadd( aCampos,{ "B5S_TIPGUI"	,cTipoGuia					} )
				lRet := PLU520Grv( 3, aCampos, 'MODEL_B5S', 'PLSU520B5S' )
				
			EndIf
			
			If (cAlias)->BD6_VLRBPR == 0
				cGrpInt 	:= IIF(nOpcao <> 4,(cAlias)->BD5_GRPINT,(cAlias)->BE4_GRPINT)
				cPadInt 	:= IIF(nOpcao <> 4,(cAlias)->BD5_PADINT,(cAlias)->BE4_PADINT)
				cPadCon 	:= IIF(nOpcao <> 4,(cAlias)->BD5_PADCON,(cAlias)->BE4_PADCON)
				cRegAte		:= IIF(nOpcao <> 4,(cAlias)->BD5_REGATE,"")
				
				aRdas		:= {}
				cOpeRDA		:= ""
				cTipPreFor 	:= (cAlias)->TIPPRE
				dDatProCir 	:= SToD((cAlias)->BD6_DTDIGI)
				cHorCir 	:= substr(strTran((cAlias)->BD6_HORPRO,':',""),1,4)
				
				aDadUsr  	:= PLSDADUSR((cAlias)->(OPEUSR+CODEMP+MATRIC+TIPREG+DIGITO),'1',.F.,dDatabase,,,"NAO_VALIDAR_CARTAO")
				If !aDadUsr[01]
					aAdd(aCritica,{cProcGuia,(cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO),(cAlias)->(OPEUSR+CODEMP+MATRIC+TIPREG+DIGITO),(cAlias)->(BD6_CODPAD+"-"+BD6_CODPRO),"Dados do usuário não encontrado."})
					aAdd( aZerados,(cAlias)->(cNumLote+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) )
					(cAlias)->(dbSkip())
					Loop
				Else
					cModPag		:= IIF(Len(aDadUsr)>=48,aDadUsr[48],"")
				EndIf
				
				aDadRDA 	:= PLSDADRDA(aDadUsr[37],cMVPLSRDAG,"1",dDatabase)
				If !aDadRDA[1]
					aAdd(aCritica,{cProcGuia,(cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO),(cAlias)->(OPEUSR+CODEMP+MATRIC+TIPREG+DIGITO),(cAlias)->(BD6_CODPAD+"-"+BD6_CODPRO),"Dados da RDA não encontrado:"+cMVPLSRDAG})
					aAdd( aZerados,(cAlias)->(cNumLote+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) )
					(cAlias)->(dbSkip())
					Loop
				EndIf
								
				aValor := PLSCALCEVE(  (cAlias)->BD6_CODPAD, (cAlias)->BD6_CODPRO,	(cAlias)->BD6_MESPAG, 	(cAlias)->BD6_ANOPAG,	(cAlias)->BD6_CODOPE,	;
										(cAlias)->BD6_CODRDA, (cAlias)->BD6_CODESP,	(cAlias)->BD6_SUBESP,	(cAlias)->BD6_CODLOC, 	(cAlias)->BD6_QTDPRO,	;
										dDatProCir,			  cModPag,				cPadInt,				cRegAte,				(cAlias)->BD6_VLRAPR,	;
		                        		aDadUsr,			  cPadCon,				{},						(cAlias)->BD6_CODTAB,	nil,					;
		                        		nil,				  nil,					cHorCir,				{},						.f.)

				aVetPag := PLSCALCCOP(	(cAlias)->BD6_CODPAD,	(cAlias)->BD6_CODPRO,	(cAlias)->BD6_MESPAG,(cAlias)->BD6_ANOPAG,	aDadRDA[02],	;
										aDadRDA[15],			Nil,					aDadRDA[12],		(cAlias)->BD6_QTDPRO,	dDatProCir,		;
										.F.,					"2",					(cAlias)->BD6_VLRAPR,Nil,					aDadUsr,		;
										cPadInt,				cPadCon,				{},					cRegAte,				0,				;
										.t.,					Nil,					cHorCir,			{},						aDadRDA[14],	;
										Nil,					Nil,					Nil,				Nil,					Nil,			;
										Nil,					dDatProCir,				cHorCir,			(cAlias)->BD6_CID,		Nil,			;
										(cAlias)->BD6_TIPGUI,	Nil,					Nil,				Nil,					Nil,			;
										Nil,					Nil,					Nil,				Nil,					Nil,			;
										Nil,					Nil,					Nil,				Nil,					Nil,			;
										Nil,					Nil,					Nil,				Nil,					aValor			)
												
				If ! Empty(aVetPag)
					nVlrTaxa := aVetPag[14]
					nTotTaxa += nVlrTaxa
					nVlrProc := aVetPag[13] + nVlrTaxa
					nTotProc += nVlrProc
					If nVlrProc == 0
						if ascan(aZerados,aAdd( aZerados,cNumLote+(cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) )) == 0							
							aAdd( aZerados,cNumLote+(cAlias)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) )
						endif
					EndIf
				EndIf
			Else
				nVlrTaxa := (cAlias)->BD6_VLRTAD
				nTotTaxa += nVlrTaxa
				nVlrProc := (cAlias)->BD6_VLRPF + (cAlias)->BD6_VLRTAD
				nTotProc += nVlrProc
			EndIf
			
			aCampos	:= {}
			aadd( aCampos,{ "B6S_FILIAL"	,xFilial( "B6S" ) 			} )
			aadd( aCampos,{ "B6S_NUMLOT"	,cNumLote		 			} )
			aadd( aCampos,{ "B6S_OPEORI"	,(cAlias)->OPEORI			} )
			aadd( aCampos,{ "B6S_CODOPE"	,(cAlias)->BD6_CODOPE		} )
			aadd( aCampos,{ "B6S_CODLDP"	,(cAlias)->BD6_CODLDP		} )
			aadd( aCampos,{ "B6S_CODPEG"	,(cAlias)->BD6_CODPEG		} )
			aadd( aCampos,{ "B6S_NUMERO"	,(cAlias)->BD6_NUMERO		} )
			aadd( aCampos,{ "B6S_ORIMOV"	,(cAlias)->BD6_ORIMOV		} )
			aadd( aCampos,{ "B6S_SEQUEN"	,(cAlias)->BD6_SEQUEN		} )
			aadd( aCampos,{ "B6S_DATPRO"	,SToD((cAlias)->BD6_DTDIGI)	} )
			aadd( aCampos,{ "B6S_CODPAD"	,(cAlias)->BD6_CODPAD		} )
			aadd( aCampos,{ "B6S_CODPRO"	,(cAlias)->BD6_CODPRO		} )
			aadd( aCampos,{ "B6S_QTDPRO"	,(cAlias)->BD6_QTDPRO		} )
			aadd( aCampos,{ "B6S_VLRTAX"	,nVlrTaxa					} )
			aadd( aCampos,{ "B6S_VLRPRO"	,nVlrProc	  				} )
			lRet := PLU520Grv( 3, aCampos, 'MODEL_B6S', 'PLSU520B6S' )
			
			aCampos	:= {}
			aadd( aCampos,{ "B5S_VLRTAX"	,nTotTaxa				} )
			aadd( aCampos,{ "B5S_VLRPRO"	,nTotProc				} )
			lRet := PLU520Grv( 4, aCampos, 'MODEL_B5S', 'PLSU520B5S' )
			
			(cAlias)->(dbSkip())
			
		EndDo
		
		If !empty(aZerados)
			For nFor := 1 To Len(aZerados)
				aCampos := {}
				B5S->(DBSetorder(1)) //B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO
				If B5S->( MsSeek(xFilial("B5S")+aZerados[nFor]) ) .and. B5S->B5S_VLRPRO <= 0
					aAdd( aCritica,{cProcGuia,aZerados[nFor],B5S->B5S_OPEORI,'',"Guia sem valor - Guia não processada !!!"} )
					While ( B5S->(!eof()) .And. B5S->(B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) == xFilial("B5S")+aZerados[nFor] )
						nTotGuias := nTotGuias - 1
						PLU520Grv( 5, aCampos, 'MODEL_B5S', 'PLSU520B5S' )
						B5S->( dbSkip() )
					EndDo				
				
					B6S->(DBSetorder(1)) //B6S_FILIAL+B6S_NUMLOT+B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO
					If B6S->( MsSeek(xFilial("B6S")+aZerados[nFor]) )
						While ( B6S->(!eof()) .And. B6S->(B6S_FILIAL+B6S_NUMLOT+B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO) == xFilial("B6S")+aZerados[nFor] )
							PLU520Grv( 5, aCampos, 'MODEL_B6S', 'PLSU520B6S' )
							B6S->( dbSkip() )
						EndDo
					EndIf
				EndIf
				// Se não achar nenhuma guia no lote, deleto o lote na B2S
				DBSelectarea("B5S")
				B5S->(DBSetorder(1)) //B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO
				If !B5S->( MsSeek(xFilial("B5S")+cNumLote) )
					DBSelectarea("B2S")
					If B2S->( MsSeek(xFilial("B2S")+cNumLote) )
						PLU520Grv( 5, aCampos, 'MODEL_B2S', 'PLSU520B2S' )
					EndIf
				EndIf
			Next nFor
			
		EndIf
		aAdd(aResumo,{cProcGuia,STR0046 + STRZero(nTotGuias,8)+STR0047}) //"Foram processados: " # " Guia(s)." 
		
	Else
		aAdd(aResumo,{cProcGuia,STR0048}) //"Registros não encontrado !!!"
	EndIf
	
	(cAlias)->(dbCloseArea())
	
Next nOpcao

cfim := time()

(cAliBase)->(dbclosearea())

oTmpBase:Delete()
freeObj(oTmpBase)               
oTmpBase := nil

If !Empty(aCritica) .and. !lAuto
	PLSCRIGEN(aCritica,{ {STR0049,"@C",25}	,{STR0050,"@C",40},{STR0051,"@C",35},{STR0052,"@C",15},{STR0053,"@C",50} },STR0054 ) //"Tipo da Guia" # "Chave da Guia" # "Chave Beneficiário" # "Procedimento" # "Critica" # "RESUMO DE CRÍTICAS"
EndIf
If !Empty(aResumo) .and. !lAuto
	PLSCRIGEN(aResumo,{ {STR0049,"@C",30},{STR0055,"@C",120} },STR0056 )//"Tipo da Guia" # "Resumo" # "RESUMO DE PROCESSAMENTO"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL520QUERY
Query das Guias

@author  Michel Montoro
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------
Static Function PL520QUERY(cTipoGuia,cAliTmp)
Local cSql 		:= ""
Local cParamDe	:= ""
Local cParamAte	:= ""

DEFAULT cTipoGuia	:= G_CONSULTA

Do Case
	
Case cTipoGuia == G_CONSULTA .OR. cTipoGuia == G_SADT_ODON .OR. cTipoGuia == G_HONORARIO // CONSULTA ou SADT ou  HONORARIO
	cSql := " SELECT "
	//--< DADOS DA GUIA >---
	cSql += " BD6_TIPGUI, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN, BD6_FASE, "
	//--< DADOS DO PROCEDIMENTO >---
	cSql += " BD6_DTDIGI, BD6_HORPRO, BD6_CODPAD, BD6_CODPRO, BD6_QTDPRO, BD6_QTDAPR, BD6_CODTAB, "
	//--< VALORES >---
	cSql += " BD6_VLRAPR, BD6_VLRPAG, BD6_VLRGLO, BD6_VLTXPG, BD6_VLRTAD, "
	cSql += " BD6_VLRPF,  BD6_VLRTPF, BD6_VLRBPR, BD6_VLRACB, "
	//--< DADOS DO BENEFICIARIO >---
	cSql += " BD5_FILIAL AS FILIAL, BD5_OPEUSR AS OPEUSR, BD5_CODEMP AS CODEMP, BD5_MATRIC AS MATRIC, BD5_TIPREG AS TIPREG, BD5_DIGITO AS DIGITO, BD6_MATANT AS MATANT, BD6_OPEORI OPEORI, "
	//--< OUTROS >---
	cSql += " BD5_GRPINT, BD5_PADINT, BD5_PADCON, BD5_REGATE, BD6_GUIACO, BD6_PAGATO, BD6_MESPAG, BD6_ANOPAG, "
	cSql += " BD5_TIPPRE AS TIPPRE, BD6_CODRDA, BD6_CODESP, BD6_SUBESP, BD6_CODLOC, BD6_PROREL, BD6_PRPRRL, BD6_NIVCRI, "
	cSql += " BD6_CHVNIV, BD6_CID,    BD6_MODCOB, BD6.R_E_C_N_O_ BD6Recno "
	
	cSql += " FROM " + RetSqlName("BD5") + " BD5 " 
	cSql += " INNER JOIN " + cAliTmp 
	cSql += " ON BD5.BD5_FILIAL = '" + xFilial("BD5") + "' "
	cSql += " AND BD5_CODOPE = '" + cCodInt + "' "
	cSql += " AND BD5_CODLDP = CODLDP "
	cSql += " AND BD5_CODPEG = CODPEG "
	cSql += " AND BD5_NUMERO = NUMERO "
	cSql += " AND BD5.D_E_L_E_T_ = ' ' "
	
	cSql += " INNER JOIN " + RetSqlName("BD6") + " BD6 "  
	cSql += " ON BD6_FILIAL = '" + xFilial("BD6") + "' "
	cSql += " AND BD6_CODOPE = BD5_CODOPE "
	cSql += " AND BD6_CODLDP = BD5_CODLDP "
	cSql += " AND BD6_CODPEG = BD5_CODPEG "
	cSql += " AND BD6_NUMERO = BD5_NUMERO "
	cSql += " AND BD6_ORIMOV = BD5_ORIMOV "
	cSql += " AND BD6_OPEORI BETWEEN '" + __aRet[01] + "' AND '"+  __aRet[02] +"' "	
	cSql += " AND BD6_OPEORI <> '" + cCodInt + "' "	
	cSql += " AND BD6_STAFAT <> '0'  "
	cSql += " AND BD6.D_E_L_E_T_ = ' ' "
		
	cSql += " WHERE BD5_SITUAC = '1'  "	
	if __aRet[9] == "0"	
		cSql += " AND BD5_FASE IN ('1','2','3') "	//1=Digitacao;2=Conferencia;3=Pronta;4=Faturada
	else
		cSql += " AND BD5_FASE = '3' "
	endif
	cSql += " AND BD5_LIBERA <> '1' "
	cSql += " AND BD5_TIPGUI = '"+ cTipoGuia  +"' "
	cSql += " AND BD5_STAFAT <> '0'  "
	
	cSQL += " AND NOT EXISTS( "
	cSQL += " SELECT * FROM "+RetSQLName("B5S")+" B5S "
	cSQL += " WHERE B5S.B5S_FILIAL = '" + xFilial("B5S") + "' "
	cSQL += "   AND B5S.B5S_CODOPE = BD5.BD5_CODOPE "
	cSQL += "   AND B5S.B5S_CODLDP = BD5.BD5_CODLDP "
	cSQL += "   AND B5S.B5S_CODPEG = BD5.BD5_CODPEG "
	cSQL += "   AND B5S.B5S_NUMERO = BD5.BD5_NUMERO "
	cSQL += "   AND (B5S.B5S_GUICRI = ' ' OR B5S.B5S_GUICRI = '0') "
	cSQL += "   AND B5S.D_E_L_E_T_ = ' ') "

Case cTipoGuia == G_RES_INTER // RESUMO ou HONORARIO
	cSql := " SELECT "
	//--< DADOS DA GUIA >---
	cSql += " BD6_TIPGUI, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN, BD6_FASE, "
	//--< DADOS DO PROCEDIMENTO >---
	cSql += " BD6_DTDIGI, BD6_HORPRO, BD6_CODPAD, BD6_CODPRO, BD6_QTDPRO, BD6_QTDAPR, BD6_CODTAB, "
	//--< VALORES DE COPARTICIPACAO >---
	cSql += " BD6_VLRAPR, BD6_VLRPAG, BD6_VLRGLO, BD6_VLTXPG, BD6_VLRTAD, "
	cSql += " BD6_VLRPF,  BD6_VLRTPF, BD6_VLRBPR, BD6_VLRACB, "
	//--< DADOS DO BENEFICIARIO >---
	cSql += " BE4_FILIAL AS FILIAL, BE4_OPEUSR AS OPEUSR, BE4_CODEMP AS CODEMP, BE4_MATRIC AS MATRIC, BE4_TIPREG AS TIPREG, BE4_DIGITO AS DIGITO, BD6_MATANT AS MATANT, BD6_OPEORI OPEORI, "
	//--< OUTROS >---
	cSql += " BE4_GRPINT, BE4_PADINT, BE4_PADCON, BD6_GUIACO, BD6_PAGATO, BD6_MESPAG, BD6_ANOPAG, "
	cSql += " BE4_TIPPRE TIPPRE, BD6_CODRDA, BD6_CODESP, BD6_SUBESP, BD6_CODLOC, BD6_PROREL, BD6_PRPRRL, BD6_NIVCRI, "
	cSql += " BD6_CHVNIV, BD6_CID,    BD6_MODCOB, BD6.R_E_C_N_O_ BD6Recno "
	
	cSql += " FROM " + RetSqlName("BE4") + " BE4 " 
	cSql += " INNER JOIN " + cAliTmp 
	cSql += " ON BE4.BE4_FILIAL = '" + xFilial("BE4") + "' "
	cSql += " AND BE4_CODOPE = '" + cCodInt + "' "
	cSql += " AND BE4_CODLDP = CODLDP "
	cSql += " AND BE4_CODPEG = CODPEG "
	cSql += " AND BE4_NUMERO = NUMERO "
	cSql += " AND BE4.D_E_L_E_T_ = ' ' "

	cSql += " INNER JOIN " + RetSqlName("BD6") + " BD6 "
	cSql += " ON  BD6_FILIAL = '" + xFilial("BD6") + "' "
	cSql += " AND BD6_CODOPE = BE4.BE4_CODOPE "
	cSql += " AND BD6_CODLDP = BE4.BE4_CODLDP "
	cSql += " AND BD6_CODPEG = BE4.BE4_CODPEG "
	cSql += " AND BD6_NUMERO = BE4.BE4_NUMERO "
	cSql += " AND BD6_ORIMOV = BE4.BE4_ORIMOV "
	cSql += " AND BD6_OPEORI BETWEEN '" + __aRet[01] + "' AND '"+  __aRet[02] +"' "	
	cSql += " AND BD6_OPEORI <> '" + cCodInt + "' "	
	cSql += " AND BD6_LIBERA <> '1' "			//1=Sim;0=Nao
	cSql += " AND BD6_STAFAT <> '0'  "
	cSql += " AND BD6.D_E_L_E_T_ = ' '  "
	

	cSql += " WHERE BE4.BE4_SITUAC = '1' " 			//1=Ativa;2=Cancelada;3=Bloqueada "	
	if __aRet[9] == "0"	
		cSql += " AND BE4.BE4_FASE IN ('1','2','3') "	//1=Digitacao;2=Conferencia;3=Pronta;4=Faturada
	else
		cSql += " AND BE4.BE4_FASE = '3' "
	endif	
	cSql += " AND BE4.BE4_TIPGUI = '"+ cTipoGuia  +"' "// Resumo de Internação	
	cSql += " AND BE4_STAFAT <> '0'  "
	cSql += " AND BE4.D_E_L_E_T_ = ' '  "	
	cSQL += " AND NOT EXISTS( "
	cSQL += " SELECT * FROM "+RetSQLName("B5S")+" B5S "
	cSQL += " WHERE B5S.B5S_FILIAL = '" + xFilial("B5S") + "' "
	cSQL += "   AND B5S.B5S_CODOPE = BE4.BE4_CODOPE "
	cSQL += "   AND B5S.B5S_CODLDP = BE4.BE4_CODLDP "
	cSQL += "   AND B5S.B5S_CODPEG = BE4.BE4_CODPEG "
	cSQL += "   AND B5S.B5S_NUMERO = BE4.BE4_NUMERO "
	cSQL += "   AND (B5S.B5S_GUICRI = ' ' OR B5S.B5S_GUICRI = '0') "
	cSQL += "   AND B5S.D_E_L_E_T_ = ' ') "

Case cTipoGuia == "GLOSA" // Query relacionado á registros glosados
	cSql := " SELECT BD5.BD5_VLRGLO,BD5.BD5_VLRTPF,B5S.*, B5S.R_E_C_N_O_ AS B5SRecno " 
	cSql += " FROM " + RetSqlName("B2S") + " B2S "
	cSql += " INNER JOIN " + RetSqlName("B5S") + " B5S "
	cSql += " 	ON  B5S.B5S_FILIAL = '" + xFilial("B5S") + "' "
	cSql += " 	AND B5S.B5S_NUMLOT = B2S.B2S_NUMLOT "
	cSql += " 	AND B5S.B5S_VLRGLO = 0 "
	cSql += " 	AND (B5S.B5S_STAGLO = '0' OR B5S.B5S_STAGLO = ' ') " // 0=Sem Glosa
	cSql += " 	AND B5S.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("BD5") + " BD5 "
	cSql += " 	ON  BD5.BD5_FILIAL = '" + xFilial("BD5") + "' "
	cSql += " 	AND BD5.BD5_CODOPE = B5S_CODOPE "
	cSql += " 	AND BD5.BD5_CODLDP = B5S_CODLDP "
	cSql += " 	AND BD5.BD5_CODPEG = B5S_CODPEG "
	cSql += " 	AND BD5.BD5_NUMERO = B5S_NUMERO "
	cSql += " 	AND BD5.BD5_VLRPAG = 0 " // Regra principal para definir Glosa
	cSql += " 	AND BD5.D_E_L_E_T_ = ' ' "
	cSql += " WHERE B2S.B2S_FILIAL = '" + xFilial("B2S") + "' "
	cSql += " 	AND B2S.B2S_OPEORI BETWEEN '" + __aRetGlo[01]		+ "' AND '" + __aRetGlo[02] 		+ "' "
	cSql += " 	AND B2S.B2S_NUMLOT BETWEEN '" + __aRetGlo[03]		+ "' AND '" + __aRetGlo[04] 		+ "' "
	cSql += " 	AND B2S.B2S_DATENV BETWEEN '" + DToS(__aRetGlo[05])	+ "' AND '" + DToS(__aRetGlo[06]) 	+ "' "
	cSql += " 	AND B2S.B2S_STATUS IN ('2','3') "
	cSql += " 	AND B2S.D_E_L_E_T_ = ' ' "
	
Case cTipoGuia == "PTUA530" // Query relacionado ao envio do PTU A530
	cSql := " SELECT B2S_DATENV AS DATENV, B2S_NUMLOT AS NUMLOT, B2S_OPEHAB AS OPEHAB, B2S_TIPGUI AS TIPGUI, " 
	cSql += " BD5_CODOPE AS CODOPE, BD5_MATANT AS MATANT, BD5.R_E_C_N_O_ AS BD5BE4Recno, 'N' AS INTERNA, "
	cSql += " B5S_CODOPE, B5S_CODLDP, B5S_CODPEG, B5S_NUMERO " 
	cSql += " FROM " + RetSqlName("B2S") + " B2S "
	cSql += " INNER JOIN " + RetSqlName("B5S") + " B5S "
	cSql += " 	ON  B5S.B5S_FILIAL = '" + xFilial("B5S") + "' "
	cSql += " 	AND B5S.B5S_NUMLOT = B2S.B2S_NUMLOT "
	cSql += " 	AND B5S.B5S_VLRGLO > 0 "
	If __aRetGlo[07] == "Sim"
		cSql += " 	AND (B5S.B5S_STAGLO = '1' OR B5S.B5S_STAGLO = '2') " // 1=Pend. Envio Glosa - 2=Glosa Enviada
	Else
		cSql += " 	AND B5S.B5S_STAGLO = '1' " // 1=Pend. Envio Glosa
	EndIf
	cSql += " 	AND B5S.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("BD5") + " BD5 "
	cSql += " 	ON  BD5.BD5_FILIAL = '" + xFilial("BD5") + "' "
	cSql += " 	AND BD5.BD5_CODOPE = B5S_CODOPE "
	cSql += " 	AND BD5.BD5_CODLDP = B5S_CODLDP "
	cSql += " 	AND BD5.BD5_CODPEG = B5S_CODPEG "
	cSql += " 	AND BD5.BD5_NUMERO = B5S_NUMERO "
	cSql += " 	AND BD5.D_E_L_E_T_ = ' ' "
	cSql += " WHERE B2S.B2S_FILIAL = '" + xFilial("B2S") + "' "
	cSql += " 	AND B2S.B2S_OPEORI BETWEEN '" + __aRetGlo[01]		+ "' AND '" + __aRetGlo[02] 		+ "' "
	cSql += " 	AND B2S.B2S_NUMLOT BETWEEN '" + __aRetGlo[03]		+ "' AND '" + __aRetGlo[04] 		+ "' "
	cSql += " 	AND B2S.B2S_DATENV BETWEEN '" + DToS(__aRetGlo[05])	+ "' AND '" + DToS(__aRetGlo[06]) 	+ "' "
	cSql += " 	AND B2S.B2S_STATUS IN ('2','3') "
	cSql += " 	AND B2S.D_E_L_E_T_ = ' ' "
	cSql += " "
	cSql += " UNION "
	cSql += " "
	cSql += " SELECT B2S_DATENV AS DATENV, B2S_NUMLOT AS NUMLOT, B2S_OPEHAB AS OPEHAB, B2S_TIPGUI AS TIPGUI, " 
	cSql += " BE4_CODOPE AS CODOPE, BE4_MATANT AS MATANT, BE4.R_E_C_N_O_ AS BD5BE4Recno, 'S' AS INTERNA, "
	cSql += " B5S_CODOPE, B5S_CODLDP, B5S_CODPEG, B5S_NUMERO "  
	cSql += " FROM " + RetSqlName("B2S") + " B2S "
	cSql += " INNER JOIN " + RetSqlName("B5S") + " B5S "
	cSql += " 	ON  B5S.B5S_FILIAL = '" + xFilial("B5S") + "' "
	cSql += " 	AND B5S.B5S_NUMLOT = B2S.B2S_NUMLOT "
	cSql += " 	AND B5S.B5S_VLRGLO > 0 "
	If __aRetGlo[07] == "Sim"
		cSql += " 	AND (B5S.B5S_STAGLO = '1' OR B5S.B5S_STAGLO = '2') " // 1=Pend. Envio Glosa - 2=Glosa Enviada
	Else
		cSql += " 	AND B5S.B5S_STAGLO = '1' " // 1=Pend. Envio Glosa
	EndIf
	cSql += " 	AND B5S.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("BE4") + " BE4 "
	cSql += " 	ON  BE4.BE4_FILIAL = '" + xFilial("BE4") + "' "
	cSql += " 	AND BE4.BE4_CODOPE = B5S_CODOPE "
	cSql += " 	AND BE4.BE4_CODLDP = B5S_CODLDP "
	cSql += " 	AND BE4.BE4_CODPEG = B5S_CODPEG "
	cSql += " 	AND BE4.BE4_NUMERO = B5S_NUMERO "
	cSql += " 	AND BE4.D_E_L_E_T_ = ' ' "
	cSql += " WHERE B2S.B2S_FILIAL = '" + xFilial("B2S") + "' "
	cSql += " 	AND B2S.B2S_OPEORI BETWEEN '" + __aRetGlo[01]		+ "' AND '" + __aRetGlo[02] 		+ "' "
	cSql += " 	AND B2S.B2S_NUMLOT BETWEEN '" + __aRetGlo[03]		+ "' AND '" + __aRetGlo[04] 		+ "' "
	cSql += " 	AND B2S.B2S_DATENV BETWEEN '" + DToS(__aRetGlo[05])	+ "' AND '" + DToS(__aRetGlo[06]) 	+ "' "
	cSql += " 	AND B2S.B2S_STATUS IN ('2','3') "
	cSql += " 	AND B2S.D_E_L_E_T_ = ' ' "

EndCase

cSql := ChangeQuery(cSql)

If Select("TrbPeg") > 0
	TrbPeg->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbPeg",.F.,.T.)

Return "TrbPeg"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUGLO520
Efetua a análise das guias glosadas

@author  Michel Montoro
@since   16/04/2018
@version P12
/*/
Function PLSUGLO520(cProcesso)

Local cTitulo	:= ""
Local cTexto	:= ""
Local aOpcoes	:= { STR0025,STR0026 } //"Processar" # "Cancelar"
Local nTaman	:= 3
Local nOpc		:= 0
Local lRet		:= .T.

Private __aRetGlo	:= {}
Private oProcess := Nil

If cProcesso == "1"
	
	cTitulo	:= STR0057 		//"Processa análise de guias glosadas"
	cTexto	:= 	CRLF + CRLF +;
	STR0058 + 	CRLF +; 	//"Esta é a opção que irá efetuar a leitura das tabelas de contas médicas do PLS e"
	STR0059 + 	CRLF +; 	//"identificar os registros com valores de participação financeira zerados e que  "
	STR0060 				//"já foram exportados para a Operadora Origem na rotina de Gestão de Avisos."
	nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )
	
	If( nOpc == 1 )
		If( pergGlosa(cProcesso) )
			oProcess := msNewProcess():New( { | lEnd | PLUA520Glo( @lEnd ) } , STR0027 , STR0028 , .F. ) //"Processando" # "Aguarde..."
			oProcess:Activate()
		EndIf
	EndIf

ElseIf cProcesso == "2"

	cTitulo	:= 	STR0061 	//"Exportação do PTU A530 - Glosa Total"
	cTexto	:= 	CRLF + CRLF +;
	STR0062 + 	CRLF +; 	//"Esta é a opção que irá efetuar a comunicação via WebService e enviar o "
	STR0063 				//"PTU A530 - Glosa Total."
	nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )
	
	If( nOpc == 1 )
		If( pergGlosa(cProcesso) )
			oProcess := msNewProcess():New( { | lEnd | PLU520A530( @lEnd ) } , STR0027 , STR0028 , .F. ) //"Processando" # "Aguarde..."
			oProcess:Activate()
		EndIf
	EndIf
	
EndIf

Return(.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} pergGlosa
Perguntas para processar registros glosados

@author    Michel Montoro
@version   P12
@since     16/04/2018
/*/
//------------------------------------------------------------------------------------------
Static Function pergGlosa(cProcesso)
Local lRet			:= .F.
Local aPergs		:= {}
Local cOperaDe		:= CriaVar("B2S_OPEORI",.F.)
Local cOperaAte		:= CriaVar("B2S_OPEORI",.F.)
Local cLoteDe		:= CriaVar("B2S_NUMLOT",.F.)
Local cLoteAte		:= Replicate("Z",Len(cLoteDe))
Local cDataDe		:= CriaVar("B2S_DATENV",.F.)
Local cDataAte		:= CriaVar("B2S_DATENV",.F.)
Local cReenvio		:= ""
Local nX			:= 1

aadd(/*01*/ aPergs,{ 1,STR0064,	cOperaDe	,"@!",'.T.','B39PLS',/*'.T.'*/,40,.T. } ) //"Oper. Origem De"
aadd(/*02*/ aPergs,{ 1,STR0065,	cOperaAte	,"@!",'.T.','B39PLS',/*'.T.'*/,40,.T. } ) //"Oper. Origem Ate"
aadd(/*03*/ aPergs,{ 1,STR0066,	cLoteDe		,"@!",'.T.', 		,/*'.T.'*/,40,.F. } ) //"Lote De"
aadd(/*04*/ aPergs,{ 1,STR0067,	cLoteAte	,"@!",'.T.',  		,/*'.T.'*/,40,.T. } ) //"Lote Até"
aadd(/*05*/ aPergs,{ 1,STR0068,	cDataDe		,"@!",'.T.', 		,/*'.T.'*/,40,.T. } ) //"Data Envio De"
aadd(/*06*/ aPergs,{ 1,STR0069,	cDataAte	,"@!",'.T.', 		,/*'.T.'*/,40,.T. } ) //"Data Envio Até"
If cProcesso == "2"
aadd(/*07*/ aPergs,{ 2,STR0070, STR0071		,{STR0071,STR0072}	,40    ,'.T.',.T. } ) //"Processa Enviados?" # "Não" # "Sim"
EndIf
 
If( paramBox( aPergs,STR0073,__aRetGlo,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSUA520',/*lCanSave*/.T.,/*lUserSave*/.T. ) ) //"Parâmetros - Processa guias glosadas"
	If( validPergGlosa( __aRetGlo ) )
		lRet := .T.
	Else
		lRet := pergGlosa()
	EndIf
EndIf
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} validPergGlosa
Validador de perguntas antes de processar o arquivo de envio

@author    Michel Montoro
@version   P12
@since     16/04/2018
/*/
//------------------------------------------------------------------------------------------
Static Function validPergGlosa( __aRetGlo )
	Local nX
	Local lRet		:= .T.
	Local cMsgErro	:= STR0074 + CRLF + CRLF //"Corrija os itens abaixo antes de prosseguir:"
	
	For nX:=1 to len( __aRetGlo )
		If		( nX == 1 .OR. nX == 2 )
			If Empty(__aRetGlo[01] + __aRetGlo[02])
				lRet		:= .F.
				cMsgErro += " - " + STR0039 + CRLF //"Parâmetros 'Operadoras De/Até' preenchidos incorretamente"
			EndIf
		ElseIf	( nX == 3 .OR. nX == 4 )
			If Empty(__aRetGlo[03] + __aRetGlo[04])
				lRet		:= .F.
				cMsgErro += " - " + STR0075 + CRLF //"Parâmetros 'Lote De/Até' preenchidos incorretamente"
			EndIf
		ElseIf	( nX == 5 )
			If Empty(__aRetGlo[05])
				lRet		:= .F.
				cMsgErro += " - " + STR0076 + CRLF //"Parâmetro 'Data Envio De' preenchido incorretamente"
			EndIf
		ElseIf	( nX == 6 )
			If Empty(__aRetGlo[06])
				lRet		:= .F.
				cMsgErro += " - " + STR0077 + CRLF //"Parâmetro 'Data Envio Até' preenchido incorretamente"
			EndIf
		EndIf
	Next nx
	
	If( !lRet )
		Alert( cMsgErro )
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLUA520Glo
Faz o processamento das guias

@author  Michel Montoro
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------
Function PLUA520Glo(lEnd)

Local cini		:= time()
Local cfim		:= ""		
Local cAlias	:= ""
Local nTotReg	:= 0
Local nCount	:= 0
Local aCampos	:= {}

cAlias := PL520QUERY("GLOSA")

If !(cAlias)->(Eof())
	DBSelectarea("B5S")
	nTotReg := Contar(cAlias,"!EoF()")
	oProcess:SetRegua1( 1 ) 		//Alimenta a primeira barra de progresso
	oProcess:SetRegua2( nTotReg ) 	//Alimenta a primeira barra de progresso
	oProcess:IncRegua1( STR0078 ) 	//"Processando Guias de Envio com Glosa: "
    (cAlias)->(DbGoTop())
	
	While !(cAlias)->(Eof())
	
		nCount++
		oProcess:IncRegua2( STR0045 + "[" + cvaltochar(nCount) + "] - [" + cvaltochar(nTotReg) + "]" ) //"Processando De: "
		
		//Posiciona B5S
		B5S->(DBSetorder(1)) //B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO
		If B5S->(MsSeek(xFilial("B5S")+(cAlias)->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO)))
			aCampos	:= {}
			aAdd( aCampos,{ "B5S_VLRGLO"	,(cAlias)->B5S_VLRPRO	} )
			aAdd( aCampos,{ "B5S_STAGLO"	,"1"					} )
			lRet := PLU520Grv( 4, aCampos, 'MODEL_B5S', 'PLSU520B5S' )
		EndIf
		
		(cAlias)->(dbSkip())
		
	EndDo
	MsgInfo(STR0046 + STRZero(nCount,8)+" "+ STR0079) //"Foram processados: " # "registros."
Else
	Help( ,, 'HELP',,STR0048, 1, 0) //"Registros não encontrado !!!"
EndIf

(cAlias)->(dbCloseArea())

cfim := time()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLU520A530
Faz o envio do PTU A530

@author  Michel Montoro
@version P12
@since   16/04/2018
/*/
//-------------------------------------------------------------------
Function PLU520A530(lEnd)

Local cini		:= time()
Local cfim		:= ""
Local cAlias	:= ""
Local nTotReg	:= 0
Local nCount	:= 0
Local a530		:= {}
Local cRet 		:= ""
Local lRet		:= .T.
Local cCodOpeAvi:= ""
Local dDatConhec:= CToD("")
Local cNumLote	:= ""
Local cNumGuia	:= ""
Local cCodOpeBen:= ""
Local cMatric	:= ""
Local cCGCOpOri := ""
Local aCpfCnpj	:= {}
Local aCampos	:= {}
Local aMsgs		:= {}

cAlias := PL520QUERY("PTUA530")

If !(cAlias)->(Eof())
	DBSelectarea("B5S")
	nTotReg := Contar(cAlias,"!EoF()")
	oProcess:SetRegua1( 1 ) 		//Alimenta a primeira barra de progresso
	oProcess:SetRegua2( nTotReg ) 	//Alimenta a primeira barra de progresso
	oProcess:IncRegua1( STR0078 ) 	//"Processando Guias de Envio com Glosa: "
    (cAlias)->(DbGoTop())
	
	While !(cAlias)->(Eof())
	
		nCount++
		oProcess:IncRegua2( STR0045 + "[" + cvaltochar(nCount) + "] - [" + cvaltochar(nTotReg) + "]" ) //"Processando De: "
		
		cCodOpeAvi	:= (cAlias)->CODOPE
		dDatConhec	:= SToD((cAlias)->DATENV) 	//(Data do Conhecimento - Data do Envio/Rec do aviso)
		cNumLote	:= (cAlias)->NUMLOT
		cCodOpeBen	:= SUBSTR( (cAlias)->MATANT,1,04)
		cMatric		:= SUBSTR( (cAlias)->MATANT,5,13)
		cCGCOpOri 	:= POSICIONE("BA0",1,xFilial("BA0")+(cAlias)->OPEHAB,"BA0_CGC")
		aCpfCnpj	:= {"2",cCGCOpOri} //{"1",cCpfCnpj} 1-CPF, 2-CNPJ (Operadora Habitual é tratado como Prestador - sempre CNPJ)
		
		If (cAlias)->INTERNA == "N"
			BD5->(DbGoTo((cAlias)->BD5BE4Recno))
			cNumGuia	:= PLU520RGui( (cAlias)->TIPGUI )
		Else
			BE4->(DbGoTo((cAlias)->BD5BE4Recno))
			cNumGuia	:= PLU520RGui( (cAlias)->TIPGUI )
		EndIf
		
		a530 := {"1","0",cCodOpeAvi,dDatConhec,cNumLote,cNumGuia,cCodOpeBen,cMatric,aCpfCnpj}
		cRet := PLSUA530(a530,.F.)
		
		If Empty(cRet)
			//Posiciona B5S
			B5S->(DBSetorder(1)) //B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO
			If B5S->( MsSeek(xFilial("B5S")+(cAlias)->(NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO)) )
				aCampos	:= {}
				aAdd( aCampos,{ "B5S_STAGLO"	,"2"	} )//2=Glosa Enviada
				lRet := PLU520Grv( 4, aCampos, 'MODEL_B5S', 'PLSU520B5S' )
			EndIf
		Else
			aAdd(aMsgs,{cNumLote,cNumGuia,cRet})
		EndIf
		
		(cAlias)->(dbSkip())
		
	EndDo
	MsgInfo(STR0046 + STRZero(nCount,8)+" "+ STR0079) //"Foram processados: " # "registros."
Else
	Help( ,, 'HELP',,STR0048, 1, 0) //"Registros não encontrado !!!"
EndIf

(cAlias)->(dbCloseArea())

If !Empty(aMsgs)
	PLSCRIGEN(aMsgs,{ {"No LOTE","@C",30},{"No GUIA","@C",30},{"CRITICA","@C",150} },"RESUMO DE CRÍTICAS" )
EndIf

cfim := time()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLU520Grv
Grava os dados do Lote Guias - Tabela B2S

@author    Guilherme Carvalho
@version   1.xx
@since     30/04/2018
/*/
//------------------------------------------------------------------------------------------
Function PLU520Grv( nOpc,aCampos,cModel,cLoadModel )
	local oAux
	local oStruct
	local oModel
	local aAux
	local aErro
	
	local nI
	local nPos
	
	local lRet := .T.
	
	oModel := FWLoadModel( cLoadModel )
	oModel:setOperation( nOpc )
	oModel:activate()
	
	oAux	:= oModel:getModel( cModel )
	oStruct	:= oAux:getStruct()
	aAux	:= oStruct:getFields()
	
	if( nOpc <> MODEL_OPERATION_DELETE )
		begin Transaction
			for nI := 1 to len( aCampos )
				if( nPos := aScan( aAux,{| x | allTrim( x[ 3 ] ) == allTrim( aCampos[ nI,1 ] ) } ) ) > 0
					if !( lRet := oModel:setValue( cModel,aCampos[ nI,1 ],aCampos[ nI,2 ] ) )
						aErro := oModel:getErrorMessage()
						
						autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
						autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
						autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
						autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
						autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
						autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
						
						mostraErro()
						disarmTransaction()
						exit
					endif
				endIf
			next nI
		end Transaction
	endIf		
	
	if( lRet := oModel:vldData() )
		oModel:commitData()
	else
		aErro := oModel:getErrorMessage()						
		autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
		autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
		autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
		autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
		autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
		autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
		
		mostraErro()
		disarmTransaction()
	endif
	
	oModel:deActivate()
	oModel:destroy()
	freeObj( oModel )
	oModel := nil
	delClassInf()
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fPesquisa
Cria o campo de pesquisa

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function fPesquisa( oPanel )

Local cCpoPesq 		:= Space(TamSx3("B5S_CODOPE")[1]+TamSx3("B5S_CODLDP")[1]+TamSx3("B5S_CODPEG")[1]+TamSx3("B5S_NUMERO")[1])
Local cTpPesq		:= Space(50)
Local nPesq			:= 1                        
Local lRet			:= .F.
Local aTpPesq		:= {}                    
Local oTFont1 		:= TFont():New("Calibri",,-22,.T.,.T.)      
Local oTFont2 		:= TFont():New("Calibri",,-18,.T.,.F.)
Local oTFont3 		:= TFont():New("Calibri",,-11,.T.,.F.)
Local oCpoPesq	
Local oBtnPesq

aADD(aTpPesq,"Operad.+Cd.Local+Cód.PEG+Número")
 
@ 010,005 	COMBOBOX cTpPesq ITEMS aTpPesq	SIZE 100, 12;
			VALID fTpPesq(@nPesq, cTpPesq)	FONT oTFont3 	OF oPanel PIXEL
@ 010,110	MSGET oCpoPesq VAR cCpoPesq 	SIZE 100,010 FONT oTFont2 PIXEL OF oPanel

oBtnPesq := TBtnBmp2():New( 012,420,043,040,'BMPVISUAL',,,,{|| Processa({|| lRet:=PesquGuia(nPesq,cCpoPesq)}, STR0080 ) }, oPanel, STR0005,,.T. ) //"Pesquisando..." # "Pesquisar"
/*
If !lRet

EndIf
*/
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} fTpPesq
Define o tipo de pesquisa

@author  Michel Montoro
@since   16/04/2018
@version P12
/*/
Static Function fTpPesq(nPesq, cTpPesq)

If AllTrim(cTpPesq) == "Operad.+Cd.Local+Cód.PEG+Número"
	nPesq := 1		
Else
	nPesq := 0
EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PesquGuia
Efetua a pesquisa das Guias

@author  Michel Montoro
@since   16/04/2018
@version P12
/*/
Static Function PesquGuia(nPesq,cCpoPesq)
Local oModel 	:= FWModelActive()
Local oModelB5S := oModel:GetModel( 'B5SDETAIL' )
Local oView 	:= FWViewActive()
Local nFor 		:= 0
Local aSaveLine := FWSaveRows()
Local cConteudo	:= ""
Local lFind		:= .F.

For nFor := 1 To oModelB5S:Length()
	oModelB5S:GoLine( nFor )
	If nPesq == 1
		cConteudo := oModelB5S:GetValue("B5S_CODOPE")+oModelB5S:GetValue("B5S_CODLDP")+oModelB5S:GetValue("B5S_CODPEG")+oModelB5S:GetValue("B5S_NUMERO")
	    If AllTrim(cCpoPesq) $ cConteudo
	    	lFind := .T.
	    	Exit
	    EndIf
	EndIf
Next nFor

If !lFind
	FWRestRows( aSaveLine )
Else
	oView:Refresh()
EndIf

Return(.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} MatricBD5
Retorna Matricula do Usuário do BD5

@author  Guilherme Carvalho
@since   30/05/2018
@version P12
/*/
Function MatricBD5()
Local cRet := ""

DBSelectarea("BD5")
cRet := AllTrim( Posicione("BD5",1,xFilial("B5S")+B5S->(B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO),"BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO") )
	
Return(cRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSU520FIL
Filtro 

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
//------------------------------------------------------------------------------------------
function PLSU520FIL(lF2)

local aPergs	:= {}
local aFilter	:= {}
local cFilter 	:= ""
local cStatus	:= space(1)
local cOpeDe	:= space(4)
local cOpeAte	:= space(4)	

default lF2 := .f.

aadd( aPergs,{ 1,"Operadora De:" , 	cOpeDe,"@!",'.T.','B39PLS',/*'.T.'*/,40,.f. } )
aadd( aPergs,{ 1,"Operadora Ate:", 	cOpeAte,"@!",'.T.','B39PLS',/*'.T.'*/,40,.t. } )
aAdd( aPergs,{ 1, "Data Imp De:" , 	dDataBase	, "", "", ""		, "", 50, .f.})
aAdd( aPergs,{ 1, "Data Imp Até:", 	dDataBase	, "", "", ""		, "", 50, .t.})
aadd( aPergs,{ 2, "Status:"		 , 	cStatus,{ "0=Todos","1=Pend. Envio Aviso","2=Aviso Enviado","3=Aviso Recebido" },100,/*'.T.'*/,.t. } )

if( paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSU520C',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	cFilter += "@B2S_FILIAL = '" + xfilial("B2S") + "'"	
	cFilter += " AND B2S_OPEORI >= '" + aFilter[1] + "'"	
	cFilter += " AND B2S_OPEORI <= '" + aFilter[2] + "'"	
	cFilter += " AND B2S_DATTRA >= '" + dtos(aFilter[3]) + "'"	
	cFilter += " AND B2S_DATTRA <= '" + dtos(aFilter[4]) + "'"	
	if aFilter[5] <> "0"
		cFilter += " AND B2S_STATUS = '" + aFilter[5] + "'"	
	endif
endIf

if lF2
	oMBrwB2S:SetFilterDefault(cFilter)
	oMBrwB2S:Refresh()
endif
	
return cFilter


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSU520DEL
Função para exclusão

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
//------------------------------------------------------------------------------------------
function PLSU520DEL
local cSql 		:= ""
local cChave 	:= ""
				
if(! msgYesNo( "Deseja excluir os registros marcados da exportação do lote de avisos?" ) )
	return .f.
endIf

cSql := " SELECT B2S_NUMLOT, R_E_C_N_O_ RECNO " 
cSql += " FROM " + RetSqlName("B2S") + " B2S "
cSql += " WHERE B2S_FILIAL = '" + xFilial("B2S") + "' "
cSql += " AND B2S_OK = '" + oMBrwB2S:cMark + "' "
cSql += " AND B2S.D_E_L_E_T_ = ' '  "

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLEXC",.F.,.T.)	

B2S->(dbsetorder(1)) // B2S_FILIAL, B2S_NUMLOT
B5S->(dbsetorder(1)) // B5S_FILIAL, B5S_NUMLOT
B6S->(dbsetorder(1)) // B6S_FILIAL, B6S_NUMLOT

begin transaction

while !PLEXC->(eof())

	B2S->(dbgoto(PLEXC->RECNO))
	cChave := B2S->B2S_NUMLOT

	// B2S	
	IncProc("Excluindo registros " + cvaltochar(B2S->(recno())))
	B2S->(RecLock('B2S',.F.))
		B2S->(DbDelete())
	B2S->(MsUnLock())
	

	// B5S
	while B5S->(MsSeek(xFilial('B5S') + cChave)) 
		IncProc("Excluindo registros " + cvaltochar(B5S->(recno())))
		B5S->(RecLock('B5S',.F.))
			B5S->(DbDelete())
		B5S->(MsUnLock())
	enddo

	// B6S
	while B6S->(MsSeek(xFilial('B6S') + cChave)) 
		IncProc("Excluindo registros " + cvaltochar(B6S->(recno())))
		B6S->(RecLock('B6S',.F.))
			B6S->(DbDelete())
		B6S->(MsUnLock())
	enddo	

	PLEXC->(dbskip())

enddo

end transaction

PLEXC->(dbclosearea())

return

/*/PlAjsTamCampo
função criada para ajustar automaticamente o campo _NUMLOT das tabelas B2S, B5S e B6S, pois foram criadas com o tamanho 10
E o correto pelo PTU/TISS é tamanho 12. O dicionário foi ajustado e ao rodar o A520, o ajuste é feito automaticamente.
/*/
function PlAjsTamCampo()
local cSql		:= ""
local cTipDB  	:= UPPER(TcGetDB())
local cTiplen	:= iif( 'MSSQL' $ cTipDB, 'LEN(','LENGTH(')
local cTipTrim	:= iif( 'MSSQL' $ cTipDB, 'LTRIM(RTRIM(','TRIM(') //trim SQL SERVER só em versão 2017
local cFecTrim	:= iif( 'MSSQL' $ cTipDB, ')))','))') 
local aTabAtu	:= {"B2S", "B5S", "B6S"}
local nAtu		:= 0
local lTamLot12	:= iif( TamSx3("B2S_NUMLOT")[1] == 12, .t., .f.)

if lTamLot12	
	for nAtu := 1 to Len(aTabAtu)
		cSql := " SELECT " + aTabAtu[nAtu] + ".R_E_C_N_O_ REC FROM " + RetSqlName(aTabAtu[nATu]) + " " + aTabAtu[nATu]
		cSql += "  WHERE " + cTiplen + cTipTrim + aTabAtu[nAtu] + "_NUMLOT " + cFecTrim + " <= 10 "
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changequery(cSql)),"TrbAtuCampo",.f.,.t.)

		while !TrbAtuCampo->(eof())
			(aTabAtu[nATu])->(dbgoto(TrbAtuCampo->REC))
			
			//atualiza o campo com zeros a esquerda em toda a tabela, após ajuste do tamanho do campo para 12
			(aTabAtu[nATu])->(reclock(aTabAtu[nATu],.f.))
				(aTabAtu[nATu])->&(aTabAtu[nATu] + "_NUMLOT") := PadL( alltrim((aTabAtu[nATu])->&(aTabAtu[nATu] + "_NUMLOT")) ,12,"0")
			(aTabAtu[nATu])->(msunlock())
			
			TrbAtuCampo->(dbskip())
		enddo
		TrbAtuCampo->(dbclosearea())
	next
endif	

return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaBase
Cria tabela temporaria da base a ser processada.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
static function fCriaBase(cAlias,oTmpTable)
local aColumns	 := {}
	
if Select(cAlias) > 0
	if oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	endif 	
endif 

aAdd( aColumns, { "CODLDP"	,"C",04,00 })
aAdd( aColumns, { "CODPEG"	,"C",08,00 })
aAdd( aColumns, { "NUMERO"	,"C",08,00 })



oTmpTable := FWTemporaryTable():New(cAlias)
oTmpTable:SetFields( aColumns )
oTmpTable:Create()

Return Nil

