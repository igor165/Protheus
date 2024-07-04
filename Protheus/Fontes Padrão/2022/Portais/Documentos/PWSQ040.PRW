#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "FILEIO.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSQ040   ºAutor  ³Telso Carneiro      º Data ³  22/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina iframe inicial de item Documentos                   º±±
±±º          ³ Resultado do filtro                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal QDO                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSQ040()

Local cHtml 		:= ""
Local oObj
Local cNomDoc		:= Alltrim(HttpGet->cNomDoc)
Local cBaixa		:= IF(Alltrim(HttpGet->lbaixa)=='true','S','N')
Local cFilCodRv		:= HttpGet->cFilCodRv
Local cQPath		:= HttpSession->WSQDO20QDOPATH[1]
Local cQPathHtm		:= HttpSession->WSQDO20QDOPATH[5]
Local cUsaHTML		:= HttpSession->WSQDO20QDOPATH[9]
Local cPathDoc		:= ""
Local cDBuffer		:= ""
Local hArq
Local cExt			:= ""
Local cFile			:= ""
Local lLiberado		:=.T.
Local nTam			:= 0
Local nX			:= 0
Local nT			:= 0
Local oAFilelst
Local aIniSessions	:= GetIniSessions(GetADV97())
Local cPathWebPP	:=""
Local cMyWebJOB		:= GETWEBJOB()
Local nDirHtml

WEB EXTENDED INIT cHtml
nPosSeSession:=0
For nT:=1 To Len(aIniSessions)
	cPesqWeb:= GetPvProfString( aIniSessions[nt] , "SIGAWEB", '(empty)', GetADV97() )
	IF cPesqWeb=="PP"
		For nX:=1 To Len(aIniSessions)
			cPesqWeb:= GetPvProfString( aIniSessions[nX] , "RESPONSEJOB", '(empty)', GetADV97() )
			IF cPesqWeb==cMyWebJOB
				nPosSeSession:=nX
				Exit
			Endif
		Next
	Endif
	IF nPosSeSession<>0
		Exit
	Endif
Next
cPathWebPP:= GetPvProfString( aIniSessions[nPosSeSession] , "PATH", '(empty)', GetADV97() )
cEnvWebPP := GetPvProfString( aIniSessions[nPosSeSession] , "ENVIRONMENT", '(empty)', GetADV97() )
cRootSrv  := GetPvProfString( cEnvWebPP , "RootPath", '(empty)', GetADV97() )
cPathWebPP:=STUFF(cPathWebPP,AT(cRootSrv,cPathWebPP),Len(cRootSrv),"")

cPathWebPP:=IF(Left(cPathWebPP,1)<>"\","\"+cPathWebPP,cPathWebPP)
cPathWebPP+=IF(Right(cPathWebPP,1)<>"\","\","")

//Pacotes de Texto
//'text/html' - Indica um conteúdo Html texto.
//'text/text'  - Indica um pacote qualquer do tipo texto.

//Pacotes de Imagem
//'image/gif' - Indica uma imagem do tipo .gif
//'image/jpeg' - Indica uma imagem do tipo .jpeg

//Pacotes Binários
//'application/xbitmap' - Indica um pacote do tipo bitmap
//'application/zip' - Indica um pacote compactado pelo executavél zip
//'application/octet-stream' - Indica como retorno um pacote qualquer mas binário

cPathDoc:=cQPath
cDisp:='attachment'

cExt:=Lower(Right(AllTrim(cNomDoc),3))
Do Case
	Case cExt=="cel"
		cType:='text/html'
		cDisp:='inline'
		IF cUsaHTML=="1"
			cNomDoc:=FileNoExt(cNomDoc)+".htm"
			cPathDoc:=cQPathHtm
		Else
			cHtml +="O Documento "+cFilCodRv+" não pode ser aberto no Portal QDO, Somente Novas Revisões com o parametro MV_QDHTML ativado."
			lLiberado:=.F.
		Endif
	Case cExt=="pdf"
		cType:='application/octet-stream'
		cDisp:='inline'
	Case cExt=="htm"
		cType:='text/html'
		cDisp:='inline'
	Case cExt=="txt"
		cType:='text/text'
	Case cExt=="bmp"
		cType:='application/xbitmap'
	Case cExt=="jpg"
		cType:='image/jpeg'
	Case cExt=="zip"
		cType:='application/zip'
	OtherWise
		cType:='application/octet-stream'
EndCase

IF lLiberado
	oObj := WSQDODOCUMENTS():New()
	oObj:cUSERCODE 	:= httpSession->USR_INFO[1]:cUserCode // Usuario do Portal
	oObj:CNOMDOC 	:= cNomDoc
	oObj:CPATCHDOC	:= cPathDoc
	
	nFByte:=0
	nHandle:= FCREATE(cNomDoc,FC_NORMAL)
	IF nHandle <> -1
		cDBuffer:="1"
		While !Empty(cDBuffer)
			oObj:NOFFSET:= nFByte
			IF !oObj:GetQDOFiles() //copia o arquivo do documento
				cHtml +="O Documento "+cFilCodRv+" não pode ser aberto no Portal QDO, Somente Novas Revisões com o parametro MV_QDHTML ativado."
				lLiberado:=.F.
				Exit
			Endif
			
			IF Len(oObj:oWSGETQDOFILESRESULT:oWSABUFFERVIEW) ==0
				cDBuffer:=""
			Else
				For nX:=1 To Len(oObj:oWSGETQDOFILESRESULT:oWSABUFFERVIEW)
					cDBuffer:=oObj:oWSGETQDOFILESRESULT:oWSABUFFERVIEW[nX]:CBUFFER
					
					IF Alltrim(cDBuffer)<>""
						FWRITE( nHandle,cDBuffer  )
					Endif
				next
			Endif
			nFByte+=512000  //500 Kb
		Enddo
		FCLOSE( nHandle )
	Endif
	
	IF lLiberado
				
		cExt:=Lower(Right(AllTrim(cNomDoc),3))
		IF cExt=="htm"
			IF !oObj:GetQDOlsHtm() //lista os arquivos htm-gif-jpg
				cHtml +="A(s) Imagen(s) do Documento "+cFilCodRv+" não pode(m) ser aberto(as) no Portal QDO, Somente Novas Revisões com o parametro MV_QDHTML ativado."
			Else
				oAFilelst:=oObj:oWSGETQDOLSHTMRESULT:oWSAFILEHTMQVIEW
				IF Len(oAFilelst) > 0
					cDir:=oAFilelst[1]:CFILEHTM
					If ( nDirHtml:=	MakeDir(cPathWebPP+cDir) ) == 0
						oObj:CPATCHDOC := cPathDoc+cDir+"\"
						For nT:=2 TO Len(oAFilelst)
							cArq:=oAFilelst[nT]:CFILEHTM
							oObj:CNOMDOC:= cArq
							nFByte:=0
							nHandle:= FCREATE(cPathWebPP+cDir+"\"+cArq,FC_NORMAL)
							IF nHandle <> -1
								cDBuffer:="1"
								While !Empty(cDBuffer)
									oObj:NOFFSET:= nFByte
									IF !oObj:GetQDOFiles() //copia o arquivo do documento
										cHtml +="O Documento "+cFilCodRv+" não pode ser aberto no Portal QDO, Somente Novas Revisões com o parametro MV_QDHTML ativado."
										Exit
									Endif
									
									IF Len(oObj:oWSGETQDOFILESRESULT:oWSABUFFERVIEW) ==0
										cDBuffer:=""
									Else
										For nX:=1 To Len(oObj:oWSGETQDOFILESRESULT:oWSABUFFERVIEW)
											cDBuffer:=oObj:oWSGETQDOFILESRESULT:oWSABUFFERVIEW[nX]:CBUFFER
											
											IF Alltrim(cDBuffer)<>""
												FWRITE( nHandle,cDBuffer  )
											Endif
										next
									Endif
									nFByte+=512000  //500 Kb
								Enddo
								FCLOSE( nHandle )
							Endif
						Next
					Endif
				Endif
			Endif
		Endif
		
		cFile:=cNomDoc
		
		If !file(cFile)
			cHtml += 'Arquivo '+cFile+' não encontrado.'
		ElseIf (hArq := FOpen(cFile)) < 0
			cHtml += 'Falha na Abertura do Arquivo '+cFile+' ( FERROR '+str(ferror(),4)+' )'
		Else
			
			nTam := FSeek(hArq, 0, 2)
			FSeek(hArq, 0, 0 )
			
			HttpSetPart(.T.)
			HttpCTType(cType)
			HttpCTDisp(cDisp+'; filename="'+cNomDoc+'"')
			HttpCTLen(nTam)
			
			cBuffer:=Space(1024000) // 1Mb
			While FRead(hArq, @cBuffer, 1024000)>0
				HttpSend(cBuffer)
			EndDo
			FClose(hArq)
		Endif
		FERASE(cNomDoc)
		
		IF cBaixa=="S"
			oObj:CFILCODRV	:= cFilCodRv
			IF oObj:GetQDOBaixa() // baixa a pendencia
				aEval(httpSession->WSQDO20ACOLSCOMP,{|x| IF(x[1]+x[3]+x[4]==cFilCodRv .and. x[6]=="P",x[6]:="B","")})
			Endif
		Endif	
		
	Endif
Endif


cHtml += ExecInPage( "PWSQ040" )


WEB EXTENDED END

Return cHtml
