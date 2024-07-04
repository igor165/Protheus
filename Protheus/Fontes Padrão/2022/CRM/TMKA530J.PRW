#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออัอออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSLARegisterTop    ณAutor: Vendas Clientes     ณData:08/01/08บฑฑ
ฑฑฬออออออออออุออออออออออออออออออฯอออออออออออออออออออออออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse que contempla as rotinas referentes a banco de dados บฑฑ
ฑฑบ          ณTop.                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class SLARegisterTop From PersistSLARegister
Method new() Constructor
Method load(obj)
Method fillEntities(obj, cAlias)

EndClass


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณnew       บAutor  ณVendas Clientes     บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Construtor da classe SLARegisterTop                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method new() Class SLARegisterTop

Return Self


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณload      บAutor  ณVendas Clientes     บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ														      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method load(obj) Class SLARegisterTop
Local lRet	 := .F. 				//Indica o retorno da funcao        
Local aArea	:= GetArea()			//Armazena a area
Local cAlias :=	GetNextAlias() 		//Alias temporario da query
Local aStru	:= SK5->(dbStruct())
Local nStru	:= 0
Local cWhere:= "% SK5.K5_CODIGO = '" + obj:registerID + "' "							//Condicao a ser adicionada na query
                                                                                            
If !Empty(obj:item)
	cWhere += " AND SK5.K5_ITEM = '" + obj:item + "' "
EndIf
cWhere += " %"



If TK510NewFields()
	BeginSQL alias cAlias
		SELECT 	K5_CODIGO,	K5_ITEM,	K5_CHAVE,	K5_DATA,
				K5_HORA,	K5_DTEXPIR,	K5_HREXPIR,	K5_DTENCER,
				K5_HRENCER,	K5_SEVE,	K5_CODSLA,	K5_CODRESP,	
				K5_STATUS,	K5_CODBLK,	K5_PAUSED,	K5_PAUSEDT,	
				K5_DTATUA,	K5_HRATUA,	K5_CODANT
		FROM %table:SK5% SK5
		WHERE	SK5.K5_FILIAL = %xFilial:SK5% AND 
				SK5.%NOTDEL% 	AND
				%exp:cWhere%  
		ORDER BY SK5.K5_ITEM
	EndSql
Else
	BeginSQL alias cAlias	
		SELECT 	K5_CODIGO,	K5_ITEM,	K5_CHAVE,	K5_DATA,
				K5_HORA,	K5_DTEXPIR,	K5_HREXPIR,	K5_DTENCER,
				K5_HRENCER,	K5_SEVERID,	K5_CODSLA,	K5_CODRESP,	
				K5_STATUS,	K5_CODBLK,	K5_PAUSED,	K5_PAUSEDT,	
				K5_DTATUA,	K5_HRATUA,	K5_CODANT
		FROM %table:SK5% SK5
		WHERE	SK5.K5_FILIAL = %xFilial:SK5% AND 
				SK5.%NOTDEL% 	AND
				%exp:cWhere%  
		ORDER BY SK5.K5_ITEM
	EndSql		
EndIf


For nStru := 1 To Len(aStru)
	If aStru[nStru,2] <> "C" .AND. aStru[nStru,2] <> "M"
		TcSetField(cAlias,aStru[nStru,1],aStru[nStru,2],aStru[nStru,3],aStru[nStru,4])
	EndIf
Next nStru

	
While (cAlias)->(!Eof())
	obj:registerID		:= (cAlias)->K5_CODIGO
	obj:item			:= (cAlias)->K5_ITEM
	obj:keyInfo			:= (cAlias)->K5_CHAVE
	//obj:details			:= (cAlias)->K5_OBS
	obj:createdDate		:= (cAlias)->K5_DATA
	obj:createdHour		:= (cAlias)->K5_HORA
	obj:dateToExpire	:= (cAlias)->K5_DTEXPIR
	obj:hourToExpire	:= (cAlias)->K5_HREXPIR
	obj:finishedDate	:= (cAlias)->K5_DTENCER
	obj:finishedHour	:= (cAlias)->K5_HRENCER
	obj:previousCode	:= (cAlias)->K5_CODANT
	obj:updatedDate		:= (cAlias)->K5_DTATUA
	obj:updatedHour		:= (cAlias)->K5_HRATUA
	If TK510NewFields()
		obj:severityCode	:= Val((cAlias)->K5_SEVE)
	Else
		obj:severityCode	:= (cAlias)->K5_SEVERID
	EndIf
	obj:SlaFound		:= (cAlias)->K5_CODSLA
	obj:SlaResponsible	:= (cAlias)->K5_CODRESP
	obj:StatusRegister	:= (cAlias)->K5_STATUS
	obj:cbWhenDelayed	:= (cAlias)->K5_CODBLK
	obj:Paused			:= (cAlias)->K5_PAUSED
	obj:PausedTime		:= (cAlias)->K5_PAUSEDT

	lRet := .T.
	(cAlias)->(DbSkip())
End	

DbSelectArea(cAlias)
DbCloseArea()     	

If lRet 
	BeginSQL alias cAlias
		SELECT 	K7_FILIAL, K7_NOMEENT, K7_CODENT, K7_CODSLA
		FROM	%table:SK7% SK7 
		WHERE	SK7.K7_FILIAL = %xFilial:SK7% AND 	
				SK7.%NOTDEL% AND
				SK7.K7_CODSLA = %EXP:obj:SlaFound%
	EndSql                                  	
	Self:fillEntities(obj, cAlias)	
	DbSelectArea(cAlias)
	DbCloseArea()     	
EndIf

RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณfillEntitiบAutor  ณVendas Clientes     บ Data ณ  22/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche o objeto com as entidades encontradas             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method fillEntities(obj, cAlias) Class SLARegisterTop
Local oEntity

While (cAlias)->(!Eof())
	oEntity := SLAEntity():New()
	oEntity:entityName	:= (cAlias)->K7_NOMEENT
	oEntity:entityValue	:= (cAlias)->K7_CODENT
	
	aAdd(obj:entities, oEntity)
	
	(cAlias)->(DbSkip())
End 

Return obj


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_TMKA530J     บAutor  ณVendas Clientes บ Data ณ  08/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao dummy apenas para o programa aparecer no inspetor de บฑฑ
ฑฑบ          ณobjetos                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION _TMKA530J()
RETURN NIL