#Include "Protheus.ch"
#include "pmsxfune.ch"

Static cNaoApl		:= "00"
Static cNaoEnv		:= "01"
Static cEnvApro		:= "02"
Static cReprova		:= "03"
Static cAprovad		:= "04"
Static cMark  		:= "LBTIK"
Static cNoMark		:= "LBNO"
Static cCpoAjoF		:= Nil
Static cNoDelRec 	:= Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsStartEcm บAutor  ณMicrosiga           บ Data ณ  03/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que chama a funcao do Bi para enviar a solicitacao    บฑฑ
ฑฑบ          ณ ao ECM                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsStartEcm(  cTipProc, cCodPrt, cProcessID, cComments, aXml, aAttach, lComplete, nNextTask, aUsers, cUserEnv, cPwdEnv )
Local lRet		:= .T.
Local nPosErr		:= 0
Local nPosPrc		:= 0
Local aEcmRet		:= {}
Local aArea		:= GetArea()
Local cXml		:= AllTrim( PmsMntXml() )
Local aAJOData	:= StrToKArr( cCodPrt, "|" )
If !Empty(cXml)
	PmsAjtXml( aXml, @cXml )
	aEcmRet := BiStartTask(  cTipProc, cCodPrt, cProcessID, cComments,cXml, aAttach, lComplete, nNextTask, aUsers, cUserEnv, cPwdEnv )
	nPosErr	:= Ascan( aEcmRet , { | x |  AllTrim( Upper( x[ 01 ] ) ) == "ERROR" } )
	nPosPrc	:= Ascan( aEcmRet , { | x |  AllTrim( Upper( x[ 01 ] ) ) == "IPROCESS" } )
	If nPosErr > 0
		Help( " ", 1, "PMSSTARTECM",,aEcmRet[ nPosErr ][ 02 ] , 5 )
		lRet := .F.
	Else
		PmsAtuAjo( aAJOData, aEcmRet[ nPosPrc ][ 2 ] , 1 )
	EndIf
Endif
RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsAtuAjo บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de atualiza็ใo dos campos da tabela ajo apos o envio บฑฑ
ฑฑบ          ณpara o ECM                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsAtuAjo( aAJOData, cProcessId )
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAJOArea	:= {} 
Local cAJOFil		:= aAJOData[ 01 ]
Local cAJOPrj		:= aAJOData[ 02 ]
Local cAJORvs		:= aAJOData[ 03 ]
Local cAJOTrf		:= aAJOData[ 04 ]
Local cAJOItm		:= aAJOData[ 05 ]

dbSelectArea( "AJO" )
aAJOArea	:= AJO->(GetArea())
AJO->( dbSetOrder( 1 ) ) //AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA+AJO_ITEM
If AJO->( dbSeek( cAJOFil+cAJOPrj+cAJORvs+cAJOTrf+cAJOItm ) )
	RecLock( "AJO", .F. )
	AJO->AJO_STATUS	:= cEnvApro //Enviado para Aprovacao
	AJO->AJO_WFID		:= cProcessId
	AJO->AJO_INI		:= cUserName + Space( 3 ) + Dtoc( dDataBase )
	AJO->( MsUnLock() )
EndIf
RestArea(aAJOArea)

RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsAjtXml บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que carrega o xml que sera enviado ao ECM           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsAjtXml( aXml, cXml )
Local nInd	:= 0
For nInd := 1 To Len( aXml )
	cXml :=	StrTran( cXml, AllTrim( aXml[ nInd ][ 01 ] ), AllTrim( aXml[ nInd ][ 02 ] ) )
Next nInd
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsMntXml บAutor  ณMicrosiga           บ Data ณ  03/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que carrega o conteudo do parametro MV_PMSFECM      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsMntXml()
Local	cXml		:= ""
Local cFileXml	:= PmsGetFile()
If ValType(cFileXml) # "U"
	Ft_Fuse( cFileXml )
	Ft_FGoTop()
	While !Ft_FEof()
		cXml += PmsGetLXml()
		Ft_FSkip()
	EndDo
Endif
Return cXml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsGetFileบAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que verifica a existencia do arquivo do parametro    บฑฑ
ฑฑบ          ณMV_PMSFECM                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsGetFile( nOpcx )
Local cRet		:= Nil
Local cFileXml	:= Nil
Local cPathTmp	:= GetMv( "MV_PMSPECM",,"" )
Local cArqNome	:= GetMv( "MV_PMSFECM",,"PmsXmlEcm.Xml" )
Local cPathFile	:= AllTrim( IIf( Empty( cPathTmp ) , GetSrvProfString( "StartPath", "" ) ,cPathTmp ) )
Default	nOpcx	:= 1
cPathFile			:= cPathFile + IIf( SubStr( AllTrim( cPathFile ) , Len( cPathFile ), 1 ) == "\" , "", "\" )
cFileXml			:= cPathFile + cArqNome
If !File( cFileXml )
	nHdlMot := MSFCreate(cFileXml,0)//P11 - caso arquivo nao seja encontrado, serแ criado com base no parametro.
	IF nHdlMot == -1
		cFileXml	:= Nil
		Help( " ", 1, "PMSGETXML",,STR0045+ CRLF + STR0001+CRLF+STR0002, 5 ) //"Nใo foi possํvel enviar a tarefa ao ECM. O arquivo XML nใo foi  encontrado. Verifique os parametros MV_PMSPECM  e  MV_PMSFECM."Arquivo inexistente"##"Verifique"
		Final("Erro F_"+str(ferror(),2)+" em "+cArqNome)
	else	
	    fWrite(nHdlMot,'<?xml version="1.0" encoding="UTF-8"?>'+chr(13)+chr(10)+;
						  '<?xml-stylesheet type="text/xsl" href="checklist.xsl"?>'+chr(13)+chr(10)+;
						    '<PMSMONIT>'+chr(13)+chr(10)+;
								'<PROJETO>'+chr(13)+chr(10)+;
									'<value>cProjeto</value>'+chr(13)+chr(10)+;
								'</PROJETO>'+chr(13)+chr(10)+;
								'<RECURSO>'+chr(13)+chr(10)+;
									'<value>cRecurso</value>'+chr(13)+chr(10)+;
								'</RECURSO>'+chr(13)+chr(10)+;
								'<TAREFA>'+chr(13)+chr(10)+;
									'<value>cTarefa</value>'+chr(13)+chr(10)+;
								'</TAREFA>'+chr(13)+chr(10)+;
								'<DESCTAREFA>'+chr(13)+chr(10)+;
									'<value>cDesTaref</value>'+chr(13)+chr(10)+;
								'</DESCTAREFA>'+chr(13)+chr(10)+;
								'<TIPO>'+chr(13)+chr(10)+;
									'<value>cTipo</value>'+chr(13)+chr(10)+;
								'</TIPO>'+chr(13)+chr(10)+;
								'<DESCTIPO>'+chr(13)+chr(10)+;
									'<value>cDesTip</value>'+chr(13)+chr(10)+;
								'</DESCTIPO>'+chr(13)+chr(10)+;
								'<STATUS>'+chr(13)+chr(10)+;
									'<value>cStatus</value>'+chr(13)+chr(10)+;
								'</STATUS>'+chr(13)+chr(10)+;
								'<MEMOTAREFA>'+chr(13)+chr(10)+;
									'<value>cMemoTaref</value>'+chr(13)+chr(10)+;
								'</MEMOTAREFA>'+chr(13)+chr(10)+;
								'<MEMOOBS>'+chr(13)+chr(10)+;
									'<value>cMemoObs</value>'+chr(13)+chr(10)+;
								'</MEMOOBS>'+chr(13)+chr(10)+;	
								'</PMSMONIT>')
	endif    
	fClose(nHdlMot)
EndIf
Do Case
	Case nOpcx == 1
		cRet := cFileXml
	Case nOpcx == 2
		cRet := cPathFile
	Case nOpcx == 3
		cRet := cArqNome
EndCase
Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsGetLXmlบAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que abre o arquivo do parametro MV_PMSFECM e carregaบฑฑ
ฑฑบ          ณas informacoes no xml                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsGetLXml()
Local	cLinhaTmp	:= ""
Local	cLinhax	:= ""
cLinhaTmp	:= Ft_FReadLn()
If !Empty( cLinhaTmp )
	cIdent	:= SubStr( cLinhaTmp, 1, 1 )
	If Len( cLinhaTmp ) < 1023
		cLinhax	:= cLinhaTmp
	Else
		cLinAnt	:= cLinhaTmp
		cLinhax += cLinAnt
		Ft_FSkip()
		cLinProx:= Ft_FReadLn()
		If Len( cLinProx ) >= 1023 .And. SubStr( cLinProx, 1, 1 ) <> cIdent
			While Len( cLinProx ) >= 1023 .And. SubStr( cLinProx, 1, 1 ) <> cIdent .And. !FT_FEof()
				cLinhax += cLinProx
				Ft_FSkip()
				cLinProx	:= Ft_FReadLn()
				If Len( cLinProx ) < 1023 .And. SubStr( cLinProx, 1, 1 ) <> cIdent
					cLinhax	+= cLinProx
				EndIf
			EndDo
		Else
			cLinhax		+= cLinProx
		EndIf
	EndIf
EndIf
Return( cLinhax )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsGetEcm บAutor  ณMicrosiga           บ Data ณ  04/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsGetECM( xProc, xUser, xPwd )
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAJOArea	:= {}
Local nErrPos		:= 0
Local cErro		:= ""
Local cAviso		:= ""
Local oXml		:= Nil
Local xData		:= Nil
Local cAJOKey		:= Nil
Local cMatEcm		:= Nil
Local cDescEcm	:= Nil
Local cRetStat	:= Nil

dbSelectArea( "AJO" )
aAJOArea	:= AJO->(GetArea())
AJO->( dbSetOrder( 3 ) ) ////AJO_FILIAL+AJO_WFID
If ValType( xUser	) == "U" .Or. ValType( xPwd ) == "U"
	xUser	:= GetMv( "MV_USRECM" )
	xPwd	:= GetMv( "MV_PWDECM" )
EndIf
xData := BiGetCardData( AllTrim( xProc ), xUser, "MD5:"+Md5( xPwd ) )
If ValType( xData ) == "A"
	nErrPos := Ascan( xData, { | x | AllTrim( x[ 1 ] ) == "ERROR" } )
	Help( " ", 1, "PMSGETECM",, xData[ nErrPos ][ 02 ] , 5 )
	aRet := .F.
Else
	oXml  := XmlParser( xData,"_", @cErro, @cAviso )
	If Empty( cAviso + cErro )
		cRetStat := IIf( Empty( oXml:_PmsMonit:_Status:_Value:Text ), cEnvApro /* EnviadoP/ Aprovacao */,;
		IIf( AllTrim( oXml:_PmsMonit:_Status:_Value:Text ) == "N", cReprova /* Reprovado*/, cAprovad /* Aprovado*/ ) )
		If AJO->( dbSeek( xFilial( "AJO" ) + Padr( xProc, TamSx3( "AJO_WFID" )[ 1 ] ) ) )
			cRetStat := IIf( Empty( cRetStat ), AJO->AJO_STATUS, cRetStat )
			RecLock( "AJO", .F. )
			AJO->AJO_STATUS := cRetStat
			If cRetStat == cNaoEnv .Or. cRetStat == cEnvApro //Nao Enviado - Enviado para Aprovacao
				AJO->AJO_FIM	:= cCpoAjoF
			ElseIf cRetStat == cAprovad //Aprovado
				AJO->AJO_FIM	:= Lower( AllTrim( oXml:_PmsMonit:_Recurso:_Value:Text ) ) + Space( 3 ) + Dtoc( dDataBase )
			EndIf
			AJO->( MsUnLock() )
		EndIf
	EndIf
EndIf
RestArea(aAJOArea)

RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsJobECM บAutor  ณMicrosiga           บ Data ณ  03/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao utilizada no Schedule para receber a aprovacao/reproบฑฑ
ฑฑบ          ณvacao do ECM                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsJobEcm( xParams )
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aSM0Area	:= {}
Local xEmprJob	:= Nil
Local xFilJob		:= Nil
Local lOpenEmp	:= Nil
Local lMultEmp	:= Nil
Private nHdlLog	:= 0
Private cHdlLog	:= Nil
Private cPLogEcm	:= Nil
PmsInitVar( xParams, @xEmprJob, @xFilJob, @lOpenEmp, @lMultEmp )
If !PmsPrepAmb( xEmprJob, xFilJob, lOpenEmp, 1 )
	Help( " ", 1, "PMSJOBECM",, STR0003+" [ "+ xEmprJob +" ][ "+ xFilJob +" ]"+CRLF+STR0004+"[ "+ Dtoc( MsDate() ) +" ]/"+STR0005+"[ "+ Time() +" ] "+STR0006+" !" , 5 ) //"Nao foi possivel abrir empresa"##"Data"##"Hora"##"Verifique"
	lRet := .F.
Else
	OpenSm0()
	dbSelectArea( "SM0" )
	SM0->( dbSetOrder( 1 ) )
	aSM0Area	:= SM0->( GetArea() )
	cCpoAjoF	:= CriaVar( "AJO_FIM", .F. )
	If SuperGetMv("MV_PMSECML",.F.) 
		PmsCrtLog( 1, @nHdlLog, @cPLogEcm, @cHdlLog, Nil )
		PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, "================= "+STR0007+" =================" ) //"Variaveis para incializacao do ambiente"
		PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, STR0004+".....[ "+ Dtoc( MsDate() ) +" ]/"+STR0005+".....[ "+ Time() +" ]" ) //"Data"##"Hora"
		PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, STR0008+"......[ "+ xEmprJob +" ]") //"Empresa"
		PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, STR0009+".......[ "+ xFilJob +" ]") //"Filial"
		PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, STR0010+"....[ "+ IIf( lOpenEmp, STR0012, STR0013 ) +" ]") //"Inic. Amb"##"Sim"##"Nao"
		PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, STR0011+"....[ "+ IIf( lMultEmp, STR0012, STR0013 ) +" ]") //"Mult. Emp"##"Sim"##"Nao"
		PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, "==========================================================================" 	)
		PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, "======== "+STR0004+"[ "+ Dtoc( MsDate() ) +" ] / "+STR0005+"[ "+ Time() +" ] ==========" 	) //"Data"##"Hora"
		PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, STR0014+" [ "+ cEmpAnt +" ]/[ "+ cFilAnt +" ]"	 		) //"Processo executado na Empresa/Filial"
	Endif
	If lMultEmp
		SM0->( dbGoTop() )
		While SM0->( !Eof() )
			If !( SM0->M0_CODIGO+SM0->M0_CODFIL == cEmpAnt+cFilAnt )
				GetEmpr( SM0->M0_CODIGO+SM0->M0_CODFIL )
			EndIf
			PmsEcmProc()
			SM0->( dbSkip() )
		EndDo
	Else
		PmsEcmProc()
	EndIf
EndIf
If SuperGetMv("MV_PMSECML",.F.) 
	PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, STR0015+" [ "+ cEmpAnt +" ]/[ "+ cFilAnt +" ]" 		) //Processo finalizado na Empresa/Filial
	PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, "======== "+STR0004+"[ "+ Dtoc( MsDate() ) +" ] / "+STR0005+"[ "+ Time() +" ] ==========" 	) //"Data"##"Hora"
	PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, "==========================================================================" 	)
Endif
PmsPrepAmb( ,,, 2 )
RestArea( aSM0Area )
RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsCtrLog บAutor  ณMicrosiga           บ Data ณ  04/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsCrtLog( nOpcx, nHdlLog, cPLogEcm, cHdlLog, cTextlog )
Local lRet			:= .T.
Local cPathLog  := IIf( nOpcx == 1, PmsGetFile( 2 ), cPLogEcm )
Local cArqLog		:= IIf( nOpcx == 1, "PmsLogEcm.Log"+Dtos( dDataBase )+"_"+StrTran( Time(),":","")+".Log", cHdlLog )
If SuperGetMv("MV_PMSECML",.F.) 
	Do Case
		Case nOpcx == 1
				nHdlLog := MsFCreate( cPathLog + cArqLog, 0 )
				If nHdlLog < 0
					lRet := .F.
				Else
					cHdlLog		:= cArqLog
					cPLogEcm	:= cPathLog
					FClose( nHdlLog )
				Endif
		Case nOpcx == 2
			If FOpen( cPathLog + cArqLog, 2 ) < 0
				lRet := .F.
			Else
				FSeek( nHdlLog, 0, 2 )
				FWrite( nHdlLog, cTextLog + CRLF)
				FClose( nHdlLog )
			EndIf
		Case nOpcx == 3
			FClose( nHdlLog )
	EndCase
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsInitVarบAutor  ณMicrosiga           บ Data ณ  04/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as variaves recebidas atraves do job               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsInitVar( xParams, xEmprJob, xFilJob, lOpenEmp, lMultEmp )

If IsBlind() .Or. ValType( xParams ) == "A"
	xEmprJob 	:= IIf( ValType( xParams[ 01 ][ 01 ][ 01 ] ) == "U" .Or. Empty( xParams[ 01 ][ 01 ][ 01 ] ), "01", xParams[ 01 ][ 01 ][ 01 ] )
	xFilJob 	:= IIf( ValType( xParams[ 01 ][ 01 ][ 02 ] ) == "U" .Or. Empty( xParams[ 01 ][ 01 ][ 02 ] ), "01", xParams[ 01 ][ 01 ][ 02 ] )
	lOpenEmp	:= IIf( ValType( xParams[ 01 ][ 01 ][ 03 ] ) == "U" , .T. , xParams[ 01 ][ 01 ][ 03 ] )
	lMultEmp	:= IIf( ValType( xParams[ 01 ][ 01 ][ 04 ] ) == "U" , .T. , xParams[ 01 ][ 01 ][ 04 ] )
ElseIf ValType( xParams ) == "U"
	xEmprJob 	:= ""
	xFilJob		:= ""
	lOpenEmp	:= .F.
	lMultEmp	:= .F.
Else
	xEmprJob 	:= IIf( ValType( xParams[ 01 ][ 01 ][ 01 ] ) == "U" .Or. Empty( xParams[ 01 ][ 01 ][ 01 ] ), "01", xParams[ 01 ][ 01 ][ 01 ] )
	xFilJob 	:= IIf( ValType( xParams[ 01 ][ 01 ][ 02 ] ) == "U" .Or. Empty( xParams[ 01 ][ 01 ][ 02 ] ), "01", xParams[ 01 ][ 01 ][ 02 ] )
	lOpenEmp	:= IIf( ValType( xParams[ 01 ][ 01 ][ 03 ] ) == "U" , .T. , xParams[ 01 ][ 01 ][ 03 ] )
	lMultEmp	:= IIf( ValType( xParams[ 01 ][ 01 ][ 04 ] ) == "U" , .T. , xParams[ 01 ][ 01 ][ 04 ] )
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsECMProcบAutor  ณMicrosiga           บ Data ณ  03/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsEcmProc()
Local lRet				:= .T.
Local cQuery  		:= Nil
Local cLogEcm		:= Nil
Local nTotReg		:= 0
Local aAJOArea		:= {}		
Local aArea				:= GetArea()
Local cWorkAlias	:= GetNextAlias()
Local cPrcNamEcm	:= GetMv( "MV_PMSNPEC",,"")

dbSelectArea( "AJO" )
aAJOArea	:= AJO->(GetArea())
AJO->( dbSetOrder( 1 ) ) //AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA+AJO_ITEM
cQuery := " SELECT DISTINCT AJO.AJO_FILIAL, AJO.AJO_PROJET, AJO.AJO_REVISA, AJO.AJO_TAREFA, "+CRLF
cQuery += " 			AJO.AJO_ORDEM, AJO.AJO_ITEM, AJO.AJO_INI, AJO.AJO_FIM, AJO.AJO_MARK, AJO.AJO_STATUS, AJO.AJO_WFID, AJO.R_E_C_N_O_ AJORECNO "+CRLF
cQuery += " FROM "+ RetSQLName( "AJO" ) +" AJO "+CRLF
cQuery += " WHERE AJO.AJO_FILIAL = '"+ xFilial( "AJO" ) +"'	"+CRLF
cQuery += " 			AND AJO.AJO_PROJET BETWEEN '"+ CriaVar( "AJO_PROJET", .F. ) +"' AND '"+ Replicate( "Z", TamSx3( "AJO_PROJET" )[ 01 ] ) +"' "+CRLF
cQuery += " 			AND AJO.AJO_STATUS IN ( '"/*+ cNaoEnv +"', '"*/+ cEnvApro +"' ) 	"+CRLF
cQuery += " 			AND AJO.AJO_FIM = '"+ CriaVar( "AJO_FIM", .F. ) +"' 	"+CRLF
cQuery += " 			AND AJO.D_E_L_E_T_ = '"+ Space( 1 ) +"' 	"+CRLF
cQuery += " GROUP BY AJO.AJO_FILIAL, AJO.AJO_PROJET, AJO.AJO_REVISA, AJO.AJO_TAREFA, AJO.AJO_ORDEM, AJO.AJO_ITEM, AJO.AJO_INI, AJO.AJO_FIM, AJO.AJO_MARK, AJO.AJO_STATUS, AJO.AJO_WFID, AJO.R_E_C_N_O_ "+CRLF
cQuery += " ORDER BY AJO.AJO_FILIAL, AJO.AJO_PROJET, AJO.AJO_REVISA, AJO.AJO_TAREFA, AJO.AJO_ITEM "+CRLF
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., __cRdd, TcGenQry( ,, cQuery ), cWorkAlias, .T., .F. )
dbSelectArea( cWorkAlias )
( cWorkAlias )->( dbEval( { || nTotReg ++ },,{ || !Eof() } ) )
If nTotReg > 0
	( cWorkAlias )->( dbGoTop() )
	While ( cWorkAlias )->( !Eof() )
		If ( cWorkAlias )->AJO_STATUS == cNaoEnv
			If PmsExecEcm( cPrcNamEcm, ( cWorkAlias )->AJORECNO ) // Implementar Parametro
				AJO->( dbGoto( ( cWorkAlias )->AJORECNO ) )
				cLogEcm	:= STR0016+" [ "+ ( cWorkAlias )->AJO_PROJET+"/"+( cWorkAlias )->AJO_REVISA+"/"+( cWorkAlias )->AJO_TAREFA+"/"+( cWorkAlias )->AJO_ORDEM+"/"+( cWorkAlias )->AJO_ITEM +" ]/ID[ "+ AllTrim( AJO->AJO_WFID ) +" ] "+STR0017 // "ITEM CHECK-LIST"##"ENVIADO COM SUCESSO"
			Else
				cLogEcm	:= STR0018+" [ "+ ( cWorkAlias )->AJO_PROJET+"/"+( cWorkAlias )->AJO_REVISA+"/"+( cWorkAlias )->AJO_TAREFA+"/"+( cWorkAlias )->AJO_ORDEM+"/"+( cWorkAlias )->AJO_ITEM +" ]/ID[ "+ AllTrim( AJO->AJO_WFID ) +" ]" // "PROBLEMAS NO ENVIO DO ITEM CHECK-LIST"
			EndIf
		ElseIf ( cWorkAlias )->AJO_STATUS == cEnvApro //Enviado para Aprovacao
			If PmsGetEcm( ( cWorkAlias )->AJO_WFID )
				AJO->( dbGoto( ( cWorkAlias )->AJORECNO ) )
				cLogEcm	:= STR0019+" [ "+ AllTrim( ( cWorkAlias )->AJO_WFID ) +" ] "+STR0020+" / "+STR0021+"[ "+ AJO->AJO_STATUS +" ]" // "RETORNO DO CHECK-LIST PROCESSO"##"PROCESSADO COM SUCESSO"##"STATUS"
			Else
				cLogEcm	:= STR0022+" [ "+ AllTrim( ( cWorkAlias )->AJO_WFID ) +" ]" //"PROBLEMAS NO RETORNO DO ITEM CHECK-LIST"
			EndIf
		EndIf
		If SuperGetMv("MV_PMSECML",.F.) 
			PmsCrtLog( 2, nHdlLog, cPLogEcm, cHdlLog, cLogEcm )
		Endif
		( cWorkAlias )->( dbSkip() )
	EndDo
EndIf
RestArea(aAJOArea)

IIf( Select( cWorkAlias ) > 0, ( cWorkAlias )->( dbCloseArea() ), Nil )
RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsExecECMบAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao do checklist de multiplos aprovadores para o ECM     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsExecEcm( cCodProcWF, nAJORecno )
Local lRet			:= .T.
Local lComplete		:= .T.
Local lJob			:= .F.
Local aArea			:= GetArea()
Local aAF8Area		:= {}
Local aAF9Area		:= {}
Local aAN4Area		:= {}
Local aAFFArea		:= {}
Local aAE8Area		:= {}
Local aAJOArea		:= {}
Local aAN1Area		:= {}
Local nRecPos			:= 0
Local nNextTask		:= 0
Local cXml 			:= Nil
Local cCodPrt			:= Nil
Local cDescPrt		:= Nil
Local cEmailEnv		:= Nil
Local cSupImed		:= Nil
Local cNameUserSys	:= Nil
Local cCodeUserSys	:= Nil
Local cComments		:= ""
Local aAux 			:= {}
Local aXml			:= {}
Local aUsers			:= {}
Local aLista			:= {}
Local aEquipe			:= {}
Local aCntsObrig		:= {}
Local aAJOData		:= {}
Local cTipProc		:= cCodProcWF
Local cProcessID		:= cCodProcWF
Local cUserEnv		:= GetMv( "MV_USRECM" )
Local cPwdEnv			:= "MD5:"+Md5( GetMv( "MV_PWDECM" ) ) 
Local aAttach			:= {}
Local lPeCrtXml		:= ExistBlock( "PMSCRTXML" )
Local cEquipe
Local cCodFunc
Local cFilAFF
Local cPrjAFF
Local cRevAFF
Local cTarAFF
Default nAJORecno	:= 0
Default cCodProcWF 	:= Nil

dbSelectArea( "AJO" )
aAJOArea	:= AJO->(GetArea())
AJO->( dbSetOrder( 1 ) )//AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA+AJO_ITEM
If nAJORecno>0
	lJob	:= .T.
	AJO->( dbGoto( nAJORecno ) )
Endif
If lRet	
	dbSelectArea( "AF8" )
	aAF8Area	:= AF8->(GetArea())
	AF8->( dbSetOrder( 1 ) )
	If !AF8->( dbSeek( xFilial( "AF8" ) + AJO->AJO_PROJET ) )
		lRet := .F.
	EndIf
	RestArea(aAF8Area)
EndIf		
If lRet	
	dbSelectArea( "AF9" )
	aAF9Area	:= AF9->(GetArea())
	AF9->( dbSetOrder( 1 ) )
	If !AF9->( dbSeek( xFilial( "AF9" ) + AJO->AJO_PROJET + AJO->AJO_REVISA + AJO->AJO_TAREFA ) ) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
		lRet := .F.
	EndIf
	RestArea(aAF9Area)
EndIf	
If lRet
	dbSelectArea( "AN4" )
	aAN4Area	:= AN4->(GetArea())
	AN4->( dbSetOrder( 1 ) )
	If !AN4->( dbSeek( xFilial( "AN4" ) + AF9->AF9_TIPPAR ) )
		lRet := .F.
	EndIf
	RestArea(aAN4Area)
Endif	
If lRet
	dbSelectArea( "AFF" )
	aAFFArea	:= AFF->(GetArea())
	AFF->( dbSetOrder( 1 ) )
	If AFF->( MsSeek( xFilial( "AFF" )+AF8->AF8_PROJET+AF8->AF8_REVISA+AF9->AF9_TAREFA ))
		cFilAFF := AFF_FILIAL;	cPrjAFF := AFF_PROJET;	cRevAFF := AFF_REVISA;	cTarAFF := AFF_TAREFA
		While !AFF->(EOF()) .AND. xFilial("AFF")+AF8->AF8_PROJET+AF8->AF8_REVISA+AF9->AF9_TAREFA = cFilAFF+cPrjAFF+cRevAFF+cTarAFF
			dDtaAFF	:= AFF_DATA 			
			cNameUserSys := PmsGetUser( AFF->AFF_USER )
			cCodeUserSys := AFF->AFF_USER
			AFF->(dbSkip())
		EndDo			
	Else
		lRet := .F.	
	EndIf
	RestArea(aAFFArea)
EndIf
If lRet	
	Aadd( aXml,{ "cProjeto"			, AF8->AF8_PROJET })
	Aadd( aXml,{ "cRecurso"			, cNameUserSys } )
	Aadd( aXml,{ "cTarefa"			, AF9->AF9_TAREFA } )
	Aadd( aXml,{ "cDesTaref"	, AllTrim( AF9->AF9_DESCRI ) } )
	Aadd( aXml,{ "cTipo"				, AN4->AN4_TIPO })
	Aadd( aXml,{ "cDesTip"		, AllTrim( AN4->AN4_DESCRI ) })
	Aadd( aXml,{ "cStatus"			, "" })
	Aadd( aXml,{ "cMemoTarefa"	, MSMM( AFF->AFF_CODMEM ) })
	Aadd( aXml,{ "cMemoObs"			, "" } )
	If lPeCrtXml
		aXml := {}
		aXml := ExecBlock( "PMSCRTXML",.F.,.F., { AJO->AJO_PROJET, AJO->AJO_REVISA, AJO->AJO_TAREFA, AJO->AJO_ITEM } )
		If Len( aXml ) == 0
			Help( " ", 1, "PMSCRTXML",, STR0023+ CRLF + STR0024, 5 ) //"Problemas no retorno do ponto de entrada"##"Verifique"
			lRet := .F.
		EndIf
	EndIf
EndIf
If lRet
	cCodPrt	:= AJO->( AJO_FILIAL +"|"+ AJO_PROJET +"|"+ AJO_REVISA +"|"+ AJO_TAREFA +"|"+ AJO_ITEM )
	aEquipe :={} 
	DbSelectArea( "AE8" )
	aAE8Area	:= AE8->(GetArea())
	AE8->( DbSetOrder( 3 ) )
	If AE8->( DbSeek( xFilial( "AE8" ) + cCodeUserSys ) )
		// busca a hierarquia do recurso na equipe
		aEquipe	:= PAConsEquipe( Upper( AllTrim( AE8->AE8_RECURS ) ), .T. )
	Else
		lRet := .F.
	EndIf
	RestArea(aAE8Area)
	If Len( aEquipe ) == 0
		Help( " ", 1, "PMSXFUNE",, STR0025 + ":" + CRLF + STR0026 + " [ " + Upper( AllTrim( cNameUserSys ) ) +" ]" , 5 ) //"Nใo foi encontrada a estrutura hierarquica"##"Recurso"
		lRet := .F.
	Else
		DbSelectArea( "AE8" )
		aAE8Area	:= AE8->(GetArea())
		AE8->( DbSetOrder( 3 ) )
		AE8->( DbSeek( xFilial( "AE8" ) + cCodeUserSys ) )
		cEquipe		:= AE8->AE8_EQUIP
		cCodFunc		:= AE8->AE8_FUNCAO
		dbSelectarea("AN1")
		aAN1Area := AN1->( GetArea() )
		AN1->( DbSetOrder( 1 ) ) // AN1_FILIAL+AN1_CODIGO
		AN1->( DbSeek( xFilial( "AN1" ) + cCodFunc ) )
		AE8->( DbSetOrder( 4 ) ) //AE8_FILIAL+AE8_EQUIP+AE8_RECURS
		AE8->( DbSeek( xFilial( "AE8" ) + cEquipe ) )
		cSupImed := ""
		Do While Empty(cSupImed) .And. !AE8->(Eof()) .And. xFilial("AE8")+cEquipe==AE8->(AE8_FILIAL+AE8_EQUIP)
			If AE8->AE8_FUNCAO==AN1->AN1_NIVSUP
				cSupImed := AE8->AE8_RECURSO
			EndIf
			AE8->(DbSkip())
		EndDo
		RestArea(aAN1Area)
		RestArea(aAE8Area)
	EndIf
	If !lJob
		aUsers	:= PmsDlgSup( cSupImed )
		If Len( aUsers ) == 0
			lRet := .F.
		Else
			MsgRun( STR0027, STR0028, { || lRet := PmsStartECM(  cTipProc, cCodPrt, cProcessID, cComments,aXml, aAttach, lComplete, nNextTask, aUsers, cUserEnv, cPwdEnv ) } ) //"Aguarde"##"Realizando integracao com ECM..."
			If !lRet
				Help( " ", 1, "PMSXFUNE",, STR0029+" [ "+ AJO->AJO_PROJET +" ]"+CRLF+STR0024 , 5 ) //"Ocorreu um problema na inicializacao da atividade"##"Verifique"
				lRet := .F.
			EndIf
		EndIf
	Else
		aAux := {}
		aAux := PmsGetUsr( cSupImed )
		Aadd( aUsers, aAux[ 01 ][ 03 ] )
		If !PmsStartECM(  cTipProc, cCodPrt, cProcessID, cComments,aXml, aAttach, lComplete, nNextTask, aUsers, cUserEnv, cPwdEnv )
			Help( " ", 1, "PMSXFUNE",, STR0029+" [ "+ AJO->AJO_PROJET +" ]"+CRLF+STR0024 , 5 ) //"Ocorreu um problema na inicializacao da atividade"##"Verifique"
			lRet := .F.
		EndIf
	EndIf
EndIf
RestArea(aAJOArea)	

RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsGetUserบAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que busca o codigo do usuario                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsGetUser( cUserSys )
Local cRet		:= Nil
Local cOldUsr	:= __cUserId
PswOrder( 1 )
If PswSeek( cUserSys )
	cRet	:= Upper( PswRet()[ 01 ][ 02 ] )
EndIf
PswSeek( cOldUsr )
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsDlgSup บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Janela de selecao de usuarios para aprovacao              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsDlgSup( cSupImed )
Local aRet			:= {}
Local aArea			:= GetArea()
Local oMarkAll
Local lMarkAll	:= .F.
Local aButtons	:= {}
Private oDlgUser
Private oGetUser
DEFINE MSDIALOG oDlgUser TITLE OemtoAnsi( STR0030 ) FROM C(240),C(259) TO C(400),C(589) PIXEL STYLE WS_CAPTION //"Sele็ใo de usuarios para aprova็ใo"
@ C(011),C(004) CheckBox oMarkAll Var lMarkAll On Click( PmsMarkAll( oGetUser, 2, lMarkAll ) ) Prompt STR0031 Size C(080),C(008) PIXEL OF oDlgUser //"Marcar / Desmarcar todos"
PmsGetDB( cSupImed )
ACTIVATE MSDIALOG oDlgUser CENTERED  ON INIT EnchoiceBar(oDlgUser, {|| IIf( U_SSPTOk( oGetUser ),( U_SSAjtRet( oGetUser, @aRet ), oDlgUser:End() ), .T. ) },{|| IIf( ApMsgYesNo(STR0032),( aRet := {}, oDlgUser:End() ), .T. ) },, aButtons ) //"Deseja cancelar operacao ?"
RestArea( aArea )
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSspTok    บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Confirmacao da selecao de aprovadores                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SSPTOk( oObj )
Local lRet		:= .T.
Local nInd		:= 0
Local nOkPos	:= GdFieldPos( "USER_OK"	, oObj:AHeader )
Local nIdPos	:= GdFieldPos( "USER_ID"	, oObj:AHeader )
Local nNmPos	:= GdFieldPos( "USER_DESC", oObj:AHeader )
Local nLogPos	:= GdFieldPos( "USER_LOGIN"	, oObj:AHeader )
If !(PmsAutoOk(oObj))
	lRet:=.F.
Endif
If lRet
	If ApMsgYesNo( STR0033, STR0034 ) //"Deseja confirmar opera็ใo?"##"Selecao de aprovadores"
		For nInd := 1 To Len( oObj:ACols )
			If AllTrim( oObj:ACols[ nInd ][ nOkPos ] ) == cMark .And. oObj:ACols[ nInd ][ (len(oObj:aHeader)+1 )] == .F.
				If Empty( oObj:ACols[ nInd ][ nIdPos ] ) .Or. Empty( oObj:ACols[ nInd ][ nLogPos ] )
					ApMsgStop( STR0035 + " [ "+ AllTrim( oObj:ACols[ nInd ][ nNmPos ] ) +" ] " + STR0036, STR0037 ) //"O aprovador"##"esta com problemas em seu cadastro de usuarios"##"Atencao"
					lRet := .F.
				EndIf
			EndIf
		Next nInd
	Else
		lRet := .F.
	EndIf
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSsAjtRet  บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna  o Id do aprovador selecionado          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SSAjtRet( oObj, aRet )
Local lRet		:= .T.
Local nInd		:= 0
Local nTamLin := Len( oObj:AHeader ) + 1
Local nTMPPos	:= GdFieldPos( "USER_OK"		, oObj:AHeader )
Local nLogPos	:= GdFieldPos( "USER_ID"	, oObj:AHeader )//alterado. O wizard da 11 envia o ID do usuario para o ECM.
For nInd := 1 To Len( oObj:ACols )
	If !oObj:ACols[ nInd ][ nTamLin ]
		If oObj:ACols[ nInd ][ nTMPPos ] == cMark
			Aadd( ARet, oObj:ACols[ nInd ][ nLogPos ] )
		EndIf
	EndIf
Next nInd
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsMarkAllบAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsMarkAll( oObj, nOpcx, lMarkAll )
Local nInd		:= 0
Local nAuxPos := 0
Local nLinAtu	:= oObj:nAt
Local nColId	:= GdFieldPos( "USER_ID"	, oObj:AHeader )
Local nTMPPos	:= GdFieldPos( "USER_OK"	, oObj:AHeader )
Local nColEml	:= GdFieldPos( "USER_EMAIL"	, oObj:AHeader )
Local nFlPos	:= GdFieldPos( "USER_DESC", oObj:AHeader )
Default lMarkAll := .F.
Do Case
	Case nOpcx == 1
		If ( AllTrim( oObj:Acols[ nLinAtu ][ nTMPPos ] ) == cNoMark ) .And. ( nColId # oObj:oBrowse:ColPos )
			oObj:Acols[ nLinAtu ][ nTMPPos ] := cMark
		ElseIf ( nColEml == oObj:oBrowse:ColPos ) //
			oObj:EditCell()
		ElseIf ( nColId == oObj:oBrowse:ColPos )
			oObj:EditCell()
			oObj:Acols[ nLinAtu ][ nTMPPos ] := cMark
			oObj:Acols[ nLinAtu ][ GdFieldPos( "USER_LOGIN"	, oObj:AHeader ) ] := AllTrim( UsrRetName( 	oObj:ACols[ nLinAtu ][ GdFieldPos( "USER_ID", oObj:AHeader ) ] ) )
			oObj:Acols[ nLinAtu ][ GdFieldPos( "USER_DESC"	, oObj:AHeader ) ] := AllTrim( UsrFullName( 	oObj:ACols[ nLinAtu ][ GdFieldPos( "USER_ID", oObj:AHeader ) ] ) )
			oObj:Acols[ nLinAtu ][ GdFieldPos( "USER_EMAIL"	, oObj:AHeader ) ] := AllTrim( Lower( UsrRetMail( 	oObj:ACols[ nLinAtu ][ GdFieldPos( "USER_ID", oObj:AHeader ) ] ) ) )
		Else
			nAuxPos := 0
			nAuxPos := Ascan( oObj:Acols, { | x | AllTrim( x[ 2 ] ) == AllTrim( cNoDelRec ) } )
			oObj:Acols[ nLinAtu ][ nTMPPos ] := IIf( nLinAtu # nAuxPos, cNoMark, cMark )
			If nLinAtu == nAuxPos
				ApMsgStop( STR0038 + " " + CRLF + "[ " + AllTrim( oObj:ACols[ nLinAtu ][ nFlPos ] ) + " ]", STR0039 ) //"ษ obrigatorio a aprovacao do analista"##"Nใo ้ possํvel remover o contato"
			EndIf
		EndIf
	Case nOpcx == 2
		For nInd := 1 To Len( oObj:Acols )
			oObj:Acols[ nInd ][ nTMPPos ] := IIf( lMarkAll, cMark , cNoMark )
		Next nInd
		nAuxPos := 0
		nAuxPos := Ascan( oObj:Acols, { | x | AllTrim( x[ 2 ] ) == AllTrim( cNoDelRec ) } )
		oObj:Acols[ nAuxPos ][ nTMPPos ] := cMark
EndCase
oObj:oBrowse:Refresh()
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsGetDb  บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsGetDB( cSupImed )
Local lRet			:= .T.
Local nX				:= 0
Local aCpoGDa      	:= { "USER_OK", "USER_ID", "USER_LOGIN", "USER_DESC", "USER_EMAIL" }
Local aAlter       	:= { "USER_OK", "USER_ID", "USER_EMAIL" }
Local nSuperior    	:= C(021)
Local nEsquerda    	:= C(004)
Local nInferior    	:= C(077)
Local nDireita     	:= C(162)
Local nOpc         	:= GD_INSERT+GD_DELETE+GD_UPDATE
Local cLinhaOk     	:= "AllwaysTrue"
Local cTudoOk      	:= "AllwaysTrue"
Local cIniCpos     	:= "+<USER_OK>"
Local nFreeze      	:= 000
Local nMax         	:= 999
Local cCampoOk     	:= "AllwaysTrue"
Local cSuperApagar 	:= ""
Local cApagaOk     	:= "PmsDRecur()"
Local oWnd         := oDlgUser
Local aHead        	:= {}
Local aCol         	:= PmsGetUsr( cSupImed )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAadd(aHead,{ AllTrim(X3Titulo()),ณ
//ณ							SX3->X3_CAMPO,      ณ
//ณ							SX3->X3_PICTURE,    ณ
//ณ							SX3->X3_TAMANHO,    ณ
//ณ							SX3->X3_DECIMAL,    ณ
//ณ							SX3->X3_VALID,      ณ
//ณ							SX3->X3_USADO,      ณ
//ณ							SX3->X3_TIPO,       ณ
//ณ							SX3->X3_F3,         ณ
//ณ							SX3->X3_CONTEXT,    ณ
//ณ							SX3->X3_CBOX,       ณ
//ณ							SX3->X3_RELACAO } ) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


Aadd(aHead,{ ""			,"USER_OK"		,"@BMP"		, 02,0,,,"C",," ",,})
Aadd(aHead,{ STR0040	,"USER_ID"		,"@!"		, 10,0,"NAOVAZIO()",,"C","USR",,,}) // "Cod.usuario"
Aadd(aHead,{ STR0041	,"USER_LOGIN"	,"@!"		, 20,0,,,"C",,,,}) //"Login usuario"
Aadd(aHead,{ STR0042	,"USER_DESC"	,"@!"		, 40,0,,,"C",,,,}) //"Nome usuario"
Aadd(aHead,{ STR0043	,"USER_EMAIL"	,"@!"		, 50,0,,,"C",,,,}) //"Email usuario"
oGetUser := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,"PmsAutoOk()"/*cLinhaOk*/,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,"PmsAutoFill()"/*cCampoOk*/,cSuperApagar,cApagaOk,oWnd,aHead,aCol)
oGetUser:oBrowse:blDblClick := { || PmsMarkAll( oGetUser, 1 ) }
oGetUser:oBrowse:bEditCol := {|| PmsAutoFill(oGetUser)}
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsDRecur บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsDRecur()
Local lRet		:= .T.
Local nIdPos	:= GdFieldPos( "USER_ID"	, oGetUser:AHeader )
Local nOkPos	:= GdFieldPos( "USER_OK"	, oGetUser:AHeader )
Local nFlPos	:= GdFieldPos( "USER_DESC", oGetUser:AHeader )
If AllTrim( oGetUser:ACols[ oGetUser:oBrowse:nAt ][ nOkPos ] ) == cMark
	If AllTrim( oGetUser:ACols[ oGetUser:oBrowse:nAt ][ nIdPos ] ) == AllTrim( cNoDelRec )
		ApMsgStop( STR0038+" "+CRLF+"[ "+ AllTrim( oGetUser:ACols[ oGetUser:oBrowse:nAt ][ nFlPos ] ) +" ]" ,STR0039) //"ษ obrigatorio a aprovacao do analista"##"Nใo ้ possํvel remover o contato"
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsGetUsr บAutor  ณMicrosiga           บ Data ณ  04/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsGetUsr( cSupImed )
Local aAux 		:= {}
Local aRet		:= {}
Local aArea		:= GetArea()
AE8->( dbSetOrder( 1 ) )
If AE8->( dbSeek( xFilial( "AE8" ) + Padr( cSupImed , TamSx3( "AE8_RECURS" )[ 1 ] ) ) )
	cNoDelRec := AllTrim( AE8->AE8_USER )
	cLogUser	:= AllTrim( UsrRetName( cNoDelRec ) )
	cFullUser	:= AllTrim( UsrFullName( cNoDelRec ) )
	cEmlUser	:= AllTrim( Lower( UsrRetMail( cNoDelRec ) ) )
	Aadd( aAux, cMark			)
	Aadd( aAux, IIf( Empty( cNoDelRec	), Space( 10 ), cNoDelRec	) )
	Aadd( aAux, IIf( Empty( cLogUser	), Space( 20 ), cLogUser	) )
	Aadd( aAux, IIf( Empty( cFullUser	), Space( 40 ), cFullUser	) )
	Aadd( aAux, IIf( Empty( cEmlUser	), Space( 50 ), cEmlUser	) )
Else
	Aadd( aAux, cNoMark			)
	Aadd( aAux, Space( 10 )	)
	Aadd( aAux, Space( 20 )	)
	Aadd( aAux, Space( 40 )	)
	Aadd( aAux, Space( 50 )	)
EndIf
Aadd( aAux,.F.)
Aadd( aRet, AClone( aAux ) )
RestArea( aArea )
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSPrepAmbบAutor  ณMicrosiga           บ Data ณ  03/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PmsPrepAmb( xEmprJob, xFilJob, lOpenEmp, nOpcx )
Local lRet		:= .T.
Local aTables := { "AJO", "AJM", "AE8", "WFE" }
Do Case
	Case nOpcx == 1
		If lOpenEmp
			RpcClearEnv()
			RpcSetType( 3 )
			If !RpcSetEnv( xEmprJob, xFilJob,,,,"PMSJOBECM",aTables,,,.T. )
				lRet := .F.
			Else
				OpenSm0()
			EndIf
		EndIf
	Case nOpcx == 2
		If !IsBlind()
			RpcClearEnv()
		EndIf
EndCase
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC         บAutor  ณMicrosiga           บ Data ณ  04/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C(nTam)
Return Int( nTam * 1.30 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPmsAutoFill บ Autor ณMarcelo Akama       บ Data ณ  02/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsAutoFill( oObj )

Local nInd	:= 0
Local nAuxPos	:= 0
Local nLinAtu	
Local nColId	
Local nTMPPos	
Local nColEml	
Local nFlPos	
Local lRet:=.T.
Local nCount:=0
Default oObj:=oGetUser
oGetUser:oBrowse:bEditCol := {|| PmsAutoFill(oGetUser)}
If Len(oObj:Acols) > 0
	nLinAtu	:= oObj:nAt
	nColId	:= GdFieldPos( "USER_ID"	, oObj:AHeader )
	nTMPPos	:= GdFieldPos( "USER_OK"	, oObj:AHeader )
	nColEml	:= GdFieldPos( "USER_EMAIL"	, oObj:AHeader )
	nFlPos	:= GdFieldPos( "USER_DESC"	, oObj:AHeader )
	oObj:Acols[ nLinAtu ][ GdFieldPos( "USER_LOGIN"	, oObj:AHeader ) ] := AllTrim( UsrRetName( 	oObj:ACols[ nLinAtu ][ GdFieldPos( "USER_ID", oObj:AHeader ) ] ) )
	oObj:Acols[ nLinAtu ][ GdFieldPos( "USER_DESC"	, oObj:AHeader ) ] := AllTrim( UsrFullName( 	oObj:ACols[ nLinAtu ][ GdFieldPos( "USER_ID", oObj:AHeader ) ] ) )
	oObj:Acols[ nLinAtu ][ GdFieldPos( "USER_EMAIL"	, oObj:AHeader ) ] := AllTrim( Lower( UsrRetMail( 	oObj:ACols[ nLinAtu ][ GdFieldPos( "USER_ID", oObj:AHeader ) ] ) ) )
	oObj:oBrowse:Refresh()
Endif
Return(.T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSAUTOOK บAutor  ณ                    บ Data ณ  13/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Tudo Ok da Get dados de Aprovador                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PMSAUTOOk(oObj)
Local lRet:=.T.
Local nLinAtu
Local nCount:=0
Local nPesq :=0
Default oObj:=oGetUser
nLinAtu	:= oObj:nAt
		For nPesq:= 1 to Len(oObj:Acols)	
			For nCount:=1 To Len(oObj:Acols)	
				If (oObj:ACols[ nPesq ][ GdFieldPos( "USER_ID", oObj:AHeader ) ])==(oObj:ACols[ nCount ][ GdFieldPos( "USER_ID", oObj:AHeader ) ]);
					.And. nCount # nPesq .and. oObj:ACols[ nCount ][ (len(oObj:aHeader)+1) ] == .F. ;
					.And. oObj:ACols[ nPesq ][ (len(oObj:aHeader)+1) ] == .F.//validando se o aprovador ja nao se encontra no grid.
					MsgStop(STR0044)//"Aprovador jแ selecionado!"
					lRet :=.F.
					oObj:GoTo(nCount)
					oObj:oBrowse:Refresh()
					Exit
				Endif
			Next nCount
			If oObj:ACols[ nPesq ][ (len(oObj:aHeader)+1 )] == .F. .And. !UsrExist(oObj:ACols[ nPesq ][ GdFieldPos( "USER_ID", oObj:AHeader ) ])
				lRet :=.F.
				oObj:GoTo(nPesq)
				oObj:oBrowse:Refresh()
				Exit
			Endif
			If lRet == .F.
				Exit
			Endif
		Next nPesq
Return (lRet)
