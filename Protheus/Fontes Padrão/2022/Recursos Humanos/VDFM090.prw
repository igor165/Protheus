#include "VDFM090.CH"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VDFM090
E-Mail de Alerta de Perícia de Aposentados e Pensionistas
@author Everson S.P Junior
@since 01/11/13
@version P11
@return nil
/*/
//------------------------------------------------------------------------------------ 
Function VDFM090()
Local	clAccount	:= ''
Local	clPassword	:= ''
Local	clServer	:= ''
Local	clFrom		:= ''
Local	clDest		:= '' 
Local	cLog		:= ""
Local	clAssunto	:= STR0001//'Pericia de Aposentados e Pensionistas'
Local	clMensagem	:= ""
Local 	dDtLimite	:= StoD("//")
Local 	nX			:= 0
Local	lMsg      	:= .T.
Local 	lGrv		:= .F. 
Local	aQueyRIP	:= {}
Local	aAreaRIP	:= {}
Local	aArea		:= {}
		
If !(Type("oMainWnd")=="O") // é Rotina Auto...
	RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2],,,"VDF")
EndIf
aAreaRIP	:= RIP->(GetArea())
aArea		:= GetArea()
clDest		:= GetMV( "MV_VDFPERI" ) 

aQueyRIP:= FUNCEML(@dDtlimite)//Retorna Array com todos os Servidores/Membros para pericias e preenche a variável dDtlimite com a data limite de verificação de vencimento

//Função para gerar o corpo do email em html de acordo com o layout do cliente FSGerHtml
clMensagem := FSGerHtml(aQueyRIP)

If Empty(clDest) .AND. (Type("oMainWnd")=="O")
	MsgAlert(STR0019 + CRLF + STR0012,STR0001) //"E-mail não enviado." # "Não há destinatários informados no parâmetro MV_VDFPERI." # "Perícia de Aposentados e Pensionistas"
Else
	If !Empty(clDest) .And. !Empty(clMensagem)
	//se nao possuir 2 endereços, coloca o ";" para que a função padrão de envio de email funcione.
		If At(";",clDest) == 0
			clDest := AllTrim(clDest) + ";"
		EndIf
		//Envia email para a área de cobrança da empresa.*/
		lGrv := gpeMail(clAssunto,clMensagem,clDest,{},@cLog)
	EndIf
	
	If lGrv
		Begin Transaction
			For nX:= 1 To Len(aQueyRIP)
				If RIP->(dbSeek( FwxFilial("RIP")+aQueyRIP[nX][2]+aQueyRIP[nX][5]) )//RIP_FILIAL + RIP_MAT + DTOS(RIP_INISEN)
					RecLock("RIP",.F.)
					RIP->RIP_DTENVI := date()
					RIP->(MsUnlock())
				End	
			Next
		End Transaction	
	EndIf
	RestArea( aAreaRIP )
	RestArea( aArea )
	
	If !(Type("oMainWnd")=="O")
		RpcClearEnv()
	Else //se acionado por tela no módulo VDF
		If lGrv
			MsgInfo(STR0018,STR0001) // "E-mail enviado com sucesso! Verifique os registros atualizados na rotina Controle de Perícias."## "Perícia de Aposentados e Pensionistas"
		Else
			MsgAlert(STR0019 + CRLF + STR0020 + DtoC(dDtLimite)+ CRLF + STR0021 ,STR0001) 
			//"E-mail não enviado." # "Não foram encontrados registros de Aposentados/Pensionistas com envio de e-mail pendente e Período de Isenção a vencer até " # dd/mm/yyyy # "Para maiores detalhes verifique a rotina de Controle de Perícias." ## "Perícia de Aposentados e Pensionistas"
		EndIF
	EndIf	
EndIf

Return

//---------------------------------------------------------------
/*/{Protheus.doc} FSGerHtml
aviso para que os responsáveis confeccionem os relatórios da corregedoria
@author Everson S.P Junior
@since 05/07/13
@version P11 
@return cHtml - Corpo do email formatado no layout html do cliente
/*/ 
//-----------------------------------------------------------------
Static Function FSGerHtml(aQueyRIP)
Local nX      := 0	
Local cHtml   := ""


If !Empty(aQueyRIP)
	cHtml	+='<html>'
	cHtml	+='<head>'
	cHtml	+='<meta http-equiv=Content-Type content="text/html; charset=windows-1252">'
	cHtml	+='<meta name=Generator content="Microsoft Word 12 (filtered)">'
	cHtml	+='<style>'
	cHtml	+='<!--'
	cHtml	+='/* Font Definitions */'
	cHtml	+='@font-face'
	cHtml	+='{font-family:"Cambria Math";'
	cHtml	+='panose-1:2 4 5 3 5 4 6 3 2 4;}'
	cHtml	+='@font-face'
	cHtml	+='{font-family:Calibri;'
	cHtml	+='panose-1:2 15 5 2 2 2 4 3 2 4;}'
	cHtml	+='/* Style Definitions */'
	cHtml	+='p.MsoNormal, li.MsoNormal, div.MsoNormal'
	cHtml	+='{mso-style-name:"Normal\,TOTVS Texto";'
	cHtml	+='margin:0cm;'
	cHtml	+='margin-bottom:.0001pt;'
	cHtml	+='text-align:justify;'
	cHtml	+='text-indent:1.0cm;'
	cHtml	+='line-height:115%;'
	cHtml	+='font-size:11.0pt;'
	cHtml	+='font-family:"Calibri","sans-serif";}'
	cHtml	+='.MsoPapDefault'
	cHtml	+='{margin-bottom:10.0pt;'
	cHtml	+='line-height:115%;}'
	cHtml	+='@page WordSection1'
	cHtml	+='{size:595.3pt 841.9pt;'
	cHtml	+='margin:70.85pt 3.0cm 70.85pt 3.0cm;}'
	cHtml	+='div.WordSection1'
	cHtml	+='{page:WordSection1;}'
	cHtml	+='-->'
	cHtml	+='</style>'
	cHtml	+='</head>'
	cHtml	+='<body lang=PT-BR>'
	cHtml	+='<div class=WordSection1>'
	For nX := 1 To Len(aQueyRIP)
		cHtml	+='<div style="border:solid windowtext 1.0pt;padding:1.0pt 4.0pt 1.0pt 4.0pt">'
		cHtml	+='<p class=MsoNormal style="border:none;padding:0cm"><i>'+ STR0015 + ' <b>'+AllTrim(aQueyRIP[nX][1])+'/'+Alltrim(aQueyRIP[nX][2])+'</b> –'
		cHtml	+='<b>'+Alltrim(aQueyRIP[nX][3])+'</b> '+ STR0016 + ' <b>'+Transform(STOD(aQueyRIP[nX][4]),"@D")+'.</b> '+ STR0017 +'</i></p>'
		cHtml	+='</div>'
		cHtml	+='<p class=MsoNormal>&nbsp;</p>'
	Next	
	cHtml	+='</div>'
	cHtml	+='</body>'
	cHtml	+='</html>'
EndIf	

Return cHtml


//---------------------------------------------------------------
/*/{Protheus.doc} FUNCEML
Query retorna os Servidores/Membros dentro do prazo de prericia.
@author Everson S.P Junior
@since 05/07/13
@version P11 
@return aRet
/*/ 
//-----------------------------------------------------------------

Static Function FUNCEML(dDtlimite)
Local cQryTmp := ' '
Local aRet    := {}
Local cQtdDia := GetMv("MV_VDFDIPE")

If Empty(cQtdDia)
	cQtdDia := "0"
EndIf

dDtLimite := dDataBase + Val(cQtdDia)

cQryTmp += " SELECT RIP_FILIAL,RIP_MAT,RIP_FINISE,RIP_INISEN,RA_NOME "+ CRLF 
cQryTmp += "FROM " 	  + RetSqlName("RIP") + " RIP " + CRLF
cQryTmp += "JOIN "     + RetSqlName( 'SRA' ) + " SRA ON
cQryTmp += " SRA.RA_FILIAL  ='"+FwxFilial('SRA')+"' AND "+ CRLF
cQryTmp += " SRA.D_E_L_E_T_ =' ' AND "+ CRLF
cQryTmp += " SRA.RA_CATFUNC ='9' OR "+ CRLF
cQryTmp += " SRA.RA_CATFUNC ='8' OR "+ CRLF
cQryTmp += " SRA.RA_CATFUNC ='7'   "+ CRLF
cQryTmp += " WHERE  "  + CRLF
cQryTmp += " RIP.RIP_FILIAL ='"+FwxFilial('RIP')+"' AND "+ CRLF
cQryTmp += " RIP.RIP_MAT 	= SRA.RA_MAT AND "+ CRLF
cQryTmp += " RIP.RIP_DTENVI = '"+Space( TamSX3("RIP_INISEN")[1] )+"' AND "+ CRLF
//DATA FIM DA PERICIA DEVE SER MENOR OU IGUAL À DATA LIMITE DO PARÂMETRO MV_VDFDIPE
cQryTmp += " RIP.RIP_FINISE <= '" + DtoS(dDtLimite) + "' AND " + CRLF
cQryTmp += " RIP.D_E_L_E_T_ =' ' "+ CRLF
cQryTmp := ChangeQuery(cQryTmp)

dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'TRBRIP', .F., .T. )

While TRBRIP->(!EOF())
	aAdd(aRet,{TRBRIP->RIP_FILIAL,TRBRIP->RIP_MAT,TRBRIP->RA_NOME,TRBRIP->RIP_FINISE,TRBRIP->RIP_INISEN}) 
	TRBRIP->(DbSkip())
EndDo

TRBRIP->(dbCloseArea())	
Return aRet




