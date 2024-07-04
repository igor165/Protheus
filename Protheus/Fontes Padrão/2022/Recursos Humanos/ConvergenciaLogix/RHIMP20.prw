#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP20.CH"

/********************************************************************************##
***********************************************************************************
***********************************************************************************
***Funcão.....:RHIMP20.prw Autor: Edna Dalfovo Data: 01/03/2013	       	   ***
***********************************************************************************
***Descrição..:Importação do Banco de Horas										   ***
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
***Esther V.   |09/02/17|      | Ajuste na carga do campo PI_PD dependendo da   ***
***............|........|......|rotina de importacao - RHIMP01/RHIMPGEN. No     ***
***............|........|......|Logix, é primeiro lido o código da verba        ***
***............|........|......|(P9_CODFOL) e então encontra-se o código do     ***
***............|........|......|evento (P9_CODIGO/PI_PD). Já na importação      ***
***............|........|......|genérica é carregado o diretamente o código     ***
***............|........|......|do evento (PI_PD).                              ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP20
	Importação de Banco de Horas
@author Edna Dalfovo
@since 01/03/2013
@version P11
@param cFileName, caractere, Nome do Arquivo
@return ${return}, ${return_description}
/*/
User Function RHIMP20(cFileName,aRelac,oSelf)
	Local aAreas		:= {SRA->(GetArea()),SRV->(GetArea()),SPI->(GetArea())}
	Local aLinha		:= {}
	Local aIndAux		:= {}
	Local cBuffer       := ""
	Local lEnvChange	:= .F.
	Local cEmpresaArq   := ""
	Local cFilialArq    := ""
	Local cEmpOrigem    := ""
	Local cPI_Mat       := ""
	Local dPI_DataOco   := CtoD("//")
	Local cCodEveAux    := ""
	Local nPI_QtHoras   := 0
	Local cPI_CodOco    := ""
	Local cPI_CodEve    := ""
	Local nInd          := 0
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local aTabelas 	 	:= {'SRA','SRV','SPI'}
	Local nTamMat		:= GetSx3Cache( "RA_MAT", "X3_TAMANHO" )
	Local nTamRvCod		:= GetSx3Cache( "RV_COD", "X3_TAMANHO" )
	Local lApaga		:= .F.
	Local lApagMov		:= .F.
	Local lPergApag		:= .T.
	Local aErro       	:= {}
	Local aFuncImp 		:= {}
	Local aPDImp 		:= {}
	Local lLogix		:= Empty(oSelf)
	
	DEFAULT aRelac		:= {}
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	SRA->(DbSetOrder(1))
	SRV->(DbSetOrder(1))
	SPI->(dbSetOrder(1))
	
	lExiste:= .T.
	While !FT_FEOF().And. !lStopOnErr		
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErro)
		U_StopProc(aFuncImp)
		U_StopProc(aPDImp)
		
		cBuffer := FT_FREADLN()
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cEmpresaArq	:=aLinha[1]
		cFilialArq	:=aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpresaArq,cFilialArq,'','',@lEnvChange,@lExiste,"PONA200",aTabelas,"PON",@aErro,OemToAnsi(STR0001))
		
		if(lEnvChange)
			IF cEmpresaArq <> cEmpOrigem
				lApaga := .T.
				cEmpOrigem := cEmpresaArq
			EndIf
		EndIf
		
		If(lApaga) .and. ExistReg()
			If lApagMov .or. ( lPergApag .and. MsgYesNo(OemToAnsi(STR0002)))
				fDelMov()
				lApagMov := .T.
			Else
				lPergApag := .F.
			EndIf
		EndIf
		
		lApaga := .F.
		
		//Verifica existencia de DE-PARA
		If !Empty(aRelac)
			If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
				aCampos := U_fGetCpoMod("RHIMP20")
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
		
		cPI_Mat		:= PadR(aLinha[3],nTamMat)
		If lLogix //se vier do RHIMP01
			cPI_CodEve 	:= PadR(aLinha[6],nTamRvCod)
			cPI_CodOco 	:= aLinha[5]
		Else //se vier do RHIMPGEN
			cPI_CodEve 	:= PadR(aLinha[5],nTamRvCod)
		EndIf
		IF lExiste
			U_IncRuler(OemToAnsi(STR0001),cPI_Mat + '/' +  cPI_CodEve + '-' + aLinha[4],cStart,.F.,,oSelf)
			
			IF !(SRA->(DbSeek(xFilial('SRA') + cPI_MAT)))
				
				If !Empty(aFuncImp)
					If aScan(aFuncImp,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + cFilialArq + cPI_MAT }) == 0
						aAdd(aFuncImp, {cEmpresaArq,cFilialArq,cPI_MAT})
					EndIf
				Else
					aAdd(aFuncImp,{cEmpresaArq,cFilialArq,cPI_MAT})
				EndIf
				
				FT_FSKIP()
				Loop
			EndIf
			If lLogix //se vier do RHIMP01		
				IF !(SRV->(DbSeek(xFilial('SRV') + cPI_CodEve)))
					
					If !Empty(aPDImp)
						If aScan(aPDImp,  { |x|  X[1]+X[2]+X[3] == cEmpresaArq + cFilialArq + cPI_CodEve }) == 0
							aAdd(aPDImp, {cEmpresaArq,cFilialArq,cPI_CodEve})
						EndIf
					Else
						aAdd(aPDImp,{cEmpresaArq,cFilialArq,cPI_CodEve})
					EndIf
									
					FT_FSKIP()
					Loop
				EndIf
			EndIf
			nInd := GetInciden(cPI_CodEve,@cCodEveAux,lLogix)
			
			If 	nInd <> 0
				If nInd > 1
					aAdd(aErro,'['+ cEmpresaArq + '/' + cFilialArq + '/' + cPI_CodEve + ']'+ OemToAnsi(STR0006))
				Else
					RecLock("SPI", .T.)
					
					SPI->PI_FILIAL  	:= xFilial('SPI')
					SPI->PI_MAT	  		:= SRA->RA_MAT
					SPI->PI_DATA		:= CtoD(aLinha[4])
					SPI->PI_PD			:= cCodEveAux
					SPI->PI_CC	  		:= aLinha[7]
					SPI->PI_QUANTV  	:= Val(STRTRAN(aLinha[8],',','.'))
					SPI->PI_QUANT   	:= Val(STRTRAN(aLinha[8],',','.'))
					SPI->PI_DEPTO   	:= aLinha[9]
					SPI->PI_CODFUNC 	:= aLinha[10]
					SPI->PI_FLAG    	:= "I"
					SPI->PI_STATUS  	:= ""
					SPI->PI_DTBAIX  	:= CtoD("")
					SPI->PI_PERIODO  	:= SubStr(DtoS(SPI->PI_DATA),1,6)
					SPI->PI_NUMPAG  	:= '01'
					SPI->PI_PROCES  	:= SRA->RA_PROCES
					
					SPI->(MSUnLock())
				EndIf
			Else
				aAdd(aErro,'['+ cEmpresaArq + '/' + cFilialArq + '/' + cPI_CodEve + ']'+ OemToAnsi(STR0005))
			EndIf
		Else
			U_IncRuler(OemToAnsi(STR0001),cPI_Mat + '/' +  cPI_CodEve + '-' + aLinha[4],cStart,.T.,,oSelf)
		EndIf
		FT_FSKIP()
	EndDo
	FT_FUSE()
	
	If !(Empty(aFuncImp))
		aSort( aFuncImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )		
		aEval(aFuncImp,{|x|aAdd(aErro,'[' + x[1]+'/'+ x[2] + '/' + x[3] +']' + OemToAnsi(STR0003))})		
	EndIf
	
	If !Empty(aPDImp)
		aSort( aPDImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )
		aEval(aPDImp,{|x|aAdd(aErro,'['+ x[1] + '/' + x[2] + '/' + x[3] + ']' + OemToAnsi(STR0004))})
	EndIf
	
	U_RIM01ERR(aErro)
	aSize(aErro,0)
	aErro := Nil
	aEval(aAreas,{|x|RestArea(x)})
	aSize(aAreas,0)
	aAreas := Nil
Return(.T.)

/*/{Protheus.doc} GetInciden
	Retorna o número de incidências;
	
	Esse trecho de código ficava dentro de RHIMP020, para melhorar a 
	legibilidade transformei em uma função, porém o código foi elaborado
	pelo autor do RHIMP020.
@author PHILIPE.POMPEU
@since 30/07/2015
@version P12
@param cCodigo, character, codigo do evento ou da verba do evento a ser encontrado na tabela SP9
@param cCodEveAux, character, variavel a ser atualizada com o codigo do evento presente na SP9
@param lLogix, logic, indica se a rotina está sendo executada a partir do RHIMP01 (Logix) ou do RHIMPGEN (importação genérica)
@return nInd, numero de registros encontrados na tabela SP9 utilizando o codigo enviado em cCodigo.
/*/
Static Function GetInciden(cCodigo,cCodEveAux,lLogix)
	Local aArea		:= GetArea()
	Local cAliasQry := GetNextAlias()
	Local nInd		:= 0
	LOCAL cQuery    := ""

If lLogix //se vier do RHIMP01
	//no Logix o codigo enviado no arquivo eh referente a verba e nao ao evento, 
	//por isso deve-se fazer o caminho contrario para encontrar o valor do campo P9_CODIGO
	cQuery := " SELECT P9_CODIGO "
	cQuery += " FROM " + RetSqlName("SP9")
	cQuery += " WHERE P9_CODFOL = " +"'"+cCodigo+"'"
	cQuery += " AND D_E_L_E_T_<>'*' AND P9_FILIAL = '"+ xFilial('SP9') +"'"
	cQuery += " ORDER BY  P9_FILIAL,P9_CODIGO"
Else //se vier do RHIMPGEN
	//necessario verificar se o codigo do evento informado existe na tabela de Eventos SP9.
	cQuery := " SELECT P9_CODIGO "
	cQuery += " FROM " + RetSqlName("SP9")
	cQuery += " WHERE P9_CODIGO = " +"'"+cCodigo+"'"
	cQuery += " AND D_E_L_E_T_<>'*' AND P9_FILIAL = '"+ xFilial('SP9') +"'"
	cQuery += " ORDER BY  P9_FILIAL,P9_CODFOL"	
EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .F.)
	dbSelectArea(cAliasQry)
	(cAliasQry)->( DbGoTop() )
	
	While !(cAliasQry)->( Eof() )
		cCodEveAux := (cAliasQry)->P9_CODIGO
		nInd := nInd +1
		(cAliasQry)->( DbSkip() )
	EndDo

	(cAliasQry)->( DbCloseArea() )
	RestArea(aArea)
Return (nInd)

/*/{Protheus.doc} fDelMov
	Apaga os dados da SPI
@author Leandro Drumond
@since 19/09/16
@version P11
/*/
Static Function fDelMov()
	Local cQuery := ''
	
	cQuery := " DELETE FROM " + InitSqlName("SPI") + " "
	cQuery += " WHERE PI_FILIAL = '" + xFilial("SPI") + "' "
	
	TcSqlExec( cQuery )
	
	TcRefresh( InitSqlName(cAlias) )
	
Return NIL

/*/{Protheus.doc} ExistReg
	Função que verifica se existe registros antes de perguntar se deseja limpar a tabela!
@author Leandro Drumond
@since 19/09/2016
@version P12
@return lResult,lógico,verdadeiro se existe registros nas tabelas
/*/
Static Function ExistReg()
	Local aArea	:= GetArea()
	Local cAliasAux := GetNextAlias()
	Local lResult := .F.
	
	BeginSql alias cAliasAux
		SELECT COUNT(*) AS SOMA
		FROM %table:SPI% SPI 
		WHERE
		PI_FILIAL = %xFilial:SPI% AND SPI.%NotDel%
	EndSql
	
	lResult := (cAliasAux)->SOMA > 0
		
	(cAliasAux)->(DbCloseArea())
	
	RestArea(aArea)
	
Return (lResult)
