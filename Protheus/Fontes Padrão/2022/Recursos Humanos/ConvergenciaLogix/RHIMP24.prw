#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RHIMP24.CH"

/*#********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP24.PRW  Autor: PHILIPE.POMPEU  Data:20/01/2016 			   ***
***********************************************************************************
***Descrição..:	Importa o arquivo de bancos										   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:		${param}, ${param_type}, ${param_descr}					   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                           	   ***
***********************************************************************************
***					Alterações feitas desde a construção inicial               	   ***
***********************************************************************************
***Chamado....:                                                                 ***
**********************************************************************************/
/*/{Protheus.doc} RHIMP24
	Função responsável pela importação do arquivo de Bancos;
@author PHILIPE.POMPEU
@since 20/01/2016
@version P11
@param cArquivo, caractere, arquivo para ser importado(caminho completo, ex: "C:\logix\arquivo.unl")
@return nil, Nulo
/*/
User Function RHIMP24(cArquivo,aRelac,oSelf)	
	Local aLinha 	:= {}
	Local aErros 	:= {}
	Local aIndAux	:= {}	
	Local cBuffer 	:= ""
	Local cEmpresa 	:= ""
	Local cFil 		:= ""
	Local cNumLinha := ""
	Local lProcede 	:= .F.
	Local lInvalido	:= .F.
	Local lNew 		:= .T.
	Local nNumLinha := 0	
	Local nTamAgen 	:= 0
	Local nTamCod 	:= 0
	Local nX		:= 0
	Local nJ		:= 0
	Local nPos		:= 0	

	FT_FUSE(cArquivo)	
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)	
	FT_FGOTOP()	
	
	nTamAgen := TamSx3("A6_AGENCIA")[1]
	nTamCod := TamSx3("A6_COD")[1]
	SA6->(DbSetOrder(1))
	
	WHILE !FT_FEOF() .And. !lStopOnErr
		nNumLinha++
		cNumLinha := cValToChar(nNumLinha)
					
		lInvalido	:= .F.
		cBuffer 	:= FT_FREADLN()
		aLinha 		:= Separa(cBuffer,'|')
		cEmpresa 	:= aLinha[1]
		cFil 		:= aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresa := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFil	 := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresa,cFil,'','',.F.,@lProcede,"RHIMP24",{'SRA','SA6'},"FIN",@aErros,OemToAnsi(STR0001))
		
		if(lProcede)
			
			if(Empty(aLinha[3]))/*Código*/			
				aAdd(aErros,"["+ OemToAnsi(STR0002)+" "+cNumLinha+"]:"+ OemToAnsi(STR0003) + '['+ OemToAnsi(STR0005) +']'+ OemToAnsi(STR0004))	
				lInvalido := .T.			
			endIf
			if(Empty(aLinha[4]))/*Nome*/
				aAdd(aErros,"["+cNumLinha+"]:"+ OemToAnsi(STR0003) +'['+ OemToAnsi(STR0006) +']'+ OemToAnsi(STR0004))
				lInvalido := .T.
			endIf
			if(Empty(aLinha[5]))/*Agência*/
				aAdd(aErros,"["+cNumLinha+"]:"+ OemToAnsi(STR0003) +'['+ OemToAnsi(STR0007) +']'+ OemToAnsi(STR0004))
				lInvalido := .T.
			endIf
			if(Empty(aLinha[7]))/*Número Conta*/
				aAdd(aErros,"["+cNumLinha+"]:"+ OemToAnsi(STR0003) +'['+ OemToAnsi(STR0008) +']'+ OemToAnsi(STR0004))
				lInvalido := .T.
			endIf
			
			if(lInvalido)
				U_IncRuler(OemToAnsi(STR0001),OemToAnsi(STR0002)+' '+ cNumLinha,cStart,.F.,,oSelf)				
			Else
			
				//Verifica existencia de DE-PARA
				If !Empty(aRelac)
					If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
						aCampos := U_fGetCpoMod("RHIMP24")
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
						
				cChave := xFilial("SA6")
				cChave += PadR(aLinha[3],nTamCod)
				cChave += PadR(SubStr(aLinha[5],1,4),nTamAgen) 
				cChave += aLinha[7]				
				
				lNew := !SA6->(DbSeek(cChave))
				
				RecLock("SA6",lNew)
				
				SA6->A6_FILIAL	:= xFilial("SA6")
				SA6->A6_COD 	:= aLinha[3]
				SA6->A6_NUMBCO	:= aLinha[3]
				SA6->A6_NOME 	:= aLinha[4]
				SA6->A6_NREDUZ	:= aLinha[4]				
				SA6->A6_AGENCIA	:= SubStr(aLinha[5],1,4)
				
				if(Len(aLinha[5]) > 4)
					SA6->A6_DVAGE:= SubStr(aLinha[5],5,1)	
				Else
					SA6->A6_DVAGE:= ""
				endIf
				
				SA6->A6_NOMEAGE	:= aLinha[6]
				SA6->A6_NUMCON	:= aLinha[7]
				SA6->A6_DVCTA	:= aLinha[8]
				
				SA6->(MsUnlock())
				
				U_IncRuler(OemToAnsi(STR0001),aLinha[3]+"/"+aLinha[7],cStart,.F.,,oSelf)				
			endIf
					
		Else
			U_IncRuler(OemToAnsi(STR0001),OemToAnsi(STR0002)+' '+ cNumLinha,cStart,.T.,,oSelf)			
		endIf
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErros)
		FT_FSKIP()			
	EndDo
	FT_FUSE()/*Libera o Arquivo.*/
		
	U_RIM01ERR(aErros)
Return
