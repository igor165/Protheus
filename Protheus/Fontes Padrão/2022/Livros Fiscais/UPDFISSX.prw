#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDFISSX
FunÁ„o de update de dicion·rios para ser usado no estudo do MVC do projeto MVC_Simplificado

@author Yuri Palacio
@since  MarÁo/2021
@version 1.0
/*/
//--------------------------------------------------------------------
Main Function UPDFISSX( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZA«√O DE DICIONARIO"
Local   cDesc1    := "Esta rotina tem como funÁ„o"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja n„o podem haver outros"
Local   cDesc3    := "usu·rios  ou  jobs utilizando  o sistema.  … EXTREMAMENTE recomendavel  que  se  faÁa um"
Local   cDesc4    := "BACKUP  dos DICION¡RIOS  e da  BASE DE DADOS antes desta atualizaÁ„o, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

If GetRPORelease() >= "12.1.031"
	blockUpd12()

	Return
EndIf

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualizaÁ„o dos dicion·rios ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "AtualizaÁ„o Realizada.", "UPDFISSX" )
				Else
					MsgStop( "AtualizaÁ„o n„o Realizada.", "UPDFISSX" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "AtualizaÁ„o ConcluÌda." )
				Else
					Final( "AtualizaÁ„o n„o Realizada." )
				EndIf
			EndIf

		Else
			MsgStop( "AtualizaÁ„o n„o Realizada.", "UPDFISSX" )

		EndIf

	Else
		MsgStop( "AtualizaÁ„o n„o Realizada.", "UPDFISSX" )

	EndIf

EndIf


Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
FunÁ„o de processamento da gravaÁ„o dos arquivos
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cFile     := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTexto    := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// SÛ adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "AtualizaÁ„o da empresa " + aRecnoSM0[nI][2] + " n„o efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZA«√O DOS DICION¡RIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora InÌcio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " VersÛo.............: " + GetVersao(.T.) )
			AutoGrLog( " Usu·rio TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usu·rio da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " EstaÁ„o............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conex„o............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 9 )

			//------------------------------------
			// Atualiza o dicion·rio SX9
			//------------------------------------
			oProcess:IncRegua1( "Dicion·rio de relacionamentos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX9()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "AtualizaÁ„o concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX9
FunÁ„o de processamento da gravaÁ„o do SX9 - Relacionamento

@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX9()
Local aEstrut   := {}
Local aSX9      := {}
Local nI        := 0

AutoGrLog( "InÌcio da AtualizaÁ„o" + " SX9" + CRLF )

aEstrut := { "X9_DOM"    , "X9_IDENT"  , "X9_CDOM"   , "X9_EXPDOM" , "X9_EXPCDOM", "X9_PROPRI" , "X9_LIGDOM" , ;
             "X9_LIGCDOM", "X9_CONDSQL", "X9_USEFIL" , "X9_VINFIL" , "X9_CHVFOR" , "X9_ENABLE" ,"X9_LOCALIZ" }


//
// DomÌnio ZA0
//
aAdd( aSX9, { ;
	'SF7'																	, ; //X9_DOM
	'001'																	, ; //X9_IDENT
	'SF7'																	, ; //X9_CDOM
	'F7_GRTRIB'																, ; //X9_EXPDOM
	'F7_GRTRIB'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'2'																		, ; //X9_VINFIL
	'2'																		, ; //X9_CHVFOR
	'S'																		, ; //X9_ENABLE
	''																	} ) //X9_LOCALIZ

//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSX9 ) )

dbSelectArea( "SX9" )
dbSetOrder( 2 )

For nI := 1 To Len( aSX9 )

	If SX9->( dbSeek( aSX9[nI][3] + aSX9[nI][1] ) )
		RecLock( "SX9", .F. )
        SX9->(DbDelete())
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi excluÌdo o relacionamento " + aSX9[nI][1] + "/" + aSX9[nI][3] )

		oProcess:IncRegua2( "Atualizando Arquivos (SX9)..." )
	EndIf

Next nI

AutoGrLog( CRLF + "Final da AtualizaÁ„o" + " SX9" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
FunÁ„o genÈrica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleÁıes feitas.
             Se n„o for marcada nenhuma o vetor volta vazio

@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Par‚metro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta sÛ com Empresas
// 3 - Monta sÛ com Filiais de uma Empresa
//
// Par‚metro  aMarcadas
// Vetor com Empresas/Filiais prÈ marcadas
//
// Par‚metro  cEmpSel
// Empresa que ser· usada para montar seleÁ„o
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
local _ni := 0

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf

dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()
While !SM0->( EOF() )
	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, alltrim(SM0->M0_CODIGO), alltrim(SM0->M0_CODFIL), alltrim(SM0->M0_NOME), alltrim(SM0->M0_FILIAL) } )
	EndIf
	dbSkip()
End
RestArea( aSalvSM0 )


//TODO, remover ao corrigir o bloco abaixo
For _ni := 1 to len(aVetor)
	aVetor[_ni,1] := .T. //marca todas empresas e filiais
Next
RetSelecao( @aRet, aVetor )

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
FunÁ„o auxiliar que monta o retorno com as seleÁıes

@param aRet    Array que ter· o retorno das seleÁıes (ù alterado internamente)
@param aVetor  Vetor do ListBox

@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
FunÁ„o de processamento abertura do SM0 modo exclusivo

@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	If MPDicInDB()
		If lShared
			OpenSm0(,.T.)
		Else
			OpenSM0Excl(,.F.)
		EndIf

		If !Empty( Select( 'SM0' ) )
			lOpen := .T.
			Exit
		EndIF
	Else
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "N„o foi possÛvel a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATEN«√O" )
EndIf

Return lOpen

//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
FunÁ„o de leitura do LOG gerado com limitacao de string

@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibiÁ„o maxima do LOG alcanÁado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet
