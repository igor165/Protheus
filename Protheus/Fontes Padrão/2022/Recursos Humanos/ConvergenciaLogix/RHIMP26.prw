#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#define STR0001 "V.A/V.R
/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP26.PRW  Autor: PHILIPE.POMPEU  Data:01/02/2016 			***
***********************************************************************************
***Descrição..:	Importa o arquivo de Vale Refeição								***
***********************************************************************************
***Uso........:        															***
***********************************************************************************
***Parâmetros.:		${param}, ${param_type}, ${param_descr}					    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                           	***
***********************************************************************************
***					Alterações feitas desde a construção inicial                ***
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/
/*/{Protheus.doc} RHIMP26
	Função responsável pela importação do arquivo de Vale Refeição	;
@author PHILIPE.POMPEU
@since 01/02/2016
@version P12
@param cArquivo, caractere, arquivo para ser importado(caminho completo, ex: "C:\logix\arquivo.unl")
@return nil, Nulo
/*/
User Function RHIMP26(cArquivo,aRelac,oSelf)
	Local aArea 	:= {}
	Local aLinha 	:= {}
	Local aErros 	:= {}
	Local aIndAux	:= {}
	Local cEmpresa 	:= ""
	Local cFil 		:= ""
	Local cBuffer 	:= ""
	Local cNumLinha := ""
	Local cNext		:= ""
	Local cTipo		:= ""
	Local cChave	:= ""
	Local cEmpOri	:= Nil
	Local lProcede 	:= .F.
	Local lInvalido	:= .F.
	Local lNew 		:= .T.
	Local nNumLinha := 0
	Local nX		:= 0
	Local nJ		:= 0
	Local nY		:= 0
	Local nPos		:= 0
	Local cIncMsg	:= ''
    Local lNovoCalc 	:= NovoCalcBEN()	
	
	DEFAULT aRelac	:= {}

	FT_FUSE(cArquivo)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	SRA->(DbSetOrder(1))
	RFO->(DbSetOrder(1))
	IF !lNovoCalc
		SR0->(DbSetOrder(3))	
	Else
		SM7->(DbSetOrder(3))	
	EndIf
	
	WHILE !FT_FEOF() .And. !lStopOnErr
		nNumLinha++
		cNumLinha := cValToChar(nNumLinha)
		cIncMsg := "Processando Linha ["+ cNumLinha +"]..." 
		
		if(oSelf != Nil)
			oSelf:IncRegua2(cIncMsg)
		else
			IncProc(cIncMsg)
		endIf	
					
		lInvalido:= .F.
		cBuffer 	:= FT_FREADLN()
		aLinha 	:= Separa(cBuffer,'|')/*Tamanho 13*/
		
		cTipo	 	:= aLinha[1]
		
		//Verifica existencia de DE-PARA
		If !Empty(aRelac)			
			If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
				aCamposAux := U_fGetCpoMod("RHIMP26")
				aIndAux2   := {}
				For nY := 1 to 2
					aCampos := aClone(aCamposAux[nY])
					aIndAux := {}
					For nX := 1 to Len(aCampos)
						For nJ := 1 to Len(aRelac)
							If (nPos := (aScan(aRelac[nJ],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
								aAdd(aIndAux,{nX,aRelac[nJ,1]})
							EndIf 
						Next nJ
					Next nX
					aAdd(aIndAux2,aClone(aIndAux))
				Next nY
			EndIf
			If cTipo == "1"
				aIndAux := aClone(aIndAux2[1])
				aCampos := aClone(aCamposAux[1])
			Else
				aIndAux := aClone(aIndAux2[2])
				aCampos := aClone(aCamposAux[2])
			EndIf
			For nX := 1 to Len(aIndAux)
				aLinha[aIndAux[nX,1]] := u_GetCodDP(aRelac,aCampos[aIndAux[nX,1],1],aLinha[aIndAux[nX,1]],aIndAux[nX,2]) //Busca DE-PARA
			Next nX
		EndIf		
		
		Do Case
			Case (cTipo == "1")/*RFO*/				
				
				SM0->(dbGoTop())				
				
				While ( SM0->(!Eof()) )
					U_RHPREARE(SM0->M0_CODIGO,SM0->M0_CODFIL,'','',.F.,.F.,"RHIMP26",{'SRA','SRQ'},"GPE",@aErros,OemToAnsi(STR0001))
					
					if(xFilial("RFO") != cEmpOri)
						cEmpOri := xFilial("RFO")
						
						RFO->(DbSetOrder(1))
						cChave := xFilial("RFO")
						cChave += aLinha[3]							
						cChave += aLinha[2]
						
						lNew := !RFO->(DbSeek(cChave))
						
						RecLock("RFO",lNew)
						RFO->RFO_FILIAL := xFilial("RFO")
						RFO->RFO_CODIGO := aLinha[2]
						RFO->RFO_TPVALE := aLinha[3]
						RFO->RFO_DESCR  := aLinha[4]
						RFO->RFO_VALOR  := Val(aLinha[6])
						RFO->RFO_PERC   := Val(aLinha[7])
						RFO->(MsUnlock())
					EndIf
					
					SM0->(dbSkip())
				EndDo	
				cEmpOri := Nil
			Case (cTipo == "2")/*SR0*/
				cEmpresa 	:= aLinha[2]
				cFil		:= aLinha[3]
				
				If !Empty(aRelac) .and. u_RhImpFil()
					cEmpresa := u_GetCodDP(aRelac,"FILIAL",aLinha[3],"FILIAL",aLinha[2],.T.,.T.) //Busca a Empresa no DE-PARA
					cFil	 := u_GetCodDP(aRelac,"FILIAL",aLinha[3],"FILIAL",aLinha[2],.T.,.F.) //Busca a Filial no DE-PARA
				EndIf				
				
				U_RHPREARE(cEmpresa,cFil,'','',.F.,@lProcede,"RHIMP26",{'SRA','SRQ'},"GPE",@aErros,OemToAnsi(STR0001))
				
				If(lProcede)
					
					//BUSCA DE-PARA dos códigos
					If !Empty(aRelac)
						aLinha[4] := u_GetCodDP(aRelac,"R0_MAT",aLinha[4],"RA_MAT") //Busca DE-PARA
					EndIf				
					
					If(Empty(aLinha[4]) .Or. (!SRA->(DbSeek(xFilial('SRA')+aLinha[4]))))
						If(Empty(aLinha[4]))
							aAdd(aErros,"[Linha "+cNumLinha+"]:"+'Campo [Matrícula] é obrigatório.')
						else
							aAdd(aErros,"[Linha "+cNumLinha+"]:"+'Campo [Matrícula] inválido.')
						endIf
						lInvalido := .T.
					endIf
					
					if(!lInvalido)					
						IF !lNovoCalc
                        	cChave := xFilial("SR0")	
                    	Else
                     		cChave := xFilial("SM7")
                    	EndIf
						cChave += SRA->RA_MAT
						cChave += aLinha[6] //_TPVALE
						cChave += aLinha[5] //_CODIGO

                        IF !lNovoCalc
						    lNew := !SR0->(DbSeek(cChave))			
						
						    RecLock("SR0",lNew)
    						SR0->R0_FILIAL 	:= xFilial("SR0")
    						SR0->R0_MAT	 	:= SRA->RA_MAT
    						SR0->R0_CODIGO 	:= aLinha[5]
    						SR0->R0_TPVALE 	:= aLinha[6]
    						SR0->R0_DIASPRO	:= Val(aLinha[7])
    						SR0->(MsUnlock())
                        Else
							lNew := !SM7->(DbSeek(cChave))			
							
							RecLock("SM7",lNew)
							SM7->M7_FILIAL	:= xFilial("SM7")
							SM7->M7_MAT	 	:= SRA->RA_MAT
							SM7->M7_CODIGO 	:= aLinha[5]
							SM7->M7_TPVALE 	:= aLinha[6]
							SM7->M7_QDIAINF	:= 1
							SM7->M7_DPROPIN	:= Val(aLinha[7])		
							SM7->M7_TPCALC 	:= "1"		
							SM7->(MsUnlock())                           
                        EndIf
					endIf				
					
				endIf
		EndCase
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErros)		
		FT_FSKIP()
	EndDo
	FT_FUSE()/*Libera o Arquivo.*/
	
	U_RIM01ERR(aErros)	
Return
