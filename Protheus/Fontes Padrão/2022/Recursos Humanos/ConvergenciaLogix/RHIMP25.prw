#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RHIMP25.CH"

/***#******************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP25.PRW  Autor: PHILIPE.POMPEU  Data:20/01/2016 		    ***
***********************************************************************************
***Descrição..:	Importa o arquivo de Beneficiários							    ***
***********************************************************************************
***Uso........:        														    ***
***********************************************************************************
***Parâmetros.:		${param}, ${param_type}, ${param_descr}					    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***					Alterações feitas desde a construção inicial                ***
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/
/*/{Protheus.doc} RHIMP25
	Função responsável pela importação do arquivo de Beneficiários;
@author PHILIPE.POMPEU
@since 20/01/2016
@version P12
@param cArquivo, caractere, arquivo para ser importado(caminho completo, ex: "C:\logix\arquivo.unl")
@return nil, Nulo
/*/
User Function RHIMP25(cArquivo,aRelac,oSelf)
	Local aLinha 	:= {}
	Local aIndAux	:= {}
	Local aErros 	:= {}
	Local aPdAux	:= {}
	Local cPdAux	:= ""
	Local cBuffer 	:= ""
	Local cEmpresa 	:= ""
	Local cFil 		:= ""
	Local cNumLinha := ""
	Local cNext		:= ""
	Local lProcede 	:= .F.
	Local lInvalido	:= .F.
	Local lNew 		:= .T.
	Local nNumLinha := 0
	Local nRecNo 	:= 0
	Local nX		:= 0
	Local nJ		:= 0
	Local nPos		:= 0

	DEFAULT aRelac	:= {}

	FT_FUSE(cArquivo)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()

	SRA->(DbSetOrder(1))
	SRQ->(DbSetOrder(1))

	WHILE !FT_FEOF() .And. !lStopOnErr
		nNumLinha++
		cNumLinha 	:= cValToChar(nNumLinha)
		lInvalido	:= .F.
		cBuffer 	:= FT_FREADLN()
		aLinha 		:= Separa(cBuffer,'|')/*Tamanho 13*/
		cEmpresa 	:= aLinha[1]
		cFil 		:= aLinha[2]

		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpresa := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFil	 := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf

		U_RHPREARE(cEmpresa,cFil,'','',.F.,@lProcede,"RHIMP25",{'SRA','SRQ'},"GPE",@aErros,OemToAnsi(STR0001))

		If(lProcede)

			//Verifica existencia de DE-PARA
			If !Empty(aRelac)
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := U_fGetCpoMod("RHIMP25")
					aSize(aLinha,Len(aCampos))
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

			If(Empty(aLinha[3]) .Or. (!SRA->(DbSeek(xFilial('SRA')+aLinha[3]))))
				If(Empty(aLinha[3]))/*Matricula*/
					aAdd(aErros,"["+ OemToAnsi(STR0002)+" "+cNumLinha+"]:"+ OemToAnsi(STR0003)+' ['+OemToAnsi(STR0005)+'] '+ OemToAnsi(STR0004))
				else
					aAdd(aErros,"["+ OemToAnsi(STR0002)+" "+cNumLinha+"]:"+ OemToAnsi(STR0003)+' ['+OemToAnsi(STR0005)+'] '+ OemToAnsi(STR0008) +'. '+ OemToAnsi(STR0009)+"->"+aLinha[3])
				endIf
				lInvalido := .T.
			endIf

			if(Empty(aLinha[4]))	//Nome
				aAdd(aErros,"["+ OemToAnsi(STR0002)+" "+cNumLinha+"]:"+ OemToAnsi(STR0003)+' ['+OemToAnsi(STR0006)+'] '+ OemToAnsi(STR0004))
				lInvalido := .T.
			endIf

			if(Empty(aLinha[12]))//Data Inicio
				aAdd(aErros,"["+ OemToAnsi(STR0002)+" "+cNumLinha+"]:"+OemToAnsi(STR0003)+' ['+OemToAnsi(STR0008)+'] '+ OemToAnsi(STR0004))
				lInvalido := .T.
			endIf

			if(lInvalido)
				U_IncRuler(OemToAnsi(STR0001),OemToAnsi(STR0002)+' '+ cNumLinha,cStart,.F.,,oSelf)
			Else
				if(Empty(aLinha[5]))
					lNew := .T.
				else
					nRecNo := GetID(SRA->RA_MAT, aLinha[5])
					lNew 	:= (nRecNo == Nil)

					if(!lNew)
						SRQ->(DbGoTo(nRecNo))
					endIf

				endIf

				RecLock("SRQ",lNew)
				if(lNew)
					SRQ->RQ_FILIAL	:= xFilial("SRQ")
					SRQ->RQ_MAT		:= SRA->RA_MAT
					SRQ->RQ_CIC		:= aLinha[5]

					cNext := GetNextSeq(SRA->RA_MAT)

					SRQ->RQ_ORDEM 	:= cNext
					SRQ->RQ_SEQUENC	:= cNext
				endIf

				SRQ->RQ_NOME	:= aLinha[4]
				SRQ->RQ_NASC	:= CtoD(aLinha[6])
				SRQ->RQ_BCDEPBE	:= aLinha[7] + aLinha[8]
				SRQ->RQ_CTDEPBE	:= aLinha[9]
				SRQ->RQ_PERCENT	:= Val(aLinha[10])
				SRQ->RQ_PERFGTS	:= Val(aLinha[11])
				SRQ->RQ_DTINI	:= CtoD(aLinha[12])

				//Melhorias CMNET
				If Len(aLinha) > 13
					SRQ->RQ_DTFIM := CtoD(aLinha[13])
					SRQ->RQ_VALFIXO := Val(aLinha[14])
					If!Empty(aLinha[15])
						aPdAux := Separa(aLinha[15],',')
						cPdAux := ""
						For nX:= 1 to Len(aPdAux)
							cPdAux += If(Empty(cPdAux),"",",")
							cPdAux += u_GetCodDP(aRelac,"RQ_VERBAS",aPdAux[nX],"RV_COD") //Busca DE-PARA
						Next nX
						SRQ->RQ_VERBAS  := cPdAux
					EndIf

					if!(Empty(aLinha[16]))
						SRQ->RQ_VERBADT := aLinha[16]
					endIf
					if!(Empty(aLinha[17]))
						SRQ->RQ_VERBFOL := aLinha[17]
					endIf
					if!(Empty(aLinha[18]))
						SRQ->RQ_VERBFER := aLinha[18]
					endIf
					if!(Empty(aLinha[19]))
						SRQ->RQ_VERB131 := aLinha[19]
					endIf
					if!(Empty(aLinha[20]))
						SRQ->RQ_VERB132 := aLinha[20]
					endIf
					if!(Empty(aLinha[21]))
						SRQ->RQ_VERBPLR := aLinha[21]
					endIf
					if!(Empty(aLinha[22]))
						SRQ->RQ_VERBRRA := aLinha[22]
					endIf
				EndIf
				SRQ->(MsUnlock())

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

/*/{Protheus.doc} GetNextSeq
 Pega o próximo sequencial
@author philipe.pompeu
@since 20/01/2016
@version P12
@param cMatricula, caractere, matrícula do funcionario
@return cResult, resultado
/*/
Static Function GetNextSeq(cMatricula)
	Local cQuery	:= ''
	Local cResult := "01"

	cQuery := "SELECT COUNT(RQ_ORDEM)+1 AS NEXTID FROM "
	cQuery += RetSqlName( "SRQ" )
	cQuery += " WHERE RQ_FILIAL='"+ xFilial("SRQ")+"' AND RQ_MAT ='"+cMatricula+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"

	cResult := ExecOnAlias(cQuery, {|x|PadL(cValToChar((x)->NEXTID),2,'0')})

	if(cResult == Nil)
		cResult := "01"
	endIf

Return (cResult)


/*/{Protheus.doc} GetID
@author philipe.pompeu
@since 27/01/2016
@version P12
@param cMatricula, character, (Descrição do parâmetro)
@param cCpf, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetID(cMatricula,cCpf)
	Local cQuery	:= ''
	Local nResult := 0
	Local bBlock := {||}

	cQuery := "SELECT R_E_C_N_O_ AS ID FROM "
	cQuery += RetSqlName( "SRQ" )
	cQuery += " WHERE RQ_FILIAL='"+ xFilial("SRQ")+"' AND RQ_MAT ='"+cMatricula+"'"
	cQuery += " AND D_E_L_E_T_ = ' ' AND RQ_CIC='"+ PadR(cCpf,TamSX3("RQ_CIC")[1])+"'"

	bBlock := {|cMyAlias|(cMyAlias)->ID}

	nResult := ExecOnAlias(cQuery,bBlock)
Return (nResult)


/*/{Protheus.doc} ExecOnAlias
@author philipe.pompeu
@since 27/01/2016
@version P12
@param cQuery, character, (Descrição do parâmetro)
@param bBlock, booleano, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function ExecOnAlias(cQuery,bBlock)
	Local aArea	:= GetArea()
	Local cMyAlias := GetNextAlias()
	Local uResult := Nil

	cQuery	:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMyAlias, .F., .T.)

	if((cMyAlias)->(! Eof()))
		uResult := eVal(bBlock,cMyAlias)
	EndIf

	(cMyAlias)->(dbCloseArea())
	RestArea(aArea)
Return (uResult)
