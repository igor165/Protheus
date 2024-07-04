#include "protheus.ch"
#include "tmsp040.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSP040()
Painel de Gestao - Coletas 	
Este painel tem como objetivo exibir a quantidade de documentos de coleta 
com status: Em Aberto; Programadas; Em Realização e Encerrado, de acordo  
com a(s) filial/filiais e periodo escolhidos.

@author Robson M
@since 30/09/2013
@version P12 
/*/
//------------------------------------------------------------------- 

Function TMSP040()

Local aInfo       := {}
Local cAliasQry   := GetNextAlias()
Local cMsg        := ""
Local cPerg       := "TMSP040"
Local cAberto	  := '0'
Local cTransito	  := '0'
Local cProgramadas:= '0'
Local cEncerrado  := '0'
Local cDtIni      := ""
Local cDtFim      := "" 
Local cFilIni 	  := ""
Local cFilFim     := ""

Pergunte(cPerg,.F.)

cFilIni:= xFilial( "DT5", mv_par01 )
cFilFim:= xFilial( "DT5", mv_par02 )
cDtIni := DTOS(mv_par03)
cDtFim := DTOS(mv_par04)

MakeSqlExpr(cPerg)

BeginSql Alias cAliasQry

	SELECT DT5_STATUS, COUNT(DUD_STATUS) AS QTDE //"Em Aberto: "
	FROM %table:DT5% DT5
	JOIN %table:DUD% DUD
		ON DUD_FILDOC  = DT5_FILORI
		AND DUD_DOC    = DT5_DOC
		AND DUD_SERIE  = DT5_SERIE 
		AND DUD.%NotDel% 
	WHERE 
		 DT5_STATUS = '1'  		 
		 AND DT5_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFim% 
		 AND DT5_DATSOL BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%
		 AND DT5.%NotDel%  
	GROUP BY DT5_STATUS
		 
	UNION 
	
	SELECT DT5_STATUS, COUNT(DUD_STATUS) AS QTDE //"Programadas: "
	FROM %table:DT5% DT5
	JOIN %table:DUD% DUD
		ON DUD_FILDOC  = DT5_FILORI
		AND DUD_DOC    = DT5_DOC
		AND DUD_SERIE  = DT5_SERIE
		AND DUD.%NotDel%
	WHERE 
		 DT5_STATUS = '2'   		 
		 AND DT5_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFim%
		 AND DT5_DATSOL BETWEEN %Exp:cDtIni% AND %Exp:cDtFim% 
		 AND DT5.%NotDel% 
	GROUP BY DT5_STATUS 
	
	UNION
	
	SELECT DT5_STATUS, COUNT(DUD_STATUS) AS QTDE//"Em realizacao: " 
	FROM %table:DT5% DT5
	JOIN %table:DUD% DUD
		ON DUD_FILDOC  = DT5_FILORI
		AND DUD_DOC    = DT5_DOC
		AND DUD_SERIE  = DT5_SERIE  
		AND DUD.%NotDel%
	WHERE 
		 DT5_STATUS = '3'		 
		 AND DT5_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFim%
		 AND DT5_DATSOL BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%  
		 AND DT5.%NotDel%
	GROUP BY DT5_STATUS
	
	UNION 
	
	SELECT DT5_STATUS, COUNT(DUD_STATUS) AS QTDE //"Realizadas: "
	FROM %table:DT5% DT5
	JOIN %table:DUD% DUD
	ON DUD_FILDOC  = DT5_FILORI
		AND DUD_DOC    = DT5_DOC
		AND DUD_SERIE  = DT5_SERIE 
		AND DUD.%NotDel%
	WHERE 
		 DT5_STATUS = '4'  		 
		 AND DT5_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFim%
		 AND DT5_DATSOL BETWEEN %Exp:cDtIni% AND %Exp:cDtFim% 
		 AND DT5.%NotDel% 
	GROUP BY DT5_STATUS
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!EOF()) 
		Do Case			
			Case (cAliasQry)->DT5_STATUS == '1' 
				cAberto:=    cValtoChar((cAliasQry)->QTDE)
				
			Case (cAliasQry)->DT5_STATUS == '2' 
				cProgramadas:=  cValtoChar((cAliasQry)->QTDE)

			Case (cAliasQry)->DT5_STATUS == '3' 
				cTransito:=    cValtoChar((cAliasQry)->QTDE)

			Case (cAliasQry)->DT5_STATUS == '4' 
				cEncerrado:= cValtoChar((cAliasQry)->QTDE)

		EndCase 
		(cAliasQry)->(dbSkip())
	 Enddo
EndIf
(cAliasQry)->(DbCloseArea())

cMsg := STR0006//"'"+"Este painel tem como objetivo exibir a quantidade de documentos de coleta "  +"'+chr(13)+chr(10)+" 
cMsg += STR0007//"'"+"com status: Em Aberto; Programadas; Em Realização e Encerrado, de acordo "   +"'+chr(13)+chr(10)+" 
cMsg += STR0008//"'"+"com a(s) filial/filiais e periodo escolhidos."+"'"	 											

aInfo  := { { STR0002,cAberto, CLR_BLUE,"{ || MsgInfo("+cMsg+") }" },   {STR0003,cProgramadas, CLR_BLUE,"{ || MsgInfo("+cMsg+") }" } ,   { STR0004,cTransito, CLR_BLUE, "{ || MsgInfo("+cMsg+") }" } ,   { STR0005,cEncerrado, CLR_BLUE, "{ || MsgInfo("+cMsg+") }" }  }

Return aInfo    