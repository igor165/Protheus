#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP03.CH"

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP03.PRW Autor: Rafael F. B.  Data:27/08/2009 				***
***********************************************************************************
***Descrição..: Responsável pela importação de Centros de Custo				    ***
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
***P. Pompeu...|30/05/16|TVDWXU|Tratamento na função GetTpESoc p/ quando os     ***
***............|........|......|parâmetros foram nulos.                         ***
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP03
Responsavel em Processar a Importacao do Centro de Custos da Tabela CTT.
@author Rafael F. B.
@since 27/08/2009
@version P11
@param cFileName, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP03(cFileName,aRelac,oSelf)
	Local aArea			:= 	CTT->(GetArea())
	Local aIndAux		:= {}
	Local cBuffer		:= ""
	Local cEmpresaArq	:= ""
	Local cFilialArq	:= ""	
	Local lExiste		:= .F.
	Local cITOBRG		:= CriaVar("CTT_ITOBRG")
	Local cCLOBRG		:= CriaVar("CTT_CLOBRG")
	Local cACITEM		:= CriaVar("CTT_ACITEM")
	Local cACCLVL		:= CriaVar("CTT_ACCLVL")
	Local cCLASSE		:= CriaVar("CTT_CLASSE") 
	Local cDescErro		:= ""
	Local aTabelas		:= {"CTT"}
	Local aCampos		:= {}	
	Local nTamDESC01	:= TamSx3('CTT_DESC01')[1]
	Local nTamNOME		:= TamSx3('CTT_NOME')[1]
	Local nTamENDER		:= TamSx3('CTT_ENDER')[1]	
	Local aErro			:= {}
	Local nOperacao		:= 3
	Local aLog 			:= {}
	Local aLinha		:= {}
	Local cTipo2 		:= ""
	Local nX			:= 0
	Local nY			:= 0
	Local nPos			:= 0
	Local nTamLin		:= 0
	
	DEFAULT aRelac 		:= {}
	
	If!(U_CanTrunk({'CTT_DESC01','CTT_NOME','CTT_ENDER'}))
		Return (.T.)
	endIf	
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	DBSelectArea("CTT")
	CTT->(DBSetOrder(1))
	
	aCampos := {}	
	aAdd(aCampos,{'CTT_FILIAL'})			
	aAdd(aCampos,{'CTT_CUSTO'})	
	aAdd(aCampos,{'CTT_DESC01'})
	aAdd(aCampos,{'CTT_BLOQ'})
	aAdd(aCampos,{'CTT_NOME'})	
	aAdd(aCampos,{'CTT_ENDER'})						
	aAdd(aCampos,{'CTT_LOGRDS'})	
	aAdd(aCampos,{'CTT_BAIRRO'})
	aAdd(aCampos,{'CTT_CEP'})
	aAdd(aCampos,{'CTT_MUNIC'})
	aAdd(aCampos,{'CTT_ESTADO'})
	aAdd(aCampos,{'CTT_TIPO'})				
	aAdd(aCampos,{'CTT_CEI'})
	aAdd(aCampos,{'CTT_CEI2'})	
	aAdd(aCampos,{'CTT_LOGRTP'})			
	aAdd(aCampos,{'CTT_TPLOT'})			
	aAdd(aCampos,{'CTT_TPINPR'})			
	aAdd(aCampos,{'CTT_NRINPR'})			
	aAdd(aCampos,{'CTT_CODMUN'})	
	aAdd(aCampos,{'CTT_TIPO2'})			
	aAdd(aCampos,{'CTT_FAP'})				
	aAdd(aCampos,{'CTT_PERRAT'})	
	aAdd(aCampos,{'CTT_LOGRNR'})			
	aAdd(aCampos,{'CTT_FPAS'})			
	aAdd(aCampos,{'CTT_CODTER'})	
	aEval(aCampos,{|x|aAdd(x,''),aAdd(x,Nil)})	
	
	aAdd(aCampos,{'CTT_CLASSE'	,cCLASSE,NIL})			
	aAdd(aCampos,{'CTT_ITOBRG'	,cITOBRG,NIL})			
	aAdd(aCampos,{'CTT_CLOBRG'	,cCLOBRG,NIL})			
	aAdd(aCampos,{'CTT_ACITEM'	,cACITEM,NIL})			
	aAdd(aCampos,{'CTT_ACCLVL'	,cACCLVL,NIL})			
	
	WHILE !(FT_FEOF()) .And. !lStopOnErr
		cBuffer := FT_FREADLN()		
		aLinha := {}
				
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		if(!U_Proceed(24,Len(aLinha)))
			Return (.F.)
		Else
			nTamLin := Len(aLinha)
			aSize(aLinha,24)
			aFill( aLinha, "", nTamLin )
		EndIf	
		
		cEmpresaArq	:= aLinha[1]
		cFilialArq		:= aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf
			
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',.F.,@lExiste,"CTBA030",aTabelas,"CTB",@aErro,OemToAnsi(STR0001))
		
		IF lExiste			
			aCampos[1,2] := FwXFilial('CTT') //CTT_FILIAL
			aCampos[2,2] := aLinha[3] //CTT_CUSTO
			aCampos[3,2] := SubStr(aLinha[4],1,nTamDESC01)//CTT_DESC01
			aCampos[4,2] := aLinha[5] //CTT_BLOQ
			aCampos[5,2] := SubStr(aLinha[6],1,nTamNOME)	//CTT_NOME		
			aCampos[6,2] := SubStr(aLinha[7],1,nTamENDER)	//CTT_ENDER
			aCampos[7,2] := IIF((Len(aLinha[7]) < 1),'',aLinha[7])
			aCampos[8,2] := aLinha[8] 
			aCampos[9,2] := aLinha[9]
			aCampos[10,2]:= aLinha[10] /*CTT_MUNIC*/
			aCampos[11,2]:= aLinha[11]
			aCampos[12,2]:= aLinha[12]		
			
			cCei2   := IIF((Len(aLinha[13]) < 1),'',aLinha[13])			
			aCampos[13,2]:= cCei2
			aCampos[14,2]:= cCei2
			
			aCampos[15,2]:= aLinha[14]
			aCampos[16,2]:= aLinha[15]//CTT_TPLOT
			aCampos[17,2]:= aLinha[16]
			aCampos[18,2]:= aLinha[17]							
			aCampos[19,2]:= SubStr(IIF(Empty(aLinha[18]),"",aLinha[18]),3)/*CTT_CODMUN*/		
			
			cTipo2 := aLinha[19]			
			Do Case
				Case (cTipo2=="T")
					cTipo2 := "3"				
				Case (cTipo2=="O")
					cTipo2 := "4"							
				OtherWise
					cTipo2 := "3"
			EndCase			
			
			aCampos[20,2]:= GetTpESoc(aLinha[15],aLinha[19])		
			
			nValFap := IIF(Empty(aLinha[23]),"0",aLinha[23])			
			nValFap := IIF(lPicFormat, StrTran(nValFap,',','.'), StrTran(nValFap,'.',',')) 
			nValFap := Val(nValFap)			
			aCampos[21,2]:= nValFap			
			
			nValRat := IIF(Empty(aLinha[24]),"0",aLinha[24])
			nValRat := IIF(lPicFormat, StrTran(nValRat,',','.'), StrTran(nValRat,'.',',')) 
			nValRat := Val(nValRat)			
			aCampos[22,2]:= nValRat
			
			aCampos[23,2]:= aLinha[20] 
			aCampos[24,2]:= aLinha[21]
			aCampos[25,2]:= aLinha[22] //CTT_CODTER			

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
			
			lMsErroAuto := .F.			
			
			if(CTT->(DbSeek(xFilial('CTT') + aCampos[2,2])))
				aCampos[26,2] := CTT->CTT_CLASSE	
				nOperacao := 4
			else
				aCampos[26,2] := cCLASSE
				nOperacao := 3				
			endIf				
			
			U_IncRuler(OemToAnsi(STR0001),aCampos[2,2],cStart,(!lExiste),,oSelf)
			
			MSExecAuto({|x,y| CTBA030(x,y)},aCampos,nOperacao)
			
			IF lMsErroAuto
				DisarmTransaction()									
				aLog := GetAutoGrLog()
				aEval(aLog,{|x|aAdd(aErro, x)})
			EndIf

		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[3],cStart,(!lExiste),,oSelf)
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
Return (.T.)

/*/{Protheus.doc} GetTpESoc
	Retorna o Tipo e-Social do C.C
@author philipe.pompeu
@since 03/06/2016
@version P11
@param cTpLot, caractere, (Descrição do parâmetro)
@param cTipo2, caractere, (Descrição do parâmetro)
@return cResult, tipo e-Social
/*/
Static Function GetTpESoc(cTpLot,cTipo2)
	Local cResult := ''
	Default cTpLot := ""
	Default cTipo2 := ""
	
	Do Case
		/*CAMPO NÃO DEVERÁ SER PREENCHIDO SE TIPO DE LOTAÇÃO FOR IGUAL*/
		Case (cTpLot $ "07|10|90")
			cResult := " "
		Case (cTipo2 == "O")
			cResult := "4"
		Case (cTipo2 == "T")
			Do Case
				Case (cTpLot $ "03")
					cResult := "2"
				Case (cTpLot $ "21|23")
					cResult := "3"	
				OtherWise
					cResult := "1"
			EndCase		
		OtherWise
			cResult := " "	
	EndCase
	
Return (cResult)
