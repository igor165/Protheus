#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP07.CH"

/******************#***************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP02.PRW Autor: Rafael Luis da Silva  Data:23/02/2010 		***
***********************************************************************************
***Descrição..: Responsável pela importação de Turnos.   						***
***********************************************************************************
***Uso........:        															***
***********************************************************************************
***Parâmetros.:		cFileName, caractere, Nome do Arquivo                 	    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***					Alterações feitas desde a construção inicial       	 		***
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP07
	Responsavel em Processar a Importacao dos turnos para a tabela SR6.
@author Rafael Luis da Silva
@since 23/02/2010
@version P11
@param cFileName, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP07(cFileName,aRelac,oSelf)
	Local aArea			:= SR6->(GetArea())
	Local aIndAux		:= {}
	Local cBuffer		:= ""
	Local nNormal		:= 0
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local cEmpresaArq	:= ""
	Local cFilialArq	:= ""
	Local cCodTurno		:= ""
	Local lCompMes		:= (GETMV("MV_COMPMES") == "S")
	Local aTabelas		:= {"SR6"}	
	Local aErro			:= {}
	Local lIsInsert		:= .T.
	Local nTamTurno		:= TamSX3("R6_TURNO")[1]
	Local lFilialVld	:= .F.
	Local aLinha		:= {}
	Local lUsaHrNorm	:= .T.
	Local lChangeEnv 	:= .F.
	Local aInitPad		:= {}
	Local cEmpOri		:= Nil
	
	DEFAULT aRelac		:= {}
	
	If!(U_CanTrunk({'R6_TURNO'}))
		Return (.T.)
	endIf
		
	if(Type("lIgnHrNorm") != "U")
		lUsaHrNorm := !(lIgnHrNorm)	
	endIf	
	
	DbSelectArea("SR6")
	SR6->(DbSetOrder(1))
	SX3->(DbSetOrder(1))
	
	If lCompMes		
		If !CompMes(@nNormal,0,MesAno(Date()))
			nNormal		:= 0			
		EndIf
	EndIf
		
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
		
	While !(FT_FEOF()) .And. !lStopOnErr
		cBuffer := FT_FREADLN()		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		if(!U_Proceed(7,Len(aLinha)))
			Return (.F.)
		Else
			aSize(aLinha,7)
		endIf	
		
		cEmpresaArq	:= aLinha[1]
		cFilialArq	:= aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',@lChangeEnv,@lFilialVld,"GPEA080",aTabelas,,@aErro,OemToAnsi(STR0001))	
		
		If lFilialVld
		
			if(lChangeEnv)
				/* Quando muda a empresa pode ser que a estrutura da tabela mude */
				if(cEmpOri != cEmpAnt)					
					cEmpOri := cEmpAnt			
					aInitPad := {}
					SX3->(dbSeek('SR6'))					
					While !SX3->(EOF()) .And. (SX3->X3_ARQUIVO == 'SR6')
						If !(SX3->X3_CAMPO $ "R6_FILIAL|R6_TURNO") .And.  X3USO(SX3->X3_USADO) .and. !Empty(SX3->X3_RELACAO)
							aAdd(aInitPad,{AllTrim(SX3->X3_CAMPO),SX3->X3_RELACAO})
						EndIf
						SX3->(DbSkip())
					EndDo				 				
				endIf						
			endIf		
			
			//Verifica existencia de DE-PARA
			If !Empty(aRelac)				
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := {{"###EMP###",""},{"R6_FILIAL",""},{"R6_TURNO",""},{"R6_DESC",""},{"R6_HRNORMA",""},{"R6_TPJORN",""},{"R6_DTPJOR",""}}
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

			cCodTurno	:= SubStr(aLinha[3],1,nTamTurno)
			cCodTurno	:= PadR(cCodTurno,nTamTurno)
			
			lIsInsert := !(SR6->(DbSeek(FwXFilial('SR6') + cCodTurno)))	
			
			RecLock("SR6", lIsInsert)					
			
			if(lIsInsert)
				SR6->R6_FILIAL:= FwXFilial('SR6')
				SR6->R6_TURNO	:= cCodTurno
			endIf
			
			aEval(aInitPad,{|x|SR6->&(x[1]) := InitPad(x[2])})
						
			SR6->R6_DESC := aLinha[4]
			
			if(lUsaHrNorm)				
				If nNormal <= 0				
					SR6->R6_HRNORMA := IIF(Empty(aLinha[5]),0,Val(aLinha[5])) 
				EndIf			
			endIf
						
			SR6->R6_TPJORN := aLinha[6]			
			SR6->R6_DTPJOR := aLinha[7]
			
			SR6->(MSUnLock())
			
			U_IncRuler(OemToAnsi(STR0001),SR6->R6_TURNO,cStart,(!lFilialVld),/*lOnlyMsg*/,oSelf)
		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[3],cStart,(!lFilialVld),/*lOnlyMsg*/,oSelf)
		EndIf
		/*Checa se deve parar o processamento.*/
		U_StopProc(aErro)		
		FT_FSKIP()		
	EndDo
	FT_FUSE()
	
	U_RIM01ERR(aErro)
	aSize(aLinha,0)
	aLinha := Nil
	aSize(aErro,0)
	aErro := Nil
	aSize(aTabelas,0)
	aTabelas := Nil
	RestArea(aArea)
Return (.T.)
