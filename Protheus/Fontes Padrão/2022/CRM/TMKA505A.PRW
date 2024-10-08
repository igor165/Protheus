#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Programa  �TeleServicingCodebase�Autor �Michel Mosca     � Data �  01/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     |Classe que contempla as rotina de acesso a banco de dados Codebase.��� 
���          �                                                                   ���
��������������������������������������������������������������������������������͹��
���Uso       � MP10                                                              ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������     
*/
Class TeleServicingCodebase From PersistTeleServicing

Method new() Constructor 
Method load(obj)
Method loadHistory(Obj, nType)
Method loadHistDetail(oObj, cCodMaster)

EndClass
            
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Michel W. Mosca  � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class TeleServicingCodebase     
Return Self     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOAD      �Autor  �Michel W. Mosca     � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �														      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(obj) Class TeleServicingCodebase  
Local lRet := .T.         
Local cAlias :=	"SKA" 

DbSelectArea(cAlias)
DbSetOrder(1) //KA_FILIAL+KA_CODIGO
If DbSeek(xFilial(cAlias)+obj:id)
	Self:fillClass(obj, cAlias) 
	DbSelectArea(cAlias)
	DbCloseArea()     
	cAlias := "SKB"
	DbSelectArea(cAlias)
	DbSetOrder(1)//KB_FILIAL+KB_CODTELE
	If DbSeek(xFilial(cAlias)+obj:id)
		Self:fillRelations(obj, cAlias)	
	EndIf
Else
	lRet := .F.
EndIF

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �loadHistor�Autor  �Vendas Clientes     � Data �  07/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que carrega os dados do Historico (codebase).       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadHistory(Obj, nType) Class TeleServicingCodebase  
Local cContactField := Obj:contactField:name			//Nome do campo de Contato 
Local cEntityField := Obj:entityName:name				//Nome do campo da Entidade
Local cEntityKey := Obj:entityKey:name					//Nome do campo Valor da Entidade
Local cCodContact	:= M->&(cContactField)				//Codigo do contato
Local cCodEntity	:= M->&(cEntityField)				//Codigo da Entidade             
Local cCodEntKey	:= M->&(cEntityKey)					//Valor da Entidade
Local cAliasMaster	:= Obj:master:alias					//Alias da tabela Master
Local cCpoFilial	:= Obj:master:BranchField:name		//Nome do campo Filial na tab. Master
Local aMaster 		:= {}								//Array de retorno dos dados resultantes da query
Local aSelFields	:= {}								//Array com os campos usados na query
Local cAlias 		:= GetNextAlias() 					//Alias temporario usado na query
Local nCount		:= 0
Local nFields		:= 0

For nCount := 1 To Len(Obj:master:fields)
	aAdd(aSelFields, Obj:master:fields[nCount]) 
Next nCount

cArqInd	:= CriaTrab(,.F.)

cQuery	:= cCpoFilial + "=='" + xFilial(cAliasMaster)+"'"
If nType == 1
	cQuery	+= ".AND. " + cContactField + "=='" + cCodContact + "'"
Else	
	cQuery 	+= ".AND. " + cEntityField + "=='" + cCodEntity + "'" 
	cQuery	+= ".AND. " + cEntityKey +   "=='" + cCodEntKey + "'" 		
EndIf

DbSelectArea(cAliasMaster)
DbSetOrder(Obj:master:iIdx)
cKey := (cAliasMaster)->(IndexKey())

IndRegua(cAliasMaster, cArqInd, cKey,, cQuery)
DbGotop()

DbSelectArea(cAliasMaster)
While ( !Eof() .AND. &cCpoFilial == xFilial(cAliasMaster) )

	aAdd(aMaster, Array( Len(aSelFields) ) )
	nLin := Len(aMaster)
	
	For nFields := 1 To Len(aSelFields)
		aMaster[nLin][nFields] := (cAliasMaster)->&(aSelFields[nFields]:name)
    Next nFields

	(cAliasMaster)->(DbSkip())
	//IncRegua()
End

dbSelectArea(cAliasMaster)
RetIndex(cAliasMaster)

Return aMaster


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �loadHistDe�Autor  �Vendas Clientes     � Data �  12/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que carrega os dados da tabela detalhe do Historico ���
���          � de Atendimento (Codebase)                                  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadHistDetail(oObj, cCodMaster) Class TeleServicingCodebase
Local cAliasDetail	:= oObj:service:tableStructureInfo:detail:alias				//Alias da tabela Detail
Local cCpoFilial	:= oObj:service:tableStructureInfo:detail:BranchField:name	//Nome do campo Filial
Local cAlias		:= GetNextAlias() 											//Alias da query
Local cFields		:= ""														//Armazena os campos da query
Local aSelFields	:= {}														//Array com os campos usados na query
Local nCount		:= 0
Local nFields		:= 0

//Pega o nome do campo p/ usar na comparacao com o codigo do chamado da tab. master
cCodField := oObj:service:tableStructureInfo:detail:fields[2]:name

For nCount := 1 To Len(oObj:service:tableStructureInfo:detail:fields)
	aAdd(aSelFields,oObj:service:tableStructureInfo:detail:fields[nCount]) 
Next nCount

cArqInd	:= CriaTrab(,.F.)

cQuery	:= cCpoFilial + "=='" + xFilial(cAliasDetail)+"'"
cQuery	+= ".AND. " + cCodField + "=='" + cCodMaster + "'"

DbSelectArea(cAliasDetail)
DbSetOrder(oObj:service:tableStructureInfo:detail:iIdx)
cKey := (cAliasDetail)->(IndexKey())

IndRegua(cAliasDetail, cArqInd, cKey,, cQuery)
DbGotop()

//��������������������������������������������������Ŀ
//� Prepara o array aDetail com o resultado da query �
//����������������������������������������������������
aDetail := {}
nLin	:= 0
While ( (cAliasDetail)->(!Eof()) .AND. &cCpoFilial == xFilial(cAliasDetail) )

	aAdd(aDetail, Array( Len(aSelFields) ) )
	nLin := Len(aDetail)
	
	For nFields := 1 To Len(aSelFields)
		aDetail[nLin][nFields] := (cAliasDetail)->&(aSelFields[nFields]:name)
    Next nFields
    
	(cAliasDetail)->(DbSkip())
End 

DbSelectArea(cAliasDetail)
RetIndex(cAliasDetail)
FErase(cArqInd+OrdBagExt())	

Return aDetail


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA500      �Autor  �Michel W. Mosca � Data �  09/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA505A()
RETURN NIL
