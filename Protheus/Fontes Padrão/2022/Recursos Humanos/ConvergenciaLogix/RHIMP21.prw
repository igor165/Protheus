#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP21.CH"

/********************************************************************************##
***********************************************************************************
***********************************************************************************
***Funcão.....:RHIMP21.prw Autor: Edna Dalfovo Data: 08/02/2013	       	   ***
***********************************************************************************
***Descrição..:Importação de Eventos												   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:		cFileName, caractere, Nome do Arquivo                 	   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP20
	Importação de Eventos
@author Edna Dalfovo
@since 08/02/2013
@version P11
@param cFileName, caractere, Nome do Arquivo
@return ${return}, ${return_description}
/*/
User Function RHIMP21(cFileName,aRelac,oSelf)
	Local aAreaSRV		:= SRV->(GetArea())
	Local aAreaSP9		:= SP9->(GetArea())
	Local aIndAux		:= {}
	Local cBuffer       := ""
	Local lChangeEnv 	:= .F.	
	Local cEmpresaArq   := ""
	Local cFilialArq    := ""
	Local cEmpOrigem    := ""	
	Local cP9_Ocorren	:= ""
	Local cP9_Codfol    := ""
	Local aTabelas 	 	:= {"SRV","SP9"}
	Local lExiste		:= .T.
	Local aErro       	:= {}
	Local nTamDesc 		:= TAMSX3("P9_DESC")[1]
	Local nTamRvCod		:= TamSX3("RV_COD")[1]
	Local nTamP9Cod		:= TamSX3("P9_CODIGO")[1]
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local aIniPad		:= {}
	Local aPDImp 		:= {}
	DEFAULT aRelac		:= {}	

	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	SP9->(DbSetOrder(1))
	SRV->(DbSetOrder(1))
	
	While !FT_FEOF().And. !lStopOnErr
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErro)
		U_StopProc(aPDImp)
				
		cBuffer := FT_FREADLN()
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cEmpresaArq  := aLinha[1]
		cFilialArq   := aLinha[2]		
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',@lChangeEnv,@lExiste,"PONA100",aTabelas,"PON",@aErro,"Ocorrência cujo código da empresa igual a " + AllTrim(cEmpresaArq)+'/'+ AllTrim(cFilialArq)+" não foram importados.")
		
		
		if(lChangeEnv)
			if(cEmpOrigem != cEmpresaArq)
				cEmpOrigem := cEmpresaArq
				/* Quando muda a empresa pode ser que a estrutura da tabela mude */
				aIniPad := InitValues()
			EndIf
		EndIf

		//Verifica existencia de DE-PARA
		If !Empty(aRelac)
			If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
				aCampos := U_fGetCpoMod("RHIMP21")
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
		
		cP9_Ocorren:= PadR(aLinha[3],nTamP9Cod)
		
		IF lExiste			
			
			if(Empty(aLinha[5]))
				cP9_Codfol := Space(nTamRvCod)
			Else
			 	cP9_Codfol := PadR(aLinha[5],nTamRvCod)
			 	IF 	!(SRV->(DbSeek(FwXFilial('SRV') + cP9_Codfol)))								
					If !Empty(aPDImp)
						If aScan(aPDImp,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + cFilialArq + cP9_Codfol }) == 0
							aAdd(aPDImp, {cEmpresaArq,cFilialArq,cP9_Codfol})
						EndIf
					Else
						aAdd(aPDImp,{cEmpresaArq,cFilialArq,cP9_Codfol})
					EndIf
					FT_FSKIP()
					U_IncRuler(OemToAnsi(STR0001),cP9_Ocorren + '/' + aLinha[5],cStart,.T.,,oSelf)
					Loop				
				Else
					cP9_Codfol := SRV->RV_COD
				EndIf				
			EndIf
			
			U_IncRuler(OemToAnsi(STR0001),cP9_Ocorren + '/' + cP9_Codfol ,cStart,.F.,,oSelf)
			
			If 	!(SP9->(DbSeek(FwXFilial('SP9') + cP9_Ocorren)))
				RecLock("SP9", .T.)
				SP9->P9_FILIAL := FwxFilial('SP9')					
				SP9->P9_CODIGO := cP9_Ocorren
			Else
				RecLock("SP9", .F.)
			EndIf
			
			SP9->P9_DESC   := SubStr(PadR(aLinha[4],nTamDesc),1,nTamDesc)
			SP9->P9_CODFOL := cP9_Codfol
			SP9->P9_TIPOCOD:= IIF(Empty(aLinha[6]),'',aLinha[6])
			SP9->P9_DESCDSR:= IIF(Empty(aLinha[7]),'',aLinha[7])
			SP9->P9_CLASEV := IIF(Empty(aLinha[8]),'',aLinha[8])
			SP9->P9_BHORAS := IIF(Empty(aLinha[9]),'',aLinha[9])
			
			aEval(aIniPad,{|x|SP9->&(x[1]) := InitPad(x[2])})
			
			SP9->(MSUnLock())	
			
								
		Else
			U_IncRuler(OemToAnsi(STR0001),cP9_Ocorren + '/' + aLinha[5],cStart,.T.,,oSelf)
		EndIf
		
		FT_FSKIP()
	EndDo
	
	FT_FUSE()
	
	If !Empty(aPDImp)
		aSort( aPDImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )
		aEval(aPDImp,{|x|aAdd(aErro,'['+ x[1] + '/' + x[2] + '/' + x[3] + ']' + OemToAnsi(STR0002))})
	EndIf
	
	U_RIM01ERR(aErro)
	
	RestArea(aAreaSP9)
	RestArea(aAreaSRV)	
Return(.T.)

/*/{Protheus.doc} InitValues
@author philipe.pompeu
@since 29/07/2015
@version P12
@return ${return}, ${return_description}
/*/
Static Function InitValues()
	Local aArea	:= SX3->(GetArea())
	Local cCpoAtu	:= ''
	Local aIniPad	:= {}
	
	/*Campos que devem utilizar inicializador padrao*/
	cCpoAtu := 'P9_IDPON|P9_BHNDE|P9_BHNATE|P9_BHPERC|P9_BHAGRU|P9_BHAVAL|P9_PBH|P9_PFOL|P9_DIVERGE|P9_EVECONT'
		
	SX3->(DbSetOrder(1))
	SX3->(dbSeek('SP9'))
	
	While !SX3->(EOF()) .And. (SX3->X3_ARQUIVO == 'SP9')
		If (SX3->X3_CAMPO $ cCpoAtu) .and. !Empty(SX3->X3_RELACAO)
			aAdd(aIniPad,{AllTrim(SX3->X3_CAMPO),SX3->X3_RELACAO})
		EndIf
		SX3->(DbSkip())
	EndDo
	
	RestArea(aArea)
Return (aIniPad)
