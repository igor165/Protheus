#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP18.CH"

/********************************************************************************##
***********************************************************************************
***********************************************************************************
***Funcão..: RHIMP18.prw Autor:Edna Dalfovo Data: 19/02/2013	                 ***
***********************************************************************************
***Descrição..:Responsável pela importação de Relógios.							   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:		cFileName, caractere, nome do arquivo       	      		   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***********************************************************************************
***Chamado....:                                                                 ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP18
Responsável pela importação de Relógios
@author Edna Dalfovo
@since 19/02/2013
@version P11
@param cFileName, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
USER Function RHIMP18(cFileName,aRelac,oSelf)
	Local aArea				:= SP0->(GetArea())
	Local aTabelas 			:= {'SP0'}	
	Local aLinha			:= {}
	Local aIndAux			:= {}
	Local cBuffer       	:= ""
	LOCAL lChangeEnv		:= .F.
	Local cEmpresaArq   	:= ""
	LOCAL cFilialArq    	:= ""
	LOCAL cEmpOri    		:= ""
	LOCAL cP0_Relogio	  	:= ""
	Local aIniPad			:= {}
	Local nTamDesc			:= TAMSX3("P0_DESC")[1]
	Local nTamArq			:= TAMSX3("P0_ARQUIVO")[1]
	Local nTamRel			:= TamSX3("P0_RELOGIO")[1]
	Local nX				:= 0
	Local nJ				:= 0
	Local nPos				:= 0
	Local aErro      		:= {}
	Local lExiste 			:= .F.
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	While !FT_FEOF() .And. !lStopOnErr		
		cBuffer := FT_FREADLN()
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErro)
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cEmpresaArq  := aLinha[1]
		cFilialArq   := aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',@lChangeEnv,@lExiste,"PONA100",aTabelas,"PON",@aErro,OemToAnsi(STR0001))		
		
		if(lChangeEnv)
			SP0->(DbSetOrder(1))
			if(cEmpOri != cEmpresaArq)
				cEmpOri := cEmpresaArq
				/* Quando muda a empresa pode ser que a estrutura da tabela mude */
				aIniPad := InitValues()
			EndIf			
		EndIf
		
		If lExiste
		
			//Verifica existencia de DE-PARA
			If !Empty(aRelac)
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := U_fGetCpoMod("RHIMP18")
					For nX := 1 to Len(aCampos)
						For nJ := 1 to Len(aRelac)
							If (nPos := (aScan(aRelac[nJ],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
								aAdd(aIndAux,{nX,aRelac[nJ,1]})
							EndIf 
						Next nJ
					Next nX
				EndIf
				For nX := 1 to Len(aIndAux)
					aLinha[aIndAux[nX,1]] := u_GetCodDP(aRelac,aCampos[aIndAux[nX,1],1],aLinha[aIndAux[nX,1]],aIndAux[nX,2]) //Busca DE-PARA
				Next nX
			EndIf		
			
			cP0_Relogio := SubStr(PadR(aLinha[3],nTamRel),1,nTamRel)
			
			U_IncRuler(OemToAnsi(STR0001),cP0_Relogio,cStart,.F.,,oSelf)		
			
			If 	!SP0->(DbSeek(xFilial('SP0') + cP0_Relogio ))
				RecLock("SP0", .T.)
			Else
				RecLock("SP0", .F.)
			EndIf			
			
			SP0->P0_FILIAL  := xFilial('SP0')
			SP0->P0_RELOGIO := cP0_Relogio
			SP0->P0_DESC    := SubStr(PadR(aLinha[4],nTamDesc),1,nTamDesc)
			SP0->P0_CONTROL := aLinha[5]
			SP0->P0_ARQUIVO := SubStr(PadR(aLinha[6],nTamArq),1,nTamArq)
			SP0->P0_TIPOARQ := 'T'  /* T - para arquivos padrão ASCII, esse valor é padrão do Logix */
			SP0->P0_REP	  := aLinha[7]
			
			IF !Empty(SP0->P0_REP)
				SP0->P0_INC := '1'
			ENDIF
			
			SP0->P0_CODINI	:= Val(aLinha[8])
			SP0->P0_CODFIM	:= Val(aLinha[9])
			SP0->P0_RELOINI	:= Val(aLinha[10])
			SP0->P0_RELOFIM	:= Val(aLinha[11])
			SP0->P0_DIAINI	:= Val(aLinha[12])
			SP0->P0_DIAFIM	:= Val(aLinha[13])
			SP0->P0_MESINI	:= Val(aLinha[14])
			SP0->P0_MESFIM	:= Val(aLinha[15])
			SP0->P0_ANOINI	:= Val(aLinha[16])
			SP0->P0_ANOFIM	:= Val(aLinha[17])
			SP0->P0_HORAINI	:= Val(aLinha[18])
			SP0->P0_HORAFIM	:= Val(aLinha[19])
			SP0->P0_MINUINI	:= Val(aLinha[20])
			SP0->P0_MINUFIM	:= Val(aLinha[21])
			SP0->P0_FUNCINI	:= Val(aLinha[22])
			SP0->P0_FUNCFIM	:= Val(aLinha[23])
			
			aEval(aIniPad,{|x|SP0->&(x[1]) := InitPad(x[2])})		
			
			SP0->(MSUnLock())			
		Else		
			U_IncRuler(OemToAnsi(STR0001),PadR(aLinha[3],nTamRel),cStart,.T.,,oSelf)
		EndIf
		
		FT_FSKIP()
	EndDo
	FT_FUSE()
	
	U_RIM01ERR(aErro)	
	
	RestArea(aArea)
Return (.T.)

/*/{Protheus.doc} InitValues
@author philipe.pompeu
@since 29/07/2015
@version P12
@return ${return}, ${return_description}
/*/
Static Function InitValues()
	Local aArea	:= SX3->(GetArea())
	Local cCpoAtu	:= ''
	Local aIniPad	:= {}
	
	/*Campos que devem utilizar inicializador padrao*/
	cCpoAtu := "P0_CC|P0_ONLINE|P0_CODFOR|P0_RELFOR|P0_DIAFOR|P0_MESFOR|P0_ANOFOR|P0_HORAFOR|P0_MINUFOR|P0_FUNCFOR|P0_GIROINI|"
	cCpoAtu += "P0_GIROFIM|P0_GIROFOR|P0_CCINI|P0_CCFIM|P0_CCFOR|P0_TIPOPER|P0_ELIMINA|P0_NOVO|"
	
	SX3->(DbSetOrder(1))
	SX3->(dbSeek('SP0'))
	
	While !SX3->(EOF()) .And. (SX3->X3_ARQUIVO == 'SP0')
		If (SX3->X3_CAMPO $ cCpoAtu) .and. !Empty(SX3->X3_RELACAO)
			aAdd(aIniPad,{AllTrim(SX3->X3_CAMPO),SX3->X3_RELACAO})
		EndIf
		SX3->(DbSkip())
	EndDo
	
	RestArea(aArea)
Return (aIniPad)
