#INCLUDE "rwmake.ch"   

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEE001()
Calculo Volume de Produto no Tanque com Base em Fatores
Adaptação da função TDCEE002
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
@return _nVolume
/*/
//-------------------------------------------------------------------
Function DCLEE002()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cFaixa  :=ALLTRIM(SUPERGETMV('MV_FXARQ',.F.,'I'))
Local aAreaDHG := DHG->(GetArea())

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

SetPrvt("_CALIAS,_CINDEX,_NRECNO,nCONTA,_VOLUME,_SELO")

If SuperGetMv("MV_DCLNEW",.F.,.F.)
	_cAlias	:= Alias()
	_cIndex	:= IndexOrd()
	_nRecno	:= Recno()
	nConta		:= 0
	_nVolume	:= 0
	
	_SELO :=	GETMV("MV_SELOINI",.F.,0)
	dbSelectArea("DHG")
	DHG->(dbSetOrder(1))
	DHG->(dbSeek(xFilial() + M->DH7_TANQUE,.F.))
	
	While !(Eof()) .and. DHG->DHG_FILIAL == xFilial() .and. DHG->DHG_TANQUE == M->DH7_TANQUE
		
		If (M->DH7_ALTPRO) >= DHG->DHG_CMINI .and. (M->DH7_ALTPRO) <= DHG->DHG_CMFIM
			
			IF cFaixa=='F'
				nconta:= DHG->DHG_CMFIM - M->DH7_ALTPRO
			Else
				nconta:= M->DH7_ALTPRO - DHG->DHG_CMINI
			Endif
			
			If nconta > 0
				If M->DH7_ALTPRO >= _SELO
					IF cFaixa=='F'
						_nvolume:= Int((DHG->DHG_ACUM - NoRound(DHG->DHG_FATOR * nconta)-DHG->DHG_LASTRO))
					ELSE
						_nvolume:= Int((DHG->DHG_ACUM + NoRound(DHG->DHG_FATOR * nconta)-DHG->DHG_LASTRO))
					ENDIF
				Else
					IF cFaixa=='F'
						_nvolume:= Int(DHG->DHG_ACUM - NoRound(DHG->DHG_FATOR * nconta))
					ELSE
						_nvolume:= Int(DHG->DHG_ACUM + NoRound(DHG->DHG_FATOR * nconta))
					ENDIF
				Endif
			else
				If M->DH7_ALTPRO >= _SELO
					_nVolume:= Int(DHG->DHG_ACUM-DHG->DHG_LASTRO)
				Else
					_nVolume:= Int(DHG->DHG_ACUM)
				Endif
			endif
			Exit
		Endif
		DbSelectArea("DHG")
		DHG->(DbSkip())
	Enddo
	
	dbSelectArea(_cAlias)
	dbSetOrder(_cIndex)
	dbGoTo(_nRecno)
	
	RestArea(aAreaDHG)
	
EndIf

Return(_nVolume)



