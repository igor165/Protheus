#include "protheus.ch"
#include "tmsp050.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSP050()
Painel de Gestao - Entregas 
Este painel tem como objetivo exibir a quantidade de documentos de entrega 
com status: Em Aberto; Programadas; Em Realização e Encerrado, de acordo  
com a(s) filial/filiais e periodo escolhidos.	

@author Robson M
@since 30/09/2013
@version P12 
/*/
//------------------------------------------------------------------- 

Function TMSP050()

Local aInfo       := {}
Local cAliasQry   := GetNextAlias()
Local cMsg        := ""
Local cPerg       := "TMSP050"
Local cAberto	  := '0'
Local cTransito	  := '0'
Local cProgramadas:= '0'
Local cEncerrado  := '0'
Local cDtIni      := ""
Local cDtFim      := "" 
Local cFilIni 	  := ""
Local cFilFim     := ""

Pergunte(cPerg,.F.)

cFilIni:= xFilial( "DT6", mv_par01)
cFilFim:= xFilial( "DT6", mv_par02)
cDtIni := DTOS(mv_par03)
cDtFim := DTOS(mv_par04)

MakeSqlExpr(cPerg)

BeginSql Alias cAliasQry

	SELECT DT6_STATUS, COUNT(DUD_STATUS) AS QTDE//"Em Aberto: " 
	FROM %table:DT6% DT6
	JOIN %table:DUD% DUD
		ON DUD_FILIAL =  DT6_FILIAL
		AND DUD_FILORI = DT6_FILORI
		AND DUD_FILDOC = DT6_FILDOC
		AND DUD_DOC    = DT6_DOC
		AND DUD_SERIE  = DT6_SERIE 
		AND DUD.%NotDel% 
	WHERE 
		 DT6_STATUS = '1'
		 AND DT6_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFim%  
		 AND DT6_DATEMI BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%  
	GROUP BY DT6_STATUS
		 
	UNION 
	
	SELECT DT6_STATUS, COUNT(DUD_STATUS) AS QTDE//"Programadas: " 
	FROM %table:DT6% DT6
	JOIN %table:DUD% DUD
		ON DUD_FILIAL = DT6_FILIAL
		AND DUD_FILORI = DT6_FILORI
		AND DUD_FILDOC = DT6_FILDOC
		AND DUD_DOC    = DT6_DOC
		AND DUD_SERIE  = DT6_SERIE
		AND DUD.%NotDel%
	WHERE 
		 DT6_STATUS = '6'
		 AND DT6_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFim%  
		 AND DT6_DATEMI BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%   
	GROUP BY DT6_STATUS 
	
	UNION
	
	SELECT DT6_STATUS, COUNT(DUD_STATUS) AS QTDE //"Em realizacao: "
	FROM %table:DT6% DT6
	JOIN %table:DUD% DUD
		ON DUD_FILIAL = DT6_FILIAL
		AND DUD_FILORI = DT6_FILORI
		AND DUD_FILDOC = DT6_FILDOC
		AND DUD_DOC    = DT6_DOC
		AND DUD_SERIE  = DT6_SERIE  
		AND DUD.%NotDel%
	WHERE 
		 DT6_STATUS = '2' 
		 AND DT6_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFim%  
		 AND DT6_DATEMI BETWEEN %Exp:cDtIni% AND %Exp:cDtFim% 
	GROUP BY DT6_STATUS
	
	UNION 
	
	SELECT DT6_STATUS, COUNT(DUD_STATUS) AS QTDE//"Encerradas: " 
	FROM %table:DT6% DT6
	JOIN %table:DUD% DUD
		ON DUD_FILIAL = DT6_FILIAL
		AND DUD_FILORI = DT6_FILORI
		AND DUD_FILDOC = DT6_FILDOC
		AND DUD_DOC    = DT6_DOC
		AND DUD_SERIE  = DT6_SERIE 
		AND DUD.%NotDel%
	WHERE 
		 DT6_STATUS = '7' 
		 AND DT6_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFim%  
		 AND DT6_DATEMI BETWEEN %Exp:cDtIni% AND %Exp:cDtFim% 
		 AND DT6.%NotDel%
	GROUP BY DT6_STATUS

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!EOF()) 
		Do Case			
			Case (cAliasQry)->DT6_STATUS == '1' 
				cAberto:=    cValtoChar((cAliasQry)->QTDE)
								
			Case (cAliasQry)->DT6_STATUS == '6' 
				cProgramadas:=  cValtoChar((cAliasQry)->QTDE)
				
			Case (cAliasQry)->DT6_STATUS == '2' 
				cTransito:=    cValtoChar((cAliasQry)->QTDE)
					
			Case (cAliasQry)->DT6_STATUS == '7' 
				cEncerrado:= cValtoChar((cAliasQry)->QTDE)
					
		EndCase 
		(cAliasQry)->(dbSkip())
	 Enddo
EndIf
(cAliasQry)->(DbCloseArea())

cMsg := STR0006//"'"+"Este painel tem como objetivo exibir a quantidade de documentos de entrega "  +"'+chr(13)+chr(10)+" 
cMsg += STR0007//"'"+"com status: Em Aberto; Programadas; Em Realização e Encerrado, de acordo "    +"'+chr(13)+chr(10)+" 
cMsg += STR0008//"'"+"com a(s) filial/filiais e periodo escolhidos."+"'"	

aInfo  := { { STR0002,cAberto, CLR_BLUE,"{ || MsgInfo("+cMsg+") }" },   {STR0003,cProgramadas, CLR_BLUE,"{ || MsgInfo("+cMsg+") }" } ,   { STR0004,cTransito, CLR_BLUE, "{ || MsgInfo("+cMsg+") }" } ,   { STR0005,cEncerrado, CLR_BLUE, "{ || MsgInfo("+cMsg+") }" }  }

Return aInfo   