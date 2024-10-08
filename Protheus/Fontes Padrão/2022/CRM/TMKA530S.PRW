#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA530S.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SLAService�Autor  �Vendas Clientes     � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Classe que descreve um servico de SLA   					  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class SLAService
Data serviceCode
Data serviceName
Data severity
Data showDialog
Data entities
Data oSLARegister 

Method new() Constructor                 
Method load(serviceCode)
Method find()
Method save()
Method start(codProtheusUser, funcName, cTimeShift, cDtInicioSLA, cHrInicioSLA, nTimePaused, lReproSLA, cDtExpRepro, cHrExpRepro)
Method update(codProtheusUser, SLAregister, cTimeShift, nForcePause, lReproSLA)
Method pause(codProtheusUser, SLAregister, cTimeShift)
Method finish(SLAregister)
Method getRegisterID()
Method getRegStatus()
Method getRegPaused()
Method getDateToExpire()
Method getSeverity() 
Method free()

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �New          �Autor  � Vendas Clientes � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe SLAService                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class SLAService
Self:serviceCode	:= ""
Self:serviceName	:= ""
Self:severity		:= ""
Self:showDialog		:= ""
Self:entities		:= {}
Self:oSLARegister	:= SLARegister():New()

Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �load      �Autor  �Vendas Clientes     � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que aciona a operacao de carregar o servico de      ���
���          � SLA especificado no parametro serviceCode                  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(serviceCode) Class SLAService
Local lRet		:= .T.			//Variavel de retorno do metodo
Local cAlias	:= "SUI"		//Alias do arquivo de Servicos SLA
Local oEntity 					//Objeto da classe SLAEntity
Local aArea		:= GetArea()
Local cCampoAux := "%UI_NOME"

If cPaisloc <> "BRA"
	Do Case 
		Case cPaisLoc $ "ARG|BOL|CHI|COL|COS|DOM|MEX|PAN|PAR|PER|POR|SAL|URU|VEN"
			cCampoAux += 'SPA'
		Case cPaisLoc $ "EUA"
			cCampoAux += 'ENG'
		Case cPaisLoc $ "ANG|EQU|HAI|PTG"	
			cCampoAux += 'PTG'
	EndCase
EndIf
cCampoAux +="%"	
//������������������������������������Ŀ
//� Localiza o Servico de SLA 		   �
//��������������������������������������
#IFDEF TOP
	cAlias := GetNextAlias()
	BeginSQL alias cAlias
		SELECT 	UI_CODIGO,		%Exp:cCampoAux% UI_NOME, 
				UI_SEVERI, 		UI_CONFIR
		FROM	%table:SUI% SUI
		WHERE	SUI.UI_FILIAL = %xFilial:SUI% AND 	
				SUI.%NOTDEL% AND
				SUI.UI_CODIGO = %EXP:serviceCode%
	EndSql               
	
#ELSE

	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbSeek(xFilial(cAlias) + serviceCode)
	
#ENDIF

//������������������������������������Ŀ
//� Carrega os dados do Servico de SLA �
//��������������������������������������
If (cAlias)->(!Eof())

	Self:serviceCode	:= (cAlias)->UI_CODIGO
	Self:serviceName	:= (cAlias)->UI_NOME  
	If !Empty((cAlias)->UI_SEVERI)
		//Executa a formula da Severidade
		Self:severity	:= &(Eval(&("{||'" + (cAlias)->UI_SEVERI + "'}"), ""))
	EndIf
	Self:showDialog		:= (cAlias)->UI_CONFIR

	DbSelectArea("SUJ")
	DbSetOrder(1)
	DbSeek(xFilial("SUJ") + (cAlias)->UI_CODIGO, .T.)
	While SUJ->(!Eof()) .AND. SUJ->UJ_FILIAL == xFilial("SUJ") .AND.;
						SUJ->UJ_CODIGO == (cAlias)->UI_CODIGO
	    
		oEntity := SLAEntity():New()
		oEntity:entityName := SUJ->UJ_ENTIDA
		If !Empty(SUJ->UJ_VALOR)
			oEntity:entityValue := &(Eval(&("{||'" + SUJ->UJ_VALOR + "'}"), ""))
		EndIf              		
		
		aAdd(Self:entities, oEntity)	
		
		SUJ->(DbSkip())
	End	


Else 
	Self:serviceCode := ""
	lRet := .F.
EndIf


#IFDEF TOP
	DbSelectArea(cAlias)
	DbCloseArea()     	
#ENDIF

RestArea(aArea)
Return lRet  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �find      �Autor  �Vendas Clientes     � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que aciona a operacao de busca por um contrato de   ���
���          � SLA que atenda as condicoes estabelecidas no Servico SLA   ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method find( cTimeShift ) Class SLAService
Local lRet		:= .F.			//Variavel de retorno do metodo
Local cSLA		:= ""			//Codigo do SLA

//Efetua a busca por um contrato de SLA
cSLA := Self:oSLARegister:findSLA( Self:entities )

If !Empty(cSLA)
	If Self:oSLARegister:findSeverity(cSLA, Self:severity, Self:showDialog, cTimeShift)
		lRet := .T.
	Else
		If !IsBlind()
			MsgAlert(STR0001 + cSLA, STR0002) //"Nao foi possivel encontrar as severidades, favor verificar o contrato de SLA: " # "Aten��o"
		Else
			ConOut(STR0001 + cSLA) //"Nao foi possivel encontrar as severidades, favor verificar o contrato de SLA: "
		EndIf
	EndIf

Else
	If !IsBlind()
		MsgAlert(STR0003+ Self:serviceName, STR0002) //"Nao foi possivel encontrar um contrato de SLA adequado ao Servico " # "Aten��o"
	Else
		ConOut(STR0003+ Self:serviceName) //"Nao foi possivel encontrar um contrato de SLA adequado ao Servico "
	EndIf

EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �save      �Autor  �Vendas Clientes     � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo que aciona a operacao de salvar o registro de SLA   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save() Class SLAService
Local lRet := .F.			//Variavel de retorno do metodo

lRet := Self:oSLARegister:save()

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �start			�Autor  �Vendas Clientes � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicia um novo registro de SLA                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Method start(codProtheusUser, funcName, cTimeShift, cDtInicioSLA, cHrInicioSLA, nTimePaused, lReproSLA, cDtExpRepro, cHrExpRepro) Class SLAService
Local lRet := .T.			//Variavel de retorno do metodo
Default funcName := ""  

//��������������������������������������������������������������������������������Ŀ
//�Data e Hora de Inicio do SLA sao recebidos e passados por valor para suporte aos�
//�casos de transferencia de chamados entre filiais. Sera criado um novo registro  �
//�com base no contrato de SLA da filial destino mas serao mantidos a data, a hora �
//�inicial assim como o montante de tempo de pausa passados pela filial origem.    �
//����������������������������������������������������������������������������������
lRet := Self:oSLARegister:start(::entities, ::severity, codProtheusUser, funcName, cTimeShift, cDtInicioSLA, cHrInicioSLA, nTimePaused, lReproSLA, cDtExpRepro, cHrExpRepro)
If !lRet
	If !IsBlind()
		MsgAlert(STR0004, STR0002) //"Nao foi possivel iniciar o registro de SLA" # "Aten��o"
	Else
		ConOut(STR0004) //"Nao foi possivel iniciar o registro de SLA"
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �update		�Autor  �Vendas Clientes � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza o registro de SLA								  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method update(codProtheusUser, SLAregister, cTimeShift, nForcePause, lReproSLA) Class SLAService
Local lRet		:= .T.								//Variavel de retorno do metodo
Local nSeverid	:= Self:oSLARegister:severityCode	//Nova severid. escolhida
Local cNovoSLA	:= Self:oSLARegister:SlaFound		//Novo contrato SLA encontrado
Default lReproSLA := .F.	// Indica se houve uma reprograma��o no prazo do SLA no chamado

If lReproSLA .AND. Empty(cNovoSLA)
	cNovoSLA := Self:ServiceCode
EndIf

//�������������������������������������������������Ŀ
//� Carrega no objeto os dados do registro do SLA  e�
//� inicia a atualizacao do registro a partir do    �
//� novo SLA/severidade encontrado                  �
//���������������������������������������������������
If Self:oSLARegister:load(SLAregister) .AND. (Self:getRegStatus() <> "2" .OR. (Self:getRegStatus() == "2" .And. Self:getRegPaused()))
	lRet := Self:oSLARegister:update(::entities, nSeverid, codProtheusUser, cNovoSLA, , cTimeShift, nForcePause, lReproSLA)
Else
	ConOut(STR0005 + SLAregister) //"Nao foi possivel carregar o registro de SLA "
	lRet := .F.
Endif

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �update		�Autor  �Vendas Clientes � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza o registro de SLA								  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method pause(codProtheusUser, SLAregister, cTimeShift) Class SLAService
Local lRet		:= .T.								//Variavel de retorno do metodo
Local nSeverid	:= 0	//Self:oSLARegister:severityCode	//Nova severid. escolhida
Local cNovoSLA	:= ""	//Self:oSLARegister:SlaFound		//Novo contrato SLA encontrado

//�������������������������������������������������Ŀ
//� Carrega no objeto os dados do registro do SLA  e�
//� inicia a atualizacao do registro a partir do    �
//� novo SLA/severidade encontrado                  �
//���������������������������������������������������
If Self:oSLARegister:load(SLAregister) .AND. Self:getRegStatus() <> "2"
	nSeverid	:= Self:oSLARegister:severityCode
	cNovoSLA	:= Self:oSLARegister:SlaFound
	lRet := Self:oSLARegister:pause(::entities, nSeverid, codProtheusUser, cNovoSLA, , cTimeShift)
Else
	ConOut(STR0005 + SLAregister) //"Nao foi possivel carregar o registro de SLA "
	lRet := .F.
Endif

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �finish		�Autor  �Vendas Clientes � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Encerra registro de SLA e processos relacionados            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method finish(SLAregister) Class SLAService
Local lRet := .T.			//Variavel de retorno do metodo

lRet := Self:oSLARegister:load(SLAregister) .AND. (Self:getRegStatus() <> "2" .OR. Self:getRegPaused())

//Chama o metodo de finalizacao da Classe de Registro de SLA
If lRet
	Self:oSLARegister:finish()
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �getRegisterID	�Autor  �Vendas Clientes � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o ID do registro de SLA 					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method getRegisterID() Class SLAService
Local cRegisterID := Self:oSLARegister:registerID

Return cRegisterID

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �getRegStatus	�Autor  �Vendas Clientes � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o Status do registro de SLA 					      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method getRegStatus() Class SLAService
Local cStatus := Self:oSLARegister:StatusRegister

Return cStatus

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �getRegStatus	�Autor  �Vendas Clientes � Data �  28/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o Status do registro de SLA 					      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method getRegPaused() Class SLAService
Local lPaused := Self:oSLARegister:Paused

Return lPaused

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �getDateToExpir�Autor  �Vendas Clientes � Data �  30/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a data p/ expirar o registro de SLA				  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method getDateToExpire() Class SLAService
Local dDateExpire := If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
dDateExpire := Self:oSLARegister:dateToExpire

Return dDateExpire

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �getSeverity	�Autor  �Vendas Clientes � Data �  30/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a severidade do registro de SLA				 	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method getSeverity() Class SLAService
Local nSeverid := Self:oSLARegister:severityCode

Return nSeverid

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �free       	�Autor  �Vendas Clientes � Data �  30/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Libera a mem�ria dos objetos utilizados.    			 	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method free() Class SLAService
TMKFree( Self:entities )
TMKFree( Self:oSLARegister )
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA530S     �Autor  �Vendas Clientes � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA530S()
RETURN NIL
