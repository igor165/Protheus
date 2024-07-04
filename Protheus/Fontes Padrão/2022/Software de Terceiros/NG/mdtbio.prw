#INCLUDE 'mdtbio.ch'
#INCLUDE 'PROTHEUS.CH'

//------------------------------------------------------------------
/*/{Protheus.doc} MdtBio
Centralizador de funcionalidades de biometria no SIGAMDT
@type  Function
@author bruno.souza
@since 13/04/2022
@param cMedRec, caracter, código da ficha médica 
@return sempre verdadeiro
@example
MdtBio("000001")
/*/
//------------------------------------------------------------------
Function MdtBio(cMedRec)

	Local cDigital

	cDigital := EnrollBio()

	If !Empty(cDigital) //Se digital preenchida, grava na TM0
		fRecBio(cDigital, cMedRec)

	EndIf

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} EnrollBio
Funcionalidade de captura das digitais
@type  Function
@author bruno.souza
@since 13/04/2022
@param cDigital, caracter, param_descr
@return cDigital, caracter, hash da digital capturada
@example
EnrollBio()
/*/
//------------------------------------------------------------------
Function EnrollBio()

	cDigital := CallWSNit(1) 

Return cDigital

//------------------------------------------------------------------
/*/{Protheus.doc} MatchBio
Função de comparação de digitais
@type  Function
@author bruno.souza
@since 13/04/2022
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
MatchBio
/*/
//------------------------------------------------------------------
Function MatchBio(cDigital)
	
	Local lOK := CallWSNit(2, cDigital) == "OK"

Return lOK

//-------------------------------------------------------------------
/*/{Protheus.doc} CallWSNit
Web service rest, api 
@type  Static Function
@author bruno.souza
@since 18/01/2022

@param nType, numeric, tipo de operação a ser realizada
1 - Enroll, captura as digitais
2 - Match, compara digital

@return cReturn, 
	caracter, hash da digital capturada ou
	validação da comparação da digital 
@example
CallWSNit(1)
/*/
//-------------------------------------------------------------------
Function CallWSNit(nType, cDigital)
	
	Local cReturn
	Local cBioHost := SuperGetMV('MV_NG2HOST', .F., 'http://localhost:9000' )
	Local cFileSave := "biometry.txt"
	Local cExec := 'cmd /c "curl ' + cBioHost + '/api/public/v1/captura/Enroll/1 > '+ cFileSave+ '"'
	Local cFileCompareSave := "compare_biometry.txt"
	Local cExecCompare := 'cmd /c "curl ' + cBioHost + '/api/public/v1/captura/Comparar?Digital='
	Local cExecFileCompare := ' > '+ cFileCompareSave+ '"'
	Local cRetCompare := ''
	Local cRmtPath
	
	// Recebe a pasta do SmartClient 
	cRmtPath := GETREMOTEININAME()
	cRmtPath := left(cRmtPath,rat('\',cRmtPath))

	If nType == 1
		WaitRun(cExec,0)
		If file(cRmtPath+cFileSave)
			cReturn := memoread(cRmtPath+cFileSave)
		Else
			cReturn := ''
			Help( ' ', 1, 'Aviso', , STR0001+STR0004, 2, 0, , , , , , { STR0002 } )
		EndIf

	ElseIf nType == 2
		WaitRun(cExecCompare + cDigital + cExecFileCompare, 0)
		
		If file(cRmtPath+cFileCompareSave)
			cRetCompare := memoread(cRmtPath+cFileCompareSave)
			If (cRetCompare != '"OK"')
				cReturn := ''
				Help( ' ', 1, 'Aviso', , STR0001+STR0003, 2, 0, , , , , , { STR0002 } )
			Else
				cReturn := "OK"
			EndIf
		Else
			cReturn := ''
			Help( ' ', 1, 'Aviso', , STR0001+STR0003, 2, 0, , , , , , { STR0002 } )
		EndIf
	EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fRecBio
Grava biometria no campo da TM0
@type  Static Function
@author bruno.souza
@since 02/06/2022

@param cDigital, caracter, hash da digital
@param cMedRec, caracter, código da ficha médica
@param lDel, boolean, indica se é deleção

@return nil

@example
fRecBio(cDigital, cMedRec, lDel)
/*/
//-------------------------------------------------------------------
Function fRecBio(cDigital, cMedRec)
	
	If dbSeek(xFilial("TM0") + cMedRec)
		RecLock('TM0', .F.)
			M->TM0_REGBIO := cDigital
		MsUnlock()
	EndIf

Return .T.
