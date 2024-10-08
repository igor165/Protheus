#INCLUDE "TMKA520.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �WFInformat�Autor  �Vendas Clientes     � Data �  06/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel pelo processo de execucao e controle de  ���
���          �WorkFlow Informativo.                                       ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class WFInformation	
Data id							//Codigo de identificacao do workflow
Data codProtheusUser			//Codigo do usuario no Protheus
Data emailUser					//E-mail do usuario
Data subject					//Assunto do WF
Data userInfo					//Informacoes do usuario
Data Body						//Corpo do e-mail
Data HtmlFile					//Arquivo HTML (opcional)
Data cCC						//E-mails que receberao copia 
Data cBCC						//E-mails que receberao copia oculta
Data codeBlockWhenReplied		//Bloco de codigo a executar quando WF for respondido
Data internalID					//Codigo interno gerado pelo componente do WF
Data oPersist           		//Classe de acesso ao banco de dados
Data oProcess					//Classe do componente Padrao TWFProcess
Data Header						//Cabecalho do WF Informativo
Data Itens						//Itens que podem ser adicionados ao WF Informativo
Data wfType						//Tipo de Workflow (1=Informativo ou 2=Autorizacao)
Data cProcessedTo				//Destinat�rio
Data cLoteApr					//Lote de aprova��o
Data cModelo					//Modelo de workflow utilizado
Data dDate                      //Data de envio
Data cTime						//Hora de envio

Method new() Constructor
Method prepare(codProtheusUser, emailUser, subject, Body, HtmlFile, cCC, cBCC)
Method setCodeBlockWhenReplied(cCodeBlock)
Method start()
Method stop()
Method load(id)
Method save()
Method delete()
Method addRow(oWFItem)
Method createPersist()
Method attachFile(cArquivo)
Method Initialize()   
Method Free()

EndClass


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �New          �Autor  � Vendas Clientes � Data �  06/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe  WFInformation.                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class WFInformation
Self:id						:= ""
Self:codProtheusUser		:= ""
Self:emailUser				:= ""
Self:subject				:= ""
Self:userInfo				:= ""
Self:Body					:= ""
Self:HtmlFile				:= ""
Self:cCC					:= ""
Self:cBCC					:= ""
Self:CodeBlockWhenReplied	:= TSEntrancePoint():new()
Self:internalID				:= ""
Self:oPersist				:= Self:createPersist()
Self:Header					:= WFRow():New()
Self:Itens					:= {}
Self:wfType					:= 1
Self:cProcessedTo			:= ""
Self:cLoteApr				:= ""
Self:cModelo				:= ""
Self:dDate					:= dDatabase
Self:cTime					:= Time()
Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �prepare      �Autor  � Vendas Clientes � Data �  10/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Preparar o envio do Workflow e a criacao dos objetos utili- ���
���          �zados no envio do Workflow	                              ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method prepare(codProtheusUser, emailUser, subject, Body, HtmlFile, cCC, cBCC) Class WFInformation
Local cTableHeader 		:= ""
Local cTableItens		:= ""  
Local nFields			:= 0
Local nI				:= 0

Self:codProtheusUser	:= codProtheusUser
Self:emailUser			:= emailUser
Self:subject			:= subject
Self:Body				:= IIf(!Empty(Body),Body,"")
Self:HtmlFile			:= IIf(!Empty(HtmlFile), HtmlFile, "WFW520.htm")
Self:cCC				:= cCC
Self:cBCC				:= cBCC

//�����������������������������������������Ŀ
//� Utiliza o componente padrao TWFProcess  �
//�������������������������������������������
//oProcess	:= TWFProcess():New(/*cCodProcess*/,/*cDescrProcess*/)
Self:oProcess	:= TWFProcess():New('000001', STR0001)			//'WF Informativo'
Self:oProcess:NewTask(STR0002, "\workflow\"+Self:HtmlFile)		//"Preparando WorkFlow Informativo"

Self:oProcess:cTo		:= Self:emailUser
Self:oProcess:cSubject	:= Self:subject
Self:oProcess:cBody		:= Self:Body
Self:oProcess:cCC 		:= Self:cCC
Self:oProcess:cBCC 		:= Self:cBCC

oHtml := Self:oProcess:oHTML

//��������������������������������������������������Ŀ
//� Preenche a tabela do HTML com os dados do Header �
//����������������������������������������������������
For nFields := 1 To Len(Self:Header:Fields)
	cName 	:= Self:Header:Fields[nFields]:name
	cValue	:= Self:Header:Fields[nFields]:value
	If ValType(cValue) == "D"
		cValue := DTOC(cValue)
	EndIf 
	If ValType(cValue) == "C"
	    cTableHeader+= '<tr>'+Chr(13)+Chr(10)
	    cTableHeader+= '<td width="25%" class="TituloMenor"><b>'+HTMLEnc(cName)+'</b></td>'+Chr(13)+Chr(10)
		cTableHeader+= '<td width="75%" class="texto" colspan="3">'+HTMLEnc(cValue)+'</td>'+Chr(13)+Chr(10)
	    cTableHeader+= '</tr>'+Chr(13)+Chr(10)
	 EndIf
Next nFields              

//Finalizacao do Header do HTML
cTableHeader+= '<tr>'+Chr(13)+Chr(10)
cTableHeader+= '<td colspan="4" class="TituloMenor" background="pontilhado.gif">'+Chr(13)+Chr(10)
cTableHeader+= '<img src="transparente.gif" width="10" height="3"></td>'+Chr(13)+Chr(10)
cTableHeader+= '</tr>'+Chr(13)+Chr(10)
cTableHeader+= '<tr>'+Chr(13)+Chr(10)
cTableHeader+= '<td class="TituloMenor">&nbsp;</td>'+Chr(13)+Chr(10)
cTableHeader+= '<td class="texto">&nbsp;</td>'+Chr(13)+Chr(10)
cTableHeader+= '<td class="TituloMenor">&nbsp;</td>'+Chr(13)+Chr(10)
cTableHeader+= '<td class="texto">&nbsp;</td>'+Chr(13)+Chr(10)
cTableHeader+= '</tr>'

//�������������������������������������������������������������Ŀ
//� Monta o cabecalho com os campos dos itens da tabela			�
//���������������������������������������������������������������
If Len(Self:Itens) > 0
	cTableItens += '<tr class="TituloMenor">'+Chr(13)+Chr(10)
	For nFields := 1 To Len( Self:Itens[1]:fields )
		cName := Self:Itens[1]:fields[nFields]:name
		cTableItens += '<td height="14" class="TituloMenor"><div align="center">'+HTMLEnc(cName)+'</div></td>'+Chr(13)+Chr(10)
	Next nFields
	cTableItens += '</tr>'+Chr(13)+Chr(10)
EndIf
	
//��������������������������������������������������Ŀ
//� Preenche a tabela do HTML com os dados dos Itens �
//����������������������������������������������������
For nI := 1 To Len(Self:Itens)
	cTableItens += '<tr class="texto">'+Chr(13)+Chr(10)
	
	For nFields := 1 to Len( Self:Itens[nI]:fields )
		cValue	:= Self:Itens[nI]:fields[nFields]:value
		If ValType(cValue) == "D"
			cValue := DTOC(cValue)
		EndIf   
		If ValType(cValue) == "C"		
			cTableItens += '<td height="14" class="texto"><div align="center">'+HTMLEnc(cValue)+'</div></td>'+Chr(13)+Chr(10)
		EndIf
	Next nFields
	
	cTableItens += '</tr>'+Chr(13)+Chr(10)
Next nI

cTableItens += '<tr>'+Chr(13)+Chr(10)
cTableItens += '<td colspan="8" class="texto" background="pontilhado.gif" height="1">&nbsp;</td>'+Chr(13)+Chr(10)
cTableItens += '</tr>'+Chr(13)+Chr(10)
	
If oHtml:ExistField(1, "CABEC")
	oHtml:ValByName("CABEC",  Self:Body	)
EndIf
If oHtml:ExistField(1, "HEADER")
	oHtml:ValByName("HEADER", cTableHeader)
EndIf
If oHtml:ExistField(1, "ITENS")
	oHtml:ValByName("ITENS",  cTableItens)
EndIf

Self:internalID	:= Self:oProcess:fProcessID + Self:oProcess:fTaskID

Return 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �setCodeBlockW�Autor  � Vendas Clientes � Data �  10/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Acao a ser executada quando o destinatario responde o       ���
���          �Workflow.                                                	  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method setCodeBlockWhenReplied(cCodeBlock) Class WFInformation
Local lRet := FindFunction(cCodeBlock)
If lRet
	Self:CodeBlockWhenReplied := cCodeBlock
EndIf
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �start        �Autor  � Vendas Clientes � Data �  10/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Envia o Workflow ao destinatario. Executado apos a prepara- ���
���          �cao do envio do Workflow	                            	  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method start() Class WFInformation
Local cMailID		:= ""
Local cHttpServer	:= "http://" + AllTrim( WFGetMV( "MV_WFBRWSR", "127.0.0.1:80" ) ) + "/"
Local cPasta		:= "aprovador"

cMailID := Self:oProcess:Start()

If File("\workflow\copia\"+cMailID)
	Conout(STR0003)		//"Arquivo HTML copiado com sucesso"
EndIf

//��������������������������������������������Ŀ
//� Quando for Workflow de Autorizacao	       �
//����������������������������������������������
If ( Self:wfType == 2 )

	Self:oProcess:NewTask(Self:subject, "\workflow\wflink.htm")
	Self:oProcess:cSubject	:= Self:subject
	Self:oProcess:cTo 		:= Self:emailUser
	
	Self:oProcess:ohtml:ValByName("usuario", "Aprovador")
	Self:oProcess:ohtml:ValByName("referente", Self:subject)
	
	If WFGetMV("MV_WFWEBEX", .F.)
		//WEBEX
		Self:oProcess:ohtml:ValByName("proc_link", cHttpServer + "workflow/w_wfhttpret.apw?ProcID=" + cPasta + "/" + cMailID + ".htm")
	Else       
		//Messenger
		Self:oProcess:ohtml:ValByName("proc_link", cHttpServer + "messenger/emp" + cEmpAnt + "/" + cPasta + "/" + cMailID + ".htm")
	EndIf
	
	Self:oProcess:Start()

EndIf

Return 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �stop         �Autor  � Vendas Clientes � Data �  10/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Encerra o controle de resposta do Workflow e remove da fila ���
���          �de espera                                               	  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method stop() Class WFInformation
Self:oProcess:Finish()
Return 
  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �load         �Autor  � Vendas Clientes � Data �  10/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Carregar um Workflow                                       ���
���          �                            		                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(id) Class WFInformation
Local lRet := .F.

Self:id := id
lRet := Self:oPersist:load(Self)
If !lRet 
	Self:id := ""
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �save         �Autor  � Vendas Clientes � Data �  10/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Insere ou atualiza um Workflow                              ���
���          �                                                       	  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save() Class WFInformation
Local lRet := .F.

lRet := Self:oPersist:save(Self) 

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Metodo   �delete       �Autor  � Vendas Clientes � Data �  10/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Apaga um Workflow                                           ���
���          �                          	                              ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method delete() Class WFInformation
Local lRet := .F.

lRet := Self:oPersist:delete(Self)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �createPersist �Autor  � Vendas Clientes� Data �  14/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a classe de acesso a banco de dados.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method createPersist() Class WFInformation
Local obj

#IFDEF TOP
	obj := WFInformationTop():New()
#ELSE
	obj := WFInformationCodebase():New()
#ENDIF

Return obj                                  
  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �addRow        �Autor  � Vendas Clientes� Data �  19/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adiciona uma nova linha (Itens do WF) 					  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method addRow(oWFItem) Class WFInformation
Local lCont := .T.

//�����������������������������������������������������������������Ŀ
//� Verificar se o item tem a mesma estrutura de campos do anterior �
//�������������������������������������������������������������������
If Len(Self:Itens) > 0 
	nFieldsNumber := Len(Self:Itens[1]:fields)
	If Len(oWFItem:Fields) <> nFieldsNumber
		MsgAlert(STR0004 + Str(nFieldsNumber,3) + STR0005 + CHR(13)+CHR(10)+;	//"Nr. de campos adicionados diferente do formato anterior de: " ## " campos."
				STR0006, "AddRow")												//"N�o ser� possivel adicionar esta linha"
		lCont := .F.
	EndIf
EndIf
	
If lCont
	aAdd(Self:Itens, oWFItem)
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Initialize    �Autor  � Vendas Clientes� Data �  21/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa/cria os atributos da classe WFInformation que    ���
���          �serao utilizados pela Classe WFAuthorization                ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Initialize() Class WFInformation
Self:id						:= ""
Self:codProtheusUser		:= ""
Self:emailUser				:= ""
Self:subject				:= ""
Self:userInfo				:= ""
Self:Body					:= ""
Self:HtmlFile				:= ""
Self:cCC					:= ""
Self:cBCC					:= ""
Self:CodeBlockWhenReplied	:= TSEntrancePoint():new()
Self:internalID				:= ""
Self:oPersist				:= Self:createPersist()
Self:Header					:= WFRow():New()
Self:Itens					:= {}
Self:wfType					:= 2
Self:cProcessedTo			:= ""
Self:cLoteApr				:= ""
Self:cModelo				:= ""
Self:dDate					:= dDatabase
Self:cTime					:= Time()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �attachFile   �Autor  �Vendas Cliente   � Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inclui anexo para ser enviado junto ao Workflow.            ���
���          �                                                            ��� 
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method attachFile(cArquivo) Class WFInformation
Local lRet := .F.

	If ValType(Self:oProcess)<>"U"
		lRet := Self:oProcess:AttachFile(cArquivo)
	EndIf

Return lRet  

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
Method Free() Class WFInformation

TMKFree( Self:CodeBlockWhenReplied )
TMKFree( Self:oPersist )
TMKFree( Self:Header )
TMKFree( Self:Itens )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA520      �Autor  �Vendas Clientes � Data �  06/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA520()
RETURN NIL
