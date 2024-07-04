#include "PROTHEUS.CH"
#Include "TOPCONN.ch"
#include "PLSA389.ch"

static aCri001 := {STR0001, STR0002} //"CPF/CNPJ Não informado no cadastro da RDA" / "Local de atendimento sem CEP cadastrado."
static aCri002 := {STR0003, STR0004} //"CEP não informado no local de atendimento" / "Local de atendimento sem CNES cadastrado."
static aCri003 := {STR0005, STR0006} //"CNES não encontrado com base no CEP e CPF/CNPJ" / "Local de atendimento com CNPJ/CPF diferente do DATASUS."
static aCri004 := {"", STR0007 } //"CNPJ/CPF não encontrado com base no CEP + CNES."

static lAutoSt := .F.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA389
Função para verificar se há inconsistências na base comparando CEP + CPF/CNPJ com o CNES, tnedo por base
o arquivo de CNES do DataSUS
fonte dos dados Atual:
[http://cnes.datasus.gov.br/pages/downloads/arquivosBaseDados.jsp] -> Atualizar caso mudar
O nome do arquivo é tbEstabelecimento + ano + mês + .csv, como "tbEstabelecimento201812.csv". Sempre que alterar a rotina, gerar um novo wizard da tabela, pois é atualizada mensalmente.

Os registros que o CEP e CNPJ/CPF baterem, oa rotina atualiza o BB8_CNES do local
Os que estiverem OK somente são contados
Os que estiverem sem o CEP, CPF/CNPJ, ou que a combinação dos mesmos não retorne um registro válido no arquivo do DataSUS
são separados e é exibido um relatório para que o usuário possa corrigir o cadastro

@author    Oscar Zanin
@since     19/09/2018
/*/
//------------------------------------------------------------------------------------------
Function PLSA389(lAuto)

Local cSql 	  := ""

lAutoSt := lAuto

cSql += " select BAU_CODIGO CODRDA, BB8_CPFCGC CPFCNPJ, BB8_CODLOC LOCAL, BB8_CEP CEP, BB8_CNES CNESBB8, BZ9_CNES CNESBZ9, BZ9_CPFCPJ CPFBZ9, BB8.R_E_C_N_O_ RECBB8, BAU.R_E_C_N_O_ RECBAU, "
cSql += " Case "
cSql += "  When BB8_CPFCGC = ' '      then '001' " //CPF/CNPJ não cadastrado
cSql += "  When BB8_CEP    = ' '      then '002' " //CEP não cadastrado
cSql += "  When BZ9_CNES  IS NULL     then '003' " //CNES não encontrado com base no CPF/CNPJ + CEP
cSql += "  When BB8_CNES  != BZ9_CNES then '004' " //CNES cadastrado diferente do encontrado
cSql += "  When BB8_CNES   = BZ9_CNES then '005' " //CNES cadastrado igual ao encontrado
cSql += "  else '999' " //Se caiu aqui vai precisar descobrir a condição que fez cair aqui...
cSql += " END "
cSql += "   RESULTADO "
cSql += " from " + RetSqlName("BB8") + " BB8 "
cSql += " Inner Join " + retSqlName("BAU") + " BAU "
cSql += " On "
cSql += " BAU.BAU_FILIAL = BB8.BB8_FILIAL AND BAU.BAU_CODIGO = BB8.BB8_CODIGO "
cSql += " Left Join " + RetSqlName("BZ9") + " BZ9 "
cSql += " On "
cSql += " BB8_FILIAL = BZ9_FILIAL AND BB8_CPFCGC = BZ9_CPFCPJ AND "
cSql += " BB8_CEP = BZ9_CEP AND BZ9.D_E_L_E_T_ = ' ' "
cSql += " Where "
cSql += " BAU_FILIAL = '" + xFilial("BAU") + "' AND "
cSql += " BAU.BAU_CODIGO >= '" + mv_par01 + "' AND BAU.BAU_CODIGO <= '" + mv_par02 + "' AND "
cSql += " BAU.D_E_L_E_T_ = ' ' AND BB8.D_E_L_E_T_ = ' ' "

PlExcQrBB8(cSql, 1) 

Return 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA389Pro
Chamada do menu da rotina de Validação de CNES x RDA x local de atendimento

@author    Oscar Zanin
@since     19/09/2018
/*/
//------------------------------------------------------------------------------------------
function PLSA389Pro(lAuto)
Local lProcessa := .F.
local aResp
Default lAuto := .F.

lAutoSt := lAuto

aResp := PlsRotEsc()

If !lAutoSt
	if !empty(aResp)
		If Pergunte("PLS389",.T.)
			if (aResp[1] == "1")
				Proc2BarGauge( {||PLSA389()}, STR0008) //"Validação CNES x RDA x Local de Atendimento"
			else
				Proc2BarGauge( {||PlsAtCfCjBB8()}, STR0008) //"Validação CNES x RDA x Local de Atendimento"
			endif
		else
			MsgInfo(STR0009) //"Operação cancelada pelo usuário"
		endif
	else
		MsgInfo(STR0009) //"Operação cancelada pelo usuário"		
	endif
else
	Pergunte("PLS389",.F.)
	Mv_Par01 := "  "
	mv_par02 := "ZZ"

	PLSA389(lAutoSt)
	PlsAtCfCjBB8()
endif
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA389VLD
Valid para os campos BB8_CEP e BB8_CNES para inibir a entrada errada de dados

@author    Oscar Zanin
@since     19/09/2018
/*/
//------------------------------------------------------------------------------------------
function PLSA389VLD(nTp)
Local lRet := .F.
Default nTp := 1

If PLSALIASEX("B9Z")
	BZ9->(dbSetOrder(2))
	If BZ9->(MsSeek(xfilial("BZ9") + M->BB8_CEP + BAU->BAU_CPFCGC))
		If nTp == 1
			M->BB8_CNES := BZ9->BZ9_CNES
			lRet := .T.
		else
			lRet := M->BB8_CNES == BZ9->BZ9_CNES
		EndIf
	elseif nTp == 1
		lRet := .T.
		M->BB8_CNES := ""
	endIf
Else
	lret := .T.
endIf

If !lRet
	MsgStop(STR0010) //"CNES inválido com base no CPF/CNPJ da RDA e CEP do Local de atendimento informados"
endIf

Return lRet



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsRotEsc
Valid para os campos BB8_CEP e BB8_CNES para inibir a entrada errada de dados

@author    Oscar Zanin
@since     19/09/2018
/*/
//------------------------------------------------------------------------------------------
static function PlsRotEsc()
local aPergs	:= {}
local aRet		:= {}
local lPerg		:= .T.
  
aadd( aPergs ,{2,STR0011, "1", {STR0012, STR0013},90,,.T.})  //"Selecione o tipo de ajuste:" / "1-Ajustar CNES BB8" / "2-Ajustar CNPJ/CPF BB8"

if !lAutoSt	
	lPerg := ParamBox(aPergs, STR0014,aRet,,,.T.,256,129,,,.F.,.F.) //"Ajuste no cadastro da tabela BB8"
Else
	aRet := {'1'}
endif


if lPerg
	if (!empty(aRet[1]))	    
		aRet := {alltrim(left(aRet[1],1))}
	endif	
endif
Return aRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsAtCfCjBB8
Query de atualização da BB8, para preencher o campo BB8_CPFCGC, caso o o CEP e CNES do local de atendimento sejam iguais ao da tabela BZ9
Fonte dos dados Atual:
[http://cnes.datasus.gov.br/pages/downloads/arquivosBaseDados.jsp] -> Atualizar caso mudar
O nome do arquivo é tbEstabelecimento + ano + mês + .csv, como "tbEstabelecimento201812.csv". Sempre que alterar a rotina, gerar um novo wizard da tabela, pois é atualizada mensalmente.

@author    Renan Martins
@since     02/2019
/*/
//------------------------------------------------------------------------------------------
static function PlsAtCfCjBB8()
local cSql		:= ""

cSql := " SELECT BAU_CODIGO CODRDA, BB8_CPFCGC CPFCNPJ, BB8_CODLOC LOCAL, BB8_CEP CEP, BB8_CNES CNESBB8, BZ9_CNES CNESBZ9, BZ9_CPFCPJ CPFBZ9, BB8.R_E_C_N_O_ RECBB8, BAU.R_E_C_N_O_ RECBAU,"
cSql += "  CASE "
cSql += "		WHEN BB8_CEP    = ' ' THEN '001' " //'Local de atendimento sem CEP'
cSql += "		WHEN BB8_CNES   = ' ' THEN '002' " //'Local de atendimento sem CNES'
cSql += "		WHEN BB8_CPFCGC != BZ9_CPFCPJ AND BB8_CPFCGC != ' ' THEN '003' " //'Local de atendimento com CNPJ/CPF diferente do DATASUS'
cSql += "		WHEN BZ9_CPFCPJ IS NULL THEN '004' " //'CNPJS/CPF não encontrado com CEP + CNES'
cSql += "		WHEN BB8_CPFCGC = ' ' THEN '005' " //'Registro para atualização - CEP + CNES iguais '
cSql += "		WHEN BB8_CPFCGC = BZ9_CPFCPJ THEN '006' " //'Registro para atualização - CEP + CNES iguais '
cSql += "		else '999' "
cSql += "  END RESULTADO "
cSql += " FROM " + retsqlname("BB8") + " BB8 "
cSql += " INNER JOIN " + retsqlname("BAU") + " BAU ON BAU.BAU_FILIAL = BB8.BB8_FILIAL "
cSql += " AND BAU.BAU_CODIGO = BB8.BB8_CODIGO "
cSql += " LEFT JOIN " + retsqlname("BZ9") + " BZ9 ON BAU_FILIAL = BZ9_FILIAL "
cSql += " AND BB8_CEP = BZ9_CEP "
cSql += " AND BB8_CNES = BZ9_CNES "
cSql += " AND BZ9.D_E_L_E_T_ = ' ' "
cSql += " WHERE "
cSql += " BB8_FILIAL = '" + xFilial("BB8") + "' "
cSql += " AND BB8.BB8_CODIGO >= '" + mv_par01 + "' AND BB8.BB8_CODIGO <= '" + mv_par02 + "' "
cSql += " AND BB8.D_E_L_E_T_ = ' ' AND BAU.D_E_L_E_T_ = ' ' "
cSql += " ORDER BY BB8_CODIGO, BB8_CODLOC "

PlExcQrBB8(cSql, 2) 

return 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlExcQrBB8
Valid para os campos BB8_CEP e BB8_CNES para inibir a entrada errada de dados

@author    Oscar Zanin
@since     19/09/2018
/*/
//------------------------------------------------------------------------------------------
function PlExcQrBB8(cSql, nTipo)
Local nContOk   := 0
Local nContErr  := 0
Local nContAlt  := 0
Local aCritica  := {}
Local aAlter	  := {}
Local cMsg		  := ""
Local nI		  := 1
Local nAtual	  := 0
Local nTotal	  := 0
Local ctotal	  := ""
Local cCodOpe	  := PLSINTPAD()
Local aChvAnt	  := { "DEFAULT", "DEFAULT", "DEFAULT" }
default cSql 	:= ""

if (!empty(nTipo) .and. !empty(cSql)) .OR. lautoSt
		
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"PLSA389",.F.,.T.)

	If !lautoSt
		IncProc(STR0016) //"Iniciando Validação"
		ProcessMessage()
	endIf

	PLSA389->( dbEval({|| nTotal ++ }) )
	PLSA389->( DbGoTop() )
	ctotal := Str(nTotal)
	If !lautoSt
		BarGauge1Set(nTotal)     
		IncProc(STR0017) //"Aguardando término da validação.."
		ProcessMessage()
	endIf

	While !(PLSA389->(EoF()))
		
		nAtual++
		If !lautoSt
			IncProc(STR0018 + Str(nAtual) + STR0019 + ctotal + "]") //"Validando registro ["  /  "] de ["  
			ProcessMessage()
		endif

		If PLSA389->RESULTADO == "001"
			nContErr++
				Aadd(aCritica, { PLSA389->CODRDA, iif(nTipo == 1, STR0020, PLSA389->LOCAL), "001", aCri001[nTipo] }) //"Não se aplica"
			
		elseIf PLSA389->RESULTADO == "002"
			nContErr++
				Aadd(aCritica, { PLSA389->CODRDA, PLSA389->LOCAL, "002", aCri002[nTipo] })
			
		elseIf PLSA389->RESULTADO == "003"
			nContErr++
				Aadd(aCritica, { PLSA389->CODRDA, PLSA389->LOCAL, "003", aCri003[nTipo] + iif(nTipo == 2, " BB8:" + alltrim(PLSA389->CPFCNPJ) + "-DataSUS: " + alltrim(PLSA389->CPFBZ9), "") })
			
			elseIf PLSA389->RESULTADO == "004" .and. nTipo == 1
			nContAlt++
			aadd(aAlter, {PLSA389->RECBB8, PLSA389->CNESBZ9, PLSA389->RECBAU} )
			
			elseIf PLSA389->RESULTADO == "004" .and. nTipo == 2
				nContErr++
				Aadd(aCritica, { PLSA389->CODRDA, PLSA389->LOCAL, "004", aCri004[nTipo] })				
					
			elseIf PLSA389->RESULTADO == "005" .and. nTipo == 1
				nContOk++

			elseIf PLSA389->RESULTADO == "005" .and. nTipo == 2
				nContAlt++
				aadd(aAlter, {PLSA389->RECBB8, PLSA389->CPFBZ9, PLSA389->RECBAU} )
			
			elseIf PLSA389->RESULTADO == "006"
			nContOk++
		endIf
		PLSA389->(dbskip())
	EndDo

	If Len(aCritica) > 0
		ASORT(aCritica, , , { | x,y | x[1] + x[2] < y[1] + y[2] } )
	EndIf

	PLSA389->(dbCloseArea())

	If nContAlt > 0
		ctotal := Str(nContAlt)
		If !lautoSt
			BarGauge1Set(nContAlt)
		EndIf
		for nI := 1 to nContAlt
			If !lautoSt
				IncProc(STR0021 + Str(nI) + STR0022 + ctotal + "]") //"Atualizando registro ["  /  "] de ["
				ProcessMessage()
			EndIf
			Begin Transaction

				BB8->(dbgoTo(aAlter[nI][1]))	
				
					if nTipo == 1
				aChvAnt[2] := BB8->BB8_CNES
					else
						aChvAnt[1] := BB8->BB8_CPFCGC
					endif
				
				BB8->(RecLock("BB8", .f.))
						if nTipo == 1
					BB8->BB8_CNES := aAlter[nI][2]
						else
							BB8->BB8_CPFCGC := aAlter[nI][2]
						endif			
				BB8->(MsUnLock())
				
				BAU->(dbGoto(aalter[nI][3]))
				If BAU->BAU_ENVRPS $ '1,3'
					BAU->(Reclock("BAU", .F.))
						BAU->BAU_ENVRPS := '3'
					BAU->(MsUnLock())
						PLSRPSALT(cCodOpe, aAlter[nI][3], aAlter[nI][1], 0, iif( nTipo == 1, {"B5B_CNES"}, {"B5B_CPFCGC"}), "1", aChvAnt)
				ElseIf BAU->BAU_ENVRPS $ ' ,0'
						PLSRPSALT(cCodOpe, aAlter[nI][3], aAlter[nI][1], 0, iif( nTipo == 1, {"B5B_CNES"}, {"B5B_CPFCGC"}), "0", aChvAnt)
				endIf
				aChvAnt	  := { "DEFAULT", "DEFAULT", "DEFAULT" }
				
			end Transaction
		Next
		PLRP5clr() //Limpar o array de contagem de beneficiário por produto
	else
		If !lautoSt
			IncProc(STR0023) //"Não houve atualização de registros"
		EndIf
	endIf

	If nContErr > 0
			cMsg += STR0024 + Str(nContErr) + STR0025 + CRLF + CRLF  //" - Houve [" / "] Registros com erros não possíveis de correção automática. "
	endIf

	If nContAlt > 0
			cMsg += STR0024 + Str(nContAlt) + STR0026 + CRLF + CRLF  //"] Registros com erros corrigidos automaticamente. "
	EndIf

	If nContOk > 0
			cMsg += STR0037 + str(nContOk)  + STR0027  //"] Registros corretos. "
	EndIf

	If !lautoSt
		If Len(cMsg) > 0
			MsgInfo(cMsg)
		else
				MsgAlert(STR0028) //"Não houve processamento! Verifique os parâmetros informados"
		EndIf
	EndIf
	//Incluir no relatório os registros alterados
	If !lautoSt
		If nContErr > 0
				If MsgYesNo(STR0029+ CRLF + STR0030)  //"Deseja visualizar as divergêcias que não foi possível corrigir?"  /   "É possível imprimir o relatório através do menu Outras ações -> Imprimir"
					PLSCRIGEN(aCritica,{ {STR0031,"@C",12 }, {STR0032,"@C",30 }, {STR0033,"@C",5} , {STR0034,"@C",250 } }, STR0036) //"RDA" / "Local Atendimento" / "Critica" / "Descrição" / "  Divergências CNES  "
			EndIf
		EndIf
	EndIf
else
	Msgalert(STR0035) //"Não foi possível identificar qual a escolha de atualização foi realizada pelo usuário!"
endIf

Return
