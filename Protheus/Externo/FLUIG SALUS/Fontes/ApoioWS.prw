#include 'totvs.ch'
#include "topconn.ch"
#DEFINE C1FILIAL 1
#DEFINE C1ITENS 2
#DEFINE C1SOLIC 3
#DEFINE C1DATA 4
#DEFINE C1ZNSCFLU 5
#DEFINE C1ZZOBS  6

/**
*
* @author: Bruno Ricardo de Oliveira
* @since: 17/09/2013 - 11:55:26
* @description: Classe com os métodos de rotinas automáticas. 
*/ 
user function ApoioWS

return 

class ApoioWS
	
	Data aAliasPreserv  as Array
	
	method New() CONSTRUCTOR
	
	
	method getFiliais(cUsuario)
	method getUsuariosProtheus()
	method getSubordinados(cFiltro)
	method putMetas(tipo, ItensMeta)
	method getMetas(cColab,cCoord)
	method getFullMetas(cColab, cCoord, cAno)
	method getPrcEst(cRun, cRevisao, cProduto, cTipo, cEspecie)
	method validaInclusao(cTipo , cAno, cColab, cRevisa)
	method putPreenchimento(tipo, ItensMeta)
	method validaPreenchimento(cTipo , cAno, cColab, cRevisa,cMes)
	method impEstTxt(cTxt, cEmp, cFil, nFluig)
	method getClientes(cCod,cLoja)
	method getProd(cCod)
	method GetCliProd(cCod,cLoja)
	method GetFrete(cCod,cLoja)
endClass

method New() class ApoioWS
	::aAliasPreserv := {}
return

method getClientes(cCod) class ApoioWS
	Local aRet := {}

	if SA1->(dbSeek(xFilial("SA1") + cCod))
		aAdd(aRet,{;
			SA1->A1_COD,;
			SA1->A1_MUN,;
			SA1->A1_NOME,;
			SA1->A1_CGC,;
			SA1->A1_CEP,;
			SA1->A1_MUN,;
		})
	else 
		aRet := {}
	ENDIF

Return aRet

method getProd(cCod) class ApoioWS
	local aRet 		:= {}

	if SB1->(dbSeek(xFilial("SB1") + cCod))
		aAdd(aRet,{;
			SB1->B1_COD,;
			SB1->B1_DESC,;
			SB1->B1_UM,;
			SB1->B1_TIPO,;
			SB1->B1_PRV1,;
		})
	else
		aRet := {}
	ENDIF

Return aRet

method GetCliProd(cCod,cLoja) class ApoioWS
	local _cAlias := getNextAlias()
	local aRet := {}
	Local _cQry := ""

	if SA1->(dbSeek(xFilial("SA1") + cCod))
		_cQry := " select A7_FILIAL " + CRLF
		_cQry += " 	  ,A7_CLIENTE " + CRLF
		_cQry += " 	  ,A7_LOJA " + CRLF
		_cQry += " 	  ,A7_PRODUTO " + CRLF
		_cQry += " 	  ,CASE  " + CRLF
		_cQry += " 			WHEN A7_DTREF12 != ' ' THEN A7_DTREF12  " + CRLF
		_cQry += " 			WHEN A7_DTREF11 != ' ' THEN A7_DTREF11  " + CRLF
		_cQry += " 			WHEN A7_DTREF10 != ' ' THEN A7_DTREF10  " + CRLF
		_cQry += " 			WHEN A7_DTREF09 != ' ' THEN A7_DTREF09  " + CRLF
		_cQry += " 			WHEN A7_DTREF08 != ' ' THEN A7_DTREF08  " + CRLF
		_cQry += " 			WHEN A7_DTREF07 != ' ' THEN A7_DTREF07  " + CRLF
		_cQry += " 			WHEN A7_DTREF06 != ' ' THEN A7_DTREF06  " + CRLF
		_cQry += " 			WHEN A7_DTREF05 != ' ' THEN A7_DTREF05  " + CRLF
		_cQry += " 			WHEN A7_DTREF04 != ' ' THEN A7_DTREF04  " + CRLF
		_cQry += " 			WHEN A7_DTREF03 != ' ' THEN A7_DTREF03  " + CRLF
		_cQry += " 			WHEN A7_DTREF02 != ' ' THEN A7_DTREF02  " + CRLF
		_cQry += " 			WHEN A7_DTREF01 != ' ' THEN A7_DTREF01  " + CRLF
		_cQry += " 		End 'DATA_' " + CRLF
		_cQry += " 		,CASE  " + CRLF
		_cQry += " 			WHEN A7_PRECO12 != ' ' THEN A7_PRECO12  " + CRLF
		_cQry += " 			WHEN A7_PRECO11 != ' ' THEN A7_PRECO11  " + CRLF
		_cQry += " 			WHEN A7_PRECO10 != ' ' THEN A7_PRECO10  " + CRLF
		_cQry += " 			WHEN A7_PRECO09 != ' ' THEN A7_PRECO09  " + CRLF
		_cQry += " 			WHEN A7_PRECO08 != ' ' THEN A7_PRECO08  " + CRLF
		_cQry += " 			WHEN A7_PRECO07 != ' ' THEN A7_PRECO07  " + CRLF
		_cQry += " 			WHEN A7_PRECO06 != ' ' THEN A7_PRECO06  " + CRLF
		_cQry += " 			WHEN A7_PRECO05 != ' ' THEN A7_PRECO05  " + CRLF
		_cQry += " 			WHEN A7_PRECO04 != ' ' THEN A7_PRECO04  " + CRLF
		_cQry += " 			WHEN A7_PRECO03 != ' ' THEN A7_PRECO03  " + CRLF
		_cQry += " 			WHEN A7_PRECO02 != ' ' THEN A7_PRECO02  " + CRLF
		_cQry += " 			WHEN A7_PRECO01 != ' ' THEN A7_PRECO01  " + CRLF
		_cQry += " 		End 'Preco' " + CRLF
		_cQry += " FROM "+RetSqlName("SA7")+" " + CRLF
		_cQry += " WHERE  A7_FILIAL = '"+xFilial("SA7")+"' " + CRLF
		_cQry += "    AND A7_CLIENTE = '"+cCod+"' " + CRLF
		_cQry += "    AND A7_LOJA = '"+cLoja+"' " + CRLF
		_cQry += "    AND D_E_L_E_T_ = '' " + CRLF

		dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

		while !(_cAlias)->(EOF())
			aAdd(aRet,{;
				(_cAlias)->A7_FILIAL,;
				(_cAlias)->A7_CLIENTE,;
				(_cAlias)->A7_LOJA,;
				(_cAlias)->DATA_,;
				(_cAlias)->Preco,;
			})
		enddo
		(_cAlias)->(DbCLoseArea()) 
	endif 

Return aRet

method getPrcEst(cRun, cRevisao, cProduto, cTipo, cEspecie) class ApoioWS
	local aRet := {}
	local cQuery := ""
	local cAlias := getNextAlias()
	local nPreco := 0
	local nBase  := 0
	local nTotal := 0
	local nFinal := 0

	if SB1->(dbSeek(xFilial("SB1") + cProduto))
		nBase := SB1->B1_QB
		cQuery += "WITH ESTRUTURA( CODIGO, COD_PAI, COD_COMP, QTD, PERDA, DT_INI, DT_FIM, NIVEL ) AS                              " +CRLF
		cQuery += "(                                                                                                              " +CRLF
		cQuery += "      SELECT G1_COD PAI, G1_COD, G1_COMP, G1_QUANT, G1_PERDA, G1_INI, G1_FIM, 1 AS NIVEL                       " +CRLF
		cQuery += "        FROM SG1010 SG1 (NOLOCK)                                                                               " +CRLF
		cQuery += "     WHERE SG1.D_E_L_E_T_ = ''                                                                                 " +CRLF
		cQuery += "       AND G1_FILIAL      = '"+xFilial("SG1")+"'                                                                               " +CRLF
		cQuery += "                                                                                                               " +CRLF
		cQuery += "     UNION ALL                                                                                                 " +CRLF
		cQuery += "                                                                                                               " +CRLF
		cQuery += "      SELECT CODIGO, G1_COD, G1_COMP, QTD * G1_QUANT, G1_PERDA, G1_INI, G1_FIM, NIVEL + 1                      " +CRLF
		cQuery += "        FROM SG1010 SG1 (NOLOCK)                                                                               " +CRLF
		cQuery += "     INNER JOIN ESTRUTURA EST                                                                                  " +CRLF
		cQuery += "        ON G1_COD = COD_COMP                                                                                   " +CRLF
		cQuery += "     WHERE SG1.D_E_L_E_T_ = ''                                                                                 " +CRLF
		cQuery += "       AND SG1.G1_FILIAL = '"+xFilial("SG1")+"'                                                                                " +CRLF
		cQuery += "                                                                                                               " +CRLF
		cQuery += ")                                                                                                              " +CRLF
		cQuery += "SELECT CODIGO , SB1_A.B1_DESC AS DESCRI, SB1_A.B1_TIPO AS TIPO , SB1_A.B1_GRUPO AS GRUPO,                      " +CRLF
		cQuery += "       COD_PAI , SB1_B.B1_DESC AS DESC_PAI , SB1_B.B1_TIPO AS TIPO_PAI , SB1_B.B1_GRUPO AS GRUPO_PAI,          " +CRLF
		cQuery += "       COD_COMP, SB1_C.B1_DESC AS DESC_COMP, SB1_C.B1_TIPO AS TIPO_COMP, SB1_C.B1_GRUPO AS GRUPO_COMP,         " +CRLF
		cQuery += "       QTD     , PERDA, SB1_C.B1_UM AS UM_COMP, DT_INI, DT_FIM, NIVEL                                          " +CRLF
		cQuery += "FROM ESTRUTURA                                                                                                 " +CRLF
		cQuery += "INNER JOIN SB1010 SB1_A (NOLOCK)                                                                               " +CRLF
		cQuery += "    ON SB1_A.D_E_L_E_T_ = ''                                                                                   " +CRLF
		cQuery += "   AND SB1_A.B1_FILIAL = '"+xFilial("SB1")+"'                                                                                  " +CRLF
		cQuery += "   AND SB1_A.B1_COD     = CODIGO                                                                               " +CRLF
		cQuery += "INNER JOIN SB1010 SB1_B (NOLOCK)                                                                               " +CRLF
		cQuery += "    ON SB1_B.D_E_L_E_T_ = ''                                                                                   " +CRLF
		cQuery += "   AND SB1_B.B1_FILIAL = '"+xFilial("SB1")+"'                                                                                  " +CRLF
		cQuery += "   AND SB1_B.B1_COD     = COD_PAI                                                                              " +CRLF
		cQuery += "INNER JOIN SB1010 SB1_C (NOLOCK)                                                                               " +CRLF
		cQuery += "    ON SB1_C.D_E_L_E_T_ = ''                                                                                   " +CRLF
		cQuery += "   AND SB1_C.B1_FILIAL = '"+xFilial("SB1")+"'                                                                                 " +CRLF
		cQuery += "   AND SB1_C.B1_COD     = COD_COMP                                                                             " +CRLF
		cQuery += "WHERE ESTRUTURA.CODIGO = '"+cProduto+"'                                                                           " +CRLF
	
		
		conout(cQuery)
		TCQUERY cQuery NEW ALIAS &(cAlias)
	
		if !(cAlias)->(eof())
			while !(cAlias)->(eof())
				if cTipo == "1"
					if (cAlias)->TIPO_COMP != "PA" .AND. (cAlias)->TIPO_COMP !=	"MO"
						nPreco := getPreco(cRun, cRevisao, (cAlias)->COD_COMP, cEspecie)
						nFinal := round(((cAlias)->QTD * nPreco) / nBase,2)
						aadd(aRet,{;
							(cAlias)->QTD,;	
							nPreco,;	
							(cAlias)->COD_COMP,;
							(cAlias)->DESC_COMP,;
							(cAlias)->COD_PAI,;
							(cAlias)->DESC_PAI,;
							(cAlias)->NIVEL,;	
							(cAlias)->UM_COMP,;		
							(cAlias)->TIPO_COMP,;	
							nFinal,;
							nBase;
						})
					endif
				else
					if (cAlias)->TIPO_COMP != "PA" .AND. (cAlias)->TIPO_COMP !=	"MO"
						nPreco := getPreco(cRun, cRevisao, (cAlias)->COD_COMP, cEspecie)
						nTotal += round((nPreco * (cAlias)->QTD) / nBase,2)
						if len(aRet) == 0
							aadd(aRet,{;
								1,;	
								0,;	
								(cAlias)->COD_PAI,;
								(cAlias)->DESC_PAI,;
								(cAlias)->COD_PAI,;
								(cAlias)->DESC_PAI,;
								(cAlias)->NIVEL,;	
								(cAlias)->UM_COMP,;		
								(cAlias)->TIPO_COMP,;	
								0,;
								nBase;
							})
						endif
					endif
				endif
				(cAlias)->(dbSkip())
			enddo
			if cTipo == "2"
				aRet[1][2] :=  nTotal //PRECO
				aRet[1][10]:=  nTotal //PRECO
			endif
			if len(aRet) > 0
				ASORT(aRet,,,{ |Z,W| Z[10] < W[10] })
			endif
			(cAlias)->(dbCloseArea())
		endif
	endif
return aRet

method impEstTxt(cTxt, cEmp, cFil, nFluig) class ApoioWS
	local cMsg := "OK"
	local cNomeArq := cValToChar(nFluig) + "-" + dtos(dDatabase) + STRTRAN( SUBSTR( TIME(), 1, 5),":","") + ".txt"
	local cDir := "\estrutura_txt\"
  	local cFile := cDir + cNomeArq
  	local nHandle := FCREATE(cFile)
  	private cFileFluig := cFile
  	private cResposta := ""
    if nHandle = -1
        conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
        cMsg := "NOK - Erro ao criar arquivo'
    else
    	FWrite(nHandle, cTxt )
        FClose(nHandle)
        cMsg := u_SLIMPSG1()
    endif
    if valtype(cResposta) != 'U'
    	cMsg := cResposta
    endif
return cMsg

method getFullMetas(cColab,cCoord, ano) class ApoioWS
	local aRet := {}
	local cQuery := ""
	local cAlias := getNextAlias()
	
	cQuery += "SELECT ZZ2_META, " +CRLF
	cQuery += "ZZ2_DTINIC, " +CRLF
	cQuery += " ZZ2_DTFIM, " +CRLF
	cQuery += " ZZ2_ANOREF, " +CRLF
	cQuery += " ZZ2_DESC, " +CRLF
	cQuery += " ZZ2_PESO, " +CRLF
	cQuery += " ZZ2_VALOR, " +CRLF
	cQuery += " ZZ2_METODO, " +CRLF
	cQuery += " ZZ2_TIPO, " +CRLF
	cQuery += " ZZ2_MESREF, " +CRLF
	cQuery += " ZZ2_MESREF, " +CRLF
	cQuery += " ZZ2_PERCQT, " +CRLF
	cQuery += " ZZ2_PERCQL, " +CRLF
	cQuery += " ZZ2_REVISA " +CRLF
	cQuery += "	FROM " + retSqlTab("ZZ2")   + CRLF
	cQuery += "	WHERE ZZ2_ATIVA = '1' "  + CRLF
	cQuery += "	AND ZZ2_COLAB = '"+cColab+"' "  + CRLF
	cQuery += "	AND ZZ2_ANOREF = '"+ano+"' "  + CRLF
	
	conout(cQuery)
	TCQUERY cQuery NEW ALIAS &(cAlias)

	if !(cAlias)->(eof())
		while !(cAlias)->(eof())
			aadd(aRet,{;
				(cAlias)->ZZ2_META,; 
				dtoc(stod((cAlias)->ZZ2_DTINIC)),; 
				dtoc(stod((cAlias)->ZZ2_DTFIM)),;
				(cAlias)->ZZ2_ANOREF,;
				(cAlias)->ZZ2_DESC,;
				(cAlias)->ZZ2_PESO,;
				(cAlias)->ZZ2_VALOR,;
				(cAlias)->ZZ2_METODO,;
				(cAlias)->ZZ2_TIPO,;
				(cAlias)->ZZ2_REVISA,;
				(cAlias)->ZZ2_MESREF,;
				(cAlias)->ZZ2_PERCQT,;
				(cAlias)->ZZ2_PERCQL;
			})
			
			(cAlias)->(dbSkip())
		enddo
		(cAlias)->(dbCloseArea())
	endif
return aRet

method getMetas(cColab,cCoord) class ApoioWS
	local aRet := {}
	local cQuery := ""
	local cAlias := getNextAlias()
	
	cQuery += "SELECT DISTINCT ZZ2_ANOREF,ZZ2_COLAB " +CRLF
	cQuery += "	FROM " + retSqlTab("ZZ2")   + CRLF
	cQuery += "	WHERE ZZ2_ATIVA = '1'AND ZZ2_COLAB = '"+cColab+"' "  + CRLF
	
	conout(cQuery)
	TCQUERY cQuery NEW ALIAS &(cAlias)

	if !(cAlias)->(eof())
		while !(cAlias)->(eof())
			aadd(aRet,{(cAlias)->ZZ2_ANOREF, (cAlias)->ZZ2_COLAB})
			(cAlias)->(dbSkip())
		enddo
		(cAlias)->(dbCloseArea())
	endif
return aRet

method putMetas(tipo, ItensMeta) Class ApoioWS
	local i := 0
	local lLimpa := .t.
	local revisa := ""
	local cMensagem := "Não foi possivel gerar as metas no protheus"
	if tipo == "Nova"
		begin sequence
			dbSelectARea("ZZ2")
			for i := 1 to len(ItensMeta:LISTA)
				reclock("ZZ2",.T.)
					ZZ2->ZZ2_FILIAL := xFilial("ZZ2")
					ZZ2->ZZ2_STATUS := "1"
					ZZ2->ZZ2_MESREF := "00"
					ZZ2->ZZ2_MESENV := "00"
					ZZ2->ZZ2_NFLUIG := ItensMeta:LISTA[i]:solicitacao
					ZZ2->ZZ2_DTINIC := CTOD(ItensMeta:LISTA[i]:dtInicio)
					ZZ2->ZZ2_DTFIM  := CTOD(ItensMeta:LISTA[i]:dtFim)
					ZZ2->ZZ2_ANOREF := ItensMeta:LISTA[i]:ano
					ZZ2->ZZ2_COLAB  := ItensMeta:LISTA[i]:colaborador
					ZZ2->ZZ2_USRFG  := ItensMeta:LISTA[i]:userFluig
					ZZ2->ZZ2_GESTOR := ItensMeta:LISTA[i]:gestor
					//ZZ2->ZZ2_GSTFG  := ItensMeta:LISTA[i]:solicitacao
					ZZ2->ZZ2_META   := ItensMeta:LISTA[i]:meta
					ZZ2->ZZ2_DESC   := ItensMeta:LISTA[i]:descricao
					ZZ2->ZZ2_PESO   := ItensMeta:LISTA[i]:peso
					ZZ2->ZZ2_VALOR  := ItensMeta:LISTA[i]:valor
					ZZ2->ZZ2_METODO := ItensMeta:LISTA[i]:metodo
					ZZ2->ZZ2_REVISA := ItensMeta:LISTA[i]:revisa
					ZZ2->ZZ2_ATIVA  := ItensMeta:LISTA[i]:ativa
					ZZ2->ZZ2_TIPO   := ItensMeta:LISTA[i]:tipo
					
					ZZ2->ZZ2_PERCQL  := ItensMeta:LISTA[i]:pesoQl
					ZZ2->ZZ2_PERCQT  := ItensMeta:LISTA[i]:pesoQt
				ZZ2->(msUnlock())
		 	next i
		 	ZZ2->(dbCloseArea())
		 	cMensagem := "OK"
		end sequence
	else
		begin sequence
			lLimpa := limpaMeta(ItensMeta:LISTA[1]:ano,ItensMeta:LISTA[1]:colaborador,ItensMeta:LISTA[1]:revisa)
			if lLimpa
				dbSelectARea("ZZ2")
				revisa := soma1(ItensMeta:LISTA[1]:revisa)
				for i := 1 to len(ItensMeta:LISTA)
					reclock("ZZ2",.T.)
						ZZ2->ZZ2_FILIAL := xFilial("ZZ2")
						ZZ2->ZZ2_STATUS := "1"
						ZZ2->ZZ2_MESREF := ItensMeta:LISTA[i]:mesref
						ZZ2->ZZ2_MESENV := ItensMeta:LISTA[i]:mesref
						ZZ2->ZZ2_NFLUIG := ItensMeta:LISTA[i]:solicitacao
						ZZ2->ZZ2_DTINIC := CTOD(ItensMeta:LISTA[i]:dtInicio)
						ZZ2->ZZ2_DTFIM  := CTOD(ItensMeta:LISTA[i]:dtFim)
						ZZ2->ZZ2_ANOREF := ItensMeta:LISTA[i]:ano
						ZZ2->ZZ2_COLAB  := ItensMeta:LISTA[i]:colaborador
						ZZ2->ZZ2_USRFG  := ItensMeta:LISTA[i]:userFluig
						ZZ2->ZZ2_GESTOR := ItensMeta:LISTA[i]:gestor
						//ZZ2->ZZ2_GSTFG  := ItensMeta:LISTA[i]:solicitacao
						ZZ2->ZZ2_META   := ItensMeta:LISTA[i]:meta
						ZZ2->ZZ2_DESC   := ItensMeta:LISTA[i]:descricao
						ZZ2->ZZ2_PESO   := ItensMeta:LISTA[i]:peso
						ZZ2->ZZ2_VALOR  := ItensMeta:LISTA[i]:valor
						ZZ2->ZZ2_METODO := ItensMeta:LISTA[i]:metodo
						ZZ2->ZZ2_REVISA := revisa
						ZZ2->ZZ2_ATIVA  := ItensMeta:LISTA[i]:ativa
						ZZ2->ZZ2_TIPO   := ItensMeta:LISTA[i]:tipo
						
						ZZ2->ZZ2_PERCQL  := ItensMeta:LISTA[i]:pesoQl
						ZZ2->ZZ2_PERCQT  := ItensMeta:LISTA[i]:pesoQt
					ZZ2->(msUnlock())
			 	next i
			 	ZZ2->(dbCloseArea())
			 	cMensagem := "OK"
			 else
			 	cMensagem := "Não foi identificado nenhuma meta aberta para a revisão " + ItensMeta:LISTA[1]:revisa
			 endif
		end sequence
	endif
return  cMensagem

method getSubordinados(cFiltro) Class ApoioWS
	local aUsers := FWSFALLUSERS()
	local i := 0
	local aRet := {}
	local aArray := {}
	local j := 0
	local aSuperior := nil
	local cIdUser := ""
	local aFiltro := nil
	PswOrder(2)
	If PswSeek(cFiltro , .T. )
		aFiltro := PSWRET(1) 
		cIdUser := aFiltro[1,1]
		// PESQUISA USUARIOS QUE POSSUEM O SUPERIOR IGUAL AO USUARIO POR FILTRO
		for i:=1 to len(aUsers)
			PswOrder(2)
			If PswSeek(aUsers[i][3] , .T. )
				aArray := PSWRET(1) // Retorna vetor com informações do usuário
				if alltrim(aArray[1,11]) != ""
					aSuperior := STRTOKARR(aArray[1,11],"|")
					for j:=1 to len(aSuperior)
						if alltrim(aSuperior[j]) == alltrim(cIdUser)
							aadd(aRet, {aUsers[i][3] , aUsers[i][4],aUsers[i,5]})
						endif
					next j 
				endif
			endif
		next i
	endif
return aRet


method getFiliais(cUsuario) Class ApoioWS
	
	local aFiliais	:= {}
	local aAreaSM0	:= SM0->(Getarea())
	Local cFiliais	:= ""
	Local aArray	:= {}
	local nB		:= 0
	local cResponsav:= ""
	
	if (cUsuario == "admin")
		cUsuario := "Administrador"
	endif
	
	cUsuario := PADR(cUsuario,25," ")
	PswOrder(2)
	
	If PswSeek(cUsuario, .T. )
		aArray := PSWRET() // Retorna vetor com informações do usuário

		aArray := aArray[2][6]
		//Verifica se tem filiais no configurador para este usuário.
		if len(aArray) > 0
			
			if (aArray[1] != "@@@@")
				aArray := aSort(aArray , , , {|x,y| x < y })
				for nB:=1 to len(aArray)
						
					if allTrim(aArray[nB]) <> cFiliais
						//Posicionando na SM0
						SM0->(DbSetOrder(1))
						SM0->(DBGoTop())
						if(SM0->(DBSeek(aArray[nB])))
						
							
							aAdd(aFiliais,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,;
								SM0->M0_ENDCOB,SM0->M0_CIDCOB,SM0->M0_ESTCOB,SM0->M0_CEPCOB,;
								""})
						endif
					
					endIf
					
					cFiliais := allTrim(aArray[nB])
					
				next nB
			
			else
				SM0->(DbSetOrder(1))
				SM0->(DBGoTop())
				while SM0->(!EoF())

					aAdd(aFiliais,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,;
						SM0->M0_ENDCOB,SM0->M0_CIDCOB,SM0->M0_ESTCOB,SM0->M0_CEPCOB,;
						""})
					
					SM0->(DbSkip())
				
				end
			endif
		endIf
	endif
	restArea(aAreaSM0)
	
return aFiliais

/**
*
* @author: Bruno Ricardo de Oliveira
* @since: 05/08/2015 - 09:52:30
* @description: Método para retornar todos os usuários do protheus. 
*/ 
method getUsuariosProtheus(cEmail) Class ApoioWS
	local aRet := {}
	local cSuperior := ""
	local aArray := {}
	local aSup := {}
	PswOrder(4)
	
	If PswSeek(cEmail, .T. )
		aArray := PSWRET(1) // Retorna vetor com informações do usuário
		aadd(aRet,aArray[1,2])
		if alltrim(aArray[1,11]) != ""
			cSuperior := STRTOKARR(aArray[1,11],"|")
			if alltrim(cSuperior[1]) != ""
				PswOrder(1)
				If PswSeek(cSuperior[1], .T. )
					aSup := PSWRET(1) // Retorna vetor com informações do usuário
					aadd(aRet,aSup[1,2])
					aadd(aRet,aSup[1,14])
				else
					aadd(aRet,"ERROR")
					aadd(aRet,"ERROR")
				endif
			else
				aadd(aRet,"ERROR")
				aadd(aRet,"ERROR")
			endif
		else
			aadd(aRet,"ERROR")
			aadd(aRet,"ERROR")
		endif
	else
		aadd(aRet,"ERROR")
		aadd(aRet,"ERROR")
		aadd(aRet,"ERROR")
	endif
return aRet

method validaInclusao(cTipo , cAno, cColab, cRevisa) Class ApoioWS
	local cMsg := "OK"
	local cQuery := ""
	local cRev := ""
	local cAlias := getNextAlias()
	
	if cTipo == "Nova"
		cQuery += "SELECT R_E_C_N_O_ " +CRLF
		cQuery += "	FROM " + retSqlTab("ZZ2")   + CRLF
		cQuery += "	WHERE ZZ2_ANOREF = '"+cAno+"' "  + CRLF
		cQuery += "	AND ZZ2_COLAB = '"+cColab+"' "  + CRLF
		cQuery += "	AND ZZ2.D_E_L_E_T_ = ' ' "  + CRLF
		conout(cQuery)
		TCQUERY cQuery NEW ALIAS &(cAlias)
	
		if !(cAlias)->(eof())
			cMsg := "NOK"
			
		endif
		(cAlias)->(dbCloseArea())
	else
		cRev := soma1(cRevisa)
		cQuery += "SELECT R_E_C_N_O_ " +CRLF
		cQuery += "	FROM " + retSqlTab("ZZ2")   + CRLF
		cQuery += "	WHERE ZZ2_ANOREF = '"+cAno+"' "  + CRLF
		cQuery += "	AND ZZ2_COLAB = '"+cColab+"' and ZZ2_REVISA = '"+cRev+"' "  + CRLF
		cQuery += "	AND ZZ2.D_E_L_E_T_ = ' ' "  + CRLF
		conout(cQuery)
		TCQUERY cQuery NEW ALIAS &(cAlias)
	
		if !(cAlias)->(eof())
			cMsg := "NOK"
			
		endif
		(cAlias)->(dbCloseArea())
	endif

return cMsg

method validaPreenchimento(cTipo , cAno, cColab, cRevisa, cMes) Class ApoioWS
	local cMsg := "OK"
	local cQuery := ""
	local cRev := ""
	local cAlias := getNextAlias()
	local cMesZZ2 := ""

	cQuery += "SELECT R_E_C_N_O_ " +CRLF
	cQuery += "	FROM " + retSqlTab("ZZ3")   + CRLF
	cQuery += "	WHERE ZZ3_ANOREF = '"+cAno+"' "  + CRLF
	cQuery += "	AND ZZ3_COLAB = '"+cColab+"' "  + CRLF
	cQuery += "	AND ZZ3_MESREF = '"+cMes+"' "  + CRLF
	cQuery += "	AND ZZ3_REVISA = '"+cRevisa+"' "  + CRLF
	cQuery += "	AND ZZ3.D_E_L_E_T_ = ' ' "  + CRLF
	conout(cQuery)
	TCQUERY cQuery NEW ALIAS &(cAlias)

	if !(cAlias)->(eof())
		cMsg := "NOK"	
	endif
	(cAlias)->(dbCloseArea())
	if cMsg == "OK"
		cQuery := "SELECT R_E_C_N_O_, ZZ2_MESREF " +CRLF
		cQuery += "	FROM  " + retSqlTab("ZZ2")   + CRLF
		cQuery += "	WHERE ZZ2_ANOREF = '"+cAno+"' "  + CRLF
		cQuery += "	AND ZZ2_COLAB = '"+cColab+"' "  + CRLF
		cQuery += "	AND ZZ2_REVISA = '"+cRevisa+"' "  + CRLF
		cQuery += "	AND ZZ2.D_E_L_E_T_ = ' ' "  + CRLF
		conout(cQuery)
		TCQUERY cQuery NEW ALIAS &(cAlias)
	
		if !(cAlias)->(eof())
			cMesZZ2 := soma1((cAlias)->ZZ2_MESREF)
			if val(cMesZZ2) != val(cMes)
				cMsg := cMesZZ2
			endif
		endif
		(cAlias)->(dbCloseArea())
	endif

return cMsg

static function limpaMeta(cAno,cColab,cRevisa)
	local lRet := .t.
	local cQuery := ""
	local cAlias := getNextAlias()
	
	cQuery += "SELECT R_E_C_N_O_ " +CRLF
	cQuery += "	FROM " + retSqlTab("ZZ2")   + CRLF
	cQuery += "	WHERE ZZ2_ATIVA = '1' AND ZZ2_ANOREF = '"+cAno+"' "  + CRLF
	cQuery += "	AND ZZ2_COLAB = '"+cColab+"' AND ZZ2_REVISA = '"+cRevisa+"' "  + CRLF
	cQuery += "	AND ZZ2.D_E_L_E_T_ = ' ' "  + CRLF
	conout(cQuery)
	TCQUERY cQuery NEW ALIAS &(cAlias)

	if !(cAlias)->(eof())
		while !(cAlias)->(eof())
			ZZ2->(dbGoTo((cAlias)->R_E_C_N_O_))
			if ZZ2->(RECLOCK("ZZ2", .F.))
				ZZ2->ZZ2_ATIVA := "2"		
						
				ZZ2->(MSUNLOCK())
			endif
			(cAlias)->(dbSkip())
		enddo
		(cAlias)->(dbCloseArea())
	else
		lRet := .f.
	endif
return lRet

method putPreenchimento(tipo, ItensMeta) Class ApoioWS
	local i := 0
	local lLimpa := .t.
	local revisa := ""
	local cMensagem := "Não foi possivel gerar as metas no protheus"
	local cAlias := getNextAlias()
	local cQuery := ""
	if tipo == "Nova"
		begin sequence
			dbSelectARea("ZZ3")
			for i := 1 to len(ItensMeta:LISTA)
				reclock("ZZ3",.T.)
					ZZ3->ZZ3_FILIAL := xFilial("ZZ3")
					ZZ3->ZZ3_NFLUIG := ItensMeta:LISTA[i]:solicitacao
					ZZ3->ZZ3_ANOREF := ItensMeta:LISTA[i]:ano
					ZZ3->ZZ3_COLAB  := ItensMeta:LISTA[i]:colaborador
					ZZ3->ZZ3_META   := ItensMeta:LISTA[i]:meta
					ZZ3->ZZ3_VALOR  := ItensMeta:LISTA[i]:valor
					ZZ3->ZZ3_PERCEN := ItensMeta:LISTA[i]:percent
					ZZ3->ZZ3_REVISA := ItensMeta:LISTA[i]:revisa
					ZZ3->ZZ3_ATIVA  := ItensMeta:LISTA[i]:ativa
					ZZ3->ZZ3_TIPO   := ItensMeta:LISTA[i]:tipo
					ZZ3->ZZ3_MESREF := ItensMeta:LISTA[i]:mes
					ZZ3->ZZ3_MESNOM := ItensMeta:LISTA[i]:nomeMes
					ZZ3->ZZ3_VALPES := ItensMeta:LISTA[i]:valpeso
					ZZ3->ZZ3_OBS	:= ItensMeta:LISTA[i]:observacao
				ZZ3->(msUnlock())
		 	next i
		 	ZZ3->(dbCloseArea())
	 		cQuery += "SELECT R_E_C_N_O_ " +CRLF
			cQuery += "	FROM " + retSqlTab("ZZ2")   + CRLF
			cQuery += "	WHERE ZZ2_ATIVA = '1' AND ZZ2_ANOREF = '"+ItensMeta:LISTA[1]:ano+"' "  + CRLF
			cQuery += "	AND ZZ2_COLAB = '"+ItensMeta:LISTA[1]:colaborador+"' AND ZZ2_REVISA = '"+ItensMeta:LISTA[1]:revisa+"' "  + CRLF
			cQuery += "	AND ZZ2.D_E_L_E_T_ = ' ' "  + CRLF
			conout(cQuery)
			TCQUERY cQuery NEW ALIAS &(cAlias)
		
			if !(cAlias)->(eof())
				while !(cAlias)->(eof())
					ZZ2->(dbGoTo((cAlias)->R_E_C_N_O_))					
					if ZZ2->(RECLOCK("ZZ2", .F.))
						If ItensMeta:LISTA[1]:mes == "12"//caso seja o ultimo mes, desativa o job
							ZZ2->ZZ2_STATUS := "2"
						EndIf
						ZZ2->ZZ2_MESREF := ItensMeta:LISTA[1]:mes										
						ZZ2->(MSUNLOCK())
					endif
					(cAlias)->(dbSkip())
				enddo
				(cAlias)->(dbCloseArea())
			endif
		 	cMensagem := "OK"
		end sequence
	else
		begin sequence
			lLimpa := limpaUserMeta(ItensMeta:LISTA[1]:ano,ItensMeta:LISTA[1]:colaborador,ItensMeta:LISTA[1]:revisa,ItensMeta:LISTA[1]:mes)
			if lLimpa
				dbSelectARea("ZZ3")
				for i := 1 to len(ItensMeta:LISTA)
					reclock("ZZ3",.T.)
						ZZ3->ZZ3_FILIAL := xFilial("ZZ3")
						ZZ3->ZZ3_NFLUIG := ItensMeta:LISTA[i]:solicitacao
						ZZ3->ZZ3_ANOREF := ItensMeta:LISTA[i]:ano
						ZZ3->ZZ3_COLAB  := ItensMeta:LISTA[i]:colaborador
						ZZ3->ZZ3_META   := ItensMeta:LISTA[i]:meta
						ZZ3->ZZ3_VALOR  := ItensMeta:LISTA[i]:valor
						ZZ3->ZZ3_PERCEN := ItensMeta:LISTA[i]:percent
						ZZ3->ZZ3_REVISA := ItensMeta:LISTA[i]:revisa
						ZZ3->ZZ3_ATIVA  := ItensMeta:LISTA[i]:ativa
						ZZ3->ZZ3_TIPO   := ItensMeta:LISTA[i]:tipo
						ZZ3->ZZ3_MESREF := ItensMeta:LISTA[i]:mes
						ZZ3->ZZ3_MESNOM := ItensMeta:LISTA[i]:nomeMes
						ZZ3->ZZ3_OBS	:= ItensMeta:LISTA[i]:observacao
					ZZ3->(msUnlock())
			 	next i
			 	ZZ3->(dbCloseArea())
			 	cQuery += "SELECT R_E_C_N_O_ " +CRLF
				cQuery += "	FROM " + retSqlTab("ZZ2")   + CRLF
				cQuery += "	WHERE ZZ2_ATIVA = '1' AND ZZ2_ANOREF = '"+ItensMeta:LISTA[1]:ano+"' "  + CRLF
				cQuery += "	AND ZZ2_COLAB = '"+ItensMeta:LISTA[1]:colaborador+"' AND ZZ2_REVISA = '"+ItensMeta:LISTA[1]:revisa+"' "  + CRLF
				cQuery += "	AND ZZ2.D_E_L_E_T_ = ' ' "  + CRLF
				conout(cQuery)
				TCQUERY cQuery NEW ALIAS &(cAlias)
			
				if !(cAlias)->(eof())
					while !(cAlias)->(eof())
						ZZ2->(dbGoTo((cAlias)->R_E_C_N_O_))
						if ZZ2->(RECLOCK("ZZ2", .F.))
							ZZ2->ZZ2_MESREF := ItensMeta:LISTA[1]:mes										
							ZZ2->(MSUNLOCK())
						endif
						(cAlias)->(dbSkip())
					enddo
					(cAlias)->(dbCloseArea())
				endif
			 	cMensagem := "OK"
			 else
			 	cMensagem := "Não foi identificado nenhuma meta aberta para a revisão " + ItensMeta:LISTA[1]:revisa
			 endif
		end sequence
	endif
return  cMensagem

static function limpaUserMeta(cAno,cColab,cRevisa,cMes)
	local lRet := .t.
	local cQuery := ""
	local cAlias := getNextAlias()
	// AINDA NÃO IMPLEMENTADO CUIDADO
	cQuery += "SELECT R_E_C_N_O_ " +CRLF
	cQuery += "	FROM " + retSqlTab("ZZ3")   + CRLF
	cQuery += "	WHERE ZZ3_ATIVA = '1' AND ZZ3_ANOREF = '"+cAno+"' "  + CRLF
	cQuery += "	AND ZZ3_COLAB = '"+cColab+"' AND ZZ3_REVISA = '"+cRevisa+"' "  + CRLF
	cQuery += "	AND ZZ3.D_E_L_E_T_ = ' ' AND ZZ3_MESREF = '"+cMes+"'"  + CRLF
	conout(cQuery)
	TCQUERY cQuery NEW ALIAS &(cAlias)

	if !(cAlias)->(eof())
		while !(cAlias)->(eof())
			ZZ3->(dbGoTo((cAlias)->R_E_C_N_O_))
			if ZZ3->(RECLOCK("ZZ3", .F.))
				ZZ3->ZZ3_ATIVA := "2"		
						
				ZZ3->(MSUNLOCK())
			endif
			(cAlias)->(dbSkip())
		enddo
		(cAlias)->(dbCloseArea())
	else
		lRet := .f.
	endif
return lRet

static function getPreco(cRun, cRevisao, cProduto, cEspecie)
	local nPreco := 0
	local lRet := .t.
	local cQuery := ""
	local cAlias := getNextAlias()
	// AINDA NÃO IMPLEMENTADO CUIDADO
	cQuery += "SELECT ZZ4_CPRESA, ZZ4_CPREOU " +CRLF
	cQuery += "	FROM " + retSqlTab("ZZ4")   + CRLF
	cQuery += "	WHERE ZZ4_ATIVA = 'S' AND ZZ4_CODRUN = '"+cRun+"' "  + CRLF
	cQuery += "	AND ZZ4.D_E_L_E_T_ = ' ' AND ZZ4_PRODUT = '"+cProduto+"'"  + CRLF
	conout(cQuery)
	TCQUERY cQuery NEW ALIAS &(cAlias)

	if !(cAlias)->(eof())
		if alltrim(cEspecie) == "01" .OR. alltrim(cEspecie) == "04" .OR. alltrim(cEspecie) == "11"
			nPreco := (cAlias)->ZZ4_CPRESA
		else
			nPreco := (cAlias)->ZZ4_CPREOU
		endif 
	endif
return nPreco





