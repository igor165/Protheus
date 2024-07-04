#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMV540TOL()

Rotina de respons�vel por validar a toler�ncia entrea a atividades

@param	  aHrGrvAOF - array contendo as atividades
          cHrCheckIn -  hora de execu��o da atividade do uMov.Me
		 
@return  array - contendo a atividade do que dever� ser atualizada

@author   Victor Bitencourt
@since    03/12/2014
@version  12.1.3
/*/
//-------------------------------------------------------------------
Function CRMV540TOL(aHrGrvAOF,cHrCheckIn)

Local cTolera       := SuperGetMV("MV_AGEHRME",.T.,"00:30:00")
Local aRet          := {}
Local cTemMed       := ""
Local nX	   	      := 0

Default aHrGrvAOF   := {}
Default cHrCheckIn  := ""

If !Empty(aHrGrvAOF) .AND. !Empty(cHrCheckIn)

	//-------------------------------------------------------------------------------
	//	 Calculando a diferen�a dos tempos entre a hora da atividade e a do Check-in  
	//-------------------------------------------------------------------------------	
	For nX := 1 To Len(aHrGrvAOF)
		If aHrGrvAOF[nX][2] >= cHrCheckIn
			cTemMed := ElapTime(cHrCheckIn,aHrGrvAOF[nX][2])
			Aadd(aHrGrvAOF[nX],cTemMed)
	    Else
	    	cTemMed := ElapTime(aHrGrvAOF[nX][2],cHrCheckIn)
	    	Aadd(aHrGrvAOF[nX],cTemMed)
	    EndIf
	Next nZ 

	//-----------------------------------------------------------------------------------
	//	Ordenando o Array do Menor para o Maio, sendo que o menor, ser� a menor difer�a
	// entre os tempos.
	//-----------------------------------------------------------------------------------	
	aSort(aHrGrvAOF,,,{|x,y| x[3] < y[3]})
	
	//-------------------------------------------------------------------------------
	//	Se o menor diferen�a estiver dentro da toler�ncia, ent�o ser� atualizada essa
	// atividade com o cod unico do umov, n�o ser� necess�rio cria uma nova
	//-------------------------------------------------------------------------------	
	If aHrGrvAOF[1][3] <= cTolera
	    aRet := aHrGrvAOF[1]
	EndIf

EndIf

Return aRet 

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMV540VST()

V�lida estrutura do execAuto


@param	   cEntidade - Entidade que dever� ser v�lidada
		   aEstrTmp -  array com os dados que dever�o ser validados
		 
@return   aEstruct - Array com dados a serem gravados pelo execauto. 

@author   Victor Bitencourt
@since    03/12/2014
@version  12.1.3

/*/
//------------------------------------------------------------------------------------------------
Function CRMV540VST(cEntidade,aEstrTmp)

Local aAreaSX3 := SX3->(GetArea())
Local aEstruct := {}
Local nPos 	 := 0

SX3->(DbSetOrder(1))//X3_ARQUIVO+X3_ORDEM

If SX3->(DbSeek(cEntidade))
	While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cEntidade
	    If X3Uso(SX3->X3_USADO) .AND. SX3->X3_CONTEXT <> "V"
			nPos := aScan(aEstrTmp,{|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})
			If nPos >= 1
				Aadd(aEstruct,{aEstrTmp[nPos][1],aEstrTmp[nPos][2],Nil})
			EndIf
		EndIf		
	SX3->(DbSkip())
	EndDo
EndIf

RestArea(aAreaSX3)

Return aEstruct
