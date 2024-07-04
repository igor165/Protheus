#include "Protheus.ch"
#Include "Directry.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "totvs.ch"
#include "Fileio.ch"
#DEFINE ENTER CHR(13)+CHR(10)

Main Function BCDataVolume()

	If MsgYesNo("Deseja iniciar o processo de volumetria de dados?","BCDataVolume")
		FWMsgRun( ,{|oSay| BCDataVolExec(oSay) }, "Aguarde...", "Carregando dados...",.F.)
	EndIf
Return

/*/{Protheus.doc} BCDataVolume
	(long_description)
	@type  Function
	@author Leandro.Oliveira
	@since 08/03/2021
	@version version
	@param oSay, Object, para evitar lock da trhead e desconstruir o Objeto gerado pelo FWMsgRun
	@return oSay, Object, para evitar lock da trhead e desconstruir o Objeto gerado pelo FWMsgRun
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function BCDataVolExec(oSay)
	Local aDataVol	:={}
	Local aCompany	:={}
	Local nI		:= 0
	Local nJ		:= 0
	local cArquivo := "\SPOOL\Volumededados_"+DtoS(date())+".CSV"
	local nHandle := FCREATE(cArquivo)
	Local clinha	:= ""
	Local cHeader	:=""
	Local Count := 0
	
	If (nHandle) <= -1
		Conout("Nao foi possivel criar arquivo: " + cArquivo)
		Return oSay
	Else
		Conout("Arquivo Criado")
	EndIf
	
	SET DELET ON
    OpenSM0()
	
	aEval( FWAllGrpCompany(), {|oComp| AAdd(aCompany, { .F., oComp, FWEmpName(oComp),{} }) } )
	//header
	Aadd(aDataVol,{{'','EMPRESA',;
		'FILIAIS',;
		'TOTAL REGISTROS CQ1';
		}})
	For nI:= 1 to Len(aCompany)
		aFil := FWAllFilial(,,aCompany[nI][2])
		For nJ:= 1 to Len(aFil)
			RPCSetType( 3 )
			RPCSetEnv( aCompany[nI][2], aFil[nJ] )
			//Dados
			Aadd(aDataVol,BCaDataEmp(aCompany[nI][2], aFil[nJ] ))
			RpcClearENv()
		Next
	Next
	//Totalizador
	Aadd(aDataVol,{{"Total","","",0}})
	//Impressao do header
	aEval(aDataVol[1][1],{|x|count++,cHeader+=iif(count>1,";","")+x})
	Conout(cHeader)
	FWrite(nHandle,cHeader+ENTER)
	For nI:= 2 to Len(aDataVol)
		cLinha:= ""
		For nJ:= 1 to Len(aDataVol[nI][1])
			If nJ = 1 .AND. nI = Len(aDataVol)
				cLinha += aDataVol[nI][1][nJ] + ";"
				loop
			Endif
			If nJ < 4
				cLinha += aDataVol[nI][1][nJ] + ";"
			Else
				cLinha += cValToChar(aDataVol[nI][1][nJ])
				aDataVol[len(aDataVol)][1][nJ]+=aDataVol[nI][1][nJ]
			EndIf
			
		Next
		// Impressao da linha
		Conout(cLinha)
		FWrite(nHandle,cLInha+ENTER)
	Next
	fClose(nHandle)
	MessageBox("Arquivo gerado em: "+cArquivo,"BCDataVolume",0)
Return oSay


/*/{Protheus.doc} BCDataVolume
	(long_description)
	@type  Function
	@author Leandro.Oliveira
	@since 08/03/2021
	@version version
	@param cCurrEmp, Char, Cod da empresa
	@return aRet, array, resultado da view
	/*/
Static Function BCaDataEmp(cCurrEmp, cCurrFil)
	Local aRet		:={}
	Local cAlias 	:=GetNextAlias()
	Local cDateFF5	:= cValToChar(YEAR(date())-5)+'0101'
	Local cQuery	:= ""
	 
	
	cQuery+="	SELECT "
	
	cQuery+="	("
	cQuery+="	SELECT COUNT(*)"
	cQuery+="	FROM "+ RetSqlName('CQ1')+"  CQ1 "

	cQuery+="	WHERE CQ1_DATA >= '"+cDateFF5+"'AND CQ1.D_E_L_E_T_ = ' ' AND CQ1_FILIAL = '"+xFilial('CQ1')+"' "
	cQuery+="	) AS CQ1_TOTAL

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	// Dados
	While (cAlias)->(!EOF())
		
		Aadd(aRet,{'',cCurrEmp,;
		(cCurrFil),;
		(cAlias)->CQ1_TOTAL;
		})
		
		(cAlias)->(DbSkip())
	End
	(cAlias)->(DbCloseArea())

Return aRet
