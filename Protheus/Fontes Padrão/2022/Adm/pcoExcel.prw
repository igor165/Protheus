#include 'protheus.ch'
#include 'PcoExcel.ch'

Static __lHaveAddIn

Function PcoExcel( cFile )
Local lRet	:= .T.
Local oDlg
Local oMsg
Local oMeter
Local oBtnOk
Local oBtnCancel
Local oPanel
Local oExcelApp
Local cLck		:= 'C:\ApExcel\ApExcel.lck'
Local cMsg		:= ''
Local nMeter	:= 0
Local cTarget

If !Empty(cFile)
	If "\" $ cFile
		cTarget := Subs(cFile,Rat("\",cFile)+1)
	Else
		cTarget := cFile
	EndIf
	
	If At("][", cTarget) == 0
		cTarget := "["+Alltrim(AK1->AK1_CODIGO)+"]["+cRevisa+"]"+cTarget
    EndIf
	
	cTarget := 'C:\ApExcel\' + cTarget

	If File(cTarget)
		Ferase(cTarget)
	EndIf

	__CopyFile(cFile,cTarget)
EndIf

DEFINE MSDIALOG oDlg FROM 050, 050 TO 150, 385 TITLE 'Integracao Excel - Planilha Orçamentária' PIXEL 
@ 000, 000 MSPANEL oPanel VAR '' OF oDlg SIZE 300, 300 

@ 005, 010 SAY oMsg VAR cMsg SIZE 150, 10 PIXEL OF oPanel
@ 020, 010 METER oMeter VAR nMeter TOTAL 100 SIZE 150, 10 PIXEL OF oPanel

DEFINE SBUTTON oBtnOk 		FROM 035, 100 TYPE 1 ENABLE OF oPanel PIXEL ACTION ( lRet := PcoXLAStart( @oExcelApp, cLck, @oMsg, @cMsg, @oMeter, @nMeter, @oBtnOk, cTarget ), oDlg:End() )
DEFINE SBUTTON oBtnCancel 	FROM 035, 135 TYPE 2 ENABLE OF oPanel PIXEL ACTION ( FErase(cLck), Sleep(10), oDlg:End() )

If !Empty(cFile)
	oDlg:bStart := oBtnOk:bAction
EndIf
ACTIVATE MSDIALOG oDlg CENTERED

FErase( cLck )

Return lRet

// ------------------------------------------------------

nMeter ++ 

If ( nMeter > 100 )
    nMeter := 1
EndIf

oMeter:Set(nMeter)
oMeter:Refresh()

Return( lRet )

// ------------------------------------------------------

Function PcoXLAStart( oExcelApp, cLck, oMsg, cMsg, oMeter, nMeter, oBtnOk, cXLSFile )
Local aCfg		:= ExecInClient( 400, { 'XlInfo' } )
LOcal lRet	:= .T.

If ( __lHaveAddIn == Nil ) .Or. ( __lHaveAddIn == .F.)
    ExecInClient( 400, { 'XlCopy', 'apExcel80.xla' } )
	__lHaveAddIn	:= File( 'C:\ApExcel\apExcel80.xla' )
	If !__lHaveAddIn
		__CopyFile("\ApExcel\apExcel80.xla",'C:\ApExcel\apExcel80.xla')
		__lHaveAddIn := File( 'C:\ApExcel\apExcel80.xla' )
	EndIf
EndIf

FClose(FCreate( cLck ))

If ! ApOleClient( 'MsExcel' ) 
	MsgStop( 'MsExcel nao instalado' )
	Return .F.
EndIf

If ( ! __lHaveAddIn )
	MsgStop( 'AddIn ApSmall nao instalado' )
	Return .F.
EndIf

If ( Len( aCfg ) < 4 )
	MsgStop( 'Parametros de conexao invalidos' )
	Return .F.
EndIf

nMeter ++
oMeter:Set(nMeter)
oMeter:Refresh()

cMsg := 'inicializando ambiente'
oMsg:Refresh()

oExcelApp := MsExcel():New()

nMeter ++
oMeter:Set(nMeter)
oMeter:Refresh()
SysRefresh()


nMeter ++
oMeter:Set(nMeter)
oMeter:Refresh()
SysRefresh()

cMsg := 'Carregando addin'
oMsg:Refresh()

oExcelApp:Workbooks:Add()

nMeter ++
oMeter:Set(nMeter)
oMeter:Refresh()
SysRefresh()

oExcelApp:WorkBooks:Open( 'C:\ApExcel\apExcel80.xla' )

nMeter ++
oMeter:Set(nMeter)
oMeter:Refresh()

CONOUT(TINICIO)
oExcelApp:Run( 'apExcel80.xla!Ap5_Excel_8.XlApConnect', cEmpAnt, cFilAnt, Dtos(dDataBase), aCfg [1], aCfg [2], Val(aCfg[3]), cLck, aCfg[4] )

cMsg := 'Conectado'
oMsg:Refresh()
nMeter ++
oMeter:Set(nMeter)
oMeter:Refresh()

oExcelApp:SetVisible(.T.)
If !Empty(cXLSFile)
	oExcelApp:WorkBooks:Close()
	oExcelApp:WorkBooks:Open(cXLSFile)
EndIf

Sleep( 2000 )

nMeter ++
oMeter:Set(nMeter)
oMeter:Refresh()
oBtnOk:SetDisable()

SysRefresh()

While ( ! KillApp() )

	nMeter ++
	
	If ( nMeter > 100 )
        nMeter := 1
	EndIf
	
	oMeter:Set(nMeter)
	oMeter:Refresh()
	SysRefresh()

	If ( ! File( cLck ) )
        Exit
	EndIf
    
	Sleep( 150 )
	
End

oExcelApp:Quit()
oExcelApp:Destroy()

Sleep( 500 )

Return lRet


Function PcoXlsOpen(oOle, aExclui,cObjeto,lForceEdit,lAtuAK2)
Local lRet		 := .T.
Local cLinks	  := ''
Local aArea		  := GetArea()
Local aAreaACB	  := GetArea()
LOCAL cDirDocs   := MsDocPath()
LOCAL cObjAux 
DEFAULT lAtuAK2	:=	.T.
DEFAULT cObjeto	  := AllTrim(GDFieldGet( "AC9_OBJETO" ))  
DEFAULT lForceEdit := .F.

If lForceEdit .Or. ".XLS" $ UPPER(cObjeto) .And. Aviso('Integracao Excel - Planilha Orçamentária',"Voce deseja abrir esta planilha no modo edição disponivel para planilhas em formato Excel ( XLS ) para integração com a planilha Orçamentária ou atravé do visualizador padrão apenas consultas ? ( O modo edição permite que os vinculos da planilha Excel sejam sincronizados com a planilha Orçamentária )"+;
									CHR(13)+CHR(10)+CHR(13)+CHR(10)+"Obs.: O modo edição requer o Microsoft Excel instalado.",{"Edição","Normal"},3,"Planilhas Excel (XLS) ",,"MDIEXCEL")==1
	dbSelectArea("ACB")
	dbSetOrder(2)
	dbSeek(xFilial('ACB')+UPPER(cObjeto))
	If SoftLock("ACB")
		PcoExcIni(cObjeto)
		If PcoExcel(cDirDocs+"\"+cObjeto)
			If Aviso('Integracao Excel - Planilha Orçamentária',"Voce deseja atualizar a planilha orçamentaria com os valores atuais da planilha Excel editada ? ",{"Sim","Nao"},2,"Salvar atualizações ?",,"MDIEXCEL") == 1
				If At("][", cObjeto) == 0
					cObjAux := "["+Alltrim(AK1->AK1_CODIGO)+"]["+cRevisa+"]"+cObjeto
				Else
					cObjAux := cObjeto	
			    EndIf
				__CopyFile( "C:\APEXCEL\"+cObjAux, "C:\APEXCEL\MsPcoBck.XLS" )
				If SmCopy( "C:\APEXCEL\"+cObjAux , cDirDocs+"\"+cObjeto )
					If lAtuAK2
						PcoIniLan("000252")
						lRet := PcoExcFin(cObjAux,@cLinks,.T.)
						PcoFinLan("000252")
					Else
						lRet := PcoExcFin(cObjAux,@cLinks,.F.)
					Endif
					If lRet
						If Aviso('Integracao Excel - Planilha Orçamentária',"A planilha "+AllTrim(cObjeto)+" ( Banco de conhecimento ) e os seus respectivos relacionamentos com as planilhas orçamentarias foram atualizados com sucesso.",{"Sair","Detalhes"},2,"Atualização efetuada com sucesso !",,"MDIEXCEL") == 2
							PcoDetalhes(cLinks)
						EndIf
					Else
						If Aviso('Integracao Excel - Planilha Orçamentária',"A planilha "+AllTrim(cObjeto)+" ( Banco de conhecimento ) e os seus respectivos relacionamentos com as planilhas orçamentarias não foram atualizados com sucesso.",{"Fechar","Detalhes"},2,"Erros na atualização !",,"MDIEXCEL") == 2
							PcoDetalhes(cLinks," - Erro na atualização")
						EndIf					
					EndIf
				Else
					PcoDetalhes("Erros foram encontrados durante a atualização do arquivo no Servidor. Foi gravado o arquivo de backup na pasta C:\APEXCEL\MsPcoBck.XLS."," - Erro na atualização")
				EndIf
			EndIf
		EndIf
		ACB->(MsUnlockAll())
	EndIf
Else
	MsDocOpen( @oOle, @aExclui )	
EndIf	


RestArea(aAreaACB)
RestArea(aArea)
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SmCopy   ³ Autor ³ Edson Maricate        ³ Data ³ 14.05.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que faz copia de arquivo.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SmallERP                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SmCopy(cOrigem,cDestino)

Processa({|| AuxSmCopy(cOrigem,cDestino) },"Atualizando arquivo..." )

Return File(cDestino)

Function AuxSmCopy( cOrigem ,cDestino )
Local nHandOri	:= 0
Local nHandDes	:= 0
Local nSize		:= 0
Local nBlock	:= 0
Local cBuffer	:= ''

// verifica se o arquivo origem existe.
If File(cOrigem)
	nHandOri	:= FOpen(cOrigem)
	nHandDes	:= FCreate(cDestino)
	nSize		:= Fseek( nHandOri, 0, 2 )
	nBlock	:= Max(nSize/100,64000)
	cBuffer	:= ''

	ProcRegua(Int(nSize/nBlock)-1)

	Fseek( nHandOri, 0, 0 )
	While FRead(nHandOri,@cBuffer,nBlock) > 0
		IncProc()
		FWrite(nHandDes,cBuffer)
	End

	FClose(nHandOri)
	FClose(nHandDes)
EndIf

Return( NIL )