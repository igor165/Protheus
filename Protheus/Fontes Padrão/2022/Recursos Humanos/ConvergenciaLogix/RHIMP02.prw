#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP02.CH"

/******##**************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP02.PRW Autor: Rafael Luis da Silva  Data:23/02/2010 		***
***********************************************************************************
***Descrição..: Responsável pela importação de Cargos.   						***
***********************************************************************************
***Uso........:        															***
***********************************************************************************
***Parâmetros.: cFileName, caractere, Nome do Arquivo                     	    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***					Alterações feitas desde a construção inicial       	 		***
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP02
	Responsável pela importação de Cargos.
@author Rafael Luis da Silva
@since 23/02/2010
@version P11
@param cFileName, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP02(cFileName,aRelac,oSelf)
	Local aArea		:= 	SRJ->(GetArea())
	Local aIndAux		:= {}
	Local cBuffer		:= ""	
	Local cEmpresaArq	:= ""
	LOCAL cFilialArq	:= ""	
	Local aCampos		:= {}	
	Local aTabelas		:= {"SRJ"}
	Local lExiste 		:= .F.
 	Local cEntity 		:= OemToAnsi(STR0001)
 	Local nTamDESC		:= TamSx3('RJ_DESC')[1]
 	Local nX			:= 0
 	Local nJ			:= 0
 	Local nPos			:= 0
 	Local aLinha		:= {}
 	Local lEnvChange 	:= .F.
 	Local oModel		:= Nil
 	Local oAux,oStruct
 	Local aStruct		:= {}	
	Private aErro 		:= {}
	
	DEFAULT aRelac := {}
	
	If!(U_CanTrunk({'RJ_DESC'}))
		Return (.T.)
	endIf
	
 	aAdd(aCampos,{'RJ_FILIAL'	,''})
	aAdd(aCampos,{'RJ_FUNCAO'	,''})
	aAdd(aCampos,{'RJ_DESC'		,''})
	aAdd(aCampos,{'RJ_CODCBO'	,''})
 
	FT_FUSE(cFileName)
	
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	
	FT_FGOTOP()
	
	dbSelectArea('SRJ')
	SRJ->(dbSetOrder(1))
		
	While !(FT_FEOF()) .And. !lStopOnErr
		cBuffer := FT_FREADLN()    
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		aSize(aLinha,5) /*Garante que sempre terá 5 posições.*/

		cEmpresaArq		:= aLinha[1]
		cFilialArq		:= aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',@lEnvChange,@lExiste,"GPEA030",aTabelas,,@aErro,cEntity)
		
		if(lEnvChange)
			if(oModel <> Nil)
				oModel:DeActivate()
				oModel:Destroy()
				oModel:= nil
				aSize(aStruct,0)
			endIf
			
			oModel := FWLoadModel('GPEA030')
			oAux 	:= oModel:GetModel('GPEA030_SRJ')
			oStruct:= oAux:GetStruct()		
			aStruct:= oStruct:GetFields()			
			
			oStruct:= Nil
			oAux	:= Nil
		endIf
		
		IF lExiste				
			U_IncRuler(cEntity,aLinha[3],cStart,(!lExiste),,oSelf)			
			aCampos[1,2] := FwXFilial('SRJ') // Filial
			aCampos[2,2] := aLinha[3] // Função			
			aCampos[3,2] := SubStr(aLinha[4],1,nTamDESC)// Descrição
			aCampos[4,2] := aLinha[5] // Cod. Cbo

			//Verifica existencia de DE-PARA
			If !Empty(aRelac)
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					For nX := 1 to Len(aCampos)
						For nJ := 1 to Len(aRelac)
							If (nPos := (aScan(aRelac[nJ],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
								aAdd(aIndAux,{nX,aRelac[nJ,1]})
							EndIf 
						Next nJ
					Next nX
				EndIf
				For nX := 1 to Len(aIndAux)
					aCampos[aIndAux[nX,1],2] := u_GetCodDP(aRelac,aCampos[aIndAux[nX,1],1],aCampos[aIndAux[nX,1],2],aIndAux[nX,2]) //Busca DE-PARA
				Next nX
			EndIf
						
			Begin Transaction			
				U_RIM01MVC( 'SRJ', aCampos,'GPEA030',cEntity,aLinha[3],'GPEA030_SRJ',.F.,oModel,aStruct)								
			End Transaction			
		Else
			U_IncRuler(cEntity,aLinha[3],cStart,(!lExiste),,oSelf)
		ENDIF	
		
		/*Checa se deve parar o processamento.*/
		U_StopProc(aErro)
		FT_FSKIP()
	ENDDO 
	FT_FUSE()
	
	U_RIM01ERR(aErro)	
	
	aSize(aCampos,0)
	aCampos := Nil
	aSize(aTabelas,0)
	aTabelas := Nil
	aSize(aLinha,0)
	aLinha := Nil
		
	RestArea(aArea)	
Return ( Nil )
