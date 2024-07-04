#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP22.CH"

/********************************************************************************##
***********************************************************************************
***********************************************************************************
***Funcão.....:RHIMP22.prw Autor: Sidney de Oliveira Data: 17/10/2013       	   ***
***********************************************************************************
***Descrição..:Importação de Item Contábil										   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:		cFileName, caractere, Nome do Arquivo                 	   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***********************************************************************************
***Chamado....:                                                                 ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP22
	Responsável por Processar a importação de Item Contábil
@author Sidney de Oliveira
@since 17/10/2013
@version P11
@param cFileName, caractere, Nome do Arquivo
@return ${return}, ${return_description}
/*/
User Function RHIMP22(cFileName,aRelac,oSelf)
	Local aAreaCTD		:= CTD->(GetArea())
	Local aLinha		:= {}
	Local aIndAux		:= {}
	Local cBuffer       := ""
	Local cEmpresaArq   := ""
	Local cFilialArq    := ""
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local lExiste       := .F.
	Local aCampos       := {}
	Local aErro       	:= {}
	Local aLog 			:= {}
	Local lItemClVl 	:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"	
	
	FT_FUSE(cFileName)	
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	aAdd(aCampos,{'CTD_FILIAL'	,''})
	aAdd(aCampos,{'CTD_ITEM'		,''})
	aAdd(aCampos,{'CTD_DESC01'	,''})
	aAdd(aCampos,{'CTD_CLASSE'	,"2"})
	aAdd(aCampos,{'CTD_NORMAL'	,"2"})
	
	aEval(aCampos,{|x|aAdd(x,Nil)})
	
	CTD->(DBSetOrder(1))		
		
	WHILE !FT_FEOF().And. !lStopOnErr
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErro)
		
		cBuffer := FT_FREADLN()
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cEmpresaArq		:= aLinha[1]
		cFilialArq		:= aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',.F.,@lExiste,"CTBA040",{"CTD"},"ADM",@aErro,OemToAnsi(STR0001))
		
		IF lExiste
			U_IncRuler(OemToAnsi(STR0001),aLinha[3],cStart,.F.,,oSelf)
			aCampos[1,2] := xFilial('CTD')
			aCampos[2,2] := aLinha[3]
			aCampos[3,2] := aLinha[4]
			
			//Verifica existencia de DE-PARA
			If !Empty(aRelac)
				If Empty(aIndSRA) //Grava a posicao dos campos que possuem DE-PARA
					For nX := 1 to Len(aCampos)
						For nJ := 1 to Len(aRelac)
							If (nPos := (aScan(aRelac[nJ],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
								aAdd(aIndSRA,{nX,aRelac[nJ,1]})
							EndIf 
						Next nJ
					Next nX
				EndIf
				For nX := 1 to Len(aIndSRA)
					aCampos[aIndSRA[nX,1],2] := u_GetCodDP(aRelac,aCampos[aIndSRA[nX,1],1],aCampos[aIndSRA[nX,1],2],aIndSRA[nX,2]) //Busca DE-PARA
				Next nX
			EndIf			
			
			Begin Transaction
				lMsErroAuto := .F.
				
				If CTD->(DbSeek(xFilial('CTD') + aCampos[2,2]))
					MSExecAuto({|x,y| CTBA040(x,y)},aCampos,4)
				Else
					MSExecAuto({|x,y| CTBA040(x,y)},aCampos,3)
				EndIf
				
				If lMsErroAuto
					DisarmTransaction()
					aLog := GetAutoGrLog()
					aEval(aLog, { |x| aAdd(aErro, x)  } )
				EndIf
			End Transaction
			
		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[3],cStart,.T.,,oSelf)
		EndIf
		
		FT_FSKIP()
	EndDo	
	FT_FUSE()	
	
	if(!lItemClVl)		
		aAdd(aErro,STR0002)
	endIf
	
	U_RIM01ERR(aErro)
	aSize(aErro,0)
	aErro := Nil
	
	RestArea(aAreaCTD)
Return(.T.)
