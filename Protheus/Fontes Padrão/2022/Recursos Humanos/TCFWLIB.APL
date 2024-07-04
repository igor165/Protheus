#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TCFWLIB.CH"
#INCLUDE "APWEBEX.CH"

Static __lTcfFinal	:= .F.
Static __cTcfStack	:= ""
Static __cFinal1	:= ""
Static __cFinal2	:= ""
Static __cTcfDefEmp	:= ""
Static __cTcfDefFil	:= ""

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Programa  ³TCFWLIB   ³ Autor ³ Marinaldo de Jesus	  ³ Data ³04/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Biblioteca de Funcoes Utilizada no Terminal de Consulta	    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Void>                                                      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ Gen‚rico                                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                     ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL. ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Ricardo D.  ³09/10/06³110288³Ajuste na abertura dos arquivos PREPARE   ³
³            ³        ³      ³ENVIRONMENT de forma a nao abrir tabelas  ³
³            ³        ³      ³que precisam ser abertas de forma exclusi-³
³            ³        ³      ³va durante os fechamentos da folha e do   ³
³            ³        ³      ³ponto eletronico.                         ³
³Alex        ³29/01/10³025836³Adaptação Gestão Corporativa, controles:  ³
³            ³        ³  2009³Grupo de campos de filial.                ³
³Alex        ³18/03/10³004209³Tratar o cCodigo no FPHist82, considerando³
³            ³        ³  2010³a Filial de forma correta.                ³
³Rogerio     ³24/03/10³006215³Alteracao da interface do RH-Online para a³
³            ³        ³  2010³versao 11.                                ³
³Mauricio MR ³21/06/10³013667³Realizado ajuste para permitir acessar    ³
³            ³        ³/2010 ³mais de uma empresa/funcao sem perda de   ³
³            ³        ³      ³conexao.                                  ³
³Allyson M   ³19/05/11³011915³Ajuste para evitar erro devido a gestao   ³
³            ³        ³/2011 ³corporativa.   							³
³Allyson M   ³28/06/12³015681³Ajuste para evitar erro devido a gestao   ³
³            ³        ³/2012 ³corporativa.(EMPSELECT)					³
³R.Berti	 ³02/08/12³TEMAF1³Ajuste efetuado ref. error log "invalid	³
³            ³        ³      ³typecast...on TCFTABELA(TCFWLIB.APL)"		³
³Gustavo M.	 ³12/12/12³TGACK0³Utilizacao da funcao FWGetPvProf para 	³
³            ³        ³      ³permitir sel de filias s/ limite de qtde.	³
³Flavio C.	 ³01.09.14³TQKWDI³Ajuste na função que retorna o diretorio	³
³            ³        ³      ³ de imagens do portal						³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Eduardo K   ³09/09/17³MPRIMESP-9259 ³Ajuste para obter o tamanho correto da     ³
³            ³        ³      		 ³filial na chave EMPSELECT(XX)           	 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´

ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFInit      ³Autor³Marinaldo de Jesus    ³ Data ³11/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Funcao de Inicializacao de Procedimento WEB                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RH OnLine                                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TcfInit( cHtml )

Local aExecBlock	:= {}
Local cProcName1	:= ProcName(1)
Local cPrefixo		:= Upper( SubStr( cProcName1 , 1 , 2 ) )
Local cBlockUser	:= ""
Local lOk			:= .T.

IF ( cPrefixo $ "W_/U_/T_/H_" )
	cBlockUser := SubStr( cProcName1 , 3 )
Else
	cBlockUser := cProcName1
EndIF

Private cPaisLoc	:= "BRA"	//Varivel Obrigatoria para ExistBlock
Private __lPyme		:= .F.	 	//Varivel Obrigatoria para ExistBlock

DEFAULT cHtml := ""

IF ExistBlock( cBlockUser )		//Se existir Funcao de usuario com o mesmo nome, executa.
	aExecBlock := ExecBlock(;
								cBlockUser,;
								.F.,;
								.F.,;
								{;
									cHtml,;
									"INIT";
								},;
								.F.;
			 				)
	IF ( ValType( aExecBlock ) == "A" )
		IF (;
				( Len( aExecBlock ) >= 1 );
				.and.;
				( ValType( aExecBlock[1] ) == "C" );
			)	
			cHtml	:= aExecBlock[ 1 ]
		EndIF	
		IF (;
				( Len( aExecBlock ) >= 2 );
				.and.;
				( ValType( aExecBlock[2] ) == "L" );
			)
			lOk		:= aExecBlock[ 2 ]
		EndIF
	EndIF
EndIF

Return( lOk )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFEnd       ³Autor³Marinaldo de Jesus    ³ Data ³11/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Funcao de Finalizacao de Procedimento WEB                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RH OnLine                                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TcfEnd( cHtml )

Local cProcName1	:= ProcName(1)
Local cPrefixo		:= Upper( SubStr( cProcName1 , 1 , 2 ) )
Local cBlockUser	:= ""
Local cHtmlBlock	:= ""

IF ( cPrefixo $ "W_/U_/T_/H_" )
	cBlockUser := SubStr( cProcName1 , 3 )
Else
	cBlockUser := cProcName1
EndIF

Private cPaisLoc	:= "BRA"	//Varivel Obrigatoria para ExistBlock
Private __lPyme		:= .F.	 	//Varivel Obrigatoria para ExistBlock

DEFAULT cHtml := ""

IF ExistBlock( cBlockUser )		//Se existir Funcao de usuario com o mesmo nome, executa.	
	cHtmlBlock := ExecBlock(;
								cBlockUser,;
								.F.,;
								.F.,;
								{;
									cHtml,;
									"END";
								},;
								.F.;
			 				)
	IF ( ValType( cHtmlBlock ) == "C" )
		cHtml := cHtmlBlock
	EndIF
EndIF

cHtml := TcfHistDisable( cHtml )

Return( .T. )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³EmptyHtml    ³Autor³Marinaldo de Jesus    ³ Data ³21/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Verifica se Uma String Html esta Vazia                      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function EmptyHtml( cHtml )

Local lEmpty := .F. 

DEFAULT cHtml := ""

lEmpty := ( Empty( cHtml ) .or. Upper( AllTrim( cHtml ) ) == Upper( AllTrim( HtmlProcId() ) ) )

Return( lEmpty )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³HtmlDefault³ Autor ³ Marinaldo de Jesus   ³ Data ³26/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna Codigo Html Padrao com mensagem pre-Definida        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³HtmlDefault( cMsg , cRetorno )								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function HtmlDefault( cTitle , cMsg , cReturn , lLogout , lPrint )

Local cHtmlDefault

DEFAULT cTitle		:= ""
DEFAULT cMsg		:= ""
DEFAULT cReturn		:= '<p align="right"><a href="W_TCFW006.APW" target="divPrincipal"><img src="'+TcfRetDirImg()+'/confirmar.gif" border="0"></a></p>'
DEFAULT lPrint		:= .F.
DEFAULT	lLogout		:= .F.

IF ( lLogout )
	cReturn	:= '<p align="right"><a href="W_TCFWRETURN.APW" ><img src="'+TcfRetDirImg()+'/confirmar.gif" border="0"></a></p>'
EndIF

//cHtmlDefault += 			HtmlProcId() + CRLF

cHtmlDefault := '<?xml version="1.0" encoding="iso-8859-1"?>' + CRLF
cHtmlDefault += '<!doctype html public "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' + CRLF
cHtmlDefault += '<html xmlns="http://www.w3.org/1999/xhtml">' + CRLF
cHtmlDefault += 	'<head>' + CRLF
cHtmlDefault += 		'<title>' + STR0004 + '</title>' + CRLF //"Protheus - RH Online"
cHtmlDefault += 			'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">' + CRLF
cHtmlDefault += 			'<link rel="stylesheet" href="css/rhonline.css" type="text/css">' + CRLF
cHtmlDefault +=				'<meta http-equiv="Expires" content="Tue, 15 Dec 1970 00:00:00 GMT">' + CRLF
cHtmlDefault +=				'<script>' + CRLF
cHtmlDefault +=					'history.forward();' + CRLF
cHtmlDefault +=				'</script>' + CRLF
cHtmlDefault += 	'</head>' + CRLF
cHtmlDefault += 	'<body style="background-color: transparent;">' + CRLF
cHtmlDefault += 		'<table width="515" border="0" cellspacing="0" cellpadding="0" align="center">' + CRLF
cHtmlDefault += 			'<tr>' + CRLF
cHtmlDefault += 				'<td class="titulo">' + CRLF
cHtmlDefault +=						'<p><img src="'+TcfRetDirImg()+'/icone_titulo.gif" width="7" height="9"> <span class="titulo_opcao">' + cTitle + '</span><br>' + CRLF
cHtmlDefault +=         			'<br>' + CRLF
cHtmlDefault +=       				'</p>' + CRLF
cHtmlDefault +=					'</td>' + CRLF
cHtmlDefault +=				'</tr>' + CRLF
cHtmlDefault +=				'<tr>' + CRLF
cHtmlDefault +=					'<td>' + CRLF
cHtmlDefault +=						'<img src="'+TcfRetDirImg()+'/tabela_conteudo.gif" width="515" height="12">' + CRLF
cHtmlDefault +=					'</td>' + CRLF
cHtmlDefault +=				'</tr>' + CRLF
cHtmlDefault +=				'<tr>' + CRLF
cHtmlDefault +=					'<td>' + CRLF
cHtmlDefault +=						'<table width="515" border="0" cellspacing="0" cellpadding="0">' + CRLF
cHtmlDefault +=         				'<tr>' + CRLF
cHtmlDefault +=           					'<td background="'+TcfRetDirImg()+'/tabela_conteudo_1.gif" width="10">&nbsp;</td>' + CRLF
cHtmlDefault +=           					'<td class="alerta" width="498" align="center">' + CRLF
cHtmlDefault +=             					'<p>&nbsp;</p>' + CRLF
cHtmlDefault +=             					'<p>' + cMsg + '!</p>' + CRLF
cHtmlDefault +=             					'<p>&nbsp;</p>' + CRLF
cHtmlDefault +=           					'</td>' + CRLF
cHtmlDefault +=           					'<td background="'+TcfRetDirImg()+'/tabela_conteudo_2.gif" width="7">&nbsp;</td>' + CRLF
cHtmlDefault +=         				'</tr>' + CRLF
cHtmlDefault +=   					'</table>' + CRLF
cHtmlDefault +=  				'</td>' + CRLF
cHtmlDefault +=   			'</tr>' + CRLF
cHtmlDefault +=   			'<tr>' + CRLF
cHtmlDefault +=    				'<td><img src="'+TcfRetDirImg()+'/tabela_conteudo_3.gif" width="515" height="14"></td>' + CRLF
cHtmlDefault +=  			'</tr>' + CRLF
cHtmlDefault +=   			'<tr>' + CRLF
cHtmlDefault +=    				'<td>'  + CRLF
cHtmlDefault += 					cReturn + CRLF
cHtmlDefault +=					'</td>' + CRLF
cHtmlDefault +=  			'</tr>' + CRLF
cHtmlDefault += 		'</table>' + CRLF
cHtmlDefault += 		'<br>' + CRLF
IF lPrint
	cHtmlDefault += 		'<br><br>' + CRLF
	cHtmlDefault += 		'<p align="right"><a href="javascript:self.print()"><img src="'+TcfRetDirImg()+'/imprimir.gif" width="90" height="28" hspace="20" border="0"></a></p>' + CRLF
EndIF
cHtmlDefault +=		'</body>' + CRLF
cHtmlDefault += '</html>' + CRLF

Return( cHtmlDefault )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TcfHistDisable³Autor³Marinaldo de Jesus   ³ Data ³25/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Inclui codigo HTML para desabiliar o Histori                ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TcfHistDisable( cHtml )

Local cHistDisable

IF !Empty( cHtml )
	cHistDisable	:=  '<head>' + CRLF
	cHistDisable	+=	'<meta http-equiv="Expires" content="-1">' + CRLF
	cHistDisable	+=  '</head>' + CRLF
	cHistDisable	+=	'<script>' + CRLF
	cHistDisable	+=	'history.forward();' + CRLF
	cHistDisable	+=	'</script>' + CRLF
	cHtml			:= ( cHistDisable + cHtml )
EndIF

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³NoCooKiesMsg ³Autor³Marinaldo de Jesus    ³ Data ³19/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna Codigo Html Padrao quando "Browser" nao Suportar    ³
³          ³CooKies 													³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function NoCooKiesMsg()

Local cHtml := ""

//"Chamada Inv&aacute;lida"
//"N&atilde;o foi poss&iacute;vel realizar o processamento."
//"Verifique se o seu browser suporta Cookies."
cHtml := HtmlDefault( STR0001 + " ( " + Procname(1) + " ) " , STR0002 + "<br>" + STR0003 , NIL , .T. )

Return( cHtml )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TcfTabela ³ Autor ³ Marinaldo de Jesus    ³ Data ³29/09/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Procura na tabela correspondente o codigo cadastrado, poden-³
³          ³do ser no SX5, SRX, ou arquivo normal.                      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TcfTabela( cFil , cTipo , cValor , cCampo , cF3 , cPict )

Local aArea 		:= GetArea()
Local aEmpInfo		:= {}
Local cRet			:= ""
Local cTabela		:= ""
Local cPrefix		:= ""
Local cCbox			:= ""
Local cAuxFil		:= ""
Local cAntValor		:= cValor
Local cXbFiltro		:= ""
Local cXbTipo		:= ""
Local cCpoDesc		:= "DESC"
Local cFieldDesc	:= ""
Local lXbFiltro		:= .F.
Local nCbox1		:= 0.00
Local nCbox2		:= 0.00
Local nPos			:= 20
Local nOrder		:= 0.00
Local nFieldDesc	:= 0.00
Local uXbFiltro		:= NIL
Local xXbFiltro		:= NIL

DEFAULT cPict		:= ""

cAuxFil := RhTamFilial(cFil,cEmpAnt)

IF ( cTipo == "SRX" )
	IF ( Select( cTipo ) == 0.00 )
		ChkFile( cTipo )
	EndIF	
	IF ( Select( cTipo ) > 0.00 )
		IF ( cF3 == "X04" )
			cAuxFil := Replicate("0", FWGETTAMFILIAL)
			nPos	:= 40
		ElseIF ( cF3 == "X39" )
			nPos := 30
		EndIF
		cValor := ( RhTamFilial(cAuxFil,cEmpAnt) + cValor )
		IF !fPHist82(cFil,Substr(cF3,2,2),cValor,1,nPos,@cRet)
			cRet	:= ""
			cAuxFil	:= Space( FwGetTamFilial )
			cValor	:= ( RhTamFilial(cAuxFil,cEmpAnt) + cAntValor )
			fPHist82(cFil,Substr(cF3,2,2),cValor,1,nPos,@cRet)
		EndIF
	EndIF
ElseIF ( cTipo == "CBOX" )
	SX3->( dbSetOrder( 02 ) )
	IF SX3->( MsSeek( cCampo ) )
		IF !Empty( cValor )
			cCbox	:= ( cValor+"=" )
			nCbox1	:= Rat( cCbox , SX3->X3_CBOX )
			nCbox2	:= SX3->( At( ";" ,SubStr( X3_CBOX , nCbox1 , Len( X3_CBOX ) ) ) )
			IF ( nCbox2 == 0.00 )
				nCbox2 := Len( SX3->X3_CBOX )
			Else
				nCbox2 := ( nCbox2 - 1 )
			EndIF
			cRet := SubStr( SX3->X3_CBOX , ( nCbox1 + Len( cCbox ) ) , ( nCbox2 - Len( cCbox ) ) )
		EndIF	
	EndIF
	SX3->( dbSetOrder( 01 ) )
ElseIF ( cTipo == "F3" )
	SXB->( dbSetOrder( 01 ) )
	IF SXB->( MsSeek( cF3 ) )
		cTabela := AllTrim( SXB->XB_CONTEM )
		IF SX2->( MsSeek( cTabela ) )
			IF ( Select( cTabela ) == 0.00 )
				ChkFile( cTabela )
			EndIF
			IF ( Select( cTabela ) > 0.00 )
				While SXB->( !Eof() .and. XB_ALIAS == cF3 )
					cXbTipo := SXB->XB_TIPO
					IF ( cXbTipo == "2" )
						IF ( nOrder == 0.00 )
							nOrder := Val( SXB->XB_COLUNA )
						EndIF	
					ElseIF ( cXbTipo == "6" )
						cXbFiltro := SXB->XB_CONTEM
					EndIF
					SXB->( dbSkip() )
				End While
			EndIF
		EndIF
		cXbFiltro := IF( Empty( cXbFiltro ) , ".T." , cXbFiltro )
		cXbFiltro := StrTran( cXbFiltro , "@" , "" )
		cXbFiltro := StrTran( cXbFiltro , "#" , "" )
		IF ( !Empty( cTabela ) .and. ( Select( cTabela ) > 0.00 ) )
			IF !( cTabela == "SM0" )
				( cTabela )->( dbSetOrder( IF( Empty( nOrder ) , 1 , nOrder ) ) )
				cAuxFil := xFilial( cTabela , cFil )
				cPrefix	:= ( PrefixoCpo( cTabela ) + "_" )
				IF ( ( cTabela )->( MsSeek( ( RhTamFilial(cAuxFil,cEmpAnt) + cValor ) ) ) )
					cFieldDesc := ( cPrefix+cCpoDesc )
					IF ( ( nFieldDesc := ( cTabela )->( FieldPos( cFieldDesc ) ) ) == 0.00 )
						cCpoDesc 	:= "DESCR"
						cFieldDesc	:= ( cPrefix+cCpoDesc )
						IF ( ( nFieldDesc := ( cTabela )->( FieldPos( cFieldDesc ) ) ) == 0.00 )
					    	cCpoDesc	:= "DESCRI"
					    	cFieldDesc	:= ( cPrefix+cCpoDesc )
					    	IF ( ( nFieldDesc	:= ( cTabela )->( FieldPos( cFieldDesc ) ) ) == 0.00 )
					    		cCpoDesc	:= "DESCRIC"
					    		cFieldDesc	:= ( cPrefix+cCpoDesc )
					    		nFieldDesc	:= ( cTabela )->( FieldPos( cFieldDesc ) )
					    	EndIF
					    EndIF
					EndIF
					While (;
								( cTabela )->(;
													!Eof() .and.;
													(;
														( cAuxFil + cValor ) == ;
														SubStr(;
																	&( IndexKey() ) ,;
																	1 ,;
																	Len( ( cAuxFil + cValor ) );
																);
													);
												);
							)												
						uXbFiltro := cXbFiltro
						IF ( lSXBFiltro := ( cTabela )->( CheckExecForm( @uXbFiltro , .F. ) ) )
							DEFAULT uXbFiltro := .F.
							If ValType( uXbFiltro ) <> "L"
								uXbFiltro := StrTran( uXbFiltro , "@#" , "" )
								// Trata o retorno qdo conteudo for uma funcao
								xXbFiltro := (uXbFiltro)
								If ValType( xXbFiltro ) <> "L"
									xXbFiltro := StrTran( xXbFiltro , "@#" , "" )
								EndIf
								uXbFiltro := xXbFiltro
							EndIf
							IF ( uXbFiltro )
								IF ( nFieldDesc > 0.00 )
									cPict	:= PesqPict( cTabela , cFieldDesc )
									cRet	:= ( cTabela )->( FieldGet( nFieldDesc ) )
								EndIF
							EndIF
						EndIF
						DEFAULT uXbFiltro := .F.
						If ValType( uXbFiltro ) <> "L"
							uXbFiltro := StrTran( uXbFiltro , "@#" , "" )
							// Trata o retorno qdo conteudo for uma funcao
							xXbFiltro := (uXbFiltro)
							If ValType( xXbFiltro ) <> "L"
								xXbFiltro := StrTran( xXbFiltro , "@#" , "" )
							EndIf
							uXbFiltro := xXbFiltro
						EndIf
						IF ( uXbFiltro )
							Exit
						EndIF
						( cTabela )->( dbSkip() )
					End While
				EndIF
			Else
				IF fInfo(@aEmpInfo,cFil)
					cRet := aEmpInfo[ 03 ]
				EndIF
				cPict := "@!"
			EndIF
		EndIF
	Else //Tabela do SX5
		IF SX2->( MsSeek( "SX5" ) )
			IF ( Select( "SX5" ) == 0.00 )
				ChkFile( "SX5" )
			EndIF	
			cAuxFil := IF( SX2->X2_MODO == "C" , Space( FwGetTamFilial ) , cFil )
		EndIF
		IF ( Select( "SX5" ) > 0.00 )
			SX5->( dbSetOrder( 01 ) )
			IF SX5->( MsSeek( ( RhTamFilial(cAuxFil,cEmpAnt) + Alltrim( cF3 ) + cValor ) ) )
				cRet := SX5->( x5Descri() )
			EndIF
		EndIF
	EndIF
EndIF

cRet := StrTran(cRet,"=","")

RestArea( aArea )

Return( cRet )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³GetEmpSigaMat³Autor³Marinaldo de Jesus    ³ Data ³11/12/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Abre o Cadastro de Empresas e Retorna Array com as Empresas ³
³          ³Validas														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function GetEmpSigaMat(lCheck)

Local aEmpresas		:= {}
Local aEmpFilSelect	:= {}
Local aMsgErr		:= {}

Local cEmpSelect	:= AllTrim( GetJobProfString( "EmpSelect" , ""  ) )
Local cFilSelect	:= ""	
Local cEmp			:= ""
Local cFil			:= ""

Local lRpcChkSxs	:= FindFunction( "RpcChkSxs" )

Local nEmp			:= 0.00
Local nSizeEmp		:= Len( cEmpSelect )
Local nFil			:= 0.00
Local nSizeFil		:= 0.00              
Local nSizeUFil     := 0
LoCal nSizeBFil		:= 0

DEFAULT lCheck := .T.

If !lCheck
	lRpcChkSxs	:= .f.
Endif
                                 
IF ( Select( "SM0" ) == 0 )
	Private cArqEmp := "sigamat.emp"
	OpenSM0()
EndIF

nSizeUFil:= FWSizeFilial() 
nSizeBFil:= nSizeUFil + 1

For nEmp := 1 To nSizeEmp Step 3
	IF !Empty( cEmp := SubStr( cEmpSelect , nEmp , 02 ) )
		If FindFunction("FWGetPvProf")
			IF !Empty( cFilSelect := AllTrim( FWGetPvProf( GetWebJob(),'EmpSelect' + cEmp  , ""  ) ) )
				nSizeFil := Len( cFilSelect )
				For nFil := 1 To nSizeFil Step nSizeBFil
					IF !Empty( cFil := SubStr( cFilSelect , nFil , nSizeUFil ) )
						aAdd( aEmpFilSelect , ( cEmp + cFil ) )
					EndIF
				Next nFil
			EndIF  
		Else
		 	IF !Empty( cFilSelect := AllTrim( GetJobProfString( 'EmpSelect' + cEmp  , ""  ) ) )
				nSizeFil := Len( cFilSelect )
				For nFil := 1 To nSizeFil Step nSizeBFil
					IF !Empty( cFil := SubStr( cFilSelect , nFil , nSizeUFil ) )
						aAdd( aEmpFilSelect , ( cEmp + cFil ) )
					EndIF
				Next nFil
		   EndIF
		Endif
	EndIF
Next nEmp


nSizeEmp := Len( aEmpFilSelect )
IF nSizeEmp = 0
	SM0->( dbGotop() )
	While SM0->( !Eof() )
		IF SM0->( !Deleted() )
			If  (!lRpcChkSxs .or. RpcChkSxs( SM0->M0_CODIGO , @aMsgErr , .F. ))
				SM0->(aAdd( aEmpresas ,{	M0_CODIGO+M0_CODFIL,M0_CODIGO+" - "+M0_NOME+" / "+M0_CODFIL+" - "+M0_FILIAL } ))
			Endif
		EndIF
		SM0->( dbSkip() )
	Enddo
Else
	For nEmp := 1 To nSizeEmp
		IF SM0->( MsSeek( aEmpFilSelect[ nEmp ] , .F. ) )
			If  !lRpcChkSxs .or. RpcChkSxs( SM0->M0_CODIGO , @aMsgErr , .F. )
				SM0->(aAdd( aEmpresas ,{	M0_CODIGO+M0_CODFIL,M0_CODIGO+" - "+M0_NOME+" / "+M0_CODFIL+" - "+M0_FILIAL } ))
			Endif
		EndIF
	Next nEmp
EndIF

Return( aClone( aEmpresas ) )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TcfRetDirImg ³Autor³Marinaldo de Jesus    ³ Data ³08/01/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna o Diretorio Onde se Encontam as Imagens do TCF		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TcfRetDirImg()

Local cDirImg := ""

#IFDEF SPANISH
		cDirImg := "imgspa"
#ELSE
	#IFDEF ENGLISH
		cDirImg := "imgeng"
	#ELSE
		cDirImg := "imagens-rh"
	#ENDIF
#ENDIF

Return( cDirImg )

/*/
======================================================================
Funcoes para utilizacao com APWEBEX. 
Configurar Working Threads com JOB Type=WEB e SigaWEB = TCF
====================================================================== */
/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³SigaTcfStart   ³Autor³Marinaldo de Jesus  ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Start do RHOnLine                                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function SigaTcfStart()

Local aEmps		:= GetEmpSigaMat(.T.) // Nao rodar checagem alguma nas empresas / filiais
Local aMsgErr	:= {}
Local cAnt		:= "__cAnt__"
Local lEnvError	:= .F.

Local cEmp
Local cFil
Local nLoop
Local nLoops
Local nFailed
Local lFirst

// Intercepta a funşÒo FINAL do ERP
SetOnExit("",.T.)
SetOnExit("TCFFINAL")

BEGIN SEQUENCE

	nLoops	:= Len( aEmps )

	If nLoops = 0
		UserException(STR0005) //"Nenhuma empresa/filial encontrados. Verifique configuração EMPSELECT e/ou arquivo SIGAMAT.EMP"
	Endif
	
	nFailed := 0

	If FindFunction( "RpcChkSxs" )
		// Verifica se as empresas do array são válidas
		// Caso não sejam, as empresas invalidas do array vão sendo eliminadas
		nLoop := 1
		While nLoop <= nLoops
			IF aEmps[nLoop] <> NIL 
				cEmp := SubStr( aEmps[nLoop][1] , 1 , 2 )
				IF !RpcChkSxs( cEmp , @aMsgErr , .F. )
					nFailed++
					adel(aEmps,nLoop)
					LOOP
				Else
					//Preparar apenas um ambiente, após a confirma do usuario
					//preparar o ambiente que usuario ira utilizar
					nLoop := nLoops 
				EndIf
			Endif
			nLoop++
		Enddo
		asize(aEmps,nLoops-nFailed)
	EndIF
	
	If nLoops = nFailed
		// Todas as empresas falham na verificacao dos dicionarios
		conout(replicate('=',79))
		conout(STR0006) //"RH ONLINE - MODULO SIGATCF - Terminal de Consulta "
		Conout(STR0007+CRLF) //"ATENCAO : Todas as empresas especificadas falharam na verificação de ambiente."
		aeval(aMsgErr , {|x| conout("Empresa ["+x[1]+"]"+CRLF+x[2]) })
		conout(replicate('=',79))
		UserException(STR0005) //"Nenhuma empresa/filial válidas. Verifique configuração EMPSELECT e/ou arquivo SIGAMAT.EMP"
	ElseIf nFailed > 0
		conout(replicate('=',79))
		conout(STR0006) //"RH ONLINE - MODULO SIGATCF - Terminal de Consulta "
		Conout(STR0008+CRLF)//"ATENCAO : Algumas empresas especificadas falharam na verificação de ambiente."
		aeval(aMsgErr , {|x| conout("Empresa ["+x[1]+"]"+CRLF+x[2]) })
		conout(replicate('=',79))
	Endif
	
	//nLoops	:= Len( aEmps )
	lFirst := .T.
	
	//Prepara ambiente
	fRhOnPrepEnv( aEmps, cAnt, lFirst )

RECOVER

	lEnvError := .T.
	
END SEQUENCE
	
IF ( __lTcfFinal )
	// Se houve finalizacao ( FINAL ) , retorna .T. AKI pra subir a thread
	// com msg de bloqueio . Nßo pode retornar direto dentro de begin ... end sequence
	Return( .T. )
ElseIF ( lEnvError )
	// Se houve Algum outro erro de ambiente, retorna .F. pra nao subir a WT
	Return( .F. )
EndIF

// Se deu tudo certo ... 
// RE-Seta novamente a rotina de finalizacao para o Default da LIB
SetOnExit("",.T.)
SetOnExit("WEXFINAL")

// e Sobe a thread
Return( .T. )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³SigaTcfConNect ³Autor³Marinaldo de Jesus  ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³chamada a toda vez que o usuario clicar em um lugar no site ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function SigaTcfConNect( p1 , p2 , p3 , p4 , p5 , p6 , p7 )

IF ( __lTcfFinal )

	// Se houve uma finalizacao no start , 
	// Aborta esta thread com um exception com a descricao do erro

	UserException( "ERP FINAL ROUTINE : " + __cFinal1 + " / " + __cFinal2 + CRLF + __cTcfStack )

EndIF

IF Empty( TCFWGetEmp() ) 
	IF Empty( TCFGetPstEmp() )
  		If !(select("_"+__cTcfDefEmp+"_SX3") > 0)
		    fRhOnPrepEnv( , __cTcfDefEmp, .F., __cTcfDefEmp , __cTcfDefFil )
		EndIf
		RPCSetEmpFil( __cTcfDefEmp , __cTcfDefFil )
	Else
		If !(select("_"+TCFGetPstEmp()+"_SX3") > 0)                            
			fRhOnPrepEnv( , __cTcfDefEmp, .F., TCFGetPstEmp(), TCFGetPstFil() )
		EndIf                  
		RPCSetEmpFil( TCFGetPstEmp() , TCFGetPstFil() )
	EndIF
Else
	If !(select("_"+TCFWGetEmp()+"_SX3") > 0)
		fRhOnPrepEnv( ,__cTcfDefEmp , .F., TCFWGetEmp(), TCFWGetFil() )
	EndIf
	RPCSetEmpFil( TCFWGetEmp() , TCFWGetFil() )
EndIF

Return( "" )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³SigaTcfReset ³Autor³Marinaldo de Jesus    ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³chamada a toda vez que o processamento terminar				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function SigaTcfReset()
	RPCClearEmp()
Return( "" )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³SigaTcfExit	 ³Autor³Marinaldo de Jesus    ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Essa funşÒo Ú chamada a quando a thread sai da memoria		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function SigaTcfExit()
	RESET ENVIRONMENT
Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TcfFinal	 ³Autor³Marinaldo de Jesus    ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Finalizacao com tratamento de Erro							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TcfFinal( cMsg1 , cMsg2 )

Local nProcName := 0

__lTcfFinal	:= .T.
__cTcfStack	:= ( "Final Stack : " + CRLF )

IF !Empty(cMsg1) ; 	__cFinal1	:= cMsg1 ; EndIF
IF !Empty(cMsg2) ; 	__cFinal2	:= cMsg2 ; EndIF

While ( !Empty( ProcName( ++nProcName ) ) )
	__cTcfStack += ProcName( nProcName ) + ' ('+Str( ProcLine( nProcName ) , 5 ) + ')' + CRLF
End While
Break
Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWGetEmp	 ³Autor³Marinaldo de Jesus    ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna a Empresa											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFWGetEmp()
Return( HttpSession->_TCFWEMP )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFGetPstEmp ³Autor³Marinaldo de Jesus    ³ Data ³15/09/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Obtem a Empresa que Foi Postada								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFGetPstEmp()

Local cEmp

IF !Empty( HttpPost->cEmpFil )
	cEmp := SubStr( HttpPost->cEmpFil , 1 , 2 )
EndIF

Return( cEmp )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFGetPstFil ³Autor³Marinaldo de Jesus    ³ Data ³15/09/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Obtem a Filial que Foi Postada								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFGetPstFil()

Local cFil

IF !Empty( HttpPost->cEmpFil )
	cFil := SubStr( HttpPost->cEmpFil , 3 , FwGetTamFilial )
EndIF

Return( cFil )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWSetEmp	 ³Autor³Marinaldo de Jesus    ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Setar a Empresa												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFWSetEmp( cEmp )
HttpSession->_TCFWEMP := cEmp
Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWGetFil	 ³Autor³Marinaldo de Jesus    ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna a Filial											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFWGetFil( )
Return( HttpSession->_TCFWFIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWSetFil	 ³Autor³Marinaldo de Jesus    ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Setar a Filial												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFWSetFil( cFil )
HttpSession->_TCFWFIL := cFil
Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWGetMat	 ³Autor³Marinaldo de Jesus    ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna a Matricula											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFWGetMat()
Return( HttpSession->_TCFWMAT )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWSetMat	 ³Autor³Marinaldo de Jesus    ³ Data ³16/02/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Seta a Matricula											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFWSetMat( cMat )
HttpSession->_TCFWMAT := cMat
Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWGetPas	 ³Autor³Marinaldo de Jesus    ³ Data ³24/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna o PassWord 											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFWGetPas()
Return( HttpSession->_TCFWPAS )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFWSetPas	 ³Autor³Marinaldo de Jesus    ³ Data ³24/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Seta o PassWord 											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFWSetPas( cPassWord )
HttpSession->_TCFWPAS := cPassWord
Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFGelAllOk  ³Autor³Marinaldo de Jesus    ³ Data ³25/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Verifica se Todas as informacoes estao OK					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFGelAllOk()
IF Empty( HttpSession->_TCFWISALLOK )
	TCFSetAllOk()
EndIF
Return( HttpSession->_TCFWISALLOK )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³TCFSetAllOk  ³Autor³Marinaldo de Jesus    ³ Data ³25/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Seta o Tudo Ok na Session                 					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³SIGATCF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function TCFSetAllOk( lAllOk )

DEFAULT lAllOk := .F.

HttpSession->_TCFWISALLOK	:= lAllOk

Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³InTcfwLibExec ³Autor ³Marinaldo de Jesus   ³ Data ³24/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Executar Funcoes Dentro de TCFWLIB                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³InTcfwLibExec( cExecIn , aFormParam )						 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³uRet                                                 	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico 													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function InTcfwLibExec( cExecIn , aFormParam )
         
Local uRet

DEFAULT cExecIn		:= ""
DEFAULT aFormParam	:= {}

IF !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= cExecIn
	CheckExecForm( @uRet )
EndIF

Return( uRet )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fRhOnPrepEnv  ³Autor ³Igor Franzoi		   ³ Data ³05/03/2010³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Executar PrepEnv (Lib) para o RHOnline						 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fRhOnPrepEnv												 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³uRet                                                 	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico 													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function fRhOnPrepEnv( aEmps, cAnt, lFirst, cSetEmp, cSetFil )

Local lRet	 := .T.
Local lPrep	 := .T.

Local cEmp
Local cFil

Local nLenFil	:= 2
Local nLoop
Local nLoops
Local nStart 	:= 1

Local aMsgErr	:= {}

DEFAULT aEmps	:= {}
DEFAULT cAnt	:= "__cAnt__"
DEFAULT lFirst	:= .T.

	IF ( Select( "SM0" ) == 0 )
		Private cArqEmp := "sigamat.emp"
		OpenSM0()
		nLenFil	:= Len(SM0->M0_CODFIL)
	EndIF

	If Empty(aEmps)
		aEmps := GetEmpSigaMat(.T.)
	EndIf
	
	If !( Type("cEmpAnt") == "U" .or. Type("cFilAnt") == "U" )
		If ( !Empty(cSetEmp) .and. !Empty(cSetFil) )
			If ( cEmpAnt <> cSetEmp .or. cFilAnt <> cSetFil )
				nStart := aScan( aEmps, { |x| x[1] == AllTrim(cSetEmp)+PadR(cSetFil, nLenFil, "")} )
				If !RpcChkSxs( cSetEmp , @aMsgErr , .F. )
					lRet := .F.
				EndIf
			Else
				lPrep := .F.
			EndIf	
		EndIf
	EndIf
	
	nLoops	:= Len( aEmps )

	If (lPrep)

		For nLoop := nStart To nLoops
	
			cEmp := SubStr( aEmps[nLoop][1] , 1 , 2 )
	
			IF ( cAnt <> cEmp )
	
				cAnt := cEmp
				cFil := SubStr( aEmps[nLoop][1] , 3 , 2 )
	
				#IFDEF TOP
					SetTopType( "A" )
				#ENDIF
	            IF lFirst
					RPCSetType( 5 )
					lFirst := .F.
				Else
					RPCSetType( 3 )
				Endif
				
				RpcSetEnv ( cEmp, cFil,,,,, {	"SRA",;
												"RBC",;
												"SRW",;
												"SR6",;
												"SR8",;
												"SP1",;
												"SP2",;
												"SP3",;
												"SP4",;
												"SP6",;
												"SP9",;
												"SPA",;
												"SPJ",;
												"SPK",;
												"SRF",;
												"SRS",;
												"SI3",;
												"SR1",;
												"SRV",;
												"SRI",;
												"SRJ",;
												"SRX",;
												"SR6",;
												"SPI",;
												"SYP"},, .T. )			
				
				RPCClearEmp()
	
				__cTcfDefEmp	:= cEmp
				__cTcfDefFil	:= cFil
				
				//Preparar apenas um ambiente, após a confirma do usuario
				//preparar o ambiente que usuario ira utilizar
				nLoop := nLoops
	
			EndIF
		
		Next nLoop
	
	EndIf

Return (lRet)
