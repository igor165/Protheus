#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP04.CH"

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP04.PRW Autor: Rafael Luis da Silva  Data:22/02/2010 		***
***********************************************************************************
***Descrição..: Responsável pela importação de Departamentos.					***
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

/*/{Protheus.doc} RHIMP04
Responsavel em Processar a Importacao dos departamentos para a Tabela SQB.
@author Rafael Luis da Silva
@since 22/02/2010
@version P11
@param cFileName, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP04(cFileName,aRelac,oSelf)
	Local aArea			:= SQB->(GetArea())
	Local cBuffer		:= ""
	Local cEmpresaArq	:= ""
	Local cFilialArq	:= ""	
	Local cDepCod		:= ""
	Local aTabelas		:= {"SQB"}
	Local lExiste		:= .F.
	Local nTamDepto		:= TamSx3("QB_DEPTO")[1]
	Local nTamCC		:= TamSx3("QB_CC")[1]
	Local lIsInsert		:= .T.
	Local aLinha		:= {}
	Local aErro			:= {}
	
	DEFAULT aRelac := {}
	
	If!(U_CanTrunk({'QB_DEPTO','QB_CC'}))
		Return (.T.)
	endIf
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	DbSelectArea("SQB")
	SQB->(DbSetOrder(1))
	
	While !(FT_FEOF()) .And. !lStopOnErr
		cBuffer := FT_FREADLN()		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cEmpresaArq	:= aLinha[1]
		cFilialArq	:= aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',.F.,@lExiste,"CSAA100",aTabelas,"GPE",@aErro,OemToAnsi(STR0001))
		
		cDepCod := SubStr(aLinha[3],1,nTamDepto)
		cDepCod := PadR(cDepCod,nTamDepto)
		
		IF lExiste
		
			If !Empty(aRelac)
				cDepCod := u_GetCodDP(aRelac,"QB_DEPTO",cDepCod,"QB_DEPTO") //Busca DE-PARA
				aLinha[5] := u_GetCodDP(aRelac,"QB_CC",aLinha[5],"CTT_CUSTO") //Busca DE-PARA				
			EndIf
										
			lIsInsert := !(SQB->(DbSeek(FwXFilial('SQB') + cDepCod)))				
			RecLock("SQB", lIsInsert)
				
			IF 	lIsInsert
				SQB->QB_FILIAL  := FwXFilial('SQB')
				SQB->QB_DEPTO	:= cDepCod			
			EndIf
			
			SQB->QB_DESCRIC	:= aLinha[4]			
			SQB->QB_CC 		:= SubStr(aLinha[5],1,nTamCC)
			U_IncRuler(OemToAnsi(STR0001),SQB->QB_DEPTO,cStart,(!lExiste),/*lOnlyMsg*/,oSelf)
			
			SQB->(MsUnlock())
		Else
			U_IncRuler(OemToAnsi(STR0001),cDepCod,cStart,(!lExiste),/*lOnlyMsg*/,oSelf)						
		EndIf		
		/*Checa se deve parar o processamento.*/
		U_StopProc(aErro)
		FT_FSKIP()		
	EndDo
	FT_FUSE()
	
	U_RIM01ERR(aErro)
	aSize(aLinha,0)
	aLinha := Nil
	aSize(aTabelas,0)
	aTabelas := Nil
	RestArea(aArea)
Return (.T.)
