#include 'protheus.ch'
#DEFINE FINALIZADO	"6"
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCENTEMAIL

Funcao generica para incluir historico da mudanca do status do compromisso 

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCENTEMAIL(lAutomacao)
	Local aResult	:= {}
	Default lAutomacao := .F.
	
	//Busco os compromissos que estão pendentes de envio (criticados ou não) e vejo se já devo mandar email de aviso de vcto
	If BuscaCompromissos()
		Do While !TRBCMP->(Eof()) 
			//Aproveito para mandar o email dos compromissos criticados e os prontos para envio
			PLCOMPENV(TRBCMP->B3D_CODOPE,TRBCMP->B3D_CDOBRI,TRBCMP->B3D_ANO,TRBCMP->B3D_CODIGO,TRBCMP->B3D_STATUS,ALLTRIM(TRBCMP->B3A_DESCRI) + " - " + TRBCMP->B3D_REFERE,STOD(TRBCMP->B3D_VCTO) - dDataBase,lAutomacao)
			aAdd(aResult,{TRBCMP->B3D_CODOPE,TRBCMP->B3D_CDOBRI,TRBCMP->B3D_ANO,TRBCMP->B3D_CODIGO,TRBCMP->B3D_TIPOBR,TRBCMP->B3D_STATUS})
			TRBCMP->(DbSkip())
		EndDo
	EndIf
	TRBCMP->(dbCloseArea())

Return aResult
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCOMPENV

Funcao generica para incluir historico da mudanca do status do compromisso

@param cCodOpe		Numero de registro da operadora na ANS
@param cCodObri		Chave da obrigacao
@param cAno			Ano do compromisso
@param cCodComp		Chave do compromisso
@param cStatus		Status atual do compromisso
@param cDesc		Descricao / nome do compromisso
@param nDiasVcto	Dias para o vencimento
@param lAuto		Diz se a rotina está sendo chamada pela automação

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLCOMPENV(cCodOpe,cCodObri,cAno,cCodComp,cStatus,cDesc,nDiasVcto,lAuto)
	Local cRemet		:= ""
	Local cDestino		:= ""
	Local cAssunto		:= "Central de Obrigações de Saúde - " + cDesc
	Local cBody			:= ""
	DEFAULT cCodOpe		:= ""
	DEFAULT cCodObri	:= ""
	DEFAULT nDiasVcto	:= 0
	DEFAULT cDesc		:= ""
	DEFAULT lAuto 		:= .F.

	B3E->(dbSetOrder(1)) //B3E_FILIAL+B3E_CODOPE+B3E_CDOBRI+B3E_ANO+B3E_CDCOMP
	//Posiciona na tabela de Contatos
	If B3E->(MsSeek(xFilial("B3E")+cCodOpe+cCodObri+cAno+cCodComp ))
		Do While !B3E->(Eof()) .AND. B3E->(B3E_FILIAL+B3E_CODOPE+B3E_CDOBRI+B3E_ANO+B3E_CDCOMP)==xFilial("B3E")+cCodOpe+cCodObri+cAno+cCodComp
			cDestino += AllTrim(B3E->B3E_EMAIL) + ";"
			B3E->(dbSkip())
		EndDo
	EndIf
	//Posiciona na tabela da Operadora
	//e retorna o email da operadora
	BA0->(DbSetOrder(5))
	If BA0->(MsSeek(xFilial("BA0")+cCodOpe) )
		cRemet := AllTrim(BA0->BA0_EMAIL)
	EndIf
	If cDestino <> ""
		cBody := "Prezado(a), <br><br>" 
		cBody += "O Compromisso " + cDesc + ": "
			
		Do Case
			Case cStatus == "2"
				cBody += "<br>- Possui críticas no processamento. Acesse a Central de Obrigações para mais detalhes."
			Case cStatus == "3"
				cBody += "<br>- Está pronto para o envio. Acesse a Central de Obrigações para gerar o arquivo XML."
			Case cStatus == "5"
				cBody += "<br>- Foi criticado pela ANS, providencie a correção e reenvio."
		End Case

		If nDiasVcto > 0
			cBody += "<br>- Vencerá em " + Alltrim(str(nDiasVcto)) + " dia(s). Providencie o envio do arquivo até a data estipulada pela ANS."
		ElseIf nDiasVcto == 0
			cBody += "<br>- Vence hoje. Providencie o envio do arquivo."
		ElseIf nDiasVcto < 0
			cBody += "<br>- Está vencido há " + Alltrim(str(abs(nDiasVcto))) + " dia(s). Providencie o envio do arquivo o mais breve possível."
		EndIf

		aCposEDataWF := {{"TEXTO",cBody}}
		
		If !lAuto
			PlsWFProc( "000001", "WF_Central_Obrigacoes" , cAssunto, "", cDestino,"" ,SuperGetMv("MV_RSPCMAIL",,"") ,"\workflow\WfRecCentralObrig.html" , aCposEDataWF , , ) //"WF - Recurso de glosa"			
		EndIf

	EndIf

Return aCposEDataWF
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SchedDef

Funcao criada para definir o pergunte do schedule

@return aParam		Parametros para a pergunta do schedule 

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SchedDef()
	Local aOrdem := {}
	Local aParam := {}

	aParam := { "P","PARAMDEF",,aOrdem,""}

Return aParam

Static Function BuscaCompromissos()
	Local cSql 		:= ""
	Local lFound	:= .F.
	Local cTIPODB 	:= Alltrim(Upper(TCGetDb()))

	cSql := " SELECT "
	cSql += "  B3A_CODOPE,B3A_CODIGO,B3A_DESCRI,B3D_VCTO,B3D_REFERE,B3D_CODOPE
	cSql += "  ,B3D_CDOBRI,B3D_ANO,B3D_CODIGO,B3D_TIPOBR,B3D_STATUS "
	cSql += " FROM " 
	cSql += "   " + RetSqlName("B3A") + " B3A "
	cSql += " , " + RetSqlName("B3D") + " B3D "
	cSql += " WHERE "
	cSQL += " B3A_FILIAL = '"+xFilial("B3A")+"' "
	cSQL += " AND B3D_FILIAL = '"+xFilial("B3D")+"' "
	cSQL += " AND B3D_CODOPE = B3A_CODOPE "
	cSQL += " AND B3D_CDOBRI = B3A_CODIGO "
	cSQL += " AND B3D_TIPOBR = B3A_TIPO "
	cSQL += " AND B3A_ATIVO = '1' "
	cSQL += " AND B3D_STATUS <> '" + FINALIZADO + "' "
	
	If cTIPODB $ "MSSQL/MSSQL7"
		cSQL += " AND DATEDIFF(day, '" + DTOS(dDataBase) + "', B3D_VCTO) <= B3D_AVVCTO "
	Else
		cSQL += " AND TO_NUMBER( TO_DATE('" + DTOS(dDataBase) + "', 'YYYYMMDD') - TO_DATE(B3D_VCTO, 'YYYYMMDD') ) <= B3D_AVVCTO "
	EndIf

	cSQL += " AND B3A.D_E_L_E_T_ = ''  "
	cSQL += " AND B3D.D_E_L_E_T_ = ''  "
	cSql += " ORDER BY B3D_VCTO "

	If (Select("TRBCMP") > 0)
		TRBCMP->(dbCloseArea())
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCMP",.F.,.T.)

	lFound := !TRBCMP->(Eof())

Return lFound