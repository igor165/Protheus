#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "JURGED.CH"

Function __JurGed() // Function Dummy
  ApMsgInfo( STR0001 ) //"JurGed -> Utilizar Classe ao inves da funcao"
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Class JurGED
Data nHandle
Data cDLL
Data cServer
Data lShowErrCos  
Data cPath  


Method New() Constructor 
Method Connect() 
Method Login() 
Method LogOut() 
Method UpFile() 
Method GetFile() 
Method Attach() 
Method Finish() 
Method Destroy()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Method New( cNomeServer, cNomeDll ) Class JurGED
::cDLL        := cNomeDll
::cServer     := cNomeServer
::nHandle     := -1
::lShowErrCos := .T.
::cPath       := ""

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Method Destroy() Class JurGED
Self := NIL
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Method Connect() Class JurGED
Local lRet := .F.

If ::nHandle == -1
	::nHandle := ExecInDLLOpen( ::cDll )
EndIf

lRet := !( ::nHandle < 0 )

If !lRet .AND. ::lShowErrCos
	ConOut( STR0002 ) //"Erro de Conxao com GED"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Method Login( lTrustee, lCloud ) Class JurGED
Local lRet    := .F.
Local nRet    := -1
Local cBuffer := ::cServer
Local nCodeAct:= 1

Default lTrustee := .F.
Default lCloud   := .F.

	If (lCloud) // Verifica se é o IManageCloud
		If (lTrustee)
			nCodeAct := 7
		Else
			nCodeAct := 8
		EndIf
	Else // Utiliza o IManage Worksite tradicional
		If (lTrustee)
			nCodeAct := 1
		Else
			nCodeAct := 2
		EndIf
	EndIf
		
	If ::nHandle >= 0
		nRet := ExeDLLRun2( ::nHandle, nCodeAct, cBuffer )
	EndIf

	lRet := !( nRet < 0 )

	If !lRet .AND. ::lShowErrCos
		ConOut( STR0003 ) //"Erro de Login com GED"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Method LogOut() Class JurGED
Local lRet    := .F.
Local nRet    := -1
Local cBuffer := ""

If ::nHandle >= 0
	nRet := ExeDLLRun2( ::nHandle, 3, cBuffer )
EndIf

lRet := !( nRet < 0 )

If !lRet .AND. ::lShowErrCos
	ConOut( STR0004 ) //"Erro de LogOut com GED"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Method Finish() Class JurGED
Local lRet := .F.
Local nRet := -1

If ::nHandle >= 0
	nRet := ExecInDllClose( ::nHandle )
	::nHandle := -1
EndIf

lRet := ( ::nHandle < 0 )

If !lRet .AND. ::lShowErrCos
	ConOut( STR0005 ) //"Erro de Finish com GED"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------        
Method Attach( cFile ) Class JurGED
Local lRet := .F.
Local nRet := -1

Default cFile   := ""
                        
cFile := PADR(cFile,255)

If ::nHandle >= 0
	nRet := ExeDLLRun2( ::nHandle, 6, @cFile )
EndIf
 
lRet := !( nRet < 0 )

cFile := AllTrim(cFile)

If !lRet .AND. ::lShowErrCos
	ConOut( STR0006 ) //"Erro de Attach com GED"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Method UpFile( cFile ) Class JurGED
Local lRet := .F.
Local nRet := -1

Default cFile   := ""

If ::nHandle >= 0
	nRet := ExeDLLRun2( ::nHandle, 5, @cFile )
EndIf
 
lRet := !( nRet < 0 )

If !lRet .AND. ::lShowErrCos
	ConOut( STR0007 ) //"Erro de UpFile com GED"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGED
CLASS JurGED

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFile( cFile ) Class JurGED
Local lRet    := .F.
Local nRet    := -1
Local cBuffer := ""

Default cFile := ""

cBuffer := cFile

If ::nHandle >= 0
	nRet := ExeDLLRun2( ::nHandle, 4, cBuffer )
EndIf

lRet := !( nRet < 0 )

If !lRet .AND. ::lShowErrCos
	ConOut( STR0008 ) //"Não é possível abrir o documento"
EndIf

Return lRet
