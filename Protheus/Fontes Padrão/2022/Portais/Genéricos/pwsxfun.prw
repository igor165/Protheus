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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GridHeader�Autor  �Luiz Felipe Couto    � Data �  10/12/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina para trazer o nome dos campos do Header              ���
��������������������������������������������������������������������������͹��
���Parametros� ExpA1: Array para disponibilizacao HTML                     ���
���          � ExpA2: Header                                               ���
���          � ExpA3: Campos a serem mostrados                             ���
���          � ExpO4: Objeto com os campos de usuario                      ���
���          � ExpC5: Nome do WS para controle dos campos do usuario       ���
���          � ExpC6: Alias da tabela para controle dos campos do usuario  ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GridLinesE�Autor  �Luiz Felipe Couto    � Data �  15/07/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina para criacao dos campos dinamicamente                ���
��������������������������������������������������������������������������͹��
���Parametros�ExpA1: [1] Array para disponibilizacao HTML                  ���
���          �       [2] Header                                            ���
���          �       [3] Valores a serem mostrados                         ���
���          �       [4] Campos a serem mostrados                          ���
���          �       [5] Campo para inclusao ou visualizacao               ���
���          �           .T. - inclusao                                    ���
���          �           .F. - visualizacao                                ���
���          �       [6] Html ou Array                                     ���
���          �           H - Html                                          ���
���          �           A - Array                                         ���
���          �       [7] Sufixo para diferenciacao                         ���
���          �       [8] Parametro para uso do objeto javascript           ���
���          �       [9] Parametro para utilizar a gridlines em uma linha  ���
���          �ExpA2: [1] Cor fundo tabela                                  ���
���          �       [2] Estilo fonte ( inclusao / alteracao )             ���
���          �       [3] Estilo fonte obrigatorio                          ���
���          �       [4] estilo fonte visualizacao                         ���
���          �       [5] estilo texto                                      ���
���          �       [6] estilo select                                     ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �11/09/06|104540|Tratamento para evitar "Array out of bounds" ���
���          �        �      �no uso do aTmpUsrFld.                        ���
���Cleber M. �11/09/06|104546|Protecao no fonte para evitar erros de posi- ���
���          �        �      �coes de array nao existentes.                ���
���Tatiana C.�09/02/07|118306|Tratamento para permitir a inclusao de campo ���
���          �        �      �Memo por usu�rio.                            ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
	conout( "Para o retorno em HTML n�o utilize a fun��o GridHeader." )
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ParseWebCo�Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Faz um parse dos WebCols para utilizacao da customizacao do ���
���          � portal                                                      ���
��������������������������������������������������������������������������͹��
���Parametros� ExpA1: Array com os campos a serem mostrados na tela        ���
���          � ExpC2: Sufixo                                               ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MntWebCols�Autor  �Luiz Felipe Couto    � Data �  16/12/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina para montagem dos WebCols                            ���
��������������������������������������������������������������������������͹��
���Parametros� ExpA1: Array com os webcols                                 ���
���          � ExpO2: Header do objeto                                     ���
���          � ExpA3: Array com os userfields                              ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
���2481-Paulo Vieira 01/10/2007 / 130816 / 811R4 - Adicionada cla�sula para���
���	  verificar se � campo de usu�rio ("U") pois n�o estava achando o campo���
���   campo e duplicava-o na rela��o de campos utilizados nas colunas.	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSHtmInEx�Autor  �Luiz Felipe Couto    � Data �  16/12/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina para montagem dos GETS                               ���
��������������������������������������������������������������������������͹��
���Parametros� ExpO1: Objeto WS                                            ���
���          � ExpC2: Valor para colocar no input                          ���
���          � ExpC3: Sufixo                                               ���
���          � ExpA4: Array com os webcols                                 ���
���          � ExpL5: Parametro de userfield                               ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �16/10/06|106875|Correcao no retorno da calculadora/calendario���
���          �        �      �para campos de usuario.                      ���
��������������������������������������������������������������������������͹��
���Tatiane M.�02/04/07|122153|Substitui��o do atributo alt da imagem para  ���
���          �        �      �o atributo title. Para Firefox o alt n�o fun-���
���          �        �      �ciona, por isso precisei alterar para title  ���
���          �        �      �que funciona tanto para Firefox como IE.     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function PWSHtmInEx( 	oObjHeader, cValue, cSuffix, aWebCols,;
								lUserField, lEdit )

Local cHtmlInput 	:= ""                            //Retorno da funcao
Local cPicture		:= AllTrim( oObjHeader:cHEADERPICTURE )//Picture do campo
Local cTmpPicture									// picture tempor�ria com a formata��o para o pa�s especif�co
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
						cHtmlInput += '<img src="' + cImagem + '/ico-calendario.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCALE.apw?Month=" + AllTrim( Str( Month( date() ) - 1 ) ) + "&Year=" + AllTrim( Str( Year( date() ) ) ) + "&CMPDEST=" + cCampo + cSuffix + "', 'jF3', 'width=350,height=270,scrollbars=no');" + '" align="middle" title="Calend�rio" disabled>'
					Else
						cHtmlInput += '<img src="' + cImagem + '/ico-calendario.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCALE.apw?Month=" + AllTrim( Str( Month( date() ) - 1 ) ) + "&Year=" + AllTrim( Str( Year( date() ) ) ) + "&CMPDEST=" + cTipoCampo + cCampo + cSuffix + "', 'jF3', 'width=350,height=270,scrollbars=no');" + '" align="middle" title="Calend�rio" disabled>'
					EndIf
				Else	
					If lUserField
						cHtmlInput += '<img src="' + cImagem + '/ico-calendario.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCALE.apw?Month=" + AllTrim( Str( Month( date() ) - 1 ) ) + "&Year=" + AllTrim( Str( Year( date() ) ) ) + "&CMPDEST=" + cCampo + cSuffix + "', 'jF3', 'width=350,height=270,scrollbars=no');" + '" style="cursor:hand" align="middle" title="Calend�rio">'
					Else
						cHtmlInput += '<img src="' + cImagem + '/ico-calendario.gif" border="0" onClick="' + "javascript:window.open('h_PWSXCALE.apw?Month=" + AllTrim( Str( Month( date() ) - 1 ) ) + "&Year=" + AllTrim( Str( Year( date() ) ) ) + "&CMPDEST=" + cTipoCampo + cCampo + cSuffix + "', 'jF3', 'width=350,height=270,scrollbars=no');" + '" style="cursor:hand" align="middle" title="Calend�rio">'
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSHtmCoEx�Autor  �Luiz Felipe Couto    � Data �  17/12/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina para montagem dos COMBOS                             ���
��������������������������������������������������������������������������͹��
���Parametros� ExpO1: Header                                               ���
���          � ExpC2: Valor                                                ���
���          � ExpC3: Sufixo                                               ���
���          � ExpA4: Array com webcols                                    ���
���          � ExpC5: Valores do Combo                                     ���
���          � ExpL6: Parametro para userfield                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

		//DOCUMENTTYPE EM CASOS DE PR�-NOTA NO PORTAL DO FORNECEDOR
		//NUNCA S�O EM FORMULARIO PR�PRIO
		If AWEBCOLS[1]=="DOCUMENTTYPE"
			aTemp := {"N=N�o"}
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSXTransf�Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Aplica picture ao valor passado por parametro               ���
��������������������������������������������������������������������������͹��
���Parametros� ExpC1: Valor a ser aplicado a picture                       ���
���          � ExpC2: Picture de retorno                                   ���
���          � ExpC3: Sinaliza se � um campo hidden. Default: .F.          ���
���          � ExpC4: Sinaliza se texto para ser exibido diretamente no	   ���
���          		c�digo HTML (sem ser em elementos <input ou <textarea>.���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Tatiana C.�12/02/07|118356|Alteracao para nao buscar a picture de campos���
���          �        | 8.11 |novamente na montagem da tela HTML.          ���
���Paulo Vier�11/10/07|131300|Alteracao para contemplar a picture utilizada���
���          �        | 8.11 |na formata��o dos valores (adjustPictValue)  ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
function PWSXTransform( xValor, cPicture, alHidden, alHtmlCode )

default alHidden := .F.
default alHtmlCode := .F.
	
//������������������������������������������Ŀ
//� Tratamento para tirar o '-' do campo CEP �
//��������������������������������������������
If AllTrim(Upper(cPicture)) == "@R 99999-999"
	xValor := Replace(xValor,"-","")
EndIf

xValor := Transform( xValor, cPicture )

if !alHidden
	xValor := adjustPictValue(xValor)
endif

if alHtmlCode
	// transforma quaisquer c�digos de "nova linha" em c�digo html de "nova linha"
	xValor := strTran(xValor, LF, HTML_LF)
endif

Return xValor

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSXTransf�Autor  �Paulo R Vieira       � Data �  11/10/07   ���
��������������������������������������������������������������������������͹��
���Desc.     � Ajusta o valor passado conforme o idioma e a picture utiliza���
���          � pelo usu�rio (rpo)                                          ���
��������������������������������������������������������������������������͹��
���Parametros� ExpC1: Valor a ser ajustado a picture                       ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���          �        |      |                                             ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GeraJS    �Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Gera os scripts para utilizacao da tela do Portal           ���
��������������������������������������������������������������������������͹��
���Parametros� ExpA1: Array de F3                                          ���
���          � ExpA2: Array de retorno                                     ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GetJsGridL�Autor  �Luiz Felipe Couto    � Data �  16/12/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna os codigos javascript para a tela do Portal         ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function GetJsGridLines()

Return HttpSession->_TMPJS

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSGetWsEr�Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina de recuperacao do erro de execucao do WebServices    ���
��������������������������������������������������������������������������͹��
���Parametros� ExpC1: Mensagem do erro interno                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function PWSGetWSError( cMsgInternal )

Local cMsgError := GetWscError( 3 )	// Soap_fault

If Empty( cMsgError )
	cMsgError := GetWscError( 1 ) //Client
Endif

cMsgError := EncodeUTF8(cMsgError)

Return cMsgError

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSHtmlAle�Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de Erro utilizada para todas as rotinas do Portal,     ���
���          � inclusive para erros de WebServices (Server e Client)       ���
��������������������������������������������������������������������������͹��
���Parametros� ExpC1: Mensagem do erro interno                             ���
���          � ExpC2: Cabecalho                                            ���
���          � ExpC3: Mensagem de erro a ser apresentada na tela           ���
���          � ExpC4: Pagina de volta                                      ���
���          � ExpL5: Determina se apresenta a tela inicial                ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSSetObjT�Autor  �Luiz Felipe Couto    � Data �  16/12/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina para preencher as propriedades dos objetos com o post���
���          � inclusive para erros de WebServices (Server e Client)       ���
��������������������������������������������������������������������������͹��
���Parametros� ExpO1: Objeto a ser populado com os dados do post           ���
���          � ExpA2: Header                                               ���
���          � ExpA3: Post                                                 ���
���          � ExpC4: Sufixo                                               ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���A.Veiga   �17/04/06� 8.11 �BOPS 96697 - Tratamento do campo MEMO do     ���
���          �        �      �cadastro de oportunidades. Se, na inclusao,  ���
���          �        �      �o campo "Notas" estivesse em branco, aparecia���
���          �        �      �o erro: "invalid property MNOTES" nao permi- ���
���          �        �      �tindo a confirmacao da oportunidade.         ���
���Cleber M. �15/09/06�102906�Alteracao da variavel cUSERTAG de NIL para ""���
���          �        �  8.11�a fim de exibir corretamente os campos de    ���
���          �        �      �usuario que estao como Disable.              ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
				
			// Se o tipo do campo for "M" (memo), redefine como "C" (caracter) porque �
			// no webbrowser o campo e' tratado como caracter.                        �
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GetImgProd�Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina de recuperacao da imagem do produto                  ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �IsImgProd �Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina para verificacao se o produto possui imagem          ���
���          � cadastrada                                                  ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function IsImgProd()

Return !Empty( HttpSession->_IMG_PROD )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �GetImgInst�Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina de recuperacao da imagem do institucional            ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �SigaPPStar�Autor  � Julio Wittwer       � Data �  25/02/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Funcao de Inicializacao adicional de Ambiente WEB (Start)   ���
���          � da Working Thread. Executada no momento do START da Working ���
���          � Thread                                                      ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

//�������������������������������������������������������������������Ŀ
//�Tratamento do ponto de entrada para alterar a descricao do portal  �
//���������������������������������������������������������������������
If ExistBlock("GCH001")
	aStrings := ExecBlock( "GCH001", .F., .F.) 
	__xCHGHCons(aStrings)
Endif


Return .T.


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �SigaPPConn�Autor  � Julio Wittwer       � Data �  25/02/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Funcao executada antes do processamento de qualquer link    ���
���          � .apw                                                        ���
��������������������������������������������������������������������������͹��
���Parametros� ExpC1: Funcao Principal                                     ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function SigaPPConnect( cFnMain )
	
HeadNoCache()

Return ''

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �HeadNoCach�Autor  � Julio Wittwer       � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Funcao para nao armazenar cache de Browser                  ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function HeadNoCache()
 
HttpHeadOut->Expires 		:= "Mon, 26 Jul 1997 05:00:00 GMT "
HttpHeadOut->Last_Modified 	:= TransData()
HttpHeadOut->Cache_Control 	:= "no-store, no-cache, must-revalidate, post-check=0, pre-check=0;"
HttpHeadOut->pragma 		:= "no-cache"

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �TransData �Autor  � Luiz Felipe Couto   � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Funcao para trocar a data para utilizacao do HeadNoCache    ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �SetEstilo �Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Define o o estilo do Portal                                 ���
��������������������������������������������������������������������������͹��
���Parametros� ExpA1: Array com os estilos do Portal                       ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function SetEstilo( aEst )

aEstilo := aClone( aEst )

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PutHeadUsr�Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Rotina de inclusao dos campos de usuario no Header          ���
��������������������������������������������������������������������������͹��
���Parametros�ExpA1: Header                                                ���
���          �ExpA2: Array com os campos de usuario                        ���
���          �ExpA3: Array com os campos a serem mostrados na tela         ���
���          �ExpC4: Nome WebServices                                      ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ParseGets �Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Faz um parse dos gets do link F3                            ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �MntLinkF3 �Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Monta link F3                                               ���
��������������������������������������������������������������������������͹��
���Parametros� ExpA1: Parametros da montagem do link F3                    ���
���          � ExpC2: Sufixo                                               ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSPutUsr �Autor  �Luiz Felipe Couto    � Data �  06/10/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Popula os dados do WebServices com os campos de usuario     ���
��������������������������������������������������������������������������͹��
���Parametros� ExpO1: Session com o WebServices                            ���
���          � ExpC2: Alias da tabela dos Campos de Usuario                ���
���          � ExpC3: Nome do WebServices com os Campos de Usuario         ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

@param		ExpO1 - Sess�o do WebService
@param      ExpC2 - Alias
@param 		ExpC3 - Nome do WebService	

@return	ExpA - Array j� populado com os dados dos campos de usuario

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
	Conout(OEMToAnsi(STR0002)) // "[GetAuthWs] - Servi�o n�o informado"
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

		// Quando WebService for exclusivo buscar o Server/Porta do servi�o
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
				Conout(OEMToAnsi(STR0008)) //"[GetAuthWs] - Conex�o indispon�vel com o WebService"   
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
Fun��o para capturar conte�do do PREPARE IN de WebService exclusivo
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
