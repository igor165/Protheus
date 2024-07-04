#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP05.CH"

/**#*******************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP05.PRW Autor: Rafael Luis da Silva  Data:23/02/2010 	    ***
***********************************************************************************
***Descrição..: Responsável pela importação de Sindicatos. 					    ***
***********************************************************************************
***Uso........:        														    ***
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

/*/{Protheus.doc} RHIMP05
Responsavel em Processar a Importacao dos sindicatos para a
Tabela RCE.
@author Rafael Luis da Silva
@since 23/02/2010
@version P11
@param cFileName, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP05(cFileName,aRelac,oSelf)
	Local aArea			:= 	RCE->(GetArea())
	Local aIndAux		:= {}
	Local cBuffer		:= ""
	Local aLinha		:= {}
	Local aCampos		:= {}
	Local cEmpresaArq   := ""
	Local cFilialArq    := ""
	Local lExiste       := .F.
	Local aTabelas 	 	:= {"RCE"}
	Local lEnvChange 	:= .F.
 	Local oModel		:= Nil
 	Local oAux,oStruct
 	Local aStruct		:= {}
 	Local nTamDescri	:= TamSx3("RCE_DESCRI")[1]
 	Local nX			:= 0
 	Local nY			:= 0
 	Local nPos			:= 0
	Private aErro       := {}
	
	DEFAULT aRelac 		:= {}
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	aAdd(aCampos,{'RCE_FILIAL'})	
	aAdd(aCampos,{'RCE_CODIGO'})	
	aAdd(aCampos,{'RCE_DESCRI'})
	aAdd(aCampos,{'RCE_MUNIC'})
	aAdd(aCampos,{'RCE_UF'})
	aAdd(aCampos,{'RCE_MESDIS'})	
	aAdd(aCampos,{'RCE_DIADIS'})	
	aAdd(aCampos,{'RCE_PISO'})	
	aAdd(aCampos,{'RCE_ENDER'})
	aAdd(aCampos,{'RCE_NUMER'})
	aAdd(aCampos,{'RCE_COMPLE'})
	aAdd(aCampos,{'RCE_BAIRRO'})
	aAdd(aCampos,{'RCE_CEP'})
	aAdd(aCampos,{'RCE_CGC'})
	aAdd(aCampos,{'RCE_ENTSIN'})
	aEval(aCampos,{|x|aAdd(x,'')})
	
	dbSelectArea('RCE')
	RCE->(dbSetOrder(1))
	
	While !(FT_FEOF()) .And. !lStopOnErr
		cBuffer := FT_FREADLN()		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)		
		cEmpresaArq :=aLinha[1]
		cFilialArq	:=aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',@lEnvChange,@lExiste,"GPEA340",aTabelas,"GPE",@aErro,OemToAnsi(STR0001))
		
		if(lEnvChange) /* Toda vez que o ambiente mudar */
			if(oModel <> Nil)
				oModel:DeActivate()
				oModel:Destroy()
				oModel:= nil
				aSize(aStruct,0)
			endIf
			
			oModel := FWLoadModel('GPEA340')
			oAux 	:= oModel:GetModel('GPEA340_RCE')
			oStruct:= oAux:GetStruct()		
			aStruct:= oStruct:GetFields()			
			
			oStruct:= Nil
			oAux	:= Nil
		endIf
		
		IF lExiste
		
			aCampos[1,2] := FwXFilial('RCE')
			aCampos[2,2] := IIF(Empty(aLinha[3]),'',aLinha[3])			
			aCampos[3,2] := SubStr(aLinha[4],1,nTamDescri)
			aCampos[4,2] := aLinha[5]			
			aCampos[5,2] := aLinha[6]
			aCampos[6,2] := aLinha[7]
			aCampos[7,2] := IIF(Empty(aLinha[8]),0,Val(aLinha[8]))
			aCampos[8,2] := IIF(Empty(aLinha[9]),0,Val(aLinha[9]))
			aCampos[9,2] := aLinha[10]
			aCampos[10,2]:= aLinha[11]
			aCampos[11,2]:= aLinha[12]
			aCampos[12,2]:= aLinha[13]
			aCampos[13,2]:= aLinha[14]
			aCampos[14,2]:= aLinha[15]
			aCampos[15,2]:= aLinha[16]
			
			//Verifica existencia de DE-PARA
			If !Empty(aRelac)
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					For nX := 1 to Len(aCampos)
						For nY := 1 to Len(aRelac)
							If (nPos := (aScan(aRelac[nY],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
								aAdd(aIndAux,{nX,aRelac[nY,1]})
							EndIf 
						Next nY
					Next nX
				EndIf
				For nX := 1 to Len(aIndAux)
					aCampos[aIndAux[nX,1],2] := u_GetCodDP(aRelac,aCampos[aIndAux[nX,1],1],aCampos[aIndAux[nX,1],2],aIndAux[nX,2]) //Busca DE-PARA
				Next nX
			EndIf
			
			U_IncRuler(OemToAnsi(STR0001),aCampos[2,2],cStart,(!lExiste),/*lOnlyMsg*/,oSelf)
			Begin Transaction			
				U_RIM01MVC('RCE', aCampos,'GPEA340',OemToAnsi(STR0001),aCampos[2,2],'GPEA340_RCE',.F.,oModel,aStruct)
			End Transaction			
		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[3],cStart,(!lExiste),/*lOnlyMsg*/,oSelf)
		EndIf
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
	aSize(aErro,0)
	aErro := Nil	
	aSize(aLinha,0)
	aLinha := Nil	
	RestArea(aArea)
Return(.T.)
