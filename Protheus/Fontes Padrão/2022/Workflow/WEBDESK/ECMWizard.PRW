#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "ECMWIZARD.CH"

// ##############################################################################################
// Projeto: INTEGRAÇÃO PROTHEUS - TOTVS ECM
// Modulo : Wizard
// Fonte  : ECMWizard - Configurações da integração PROTHEUS - TOTVS ECM
// ----------+-------------------------+---------------------------------------------------------
// Data      | Autor                   | Descricao
// ----------+-------------------------+---------------------------------------------------------
//  20.07.09 | 3510 - Gilmar P. Santos | Wizard para exportação de usuários do Microsiga Protheus
//           |                         | para o TOTVS ECM e configuração de parâmetros (SX6)
// ----------------------------------------------------------------------------------------------

//Constantes de identificação dos elementos do array de usuários
#DEFINE USR_CODIGO 		1
#DEFINE USR_LOGIN 		2
#DEFINE USR_SENHA 		3
#DEFINE USR_NOME  		4
#DEFINE USR_EMAIL 		5
#DEFINE USR_GRUPO 		6
#DEFINE USR_PAPEL 		7
#DEFINE USR_SELECT 		8

//Constantes de identificação dos elementos do array de grupos
#DEFINE GRP_COD	   	1
#DEFINE GRP_NOME			2

//Constantes de identificação dos elementos do array de papéis
#DEFINE ROL_COD			1
#DEFINE ROL_NOME   		2

//Constantes de identificação dos elementos do combo Filiais
#DEFINE FILIAL_TODAS	"1"
#DEFINE FILIAL_ATUAL	"2"

//Constantes de identificação dos parâmetros (SX6)
#DEFINE MV_WS			"MV_ECMWS"
#DEFINE MV_EMP			"MV_ECMEMP"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TBIEcmWizard
Cria um Wizard para configuração dos parâmetros de integração Protheus - ECM

@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
/*/
//--------------------------------------------------------------------------
class TBIEcmWizard
	data foWizard		//Wizard
	data faUsuarios		//Usuarios Protheus
	data faEcmUsers		//Usuarios ECM
	data fcFilial		//Indica se parâmetro é específico de uma filial (2) ou se é válido para todas (1)
	data fcWebservice	//Endereço dos WebServices no TOTVS ECM
	data fcEmpEcm		//Código da empresa correspondente no TOTVS ECM
	data fcLogin		//Usuário com acesso aos WebServices
	data fcPwd			//Senha do usuário para acessar os WebServices
	data fcErrorMsg		//Mensagem de erro
	data flErrorWs		//Indica erro na execução de Web Service

	method New() constructor
	method NewObject()
	method Start()
	method getWsEcmData()
	method fillUsuarios()
	method getEcmUsers() 
	method UpdateArray()
	method getArrConf()
	method saveConfig()  
	method saveParam()
	method saveUsers()
	method md5Pwd()
	method lUserExist( cLogin )
endclass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Cria uma nova instância da classe TBIEcmWizard

@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@sample
....
	oWizard := TBIEcmWizard():New()
....
/*/
//-------------------------------------------------------------------
method New() class TBIEcmWizard
	::NewObject()
return

//-------------------------------------------------------------------
/*/{Protheus.doc} NewObject
Cria uma nova instância da classe TBIEcmWizard - Uso Interno

@protected
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
/*/
//-------------------------------------------------------------------
method NewObject() class TBIEcmWizard
	::faUsuarios := {}

	::foWizard := NIL

	::fcFilial := ""
	::fcErrorMsg := ""
	::flErrorws := .F.
	
	::fcWebservice := padr( GetMv( MV_WS, .F., space(100) ), 100 )
	::fcEmpEcm := padr(GetMv( MV_EMP, .F., space(20) ), 20 )
	::fcLogin := space(20)
	::fcPwd := space(20)
	
return

//-------------------------------------------------------------------
/*/{Protheus.doc} Start
Executa o Wizard de Integração Protheus - TOTVS ECM

@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@sample
....
	oWizard := TBIEcmWizard():New()
	oWizard:Start()
....
/*/
//-------------------------------------------------------------------
method Start() class TBIEcmWizard
	local oPanel 		:= NIL
	local oLstEsq 		:= NIL
	local oLstDir 		:= NIL 
	local oLstMemo 		:= NIL
	local oFont 		:= NIL
	local oBtnAllDir 	:= NIL 
	local oBtnDir 		:= NIL 
	local oBtnEsq 		:= NIL 
	local oBtnAllEsq 	:= NIL
	local oBrowse 		:= NIL
	local oCboFilial 	:= NIL 	
	local oMeter		:= NIL
	local aLstEsq 		:= {}
	local aLstDir 		:= {}	
	local aLstConf 		:= {}
	local aLstUsrGrp 	:= {}
	local aColumn 		:= {}
	local bAllDir 		:= {||}
	local bAllEsq 		:= {||}
	local bDir 			:= {||}
	local bEsq 			:= {||}
	local nLen 			:= 0
	local nCount 		:= 0
	local cConfirm 		:= "" 	
	local cLstMemo 		:= ""
	           
	
	//1º Panel - Introdução
	DEFINE WIZARD ::foWizard ;
		TITLE STR0001 ;	//"Wizard de configuração da integração com TOTVS ECM"
		MESSAGE STR0002 ;	//"INICIO DO WIZARD TOTVS ECM"
		TEXT STR0003 ;		//"Neste Wizard o administrador do sistema irá configurar os parâmetros de integração com o TOTVS ECM."
			+ CRLF + CRLF ;
			+ STR0004 ;		//"Pré-requisitos:"
			+ CRLF ;
			+ STR0005 ;		//"- Os WebServices de integração do TOTVS ECM devem estar ativos."
			+ CRLF + CRLF ;
			+ STR0006 ;		//"Para continuar com a configuração, selecione a opção Avançar"
		NEXT {|| .T. } ;
		PANEL    
		
		
	//2º Panel - Parâmetros de integração
	CREATE PANEL ::foWizard ;
		HEADER "" ;
		MESSAGE STR0007 ; //"PARÂMETROS DE INTEGRAÇÃO"
		BACK {|| .T. };
		NEXT {|| cursorWait(), oMeter:lVisibleControl := .T., oMeter:refresh(), x:=::getWsEcmData(oMeter), iif(x, iif( !::fillUsuarios(oMeter), msgStop( STR0027 ), ), msgStop( ::fcErrorMsg ) ), cursorArrow(), x };
		FINISH {|| .F. } ;
		EXEC {|| oMeter:set(0), oMeter:lVisibleControl := .F., oMeter:refresh() } ;
		PANEL

	oPanel := ::foWizard:GetPanel( 2 )

	//Filial
	@ 025,005 SAY STR0030 OF oPanel SIZE 90,8 PIXEL
	oCboFilial := TComboBox():New( 025, 050, {|x|if(PCount()>0,::fcFilial:=x,::fcFilial)}, {FILIAL_TODAS + "=" + STR0032,FILIAL_ATUAL + "=" + STR0031}, 100, 10, oPanel,, {||.T.}, {||.T.},,, .T.,,,,{||.T.},,,,,"::fcFilial" )

	//WebService
	@ 045,005 SAY STR0008 OF oPanel SIZE 90,8 PIXEL  
	@ 045,050 MsGet ::fcWebservice OF oPanel SIZE 200,10 When .T. PIXEL	

	//Empresa ECM
	@ 065,005 SAY STR0009	OF oPanel SIZE 120,8 PIXEL  
	@ 065,050 MsGet ::fcEmpEcm OF oPanel SIZE 50,10 PICTURE "999999" When .T. PIXEL

	//Login
	@ 085,005 SAY STR0010 OF oPanel SIZE 120,8 PIXEL  
	@ 085,050 MsGet ::fcLogin OF oPanel SIZE 50,10 When .T. PIXEL

	//Senha
	@ 105,005 SAY STR0011 OF oPanel SIZE 120,8 PIXEL  
	@ 105,050 MsGet ::fcPwd OF oPanel SIZE 50,10 When .T. PIXEL PASSWORD
	
	oMeter := TMeter():New( 125/*nRow*/, 005/*nCol*/, /*bSetGet*/, 0/*nTotal*/, oPanel/*oWnd*/, 280/*nWidth*/, 10/*nHeight*/, /*uParam8*/, .T./*lPixel*/, /*uParam10*/, /*uParam11*/, .T./*lNoPerc*/, /*nClrPane*/, /*uParam14*/, /*uParam15*/, /*uParam16*/, /*uParam17*/ )
	oMeter:setTotal( 1000 )
	oMeter:lVisibleControl := .T.
	
	//3º Panel - Selecionar usuários
	CREATE PANEL ::foWizard ;
		HEADER "" ;
		MESSAGE STR0012 ;	//"USUÁRIOS QUE SERÃO EXPORTADOS"
		BACK {|| MsgYesNo( STR0025, STR0024 ) };
		NEXT {|| aEval( ::faUsuarios, ;
						{|x| x[USR_SELECT] := ( aScan( aLstDir, x[USR_LOGIN] ) > 0 ) } ), ;
				.T. } ;
		FINISH {|| .F. } ;
		EXEC {|| aLstEsq := {}, ;
  				 aLstDir := {}, ;
				aEval( ::faUsuarios, ;
						{|x| iif( x[USR_SELECT], ;
								aAdd( aLstDir, x[USR_LOGIN] ), ;
								aAdd( aLstEsq, x[USR_LOGIN] ) )} ), ;
				oLstEsq:setArray( aLstEsq ), ;
				oLstDir:setArray( aLstDir ) } ;
		PANEL

	oPanel := ::foWizard:GetPanel(3)

	//"Disponíveis"
	@ 002,005 SAY STR0013 OF oPanel SIZE 120,8 PIXEL

	//"Selecionados"
	@ 002,170 SAY STR0014 OF oPanel SIZE 120,8 PIXEL

	oLstEsq := TListBox():New( 010, 005, {||}, aLstEsq, 115, 120,, oPanel,,,, .T. )
	oLstDir := TListBox():New( 010, 170, {||}, aLstDir, 115, 120,, oPanel,,,, .T. )

	bAllDir := {|| aEval( aLstEsq, {|x| aAdd(aLstDir, x)} ), ;
				aLstEsq := {}, ;
				aSort( aLstDir ), ;
				oLstEsq:setArray(aLstEsq), ;
				oLstDir:setArray(aLstDir) }

	bAllEsq := {|| aEval( aLstDir, {|x| aAdd(aLstEsq, x)} ), ;
				aLstDir := {}, ;   
				aSort( aLstEsq ), ;
				oLstEsq:setArray(aLstEsq), ;
				oLstDir:setArray(aLstDir) }

	bDir	:= {|| aAdd( aLstDir, aLstEsq[oLstEsq:nAt] ), ;
				aDel( aLstEsq, oLstEsq:nAt ), ;
				aSize( aLstEsq, len( aLstEsq ) - 1 ), ;
				aSort( aLstDir ), ;
				oLstEsq:setArray(aLstEsq), ;
				oLstDir:setArray(aLstDir) }

	bEsq	:= {|| aAdd( aLstEsq, aLstDir[oLstDir:nAt] ), ;
				aDel( aLstDir, oLstDir:nAt ), ;
				aSize( aLstDir, len( aLstDir ) - 1 ), ;
				aSort( aLstEsq ), ;
				oLstEsq:setArray(aLstEsq), ;
				oLstDir:setArray(aLstDir) }

	oLstDir:blDblClick := bEsq
	oLstEsq:blDblClick := bDir

	oFont := TFont():New( "Arial",, -12, , .T. )
	oBtnAllDir	:= TButton():New( 040, 125, ">>", oPanel, bAllDir, 040, 012,, oFont,, .T.,,,, /*bWhen*/)
	oBtnDir 	:= TButton():New( 055, 125, ">" , oPanel, {|| iif( oLstEsq:nAt>0, eval( bDir ), .T. ) } , 040, 012,, oFont,, .T.,,,, /*bWhen*/)
	oBtnEsq		:= TButton():New( 070, 125, "<" , oPanel, {|| iif( oLstDir:nAt>0, eval( bEsq ), .T. ) } , 040, 012,, oFont,, .T.,,,, /*bWhen*/)
	oBtnAllEsq	:= TButton():New( 085, 125, "<<", oPanel, bAllEsq, 040, 012,, oFont,, .T.,,,, /*bWhen*/)


	//4º Panel - Lista de usuários selecionados para exportação
	CREATE PANEL ::foWizard ;
		HEADER "" ;
		MESSAGE STR0042 ;    //"Lista de usuários selecionados para exportação."
		BACK {|| .T. };
		NEXT {|| ::UpdateArray( ::faUsuarios, {USR_LOGIN,USR_GRUPO,USR_PAPEL}, aLstUsrGrp, {1, 2, 3} ), .T. } ;
		FINISH {|| .F.} ;
		EXEC {|| aLstUsrGrp := {}, ;
				aEval( ::faUsuarios, ;
						{|x| iif( x[USR_SELECT], aAdd( aLstUsrGrp, {x[USR_LOGIN], x[USR_GRUPO], x[USR_PAPEL]} ),.T. ) } ), ;
				oBrowse:SetArray( aLstUsrGrp ) } ;
		PANEL

	oPanel := ::foWizard:GetPanel(4)

	//TCColumn():New(<cTitulo>, < bData>, [cPicture], [uParam4], [uParam5], ;
	//				[cAlinhamento], [nLargura], [uParam8], [lEdit], [uParam10], [bValid], ;
	//				[uParam12], [uParam13], [uParam14])

	aColumn := {TCColumn():New( STR0016, {|| iif( len(aLstUsrGrp)>0, aLstUsrGrp[oBrowse:nAt,1], "" )},,,,"LEFT",060,.F.,.F.,,,,,)}

	// Cria Browse
	oBrowse := TCBrowse():New( ;
			05 /*[ nRow]*/, ;
			05 /*[ nCol]*/, ;
			280 /*[ nWidth]*/, ;
			130 /*[ nHeight]*/, ;
			/*[ bLine]*/, ;
			/*[ aHeaders]*/, ;
			/*[ aColSizes]*/, ;
			oPanel /*[ oWnd]*/, ;
			/*[ cField]*/, ;
			/*[ uValue1]*/, ;
			/*[ uValue2]*/, ;
			/*[ bChange]*/, ;
			/*[ bLDblClick]*/, ;
			/*[ bRClick]*/, ;
			/*[ oFont]*/, ;
			/*[ oCursor]*/, ;
			/*[ nClrFore]*/, ;
			/*[ nClrBack]*/, ;
			/*[ cMsg]*/, ;
			/*[ uParam20]*/, ;
			/*[ cAlias]*/, ;
			.T. /*[ lPixel]*/, ;
			/*[ bWhen]*/, ;
			/*[ uParam24]*/, ;
			/*[ bValid]*/,;
			/*[ lHScroll]*/, ;
			/*[ lVScroll]*/;
	)

	// Adiciona colunas
	nLen := len( aColumn )
	for nCount := 1 to nLen
		oBrowse:AddColumn( aColumn[nCount] )
	next


	//5º Panel - Confirmar configurações
	CREATE PANEL ::foWizard ;
		HEADER "" ;
		MESSAGE STR0019 ; 	//"CONFIRMAR CONFIGURAÇÕES"
		BACK {|| .T. };
		NEXT {|| .F. } ;
		FINISH {|| iif( MsgYesNo( STR0026, STR0024 ), ::saveConfig(), .F. ) } ;
		EXEC {|| aLstConf := {}, ;
				cLstMemo := "", ;
				aLstConf := ::getArrConf(), ;
				aEval( aLstConf, {|x| cLstMemo += x + CRLF } ) } ;
		PANEL

	oPanel := ::foWizard:GetPanel(5)

	oFont := TFont():New( "Courier New",, -11, , .F. )

	oLstMemo := TMultiGet():New( 005/*nRow*/, 005/*nCol*/, {|u|if(Pcount()>0, cLstMemo := u, cLstMemo)}/*bSetGet*/, oPanel/*oWnd*/, 280/*nWidth*/, 120/*nHeight*/, oFont/*oFont*/, .F./*lHScroll*/, /*nClrFore*/, /*nClrBack*/, /*uParam11*/, .T./*lPixel*/, /*uParam13*/, /*uParam14*/, {||.T.}/*bWhen*/, /*uParam16*/, /*uParam17*/, .T./*lReadOnly*/, {||.T.}/*bValid*/, /*uParam20*/, /*uParam21*/, /*lNoBorder*/, /*lNoVScroll*/ )

	//"Para confirmar a configuração, selecione a opção Finalizar"
	@ 128,10 SAY STR0023 OF oPanel SIZE 290,8 PIXEL

	//Ativa o Wizard
	ACTIVATE WIZARD ::foWizard ;
		CENTERED ;
		VALID {|| .T.} ;
		ON INIT {|| .T.} ;
		WHEN {|| .T.}

return .T.


//-------------------------------------------------------------------------
/*/{Protheus.doc} getWsEcmData
Efetua a leitura dos valores de grupos, papéis e usuários no TOTVS ECM

@protected
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@return  lOk booleano indicando se conseguiu acessar com sucesso os WebServices
/*/
//-------------------------------------------------------------------------
method getWsEcmData( aoMeter ) class TBIEcmWizard 
	local lOk := .T.
	local cError := nil

	aoMeter:set(0)
	aoMeter:refresh()

	lOk := !::flErrorWs

	if lOk
		aoMeter:set(500)
		aoMeter:refresh()
	else
		cError := getWScError( 3 )

		if valtype( cError ) == "C"
			::fcErrorMsg := STR0028 + CRLF + STR0022 //"Erro ao acessar o WebService" + "Verifique usuário, senha e empresa"
		else
			::fcErrorMsg := STR0028 + CRLF + STR0029 //"Erro ao acessar o WebService" + "Verifique o endereço informado"
		endif
	endif
                                                    
return lOk

//-------------------------------------------------------------------------
/*/{Protheus.doc} FillUsuarios
Prepara um array com a lista de usuários com pendências de exportação

@protected
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@return  lExist booleano indicando se existe algum usuário a ser exportado
/*/
//-------------------------------------------------------------------------
method FillUsuarios( aoMeter ) class TBIEcmWizard 
	local lExist 			:= .F.
	local aUsrProtheus		:= {}
	local nCount			:= 0
	local nLen				:= 0 
	local nIncMeter			:= 0
	local nIncAtual	   		:= 500
       
	Local cID				:= ""
    Local cLogin			:= ""
	Local cNome 			:= ""
	Local cEmail			:= ""  
	Local cSenha 			:= ""
	Local cBloqueado		:= .F.

	::faUsuarios := {}

	aUsrProtheus := FWSFAllUsers()

	nLen := Len( aUsrProtheus )

	if nLen > 0	
		nIncMeter := 500 / nLen
	endif

	for nCount := 1 to nLen
		nIncAtual += nIncMeter

		aoMeter:set( floor( nIncAtual ) )
		aoMeter:refresh()
	              
		cID				:= aUsrProtheus[nCount][2]
    	cLogin			:= aUsrProtheus[nCount][3]
		cNome 			:= aUsrProtheus[nCount][4]
		cEmail			:= aUsrProtheus[nCount][5] 
		cSenha 			:= PswMD5GetPass( cID )        
		cBloqueado    	:= FWSFUser( cID ,"DATAUSER","USR_MSBLQL",.F.)
		
		//Ignora inativos
		if ! ( cBloqueado == '1' ) .and. ! Empty( cSenha ) 

			//Ignora usuários que já existem no TOTVS ECM
			If ( ! ::lUserExist( cLogin ) )	
				lExist = .T.

				aAdd( ::faUsuarios, ;
					  {cID, ;		//Código
					   cLogin, ;	//Login
					   cSenha, ;	//Senha
					   cNome, ;		//Nome
					   cEmail, ;	//Email
					   "", ;		//Grupo
					   "", ;		//Papel
					   .F.} )		//Selecionado
			EndIf 
		endif
	next
return lExist

//-------------------------------------------------------------------------
/*/{Protheus.doc} getEcmUsers
Retorna os usuários ativos no TOTVS ECM

@protected
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@return  aRet array com o login dos usuários ativos no TOTVS ECM
/*/
//-------------------------------------------------------------------------
method getEcmUsers() class TBIEcmWizard
	local oWs := WSColleagueServiceService():new() 
 	local nLen := 0
 	local nCount := 0
 	local aRet := {}

	::flErrorWs := .F.

	oWs:_URL := Alltrim( ::fcWebservice ) + "/ColleagueService"

	if oWs:getColleagues( Alltrim( ::fcLogin ), ::md5Pwd(), Val( ::fcEmpEcm ) )
		nLen = len( oWs:oWsGetColleaguesResult:oWsItem )
		for nCount := 1 to nLen
			aAdd( aRet, oWs:oWsGetColleaguesResult:oWsItem[nCount]:cLogin )
		next
	else 
		::flErrorWs := .T.
	endif	
return aRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} UpdateArray
Copia valores de determinadas colunas de um array para outro, de acordo com
as chaves informadas

@protected
@param   aDest Array que será atualizada
@param   aFldDest Campos do array destino (o primeiro deve ser a chave)
@param   aOri Array que contém os valores que serão copiados
@param   aFldOri Campos do array origem (o primeiro deve ser a chave)
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
/*/
//-------------------------------------------------------------------------
method UpdateArray( aDest, aFldDest, aOri, aFldOri ) class TBIEcmWizard
	local nLen := 0
	local nLen2 := 0
	local nCount := 0
	local nCount2 := 0
	local npos := 0

	nLen := len( aOri )
	nLen2 := len( aFldDest )
	for nCount := 1 to nLen
		nPos := aScan( aDest, { |x| x[ aFldDest[1] ] == aOri[nCount][ aFldOri[1] ] } )

		if nPos > 0
			for nCount2 := 2 to nLen2
				aDest[nPos][ aFldDest[nCount2] ] := aOri[nCount][ aFldOri[nCount2] ]
			next
		endif
	next

return   

//-------------------------------------------------------------------------
/*/{Protheus.doc} getArrConf
Array de log com todas as configurações selecionadas

@protected
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@return  aConf array preenchida com as configurações selecionadas
/*/
//-------------------------------------------------------------------------
method getArrConf() class TBIEcmWizard
	local nLen 		:= 0
	local nCount 	:= 0
	local aConf 	:= {}

	if ( ::fcFilial == FILIAL_TODAS )
		aAdd( aConf, STR0036 )	//"Configurações válidas para todas as Filiais"
	else 
		aAdd( aConf, STR0037 )	//"Configurações válidas apenas para a Filial Atual"
	endif
	aAdd( aConf, "" )	
	aAdd( aConf, "[" + STR0020 + "]" )	//"Empresa TOTVS ECM"
	aAdd( aConf, "  " + ::fcEmpEcm )
	aAdd( aConf, "" )
	aAdd( aConf, "[" + STR0021 + "]" )	//"Acesso ao WebService"
	aAdd( aConf, "  " + ::fcWebservice )
	aAdd( aConf, "" )

	aAdd( aConf, "[ " + padr( STR0016, 22 ) + " ]" )
	
	nLen = len( ::faUsuarios )
	for nCount := 1 to nLen
		if ::faUsuarios[nCount][USR_SELECT]
			aAdd( aConf, space(2) + padr( substr(::faUsuarios[nCount][USR_LOGIN], 1, 23), 23 ) )
		endif
	next
return aConf

//-------------------------------------------------------------------------
/*/{Protheus.doc} saveConfig
Efetiva as configurações selecionadas

@protected
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@return  lOk booleano indicando se houve sucesso ou não
/*/
//-------------------------------------------------------------------------
method saveConfig() class TBIEcmWizard
	local lOk := .F.

	if ( ::saveParam() )
		if ( ::saveUsers() )
			lOk := .T.
			//"Operação realizada com sucesso"
			msgInfo( STR0039 )
		else
			//"Erro ao realizar gravação de usuários no TOTVS ECM"
			msgStop( STR0038 )
		endif
	else
		//"Erro ao gravar parâmetros"
		msgStop( STR0033 )
	endif

return lOk

//-------------------------------------------------------------------------
/*/{Protheus.doc} saveParam
Atualiza SX6 de acordo com parâmetros selecionados

@protected
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
/*/
//-------------------------------------------------------------------------
method saveParam() class TBIEcmWizard
	local aArea	:= GetArea()
	local cFil := ""

	if ::fcFilial == FILIAL_TODAS
		cFil := space( len( cFilAnt) )
	else
		cFil := cFilAnt
	endif

	dbSelectArea( "SX6" )
	SX6->( dbSetOrder( 1 ) )

	// Grava parâmetro com endereço dos webservices TOTVS ECM
	SX6->( dbSeek( cFil + MV_WS ) )

	if SX6->( EoF() )
		RecLock( "SX6", .T. )

		SX6->X6_VAR		:= MV_WS
		SX6->X6_TIPO	:= "C"
		SX6->X6_DESCRIC := STR0034

		if !empty( cFil )
			SX6->X6_FIL	:= cFil
		endif 
	else
		RecLock( "SX6", .F. )
	endif

	SX6->X6_CONTENG := ::fcWebservice
	SX6->X6_CONTSPA := ::fcWebservice
	SX6->X6_CONTEUD := ::fcWebservice

	MsUnLock()

	// Grava parâmetro com equivalência de empresa no TOTVS ECM
	SX6->( dbSeek( cFil + MV_EMP ) )

	if SX6->( EoF() )
		RecLock( "SX6", .T. )

		SX6->X6_VAR		:= MV_EMP
		SX6->X6_TIPO	:= "C"
		SX6->X6_DESCRIC := STR0035

		if !empty( cFil )
			SX6->X6_FIL	:= cFil
		endif 
	else
		RecLock( "SX6", .F. )
	endIf

	SX6->X6_CONTENG := Alltrim( ::fcEmpEcm )
	SX6->X6_CONTSPA := Alltrim( ::fcEmpEcm )
	SX6->X6_CONTEUD := Alltrim( ::fcEmpEcm )

	MsUnLock()

	RestArea( aArea )

return  .T.

//-------------------------------------------------------------------------
/*/{Protheus.doc} saveUsers
Exporta usuários para o TOTVS ECM

@protected
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@return  lOk booleano indicando se houve sucesso ou não
/*/
//-------------------------------------------------------------------------
method saveUsers() class TBIEcmWizard
	local oWs 			:= NIL
	local oUser 		:= NIL
	local oGroup 		:= NIL
	local oUserColl 	:= NIL
	local oGroupColl 	:= NIL
	local oRoleColl 	:= NIL
	local nLen 			:= 0
	local nCount 		:= 0
	local lOk 			:= .T.
	local cRetWs 		:= ""

	//"Iniciando exportação de Usuários..."
	conout( STR0040 )

	::flErrorWs := .F.
	nLen := len( ::faUsuarios ) 
	
	for nCount := 1 to nLen 
		if ::faUsuarios[nCount][USR_SELECT]
                
			conout( Alltrim( ::faUsuarios[nCount][USR_LOGIN] ) + STR0043 /*" - Exportado!"*/ )
              

			oWs 		:= WSColleagueServiceService():new() 
			oWs:_URL 	:= Alltrim( ::fcWebservice ) + "/ColleagueService"
			oUserColl 	:= oWs:oWScreateColleaguewithDependenciesColleagues
			oGroupColl 	:= oWs:oWScreateColleaguewithDependenciesGroups
			oRoleColl 	:= oWs:oWScreateColleaguewithDependenciesworkflowRoles
             

			oUser 				:= ColleagueServiceService_colleagueDto():New()
			oUser:ncompanyId	:= val( ::fcEmpEcm )
			oUser:ladminUser	:= .F.
			oUser:lactive		:= .T.
			oUser:cId  			:= Alltrim( ::faUsuarios[nCount][USR_LOGIN] )
			oUser:cName			:= Alltrim( ::faUsuarios[nCount][USR_NOME] )
			oUser:clogin 		:= Alltrim( ::faUsuarios[nCount][USR_LOGIN] )
			oUser:cpasswd 		:= ::faUsuarios[nCount][USR_SENHA]

			if !Empty( ::faUsuarios[nCount][USR_EMAIL] )
				oUser:cmail 		:= Alltrim( substr( ::faUsuarios[nCount][USR_EMAIL], 1, 50 ) )
			endif

			aAdd( oUserColl:oWSitem, oUser )


			oGroup 				:= ColleagueServiceService_groupDto():New()
			oGroup:nCompanyId	:= val( ::fcEmpEcm )
			oGroup:cGroupId 	:= "*"

			aAdd( oGroupColl:oWSitem, oGroup )


			if oWs:createColleaguewithDependencies( Alltrim( ::fcLogin ), ::md5Pwd(), Val( ::fcEmpEcm ), oUserColl, oGroupColl, oRoleColl )
				cRetWs := oWs:cResultXML
				if !( valtype( cRetWs ) == "C" ) .or. !( upper( Alltrim( cRetWs ) ) == "OK" )
					conout( STR0044 /*"Erro ao exportar usuário: "*/ + Alltrim( ::faUsuarios[nCount][USR_LOGIN] ) )
				endif
			else      
				conout( STR0044 /*"Erro ao exportar usuário: "*/ + Alltrim( ::faUsuarios[nCount][USR_LOGIN] ) )
			endif
		endif
	next
return  lOk

//-------------------------------------------------------------------------
/*/{Protheus.doc} md5Pwd
Retorna a senha no formato MD5:<SENHA EM MD5>

@protected
@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@return  cMd5Pwd senha no formato MD5:<SENHA EM MD5>
/*/
//-------------------------------------------------------------------------
method md5Pwd() class TBIEcmWizard
	local cMd5Pwd

	cMd5Pwd := "MD5:" + md5( Alltrim( ::fcPwd ) )

return cMd5Pwd

//-------------------------------------------------------------------------
/*/{Protheus.doc} lComparaLogin
Verifica existe usuário do ECM correspondente ao usuário do Protheus. 

@protected
@author  TI3174 - Valdiney V GOMES
@version P11
@since   14/03/2011
@return  lRet Indica se o usuário do Protheus existe no ECM. 
/*/
//-------------------------------------------------------------------------
method lUserExist( cLogin ) class TBIEcmWizard
	local oWs 		:= WSColleagueServiceService():new() 
 	local nUsuario 	:= 0
 	local lExiste	:= .F.
    
	Default cLogin 	:= ""

	::flErrorWs 	:= .F.
	oWs:_URL := Alltrim( ::fcWebservice ) + "/ColleagueService"

	if oWs:getColleague( Alltrim( ::fcLogin ), ::md5Pwd(), Val( ::fcEmpEcm ), AllTrim( cLogin ) )
		nUsuario = len( oWs:oWSgetColleaguecolab:oWsItem )  
		
		If ( nUsuario > 0 ) 
			lExiste := .T.
		EndIf
	else 
		::flErrorWs := .T.
	endif	
return lExiste

//-------------------------------------------------------------------------
/*/{Protheus.doc} CFGBIECMWZ
Instancia e executa o wizard de integração Protheus - TOTVS ECM

@author  TI3510 - Gilmar P. Santos
@version P11
@since   20/07/2009
@sample
....
	prepare environment empresa "99" filial "01"

	CFGBIECMWZ()
....
/*/
//-------------------------------------------------------------------------
function CFGBIECMWZ()  
	local oWizard := NIL	
	//prepare environment empresa "99" filial "01"    	
	oWizard := TBIEcmWizard():New()
	oWizard:Start()
return