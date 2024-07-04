#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP06.CH"

/*******#**************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP06.PRW Autor: Rafael Luis da Silva  Data:23/02/2010 		***
***********************************************************************************
***Descrição..: Responsável pela importação de Verbas.   						***
***********************************************************************************
***Uso........:        															***
***********************************************************************************
***Parâmetros.:		cFileName, caractere, Nome do Arquivo                 	    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***					Alterações feitas desde a construção inicial       	 		***
***********************************************************************************
***RESPONSÁVEL.|DATA....|CÓDIGO|BREVE DESCRIÇÃO DA CORREÇÃO.....................***
***********************************************************************************
***P. Pompeu...|15/04/16|TSQLH9|Preencher c/ zero campos RV_INCSIND e RV_CODFOL ***
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
***Oswaldo L   |04/07/17|DRHESO|Remover tratativas de campos que passaram       ***
***            |        |CP-552|a ser "nao utilizados" no SX3                   *** 
**********************************************************************************/

/*/{Protheus.doc} RHIMP06
Responsavel em Processar a Importacao das verbas para a tabela SRV.
@author Rafael Luis da Silva
@since 23/02/2010
@version P11
@param cFileName, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP06(cFileName,aRelac,oSelf)
	Local aArea		:= 	SRV->(GetArea())
	Local aIndAux	:= {}
	Local cBuffer	:= ""
	Local cEmpresaArq	:= ""
	Local cFilialArq	:= ""
	Local aTabelas	:= {"SRV"}	
	Local lExiste	:= .F.
	Local lIsInsert	:= .F.
	Local aErro		:= {}
	Local aLinha	:= {}
	Local xINSSFER	:= CriaVar("RV_INSSFER"	,.T.,'L',.F.)			
	Local xLEEINC	:= CriaVar("RV_LEEINC"	,.T.,'L',.F.)			
	Local xLEEPRE	:= CriaVar("RV_LEEPRE"	,.T.,'L',.F.)			
	Local xLEEAUS	:= CriaVar("RV_LEEAUS"	,.T.,'L',.F.)
	Local xLEEBEN	:= CriaVar("RV_LEEBEN"	,.T.,'L',.F.)
	Local xLEEFIX	:= CriaVar("RV_LEEFIX"	,.T.,'L',.F.)			
	Local xFECCOMP	:= CriaVar("RV_FECCOMP"	,.T.,'L',.F.)			
	Local xCODMEMO	:= CriaVar("RV_CODMEMO"	,.T.,'L',.F.)			
	Local xFERSEG	:= CriaVar("RV_FERSEG"	,.T.,'L',.F.)			
	Local xEMPCONS	:= CriaVar("RV_EMPCONS"	,.T.,'L',.F.)			
	Local xDESCDET	:= CriaVar("RV_DESCDET"	,.T.,'L',.F.)			
	Local xBASCAL	:= CriaVar("RV_BASCAL"	,.T.,'L',.F.)			
	Local xIMPRIPD	:= CriaVar("RV_IMPRIPD"	,.T.,'L',.F.)			
	Local xCODMSEG	:= CriaVar("RV_CODMSEG"	,.T.,'L',.F.)			
	Local xCODCOM_	:= CriaVar("RV_CODCOM_"	,.T.,'L',.F.)
	Local nTamIncSnd:= TamSx3("RV_INCSIND")[1]
	Local nTamCodFol:= TamSx3("RV_CODFOL")[1]
	Local nX		:= 0
	Local nJ		:= 0
	Local nPos		:= 0
	
	DEFAULT aRelac 		:= {}
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	dbSelectArea("SRV")
	SRV->(dbSetOrder(1))
	
	While !FT_FEOF() .And. !lStopOnErr	
		cBuffer := FT_FREADLN()		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		if(!U_Proceed(43,Len(aLinha)))
			Return (.F.)
		Else
			aSize(aLinha,43)
		endIf	
		cEmpresaArq	:=aLinha[1]
		cFilialArq	:=aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',.F.,@lExiste,"GPEA040",aTabelas,"GPE",@aErro,OemToAnsi(STR0001))
		
		IF lExiste

			//Verifica existencia de DE-PARA
			If !Empty(aRelac)				
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := U_fGetCpoMod("RHIMP06")
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
		
			lIsInsert := !(SRV->(dbSeek(FwXFilial('SRV',cFilialArq) + aLinha[3])))
			RecLock("SRV", lIsInsert)
			
			if(lIsInsert)				
				SRV->RV_FILIAL	:= FwXFilial('SRV',cFilialArq)
				SRV->RV_COD 	:= IIF(Empty(aLinha[3]),'',aLinha[3])
				SRV->RV_DESC 	:= aLinha[4]
				SRV->RV_INSSFER	:= xINSSFER
				SRV->RV_LEEINC	:= xLEEINC
				SRV->RV_LEEPRE	:= xLEEPRE
				SRV->RV_LEEAUS	:= xLEEAUS
				SRV->RV_LEEBEN	:= xLEEBEN
				SRV->RV_LEEFIX	:= xLEEFIX
				SRV->RV_FECCOMP	:= xFECCOMP
				SRV->RV_CODMEMO	:= xCODMEMO
				SRV->RV_BASCAL	:= xBASCAL
				SRV->RV_FERSEG	:= xFERSEG
				SRV->RV_EMPCONS	:= xEMPCONS
				SRV->RV_DESCDET	:= aLinha[4]
				SRV->RV_IMPRIPD	:= xIMPRIPD
				SRV->RV_CODMSEG	:= xCODMSEG
				SRV->RV_CODCOM_	:= xCODCOM_
			EndIf
			
			U_IncRuler(OemToAnsi(STR0001),SRV->RV_COD,cStart,(!lExiste),/*lOnlyMsg*/,oSelf)

			If !Empty(aRelac)
				For nX := 5 to Len(aCampos)
					If !Empty(aLinha[nX])
						SRV->(&(aCampos[nX,1])) := aLinha[nX]
					EndIf
				Next nX
				SRV->RV_PERC 		:= IIF(Empty(aLinha[7]),0,Val(aLinha[7]))
				SRV->RV_INCSIND 	:= PadL(aLinha[34],nTamIncSnd,"0")
			Else
				SRV->RV_TIPOCOD		:= aLinha[5]
				SRV->RV_TIPO		:= aLinha[6]
				SRV->RV_PERC 		:= IIF(Empty(aLinha[7]),0,Val(aLinha[7])) 
				SRV->RV_LCTOP		:= aLinha[8]
				SRV->RV_MED13		:= aLinha[9]
				SRV->RV_MEDFER		:= aLinha[10]
				SRV->RV_MEDAVI		:= aLinha[11]
				SRV->RV_CODFOL		:= If(!Empty(aLinha[12]),PadL(aLinha[12],nTamCodFol,"0"),"")
				SRV->RV_INSS  		:= aLinha[13]
				SRV->RV_IR 	 		:= aLinha[14]
				SRV->RV_FGTS  		:= aLinha[15]
				SRV->RV_REF13		:= aLinha[16]
				SRV->RV_REFFER		:= aLinha[17]
				SRV->RV_ADIANTA 	:= aLinha[18]
				SRV->RV_PERICUL 	:= aLinha[19]
				SRV->RV_INSALUB 	:= aLinha[20]
				SRV->RV_SINDICA 	:= aLinha[21]
				SRV->RV_SALFAMI 	:= aLinha[22]
				SRV->RV_DEDINSS 	:= aLinha[23]
				SRV->RV_RAIS	   	:= aLinha[24]
				SRV->RV_DIRF    	:= aLinha[25]			
				SRV->RV_NATUREZ 	:= aLinha[26]			
				SRV->RV_DSRHE		:= aLinha[27]			
				/* Já esta definido nos campos 9, 10 e 11
				SRV->RV_MED13		:= aLinha[28]			
				SRV->RV_MEDFER		:= aLinha[29]			
				SRV->RV_MEDAVI		:= aLinha[30]
				*/			
				SRV->RV_INCCP		:= aLinha[31]			
				SRV->RV_INCIRF		:= aLinha[32]			
				SRV->RV_INCFGTS 	:= aLinha[33]			
				SRV->RV_INCSIND 	:= PadL(aLinha[34],nTamIncSnd,"0")			
							
				SRV->RV_TPPIRRF 	:= aLinha[36]			
				SRV->RV_TPPFGTS 	:= aLinha[37]			
				SRV->RV_TPPSIND 	:= aLinha[38]			
							
				
			EndIf

			SRV->(MSUnLock())			
		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[3],cStart,(!lExiste),/*lOnlyMsg*/,oSelf)
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
Return(.T.)
