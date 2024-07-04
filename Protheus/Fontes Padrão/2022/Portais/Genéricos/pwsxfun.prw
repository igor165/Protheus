#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSXFUN.CH"
#INCLUDE "fwlibversion.ch"
#INCLUDE "TBICONN.CH"

#DEFINE TAMCAMPO 		20
#DEFINE TAMMAX 			72
#DEFINE TAMMIN 			20
#DEFINE  CRLF			Chr( 13 )
#DEFINE  LF				Chr( 10 )

#DEFINE  HTML_LF		"<br>"

//#DEFINE _PORTAL_DEBUG

STATIC aEstilo := {}
Static cAuthWS := Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGridHeaderบAutor  ณLuiz Felipe Couto    บ Data ณ  10/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para trazer o nome dos campos do Header              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1: Array para disponibilizacao HTML                     บฑฑ
ฑฑบ          ณ ExpA2: Header                                               บฑฑ
ฑฑบ          ณ ExpA3: Campos a serem mostrados                             บฑฑ
ฑฑบ          ณ ExpO4: Objeto com os campos de usuario                      บฑฑ
ฑฑบ          ณ ExpC5: Nome do WS para controle dos campos do usuario       บฑฑ
ฑฑบ          ณ ExpC6: Alias da tabela para controle dos campos do usuario  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GridHeader( aGrid	, aHeader, aWebCols, oUserField,;
					cNomeWS	, cAlias  )

Local nI			:= 0
Local nC			:= 0
Local nJ			:= 0
Local nPosHeader	:= 0
Local nTam			:= 0
Local aRetorno 		:= {}
Local aTmpUsrFld 	:= {}
Local oObj

DEFAULT cNomeWS 	:= "MTCUSTOMERSALESORDER"
DEFAULT cAlias 		:= "SC6"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL( @oObj, "CFGDICTIONARY.APW" )

If oUserField <> NIL
	If ValType( oUserField ) == "A"
		For nI := 1 To Len( oUserField )
			aProp := ClassDataArr( oUserField[nI] )
			nPos := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
			
			If nPos > 0
				If Type( "aProp[nPos][2]:oWSUSERFIELD" ) <> "U"
					For nJ := 1 To Len( aProp[nPos][2]:oWSUSERFIELD )
						If nJ == 1
							AAdd( aTmpUsrFld, {} )
							nTam := Len( aTmpUsrFld )
						Endif
						
						AAdd( aTmpUsrFld[nTam], aProp[nPos][2]:oWSUSERFIELD[nJ] )
					Next nJ
				Else
					oObj:cUSERCODE 	:= GetUsrCode()
					oObj:cALIAS		:= cAlias
					
					//cUSERCODE,cALIAS
					If oObj:GETUSERFIELD()
						aProp[nPos][2] := &( cNomeWS + "_ARRAYOFUSERFIELD():New()" )
						For nC := 1 To Len( oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
							If nC == 1
								AAdd( aTmpUsrFld, {} )
								nTam := Len( aTmpUsrFld )
							Endif
	
							AAdd( aProp[nPos][2]:oWSUSERFIELD, &( cNomeWS + "_USERFIELD():New()" ) )
							
							aProp[nPos][2]:oWSUSERFIELD[nC]:nUSERDEC		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nC]:nUSERDEC
							aProp[nPos][2]:oWSUSERFIELD[nC]:cUSERNAME		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nC]:cUSERNAME
							aProp[nPos][2]:oWSUSERFIELD[nC]:lUSEROBLIG		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nC]:lUSEROBLIG
							aProp[nPos][2]:oWSUSERFIELD[nC]:cUSERPICTURE	:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nC]:cUSERPICTURE
							aProp[nPos][2]:oWSUSERFIELD[nC]:nUSERSIZE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nC]:nUSERSIZE
							aProp[nPos][2]:oWSUSERFIELD[nC]:cUSERTAG		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nC]:cUSERTAG
							aProp[nPos][2]:oWSUSERFIELD[nC]:cUSERTITLE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nC]:cUSERTITLE
							aProp[nPos][2]:oWSUSERFIELD[nC]:cUSERTYPE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nC]:cUSERTYPE
							aProp[nPos][2]:oWSUSERFIELD[nC]:cUSERCOMBOBOX	:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nC]:cUSERCOMBOBOX
							
							AAdd( aTmpUsrFld[nTam], aProp[nPos][2]:oWSUSERFIELD[nC] )
						Next nC
					Endif
				Endif
			Endif
		Next nI
	Else
		aProp := ClassDataArr( oUserField )
		nPos := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
		
		If nPos > 0
			If Type( "aProp[nPos][2]:oWSUSERFIELD" ) <> "U"
				For nI := 1 To Len( aProp[nPos][2]:oWSUSERFIELD )
					If nI == 1
						AAdd( aTmpUsrFld, {} )
						nTam := Len( aTmpUsrFld )
					Endif

					AAdd( aTmpUsrFld[nTam], aProp[nPos][2]:oWSUSERFIELD[nI] )
				Next nI
			Else
				oObj:cUSERCODE 	:= GetUsrCode()
				oObj:cALIAS		:= cAlias
				
				//cUSERCODE,cALIAS
				If oObj:GETUSERFIELD()
					aProp[nPos][2] := &( cNomeWS + "_ARRAYOFUSERFIELD():New()" )
					
					For nI := 1 To Len( oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
						If nI == 1
							AAdd( aTmpUsrFld, {} )
							nTam := Len( aTmpUsrFld )
						Endif

						AAdd( aProp[nPos][2]:oWSUSERFIELD, &( cNomeWS + "_USERFIELD():New()" ) )
						
						aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERDEC		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERDEC
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERNAME		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERNAME
						aProp[nPos][2]:oWSUSERFIELD[nI]:lUSEROBLIG		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:lUSEROBLIG
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERPICTURE	:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERPICTURE
						aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERSIZE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERSIZE
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTAG		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTAG
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTITLE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTITLE
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTYPE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTYPE
						
						AAdd( aTmpUsrFld[nTam], aProp[nPos][2]:oWSUSERFIELD[nI] )
					Next nI
				Endif
			Endif
		Endif
	Endif
Endif

aWebCols := MntWebCols( aWebCols, aHeader, aTmpUsrFld )

nTam := Len( aWebCols )

For nI := 1 To nTam
	If ValType( aWebCols[nI] ) == "A"
		nPosHeader := ascan( aHeader, { |x| x:cHEADERFIELD == aWebCols[nI][1] } )
	Else
		nPosHeader := ascan( aHeader, { |x| x:cHEADERFIELD == aWebCols[nI] } )
	Endif

	If nPosHeader > 0
		AAdd( aRetorno, HtmlNoTags( aHeader[nPosHeader]:cHEADERTITLE)) 
	Else
		If Len( aTmpUsrFld ) > 0
			For nJ := 1 To Len( aTmpUsrFld )
				If ValType( aWebCols[nI] ) == "A"
					nPosHeader := aScan( aTmpUsrFld[nJ], { |x| AllTrim( x:cUSERNAME ) == AllTrim( aWebCols[nI][1] ) } )
				Else
					nPosHeader := aScan( aTmpUsrFld[nJ], { |x| AllTrim( x:cUSERNAME ) == AllTrim( aWebCols[nI] ) } )
				Endif
		
				If nPosHeader > 0
					nPosRetorno := aScan( aRetorno, { |x| x == HtmlNoTags( aTmpUsrFld[nJ][nPosHeader]:cUSERTITLE ) } )
					
					If nPosRetorno == 0
						AAdd( aRetorno, HtmlNoTags( aTmpUsrFld[nJ][nPosHeader]:cUSERTITLE ) )
					Endif
				Endif
			Next nJ
		Endif
	Endif
Next

AAdd( aGrid, aRetorno )

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGridLinesEบAutor  ณLuiz Felipe Couto    บ Data ณ  15/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para criacao dos campos dinamicamente                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: [1] Array para disponibilizacao HTML                  บฑฑ
ฑฑบ          ณ       [2] Header                                            บฑฑ
ฑฑบ          ณ       [3] Valores a serem mostrados                         บฑฑ
ฑฑบ          ณ       [4] Campos a serem mostrados                          บฑฑ
ฑฑบ          ณ       [5] Campo para inclusao ou visualizacao               บฑฑ
ฑฑบ          ณ           .T. - inclusao                                    บฑฑ
ฑฑบ          ณ           .F. - visualizacao                                บฑฑ
ฑฑบ          ณ       [6] Html ou Array                                     บฑฑ
ฑฑบ          ณ           H - Html                                          บฑฑ
ฑฑบ          ณ           A - Array                                         บฑฑ
ฑฑบ          ณ       [7] Sufixo para diferenciacao                         บฑฑ
ฑฑบ          ณ       [8] Parametro para uso do objeto javascript           บฑฑ
ฑฑบ          ณ       [9] Parametro para utilizar a gridlines em uma linha  บฑฑ
ฑฑบ          ณExpA2: [1] Cor fundo tabela                                  บฑฑ
ฑฑบ          ณ       [2] Estilo fonte ( inclusao / alteracao )             บฑฑ
ฑฑบ          ณ       [3] Estilo fonte obrigatorio                          บฑฑ
ฑฑบ          ณ       [4] estilo fonte visualizacao                         บฑฑ
ฑฑบ          ณ       [5] estilo texto                                      บฑฑ
ฑฑบ          ณ       [6] estilo select                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCleber M. ณ11/09/06|104540|Tratamento para evitar "Array out of bounds" บฑฑ
ฑฑบ          ณ        ณ      ณno uso do aTmpUsrFld.                        บฑฑ
ฑฑบCleber M. ณ11/09/06|104546|Protecao no fonte para evitar erros de posi- บฑฑ
ฑฑบ          ณ        ณ      ณcoes de array nao existentes.                บฑฑ
ฑฑบTatiana C.ณ09/02/07|118306|Tratamento para permitir a inclusao de campo บฑฑ
ฑฑบ          ณ        ณ      ณMemo por usuแrio.                            บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GridLinesEx( aDados, cNomeWS, cAlias )

Local cPicture  	:= ""
Local xValor		:= ""
Local cHtml 		:= ''
Local cInpTemp 		:= ""
Local nX 			:= 0
Local nY 			:= 0
Local nI			:= 0
Local nJ			:= 0
Local nH			:= 0
Local nTamValores	:= 0
Local nTamHeader	:= 0
Local nPosH			:= 0
Local nPosPos		:= 0
Local aRetorno 		:= {}
Local aWebHeader 	:= {}
Local aTmpUsrFld	:= {}
Local aHeaderTemp	:= {}
Local aPropObj		:= {}
Local oObj
Local lUserField	:= .F.
Local cLanguage		:= ""
Local cIdiom		:= FWRetIdiom()        //Retorna Idioma Atual

PRIVATE __oObjeto
PRIVATE aProp		:= {}

DEFAULT aDados[5] 	:= .F.
DEFAULT aDados[8] 	:= 0	// Parametro para entrada, meio e saida do script de validacao dos formularios
						    // 0 - Default
						    // 1 - Entrada
						    // 2 - Meio
						    // 3 - Saida
DEFAULT cNomeWS		:= ""
DEFAULT cAlias		:= ""

// Session para armazenar a CriaObj
If aDados[8] == 0 .OR. aDados[8] == 1
	HttpSession->_TMPJS := '<script language="JavaScript">' + CRLF
	HttpSession->_TMPJS += 'var oForm = new Form(document.forms[0]);' + CRLF
Endif

If cIdiom == 'en' 
	cLanguage := 'ENGLISH'
ElseIf cIdiom == 'es'
	cLanguage := 'SPANISH'
Else
	cLanguage := 'PORTUGUESE'
EndIf


if !empty( GETPVPROFSTRING(GetEnvServer(),"PictFormat","",GetADV97()) )
	HttpSession->_TMPJS += "defineLanguage('" + cLanguage + "');"
endif
	
If aDados[6] == "H" .AND. !Empty( aDados[1] ) .AND. Len( aDados ) == 8
	conout( "Para o retorno em HTML nใo utilize a fun็ใo GridHeader." )
	aDados[1] := {}
	
	Return
Endif

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL( @oObj, "CFGDICTIONARY.APW" )

If ValType( aDados[3] ) == "A"
	For nI := 1 To Len( aDados[3] )
		aProp := ClassDataArr( aDados[3][nI] )
		
		nPos := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
		
		If nPos > 0
			If Type( "aProp[nPos][2]:oWSUSERFIELD" ) <> "U"
				For nJ := 1 To Len( aProp[nPos][2]:oWSUSERFIELD )
					If nJ == 1
						AAdd( aTmpUsrFld, {} )
						nTam := Len( aTmpUsrFld )
					Endif
					
					AAdd( aTmpUsrFld[nTam], aProp[nPos][2]:oWSUSERFIELD[nJ] )
				Next nJ
			Else
				oObj:cUSERCODE 	:= GetUsrCode()
				oObj:cALIAS		:= cAlias
				
				//cUSERCODE,cALIAS
				If oObj:GETUSERFIELD()
					aProp[nPos][2] := &( cNomeWS + "_ARRAYOFUSERFIELD():New()" )
					
					For nI := 1 To Len( oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
						If nI == 1
							AAdd( aTmpUsrFld, {} )
							nTam := Len( aTmpUsrFld )
						Endif

						AAdd( aProp[nPos][2]:oWSUSERFIELD, &( cNomeWS + "_USERFIELD():New()" ) )
						
						aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERDEC		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERDEC
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERNAME		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERNAME
						aProp[nPos][2]:oWSUSERFIELD[nI]:lUSEROBLIG		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:lUSEROBLIG
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERPICTURE	:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERPICTURE
						aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERSIZE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERSIZE
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTAG		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTAG
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTITLE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTITLE
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTYPE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTYPE
						aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERCOMBOBOX	:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERCOMBOBOX
						
						AAdd( aTmpUsrFld[nTam], aProp[nPos][2]:oWSUSERFIELD[nI] )
					Next nI
				Endif
			Endif
		Endif
	Next nI
Else
	aProp := ClassDataArr( aDados[3] )
	
	nPos := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	
	If nPos > 0
		If Type( "aProp[nPos][2]:oWSUSERFIELD" ) <> "U"
			For nI := 1 To Len( aProp[nPos][2]:oWSUSERFIELD )
				If nI == 1
					AAdd( aTmpUsrFld, {} )
					nTam := Len( aTmpUsrFld )
				Endif
				
				AAdd( aTmpUsrFld[nTam], aProp[nPos][2]:oWSUSERFIELD[nI] )
			Next nI
		Else
			oObj:cUSERCODE 	:= GetUsrCode()
			oObj:cALIAS		:= cAlias
			
			//cUSERCODE,cALIAS
			If oObj:GETUSERFIELD()
				aProp[nPos][2] := &( cNomeWS + "_ARRAYOFUSERFIELD():New()" )
				
				For nI := 1 To Len( oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
					If nI == 1
						AAdd( aTmpUsrFld, {} )
						nTam := Len( aTmpUsrFld )
					Endif

					AAdd( aProp[nPos][2]:oWSUSERFIELD, &( cNomeWS + "_USERFIELD():New()" ) )
					
					aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERDEC		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERDEC
					aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERNAME		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERNAME
					aProp[nPos][2]:oWSUSERFIELD[nI]:lUSEROBLIG		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:lUSEROBLIG
					aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERPICTURE	:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERPICTURE
					aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERSIZE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERSIZE
					aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTAG		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTAG
					aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTITLE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTITLE
					aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTYPE		:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTYPE
					aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERCOMBOBOX	:= oObj:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERCOMBOBOX
					
					AAdd( aTmpUsrFld[nTam], aProp[nPos][2]:oWSUSERFIELD[nI] )
				Next nI
			Endif
		Endif
	Endif
Endif

For nI := 1 To Len( aDados[2] )
	AAdd( aHeaderTemp, aDados[2][nI]:Clone() )
Next nI

aDados[4] := MntWebCols( aDados[4], aHeaderTemp, aTmpUsrFld )
aDados[4] := ParseWebCols( aDados[4], aDados[7] )

PutHeadUsrFld( aDados[2], aTmpUsrFld, aDados[4], cNomeWS )

aHeaderTemp := {}

For nI := 1 To Len( aDados[2] )
	AAdd( aHeaderTemp, aDados[2][nI]:Clone() )
Next nI

nTamHeader := Len( aHeaderTemp )

For nY := 1 To Len( aDados[4] )
	nPosH := ascan( aHeaderTemp, { |x| AllTrim( x:cHEADERFIELD ) == AllTrim( aDados[4][nY][1] ) } )

	If nPosH > 0
		AAdd( aWebHeader, nPosH )
	Else
		nPosH := ascan( aHeaderTemp, { |x| AllTrim( SubStr( x:cHEADERFIELD, 2 ) ) == AllTrim( aDados[4][nY][1] ) } )
			
		If nPosH > 0
			AAdd( aWebHeader, nPosH )
		Endif
	Endif
Next nY

nTamHeader := Len( aWebHeader )

#IFDEF _PORTAL_DEBUG
	conout("****************************************")
	conout("** SISTEMA RODANDO EM VERSAO DEUGB!!! **")
	conout("****************************************")
	ApWExAddErr( "HEADER", varinfo( "", aHeaderTemp, , .F., .F. ) )
	ApWExAddErr( "OBJETO", varinfo( "", aDados[3], , .F., .F. ) )
#Endif

If Len( aDados ) > 8
	If aDados[9]
		If ValType( aDados[3] ) == "O"
			aPropObj := ClassDataArr( aDados[3] )
			AAdd( aDados[1], {} )
			aRetorno := {}
			__oObjeto  := aDados[3]
	
			For nY := 1 To nTamHeader
				nH 			:= aWebHeader[nY]
				cPicture 	:= AllTrim( aHeaderTemp[nH]:cHEADERPICTURE )

				If aHeaderTemp[nH]:cHEADERTYPE == "M"
					cHeaderType := "C"
				Else
					cHeaderType := aHeaderTemp[nH]:cHEADERTYPE
				Endif

				nPosProp := aScan( aPropObj, { |x| AllTrim( x[1] ) == Upper( cHeaderType + aHeaderTemp[nH]:cHEADERFIELD ) } )
		
				If nPosProp > 0
					xValor := "__oObjeto:" + IIF( aHeaderTemp[nH]:cHEADERTYPE == "M", "C", aHeaderTemp[nH]:cHEADERTYPE ) + aHeaderTemp[nH]:cHEADERFIELD
					xValor := &xValor
					
					If Empty( xValor )
						xValor := ""
	
						If aHeaderTemp[nH]:cHEADERTYPE == "N"
							xValor := Val( xValor )
						ElseIf aHeaderTemp[nH]:cHEADERTYPE == "D"
							xValor := CToD( xValor )
						Endif
					Endif
					
					lUserField 	:= .F.
				Else
					If Len(aTmpUsrFld) > 0
						nPosUsrFld := aScan( aTmpUsrFld[1], { |x| AllTrim( x:cUSERNAME ) == SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) } )
					Else
					  	nPosUsrFld := 0
					EndIf
					
					If nPosUsrFld > 0
						cPicture := AllTrim( aTmpUsrFld[1][nPosUsrFld]:cUSERPICTURE )
						
						If aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "C"
							xValor := aTmpUsrFld[1][nPosUsrFld]:cUSERTAG 
						ElseIf aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "M"
							xValor := aTmpUsrFld[1][nPosUsrFld]:cUSERTAG							
						ElseIf aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "N"
							xValor := aTmpUsrFld[1][nPosUsrFld]:cUSERTAG
							xValor := Replace(xValor,",",".")
							xValor := Val( xValor )
						ElseIf aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "D"
							
						if empty(CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG ))
							xValor := SToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
						else
							xValor := CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
						endif						
						Endif
						
						lUserField := .T.
					Endif
				Endif

				nPos := aScan( aDados[4], { |x| x[1] == aHeaderTemp[nH]:cHEADERFIELD } )
	
				If nPos == 0
					nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) ) } )
				Endif
				
				If nPos > 0
					If aDados[6] == "H"
						If aDados[5] .AND. aDados[4][nPos][5]
							If Empty( aHeaderTemp[nH]:CHEADERCOMBOBOX )
								cInpTemp := PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], lUserField, aDados[5])
							Else
								cInpTemp := PWSHtmCoEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], aHeaderTemp[nH]:CHEADERCOMBOBOX, lUserField,aDados[5] )
							Endif

							AAdd( aDados[1][Len( aDados[1] )], cInpTemp )
						Else
							cInpTemp := '<input type="hidden" name="' + aHeaderTemp[nH]:cHEADERTYPE + aHeaderTemp[nH]:cHEADERFIELD + IIF( !Empty( aDados[7] ), "_" + aDados[7], "" ) + '_H" value="' + IIF( Empty( xValor ), "", PWSXTransform( xValor, cPicture, .T. ) ) + '">'

							AAdd( aDados[1][Len( aDados[1] )], IIF( Empty( xValor ), "&nbsp;", PWSXTransform( xValor, cPicture ) + cInpTemp ) )
						Endif
					Endif
				Endif
			Next nY
		Else
			nTamValores := Len( aDados[3] )
		
			For nX := 1 To nTamValores
				aPropObj := ClassDataArr( aDados[3][nX] )
				AAdd( aDados[1], {} )
				aRetorno := {}
				__oObjeto  := aDados[3][nX]
		
				For nY := 1 To nTamHeader
					nH 			:= aWebHeader[nY]
					cPicture 	:= AllTrim( aHeaderTemp[nH]:cHEADERPICTURE )

					If aHeaderTemp[nH]:cHEADERTYPE == "M"
						cHeaderType := "C"
					Else
						cHeaderType := aHeaderTemp[nH]:cHEADERTYPE
					Endif

					nPosProp := aScan( aPropObj, { |x| AllTrim( x[1] ) == Upper( cHeaderType + aHeaderTemp[nH]:cHEADERFIELD ) } )
			
					If nPosProp > 0
						xValor := "__oObjeto:" + IIF( aHeaderTemp[nH]:cHEADERTYPE == "M", "C", aHeaderTemp[nH]:cHEADERTYPE ) + aHeaderTemp[nH]:cHEADERFIELD
						xValor := &xValor

						If Empty( xValor )
							xValor := ""
		
							If aHeaderTemp[nH]:cHEADERTYPE == "N"
								xValor := Val( xValor )
							ElseIf aHeaderTemp[nH]:cHEADERTYPE == "D"
								xValor := CToD( xValor )
							Endif
						Endif

						lUserField := .F.
					Else
						If nX <= Len(aTmpUsrFld)
							nPosUsrFld := aScan( aTmpUsrFld[nX], { |x| AllTrim( x:cUSERNAME ) == SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) } )
						Else
							nPosUsrFld := 0
						EndIf
						
						If nPosUsrFld > 0
							cPicture := AllTrim( aTmpUsrFld[nX][nPosUsrFld]:cUSERPICTURE )
							
							If aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "C"
								xValor := aTmpUsrFld[nX][nPosUsrFld]:cUSERTAG 
							ElseIf aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "M"
								xValor := aTmpUsrFld[nX][nPosUsrFld]:cUSERTAG								
							ElseIf aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "N"
								xValor := aTmpUsrFld[nX][nPosUsrFld]:cUSERTAG
								xValor := Replace(xValor,",",".")
								xValor := Val( xValor )
							ElseIf aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "D"
								if empty(CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG ))
									xValor := SToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
								else
									xValor := CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
								endif
								
							Endif

							lUserField := .T.
						Endif
					Endif

					nPos := aScan( aDados[4], { |x| x[1] == aHeaderTemp[nH]:cHEADERFIELD } )
		
					If nPos == 0
						nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) ) } )
					Endif
					
					If nPos > 0
						If aDados[6] == "H"
							If aDados[5] .AND. aDados[4][nPos][5]
								If Empty( aHeaderTemp[nH]:CHEADERCOMBOBOX )
									cInpTemp := PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], lUserField, aDados[5] )
								Else
									cInpTemp := PWSHtmCoEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], aHeaderTemp[nH]:CHEADERCOMBOBOX, lUserField,aDados[5] )
								Endif
		
								AAdd( aDados[1][Len( aDados[1] )], cInpTemp )
							Else
								AAdd( aDados[1][Len( aDados[1] )], IIF( Empty( xValor ), "&nbsp;", PWSXTransform( xValor, cPicture ) ) )
	
							Endif
						Endif
					Endif
				Next nY
			Next nX
		Endif
	Endif
Else
	// Alimenta demais linhas com os dados formatados para WEB
	If ValType( aDados[3] ) == "O"
		aPropObj := ClassDataArr( aDados[3] )
		aRetorno := {}
		__oObjeto  := aDados[3]
	
		cHtml += '<table width="650" border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="' + aEstilo[1] + '" bgcolor="' + aEstilo[1] + '" id="TABCAB">' +;
					'<tr>' +;
					'<td bordercolor="#FFFFFF" class="titulo">' +;
					'<table width="100%" border="0" cellspacing="0" cellpadding="0">' +;
					'<tr><td colspan="5">&nbsp</td></tr>'
					
		For nY := 1 To nTamHeader
			nH 			:= aWebHeader[nY]
			cPicture 	:= AllTrim( aHeaderTemp[nH]:cHEADERPICTURE )
			
			If aHeaderTemp[nH]:cHEADERTYPE == "M"
				cHeaderType := "C"
			Else
				cHeaderType := aHeaderTemp[nH]:cHEADERTYPE
			Endif
			
			nPosProp := aScan( aPropObj, { |x| AllTrim( x[1] ) == Upper( cHeaderType + aHeaderTemp[nH]:cHEADERFIELD ) } )
	
			If nPosProp > 0
				xValor := "__oObjeto:" + IIF( aHeaderTemp[nH]:cHEADERTYPE == "M", "C", aHeaderTemp[nH]:cHEADERTYPE ) + aHeaderTemp[nH]:cHEADERFIELD
				xValor := &xValor

				If Empty( xValor )
					xValor := ""

					If aHeaderTemp[nH]:cHEADERTYPE == "N"
						xValor := Val( xValor )
					ElseIf aHeaderTemp[nH]:cHEADERTYPE == "D"
						xValor := CToD( xValor )
					Endif
				Endif

				lUserField := .F.
			Else
				If Len(aTmpUsrFld) > 0
					nPosUsrFld := aScan( aTmpUsrFld[1], { |x| AllTrim( x:cUSERNAME ) == SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) } )
				Else
					nPosUsrFld := 0
				EndIf
				
				If nPosUsrFld > 0
					cPicture := AllTrim( aTmpUsrFld[1][nPosUsrFld]:cUSERPICTURE )
					
					If aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "C" .OR. ;
						aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "M"
						xValor := aTmpUsrFld[1][nPosUsrFld]:cUSERTAG
					ElseIf aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "N"
						xValor := aTmpUsrFld[1][nPosUsrFld]:cUSERTAG
						xValor := Replace(xValor,",",".")
						xValor := Val( xValor )
					ElseIf aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "D"
						if empty(CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG ))
							xValor := SToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
						else
							xValor := CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
						endif
					Endif

					lUserField := .T.
				Endif
			Endif
	
			nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( aHeaderTemp[nH]:cHEADERFIELD ) } )
			
			If nPos == 0
				nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) ) } )
			Endif
			
			If nPos > 0
				If aDados[6] == "H"
					nH 			:= aWebHeader[nY]
					cPicture 	:= AllTrim( aHeaderTemp[nH]:cHEADERPICTURE )
		
					If aHeaderTemp[nH]:cHEADERTYPE == "M"
						cHeaderType := "C"
					Else
						cHeaderType := aHeaderTemp[nH]:cHEADERTYPE
					Endif

					nPosProp := aScan( aPropObj, { |x| AllTrim( x[1] ) == Upper( cHeaderType + aHeaderTemp[nH]:cHEADERFIELD ) } )
		
					If nPosProp > 0
						xValor := "__oObjeto:" + IIF( aHeaderTemp[nH]:cHEADERTYPE == "M", "C", aHeaderTemp[nH]:cHEADERTYPE ) + aHeaderTemp[nH]:cHEADERFIELD
						xValor := &xValor

						If Empty( xValor )
							xValor := ""
		
							If aHeaderTemp[nH]:cHEADERTYPE == "N"
								xValor := Val( xValor )
							ElseIf aHeaderTemp[nH]:cHEADERTYPE == "D"
								xValor := CToD( xValor )
							Endif
						Endif

						lUserField := .F.
					Else
						If Len(aTmpUsrFld) > 0
							nPosUsrFld := aScan( aTmpUsrFld[1], { |x| AllTrim( x:cUSERNAME ) == SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) } )
						Else
							nPosUsrFld := 0
						EndIf
						
						If nPosUsrFld > 0
							cPicture := AllTrim( aTmpUsrFld[1][nPosUsrFld]:cUSERPICTURE )
							
							If aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "C" .OR.;
								aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "M"
								xValor := aTmpUsrFld[1][nPosUsrFld]:cUSERTAG
							ElseIf aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "N"
								xValor := aTmpUsrFld[1][nPosUsrFld]:cUSERTAG
								xValor := Replace(xValor,",",".")
								xValor := Val( xValor )
							ElseIf aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "D"
								if empty(CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG ))
									xValor := SToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
								else
									xValor := CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
								endif
							Endif

							lUserField := .T.
						Endif
					Endif
		
					nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( aHeaderTemp[nH]:cHEADERFIELD ) } )
					
					If nPos == 0
						nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) ) } )
					Endif
					
					If nPos > 0
						If aHeaderTemp[nH]:nHEADERSIZE > TAMCAMPO
							cHtml += '<tr>' +;
										'<td>&nbsp;&nbsp;&nbsp;</td>' +;
										'<td valign="middle" class="' + IIF( aHeaderTemp[nH]:lHEADEROBLIG, aEstilo[3], aEstilo[2] ) + '">' + aHeaderTemp[nH]:cHEADERTITLE + '</td>'
							
							If Empty( aHeaderTemp[nH]:CHEADERCOMBOBOX )
								cInpTemp := PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], lUserField,aDados[5] )
							Else
								cInpTemp := PWSHtmCoEx( aHeaderTemp[nH], xValor, aDados[7], aDados[4][nPos], aHeaderTemp[nH]:CHEADERCOMBOBOX, lUserField,aDados[5] )
							Endif
							cHtml += '<td valign="middle" colspan="3">' + cInpTemp + '</td>'
							cHtml += '</tr>'
						Else
							cHtml += '<tr>' +;
										'<td>&nbsp;&nbsp;&nbsp;</td>' +;
										'<td valign="middle" class="' + IIF( aHeaderTemp[nH]:lHEADEROBLIG, aEstilo[3], aEstilo[2] ) + '">' + aHeaderTemp[nH]:cHEADERTITLE + '</td>'
							
							If Empty( aHeaderTemp[nH]:CHEADERCOMBOBOX )
								cInpTemp := PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], lUserField,aDados[5] )
							Else
								cInpTemp := PWSHtmCoEx( aHeaderTemp[nH], xValor, aDados[7], aDados[4][nPos], aHeaderTemp[nH]:CHEADERCOMBOBOX, lUserField,aDados[5] )
							Endif
							cHtml += '<td valign="middle">' + cInpTemp + '</td>'
							
							If (nY++) < nTamHEader
								nH 			:= aWebHeader[nY]
								cPicture 	:= AllTrim( aHeaderTemp[nH]:cHEADERPICTURE )
					
								If aHeaderTemp[nH]:cHEADERTYPE == "M"
									cHeaderType := "C"
								Else
									cHeaderType := aHeaderTemp[nH]:cHEADERTYPE
								Endif

								nPosProp := aScan( aPropObj, { |x| AllTrim( x[1] ) == Upper( cHeaderType + aHeaderTemp[nH]:cHEADERFIELD ) } )
			
								If nPosProp > 0
									xValor := "__oObjeto:" + IIF( aHeaderTemp[nH]:cHEADERTYPE == "M", "C", aHeaderTemp[nH]:cHEADERTYPE ) + aHeaderTemp[nH]:cHEADERFIELD
									xValor := &xValor

									If Empty( xValor )
										xValor := ""
					
										If aHeaderTemp[nH]:cHEADERTYPE == "N"
											xValor := Val( xValor )
										ElseIf aHeaderTemp[nH]:cHEADERTYPE == "D"
											xValor := CToD( xValor )
										Endif
									Endif

									lUserField := .F.
								Else
									If Len(aTmpUsrFld) > 0
										nPosUsrFld := aScan( aTmpUsrFld[1], { |x| AllTrim( x:cUSERNAME ) == SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) } )
									Else
										nPosUsrFld := 0	
									EndIf
									
									If nPosUsrFld > 0
										cPicture := AllTrim( aTmpUsrFld[1][nPosUsrFld]:cUSERPICTURE )
										
										If aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "C" .OR.;
											aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "M"
											xValor := aTmpUsrFld[1][nPosUsrFld]:cUSERTAG
										ElseIf aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "N"
											xValor := aTmpUsrFld[1][nPosUsrFld]:cUSERTAG
											xValor := Replace(xValor,",",".")
											xValor := Val( xValor )
										ElseIf aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "D"
											if empty(CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG ))
												xValor := SToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
											else
												xValor := CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
											endif
										Endif

										lUserField := .T.
									Endif
								Endif
					
								nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( aHeaderTemp[nH]:cHEADERFIELD ) } )
								
								If nPos == 0
									nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) ) } )
								Endif
			
								If aHeaderTemp[nH]:nHEADERSIZE > TAMCAMPO
									cHtml += '<tr>' +;
												'<td>&nbsp;&nbsp;&nbsp;</td>' +;
												'<td valign="middle" class="' + IIF( aHeaderTemp[nH]:lHEADEROBLIG, aEstilo[3], aEstilo[2] ) + '">' + aHeaderTemp[nH]:cHEADERTITLE + '</td>'
									
									If Empty( aHeaderTemp[nH]:CHEADERCOMBOBOX )
										cInpTemp := PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], lUserField,aDados[5] )
									Else
										cInpTemp := PWSHtmCoEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], aHeaderTemp[nH]:CHEADERCOMBOBOX, lUserField,aDados[5] )
									Endif
									cHtml += '<td valign="middle" colspan="3">' + cInpTemp + '</td>'
									cHtml += '</tr>'
									
									Loop
								Else
									cHtml += '<td valign="middle" class="' + IIF( aHeaderTemp[nH]:lHEADEROBLIG, aEstilo[3], aEstilo[2] ) + '">' + aHeaderTemp[nH]:cHEADERTITLE + '</td>'
									
									If Empty( aHeaderTemp[nH]:CHEADERCOMBOBOX )
										cInpTemp := PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], lUserField,aDados[5] )
									Else
										cInpTemp := PWSHtmCoEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos], aHeaderTemp[nH]:CHEADERCOMBOBOX, lUserField,aDados[5] )
									Endif
									cHtml += '<td valign="middle">' + cInpTemp + '</td>'
									cHtml += '</tr>'
								Endif
							Else
								cHtml += '<td>&nbsp;&nbsp;&nbsp;</td>' +;
											'<td>&nbsp;&nbsp;&nbsp;</td>' +;
											'</tr>'
							Endif
						Endif
					Endif
				Else
					If aDados[5]
						nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( aHeaderTemp[nH]:cHEADERFIELD ) } )
						
						If nPos == 0
							nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) ) } )
						Endif
		
						If nPos > 0
							AAdd( aRetorno, PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos],,aDados[5] ) )
						Endif
					Else
						AAdd( aRetorno, PWSXTransform( xValor, cPicture, , .t. ) )
					Endif
				Endif
			Endif
		Next nX
	
		cHtml += '<tr><td colspan="5">&nbsp;</td></tr>' +;
					'</table></td>' +;
					'</tr>' +;
					'</table>'
					
		If aDados[6] == "H"
			AAdd( aDados[1], cHtml )
		Else
			AAdd( aDados[1], aRetorno )
		Endif
	ElseIf ValType( aDados[3] ) == "A"
	    nTamValores := Len( aDados[3] )
	
		cHtml += '<table width="535" border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="' + aEstilo[1] + '" bgcolor="' + aEstilo[1] + '" id="TABCAB">' +;
					'<tr>' +;
					'<td bordercolor="#FFFFFF" class="titulo">' +;
					'<table width="100%" border="0" cellspacing="0" cellpadding="0">' +;
					'<tr><td colspan="5">&nbsp;</td></tr>'
					
		For nX := 1 To nTamValores
 			aPropObj := ClassDataArr( aDados[3][nX] )
			aRetorno := {}
			__oObjeto  := aDados[3][nX]
			
			For nY := 1 To nTamHeader
				nH 			:= aWebHeader[nY]
				cPicture 	:= AllTrim( aHeaderTemp[nH]:cHEADERPICTURE )
				
				nPosProp := aScan( aPropObj, { |x| AllTrim( x[1] ) == Upper( aHeaderTemp[nH]:cHEADERTYPE + aHeaderTemp[nH]:cHEADERFIELD ) } )
				
				If nPosProp > 0
					xValor := "__oObjeto:" + IIF( aHeaderTemp[nH]:cHEADERTYPE == "M", "C", aHeaderTemp[nH]:cHEADERTYPE ) + aHeaderTemp[nH]:cHEADERFIELD
					xValor := &xValor
	 				
					If Empty( xValor )
						xValor := ""
	
						If aHeaderTemp[nH]:cHEADERTYPE == "N"
							xValor := Val( xValor )
						ElseIf aHeaderTemp[nH]:cHEADERTYPE == "D"
							xValor := CToD( xValor )
						Endif
					Endif

					lUserField := .F.
				Else
					If nX <= Len(aTmpUsrFld)
						nPosUsrFld := aScan( aTmpUsrFld[nX], { |x| AllTrim( x:cUSERNAME ) == SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) } )
					Else
						nPosUsrFld := 0
					EndIf
					If nPosUsrFld > 0
						cPicture := AllTrim( aTmpUsrFld[nX][nPosUsrFld]:cUSERPICTURE )
						
						If aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "C" .OR.;
							aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "M"
							xValor := aTmpUsrFld[nX][nPosUsrFld]:cUSERTAG
						ElseIf aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "N"
							xValor := aTmpUsrFld[nX][nPosUsrFld]:cUSERTAG
							xValor := Replace(xValor,",",".")
							xValor := Val( xValor )	
						ElseIf aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "D"
							if empty(CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG ))
								xValor := SToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
							else
								xValor := CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
							endif
						Endif
						
						lUserField := .T.
					Endif
				Endif
	
				nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( aHeaderTemp[nH]:cHEADERFIELD ) } )
	
				If nPos == 0
					nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) ) } )
				Endif
				
				If nPos > 0
					If aDados[6] == "H"
						If aHeaderTemp[nH]:nHEADERSIZE > TAMCAMPO
							cHtml += '<tr>' +;
										'<td>&nbsp;&nbsp;&nbsp;</td>' +;
										'<td valign="middle" class="' + aEstilo[3] + '">' + aHeaderTemp[nH]:cHEADERTITLE + '</td>'
							
							If Empty( aHeaderTemp[nH]:CHEADERCOMBOBOX )
								cInpTemp := PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos],,aDados[5] )
							Else
								cInpTemp := PWSHtmCoEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ) , aDados[7], aDados[4][nPos], aHeaderTemp[nH]:CHEADERCOMBOBOX,,aDados[5] )
							Endif
							cHtml += '<td valign="middle" colspan="3">' + cInpTemp + '</td>'
							cHtml += '</tr>'
						Else
							cHtml += '<tr>' +;
										'<td>&nbsp;&nbsp;&nbsp;</td>' +;
										'<td valign="middle" class="' + aEstilo[3] + '">' + aHeaderTemp[nH]:cHEADERTITLE + '</td>'
							
							If Empty( aHeaderTemp[nH]:CHEADERCOMBOBOX )
								cInpTemp := PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos],,aDados[5] )
							Else
								cInpTemp := PWSHtmCoEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ) , aDados[7], aDados[4][nPos], aHeaderTemp[nH]:CHEADERCOMBOBOX,,aDados[5] )
							Endif
							cHtml += '<td valign="middle">' + cInpTemp + '</td>'
							
							If (nY++) < nTamHEader
								nH 			:= aWebHeader[nY]
								cPicture 	:= AllTrim( aHeaderTemp[nH]:cHEADERPICTURE )
								nPosProp 	:= aScan( aPropObj, { |x| AllTrim( x[1] ) == Upper( aHeaderTemp[nH]:cHEADERTYPE + aHeaderTemp[nH]:cHEADERFIELD ) } )
		
								If nPosProp > 0
									xValor   := "__oObjeto:" + IIF( aHeaderTemp[nH]:cHEADERTYPE == "M", "C", aHeaderTemp[nH]:cHEADERTYPE ) + aHeaderTemp[nH]:cHEADERFIELD
									xValor   := &xValor

									If Empty( xValor )
										xValor := ""
					
										If aHeaderTemp[nH]:cHEADERTYPE == "N"
											xValor := Val( xValor )
										ElseIf aHeaderTemp[nH]:cHEADERTYPE == "D"
											xValor := CToD( xValor )
										Endif
									Endif

									lUserField := .F.
								Else
									If nX <= Len(aTmpUsrFld)
										nPosUsrFld := aScan( aTmpUsrFld[nX], { |x| AllTrim( x:cUSERNAME ) == SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) } )
									Else
										nPosUsrFld := 0
									EndIf
									
									If nPosUsrFld > 0
										cPicture := AllTrim( aTmpUsrFld[nX][nPosUsrFld]:cUSERPICTURE )
										
										If aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "C" .OR.;
											aTmpUsrFld[1][nPosUsrFld]:cUSERTYPE == "M"
											xValor := aTmpUsrFld[nX][nPosUsrFld]:cUSERTAG
										ElseIf aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "N"
											xValor := aTmpUsrFld[nX][nPosUsrFld]:cUSERTAG
											xValor := Replace(xValor,",",".")
											xValor := Val( xValor )
										ElseIf aTmpUsrFld[nX][nPosUsrFld]:cUSERTYPE == "D"
											if empty(CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG ))
												xValor := SToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
											else
												xValor := CToD( aTmpUsrFld[1][nPosUsrFld]:cUSERTAG )
											endif
										Endif
										lUserField := .T.
									Endif
								Endif
		
								nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( aHeaderTemp[nH]:cHEADERFIELD ) } )
			
								If nPos == 0
									nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( SubStr( aHeaderTemp[nH]:cHEADERFIELD, 2 ) ) } )
								Endif
								
								If nPos > 0
									cHtml += '<td valign="middle" class="' + aEstilo[3] + '">' + aHeaderTemp[nH]:cHEADERTITLE + '</td>'
									
									If Empty( aHeaderTemp[nH]:CHEADERCOMBOBOX )
										cInpTemp := PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos],,aDados[5] )
									Else
										cInpTemp := PWSHtmCoEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ) , aDados[7], aDados[4][nPos], aHeaderTemp[nH]:CHEADERCOMBOBOX,,aDados[5] )
									Endif
									cHtml += '<td valign="middle">' + cInpTemp + '</td>'
								Endif
		
								cHtml += '</tr>'
							Else
								cHtml += '<td>&nbsp;&nbsp;&nbsp;</td>' +;
											'<td>&nbsp;&nbsp;&nbsp;</td>' +;
											'</tr>'
							Endif
						Endif
					Else
						If aDados[5]
							nPos := aScan( aDados[4], { |x| AllTrim( x[1] ) == AllTrim( aHeaderTemp[nH]:cHEADERFIELD ) } )
							
							If nPos > 0
								AAdd( aRetorno, PWSHtmInEx( aHeaderTemp[nH], PWSXTransform( xValor, cPicture ), aDados[7], aDados[4][nPos],,aDados[5] ) )
							Endif
						Else
							AAdd( aRetorno, PWSXTransform( xValor, cPicture ) )
						Endif
					Endif
				Endif
			Next nY
		
			cHtml += '<tr><td colspan="5">&nbsp;</td></tr>' +;
						'</table></td>' +;
						'</tr>' +;
						'</table>'
			
			If aDados[6] == "H"
				AAdd( aDados[1], cHtml )
			Else
				AAdd( aDados[1], aRetorno )
			Endif
			
		Next nX
	Else
		UserException('Unexpected #2 Argument Type : '+valtype(aDados[3]))
	Endif
Endif

// Session para armazenar a CriaObj
If aDados[8] == 0 .OR. aDados[8] == 3
	HttpSession->_TMPJS += '</script>'
Endif

#IFDEF _PORTAL_DEBUG
	ApWExAddErr()
	ApWExAddErr()
#Endif

__oObjeto := NIL 

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณParseWebCoบAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz um parse dos WebCols para utilizacao da customizacao do บฑฑ
ฑฑบ          ณ portal                                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1: Array com os campos a serem mostrados na tela        บฑฑ
ฑฑบ          ณ ExpC2: Sufixo                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ParseWebCols( aWebCols, cSuffix )

Local nI 		:= 0
Local nTam 		:= 0
Local nTamTemp 	:= 0
Local aRet 		:= {}

nTam := Len( aWebCols )

For nI := 1 To nTam
	If ValType( aWebCols[nI] ) == "A"
		nTamTemp := Len( aWebCols[nI] )
		
		Do Case
			Case aWebCols[nI][2] == "N"
				Do Case
					Case nTamTemp == 2
						AAdd( aRet, { aWebCols[nI][1], aWebCols[nI][2], "", 0, .T. } )

					Case nTamTemp == 3
						AAdd( aRet, { aWebCols[nI][1], aWebCols[nI][2], "", aWebCols[nI][3], .T. } )

					Case nTamTemp == 4
						If ValType( aWebCols[nI][3] ) == "A" .AND. ValType( aWebCols[nI][4] ) == "A"
							AAdd( aRet, { aWebCols[nI][1], aWebCols[nI][2], MntLinkF3( { aWebCols[nI][3], aWebCols[nI][4] }, cSuffix ), 0, .T. } )
						Else
							AAdd( aRet, { aWebCols[nI][1], aWebCols[nI][2], "", aWebCols[nI][3], aWebCols[nI][4] } )
						Endif

					Case nTamTemp == 5
						AAdd( aRet, { aWebCols[nI][1], aWebCols[nI][2], MntLinkF3( { aWebCols[nI][3], aWebCols[nI][4] }, cSuffix ), aWebCols[nI][5], .T. } )

					Case nTamTemp == 6
						AAdd( aRet, { aWebCols[nI][1], aWebCols[nI][2], MntLinkF3( { aWebCols[nI][3], aWebCols[nI][4] }, cSuffix, aWebCols[nI][6] ), aWebCols[nI][5], .T. } )

				EndCase
			Case aWebCols[nI][2] == "D"
				Do Case
					Case nTamTemp == 2
						AAdd( aRet, { aWebCols[nI][1], aWebCols[nI][2], "", 0, .T. } )
					Case nTamTemp == 3
						AAdd( aRet, { aWebCols[nI][1], aWebCols[nI][2], "", aWebCols[nI][3], .T. } )
				EndCase
			Case aWebCols[nI][2] == "H"
				AAdd( aRet, { aWebCols[nI][1], aWebCols[nI][2], "", 0, .T. } )
		EndCase
	Else
		AAdd( aRet, { aWebCols[nI], "N", "", 0, .T. } )
	Endif
Next nI

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMntWebColsบAutor  ณLuiz Felipe Couto    บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para montagem dos WebCols                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1: Array com os webcols                                 บฑฑ
ฑฑบ          ณ ExpO2: Header do objeto                                     บฑฑ
ฑฑบ          ณ ExpA3: Array com os userfields                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑบ2481-Paulo Vieira 01/10/2007 / 130816 / 811R4 - Adicionada cla๚sula paraบฑฑ
ฑฑบ	  verificar se ้ campo de usuแrio ("U") pois nใo estava achando o campoบฑฑ
ฑฑบ   campo e duplicava-o na rela็ใo de campos utilizados nas colunas.	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MntWebCols( aWebCols, aHeader, aUserField )

Local nI 			:= 0
Local nJ 			:= 0
Local nTam 			:= 0
Local nPosField 	:= 0

DEFAULT aUserField := {}

If Empty( aWebCols )
	aWebCols := {}
	nTam := Len( aHeader )
	
	For nI := 1 To nTam
		AAdd( aWebCols, aHeader[nI]:cHEADERFIELD )
	Next nI
	
	For nI := 1 To Len( aUserField )
		For nJ := 1 To Len( aUserField[nI] )
			nPosField := aScan( aWebCols, { |x| (AllTrim(x) == AllTrim(aUserField[nI][nJ]:cUSERNAME) .OR. AllTrim(x) == "U"+AllTrim(aUserField[nI][nJ]:cUSERNAME)) } )
			
			If nPosField == 0
				AAdd( aWebCols, AllTrim( aUserField[nI][nJ]:cUSERNAME ) )
			Endif
		Next nJ
	Next nI
Endif

Return aWebCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSHtmInExบAutor  ณLuiz Felipe Couto    บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para montagem dos GETS                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1: Objeto WS                                            บฑฑ
ฑฑบ          ณ ExpC2: Valor para colocar no input                          บฑฑ
ฑฑบ          ณ ExpC3: Sufixo                                               บฑฑ
ฑฑบ          ณ ExpA4: Array com os webcols                                 บฑฑ
ฑฑบ          ณ ExpL5: Parametro de userfield                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCleber M. ณ16/10/06|106875|Correcao no retorno da calculadora/calendarioบฑฑ
ฑฑบ          ณ        ณ      ณpara campos de usuario.                      บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบTatiane M.ณ02/04/07|122153|Substitui็ใo do atributo alt da imagem para  บฑฑ
ฑฑบ          ณ        ณ      ณo atributo title. Para Firefox o alt nใo fun-บฑฑ
ฑฑบ          ณ        ณ      ณciona, por isso precisei alterar para title  บฑฑ
ฑฑบ          ณ        ณ      ณque funciona tanto para Firefox como IE.     บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PWSHtmInEx( 	oObjHeader, cValue, cSuffix, aWebCols,;
								lUserField, lEdit )

Local cHtmlInput 	:= ""                            //Retorno da funcao
Local cPicture		:= AllTrim( oObjHeader:cHEADERPICTURE )//Picture do campo
Local cTmpPicture									// picture temporแria com a formata็ใo para o paํs especifํco
Local cTipoCampo	:= oObjHeader:cHEADERTYPE        //Tipo do campo (memo, caracter, numerico, data)
Local cTipoTmp		:= ""                            //Tipo de campo (temporaria)
Local cCampo		:= oObjHeader:cHEADERFIELD       //Nome do campo
Local nMaxLen		:= 0                             //Tamanho maximo do campo
Local nTamMemo    := 0                             //Tamanho do campo Memo

DEFAULT lUserField := .F.
DEFAULT lEdit      := .T.

If Empty( GetPrtSkin() )
	cImagem := "images"
Else
	cImagem := GetPrtSkin()
Endif

cValue	:= AllTrim( cValue )
cSuffix := IIF( Empty( cSuffix ), "", "_" + cSuffix )

If cTipoCampo $ "MCND"
	If aWebCols[2] <> "H"
		If cTipoCampo == "M" 
			cHtmlInput += '<textarea '
			If lUserField
				cHtmlInput += 'name="' + cCampo + cSuffix + '" '
			Else
				cHtmlInput += 'name="C' + cCampo + cSuffix + '" '
			Endif
		Else
			If Empty( cPicture )
				If cTipoCampo == "D"
					cTipoTmp := "D"
					cPicture := "@D 99/99/9999"
				Else
					cTipoTmp := "C"
					cPicture := "@S"
				Endif
			Else
				cTipoTmp := cTipoCampo
			Endif
			
			cTmpPicture = adjustPictValue(cPicture)
			cHtmlInput += '<input type="text" onKeyUp="Picture( event, this, ' + "'" + cTmpPicture + "'" + ', ' + "'" + cTipoTmp + "'" + ', aBuffer);" '

			If lUserField
				cHtmlInput += 'name="' + cCampo + cSuffix + '" '
			Else
				cHtmlInput += 'name="' + cTipoCampo + cCampo + cSuffix + '" '
			Endif
		Endif
		
		Do Case
			Case cTipoCampo == "M"
				nTamMemo := if((aWebCols[4] == NIL), TAMMAX, if( (Empty(aWebCols[4]) .or. aWebCols[4] == 0), TAMMAX, aWebCols[4]))
				cHtmlInput += 'cols="' + Str( nTamMemo ) + '" rows="4" '
			Case aWebCols[4] > 0
				cHtmlInput += 'size="' + Str( aWebCols[4] ) + '" '
			Otherwise
				If oObjHeader:NHEADERSIZE > TAMCAMPO
					cHtmlInput += 'size="' + Str( TAMMAX ) + '" '
				Else
					cHtmlInput += 'size="' + Str( TAMMIN ) + '" '
				Endif
		EndCase
		
		If cTipoCampo <> "M"
			cPicture 	:= AllTrim( cPicture )
			nPos 		:= At( "@", cPicture )
			nMaxLen 	:= oObjHeader:nHEADERSIZE
			
			If nPos > 0
				If Len( cPicture ) > 2
					nMaxLen := Len( cPicture ) - 3
				Endif
			Else
				If Len( cPicture ) > 0				
					nMaxLen := Len( cPicture )
				Endif
			Endif
			
			If SubStr( cPicture, 1, 2 ) == "@S"
				If !Empty( SubStr( cPicture, 3 ) )
					nMaxLen := Val( SubStr( cPicture, 3 ) )
				Endif
			Endif

			cHtmlInput += 'maxlength="' + AllTrim( Str( nMaxLen ) ) + '" '
		Endif

		cHtmlInput += 'class="' + aEstilo[5] + '" '
		
		if !lEdit
			cHtmlInput += ' readonly="readonly" style="background-color: #F4F3F3"'
		endif

		If cValue == NIL      
		
			If aWebCols[2] == "D"
				cHtmlInput += 'disabled '
			Endif
			
			if aWebCols[1] == "PRODUCTDESCRIPTION" 
				cHtmlInput += 'readOnly '
		  	Endif

			If cTipoCampo <> "M"
				cHtmlInput += 'value="" '
			Else
				cHtmlInput += '> '
			Endif
		Else
			If aWebCols[2] == "D"
				cHtmlInput += 'disabled '
			Endif    
				
			if aWebCols[1] == "PRODUCTDESCRIPTION"
				cHtmlInput += 'readOnly '
		  	Endif
			
			If cTipoCampo == "M"
				cHtmlInput += '>' + cValue + ' '
			Else
				cHtmlInput += 'value="' + cValue + '" '
			Endif
		Endif
		
		If cTipoCampo == "M"
			cHtmlInput += '</textarea>'
		Else
			If aWebCols[2] == "L"
				cHtmlInput += aWebCols[3] + '>'
			Else
				cHtmlInput += '>'
			Endif
		Endif
		
			If !Empty( aWebCols[3] ) .AND. aWebCols[2] <> "L" .AND. lEdit
			If aWebCols[2] == "D"
				cHtmlInput += '<img src="' + cImagem + '/ico-zoom.gif" border="0" onClick="' + "javascript:window.open('" + aWebCols[3] + "', 'jF3', 'top=30,left=30,width=800,height=850,scrollbars=yes');" + '" align="middle" title="Busca" disabled>'
			Else
				cHtmlInput += '<img src="' + cImagem + '/ico-zoom.gif" border="0" onClick="' + "javascript:window.open('" + aWebCols[3] + "', 'jF3', 'top=30,left=30,width=800,height=850,scrollbars=yes');" + '" style="cursor:hand" align="middle" title="Busca">'
			Endif
		Endif
		
		If aWebCols[2] <> "D"
			If lUserField
				HttpSession->_TMPJS += 'oForm.Add(document.forms[0].' + cCampo + cSuffix + ', ' + IIF( oObjHeader:LHEADEROBLIG .And. cCampo!="PAYMENTPLANCODE", "false", "true" ) + ')' + CRLF
			Else
				HttpSession->_TMPJS += 'oForm.Add(document.forms[0].' + cTipoCampo + cCampo + cSuffix + ', ' + IIF( oObjHeader:LHEADEROBLIG .And. cCampo!="PAYMENTPLANCODE", "false", "true" ) + ')' + CRLF
			Endif
		Endif
		        
		if lEdit
			If cTipoCampo == "N"
				If aWebCols[2] == "D"
					If lUserField
						cHtmlInput += '<img src="' + cImagem + '/ico-calculadora.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCalc.apw?CMPDEST=" + cCampo + cSuffix + "', 'jF3', 'width=500,height=500,scrollbars=no');" + '" align="middle" title="Calculadora" disabled>'
					Else
						cHtmlInput += '<img src="' + cImagem + '/ico-calculadora.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCalc.apw?CMPDEST=" + cTipoCampo + cCampo + cSuffix + "', 'jF3', 'width=500,height=500,scrollbars=no');" + '" align="middle" title="Calculadora" disabled>'
					EndIf
				Else
					If lUserField
						cHtmlInput += '<img src="' + cImagem + '/ico-calculadora.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCalc.apw?CMPDEST=" + cCampo + cSuffix + "', 'jF3', 'width=500,height=500,scrollbars=no');" + '" style="cursor:hand" align="middle" title="Calculadora">'
					Else
						cHtmlInput += '<img src="' + cImagem + '/ico-calculadora.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCalc.apw?CMPDEST=" + cTipoCampo + cCampo + cSuffix + "', 'jF3', 'width=500,height=500,scrollbars=no');" + '" style="cursor:hand" align="middle" title="Calculadora">'			
					EndIf
				Endif
			ElseIf cTipoCampo == "D"
				If aWebCols[2] == "D"
					If lUserField
						cHtmlInput += '<img src="' + cImagem + '/ico-calendario.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCALE.apw?Month=" + AllTrim( Str( Month( date() ) - 1 ) ) + "&Year=" + AllTrim( Str( Year( date() ) ) ) + "&CMPDEST=" + cCampo + cSuffix + "', 'jF3', 'width=350,height=270,scrollbars=no');" + '" align="middle" title="Calendแrio" disabled>'
					Else
						cHtmlInput += '<img src="' + cImagem + '/ico-calendario.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCALE.apw?Month=" + AllTrim( Str( Month( date() ) - 1 ) ) + "&Year=" + AllTrim( Str( Year( date() ) ) ) + "&CMPDEST=" + cTipoCampo + cCampo + cSuffix + "', 'jF3', 'width=350,height=270,scrollbars=no');" + '" align="middle" title="Calendแrio" disabled>'
					EndIf
				Else	
					If lUserField
						cHtmlInput += '<img src="' + cImagem + '/ico-calendario.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCALE.apw?Month=" + AllTrim( Str( Month( date() ) - 1 ) ) + "&Year=" + AllTrim( Str( Year( date() ) ) ) + "&CMPDEST=" + cCampo + cSuffix + "', 'jF3', 'width=350,height=270,scrollbars=no');" + '" style="cursor:hand" align="middle" title="Calendแrio">'
					Else
						cHtmlInput += '<img src="' + cImagem + '/ico-calendario.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCALE.apw?Month=" + AllTrim( Str( Month( date() ) - 1 ) ) + "&Year=" + AllTrim( Str( Year( date() ) ) ) + "&CMPDEST=" + cTipoCampo + cCampo + cSuffix + "', 'jF3', 'width=350,height=270,scrollbars=no');" + '" style="cursor:hand" align="middle" title="Calendแrio">'
					EndIf
				Endif
			Endif
		EndIf
		
		If aWebCols[2] == "D"
			If !Empty( cValue )
				Do Case
					Case ValType( cValue ) == "N"
						cValue := AllTrim( Str( cValue ) )
					Case ValType( cValue ) == "D"
						cValue := DToC( cValue )
					Otherwise
				EndCase
			Else
				cValue := ""
			Endif

			If lUserField
				If !Empty(cValue)
					cHtmlInput += '<input type="hidden" name="' + cCampo + cSuffix + '" value="' + cValue + '">'
				Else
					cHtmlInput += '<input type="hidden" name="' + cCampo + cSuffix + '_H" value="' + cValue + '">'
				EndIf
			Else
				cHtmlInput += '<input type="hidden" name="' + cTipoCampo + cCampo + cSuffix + '_H" value="' + cValue + '">'
			Endif
		Endif
	Else
		If Empty( cValue )
			cValue := ""
		Endif
		
		If lUserField
			cHtmlInput += '<input type="hidden" name="' + cCampo + cSuffix + '" value="' + cValue + '">'
		Else
			cHtmlInput += '<input type="hidden" name="' + IIF( cTipoCampo == "M", "C", cTipoCampo ) + cCampo + cSuffix + '" value="' + cValue + '">'
		Endif
	Endif
Else
	cHtmlInput := '<!-- ' + ProcName( 0 ) + ' Error : Invalid Field Type '
	cHtmlInput += '(' + cTipoCampo + ') from field '
	cHtmlInput += '(' + cCampo + ') -->'
Endif

Return cHtmlInput

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSHtmCoExบAutor  ณLuiz Felipe Couto    บ Data ณ  17/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para montagem dos COMBOS                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1: Header                                               บฑฑ
ฑฑบ          ณ ExpC2: Valor                                                บฑฑ
ฑฑบ          ณ ExpC3: Sufixo                                               บฑฑ
ฑฑบ          ณ ExpA4: Array com webcols                                    บฑฑ
ฑฑบ          ณ ExpC5: Valores do Combo                                     บฑฑ
ฑฑบ          ณ ExpL6: Parametro para userfield                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PWSHtmCoEx( 	oObjHeader, cValue, cSuffix, aWebCols,;
								cValuesBox, lUserField, lEdit )

Local cHtmlCombo 	:= ""
Local nI 			:= 0
Local nTam 			:= 0
Local nTemp 		:= 0
Local aTemp 		:= {}

DEFAULT cValuesBox 	:= ""
DEFAULT lUserField 	:= .F.
DEFAULT lEdit       := .T.

cSuffix := IIF( Empty(cSuffix), "", "_" + cSuffix )

If oObjHeader:cHEADERTYPE $ "CND"
	If aWebCols[2] <> "H"
		cHtmlCombo += '<'
		cHtmlCombo += 'select '
		                
		if !lEdit
			cHtmlCombo += ' onfocus=this.blur() style="background-color: #F4F3F3" '
		endif
				
		If lUserField
			cHtmlCombo += 'name="U' + SubStr( oObjHeader:cHEADERFIELD, 2 ) + cSuffix + '" '
		Else
			cHtmlCombo += 'name="' + oObjHeader:cHEADERTYPE + oObjHeader:cHEADERFIELD + cSuffix + '" '
		Endif

		If oObjHeader:nHEADERSIZE > TAMCAMPO
			cHtmlCombo += 'class="' + aEstilo[6] + '" '
		Else
			cHtmlCombo += 'class="' + aEstilo[6] + '" '
		Endif
		
		If aWebCols[2] == "D"
			cHtmlCombo += 'disabled'
		Endif
		
		cHtmlCombo += '>'

		//DOCUMENTTYPE EM CASOS DE PRษ-NOTA NO PORTAL DO FORNECEDOR
		//NUNCA SรO EM FORMULARIO PRำPRIO
		If AWEBCOLS[1]=="DOCUMENTTYPE"
			aTemp := {"N=Nใo"}
		Else
			aTemp := Separa( cValuesBox, ";", .F. )
		Endif
		nTam := Len( aTemp )
		For nI := 1 To nTam
			nTemp := At( "=", aTemp[nI] )
			cHtmlCombo += '<option value="' + SubStr( aTemp[nI], IIF( At( "&", aTemp[nI] ) > 0, 2, 1 ), IIF( At( "&", aTemp[nI] ) > 0, nTemp-2, nTemp-1 ) ) + '" ' + IIF( SubStr( aTemp[nI], 1, nTemp-1 ) == cValue  .OR. At( "&", aTemp[nI] ) > 0, "selected", "" ) + '>' + SubStr( aTemp[nI], nTemp+1 ) + '</option>'
		Next nI
		
		cHtmlCombo += '</select>'
		
		nTemp := At( "=", aTemp[1] )
		If aWebCols[2] == "D"
			If lUserField
				cHtmlCombo += '<input type="hidden" name="' + SubStr( oObjHeader:cHEADERFIELD, 2 ) + cSuffix + '_H" value="' + RTrim( HtmlNoTags( cValue ) ) + '">'
			Else
				cHtmlCombo += '<input type="hidden" name="' + oObjHeader:cHEADERTYPE + oObjHeader:cHEADERFIELD + cSuffix + '_H" value="' + RTrim( HtmlNoTags( cValue ) ) + '">'
			Endif
		Endif
	Else
		If lUserField
			cHtmlCombo += '<input type="hidden" name="' + SubStr( oObjHeader:cHEADERFIELD, 2 ) + cSuffix + '" value="' + RTrim( HtmlNoTags( cValue ) ) + '">'
		Else
			cHtmlCombo += '<input type="hidden" name="' + oObjHeader:cHEADERTYPE + oObjHeader:cHEADERFIELD + cSuffix + '" value="' + RTrim( HtmlNoTags( cValue ) ) + '">'
		Endif
	Endif
Else
	cHtmlCombo := '<!-- ' + ProcName( 0 ) + ' Error : Invalid Field Type '
	cHtmlCombo += '(' + oObjHeader:cHEADERTYPE + ') from field '
	cHtmlCombo += '(' + oObjHeader:cHEADERFIELD + ') -->'
Endif

Return cHtmlCombo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSXTransfบAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Aplica picture ao valor passado por parametro               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Valor a ser aplicado a picture                       บฑฑ
ฑฑบ          ณ ExpC2: Picture de retorno                                   บฑฑ
ฑฑบ          ณ ExpC3: Sinaliza se ้ um campo hidden. Default: .F.          บฑฑ
ฑฑบ          ณ ExpC4: Sinaliza se texto para ser exibido diretamente no	   บฑฑ
ฑฑบ          		c๓digo HTML (sem ser em elementos <input ou <textarea>.บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบTatiana C.ณ12/02/07|118356|Alteracao para nao buscar a picture de camposบฑฑ
ฑฑบ          ณ        | 8.11 |novamente na montagem da tela HTML.          บฑฑ
ฑฑบPaulo Vierณ11/10/07|131300|Alteracao para contemplar a picture utilizadaบฑฑ
ฑฑบ          ณ        | 8.11 |na formata็ใo dos valores (adjustPictValue)  บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function PWSXTransform( xValor, cPicture, alHidden, alHtmlCode )

default alHidden := .F.
default alHtmlCode := .F.
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tratamento para tirar o '-' do campo CEP ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If AllTrim(Upper(cPicture)) == "@R 99999-999"
	xValor := Replace(xValor,"-","")
EndIf

xValor := Transform( xValor, cPicture )

if !alHidden
	xValor := adjustPictValue(xValor)
endif

if alHtmlCode
	// transforma quaisquer c๓digos de "nova linha" em c๓digo html de "nova linha"
	xValor := strTran(xValor, LF, HTML_LF)
endif

Return xValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSXTransfบAutor  ณPaulo R Vieira       บ Data ณ  11/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o valor passado conforme o idioma e a picture utilizaบฑฑ
ฑฑบ          ณ pelo usuแrio (rpo)                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Valor a ser ajustado a picture                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ        |      |                                             บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function adjustPictValue(acValue)
Local cIdiom	:= FWRetIdiom()        //Retorna Idioma Atual

	acValue := DwStr(acValue)

if !empty( GETPVPROFSTRING(GetEnvServer(),"PictFormat","",GetADV97()) )
	If cIdiom == 'en' 
		acValue := Replace(acValue, ".", "|")
		acValue := Replace(acValue, ",", ".")
		acValue := Replace(acValue, "|", ",")
	ElseIf cIdiom == 'es'
		acValue := Replace(acValue, ".", "|")
		acValue := Replace(acValue, ",", ".")
		acValue := Replace(acValue, "|", ",")
	EndIf
endif
	
return acValue

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraJS    บAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera os scripts para utilizacao da tela do Portal           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1: Array de F3                                          บฑฑ
ฑฑบ          ณ ExpA2: Array de retorno                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GeraJs( aF3s, aRets )

Local nI := 0
Local nY := 0
Local nTam := Len( aF3s )
Local nTamY := Len( aRets )
Local cJs := "<script>" + CRLF
Local cPrecoTemp := ""
Local xValue	:=	""
Private nJ := 0
Private oTempObj := aRets

cJs += "function envia( x )" + CRLF
cJs += "{" + CRLF

For nY := 1 To nTamY
	nJ := nY

	cJs += "if( x == " + AllTrim( Str( nY - 1) ) + " )" + CRLF
	cJs += "{"  + CRLF
	
	If HttpGet->F3Nome == "GETCATALOG"
//		cPrecoTemp := GetPrice( &( "oTempObj[nJ]:" + aF3s[1][1] ) )
		
		cJs += "if( parent.opener.document.forms[0].NNETUNITPRICE == null )"
		cJs += "{"
		cJs += "if( parent.opener.document.forms[0].NUNITVALUE != null )"
		cJs += "{"
		cJs += "parent.opener.document.forms[0].NUNITVALUE.value = '" + IIF( !Empty( cPrecoTemp ), AllTrim( Transform( cPrecoTemp[1]:nPRICE, "@E 999,999,999.99" ) ), "" ) + "';"
		cJs += "}"
		cJs += "}"
		cJs += "else"
		cJs += "{"
		cJs += "parent.opener.document.forms[0].NNETUNITPRICE.value = '" + IIF( !Empty( cPrecoTemp ), AllTrim( Transform( cPrecoTemp[1]:nPRICE, "@E 999,999,999.99" ) ), "" ) + "';"
		cJs += "parent.opener.document.forms[0].NNETUNITPRICE_H.value = '" + IIF( !Empty( cPrecoTemp ), AllTrim( Transform( cPrecoTemp[1]:nPRICE, "@E 999,999,999.99" ) ), "" ) + "';"
		cJs += "}"
	Endif

	For nI := 1 To nTam                                                           
			xValue	:=	&( "oTempObj[nJ]:" + aF3s[nI][1] ) 
			If ValType(xValue) == "N"
				xValue	:=	Str(xValue)                                                                 
				cJs += "parent.opener.document.forms[0]." + aF3s[nI][2] + ".value = "+xValue+ ";" + CRLF
			Else 
				If ValType(xValue) == "D"
					xValue	:=	Dtoc(xValue)
				ElseIf	ValType(xValue) == "L"
					xValue	:=	If(xValue,'.T.','.F.')
				Endif
				cJs += "parent.opener.document.forms[0]." + aF3s[nI][2] + ".value = '"+xValue+ "';" + CRLF
			Endif	
	Next nI
	cJs += "}"  + CRLF
Next nY

If Alltrim(HttpGet->F3Nome) == "BRWCOURSE"
	If "1" $ aF3s[1][2]
		cJs += "parent.opener.showOther('lCourse1Other', 'cCourse1Code', 'cCourse1Desc', 'oCourse1F3', false, 'cC1Desc', '1');" + CRLF
	ElseIf "2" $ aF3s[1][2]
		cJs += "parent.opener.showOther('lCourse2Other', 'cCourse2Code', 'cCourse2Desc', 'oCourse2F3', false, 'cC2Desc', '1');" + CRLF
	ElseIf "3" $ aF3s[1][2]
		cJs += "parent.opener.showOther('lCourse3Other', 'cCourse3Code', 'cCourse3Desc', 'oCourse3F3', false, 'cC3Desc', '1');" + CRLF
	ElseIf "4" $ aF3s[1][2]
		cJs += "parent.opener.showOther('lCourse4Other', 'cCourse4Code', 'cCourse4Desc', 'oCourse4F3', false, 'cC4Desc', '1');" + CRLF
	EndIf
EndIf
cJs += "parent.window.close();" + CRLF
cJs += "}" + CRLF
cJs += "</script>"
	
Return cJs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetJsGridLบAutor  ณLuiz Felipe Couto    บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os codigos javascript para a tela do Portal         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetJsGridLines()

Return HttpSession->_TMPJS

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSGetWsErบAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de recuperacao do erro de execucao do WebServices    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Mensagem do erro interno                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PWSGetWSError( cMsgInternal )

Local cMsgError := GetWscError( 3 )	// Soap_fault

If Empty( cMsgError )
	cMsgError := GetWscError( 1 ) //Client
Endif

cMsgError := EncodeUTF8(cMsgError)

Return cMsgError

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSHtmlAleบAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de Erro utilizada para todas as rotinas do Portal,     บฑฑ
ฑฑบ          ณ inclusive para erros de WebServices (Server e Client)       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Mensagem do erro interno                             บฑฑ
ฑฑบ          ณ ExpC2: Cabecalho                                            บฑฑ
ฑฑบ          ณ ExpC3: Mensagem de erro a ser apresentada na tela           บฑฑ
ฑฑบ          ณ ExpC4: Pagina de volta                                      บฑฑ
ฑฑบ          ณ ExpL5: Determina se apresenta a tela inicial                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PWSHtmlAlert( cMsgInternal, cTopo, cMsg, cPagVolta, lInSite)

Local cMsgError := PWSGetWSError( cMsgInternal )
Local cHtml := ""

Default lInSite := .T.

WEB EXTENDED INIT cHtml START IIF(lInSite,"InSite","")

HttpSession->_HTMLERRO := { NIL, NIL, NIL }

If Empty( cMsg )
	If !Empty( cMsgError )
		cMsg := cMsgError
	Endif
Endif

HttpSession->_HTMLERRO[1] := cTopo
HttpSession->_HTMLERRO[2] := cMsg
HttpSession->_HTMLERRO[3] := cPagVolta

cHtml += ExecInPage( "PWSXERRO" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSSetObjTบAutor  ณLuiz Felipe Couto    บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para preencher as propriedades dos objetos com o postบฑฑ
ฑฑบ          ณ inclusive para erros de WebServices (Server e Client)       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1: Objeto a ser populado com os dados do post           บฑฑ
ฑฑบ          ณ ExpA2: Header                                               บฑฑ
ฑฑบ          ณ ExpA3: Post                                                 บฑฑ
ฑฑบ          ณ ExpC4: Sufixo                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบA.Veiga   ณ17/04/06ณ 8.11 ณBOPS 96697 - Tratamento do campo MEMO do     บฑฑ
ฑฑบ          ณ        ณ      ณcadastro de oportunidades. Se, na inclusao,  บฑฑ
ฑฑบ          ณ        ณ      ณo campo "Notas" estivesse em branco, apareciaบฑฑ
ฑฑบ          ณ        ณ      ณo erro: "invalid property MNOTES" nao permi- บฑฑ
ฑฑบ          ณ        ณ      ณtindo a confirmacao da oportunidade.         บฑฑ
ฑฑบCleber M. ณ15/09/06ณ102906ณAlteracao da variavel cUSERTAG de NIL para ""บฑฑ
ฑฑบ          ณ        ณ  8.11ณa fim de exibir corretamente os campos de    บฑฑ
ฑฑบ          ณ        ณ      ณusuario que estao como Disable.              บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PWSSetObjToPost( oObj, aHeader, aPosts, cSuffix )

Local cPostField 	:= ""				//Campo a ser postado
Local nI 			:= 0				//Usada em lacos For...Next 
Local nJ			:= 0				//Usada em lacos For...Next 
Local nTamH 		:= Len( aHeader )	//Tamanho do array aHeader
Local nPos 			:= 0				//Posicao encontrada no array
Local lFound		:= .T.				//Indica se encontrou o campo
Local cPostFld2   	:= "" 
Local cLanguage		:= ""
Local cTipoCampo	:= ""
Local cIdiom		:= FWRetIdiom()        //Retorna Idioma Atual

Private oTemp := oObj

If cIdiom == 'en' 
	cLanguage := 'ENGLISH'
ElseIf cIdiom == 'es'
	cLanguage := 'SPANISH'
Else
	cLanguage := 'PORTUGUESE'
EndIf

cSuffix := IIF( Empty( cSuffix ), "", "_" + cSuffix )

For nI := 1 To nTamH
	lFound 		:= .F.
	cTipoCampo := IIF( aHeader[nI]:CHEADERTYPE == "M", "C", aHeader[nI]:CHEADERTYPE )
	cPostField 	:= Upper( cTipoCampo + aHeader[nI]:CHEADERFIELD + cSuffix )
	cPostFld2 := Upper(aHeader[nI]:CHEADERTYPE + aHeader[nI]:CHEADERFIELD + cSuffix )	
	nPos 		:= aScan( aPosts, { |x| x == cPostField } )
	
	If nPos > 0
		lFound := .T.
		
		If !Empty( &( "HttpPost->" + aPosts[nPos] ) )  
			If aHeader[nI]:CHEADERTYPE == "C" .OR. aHeader[nI]:CHEADERTYPE == "M"
				&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := &( "HttpPost->" + aPosts[nPos] )
				
				If !Empty( aHeader[nI]:cHEADERPICTURE ) .AND. Len( AllTrim( aHeader[nI]:cHEADERPICTURE ) ) > 2
					&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := StrTran( &( "oTemp:C" + aHeader[nI]:CHEADERFIELD ), "/", "" )
					&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := StrTran( &( "oTemp:C" + aHeader[nI]:CHEADERFIELD ), ".", "" )
					&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := StrTran( &( "oTemp:C" + aHeader[nI]:CHEADERFIELD ), "-", "" )
					&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := StrTran( &( "oTemp:C" + aHeader[nI]:CHEADERFIELD ), ",", "" )
				Endif
			ElseIf aHeader[nI]:CHEADERTYPE == "D"
				&( "oTemp:" + aHeader[nI]:CHEADERTYPE + aHeader[nI]:CHEADERFIELD ) := CtoD( &( "HttpPost->" + aPosts[nPos] ) )
			ElseIf aHeader[nI]:CHEADERTYPE == "N"
				&( "HttpPost->" + aPosts[nPos] ) := StrTran( &( "HttpPost->" + aPosts[nPos] ), ".", "" )
				&( "HttpPost->" + aPosts[nPos] ) := StrTran( &( "HttpPost->" + aPosts[nPos] ), ",", "." )
				&( "oTemp:" + aHeader[nI]:CHEADERTYPE + aHeader[nI]:CHEADERFIELD ) := Val( &( "HttpPost->" + aPosts[nPos] ) )
			Endif
		Else
			If aHeader[nI]:CHEADERTYPE == "C" 
				&( "oTemp:" + aHeader[nI]:CHEADERTYPE + aHeader[nI]:CHEADERFIELD ) := ""
			ElseIf aHeader[nI]:CHEADERTYPE == "N"
				&( "oTemp:" + aHeader[nI]:CHEADERTYPE + aHeader[nI]:CHEADERFIELD ) := 0
				
			// Se o tipo do campo for "M" (memo), redefine como "C" (caracter) porque ณ
			// no webbrowser o campo e' tratado como caracter.                        ณ
			ElseIf aHeader[nI]:CHEADERTYPE == "M" 
				&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := ""
			Else
				&( "oTemp:" + aHeader[nI]:CHEADERTYPE + aHeader[nI]:CHEADERFIELD ) := NIL
			Endif
		Endif
	Else
	    If aHeader[nI]:CHEADERTYPE == "M"  
	    	nPosHidden := aScan( aPosts, { |x| x == cPostFld2 + "_H" } )
	    Else
			nPosHidden := aScan( aPosts, { |x| x == cPostField + "_H" } )
		EndIf
		
		If nPosHidden > 0
			lFound := .T.
			
			If !Empty( &( "HttpPost->" + aPosts[nPosHidden] ) )
				If aHeader[nI]:CHEADERTYPE == "C" .OR. aHeader[nI]:CHEADERTYPE == "M"
				    if SubStr(aPosts[nPosHidden3],1,2) == "CU" 
						aProp := ClassDataArr( oTemp )
						nPosUsrFld := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )					
						If nPosUsrFld > 0 .AND. Type( "aProp[nPosUsrFld][2]" ) <> "U"
							For nJ := 1 To Len( aProp[nPosUsrFld][2]:oWSUSERFIELD )
								lFound 		:= .T.
								cPostField 	:= AllTrim( "U" + aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERNAME ) + cSuffix
								nPos := aScan( aPosts, { |x| AllTrim( x ) == "C"+AllTrim( cPostField )+"_H" } )
								If nPos > 0
									If aHeader[nI]:CHEADERTYPE == "C" 
										aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERTAG := &( "HttpPost->" + aPosts[nPos] )
									EndIf
								EndIf
							Next nJ
						EndIf
				    ElseIf SubStr(aPosts[nPosHidden],1,2) == "MU"
						aProp := ClassDataArr( oTemp )
						nPosUsrFld := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )					
						If nPosUsrFld > 0 .AND. Type( "aProp[nPosUsrFld][2]" ) <> "U"
							For nJ := 1 To Len( aProp[nPosUsrFld][2]:oWSUSERFIELD )
								lFound 		:= .T.
								cPostField 	:= AllTrim( "U" + aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERNAME ) + cSuffix
								nPos := aScan( aPosts, { |x| AllTrim( x ) == "M"+AllTrim( cPostField )+"_H" } )
								If nPos > 0
									If aHeader[nI]:CHEADERTYPE == "M"
										aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERTAG := &( "HttpPost->" + aPosts[nPos] )
									EndIf
								EndIf
							Next nJ
						EndIf						
					Else	
						&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := &( "HttpPost->" + aPosts[nPosHidden] )
						If !Empty( aHeader[nI]:cHEADERPICTURE ) .AND. Len( AllTrim( aHeader[nI]:cHEADERPICTURE ) ) > 2
							&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := StrTran( &( "oTemp:C" + aHeader[nI]:CHEADERFIELD ), "/", "" )
							&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := StrTran( &( "oTemp:C" + aHeader[nI]:CHEADERFIELD ), ".", "" )
							&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := StrTran( &( "oTemp:C" + aHeader[nI]:CHEADERFIELD ), "-", "" )
							&( "oTemp:C" + aHeader[nI]:CHEADERFIELD ) := StrTran( &( "oTemp:C" + aHeader[nI]:CHEADERFIELD ), ",", "" )
						Endif
					EndIf                
				ElseIf aHeader[nI]:CHEADERTYPE == "D"
					if SubStr (aPosts[nPosHidden],1,2) == "DU" 
						aProp := ClassDataArr( oTemp )
						nPosUsrFld := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )					
						If nPosUsrFld > 0 .AND. Type( "aProp[nPosUsrFld][2]" ) <> "U"
							For nJ := 1 To Len( aProp[nPosUsrFld][2]:oWSUSERFIELD )
								lFound 		:= .T.
								cPostField 	:= AllTrim( "U" + aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERNAME ) + cSuffix
								nPos := aScan( aPosts, { |x| AllTrim( x ) == "D"+AllTrim( cPostField )+"_H" } )
								If nPos > 0
									If aHeader[nI]:CHEADERTYPE == "D"	
										aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERTAG := &( "HttpPost->" + aPosts[nPos] ) 									
									EndIf
								EndIf
							Next nJ
						EndIf
					Else	
						&( "oTemp:" + aHeader[nI]:CHEADERTYPE + aHeader[nI]:CHEADERFIELD ) := CtoD( &( "HttpPost->" + aPosts[nPosHidden] ) )
					EndIf                					
				ElseIf aHeader[nI]:CHEADERTYPE == "N"
					if SubStr (aPosts[nPosHidden],1,2) == "NU" .Or. SubStr (aPosts[nPosHidden],1,2) == "NQ"
						aProp := ClassDataArr( oTemp )
						nPosUsrFld := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )					
						If nPosUsrFld > 0 .AND. Type( "aProp[nPosUsrFld][2]" ) <> "U"
							For nJ := 1 To Len( aProp[nPosUsrFld][2]:oWSUSERFIELD )
								lFound 		:= .T.
								cPostField 	:= AllTrim( "U" + aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERNAME ) + cSuffix
								nPos := aScan( aPosts, { |x| AllTrim( x ) == "N"+AllTrim( cPostField )+"_H" } )
								If nPos > 0
									If aHeader[nI]:CHEADERTYPE == "N"	
										aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERTAG := &( "HttpPost->" + aPosts[nPos] ) 
									EndIf
								EndIf
							Next nJ
						EndIf
					Else					
						If cLanguage == "PORTUGUESE"
						&( "HttpPost->" + aPosts[nPosHidden] ) := StrTran( &( "HttpPost->" + aPosts[nPosHidden] ), ".", "" )
						&( "HttpPost->" + aPosts[nPosHidden] ) := StrTran( &( "HttpPost->" + aPosts[nPosHidden] ), ",", "." )
						Else
							If cLanguage == "SPANISH"
								If ( "," $  &( "HttpPost->" + aPosts[nPosHidden] ) ) 
									&( "HttpPost->" + aPosts[nPosHidden] ) := StrTran( &( "HttpPost->" + aPosts[nPosHidden] ), ",", "|" )
									&( "HttpPost->" + aPosts[nPosHidden] ) := StrTran( &( "HttpPost->" + aPosts[nPosHidden] ), ".", "" )
									&( "HttpPost->" + aPosts[nPosHidden] ) := StrTran( &( "HttpPost->" + aPosts[nPosHidden] ), "|", "." )
								EndIf 
							EndIf	
						EndIf                                                                                           					
						&( "oTemp:" + aHeader[nI]:CHEADERTYPE + aHeader[nI]:CHEADERFIELD ) := Val( &( "HttpPost->" + aPosts[nPosHidden] ) ) //Val( StrTran( &( "HttpPost->" + aPosts[nPosHidden] ), ",", "." ) )
					EndIf                					
				Endif
			Endif
		Else
			aProp := ClassDataArr( oTemp )
			nPosUsrFld := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
			
			If nPosUsrFld > 0 .AND. Type( "aProp[nPosUsrFld][2]" ) <> "U"
				For nJ := 1 To Len( aProp[nPosUsrFld][2]:oWSUSERFIELD )
					lFound 		:= .T.
					cPostField 	:= AllTrim( "U" + aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERNAME ) + cSuffix
					
					nPos := aScan( aPosts, { |x| AllTrim( x ) == AllTrim( cPostField ) } )
					
					If nPos > 0
						aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERTAG := &( "HttpPost->" + aPosts[nPos] )
					Else
						aProp[nPosUsrFld][2]:oWSUSERFIELD[nJ]:cUSERTAG := "" 
					EndIf
				Next nJ
			EndIf
		EndIf
	EndIf

	If !lFound
		&( "oTemp:" + cTipoCampo + aHeader[nI]:CHEADERFIELD ) := NIL
	EndIf
Next nI

oObj := oTemp

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetImgProdบAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de recuperacao da imagem do produto                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetImgProd()

If Upper( SubStr( HttpSession->_IMG_PROD, 1, 2 ) ) == "BM"
	HttpCTType( "application/xbitmap" )
	HttpCTDisp( 'attachment; filename="produto.bmp"' )
Else
	HttpCTType( "image/jpeg" )
	HttpCTDisp( 'attachment; filename="produto.jpg"' )
Endif

HttpSend( HttpSession->_IMG_PROD )

Return ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsImgProd บAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para verificacao se o produto possui imagem          บฑฑ
ฑฑบ          ณ cadastrada                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IsImgProd()

Return !Empty( HttpSession->_IMG_PROD )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetImgInstบAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de recuperacao da imagem do institucional            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetImgInst()

if valType(HttpSession->_IMG_INST) <> 'U'

	If Upper( SubStr( HttpSession->_IMG_INST, 1, 2 ) ) == "BM"
		HttpCTType( "application/xbitmap" )
	Else
		HttpCTType( "image/jpeg" )
	Endif
	
	HttpCTLen( Len( HttpSession->_IMG_INST ) )
	HttpSend( HttpSession->_IMG_INST )

endIf	

return ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSigaPPStarบAutor  ณ Julio Wittwer       บ Data ณ  25/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de Inicializacao adicional de Ambiente WEB (Start)   บฑฑ
ฑฑบ          ณ da Working Thread. Executada no momento do START da Working บฑฑ
ฑฑบ          ณ Thread                                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SigaPPStart()

Local aStrings		:= ""

Local oParam		:= " " 
Local cParam		:= Nil

oParam := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL(@oParam,"CFGDICTIONARY.APW") 

If oParam:GETPARAM( "MSALPHA", "MV_LOGSIGA" )     
	cParam := oParam:cGETPARAMRESULT 
	If cParam # Nil .AND. ! Empty(cParam) .AND. UPPER(cParam) == "LOGOCENTER"
   		__xCHGHCons({	{"Protheus","Logix"},;
		  				{"Microsiga","Logocenter"} })
	Endif 				
Endif		

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTratamento do ponto de entrada para alterar a descricao do portal  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("GCH001")
	aStrings := ExecBlock( "GCH001", .F., .F.) 
	__xCHGHCons(aStrings)
Endif


Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSigaPPConnบAutor  ณ Julio Wittwer       บ Data ณ  25/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao executada antes do processamento de qualquer link    บฑฑ
ฑฑบ          ณ .apw                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Funcao Principal                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SigaPPConnect( cFnMain )
	
HeadNoCache()

Return ''

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHeadNoCachบAutor  ณ Julio Wittwer       บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para nao armazenar cache de Browser                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HeadNoCache()
 
HttpHeadOut->Expires 		:= "Mon, 26 Jul 1997 05:00:00 GMT "
HttpHeadOut->Last_Modified 	:= TransData()
HttpHeadOut->Cache_Control 	:= "no-store, no-cache, must-revalidate, post-check=0, pre-check=0;"
HttpHeadOut->pragma 		:= "no-cache"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTransData บAutor  ณ Luiz Felipe Couto   บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para trocar a data para utilizacao do HeadNoCache    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TransData()

cData := DToC( Date() )
cHora := AllTrim( Str( Val( Substr( Time(), 1, 2 ) ) - 3 ) ) + ":" + Substr( Time(), 4, 2 ) + ":" + Substr( Time(), 7, 2 )
nDiaSem := Dow( CToD( cData ) )
cDiaSem := ""

cDia := Substr( cData, 1, 2 )
cMes := Substr( cData, 4, 2 )
cAno := Substr( cData, 7, 4 )

Do Case
	Case cMes == "01"
		cMes := "Jan"
	Case cMes == "02"
		cMes := "Feb"
	Case cMes == "03"
		cMes := "Mar"
	Case cMes == "04"
		cMes := "Apr"
	Case cMes == "05"
		cMes := "May"
	Case cMes == "06"
		cMes := "Jun"
	Case cMes == "07"
		cMes := "Jul"
	Case cMes == "08"
		cMes := "Aug"
	Case cMes == "09"
		cMes := "Sep"
	Case cMes == "10"
		cMes := "Oct"
	Case cMes == "11"
		cMes := "Nov"
	Case cMes == "12"
		cMes := "Dec"
EndCase

Do Case
	Case nDiaSem == 1
		cDiaSem := "Sun"
	Case nDiaSem == 2
		cDiaSem := "Mon"
	Case nDiaSem == 3
		cDiaSem := "Tue"
	Case nDiaSem == 4
		cDiaSem := "Wed"
	Case nDiaSem == 5
		cDiaSem := "Thu"
	Case nDiaSem == 6
		cDiaSem := "Fri"
	Case nDiaSem == 7
		cDiaSem := "Sat"
EndCase		

cData := cDiaSem + ", " + cDia + " " + cMes + " " + cAno + " " + cHora + " GMT"

Return cData

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSetEstilo บAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define o o estilo do Portal                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1: Array com os estilos do Portal                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SetEstilo( aEst )

aEstilo := aClone( aEst )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPutHeadUsrบAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de inclusao dos campos de usuario no Header          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Header                                                บฑฑ
ฑฑบ          ณExpA2: Array com os campos de usuario                        บฑฑ
ฑฑบ          ณExpA3: Array com os campos a serem mostrados na tela         บฑฑ
ฑฑบ          ณExpC4: Nome WebServices                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PutHeadUsrFld( aHeader, aUserField, aWebCols, cNomeWS )

Local lRetorno		:= .T.
Local nI 			:= 0
Local nJ 			:= 0
Local nPos 			:= 0
Local nPosHeader 	:= 0

For nI := 1 To Len( aWebCols )
	nPos := aScan( aHeader, { |x| AllTrim( x:cHEADERFIELD ) == AllTrim( "U" + aWebCols[nI][1] ) } )
	
	If nPos == 0
		For nJ := 1 To Len( aUserField )
			nPos := aScan( aUserField[nJ], { |x| AllTrim( x:cUSERNAME ) == AllTrim( aWebCols[nI][1] ) } )
			
			If nPos > 0
				nPosHeader := aScan( aHeader, { |x| x:cHEADERFIELD == AllTrim( "U" + aUserField[nJ][nPos]:cUSERNAME ) } )
				
				If nPosHeader == 0
					aSize( aHeader, Len( aHeader ) + 1 )
					aIns( aHeader, nI )
		
					aHeader[nI] := &( cNomeWS + "_BRWHEADER():New()" )
					aHeader[nI]:cHEADERTITLE 	:= aUserField[nJ][nPos]:cUSERTITLE
					aHeader[nI]:cHEADERFIELD 	:= AllTrim( "U" + aUserField[nJ][nPos]:cUSERNAME )
					aHeader[nI]:cHEADERPICTURE	:= aUserField[nJ][nPos]:cUSERPICTURE
					aHeader[nI]:nHEADERSIZE 	:= aUserField[nJ][nPos]:nUSERSIZE
					aHeader[nI]:nHEADERDEC 		:= aUserField[nJ][nPos]:nUSERDEC
					aHeader[nI]:cHEADERTYPE		:= aUserField[nJ][nPos]:cUSERTYPE
					aHeader[nI]:lHEADEROBLIG 	:= aUserField[nJ][nPos]:lUSEROBLIG
					aHeader[nI]:cHEADERCOMBOBOX	:= aUserField[nJ][nPos]:cUSERCOMBOBOX
				Endif
			Endif
		Next nJ
	Endif
Next nI

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณParseGets บAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz um parse dos gets do link F3                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ParseGets()

Local aRet := { {}, {} }
Local aTemp1 := {}
Local aTemp2 := {}
Local nI := 0, nTam := Len( HttpGet->aGets )

For nI := 1 To nTam
	If Upper( SubStr( HttpGet->aGets[nI], 1, 5 ) ) = "CMPWS"
		AAdd( aTemp1, &( "HttpGet->" + HttpGet->aGets[nI] ) )
	ElseIf Upper( SubStr( HttpGet->aGets[nI], 1, 7 ) ) = "CMPDEST"
		AAdd( aTemp2, &( "HttpGet->" + HttpGet->aGets[nI] ) )
	ElseIf Upper( SubStr( HttpGet->aGets[nI], 1, 6 ) ) = "GRIDF3"
		AAdd( aRet[2], &( "HttpGet->" + HttpGet->aGets[nI] ) )
	Endif
Next nI

nTam := Len( aTemp1 )

If nTam == 0
	Return HttpSession->PGETS
Else
	If nTam == Len( aTemp2 )
		For nI := 1 To nTam
			AAdd( aRet[1], { aTemp1[nI], aTemp2[nI] } )
		Next nI
		HttpSession->PGETS := aRet
	Else
		//Erro de parametros
	Endif
Endif

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMntLinkF3 บAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta link F3                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1: Parametros da montagem do link F3                    บฑฑ
ฑฑบ          ณ ExpC2: Sufixo                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MntLinkF3( aParam, cSuffix )

Local nWs 		:= 0
Local nTamWs 	:= Len(aParam[1])
Local nGrid 	:= 0
Local nTamGrid 	:= Len(aParam[2])
Local cRet 		:= "W_PWSXF3000.APW?F3Nome=" + aParam[1][1] + "&"

cSuffix := IIF( Empty(cSuffix), "", "_" + cSuffix )

For nWs := 2 To nTamWs
	cRet += "CMPWS"   + AllTrim(Str(nWs-1)) + "=" + aParam[1][nWs][2] + "&"
	cRet += "CMPDEST" + AllTrim(Str(nWs-1)) + "=" + aParam[1][nWs][1] + cSuffix + "&"
Next nWs

For nGrid := 1 To nTamGrid
	cRet += "GRIDF3" + AllTrim(Str(nGrid)) + "=" + aParam[2][nGrid] + "&"
Next nGrid

Return SubStr( cRet, 1, Len( cRet )-1 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSPutUsr บAutor  ณLuiz Felipe Couto    บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Popula os dados do WebServices com os campos de usuario     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1: Session com o WebServices                            บฑฑ
ฑฑบ          ณ ExpC2: Alias da tabela dos Campos de Usuario                บฑฑ
ฑฑบ          ณ ExpC3: Nome do WebServices com os Campos de Usuario         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PWSPutUsrFld( oSession, cAlias, cWS )

Local nI := 0
Local oObjCfg

oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL( @oObjCfg, "CFGDICTIONARY.APW" )

aProp 	:= ClassDataArr( oSession )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

oObjCfg:cUSERCODE 	:= GetUsrCode()
oObjCfg:cALIAS		:= cAlias

//cUSERCODE,cALIAS
If oObjCfg:GETUSERFIELD()
	aProp[nPos][2] := &( cWS + "_ARRAYOFUSERFIELD():New()" )
	
	For nI := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
		AAdd( aProp[nPos][2]:oWSUSERFIELD, &( cWS + "_USERFIELD():New()" ) )
		
		aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERDEC
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERNAME
		aProp[nPos][2]:oWSUSERFIELD[nI]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:lUSEROBLIG
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERPICTURE
		aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERSIZE
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTAG
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTITLE
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTYPE
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERCOMBOBOX	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERCOMBOBOX
	Next nI
Endif

Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} PWSXFUN

Popula os dados do WebServices com os campos de usuario do Portal do Vendedor

@sample	PWSSetObjToPost( HttpSession->PWSV044GRAVA[1], HttpSession->PWSV042HEADER[1][1], HttpPost->aPost )

@param		ExpO1 - Sessใo do WebService
@param      ExpC2 - Alias
@param 		ExpC3 - Nome do WebService	

@return	ExpA - Array jแ populado com os dados dos campos de usuario

@version	12
/*/
//------------------------------------------------------------------------------
Function PWVPutUsrFld( oSession, cAlias, cWS )

Local nI := 0
Local oObjCfg

oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL( @oObjCfg, "CFGDICTIONARY.APW" )

aProp 	:= ClassDataArr( oSession )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

oObjCfg:cUSERCODE 	:= GetUsrCode()
oObjCfg:cALIAS		:= cAlias

//cUSERCODE,cALIAS
If oObjCfg:GETUSERFIELD()
	aProp[nPos][2] := &( cWS + "_ARRAYOFUSERFIELD():New()" )
	
	For nI := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
		AAdd( aProp[nPos][2]:oWSUSERFIELD, &( cWS + "_USERFIELD():New()" ) )
		
		aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERDEC
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERNAME
		aProp[nPos][2]:oWSUSERFIELD[nI]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:lUSEROBLIG
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERPICTURE
		aProp[nPos][2]:oWSUSERFIELD[nI]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:nUSERSIZE
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTAG
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTITLE
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERTYPE
		aProp[nPos][2]:oWSUSERFIELD[nI]:cUSERCOMBOBOX	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nI]:cUSERCOMBOBOX
	Next nI
Endif

Return aProp


//-------------------------------------------------------------------
/*/{Protheus.doc} function GetAuthWs(cService)
Rotina para instanciar e autenticar os webservices
@author  Gisele Nuncherino
@since   25/09/2020
/*/
//-------------------------------------------------------------------
Function GetAuthWs(cService)

Local oObj			:= NIL
Local oServer		:= NIL
Local aIniSessions 	:= GetIniSessions(GetADV97())
Local nT 			:= 0
Local nRPCPort 		:= 0
Local aEnv			:= {}
Local cPesqWeb		:= ""
Local cJobs			:= ""
Local cRpcServer 	:= ""
Local cRPCEnv 		:= ""

if empty(cService)
	Conout(OEMToAnsi(STR0002)) // "[GetAuthWs] - Servi็o nใo informado"
	return Nil
Endif

If ValType(cAuthWS) == "U"
	
	cAuthWS := ''
	
	If Type("cModulo") == "U"
		For nT:=1 To Len(aIniSessions) 
			cJobs := GetPvProfString( aIniSessions[nt] , "ONCONNECT", '', GetADV97() )
			If cJobs == '__WSCONNECT'
				cPesqWeb:= GetPvProfString( aIniSessions[nt] , "PREPAREIN", '', GetADV97() )
				If !Empty(cPesqWeb)
					Exit
				EndIf
			EndIf
		Next

		// Quando WebService for exclusivo buscar o Server/Porta do servi็o
		If Empty(cPesqWeb) 
			For nT:=1 To Len(aIniSessions)
				cJobs := GetPvProfString( aIniSessions[nt] , "ONCONNECT", '', GetADV97()) 
				If cJobs == 'CONNECTWEBEX'
					cRpcServer	:= GetPvProfString( aIniSessions[nt] , "SERVERWS", '', GetADV97())
					nRPCPort	:= Val(GetPvProfString( aIniSessions[nt] , "PORTWS", '', GetADV97()))
					cRPCEnv		:= GetPvProfString( aIniSessions[nt] , "ENVIRONMENT", '', GetADV97())
					If !Empty(cRpcServer) .And. !Empty(nRPCPort) .And. !Empty(cRPCEnv)
						Exit
					EndIf
				EndIf
			Next

			oServer := TRPC():New( cRPCEnv )
			If oServer:Connect( cRpcServer, nRPCPort ) 		
				cPesqWeb := oServer:CallProc("fRPCWS")  	
				oServer:Disconnect()
			Else
				Conout(OEMToAnsi(STR0008)) //"[GetAuthWs] - Conexใo indisponํvel com o WebService"   
				Return Nil	
			EndIf
		EndIf

		if !empty(cPesqWeb)
			aEnv := StrTokArr( cPesqWeb , "," )
			if len(aEnv) >= 2
				cEmpresa := alltrim(aEnv[1])
				cUnidade  := alltrim(aEnv[2])
			else
				Conout(OEMToAnsi(STR0005)) //""[GetAuthWs] - Dados de conexao invalidos"   
				return Nil			
			endif
		endif

		if Empty(cEmpresa) .or. Empty(cUnidade)
			Conout(OEMToAnsi(STR0005)) //""[GetAuthWs] - Dados de conexao invalidos"   
			return Nil
		Endif

		RPCSETTYPE(3)
		PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cUnidade 

		cAuthWS := SuperGetMV("MV_AUTHWS",.F.,"")

		RESET ENVIRONMENT
	else
		cAuthWS := SuperGetMV("MV_AUTHWS",.F.,"")
	Endif

	oObj :=  &( alltrim(cService) + "():New()" ) 

	if !Empty(cAuthWS) 
		oObj:_HEADOUT :=  { "Authorization: BASIC "+ ENCODE64(rc4crypt( cAuthWS ,"AuthWS#ReceiptID", .F.,.T.)) }
	endif

else
	oObj :=  &( alltrim(cService) + "():New()" ) 
	if !Empty(cAuthWS) 
		oObj:_HEADOUT :=  { "Authorization: BASIC "+ ENCODE64(rc4crypt( cAuthWS ,"AuthWS#ReceiptID", .F.,.T.)) }
	endif
Endif

return oObj

//-------------------------------------------------------------------
/*/{Protheus.doc} function fRPCWS()
Fun็ใo para capturar conte๚do do PREPARE IN de WebService exclusivo
@author  raquel.andrade
@since   01/06/2020
/*/
//-------------------------------------------------------------------
Function fRPCWS()
Local aIniSessions 	:= GetIniSessions(GetADV97())
Local nT 			:= 0
Local cPesqWeb		:= ""
Local cJobs			:= ""
	
	// Acesso appserver.ini do WS exclusivo
	For nT:=1 To Len(aIniSessions) 
		cJobs := GetPvProfString( aIniSessions[nt] , "ONCONNECT", '', GetADV97() )
		If cJobs == '__WSCONNECT'
			cPesqWeb:= GetPvProfString( aIniSessions[nt] , "PREPAREIN", '', GetADV97() )
			If !Empty(cPesqWeb)
				Exit
			EndIf
		EndIf
	Next		

Return ( cPesqWeb )
