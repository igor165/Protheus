#INCLUDE "UBAR001.ch"
#include "protheus.ch"
#include "report.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} UBAR001
Função de relatorio Blocos Reservados
@author Aécio Gomes
@since 21/06/2013
@version MP11                                      
/*/
//-------------------------------------------------------------------
Function UBAR001()
	Local oReport
	Local cPerg := "UBAR001"
  
  	//variavel de unidade de beneficiamento
	Private cUserBenf 	:= "" 
	Private lRet		:= .F.
	         
	If FindFunction("TRepInUse") .And. TRepInUse()

		/* Grupo de perguntas UBAR001 
			MV_PAR01 //Safra
			MV_PAR02 //Cliente
			MV_PAR03 //Loja
			MV_PAR04 //Contrato
			MV_PAR05 //Reserva De
			MV_PAR06 //Reserva Ate
			MV_PAR07 //Nome do Classificador do Cliente
			MV_PAR08 //Nome do Classificador Interno
			MV_PAR09 //Nome do responsável
		*/                 
	
		Pergunte(cPerg,.F.)

		//verifica se possui unidade de beneficiamento
		lRet := UBAR01Usu()	
		//If !lRet
		//	Return
		//EndIf
		
		//-------------------------
		// Interface de impressão       
		//-------------------------
		oReport:= ReportDef(cPerg)
		oReport:PrintDialog()
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função de definição do layout e formato do relatório

@return oReport	Objeto criado com o formato do relatório
@author Aécio Gomes
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef(cPerg)
	Local oReport	:= NIL
	Local oSec1	:= NIL
	Local oSec2	:= NIL
	Local oFunc1	:= Nil

	DEFINE REPORT oReport NAME "UBAR001" TITLE STR0001 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} //"Blocos Reservados"
	oReport:lParamPage 	:= .F. 	//Não imprime os parametros
	oReport:nFontBody 	:= 8 	//Aumenta o tamanho da fonte
	oReport:SetCustomText( {|| AGRARCabec(oReport, mv_par01) } ) // Cabeçalho customizado

	//---------
	// Seção 1
	//---------
	DEFINE SECTION oSec1 OF oReport TITLE STR0002 TABLES "DXP","DXQ" //"Reservas"

	DEFINE CELL NAME "DXP_CLIENT" 	OF oSec1  TITLE STR0003 //"Cliente Destino"
	DEFINE CELL NAME "DXP_CODCTP" 	OF oSec1
	DEFINE CELL NAME "DXQ_CODRES" 	OF oSec1
	DEFINE CELL NAME "DXQ_BLOCO" 	OF oSec1
	DEFINE CELL NAME "DXQ_TIPO" 	OF oSec1
	DEFINE CELL NAME "DXQ_QUANT" 	OF oSec1 TITLE STR0004 //"Fardos"
	DEFINE CELL NAME "DXQ_PSBRUT" 	OF oSec1
	DEFINE CELL NAME "DXQ_PSLIQU" 	OF oSec1

	//---------
	// Seção 2
	//---------
	DEFINE SECTION oSec2 OF oReport TOTAL TEXT STR0005 TITLE STR0006 //"Total Geral"###"Totalizador por tipo"
	oSec2:SetTotalInLine(.T.)

	DEFINE CELL NAME "DXQ_TIPO" 	OF oSec2
	DEFINE CELL NAME "DXQ_QUANT" 	OF oSec2 TITLE STR0004 BLOCK{|| QUANT} //"Fardos"
	DEFINE CELL NAME "DXQ_PSBRUT" 	OF oSec2 BLOCK{|| PSBRUT}
	DEFINE CELL NAME "DXQ_PSLIQU" 	OF oSec2 BLOCK{|| PSLIQU}

	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("DXQ_QUANT")  OF oSec2 FUNCTION SUM  TITLE STR0004 NO END REPORT  //"Fardos"
	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("DXQ_PSBRUT")  OF oSec2 FUNCTION SUM  TITLE STR0007 NO END REPORT  //"Peso Bruto"
	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("DXQ_PSLIQU")  OF oSec2 FUNCTION SUM  TITLE STR0008 NO END REPORT  //"Peso Líquido"

Return oReport

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função para busca das informações que serão impressas no relatório

@param oReport	Objeto para manipulação das seções, atributos e dados do relatório.
@ret'urn 
@author Aécio Ferreira Gomes
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport)
	Local oSec1		:= oReport:Section(1)
	Local oSec2		:= oReport:Section(2)
	Local cAlias		:= ""
	Local cSafra		:= MV_PAR01 //Safra
	Local cCliente	:= MV_PAR02 //Cliente
	Local cLoja		:= MV_PAR03 //Loja
	Local cContrato	:= MV_PAR04 //Contrato
	Local cResDe		:= MV_PAR05 //Reserva De
	Local cResAte		:= IIF(Empty(MV_PAR06), StrTran(MV_PAR06,' ','Z'),MV_PAR06)//Reserva Ate
	
	Local cNmClaCli 	:= MV_PAR07 //Nome do Classificador do Cliente
	Local cNmClaInt 	:= MV_PAR08 //Nome do Classificador Interno
	Local cResponsa 	:= MV_PAR09 //Nome do responsável
	Local cNomeEmp	:= AllTrim(FwFilialName(,cFilAnt,2))
	Local cNomeCli 	:= ""
	Local cQry1		:= ""
	
	
	cQry1 += " DXP.D_E_L_E_T_ = '' "
	cQry1 += " AND DXQ.D_E_L_E_T_ = '' "
	cQry1 := "%" + cQry1 + "%" 

	#IFDEF TOP

		IF Funname() = "AGRA720"
			cCodigoD	:= 	DXP->DXP_CODIGO
			cDataD		:=	DtoS(DXP->DXP_DATA)
			cClienteD 	:= 	DXP->DXP_CLIENT
			cLjCliD	:=	DXP->DXP_LJCLI
			cSafraD	:= 	DXP->DXP_SAFRA
			cCodCtpD	:= 	DXP->DXP_CODCTP
			cIteCtpD	:=	DXP->DXP_ITECTP
			cClacomD	:= 	DXP->DXP_CLACOM
		
			//----------------------------
			// Query do relatorio secao 1
			//----------------------------
			Begin Report Query oSec1
		
				cAlias:= GetNextAlias()
		
				BeginSql Alias cAlias
					SELECT *
					FROM %table:DXP% DXP,
						 %table:DXQ% DXQ
					WHERE DXP.DXP_FILIAL    = %xFilial:DXP%
					  AND DXQ.DXQ_FILIAL 	= %xFilial:DXQ%
					  AND DXP.DXP_SAFRA 	= %exp:cSafraD%
					  AND DXP.DXP_CLIENT 	= %exp:cClienteD%
					  AND DXP.DXP_LJCLI 	= %exp:cLjCliD%
					  AND DXP.DXP_CODCTP 	= %exp:cCodCtpD%
					  AND DXQ.DXQ_CODRES 	= %exp:cCodigoD%
					  AND DXP.DXP_DATA		= %exp:cDataD%
					  AND DXP.DXP_CODIGO    = %exp:cCodigoD%
					  AND %Exp:cQry1%
				EndSql
	
			End Report Query oSec1
		
			oSec1:Init()
			oSec1:Cell("DXP_CLIENT"):Disable()
			oSec1:Cell("DXP_CODCTP"):Disable()
			oReport:nCol := 100
			oSec1:Print()
			cNomeCli := Posicione("SA1",1,xFilial("SA1")+cClienteD+cLjCliD,"A1_NREDUZ")
			(cAlias)->(DBCloseArea())
	
			//--------------------------------
			// Query do relatorio da secao 2
			//--------------------------------
			Begin Report Query oSec2
				cAlias:= GetNextAlias()
				BeginSql Alias cAlias
					SELECT DXQ_TIPO, SUM(DXQ_QUANT) AS QUANT, SUM(DXQ_PSBRUT) AS PSBRUT, SUM(DXQ_PSLIQU) AS PSLIQU
					  FROM %table:DXP% DXP,
					       %table:DXQ% DXQ
					 WHERE DXP.DXP_FILIAL   = %xFilial:DXP%
					   AND DXQ.DXQ_FILIAL 	= %xFilial:DXQ%
					   AND DXP.DXP_SAFRA 	= %exp:cSafraD%
					   AND DXP.DXP_CLIENT 	= %exp:cClienteD%
					   AND DXP.DXP_LJCLI 	= %exp:cLjCliD%
					   AND DXP.DXP_CODCTP 	= %exp:cCodCtpD%
					   AND DXQ.DXQ_CODRES 	= %exp:cCodigoD%
					   AND DXP.DXP_DATA		= %exp:cDataD%
				       AND DXP.DXP_CODIGO   = %exp:cCodigoD%
					   AND %Exp:cQry1%
					GROUP BY DXQ_TIPO
				EndSql
			End Report Query oSec2
	
			oSec2:Init()
			oSec2:Print()
			(cAlias)->(DBCloseArea())
			
			If !oReport:NoPrint()
			
				oReport:SkipLine(5)
				oReport:PrintText(MV_PAR10,,50)
				oReport:SkipLine(5)
				//If oReport:IsPortrait()
					oReport:PrintText(SUBSTR(STR0009,1,83),,50) //"Take-up realizado mediante apresentação de listagem completa com resultados de HVI,
					oReport:PrintText(SUBSTR(STR0009,84,58),,50) // cujas análises foram feitas em laboratórios credenciados."
				//Else	
				//	oReport:PrintText(STR0009,,25) //"Take-up realizado mediante apresentação de listagem completa com resultados de HVI, cujas análises foram feitas em laboratórios credenciados."
				//Endif
				oReport:SkipLine(5)
			
		   		// Assinatura do classificador do Cliente
				oReport:PrintText(STR0010+Replicate("_",50),,50) 	//"Assinatura   : "
				oReport:PrintText(STR0011+cNmClaCli,,25) 			//"Classificador: "
				oReport:PrintText(STR0012+cNomeCli,,25) 			//"Empresa      : "
				oReport:SkipLine(1)
		    
		    	// Assinatura do classificador interno
				oReport:PrintText(STR0010+Replicate("_",50),,50) 	//"Assinatura   : "
				oReport:PrintText(STR0011+cNmClaInt,,50) 			//"Classificador: "
				oReport:PrintText(STR0012+cNomeEmp,,50) 			//"Empresa      : "
				oReport:SkipLine(1)
			
		    	// Assinatura do Responsável
				oReport:PrintText(STR0010+Replicate("_",50),,50) 	//"Assinatura   : "
				oReport:PrintText(STR0013+cResponsa,,50) 			//"Responsável  : "
				oReport:PrintText(STR0012+cNomeEmp,,50) 			//"Empresa      : "
				oReport:SkipLine(1)
			EndIf
	
		ELSE
			//----------------------------
			// Query do relatorio secao 1
			//----------------------------
			Begin Report Query oSec1
		
				cAlias:= GetNextAlias()
		
				BeginSql Alias cAlias
					SELECT *
					FROM %table:DXP% DXP,
						 %table:DXQ% DXQ
					WHERE DXP.DXP_FILIAL = %xFilial:DXP%
					  AND DXQ.DXQ_FILIAL = %xFilial:DXQ%
					  AND DXP.DXP_SAFRA  = %exp:cSafra%
					  AND DXP.DXP_CLIENT = %exp:cCliente%
					  AND DXP.DXP_LJCLI  = %exp:cLoja%
					  AND DXP.DXP_CODCTP = %exp:cContrato%
					  AND DXP.DXP_CODIGO >= %exp:cResDe% 
					  AND DXP.DXP_CODIGO <= %exp:cResAte%
					  AND DXQ.DXQ_CODRES = DXP.DXP_CODIGO
					  AND %Exp:cQry1%
				EndSql
	
			End Report Query oSec1
		
			oSec1:Init()
			oSec1:Cell("DXP_CLIENT"):Disable()
			oSec1:Cell("DXP_CODCTP"):Disable()
			oSec1:Print()
			cNomeCli := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NREDUZ")
			(cAlias)->(DBCloseArea())
	
			//--------------------------------
			// Query do relatorio da secao 2
			//--------------------------------
			Begin Report Query oSec2
				cAlias:= GetNextAlias()
				BeginSql Alias cAlias
					SELECT DXQ_TIPO, SUM(DXQ_QUANT) AS QUANT, SUM(DXQ_PSBRUT) AS PSBRUT, SUM(DXQ_PSLIQU) AS PSLIQU
					FROM %table:DXP% DXP,
					     %table:DXQ% DXQ
					WHERE DXP.DXP_FILIAL = %xFilial:DXP%
					  AND DXQ.DXQ_FILIAL = %xFilial:DXQ%
					  AND DXP.DXP_SAFRA  = %exp:cSafra%
					  AND DXP.DXP_CLIENT = %exp:cCliente%
					  AND DXP.DXP_LJCLI  = %exp:cLoja%
					  AND DXP.DXP_CODCTP = %exp:cContrato%
					  AND DXP.DXP_CODIGO BETWEEN %exp:cResDe% AND %exp:cResAte%
					  AND DXQ.DXQ_CODRES = DXP.DXP_CODIGO
					  AND %Exp:cQry1%
					GROUP BY DXQ_TIPO
				EndSql
			End Report Query oSec2
	
			oSec2:Init()
			oSec2:Print()
			(cAlias)->(DBCloseArea())
			
			If !oReport:NoPrint()
				oReport:SkipLine(5)
				oReport:PrintText(MV_PAR10,,50)
				oReport:SkipLine(5)
				//If oReport:IsPortrait()
					oReport:PrintText(SUBSTR(STR0009,1,83),,50) //"Take-up realizado mediante apresentação de listagem completa com resultados de HVI,
					oReport:PrintText(SUBSTR(STR0009,84,58),,50) // cujas análises foram feitas em laboratórios credenciados."
				//Else	
				//	oReport:PrintText(STR0009,,25) //"Take-up realizado mediante apresentação de listagem completa com resultados de HVI, cujas análises foram feitas em laboratórios credenciados."
				//Endif	
				oReport:SkipLine(5)
			
		    	// Assinatura do classificador do Cliente
				oReport:PrintText(STR0010+Replicate("_",50),,50) 	//"Assinatura   : "
				oReport:PrintText(STR0011+cNmClaCli,,50) 			//"Classificador: "
				oReport:PrintText(STR0012+cNomeCli,,50) 			//"Empresa      : "
				oReport:SkipLine(1)
		    
		    	// Assinatura do classificador interno
				oReport:PrintText(STR0010+Replicate("_",50),,50) 	//"Assinatura   : "
				oReport:PrintText(STR0011+cNmClaInt,,50) 			//"Classificador: "
				oReport:PrintText(STR0012+cNomeEmp,,50) 			//"Empresa      : "
				oReport:SkipLine(1)
			
		    	// Assinatura do Responsável
				oReport:PrintText(STR0010+Replicate("_",50),,50) 	//"Assinatura   : "
				oReport:PrintText(STR0013+cResponsa,,50) 			//"Responsável  : "
				oReport:PrintText(STR0012+cNomeEmp,,50) 			//"Empresa      : "
				oReport:SkipLine(1)
			EndIf
		ENDIF
	#ENDIF
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} AGRARCabec
Função para montar cabecalho do relatorio  

@param oReport Objeto para manipulação das seções, atributos e dados do relatório.
@return aCabec  Array com o cabecalho montado
@author Aécio Gomes
@since 21/06/2013
@version MP11.8
/*/
//----------------------------------------------------------------------------------
Static Function AGRARCabec(oReport, cSafra)
	Local aCabec := {}
	Local cNmEmp	:= ""
	Local cNmFilial	:= ""
	Local cChar		:= CHR(160)  // caracter dummy para alinhamento do cabeçalho

	Default cSafra := ""

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif

	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )

	// Linha 1
	AADD(aCabec, "__LOGOEMP__") // Esquerda

	// Linha 2 
	AADD(aCabec, cChar) //Esquerda
	aCabec[2] += Space(9) // Meio
	aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

	// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(9) + oReport:cRealTitle // Meio
	aCabec[3] += Space(9) + STR0014 + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, STR0015 + cNmEmp) //Esquerda //"Empresa:"
	aCabec[5] += Space(9) // Meio

	IF Funname() = "AGRA720"
		cSafraD	:= 	DXP->DXP_SAFRA
	
		If !Empty(cSafraD)
			aCabec[5] += Space(9)+ STR0016+cSafraD   // Direita //"Safra:"
		EndIf
	ELSE
		If !Empty(cSafra)
			aCabec[5] += Space(9)+ STR0016+cSafra   // Direita //"Safra:"
		EndIf
	ENDIF

	// Linha 6
	AADD(aCabec,  +STR0017 + cNmFilial) //Esquerda //"Filial:"

	IF Funname() = "AGRA720"
 
		cClienteD 	:= 	DXP->DXP_CLIENT
		cLjCliD	:=	DXP->DXP_LJCLI
		cCodCtpD	:= 	DXP->DXP_CODCTP

	// Linha 7
		AADD(aCabec,  +STR0018 + Posicione("SA1",1,xFilial("SA1")+cClienteD+cLjCliD,"A1_NREDUZ")) //Esquerda //"Cliente Destino:"

	// Linha 8
		AADD(aCabec,  +STR0019 + cCodCtpD) //Esquerda //"Contrato:"
	ELSE
	// Linha 7
		AADD(aCabec,  +STR0018 + Posicione("SA1",1,xFilial("SA1")+MV_PAR02+MV_PAR03,"A1_NREDUZ")) //Esquerda //"Cliente Destino:"

	// Linha 8
		AADD(aCabec,  +STR0019 + MV_PAR04) //Esquerda //"Contrato:"
	ENDIF
Return aCabec


//-----------------------------------------------------------
/*{Protheus.doc} UBAR01Usu
Validação a inicialização do modelo de dados

@param..: lRet
@author.: Ana Laura Olegini
@since..: 23/06/2015
@Uso....: UBAR001
*/
//-----------------------------------------------------------
Static Function UBAR01Usu()
	Local cCodUser 	:= RetCodUsr()
	dbSelectArea("NKF")
	dbSetOrder(1)
	If !dbSeek(xFilial("NKF")+cCodUser)	
		//Help('',1,STR0017,,STR0018,1) //"Atenção"###"Usuário não possui Unidade de Beneficiamento cadastrado."
		lRet := .F.
	Else
		cUserBenf := NKF->NKF_CODUNB
		lRet := .T.
	EndIf
Return lRet
