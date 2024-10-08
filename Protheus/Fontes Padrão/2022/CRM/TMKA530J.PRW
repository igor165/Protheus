#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SLARegisterTop    �Autor: Vendas Clientes     �Data:08/01/08���
�������������������������������������������������������������������������͹��
���Desc.     �Classe que contempla as rotinas referentes a banco de dados ���
���          �Top.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class SLARegisterTop From PersistSLARegister
Method new() Constructor
Method load(obj)
Method fillEntities(obj, cAlias)

EndClass


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �new       �Autor  �Vendas Clientes     � Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construtor da classe SLARegisterTop                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class SLARegisterTop

Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �load      �Autor  �Vendas Clientes     � Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �														      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �fillEntiti�Autor  �Vendas Clientes     � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Preenche o objeto com as entidades encontradas             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA530J     �Autor  �Vendas Clientes � Data �  08/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION _TMKA530J()
RETURN NIL