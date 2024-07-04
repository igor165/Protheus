#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP19.CH"

/********************************************************************************##
***********************************************************************************
***********************************************************************************
***Funcão..: RHIMP19.prw Autor: Edna Dalfovo Data: 21/02/2013                   ***
***********************************************************************************
***Descrição..:Importação dos Crachás Provisórios(SPE)      					   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:		cFileName, caractere, Nome do Arquivo              		   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/
/*/{Protheus.doc} RHIMP19
	Importação dos Crachás Provisórios(SPE)
@author Edna Dalfovo
@since 21/02/2013
@version P11
@param cFileName, caractere, Nome do Arquivo
@return ${return}, ${return_description}
/*/
User Function RHIMP19(cFileName,aRelac,oSelf)
	Local aArea			:= GetArea()
	Local aAreaSRA		:= SRA->(GetArea())
	Local aAreaSPE		:= SPE->(GetArea())
	Local aIndAux		:= {}
	Local aLinha		:= {}
	Local cBuffer		:= ""
	Local cEmpresaArq	:= ""
	LOCAL cFilialArq	:= ""
	LOCAL cPE_Matprov	:= ""
	LOCAL cPE_Mat		:= ""
	LOCAL dPE_DataIni	:= CtoD("//")
	Local aTabelas 		:= {"SRA","SPE"}
	Local nTamMat 		:= TamSX3("RA_MAT")[1]
	Local nTmMatProv	:= TamSX3("PE_MATPROV")[1]
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local aErro			:= {}
	Local lExiste		:= .T.
	
	DEFAULT aRelac		:= {}
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	SRA->(DbSetOrder(1))
	SPE->(DbSetOrder(3))
	
	While !FT_FEOF() .And. !lStopOnErr		
		cBuffer := FT_FREADLN()
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cEmpresaArq		:= aLinha[1]
		cFilialArq		:= aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',.F.,@lExiste,"PONA120",aTabelas,"PON",@aErro,OemToAnsi(STR0001))
		
		//Verifica existencia de DE-PARA
		If !Empty(aRelac)
			If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
				aCampos := U_fGetCpoMod("RHIMP19")
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
		
		cPE_Matprov	:= PadR(aLinha[3],nTmMatProv)
		cPE_Mat	 	:= PadR(aLinha[4],nTamMat)
		
		IF lExiste			
			
			U_IncRuler(OemToAnsi(STR0001),cPE_Mat + '-' +  cPE_Matprov,cStart,.F.,,oSelf)	
			
			dPE_DataIni 	:= CtoD(aLinha[5])
			
			IF 	(SRA->(DbSeek(xFilial('SRA') + cPE_Mat))) .OR. Empty(cPE_Mat)
				
				IF !SPE->(DbSeek(xFilial('SPE') + cPE_Matprov + cPE_Mat + DtoS(dPE_DataIni)))
					
					RecLock("SPE", .T.)
					SPE->PE_FILIAL 	:= xFilial('SPE')
					SPE->PE_MATPROV := cPE_Matprov
					SPE->PE_MAT 	:= cPE_Mat
					SPE->PE_DATAINI :=  dPE_DataIni
				Else
					RecLock("SPE", .F.)
				EndIf
				SPE->PE_DATAFIM := CtoD(aLinha[6])
				
				SPE->(MSUnLock())
			Else
				aAdd(aErro,'[' + cEmpresaArq + '/' + cFilialArq + '/' + cPE_Mat + ']'  + OemToAnsi(STR0002))
			EndIf
		Else
			U_IncRuler(OemToAnsi(STR0001),cPE_Mat + '-' +  cPE_Matprov,cStart,.F.,,oSelf)
		EndIf
		
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErro)
		FT_FSKIP()
	EndDo
	FT_FUSE()
	
	U_RIM01ERR(aErro)	
	aSize(aErro,0)
	aErro := Nil
	
	RestArea(aAreaSPE)
	aSize(aAreaSPE,0)
	aAreaSPE := Nil
	RestArea(aAreaSRA)
	aSize(aAreaSRA,0)
	aAreaSRA := Nil
	RestArea(aArea)
	aSize(aArea,0)
	aArea := Nil
	
Return(.T.)
